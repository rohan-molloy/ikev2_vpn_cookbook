#
# Cookbook:: ikev2_vpn
# Recipe:: restart_ipsec
#
# Copyright:: 2019, The Authors, All Rights Reserved.
service 'Restart-ipsec-service' do
    service_name 'ipsec'
    action :restart
end
