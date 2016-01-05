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

  A ```webhook_pandoc_artigos``` é a classe base para implementar a aplicação ```webhook_pandoc_artigos```.

1. Parâmetros padrão e forma de uso:

  ```puppet
  class { 'webhook_pandoc_artigos':
          $exec_environment = undef, # environment for exec resource (type)
          $webhook_wsgi_hello = false,  # initial setup test (hello, world)
          $webhook_wsgi_hello_flask = false, # initial setup test (hello, world by flask)
        }
  ```

1. Dados de configuração:

  Os dados devem ser disponibilizados via ***Hiera (datasources)*** e seguindo a hierarquia estabelecida de separação de dados e código (<http://www-git/puppet/documentos/wikis/puppet#37-separa%C3%A7%C3%A3o-de-dados-e-c%C3%B3digo>). Os parâmetros necessários para configurar a aplicação, são:

   - **```webhook_service_name```**: nome para acesso ao serviço/aplicação; Host webhook para de acesso ao ao serviço de conversão de arquivos
   - **```webhook_service_name_aliases```**: nome adicionais (apelidos) para acesso ao serviço/aplicação; Alias webhook para de acesso ao ao serviço de conversão de arquivos
   - **```webhook_docroot```**: Diretório de instalação da aplicação webhook para serviço de conversão de arquivos
   - **```webhook_script_aliases```**: Endereço (URL) para envio de arquivo (*Pandoc/Markdown*) a ser convertido para *PDF*
   - **```webhook_pdfdownload_aliases```**: Endereço (URL) para obter o arquivo (*PDF*) resultado da conversão realizada
   - **```webhook_pdfdownload_aliases_path```**: Diretório temporário onde serão armazenados os arquivos *Pandoc/Markdown* e  *PDF*
   - **```webhook_markdowntemplate_path```**: Diretório de instalação da ferramenta/aplicação ***markdown-template*** necessária para o serviço de conversão de arquivos
   - **```webhook_gitlab_user_name```**: Nome de usuário para conexão do serviço *Webhook* ao serviço *Gitlab*
   - **```webhook_gitlab_user_pass```**: Senha do usuário para conexão do serviço *Webhook* ao serviço *Gitlab*
   - **```dtp_puppetversion_min```** *(opcional)*: Versão de puppet minima suportada
   - **```dtp_puppetversion_max```** *(opcional)*: Versão máxima suportada de puppet
   - **```exec_environment```** *(opcional)*: Parâmetros para ambiente (environment) de execução de scripts/módulo puppet
   - **```webhook_wsgi_hello```** *(opcional)*: Implementa aplicação python simples (hello, world)
   - **```webhook_wsgi_hello_flask```** *(opcional)*: Implementa aplicação python+flask simples (hello, world by flask)  

  Amostra de parâmetros e respectivos valores para arquivo *Hiera* (exemplo: ```webhook.yaml```)

  ```yaml
  webhook_service_name: webhook-hom.puppet
  webhook_service_name_aliases: webhook-hom, hwebhook.puppet, hwebhook
  webhook_script_aliases: /artigos-2pdf
  webhook_pdfdownload_aliases: /artigos-download
  webhook_docroot: /u01/var/www/webhook
  webhook_pdfdownload_aliases_path: /u01/var/tmp/webhook_tmp
  webhook_markdowntemplate_path: /u01/var/share/markdown-template/
  webhook_gitlab_user_name: admin
  webhook_gitlab_user_pass: secret
  dtp_puppetversion_min: 3.6.2
  dtp_puppetversion_max: 3.8.4
  ```

## A Fazer

As implementações serão tratadas por tickets/*issues* a serem adicionados no projeto.

## Testes/exemplo

Para testes funcionais desse módulo poderá ser visto (ou executado) o provisionamento em *Vagrant* segundo o *script* na pasta ```examples```.

## Contribuições

Para contribuir crie sua ***branch*** identificando o *recurso* que irá fazer e ...

## Release Notes/Contributors/Etc **Optional**

Por enquanto não temos um *changelog*, mas em princípio é ideal que controlemos a evolução via *milestones* e *issues* no site desse projeto.
