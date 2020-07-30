/* ------------------------------------------------------------------------- */
/* ----- di_fly.h ----- the bindings --------------------------------------- */
/* ------------------------------------------------------------------------- */

#ifndef __AES__
#include <aes.h>
#endif

/* ------------------------------------------------------------------------- */

typedef struct
{
   unsigned int   version;
   struct
   {
      unsigned light : 1;  /* light version (read) */
      unsigned : 5;  /* reserved    */
      unsigned keys  : 1;  /* key handling      */
      unsigned edit  : 1;  /* extended editor   */
      unsigned redraw   : 1;  /* send redraw message  */
      unsigned flytyp   : 1;  /* solid/hollow fly  */
      unsigned fly   : 1;  /* flying on/off  */
      unsigned alert : 1;  /* Alerts/Errors on/off */
      unsigned v_mem  : 1; /* use virtual memory   */
      unsigned f_grow   : 1;  /* grow/shrink boxes */
      unsigned g_grow : 1;
      unsigned bypass : 1; /* ON/OFF highest prio  */
   } config;
   char  *vpath;        /* path for v-mem */
   void  cdecl (*di_fly)(OBJECT *tree);   /* fly routine    */
} LTMFLY;

/* ------------------------------------------------------------------------- */

long *get_cookie(long cookie);
void di_fly(OBJECT *tree);

/* ------------------------------------------------------------------------- */
