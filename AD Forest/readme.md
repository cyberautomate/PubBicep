## Single VM Template using Modules

What you get.
1. Single Server 2020 VM
2. Single vNet
3. Single NSG with RDP open to the public IP address if the host that you ran the deploy.ps1 from.
4. The main.bicep deploys the core VM and links calls the other required resources by using modules all from the local disk. (See below)

**All of the modules are created in a manner that you should be able to reuse them for other deployments... that's kinda the point. If you see something I may have missed send me a PR or message me. :)**

- main.bicep
  - modules/domainSA.bicep
  - modules/nic.bicep
  - modules/nsg.bicep
  - modules/PIP.bicep
  - modules/vNet.bicep