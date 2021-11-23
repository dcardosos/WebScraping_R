library(tidyverse)
library(lubridate)
library(tidytext)
library(future)
library(furrr)
library()
# baixar pagina 

baixa_pag <- function(tx_texto, current_page = 1, dt_inicio = today() - 100, dt_fim = today()){
  
  path <- glue::glue("trabalho_final/output/{tx_texto}_{dt_inicio}_{dt_fim}_{current_page}.html")
  
  path <- path %>% str_remove_all('"') %>% str_replace_all(" ", "_")
  
  dt_inicio <- format(dt_inicio, "%d/%m/%Y")
  dt_fim <- format(dt_fim, "%d/%m/%Y")
    
  u_base <- "https://www.camara.leg.br/internet/sitaqweb/"
  u_tabela <- paste0(u_base, "resultadoPesquisaDiscursos.asp")
  
  query <- list(
    'CurrentPage' = current_page,
    'BasePesq'= 'plenario',
    'dtInicio'= dt_inicio,
    'dtFim'= dt_fim,
    'txUF'= '',
    'CampoOrdenacao' = 'dtSessao',
    'TipoOrdenacao'= 'DESC',
    'PageSize'= '50',
    'txTexto'= tx_texto
  )
  
  r_discurso <- httr::GET(u_tabela, query = query,
                          httr::write_disk(path, overwrite = TRUE))
  
  r_discurso
}

get_url_texto <- function(r_html){
  
  # retorna urls dos textos
  
  
  u_base <- "https://www.camara.leg.br/internet/sitaqweb/"
  
  r_html %>% 
    xml2::read_html() %>% 
    xml2::xml_find_all('//*[@id="content"]/div/table/tbody/tr/td/a') %>% 
    xml2::xml_attr("href") %>% 
    str_squish() %>% 
    str_replace_all(" ", "") %>% 
    na.omit() %>% 
    as.character() %>% 
    paste0(u_base, .) 
}


get_texto <- function(txt_urls){
  
  #  pega cada url e acessa 
  
  txt_urls %>% 
    stringr::str_remove("(?<=txTipoSessao=).+?(?=&)") %>% 
    abjutils::rm_accent() %>%
    read_html(options = "HUGE") %>% 
    xml_find_first("/html/body/p") %>% 
    xml_text() %>% 
    str_squish() %>% 
    str_trim() %>% 
    str_replace_all("\"", "'") %>% 
    str_remove_all("(Desligamento automático do microfone.)")
  
}

maybe_get_texto <- purrr::possibly(get_texto, otherwise = "erro")

maybe_get_texto_progress <- function(u_texto){
  
  # retorna os textos utilizando paralelizacao com barra de progresso
   
  future::plan(multisession)
  progressr::with_progress({
    
    p <- progressr::progressor(length(u_texto))
    
    discursos <- 
      furrr::future_map_chr(u_texto, ~{
        p()
        maybe_get_texto(.x) 
      })
  })
  
}

# tabela ------------------------------------------------------------------

get_tabela <- function(r_html){
  
  r_html %>% 
    xml2::read_html() %>% 
    xml2::xml_find_first('//*[@id="content"]/div/table') %>% 
    rvest::html_table()
}

tabela_tidy <- function(tab, txt){
  
  tab %>% 
    janitor::clean_names() %>% 
    dplyr::filter(dplyr::row_number() %% 2 != 0) %>% 
    tidyr::separate(orador, 
                    c("orador", "partido"),
                    sep = ",") %>% 
    tidyr::separate(publicacao,
                    c("local_publicacao", "data_publicacao"),
                    sep = " ") %>% 
    dplyr::mutate( 
      dplyr::across(
        .cols = c(data, data_publicacao),
        .fns = lubridate::dmy
      ),
      texto = txt 
    )

}

# aplicacao ---------------------------------------------------------------

pagina <- baixa_pag('maconha') 

textos <- 
  pagina %>% 
  get_url_texto() %>% 
  maybe_get_texto_progress()

tab <- 
  pagina %>% 
  get_tabela() %>% 
  tabela_tidy(textos)


# worcloud ----------------------------------------------------------------

stop_words <- tidytext::get_stopwords("pt")

others_words <- c("nao", "ter", "termos", "r", "fls", "sr")

tokenizado <- 
  tab %>% 
  rowid_to_column("id") %>% 
  filter(orador == "GENERAL GIRÃO") %>%
  select(id, texto) %>% 
  unnest_tokens(word, texto) %>% 
  dplyr::filter(!grepl('[0-9]', word)) %>%
  dplyr::mutate(word = abjutils::rm_accent(word)) %>% 
  dplyr::anti_join(stop_words) %>% 
  dplyr::group_by(word) %>% 
  dplyr::count(word, sort = TRUE) %>% 
  dplyr::filter(n > 5, !word %in% others_words)

tokenizado %>% 
  ggplot(
    aes(
      label = word, size = n,
      color = factor(sample.int(10, nrow(tokenizado), replace = TRUE))
    )
  ) +
  geom_text_wordcloud() +
  scale_size_area(max_size = 20) +
  theme_minimal()

wordcloud2(tokenizado)


# complete query ----------------------------------------------------------

# query <- list(
#   
#   "CurrentPage" = '1',
#   'txIndexacao'= '',
#   'BasePesq'= 'plenario',
#   'txOrador'= '',
#   'txPartido'= '',
#   'dtInicio'= '01/09/2021',
#   'dtFim'= '18/11/2021',
#   'txUF'= 'SP',
#   'txSessao'= '',
#   'listaTipoSessao'= '',
#   'listaTipoInterv'= '',
#   'inFalaPres'= '',
#   'listaTipoFala'= '',
#   'listaFaseSessao'= '',
#   'txAparteante'= '',
#   'listaEtapa'= '',
#   'CampoOrdenacao' = 'dtSessao',
#   'TipoOrdenacao'= 'DESC',
#   'PageSize'= '50',
#   'txTexto'= '',
#   'txSumario'= 'pandemia'
#   
# )

