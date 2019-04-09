class corp104_hydra::service inherits corp104_hydra {
  file { 'systemd config':
    ensure  => file,
    name    => '/lib/systemd/system/hydra.service',
    source  => 'puppet:///modules/corp104_hydra/hydra.service',
    require => Class['Corp104_hydra::install']
  }
}