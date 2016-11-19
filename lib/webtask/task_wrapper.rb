module Webtask
  class TaskWrapper < SimpleDelegator
    def has_options_for?(arg_name)
      !!options[arg_name.to_sym]
    end

    def shell_command(args:)
      "bundle exec rake #{name}[#{args.join(",")}]"
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
end
