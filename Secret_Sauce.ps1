$loginURL = "https://lms.emtrain.com"
$ie = New-Object -ComObject InternetExplorer.Application
$ie.visible = $true
$ie.navigate($loginURL)
while ($ie.Busy -eq $true) {Start-Sleep -Seconds 1}

$timer = (Get-Date).AddHours(2)
$current = (Get-Date)

while ($current -le $timer)
{
    $clickFlip = $ie.Document.documentElement.getElementsByClassName("click_flip_element")

    if ($clickFlip)
    {
        $count = $clickFlip.length
        for ($i = 0; $i -lt $count; $i++)
        {
            Start-Sleep -Seconds 1
            $clickFlip[$i].click()
            Start-Sleep -Seconds 1
            $clickFlip[$i].click()       
        }
    }

    $clickFlip = $null

    $startButton = $ie.Document.documentElement.getElementsByClassName("button") | ? {$_.ID -eq "start_button"}

    if ($startButton)
    {
        $startButton.click()
        Start-Sleep -Seconds 1
        while ([bool]($ie.Document.documentElement.getElementsByClassName("quiz_button_v2 button")))
        {

            $slider = $ie.Document.documentElement.getElementsByClassName("ui-slider-range ui-widget-header ui-corner-all ui-slider-range-min")
            if ($slider)
            {
                $elements1 = $slider[0].outerHTML -replace ('0','65')
                $slider[0].outerHTML = $elements1

                $sliderButton = $ie.Document.documentElement.getElementsByClassName("ui-slider-handle ui-state-default ui-corner-all")
                $elements2 = $sliderButton[0].outerHTML -replace ('style="left: 0%;"','style="left: 65%;"')
                $sliderButton[0].outerHTML = $elements2
                $sliderButton[0].click()

                $submit = $ie.Document.documentElement.getElementsByClassName("button spectrum_next spectrum_disabled")
                $submit[0].className = "button spectrum_next"
                $submitButton = $ie.Document.documentElement.getElementsByClassName("button spectrum_next") | ? {$_.ID -eq "next_button_v2"}
                $submitButton[0].
                $submitButton[0].click()
            }

            Start-Sleep -Seconds 1
            $quiz = $ie.Document.documentElement.getElementsByClassName("quiz_button_v2 button")
            $count = $quiz.length
            for ($i = 0; $i -lt $count; $i++)
            {
                if ($quiz[$i].outerHtml -like "*true, true, this*")
                {
                    $quiz[$i].click()
                    Start-Sleep -Seconds 1
                    $next = $ie.Document.documentElement.getElementsByClassName("button") | ? {$_.ID -eq "next_button_v2"}
                    $next.click()
                }
            }
        }
    }

    ($ie.Document.documentElement.getElementsByClassName("create_tooltip") | ? {$_.ID -eq "forward_button"}).click()
    Start-Sleep -Seconds 3
}

 