module Itamae
  module Plugin
    module Resource
      module Iptables
        module StateRule
          def self.prepended(base)
            base.class_eval do
              define_attribute :state, type: Array
            end
          end

          def build_rule(attrs)
            rule =
              if state = attrs['state']
                ['--match', 'state', '--state', state.join(',')]
              elsif not_state = attrs['not_state']
                ['--match', 'state', '!', '--state', not_state.join(',')]
              else
                []
              end
            super + rule
          end
        end
      end
    end
  end
end
