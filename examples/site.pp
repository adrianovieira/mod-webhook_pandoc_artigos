# Site.pp para testes de módulos com o vagrant.
#
#
# BEGIN: Definição de variaveis globais que estariam no foreman.
# INCLUIR TODAS AS VARIAVEIS GLOBAIS DO FOREMAN ABAIXO.
$dtp_cp = 'cprj'
$ip_master = '000.000.000.000' # colocar o ip da máquina
$dtp_download_server = "nfs.prj.configdtp" # colocar endereço do NFS
# END: Definição de variaveis globais que estariam no foreman.
Yumrepo <| |> -> Package <| provider != 'rpm' |>
File <| tag == 'repositorios' |> -> Package <| provider != 'rpm' |>
Exec <| tag == 'repositorios' |> -> Package <| provider != 'rpm' |>
if versioncmp($::puppetversion,'3.6.1') >= 0 {

  $allow_virtual_packages = hiera('allow_virtual_packages',false)

  Package {
    allow_virtual => $allow_virtual_packages,
  }
}

node default {
  # BEGIN: Exemplo de erro e sucesso.
  # SUCESSO
  # notify {"puppet executou com sucesso. CP: ${dtp_cp}":}
  # ERRO
  # fail("puppet falhou a execucao.")
  # END: Exemplo de erro e sucesso.

  # modulos basicos
  include dtp_so
  include dtp_sudo
  include dtp_repositorios

  # modulos especificos
  # firewall
  include firewall
  firewall { "000 accept all icmp requests":
    proto  => "icmp",
    action => "accept",
  }
  firewall { '22 allow ssh access':
    port   => 22,
    proto  => tcp,
    action => accept,
  }
  firewall { '100 allow http and https access':
    port   => [80, 443],
    proto  => tcp,
    action => accept,
  }
  firewall { "999 drop all other requests":
    action => "drop",
  }

  #include webhook_pandoc_artigos {$webhook_wsgi_replace = true}
  class {'webhook_pandoc_artigos':
      webhook_wsgi_hello => true,
  }

}
