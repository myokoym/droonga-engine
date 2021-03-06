# Copyright (C) 2014 Droonga Project
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License version 2.1 as published by the Free Software Foundation.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

require "droonga/planner"
require "droonga/collectors"

module Droonga
  class SingleStep
    def initialize(dataset, definition)
      @dataset = dataset
      @definition = definition
    end

    def plan(message)
      if message["type"] == "search"
        # XXX: workaround
        planner = Plugins::Search::Planner.new
        return planner.plan(message)
      end

      # XXX: Re-implement me.
      planner = Planner.new
      options = {}
      options[:write] = @definition.write?
      collector_class = @definition.collector_class
      if collector_class
        reduce_key = "result"
        options[:reduce] = {
          reduce_key => collector_class.operator,
        }
      end

      body = message["body"]
      fact_input = find_fact_input(@definition.inputs, @dataset.fact, body)
      if fact_input
        record = body[fact_input[:filter]]
        planner.send(:scatter, message, record, options)
      else
        planner.send(:broadcast, message, options)
      end
    end

    def find_fact_input(inputs, fact, body)
      inputs.each do |key, input|
        if input[:type] == :table
          # for backward compatibility. We can remove the following code
          # when all our catalog.json specify "fact" parameter.
          return input if fact.nil?

          return input if body[key] == fact
        end
      end
      nil
    end
  end
end
