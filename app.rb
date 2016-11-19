require "sinatra"
require "haml"
require "rake"
require "yaml"

config = YAML.load_file(".config")

enable :sessions

set :public_folder, File.dirname(__FILE__) + '/public'
set :session_secret, config["session_secret"]

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

get "/" do
  notice = session.delete(:notice)

  haml :index, format: :html5, locals: { tasks: rake_app.tasks.map { |task| TaskWrapper.new(task) }, notice: notice }
end

rake_app.tasks.each do |task|

  post "/#{task.name}" do

    argument_list = task.arg_names.map do |arg_name| 
      params[:args][arg_name]
    end

    task.invoke(*argument_list)
    task.reenable

    session[:notice] = "Successfully executed task #{task.name.inspect}"

    redirect to("/")
  end

end
