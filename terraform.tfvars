azsubscriptionid = "XXXXXXXXXXXXXXXXXXXX" // Out your own SUbscription

project = "mre-az"
TAG = "nocsoc"

ResourceGroup= "cloudteam_mremini_spokes"
VNET= "mre_az_nocsoc_useast"

username = "XXXXXX"
password =  "XXXXXX"

//-------------------------------------------------FMG----------------------------------------

fmg_vmsize= "Standard_D4s_v3"

fmg1ip =    [ "10.62.0.10"
        ]

fmg2ip =    [ "10.62.0.11"            
        ]

fmg1subnets=["mre_aznocsoc_useast_sub1"
        ] 
fmg2subnets= [ "mre_aznocsoc_useast_sub1"
        
        ]

FMG_IMAGE_SKU= "fortinet-fortimanager"
FMG_PRODUCT = "fortinet-fortimanager"
FMG_VERSION = "6.4.2"

//-------------------------------------------------FAZ----------------------------------------

faz_vmsize= "Standard_D4s_v3"

faz1ip =    [ "10.62.1.10"
         ]
          
faz2ip =    [ "10.62.1.11"            
         ]        
FAZ_IMAGE_SKU= "fortinet-fortianalyzer"
FAZ_PRODUCT =  "fortinet-fortianalyzer"
FAZ_VERSION = "6.4.2"


faz1subnets=["mre_aznocsoc_useast_sub2"
        ] 
faz2subnets= [ "mre_aznocsoc_useast_sub2"
        
        ]

//-------------------------------------------------------------------------------------------




