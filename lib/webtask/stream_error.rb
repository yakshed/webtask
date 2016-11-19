module Webtask
  class StreamError
    def initialize(stream)
      @stream = stream
      @errors = false
    end

    def errors?
      @errors
    end

    def write(data)
      @errors = true
      @stream << "event: stderr\n"
      @stream << "data: #{data}\n\n"
    end
  end
end
