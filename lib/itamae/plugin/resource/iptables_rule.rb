require 'itamae/resource/base'

module Itamae
  module Plugin
    module Resource
      class IptablesRule < Itamae::Resource::Base
        NEGATABLE_RULES = {
          protocol: { type: String },
          source: { type: String },
          destination: { type: String },
          in_interface: { type: String },
          out_interface: { type: String },
          sport: { type: Fixnum },
          dport: { type: Fixnum },
        }

        define_attribute :chain, type: String, required: true
        define_attribute :table, type: String, default: 'filter'

        NEGATABLE_RULES.each do |key, opts|
          define_attribute key, opts
          define_attribute :"not_#{key}", opts
        end

        define_attribute :jump, type: String

        # state match
        define_attribute :state, type: Array

        # owner match
        [:uid_owner, :gid_owner].each do |key|
          define_attribute key, type: String
          define_attribute :"not_#{key}", type: String
        end

        define_attribute :log_level, type: String
        define_attribute :log_prefix, type: String

        define_attribute :comment, type: String, default_name: true

        def pre_action
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

        SIMPLE_RULE_KEYS = %w[
          jump
          log_level
          log_prefix
        ]

        def build_rule(attrs)
          rule = []

          NEGATABLE_RULES.each_key.map(&:to_s).each do |key|
            if attrs.has_key?(key)
              rule << "--#{key.gsub('_', '-')}" << attrs[key]
            elsif attrs.has_key?("not_#{key}")
              rule << "--#{key.gsub('_', '-')}" << '!' << attrs[key]
            end
          end

          SIMPLE_RULE_KEYS.each do |key|
            if attrs.has_key?(key)
              rule << "--#{key.gsub('_', '-')}" << attrs[key]
            end
          end

          rule += build_rules_for_state(attrs)
          rule += build_rules_for_owner(attrs)
          rule << '--match' << 'comment' << '--comment' << attrs['comment']

          rule
        end

        def build_rules_for_state(attrs)
          if state = attrs['state']
            ['--match', 'state', '--state', state.join(',')]
          elsif not_state = attrs['not_state']
            ['--match', 'state', '!', '--state', state.join(',')]
          else
            []
          end
        end

        def build_rules_for_owner(attrs)
          rules = %w[uid_owner gid_owner].flat_map do |key|
            if id = attrs[key]
              ["--#{key.gsub('_', '-')}", id]
            elsif not_id = attrs["not_#{key}"]
              ['!', "--#{key.gsub('_', '-')}", not_id]
            else
              []
            end
          end
          unless rules.empty?
            rules.unshift('--match', 'owner')
          end
          rules
        end
      end
    end
  end
end
