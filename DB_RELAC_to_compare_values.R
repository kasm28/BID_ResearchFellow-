# Este script prepara los datos recopilados provenientes del IRENA, climatescope, ministerios de energía y sitios oficiales 
#del gobierno de 21 paises latinoamericanos y del caribe con el fin de identificar las leyes enfocadas a la promocion de
#energias renovables en la Matriz Energetica de America Latina y el Caribe. Dichas leyes fueron recopialdas, leidas detalladamente 
#y posteriormente marcadas segun la estrategia u objetivo que se identificó en su contenido (resumido en la columna "Descripcion"). 
#El objetivo es codificar el texto recopilado en variables binarias para fácilitar el posterior procesamiento de la 
#informacion.

library(readxl)
DB_RELAC <- read_excel("C:/..............   DOCUMENTOS TRABAJO/RE-ENERGIAS RENOVABLES/PANEL/TIMELINE RE LAC/Reporte ALC RegulFramework/DB_RELAC.xlsx", sheet = "VAL_RELAC")
View(DB_RELAC)
summary(DB_RELAC)
#contamos con dos filas adicionales que no contienen ningun tipo de valores "NA" por lo que procedemos a eliminarlas de la 
#siguiente manera:
DB_RELAC<-DB_RELAC[-437:-438,]

summary(DB_RELAC)
#Llama poderosamente la atencion: primero verificamos que estamos trabajando con 1973-2017
#segundo el año máximo de modificacion aparece como 2030 por lo que es un dato bastante atipico y debemos proceder a 
#revisar el porqué y limpiar este tipo de objetos en nuestra data.

as.numeric(DB_RELAC$anno_modificacion)
DB_RELAC$anno_modificacion[DB_RELAC$anno_modificacion == 2030] <- 2016
summary(DB_RELAC$anno_modificacion)

#tercero debemos estandarizar los "NA" s que se encuentran en variables como el año de modificacion y otras
DB_RELAC$anno_modificacion[is.na(DB_RELAC$anno_modificacion)] <- 0
summary(DB_RELAC$anno_modificacion)

DB_RELAC$Tiempo_vig_after_modf[is.na(DB_RELAC$Tiempo_vig_after_modf)] <- 0
DB_RELAC$Tiempo_Vigencia_ifOver[is.na(DB_RELAC$Tiempo_Vigencia_ifOver)] <- 0
DB_RELAC$Tiempo_Vigencia_TOTAL[is.na(DB_RELAC$Tiempo_Vigencia_TOTAL)] <- 0

summary(DB_RELAC)

#por ultimo las variables Tiempo_Vigencia_** contienen valores negativos que pueden incomodar un poco para su procesamiento 
#por lo que debe buscarse una manera de modificar para facilitar procesos futuros
#estas variables de vigencia negativas lo que significan es que la ley se promulgó y acabó o fue reemplazada y terminada ese 
#mismo año, no tuvo vigencia mayor a un año. y los valores NA en estas 3 corresponden a las cuales no se tuvo datos de cuando 
#se terminó sin embargo se dan como terminadas por lo que podría imputarse el valor "0".

str(DB_RELAC)
#encontramos tambien que la variable 2018 (que captura el tiempo de vigencia a 2018 (1er trimestre)) contiene caracteres no 
#numericos, los cuales corresponden a "OVER" y debemos buscar una manera de categorizarlo en forma numerica para dejarla como 
#variable numerica y facilitar procesos futuros.
write.csv2(DB_RELAC, file = "db_relac_r_2018.csv", row.names = FALSE)

######################################################################################
#Lo primero que haremos es con R crear nosotros mismos las variables 10 a la 24 
#que contienen la informacion codificada en variables binarias.
######################################################################################
