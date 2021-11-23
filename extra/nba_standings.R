library(tidyverse)
library(httr)
library(xml2)

leitura_pag <- function(ano){
  
  u_base <- glue::glue("https://www.basketball-reference.com/leagues/NBA_{ano}_standings.html")
  
  r_nba <- httr::GET(u_base,
                     httr::write_disk(glue::glue("output/nba_{ano}.html"), 
                     overwrite = TRUE))
  
  r_nba
}

limpa_tabela <- function(tabela, .conf){
  
  tabela %>% 
    janitor::clean_names() %>% 
    dplyr::mutate(
      # trocar por na
      gb = dplyr::na_if(gb, "—"),
      # remove numeros
      {{.conf}} := str_trim({{.conf}}) %>% 
        str_extract(".*(?=\\s)"),
    ) %>% 
    dplyr::rename(times = {{.conf}})
  
}

leitura_html <- function(html, .conf){
  
  
  xpath <- glue::glue('//*[@id="confs_standings_{.conf}"]')
  
  html <- 
    xml2::read_html(html) %>%
    xml2::xml_find_first(xpath) %>% 
    rvest::html_table()
  
  html
}

eastern <- 
  leitura_pag("2021") %>% 
  leitura_html("E") %>% 
  limpa_tabela(eastern_conference)

western <- 
  leitura_pag("2021") %>% 
  leitura_html("W") %>% 
  limpa_tabela(western_conference)

nba <- 
  bind_rows(eastern, western, .id = "conferencia") %>% 
  mutate(conferencia = dplyr::case_when(
    conferencia == "1" ~ "eastern",
    conferencia == "2" ~ "western"
    ))


tab_eastern <- function(ano, .conf){

  string <- rlang::as_string(dplyr::ensym(.conf))   
  
  if ( string == "eastern_conference"){
    
    sigla <- "E"
  
  } else {
    
    sigla <- "W"
  }
 
   leitura_pag(ano) %>% 
    leitura_html(sigla) %>% 
    limpa_tabela(.conf)
  
}


tab_eastern(2020, eastern_conference)




vetor_anos <- 2016:2021

nba_eastern <- 
  purrr::map_dfr(vetor_anos, tab_eastern, .id = "ano") %>% 
  dplyr::mutate(
    ano = case_when(
      ano == "1"  ~ "2016",
      ano == "2" ~ "2017",
      ano == "3" ~ "2018",
      ano == "4" ~ "2019",
      ano == "5" ~ "2020",
      ano == "6" ~ "2021",
      ano == "7" ~ "2022"
    )
  )
 