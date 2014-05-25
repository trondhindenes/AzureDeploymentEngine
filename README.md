# Azure Deployment Engine #

Azure Deployment Engine (or AZdE) is a PowerShell module for automating the deployment of complex, multi-VM systems in Microsoft Azure.

### What it does ###

* Construct a deployment using PowerShell functions or by editing json
* Import/Export to Json
* Deploy one or multiple VMs
* Auto-deployment of domain controller VM
* Run post-deployment scripts on one or several VMs to perform app installs
* Copy files between local computer and Azure VMs using blob storage

### What it doesn't do (yet) ###

* Verify your inputs. Which may lead to errors while running the script, for instance if you specified an invalid cloudservice name
* Use paralellism. The script will deploy VMs, one at a time, and then run scripts also one at a time. 

