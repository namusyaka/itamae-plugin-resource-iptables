module Itamae
  module Plugin
    module Resource
      module Iptables
        module LogRule
          def self.prepended(base)
            base.class_eval do
              define_attribute :log_level, type: String
              define_attribute :log_prefix, type: String
            end
          end

          def build_rule(attrs)
            rule = []
            %w[log_level log_prefix].each do |key|
              if attrs.has_key?(key)
                rule << "--#{key.gsub('_', '-')}" << attrs[key]
              end
            end
            super + rule
          end
        end
      end
    end
  end
end
