#/bin/bash
set -euo pipefail
IFS=$'\n\t'

#---------------------------------------------------------------
# edu_deploy.sh
# Author: Kellyn Gorman
# Deploys EDU Solution via Azure CLI to Azure
# Initial Script- 10/09/2018
#---------------------------------------------------------------
# -e: immediately exit if anything is missing
# -o: prevents masked errors
# IFS: deters from bugs, looping arrays or arguments (e.g. $@)
#---------------------------------------------------------------

usage() { echo "Usage: $0 -i <subscriptionID> -g <groupname> -p <password> -pp <proxypassword> -s <servername> -l <zone>" 1>&2; exit 1; }

declare subscriptionID=""
declare groupname=""
declare password=""
declare proxypassword=""
declare servername=""
declare zone=""

# Initialize parameters specified from command line
while getopts ":i:g:p:pp:s:l:" arg; do
	case "${arg}" in
		i)
			subscriptionID=${OPTARG}
			;;
		g)
			groupname=${OPTARG}
			;;
		p)
			password=${OPTARG}
			;;
		pp)
			proxypassword=${OPTARG}
			;;
		s)
			servername=${OPTARG}
			;;
		l)
			zone=${OPTARG}
			;;
		esac
done
shift $((OPTIND-1))

#template Files to be used
templateFile1="template1.json"

if [ ! -f "$templateFile1" ]; then
        echo "$templateFile1 not found"
        exit 1
fi

templateFile2="template2.json"

if [ ! -f "$templateFile2" ]; then
        echo "$templateFile2 not found"
        exit 1
fi

#parameter files to be used
parametersFile1="parameters1.json"

if [ ! -f "$parametersFile1" ]; then
        echo "$parametersFile1 not found"
        exit 1
fi

parametersFile2="parameters2.json"

if [ ! -f "$parametersFile2" ]; then
        echo "$parametersFile2 not found"
        exit 1
fi

#Prompt for parameters is some required parameters are missing
#login to azure using your credentials

echo "Here is your Subscription ID Information"
az account show | grep id

if [[ -z "$subscriptionID" ]]; then
	echo "Copy and Paste the Subscription ID from above, without the quotes to be used:"
	read subscriptionID
	[[ "${subscriptionID:?}" ]]
fi

if [[ -z "$groupname" ]]; then
	echo "What is the name for the resource group to create the deployment in? Example: EDU_Group "
	echo "Enter your Resource Group name:"
	read groupname
	[[ "${groupname:?}" ]]
fi

if [[ -z "$password" ]]; then
	echo "Your database login will be sqladmin and you'll need a password for this login?"
        echo "Password must meet requirements for sql server, including capilatization, special characters.  Example: SQLAdm1nt3st1ng!"
	echo "Enter the login password "
	read password
	[[ "${password:?}" ]]
fi

if [[ -z "$proxypassword" ]]; then
        echo "This password is for the proxy user that will work wtih the objects in the databsaes. Special characters can cause issues, use only number and letters for this password.  Example: SQLAdm1nt3st1ng"
	echo "Enter a password for your database proxy login:"
	read proxypassword
	[[ "${proxypassword:?}" ]]
fi

if [[ -z "$servername" ]]; then
	echo "What would you like for the name of the server that will house your sql databases? Example hiededusql1 "
	echo "Enter the server name:"
	read servername
	[[ "${servername:?}" ]]
fi

if [[ -z "$zone" ]]; then
	echo "Finally, what will be the Azure location zone to create everything in? Example eastus or centralus "
	echo "Enter the location name:"
	read zone
	[[ "${zone:?}" ]]
fi

# The ip address range that you want to allow to access your DB. 
# This rule is used by Visual Studio and SSMS to access and load data.  The firewall is dynamically offered for the workstation, but not for the Azure Cloud Shell.
# Added dynamic pull for IP Address for firewall rule 10/23/2018, KGorman
# Added a logfile and a static sqladmin for the database login.

echo "getting IP Address for Azure Cloud Shell for firewall rule"
export myip=$(curl http://ifconfig.me)
export startip=$myip
export endip=$myip
export adminlogin=sqladmin

#---------------------------------------------------------------
# Customers should only update the variables in the top of the script, nothing below this line.
#---------------------------------------------------------------

# Set default subscription ID if not already set by customer.
# Created on 10/14/2018
az account set --subscription $subscriptionID
 
# Create a resource group
az group create \
	--name $groupname \
	--location $zone

# Create a logical server in the resource group
az sql server create \
	--name $servername \
	--resource-group $groupname \
	--location $zone  \
	--admin-user $adminlogin \
	--admin-password $password


# Configure a firewall rule for the server
az sql server firewall-rule create \
	--resource-group $groupname \
	--server $servername \
	-n AllowYourIp \
	--start-ip-address $startip \
	--end-ip-address $endip

az configure --defaults sql-server=$servername
# Create a database for the staging database
az sql db create \
	--resource-group $groupname \
	--name HiEd_Staging \
        --service-objective S0 \
        --capacity 10 \
	--zone-redundant false 

# Create a database  for the data warehouse
az sql db create \
        --resource-group $groupname \
        --name HiEd_DW \
        --service-objective S0 \
        --capacity 10 \
        --zone-redundant false 


# Deploy Azure Analysis Server and ADF
# Added 10/16/2018
# Start deployment
(
        set -x
        az group deployment create --resource-group "$groupname" --template-file "$templateFile1" --parameters "@${parametersFile1}"
)

if [ $?  == 0 ];
 then
        echo "Azure Data Factory has been successfully deployed"
fi
 
echo "You will be requested for the Azure administrator for the Analysis server: Example-  kegorman@microsoft.com"

(
        set -x
        az group deployment create --resource-group "$groupname" --template-file "$templateFile2" --parameters "@${parametersFile2}"
)

if [ $?  == 0 ];
 then
        echo "Azure Analysis Server has been successfully deployed"
fi

echo "This Completes Part I, the physical resources deployment, Part II will now begin."

# Populate Database Objects
# Added 10/23/18, KGorman
# Added proxy login to support scripts and added check log for post deploy. 10/25/2018
# DataWarehouse
echo "Part II logs into the SQL Server and deploys the logical objects and support structures."
sqlcmd -U $adminlogin -S"${servername}.database.windows.net" -P "$password" -d master -Q "CREATE LOGIN HigherEDProxyUser WITH PASSWORD = '${proxypassword}'; "

sqlcmd -U $adminlogin -S "${servername}.database.windows.net" -P "$password" -d HiEd_DW -i "edu_hied_DW.sql"

# DataStaging
sqlcmd -U $adminlogin -S "${servername}.database.windows.net" -P "$password" -d HiEd_Staging -i "edu_hied_staging.sql"

echo "This is your Admin User,Password and Proxy Password:"  > edu_deploy.txt
echo $adminlogin $password $proxypassword >> edu_deploy.txt
echo "This is your Azure location zone:" $zone >> edu_deploy.txt
echo "This is the SQL Server your created for the databases:" >> edu_deploy.txt
echo $servername >> edu_deploy.txt
echo "This is the subscription deployed to and the Firewall IP:" >> edu_deploy.txt
echo $subscriptionID $myip >> edu_deploy.txt
echo "------------------------------------------------------------------------------------------------------------"
# Check for data and push to output file
sqlcmd -U $adminlogin -S "${servername}.database.windows.net" -P "$password" -d HiEd_Staging -i "ck_views.sql" > $logfile

echo "Part II is now complete."
