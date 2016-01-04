class webhook_pandoc_artigos::params (
        $webhook_service_name = 'webhook-dev.puppet',
        $webhook_service_name_aliases = 'webhook-dev',
        $webhook_docroot = '/var/www/webhook',
        $webhook_script_aliases = '/artigos-2pdf',
        $webhook_pdfdownload_aliases = '/artigos-download',
        $webhook_pdfdownload_aliases_path = '/var/tmp/webhook_tmp',
        $webhook_markdowntemplate_path = '/var/share/markdown-template/',
        $webhook_gitlab_user_name = hiera('webhook_gitlab_user_name','admin'),
        $webhook_gitlab_user_pass = hiera('webhook_gitlab_user_pass','secret'),
        $dtp_puppetversion_min = '3.6.2',
        $dtp_puppetversion_max = '3.8.4',
        $exec_environment = undef, # environment for exec
        $webhook_wsgi_hello = false,  # initial setup test (hello, world)
        $webhook_wsgi_hello_flask = false, # initial setup test (hello, world by flask)
        )
{

}
