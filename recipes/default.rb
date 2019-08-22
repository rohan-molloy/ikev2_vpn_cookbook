#
# Cookbook:: ikev2_vpn
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

apt_update 'update'
include_recipe 'ikev2_vpn::install_ipsec'
include_recipe 'ikev2_vpn::letsencrypt'
include_recipe 'ikev2_vpn::config_ipsec'
include_recipe 'ikev2_vpn::iptables'
include_recipe 'ikev2_vpn::sysctl'
include_recipe 'ikev2_vpn::restart_ipsec'