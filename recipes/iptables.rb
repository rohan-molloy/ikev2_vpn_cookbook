#
# Cookbook:: ikev2_vpn
# Recipe:: iptables
#
# Copyright:: 2019, Rohan Molloy, All Rights Reserved.

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
        :Subnet => node['ikev2_vpn']['subnet'],
        :WanInputDefault => node['ikev2_vpn']['iptables']['wan_input_default'],
        :VpnInputDefault => node['ikev2_vpn']['iptables']['vpn_input_default']
    })
end

execute 'Apply-iptables-rules' do
    command '/sbin/iptables-restore < /etc/iptables/rules.v4'
    action :run
end

service 'Reload-iptables-service' do
    service_name 'netfilter-persistent'
    action [:enable, :restart]
end
