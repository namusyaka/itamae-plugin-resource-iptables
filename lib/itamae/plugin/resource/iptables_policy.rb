require 'itamae/resource/base'

module Itamae
  module Plugin
    module Resource
      class IptablesPolicy < Itamae::Resource::Base
        define_attribute :action, required: true
        define_attribute :chain, default_name: true
        define_attribute :table, type: String, default: 'filter'

        def set_current_attributes
          super
          current.action = get_policy(attributes.table, attributes.chain)
        end

        def action_drop(options)
          run_command(['iptables', '--table', attributes.table, '--policy', attributes.chain, 'DROP'])
        end

        def action_accept(options)
          run_command(['iptables', '--table', attributes.table, '--policy', attributes.chain, 'ACCEPT'])
        end

        private

        def get_policy(table, chain)
          line = run_command(['iptables', '--table', table, '--list-rules', chain]).stdout.each_line.first.chomp
          line[/\A-P #{Regexp.escape(chain)} (.+)\z/, 1].downcase.to_sym
        end
      end
    end
  end
end
