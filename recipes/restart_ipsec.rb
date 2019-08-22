#
# Cookbook:: ikev2_vpn
# Recipe:: restart_ipsec
#
# Copyright:: 2019, Rohan Molloy, All Rights Reserved.
service 'Restart-ipsec-service' do
    service_name 'ipsec'
    action :restart
end
