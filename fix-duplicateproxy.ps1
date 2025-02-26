# Import Active Directory module (if not already loaded)
Import-Module ActiveDirectory

# Define users and the target OU
$Users = @(
    "Karthik Rajan",
    "Manikonda Jeswanth",
    "Suneel Mekala",
    "Sunil Thomas",
    "Nidhi Sanjay Gupta",
    "Roshani Rajput",
    "Amit Jaiswal",
    "Sammeta Sridhar",
    "Ankit Sanodia",
    "Vivek Kumar Sahu",
    "Chander Parkash",
    "Gourav Raj",
    "Sandeep Singh",
    "Jayalakshmi S",
    "Kishor Chavan"
)

# Specify the target OU where users will be moved
$TargetOU = "OU=TemporaryOU,DC=yourdomain,DC=com"

# Create a hash table to store original OUs
$OriginalOUs = @{}

# Move users to the target OU and store their original OUs
foreach ($User in $Users) {
    $ADUser = Get-ADUser -Filter {Name -eq $User} -Properties DistinguishedName
    if ($ADUser) {
        $OriginalOUs[$User] = ($ADUser.DistinguishedName -replace '^CN=.*?,', '')  # Extract the original OU
        Write-Output "Moving $User to $TargetOU"
        Move-ADObject -Identity $ADUser.DistinguishedName -TargetPath $TargetOU
    } else {
        Write-Output "User $User not found in AD."
    }
}

# Wait for 30 minutes
Write-Output "Waiting for 30 minutes before moving users back..."
Start-Sleep -Seconds 1800

# Move users back to their original OUs
foreach ($User in $Users) {
    if ($OriginalOUs.ContainsKey($User)) {
        $ADUser = Get-ADUser -Filter {Name -eq $User} -Properties DistinguishedName
        if ($ADUser) {
            Write-Output "Moving $User back to $($OriginalOUs[$User])"
            Move-ADObject -Identity $ADUser.DistinguishedName -TargetPath $OriginalOUs[$User]
        } else {
            Write-Output "User $User not found when trying to move back."
        }
    }
}

Write-Output "Script execution completed."
