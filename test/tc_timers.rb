#!/usr/bin/env ruby

require "test/unit"
require "statsd"

class TimerTest < Test::Unit::TestCase
  include StatsD

  def setup
    data = [30, 40, 30, 55, 90]
    @key = "test.counter"
    StatsD.flush_interval = 10
    StatsD.pct_threshold = 90
    data.each { |v| receive_data("#{@key}:#{v}|ms") }
    str = StatsD.carbon_update_str
    @response = {}
    str.split("\n").each do |line|
      k, v, t = line.split(" ", 3)
      @response[k] = v
    end
  end

  def test_mean
    assert_equal("38.75", @response["stats.timers.#{@key}.mean"])
  end

  def test_lower
    assert_equal("30.0", @response["stats.timers.#{@key}.lower"])
  end

  def test_upper
    assert_equal("90.0", @response["stats.timers.#{@key}.upper"])
  end

  def test_upper_90
    assert_equal("55.0", @response["stats.timers.#{@key}.upper_90"])
  end

  def test_count
    assert_equal("5", @response["stats.timers.#{@key}.count"])
  end
end
