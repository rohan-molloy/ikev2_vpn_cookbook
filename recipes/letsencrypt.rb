#
# Cookbook:: ikev2_vpn
# Recipe:: letsencrypt
#
# Copyright:: 2019, The Authors, All Rights Reserved.

apt_package 'Install-certbot' do
    package_name 'certbot'
    action :install
end


directory 'Create-letsencrypt-directory' do
    path '/etc/letsencrypt'
    owner 'root'
    action :create
end

template 'Generate-letsencrypt-config' do
    path '/etc/letsencrypt/cli.ini'
    source 'cli.ini.erb'
    template ({
        :preferred_challenges => 'http',
        :rsa_key_size => '4096',
        :email => node['ikev2_vpn']['le_email'],
        :domains => node['fqdn'],
        :pre_hook => '/sbin/iptables --insert INPUT -p tcp --dport 80 -j ACCEPT',
        :post_hook => '/sbin/iptables --delete INPUT -p tcp --dport 80 -j ACCEPT',
        :renew_hook => '/usr/sbin/ipsec reload && /usr/sbin/ipsec secrets',
        :cert_path => '/etc/ipsec.d/certs/cert.pem',
        :key_path => '/etc/ipsec.d/private/privkey.pem',
        :chain_path => '/etc/ipsec/cacerts/chain.pem'
    })
    owner 'root'
    action :create
end

execute 'Execute-letsencrypt' do
    command '/usr/bin/certbot certonly --non-interactive --agree-tos --standalone'
    action :run
end

