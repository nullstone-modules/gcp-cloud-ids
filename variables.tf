variable "threat_severity" {
  type        = string
  default     = "INFORMATIONAL"
  description = "Minimum threat severity for alerts. (INFORMATIONAL, LOW, MEDIUM, HIGH)"

  validation {
    condition     = contains(["INFORMATIONAL", "LOW", "MEDIUM", "HIGH"], var.threat_severity)
    error_message = "Threat severity must be one of: INFORMATIONAL, LOW, MEDIUM, HIGH."
  }
}
