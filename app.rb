require "sinatra"
require "haml"
require "rake"
require "yaml"
require "digest"
require "open3"

set :server, "thin"
set :output_streams, {}
set :public_folder, File.dirname(__FILE__) + '/public'

# Required to access task descriptions
Rake::TaskManager.record_task_metadata = true

rake_app = Rake.application

rake_app.init
rake_app.load_rakefile

class TaskWrapper < SimpleDelegator
  def has_options_for?(arg_name)
    !!options[arg_name.to_sym]
  end

  def options
    arg_names.each_with_object({}) do |arg_name, options|
      if __getobj__.respond_to?(:options_for, true)
        if options_for_arg_name = __getobj__.send(:options_for, arg_name)
          options[arg_name.to_sym] = options_for_arg_name
        else
          next
        end
      else
        next
      end
    end
  end
end

class StreamOut
  def initialize(stream)
    @stream = stream
  end

  def write(data)
    @stream << "event: stdout\n"
    @stream << "data: #{data}\n\n"
  end
end

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

get "/" do
  haml :index, format: :html5, locals: { tasks: rake_app.tasks.map { |task| TaskWrapper.new(task) } }
end

get "/stream/:stream_id", provides: "text/event-stream" do
  stream :keep_open do |out|
    next unless settings.output_streams.has_key?(params[:stream_id])

    cmd = settings.output_streams[params[:stream_id]]
    outputs = { err: StreamError.new(out), out: StreamOut.new(out) }

    outputs[:out].write(">>> Running #{cmd.inspect}...")
    outputs[:out].write("\n")

    Open3.popen3(cmd) do |_stdin, stdout, stderr, thread|
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

    outputs[:out].write("\n")

    if outputs[:err].errors?
      outputs[:err].write("There have been errors!")
    else
      outputs[:out].write("All Done!")
    end

    settings.output_streams.delete(params[:stream_id])
  end
end

rake_app.tasks.each do |task|

  post "/#{task.name}" do

    argument_list = task.arg_names.map do |arg_name| 
      params[:args][arg_name]
    end

    command = "bundle exec rake #{task.name}[#{argument_list.join(",")}]"

    stream_id = Digest::SHA1.hexdigest(rand.to_s)
    settings.output_streams[stream_id] = command

    haml :result, format: :html5, locals: { task: task, stream_id: stream_id }
  end

end
