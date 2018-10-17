#/bin/bash
set -euo pipefail
IFS=$'\n\t'

#---------------------------------------------------------------
# edu_deploy.sh
# Author: Kellyn Gorman
# Deploys EDU Solution via Azure CLI to Azure
#---------------------------------------------------------------
# -e: immediately exit if anything is missing
# -o: prevents masked errors
# IFS: deters from bugs, looping arrays or arguments (e.g. $@)
#---------------------------------------------------------------

usage() { echo "Usage: $0 -i <subscriptionID> -g <groupname> -u <adminlogin> -p <password> -s <servername> -l <zone>" 1>&2; exit 1; }

declare subscriptionID=""
declare groupname=""
declare adminlogin=""
declare password=""
declare servername=""
declare zone=""

# Initialize parameters specified from command line
while getopts ":i:g:u:p:s:l:" arg; do
        case "${arg}" in
                i)
                        subscriptionID=${OPTARG}
                        ;;
                g)
                        groupname=${OPTARG}
                        ;;
                u)
                        adminlogin=${OPTARG}
                        ;;
                p)
                        password=${OPTARG}
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

if [[ -z "$adminlogin" ]]; then
        echo "What name would you like for your Database admin login?  Example sqladmin "
        echo "Enter the login name "
        read adminlogin
        [[ "${adminlogin:?}" ]]
fi

if [[ -z "$password" ]]; then
        echo "Password must meet requirements for sql server, including capilatization, special characters.  Example: SQLAdm1nt3st1ng!"
        echo "Enter a password for your database admin login:"
        read password
fi

if [[ -z "$servername" ]]; then
        echo "What would you like for the name of the server that will house your sql databases? Example hiededusql1 "
        echo "Enter the server name:"
        read servername
fi

if [[ -z "$zone" ]]; then
        echo "Finally, what will be the Azure location zone to create everything in? Example eastus or centralus "
        echo "Enter the location name:"
        read zone
fi

# The ip address range that you want to allow to access your DB. This can be updated later on in the portal, so defaults can remain.
export startip=67.100.0.0
export endip=72.82.0.0

#---------------------------------------------------------------
# Customers should only update the variables in the top of the script, nothing below this line.
#---------------------------------------------------------------

# Set default subscription ID if not already set by customer.
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


#Deploy Azure Analysis Server and ADF
#Start deployment
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

echo "All resources should have been deployed successfully.  Check Resource Group in Azure Portal."