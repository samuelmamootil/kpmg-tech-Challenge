output "azure_sql_connection_string" {
  description = "Connection string for the Azure SQL Database."
  value       = "jdbc:sqlserver://${azurerm_mssql_server.sql_server.fully_qualified_domain_name}:1433;database=${azurerm_mssql_database.sql_db.name};user=${azurerm_mssql_server.sql_server.administrator_login}@${azurerm_mssql_server.sql_server.name};password=${azurerm_mssql_server.sql_server.administrator_login_password};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
  sensitive   = true
}