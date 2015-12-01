class dtp_webhook_pandoc_artigos (
        $webhook_wsgi_replace = false,
        $webhook_service_name = 'webhook-dev.puppet',
        $webhook_docroot = '/var/www/webhook',
        )
{
  # verifica suporte a plataforma
  case $::osfamily {
    'RedHat': {
      if $::operatingsystemmajrelease <= 6 {
        $msg = "Plataforma ${::osfamily}-${::operatingsystemmajrelease} não suportada."
        fail("modulo dtp_webhook_pandoc_artigos : ${msg}")
      }
    }
    default: {
      $msg = "Plataforma ${::osfamily} não suportada."
      fail("modulo dtp_webhook_pandoc_artigos : ${msg}")
    }
  }

  $msg = "Plataforma ${::osfamily}-${::operatingsystemrelease} suportada. "
  notice("modulo dtp_webhook_pandoc_artigos : ${msg}")

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

  if $webhook_wsgi_replace {
    #  /*
     file { "webhook_hello":
       path => "${webhook_docroot}/webhook.wsgi",
       content => '# -*- coding: utf-8 -*-
import os, time
def application(environ, start_response):
    status = "200 OK"
    output = "Olá, Webhook em "+ os.uname()[1] +"! <br /><small>"+time.strftime("%d/%h/%Y %H:%M:%S")+"</small>"

    response_headers = [("Content-type", "text/html"),
                        ("Content-Length", str(len(output)))]
    start_response(status, response_headers)

    return [output]

        ',
     }
     #*/

     /*
     file { "webhook_hello_flask":
       path => "${webhook_docroot}/webhook.wsgi",
       content => '# -*- coding: utf-8 -*-
import os, time
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello_world():
    return "Hello World!"+ os.uname()[1] +"! <br /><small>"+time.strftime("%d/%h/%Y %H:%M:%S")+"</small>"

        ',
     }
     */
  }

}
