# Set subscription
# subscriptionId="your subscription ID"
# az account set --subscription $subscriptionId

# Set resourcegroup and location
resourceGroupName=Flask-resourcegroup-epam-name-test
location=centralus

# Set an admin login and password for your database
adminlogin=SqlAdmin
password="ChangeYourAdminPassword1"

# The logical server name has to be unique in the system
servername=server-20075
DBURL="server-20075.postgres.database.azure.com"

# The ip address range that you want to allow to access your DB
startip=0.0.0.0
endip=0.0.0.0

# Set name of App Service Plan and Web App
planName=SampleAppServicePlanTest
webappname=Flask-EPAM-Test-App-Test

# Create a resource group
az group create --name $resourceGroupName --location $location

# Create load balancing app service plan
az appservice plan create -n $planName -g $resourceGroupName -l $location --is-linux --number-of-workers 2 --sku P1v2

# Create initial web app
az webapp create --name $webappname --resource-group $resourceGroupName --plan $planName --runtime "Python|3.7"

# Create a logical server in the resource group
az postgres server create --name $servername --resource-group $resourceGroupName --location $location --admin-user $adminlogin --admin-password $password --sku-name B_Gen5_1

# Configure a firewall rule for the server
az postgres server firewall-rule create --resource-group $resourceGroupName --server-name $servername --start-ip-address $startip --end-ip-address $endip --name allow-all-azure-ip

# Create new database and user credentials
PGPASSWORD=$password psql -h $DBURL -U $adminlogin@$servername --file='db.sql' postgres

# Connect to new database with user credentials and insert inital values
PGPASSWORD='Interforaewg098!' psql -h $DBURL -U 'api_db_user'@$servername -d 'api_db' --file='db1.sql'




