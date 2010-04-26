#--
# Copyright (c) 2008-2010 David Kellum
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

class AddVisitAfter < ActiveRecord::Migration

  def self.up
    add_column( 'urls', 'next_visit_after', 'timestamp with time zone' )
    execute 'ALTER TABLE urls ALTER COLUMN next_visit_after SET DEFAULT now()'
    # null: never visit (terminal result)
    # Don't visit again before the specified date.
  end

  def self.down
    remove_column( 'urls', 'next_visit_after' )
  end

end
