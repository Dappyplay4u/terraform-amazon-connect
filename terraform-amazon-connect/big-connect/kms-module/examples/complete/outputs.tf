###############################################################################
# KMS Complete Example — Outputs
###############################################################################

output "key_arns" {
  description = "Map of key purpose → KMS Key ARN"
  value       = module.kms.key_arns
  sensitive   = true
}

output "alias_names" {
  description = "Map of key purpose → KMS Alias name"
  value       = module.kms.alias_names
}

output "name_prefix" {
  description = "Resolved name prefix used by the module"
  value       = module.kms.name_prefix
}
