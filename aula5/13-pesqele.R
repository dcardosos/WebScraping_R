library(webdriver)
library(magrittr)

# n da certo
u_pesqele <- "https://rseis.shinyapps.io/pesqEle"
httr::GET(u_pesqele, httr::write_disk("output/pesqele.html"))

pjs <- run_phantomjs()
ses <- Session$new(port = pjs$port)

ses$go(u_pesqele)
ses$takeScreenshot("output/pesqele.png")

#elems <- ses$findElement(xpath = '.info-box-number')
elems <- ses$findElements(xpath = "//span[@class='info-box-number']")

elems[[1]]$getText()

textos <- purrr::map_chr(elems, ~.x$getText())

# filtrar resultados para pesquisas presidenciais e clicar

radio <- ses$findElement(xpath = "//input[@name='abrangencia' and @value='nacionais']")

radio$click()

elems <- ses$findElements(xpath = "//span[@class='info-box-number']")
textos_novos <- purrr::map_chr(elems, ~.x$getText())

# acessar dados de uma aba do dash ----------------------------------------

tab <- ses$findElement(xpath = "//a[@href='#shiny-tab-empresas']")
tab$click()
ses$takeScreenshot()

elem <- ses$findElement(xpath = "//select[@name='DataTables_Table_0_length']/option[@value='100']")
elem$click()
ses$takeScreenshot()

html <- ses$getSource()

readr::write_file(html, "output/pesqele.html")

"output/pesqele.html" %>% 
  xml2::read_html() %>% 
  xml2::xml_find_first("//table") %>% 
  rvest::html_table() %>% 
  janitor::clean_names()

# tentativa de mudar o httr value pra 200 ---------------------------------
## https://jquery.com
script <- '$(#DataTables_Table_0_length > label > select > option:nth-child(5)").attr("value", "200")'

elem$executeScript(script)

# fechar a sessão ---------------------------------------------------------

ses$delete()
pjs$process$kill()

