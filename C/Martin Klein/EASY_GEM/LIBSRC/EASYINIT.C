#include <vdi.h>
#include <aes.h>
#include <tos.h>

/* -------------------------------------------------------------------- */
/*    Globale Variablen.                                                */
/* -------------------------------------------------------------------- */
int contrl[12],intin[128],intout[128],ptsin[128],ptsout[128];
int work_in[12],work_out[57];
int handle,phys_handle;
int gl_hchar,gl_wchar,gl_hbox,gl_wbox,gl_apid;
int _sbreite,_shoehe,_splanes,_sbytes;
char *_sscreen;
extern GEMPARBLK _GemParBlk;

typedef enum {FALSE,TRUE} boolean;

/* ------------------------------------------------------ */
/*    Funktionen.                                         */
/* ------------------------------------------------------ */

boolean open_vwork()
{
   register int i;
   int farbe;

   if((gl_apid = appl_init()) != -1)
   {
      for(i = 1; i < 10; work_in[i++] = 1);
      work_in[10] = 2;
      phys_handle = graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
      work_in[0] = handle = phys_handle;
      v_opnvwk(work_in, &handle, work_out);
      _sbreite=_GemParBlk.intout[0]+1;
      _shoehe=_GemParBlk.intout[1]+1;
      farbe=_GemParBlk.intout[13];
      _splanes=0;
      _sscreen=(char *)Logbase();
      while(farbe>1)    /* Anzahl der Farbebenen ermitteln  */
      {                 /* planes=log2(farben)              */
         farbe>>=1;
         _splanes++;
      }
      _sbytes=_sbreite/(_splanes<<3);
      graf_mouse(ARROW,0L);
   }
   else
      return(FALSE);
      
	return(TRUE);
}

void close_vwork()
{ v_clsvwk(handle);appl_exit(); }
