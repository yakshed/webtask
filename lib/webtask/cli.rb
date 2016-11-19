require 'singleton'

module Webtask
  class CLI
    include Singleton

    DEFAULT_PORT = 4567.freeze
    DEFAULT_BIND =  "127.0.0.1".freeze

    attr_accessor :port
    attr_accessor :bind

    def initialize
      @port = DEFAULT_PORT
      @bind = DEFAULT_BIND
    end

    def show_help
      puts <<~HELP_TEXT
        webtask – A web GUI for your Rake tasks

        Options:

          -b   bind to a different address (default: #{DEFAULT_BIND})
          -p   bind to a different port (default: #{DEFAULT_PORT})
      HELP_TEXT
      exit
    end
  end
end
