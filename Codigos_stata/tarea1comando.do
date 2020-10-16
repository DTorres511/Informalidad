**********************************************************************************
*******************Análisis de Tarifas de Exportación e Importación***************
**********************************************************************************
*Fuente: WITS 
*Años: 1993-2018

*(1.1)********************************ARMAMOS LA DATA (1)
clear
import excel "C:\Users\Lori\Desktop\work_dianatorres\base_impo.xlsx", sheet("datos") firstrow
collapse SimpleAverage if DutyType=="AHS" , by(ProductName TariffYear PartnerName ImportsValuein1000USD)

gen AverageA=.
replace AverageA=1993 if TariffYear==1993
replace AverageA=2003 if TariffYear==2003
replace AverageA=2009 if TariffYear==2009
replace AverageA=2013 if TariffYear==2013
replace AverageA=2018 if TariffYear==2018
drop if missing(AverageA)
drop AverageA

gen Product=. if ProductName=="Total Trade"
replace Product=1 if ProductName!="Total Trade"
drop if missing(Product)
drop Product 
*Perú desde el Mundo: Evolución del arancel de importación según años estratégicos
table ProductName TariffYear, c(mean SimpleAverage) 

*(1.2)********************EXPORTAMOS LA TABLA

* para exportar a excel, descargar el comando:
ssc install tabout
help tabout
*abrir la carpeta donde se adjuntara el excel de la tabla
cd "C:\Users\Lori\Desktop\work_dianatorres"
*Guardar en excel:2 opciones
tabout ProductName TariffYear using tabladiana.xls,h3(nil) f(4c) c(mean SimpleAverage) sum  
tabout ProductName TariffYear using tabladiana.xls, dpcomma c(mean SimpleAverage) sum  
*dpcoma:si queremos que los decimales se representen por coma
*uso h3(nil) para que no me aparezca como titulo mean
*agrego f(4c) para que los resultados aparezcan con 4 decimales
*se agrega sum, para decirle al comando que es una tabla de resumen

*Por Socio Comercial: volución del arancel de importación 
table ProductName TariffYear, c(mean SimpleAverage),if PartnerName=="Argentina"
*exportar la tabla
tabout ProductName TariffYear if PartnerName=="Argentina" using tabladiana.xls, h3(nil) f(4c) c(mean SimpleAverage) sum append
*se pone append para que la ultima tabla sea agregada a la misma hoja del excel anterior

*(1.3)********************************ARMAMOS LA DATA (2)

*Evolución del arancel en tres periodos:
gen byte range_year=1 if TariffYear>=1993 & TariffYear<2003
replace range_year=2 if TariffYear>=2003 & TariffYear<2013
replace range_year=3 if TariffYear>=2013 & TariffYear<=2018

label variable range_year "Range of years(average)"
label define range_year1 1 "1993-2002"
label define range_year1 2 "2003-2012", add
label define range_year1 3 "2013-2018", add
label values range_year range_year1

table ProductName range_year , c(mean SimpleAverage)
*Guardar en excel

*(1.4)********************EXPORTAMOS LA TABLA

tabout ProductName range_year using tabladiana.xls,  h3(nil) f(4c) c(mean SimpleAverage) sum append







