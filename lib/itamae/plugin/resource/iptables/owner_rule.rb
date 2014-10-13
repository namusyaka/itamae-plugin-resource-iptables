module Itamae
  module Plugin
    module Resource
      module Iptables
        module OwnerRule
          def self.prepended(base)
            base.class_eval do
              [:uid_owner, :gid_owner].each do |key|
                define_attribute key, type: String
                define_attribute :"not_#{key}", type: String
              end
            end
          end

          def build_rule(attrs)
            rule = %w[uid_owner gid_owner].flat_map do |key|
              if id = attrs[key]
                ["--#{key.gsub('_', '-')}", id]
              elsif not_id = attrs["not_#{key}"]
                ['!', "--#{key.gsub('_', '-')}", not_id]
              else
                []
              end
            end
            unless rule.empty?
              rule.unshift('--match', 'owner')
            end
            super + rule
          end
        end
      end
    end
  end
end
