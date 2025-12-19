/**************************************************************************
*
*                    Universal Fontselector Version 0.96
*                     (c) 1991-1993 by Michael ThÑnitz
*
**************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>

#include "ufsl.h"

#define SCREEN 1
#define MONO   1

static int work_in[103],work_out[57];
int aeshandle, vdihandle;
char alertstr[256];

int cdecl fontsel_init(void); 
int cdecl fontsel_input(int vdihandle, int dummy, int ftype, char *text, int *id, int *size);

/* ----- Cookie Jar -------------------------------------------------------- */

typedef struct
{
	long	id,
		*ptr;
} COOKJAR;

/* ------------------------------------------------------------------------- */
/* ----- get_cookie -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

static long *get_cookie(long cookie)
{
	long	sav;
	COOKJAR	*cookiejar;
	int	i = 0;

	sav = Super((void *)1L);
	if(sav == 0L)
		sav = Super(0L);
	cookiejar = *((COOKJAR **)0x05a0l);
	if(sav != -1L)
		Super((void *)sav);
	if(cookiejar)
	{
		while(cookiejar[i].id)
		{
			if(cookiejar[i].id == cookie)
				return(cookiejar[i].ptr);
			i++;
		}
	}
	return(0l);
}

static int open_work (int device)
{
   register int i;
   int handle;

   for (i = 0; i < 103; i++) work_in [i] = 1;
   work_in [0]  = device;                         /* device handle */
   work_in [10] = 2;                         /* Raster Koordinaten */

   if (device == SCREEN)
   {
     handle=aeshandle;
     v_opnvwk (work_in, &handle, work_out);     /* virtuell îffnen */
   }
   else                                        /* nicht Bildschirm */
   {
     v_opnwk (work_in, &handle, work_out);  /* physikalisch îffnen */
   }
   return (handle);
}

static void close_work (int handle, int device)
{
  switch (device)
  {
    case SCREEN:
       v_clsvwk (handle);
       break;
    default:
       v_clswk (handle);
       break;
  }
}

void cdecl helpfunc()
{
   form_alert(1,"[0][|Hilfstext][  OK  ]");
}

main()
{
   int ret,id,size,n_fonts,done=FALSE;
   UFSL *ufsl;

   appl_init();
   graf_mouse(ARROW,NULL);
   aeshandle=graf_handle(&ret,&ret,&ret,&ret);
   vdihandle=open_work(SCREEN);

   if(vq_gdos())
      vst_load_fonts(vdihandle,0);
 
   ufsl=(UFSL *)get_cookie('UFSL');
   if(ufsl)
   {
	   do
      {
			ufsl->fontsel_init(); /* IMMER vorher aufrufen!!! */
	      ufsl->dialtyp=DIALOG;
	      ufsl->helpbutton->ob_width=7*(strlen("HILFE")+3);
	      ufsl->helpbutton->ob_flags=SELECTABLE|EXIT;
	      ufsl->helpbutton->ob_state=OUTLINED|SHADOWED;
	      ufsl->helpbutton->ob_spec.tedinfo->te_font=SMALL;
	      strcpy(ufsl->helpbutton->ob_spec.tedinfo->te_ptext,"HILFE");
	      ufsl->helpfunc=helpfunc;
	      ufsl->msgfunc=NULL;
		   switch(ufsl->fontsel_input(vdihandle,0,0,"Bitte Font auswÑhlen",&id,&size))
		   {
		      case 1:
		         sprintf(alertstr,"[1][|FontId: %d, Fontgrîûe: %dpt.][  OK  ]",id,size);
		         form_alert(1,alertstr);
               vst_font(vdihandle,id);
		   	   vst_point(vdihandle,size,&ret,&ret,&ret,&ret);
		         break;
		      case 0:
		         form_alert(1,"[1][|Abbruch gewÑhlt. ][  OK  ]");
		         done=TRUE;
		         break;
		      case -1:
		         form_alert(1,"[3][|Out of Memory! ][  OK  ]");
		         done=TRUE;
		         break;
		      case -2:
		         form_alert(1,"[3][|Mehrfachaufruf nicht mîglich! ][  OK  ]");
		         done=TRUE;
		         break;
		      case -3:
		         form_alert(1,"[3][|Fontgrîûe konnte nicht|identifiziert werden! ][  OK  ]");
		         done=TRUE;
		         break;
		      case -4:
		         form_alert(1,"[3][|Anzahl Fonts muû|grîûer null sein! ][  OK  ]");
		         done=TRUE;
		         break;
		   }
	   }
	   while(!done);
	}
   else
      form_alert(1,"[1][|Kein gÅltiger UFSL-Cookie! ][  OK  ]");

   if(vq_gdos())
      vst_unload_fonts(vdihandle,0);
   close_work(vdihandle,SCREEN);
   appl_exit();
}

