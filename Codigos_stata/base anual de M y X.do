***********************
*****Para importaciones
***********************
clear
import excel "C:\Users\Lori\Desktop\work_dianatorres\tarea2\uniong1.xlsx",  firstrow(variables)
*mi excel descargado demora mucho en convertir los datos en números, asi que lo hago en stata
destring Reporter Partner TariffYear TradeYear SimpleAverage WeightedAverage StandardDeviation MinimumRate MaximumRate NbrofTotalLines NbrofDomesticPeaks NbrofInternationalPeaks ImportsValuein1000USD BindingCoverage,replace

keep if clase_dato=="importacion"
*eliminar "total trade"
gen Productn=. if (ProductName=="Total Trade")
replace Productn=1 if (ProductName!="Total Trade")
drop if missing(Productn)
drop Productn 
*eliminar "17 paises mas importantes"
gen Partnern=. if (PartnerName=="17 paises mas importacionantes")
replace Partnern=1 if (PartnerName!="17 paises mas importacionantes")
drop if missing(Partnern)
drop Partnern 

*armar la base para importaciones
collapse (mean) SimpleAverage StandardDeviation MinimumRate MaximumRate ImportsValuein1000USD if DutyType=="AHS", by(TariffYear)

*renombrar las variables para distinguir importaciones
rename MinimumRate M_MinimumRate
rename MaximumRate M_MaximumRate
rename ImportsValuein1000USD M_ImportsValuein1000USD
rename SimpleAverage M_SimpleAverage
rename StandardDeviation M_StandardDeviation
save "C:\Users\Lori\Desktop\work_dianatorres\basem1"

*************************
*******Para exportaciones
*************************

clear
import excel "C:\Users\Lori\Desktop\work_dianatorres\tarea2\uniong1.xlsx",  firstrow
*mi excel descargado demora mucho en convertir los datos en números, asi que lo hago en stata
destring Reporter Partner TariffYear TradeYear SimpleAverage WeightedAverage StandardDeviation MinimumRate MaximumRate NbrofTotalLines NbrofDomesticPeaks NbrofInternationalPeaks ImportsValuein1000USD BindingCoverage,replace

keep if clase_dato=="exportacion"

*eliminar "total trade"
gen Productn=. if (ProductName=="Total Trade")
replace Productn=1 if (ProductName!="Total Trade")
drop if missing(Productn)
drop Productn 
*eliminar "17 paises mas importantes"
gen Reportern=. if (ReporterName=="17 paises mas importacionantes")
replace Reportern=1 if (ReporterName!="17 paises mas importacionantes")
drop if missing(Reportern)
drop Reportern 

*armar la base para exportaciones
collapse (mean) SimpleAverage StandardDeviation MinimumRate MaximumRate ImportsValuein1000USD if DutyType=="AHS", by(TariffYear)
*renombrar las variables para distinguir exportaciones
rename MinimumRate X_MinimumRate
rename MaximumRate X_MaximumRate
rename ImportsValuein1000USD X_ImportsValuein1000USD
rename SimpleAverage X_SimpleAverage
rename StandardDeviation X_StandardDeviation

*uniendo las bases de impo + expo
merge 1:1  TariffYear using "C:\Users\Lori\Desktop\work_dianatorres\basem1"
drop _merge
*poniendo a dos decimales todo
format X_MinimumRate X_MaximumRate X_ImportsValuein1000USD X_SimpleAverage X_StandardDeviation %9.2f 
format M_MinimumRate M_MaximumRate M_ImportsValuein1000USD M_SimpleAverage M_StandardDeviation %9.2f
*aunque le cambie el formato, la base se descarga sin considerar los dos decimales
*exportando la base a excel
export excel "C:\Users\Lori\Desktop\work_dianatorres\unionfinalt2.xlsx", firstrow(variables)





















