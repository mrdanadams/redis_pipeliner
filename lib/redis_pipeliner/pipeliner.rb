module RedisPipeliner
  # Enqueues commands in a pipeline and waits until they are finished.
  # Usage pattern is to call #enqueue with each REDIS future and a block to process it,
  # then call #wait outside the Redis.pipelined call.
  class Pipeliner
    def initialize(redis)
      @redis = redis
      @commands = []
    end

    # Adds a command (a Future, actually) with an option block to call when the Future has been realized.
    def enqueue(future, &proc)
      @commands << { future: future, callback: proc }
    end

    # Blocks until all Futures have been realized and returns the values.
    # This should be called _outside_ the Redis.pipelined call.
    # Note that the value enqueue is the REDIS return value, not the value returned by any passed block.
    # Nil values will be included in the return values (if that's what REDIS gives us).
    def values
      return @values unless @values.nil?

      @values = []
      @commands.each do |cmd|
        while cmd[:future].value.is_a?(Redis::FutureNotReady)
          sleep(1.0 / 100.0)
        end

        v = cmd[:future].value
        cmd[:callback].call(v) unless cmd[:callback].nil?
        @values << v
      end

      @values
    end

    # Returns the enqueue REDIS commands
    def commands
      @commands.map {|h| h[:future] }
    end

    alias_method :wait, :values
  end
end
