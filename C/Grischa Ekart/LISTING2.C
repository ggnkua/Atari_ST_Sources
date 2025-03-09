/************************************************/
/*            TOS_VER.C  von 14.11.1990         */
/*  (w) by Grischa Ekart  (c) MAXON Computer    */
/*  erstellt mit Turbo C V1.0 von BORLAND GmbH  */
/************************************************/
#include <tos.h>

/*             function prototypes              */

int   tos_version(void);

/*             function definitions             */

int
tos_version(void)
{
   void  *ssp;
   int   version;

   ssp = (void *)Super(0L);
   version = *(int *)(*((long *)0x4f2) + 2);
   Super(ssp);
   return(version);
}



