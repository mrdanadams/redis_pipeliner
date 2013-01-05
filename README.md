# Ruby gem for easily pipelining REDIS commands
https://github.com/mrdanadams/redis_pipeliner

(Inspired by this blog post on [5-10x Speed Ups by Pipeling Multiple REDIS Commands in Ruby](http://mrdanadams.com/2012/pipeline-redis-commands-ruby/) by [Dan Adams](http://mrdanadams.com).)

[Pipelining in REDIS](https://github.com/redis/redis-rb#pipelining) is a great way to stay performant when executing multiple commands. It should also be easy to use.

## Usage

Basic usage involves:

1. Enqueueing a number of REDIS commands inside a `pipelined` block
2. Doing something with the results either afterwards or inside blocks specific to each command.

Ex: (a bit contrived...)

```ruby
# Put a bunch of values in a few different hashes
redis = Redis.connect
redis.hset "h1", "foo", 1
redis.hset "h2", "bar", 2
redis.hest "h3", "baz", 3

# Get the values pipelined and sum them up
values = RedisPipeliner.pipeline redis do |p|
  # This would normally be 3 round-trips
  p << redis.hget("h1", "foo")
  p << redis.hget("h2", "bar")
  p << redis.hget("h3", "baz")
end
values.map(&:to_i).inject(&:+).should == 6
```

You can also pass in a block to be called for each value rather than operating on the values afterwards:

```ruby
results = []
RedisPipeliner.pipeline redis do |p|
  [%w(h1 foo), %w(h2 bar), %w(h3 baz)].each do |pair|
    p << redis.hget(pair[0], pair[1]) do |value|
      # referencing pair inside the block
      results << pair[1] + value
    end
  end
end
results.first.should == "foo1"
```

See the specs for executable examples.
