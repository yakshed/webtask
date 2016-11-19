module Webtask
  class RakeApplication
    # Required to access task descriptions
    Rake::TaskManager.record_task_metadata = true

    class << self
      def tasks
        @tasks ||= rake_app.tasks.map { |task| TaskWrapper.new(task) }
      end

      def build_task_endpoints(application)
        tasks.each do |task|
          application.post "/#{task.name}" do
            argument_list = task.arg_names.map do |arg_name|
              params[:args][arg_name]
            end

            stream_id = Digest::SHA1.hexdigest(rand.to_s)
            application.settings.output_streams[stream_id] = task.shell_command(args: argument_list)

            haml :result, format: :html5, locals: { task: task, stream_id: stream_id }
          end
        end
      end


      private

      def rake_app
        return @rake_app if @rake_app

        @rake_app = Rake.application
        @rake_app.options.rakelib = [ "rakelib" ]
        @rake_app.load_rakefile

        return @rake_app
      end
    end
  end
end
