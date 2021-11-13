library(xml2)

link <- "https://raw.githubusercontent.com/curso-r/main-web-scraping/master/exemplos_de_aula/html_exemplo.html"


html <- xml2::read_html(link)

class(html)


# navegar no DOM de acordo com uma query, uma consulta
# nesse caso, todas as tags são "p"
todos_os_p <- xml2::xml_find_all(html, "//p")     # superfilho
class(todos_os_p) # conjunto de nodes

p_filho_de_body <- xml_find_all(html, "./body/p") # filho

body <- xml_find_all(html, "./body")

xml2::xml_text(body) # pega tudo e junta em um texto só

xml2::xml_attrs(todos_os_p) # atributos


# alterar e salvar dentor do R --------------------------------------------

xml_attr(todos_os_p, "style") <- "color:green"
todos_os_p

