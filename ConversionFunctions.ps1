Function ConvertToMeters($feet)
{
    "$feet equals $($feet*.31) meters"
} #end ConvertToMeters

Function ConvertToFeet($meters)
{
    "$meters meters equals $($meters * 3.28) feet"
} #end ConvertToFeet

Function ConvertToFahrenheit($celsius)
{
    "$celsius celsius equals $((1.8 * $celsius) + 32 ) fahrenheit"
} #end ConvertToFahrenheit

Function ConvertToCelsius($fahrenheit) 
{
    "$fahrenheit fahrenheit equals $( (($fahrenheit -32)/9)*5) celsius"
} #end ConverToCelsius

Function ConvertToMiles($kilometer)
{
    "$kilometer kilometers equals $( ($kilometer * .6211) ) miles"
} #end ConvertToMiles

Function ConvertToKilometers($miles)
{
    "$miles miles equals $( ($miles * 1.61) ) kilometers"
} #end ConvertToKilometers