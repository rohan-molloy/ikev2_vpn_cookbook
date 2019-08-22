#
# Cookbook:: ikev2_vpn
# Recipe:: letsencrypt
#
# Copyright:: 2019, Rohan Molloy, All Rights Reserved.

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
        :domains => node['fqdn'],
        :pre_hook => '/sbin/iptables --insert INPUT -p tcp --dport 80 -j ACCEPT',
        :post_hook => '/sbin/iptables --delete INPUT -p tcp --dport 80 -j ACCEPT',
        :renew_hook => '/usr/sbin/ipsec reload && /usr/sbin/ipsec secrets',
    })
    owner 'root'
    action :create
end

execute 'Execute-letsencrypt-without-email' do
    command '/usr/bin/certbot certonly --register-unsafely-without-email --no-eff-email --non-interactive --agree-tos --standalone -d '+node['fqdn']
    action :run
    only_if { node['ikev2_vpn']['le_email']=='' }
end

execute 'Execute-letsencrypt-with-email' do
    command '/usr/bin/certbot certonly -m '+node['ikev2_vpn']['le_email']+' --non-interactive --agree-tos --standalone -d '+node['fqdn']
    action :run
    not_if { node['ikev2_vpn']['le_email']=='' }
end

execute 'Copy-cert' do
    command 'cp /etc/letsencrypt/live/'+node['fqdn']+'/cert.pem /etc/ipsec.d/certs/cert.pem'
    action :run
end

execute 'Copy-chain' do
    command 'cp /etc/letsencrypt/live/'+node['fqdn']+'/chain.pem /etc/ipsec.d/cacerts/chain.pem'
    action :run
end

execute 'Copy-key' do
    command 'cp /etc/letsencrypt/live/'+node['fqdn']+'/privkey.pem /etc/ipsec.d/private/privkey.pem'
    action :run
end