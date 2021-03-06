# Class to configure a Puppet Master. See README.md for more details.
class ospuppet::master (
  $vardir                       = $::ospuppet::master::params::vardir,
  $logdir                       = $::ospuppet::master::params::logdir,
  $rundir                       = $::ospuppet::master::params::rundir,
  $pidfile                      = $::ospuppet::master::params::pidfile,
  $dns_alt_names                = $::ospuppet::master::params::dns_alt_names,
  $custom_settings              = $::ospuppet::master::params::custom_settings,
  $hiera_config                 = $::ospuppet::master::params::hiera_config,
  $hiera_backends               = $::ospuppet::master::params::hiera_backends,
  $hiera_hierarchy              = $::ospuppet::master::params::hiera_hierarchy,
  $hiera_yaml_datadir           = $::ospuppet::master::params::hiera_yaml_datadir,
  $hiera_merge_package_name     = $::ospuppet::master::params::hiera_merge_package_name,
  $hiera_merge_package_version  = $::ospuppet::master::params::hiera_merge_package_version,
  $hiera_merge_behavior         = $::ospuppet::master::params::hiera_merge_behavior,
  $hiera_logger                 = $::ospuppet::master::params::hiera_logger,
  $hiera_eyaml_package_name     = $::ospuppet::master::params::hiera_eyaml_package_name,
  $hiera_eyaml_package_version  = $::ospuppet::master::params::hiera_eyaml_package_version,
  $hiera_eyaml_extension        = $::ospuppet::master::params::hiera_eyaml_extension,
  $hiera_eyaml_key_dir          = $::ospuppet::master::params::hiera_eyaml_key_dir,
  $hiera_eyaml_private_key      = $::ospuppet::master::params::hiera_eyaml_private_key,
  $hiera_eyaml_public_key       = $::ospuppet::master::params::hiera_eyaml_public_key,
  $gem_provider_install_options = [],
) inherits ::ospuppet::master::params {

  require ospuppet

  validate_absolute_path(
    $vardir,
    $logdir,
    $rundir,
    $pidfile,
    $hiera_config,
    $hiera_yaml_datadir,
    $hiera_eyaml_key_dir,
  )

  validate_array(
    $hiera_backends,
    $hiera_hierarchy,
    $gem_provider_install_options,
  )

  validate_string(
    $dns_alt_names,
    $hiera_merge_package_name,
    $hiera_merge_package_version,
    $hiera_merge_behavior,
    $hiera_logger,
    $hiera_eyaml_package_name,
    $hiera_eyaml_package_version,
    $hiera_eyaml_extension,
    $hiera_eyaml_private_key,
    $hiera_eyaml_public_key,
  )

  validate_hash(
    $custom_settings,
  )

  validate_re($hiera_merge_behavior, '^(native|deep|deeper)$')
  validate_re($hiera_logger, '^(noop|puppet|console)$')

  if defined(Class[::ospuppet::server]) {
    Class[ospuppet::master::config::hiera] ~> Class[ospuppet::server::service]
    Class[ospuppet::master::config::settings] ~> Class[ospuppet::server::service]
  }

  contain ospuppet::master::config

}
