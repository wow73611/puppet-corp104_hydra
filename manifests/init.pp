class corp104_hydra (
  Optional[String] $http_proxy,
  String $version,
  String $tmp_path,
  String $install_path,
){

  contain corp104_hydra::install
  contain corp104_hydra::service

  Class['::corp104_hydra::install']
  -> Class['::corp104_hydra::service']
}
