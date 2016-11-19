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

get "/" do
  notice = session.delete(:notice)

  haml :index, format: :html5, locals: { tasks: rake_app.tasks, notice: notice }
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
