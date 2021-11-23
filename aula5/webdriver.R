library(webdriver)
# webdriver::install_phantomjs()

# abre um processo do phantomjs
# coloca em uma porta aleatória a principio
pjs <- run_phantomjs()
pjs

# abre um navegador de fato
ses <- Session$new(port = pjs$port)

ses$go("https://google.com")
ses$takeScreenshot(file = "output/screenshot_ex")

# ses$findElement - retorna um elemento da página dado um
## seletor ou XPath para o mesmo

# elem$click - clica em um elemento
# elem$sendKeys() - envia uma tecla para o elemento