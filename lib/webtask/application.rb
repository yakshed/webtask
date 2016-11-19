module Webtask
  class Application < Sinatra::Base
    set :server, "thin"
    set :output_streams, {}
    set :public_folder, File.dirname(__FILE__) + "/public"
    set :bind, Webtask::CLI.instance.bind
    set :port, Webtask::CLI.instance.port

    RakeApplication.build_task_endpoints(self)

    get "/" do
      haml :index, format: :html5, locals: { tasks: RakeApplication.tasks }
    end

    get "/stream/:stream_id", provides: "text/event-stream" do
      stream :keep_open do |out|
        next unless settings.output_streams.has_key?(params[:stream_id])

        TaskRunner.run(command: settings.output_streams[params[:stream_id]], out: out)

        settings.output_streams.delete(params[:stream_id])
      end
    end
  end
end
