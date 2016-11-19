module Webtask
  class StreamOut
    def initialize(stream)
      @stream = stream
    end

    def write(data)
      @stream << "event: stdout\n"
      @stream << "data: #{data}\n\n"
    end
  end
end
