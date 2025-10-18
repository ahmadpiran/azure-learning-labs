# Lessons Learned - Phase 1

## Date: 10-18-2025

## Key Learnings 📚

### Terraform Specifics
1. **Dependencies**: Terraform figures out order automatically (mostly)
2. **Implicit vs Explicit**: Using `resource.attribute` creates implicit dependency
3. **File functions**: `file()` and `filebase64()` read files at plan time
4. **Path module**: `${path.module}` for relative paths
5. **Formatting**: `terraform fmt` should be run before every commit

### Azure Architecture
1. **Everything needs a resource group**: It's the top-level container
2. **VNet before subnet**: Network hierarchy matters
3. **Public IP is separate**: Not automatically created with VM
4. **NIC is the connection point**: Links VM to network
5. **NSG can attach to subnet OR NIC**: I chose NIC for granular control

### Cloud-Init
1. **Runs once**: Only on first boot of new VM
2. **Order matters**: `packages` → `write_files` → `runcmd`
3. **YAML is picky**: Indentation must be exact (2 spaces)
4. **Logs are my friend**: `/var/log/cloud-init-output.log` is invaluable
5. **Sleep helps**: Adding delays for disk detection prevented issues

### Linux Administration
1. **lsblk**: Best tool for viewing disk layout
2. **df -h**: Shows mounted filesystems and usage
3. **fstab**: Controls automatic mounting on boot
4. **UUID vs device name**: UUID is more reliable for fstab
5. **Ownership matters**: `chown` needed for user access to mounted disks


## Questions I Still Have ❓

1. When should I use remote state instead of local?
2. How do I handle secrets properly in Terraform?
3. What's the difference between Availability Sets and Zones?
4. When should I use VM Scale Sets vs individual VMs?
5. How do I implement proper backup strategies?

*These will be explored in future phases*

## Resources That Helped 📖

- Terraform Azure Provider Docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- Azure VM Documentation: https://learn.microsoft.com/en-us/azure/virtual-machines/
- Cloud-Init Documentation: https://cloudinit.readthedocs.io/
- Azure Pricing Calculator: https://azure.microsoft.com/en-us/pricing/calculator/

## Conclusion

Phase 1 was successful! I now have:
- ✅ Working Azure VM infrastructure
- ✅ Automated deployment with Terraform
- ✅ Automated configuration with cloud-init
- ✅ Persistent data storage
- ✅ Web server serving content
- ✅ Comprehensive documentation
- ✅ Good git history
- ✅ Understanding of foundational concepts

**Confidence level**: Ready for Phase 2! 💪