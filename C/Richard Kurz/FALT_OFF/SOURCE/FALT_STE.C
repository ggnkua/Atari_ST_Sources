/* FALT_STE.C       
 *  
 * Steuerprogramm fÅr FALT_OFF.PRG V1.1    
 *
 * Erstellt mit PURE C V1.0 am
 * (c) 1992 by Richard Kurz
 * TOS-Magazin
 */

#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>

/* Wahr und Falsch wollen definiert sein   */
#define TRUE 1
#define FALSE 0

#define XBMAGIC 0x58425241L /* XBRA-Magic  */
#define XBID 0x46414c54L    /* XBRA-ID     */

extern int _app; /* ACC oder nicht ACC ?   */ 

int appl_id,     /* GEM-Angelegenheiten    */    
    menu_id; 

/* Durchsucht die XBRA-Kette nach FALTOFF. */
/* Bei positivem Ergebnis wird ein Zeiger  */
/* auf die Patch-Variablen vbl_flag und    */
/* xbi_flag zurÅckgeliefert.               */
char *find_xbra(void)
{
  unsigned long t;   /* Wird als Hilfs-    */
                     /* zeiger miûbraucht. */
  struct XBRA        /* XBRA Struktur.     */
  {
    unsigned long magic;
    unsigned long id;
    unsigned long old_vec;
  } *xb;
#pragma warn -rpt    /* PURE C ist nur     */
  t=(unsigned long)Setexc(46,-1L);  
                     /* schwer vom Warnen  */
#pragma warn +rpt    /* abzuhalten.        */         
  xb=(struct XBRA *)(t-12);
  while(xb->magic==XBMAGIC)
  {
    if(xb->id==XBID)
    {
      t=(unsigned long)xb;
      return((char *)(t-2)); 
    }
    xb=(struct XBRA *)(xb->old_vec-12);
  }
  return(NULL);
} /* find_xbra */

/* Der eigentliche Hauptteil.              */
void gem_prg(void)
{
  static char s[80]; /* Der Alertstring.   */
  char *f_flags;     /* Zeiger auf die     */
                     /* Patchvariablen.    */
  char *sv,*sx;      /* Kleine Bastelei.   */
  int i=0;           /* Welcher Button?    */

  f_flags=find_xbra(); 
  if(f_flags!=NULL)
  {
    while(i!=3)
    {                /* Wenn vbl_flag==99  */
                     /* ist, war kein VBL  */
                     /* Slot mehr frei.    */
      if(f_flags[0]==99) sv="BAD";
      else if(f_flags[0])sv="ON ";
      else      sv="OFF";
      if(f_flags[1])  sx="ON ";
      else      sx="OFF";
      sprintf(s,
        "[1][ |%s|%s][VBL %s|XBIOS %s|OKAY]",
        "  FALT_STE by Richard Kurz",
        "        TOS Magazin",
        sv,sx);
      i=form_alert(3,s);
      if(i==1 && f_flags[0]!=99) 
        f_flags[0]=f_flags[0]?0:1;
      else if(i==2) f_flags[1]=f_flags[1]?0:1;
    }
  }
  else
    form_alert(1,
      "[3][FALT_OFF|nicht gefunden][ Pech ]");
} /* gem_prg */

/* FALT_STE kann entweder als PRG oder     */
/* als ACC gestartet werden.               */
void main( void )
{
  static int buffer[8]; /* Puffer fÅr      */
                        /* event_mesag.    */
  appl_id=appl_init();
  if(appl_id!=-1)
  {
    if(!_app) 
    {
      menu_id=menu_register(appl_id,
        "  FALT_STE");
      for(;;)
      {
        evnt_mesag(buffer);
        if(buffer[0]==AC_OPEN)
        {
          if(buffer[4]==menu_id)
            gem_prg();
        }
      } 
    }
    else
    {
      graf_mouse(ARROW,(void *)0);
      gem_prg();
    }
    appl_exit();
  }
  exit(0);
} /* main */

