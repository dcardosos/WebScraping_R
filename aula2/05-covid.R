library(tidyverse)
library(httr)

# nome do arquivo não está no html da página
r0 <- httr::GET("https://covid.saude.gov.br/",
                httr::write_disk("output/covid_home"))

# pagina é dinâmica, mas dá para tentar
# vasculhando no site, identificamos essa url aqui

u_portal_geral <- "https://xx9p7hp1p7.execute-api.us-east-1.amazonaws.com/prod/PortalGeral"

## POG = programação orientada a GAMBIARRA
r1 <- httr::GET(u_portal_geral) # status 200
content(r1) # unauthorized

## testar com user-agent
user_agent <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:94.0) Gecko/20100101 Firefox/94.0"
r2 <- httr::GET(
  u_portal_geral,
  httr::user_agent(user_agent)
)

httr::content(r2)


## temos x-parse-application-id, adicionar um header
r3 <- httr::GET(
  u_portal_geral,
  #httr::user_agent(user_agent),
  httr::add_headers(`x-parse-application-id` = "unAFkcaNDeXajurGB7LChj8SgQYS2ptm")
)

link_acesso <- 
  httr::content(r3) %>%
  purrr::pluck("results", 1, "arquivo", "url")


## pegar o x-parse-application-id automaticamente
## empiricamente, tanto faz pegar isso

u_Js <- "https://covid.saude.gov.br/14-es2015.d9ae86a9db5bc4696730.js"

r_Js <- httr::GET(u_Js)

x_parse_app_id <- 
  r_Js %>% 
  httr::content("text") %>% 
  stringr::str_extract('(?<="X-Parse-Application-Id",")[0-9a-zA-Z]+')

u_portal_geral <- "https://xx9p7hp1p7.execute-api.us-east-1.amazonaws.com/prod/PortalGeral"

r_portal_geral <- httr::GET(
  
  u_portal_geral,
  httr::add_headers(`x-parse-application-id` = x_parse_app_id)
  
)

link_acesso <- 
  httr::content(r_portal_geral) %>%
  purrr::pluck("results", 1, "arquivo", "url")

httr::GET(link_acesso,
          httr::write_disk("output/resultado.7z"))
