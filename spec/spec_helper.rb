require 'rubygems'
require 'bundler/setup'
require 'rspec-puppet'
require 'puppetlabs_spec_helper/rake_tasks'
require 'hiera-puppet-helper'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
end
