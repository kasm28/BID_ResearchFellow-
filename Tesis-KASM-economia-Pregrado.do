/********************************************************************************
***   This Do file creates a DATASET to evaluate quality in education system  					 ***
***   on Colombia. We already have information from primary levels average   					 ***
***   scores (Saber 3, 5, 9). The secondary indivudual score (Saber 11) is   					 ***
***   already merged with college enrollment (from SPADIES) and its           					 ***
***   respective institucional information (college and school),             					 ***
*********************************************************************************

	Creator: Alexandra Sastoque Mendez 
	First Version: 			April 29th / 2016
	Date of last version:  	Aug 1st / 2016    (Prev: May 2nd/16)

		Important changes made to do:
				1)   	Install package to export stata regression outputs and set the output directoy where 
					we want them to be saved. 
				2) 	Find a variable to show average scores for each test using 3 main profiencies (science, 
					maths and language). This, to examine the school´s quality (at primary and secondary
					levels).
				2.1)   	Make them cohort comparable (standarize with mean 50, min 0 max 100).
				3) 	Build a variable to quantify the effect of students expectations generates from school
					to enroll college (Higer Education, HE).
				3.1) 	For each student the expectation is equal to the average proportion of college students 
					who had enroll HE during an specific period of time (i.e last 2 years).	
				4)   	Transform some independet variables to make easier job at data processing and analysis.
				4.1) 	Build numeric, cathegoric or dummies variables which contains schools and colleges information:
					- Dicotomic variables to signalize nature of institutions (private or public). That is a
					  dummy equal to 1 if it's public (to inquire into public education system as its 
					  provided by the government) or 0 if it´s private.
					- Dicotomic variables (altough could be categorical one) to indicate if institutions on
					  which students are attained at tertiary level are categorized as thecnical, technological 
					  or universities.
					- Built a variable (optional) triying robustness controlling population (e.g by ethnicities,
 					  regions, calendars on institutions, school days or the highest concentration point) looking 
					  for cleaner results. In this case we use Bogotá as the highest concentration point, so for each  
					  student the variable is equal to 1 if its school is from Bogotá or 0 otherwise. 
				5) 	Build dependent variable on college enrollment. 
				5.1)	For each student...a dummy equal to 1 if the student has any college code (or value diferent 
					to missing (.) -it depends on the author's source) from SPADIES dataset, or 0 otherwise. 
				
				

*********************************************************************************/

clear all
set more off

// ColombiaEduDataSet.

global path "/Volumes/Shura/Dropbox/´myuser´/"
}

qui do "${path}do_files/InitializeGlobals.do"

ssc install outreg2

if "`c(username)'"!="Dani Y Ale" {
cd "C:\TESIS\DOCUMENTO-TESIS\Results"
}
else{
cd "C:\Documents"
}



clear all

set more off

use "C:\TESIS\NUEVA\BASE TESIS DEFINITIVA.dta", clear

ssc install outreg2

*******************************************************************************
***Volviendo a una sola variable con el puntaje de cada prueba SABER11 para cada año** 
*******************************************************************************/
**** El primer procedimiento es para puntajes antes de 2010, el segundo para los despues ***
*******************************************************************************************
 
foreach materia in biologia maths filosofia fisica quimica lenguaje total {
          egen sb11_total_`materia'=rowtotal(sb11_*_`materia')   
	}


forvalues a=2006(1)2010 {
           forvalues p=1(1)2 {
                   drop sb11_`a'_`p'_*
        	}
	}

	sum sb11_total_* 

	
rename sb11_total_total sb11_antes2010

***** puntajes Saber11 despues de 2010 *******

foreach materia in lengua maths sociales filosofia biologia quimica fisica ingles {
	egen sb11_dsps2010_`materia'= rowtotal(sb11_*_`materia')
	}
	
forvalues a=2011(1)2014 {
           forvalues p=1(1)2 {
                   drop sb11_`a'_`p'_*
        	}
	}
	
egen float sb11_despues2010 = rowtotal(sb11_dsps2010_lengua  sb11_dsps2010_maths sb11_dsps2010_sociales sb11_dsps2010_filosofia sb11_dsps2010_biologia sb11_dsps2010_quimica sb11_dsps2010_fisica)

sum sb11_antes2010 sb11_despues2010

sum sb11_*
	

*******************************************************************************
****  Estadaizacion para hacer comparables los nuevos valores creados, **** 
************** de tres simple se asigna 100 al mayor puntaje ***************
*******************************************************************************/



replace sb11_total_biologia = ( sb11_total_biologia*100 ) / 687.0267

replace sb11_total_maths = ( sb11_total_maths*100 ) / 686.3782

replace sb11_total_filosofia = ( sb11_total_filosofia*100 ) / 664.0475

replace sb11_total_fisica = ( sb11_total_fisica*100 ) / 616.2919

replace sb11_total_quimica = ( sb11_total_quimica*100 ) / 688.6348

replace sb11_total_lenguaje = ( sb11_total_lenguaje*100 ) / 100

replace sb11_dsps2010_lengua = (sb11_dsps2010_lengua*100) / 672.8761

replace sb11_dsps2010_maths = (sb11_dsps2010_maths*100) / 1303.763

replace sb11_dsps2010_sociales = (sb11_dsps2010_sociales*100) / 688.302

replace sb11_dsps2010_filosofia = (sb11_dsps2010_filosofia*100) / 1246.215

replace sb11_dsps2010_biologia = (sb11_dsps2010_biologia*100) / 1298.876

replace sb11_dsps2010_quimica = (sb11_dsps2010_quimica*100) / 1286.664

replace sb11_dsps2010_fisica = (sb11_dsps2010_fisica*100) / 1158.827

replace sb11_dsps2010_ingles = (sb11_dsps2010_ingles*100) / 684.0284

replace sb11_despues2010 = (sb11_despues2010 * 100) / 7599.004


sum sb11_*




********************************************************************************
******* Para la medicion de calidad en educacion basica y media  ********** 
** Creamos una variable para el puntaje total de cada prueba saber, 3, 5 y 9 **
********************************************************************************

egen float sb3_total = rowtotal(sb3_*)

egen float sb5_total = rowtotal(sb5_*)

egen float sb9_total = rowtotal(sb9_*)

sum sb3_total sb5_total sb9_total 


replace sb3_total = ( sb3_total* 100 ) / 584.6

replace sb5_total = (sb5_total*100) / 1249.6

replace sb9_total = (sb9_total*100) / 1288.375

sum sb3_total sb5_total sb9_total

drop sb3_2012_* sb3_2013_* sb3_2014_* sb5_2009_* sb5_2012_* sb5_2013_* sb5_2014_* sb9_2009_* sb9_2012_* sb9_2013_* sb9_2014* *_puesto



*******************************************************************************
***        Genera una dummy para cada variable de SPADIES para conocer    ****
****           a donde entra y si se hace con algun tipo de apoyo         ***
******************************************************************************

gen DummyApoyoOtro=apo_otr!=.

gen DummyApoyoFin=apo_fin!=.

gen DummyApoyoAcadem=apo_aca!=.

gen DummyApoyoIcetex=apo_ictx!=.

gen DummyPublica=0 if prog_metodologia==2 

****** de la variable metodologia se sabe si la u es privada o publica *****

replace DummyPublica=1 if prog_metodologia==1

label variable DummyPublica `"1 "Publica" 0 "Privada""'

***** los niveles mas altos en la variable prog_nivel es universitarios,  ****
******* niveles 1 y 2= tecnico y tecnologico respectivamente   ******


gen DummyUniversitarios=1 if prog_nivel==4 | prog_nivel==5 | prog_nivel==8 

replace DummyUniversitarios=0 if prog_nivel==1 | prog_nivel==2 

label variable DummyUniversitarios `"1 "Universitario" 0 "Tecn&Tecnol""'





**** hay valores atipicos en la variable estudiante_trabaja ****
******                    se limpia                        **** 
 
replace icfes_estudiante_trabaja=. if icfes_estudiante_trabaja==7 



**************************************************************
***** botamos las que no vamos a usar o estan repetidas ******
**************************************************************

drop cole_jornada cole_codmpio_colegio cole_mpio_colegio




**********************************************************************
*****    PARA EL GRAFICO DE CAMBIO DE GOBIENO URIBE A SANTOS     ******
***** Crea una dummy =1 si entro despues de 2010 y cero al resto ******
*********************************************************************


gen DummySantosI=1 if periodoprimiparo==20101 | periodoprimiparo==20102 |periodoprimiparo==20111 | periodoprimiparo==20112 | periodoprimiparo==20121 | periodoprimiparo==20122

replace DummySantosI=0 if periodoprimiparo==20061

replace DummySantosI=0 if periodoprimiparo==20062 | periodoprimiparo==20071 | periodoprimiparo==20072 | periodoprimiparo==20081 | periodoprimiparo==20082 | periodoprimiparo==20091 | periodoprimiparo==20092

replace DummySantosI=. if periodoprimiparo==19981 | periodoprimiparo==19982 | periodoprimiparo==19991 | periodoprimiparo==19992 | periodoprimiparo==20001 | periodoprimiparo==20002 |periodoprimiparo==20011 | periodoprimiparo==20012 | periodoprimiparo==20021 | periodoprimiparo==20022 |periodoprimiparo==20031 | periodoprimiparo==20032 |periodoprimiparo==20041 | periodoprimiparo==20042 | periodoprimiparo==20051 | periodoprimiparo==20052

label variable DummySantosI `"1 "Santos" 0 "Uribe""'





**** Genera promedio de puntaje de saber11 para todos antes y despues de SantosI ****

egen float sb11_antes2010_todos = mean(sb11_antes2010)


egen sb11_dsps2010_todos = mean (sb11_despues2010)

sum *todos



**** Promedio puntaje de Saber11 por Departamento antes y despues de SantosI *******
**** no utilizo el "if DummySantos==1;0" por que ya se filtraron anteriormente *****
**** los puntajes por periodo de ingreso, antes y despues de 2010   *****

bysort depa_apli: egen float sb11_antes2010_porDEPTO = mean(sb11_antes2010) 


bysort depa_apli: egen float sb11_dsps2010_porDEPTO = mean(sb11_despues2010)

sum sb11_antes2010_todos sb11_antes2010_porDEPTO sb11_dsps2010_todos sb11_dsps2010_porDEPTO





********************************************************************************
*******                      GRAFICO             *****************
*******************************************************************************


twoway (scatter sb11_dsps2010_todos sb11_antes2010_todos) (scatter sb11_dsps2010_porDEPTO sb11_antes2010_porDEPTO)

twoway (scatter sb11_dsps2010_porDEPTO sb11_antes2010_porDEPTO) (function y=x)



****** la linea de fitted values funciona cuando le ordeno dibujarla ******
**** para el rango dentro del cual se encuentran los puntajes  ****


twoway (scatter sb11_dsps2010_porDEPTO sb11_antes2010_porDEPTO) (function y=x, range(sb11_antes2010_porDEPTO))




**************************************************************************************
********************                                 REGRESIONES         ***** 
***************************************************************************************

****** CORRER CON EL PUNTAJE TOTAL DE LA BASE DE LUIS OMAR ****

rename sb11_antes2010 sb11_total

cd ""C:\TESIS Alexandra"



reg DummyIES sb11_total_maths sb11_total_filosofia sb11_total_fisica sb11_total_quimica sb11_total_lenguaje sb11_total, r 

** MODELO 1 fisica y quimica no tienen efectos significativos, matematicas es la que mas peso tiene ** 

reg DummyIES sb11_total* i. icfes_ano, cluster (codigo_icfes)

outreg2 using icfspa.xls, excel dec(3)

** MODELO 1 con el paso de la cohorte disminuye el ingreso ** 


reg DummyIES sb11_total* i.icfes_ano  i. icfes_nivsis i.icfes_estudiante_* i.icfes_familia_* i.nivel_ed_* , cluster(codigo_icfes)
outreg2 using icfspa.xls, excel dec(3)

** MODELO 2 los de mayor estrato mas probabilidades de ingresan **  
** MODELO 2: mayor nivel ed de los padres lleva al estudiante a querer superar o igualar el de sus padres, hay mas probabilidad de ingreso ** 
**       a mas hermanos mas disminuye la probabilidad de ingreso, *****
**       y a mayor ingreso familiar, mayor estrato se mejora **


reg DummyIES sb11_total* edad i.icfes_ano i. icfes_nivsis i.icfes_estudiante_* i.icfes_familia_* i.nivel_ed_* i.colegio_naturaleza, cluster (codigo_icfes)

outreg2 using icfspa.xls, excel dec(3)

 **** MODELO 3:  Colegio publico menor probabilidad, mayor edad tambien disminuye la probabilidad *****
**si el colegio es publico el genero influye positivamente al ser mujer, el numero de personas ******
*** de la familia y si el estudiante trabaja influyen negativamente, el ingreso, ****
**** el estrato, nivel de sisben y los niveles educativos de los padres influyen ****
*****       tambien positivamente             **
 

 
 
 
 ********************************************************************************
 ****                   MODELO ENFOCADO A LA CALIDAD DE LA ED BASICA Y MEDIA ****
 ********************************************************************************
 

reg DummyIES sb3_total sb5_total sb9_total sb11_total i. icfes_ano, cluster (codigo_icfes)

outreg2 using sb359.xls, excel dec (3)
 
****** el resultado de cada prueba aumenta muy poco la probabilidad de ingreso ***
*************** a medida que se avanza en el sistema educativo ******************  



reg DummyIES sb3_total i. icfes_ano, cluster (codigo_icfes)

outreg2 using sb359.xls, excel dec (3)


reg DummyIES sb5_total i. icfes_ano, cluster (codigo_icfes)

outreg2 using sb359.xls, excel dec (3)
 

reg DummyIES sb9_total i. icfes_ano, cluster (codigo_icfes)

outreg2 using sb359.xls, excel dec (3)
 

reg DummyIES sb11_total i. icfes_ano, cluster (codigo_icfes)

outreg2 using sb359.xls, excel dec (3)

** solo con el saber 11 se aumenta la F y R-sq dndo mas significancia a los coeficientes ** 



** MODELO 4 mirando las constantes de las 4 regresiones anteriores, al ver ******
**** que de sb 3 a sb11 disminnuye, puede decirse que a medida que se va ******* 
***** avanzando en el sistema educativo DISMINUYE LA CALIDAD ...... ******** 
****** el estudiante debe hacer cada vez un mayor esfuerzo inicial  ************
**** en terminos academicos para elevar sus posibilidades de mantenerse ********
*****        en el sistema e ingresar a la universidad (?  *****************










*********************************************************************************
******             EVALUANDO LA FORMA EN LA QUE INGRESAN con Dummies deSPADIES **
*********************************************************************************


reg DummyApoyoOtro icfes_estudiante_* icfes_nivsis icfes_familia_* nivel_ed_* sb11_total i.icfes_ano, cluster(codigo_icfes)

outreg2 using pordummies.xls, excel dec (3)

** El nivel educativo del padre y madre es la mas importante para acceder a este tipo de apoyo. Disminuye a traves del tiempo **


reg DummyApoyoFin icfes_estudiante_* icfes_nivsis icfes_familia_* nivel_ed_* sb11_total i.icfes_ano, cluster(codigo_icfes)

outreg2 using pordummies.xls, excel dec (3)
 

reg DummyApoyoAcadem icfes_estudiante_* icfes_nivsis icfes_familia_* nivel_ed_* sb11_total i.icfes_ano, cluster(codigo_icfes)

outreg2 using pordummies.xls, excel dec (3) 


reg DummyApoyoIcetex icfes_estudiante_* icfes_nivsis icfes_familia_* nivel_ed_* sb11_total i.icfes_ano, cluster(codigo_icfes)

outreg2 using pordummies.xls, excel dec (3)



**mas personas en la familia y si trabaja menos posibilidad de acceder  ***** 
***** a apoyos de cualquiera de los 4 tipos para ingresar a ES **************
***** Lo que mas pesa para recibir cualquier tipo de apoyo son     **********
***** los niveles educativos d los padres seguido por el ingreso famiiar,
*********       el nivel del sisben y por ultimo el estrato     ********

reg DummyPublica sb11_total i.icfes_ano, cluster(codigo_icfes)

outreg2 using pordummies.xls, excel dec (3)
**Para una universidad publica la probabilidad de ingresar aumenta a traves del tiempo** 




reg DummyUniversitarios sb11_total i.icfes_ano, cluster(codigo_icfes)

outreg2 using pordummies.xls, excel dec (3)
** Para acceder al nivel Universitario la probabilidd aumenta entre cohortes ** 








*********************************************************************************
*********                INTENTO EVALUACION PARA ENTRAR EN SANTOS I   **********
*********************************************************************************
     

reg DummySantosI sb11_total icfes_estudiante_* icfes_familia_* nivel_ed_* icfes_nivsis, cluster(codigo_icfes)
** para ingresar en santosI si trabaja y el estrato no son significativos **** 
**** ser mujer mayor ingreso y los niveles educativos de los padres se *******
*** relacionan negativamente con el ingreso , esto debido al fuerte fomento **** 
*** de aumento de cobertura que lastimosamente no va de la mano con el mejora_ ***
***** miento de la calidad, sino que cmo se ha observado en la teoria y *** 
**** evidencia internacional, se contrarestan **** 
