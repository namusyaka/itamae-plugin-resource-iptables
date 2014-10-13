require 'itamae/plugin/resource/iptables'

iptables_flush 'flush' do
end

iptables_policy 'INPUT' do
  action :accept
end

iptables_policy 'OUTPUT' do
  action :accept
end

iptables_policy 'FORWARD' do
  action :accept
end

iptables_rule 'redirect to rtmpsuck' do
  action :redirect
  table 'nat'
  chain 'OUTPUT'
  protocol 'tcp'
  dport 1935
  not_uid_owner 'rtmpsuck'
end

iptables_save '/etc/iptables/iptables.rules' do
end

service 'iptables.service' do
  action [:enable, :start]
end
