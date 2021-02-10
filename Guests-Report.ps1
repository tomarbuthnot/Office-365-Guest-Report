
<#

# Use this script completely at your own risk


# Get the Azure AD module and Connect to Azure AD if you haven't already

Install-Module AzureAD -Repository PSGallery


#>


#Connect to AzureAD
Connect-AzureAD

# Get all guests
$GuestUsers = Get-AzureADUser -Filter "UserType eq 'Guest'" -All $true


# Define a new object to gather output
$GuestUsersAndDomain =  @()


 $GuestUsers | ForEach-Object {
   
                        # Put all details into an object

                        
                        # Work out guest domain
                        $string = $($_.UserPrincipalName)
                        $split1 = $string -split '#EXT#'
                        $split2 = $split1[0] -split '_'                        
                        
                        $output = New-Object -TypeName PSobject 

                        $output | add-member NoteProperty "ObjectId" -value $($_.ObjectId)
                        $output | add-member NoteProperty "DisplayName" -value $($_.DisplayName)
                        $output | add-member NoteProperty "GuestDomain" -value $split2[$split2.count-1].ToLower()
                        $output | add-member NoteProperty "UserPrincipalName" -value $($_.UserPrincipalName)

                        $GuestUsersAndDomain += $output
                        }
    

# Count the instances of a domain

$UniqueDomains = $GuestUsersAndDomain | Select-Object -Property GuestDomain -Unique

# Define a new object to gather output
$UsersbyDomainCount =  @()

ForEach ($domain in $UniqueDomains) {

    # Write-host "Getting number of instances of $($domain.GuestDomain)"

    $MatchingUsers = $GuestUsersAndDomain | Where-Object {$_.GuestDomain -eq $($domain.guestdomain)}
                        
                        # $MatchingUsers
    
                        # Put all details into an object

                        $MatchingUsersCount = $MatchingUsers | Measure-Object | Select-Object Count
                    
                        
                        $output = New-Object -TypeName PSobject 
                        $output | add-member NoteProperty "GuestDomain" -value $($domain.guestdomain)
                        $output | add-member NoteProperty "GuestUserCount" -value $($MatchingUsersCount.Count)


                        $UsersbyDomainCount += $output
     }
    


#######################


Write-Host "Number of guest users:                $($GuestUsers.Count)"
Write-Host "Number of unique domians:             $($UniqueDomains.Count)"
Write-Host 
Write-Host "Unique Guests per domain:"
$UsersbyDomainCount | Sort-Object GuestUserCount -Descending | Format-Table

