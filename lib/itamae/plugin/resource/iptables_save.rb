require 'itamae/resource/file'

module Itamae
  module Plugin
    module Resource
      class IptablesSave < Itamae::Resource::File
        def pre_action
          attributes.content = run_command(['iptables-save']).stdout
          attributes.owner ||= 'root'
          attributes.group ||= 'root'
          attributes.mode ||= '644'
          super
        end

        def show_differences
          # suppress differences
        end
      end
    end
  end
end
