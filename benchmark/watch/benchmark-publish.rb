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

require "benchmark"
require "fileutils"
require "optparse"
require "csv"

require "groonga"

require "droonga/watcher"
require File.expand_path(File.join(__FILE__, "..", "..", "utils.rb"))

class PublishBenchmark
  attr_reader :n_subscribers

  def initialize(n_initial_subscribers)
    @database = DroongaBenchmark::WatchDatabase.new
    @watcher = Droonga::Watcher.new(@database.context)
    @keywords_generator = DroongaBenchmark::KeywordsGenerator.new
    @keywords = []
    @n_subscribers = 0
    add_subscribers(n_initial_subscribers)
  end

  def run
    @matched_keywords.each do |keyword|
      publish(keyword)
    end
  end

  def prepare_keywords(n_keywords)
    @matched_keywords = @keywords.sample(n_keywords)
  end

  def add_subscribers(n_subscribers)
    new_keywords = []
    n_subscribers.times do
      new_keywords << @keywords_generator.next
    end
    @database.subscribe_to(new_keywords)
    @keywords += new_keywords
    @n_subscribers += n_subscribers
  end

  private
  def publish(matched_keyword)
    @watcher.publish([matched_keyword], {}) do |route, subscribers|
    end
  end
end

options = {
  :n_subscribers => 1000,
  :n_times       => 1000,
  :n_steps       => 10,
  :output_path   => "/tmp/watch-benchmark-notify.csv",
}
option_parser = OptionParser.new do |parser|
  parser.on("--subscribers=N", Integer,
            "initial number of subscribers (optional)") do |n_subscribers|
    options[:n_subscribers] = n_subscribers
  end
  parser.on("--times=N", Integer,
            "number of publish times (optional)") do |n_times|
    options[:n_times] = n_times
  end
  parser.on("--steps=N", Integer,
            "number of benchmark steps (optional)") do |n_steps|
    options[:n_steps] = n_steps
  end
  parser.on("--output-path=PATH", String,
            "path to the output CSV file (optional)") do |output_path|
    options[:output_path] = output_path
  end
end
args = option_parser.parse!(ARGV)


publish_benchmark = PublishBenchmark.new(options[:n_subscribers])
results = []
options[:n_steps].times do |try_count|
  publish_benchmark.add_subscribers(publish_benchmark.n_subscribers) if try_count > 0
  label = "#{publish_benchmark.n_subscribers} subscribers"
  result = Benchmark.bmbm do |benchmark|
    publish_benchmark.prepare_keywords(options[:n_times])
    benchmark.report(label) do
      publish_benchmark.run
    end
  end
  result = result.join("").strip.gsub(/[()]/, "").split(/\s+/)
  results << [label] + result
end
total_results = [
  ["case", "user", "system", "total", "real"],
]
total_results += results

puts ""
puts "Results (saved to #{options[:output_path]}):"
File.open(options[:output_path], "w") do |file|
  total_results.each do |row|
    file.puts(CSV.generate_line(row))
    puts row.join(",")
  end
end
