/*            FORM.C V1.0, 18.9.1990            */
/* Autor: Grischa Ekart / (c) by Grischa Ekart  */

#include <stdio.h>
#include "gem_it.h"

int
form_value(int def_button, char *string, ...)
{
   va_list  arguments;
   char  buffer[256];

   va_start(arguments, char *);
   vsprintf(buffer, string, arguments);
   va_end(arguments);
   return(form_alert(def_button, buffer));
}
