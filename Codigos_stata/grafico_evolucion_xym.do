*******************************************************************************
***********************Graficando la evolución tarifa importación Perú-MUNDO:
*******************************************************************************

clear
import excel "C:\Users\Dianita\Desktop\Trade\Datos\base_impo.xlsx", sheet("base_stata") firstrow
collapse (mean) SimpleAverage StandardDeviation MinimumRate MaximumRate , by(TariffYear)
format TariffYear %ty
tsset TariffYear
tsline SimpleAverage
tsline SimpleAverage StandardDeviation 
tsline SimpleAverage MinimumRate MaximumRate, xtitle(Years) title(Evolución del Arancel de importación Perú-MUNDO) legend(order(1 "AVERAGE" 2 "MIN" 3 "MAX"))
graph save evolucion1

graph export "C:\Users\Dianita\Desktop\Trade\Datos\evolucion1.png"

*Una tabla columnas: País, Importvalue, Participación del Flujo 
clear
import excel "C:\Users\Administrador\Desktop\DataJobID-2059515_2059515_tariffimpo.xlsx", sheet("base_stata") firstrow
collapse ImportsValuein1000USD if ProductName=="Total Trade" , by(PartnerName)

gsort -ImportsValuein1000USD
count 
generate FlowShare=_n 
list PartnerName ImportsValuein1000USD FlowShare if (FlowShare<=10)
