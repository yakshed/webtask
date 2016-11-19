require "sinatra"
require "haml"
require "rake"

set :public_folder, File.dirname(__FILE__) + '/public'

enable :sessions

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
    task.invoke
    task.reenable

    session[:notice] = "Successfully executed task #{task.name.inspect}"

    redirect to("/")
  end

end
