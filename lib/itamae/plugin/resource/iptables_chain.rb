require 'itamae/resource/base'

module Itamae
  module Plugin
    module Resource
      class IptablesChain < Itamae::Resource::Base
        define_attribute :action, default: :create
        define_attribute :chain, type: String, default_name: true
        define_attribute :table, type: String, default: 'filter'

        def set_current_attributes
          current.exist = run_command(['iptables', '--table', attributes.table, '--list-rules', attributes.chain], error: false).exit_status == 0
          unless current.exist
            Itamae.logger.info "Create chain #{attributes.chain}"
          end
        end

        def action_create(options)
          unless current.exist
            run_command(['iptables', '--table', attributes.table, '--new-chain', attributes.chain])
          end
        end
      end
    end
  end
end
