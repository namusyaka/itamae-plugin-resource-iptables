require 'itamae/resource/base'

require 'itamae/plugin/resource/iptables/basic_rule'
require 'itamae/plugin/resource/iptables/multiport_rule'
require 'itamae/plugin/resource/iptables/log_rule'
require 'itamae/plugin/resource/iptables/owner_rule'
require 'itamae/plugin/resource/iptables/state_rule'

module Itamae
  module Plugin
    module Resource
      class IptablesRule < Itamae::Resource::Base
        define_attribute :chain, type: String, required: true
        define_attribute :table, type: String, default: 'filter'
        define_attribute :jump, type: String
        define_attribute :comment, type: String, default_name: true

        prepend Iptables::BasicRule
        prepend Iptables::LogRule
        prepend Iptables::MultiportRule
        prepend Iptables::OwnerRule
        prepend Iptables::StateRule

        def pre_action
          super
          if attributes.action != :create
            attributes.jump = attributes.action.to_s.upcase
          end
        end

        def set_current_attributes
          super
          rule = build_rule(attributes)
          current.exist = run_command(['iptables', '--table', attributes.table, '--check', attributes.chain] + rule, error: false).exit_status == 0
          unless current.exist
            Logger.info "Create rule for #{attributes.chain}: #{rule.join(' ')}"
          end
        end

        def action_create(options)
          unless current.exist
            rule = build_rule(attributes)
            run_command(['iptables', '--table', attributes.table, '--append', attributes.chain] + rule)
          end
        end

        alias_method :action_accept, :action_create
        alias_method :action_drop, :action_create
        alias_method :action_log, :action_create
        alias_method :action_redirect, :action_create

        private

        def build_rule(attrs)
          rule = []
          rule << "--jump" << attrs.jump
          rule << '--match' << 'comment' << '--comment' << attrs.comment
          rule
        end
      end
    end
  end
end
