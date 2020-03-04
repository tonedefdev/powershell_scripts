. "C:\users\admin.aowens\Desktop\Employee_Class.ps1"

$Employee = [Employee]::New()
$Employee.EmploymentType = "ARE-Permanent"
$Employee.FirstName = "Robert"
$Employee.LastName = "Hope"
$Employee.PreferredName = "Bob"
$Employee.Title = "Automation Agent"
$Employee.Office = "Pasadena"
$Employee.TelephoneNumber = "818.854.8888"
$Employee.MobileNumber = "818.854.7777"
$Employee.EmailAddress = "bhope@are.com"
$Employee.StreetAddress = "385 E. Colorado Blvd. Suite 299"
$Employee.City = "Pasadena"
$Employee.State = "CA"
$Employee.ZipCode = "91101"
$Employee.Department = "Information Technology"
$Employee.Company = "Alexandria Real Estate Equities, Inc."
$Employee.Manager = "Tony Owens"

$Employee.CreatePermUser()