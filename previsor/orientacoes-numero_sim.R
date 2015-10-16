# Este banco indica quais orientacoes de votacoes para cada partido e para o governo
library(tidyr)
library(dplyr)

setwd('/var/www/html/vai-passar/previsor/')

source('orientacoes2.R')

# Burga, muda essa pasta 
setwd('/var/www/html/vai-passar/previsor/planilhas/')

orientacoes <- read.csv('orientacoes.csv', stringsAsFactors=FALSE, sep=';', header=FALSE)
# Abre o banco



# orientacoes$V5[orientacoes$V5=="Não"] <- 0
# orientacoes$V5[orientacoes$V5=="Sim"] <- 1
# orientacoes$V5[orientacoes$V5=="Liberado"] <- NA
# orientacoes$V5[orientacoes$V5=="Obstrução"] <- NA
# Processa a variável V5



orientacoes$V4[orientacoes$V4=="PmdbPpPtbDem..."] <- "Pmdb|Pp|Ptb|Dem"
orientacoes$V4[orientacoes$V4=="PmdbPpPtbDemPscPhsPen"] <- "Pmdb|Pp|Ptb|Dem|Psc|Phs|Pen"
orientacoes$V4[orientacoes$V4=="PmdbPpPtbDemSdPscPhsPen"] <- "Pmdb|Pp|Ptb|Dem|Sd|Psc|Phs|Pen"
orientacoes$V4[orientacoes$V4=="PmdbPpPtbPscPhsPen"] <- "Pmdb|Pp|Ptb|Psc|Phs|Pen"
orientacoes$V4[orientacoes$V4=="PrbPtnPmnPrpPsdcPrtb"] <- "Prb|Ptn|Pmn|Prp|Psdc|Prtb"
orientacoes$V4[orientacoes$V4=="PrbPtnPmnPrpPsdcPrtbPtcPslPtdoB"] <- "Prb|Ptn|Pmn|Prp|Psdc|Prtb|Ptc|Psl|PtdoB"
orientacoes$V4[orientacoes$V4=="PsdbPsbPpsPv"] <- "Psdb|Psb|Pps|Pv"
orientacoes$V4[orientacoes$V4=="PtPsdPrPdtProsPc"] <- "Psdb|Psb|Pps|Pv"
orientacoes$V4[orientacoes$V4=="Repr.PSL"] <- "PSL"
orientacoes$V4[orientacoes$V4=="Repr.PTC"] <- "PTC"
orientacoes$V4[orientacoes$V4=="Repr.PTdoB"] <- "PTdoB"
orientacoes$V4[orientacoes$V4=="Solidaried"] <- "SD"
orientacoes$V4[orientacoes$V4=="GOV."] <- "Gov"
orientacoes$V4[orientacoes$V4=="Repr.PSOL"] <- "psol"
orientacoes$V4[orientacoes$V4=="PtPsdPrPdtProsPcdob"] <- "Pt|Psd|Pr|Pdt|Pros|Pcdob"
orientacoes$V4[orientacoes$V4=="PsdbPsbPps"] <- "Psdb|Psb|Pps"
orientacoes$V4[orientacoes$V4=="PmdbPen"] <- "Pmdb|Pen"
orientacoes$V4[orientacoes$V4=="PsdbPsbPps"] <- "Psdb|Psb|Pps"
orientacoes$V4[orientacoes$V4=="PpPtbPscPhs"] <- "Pp|Ptb|Psc|Phs"
orientacoes$V4[orientacoes$V4=="PrbPtnPmnPrpPsdcPtcPslPtdoB"] <- "Prb|Ptn|Pmn|Prp|Psdc|Ptc|Psl|PtdoB"
orientacoes$V4[orientacoes$V4=="Repr.REDE"] <- "REDE"

# Altera as entradas pra facilitar trabalho
# Estamos separando partidos com '|', para poder separa-los em colunas
# posteriormente

orientacoes$V4 <- tolower(orientacoes$V4)
# transforma partidos tudo para letras minusculas

orientacoes <- orientacoes %>%
  transform(V4 = strsplit(V4, "\\|")) %>%
  unnest(V4)
# Separa as variaveis 


colnames(orientacoes) <- c("ID_VOTACAO", "DATA", "HORA", "ORIENTACAO", "PARTIDO")
# Altera nomes das colunas de "V4" para nomes pertinentes

orientacoes <- orientacoes[!duplicated(orientacoes),]
# Remove valores duplicados


# Obter apenas a orientacao do governo. Para isso, copiamos o df:




orientacoes <- mutate(orientacoes, ORIENTACAO=ifelse(ORIENTACAO=="Obstrução", "Não", ORIENTACAO))





orientacoes <- spread(orientacoes, PARTIDO, ORIENTACAO)

#  orientacoes <- select(orientacoes, ID_VOTACAO, pt, pmdb, psd, pcdob, pdt, prb, pr , pros)



votos <- read.csv("votos.csv", , stringsAsFactors=FALSE, sep=';')

proposicoes <- read.csv("proposicoes.csv", stringsAsFactors=FALSE, sep=';')


conta_sim <- function(x) {
  n_sim <- try(table(x)[["SIM"]], TRUE)
  return(n_sim)
  
}

votos <- votos %>%
  filter((VOTO=="SIM" | VOTO=="NAO")) %>%
  mutate(votos_sim=ifelse(VOTO=="SIM", 1, 0)) %>%
  group_by(ID_VOTACAO) %>%
  summarise(contagem=n(), votos_sim=sum(votos_sim))

votos <- inner_join(votos, proposicoes)






library(randomForest)


votos <- inner_join(votos,orientacoes, by="ID_VOTACAO")


votos <- select(votos, ID_VOTACAO, contagem, dem, TIPO, gov, minoria, sd,starts_with("p"), resultado=votos_sim)

nome_colunas <- colnames(votos)[2:length(colnames(votos))]

for (i in nome_colunas) {
  print(i)
  print(sum(is.na(votos[[i]])))
}
 

# votosn <- inner_join(votos, proposicoes, by="ID_VOTACAO")

# write.csv(votosn, file="orietacoes_e_votacoes.csv", row.names=FALSE)

#Excluindo PSOL, pois possui muitas NAs
# Também vamos excluir ptc, ptdob, pros e sd

votos <- select(votos, -ptc, -ptdob, -pros, -sd)


### Rodando
for (i in colnames(votos)) {
  if (i != "resultado" & i !="contagem") {
    votos[[i]] <- as.factor(votos[[i]])
  }

  }


# O modelo é bom

modelo <- randomForest(resultado ~ gov + minoria + pt + pmdb
                       + psdb + psd + TIPO,
                       data=votos, ntree=500)

modelo

varImpPlot(modelo)
### Previsões

vari <- c("Sim", "Não", "Liberado")
varo <- c("Sim", "Não")

vara <- c("MPV", "PDC", "PEC", "PL", "PLP", "REQ", "REC")
previsor <- expand.grid(varo, vari, vari, 
            vari, vari,  varo, vara)

colnames(previsor) <- c("gov", "minoria",  "pmdb", 
                        "psd", "psdb",  "pt", "TIPO")

previsor <- as.data.frame(previsor, stringsAsFactors=FALSE)



previsor$resultado <- predict(modelo,previsor)



# write.csv(previsor, "previsto2.csv", row.names=FALSE)


## Gera csv com data ultima votação e numero de linhas


### FILTREMOS PECs e PLPs

previsor_pec <- filter(previsor, TIPO=="PEC")

previsor_plp <- filter(previsor, TIPO=="PLP")

previsor_dois <- filter(previsor, TIPO=="PL")



previsor_plp$resultado <- previsor_plp$resultado/513 

for (i in 1:nrow(previsor_pec)) {
  if ( previsor_pec$resultado[i] <= 307.8) {
    previsor_pec$resultado[i] <- previsor_pec$resultado[i] * (1/307.8) * (1/2)
  }
  else {
    previsor_pec$resultado[i] <- previsor_pec$resultado[i] * (1/205.2) * (1/2)
  }
}



for (i in 1:nrow(previsor_dois)) {
  if ( previsor_dois$resultado[i] <= 342) {
    previsor_dois$resultado[i] <- previsor_dois$resultado[i] * (1/342) * (1/2)
  }
  else {
    previsor_dois$resultado[i] <- previsor_dois$resultado[i] * (1/171) * (1/2)
  }
}



summary(previsor_plp$resultado)


previsor_plp$KIND <- 1
previsor_pec$KIND <- 2

previsor_dois$KIND <- 3

previsor_first$KIND <- 0

previsor <- rbind(previsor_first, previsor_pec, previsor_plp
                  #, previsor_dois
                  )


previsor <- select(previsor, -TIPO)
### Testando o modelo

for (i in 1:(ncol(previsor)-1)) {
  previsor[,i] <- gsub("Sim", "2", previsor[,i])
  previsor[,i] <- gsub("Liberado", "1", previsor[,i])
  previsor[,i] <- gsub("Não", "0", previsor[,i])
}


previsor$resultado[previsor$resultado > .99] <- .99


# previsor_first$KIND <- 0

# head(previsor[previsor$KIND==2,])
write.csv(previsor, "previsto.csv", row.names=FALSE)









# votos$previsor <- predict(modelo,votos)

# plot(votos$previsor, votos$resultado)


# votos$resultado2 <- ifelse(votos$resultado >= (votos$contagem)/2, 1, 0)
# votos$resultado2[votos$TIPO=="PEC"] <- ifelse(votos$resultado[votos$TIPO=="PEC"] >= 308, 1, 0)

# votos$previsor2 <- ifelse(votos$previsor >= (votos$contagem)/2, 1, 0)
# votos$previsor2[votos$TIPO=="PEC"] <- ifelse(votos$previsor[votos$TIPO=="PEC"] >= 308, 1, 0)


# media_contagem <- mean(votos$contagem)

# votos$resultado3 <- ifelse(votos$resultado >= (media_contagem)/2, 1, 0)
# votos$resultado3[votos$TIPO=="PEC"] <- ifelse(votos$resultado[votos$TIPO=="PEC"] >= 308, 1, 0)

# votos$previsor3 <- ifelse(votos$previsor >= (media_contagem-50)/2, 1, 0)
# votos$previsor3[votos$TIPO=="PEC"] <- ifelse(votos$previsor[votos$TIPO=="PEC"] >= 308, 1, 0)



# table(votos$resultado3, votos$previsor3)

# table(votos$resultado2, votos$previsor3)