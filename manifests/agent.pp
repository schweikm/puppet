# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include puppet::agent
class puppet::agent (
  Enum['running', 'stopped']         $status,
  Boolean                            $enabled,
  Hash[String, Hash[String, String]] $config,
) {

  package { 'puppet-agent':
    ensure => 'installed',
    notify => Service['puppet'],
  }

  # Write each agent configuration option to the puppet.conf file
  keys($config).each|String $section| {
    $config[$section].each |String $setting, String $value| {
      ini_setting { "agent ${section} ${setting}":
        ensure  => 'present',
        path    => '/etc/puppetlabs/puppet/puppet.conf',
        section => $section,
        setting => $setting,
        value   => $value,
        require => Package['puppet-agent'],
        notify  => Service['puppet'],
      }
    }
  }

  service { 'puppet':
    ensure => $status,
    enable => $enabled,
  }

}
