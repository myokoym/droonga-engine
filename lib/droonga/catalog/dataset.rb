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

require "droonga/catalog/schema"
require "droonga/catalog/single_volume"
require "droonga/catalog/collection_volume"
require "droonga/catalog/volume_collection"

module Droonga
  module Catalog
    class Dataset
      def initialize(name, data)
        @name = name
        @data = data
        @schema = nil
      end

      # provided for compatibility
      def [](key)
        @data[key]
      end

      # provided for compatibility
      def []=(key, value)
        @data[key] = value
      end

      def schema
        @schema ||= Schema.new(@name, @data["schema"])
      end

      def plugins
        @data["plugins"] || []
      end

      def fact
        @data["fact"]
      end

      def n_workers
        @data["nWorkers"] || 0
      end

      def replicas
        @replicas ||= VolumeCollection.new(create_volumes(@data["replicas"]))
      end

      private
      def create_volumes(raw_volumes)
        raw_volumes.collect do |raw_volume|
          if raw_volume.key?("address")
            SingleVolume.new(raw_volume)
          else
            CollectionVolume.new(raw_volume)
          end
        end
      end
    end
  end
end
