require 'spec_helper'

describe 'r_profile::linux::sysctl' do

  let(:facts) do
    {
      :kernel                     => "Linux",
      :osfamily                   => "RedHat",
      :operatingsystemmajrelease  => '7',
    }
  end

  context "catalog compiles" do
    it { should compile}
  end

  context 'with default values for all parameters' do
    it { should contain_class('r_profile::linux::sysctl') }
  end

  context 'delegates sysctl entries correctly' do
    settings = {
      'net.ipv4.conf.all.accept_redirects' => 0,
      'net.ipv4.tcp_syncookies'            => 1
    }
    let :params do
      {
        :settings => settings
      }
    end
    # fragment file created
    it { should contain_file('/etc/sysctl.d/net.ipv4.conf.all.accept_redirects.conf').with({
      :content  => "net.ipv4.conf.all.accept_redirects = 0\n",
      :owner    => 'root',
      :mode     => '0644'
    }).that_notifies('Exec[sysctl-net.ipv4.conf.all.accept_redirects]')}
    it { should contain_file('/etc/sysctl.d/net.ipv4.tcp_syncookies.conf').with({
      :content  => "net.ipv4.tcp_syncookies = 1\n",
      :owner    => 'root',
      :mode     => '0644'
    }).that_notifies('Exec[sysctl-net.ipv4.tcp_syncookies]')}
  end
end
