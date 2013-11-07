# -*- coding: utf-8 -*-
#
# Copyright (C) 2013 droonga project
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

module Droonga
  class WatchSchema
    def initialize(context)
      @context = context
    end

    def ensure_created
      if @context["Keyword"]
        $log.trace "[#{Process.pid}] Watch tables exists. Skipping creation"
        return
      end
      $log.trace "[#{Process.pid}] Creating Watch tables"
      ensure_tables
      $log.trace "[#{Process.pid}] Created Watch tables"
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
  end
end
