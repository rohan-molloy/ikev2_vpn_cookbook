describe package('strongswan') do
  it { should be_installed }
end

describe package('libstrongswan-standard-plugins') do
  it { should be_installed }
end

describe package('strongswan-libcharon') do
  it { should be_installed }
end

describe package('strongswan') do
  it { should be_installed }
end

describe package('libcharon-standard-plugins') do
  it { should be_installed }
end

describe package('libcharon-extra-pluginss') do
  it { should be_installed }
end