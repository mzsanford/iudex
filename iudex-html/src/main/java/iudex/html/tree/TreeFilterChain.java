/*
 * Copyright (c) 2008-2012 David Kellum
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

package iudex.html.tree;

import java.util.ArrayList;
import java.util.List;

import static iudex.html.tree.TreeFilter.Action.*;

import com.gravitext.xml.tree.Node;

public class TreeFilterChain
    implements TreeFilter
{
    public TreeFilterChain( List<TreeFilter> filters )
    {
        _filters = new ArrayList<TreeFilter>( filters );
    }

    public List<? extends TreeFilter> children()
    {
        return _filters;
    }

    public Action filter( final Node node )
    {
        Action action = CONTINUE;
        for( TreeFilter filter : _filters ) {
            action = filter.filter( node );
            if( action != CONTINUE ) break;
        }
        return action;
    }

    private final ArrayList<TreeFilter> _filters;
}
