# -*- coding: utf-8 -*-
#
# Copyright (C) 2013 Kotoumi project
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

require 'groonga'

module Kotoumi
  class Worker
    def initialize(database, queue_name)
      @context = Groonga::Context.new
      @database = @context.open_database(database)
      @queue_name = queue_name
    end

    def shutdown
      @database.close
      @context.close
      @database = @context = nil
    end

    def process_message(envelope)
      case envelope["type"]
      when "search"
        search(envelope["body"])
      end
    end

    private
    def search(request)
      result = {}
      request["queries"].each do |name, query|
        result[name] = search_query(query)
      end
      result
    end

    def search_query(query)
      source = @context[query["source"]]
      {
        "count" => source.size,
      }
    end
  end
end
