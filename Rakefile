require "rake"

desc "Prints the current time in `/tmp/webrake`"
task :update_timestamp do
  File.open("/tmp/webrake", "w+") do |f|
    f.puts Time.now
  end
end
