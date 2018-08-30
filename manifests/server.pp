# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include puppet::server
class puppet::server (
  Enum['running', 'stopped']         $status,
  Boolean                            $enabled,
  String                             $jvm_heap,
  Hash[String, Hash[String, String]] $config,
) {

  include '::puppet::agent'

  package { 'puppetserver':
    ensure  => 'installed',
    require => Package['puppet-agent'],
  }

  # Write each master configuration option
  keys($config).each|String $section| {
    $config[$section].each |String $setting, String $value| {
      ini_setting { "master ${section} ${setting}":
        ensure  => 'present',
        path    => '/etc/puppetlabs/puppet/puppet.conf',
        section => $section,
        setting => $setting,
        value   => $value,
        require => Package['puppetserver'],
        notify  => Service['puppetserver'],
      }
    }
  }

  # also do XMX ini_subsetting
  ['-Xms', '-Xmx'].each |String $jvm_setting| {
    ini_subsetting { "puppetserver jvm heap ${jvm_setting}":
      ensure            => 'present',
      path              => '/etc/sysconfig/puppetserver',
      key_val_separator => '=',
      section           => '',
      setting           => 'JAVA_ARGS',
      subsetting        => $jvm_setting,
      value             => $jvm_heap,
      require           => Package['puppetserver'],
      notify            => Service['puppetserver'],
    }
  }

  service { 'puppetserver':
    ensure => $status,
    enable => $enabled,
  }

}
