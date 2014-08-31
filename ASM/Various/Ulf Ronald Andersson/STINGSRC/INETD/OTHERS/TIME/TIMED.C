

#include <aes.h>
#include <stdio.h>

#include "module.h"


ISM_SPECS * cdecl  module_init (ISM_PARA *data);
void  cdecl module_term (ISM_PARA *data);
void  cdecl module_user (ISM_PARA *data),  cdecl module_server (ISM_PARA *data);


ISM_SPECS  my_specs = {  (IND_FUNC) module_init,  (IND_FUNC) module_term,
                         (IND_FUNC) module_user,  (IND_FUNC) module_server,
                          NULL,  0,  ISM_UDP | ISM_TCP,  0,  "Time Server"
              };
