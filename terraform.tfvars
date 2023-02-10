prefix = "tf-gcp-bigip"
f5_ssh_publickey     = "~/.ssh/cactuslizard.pub"
f5_username = "admin"
gcp_secret_name = "cactuslizard-f5-password"
service_account = "154895444964-compute@developer.gserviceaccount.com"
project_id = "cactuslizard-361714"
region = "us-central1"
vms = {
    vm1 = {                                         
        machine_type   = "n1-standard-4"                                          
        zone = "us-central1-a"  
        image = "projects/f5-7626-networks-public/global/images/f5-bigip-16-1-3-1-0-0-11-byol-all-modules-2boot-loc-0721055536"           
    }
    vm2 = {                                         
        machine_type   = "n1-standard-4"                                          
        zone = "us-central1-b"
        image = "projects/f5-7626-networks-public/global/images/f5-bigip-16-1-3-1-0-0-11-byol-all-modules-2boot-loc-0721055536"               
    }
}