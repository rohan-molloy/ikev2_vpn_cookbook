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
    variables ({
        :preferred_challenges => 'http',
        :rsa_key_size => '4096',
        :email => node['ikev2_vpn']['le_email'],
        :domains => node['fqdn'],
        :pre_hook => '/sbin/iptables --insert INPUT -p tcp --dport 80 -j ACCEPT',
        :post_hook => '/sbin/iptables --delete INPUT -p tcp --dport 80 -j ACCEPT',
        :renew_hook => '/usr/sbin/ipsec reload && /usr/sbin/ipsec secrets',
    })
    owner 'root'
    action :create
end

execute 'Execute-letsencrypt2' do
    command '/usr/bin/certbot certonly --non-interactive --agree-tos --standalone -d '+node['fqdn']
    action :run
end

execute 'Copy-cert' do
    command "cp /etc/letsencrypt/live/#{node['fqdn']}/cert.pem /etc/ipsec.d/certs/cert.pem"
end
execute 'Copy-chain' do
    command "cp /etc/letsencrypt/live/#{node['fqdn']}/chain.pem /etc/ipsec.d/cacerts/chain.pem"
end
execute 'Copy-key' do
    command "cp /etc/letsencrypt/live/#{node['fqdn']}/privkey.pem /etc/ipsec.d/private/privkey.pem"
end