require "sinatra/base"
require "haml"
require "rake"
require "yaml"
require "digest"
require "open3"

require "webtask/version"

require "webtask/rake_application"
require "webtask/task_wrapper"
require "webtask/task_runner"
require "webtask/stream_out"
require "webtask/stream_error"
require "webtask/application"

module Webtask
end
