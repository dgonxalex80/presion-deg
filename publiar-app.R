#subir app a shiny app

library(rsconnect)

rsconnect::setAccountInfo(name='daniel-enrique-gonzlez-gmez',
                          token='E6BEA322840B3A3C0FBC96A574EC8D2E',
                          secret='0guJa+qHT8s8wKh9QCjPwE00tGS0CLCGiUlwMq3T')

rsconnect::deployApp()
