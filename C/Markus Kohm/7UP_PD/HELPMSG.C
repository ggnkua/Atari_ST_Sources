/*
   example to show the message pipe to TC_HELP accessory
   (c) 1990 by Borland International
*/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>

#include "7up.h"
#include "windows.h"
/*
#include "helpmsg.h"
*/
/*
    some macros for the message pipe to TC_HELP.ACC
    (c) 1990 by Borland International
*/

#define AC_HELP     1025            /* message to DA         */
#define AC_VERSION  1027            /* Ask DA for version    */
#define AC_COPY     1028            /* Ask DA to copy screen */
#define AC_REPLY    1026            /* message from DA       */
/*
#define AC_NAME     "TC_HELP "      /* DA name               */
*/
#define AC_NAME     "1STGUIDE"      /* DA name               */

/*
   call the Help DA
*/

#if GEMDOS

extern LINESTRUCT *begcut,*endcut;
extern int gl_apid;
extern OBJECT *divmenu;

static char keyword[65];
static char ac_name[9];
static unsigned int msgbuf[8];

char *extract(char *, int n);
void TCHelp( int acc_id, int ap_id, char *KeyWord, int msgtyp);

char *extract(char *beg, int n)
{
   strncpy(keyword,beg,min(n,63));
   keyword[min(n,63)]=0;
   return(keyword);
}

void TCHelp( int acc_id, int ap_id, char *Key, int msgtyp)
{
   msgbuf[0] = msgtyp;           /* magic message number     */
   msgbuf[1] = ap_id;            /* my own id                */
   msgbuf[2] = 0;                /* no more than 16 bytes    */

   *(char **)&msgbuf[3] = keyword;   /* the KeyWord          */
#if OLDTOS
   wind_update(END_UPDATE);
#endif
   appl_write( acc_id, 16, msgbuf); /* write message        */
#if OLDTOS
   wind_update(BEG_UPDATE);
#endif
}
#endif

int help(void)
{
#if GEMDOS
   int accid;
   char *keyw;

   sprintf(ac_name,"%-8s",(char *)(divmenu[DIVHDA].ob_spec.index/*+16L*/));
   accid=appl_find(ac_name);/* genau 8 Buchstaben, sonst mit BLANKS auffllen */

   if(accid>=0)
   {
      graf_mouse(M_ON,NULL); /* ACHTUNG! nur bei event */
      if(Wgettop() && begcut && endcut)
      {
         keyw=(char *)extract(&begcut->string[begcut->begcol],
                                  begcut->endcol-begcut->begcol);
      }
      else
      {
         strcpy(keyword,"7UP");
         keyw=keyword;
      }
      if(*keyw)
      {
         TCHelp(accid,gl_apid,keyw,AC_HELP); /* call DA */
         return(TRUE);
      }
   }
#endif
   return(FALSE);
}
