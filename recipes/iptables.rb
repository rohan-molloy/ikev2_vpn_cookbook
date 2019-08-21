#
# Cookbook:: ikev2_vpn
# Recipe:: iptables
#
# Copyright:: 2019, The Authors, All Rights Reserved.

apt_package 'Install-netfilter-persistent' do
    package_name 'netfilter-persistent'
    action :install
end

directory 'Create-iptables-directory' do
    path '/etc/iptables'
    owner 'root'
    action :create
end

template 'Generate-iptables-rules' do
    path '/etc/iptables/rules.v4'
    source 'rules.v4.erb'
    owner 'root'
    mode '0600'
    variables ({
        :Interface => node['network']['default_interface'],
        :Subnet => node['ikev2_vpn']['subnet']
    })
end

service 'Reload-iptables-service' do
    service_name 'netfilter-persistent'
    action [:enable, :restart]
end


# execute 'nat_ipsec_policy' do
#     command "/sbin/iptables -t nat -A POSTROUTING -s #{subnet} -o #{iface}  -m policy --pol ipsec --dir out -j ACCEPT"
#     action :run
# end

# execute 'nat_ipsec_masquerade' do
#     command "/sbin/iptables -t nat -A POSTROUTING -s #{subnet} -o #{iface}  -j MASQUERADE"
#     action :run
# end

# execute 'mangle_ipsec_reduce_mtu' do
#     command "/sbin/iptables -t mangle -A FORWARD  -m policy --pol ipsec --dir in -s #{subnet} -o #{iface} -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360"
#     action :run
# end

# execute 'filter_ipsec_forward_1' do
#     command "/sbin/iptables -t filter -A FORWARD -m policy --pol ipsec --dir in -p esp -s #{subnet} -j ACCEPT"
#     action :run
# end 

# execute 'filter_ipsec_forward_2' do
#     command "/sbin/iptables -t filter -A FORWARD -m policy --pol ipsec --dir out -p esp -d #{subnet} -j ACCEPT"
#     action :run
# end 

# execute 'filter_ipsec_input_1' do
#     command "/sbin/iptables -t filter -A INPUT -p udp --dport 500 -j ACCEPT"
#     action :run
# end 

# execute 'filter_ipsec_input_2' do
#     command "/sbin/iptables -t filter -A INPUT -p udp --dport 4500 -j ACCEPT"
#     action :run
# end 

# execute 'filter_ipsec_input_3' do
#     command "/sbin/iptables -t filter -A INPUT -p ah -j ACCEPT"
#     action :run
# end 

# execute 'filter_ipsec_input_4' do
#     command "/sbin/iptables -t filter -A INPUT -p esp -j ACCEPT"
#     action :run
# end 



