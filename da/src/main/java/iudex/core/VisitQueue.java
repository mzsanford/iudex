package iudex.core;

import java.util.HashMap;
import java.util.Map;
import java.util.PriorityQueue;


/**
 * 
 * The readyHosts queue is prioritized by the top FetchOrder in each ready host.
 * The sleeping host queue is prioritize by least next visit. 
 */
public class VisitQueue
{
    //FIXME: List<VisitOrder> with common host orders instead?
    public synchronized void add( VisitOrder order )
    {
        String host = order.url().host();
        HostQueue queue = _hosts.get( host );
        boolean isNew = false;
        
        if( queue == null ) {
            queue = new HostQueue( host );
            isNew = true;
        }
        
        queue.add( order ); 

        if( isNew ) {
            _hosts.put( host, queue );
            _readyHosts.add( queue );  
        }

        ++_size;
        notifyAll();
    }

    public synchronized int size()
    {
        return _size;
    }
    
    public synchronized HostQueue take() throws InterruptedException
    {
        HostQueue ready = null;
        while( ( ready = _readyHosts.poll() ) == null ) {
            final long now = System.currentTimeMillis();
            
            HostQueue next = null;
            while( ( next = _sleepHosts.peek() ) != null ) {
                if( ( now - next.nextVisit() ) >= 0 ) {
                    _readyHosts.add( _sleepHosts.remove() );
                }
                else break;
            }
            if( _readyHosts.isEmpty() ) {
                long delay = 
                    ( next == null ) ? 0 : ( next.nextVisit() - now + 1 );
                wait( delay );
            }
        }
        return ready;
    }
    
    public synchronized void untake( HostQueue queue )
    {
        --_size;
        if( queue.size() == 0 ) {
            _hosts.remove( queue.host() );
        }
        else {
            _sleepHosts.add( queue );
            notifyAll();
        }
    }
    
    private final Map<String,HostQueue> _hosts = 
        new HashMap<String,HostQueue>(); 
    
    private int _size = 0;

    private PriorityQueue<HostQueue> _readyHosts = 
        new PriorityQueue<HostQueue>
            ( 1024, new HostQueue.TopOrderComparator() );

    private PriorityQueue<HostQueue> _sleepHosts = 
        new PriorityQueue<HostQueue>
            ( 128, new HostQueue.NextVisitComparator() );

}