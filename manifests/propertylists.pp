# == Class: managedmac::propertylists
#
# Dynamically create Puppet Propertylist resources using the Puppet built-in
# 'create_resources' function.
#
# We do some validation of data, but the usual caveats apply: garbage in,
# garbage out.
#
# === Parameters
#
# [*files*]
#   This is a Hash of Hashes.
#   The hash should be in the form { title => { parameters } }.
#   See http://tinyurl.com/7783b9l, and the examples below for details.
#   Type: Hash
#
# [*defaults*]
#   A Hash that defines the default values for the resources created.
#   See http://tinyurl.com/7783b9l, and the examples below for details.
#   Type: Hash
#
# === Variables
#
# Not applicable
#
# === Examples
# This class was designed to be used with Hiera. As such, the best way to pass
# options is to specify them in your Hiera datadir:
#
# # Example: defaults.yaml
# ---
# managedmac::propertylists::defaults:
#   owner: root
#   group: wheel
#   format: xml
# managedmac::propertylists::files:
#   '/path/to/a/file.plist':
#     content:
#       - 'A string.'
#       - a_hash_key: 1
#       - 42
#   '/path/to/another/file.plist':
#     content:
#       0: 1
#       foo: bar
#       bar: baz
#       an_array:
#          - 99
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::propertylists
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
# # Create some Hashes
# $defaults = { owner => 'root', method => insert, }
# $files = {
#   '/this/is/a/file.plist' => {
#     'content' => { 'some_key' => 'some_value'},
#     format => xml,
#   },
# }
#
# class { 'managedmac::propertylists':
#   files    => $files,
#   defaults => $defaults,
# }
#
# === Authors
#
# Brian Warsing <bcw@sfu.ca>
#
# === Copyright
#
# Copyright 2014 Simon Fraser University, unless otherwise noted.
#
class managedmac::propertylists (

  $files    = undef,
  $defaults = {}

) {

  unless $files == undef {

    validate_hash ($files)
    validate_hash ($defaults)

    if empty ($files) {
      fail('Parameter Error: $files is empty')
    } else {
      # Cheating: validate that the key for each file is an absolute path
      $check_hash = inline_template("<%= @files.select! {
        |k,v| Pathname.new(k).absolute? } %>")

        unless empty($check_hash) {
        fail("Propertylist Error: Failed to parse one or more file data objects:
          ${check_hash}")
      }
      create_resources(propertylist, $files, $defaults)
    }

  }

}