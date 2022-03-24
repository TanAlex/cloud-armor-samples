
# Cloud Armor Security policies
resource "google_compute_security_policy" "security-policy-1" {
  name        = "armor-security-policy"
  description = "Security policy with owasp-top-ten and whitelist IPs"

  rule {
    action   = "deny(403)"
    priority = "1500"
    match {
      expr {
        expression = <<EOF
        evaluatePreconfiguredExpr('xss-stable', ['owasp-crs-v030001-id941340-xss',
          'owasp-crs-v030001-id941130-xss',
          'owasp-crs-v030001-id941170-xss',
          'owasp-crs-v030001-id941330-xss',
        ]
        )
        EOF
      }
    }
    description = "Prevent cross site scripting attacks"
  }

  rule {
    action   = "deny(403)"
    priority = "2000"
    match {
      expr {
        expression = <<EOF
        evaluatePreconfiguredExpr('sqli-stable', ['owasp-crs-v030001-id942110-sqli',
          'owasp-crs-v030001-id942120-sqli',
          'owasp-crs-v030001-id942150-sqli',
          'owasp-crs-v030001-id942180-sqli',
          'owasp-crs-v030001-id942200-sqli',
          'owasp-crs-v030001-id942210-sqli',
          'owasp-crs-v030001-id942260-sqli',
          'owasp-crs-v030001-id942300-sqli',
          'owasp-crs-v030001-id942310-sqli',
          'owasp-crs-v030001-id942330-sqli',
          'owasp-crs-v030001-id942340-sqli',
          'owasp-crs-v030001-id942380-sqli',
          'owasp-crs-v030001-id942390-sqli',
          'owasp-crs-v030001-id942400-sqli',
          'owasp-crs-v030001-id942410-sqli',
          'owasp-crs-v030001-id942430-sqli',
          'owasp-crs-v030001-id942440-sqli',
          'owasp-crs-v030001-id942450-sqli',
          'owasp-crs-v030001-id942251-sqli',
          'owasp-crs-v030001-id942420-sqli',
          'owasp-crs-v030001-id942431-sqli',
          'owasp-crs-v030001-id942460-sqli',
          'owasp-crs-v030001-id942421-sqli',
          'owasp-crs-v030001-id942432-sqli',
          'owasp-crs-v030001-id942190-sqli']
        )
        EOF
      }
    }
    description = "Prevent sql injection attacks"
  }

  rule {
    action   = "deny(403)"
    priority = "3000"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('rce-stable') && evaluatePreconfiguredExpr('rfi-stable')"
      }
    }
    description = "Prevent remote code execution"
  }

  rule {
    action   = "deny(403)"
    priority = "3010"
    match {
      expr {
        expression = <<EOF
        evaluatePreconfiguredExpr('lfi-stable', ['owasp-crs-v030001-id930120-lfi']
        )
        EOF
      }
    }
    description = "Prevent Local file inclusion attacks"
  }

  rule {
    action   = "deny(403)"
    priority = "3030"
    match {
      expr {
        expression = <<EOF
        evaluatePreconfiguredExpr('methodenforcement-stable')
        EOF
      }
    }
    description = "Prevent method enforcement"
  }

  rule {
    action   = "deny(403)"
    priority = "3040"
    match {
      expr {
        expression = <<EOF
        evaluatePreconfiguredExpr('scannerdetection-stable',
        ['owasp-crs-v030001-id913101-scannerdetection',
        'owasp-crs-v030001-id913102-scannerdetection']
        )
        EOF
      }
    }
    description = "Scan Detection Stable rule"
  }

  rule {
    action   = "deny(403)"
    priority = "3050"
    match {
      expr {
        expression = <<EOF
        evaluatePreconfiguredExpr('protocolattack-stable',
        ['owasp-crs-v030001-id921151-protocolattack',
        'owasp-crs-v030001-id921170-protocolattack']
        )
        EOF
      }
    }
    description = "Protocol Attack Stable rule"
  }

  rule {
    action   = "deny(403)"
    priority = "3060"
    match {
      expr {
        expression = <<EOF
        evaluatePreconfiguredExpr('sessionfixation-stable')
        EOF
      }
    }
    description = "Session Fixation Stable rule"
  }

  rule {
    action   = "deny(403)"
    priority = "4000"
    match {
      expr {
        expression = <<EOF
        evaluatePreconfiguredExpr('cve-canary', ['owasp-crs-v030001-id244228-cve',
        'owasp-crs-v030001-id344228-cve'])
        EOF
      }
    }
    description = "Log4j and other CVE rule"
  }

  # Whitelist traffic from certain ip address
  rule {
    action   = "allow"
    priority = "1000"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = var.ip_white_list
        # src_ip_ranges = ["192.0.0.0/32"]
      }
    }

    description = "allow traffic from whitelist networks"
  }



  # Reject all traffic that hasn't been whitelisted.
  rule {
    action   = "deny(403)"
    priority = "2147483647"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = ["*"]
      }
    }

    description = "Default rule, higher priority overrides it"
  }
}