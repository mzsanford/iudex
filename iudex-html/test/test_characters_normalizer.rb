#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2010 David Kellum
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You
# may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#++

require File.join( File.dirname( __FILE__ ), "setup" )

class TestCharactersNormalizer < MiniTest::Unit::TestCase
  include HTMLTestHelper

  include Iudex::HTML
  include Iudex::HTML::Filters
  include Iudex::HTML::Tree
  include Iudex::HTML::Tree::Filters
  include Gravitext::HTMap
  include Iudex::Core
  include Iudex::Filter::Core

  UniMap.define_accessors

  Order = HTMLTreeFilter::Order

  def test_simple_block
    # Note: '~' is padding removed in compare

    html = { :in  => "<p> x  y </p>",
             :out => "<p>~x ~y~</p>" }

    assert_normalize( html )
  end

  def test_simple_inline
    html = { :in  => "<i> x  y </i>",
             :out => "<i> x ~y </i>" }

    assert_normalize( html )
  end

  def test_mixed_inline
    html = { :in  => "<p> x  y <i>z </i> </p>",
             :out => "<p>~x ~y <i>z </i>~</p>" }

    assert_normalize( html )
  end

  def test_empty
    html = { :in  => "<div><p> </p>  <p>foo</p> </div>",
             :out => "<div><p/>~~~~~~<p>foo</p>~</div>" }

    assert_normalize( html )
  end

  def test_pre
    html = { :in  => "<div> x <pre>  \0x\n <a>  y </a></pre> </div>",
             :out => "<div>~x~<pre>  ~ x\n <a>  y </a></pre>~</div>" }

    assert_normalize( html )
  end

  def assert_normalize( html )
    [ Order::BREADTH_FIRST, Order::DEPTH_FIRST ].each do |order|
      map = content( html[ :in ] )
      tfc = TreeFilterChain.new( [ CharactersNormalizer.new ] )
      tf = HTMLTreeFilter.new( :source_tree.to_k, tfc, order )
      chain = filter_chain( tf  )
      assert( chain.filter( map ) )
      assert_fragment_ws( html[ :out ], inner( map.source_tree ), true )
    end
  end

  def content( html, charset = "UTF-8" )
    map = UniMap.new
    map.source = HTMLUtils::source( html.to_java_bytes, "UTF-8" )
    map
  end

  def filter_chain( *filters )
    pf = HTMLParseFilter.new( :source.to_k, nil, :source_tree.to_k )
    pf.parse_as_fragment = true
    filters.unshift( pf )
    FilterChain.new( "test", filters )
  end

end
