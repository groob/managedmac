# == Class: managedmac::logouthook
#
# Simple class for activating or deactivating OS X logouthooks and specifying
# a directory of scripts to execute at logout time.
#
# How does it work?
#
# Employs Managedmac::Hook defined type to create a master logouthook.
#   /etc/masterhooks/logouthook.rb
# It then activates the hook by setting the LogoutHook key in the root
# com.apple.loginwindow preferences domain.
#
# Once the hook is activated, each time a user logs in, the scripts directory
# you specify will be searched for executables. From this discovery, a list
# of child executables is created. The Master hook will then iterate over this
# list, executing each file in turn.
#
# The files are executed in alpha-numeric order.
#
# NOTE: While setting enalbe => true will create the script dir if it doesn't
# already exist, setting enable => false will NOT remove directory as it is not
# strictly managed. Removal of orphaned scripts is an excercise left up to the
# administrator.
#
# We do some validation of data, but the usual caveats apply: garbage in,
# garbage out.
#
# === Parameters
#
# There 2 parameters, the $enable parameter is required.
#
# [*enable*]
#   Type: Boolen
#
# [*scripts*]
#   An absolute path on the local machine that will store the scripts you want
#   executed by the master logouthook. Optional parameter.
#   Default: /etc/logouthooks
#   Type: String
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
# managedmac::logouthook::enable: true
# managedmac::logouthook::scripts: /path/to/your/scripts
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::logouthook
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  class { 'managedmac::logouthook': enable => true, }
#
# === Authors
#
# Brian Warsing <bcw@sfu.ca>
#
# === Copyright
#
# Copyright 2014 Simon Fraser University, unless otherwise noted.
#
class managedmac::logouthook ($enable, $scripts = '/etc/logouthooks') {

  managedmac::hook {'logout':
    enable  => $enable,
    scripts => $scripts,
  }

}