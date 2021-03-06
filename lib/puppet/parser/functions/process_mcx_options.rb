require 'cfpropertylist'
module Puppet::Parser::Functions
  newfunction(:process_mcx_options, :type => :rvalue, :doc => <<-EOS
Returns MCX PropertyList as String.
    EOS
  ) do |args|

    if args.size != 5
      e = "process_mcx_options(): Wrong number of args: #{args.size} for 5"
      raise(Puppet::ParseError, e)
    end

    bluetooth, wifi, loginitems, suppress_icloud_setup, hidden_preference_panes = *args

    plist_options = {
      :plist_format => CFPropertyList::List::FORMAT_XML,
      :formatted    => true,
    }

    settings = {
      'com.apple.MCXBluetooth'      => {},
      'com.apple.MCXAirPort'        => {},
      'loginwindow'                 => {},
      'com.apple.SetupAssistant'    => {},
      'com.apple.systempreferences' => {},
    }

    case bluetooth
    when TrueClass, FalseClass
      settings['com.apple.MCXBluetooth'] = {
        'DisableBluetooth' => Hash['state', 'always', 'value', bluetooth]
      }
    else
      settings.delete('com.apple.MCXBluetooth')
    end

    case wifi
    when TrueClass, FalseClass
      settings['com.apple.MCXAirPort'] = {
        'DisableAirPort' => Hash['state', 'always', 'value', wifi]
      }
    else
      settings.delete('com.apple.MCXAirPort')
    end

    if loginitems.empty?
      settings.delete('loginwindow')
    else
      values = loginitems.collect do |path|
        Hash['Hide', true, 'Path', path]
      end
      settings['loginwindow'] = {
        'AutoLaunchedApplicationDictionary-raw' => {
          'state' => 'always',
          'upk'   => {
            'mcx_input_key_names'   => ['AutoLaunchedApplicationDictionary-raw'],
            'mcx_output_key_name'   => 'AutoLaunchedApplicationDictionary-managed',
            'mcx_remove_duplicates' => true,
          },
          'value' => values,
        },
        'DisableLoginItemsSuppression' => {
          'state' => 'always',
          'value' => false,
        },
        'LoginUserMayAddItems' => {
          'state' => 'always',
          'value' => true,
        }
      }
    end

    case suppress_icloud_setup
    when true
      settings['com.apple.SetupAssistant'] = {
        'DidSeeCloudSetup' => {
          'state' => 'once',
          'value' => true,
        },
        'LastSeenCloudProductVersion' => {
          'state' => 'once',
          'value' => lookupvar('macosx_productversion_major'),
        },
      }
    else
      settings.delete('com.apple.SetupAssistant')
    end

    if hidden_preference_panes.empty?
      settings.delete('com.apple.systempreferences')
    else
      settings['com.apple.systempreferences'] = {
        'HiddenPreferencePanes-Raw' => {
          'state' => 'always',
          'upk'   => {
            'mcx_input_key_names'   => ['HiddenPreferencePanes-Raw'],
            'mcx_output_key_name'   => 'HiddenPreferencePanes',
            'mcx_remove_duplicates' => true
          },
          'value' => hidden_preference_panes,
        }
      }
    end

    return nil if settings.empty?

    # This is a Hack.
    # The content attrib equality test in the Puppet MCX type/provider compares
    # the MCX as a String. This is silly, but so is the manner in which
    # CFPropertyList formats the XML it outputs. The net result of these two
    # mistakes is that Puppet will re-apply the resource on every run, just
    # because the whitespace in the margins is out of whack.
    #
    # As a workaround, we pass the CFPropertyList XML through /usr/bin/plutil
    # to conform it.
    # Thanks to @glarizza for this little snippet...
    # https://gist.github.com/glarizza/3185900
    IO.popen('plutil -convert xml1 -o - -', mode='r+') do |io|
      io.write settings.to_plist(plist_options)
      io.close_write
      io.read
    end
  end
end
