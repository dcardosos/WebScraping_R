library(tidyverse)
library(httr)
library(xml2)

brfut_baixar_pag <- function(){
  
  u_html <- "https://www.cbf.com.br/futebol-brasileiro/competicoes/campeonato-brasileiro-serie-a/2021"  
    
  httr::GET(u_html, 
            httr::write_disk("output/brasileirao.html",
                             overwrite = TRUE))
}


achar_tabela <- function(pagina){
  
  pagina %>% 
    read_html() %>% 
    xml_find_first('/html/body/div[1]/main/article/div[1]/div/div/section[1]/div[1]/table') %>% 
    rvest::html_table()
}

tabela_tidy <- function(tabela){
  
  new_names <- c("posicao", "time","pontos","jogos", 
                 "vitorias", "empate", "derrota",
                 "gols_pro", "gols_contra", "saldo_de_gols", 
                 "carta_amarelo", "cartao_vermelho", 
                 "aproveitamento")
  
  tabela %>% 
    janitor::clean_names() %>% 
    select(-recentes, -prox) %>%
    separate(
      col = posicao,
      into = c("posicao", "time"),
      sep = "º\r\n"
    ) %>% 
    filter(!is.na(time)) %>% 
    mutate(
      # pegando o time
      time = str_squish(time) %>% str_sub(3) %>% str_squish(),
      # texto para numero
      across(pts:ca, readr::parse_number),
    ) %>% 
    purrr::set_names(new_names) %>% 
    dplyr::mutate(
      
      aproveitamento = as.integer(aproveitamento) / 100
    )
}


aplicacao <- function(){
  
  brfut_baixar_pag() %>% 
    achar_tabela() %>% 
    tabela_tidy()
}

aplicacao() -> da

da %>% 
  group_by(carta_amarelo) %>% 
  summarise(media_aproveitamento = mean(aproveitamento)) %>% 
  arrange(-media_aproveitamento) %>% 
  ggplot(aes(carta_amarelo, media_aproveitamento)) +
  geom_point() +
  geom_smooth(method = "lm")
