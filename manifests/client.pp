class bacula::client (
  $package = $bacula::params::client_package,
  $config = $bacula::params::client_config,
  $group = $bacula::params::group,
  $service = $bacula::params::client_service,
  $port = $bacula::params::client_port,
  $working_directory = $bacula::params::working_directory,
  $pid_directory = $bacula::params::pid_directory,
  $password = $bacula::params::client_password,
  $max_concurrent_jobs = 1,
  $catalog = 'MainCatalog',
  $file_retention = '2 months',
  $job_retention = '6 months',
) inherits bacula::params {
  include bacula::tls
  $site = $bacula::params::site

  package { 'bacula-client':
    ensure => present,
    name   => $package,
  }
  service { 'bacula-client':
    ensure  => running,
    name    => $service,
    require => Package['bacula-client'],
  }

  concat { $config:
    mode    => '0640',
    owner   => 'root',
    group   => $group,
    require => Package['bacula-client'],
    notify  => Service['bacula-client'],
  }
  concat::fragment { 'bacula_fd':
    target  => $config,
    content => template('bacula/fd.erb'),
    order   => $bacula::params::order_client,
  }
  @@bacula::client::director { $::fqdn:
    site           => $site,
    port           => $port,
    password       => $password,
    catalog        => $catalog,
    file_retention => $file_retention,
    job_retention  => $job_retention,
  }
  Bacula::Director::Client <<| site == $site |>>
  Bacula::Messages::Client <<| site == $site |>>
}
