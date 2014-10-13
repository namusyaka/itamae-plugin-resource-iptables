module Itamae
  module Plugin
    module Resource
      module Iptables
        module BasicRule
          RULES = {
            protocol: { type: String },
            source: { type: String },
            destination: { type: String },
            in_interface: { type: String },
            out_interface: { type: String },
          }

          def self.prepended(base)
            base.class_eval do
              RULES.each do |key, opts|
                define_attribute key, opts
                define_attribute :"not_#{key}", opts
              end
            end
          end

          def build_rule(attrs)
            rule = []
            RULES.each_key.map(&:to_s).each do |key|
              if attrs.has_key?(key)
                rule << "--#{key.gsub('_', '-')}" << attrs[key]
              elsif attrs.has_key?("not_#{key}")
                rule << "--#{key.gsub('_', '-')}" << '!' << attrs[key]
              end
            end
            super + rule
          end
        end
      end
    end
  end
end
