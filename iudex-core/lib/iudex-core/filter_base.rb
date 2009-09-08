#--
# Copyright (C) 2008-2009 David Kellum
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

require 'iudex-core'

module Iudex
  module Filters

    import 'iudex.core.Filter'
    import 'iudex.core.Described'
    import 'iudex.core.Named'

    class FilterBase
      include Filter
      include Described
      include Named

      def describe
        []
      end

      def name
        n = self.class.name
        n = n.gsub( /::/, '.' )
        n = n.gsub( /(\w)\w+\./ ) { |m| $1.downcase + '.' }
        n
      end

      def filter( map )
        true
      end
    end

  end
end
