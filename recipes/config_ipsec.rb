#
# Cookbook:: ikev2_vpn
# Recipe:: config_ipsec
#
# Copyright:: 2019, Rohan Molloy, All Rights Reserved.

template 'Generate-ipsec-config' do
    path '/etc/ipsec.conf'
    source 'ipsec.conf.erb'
    variables ({
        :strictcrlpolicy => 'no',
        :uniqueids => 'never',
        :conn_name => 'roadwarrior',
        :auto => 'add',
        :compress => 'no', 
        :type => 'tunnel',
        :keyexchange => 'ikev2',
        :forceencaps => 'yes',
        :fragmentation => 'yes',
        :ike => 'aes256gcm16-prfsha384-ecp521,aes256gcm16-prfsha384-ecp384!',
        :esp => 'aes256gcm16-ecp521,aes256gcm16-ecp384!',
        :dpdaction => 'clear',
        :dpddelay => '900s',
        :rekey => 'no',
        :left => '%any',
        :leftid => '@'+node['fqdn'],
        :leftcert => 'cert.pem',
        :leftsendcert => 'always',
        :leftsubnet => '0.0.0.0/0',
        :right => '%any',
        :rightid => '%any',
        :rightauth => 'eap-mschapv2',
        :eap_identity => '%identity',
        :rightdns => node['ikev2_vpn']['dns'],
        :rightsourceip => node['ikev2_vpn']['subnet'],
        :rightsendcert => 'never'
    })
    owner 'root'
    action :create
end

template 'Generate-ipsec-secrets' do
    path '/etc/ipsec.secrets'
    source 'ipsec.secrets.erb'
    variables ({
        :Username => node['ikev2_vpn']['username'],
        :Password => node['ikev2_vpn']['password'],
        :CommonName => node['fqdn']
    })
    owner 'root'
    mode '600'
    action :create
end
