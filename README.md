# Webhook: Módulo Puppet para deploy

É para realizar deploy de infraestrutura para o [Webhook](http://www-git/hook-apps/webhook-pandoc-artigos) de conversão de arquivos *Pandoc/Markdown* para *PDF*.

## Requisitos para o módulo

As dependências para esse módulo ser executado são:

- módulo Puppet Apache (+wsgi-python);

## Funcionalidades

Os recursos previstos para esse módulo são:

- configuração de site virtual (*apache-vhost*) para o *Webhook*
- configuração de URL para download de PDF
- instalação das dependências necessárias para o *Webhook* poder converter o arquivo *Pandoc/Markdown* para *PDF* (ex: pandoc)

O detalhamento desses e outros recursos a serem criados podem ser vistos em *Issues* ou no *Wiki* do repositório desse módulo.

## A Fazer

As implementações serão tratadas por tickets/*issues* a serem adicionados no projeto.

## Testes/exemplo

Para testes funcionais desse módulo poderá ser visto (ou executado) o provisionamento em *Vagrant* segundo o *script* na pasta ```examples```.
