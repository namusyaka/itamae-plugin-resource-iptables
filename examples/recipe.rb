require 'itamae/plugin/resource/iptables'

iptables_policy 'INPUT' do
  action :drop
end
