source ENV['GEM_SOURCE'] || 'https://rubygems.org'
case RUBY_PLATFORM
when /darwin/
  gem 'CFPropertyList'
end
gem 'puppet', '4.9.0'
gem 'facter', '2.4.6'
gem 'rubocop', '0.47.1'
gem 'pdqtest', '0.4.3'
gem 'rspec-puppet-facts', '1.7.0'
gem 'puppet-strings',
  :git => 'https://github.com/declarativesystems/puppet-strings',
  :ref => 'no_dates'
gem 'metadatajson2puppetfile', '0.1.2'
gem 'derelict', '0.6.2'
gem 'puppetclassify', '0.1.5'
gem 'ruby-puppetdb', '2.3.0'

# Gem dependencies for azure type and provider (or rspec can't run)
gem 'hocon', '1.1.3'
gem "retries", "0.0.5"
gem "azure", "0.7.9"
gem "azure_mgmt_compute", "0.3.1"
gem "azure_mgmt_network", "0.3.1"
gem "azure_mgmt_resources", "0.3.1"
gem "azure_mgmt_storage", "0.3.1"
