#
# Cookbook:: ikev2_vpn
# Recipe:: sysctl
#
# Copyright:: 2019, The Authors, All Rights Reserved.

sysctl 'ipv4-enable-forwarding' do
    key 'net.ipv4.ip_forward'
    value 1
    action :apply
end
sysctl 'ipv4-turn-off-path-mtu-discovery' do
    key 'net.ipv4.ip_no_pmtu_disc'
    value 1
    action :apply 
end

sysctl 'ipv4-enable-reverse-path-filtering' do
    key 'net.ipv4.conf.all.rp_filter'
    value 1
    action :apply
end

sysctl 'ipv4-never-accept-redirects' do
    key 'net.ipv4.conf.all.accept_redirects'
    value 0
    action :apply
end

sysctl 'ipv4-never-send-redirects' do
    key 'net.ipv4.conf.all.send_redirects'
    value 0
    action :apply

end

sysctl 'disable-all-ipv6' do
    key 'net.ipv6.conf.all.disable_ipv6'
    value node['ikev2_vpn']['disable_ipv6']
    action :apply
end