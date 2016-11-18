require "sinatra"
require "rake"

rake_app = Rake.application

rake_app.init
rake_app.load_rakefile

rake_app.tasks.each do |task|

  post "/#{task.name}" do
    task.invoke
    task.reenable

    "Executed #{task.name}"
  end

end
