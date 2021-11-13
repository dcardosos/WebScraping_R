library(magrittr)
library(ggplot2)
library(xml2)

# 1. Obtenha o vetor com as probabilidades dos resultados que realmente aconteceram
## Dica: qual é a cor deles?
u_html <- "http://www.chancedegol.com.br/br21.htm"

html <- xml2::read_html(u_html)

tabelas <- xml2::xml_find_all(html, "//table")

true_positive_probs <- 
  tabelas[[8]] %>% 
  xml_find_all('.//tr//td//font[contains(@color, "#FF0000")]') %>% 
  xml_text() %>% 
  readr::parse_number() / 100 
  


# 2. Construa a tabela final e armazene em tab_cdg
## Dica: utilize rvest::html_table() e adicione a coluna cores


tab_cdg <-
  tabelas[[8]] %>% 
  rvest::html_table(header = TRUE) %>% 
  janitor::clean_names() %>%
  dplyr::rename(placar = x) %>% 
  dplyr::mutate(
    data = lubridate::dmy(data),
    vitoria_do_mandante = readr::parse_number(vitoria_do_mandante) / 100, 
    vitoria_do_visitante = readr::parse_number(vitoria_do_visitante) / 100,
    empate = readr::parse_number(empate) / 100,
    cores = true_positive_probs
  ) %>% 
  tidyr::separate(
    col = placar, 
    into = c("gols_mandante", "gols_visitante"),
    sep = "x"
  ) 

# 3. Rode tibble::glimpse(tab_cdg)
## e cole o resultado abaixo. Deixe o resultado como um comentário
## Dica: Selecione as linhas que deseja comentar e aplique Ctrl+Shift+C

tibble::glimpse(tab_cdg)

# Rows: 308
# Columns: 9
# $ data                 <date> 2021-05-29, 2021-05-29, 2021-05-29, 2021-05-30, 2021-05-30, 2021-05-30, 202~
# $ mandante             <chr> "São Paulo", "Bahia", "Cuiabá", "Flamengo", "Corinthians", "Atlético MG", "I~
# $ gols_mandante        <chr> "0", "3", "2", "1", "0", "1", "2", "3", "1", "0", "3", "3", "2", "1", "3", "~
# $ gols_visitante       <chr> "0", "0", "2", "0", "1", "2", "2", "2", "0", "3", "1", "3", "0", "0", "1", "~
# $ visitante            <chr> "Fluminense", "Santos", "Juventude", "Palmeiras", "Atlético GO", "Fortaleza"~
# $ vitoria_do_mandante  <dbl> 0.579, 0.521, 0.404, 0.484, 0.467, 0.505, 0.752, 0.377, 0.358, 0.311, 0.288,~
# $ empate               <dbl> 0.217, 0.240, 0.277, 0.248, 0.265, 0.270, 0.178, 0.262, 0.331, 0.309, 0.244,~
# $ vitoria_do_visitante <dbl> 0.204, 0.239, 0.318, 0.268, 0.268, 0.225, 0.069, 0.361, 0.311, 0.380, 0.467,~
# $ cores                <dbl> 0.217, 0.521, 0.277, 0.484, 0.268, 0.225, 0.178, 0.377, 0.358, 0.380, 0.288,~


# 4. [extra] Construa um gráfico que mostra qual é a proporção
# de acertos do Chance de Gol por time. Os passos são
# a) obter qual seria o chute do Chance de Gol, dado pelo resultado com
# maior probabilidade em cada jogo
# b) construir uma coluna "acertou", que é TRUE se o modelo acertou 
# e FALSE caso contrário
# c) empilhar a base (usar tidyr::gather ou tidyr::pivot_longer) para considerar
# tanto mandantes quanto visitantes
# d) agrupar por time e calcular a proporção de acertos. Ordenar a variável
# pela proporção de acertos
# e) montar o gráfico!

tab_cdg %>% 
  dplyr::mutate(resultado = ifelse(gols_mandante > gols_visitante, mandante,
                          ifelse(gols_mandante < gols_visitante, visitante, "Empate"))) %>% 
  dplyr::group_by(resultado) %>% 
  dplyr::tally() %>% 
  dplyr::mutate(prop=n/sum(n)) %>% 
  dplyr::arrange(-prop) %>% 
  ggplot(aes(prop, reorder(resultado, prop), fill = resultado)) + 
  geom_bar(stat = "identity", show.legend = FALSE) +
  theme_minimal() + 
  labs(
    x = "Proporção de acertos (errado)",
    y = ""
  )


## o correto
tab_cdg %>% 
  dplyr::mutate(
    acertou = pmax(vitoria_do_mandante, empate, vitoria_do_visitante) == cores
  ) %>%
  tidyr::pivot_longer(c(mandante, visitante)) %>%
  dplyr::group_by(value) %>%
  dplyr::summarise(prop_acertos = mean(acertou), .groups = "drop") %>%
  dplyr::mutate(value = forcats::fct_reorder(value, prop_acertos)) %>%
  ggplot(aes(x = prop_acertos, y = value)) +
  geom_col(fill = "darkblue") +
  scale_x_continuous(labels = scales::percent) +
  theme_minimal(12) +
  labs(
    x = "Proporção de acertos",
    y = "Time"
  )
  
