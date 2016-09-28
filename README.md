# ospuppet

[![Build Status](https://travis-ci.org/juame/juame-ospuppet.svg?branch=master)](https://travis-ci.org/juame/juame-ospuppet)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
  * [Puppet Agent](#puppet-agent)
  * [Puppet Master](#puppet-master)
  * [Puppet Server](#puppet-server)
3. [Setup](#setup)
  * [Setup requirements](#setup-requirements)
  * [Beginning with ospuppet](#beginning-with-ospuppet)
4. [Usage](#usage)
  * [Usage of Puppet Agent](#usage-of-puppet-agent)
    * [Install Puppet Agent and specify some settings](#install-puppet-agent-and-specify-some-settings)
  * [Usage of Puppet Master](#usage-of-puppet-master)
    * [Configure Hiera Settings](#configure-hiera-settings)
  * [Usage of Puppet Server](#usage-of-puppet-server)
    * [Memory Allocation](#memory-allocation)
    * [Manage Puppet Server Service and stop Puppet Master](#manage-puppet-server-service-and-stop-puppet-master)
    * [Puppet Server should listen on specific IP and port](#puppet-server-should-listen-on-specific-ip-and-port)
    * [puppet-admin HTTP API Client Whitelist](#puppet-admin-http-api-client-whitelist)
    * [Add any setting to puppetserver.conf without specific parameter](#add-any-setting-to-puppetserverconf-without-specific-parameter)
5. [Reference](#reference)
  * [Classes](#classes)
  * [Defines](#defines)
  * [Parameters](#parameters)
    * [::ospuppet::agent](#ospuppetagent)
    * [::ospuppet::master](#ospuppetmaster)
    * [::ospuppet::server](#ospuppetserver)
6. [Limitations](#limitations)
7. [Development](#development)
  * [Running tests](#running-tests)

## Overview

The ospuppet module lets you use Puppet to install, configure and manage puppet itself.

## Module Description

The ospuppet module lets you use Puppet for following components:

  * Puppet Agent
  * Puppet Master
  * Puppet Server (>2.0.0)

To manage the files in ini format the module uses the resources of the module [puppetlabs/inifile](https://forge.puppetlabs.com/puppetlabs/inifile). It uses the resources of the module [puppetlabs/hocon](https://forge.puppetlabs.com/puppetlabs/hocon) to manage the files in HOCON format.
Additionally the module uses [puppetlabs/puppetserver_gem](https://forge.puppetlabs.com/puppetlabs/puppetserver_gem) to install gems in Puppet Server.

### Puppet Agent

The module lets you install, configure and manage the Puppet Agent. Currently it's possible to manage the `init settings` and the `puppet.conf` configuration file. The class `::ospuppet::agent` does have parameters for the very standard settings in the configuration file. There are also hashes to add or manage other settings without dedicated parameters.

### Puppet Master

The module lets you configure the `hiera.yaml` with the backends `yaml` and `eyaml`. The module creates a private-/public-key pair if `eyaml` is enabled. The class has parameters for the standard settings in the configuration file (section `master`). It's possible to manage any ini setting with a `custom_settings` hash.

### Puppet Server

The module lets you install, configure and manage the Puppet Server. Currently it's possible to manage the `init settings`, `puppetserver.conf` and `webserver.conf` configuration files. The class `::ospuppet::server` does have parameters for the very standard settings in the mentioned configuration files. There are also hashes to add or manage other settings without dedicated parameters.

## Setup

### Setup requirements

Make sure that following modules are installed:
```
puppet module install puppetlabs-stdlib
puppet module install puppetlabs-inifile
puppet module install puppetlabs-hocon
puppet module install puppetlabs-puppetserver_gem
```
Make sure that the necessary software packages are available for the package manager (like *yum*).
For example you can use the [Puppet Collections](https://docs.puppetlabs.com/guides/puppetlabs_package_repositories.html#using-puppet-collections).

### Beginning with ospuppet

#### Puppet Agent

The simplest way to install and start the Puppet Agent is...

```
include ::ospuppet::agent
```

#### Puppet Master

The simplest way to get Puppet Master up and running with this module is...

```
include ::ospuppet::server
include ::ospuppet::master
```

#### Puppet Server

The simplest way to get Puppet Server up and running with this module is...

```
include ::ospuppet::server
```

## Usage

### Usage of Puppet Agent

#### Install Puppet Agent and specify some settings

Simply install the Puppet Agent, specify the `certname`, `server`, `runinterval`, etc. and start the service.

```
class { '::ospuppet::agent':
  package_name      => 'puppet-agent',
  package_version   => '1.2.4-1.el7',
  service_running   => true,
  service_enabled   => true,
  certname          => $::fqdn,
  server            => "puppetmaster.example.com",
  usecacheonfailure => true,
  runinterval       => '60m',
}
```

### Usage of Puppet Master

#### Configure Hiera Settings

Configure the hiera settings in `hiera.yaml' and make sure that the necessary gems are installed:

```
class { '::ospuppet::master':
  hiera_merge_package_version => '1.0.1',
  hiera_eyaml_package_version => '2.0.8',
  hiera_backends              => [ 'yaml', 'eyaml' ],
  hiera_hierarchy             => [
    'secure/nodes/%{::clientcert}',
    'nodes/%{::clientcert}',
    'services/%{::service}/%{::role}',
    'locations/%{::location}',
    'common',
  ],
  hiera_yaml_datadir          => '/etc/puppetlabs/code/environments/%{environment}/hieradata',
}
```

### Usage of Puppet Server

#### Memory Allocation
Use following parameters to change the Puppet Server memory allocation and to set the path to the java binary (*init settings*).
```
class { '::ospuppet::server':
  init_settings_java_bin         => '/usr/bin/java',
  init_settings_java_xms         => '512m',
  init_settings_java_xmx         => '512m',
  init_settings_java_maxpermsize => '256m',
}
```

#### Manage Puppet Server Service and stop Puppet Master

This will make sure that the Puppet Server service is running and the service is enabled.
When `$service_manage_master` is set to true it will make sure that any Puppet Master service is stopped.
(It might be possible that an error occur when there's no Puppet Master service. I'm thinking about removing this.)

```
class { '::ospuppet::server':
  service_name          => 'running',
  service_running       => true,
  service_enabled       => true,
  service_manage_master => true,
}
```

#### Puppet Server should listen on specific IP and port

Use the parameters `webserver_ssl_host` and `webserver_ssl_port` to specify the IP and port.
```
class { '::ospuppet::server':
  webserver_ssl_host => '0.0.0.0',
  webserver_ssl_port => '8140',
}
```

#### puppet-admin HTTP API Client Whitelist

To manage the puppet-admin HTTP API Client Whitelist:
```
class { '::ospuppet::server':
  puppetserver_admin_client_whitelist => ['puppet.example.com', 'server.example.com'],
}
```

#### Add any setting to puppetserver.conf without specific parameter

The hash `puppetserver_custom_settings` can be used to create any [hocon_setting](https://github.com/puppetlabs/puppetlabs-hocon#usage) resource.
```
class { '::ospuppet::server':
  puppetserver_max_active_instances => 1,
  puppetserver_custom_settings      => {
    'max-requests-per-instance' => {
      'ensure'  => 'present',
      'setting' => 'jruby-puppet.max-requests-per-instance',
      'value'   => '0',
      'type'    => 'number',
    },
    'authorization-required'    => {
      'ensure'  => 'present',
      'setting' => 'puppet-admin.authorization-required',
      'value'   => true,
      'type'    => 'boolean',
    },
  },
}
```

## Reference

### Classes

#### Public Classes

  * `::ospuppet::agent` class to manage Puppet Agent.
  * `::ospuppet::master` class to manage Puppet Master.
  * `::ospuppet::server` class to manage Puppet Server.

#### Private Classes

  * `::ospuppet` main class. Parameters for other classes. See [::ospuppet](#ospuppet2).
  * `::ospuppet::agent::config` class for the configuration of the Puppet Agent.
    * `::ospuppet::agent::config::init_settings` manages the init settings.
    * `::ospuppet::agent::config::settings` manages settings in `puppet.conf`.
  * `::ospuppet::agent::install` class responsible for the installation of the Puppet Agent.
  * `::ospuppet::agent::service` this class manages the Puppet Agent services.
  * `::ospuppet::master::config` class for the configuration of the Puppet Master.
    * `::ospuppet::master::config::hiera` manages the `hiera.yaml`.
      * `::ospuppet::master::config::hiera::eyaml` installs and configures eyaml.
      * `::ospuppet::master::config::hiera::merge` installs the gem for the merge behavior.
    * `::ospuppet::master::config::settings` manages settings in `puppet.conf`.
  * `::ospuppet::server::config` class for the configuration of the Puppet Server.
    * `::ospuppet::server::config::init_settings` manages the init settings.
    * `::ospuppet::server::config::puppetserver` manages the settings in the `puppetserver.conf`.
    * `::ospuppet::server::config::webserver` manages the settings in the `webserver.conf`.
  * `::ospuppet::server::install` class responsible for the installation of the Puppet Server.
  * `::ospuppet::server::service` this class manages the Puppet Server services.

### Parameters

#### ::ospuppet

Do NOT declare this private class! Please rely on automated data binding to set those parameter values!

##### `puppet_user`

Specifies the user for the Puppet processes. Valid options: a string containing a valid user name. Default: `puppet`.

##### `puppet_group`

Specifies the group for the Puppet processes. Valid options: a string containing a valid user name. Default: `puppet`.

##### `puppet_confdir`

Specifies the path to the puppet configuration files. Valid options: a string containing an absolute path. options: Default: `/etc/puppetlabs/puppet`

##### `puppet_config`

Specifies the configuration file for Puppet. Valid options: a string containing a valid file name. Default: `puppet.conf`

##### `puppet_codedir`

Specifies the path to the puppet code dir. Valid options: a string containing an absolute path. Default: `/etc/puppetlabs/code`

##### `puppet_gem_provider`

Specifies the provider for Puppet. Valid options: a string containing a valid provider. Default: `puppet_gem`.

##### `puppetserver_gem_provider`

Specifies the provider for Puppet Server. Valid options: a string containing a valid provider. Default: `puppetserver_gem`.

#### ::ospuppet::agent

##### `package_name`

Specifies the package to install. Valid options: a string containing a valid package name. Default: `puppet-agent`.

##### `package_version`

Specifies which version of the package should be installed. Valid options: a string containing a version. Default: `latest`.

##### `service_name`

Specifies the service name of the Puppet Agent. Valid options: a string containing a valid service name. Default: `puppet`.

##### `service_running`

Specifies if the service is running. Valid options: a boolean. Default: `true`.

##### `service_enabled`

Specifies if the service is enabled. Valid options: a boolean. Default: `true`.

##### `init_settings_config`

Specifies the init settings configuration file. Valid options: a string containing an absolute path. Default: `/etc/sysconfig/puppet` (RedHat) or `/etc/default/puppet` (Debian).

##### `init_settings_custom_settings`

A hash for any init setting. Valid options: a hash containing a hash with a title, valid parameters and values. Default: `{}` (empty hash).

##### `init_settings_custom_subsettings`

A hash for any init (sub-)setting (like `JAVA_ARGS`). Valid options: a hash containing a hash with a title, valid parameters and values. Default: `{}` (empty hash).

##### `certname`

The name to use when handling certificates. Valid Options: a valid FQDN. Default: `$::fqdn`

##### `server`

Specifies the puppet master server to which the puppet agent should connect. Valid Options: a hostname or FQDN. Default: `puppet`

##### `ca_server`

The server to use for certificate authority requests. Only set if parameter is defined. Otherwise using puppet defaults. Valid Options: a hostname or FQDN. Default: `undef`

##### `report`

Whether to send reports after every transaction. Valid options: a boolean. Default: `true`.

##### `report_server`

The server to send transaction reports to. Only set if parameter is defined. Otherwise using puppet defaults. Valid Options: a hostname or FQDN. Default: `undef`

##### `environment`

The environment Puppet is running in. Valid options: a string. Default: `production`

Note: this parameter sets the environment parameter in both the `[main]` and `[agent]` sections of `puppet.conf` which may not be what you want unless you're running puppet in masterless mode. Specifically, this requires the environment you set here to be present in the code directory (e.g. `/etc/puppetlabs/code/environments/`), or other puppet commands such as facts or config may stop working. If you just want to set the environment used by the agent to request a catalog, use the
`custom_settings` parameter instead to set `environment` for just the agent section of the config file (see the example below).

##### `priority`

The scheduling priority of the process. Only set if parameter is defined. Otherwise using puppet defaults. Valid options: an integer. Default: `undef`

##### `usecacheonfailure`

Whether to use the cached configuration when the remote configuration will not compile. Valid options: a boolean. Default: `true`.

##### `runinterval`

How often puppet agent applies the catalog. Valid options: 0 or a string ending with s, m, h, d or y. Default: `30m`

##### `waitforcert`

How frequently puppet agent should ask for a signed certificate. Valid options: 0 or a string ending with s, m, h, d or y. Default: `2m`

##### `daemonize`

Whether to send the process into the background. Valid options: a boolean. Default: `true`.

##### `custom_settings`

A hash for any setting in the `puppet.conf`, section `[agent]`. Valid options: a hash containing a hash with a title, valid parameters and values. Default: `{}` (empty hash). For example:

```
class { '::ospuppet::agent':
  custom_settings => {
    'ospuppet::agent::config::settings.agent.environment' => {
      'ensure'  => 'present',
      'setting' => 'environment',
      'value'   => 'qa',
    },
  }
}
```

#### ::ospuppet::master

##### `vardir`

Specifies the path to Puppet Server var directory. Valid options: a string containing an absolute path. Default: `/opt/puppetlabs/server/data/puppetserver`

##### `logdir`

Specifies the path to Puppet Server log directory. Valid options: a string containing an absolute path. Default: `/var/log/puppetlabs/puppetserver`

##### `rundir`

Specifies the path to Puppet Server run directory. Valid options: a string containing an absolute path. Default: `/var/run/puppetlabs/puppetserver`

##### `pidfile`

Specifies the path to Puppet Server pid file. Valid options: a string containing an absolute path. Default: `/var/run/puppetlabs/puppetserver/puppetserver.pid`

##### `dns_alt_names`

A comma-separated list of alternative DNS names used for `subjectAltName` in the certificate. Setting is set in the file `puppet.conf`, section `[main]`.Valid options: a string containing a comma-separated list of names. Default: undef.

##### `custom_settings`

A hash for any setting in the `puppet.conf`, section `[master]`. Valid options: a hash containing a hash with a title, valid parameters and values. Default: `{}` (empty hash).

##### `hiera_config`

Specifies the path to the `hiera.yaml`. Valid options: a string containing an absolute path. Default: `/etc/puppet/code/hiera.yaml`.

##### `hiera_backends`

Specifies the backends for hiera. Valid options: an array containing strings. Default: `[ 'yaml', 'eyaml' ]`.

##### `hiera_hierarchy`

Specifies the backends for hiera. Valid options: an array containing pathes within the hiera datadir.
Default: `[ 'secure/nodes/%{::clientcert}', 'secure/services/%{::service}/%{::stage}/%{::role}', 'nodes/%{::clientcert}', 'services/%{::service}/%{::stage}/%{::role}', 'services/%{::service}/%{::stage}', 'services/%{::service}/%{::role}', 'services/%{::service}', 'locations/%{::location}', 'common' ]`.

##### `hiera_yaml_datadir`

Specifies the path to the yaml and eyaml datadir. Valid options: a string containing an absolute path. Default: `/etc/puppetlabs/code/environments/%{environment}/hieradata`.

##### `hiera_merge_package_name`

Specifies the name of the hiera merge gem. Valid options: a string containing a valid name. Default: `deep_merge`.


##### `hiera_merge_package_version`

Specifies which version of the package should be installed. Valid options: a string containing a version. Default: `latest`.

##### `hiera_merge_behavior`

Specifies the merge behavior. Valid options: a string containing a valid merge behavior: `native`, `deep` or `deeper`. Default: `deeper`.

##### `hiera_logger`

Specifies the logging of hiera. Valid options: a string containing a valid log type: `noop`, `console` or `puppet`. Default: `noop`.

##### `hiera_eyaml_package_name`

Specifies the name of the eyaml gem. Valid options: a string containing a valid name. Default: `hiera-eyaml`.

##### `hiera_eyaml_package_version`

Specifies which version of the package should be installed. Valid options: a string containing a version. Default: `latest`.

##### `hiera_eyaml_extension`

Specifies the extension for eyaml files. Valid options: a string. Default: `eyaml`.

##### `hiera_eyaml_key_dir`

Specifies the path to the eyaml keys. Valid options: a string containing an absolute path. Default: `/etc/puppetlabs/puppet/keys`.

##### `hiera_eyaml_private_key`

Specifies the name of the eyaml private key. Valid options: a string. Default: `private_key.pkcs7.pem`.

##### `hiera_eyaml_public_key`

Specifies the name of the eyaml public key. Valid options: a string. Default: `public_key.pkcs7.pem`.

##### `gem_provider_install_options`

Specifies an array for the `install_options` of the package-resources with provider `gem`. Valid options: an array. Default: `[]`.

#### ::ospuppet::server

##### `package_name`

Specifies the package to install. Valid options: a string containing a valid package name. Default: `puppetserver`.

##### `ensure_installed`

Specifies if Puppet Server should be installed. Valid options: a boolean. Default: `true`.

##### `package_version`

Specifies which version of the package should be installed. Valid options: a string containing a version. Default: `latest`.

##### `service_name`

Specifies the service name. Valid options: a string containing a valid service name. Default: `puppetserver`.

##### `service_running`

Specifies if the service is running. Valid options: a boolean. Default: `true`.

##### `service_enabled`

Specifies if the service is enabled. Valid options: a boolean. Default: `true`.

##### `service_manage_master`

Specifies if the Puppet Master service is managed. Managed means this module stops and disables the service. Valid options: a boolean. Default: `false`.

##### `config_dir`

Specifies the configuration directory of the Puppet Server installation. Parameter is also used for the init setting `CONFIG`. Valid options: a string containing an absolute path. Default: `/etc/puppetlabs/puppetserver/conf.d`.

##### `init_settings_config`

Specifies the init settings configuration file. Valid options: a string containing an absolute path. Default: `/etc/sysconfig/puppetserver` (RedHat) or `/etc/default/puppetserver` (Debian).

##### `init_settings_java_bin`

Specifies the path to the java binary (init setting `JAVA`). Valid options: a string containing an absolute path. Default: `/usr/bin/java`.

##### `init_settings_java_xms`

Specifies the Xms subsetting for the JVM in the init setting `JAVA_ARGS`. Valid options: a string containing a number and ends with `m` (megabyte) or `g` (gigabyte). Default: `2g`.

##### `init_settings_java_xmx`

Specifies the Xmx subsetting for the JVM in the init setting `JAVA_ARGS`. Valid options: a string containing a number and ends with `m` (megabyte) or `g` (gigabyte). Default: `2g`.

##### `init_settings_java_maxpermsize`

Specifies the MaxPermSize subsetting for the JVM in the init setting `JAVA_ARGS`. Valid options: a string containing a number and ends with `m` (megabyte) or `g` (gigabyte). Default: `256m`.

##### `init_settings_user`

Specifies the user for the Puppet Server processes in the init setting `user`. Valid options: a string containing a valid user name. Default: `puppet`.

##### `init_settings_group`

Specifies the group for the Puppet Server processes in the init setting `user`. Valid options: a string containing a valid group name. Default: `puppet`.

##### `init_settings_install_dir`

Specifies the installation directory of the Puppet Server installation in the init setting `INSTALL_DIR`. Valid options: a string containing an absolute path. Default: `/etc/puppetlabs/puppetserver/bootstrap.cfg`.

##### `init_settings_bootstrap_config`

Specifies the bootstrap configuration file for Puppet Server in the init setting `BOOTSTRAP_CONFIG`. Valid options: a string containing an absolute path. Default: `/etc/puppetlabs/puppetserver/bootstrap.cfg`.

##### `init_settings_service_stop_retries`

Specifies the number for the init setting `SERVICE_STOP_RETRIES`. Valid options: a number. Default: `60`.

##### `init_settings_custom_settings`

A hash for any init setting. Valid options: a hash containing a hash with a title, valid parameters and values. Default: `{}` (empty hash).

##### `init_settings_custom_subsettings`

A hash for any init (sub-)setting (like `JAVA_ARGS`) Valid options: a hash containing a hash with a title, valid parameters and values. Default: `{}` (empty hash).

##### `puppetserver_ruby_load_path`

Specifies the places for the puppet-agent dependencies like puppet, facter, etc. Valid options: an array containing an absolute path. Default: `['/opt/puppetlabs/puppet/lib/ruby/vendor_ruby']`.

##### `puppetserver_gem_home`

Specifies where JRuby will look for gems. Valid options: a string containing an absolute path. Default: `/opt/puppetlabs/server/data/puppetserver/jruby-gems`.

##### `puppetserver_master_conf_dir`

Specifies the path to puppet master configuration directory. Valid options: a string containing an absolute path. Default: `/etc/puppetlabs/puppet`.

##### `puppetserver_master_code_dir`

Specifies the path to puppet master code directory. Valid options: a string containing an absolute path. Default: `/etc/puppetlabs/code`.

##### `puppetserver_master_var_dir`

Specifies the path to puppet master var directory. Valid options: a string containing an absolute path. Default: `/opt/puppetlabs/server/data/puppetserver`.

##### `puppetserver_master_run_dir`

Specifies the path to puppet master run directory. Valid options: a string containing an absolute path. Default: `/var/run/puppetlabs/puppetserver`.

##### `puppetserver_master_log_dir`

Specifies the path to puppet master log directory. Valid options: a string containing an absolute path. Default: `/var/log/puppetlabs/puppetserver`.

##### `puppetserver_max_active_instances`

Specifies the maximum number of JRuby instances to allow. Valid options: a number. Default: `undef`.

##### `puppetserver_profiler_enabled`

Enables or disables profiling for the Ruby code. Valid options: a boolean. Default: `undef`.

##### `puppetserver_admin_client_whitelist`

Specifies the values for the puppet-admin HTTP API client whitelist. Valid options: an array containing strings with valid client certificate names. Default: `[]` (empty array).

##### `puppetserver_custom_settings`

A hash for any setting in the `puppetserver.conf`. Valid options: a hash containing a hash with a title, valid parameters and values. Default: `{}` (empty hash).

##### `webserver_access_log_config`

Specifies the path to an XML file containing configuration information for the Logback-access module. Valid options: a string containing an absolute path. Default: `/etc/puppetlabs/puppetserver/request-logging.xml`.

##### `webserver_client_auth`

Specifies the mode that the server uses to validate the client's certificate for incoming SSL connections. A string containing `none`, `need` or `want`. Default: `want`.

##### `webserver_ssl_host`

Sets the hostname to listen on for encrypted HTTPS traffic. Valid options: a string containing an IP address (or localhost). Default: `0.0.0.0`.

##### `webserver_ssl_port`

Sets the port to use for encrypted HTTPS traffic. Valid options: a string containing a valid port number. Default: `8140`.

##### `webserver_custom_settings`

A hash for any setting in the `webserver.conf`. Valid options: a hash containing a hash with a title, valid parameters and values. Default: `{}` (empty hash).

### Defines

## Limitations

The module is limited to Puppet 4.x releases and RedHat or CentOS Linux.

## Development

Pull Requests and [Issues](https://github.com/juame/juame-ospuppet/issues) are highly appreciated.

### Running tests

This repository contains tests for rspec-puppet.

Quickstart:
```
gem install bundler
bundle install
bundle exec rake spec
```
