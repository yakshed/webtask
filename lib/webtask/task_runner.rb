module Webtask
  class TaskRunner
    class << self
      def run(command:, out:)
        runner = new(command: command, out: out)
        runner.run
      end
    end

    def initialize(command:, out:)
      @command = command
      @out = out
    end

    def run
      print_intro

      execute_command

      print_outro
    end


    private

    attr_reader :command
    attr_reader :out

    def outputs
      @outputs ||= { err: StreamError.new(out), out: StreamOut.new(out) }
    end

    def print_intro
      outputs[:out].write(">>> Running #{command.inspect}...")
      outputs[:out].write("\n")
    end

    def execute_command
      Open3.popen3(command) do |_stdin, stdout, stderr, thread|
        # read each stream from a new thread
        { out: stdout, err: stderr }.each do |key, io|
          Thread.new do
            until (raw_line = io.gets).nil? do
              outputs[key].write [Time.now, raw_line].join(" - ")
            end
          end
        end

        thread.join # don't exit until the external process is done
      end
    end

    def print_outro
      outputs[:out].write("\n")

      if outputs[:err].errors?
        outputs[:err].write("There have been errors!")
      else
        outputs[:out].write("All Done!")
      end
    end
  end
end
