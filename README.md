# Description

[![Code Climate](https://codeclimate.com/github/CRDevOps/logio-cookbook/badges/gpa.svg)](https://codeclimate.com/github/CRDevOps/logio-cookbook)

Cookbook logio lets you install and configure [Log.io](http://logio.org/), a real-time log monitoring tool.

# Requirements

## Platform:

* Debian
* Ubuntu
* CentOS



## Cookbooks:

*No dependencies defined*, but before using this cookbook you should run the default recipe of the [build-essential cookbook](https://supermarket.chef.io/cookbooks/build-essential).

# Attributes

* `node['logio']['nvm_version']` - Defaults to `'0.26.0'`
* `node['logio']['nvm_installer']` - Defaults to https://raw.githubusercontent.com/creationix/nvm/v0.26.0/install.sh
* `node['logio']['username']` - Defaults to `'logio'`
* `node['logio']['server']['listen_ip']` - Defaults to `'0.0.0.0'`
* `node['logio']['server']['listen_port']` - Defaults to `28_777`
* `node['logio']['client']['remote_host']` - Defaults to `'localhost'`
* `node['logio']['client']['remote_port']` - Defaults to `28_777`
* `node['logio']['client']['node_name']` - Defaults to `'localhost'`
* `node['logio']['web_server']['listen_host']` - Defaults to `'0.0.0.0'`
* `node['logio']['web_server']['listen_port']` - Defaults to `28_778`
* `node['logio']['web_server']['username']` - Defaults to `nil`
* `node['logio']['web_server']['password']` - Defaults to `nil`
* `node['logio']['web_server']['ssl_pkey']` - Defaults to `nil`
* `node['logio']['web_server']['ssl_cert']` - Defaults to `nil`
* `node['logio']['web_server']['restrict_socket']` - Defaults to `'*:*'`
* `node['logio']['web_server']['restrict_http']` - Defaults to `[]`


# Recipes

This is a LWRP-only cookbook, it means that you should write a wrapper-cookbook in order to use it.

# LWRP

Let's say you want to monitor your Apache logs, all you have to do is add your access.log and error.log files:

```ruby 
logio_harvest 'apache_access' do
  stream_name 'apache'
  log_file '/var/log/apache2/access.log'
end
```

```ruby 
logio_harvest 'apache_error' do
  stream_name 'apache'
  log_file '/var/log/apache2/error.log'
end
```

Enable the Log.io server (`log.io-server`)

```ruby
logio 'server'
```

Enable the Log.io harvester (`log.io-harvester`)

```ruby
logio 'harvester'
```

See fixture cookbook in `tests/fixtures/cookbooks`.

If you need additional help making this work, please [read this post](http://mauricioaraya.net/).

# Author

Author & Maintainer:: Mauricio Araya V. (<hello@mauricioaraya.net>)

License:: MIT