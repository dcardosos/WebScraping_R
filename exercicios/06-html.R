library(xml2)

# ler o HTML
html <- read_html("https://raw.githubusercontent.com/curso-r/main-web-scraping/master/exemplos_de_aula/html_exemplo.html")

# 1. Qual a diferença entre xml_find_all() e xml_find_first()?
xml_find_all(html, "//p") # todos
xml_find_first(html, "//p") # o primeiro q aparece


# 2. O que faz a função contains() aplicada dentro do XPath?
## Dica: xml_find_all(html, "//p[contains(@style, 'blue')]")

## acha a tag que contenha o qye está escrito dentro do parentesis
xml_find_all(html, "//p[contains(@style, 'blue')]")
