sudo apt-get -y update
sudo apt-get -y install git
sudo apt-get -y install az
sudo apt-get install -y postgresql postgresql-contrib
mkdir q1
cd q1
git clone https://github.com/Xangliev/Devops-epam-app.git
cd Devops-epam-app/sql

# az login --service-principal -u $APPID --password $PASSWORD --tenant $TENANTID

# az account set --subscription $SUBSCRIPTIONID
# sh db_initialization.sh