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

module Droonga
  module Catalog
    class Schema
      class Column
        attr_reader :name
        def initialize(name, data)
          @name = name
          @data = data
        end

        def ==(other)
          self.class == other.class and
            name == other.name
          # TODO should consider @data
        end
      end

      class Table
        attr_reader :name, :columns
        def initialize(name, data)
          @name = name
          @data = data

          @columns = columns_data.map do |column_name, column_data|
            Column.new(column_name, column_data)
          end
        end

        def ==(other)
          self.class == other.class and
            name == other.name and
            columns == other.columns
        end

        private
        def columns_data
          @data["columns"] || []
        end
      end

      attr_reader :tables
      def initialize(data)
        @data = data || []
        @tables = @data.map do |table_name, table_data|
          Table.new(table_name, table_data)
        end
      end

      def ==(other)
        self.class == other.class and
          tables == other.tables
      end
    end
  end
end
