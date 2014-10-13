require 'itamae/resource/base'

module Itamae
  module Plugin
    module Resource
      class IptablesFlush < Itamae::Resource::Base
        define_attribute :action, default: :run

        def action_run(options)
          run_command(['iptables', '-F'])
          run_command(['iptables', '-X'])
        end
      end
    end
  end
end
