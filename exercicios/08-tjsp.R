library(tidyverse)
library(xml2)
library(httr)
library(tidytext)
library(ggwordcloud)
library(wordcloud2)

# 1. Crie uma função tjsp_baixar_pag() que baixa a página
## Dica: usar httr::write_disk()

# 2. Baixe as primeiras 10 páginas de resultados, 
# a partir de um termo de busca à sua escolha.
# Por exemplo: briga de condomínio

# 3. Crie uma funcao ler_item que lê cada item da tabela, como fizemos

# 4. Aplique a sua função em todos os elementos da saída e empilhe
## Dica: usar purrr::map_dfr()

# 5. Separe o título do conteúdo
## Dica: usar tidyr::separate()

# 6. Aplique tidyr::pivot_wider() para ficar com uma linha
## para cada processo. Cuidado: a linha com o número do processo é diferente

# 7. Armazene o resultado final em tab_tjsp

# baixar a pagina ---------------------------------------------------------

tjsp_baixar_pag <- function(busca){
  
  query <- list(
    "conversationId" = "",
    "dadosConsulta.pesquisaLivre" = busca,
    "tipoNumero" = "UNIFICADO",
    "dadosConsulta.dtInicio" = "",
    "dadosConsulta.dtFim" = "",
    "dadosConsulta.ordenacao" = "DESC"
  )
  
  request <- httr::GET("https://esaj.tjsp.jus.br/cjpg/pesquisar.do",
                       query = query,
                       httr::write_disk(paste0("output/pagina", busca, ".html"), 
                                        overwrite = TRUE))
  request
} 


# leitura de cada item ----------------------------------------------------

ler_item <- function(item){
  
  texto <- 
    item %>% 
    xml2::xml_find_first('//div[@style="display: none;" and @align="justify"]') %>% 
    xml2::xml_text() %>% 
    stringr::str_trim()
  
  item %>% 
    rvest::html_table() %>% 
    tibble::as_tibble() %>% 
    dplyr::mutate(X1 = stringr::str_squish(X1),
                  texto = texto)
}

# parsear o arquivo -------------------------------------------------------

parse_pagina <- function(arquivo){
  
    tab_html <- 
      arquivo %>%
      xml2::read_html() %>% 
      xml2::xml_find_all('//*[@class="fundocinza1"]')
  
  purrr::map_dfr(tab_html, ler_item, .id = "id")
  
}

# tabela tidy -------------------------------------------------------------

tabela_tidy <- function(tabela){
  
  tabela %>% 
    dplyr::select(-X2) %>% 
    dplyr::mutate(n_processo = stringr::str_extract(X1, "^[0-9.-]+")) %>% 
    tidyr::fill(n_processo) %>% 
    dplyr::group_by(id) %>% 
    dplyr::slice(-1, -9) %>% 
    dplyr::ungroup() %>% 
    tidyr::separate(X1, 
                    c("titulo", "conteudo"), 
                    sep = ":", 
                    extra = "merge") %>% 
    tidyr::pivot_wider(
      names_from = titulo,
      values_from = conteudo) %>% 
    janitor::clean_names() %>% 
    dplyr::arrange(as.integer(id))
}


# aplicação ---------------------------------------------------------------
tab_tjsp <- 
  tjsp_baixar_pag("league of legends") %>% 
  parse_pagina() %>% 
  tabela_tidy()

# 8.  Rode tibble::glimpse(tab_tjsp)
## e cole o resultado abaixo. Deixe o resultado como um comentário
## Dica: Selecione as linhas que deseja comentar e aplique Ctrl+Shift+C

dplyr::glimpse(tab_tjsp)

# Rows: 10
# Columns: 10
# $ id                       <chr> "1", "2", "3", "4", "5", "6", "7", "8", "9", ~
# $ texto                    <chr> "TRIBUNAL DE JUSTIÇA DO ESTADO DE SÃO PAULO\n~
# $ n_processo               <chr> "1031244-32.2021.8.26.0506", "1000512-83.2021~
# $ classe                   <chr> " Procedimento do Juizado Especial Cível", " ~
# $ assunto                  <chr> " Petição intermediária", " Rescisão do contr~
# $ magistrado               <chr> " VINICIUS RODRIGUES VIEIRA", " ORLANDO GONÇA~
# $ comarca                  <chr> " Ribeirão Preto", " Nazaré Paulista", " Jaca~
# $ foro                     <chr> " Foro de Ribeirão Preto", " Foro de Nazaré P~
# $ vara                     <chr> " Vara do Juizado Especial Cível", " Anexo do~
# $ data_de_disponibilizacao <chr> " 10/11/2021", " 16/06/2021", " 30/04/2021", ~


# 9. [extra] monte um wordcloud.
## Dica: use tidytext para separar as palavras e ggwordcloud para o gráfico.
## Dica: mostre apenas palavras que aparecem mais do que 5 vezes.

stop_words <- tidytext::get_stopwords("pt")

others_words <- c("nao", "ter", "termos", "r", "fls")

tokenizado <- 
  tab_tjsp %>% 
  dplyr::select(id, texto) %>% 
  unnest_tokens(word, texto) %>%
  dplyr::filter(!grepl('[0-9]', word)) %>%
  dplyr::mutate(word = abjutils::rm_accent(word)) %>% 
  dplyr::anti_join(stop_words) %>% 
  dplyr::group_by(word) %>% 
  dplyr::count(word, sort = TRUE) %>% 
  dplyr::filter(n > 5,
                !word %in% others_words)

tokenizado %>% 
  head(30) %>% 
  ggplot(
    aes(
      label = word, size = n,
      color = factor(sample.int(10, nrow(head(tokenizado, 30)), replace = TRUE))
      )
    ) +
  geom_text_wordcloud() +
  scale_size_area(max_size = 20) +
  theme_minimal()

wordcloud2(tokenizado)


