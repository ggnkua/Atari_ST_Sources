#include <tos.h>
#include <stdio.h>
struct Cookie 
{
union {
       char name[4];
       long emptyfl;
      } id;
long setting;
} *jar;

int main(void)
{
char *ssp;
 ssp = (char*)Super(0l);
 jar = *((struct Cookie **)0x5a0l);
 if (jar)        /* Jar vorhanden? */
   {  
 
   while (jar->id.emptyfl) 

     {
     printf("\n'%s' = $%lx",
            jar->id.name,jar->setting);
     jar++; /* n„chster Eintrag */
     }

   }
   Super(ssp);
   Crawcin();
   return 0;

}

