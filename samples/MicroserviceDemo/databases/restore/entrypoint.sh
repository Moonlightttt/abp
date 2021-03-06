#!/bin/bash

set -e
mkdir -p /var/opt/mssql/backup
mv /src/MsDemo_Identity.bak /var/opt/mssql/backup
mv /src/MsDemo_ProductManagement.bak /var/opt/mssql/backup

until /opt/mssql-tools/bin/sqlcmd -S sqlserver -U SA -P $SA_PASSWORD -Q 'SELECT name FROM master.sys.databases'; do
>&2 echo "SQL Server is starting up"
sleep 1
done

/opt/mssql-tools/bin/sqlcmd \
   -S sqlserver -U SA -P $SA_PASSWORD \
   -Q 'RESTORE DATABASE MsDemo_Identity FROM DISK = "/var/opt/mssql/backup/MsDemo_Identity.bak" WITH REPLACE,
         MOVE "MsDemo_Identity" TO "/var/opt/mssql/data/MsDemo_Identity.mdf", 
         MOVE "MsDemo_Identity_log" TO "/var/opt/mssql/data/MsDemo_Identity_log.ldf"'

/opt/mssql-tools/bin/sqlcmd \
   -S sqlserver -U SA -P $SA_PASSWORD \
   -Q 'RESTORE DATABASE MsDemo_ProductManagement FROM DISK = "/var/opt/mssql/backup/MsDemo_ProductManagement.bak" WITH REPLACE,
         MOVE "MsDemo_ProductManagement" TO "/var/opt/mssql/data/MsDemo_ProductManagement.mdf", 
         MOVE "MsDemo_ProductManagement_log" TO "/var/opt/mssql/data/MsDemo_ProductManagement_log.ldf"'

/opt/mssql-tools/bin/sqlcmd \
   -S sqlserver -U SA -P $SA_PASSWORD \
   -d MsDemo_Identity \
   -Q 'UPDATE IdentityServerClientRedirectUris SET RedirectUri = "http://localhost:51512/signin-oidc" WHERE ClientId = "3C8A6051-2030-1977-707F-39ED0F2F4527"
       UPDATE IdentityServerClientRedirectUris SET RedirectUri = "http://localhost:51513/signin-oidc" WHERE ClientId = "D1190176-2529-D6AB-ED4C-39ED0F2F4557"
       UPDATE IdentityServerClientPostLogoutRedirectUris SET PostLogoutRedirectUri = "http://localhost:51512/signout-callback-oidc" WHERE ClientId = "3C8A6051-2030-1977-707F-39ED0F2F4527"
       UPDATE IdentityServerClientPostLogoutRedirectUris SET PostLogoutRedirectUri = "http://localhost:51513/signout-callback-oidc" WHERE ClientId = "D1190176-2529-D6AB-ED4C-39ED0F2F4557"'