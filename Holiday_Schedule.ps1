$CalendarCheck = "I:\AREHolidays2019DoNotDelete.txt"
if (Test-Path -Path $CalendarCheck)
{
    Exit
} else {

    $olFolderCalender = 9
    $olAppointItem = 1
    $olOutOfOffice = 3
    $objOutlook = New-Object -ComObject "Outlook.Application"
    $objNamespace = $objOutlook.GetNamespace("MAPI")
    $objCalendar = $objNamespace.GetDefaultFolder($olFolderCalender)
    $objHash = @{
        "February 18, 2019" = "ARE Holiday - President's Day"
        "May 24, 2019" = "ARE Holiday - Memorial Day"
        "May 27, 2019" = "ARE Holiday - Memorial Day"
        "July 4, 2019"= "ARE Holiday - Independence Day"
        "August 30, 2019" = "ARE Holiday - Labor Day"
        "September 2, 2019" = "ARE Holiday - Labor Day"
        "November 11, 2019" = "ARE Holiday - Veteran's Day"
        "November 28, 2019" = "ARE Holiday - Thanksgiving Day"
        "November 29, 2019" = "ARE Holiday - Thanksgiving Day"
        "December 24, 2019" = "ARE Holiday - Christmas Eve"
        "December 25, 2019" = "ARE Holiday - Christmas Day"
        "January 1, 2020" = "ARE Holiday - New Year's Day (2020)"
    }

    foreach ($Item in $objHash.Keys)
    {       
        $dtmHolidayDate = $Item
        $strHolidayName = $objHash[$Item]
        $objHoliday = $objOutlook.CreateItem($olAppointItem)
        $objHoliday.Subject = $strHolidayName
        $objHoliday.Start = "$dtmHolidayDate 9:00AM"
        $objHoliday.End = "$dtmHolidayDate 10:00AM"
        $objHoliday.AllDayEvent = $true
        $objHoliday.ReminderSet = $false
        $objHoliday.BusyStatus = $olOutOfOffice
        $objHoliday.Save()
    }
    $objOutlook.Quit()

    New-Item -Path $CalendarCheck -ItemType File
}