library(magrittr)
library(lubridate)
library(ggplot2)
library(httr)
library(jsonlite)
library(dplyr)
library(tidyr)
library(purrr)
library(janitor)
library(tibble)

# 1. Escreva uma função que recebe uma data e retorna a tabela dos mananciais

baixar_sabesp <- function(data) {
  # ...
  # Dica: u_base <- "http://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/"
  
  u_base <- "http://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/"
  
  r_sabesb <- httr::GET(paste0(u_base, data))
  
  httr::content(r_sabesb, as = "parsed", simplifyDataFrame = TRUE)$ReturnObj$sistemas %>% 
    tibble::as_tibble() %>% 
    janitor::clean_names()
}



# 2. Armazene no objeto tab_sabesp a tabela do dia `Sys.Date() - 1` (ontem)

tab_sabesp <- baixar_sabesp(Sys.Date() - 1)

# 3. [extra] Arrume os dados para que fique assim:

# Observations: 7
# Variables: 2
# $ nome   <fct> Cantareira, Alto Tietê, Guarapiranga, Cotia, Rio Grande, Rio Claro, São Lourenço
# $ volume <dbl> 63.25681, 90.35307, 84.25839, 102.28429, 93.66445, 99.85615, 97.33682

tab_sabesp %>% 
  dplyr::select(nome, volume_porcentagem) %>% 
  dplyr::rename(volume = volume_porcentagem) %>% 
  dplyr::mutate(nome = as.factor(nome))



# Extra - série temporal --------------------------------------------------

baixar_sabesp <- function(data) {
  # ...
  # Dica: u_base <- "http://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/"
  
  u_base <- "http://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/"
  
  r_sabesb <- httr::GET(paste0(u_base, data))
  
  httr::content(r_sabesb, as = "parsed", simplifyDataFrame = TRUE)$ReturnObj$sistemas %>% 
    tibble::as_tibble() %>% 
    janitor::clean_names() %>% 
    dplyr::select(nome, volume_porcentagem) %>% 
    dplyr::rename(volume = volume_porcentagem) %>% 
    dplyr::mutate(nome = as.factor(nome))
  
}


dados_por_periodo <- function(periodo) {
  
  tibble::tibble(
    data = periodo) %>% 
    dplyr::mutate(dados = purrr::map(.x = data, 
                                     .f = ~ baixar_sabesp(.x))) %>%
    tidyr::unnest()
}

dados <- dados_por_periodo(seq.Date(today() - 7, today(), "days"))

dados %>% 
  ggplot(aes(x = data, y = volume, color = nome)) +
  geom_line(size = 1.2) +
  theme_minimal() +
  labs(
    x = "Data",
    y = "Volume (%)",
    title = "Volume dos mananciais nos últimos 100 dias",
    caption = "Fonte: `API da Sabesp`")
