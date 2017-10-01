/* *** TTX_INIT.C - init and de-init *** */

#include <aes.h>
#include <osbind.h>

#include <string.h>
#include <stddef.h>

#include "xgriff.h"
#include "ttx_rsc.h"
#include "ttx_main.h"

#ifndef FALSE
#define FALSE 0
#define TRUE  (!0)
#endif

#ifdef SOZOBON
extern short _app;					/* Are we an application or an accessory? */
#define aesversion  gl_apversion	/* Depends on your GEM-Lib */
#define wind_set_str(handle,what,strn)  wind_set(handle,what,strn,0L)
#endif

#ifdef __TURBOC__ /* Turbo-C GEM Lib */
#define aesversion _GemParBlk.global[0]
#define wind_set_str(handle,what,strn)  wind_set(handle,what,strn,0L)
/* appl_getinfo von der NEW_AES.LIB : */
int appl_getinfo(int ap_gtype,int *ap_gout1, int *ap_gout2, int *ap_gout3, int *ap_gout4);
#endif


/* *** Try to use appl_getinfo  *** */
int appl_xgetinfo(int type, int *out1, int *out2, int *out3, int *out4)
{
  static int axgi_init=FALSE, has_agi;

  if(!axgi_init)		/* Already initialized? */
  {					/* Check if agi is possible */
    axgi_init=TRUE;
    has_agi = ( appl_find("?AGI\0\0\0\0")>=0
         || aesversion>0x0400
         || xgetcookie('MagX', 0L)
         || (aesversion==0x400 && xgetcookie('MiNT', 0L)) );
  }

 if(has_agi)
   return appl_getinfo(type, out1, out2, out3, out4);
 else
   return 0;
}


/* *** Load a 'skin' *** */
void loadskin(char *name)
{
  if( rsrc_load(name) )        /* Try to load the 'skin' RSC */
  {
    char *ptr;
    rsrc_gaddr(R_TREE, MAINDLG, &maindlg);  /* Get addresses */
    rsrc_gaddr(R_TREE, ICONDLG, &itree);
    maindlg[MODNAME].ob_spec.tedinfo->te_ptext = modulename;
    ptr = strrchr(name, '\\');            /* Search path end */
    if( ptr==NULL )
      ptr = name;
    else
      ptr += 1;
    strncpy(skinname, ptr, 12);
  }
  else
  {
    maindlg = _maindlg;
    itree = _itree;
    strcpy(skinname, "built-in");
  }

  skinname[12] = 0;

#ifdef TTX_DSP
  maindlg[BWARDBUT].ob_state|=DISABLED;
  maindlg[FWARDBUT].ob_state|=DISABLED;
  /*maindlg[SETUPBUT].ob_state|=DISABLED;*/
#endif

  dlgs[0]=itree; dlgs[1]=maindlg;
}


/* *** Initialize the GEM *** */
int enterGEM(void)
{
  int i;
  int agi1, agi2, agi3, agi4;

  ap_id=appl_init();
  if(aesversion>=0x0400 || !_app)		/* Set name if GEM version >= 4.00 */
    menu_register(ap_id, "  Tetrax\0\0");
  graf_mouse(ARROW, 0L);					/* Switch mouse to arrow */

  /* Init the built-in resources */
  i=MAINBOX;
  do  rsrc_obfix(_maindlg, i);  while( !(_maindlg[i++].ob_flags & LASTOB) );
  i=ICNFBOX;
  do  rsrc_obfix(_itree, i);  while( !(_itree[i++].ob_flags & LASTOB) );
  i=SETUPBOX;
  do  rsrc_obfix(setupdlg, i);  while( !(setupdlg[i++].ob_flags & LASTOB) );
  i=ABOUTBOX;
  do  rsrc_obfix(aboutdlg, i);  while( !(aboutdlg[i++].ob_flags & LASTOB) );
/* i=MOSTEBOX;*/
/* do  rsrc_obfix(mostepop, i);  while( !(mostepop[i++].ob_flags & LASTOB) );*/
  i=FREQBOX;
  do  rsrc_obfix(freqpop, i);  while( !(freqpop[i++].ob_flags & LASTOB) );
  i=EOFRBOX;
  do  rsrc_obfix(eofrpop, i);  while( !(eofrpop[i++].ob_flags & LASTOB) );

  dlgs[0]=itree; dlgs[1]=maindlg;
  dlgs[2]=setupdlg; dlgs[3]=aboutdlg;

  loadskin("tetrax.rsc");                /* Try to load a skin */

  form_center(maindlg, &i, &i, &i, &i);

  /* Try to tell the AES that we understand AP_TERM */
  if( _app && ( (appl_xgetinfo(10, &agi1, &agi2, &agi3, &agi4) && agi1&0x0FF>=9)
               || aesversion>=0x0400) )
    shel_write(9, 1, 0, 0L, 0L);

  return 0;
}

/* *** Leave GEM *** */
int exitGEM(void)
{
  appl_exit();

  return 0;
}
