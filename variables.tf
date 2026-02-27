variable "threat_severity" {
  type        = string
  default     = "INFORMATIONAL"
  description = "Minimum threat severity for alerts. (INFORMATIONAL, LOW, MEDIUM, HIGH)"

  validation {
    condition     = contains(["INFORMATIONAL", "LOW", "MEDIUM", "HIGH"], var.threat_severity)
    error_message = "Threat severity must be one of: INFORMATIONAL, LOW, MEDIUM, HIGH."
  }
}

variable "alert_severities" {
  type        = list(string)
  default     = ["MEDIUM", "HIGH", "CRITICAL"]
  description = "List of alert severities to monitor. (INFORMATIONAL, LOW, MEDIUM, HIGH)"
}
