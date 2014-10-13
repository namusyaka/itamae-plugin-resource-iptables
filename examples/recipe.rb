require 'itamae/plugin/resource/iptables'

iptables_policy 'INPUT' do
  action :drop
end

iptables_rule 'accept loopback' do
  action :accept
  chain 'INPUT'
  in_interface 'lo'
end

iptables_rule 'accept ping' do
  action :accept
  chain 'INPUT'
  protocol 'icmp'
end

iptables_rule 'accept related,established' do
  action :accept
  chain 'INPUT'
  state %w[RELATED ESTABLISHED]
end

iptables_rule 'accept from local' do
  action :accept
  chain 'INPUT'
  source '192.168.10.0/24'
end
