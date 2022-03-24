# README

This repo shows how to create Cloud Armor security policy rules

# Cloud Armor limitations

* It only supports External HTTP(S) Load balancers
* It does NOT support any Internal Load balancers
* It does NOT support RXLB (Regional External LB) which is based on Envoy

Reference:
https://github.com/hashicorp/terraform-provider-google/blob/main/examples/cloud-armor/main.tf

Rules Tuning:
https://cloud.google.com/armor/docs/rule-tuning

K8S Ingress with Cloud Armor
https://github.com/abdidarmawan007/k8s-ingress-gce-cloud-armor

# Cloud Armor vs the Firewall rule

* Cloud Armor's whitelist will be checked first, if it's denied, the result will be 403 access error
```
<!doctype html><meta charset="utf-8"><meta name=viewport content="width=device-width, initial-scale=1"><title>403</title>403 Forbidden
```

* The firewall in GCP network is not necessary, even when we don't have a firewall rule  
The LB will still be able to send the traffic to the backend VM

# Rules

Check `cloud-armor.tf` for all the standard rules

Reference: https://cloud.google.com/armor/docs/rule-tuning