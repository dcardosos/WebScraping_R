library(magrittr)

## full XPath = começa do html sempre
## XPath = tentar encontrar o menor caminho até chegar no lugar

# acesso ------------------------------------------------------------------

u_cdg <- "http://www.chancedegol.com.br/br20.htm"
r_cdg_raw <- httr::GET(u_cdg)

## status code 200 mas algo estranho acontecendo, pense: deve ser encoding
## baixe o arquivo

r_cdg_raw <- httr::GET(u_cdg, httr::write_disk("output/cdg.html", overwrite = TRUE))

## usar alguma função que diga qual o encoding de um arquivo

readr::guess_encoding("output/cdg.html")

## ISO = microsoft usa, ISO-1 é latin1 e ISO-2 é latin2 (padrão no Brasil)
## tudo do Tidyverse lê com UTF-8 (pelo menos o padrão, apesar de ser parametrizável)
## esse arquivo que estamos trabalhando NEM HEAD tem, não começa com Doctype


# parse -------------------------------------------------------------------

cdg_html <- httr::content(r_cdg_raw, encoding = "ISO-8859-1")


tabela <- 
  cdg_html %>% 
  xml_find_all("/html/body/div/font/table")

## funciona pq so tem uma table na pagina inteira
tabela_jeito_simples <-
  cdg_html %>% 
  xml_find_all("//table")

# transformando em um tibble ----------------------------------------------

tabela %>% 
  rvest::html_table(header = TRUE) %>% 
  purrr::pluck(1)

tabela_preliminar <- 
  tabela[[1]] %>% 
  rvest::html_table(header = TRUE) %>% 
  janitor::clean_names()

tabela_tidy <-
  tabela_preliminar %>% 
  dplyr::mutate(
    data = lubridate::dmy(data),
    vitoria_do_mandante = readr::parse_number(vitoria_do_mandante) / 100,
    empate = readr::parse_number(empate) / 100,
    vitoria_do_visitante = readr::parse_number(vitoria_do_visitante) / 100
  ) %>% 
  dplyr::rename(placar = x)

tabela_tidy

# versao do codigo com pipeline reduzido ----------------------------------

tabela_tidy <- 
  httr::content(r_cdg_raw, encoding = "ISO-8859-1") %>% 
  xml_find_first("//table") %>% 
  rvest::html_table(header = TRUE) %>% 
  janitor::clean_names() %>% 
  dplyr::mutate(
    data = lubridate::dmy(data),
    vitoria_do_mandante = readr::parse_number(vitoria_do_mandante) / 100,
    empate = readr::parse_number(empate) / 100,
    vitoria_do_visitante = readr::parse_number(vitoria_do_visitante) / 100
  ) %>% 
  dplyr::rename(placar = x)  

