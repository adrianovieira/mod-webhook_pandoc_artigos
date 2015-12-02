class dtp_webhook_pandoc_artigos (
        $webhook_wsgi_hello = false,
        $webhook_wsgi_hello_flask = false,
        $webhook_service_name = 'webhook-dev.puppet',
        $webhook_docroot = '/var/www/webhook',
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
    wsgi_script_aliases         => { '/' => "${webhook_docroot}/webhook.wsgi" },
  }

  $packages = $operatingsystem ? {
    /(?i-mx:debian)/               => [ "make", "pandoc",
                                        "texlive",
                                        "texlive-full"
                                      ],
    /(?i-mx:centos|fedora|redhat)/ => [ "make", "pandoc", "pandoc-pdf", "pandoc-citeproc", "python-pip",
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

}
