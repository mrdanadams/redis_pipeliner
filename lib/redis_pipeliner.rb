require "redis_pipeliner/version"
require "redis"
require "redis_pipeliner/pipeliner"

module RedisPipeliner
  class << self
    # Convenience for creating a pipeline, enqueueing, and blocking until the results are processed.
    def pipeline(redis, &proc)
      pipeliner = RedisPipeliner::Pipeliner.new(redis)
      redis.pipelined do
        proc.call pipeliner
      end

      pipeliner.values
    end
  end
end
