
resource "random_id" "instance_id" {
  byte_length = 4
}

# Configure the Google Cloud provider
provider "google" {
  # credentials = file(var.credentials_file_path)
  project     = var.project
  region      = var.region
  zone        = var.region_zone
}

# Set up a backend to be proxied to:
# A single instance in a pool running nginx with port 80 open will allow end to end network testing
resource "google_compute_instance" "cluster1" {
  name         = "armor-gce-${random_id.instance_id.hex}"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = var.network
    subnetwork = var.subnet
    # access_config {
    #   # Ephemeral IP
    # }
  }
  tags = ["web-server"]
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq nginx; sudo service nginx restart"
}

# resource "google_compute_firewall" "cluster1" {
#   name    = "armor-firewall"
#   network = var.network
#   # source_ranges = var.ip_white_list
#   # source_ranges = ["192.0.0.0/32"]
#   source_ranges = ["0.0.0.0/0"]
#   target_tags = ["web-server"]
#   allow {
#     protocol = "tcp"
#     ports    = ["80", "443"]
#   }
# }


resource "google_compute_firewall" "fw-healthcheck" {
  name          = "armor-firewall-hc"
  direction     = "INGRESS"
  network       = var.network
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
  target_tags = ["web-server"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_instance_group" "webservers" {
  name        = "instance-group-all"
  description = "An instance group for the single GCE instance"

  instances = [
    google_compute_instance.cluster1.self_link,
  ]

  named_port {
    name = "http"
    port = "80"
  }
}

resource "google_compute_target_pool" "example" {
  name = "armor-pool"

  instances = [
    google_compute_instance.cluster1.self_link,
  ]

  health_checks = [
    google_compute_http_health_check.health.name,
  ]
}

resource "google_compute_http_health_check" "health" {
  name               = "armor-healthcheck"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}

resource "google_compute_backend_service" "website" {
  name        = "armor-backend"
  description = "Our company website"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10
  enable_cdn  = false

  backend {
    group = google_compute_instance_group.webservers.self_link
  }

  security_policy = google_compute_security_policy.security-policy-1.self_link

  health_checks = [google_compute_http_health_check.health.self_link]
}


# Front end of the load balancer
resource "google_compute_global_forwarding_rule" "default" {
  name       = "armor-rule"
  target     = google_compute_target_http_proxy.default.self_link
  port_range = "80"
}

resource "google_compute_target_http_proxy" "default" {
  name    = "armor-proxy"
  url_map = google_compute_url_map.default.self_link
}

resource "google_compute_url_map" "default" {
  name            = "armor-url-map"
  default_service = google_compute_backend_service.website.self_link

  host_rule {
    hosts        = ["mysite.com"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.website.self_link

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.website.self_link
    }
  }
}

output "ip" {
  value = google_compute_global_forwarding_rule.default.ip_address
}