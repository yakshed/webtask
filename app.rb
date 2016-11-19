require "sinatra"
require "haml"
require "rake"
require "yaml"
require "digest"

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
    @stream << "data: #{data}\n\n"
  end
end

get "/" do
  haml :index, format: :html5, locals: { tasks: rake_app.tasks.map { |task| TaskWrapper.new(task) } }
end

get "/stream/:stream_id", provides: "text/event-stream" do
  stream :keep_open do |out|
    next unless settings.output_streams.has_key?(params[:stream_id])

    settings.output_streams[params[:stream_id]].call(StreamOut.new(out))

    settings.output_streams.delete(params[:stream_id])
  end
end

rake_app.tasks.each do |task|

  post "/#{task.name}" do

    argument_list = task.arg_names.map do |arg_name| 
      params[:args][arg_name]
    end

    stream_id = Digest::SHA1.hexdigest(rand.to_s)
    settings.output_streams[stream_id] = ->(output) do
      begin
        old_stdout = $stdout
        $stdout = output
        task.invoke(*argument_list)
        task.reenable

        output.write("\n")
        output.write("All Done!")
      ensure
        $stdout = old_stdout
      end
    end

    haml :result, format: :html5, locals: { task: task, stream_id: stream_id }
  end

end
