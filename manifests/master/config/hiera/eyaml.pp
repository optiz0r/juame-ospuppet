# PRIVATE CLASS - do not use directly
class ospuppet::master::config::hiera::eyaml {

  $puppet_user                  = $::ospuppet::puppet_user
  $puppet_group                 = $::ospuppet::puppet_group
  $puppet_gem_provider          = $::ospuppet::puppet_gem_provider
  $puppetserver_gem_provider    = $::ospuppet::puppetserver_gem_provider
  $gem_provider_install_options = $::ospuppet::master::gem_provider_install_options
  $hiera_eyaml_package_name     = $::ospuppet::master::hiera_eyaml_package_name
  $hiera_eyaml_package_version  = $::ospuppet::master::hiera_eyaml_package_version
  $hiera_eyaml_key_dir          = $::ospuppet::master::hiera_eyaml_key_dir
  $hiera_eyaml_private_key      = $::ospuppet::master::hiera_eyaml_private_key
  $hiera_eyaml_public_key       = $::ospuppet::master::hiera_eyaml_public_key

  package { "puppet.${hiera_eyaml_package_name}":
    ensure          => $hiera_eyaml_package_version,
    name            => $hiera_eyaml_package_name,
    install_options => $gem_provider_install_options,
    provider        => $puppet_gem_provider,
  }

  package { "puppetserver.${hiera_eyaml_package_name}":
    ensure          => $hiera_eyaml_package_version,
    name            => $hiera_eyaml_package_name,
    install_options => $gem_provider_install_options,
    provider        => $puppetserver_gem_provider,
  }

  file { $hiera_eyaml_key_dir:
    ensure => directory,
    owner  => $puppet_user,
    group  => $puppet_group,
    mode   => '0771',
    before => Exec["${module_name}.${name}.createkeys"],
  }

  $_createkeys_private="--pkcs7-private-key=${hiera_eyaml_key_dir}/${hiera_eyaml_private_key}"
  $_createkeys_public="--pkcs7-public-key=${hiera_eyaml_key_dir}/${hiera_eyaml_public_key}"
  exec { "${module_name}.${name}.createkeys":
    path      => '/opt/puppetlabs/puppet/bin',
    command   => "eyaml createkeys ${_createkeys_private} ${_createkeys_public}",
    user      => $puppet_user,
    creates   => "${hiera_eyaml_key_dir}/${hiera_eyaml_private_key}",
    logoutput => true,
    require   => Package["puppet.${hiera_eyaml_package_name}"],
  }

}
