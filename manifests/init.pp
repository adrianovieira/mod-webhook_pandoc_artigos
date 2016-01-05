class webhook_pandoc_artigos (
        $exec_environment = $webhook_pandoc_artigos::params::exec_environment, # environment for exec
        $webhook_wsgi_hello = $webhook_pandoc_artigos::params::webhook_wsgi_hello,  # initial setup test (hello, world)
        $webhook_wsgi_hello_flask = $webhook_pandoc_artigos::params::webhook_wsgi_hello_flask, # initial setup test (hello, world by flask)
      ) inherits webhook_pandoc_artigos::params
{
  /*
    # verifica puppet suportado
    # facters institucionais
      dtp_puppetversion_min => versão minima suportada
      dtp_puppetversion_max => versão máxima suportada
  */
  if (!(versioncmp($puppetversion, $dtp_puppetversion_min) >= 0 and versioncmp($dtp_puppetversion_max, $puppetversion) >= 0))  {
    fail("webhook_pandoc_artigos: puppet version ${puppetversion} is not supported. Use: ${dtp_puppetversion_min} thru ${dtp_puppetversion_max}.")
  } else {
    info("puppet version ${puppetversion} supported")
  }

  # verifica suporte a plataforma
  case $::operatingsystem {
    'RedHat', 'Centos': { # operating system 'RedHat', 'CentOS'
      if versioncmp($::operatingsystemmajrelease, '6') < 0 {
        fail("mod webhook_pandoc_artigos: operating system version ${::operatingsystem}-${::operatingsystemmajrelease} is not supported. Use ${::operatingsystem}>=6")
      }
    }
    'Debian': { # operating system Debian like
      if versioncmp($::operatingsystemmajrelease, '8') < 0 {
        fail("mod webhook_pandoc_artigos: operating system version ${::operatingsystem}-${::operatingsystemmajrelease} is not supported. Use ${::operatingsystem}>=8")
      }
    }
    default: {
      fail("mod webhook_pandoc_artigos: operating system ${::osfamily} is not supported")
    }
  }

  info("Operating system ${::osfamily}-${::operatingsystemrelease} supported (env: [${environment}])")

  # http: WEBHOOK
  include apache
  include 'apache::mod::wsgi'
  apache::vhost { "${webhook_service_name}":
    serveraliases => "${webhook_service_name_aliases}",
    port                        => '80',
    docroot                     => "${webhook_docroot}",
    aliases                     => [{ alias => $webhook_pdfdownload_aliases,
                                      path => $webhook_pdfdownload_aliases_path,
                                    }],
    options                     => '-Indexes',
    wsgi_application_group      => '%{GLOBAL}',
    wsgi_daemon_process         => 'wsgi',
    wsgi_daemon_process_options => {
      processes    => '2',
      threads      => '15',
      display-name => '%{GROUP}',
    },
    wsgi_import_script          => "${webhook_docroot}/webhook.wsgi",
    wsgi_import_script_options  =>
      { process-group => 'wsgi', application-group => '%{GLOBAL}' },
    wsgi_process_group          => 'wsgi',
    wsgi_script_aliases         => { "${webhook_script_aliases}" => "${webhook_docroot}/webhook.wsgi" },
  }

  $packages = $operatingsystem ? {
    /(?i-mx:debian)/               => [ "make",
                                        "texlive",
                                        "texlive-xetex",
                                        "python-flask", "python-requests",
                                      ],
    /(?i-mx:centos|fedora|redhat)/ => [ "make", "pandoc", "pandoc-pdf", "pandoc-citeproc",
                                        "python-flask", "python-requests",
                                        "texlive",
                                        "texlive-texlive.infra",
                                        "texlive-framed",
                                        "texlive-ulem",
                                        "texlive-xetex",
                                        "texlive-xetex-def",
                                        "texlive-mathspec",
                                        "texlive-ucs",
                                        "texlive-pdftex",
                                        "texlive-euenc",
                                        "texlive-xltxtra",
                                        "texlive-polyglossia"
                                      ],
  }

  # dados específicos por plataforma
  case $::operatingsystem {
    'RedHat', 'Centos': { # operating system 'RedHat', 'CentOS'
      $apache_user = 'apache'
      $apache_group = 'apache'
    }
    'Debian': { # operating system Debian like
      $apache_user = 'www-data'
      $apache_group = 'www-data'
      package { 'wget': ensure => present }->
      exec {'pandoc_get':
        path => '/usr/bin',
        command => 'wget https://github.com/jgm/pandoc/releases/download/1.13.2/pandoc-1.13.2-1-amd64.deb -v',
        onlyif => [ 'test ! `/usr/bin/dpkg-query -W --showformat \'${Status} ${Package} ${Version}\n\' pandoc`',
                    "test ! -f /tmp/pandoc-1.13.2-1-amd64.deb"],
        environment => $exec_environment,
      }->
      exec {'pandoc_install':
        path => '/usr/bin',
        command => 'dpkg -i pandoc-1.13.2-1-amd64.deb',
        onlyif => 'test ! `/usr/bin/dpkg-query -W --showformat \'${Status} ${Package} ${Version}\n\' pandoc`',
        environment => 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      }
    }
  }

  # create directory tree if necessary
  exec { 'create_dirtree':
    command => "/bin/mkdir -p ${webhook_docroot} ${webhook_pdfdownload_aliases_path} ${webhook_markdowntemplate_path}",
  }->
  file { "webhook_pdfdownload_aliases_path":
    path => "${webhook_pdfdownload_aliases_path}",
    ensure => directory,
    owner => $apache_user,
    group => $apache_group,
  }

  package { $packages: ensure => present } ->
  package { 'python-pip': ensure => present }->
  exec {'pyapi-gitlab_install':
    path => '/usr/bin',
    command => 'pip install pyapi-gitlab',
    onlyif => 'test ! `pip list|grep pyapi-gitlab|wc -l` -eq 1',
    environment => $exec_environment,
  }

  if $webhook_wsgi_hello {
    file { "webhook_hello":
      path => "${webhook_docroot}/webhook.wsgi",
      source => "puppet:///modules/webhook_pandoc_artigos/webhook-hello.wsgi"
    }
  }

  if $webhook_wsgi_hello_flask {
    file { "webhook_hello_flask":
      path => "${webhook_docroot}/webhook.wsgi",
      source => "puppet:///modules/webhook_pandoc_artigos/webhook-hello_flask.wsgi"
    }
  }

  if (!(($webhook_wsgi_hello) or ($webhook_wsgi_hello_flask))) {
    $file_webhookcfg_exists = inline_template("<% if File.exist?(\'${webhook_docroot}/webhook.cfg\') -%>true<% end -%>")

    if(!$file_webhookcfg_exists) {
      package { 'git': ensure => present }
      file { "$webhook_docroot":
        path => "${webhook_docroot}",
        ensure => absent,
        force => true,
        backup => false,
      }
      ->
      exec { 'webhook_deploy':
        path => '/usr/bin',
        command => "git clone http://www-git.prevnet/hook-apps/webhook-pandoc-artigos.git ${webhook_docroot}",
        onlyif => ["test ! -f ${webhook_docroot}/webhook.cfg", "test ! -f ${webhook_docroot}/webhook.py"],
      }->
      file { "webhook_deploy":
        path => "${webhook_docroot}/webhook.wsgi",
        source => "${webhook_docroot}/webhook-dist.wsgi"
      }
    }

    $timestamp = generate('/bin/date', '+%Y%d%m_%H%M%S')
    file { "webhook.cfg":
      path => "${webhook_docroot}/webhook.cfg",
      content => template("webhook_pandoc_artigos/webhook-dist.cfg.erb"),
      backup => ".puppet-bak_${timestamp}",
      audit => content,
    }

    exec { 'webhook_markdowntemplate':
      path => '/usr/bin',
      command => "git clone http://www-git.prevnet/documentos/markdown-template.git ${webhook_markdowntemplate_path}",
      onlyif => ["test ! -f ${webhook_markdowntemplate_path}/makefile"],
    }

  }

}
