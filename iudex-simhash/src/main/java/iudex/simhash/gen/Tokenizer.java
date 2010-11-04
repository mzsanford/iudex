/*
 * Copyright (c) 2010 David Kellum
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you
 * may not use this file except in compliance with the License.  You may
 * obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied.  See the License for the specific language governing
 * permissions and limitations under the License.
 */

package iudex.simhash.gen;

import iudex.util.Characters;

import java.nio.CharBuffer;
import java.util.Iterator;

/**
 * Tokenize a CharBuffer on (HTML-recognized) whitespace. Input
 * CharBuffer should be control-char normalized prior.
 *
 * <h2>Implementation Notes</h2>
 *
 * This tokenizer makes no attempt to fully normalize tokens as words.
 * Tokens are not case folded, nor is common punctuation removed.
 *
 * @see iudex.util.Characters
 */
public final class Tokenizer
    implements Iterator<CharBuffer>
{
    /**
     * Construct given input CharBuffer which will be consumed as
     * tokenized (may be prudent to duplicate first.)
     */
    public Tokenizer( CharBuffer in )
    {
        _in = in;
    }

    @Override
    public boolean hasNext()
    {
        if( _next == null ) {
            if( _in.hasRemaining() ) {
                scan();
                return ( _next != null );
            }
            else return false;
        }
        return true;
    }

    @Override
    public CharBuffer next()
    {
        if( hasNext() ) {
            CharBuffer n = _next;
            _next = null;
            return n;
        }
        throw new IllegalStateException( "next() without hasNext()" );
    }

    @Override
    public void remove()
    {
        throw new UnsupportedOperationException( "Tokenizer.remove()" );
    }

    private void scan()
    {
        int pos = _in.position();
        final int end = _in.limit();
        int start = -1;

        while( pos < end ) {
            if( isWS( _in.get( pos ) ) ) {
                if( start >= 0 ) break;
            }
            else if( start < 0 ) start = pos;

            ++pos;
        }

        if( start >= 0 && start < pos ) {
            _next = _in.duplicate();
            _next.position( start );
            _next.limit( pos );
            _in.position( ( pos < end ) ? pos + 1 : end );
        }
    }

    private boolean isWS( final char c )
    {
        // Specific characters to be treated as whitespace/token boundaries.

        switch( c ) {

        // Drop all double-quote forms, as dups could be rendered with smart
        // vs plain forms.
        case 0x0022: // [ " ]
        case 0x201C: // [ “ ]
        case 0x201D: // [ ” ]

        // Same with single quotes. Note this will orphan 's, 't, etc. in
        // English.
        case 0x0027: // [ ' ]
        case 0x2018: // [ ‘ ]
        case 0x2019: // [ ’ ]

        // Same for ASCII DASH vs Unicode EM DASH and friends.
        case 0x002D: // [ - ]
        case 0x2010: // [ ‐ ]
        case 0x2011: // [ ‑ ]
        case 0x2012: // [ ‒ ]
        case 0x2013: // [ – ]
        case 0x2014: // [ — ]
        case 0x2015: // [ ― ]

            return true;
        }

        // And the HTML whitespace set.
        return Characters.isHTMLWS( c );
    }

    private final CharBuffer _in;
    private CharBuffer _next = null;
}
