#
Import-Module ActiveDirectory

#
Push-Location (Split-Path ($MyInvocation.MyCommand.Path))

#
$ou = "OU=RedTape users,DC=redtape,DC=local" # Which OU to create the user in
#$initialPassword = "bSM*8aJ-MqTLs5*L"       # Initial password set for the user
$orgShortName = "redtape"                     # This is used to build a user's sAMAccountName
$dnsDomain = "redtape.local"              # Domain is used for e-mail address and UPN
$company = "RedTape inc test user"            # Used for the user object's company attribute

# Other parameters
$userCount = 10000                             # How many users to create

# Files used
$firstNameFile = "Firstnames.txt"           # Format: fornamn
$lastNameFile  = "Lastnames.txt"            # Format: efternamn
$initials      = "Initials.txt"             # Format: Initals
$streetFile    = "streets.txt"              # Format: gatunamn
$addressFile   = "Addresses.txt"            # Format: stad, kommun

# Read input files
$fornamn   = Import-CSV $firstNameFile -Encoding utf7
$efternamn = Import-CSV $lastNameFile  -Encoding utf7
$initial   = Import-CSV $initials      -Encoding utf7
$gatunamn  = Import-CSV $streetFile    -Encoding utf7
$stad      = Import-CSV $addressFile   -Encoding utf7

# Preparation
$securePassword = ConvertTo-SecureString -AsPlainText "bSM*8aJ-MqTLs5*L" -Force

# Create (and overwrite) new array lists [0]
$CSV_Fname  = New-Object System.Collections.ArrayList
$CSV_Lname  = New-Object System.Collections.ArrayList
$CSV_Init   = New-Object System.Collections.ArrayList
$CSV_gata   = New-Object System.Collections.ArrayList
$CSV_adress = New-Object System.Collections.ArrayList

#Populate entire $firstNames and $lastNames into the array
$CSV_Fname.Add($fornamn)
$CSV_Lname.Add($efternamn)
$CSV_Init.Add($Initial)
$CSV_gata.Add($gatunamn)
$CSV_adress.Add($stad)

For ($i=1; $i -le $userCount; $i++) #Create only one user until it works.
{

   $Fname  = ($CSV_Fname  | Get-Random).fornamn
   $Lname  = ($CSV_Lname  | Get-Random).efternamn
   $Init   = ($CSV_Init   | Get-Random).initials

   $locationIndex = Get-Random -Minimum 0 -Maximum $stad.Count
   $ort = $stad[$locationIndex].stad
   $kom = $stad[$locationIndex].kommun + " kommun"
   

   $employeeNumber = Get-Random -Minimum 1000 -Maximum 9999
   $sAMAccountName = ($Fname.Substring(0,3) + $employeeNumber + $Lname.Substring(0,3)).ToLower()
   $acc = $sAMAccountName.replace("ö", "o")
   $acc = $acc.replace("å", "a")
   $acc = $acc.replace("ä", "a")

   $gatuadress = (($CSV_gata   | Get-Random).gatunamn) + " " + (Get-Random -Minimum 1 -Maximum 40)
   $displayName = (Get-Culture).TextInfo.ToTitleCase($Fname + " " + $Lname)
   $email = "$Fname.$init.$Lname@$dnsDomain".ToLower()
   $upn = "$sAMAccountName@$dnsDomain".ToLower()

   New-ADUser -SamAccountName $acc -Name $displayName -Path $ou -AccountPassword $securePassword -Enabled $true -GivenName $Fname -Initials $init -Surname $Lname -DisplayName $displayName -EmailAddress $email -StreetAddress $gatuadress -City $ort -State $kom -Country "SE" -UserPrincipalName $upn -Company $company
   write-host $acc, $displayName, $gatuadress, $ort, $kom
   #start-sleep 1
   }

#New-ADUser -SamAccountName $sAMAccountName -Name $displayName -Path $ou -AccountPassword $securePassword -Enabled $true -GivenName $Fname -Surname $Lname -DisplayName $displayName -EmailAddress "$Fname.$Lname@$dnsDomain" -StreetAddress $street -City $city -PostalCode $postalCode -State $state -Country $country -UserPrincipalName "$sAMAccountName@$dnsDomain" -Company $company -Department $department -EmployeeNumber $employeeNumber -Title $title -OfficePhone $officePhone