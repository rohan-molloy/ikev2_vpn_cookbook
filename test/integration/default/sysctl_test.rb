describe file '/proc/sys/net/ipv4/ip_forward' do
  its('content') { should match '1' }
end

describe file '/proc/sys/net/ipv4/ip_no_pmtu_disc' do
  its('content') { should match '1' }
end

describe file '/proc/sys/net/ipv4/conf/all/rp_filter' do
  its('content') { should match '1' }
end

describe file '/proc/sys/net/ipv4/conf/all/accept_redirects' do
  its('content') { should match '0' }
end

describe file '/proc/sys/net/ipv4/conf/all/send_redirects' do
  its('content') { should match '0' }
end