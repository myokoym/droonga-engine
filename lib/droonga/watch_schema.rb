# -*- coding: utf-8 -*-
#
# Copyright (C) 2013 Droonga Project
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

require "groonga"

require "droonga/loggable"

module Droonga
  class WatchSchema
    include Loggable

    def initialize(context)
      @context = context
    end

    def ensure_created
      if @context["Keyword"]
        logger.trace("skip table creation")
        return
      end
      logger.trace("ensure_tables: start")
      ensure_tables
      logger.trace("ensure_tables: done")
    end

    private
    def ensure_tables
      Groonga::Schema.define(:context => @context) do |schema|
        schema.create_table("Keyword",
                            :type => :patricia_trie,
                            :key_type => "ShortText",
                            :key_normalize => true,
                            :force => true) do |table|
                            end

        schema.create_table("Query",
                            :type => :hash,
                            :key_type => "ShortText",
                            :force => true) do |table|
                            end

        schema.create_table("Route",
                            :type => :hash,
                            :key_type => "ShortText",
                            :force => true) do |table|
                            end

        schema.create_table("Subscriber",
                            :type => :hash,
                            :key_type => "ShortText",
                            :force => true) do |table|
          table.time("last_modified")
                            end

        schema.change_table("Query") do |table|
          table.reference("keywords", "Keyword", :type => :vector)
        end

        schema.change_table("Subscriber") do |table|
          table.reference("route", "Route")
          table.reference("subscriptions", "Query", :type => :vector)
        end

        schema.change_table("Keyword") do |table|
          table.index("Query", "keywords", :name => "queries")
        end

        schema.change_table("Query") do |table|
          table.index("Subscriber", "subscriptions", :name => "subscribers")
        end
      end
    end

    def log_tag
      "[#{Process.ppid}] watch_schema"
    end
  end
end
