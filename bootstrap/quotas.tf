resource "google_cloud_quotas_quota_preference" "cpu_regional" {

  parent   = "projects/${var.project_id}"
  service  = "compute.googleapis.com"
  quota_id = "CPUS-per-project-region"

  quota_config {
    preferred_value = 8
  }
  ignore_safety_checks = "QUOTA_DECREASE_PERCENTAGE_TOO_HIGH"
}

resource "google_cloud_quotas_quota_preference" "cpu_all_regions" {

  parent   = "projects/${var.project_id}"
  service  = "compute.googleapis.com"
  quota_id = "CPUS-ALL-REGIONS-per-project"

  quota_config {
    preferred_value = 8
  }
  ignore_safety_checks = "QUOTA_DECREASE_PERCENTAGE_TOO_HIGH"
}

resource "google_cloud_quotas_quota_preference" "reservations_regional" {

  parent   = "projects/${var.project_id}"
  service  = "compute.googleapis.com"
  quota_id = "RESERVATIONS-per-project-region"

  quota_config {
    preferred_value = 0
  }
  ignore_safety_checks = "QUOTA_DECREASE_PERCENTAGE_TOO_HIGH"
}

resource "google_cloud_quotas_quota_preference" "persistent_disk_regional" {

  parent   = "projects/${var.project_id}"
  service  = "compute.googleapis.com"
  quota_id = "DISKS-TOTAL-GB-per-project-region"

  quota_config {
    preferred_value = 200
  }
  ignore_safety_checks = "QUOTA_DECREASE_PERCENTAGE_TOO_HIGH"
}

resource "google_cloud_quotas_quota_preference" "gpu_all_regions" {

  parent   = "projects/${var.project_id}"
  service  = "compute.googleapis.com"
  quota_id = "GPUS-ALL-REGIONS-per-project"

  quota_config {
    preferred_value = 0
  }
  ignore_safety_checks = "QUOTA_DECREASE_PERCENTAGE_TOO_HIGH"
}
