output "mgmtPublicIP" {
  value = { for vm in keys(var.vms) : vm => module.bigip[vm].*.mgmtPublicIP }
}
output "bigip_username" {
  value = { for vm in keys(var.vms) : vm => module.bigip[vm].*.f5_username }
}
output "mgmtPort" {
  value = { for vm in keys(var.vms) : vm => module.bigip[vm].*.mgmtPort }
}
output "public_addresses" {
  value = { for vm in keys(var.vms) : vm => module.bigip[vm].*.public_addresses }
}
output "private_addresses" {
  value = { for vm in keys(var.vms) : vm => module.bigip[vm].*.private_addresses }
}
output "service_account" {
  value = { for vm in keys(var.vms) : vm => module.bigip[vm].*.service_account }
}
output "self_link" {
  value = { for vm in keys(var.vms) : vm => module.bigip[vm].*.self_link }            
}
output "name" {
  value = { for vm in keys(var.vms) : vm => module.bigip[vm].*.name }
}
output "zone" {
  value = { for vm in keys(var.vms) : vm => module.bigip[vm].*.zone }
}
output "bigip_instance_ids" {
  value = { for vm in keys(var.vms) : vm => module.bigip[vm].*.bigip_instance_ids }
}
output "f5-admin-password" {
  value = data.google_secret_manager_secret_version.admin-password.secret_data
  sensitive = true
}
