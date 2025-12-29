#include <TOS.H>

#ifndef BOOLE
 #define BOOLE
 typedef enum               /* Boole'sche Variablen */
 {
    FALSE,
    TRUE
 }
 boolean;
#endif
   
typedef struct
{
   long cookie_id;            /* Cookie-ID   */
   long cookie_value;         /* Cookie-Wert */
} COOKIE;

boolean getcookie(long cookie, long *p_value)
{
   /*  Cookie auslesen                          */
   /*  ---------------                          */
   /*  cookie          Kennung                  */
   /*  p_value         Wert programmabh„ngig    */
   /*  max_cookies     Anzahl m”glicher Cookies */
	
	register long usp;
   COOKIE *cookiejar;

   usp = Super(0L);
   cookiejar = (COOKIE *) *((long *) 0x5a0L);
   Super( (void *) usp);
	
   if (cookiejar == 0L)
      return FALSE;
   else
   {
	   do                                     /* Cookie-Suchschleife  */
      {
         if (cookiejar->cookie_id == cookie)
         {
            if (p_value) /* nur wenn kein Nullpointer */
            	*p_value = cookiejar->cookie_value;
            return TRUE;
         }
      }
      while (cookiejar++->cookie_id != 0);
   }
   return FALSE;
}
/* ----------------- */
