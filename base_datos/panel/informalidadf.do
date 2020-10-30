{
*Armando la data por módulos
clear all
set more off

global data "C:\Users\Lori\Desktop\work_dianatorres\Informalidad"
global output "C:\Users\Lori\Desktop\work_dianatorres\Informalidad\Output"

cd $data

*Selección del año
*desde el año 2007 se presenta la variable estructura sobre empleo formal o informal
*debemos correr todo el comando para que local funcione
local year 2009

use conglome vivienda hogar codperso ubigeo p204 p205 p206 p207 p208a p209 using "enaho01-`year'-200.dta", clear

rename p207 gender
rename p208a age
rename p209 est_civil
destring conglome, replace
destring vivienda, replace
destring hogar, replace
destring codperso, replace
save "mod2001-`year'.dta", replace

use conglome vivienda hogar codperso p4191 p4192 p4193 p4194 using "enaho01a-`year'-400.dta", clear
* Afiliacion seguro medico SEGMED
* Se asume que un trabajador que cotiza
* seguridad social tiene por tanto algun tipo
* de contrato, recibe vacaciones, etc.
*si segmed=0 tiene seguro de salud
gen segmed = 1
replace segmed = 0 if p4191==1
replace segmed = 0 if p4192==1
replace segmed = 0 if p4193==1
replace segmed = 0 if p4194==1
drop p4191 p4192 p4193 p4194
label var segmed "No cuenta con seguro"
destring conglome, replace
destring vivienda, replace
destring hogar, replace
destring codperso, replace
save "mod4001-`year'.dta", replace

*aqui debemos cambiar la variable p510a  por p510a1 a partir del año 2012 y la alternativa a tomar es la 3
*considerar la variable ocupinf a partir del 2007
use conglome vivienda hogar codperso fac500a i513t i518 i524d1 i530a i538d1 i541a ocu500 p505 p506 p507 p510 p510a p510b ///
p512a p512b ocupinf using "enaho01a-`year'-500.dta", clear
rename i524d1 i524e1
rename i538d1 i538e1

**  Clasificacion internacional de la
*   situacion en el empleo (cise).
*   1) Cuenta propia.
*   2) Empleadores.
*   3) Trabajador familiar auxiliar.
*   4) Empleados.

gen		cise = 1 if p507==2
replace cise = 2 if p507==1
replace cise = 3 if p507==5
*todos los dependientes
replace cise = 4 if (p507==3 | p507==4 |p507==6)
*los otros
replace cise = 5 if p507==7

rename fac500a pw

destring conglome, replace
destring vivienda, replace
destring hogar, replace
destring codperso, replace
save "mod5001-`year'.dta", replace



*Uniendo bases
use "mod2001-`year'.dta", clear
merge 1:1 conglome vivienda hogar codperso using "mod4001-`year'.dta"
drop _merge
merge 1:1 conglome vivienda hogar codperso using "mod5001-`year'.dta"
keep if _merge==3
drop _merge

* CLASIFICANDO EN SECTOR FORMAL E INFORMAL (sec_siu).
*    1) SECTOR INFORMAL.
*       CUENTA PROPIA Y EMPLEADORES (p507=1 o p507=2).
*         Se consideran con empleo en el sector informal los que tienen
*         negocios o empresas que no se encuentran registradas como persona
*         juridica (P510a = 2) y que no llevan las cuentas por medios de
*         libros exigidos por la SUNAT o sistema de contabilidad (P510b = 2)
*         y que tienen 5 o menos personas ocupadas (P512 < 6)
*
*       Trabajador Familiar Auxiliar (P507 = 5).
*         Se consideran con empleo en el sector informal los que trabajan en
*         empresas o negocios con 5 o menos personas ocupadas (P512 < 6)
*
*       Asalariados (P507 = 3, 4, 7)
*         Se consideran con empleo en el sector informal los que no son
*         trabajadores domesticos  (P507 = 6) y que trabajan para una empresa
*         o patrono privado, (P510 = 5, 6),  (i) que no estan registrados como
*         persona juridica (P510a = 2) (ii) que no llevan las cuentas por
*         medios de libros exigidos por la SUNAT o sistema de contabilidad
*         (P510b = 2)  y (iii) que tienen 5 o menos personas ocupadas (P512 < 6)
*
*    2) SECTOR DE HOGARES.
*       Incluye a todos los trabajadores del hogar (P507 = 6).
*
*    3) SECTOR FORMAL.
*       Empleados del sector publico.
*       Todos los ocupados no clasificados como del sector informal, ni del
*       sector de hogares.

*1 formal
*2 informal
gen 	sec_siu = 1
replace sec_siu = 1 if (p507==3 | p507==4 ) & (p510==1 | p510==2 | p510==3)
replace sec_siu = 2 if (p507==1 | p507==2) & p510a==2 & p510b==2 & p512a==1 & (p512b>=1 & p512b<=5)
replace sec_siu = 2 if p507==5 & p512a==1 & (p512b>=1 & p512b<=5)
replace sec_siu = 2 if ((p507==3 | p507==4 | p507==7) & (p510a==2) & p510b==2 & p512a==1 ///
& (p512b>=1 & p512b<=5))
*cambios:
*sacar a otros p507=7 de formales
*incluir p510a1=3, no esta registrado en la sunat  

** Empleo Informal:
* Se asume que un trabajador que cotiza
* seguridad social tiene por tanto algun tipo
* de contrato, recibe vacaciones, etc.

* Basado en la tenencia de seguro medico,
* se codifica cada trabajador como formal
* o informal.
* Observar que los numeros impares son
* informales y los pares formales.

* (2)
* (i)   trabajadores por cuenta propia dueños de sus
*       propias empresas del sector informal.
* (ii)  empleadores dueños de sus propias empresas
*       del sector informal.
* (iii) trabajadores familiares auxiliares independiemtente
*       de si trabajan en empresas del sector formal o informal.
* (5)   asalariados que no cotizan seguridad social.

gen 	emp_siu = 1 if (cise==1 & sec_siu==2)
replace emp_siu = 2 if (cise==1 & sec_siu==1)
replace emp_siu = 3 if (cise==2 & sec_siu==2)
replace emp_siu = 4 if (cise==2 & sec_siu==1)
*informal a los otros de cise y a los trabajadores familiares no remunerados
replace emp_siu = 5 if (cise==3 | cise==5)
replace emp_siu = 6 if (cise==4 & segmed==0)
replace emp_siu = 7 if (cise==4 & segmed==1 )

* poblacion ocupada no residente, .
*0 no pea, desocupado
*1 pea:ocupado
*no cinsideraremos esta variable porque reduce los datos para determinar la condicion de formalidad en el empleo
gen ocupres =((p204 == 1 & p205 == 2) | (p204 == 2 & p206 == 1)) & ocu500 == 1
label variable segmed  "Afiliado a seguro medico por trabajo"
label variable cise    "Empleos segun situacion en el empleo"
label variable sec_siu "Tipo de unidad de produccion"
label variable emp_siu "Empleo Formal e Informal"
drop p204 p205 p206 p510 p510a p510b p512a p512b

* Indicador de Informalidad: no consideramos si es ocupado 
gen ocupinfp =  0 if (emp_siu==2 | emp_siu==4 |emp_siu==6) 
replace ocupinfp = 1 if (emp_siu==1 | emp_siu==3 | emp_siu==5 | emp_siu==7) 
*replace ocupinfp = . if ocupres==0
label variable ocupinfp "Condicion de empleo-replica"
label define ocupinfp 0 "empleo_formal" 1 "empleo_informal"
* o es empleo formal y 1 empleo informal
*drop ocupres
cd $output
save "basefinal1-`year'.dta", replace
*tablas para cada año
tabout ocupinfp p507 using tabresumen1_`year'.xls, h3(nil) 

*Indicador de Informalidad: 2009-2015-2016-2017-2018-2019 (solo a los ocupados)
gen ocupinfp1 =  0 if (emp_siu==2 | emp_siu==4 |emp_siu==6) & ocu500==1
replace ocupinfp1 = 1 if (emp_siu==1 | emp_siu==3 | emp_siu==5 | emp_siu==7) & ocu500==1

*correlación
replace ocupinf=0 if ocupinf==2
pwcorr ocupinfp ocupinf
*-----------------------
}
{****DATA PANEL -BASE: 2011*******
****DATA PANEL -BASE: 2011*******
*Armando la data por módulos
clear all
set more off

global data "C:\Users\Lori\Desktop\work_dianatorres\Informalidad\PANEL"
global output "C:\Users\Lori\Desktop\work_dianatorres\Informalidad\PANEL\Output\base2015"
*base2016
*base2017
*base2018
*base2019
cd $data

*Selección del año
*desde el año 2007 se presenta la variable estructura sobre empleo formal o informal
*debemos correr todo el comando para que local funcione
local year 11
*para la base 2011
use con_`year' viv_`year' hog_`year' codp_`year' ubigeo_`year' p204_`year' p205_`year' p206_`year' p207_`year' p208a_`year' p209_`year' using "enaho01a-2007-2011-500-panel", clear
*para la base 2015 "enaho01a-2011-2015-500-panel"
*para la base 2016 "enaho01a-2012-2016-500-panel"
*para la base 2017 "enaho01a-2013-2017-500-panel"
*para la base 2018 "enaho01a-2014-2018-500-panel"
*para la base 2019 "enaho01a-2011-2015-500-panel"

rename p207_`year' gender
rename p208a_`year' age
rename p209_`year' est_civil
destring con_`year', replace
destring viv_`year', replace
destring hog_`year', replace
destring codp_`year', replace
save "mod200-`year'.dta", replace
*base 2011
use con_`year' viv_`year' hog_`year' codp_`year' p4191_`year' p4192_`year' p4193_`year' p4194_`year' using "enaho01a-2007-2011-400-panel", clear

* Afiliacion seguro medico SEGMED
* Se asume que un trabajador que cotiza
* seguridad social tiene por tanto algun tipo
* de contrato, recibe vacaciones, etc.
*si segmed=0 tiene seguro de salud
gen segmed = 1
replace segmed = 0 if p4191_`year'==1
replace segmed = 0 if p4192_`year'==1
replace segmed = 0 if p4193_`year'==1
replace segmed = 0 if p4194_`year'==1
drop p4191_`year' p4192_`year' p4193_`year' p4194_`year'
label var segmed "No cuenta con seguro"
destring con_`year', replace
destring viv_`year', replace
destring hog_`year', replace
destring codp_`year', replace
save "mod400-`year'.dta", replace

*aqui debemos cambiar la variable p510a  por p510a1 a partir del año 2012 y la alternativa a tomar es la 3
*no hay la variable ocupinf en la base 2011
*base 2011
use con_`year' viv_`year' hog_`year' codp_`year' fac5_`year'  ocu500_`year' p505_`year' p506_`year' p507_`year' p510_`year' p510a_`year' p510b_`year' ///
p512a_`year' p512b_`year'  using "enaho01a-2007-2011-500-panel", clear

*rename i524d1 i524e1 no estamos usando estas variables
*i513t i518 i524d1 i530a i538d1 i541a
*rename i538d1 i538e1

**  Clasificacion internacional de la
*   situacion en el empleo (cise).
*   1) Cuenta propia.
*   2) Empleadores.
*   3) Trabajador familiar auxiliar.
*   4) Empleados.

gen		cise = 1 if p507_`year'==2
replace cise = 2 if p507_`year'==1
replace cise = 3 if p507_`year'==5
*todos los dependientes
replace cise = 4 if (p507_`year'==3 | p507_`year'==4 |p507_`year'==6)
*los otros
replace cise = 5 if p507_`year'==7

rename fac5_`year' pw

destring con_`year', replace
destring viv_`year', replace
destring hog_`year', replace
destring codp_`year', replace
save "mod500-`year'.dta", replace



*Uniendo bases
use "mod200-`year'.dta", clear
merge n:n con_`year' viv_`year' hog_`year' codp_`year' using "mod400-`year'.dta"
drop _merge
merge n:n con_`year' viv_`year' hog_`year' codp_`year' using "mod500-`year'.dta"
keep if _merge==3
drop _merge

* CLASIFICANDO EN SECTOR FORMAL E INFORMAL (sec_siu).
*    1) SECTOR INFORMAL.
*       CUENTA PROPIA Y EMPLEADORES (p507=1 o p507=2).
*         Se consideran con empleo en el sector informal los que tienen
*         negocios o empresas que no se encuentran registradas como persona
*         juridica (P510a = 2) y que no llevan las cuentas por medios de
*         libros exigidos por la SUNAT o sistema de contabilidad (P510b = 2)
*         y que tienen 5 o menos personas ocupadas (P512 < 6)
*
*       Trabajador Familiar Auxiliar (P507 = 5).
*         Se consideran con empleo en el sector informal los que trabajan en
*         empresas o negocios con 5 o menos personas ocupadas (P512 < 6)
*
*       Asalariados (P507 = 3, 4, 7)
*         Se consideran con empleo en el sector informal los que no son
*         trabajadores domesticos  (P507 = 6) y que trabajan para una empresa
*         o patrono privado, (P510 = 5, 6),  (i) que no estan registrados como
*         persona juridica (P510a = 2) (ii) que no llevan las cuentas por
*         medios de libros exigidos por la SUNAT o sistema de contabilidad
*         (P510b = 2)  y (iii) que tienen 5 o menos personas ocupadas (P512 < 6)
*
*    2) SECTOR DE HOGARES.
*       Incluye a todos los trabajadores del hogar (P507 = 6).
*
*    3) SECTOR FORMAL.
*       Empleados del sector publico.
*       Todos los ocupados no clasificados como del sector informal, ni del
*       sector de hogares.

*1 formal
*2 informal
gen 	sec_siu = 1
replace sec_siu = 1 if (p507_`year'==3 | p507_`year'==4 ) & (p510_`year'==1 | p510_`year'==2 | p510_`year'==3)
replace sec_siu = 2 if (p507_`year'==1 | p507_`year'==2) & p510a_`year'==2 & p510b_`year'==2 & p512a_`year'==1 & (p512b_`year'>=1 & p512b_`year'<=5)
replace sec_siu = 2 if p507_`year'==5 & p512a_`year'==1 & (p512b_`year'>=1 & p512b_`year'<=5)
replace sec_siu = 2 if ((p507_`year'==3 | p507_`year'==4 | p507_`year'==7) & (p510a_`year'==2) & p510b_`year'==2 & p512a_`year'==1 ///
& (p512b_`year'>=1 & p512b_`year'<=5))
*cambios:
*sacar a otros p507=7 de formales
*incluir p510a1=3, no esta registrado en la sunat  

** Empleo Informal:
* Se asume que un trabajador que cotiza
* seguridad social tiene por tanto algun tipo
* de contrato, recibe vacaciones, etc.

* Basado en la tenencia de seguro medico,
* se codifica cada trabajador como formal
* o informal.
* Observar que los numeros impares son
* informales y los pares formales.

* (2)
* (i)   trabajadores por cuenta propia dueños de sus
*       propias empresas del sector informal.
* (ii)  empleadores dueños de sus propias empresas
*       del sector informal.
* (iii) trabajadores familiares auxiliares independiemtente
*       de si trabajan en empresas del sector formal o informal.
* (5)   asalariados que no cotizan seguridad social.

gen 	emp_siu = 1 if (cise==1 & sec_siu==2)
replace emp_siu = 2 if (cise==1 & sec_siu==1)
replace emp_siu = 3 if (cise==2 & sec_siu==2)
replace emp_siu = 4 if (cise==2 & sec_siu==1)
*informal a los otros de cise y a los trabajadores familiares no remunerados
replace emp_siu = 5 if (cise==3 | cise==5)
replace emp_siu = 6 if (cise==4 & segmed==0)
replace emp_siu = 7 if (cise==4 & segmed==1 )

* poblacion ocupada no residente, .
*0 no pea, desocupado
*1 pea:ocupado
*no cinsideraremos esta variable porque reduce los datos para determinar la condicion de formalidad en el empleo
gen ocupres =((p204_`year' == 1 & p205_`year' == 2) | (p204_`year' == 2 & p206_`year' == 1)) & ocu500_`year' == 1
label variable segmed  "Afiliado a seguro medico por trabajo"
label variable cise    "Empleos segun situacion en el empleo"
label variable sec_siu "Tipo de unidad de produccion"
label variable emp_siu "Empleo Formal e Informal"
drop p204_`year' p205_`year' p206_`year' p510_`year' p510a_`year' p510b_`year' p512a_`year' p512b_`year'

* Indicador de Informalidad: no consideramos si es ocupado 
gen ocupinfp =  0 if (emp_siu==2 | emp_siu==4 |emp_siu==6) 
replace ocupinfp = 1 if (emp_siu==1 | emp_siu==3 | emp_siu==5 | emp_siu==7) 
*replace ocupinfp = . if ocupres==0
label variable ocupinfp "Condicion de empleo-replica"
label define ocupinfp 0 "empleo_formal" 1 "empleo_informal"
* o es empleo formal y 1 empleo informal
*drop ocupres
cd $output
save "basefinal-`year'.dta", replace
*tablas para cada año
tabout ocupinfp p507_`year' using tabresumen1_`year'.xls, h3(nil) 

*Indicador de Informalidad: 2009-2015-2016-2017-2018-2019 (solo a los ocupados)
gen ocupinfp1 =  0 if (emp_siu==2 | emp_siu==4 |emp_siu==6) & ocu500==1
replace ocupinfp1 = 1 if (emp_siu==1 | emp_siu==3 | emp_siu==5 | emp_siu==7) & ocu500==1

*correlación
replace ocupinf=0 if ocupinf==2
pwcorr ocupinfp ocupinf
*-----------------------







}
{****DATA PANEL -BASE: 2015*******
*Armando la data por módulos
clear all
set more off

global data "C:\Users\Lori\Desktop\work_dianatorres\Informalidad\PANEL\base2015"
global output "C:\Users\Lori\Desktop\work_dianatorres\Informalidad\PANEL\base2015"
*base2016
*base2017
*base2018
*base2019
cd $data

*Selección del año
*desde el año 2007 se presenta la variable estructura sobre empleo formal o informal
*debemos correr todo el comando para que local funcione
local year 15
*para la base 2011
use conglome_`year' vivienda_`year' hogar_`year' codperso_`year' ubigeo_`year' p204_`year' p205_`year' p206_`year' p207_`year' p208a_`year' p209_`year' using "enaho01a-2011-2015-500-panel", clear
*para la base 2015 "enaho01a-2011-2015-500-panel"
*para la base 2016 "enaho01a-2012-2016-500-panel"
*para la base 2017 "enaho01a-2013-2017-500-panel"
*para la base 2018 "enaho01a-2014-2018-500-panel"
*para la base 2019 "enaho01a-2011-2015-500-panel"

rename p207_`year' gender
rename p208a_`year' age
rename p209_`year' est_civil
destring conglome_`year', replace
destring vivienda_`year', replace
destring hogar_`year', replace
destring codperso_`year', replace
save "mod200-`year'.dta", replace
*base 2011
use conglome_`year' vivienda_`year' hogar_`year' codperso_`year' p4191_`year' p4192_`year' p4193_`year' p4194_`year' using "enaho01a-2011-2015-400-panel", clear

* Afiliacion seguro medico SEGMED
* Se asume que un trabajador que cotiza
* seguridad social tiene por tanto algun tipo
* de contrato, recibe vacaciones, etc.
*si segmed=0 tiene seguro de salud
gen segmed = 1
replace segmed = 0 if p4191_`year'==1
replace segmed = 0 if p4192_`year'==1
replace segmed = 0 if p4193_`year'==1
replace segmed = 0 if p4194_`year'==1
drop p4191_`year' p4192_`year' p4193_`year' p4194_`year'
label var segmed "No cuenta con seguro"
destring conglome_`year', replace
destring vivienda_`year', replace
destring hogar_`year', replace
destring codperso_`year', replace
save "mod400-`year'.dta", replace

*aqui debemos cambiar la variable p510a  por p510a1 a partir del año 2012 y la alternativa a tomar es la 3
*no hay la variable ocupinf en la base 2011
*base 2011
use conglome_`year' vivienda_`year' hogar_`year' codperso_`year' fac500a_`year'  ocu500_`year' p505_`year' p506_`year' p507_`year' p510_`year' p510a1_`year' p510b_`year' ///
p512a_`year' p512b_`year'  ocupinf_`year' using "enaho01a-2011-2015-500-panel", clear
*fac500a7 para 2011
*fac500 para el resto de años
*rename i524d1 i524e1 no estamos usando estas variables
*i513t i518 i524d1 i530a i538d1 i541a
*rename i538d1 i538e1

**  Clasificacion internacional de la
*   situacion en el empleo (cise).
*   1) Cuenta propia.
*   2) Empleadores.
*   3) Trabajador familiar auxiliar.
*   4) Empleados.

gen		cise = 1 if p507_`year'==2
replace cise = 2 if p507_`year'==1
replace cise = 3 if p507_`year'==5
*todos los dependientes
replace cise = 4 if (p507_`year'==3 | p507_`year'==4 |p507_`year'==6)
*los otros
replace cise = 5 if p507_`year'==7

rename fac500a_`year' pw

destring conglome_`year', replace
destring vivienda_`year', replace
destring hogar_`year', replace
destring codperso_`year', replace
save "mod500-`year'.dta", replace



*Uniendo bases
use "mod200-`year'.dta", clear
merge n:n conglome_`year' vivienda_`year' hogar_`year' codperso_`year' using "mod400-`year'.dta"
drop _merge
merge n:n conglome_`year' vivienda_`year' hogar_`year' codperso_`year' using "mod500-`year'.dta"
keep if _merge==3
drop _merge

* CLASIFICANDO EN SECTOR FORMAL E INFORMAL (sec_siu).
*    1) SECTOR INFORMAL.
*       CUENTA PROPIA Y EMPLEADORES (p507=1 o p507=2).
*         Se consideran con empleo en el sector informal los que tienen
*         negocios o empresas que no se encuentran registradas como persona
*         juridica (P510a = 2) y que no llevan las cuentas por medios de
*         libros exigidos por la SUNAT o sistema de contabilidad (P510b = 2)
*         y que tienen 5 o menos personas ocupadas (P512 < 6)
*
*       Trabajador Familiar Auxiliar (P507 = 5).
*         Se consideran con empleo en el sector informal los que trabajan en
*         empresas o negocios con 5 o menos personas ocupadas (P512 < 6)
*
*       Asalariados (P507 = 3, 4, 7)
*         Se consideran con empleo en el sector informal los que no son
*         trabajadores domesticos  (P507 = 6) y que trabajan para una empresa
*         o patrono privado, (P510 = 5, 6),  (i) que no estan registrados como
*         persona juridica (P510a = 2) (ii) que no llevan las cuentas por
*         medios de libros exigidos por la SUNAT o sistema de contabilidad
*         (P510b = 2)  y (iii) que tienen 5 o menos personas ocupadas (P512 < 6)
*
*    2) SECTOR DE HOGARES.
*       Incluye a todos los trabajadores del hogar (P507 = 6).
*
*    3) SECTOR FORMAL.
*       Empleados del sector publico.
*       Todos los ocupados no clasificados como del sector informal, ni del
*       sector de hogares.

*1 formal
*2 informal
gen 	sec_siu = 1
replace sec_siu = 1 if (p507_`year'==3 | p507_`year'==4 ) & (p510_`year'==1 | p510_`year'==2 | p510_`year'==3)
replace sec_siu = 2 if (p507_`year'==1 | p507_`year'==2) & p510a1_`year'==3 & p510b_`year'==2 & p512a_`year'==1 & (p512b_`year'>=1 & p512b_`year'<=5)
replace sec_siu = 2 if p507_`year'==5 & p512a_`year'==1 & (p512b_`year'>=1 & p512b_`year'<=5)
replace sec_siu = 2 if ((p507_`year'==3 | p507_`year'==4 | p507_`year'==7) & (p510a1_`year'==3) & p510b_`year'==2 & p512a_`year'==1 ///
& (p512b_`year'>=1 & p512b_`year'<=5))
*cambios:
*sacar a otros p507=7 de formales
*incluir p510a1=3, no esta registrado en la sunat  

** Empleo Informal:
* Se asume que un trabajador que cotiza
* seguridad social tiene por tanto algun tipo
* de contrato, recibe vacaciones, etc.

* Basado en la tenencia de seguro medico,
* se codifica cada trabajador como formal
* o informal.
* Observar que los numeros impares son
* informales y los pares formales.

* (2)
* (i)   trabajadores por cuenta propia dueños de sus
*       propias empresas del sector informal.
* (ii)  empleadores dueños de sus propias empresas
*       del sector informal.
* (iii) trabajadores familiares auxiliares independiemtente
*       de si trabajan en empresas del sector formal o informal.
* (5)   asalariados que no cotizan seguridad social.

gen 	emp_siu = 1 if (cise==1 & sec_siu==2)
replace emp_siu = 2 if (cise==1 & sec_siu==1)
replace emp_siu = 3 if (cise==2 & sec_siu==2)
replace emp_siu = 4 if (cise==2 & sec_siu==1)
*informal a los otros de cise y a los trabajadores familiares no remunerados
replace emp_siu = 5 if (cise==3 | cise==5)
replace emp_siu = 6 if (cise==4 & segmed==0)
replace emp_siu = 7 if (cise==4 & segmed==1 )

* poblacion ocupada no residente, .
*0 no pea, desocupado
*1 pea:ocupado
*no cinsideraremos esta variable porque reduce los datos para determinar la condicion de formalidad en el empleo
gen ocupres =((p204_`year' == 1 & p205_`year' == 2) | (p204_`year' == 2 & p206_`year' == 1)) & ocu500_`year' == 1
label variable segmed  "Afiliado a seguro medico por trabajo"
label variable cise    "Empleos segun situacion en el empleo"
label variable sec_siu "Tipo de unidad de produccion"
label variable emp_siu "Empleo Formal e Informal"
drop p204_`year' p205_`year' p206_`year' p510_`year' p510a1_`year' p510b_`year' p512a_`year' p512b_`year'

* Indicador de Informalidad: no consideramos si es ocupado 
gen ocupinfp =  0 if (emp_siu==2 | emp_siu==4 |emp_siu==6) 
replace ocupinfp = 1 if (emp_siu==1 | emp_siu==3 | emp_siu==5 | emp_siu==7) 
*replace ocupinfp = . if ocupres==0
label variable ocupinfp "Condicion de empleo-replica"
label define ocupinfp 0 "empleo_formal" 1 "empleo_informal"
* o es empleo formal y 1 empleo informal
*drop ocupres
cd $output
*tablas para cada año
tabout ocupinfp p507_`year' using tabresumen1_`year'.xls, h3(nil) 

*Indicador de Informalidad: 2009-2015-2016-2017-2018-2019 (solo a los ocupados)
gen ocupinfp1 =  0 if (emp_siu==2 | emp_siu==4 |emp_siu==6) & ocu500==1
replace ocupinfp1 = 1 if (emp_siu==1 | emp_siu==3 | emp_siu==5 | emp_siu==7) & ocu500==1
save "basefinal-`year'.dta", replace

*correlación
replace ocupinf_`year'=0 if ocupinf_`year'==2
pwcorr ocupinfp ocupinf_`year'
*-----------------------



}
{****DATA PANEL -BASE: 2016*******
* NO LEE EL DTA
*Armando la data por módulos
clear all
set more off

global data "C:\Users\Lori\Desktop\work_dianatorres\Informalidad\PANEL\base2016"
global output "C:\Users\Lori\Desktop\work_dianatorres\Informalidad\PANEL\base2016"
*base2016
*base2017
*base2018
*base2019
cd $data

*Selección del año
*desde el año 2007 se presenta la variable estructura sobre empleo formal o informal
*debemos correr todo el comando para que local funcione
local year 12
*para la base 2011
use conglome_`year' vivienda_`year' hogar_`year' codperso_`year' ubigeo_`year' p204_`year' p205_`year' p206_`year' p207_`year' p208a_`year' p209_`year' using "enaho01a-2012-2016-500-panel", clear
*para la base 2015 "enaho01a-2011-2015-500-panel"
*para la base 2016 "enaho01a-2012-2016-500-panel"
*para la base 2017 "enaho01a-2013-2017-500-panel"
*para la base 2018 "enaho01a-2014-2018-500-panel"
*para la base 2019 "enaho01a-2011-2015-500-panel"

rename p207_`year' gender
rename p208a_`year' age
rename p209_`year' est_civil
destring conglome_`year', replace
destring vivienda_`year', replace
destring hogar_`year', replace
destring codperso_`year', replace
save "mod200-`year'.dta", replace
*base 2011
use conglome_`year' vivienda_`year' hogar_`year' codperso_`year' p4191_`year' p4192_`year' p4193_`year' p4194_`year' using "enaho01a-2012-2016-400-panel", clear

* Afiliacion seguro medico SEGMED
* Se asume que un trabajador que cotiza
* seguridad social tiene por tanto algun tipo
* de contrato, recibe vacaciones, etc.
*si segmed=0 tiene seguro de salud
gen segmed = 1
replace segmed = 0 if p4191_`year'==1
replace segmed = 0 if p4192_`year'==1
replace segmed = 0 if p4193_`year'==1
replace segmed = 0 if p4194_`year'==1
drop p4191_`year' p4192_`year' p4193_`year' p4194_`year'
label var segmed "No cuenta con seguro"
destring conglome_`year', replace
destring vivienda_`year', replace
destring hogar_`year', replace
destring codperso_`year', replace
save "mod400-`year'.dta", replace

*aqui debemos cambiar la variable p510a  por p510a1 a partir del año 2012 y la alternativa a tomar es la 3
*no hay la variable ocupinf en la base 2011
*base 2011
use conglome_`year' vivienda_`year' hogar_`year' codperso_`year' fac500a_`year'  ocu500_`year' p505_`year' p506_`year' p507_`year' p510_`year' p510a1_`year' p510b_`year' ///
p512a_`year' p512b_`year'  ocupinf_`year' using "enaho01a-2012-2016-500-panel", clear
*fac500a7 para 2011
*fac500 para el resto de años
*rename i524d1 i524e1 no estamos usando estas variables
*i513t i518 i524d1 i530a i538d1 i541a
*rename i538d1 i538e1

**  Clasificacion internacional de la
*   situacion en el empleo (cise).
*   1) Cuenta propia.
*   2) Empleadores.
*   3) Trabajador familiar auxiliar.
*   4) Empleados.

gen		cise = 1 if p507_`year'==2
replace cise = 2 if p507_`year'==1
replace cise = 3 if p507_`year'==5
*todos los dependientes
replace cise = 4 if (p507_`year'==3 | p507_`year'==4 |p507_`year'==6)
*los otros
replace cise = 5 if p507_`year'==7

rename fac500a_`year' pw

destring conglome_`year', replace
destring vivienda_`year', replace
destring hogar_`year', replace
destring codperso_`year', replace
save "mod500-`year'.dta", replace



*Uniendo bases
use "mod200-`year'.dta", clear
merge n:n conglome_`year' vivienda_`year' hogar_`year' codperso_`year' using "mod400-`year'.dta"
drop _merge
merge n:n conglome_`year' vivienda_`year' hogar_`year' codperso_`year' using "mod500-`year'.dta"
keep if _merge==3
drop _merge

* CLASIFICANDO EN SECTOR FORMAL E INFORMAL (sec_siu).
*    1) SECTOR INFORMAL.
*       CUENTA PROPIA Y EMPLEADORES (p507=1 o p507=2).
*         Se consideran con empleo en el sector informal los que tienen
*         negocios o empresas que no se encuentran registradas como persona
*         juridica (P510a = 2) y que no llevan las cuentas por medios de
*         libros exigidos por la SUNAT o sistema de contabilidad (P510b = 2)
*         y que tienen 5 o menos personas ocupadas (P512 < 6)
*
*       Trabajador Familiar Auxiliar (P507 = 5).
*         Se consideran con empleo en el sector informal los que trabajan en
*         empresas o negocios con 5 o menos personas ocupadas (P512 < 6)
*
*       Asalariados (P507 = 3, 4, 7)
*         Se consideran con empleo en el sector informal los que no son
*         trabajadores domesticos  (P507 = 6) y que trabajan para una empresa
*         o patrono privado, (P510 = 5, 6),  (i) que no estan registrados como
*         persona juridica (P510a = 2) (ii) que no llevan las cuentas por
*         medios de libros exigidos por la SUNAT o sistema de contabilidad
*         (P510b = 2)  y (iii) que tienen 5 o menos personas ocupadas (P512 < 6)
*
*    2) SECTOR DE HOGARES.
*       Incluye a todos los trabajadores del hogar (P507 = 6).
*
*    3) SECTOR FORMAL.
*       Empleados del sector publico.
*       Todos los ocupados no clasificados como del sector informal, ni del
*       sector de hogares.

*1 formal
*2 informal
gen 	sec_siu = 1
replace sec_siu = 1 if (p507_`year'==3 | p507_`year'==4 ) & (p510_`year'==1 | p510_`year'==2 | p510_`year'==3)
replace sec_siu = 2 if (p507_`year'==1 | p507_`year'==2) & p510a1_`year'==3 & p510b_`year'==2 & p512a_`year'==1 & (p512b_`year'>=1 & p512b_`year'<=5)
replace sec_siu = 2 if p507_`year'==5 & p512a_`year'==1 & (p512b_`year'>=1 & p512b_`year'<=5)
replace sec_siu = 2 if ((p507_`year'==3 | p507_`year'==4 | p507_`year'==7) & (p510a1_`year'==3) & p510b_`year'==2 & p512a_`year'==1 ///
& (p512b_`year'>=1 & p512b_`year'<=5))
*cambios:
*sacar a otros p507=7 de formales
*incluir p510a1=3, no esta registrado en la sunat  

** Empleo Informal:
* Se asume que un trabajador que cotiza
* seguridad social tiene por tanto algun tipo
* de contrato, recibe vacaciones, etc.

* Basado en la tenencia de seguro medico,
* se codifica cada trabajador como formal
* o informal.
* Observar que los numeros impares son
* informales y los pares formales.

* (2)
* (i)   trabajadores por cuenta propia dueños de sus
*       propias empresas del sector informal.
* (ii)  empleadores dueños de sus propias empresas
*       del sector informal.
* (iii) trabajadores familiares auxiliares independiemtente
*       de si trabajan en empresas del sector formal o informal.
* (5)   asalariados que no cotizan seguridad social.

gen 	emp_siu = 1 if (cise==1 & sec_siu==2)
replace emp_siu = 2 if (cise==1 & sec_siu==1)
replace emp_siu = 3 if (cise==2 & sec_siu==2)
replace emp_siu = 4 if (cise==2 & sec_siu==1)
*informal a los otros de cise y a los trabajadores familiares no remunerados
replace emp_siu = 5 if (cise==3 | cise==5)
replace emp_siu = 6 if (cise==4 & segmed==0)
replace emp_siu = 7 if (cise==4 & segmed==1 )

* poblacion ocupada no residente, .
*0 no pea, desocupado
*1 pea:ocupado
*no cinsideraremos esta variable porque reduce los datos para determinar la condicion de formalidad en el empleo
gen ocupres =((p204_`year' == 1 & p205_`year' == 2) | (p204_`year' == 2 & p206_`year' == 1)) & ocu500_`year' == 1
label variable segmed  "Afiliado a seguro medico por trabajo"
label variable cise    "Empleos segun situacion en el empleo"
label variable sec_siu "Tipo de unidad de produccion"
label variable emp_siu "Empleo Formal e Informal"
drop p204_`year' p205_`year' p206_`year' p510_`year' p510a1_`year' p510b_`year' p512a_`year' p512b_`year'

* Indicador de Informalidad: no consideramos si es ocupado 
gen ocupinfp =  0 if (emp_siu==2 | emp_siu==4 |emp_siu==6) 
replace ocupinfp = 1 if (emp_siu==1 | emp_siu==3 | emp_siu==5 | emp_siu==7) 
*replace ocupinfp = . if ocupres==0
label variable ocupinfp "Condicion de empleo-replica"
label define ocupinfp 0 "empleo_formal" 1 "empleo_informal"
* o es empleo formal y 1 empleo informal
*drop ocupres
cd $output
*tablas para cada año
tabout ocupinfp p507_`year' using tabresumen1_`year'.xls, h3(nil) 

*Indicador de Informalidad: 2009-2015-2016-2017-2018-2019 (solo a los ocupados)
gen ocupinfp1 =  0 if (emp_siu==2 | emp_siu==4 |emp_siu==6) & ocu500==1
replace ocupinfp1 = 1 if (emp_siu==1 | emp_siu==3 | emp_siu==5 | emp_siu==7) & ocu500==1
save "basefinal-`year'.dta", replace

*correlación
replace ocupinf_`year'=0 if ocupinf_`year'==2
pwcorr ocupinfp ocupinf_`year'
*-----------------------



}
{****DATA PANEL -BASE: 2017*******
*Armando la data por módulos
clear all
set more off

global data "C:\Users\Lori\Desktop\work_dianatorres\Informalidad\PANEL\base2017"
global output "C:\Users\Lori\Desktop\work_dianatorres\Informalidad\PANEL\base2017"
*base2016
*base2017
*base2018
*base2019
cd $data

*Selección del año
*desde el año 2007 se presenta la variable estructura sobre empleo formal o informal
*debemos correr todo el comando para que local funcione
local year 13
*para la base 2011
use conglome_`year' vivienda_`year' hogar_`year' codperso_`year' ubigeo_`year' p204_`year' p205_`year' p206_`year' p207_`year' p208a_`year' p209_`year' using "enaho01a-2013-2017-500-panel", clear
*para la base 2015 "enaho01a-2011-2015-500-panel"
*para la base 2016 "enaho01a-2012-2016-500-panel"
*para la base 2017 "enaho01a-2013-2017-500-panel"
*para la base 2018 "enaho01a-2014-2018-500-panel"
*para la base 2019 "enaho01a-2011-2015-500-panel"

rename p207_`year' gender
rename p208a_`year' age
rename p209_`year' est_civil
destring conglome_`year', replace
destring vivienda_`year', replace
destring hogar_`year', replace
destring codperso_`year', replace
save "mod200-`year'.dta", replace
*base 2011
use conglome_`year' vivienda_`year' hogar_`year' codperso_`year' p4191_`year' p4192_`year' p4193_`year' p4194_`year' using "enaho01a-2013-2017-400-panel", clear

* Afiliacion seguro medico SEGMED
* Se asume que un trabajador que cotiza
* seguridad social tiene por tanto algun tipo
* de contrato, recibe vacaciones, etc.
*si segmed=0 tiene seguro de salud
gen segmed = 1
replace segmed = 0 if p4191_`year'==1
replace segmed = 0 if p4192_`year'==1
replace segmed = 0 if p4193_`year'==1
replace segmed = 0 if p4194_`year'==1
drop p4191_`year' p4192_`year' p4193_`year' p4194_`year'
label var segmed "No cuenta con seguro"
destring conglome_`year', replace
destring vivienda_`year', replace
destring hogar_`year', replace
destring codperso_`year', replace
save "mod400-`year'.dta", replace

*aqui debemos cambiar la variable p510a  por p510a1 a partir del año 2012 y la alternativa a tomar es la 3
*no hay la variable ocupinf en la base 2011
*base 2011
use conglome_`year' vivienda_`year' hogar_`year' codperso_`year' fac500a_`year'  ocu500_`year' p505_`year' p506_`year' p507_`year' p510_`year' p510a1_`year' p510b_`year' ///
p512a_`year' p512b_`year'  ocupinf_`year' using "enaho01a-2013-2017-500-panel", clear
*fac500a7 para 2011
*fac500 para el resto de años
*rename i524d1 i524e1 no estamos usando estas variables
*i513t i518 i524d1 i530a i538d1 i541a
*rename i538d1 i538e1

**  Clasificacion internacional de la
*   situacion en el empleo (cise).
*   1) Cuenta propia.
*   2) Empleadores.
*   3) Trabajador familiar auxiliar.
*   4) Empleados.

gen		cise = 1 if p507_`year'==2
replace cise = 2 if p507_`year'==1
replace cise = 3 if p507_`year'==5
*todos los dependientes
replace cise = 4 if (p507_`year'==3 | p507_`year'==4 |p507_`year'==6)
*los otros
replace cise = 5 if p507_`year'==7

rename fac500a_`year' pw

destring conglome_`year', replace
destring vivienda_`year', replace
destring hogar_`year', replace
destring codperso_`year', replace
save "mod500-`year'.dta", replace



*Uniendo bases
use "mod200-`year'.dta", clear
merge n:n conglome_`year' vivienda_`year' hogar_`year' codperso_`year' using "mod400-`year'.dta"
drop _merge
merge n:n conglome_`year' vivienda_`year' hogar_`year' codperso_`year' using "mod500-`year'.dta"
keep if _merge==3
drop _merge

* CLASIFICANDO EN SECTOR FORMAL E INFORMAL (sec_siu).
*    1) SECTOR INFORMAL.
*       CUENTA PROPIA Y EMPLEADORES (p507=1 o p507=2).
*         Se consideran con empleo en el sector informal los que tienen
*         negocios o empresas que no se encuentran registradas como persona
*         juridica (P510a = 2) y que no llevan las cuentas por medios de
*         libros exigidos por la SUNAT o sistema de contabilidad (P510b = 2)
*         y que tienen 5 o menos personas ocupadas (P512 < 6)
*
*       Trabajador Familiar Auxiliar (P507 = 5).
*         Se consideran con empleo en el sector informal los que trabajan en
*         empresas o negocios con 5 o menos personas ocupadas (P512 < 6)
*
*       Asalariados (P507 = 3, 4, 7)
*         Se consideran con empleo en el sector informal los que no son
*         trabajadores domesticos  (P507 = 6) y que trabajan para una empresa
*         o patrono privado, (P510 = 5, 6),  (i) que no estan registrados como
*         persona juridica (P510a = 2) (ii) que no llevan las cuentas por
*         medios de libros exigidos por la SUNAT o sistema de contabilidad
*         (P510b = 2)  y (iii) que tienen 5 o menos personas ocupadas (P512 < 6)
*
*    2) SECTOR DE HOGARES.
*       Incluye a todos los trabajadores del hogar (P507 = 6).
*
*    3) SECTOR FORMAL.
*       Empleados del sector publico.
*       Todos los ocupados no clasificados como del sector informal, ni del
*       sector de hogares.

*1 formal
*2 informal
gen 	sec_siu = 1
replace sec_siu = 1 if (p507_`year'==3 | p507_`year'==4 ) & (p510_`year'==1 | p510_`year'==2 | p510_`year'==3)
replace sec_siu = 2 if (p507_`year'==1 | p507_`year'==2) & p510a1_`year'==3 & p510b_`year'==2 & p512a_`year'==1 & (p512b_`year'>=1 & p512b_`year'<=5)
replace sec_siu = 2 if p507_`year'==5 & p512a_`year'==1 & (p512b_`year'>=1 & p512b_`year'<=5)
replace sec_siu = 2 if ((p507_`year'==3 | p507_`year'==4 | p507_`year'==7) & (p510a1_`year'==3) & p510b_`year'==2 & p512a_`year'==1 ///
& (p512b_`year'>=1 & p512b_`year'<=5))
*cambios:
*sacar a otros p507=7 de formales
*incluir p510a1=3, no esta registrado en la sunat  

** Empleo Informal:
* Se asume que un trabajador que cotiza
* seguridad social tiene por tanto algun tipo
* de contrato, recibe vacaciones, etc.

* Basado en la tenencia de seguro medico,
* se codifica cada trabajador como formal
* o informal.
* Observar que los numeros impares son
* informales y los pares formales.

* (2)
* (i)   trabajadores por cuenta propia dueños de sus
*       propias empresas del sector informal.
* (ii)  empleadores dueños de sus propias empresas
*       del sector informal.
* (iii) trabajadores familiares auxiliares independiemtente
*       de si trabajan en empresas del sector formal o informal.
* (5)   asalariados que no cotizan seguridad social.

gen 	emp_siu = 1 if (cise==1 & sec_siu==2)
replace emp_siu = 2 if (cise==1 & sec_siu==1)
replace emp_siu = 3 if (cise==2 & sec_siu==2)
replace emp_siu = 4 if (cise==2 & sec_siu==1)
*informal a los otros de cise y a los trabajadores familiares no remunerados
replace emp_siu = 5 if (cise==3 | cise==5)
replace emp_siu = 6 if (cise==4 & segmed==0)
replace emp_siu = 7 if (cise==4 & segmed==1 )

* poblacion ocupada no residente, .
*0 no pea, desocupado
*1 pea:ocupado
*no cinsideraremos esta variable porque reduce los datos para determinar la condicion de formalidad en el empleo
gen ocupres =((p204_`year' == 1 & p205_`year' == 2) | (p204_`year' == 2 & p206_`year' == 1)) & ocu500_`year' == 1
label variable segmed  "Afiliado a seguro medico por trabajo"
label variable cise    "Empleos segun situacion en el empleo"
label variable sec_siu "Tipo de unidad de produccion"
label variable emp_siu "Empleo Formal e Informal"
drop p204_`year' p205_`year' p206_`year' p510_`year' p510a1_`year' p510b_`year' p512a_`year' p512b_`year'

* Indicador de Informalidad: no consideramos si es ocupado 
gen ocupinfp =  0 if (emp_siu==2 | emp_siu==4 |emp_siu==6) 
replace ocupinfp = 1 if (emp_siu==1 | emp_siu==3 | emp_siu==5 | emp_siu==7) 
*replace ocupinfp = . if ocupres==0
label variable ocupinfp "Condicion de empleo-replica"
label define ocupinfp 0 "empleo_formal" 1 "empleo_informal"
* o es empleo formal y 1 empleo informal
*drop ocupres
cd $output
*tablas para cada año
tabout ocupinfp p507_`year' using tabresumen1_`year'.xls, h3(nil) 

*Indicador de Informalidad: 2009-2015-2016-2017-2018-2019 (solo a los ocupados)
gen ocupinfp1 =  0 if (emp_siu==2 | emp_siu==4 |emp_siu==6) & ocu500==1
replace ocupinfp1 = 1 if (emp_siu==1 | emp_siu==3 | emp_siu==5 | emp_siu==7) & ocu500==1
save "basefinal-`year'.dta", replace

*correlación
replace ocupinf_`year'=0 if ocupinf_`year'==2
pwcorr ocupinfp ocupinf_`year'
*-----------------------

}
{****DATA PANEL -BASE: 2018*******
clear all
set more off

global data "C:\Users\Lori\Desktop\work_dianatorres\Informalidad\PANEL\base2016"
global output "C:\Users\Lori\Desktop\work_dianatorres\Informalidad\PANEL\base2016"
*base2016
*base2017
*base2018
*base2019
cd $data

*Selección del año
*desde el año 2007 se presenta la variable estructura sobre empleo formal o informal
*debemos correr todo el comando para que local funcione
local year 14
*para la base 2011
use conglome_`year' vivienda_`year' hogar_`year' codperso_`year' ubigeo_`year' p204_`year' p205_`year' p206_`year' p207_`year' p208a_`year' p209_`year' using "enaho01a-2014-2018-500-panel", clear
*para la base 2015 "enaho01a-2011-2015-500-panel"
*para la base 2016 "enaho01a-2012-2016-500-panel"
*para la base 2017 "enaho01a-2013-2017-500-panel"
*para la base 2018 "enaho01a-2014-2018-500-panel"
*para la base 2019 "enaho01a-2011-2015-500-panel"

rename p207_`year' gender
rename p208a_`year' age
rename p209_`year' est_civil
destring conglome_`year', replace
destring vivienda_`year', replace
destring hogar_`year', replace
destring codperso_`year', replace
save "mod200-`year'.dta", replace
*base 2011
use conglome_`year' vivienda_`year' hogar_`year' codperso_`year' p4191_`year' p4192_`year' p4193_`year' p4194_`year' using "enaho01a-2014-2018-400-panel", clear

* Afiliacion seguro medico SEGMED
* Se asume que un trabajador que cotiza
* seguridad social tiene por tanto algun tipo
* de contrato, recibe vacaciones, etc.
*si segmed=0 tiene seguro de salud
gen segmed = 1
replace segmed = 0 if p4191_`year'==1
replace segmed = 0 if p4192_`year'==1
replace segmed = 0 if p4193_`year'==1
replace segmed = 0 if p4194_`year'==1
drop p4191_`year' p4192_`year' p4193_`year' p4194_`year'
label var segmed "No cuenta con seguro"
destring conglome_`year', replace
destring vivienda_`year', replace
destring hogar_`year', replace
destring codperso_`year', replace
save "mod400-`year'.dta", replace

*aqui debemos cambiar la variable p510a  por p510a1 a partir del año 2012 y la alternativa a tomar es la 3
*no hay la variable ocupinf en la base 2011
*base 2011
use conglome_`year' vivienda_`year' hogar_`year' codperso_`year' fac500a_`year'  ocu500_`year' p505_`year' p506_`year' p507_`year' p510_`year' p510a1_`year' p510b_`year' ///
p512a_`year' p512b_`year'  ocupinf_`year' using "enaho01a-2014-2018-500-panel", clear
*fac500a7 para 2011
*fac500 para el resto de años
*rename i524d1 i524e1 no estamos usando estas variables
*i513t i518 i524d1 i530a i538d1 i541a
*rename i538d1 i538e1

**  Clasificacion internacional de la
*   situacion en el empleo (cise).
*   1) Cuenta propia.
*   2) Empleadores.
*   3) Trabajador familiar auxiliar.
*   4) Empleados.

gen		cise = 1 if p507_`year'==2
replace cise = 2 if p507_`year'==1
replace cise = 3 if p507_`year'==5
*todos los dependientes
replace cise = 4 if (p507_`year'==3 | p507_`year'==4 |p507_`year'==6)
*los otros
replace cise = 5 if p507_`year'==7

rename fac500a_`year' pw

destring conglome_`year', replace
destring vivienda_`year', replace
destring hogar_`year', replace
destring codperso_`year', replace
save "mod500-`year'.dta", replace



*Uniendo bases
use "mod200-`year'.dta", clear
merge n:n conglome_`year' vivienda_`year' hogar_`year' codperso_`year' using "mod400-`year'.dta"
drop _merge
merge n:n conglome_`year' vivienda_`year' hogar_`year' codperso_`year' using "mod500-`year'.dta"
keep if _merge==3
drop _merge

* CLASIFICANDO EN SECTOR FORMAL E INFORMAL (sec_siu).
*    1) SECTOR INFORMAL.
*       CUENTA PROPIA Y EMPLEADORES (p507=1 o p507=2).
*         Se consideran con empleo en el sector informal los que tienen
*         negocios o empresas que no se encuentran registradas como persona
*         juridica (P510a = 2) y que no llevan las cuentas por medios de
*         libros exigidos por la SUNAT o sistema de contabilidad (P510b = 2)
*         y que tienen 5 o menos personas ocupadas (P512 < 6)
*
*       Trabajador Familiar Auxiliar (P507 = 5).
*         Se consideran con empleo en el sector informal los que trabajan en
*         empresas o negocios con 5 o menos personas ocupadas (P512 < 6)
*
*       Asalariados (P507 = 3, 4, 7)
*         Se consideran con empleo en el sector informal los que no son
*         trabajadores domesticos  (P507 = 6) y que trabajan para una empresa
*         o patrono privado, (P510 = 5, 6),  (i) que no estan registrados como
*         persona juridica (P510a = 2) (ii) que no llevan las cuentas por
*         medios de libros exigidos por la SUNAT o sistema de contabilidad
*         (P510b = 2)  y (iii) que tienen 5 o menos personas ocupadas (P512 < 6)
*
*    2) SECTOR DE HOGARES.
*       Incluye a todos los trabajadores del hogar (P507 = 6).
*
*    3) SECTOR FORMAL.
*       Empleados del sector publico.
*       Todos los ocupados no clasificados como del sector informal, ni del
*       sector de hogares.

*1 formal
*2 informal
gen 	sec_siu = 1
replace sec_siu = 1 if (p507_`year'==3 | p507_`year'==4 ) & (p510_`year'==1 | p510_`year'==2 | p510_`year'==3)
replace sec_siu = 2 if (p507_`year'==1 | p507_`year'==2) & p510a1_`year'==3 & p510b_`year'==2 & p512a_`year'==1 & (p512b_`year'>=1 & p512b_`year'<=5)
replace sec_siu = 2 if p507_`year'==5 & p512a_`year'==1 & (p512b_`year'>=1 & p512b_`year'<=5)
replace sec_siu = 2 if ((p507_`year'==3 | p507_`year'==4 | p507_`year'==7) & (p510a1_`year'==3) & p510b_`year'==2 & p512a_`year'==1 ///
& (p512b_`year'>=1 & p512b_`year'<=5))
*cambios:
*sacar a otros p507=7 de formales
*incluir p510a1=3, no esta registrado en la sunat  

** Empleo Informal:
* Se asume que un trabajador que cotiza
* seguridad social tiene por tanto algun tipo
* de contrato, recibe vacaciones, etc.

* Basado en la tenencia de seguro medico,
* se codifica cada trabajador como formal
* o informal.
* Observar que los numeros impares son
* informales y los pares formales.

* (2)
* (i)   trabajadores por cuenta propia dueños de sus
*       propias empresas del sector informal.
* (ii)  empleadores dueños de sus propias empresas
*       del sector informal.
* (iii) trabajadores familiares auxiliares independiemtente
*       de si trabajan en empresas del sector formal o informal.
* (5)   asalariados que no cotizan seguridad social.

gen 	emp_siu = 1 if (cise==1 & sec_siu==2)
replace emp_siu = 2 if (cise==1 & sec_siu==1)
replace emp_siu = 3 if (cise==2 & sec_siu==2)
replace emp_siu = 4 if (cise==2 & sec_siu==1)
*informal a los otros de cise y a los trabajadores familiares no remunerados
replace emp_siu = 5 if (cise==3 | cise==5)
replace emp_siu = 6 if (cise==4 & segmed==0)
replace emp_siu = 7 if (cise==4 & segmed==1 )

* poblacion ocupada no residente, .
*0 no pea, desocupado
*1 pea:ocupado
*no cinsideraremos esta variable porque reduce los datos para determinar la condicion de formalidad en el empleo
gen ocupres =((p204_`year' == 1 & p205_`year' == 2) | (p204_`year' == 2 & p206_`year' == 1)) & ocu500_`year' == 1
label variable segmed  "Afiliado a seguro medico por trabajo"
label variable cise    "Empleos segun situacion en el empleo"
label variable sec_siu "Tipo de unidad de produccion"
label variable emp_siu "Empleo Formal e Informal"
drop p204_`year' p205_`year' p206_`year' p510_`year' p510a1_`year' p510b_`year' p512a_`year' p512b_`year'

* Indicador de Informalidad: no consideramos si es ocupado 
gen ocupinfp =  0 if (emp_siu==2 | emp_siu==4 |emp_siu==6) 
replace ocupinfp = 1 if (emp_siu==1 | emp_siu==3 | emp_siu==5 | emp_siu==7) 
*replace ocupinfp = . if ocupres==0
label variable ocupinfp "Condicion de empleo-replica"
label define ocupinfp 0 "empleo_formal" 1 "empleo_informal"
* o es empleo formal y 1 empleo informal
*drop ocupres
cd $output
*tablas para cada año
tabout ocupinfp p507_`year' using tabresumen1_`year'.xls, h3(nil) 

*Indicador de Informalidad: 2009-2015-2016-2017-2018-2019 (solo a los ocupados)
gen ocupinfp1 =  0 if (emp_siu==2 | emp_siu==4 |emp_siu==6) & ocu500==1
replace ocupinfp1 = 1 if (emp_siu==1 | emp_siu==3 | emp_siu==5 | emp_siu==7) & ocu500==1
save "basefinal-`year'.dta", replace

*correlación
replace ocupinf_`year'=0 if ocupinf_`year'==2
pwcorr ocupinfp ocupinf_`year'
*-----------------------

}

*debemos uniformizar el 2019: pasar de numerica a string 
{****DATA PANEL -BASE: 2019*******
*Armando la data por módulos
clear all
set more off

global data "C:\Users\Lori\Desktop\work_dianatorres\Informalidad\PANEL\base2019"
global output "C:\Users\Lori\Desktop\work_dianatorres\Informalidad\PANEL\base2019"
*base2016
*base2017
*base2018
*base2019
cd $data

*Selección del año
*desde el año 2007 se presenta la variable estructura sobre empleo formal o informal
*debemos correr todo el comando para que local funcione
local year 19
*para la base 2011
use conglome_`year' vivienda_`year' hogar_`year' codperso_`year' ubigeo_`year' p204_`year' p205_`year' p206_`year' p207_`year' p208a_`year' p209_`year' using "enaho01a-2015-2019-500-panel", clear
*para la base 2015 "enaho01a-2011-2015-500-panel"
*para la base 2016 "enaho01a-2012-2016-500-panel"
*para la base 2017 "enaho01a-2013-2017-500-panel"
*para la base 2018 "enaho01a-2014-2018-500-panel"
*para la base 2019 "enaho01a-2011-2015-500-panel"

rename p207_`year' gender
rename p208a_`year' age
rename p209_`year' est_civil
*para el año 15 usar tostring
tostring conglome_`year', replace
tostring vivienda_`year', replace
tostring hogar_`year', replace
tostring codperso_`year', replace
save "mod200-`year'.dta", replace
*base 2011
use conglome_`year' vivienda_`year' hogar_`year' codperso_`year' p4191_`year' p4192_`year' p4193_`year' p4194_`year' using "enaho01a-2015-2019-400-panel", clear

* Afiliacion seguro medico SEGMED
* Se asume que un trabajador que cotiza
* seguridad social tiene por tanto algun tipo
* de contrato, recibe vacaciones, etc.
*si segmed=0 tiene seguro de salud
gen segmed = 1
replace segmed = 0 if p4191_`year'==1
replace segmed = 0 if p4192_`year'==1
replace segmed = 0 if p4193_`year'==1
replace segmed = 0 if p4194_`year'==1
drop p4191_`year' p4192_`year' p4193_`year' p4194_`year'
label var segmed "No cuenta con seguro"
destring conglome_`year', replace
destring vivienda_`year', replace
destring hogar_`year', replace
destring codperso_`year', replace
save "mod400-`year'.dta", replace

*aqui debemos cambiar la variable p510a  por p510a1 a partir del año 2012 y la alternativa a tomar es la 3
*no hay la variable ocupinf en la base 2011
*base 2011
use conglome_`year' vivienda_`year' hogar_`year' codperso_`year' fac500a_`year'  ocu500_`year' p505_`year' p506_`year' p507_`year' p510_`year' p510a1_`year' p510b_`year' ///
p512a_`year' p512b_`year'  ocupinf_`year' using "enaho01a-2015-2019-500-panel", clear
*fac500a7 para 2011
*fac500 para el resto de años
*rename i524d1 i524e1 no estamos usando estas variables
*i513t i518 i524d1 i530a i538d1 i541a
*rename i538d1 i538e1

**  Clasificacion internacional de la
*   situacion en el empleo (cise).
*   1) Cuenta propia.
*   2) Empleadores.
*   3) Trabajador familiar auxiliar.
*   4) Empleados.

gen		cise = 1 if p507_`year'==2
replace cise = 2 if p507_`year'==1
replace cise = 3 if p507_`year'==5
*todos los dependientes
replace cise = 4 if (p507_`year'==3 | p507_`year'==4 |p507_`year'==6)
*los otros
replace cise = 5 if p507_`year'==7

rename fac500a_`year' pw

tostring conglome_`year', replace
tostring vivienda_`year', replace
tostring hogar_`year', replace
tostring codperso_`year', replace
save "mod500-`year'.dta", replace



*Uniendo bases
use "mod200-`year'.dta", clear
merge n:n conglome_`year' vivienda_`year' hogar_`year' codperso_`year' using "mod400-`year'.dta"
drop _merge
merge n:n conglome_`year' vivienda_`year' hogar_`year' codperso_`year' using "mod500-`year'.dta"
keep if _merge==3
drop _merge

* CLASIFICANDO EN SECTOR FORMAL E INFORMAL (sec_siu).
*    1) SECTOR INFORMAL.
*       CUENTA PROPIA Y EMPLEADORES (p507=1 o p507=2).
*         Se consideran con empleo en el sector informal los que tienen
*         negocios o empresas que no se encuentran registradas como persona
*         juridica (P510a = 2) y que no llevan las cuentas por medios de
*         libros exigidos por la SUNAT o sistema de contabilidad (P510b = 2)
*         y que tienen 5 o menos personas ocupadas (P512 < 6)
*
*       Trabajador Familiar Auxiliar (P507 = 5).
*         Se consideran con empleo en el sector informal los que trabajan en
*         empresas o negocios con 5 o menos personas ocupadas (P512 < 6)
*
*       Asalariados (P507 = 3, 4, 7)
*         Se consideran con empleo en el sector informal los que no son
*         trabajadores domesticos  (P507 = 6) y que trabajan para una empresa
*         o patrono privado, (P510 = 5, 6),  (i) que no estan registrados como
*         persona juridica (P510a = 2) (ii) que no llevan las cuentas por
*         medios de libros exigidos por la SUNAT o sistema de contabilidad
*         (P510b = 2)  y (iii) que tienen 5 o menos personas ocupadas (P512 < 6)
*
*    2) SECTOR DE HOGARES.
*       Incluye a todos los trabajadores del hogar (P507 = 6).
*
*    3) SECTOR FORMAL.
*       Empleados del sector publico.
*       Todos los ocupados no clasificados como del sector informal, ni del
*       sector de hogares.

*1 formal
*2 informal
gen 	sec_siu = 1
replace sec_siu = 1 if (p507_`year'==3 | p507_`year'==4 ) & (p510_`year'==1 | p510_`year'==2 | p510_`year'==3)
replace sec_siu = 2 if (p507_`year'==1 | p507_`year'==2) & p510a1_`year'==3 & p510b_`year'==2 & p512a_`year'==1 & (p512b_`year'>=1 & p512b_`year'<=5)
replace sec_siu = 2 if p507_`year'==5 & p512a_`year'==1 & (p512b_`year'>=1 & p512b_`year'<=5)
replace sec_siu = 2 if ((p507_`year'==3 | p507_`year'==4 | p507_`year'==7) & (p510a1_`year'==3) & p510b_`year'==2 & p512a_`year'==1 ///
& (p512b_`year'>=1 & p512b_`year'<=5))
*cambios:
*sacar a otros p507=7 de formales
*incluir p510a1=3, no esta registrado en la sunat  

** Empleo Informal:
* Se asume que un trabajador que cotiza
* seguridad social tiene por tanto algun tipo
* de contrato, recibe vacaciones, etc.

* Basado en la tenencia de seguro medico,
* se codifica cada trabajador como formal
* o informal.
* Observar que los numeros impares son
* informales y los pares formales.

* (2)
* (i)   trabajadores por cuenta propia dueños de sus
*       propias empresas del sector informal.
* (ii)  empleadores dueños de sus propias empresas
*       del sector informal.
* (iii) trabajadores familiares auxiliares independiemtente
*       de si trabajan en empresas del sector formal o informal.
* (5)   asalariados que no cotizan seguridad social.

gen 	emp_siu = 1 if (cise==1 & sec_siu==2)
replace emp_siu = 2 if (cise==1 & sec_siu==1)
replace emp_siu = 3 if (cise==2 & sec_siu==2)
replace emp_siu = 4 if (cise==2 & sec_siu==1)
*informal a los otros de cise y a los trabajadores familiares no remunerados
replace emp_siu = 5 if (cise==3 | cise==5)
replace emp_siu = 6 if (cise==4 & segmed==0)
replace emp_siu = 7 if (cise==4 & segmed==1 )

* poblacion ocupada no residente, .
*0 no pea, desocupado
*1 pea:ocupado
*no cinsideraremos esta variable porque reduce los datos para determinar la condicion de formalidad en el empleo
gen ocupres =((p204_`year' == 1 & p205_`year' == 2) | (p204_`year' == 2 & p206_`year' == 1)) & ocu500_`year' == 1
label variable segmed  "Afiliado a seguro medico por trabajo"
label variable cise    "Empleos segun situacion en el empleo"
label variable sec_siu "Tipo de unidad de produccion"
label variable emp_siu "Empleo Formal e Informal"
drop p204_`year' p205_`year' p206_`year' p510_`year' p510a1_`year' p510b_`year' p512a_`year' p512b_`year'

* Indicador de Informalidad: no consideramos si es ocupado 
gen ocupinfp =  0 if (emp_siu==2 | emp_siu==4 |emp_siu==6) 
replace ocupinfp = 1 if (emp_siu==1 | emp_siu==3 | emp_siu==5 | emp_siu==7) 
*replace ocupinfp = . if ocupres==0
label variable ocupinfp "Condicion de empleo-replica"
label define ocupinfp 0 "empleo_formal" 1 "empleo_informal"
* o es empleo formal y 1 empleo informal
*drop ocupres
cd $output
*tablas para cada año
tabout ocupinfp p507_`year' using tabresumen1_`year'.xls, h3(nil) 

*Indicador de Informalidad: 2009-2015-2016-2017-2018-2019 (solo a los ocupados)
gen ocupinfp1 =  0 if (emp_siu==2 | emp_siu==4 |emp_siu==6) & ocu500==1
replace ocupinfp1 = 1 if (emp_siu==1 | emp_siu==3 | emp_siu==5 | emp_siu==7) & ocu500==1
save "basefinal-`year'.dta", replace

*correlación
replace ocupinf_`year'=0 if ocupinf_`year'==2
pwcorr ocupinfp ocupinf_`year'
*-----------------------


}
