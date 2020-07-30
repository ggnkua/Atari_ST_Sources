/***************************************************************************
*
*                                 mevent.c                          05.09.89
*
*                   Neues evnt_multi() nach XGEM-Manier
*
***************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <aes.h>
#include <tos.h>

#include "macro.h"

extern TMACRO macro;

static AESPB aespb=
{
   _GemParBlk.contrl,
   _GemParBlk.global,
   _GemParBlk.intin,
   _GemParBlk.intout,
   _GemParBlk.addrin,
   _GemParBlk.addrout
};

int evnt_event(MEVENT *mevent)
{
	if(macro.play)
	{
	   memcpy(_GemParBlk.intin,mevent,14*sizeof(int));
	   _GemParBlk.addrin[0]=mevent->e_mepbuf;
	   
	   _GemParBlk.intin[14]=0;
	   _GemParBlk.intin[15]=0;
	
	   _GemParBlk.contrl[0]=25;
	   _GemParBlk.contrl[1]=16;
	   _GemParBlk.contrl[2]=7;
	   _GemParBlk.contrl[3]=1;
	   _crystal(&aespb);
	
	   memcpy(&mevent->e_mx,&_GemParBlk.intout[1],6*sizeof(int));

	   play_macro(&mevent->e_ks,&mevent->e_kr);

	   return((_GemParBlk.intout[0]|MU_KEYBD) & ~(MU_TIMER|MU_BUTTON|MU_M1));
	}
	else
	{
	   memcpy(_GemParBlk.intin,mevent,14*sizeof(int));   
	   _GemParBlk.addrin[0]=mevent->e_mepbuf;
	   
	   _GemParBlk.intin[14]=(int)mevent->e_time & 0xffff;
	   _GemParBlk.intin[15]=(int)mevent->e_time >> 16;
	
	   _GemParBlk.contrl[0]=25;   
	   _GemParBlk.contrl[1]=16;   
	   _GemParBlk.contrl[2]=7;   
	   _GemParBlk.contrl[3]=1;   
	   _crystal(&aespb);
	
	   memcpy(&mevent->e_mx,&_GemParBlk.intout[1],6*sizeof(int));
/*
	   mevent->e_ks=(int)Kbshift(-1);
*/
	   if(_GemParBlk.intout[0] & MU_KEYBD)
	   {
      	_GemParBlk.intout[0] = record_macro(0,mevent->e_ks,mevent->e_kr);
		}
	   return(_GemParBlk.intout[0]);
   }
}
