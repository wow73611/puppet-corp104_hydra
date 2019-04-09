class corp104_hydra::install inherits corp104_hydra {

  $hydra_download_url="https://github.com/ory/hydra/releases/download/v${corp104_hydra::version}/hydra_${corp104_hydra::version}_Linux_64-bit.tar.gz"
  $hydra_checksum_url="https://github.com/ory/hydra/releases/download/v${corp104_hydra::version}/hydra_${corp104_hydra::version}_checksums.txt"

  $hydra_checksum_path="${corp104_hydra::tmp_path}/hydra_${corp104_hydra::version}_checksums.txt"
  $hydra_download_path="${corp104_hydra::tmp_path}/hydra_${corp104_hydra::version}_Linux_64-bit.tar.gz"

  # Create group
  group { 'hydra':
  	ensure => 'present',
    before => User['hydra']
  }
  
  # Create user
  user { 'hydra':
    ensure => 'present',
    system => true,
    gid    => 'hydra',
    before => Exec['download-hydra-checksum']
  }

  # Download hydra
  if $corp104_hydra::http_proxy{
    exec { 'download-hydra-checksum':
      provider => 'shell',
      command  => "curl -x ${corp104_hydra::http_proxy} -L ${hydra_checksum_url} >  ${hydra_checksum_path}",
      path     => '/bin:/usr/bin:/usr/local/bin:/usr/sbin',
      unless   => "test -e ${hydra_checksum_path}",
      before   => Exec['download-hydra']
    }
    exec { 'download-hydra':
      provider => 'shell',
      command  => "curl -x ${corp104_hydra::http_proxy} -o ${hydra_download_path} -O -L ${hydra_download_url}",
      path     => '/bin:/usr/bin:/usr/local/bin:/usr/sbin',
      unless   => "cd ${corp104_hydra::tmp_path} && grep Linux_64 hydra_1.0.0-rc.8+oryOS.10_checksums.txt > checksum.txt && shasum -c checksum.txt",
    }
  }
  else {
    exec { 'download-hydra-checksum':
      provider => 'shell',
      command  => "curl -L ${hydra_checksum_url} >  ${hydra_checksum_path}",
      path     => '/bin:/usr/bin:/usr/local/bin:/usr/sbin',
      unless   => "test -e ${hydra_checksum_path}",
      before   => Exec['download-hydra']
    }
    exec { 'download-hydra':
      provider => 'shell',
      command  => "curl -o ${hydra_download_path} -O -L ${hydra_download_url}",
      path     => '/bin:/usr/bin:/usr/local/bin:/usr/sbin',
      unless   => "cd ${corp104_hydra::tmp_path} && grep Linux_64 hydra_1.0.0-rc.8+oryOS.10_checksums.txt > checksum.txt && shasum -c checksum.txt",
    }
  }

  # Unpackage
  exec { 'unpackage hydra':
    provider    => 'shell',
    command     => "tar xvf ${hydra_download_path} -C ${corp104_hydra::tmp_path}",
    path        => '/bin:/usr/bin:/usr/local/bin:/usr/sbin',
    refreshonly => true,
    subscribe   => Exec['download-hydra'],
  }

  # create hydra directory
  file { '/opt/hydra':
    ensure  => 'directory',
    before  => File['hydra'],
    require => User['hydra'],
    owner   => 'hydra',
    group   => 'hydra'
  }

    # create hydra log directory
  file { '/var/log/hydra':
    ensure => 'directory',
    before => File['hydra'],
    require => User['hydra'],
    owner  => 'hydra',
    group  => 'hydra'
  }

  # Copy file
  file { 'hydra':
    ensure             => present,
    source             => "${corp104_hydra::tmp_path}/hydra",
    path               => "$corp104_hydra::install_path/hydra",
    recurse            => true,
    replace            => false,
    source_permissions => use,
    owner              => 'hydra',
    group              => 'hydra',
    subscribe          => Exec['unpackage hydra'],
  }
}