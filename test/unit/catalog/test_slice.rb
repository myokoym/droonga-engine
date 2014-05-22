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

require "droonga/catalog/dataset"

class CatalogSliceTest < Test::Unit::TestCase
  private
  def create_slice(data)
    minimum_dataset_data = {
      "replicas" => {
      },
    }
    dataset = Droonga::Catalog::Dataset.new("DatasetName", minimum_dataset_data)
    Droonga::Catalog::Slice.new(dataset, data)
  end

  class WeightTest < self
    def test_default
      data = {
      }
      slice = create_slice(data)
      assert_equal(1, slice.weight)
    end

    def test_specified
      data = {
        "weight" => 29,
      }
      slice = create_slice(data)
      assert_equal(29, slice.weight)
    end
  end

  class LabelTest < self
    def test_default
      data = {
      }
      slice = create_slice(data)
      assert_nil(slice.label)
    end

    def test_specified
      data = {
        "label" => "High",
      }
      slice = create_slice(data)
      assert_equal("High", slice.label)
    end
  end

  class BoundaryTest < self
    def test_default
      data = {
      }
      slice = create_slice(data)
      assert_nil(slice.boundary)
    end

    def test_specified
      data = {
        "boundary" => "2014-03-21",
      }
      slice = create_slice(data)
      assert_equal("2014-03-21", slice.boundary)
    end
  end

  class VolumeTest < self
    def test_single
      data = {
        "volume" => {
          "address" => "127.0.0.1:10047/volume.000",
        },
      }
      slice = create_slice(data)
      assert_equal("127.0.0.1:10047/volume.000",
                   slice.volume.address)
    end

    def test_all_nodes
      data = {
        "volume" => {
          "address" => "127.0.0.1:10047/volume.000",
        },
      }
      slice = create_slice(data)
      assert_equal(["127.0.0.1:10047/volume"],
                   slice.all_nodes)
    end
  end
end
