#Variables
$TenantId 		        = "?GUID?"
$SubscriptionId 	    = "?GUID?"
$location 		        = "Central US"
$location2 		        = "East US 2"
$environment 		    = "hub"
$application 		    = "log"
$iteration              = ""
$application_owner 	    = "Mark Brendanawicz"
$deployment_source 	    = "PowerShell"
#Custom
$ExecutionAccount 	    = "xxxxx"
$ExecutionAccountId 	= "xxxxx"
$PurviewCollectionRef 	= "AdventureWorksLT"
$SQLServerLogin 	    = "SqlAdmin"
$SQLServerPassword 	    = "Change!Me@Now"
#

# Login
az login
Connect-AzAccount
Set-AzContext -SubscriptionId $SubscriptionId 

#Install Module
Install-Module Az.Purview
Install-Module Az.Sql
Install-Module AzureAD

#
# Tags
#
$tags = @{
    "environment"           = $environment;
    "application"           = $application;
    "iteration"             = $iteration;
    "location"              = $location; 
    "application_owner"     = $application_owner;
    "deployment_source"     = $deployment_source
    }

#
# RG
#
$rg = New-AzResourceGroup `
        -Name "${environment}${application}${$iteration}-rg" `
        -Location $location `
        -Tag $tags

#New Pureview Account
#https://learn.microsoft.com/en-us/powershell/module/az.purview/new-azpurviewaccount?view=azps-10.1.0
$PurviewAccount = New-AzPurviewAccount `
    -ResourceGroupName $rg.ResourceGroupName `
    -Name "${environment}${application}${$iteration}-act" `
    -Location $location `
    -IdentityType SystemAssigned `
    -SkuCapacity 4 `
    -SkuName Standard `
    -Tag $tags

#New SQL Server
#https://learn.microsoft.com/en-us/powershell/module/az.sql/new-azsqlserver?view=azps-10.1.0
$SQLServer = New-AzSqlServer `
    -ResourceGroupName $rg.ResourceGroupName `
    -Location $location `
    -ServerName "${environment}${application}${$iteration}-sql-srv" `
    -ServerVersion "12.0" `
    -AssignIdentity `
    -ExternalAdminName $ExecutionAccount -EnableActiveDirectoryOnlyAuthentication `
    -Tag $tags
    #-SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SQLServerLogin, $(ConvertTo-SecureString -String $SQLServerPassword -AsPlainText -Force)) `


#SQL Server Firewall
New-AzSqlServerFirewallRule -ResourceGroupName $rg.ResourceGroupName `
    -ServerName "${environment}${application}${$iteration}-sql-srv" `
    -AllowAllAzureIPs

#New SQL DB
#https://learn.microsoft.com/en-us/powershell/module/az.sql/new-azsqldatabase?view=azps-10.1.0
$SQLDatabase = New-AzSqlDatabase `
    -ResourceGroupName $rg.ResourceGroupName `
    -ServerName "${environment}${application}${$iteration}-sql-srv" `
    -DatabaseName "${environment}${application}${$iteration}-sql-db0" `
    -Edition "Basic" `
    -SampleName "AdventureWorksLT" `
    -Tag $tags

#Add admin account with PowerShell
$Purview = Get-AzPurviewAccount -Name "${environment}${application}${$iteration}-act" -ResourceGroupName $rg.ResourceGroupName
Add-AzPurviewAccountRootCollectionAdmin -InputObject $Purview -ObjectId $ExecutionAccountId

# (Manual) Create collection
#Access purview portal, https://web.purview.azure.com/
#Create collection

#Grant MI RBAC
$spID = (Get-AzPurviewAccount -ResourceGroupName $rg.ResourceGroupName).identity.principalid
$GetSQLServerID = Get-AzSQLServer -ResourceGroupName $rg.ResourceGroupName
New-AzRoleAssignment -ObjectId $spID `
    -RoleDefinitionName "Reader" `
    -Scope $GetSQLServerID.ResourceID

#Add datasource
$SQLServerEndpoint = Get-AzSqlServer -ResourceGroupName $rg.ResourceGroupName -ServerName "${environment}${application}${$iteration}-sql-srv" | select FullyQualifiedDomainName
New-AzPurviewAzureSqlDatabaseDataSourceObject -Kind 'AzureSqlDatabase' `
    -CollectionReferenceName $PurviewCollectionRef `
    -CollectionType 'CollectionReference' `
    -ServerEndpoint $SQLServerEndpoint

#ScanObject1
New-AzPurviewAzureSqlDatabaseCredentialScanObject -Kind 'AzureSqlDatabaseCredential' `
    -CollectionReferenceName $PurviewCollectionRef `
    -CollectionType 'CollectionReference' `
    -CredentialReferenceName 'ServicePrincipal' `
    -CredentialType 'ServicePrincipal' `
    -DatabaseName "${environment}${application}${$iteration}-sql-db0" `
    -ScanRulesetName 'AzureSqlDatabase' `
    -ScanRulesetType 'System' `
    -ServerEndpoint $SQLServerEndpoint

#Scan (Used portal)
New-AzPurviewAzureSqlDatabaseScanRulesetObject -Kind 'AzureSqlDatabase' `
    -Description 'AdventureWorksLT' `
    -ExcludedSystemClassification @('MICROSOFT.FINANCIAL.CREDIT_CARD_NUMBER','MICROSOFT.SECURITY.COMMON_PASSWORDS') `
    -IncludedCustomClassificationRuleName @('ClassificationRule2') -Type 'Custom'

# SQL (Added in portal)
#
#CREATE USER "sbx-pur-act" FROM EXTERNAL PROVIDER
#GO
#
#EXEC sp_addrolemember 'db_datareader', [sbx-pur-act]
#GO
