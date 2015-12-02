class dtp_webhook_pandoc_artigos (
        $webhook_wsgi_hello = false,
        $webhook_wsgi_hello_flask = false,
        $webhook_service_name = 'webhook-dev.puppet',
        $webhook_docroot = '/var/www/webhook',
        $webhook_script_aliases = '/artigos-2pdf',
        $webhook_pdfdownload_aliases = '/artigos-download',
        $webhook_pdfdownload_aliases_path = '/var/tmp/webhook_tmp',
        $webhook_markdowntemplate_path = '/var/share/markdown-template/',
        $dtp_puppetversion_min = '3.8',
        $dtp_puppetversion_max = '3.8.4',
        )
{
  /*
    # verifica puppet suportado
    # facters institucionais
      dtp_puppetversion_min => versão minima suportada
      dtp_puppetversion_max => versão máxima suportada
  */
  if (!(versioncmp($puppetversion, $dtp_puppetversion_min) > 0 and versioncmp($dtp_puppetversion_max, $puppetversion) >= 0))  {
    fail("webhook_pandoc_artigos: puppet version ${puppetversion} is not supported")
  } else {
    info("puppet version ${puppetversion} supported")
  }

  # verifica suporte a plataforma
  case $::osfamily {
    'RedHat': {
      if versioncmp($::operatingsystemmajrelease, '6') < 0 {
        $msg = "Plataforma ${::operatingsystem}-${::operatingsystemmajrelease} não suportada."
        fail("mod webhook_pandoc_artigos: ${msg}")
      }
    }
    default: {
      $msg = "Plataforma ${::osfamily} não suportada."
      fail("mod webhook_pandoc_artigos: ${msg}")
    }
  }

  $msg = "Plataforma ${::osfamily}-${::operatingsystemrelease} suportada. "
  notice("mod webhook_pandoc_artigos: ${msg}")

  # http: WEBHOOK
  include apache
  include 'apache::mod::wsgi'
  apache::vhost { "${webhook_service_name}":
    port                        => '80',
    docroot                     => "${webhook_docroot}",
    aliases                     => [{ alias => $webhook_pdfdownload_aliases,
                                      path => $webhook_pdfdownload_aliases_path,
                                    }],
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
    /(?i-mx:debian)/               => [ "make", "pandoc",
                                        "texlive",
                                        "texlive-full"
                                      ],
    /(?i-mx:centos|fedora|redhat)/ => [ "make", "pandoc", "pandoc-pdf", "pandoc-citeproc",
                                        "python-pip", "python-flask",
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
  package { $packages: ensure => present }

  if $webhook_wsgi_hello {
    file { "webhook_hello":
      path => "${webhook_docroot}/webhook.wsgi",
      source => "puppet:///modules/dtp_webhook_pandoc_artigos/webhook-hello.wsgi"
    }
  }

  if $webhook_wsgi_hello_flask {
    file { "webhook_hello_flask":
      path => "${webhook_docroot}/webhook.wsgi",
      source => "puppet:///modules/dtp_webhook_pandoc_artigos/webhook-hello_flask.wsgi"
    }
  }

  if (!(($webhook_wsgi_hello) and ($webhook_wsgi_hello_flask))) {
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

    file {"${webhook_docroot}/webhook.cfg":
      ensure => present,
      audit => all,
    }

    exec { 'webhook_markdowntemplate':
      path => '/usr/bin',
      command => "git clone http://www-git.prevnet/documentos/markdown-template.git ${webhook_markdowntemplate_path}",
      onlyif => ["test ! -f ${webhook_markdowntemplate_path}/makefile"],
    }

  }

}
