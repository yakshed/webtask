require "rake"
require "json"
require "yaml"
require "net/http"
require "uri"

config = YAML.load_file(".config")

desc "Prints the current time in `/tmp/webrake`"
task :update_timestamp do
  File.open("/tmp/webrake", "w+") do |f|
    f.puts Time.now
  end
end

desc "Send Notification to Slack"
task :notify, %i(notification) do |_t, args|
  slack_payload = {
    text: args[:notification],
    channel: "@dirk"
  }

  Net::HTTP.post_form(URI(config["slack_webhook_url"]), payload: slack_payload.to_json)
end
