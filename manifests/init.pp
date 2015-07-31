class webhook_pandoc_artigos {
  # http: WEBHOOK
  include apache
  include 'apache::mod::wsgi'
  apache::vhost { 'webhook.www-git':
    port                        => '80',
    docroot                     => '/var/www/webhook',
    wsgi_application_group      => '%{GLOBAL}',
    wsgi_daemon_process         => 'wsgi',
    wsgi_daemon_process_options => {
      processes    => '2',
      threads      => '15',
      display-name => '%{GROUP}',
    },  
    wsgi_import_script          => '/var/www/webhook/webhook.wsgi',
    wsgi_import_script_options  =>  
      { process-group => 'wsgi', application-group => '%{GLOBAL}' },
    wsgi_process_group          => 'wsgi',
    wsgi_script_aliases         => { '/' => '/var/www/webhook/webhook.wsgi' },
  }

}


