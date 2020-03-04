$mesoDN = "CN=Microsoft Exchange System Objects,DC=labspace,DC=com"

$mesoContainer = [ADSI]("LDAP://" + $mesoDN)
$sysMbxFinder = new-object System.DirectoryServices.DirectorySearcher
$sysMbxFinder.SearchRoot = $mesoContainer
$sysMbxFinder.PageSize = 1000
$sysMbxFinder.Filter = "(cn=SystemMailbox*)"
$sysMbxFinder.SearchScope = "OneLevel"

$sysMbxResults = $sysMbxFinder.FindAll()
"Found " + $sysMbxResults.Count + " System Mailboxes. Checking GUIDs..."

$report = @()
foreach ($result in $sysMbxResults)
{
	$cn = $result.Properties.cn[0]
	$guidStartIndex = $cn.IndexOf("{")
	$guidString = $cn.Substring($guidStartIndex + 1).TrimEnd("}")
	$guidEntry = [ADSI]("LDAP://<GUID=" + $guidString + ">")
	if (-not $guidEntry.distinguishedName)
	{
		$report += ("Guid does not resolve: " + $cn)
	}
}
$report