# Este script prepara los datos recopilados provenientes del IRENA, climatescope, ministerios de energía y sitios oficiales del gobierno de 21 paises latinoamericanos y del caribe con el fin de identificar las leyes enfocadas a la promocion de energias renovables en la Matriz Energetica de America Latina y el Caribe. Dichas leyes fueron recopialdas, leidas detalladamente y posteriormente marcadas segun la estrategia u objetivo que se identificó en su contenido (resumido en la columna "Descripcion"). El objetivo es codificar el texto recopilado en variables binarias para fácilitar el posterior procesamiento de la informacion.

library(readxl)
database_v20180605 <- read_excel("C:/..............   DOCUMENTOS TRABAJO/RE-ENERGIAS RENOVABLES/PANEL/TIMELINE RE LAC/Reporte ALC RegulFramework/database_v20180605.xlsx", sheet = "DATOS", range = "A1:N438")
View(database_v20180605)
my_data<- database_v20180605
str(my_data)
ncol(my_data)
names(my_data)

#Pais - contiene el nombre del pais bajo estudio
#Tipo_Docum  -  contiene el tipo de documento legal al que se hace referencia, ya sea LEY, RESOLUCION, DECRETO, PLAN de ACCION - Sin embargo no está completa.
#Numero_Docum - contiene el numero de la LEY, DECRETO, RESOLUCION u otro.
#Fecha_pub - contiene el año en que se promulga la regulacion en cuestion.
#Descripcion - contiene en resumen la informacion clave contenida en el instrumento regulatorio.
#anno_pub - año de publicacion del instrumento regulatorio
#Fuente_Doc - fuente de donde se extrajo la informacion del documento
#Estado_V - si se encuentra vigente, terminada, modificada, repealed, o bajo revision
#Tipo_Instrumento - segun la clasificacion del IRENA si es un instrumento de soporte a politicas, instrumento economico o regulatorio
#Corresp_Legisl_Doc - nombre completo del instrumento legal
#Reg/Mod - nombre del documento con el cual se vio modificado o reforzado el instrumento en el orden "Tipo_Docum"+"Numero_Docum"+"Fecha_pub"
#Estrategia_Objetivo - si el documento se ajusta a la clasificacion del IRENA en Net Meterin, Net Billing, Fiscal Incentives, Tax Excemption, Import Duty Excemption, Mandatory Blend, Auction, Feed-in Tariff, Speciffic Legislation, Investment, Priority Dispatch, Grid Access
#Categoria_Estrategia - misma informacion de la variable anterior -incompleta.
#Target - tipo de energia renovable al cual (impulsa) está dirigido el instrumento regulatorio

# Las columnas "Tipo_Docum"         "Numero_Docum"       "Fecha_pub"        "Fuente_Doc"    Y   "Categoria_Estrategia"     no son de utilidad para el objetivo de este primer proceso de preparacion de los datos ni para futuros procesos ya que no contienen informacion completa o repiten la contenida en otras como por ejemplo   "Estrategia_Objetivo" y "Categoria_Estrategia".
lac_regul<-my_data[ , -c(2:4,6, 13)] 
names(lac_regul)

# lac_regul es el db con que trabajaremos de aqui en adelante con el objetivo de convertir la informacion de texto en variables binarias y posteriormente consolidar un panel de datos de los instrumentos reulatorios implementados en america latina y el caribe (21 paises elegidos), durante 1970-2017.
setwd("nombre-directorio")

# Dando una mirada mas profunda a la variable año de publicacion de la ley (anno_pub) se encuentra un valor atipico que corresponde a row: 383 colum:3 
type.convert(lac_regul$anno_pub, numeric(length = 4L), na.strings = "") #contiene el valor 2003, 2007 en una sola observacion lo que convierte los datos en chr y no nos permite cambiar su type
#corregimos el valor especifico
lac_regul[383,3]
#hay dos maneras:     1)   lac_regul$anno_pub[lac_regul$anno_pub == "2003, 2007"] <- "2003"
#                     2)   lac_regul[383,3]<- "2003"
#para este caso utilizaremos la mas sencilla 2) y verificamos yendo a la observacion especifica
lac_regul[383,3]<- "2003"
lac_regul[393,3]
#además encontramos que la fila 231 no posee ningun tipo de informacion por lo que procedemos a eliminarla
lac_regul[231,]
lac_regul<-lac_regul[-231,]

#guardamos cambios en el formato de preferencia (por defecto quedaran guardados en el directorio anteriormente establecido)
write.csv2(lac_regul, file="lac_regul.csv")
save(lac_regul, file="lac_regul.rdata")
names(lac_regul)
#cerramos y volvemos a abrirla para limpiar el ambiente y comprobar que quedó guardada
#es recomendable limpiar todas las ventanas para una mejor comprension y un trabajo más organizado con la nueva data.
q()

####################################################################################
#continuar a partir de aqui como nuevo script
####################################################################################

#Nos debe abrir un data.frame de 436 filas por 9 variables 
load("~/lac_regul.rdata")
view(lac_regul)
summary(lac_regul)
names(lac_regul)

#necesitamos la variable de año como numerica para poder empezar a trabajar con ella
lac_regul$anno_pub<- as.numeric(as.character(lac_regul$anno_pub))
summary(lac_regul$anno_pub)

##############################################################################################################
#para conocer si fue o no modificada la ley o el instrumento regulatorio debemos crear una nueva variable
#a partir de ´Reg/Mod´ que contiene el nombre de la ley que le modifico. Para facilidad se sabe que los ultimos
#cuatro caracteres de dichas celdas corresponden al año de la ley que modificó a la primera promulgacion
#de acuerdo con esto buscamos crear una nueva variable que contenga solo los ultimos 4 caracteres de ´Reg/Mod´
#con el fin de conocer no solo si fue modificada, sino el año en que esto tuvo efecto, en caso contrario 
#aparecerá un cero "0". Utilizaremos la libreria "stringr"

#install.packages("stringr") #hablita esta linea de codigo si no has descargado la libreria que vamos a utilizar
library(stringr)
lac_regul$anno_modificacion <- str_sub(lac_regul$`Reg/Mod`, start= -4)
lac_regul$anno_modificacion<- as.numeric(as.character(lac_regul$anno_modificacion))
summary(lac_regul$anno_modificacion)
#tenemos un dato atipico "2030" que debemos cambiar al igual que los valores "NA" dejarlos como = 0
lac_regul$anno_modificacion[lac_regul$anno_modificacion == 2030] <- 2016
lac_regul$anno_modificacion[433] <- 2016
lac_regul$anno_modificacion[is.na(lac_regul$anno_modificacion)] <- 0
summary(lac_regul$anno_modificacion)

#> summary(lac_regul$anno_modificacion)
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#0       0       0     812    2012    2017 
#> summary(DB_RELAC$anno_modificacion)
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#0       0       0     812    2012    2017

summary(lac_regul)


#########################################################################################################
#Creating dummies: to know if the country have stablished a regulation (law, resolution, decrete)  ######
# aiming to any of the strategies detected from IRENA's classification.                            ######
##############################################################################################################
### Para verificar nuestras dummies se cuenta con un panel previamente realizado en excel cuidadosamente   ###
### el cual fué cargado en otro script, se encontrarán aqui algunos resultados (summary) de sus variables, ###
### comparados con los que procesamos con código R para verificar los aciertos en la generacion de dummies ###
##############################################################################################################

#convirtiendo en binaria si la ley esta dirigida a promover el acceso prioritario por parte de energias
#renovables no convencionales a cadenas de produccion, generacion y despacho en la matriz energetica

library(stringr)
lac_regul$Access <- as.integer(str_detect(lac_regul$Estrat_Objetivo,"Access"))
lac_regul$Access[is.na(lac_regul$Access)] <- 0
#> summary(lac_regul$Access)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#0.00000 0.00000 0.00000 0.03899 0.00000 1.00000
#> summary(DB_RELAC$`Acceso garantizado`)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#0.00000 0.00000 0.00000 0.03899 0.00000 1.00000

#dummy de ley impulsando Feed-in Tariffs
lac_regul$FiT<- as.integer(str_detect(lac_regul$Estrat_Objetivo,"Feed"))
summary(lac_regul$FiT)
lac_regul$FiT[is.na(lac_regul$FiT)] <- 0
#> summary(lac_regul$FiT)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#0.00000 0.00000 0.00000 0.05734 0.00000 1.00000
#> summary(DB_RELAC$FiT)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#0.00000 0.00000 0.00000 0.05734 0.00000 1.00000

#dummy de licitaciones publicas competitivas para empresas generadoras con FNCER
lac_regul$Auctions<- as.integer(str_detect(lac_regul$Estrat_Objetivo,"Auction"))
summary(lac_regul$Auctions)
lac_regul$Auctions[is.na(lac_regul$Auctions)] <- 0
#> summary(DB_RELAC$`Public Comp Bid`)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#0.0000  0.0000  0.0000  0.1995  0.0000  1.0000
#> summary(lac_regul$Auctions)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#0.0000  0.0000  0.0000  0.1995  0.0000  1.0000

#Hasta aquí quedamos con 13 variables

#dummy de si se poseen instrumentos legales que proveen Incentivos Fiscales a la generacion de energia con FNCER
lac_regul$Fiscal_Incentives<- as.integer(str_detect(lac_regul$Estrat_Objetivo,"Incentives"))
summary(lac_regul$Fiscal_Incentives)
lac_regul$Fiscal_Incentives[is.na(lac_regul$Fiscal_Incentives)] <- 0
#> summary(lac_regul$Fiscal_Incentives)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#  0.000   0.000   0.000   0.117   0.000   1.000 
#> summary(DB_RELAC$`Fiscal Incentives`)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#  0.000   0.000   0.000   0.117   0.000   1.000 

#para la dummy de excensiones de impuestos de importacion tomaremos como base la columna "Descripcion" ya que en "Estrat_Objetivo" no se encuentra esto especificado con excepcion de la fila 96
lac_regul$Import_Excempt<- as.integer(str_detect(lac_regul$Descripcion,"Import"))
summary(lac_regul$Import_Excempt)
lac_regul[96,15]<- 1
lac_regul$Import_Excempt[is.na(lac_regul$Import_Excempt)] <- 0
#> summary(lac_regul$Import_Excempt)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#0.00000 0.00000 0.00000 0.05734 0.00000 1.00000
#> summary(DB_RELAC$`Excensiones Import`)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#0.00000 0.00000 0.00000 0.05734 0.00000 1.00000

#dummy de Ley especifica de impulso y/o promocion de FNCER
lac_regul$Specif_Leg<- as.integer(str_detect(lac_regul$Estrat_Objetivo,"Specific"))
summary(lac_regul$Specif_Leg)
lac_regul$Specif_Leg[is.na(lac_regul$Specif_Leg)] <- 0
#> summary(lac_regul$Specif_Leg)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#0.00000 0.00000 0.00000 0.08486 0.00000 1.00000 
#> summary(DB_RELAC$`Specifc Legisl`)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#0.00000 0.00000 0.00000 0.08486 0.00000 1.00000 

#Dummy de esquema de medicion neta que posee el pais
#dummy de net billing o facturacion neta 
lac_regul$Net_Billing <- as.integer(str_detect(lac_regul$Estrat_Objetivo, "Billing"))
summary(lac_regul$Net_Billing)
lac_regul$Net_Billing[is.na(lac_regul$Net_Billing)] <- 0
#> summary(lac_regul$Net_Billing)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#0.00000 0.00000 0.00000 0.01147 0.00000 1.00000 
#> summary(DB_RELAC$`Net Billing`)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#0.00000 0.00000 0.00000 0.01147 0.00000 1.00000

#dummy de net metering o medicion neta 
lac_regul$Net_Metering <- as.integer(str_detect(lac_regul$Estrat_Objetivo, "Metering"))
summary(lac_regul$Net_Metering)
lac_regul$Net_Metering[is.na(lac_regul$Net_Metering)] <- 0
#> summary(lac_regul$Net_Metering)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#0.00000 0.00000 0.00000 0.05505 0.00000 1.00000 
#> summary(DB_RELAC$`Net Metering`)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#0.00000 0.00000 0.00000 0.05505 0.00000 1.00000 

#Dummy de estrategias dirigidas a fondos o inversion directa en FNCER
#para esta dummy tenemos dos palabras clave por lo que utilizaremos el comando ifelse df$Vegan <- ifelse(df$type == "Vegan", 1, 0)
lac_regul$FundInvest <- as.integer(ifelse(lac_regul$Estrat_Objetivo == "Funding", str_detect(lac_regul$Estrat_Objetivo, "Fund"), str_detect(lac_regul$Estrat_Objetivo, "Invest")))
summary(lac_regul$FundInvest)
##lac_regul$FundInvest[101]<- 1 ##POR ERROR DE DIGITACION EN lac_regul[101,8] <- "Funding"
lac_regul$FundInvest[is.na(lac_regul$FundInvest)] <- 0

#> summary(lac_regul$FundInvest)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
# 0.0000  0.0000  0.0000  0.1055  0.0000  1.0000
#> summary(DB_RELAC$`Fund/inv P`)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
# 0.0000  0.0000  0.0000  0.1055  0.0000  1.0000


#Dummy de mandatos de mexcla de combustible bioetanol transicion de combustibles fosiles a FNCER
#para esta dummy tenemos dos palabras clave por lo que utilizaremos el comando ifelse df$Vegan <- ifelse(df$type == "Vegan", 1, 0)
lac_regul$Biofuels <- as.integer(ifelse(grepl("Mandat", lac_regul$Estrat_Objetivo, ignore.case = FALSE), str_detect(lac_regul$Estrat_Objetivo, "Mandat"), str_detect(lac_regul$Descripcion, "Bio")))
summary(lac_regul$Biofuels)
lac_regul$Biofuels[is.na(lac_regul$Biofuels)] <- 0
#> summary(lac_regul$Biofuels)
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#0.00000 0.00000 0.00000 0.06651 0.00000 1.00000 
#> summary(DB_RELAC$Biofuels)
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#0.00000 0.00000 0.00000 0.06651 0.00000 1.0000

#########################################################################################################################
### Crearemos una dummy a partir de "anno_modificacion" que nos indique si el documento legal ha sido o no modificado ###

lac_regul$Modif_dummy <- ifelse(lac_regul$anno_modificacion > 1, 1, 0)
summary(lac_regul$Modif_dummy)
#> summary(lac_regul$Modif_dummy)
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#0.000   0.000   0.000   0.406   1.000   1.000 
#> summary(DB_RELAC$`Reg/Modif`)
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#0.000   0.000   0.000   0.406   1.000   1.000

#########################################################################################################################
### Crearemos una variable que nos dé cuenta del lapso de tiempo que transcurrio para un documento ser      ###
### modificado o regulado (cantidad de años que pasan hasta que eso sucede o se derroga/pierde vigencia)    ###

typeof(lac_regul$anno_pub)
typeof(lac_regul$anno_modificacion)

#lac_regul$anno_pub <-as.numeric(lac_regul$anno_pub)
#lac_regul$anno_modificacion <-as.numeric(lac_regul$anno_modificacion)
#lac_regul$`Reg/Mod`[330] <- 2014

lac_regul$Lapso_modif <- as.integer(ifelse(lac_regul$Modif_dummy == 1, lac_regul$anno_modificacion - lac_regul$anno_pub, 0))
summary(lac_regul$Lapso_modif)
#which(lac_regul == -2013, arr.ind = TRUE)
#lac_regul$Lapso_modif[433]
#lac_regul[433,]
#lac_regul$Lapso_modif[433] <- 0
which(lac_regul == -1, arr.ind = TRUE)
lac_regul[330,]
lac_regul$Lapso_modif[330] <- 0
#> summary(lac_regul$Lapso_modif)
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#0.000   0.000   0.000   2.032   2.000  37.000 
#> summary(DB_RELAC$`Lapso L_M`)
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#0.000   0.000   0.000   2.032   2.000  37.000 


########################################################################################
### Crearemos una variable que nos dé cuenta de cuantos años lleva vigente a 2018    ###

lac_regul$vigencia_2018 <- ifelse(grepl("In Force", lac_regul$Estado_V, ignore.case = TRUE), 2018-lac_regul$anno_pub, NA)
summary(lac_regul$vigencia_2018)
lac_regul$vigencia_2018[21]
lac_regul$vigencia_2018[22]
#> DB_RELAC$`2018`[21]
#[1] "12"
#> DB_RELAC$`2018`[22]
#[1] "OVER"
lac_regul$vigencia_2018[382]
#> DB_RELAC$`2018`[382]
#[1] "15"
#sum(is.na(lac_regul$vigencia_2018))
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
#  1.000   4.000   8.000   9.388  12.000  45.000     109

lac_regul$Vigencia_if_over <- ifelse(is.na(lac_regul$vigencia_2018), lac_regul$anno_modificacion-lac_regul$anno_pub, 0)
summary(lac_regul$Vigencia_if_over)
sum(lac_regul$Vigencia_if_over<0) #los negativos indican que el mismo año fue derrogado
#estas variables de vigencia negativas lo que significan es que la ley se promulgó y acabó o fue reemplazada y terminada ese 
#mismo año, no tuvo vigencia mayor a un año. y los valores NA en estas corresponden a las cuales no se tuvo datos de cuando 
#se terminó sin embargo se dan como terminadas por lo que se imputa el valor "0".

### Las últimas vars son una muestra de las variables interesantes que pueden ser     ###
### creadas a partir de los datos recolectados y esquematizados en dummies para      ###
### posteriormente ser procesados y realizar analisis interesantes.                  ###



###################################################################################################
###                  Pasemos a crear un PANEL con los datos que ya tenemos                      ###
###################################################################################################
install.packages("dplyr")

library(dplyr)
panel_relac <-

