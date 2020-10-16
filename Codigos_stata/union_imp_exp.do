*********************************************************************
****************UNION EXPORTACIONES-IMPORTACIONES********************
*********************************************************************
*(1)********************************ARMAMOS LA DATA (IMPORTACIONES)
clear
import excel "C:\Users\Lori\Desktop\work_dianatorres\tarea2\uniong1.xlsx",  firstrow
*mi excel descargado demora mucho en convertir los datos en números, asi que lo hago en stata
destring Reporter Partner TariffYear TradeYear SimpleAverage WeightedAverage StandardDeviation MinimumRate MaximumRate NbrofTotalLines NbrofDomesticPeaks NbrofInternationalPeaks ImportsValuein1000USD BindingCoverage,replace
collapse SimpleAverage if (DutyType=="AHS" & clase_dato=="importacion"), by(Product ProductName TariffYear PartnerName MinimumRate MaximumRate ImportsValuein1000USD)
collapse SimpleAverage MinimumRate MaximumRate ImportsValuein1000USD clase_dato if DutyType=="AHS", by( TariffYear)

gen AverageA=.
replace AverageA=2000 if TariffYear==2000
replace AverageA=2005 if TariffYear==2005
replace AverageA=2009 if TariffYear==2009
replace AverageA=2013 if TariffYear==2013
replace AverageA=2019 if TariffYear==2019
drop if missing(AverageA)
drop AverageA

gen Productn=. if (ProductName=="Total Trade")
replace Productn=1 if (ProductName!="Total Trade")
drop if missing(Productn)
drop Productn 

gen Partnern=. if (PartnerName=="17 paises mas importacionantes")
replace Partnern=1 if (PartnerName!="17 paises mas importacionantes")
drop if missing(Partnern)
drop Partnern 

*cambiar el nombre a las variables para separar importacion de exportacion
rename MinimumRate MMinimumRate
rename MaximumRate MMaximumRate
rename ImportsValuein1000USD MImportsValuein1000USD
rename SimpleAverage MSimpleAverage

save "C:\Users\Lori\Desktop\work_dianatorres\tarea2\baseM"

***************************ARMAMOS LA DATA EXPORTACIONES

clear
import excel "C:\Users\Lori\Desktop\work_dianatorres\tarea2\uniong1.xlsx",  firstrow
*mi excel descargado demora mucho en convertir los datos en números, asi que lo hago en stata
destring Reporter Partner TariffYear TradeYear SimpleAverage WeightedAverage StandardDeviation MinimumRate MaximumRate NbrofTotalLines NbrofDomesticPeaks NbrofInternationalPeaks ImportsValuein1000USD BindingCoverage,replace
collapse SimpleAverage if (DutyType=="AHS" & clase_dato=="exportacion"), by(Product ProductName TariffYear ReporterName MinimumRate MaximumRate ImportsValuein1000USD)

gen AverageA=.
replace AverageA=2000 if TariffYear==2000
replace AverageA=2005 if TariffYear==2005
replace AverageA=2009 if TariffYear==2009
replace AverageA=2013 if TariffYear==2013
replace AverageA=2019 if TariffYear==2019
drop if missing(AverageA)
drop AverageA

gen Productn=. if (ProductName=="Total Trade")
replace Productn=1 if (ProductName!="Total Trade")
drop if missing(Productn)
drop Productn 

gen Reportern=. if (ReporterName=="17 paises mas importacionantes")
replace Reportern=1 if (ReporterName!="17 paises mas importacionantes")
drop if missing(Reportern)
drop Reportern 

*cambiar el nombre a las variables para separar importacion de exportacion
rename MinimumRate XMinimumRate
rename MaximumRate XMaximumRate
rename ImportsValuein1000USD XImportsValuein1000USD
rename SimpleAverage XSimpleAverage






*Perú desde el Mundo: Evolución del arancel de importación según años estratégicos
table ProductName TariffYear, c(mean XSimpleAverage min XSimpleAverage max XSimpleAverage ) 

*(2)********************EXPORTAMOS LA TABLA

* para exportar a excel, descargar el comando:
ssc install tabout
help tabout
*abrir la carpeta donde se adjuntara el excel de la tabla
cd "C:\Users\Lori\Desktop\work_dianatorres"
*Guardar en excel:2 opciones
tabout ProductName TariffYear using tablaimp.xls,h3(nil) f(4c) c(mean SimpleAverage) sum  
tabout ProductName TariffYear using tablaimp.xls, dpcomma c(mean SimpleAverage) sum  
*dpcoma:si queremos que los decimales se representen por coma
*uso h3(nil) para que no me aparezca como titulo mean
*agrego f(4c) para que los resultados aparezcan con 4 decimales
*se agrega sum, para decirle al comando que es una tabla de resumen

*Por Socio Comercial: evolución del arancel de importación 
table ProductName TariffYear, c(mean SimpleAverage),if PartnerName=="China"
*exportar la tabla
tabout ProductName TariffYear if PartnerName=="China" using tablaimpchina.xls, h3(nil) f(4c) c(mean SimpleAverage) sum 
*se pone append para que la ultima tabla sea agregada a la misma hoja del excel anterior(donde sacamos la 1ra tabla)

*(1)********************************ARMAMOS LA DATA (2)

*Evolución del arancel en tres periodos:
gen byte range_year=1 if TariffYear>=2000 & TariffYear<2005
replace range_year=2 if TariffYear>=2005 & TariffYear<2013
replace range_year=3 if TariffYear>=2013 & TariffYear<=2019

label variable range_year "Range of years(average)"
label define range_year1 1 "2000-2004"
label define range_year1 2 "2005-2012", add
label define range_year1 3 "2013-2019", add
label values range_year range_year1

table ProductName range_year , c(mean SimpleAverage)
*Guardar en excel

*(2)********************EXPORTAMOS LA TABLA

tabout ProductName range_year using tablaimp2.xls,  h3(nil) f(4c) c(mean SimpleAverage) sum 

*(1)********************************ARMAMOS LA DATA (EXPORTACIONES)
clear
import excel "C:\Users\Lori\Desktop\work_dianatorres\tarea2\uniong1.xlsx",  firstrow
*mi excel descargado demora mucho en convertir los datos en números, asi que lo hago en stata
destring Reporter Partner TariffYear TradeYear SimpleAverage WeightedAverage StandardDeviation MinimumRate MaximumRate NbrofTotalLines NbrofDomesticPeaks NbrofInternationalPeaks ImportsValuein1000USD BindingCoverage,replace
collapse SimpleAverage if (DutyType=="AHS" & clase_dato=="exportacion"), by(ProductName TariffYear ReporterName ImportsValuein1000USD)

gen AverageA=.
replace AverageA=2000 if TariffYear==2000
replace AverageA=2005 if TariffYear==2005
replace AverageA=2009 if TariffYear==2009
replace AverageA=2013 if TariffYear==2013
replace AverageA=2019 if TariffYear==2019
drop if missing(AverageA)
drop AverageA

gen Product=. if ProductName=="Total Trade"
replace Product=1 if ProductName!="Total Trade"
drop if missing(Product)
drop Product 
*Perú desde el Mundo: Evolución del arancel de importación según años estratégicos
table ProductName TariffYear, c(mean SimpleAverage) 

*(2)********************EXPORTAMOS LA TABLA

* para exportar a excel, descargar el comando:
ssc install tabout
help tabout
*abrir la carpeta donde se adjuntara el excel de la tabla
cd "C:\Users\Lori\Desktop\work_dianatorres"
*Guardar en excel:2 opciones
tabout ProductName TariffYear using tablaexp.xls,h3(nil) f(4c) c(mean SimpleAverage) sum  
tabout ProductName TariffYear using tablaexp.xls, dpcomma c(mean SimpleAverage) sum  
*dpcoma:si queremos que los decimales se representen por coma
*uso h3(nil) para que no me aparezca como titulo mean
*agrego f(4c) para que los resultados aparezcan con 4 decimales
*se agrega sum, para decirle al comando que es una tabla de resumen

*Por Socio Comercial: evolución del arancel de importación 
table ProductName TariffYear, c(mean SimpleAverage),if ReporterName=="China"
*exportar la tabla
tabout ProductName TariffYear if ReporterName=="China" using tablaexpchina.xls, h3(nil) f(4c) c(mean SimpleAverage) sum 
*se pone append para que la ultima tabla sea agregada a la misma hoja del excel anterior(donde sacamos la 1ra tabla)

*(1)********************************ARMAMOS LA DATA (2)

*Evolución del arancel en tres periodos:
gen byte range_year=1 if TariffYear>=2000 & TariffYear<2005
replace range_year=2 if TariffYear>=2005 & TariffYear<2013
replace range_year=3 if TariffYear>=2013 & TariffYear<=2019

label variable range_year "Range of years(average)"
label define range_year1 1 "2000-2004"
label define range_year1 2 "2005-2012", add
label define range_year1 3 "2013-2019", add
label values range_year range_year1

table ProductName range_year , c(mean SimpleAverage)
*Guardar en excel

*(2)********************EXPORTAMOS LA TABLA

tabout ProductName range_year using tablaexp2.xls,  h3(nil) f(4c) c(mean SimpleAverage) sum 









