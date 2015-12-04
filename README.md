# Webhook: Módulo Puppet para deploy de aplicação ```webhook_pandoc_artigos```

É para realizar deploy de infraestrutura para a aplicação [Webhook](http://www-git/hook-apps/webhook-pandoc-artigos) que realiza a conversão de arquivos *Pandoc/Markdown* para *PDF*.

## Requisitos para o módulo

Esse módulo tem como dependência (```metadata.json```) os seguintes módulos:

- módulo Puppet Apache (+wsgi,python);

```json
{ "name": "puppetlabs/apache", "version_requirement":">= 1.2.0" }
```

## Limitações

1. Plataformas testadas:
     - ```CEntOS-7```

## Funcionalidades

### O que esse módulo faz?

Disponibiliza o serviço de conversão de artigos em **Pandoc/Markdown** para PDF

Os recursos para esse módulo são:

- configuração de site virtual (*apache-vhost*) para o *Webhook*
- configuração de URL para download de PDF
- instalação das dependências necessárias para o *Webhook* poder converter o arquivo *Pandoc/Markdown* para *PDF* (ex: pandoc)

O detalhamento de melhorias ou correções a serem realizadas podem ser vistas em *Issues* ou no *Wiki* do repositório desse módulo.

### Classes

- ```webhook_pandoc_artigos``` classe base para implementar a aplicação ```webhook_pandoc_artigos```.

1. Parâmetros padrão e forma de uso:

```puppet
class { 'webhook_pandoc_artigos':
        $webhook_service_name = 'webhook-dev.puppet',
        $webhook_docroot = '/var/www/webhook',
        $webhook_script_aliases = '/artigos-2pdf',
        $webhook_pdfdownload_aliases = '/artigos-download',
        $webhook_pdfdownload_aliases_path = '/var/tmp/webhook_tmp',
        $webhook_markdowntemplate_path = '/var/share/markdown-template/',
        $webhook_gitlab_user_name = hiera('webhook_gitlab_user_name','admin'),
        $webhook_gitlab_user_pass = hiera('webhook_gitlab_user_pass','secret'),
        $dtp_puppetversion_min = '3.6.2',
        $dtp_puppetversion_max = '3.8.4',
        $exec_environment = '', # environment for exec
        $webhook_wsgi_hello = false,  # initial setup test (hello, world)
        $webhook_wsgi_hello_flask = false, # initial setup test (hello, world by flask)
      }
```


## A Fazer

As implementações serão tratadas por tickets/*issues* a serem adicionados no projeto.

## Testes/exemplo

Para testes funcionais desse módulo poderá ser visto (ou executado) o provisionamento em *Vagrant* segundo o *script* na pasta ```examples```.

## Contribuições

Para contribuir crie sua ***branch*** identificando o *recurso* que irá fazer e ...

## Release Notes/Contributors/Etc **Optional**

Por enquanto não temos um *changelog*, mas em princípio é ideal que controlemos a evolução via *milestones* e *issues* no site desse projeto.