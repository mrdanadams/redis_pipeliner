require 'spec_helper'

describe RedisPipeliner do
  let :redis do
    Redis.connect
  end

  it 'supports basic usage' do
    redis.del "testhash"
    redis.hset "testhash", "bar", 1
    redis.hset "testhash", "foo", 2

    redis.hmget("testhash", "foo", "bar").map(&:to_i).inject(&:+).should == 3

    total = 0
    values = RedisPipeliner.pipeline redis do |pipe|
      %w(bar foo).each do |key|
        pipe << redis.hget("testhash", key) do |result|
          total += result.to_i
        end
      end
    end
    values.map(&:to_i).inject(&:+).should == 3
  end

  it 'can reference variables outside the proce' do
    redis.del "testhash"
    redis.hset "testhash", "bar", 1
    redis.hset "testhash", "foo", 2

    results = []
    RedisPipeliner.pipeline redis do |pipe|
      %w(bar foo).each do |key|
        pipe.enqueue redis.hget("testhash", key) do |result|
          results << key+result
        end
      end
    end

    results.should == %w(bar1 foo2)
  end

  it 'should pipelines commands and return values' do
    redis.del "testhash"
    redis.hset "testhash", "bar", 1
    redis.hset "testhash", "foo", 2

    pipeliner = RedisPipeliner::Pipeliner.new(redis)
    redis.pipelined do
      %w(bar foo).each do |key|
        # allows not having a block
        pipeliner.enqueue redis.hget("testhash", key)
      end
    end

    pipeliner.commands.first.value.should_not be_nil # you can't test this class for type...

    pipeliner.values.map(&:to_i).inject(&:+).should == 3
    pipeliner.values.should === pipeliner.values
  end
end
