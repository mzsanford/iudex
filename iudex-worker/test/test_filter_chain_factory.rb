#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2008-2012 David Kellum
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

require 'iudex-httpclient-3'

require 'iudex-da'
require 'iudex-da/pool_data_source_factory'

require 'iudex-worker'
require 'iudex-worker/filter_chain_factory'
require 'iudex-httpclient-3'

class TestFilterChainFactory < MiniTest::Unit::TestCase
  include Iudex
  include Gravitext::HTMap

  def setup
    RJack::Logback[ 'iudex' ].level = RJack::Logback::DEBUG
  end

  def teardown
    RJack::Logback[ 'iudex' ].level = nil
  end

  import 'iudex.core.VisitCounter'
  class TestVisitCounter
    include VisitCounter

    attr_reader :released

    def initialize
      super()
      @released = []
    end

    def release( acquired, newOrder )
      @released << acquired
    end
  end

  def test_filter
    fcf = Worker::FilterChainFactory.new( "test" )

    mgr = HTTPClient3.create_manager
    mgr.start
    fcf.http_client = HTTPClient3::HTTPClient3.new( mgr.client )
    fcf.visit_counter = counter = TestVisitCounter.new

    dsf = DA::PoolDataSourceFactory.new
    fcf.data_source = dsf.create

    fcf.filter do |chain|
      # Run twice (assume new the first time, updates the second).

      order = UniMap.new.tap do |o|
        o.url = Core::VisitURL.normalize( "http://gravitext.com/atom.xml" )
        o.type = "FEED"
        o.priority = 1.0
      end

      orders = [ order, order.clone ]

      orders.each do |o|
        assert( chain.filter( o ) )
      end

      # Note this only works timing wise because of blocking
      # HTTPClient.
      assert_equal( orders, counter.released )
    end

    mgr.shutdown
    dsf.close

  end

end
