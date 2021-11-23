library(tidyverse)
library(httr)
library(xml2)
library(jsonlite)
library(future)
library(furrr)
library(progressr)
library(tictoc)

# baixa_pagina ------------------------------------------------------------

baixa_pagina <- function(personagem){
  
  personagem <- 
    str_replace_all(personagem, " ", "-") %>% 
    str_to_lower() %>% 
    str_remove('"')
  
  url <- paste0("https://www.starwars.com/databank/", personagem)
  
  httr::GET(url,
            httr::write_disk(paste0("output/", personagem, ".html"),
                             overwrite = TRUE))
}

# leitura do html ---------------------------------------------------------

leitura_html <- function(arquivo){
  
  xml2::read_html(arquivo) 
  
}

# montando tabela ---------------------------------------------------------

tabela_tidy <- function(html) {
  
  imagem <- 
    html %>% 
    xml2::xml_find_first('//*[@class="aspect"]/img') %>% 
    xml2::xml_attr("src")
  
  personagem <- 
    html %>% 
    xml2::xml_find_first('//*[@class="content-info"]') %>% 
    xml2::xml_find_first('//*[@class="long-title"]') %>% 
    xml2::xml_text()
  
  descricao <- 
    html %>% 
    xml2::xml_find_first('//*[@class="content-info"]') %>% 
    xml2::xml_find_first('//*[@class="desc"]') %>% 
    xml2::xml_text()
  
  dimensoes_cm <- 
    html %>% 
    xml2::xml_find_first('//*[@class="category linebreaks"]/ul') %>% 
    xml2::xml_text() %>% 
    str_remove(",") %>% 
    str_squish() %>% 
    parse_number() * 100
  
  html %>% 
    xml2::xml_find_all('//*[@class="category"]') %>% 
    xml2::xml_text() %>% 
    stringr::str_squish() %>%
    str_sub(end = -2) %>% 
    as_tibble() %>%
    separate(col = value, 
             into = c("titulos", "texto"), 
             sep = " ",
             extra = "merge") %>% 
    pivot_wider(names_from = titulos, values_from = texto) %>% 
    # rename(
    #   filmes = Appearances,
    #   filiacao = Affiliations,
    #   genero = Gender,
    #   especie = species,
    #   armas = Weapons,
    #   veiculos = Vehicles
    # ) %>%
    mutate(
      personagem = personagem,
      descricao = descricao,
      imagem = imagem,
      dimensoes_cm = dimensoes_cm#,
      #filmes = str_split(filmes, ",")
    ) #%>% 
    #relocate(c(personagem, descricao, dimensoes_cm), .before = filmes)
  
}


# pegando todos os personagens --------------------------------------------

## vai de 40 em 40, tem 814

api_personagens <- function(offset){
  
  u_base <- "https://www.starwars.com/_grill/filter/databank"
  
  query <- list(
    "filter" = "Characters",
    "mod" = 6,
    "updated_at" = "23_11",
    "offset" = offset)
  
 httr::GET(u_base, query = query) %>% 
   httr::content(simplifyDataFrame = TRUE) %>% 
   purrr::pluck("data")
  
}

montar_tabela <- function(dados) {
  
  dados %>% 
    as_tibble() %>% 
    select(c(title, default_thumb, desc)) %>% 
    rename(
      nome = title,
      imagem = default_thumb,
      descricao = desc
    )
  
}

aplicacao <- function(offset) {
  
  api_personagens(offset) %>% 
    montar_tabela()
}


dados <- map_dfr(
  .x = seq(0, 814, 40),
  .f= ~ aplicacao(.x)
  )

#dados %>% write_csv("output/personagens_starwars")

nomes <- 
  dados %>% 
  mutate(nome = case_when(
    nome == "Sugi (Character)" ~ "sugi", 
    nome == "Q9-0 (Zero)" ~ "zero",
    nome == "Chopper (C1-10P)" ~ "chopper",
    nome == "C-3PO (See-Threepio)" ~ "c-3po",
    nome == "G1-7CH (Glitch)" ~ "badgateway",
    TRUE ~ as.character(nome)
  )) %>%
  mutate(
    nome = nome %>% 
      str_replace_all("[[:punct:]]", " ") %>% 
      str_squish() %>% 
      str_replace_all(" ", "-") %>% 
      abjutils::rm_accent() %>% 
      str_to_lower()
  ) %>% 
  pull(nome)

# aplicacao final ---------------------------------------------------------

aplicacao_final <- function(personagem){
  
  personagem %>% 
    baixa_pagina() %>% 
    leitura_html() %>% 
    tabela_tidy()

}

maybe_aplicacao <- purrr::possibly(aplicacao_final, 
                                   otherwise = tibble::tibble(erro = "erro"))

future::plan(multisession)
progressr::with_progress({
  
  p <- progressr::progressor(length(nomes))
  
  tab_tidy <- 
    furrr::future_map_dfr(nomes, ~{
      p()
      maybe_aplicacao(.x) 
    })
})