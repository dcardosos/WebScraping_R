# https://github.com/jjesusfilho/tjsp

library(magrittr)

ss <- rvest::session("https://esaj.tjsp.jus.br/cjpg/pesquisar.do")
rvest::html_form(ss)

abjutils::chrome_to_body(
  
"conversationId: 
dadosConsulta.pesquisaLivre: league of legends
tipoNumero: UNIFICADO
numeroDigitoAnoUnificado: 
foroNumeroUnificado: 
dadosConsulta.nuProcesso: 
dadosConsulta.nuProcessoAntigo: 
classeTreeSelection.values: 
classeTreeSelection.text: 
assuntoTreeSelection.values: 
assuntoTreeSelection.text: 
agenteSelectedEntitiesList: 
contadoragente: 0
contadorMaioragente: 0
cdAgente: 
nmAgente: 
dadosConsulta.dtInicio: 
dadosConsulta.dtFim: 
varasTreeSelection.values: 
varasTreeSelection.text: 
dadosConsulta.ordenacao: DESC")



u_tjsp <- "https://esaj.tjsp.jus.br/cjpg/pesquisar.do"

busca <- "league of legends"

query <- list(
  "conversationId" = "",
  "dadosConsulta.pesquisaLivre" = busca,
  "tipoNumero" = "UNIFICADO",
  "numeroDigitoAnoUnificado" = "",
  "foroNumeroUnificado" = "",
  "dadosConsulta.nuProcesso" = "",
  "dadosConsulta.nuProcessoAntigo" = "",
  "classeTreeSelection.values" = "",
  "classeTreeSelection.text" = "",
  "assuntoTreeSelection.values" = "",
  "assuntoTreeSelection.text" = "",
  "agenteSelectedEntitiesList" = "",
  "contadoragente" = "0",
  "contadorMaioragente" = "0",
  "cdAgente" = "",
  "nmAgente" = "",
  "dadosConsulta.dtInicio" = "",
  "dadosConsulta.dtFim" = "",
  "varasTreeSelection.values" = "",
  "varasTreeSelection.text" = "",
  "dadosConsulta.ordenacao" = "DESC"
)


r_tjsp <- httr::GET(u_tjsp, query = query,
                    httr::write_disk("output/tjsp_lol.html", overwrite = TRUE))

# parsing -----------------------------------------------------------------

#'//*[@id="divDadosResultados"]/table/tbody/tr[1]'
## qualquer coisa
## onde
## [condição, no caso @id que seja igual divDadosResultado]
## a gente já sabe

html <- xml2::read_html(r_tjsp)

# n funcionou
fundocinza <- html %>% 
  xml2::xml_find_all('//*[@id="divDadosResultado"]/table/tbody/tr[1]')

# funciona mas é dificil de generalizar
fundocinza <- html %>% 
  xml2::xml_find_all('//*[@id="divDadosResultado"]/table/tr')

# direto ao ponto
fundocinza <- html %>% 
  xml2::xml_find_all('//*[@class="fundocinza1"]')

# outra forma: usando rvest
fundocinza <- html %>% 
  rvest::html_elements(xpayh = '//*[@class="fundocinza1"]')

# outra forma: usando rvest
## transforma .fundocinza1 em um xpath com rvest:::make_selector
fundocinza <- html %>% 
  rvest::html_elements(css = '.fundocinza1')



# get table ---------------------------------------------------------------
item <- fundocinza[[1]]

montar_tabela <- function(item) {
  
  tabela <-
    item %>% 
    xml2::xml_find_first("./td[2]/table") %>% 
    rvest::html_table()
  
  processo <- tabela$X1[1]
  
  
  texto <- item %>% 
    xml2::xml_find_first(".//div[@align='justify' and @style='display: none;']") %>% 
    xml2::xml_text() %>% 
    stringr::str_trim()
   
  tabela_filtrada <- 
    tabela %>% 
    dplyr::filter(is.na(X2)) %>% 
    tidyr::separate(
      X1, c("nome", "valor"), 
      sep = ":", extra = "merge"
    ) %>% 
    dplyr::mutate(
      valor = stringr::str_squish(valor)
    ) %>% 
    dplyr::select(-X2) %>% 
    dplyr::mutate(
      processo = processo,
      texto = texto
    ) %>% 
    tidyr::pivot_wider(
      names_from = nome,
      values_from = valor
    ) %>%
    janitor::clean_names()
  
  tabela_filtrada
}

montar_tabela(item)

tabela_completa <- purrr::map_dfr(fundocinza, montar_tabela, .id = "id")


# outras paginas ----------------------------------------------------------

u_paginacao <- "https://esaj.tjsp.jus.br/cjpg/trocarDePagina.do"
pagina2 <- list(
  
  "pagina" = "2",
  "conversationId" = ""
)

r_pag <- httr::GET(u_paginacao, query = pagina2)

html <- xml2::read_html(r_pag)
fundocinza <- html %>% 
  rvest::html_elements(xpath = '//*[@class="fundocinza1"]')

tabela_completa_2 <- purrr::map_dfr(fundocinza, montar_tabela, .id = "id")

resultado_final <- dplyr::bind_rows(tabela_completa, tabela_completa_2, .id = "pagina")
