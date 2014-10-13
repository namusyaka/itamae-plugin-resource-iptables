require 'itamae/resource/base'

module Itamae
  module Plugin
    module Resource
      class IptablesFlush < Itamae::Resource::Base
        define_attribute :action, default: :run

        def action_run(options)
          get_tables.each do |table|
            run_command(['iptables', '--table', table, '--flush'])
            run_command(['iptables', '--table', table, '--delete-chain'])
          end
        end

        private

        def get_tables
          run_command(['cat', '/proc/net/ip_tables_names']).stdout.each_line.map(&:chomp)
        end
      end
    end
  end
end
