#
#Env Variables
environment                    = "hub"         #Hub, Prd, Stg, Dev, Tst, Idp
application                    = "pur"         #net, app, ads
location                       = "centralus"   #Azure Location
iteration                      = ""            #Numeric
application_owner              = "Mark Brendanawicz"
deployment_source              = "terraform"
#
#Tags
default_tags =  {
        location               = "centralus"
        environment            = "hub"
        application            = "pur"
        application_owner      = "Mark Brendanawicz"
        iteration              = ""
        deployment_source      = "terraform"
        }
#
#Custom
sqllogin                       = "?dbaadminlogin?"
sqlpass                        = "?makeithardtoguess?"
sqladminlogin                  = "?azuread account?"
sqladminloginid                = "?azuread account?"
