# Multi-tenant VNET peering

In order to do VNET peering between different AD tenant IDs, you must first setup the service principal that is used by 
Terraform correctly. This example uses a single service principal located in tenant 1. This service principal is given
permission to perform actions on tenant 2.

## Setup service principal

### Tenant 1 - Create service principal

1. Go to "App Registrations" and select "New Registration"
2. Give a descriptive name like "terraform-sp"
3. Select "Accounts in any organizational directory (Any Azure AD directory - Multitenant)"
4. For the Redirect URI set "https://www.microsoft.com"
5. Copy the Client ID for later use
6. Go to "Certificates & secrets" and create a new client secret. Copy this value down as it will obfuscate when you leave this page

### Tenant 2 - Allow access to service principal

You need to allow the service principal in tenant 1 access to resoruces in tenant 2. This can be done at the resoruce group
level or at the subscription level. This example is at the subscription level. 

1. In a new private browser window (because of cookies and current login status), open the following URL filling in the pieces

 `https://login.microsoftonline.com/<Tenant 2 ID>/oauth2/authorize?client_id=<Application (client) ID>&response_type=code&redirect_uri=https%3A%2F%2Fwww.microsoft.com%2F`

You will be asked to authorize this application on behalf of your organization

3. Open up the IAM for the subscriptoion (or resoruce group) in tenant 2
    Add role - add the tenant 1 service principal (which should now be available in tenant 2) with the contributer role for the subscription or resource group

At this point, you should be all set with permissions to access and create resoruces in tenant 2 with the tenant 1 service principal. You will still need to setup provider aliases
as described below.

## Terraform

The key to make this work is to use the service principal for tenant 1 to deploy and manage resoruces for both tenant 1 and tenant 2. This will still require that you have 
seperate provider blocks for each tenant, utilizing the 'alias' attribute to allow you to call on each individually. 

Each Terraform provider block will need to specify the 'auxiliary_tenant_ids' attribute. This is the tenant ID of the ***OTHER*** tenant. This is key.

Here is an example provider block for tenant 1:

>provider "azurerm" {   
  alias           = "tenant1"  
  version         = "=1.44.0"  
  subscription_id = "${var.tenant_1_subscription_id}"  
  tenant_id       = "${var.tenant_id_1}"  
  client_id       = "${var.client_id_1}"  
  client_secret   = "${var.secret_1}"  
  auxiliary_tenant_ids = ["${var.tenant_id_2}"]  
}  

Here is an example provider block for tenant 2:

>provider "azurerm" {  
  alias           = "tenant2"  
  version         = "=1.44.0"  
  subscription_id = "${var.tenant_2_subscription_id}"  
  tenant_id       = "${var.tenant_id_2}"  
  client_id       = "${var.client_id_1}"  
  client_secret   = "${var.secret_1}"  
  auxiliary_tenant_ids = ["${var.tenant_id_1}"]  
}  

Notice that the 'auxiliary_tenant_ids' attribute has a list in which only the ***other*** tenant ID is listed. This will allow for additional mulit-tenancy if you like that kind of thing. :)


In terraform, be sure to use the 'auxiliary_tenant_ids' attribute for the providers. The auxiliary_tenant_ids is for the OTHER tenants that the provider will need to access. 

keep in mind that if you are not using multiple tenants, you cannot use the auxiliary_tenant_ids attribute as it will fail.

**You will use tenant 1's serviceprincipal to perform the peerings in both tenants.**

# Authors
Module is maintained by Nathan Farrar
