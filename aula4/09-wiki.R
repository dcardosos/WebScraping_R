library(xml2)
library(httr)
library(magrittr)
library(purrr)
library(future)

# nossa missão é baixar várias páginas da wikipedia pro computador

# 1. listar links ----------------------------------------------------------

url0 <- "https://en.wikipedia.org/wiki/R_(programming_language)"
# por conta da barra wiki
url_wiki <- "https://en.wikipedia.org"

links <- read_html(url0) %>% 
  xml_find_all(".//a") %>% # todos os links que aparece na pagina inteira
  xml_attr("href") %>% 
  stringr::str_c(url_wiki, .) %>% 
  na.omit() %>% 
  as.character()

#links_final <- paste0(url_wiki, links)
# stringr::str_c(url_wiki, links) - mais rapido

links_para_baixar <- links[1:20]

# 2. preparar o terreno para iterar ---------------------------------------

### RASCUNHO 

link_inicial <- links[5]
diretorio <- "aula4/pasta_da_wiki/"

nome_do_arquivo <- link_inicial %>% 
  stringr::str_remove_all("[:punct:]") %>% 
  stringr::str_to_lower() %>% 
  stringr::str_c(".html") %>% 
  stringr::str_c(diretorio, .)

httr::GET(link_inicial, write_disk(nome_do_arquivo))

## basename -> me da so o final
## fs::path_file
fs::path_file(links)

### FIM DO RASCUNHO ^^ 

baixa_pag_wiki <- function(link, dir, p){
  
  if(stringr::str_detect(link, "#")){
    stop("Link com # é proibido")
    
  }
  
  nome_do_arquivo <- 
    link %>% 
    fs::path_file() %>% 
    #janitor::clean_names() %>% 
    stringr::str_replace_all("[:punct:]", "_") %>% 
    stringr::str_to_lower() %>% 
    stringr::str_c(".html") %>% 
    stringr::str_c(dir, .)
    # fs::path(dir, ., ext = "html")
  httr::GET(link, write_disk(nome_do_arquivo, overwrite = TRUE))
  
  p()
  
  return(nome_do_arquivo)
}


baixa_pag_wiki(links[1], diretorio)

# 3. iterar ---------------------------------------------------------------


maybe_baixa_pag_wiki <- possibly(baixa_pag_wiki, "esse aqui deu errado")

purrr::map(links[1:20], 
           maybe_baixa_pag_wiki, 
           dir = "aula4/pasta_da_wiki/")


q_s_baixa_pagina_wiki <- quietly(safely(baixa_pag_wiki))

# 4. paralelizacao ---------------------------------------------------------
progressr::handlers("txtprogressbar")

tictoc::tic()
progressr::with_progress({
  
  prog <- progressr::progressor(along = links[1:30])  
  
  purrr::map(links[1:30], 
             maybe_baixa_pag_wiki, 
             dir = "aula4/pasta_da_wiki/",
             p = prog)
  
})
tictoc::toc()

## versao paralela -
## tem algumas etapas de preparação do ambiente que o future faz
## aloca memoria e cria sessoes do R e carrega no ambiente dessas
## sessoes do R aquilo que é suficiente para gerar o código que vc tem
## carrega os pacotes necessários e tudo mais e essa preparação leva
## um tempo, ai na segunda vez ele vai mais rapido por guardar info
## nos caches
Sim
plan(multisession, workers = 8)

tictoc::tic()
progressr::with_progress({
  
  prog <- progressr::progressor(along = links[1:30])  
  
  furrr::future_map(links[1:30], 
             maybe_baixa_pag_wiki, 
             dir = "aula4/pasta_da_wiki/",
             p = prog)
  
})
tictoc::toc()
