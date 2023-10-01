#Add admin account with PowerShell

$Purview = Get-AzPurviewAccount -Name sbx-pur-act -ResourceGroupName sbx-pur-rg
$ADObjectID = "?AzureADObjectID?"
$ServerEndPoint = "sbx-sql-srv.database.windows.net"
$Database = "AdventureWorksLT"

Add-AzPurviewAccountRootCollectionAdmin -InputObject $Purview -ObjectId $ADObjectID

#Add datasource (Added in portal)

New-AzPurviewSqlServerDatabaseDataSourceObject `
    -Kind 'SqlServerDatabase' `
    -CollectionReferenceName $Database `
    -CollectionType 'CollectionReference' `
    -ServerEndpoint $ServerEndPoint
