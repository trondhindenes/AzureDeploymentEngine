# Azure Deployment Engine #

Azure Deployment Engine (or AZdE) is a PowerShell module for automating the deployment of complex, multi-VM systems in Microsoft Azure in a flexible way.

It was written by Trond Hindenes, who shamelessly borrowed some code written by Aleksandar Nikolic (basically all the difficult things were written by Aleksandar).

### What it does ###

* Construct a deployment using PowerShell functions or by editing json
* Import/Export to Json
* Deploy one or multiple VMs
* Auto-deployment of domain controller VM
* Run post-deployment scripts on one or several VMs to perform app installs
* Copy files between local computer and Azure VMs using blob storage

### More info

Head over to the wiki page at https://github.com/trondhindenes/AzureDeploymentEngine/wiki for tons of info and docs and stuff.