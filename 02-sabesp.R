library(magrittr)
library(httr)
library(jsonlite)


u_base <- "https://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas"
endpoint <- "/2021-10-20"
u_sabesp <- paste0(u_base, endpoint)

# r_sabesp <- GET(u_sabesp, config(ssl_verifypeer = FALSE))
r_sabesp <- GET(u_sabesp)

resultado <- content(r_sabesp, as = "parsed", simplifyDataFrame = TRUE)
resultado$ReturnObj # objeto complexo, uma lista

tabela <- resultado$ReturnObj$sistemas %>% 
  tibble::as_tibble() %>% 
  janitor::clean_names()

tabela


# poderia fazer tudo em uma função


baixa_reservatorios <- function(data){
  
  u_base <- "https://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/"
  endpoint <- data
  u_sabesp <- paste0(u_base, endpoint)

  r_sabesp <- GET(u_sabesp)
  
  resultado <- content(r_sabesp, as = "parsed", simplifyDataFrame = TRUE)
  resultado$ReturnObj 
  
  tabela <- resultado$ReturnObj$sistemas %>% 
    tibble::as_tibble() %>% 
    janitor::clean_names()
  
  tabela
  
}

baixa_reservatorios("2020-11-03")
## remotes::install_github("beatrizmilz/mananciais")
## mananciais::dados_mananciais()


# :: --> funções exportadas
# ::: --> funções que estão no pacote, mas são funções internas
