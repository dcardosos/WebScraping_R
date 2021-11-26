library(magrittr)
# javax.faces.ViewState: - guarda o estado da minha session

u <- "https://dejt.jt.jus.br/dejt/f/n/diariocon"

r0 <- httr::GET(u)
# ctrl f, pesquisar por "view"

state <- r0 %>% 
  xml2::read_html() %>% 
  xml2::xml_find_first('//*[@name="javax.faces.ViewState"]') %>% 
  xml2::xml_attr("value")

body <- list(
  "corpo:formulario:dataIni" = "25/11/2021",
  "corpo:formulario:dataFim" = "25/11/2021",
  "corpo:formulario:tipoCaderno" = "",
  "corpo:formulario:tribunal" = "",
  "corpo:formulario:ordenacaoPlc" = "",
  "navDe" = "1",
  "detCorrPlc" = "",
  "tabCorrPlc" = "",
  "detCorrPlcPaginado" = "",
  "exibeEdDocPlc" = "",
  "indExcDetPlc" = "",
  "org.apache.myfaces.trinidad.faces.FORM" = "corpo:formulario",
  "_noJavaScript" = "false",
  "javax.faces.ViewState" = state,
  "source" = "corpo:formulario:botaoAcaoPesquisar")

# deu errado, pq precisa considerar o encoding correto
r <- httr::POST(
  u, 
  body = body,
  httr::write_disk("output/dejt_inicial.html", overwrite = TRUE)
)

tabela <- r %>% 
  xml2::read_html() %>% 
  xml2::xml_find_first("//div[@id='diarioCon']/fieldset/table")

tab_data <- tabela %>%
  rvest::html_table() %>% 
  janitor::clean_names()

botoes <- tabela %>% 
  xml2::xml_find_all(".//button") %>% 
  xml2::xml_attr("onclick") %>% 
  stringr::str_extract("corpo:formulario:plcLogicaItens[^']+")

tab_data$number_baixar <- botoes

baixar_pdf <- function(id_documento, body){
  
  body$source <- id_documento
  
  id_pdf <- id_documento %>% 
    stringr::str_extract("[0-9]+")
  
  nm_arquivo <- stringr::str_glue("output/pdf/{id_pdf}.pdf")
  
  r <- httr::POST(
    u, 
    body = body,
    httr::write_disk(nm_arquivo, overwrite = TRUE)
  )
  
  nm_arquivo
}

purrr::map(tab_data$number_baixar, baixar_pdf, body = body)
