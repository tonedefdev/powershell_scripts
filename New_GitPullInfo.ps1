$PullQuery = Get-Content -Path "C:\Temp\pull.txt"

if ($PullQuery -contains "Already up to date.") 
{
    Break

} else {

    $Array = @()
        
    for ($i = 0; $i -lt $PullQuery.Count; $i++)
    {
        if ($PullQuery[$i] -eq "Fast-forward")
        {

            $StepBack = $i - 1
            $Array += $PullQuery[$StepBack]
            $Array += ""
            $Range = ($i + 1)..$PullQuery.Count
            
            foreach ($i in $Range)
            {
                $Array += $PullQuery[$i]
            }
        }
    }

    $Array

}