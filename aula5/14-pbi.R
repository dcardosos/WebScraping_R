library(magrittr)
library(RSelenium)

drv <- rsDriver(browser = "firefox")

ses <- drv$client

ses$navigate("https://google.com")

elem <- ses$findElement("xpath", "//input[@name='q']")

elem$sendKeysToElement(list("ibovespa", key = "enter"))
Sys.sleep(2)
ses$screenshot(file = "output/ibovespa.png")

# exemplo power bi --------------------------------------------------------

u_pbi <- "https://app.powerbi.com/view?r=eyJrIjoiNDA1ZmJkOTktYjIxZC00YWIxLTg2ZjgtNDY3NjE1MmE3NTM3IiwidCI6ImFkOTE5MGU2LWM0NWQtNDYwMC1iYzVjLWVjYTU1NGNjZjQ5NyIsImMiOjJ9&pageName=ReportSectiondafa4924ddb5d073a0a0"
ses$navigate(u_pbi)

## contains - como se fosse um str_detect
elem <- ses$findElement("xpath", "//div[contains(@class, 'slicerText') and @title='Estadual']")
elem$clickElement()

checkbox <- ses$findElement("xpath", "//span[@class, 'slicerText' and text()='TJRR']")
checkbox$clickElement()

# desclicou tudo, e vamos para o TST
checkbox <- ses$findElement("xpath", "//span[@class='slicerText' and text()='TST']")
checkbox$clickElement()

# deu erro pq precisa scrollar, preciso achar um scroller e scrollar
scroll <- ses$findElement("xpath", "//div[contains(@class, 'scrolly_visible')]")
scroll$executeScript(
  "arguments[0].scrollBy(0, 10)", 
  args = list(scroll))

checkbox <- ses$findElement("xpath", "//span[@class='slicerText' and text()='TST']")
checkbox$clickElement()




