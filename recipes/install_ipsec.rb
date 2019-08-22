#
# Cookbook:: ikev2_vpn
# Recipe:: install_ipsec
#
# Copyright:: 2019, The Authors, All Rights Reserved.
apt_package 'Install-strongswan' do
    package_name %w(strongswan libstrongswan-standard-plugins strongswan-libcharon libcharon-standard-plugins libcharon-extra-plugins)
    action :install
end