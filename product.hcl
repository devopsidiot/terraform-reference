locals {
  #Allowed characters include "a-z", "0-9", and "-" (hyphen). 
  product_name = "DevopsIdiot" #FixMeFirst #no_environment_names

  tags = {
    Application  = "DevopsIdiot" #FixMeFirst
    Team         = "DevOps"      #FixMeFirst
    BusinessUnit = "Engineering" #FixMeFirst
    Terraform    = true
  }
}
