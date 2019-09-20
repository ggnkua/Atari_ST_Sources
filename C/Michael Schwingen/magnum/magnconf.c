/*
   $Id: magnconf.c,v 1.6 1998/05/14 11:18:22 rincewind Exp $
   
   $Log: magnconf.c,v $
 * Revision 1.6  1998/05/14  11:18:22  rincewind
 * added a fifth option field
 *
 * Revision 1.5  1997/03/14  00:14:22  rincewind
 * *** empty log message ***
 *
 * Revision 1.4  1996/11/28  17:59:40  rincewind
 * Ramtest abschaltbar
 *
 * Revision 1.3  1995/08/30  16:41:36  rincewind
 * moved patch area in magnum.s
 *
 * Revision 1.2  1995/08/28  20:31:32  rincewind
 * added help dialog
 *
 * Revision 1.1  1995/08/28  20:14:48  rincewind
 * Initial revision
 *
   
*/

#include <intrface\portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include <string.h>
#include <intrface\nkcc.h>
#include <intrface\mglobal.h>
#include <intrface\mydial.h>

#define CICONBLK int
#define CICON int
#include "magnconf.rh"
#include "magnconf.h"

void rsrc_init(void)
{
	int i;
	for(i=0;i<NUM_OBS;i++)
		rsrc_obfix(rs_object,i);
}

unsigned form_menu(OBJECT *tree, unsigned startobj);
void main2(void);
unsigned get_pars(void);
unsigned put_pars(void);
int open_file(int mode, char *msg);

#define BUFSIZE 10240
unsigned char buffer[BUFSIZE];
int msg[8];                        /* Message-Puffer fr evnt_mesag() */
char bootdrive;
char path[256], name[20];
unsigned int last_flagmask;    

typedef struct
{
	char magic[8];
	unsigned flags;
	unsigned flagmask;
} DRVHEADER;

int myd_alert(int button, int alert_num)
{
  return do_alert(button,rs_frstr[alert_num]);
}

unsigned form_menu(OBJECT *tree, unsigned startobj)
{
  int x,ok;

	wind_update(BEG_UPDATE);
	x = HndlDial(tree,startobj,TRUE,NULL,&ok);
	wind_update(END_UPDATE);
	return x;
}

/* Hauptprogramm Teil I: Initialisierungen */
int main(void)
{
  int gl_apid;
  
  if ((gl_apid = appl_init()) != -1)
  /*  Initialisierung, main2() aufrufen */
  {
    if (_app)
      graf_mouse(ARROW,0);
    else
      menu_register(gl_apid,"  MAGNUM-Config");
		/* NKCC und die MyDials werden initialisiert */
		nkc_init (NKI_NO200HZ, 0);     /* Initialisiere NKCC */
		nkc_set (0);

	  if (dial_init (malloc, free, NULL, NULL, NULL) == TRUE)
	  { 
	    rsrc_init();   /* Ressourcedaten an Aufl”sung anpassen */
    	dial_fix(rs_trindex[MAIN],TRUE);
    	dial_fix(rs_trindex[HELP],TRUE);
    	main2();
    	dial_exit();
    	nkc_exit();
    }
    appl_exit();
  }
  else
  /*  print error msg, if ACC: loop forever*/
  {
    Cconws("MAGNCONF:Fehler bei der Programminitialisierung!");
    while (!_app)
      evnt_mesag(msg);  /* Endlosschleife bei Accessory */
  }
  return 0;
}

long get_bootdrive(void)
{
  bootdrive = *(char *) 0x447 + 'A';
  return 0;
}

void main2(void)
{
  register unsigned button;
  register OBJECT *tree = rs_trindex[MAIN];
  unsigned parflag=1;

	Supexec(get_bootdrive);
  do
  {
    /*  ACC: Warten auf AC_OPEN message*/
    if (!_app)
      do
      {
        evnt_mesag(msg);
      } while (msg[0]!=AC_OPEN);
    wind_update(BEG_UPDATE);
    /*  wenn noch keine Parameter geholt wurden: jetzt nachholen*/
    if (parflag)
      if (get_pars() == TRUE)
      {
        wind_update(END_UPDATE);
        continue; /* Parameterholen abgebrochen */
      }
    parflag=0;
    /*  Dialog-Hauptschleife - Ende bei Anklicken des 'ENDE'-Buttons*/
    do
    {
      button = form_menu(tree,0);
      switch(button)
      {
        case M_SAVE:
          if(put_pars() == 0)
          {
          	tree[M_SAVE].ob_flags &= ~DEFAULT;
          	tree[M_QUIT].ob_flags |= DEFAULT;
          }
          break;
        case M_HELP:
          set_obspec(rs_trindex[HELP],H_ID,(long) "$Id: magnconf.c,v 1.6 1998/05/14 11:18:22 rincewind Exp $");
          form_menu(rs_trindex[HELP],0);
          break;
      }
    } while (button!=M_QUIT);
    wind_update(END_UPDATE);
  } while (!_app);
}

/*
   Parameter aus Datei holen
   out: 0 = OK / 1 = Abbruch
*/
unsigned get_pars(void)
{
  unsigned i;
  DRVHEADER *drv;
  int fp;

  /* Datei lesen, DRVHEADER-Struktur suchen*/
retry_read:
  fp = open_file(FO_READ,rs_frstr[S_LOADFILE]);
  if (fp < 0)
    return 1;

  /*  string "MAGPATC2" in File suchen (max. 400 bytes ab Dateianfang)*/
  drv = NULL;
  if (Fread(fp,BUFSIZE,buffer) == BUFSIZE)
  {
		for(i=0;i<BUFSIZE-8;i+=2)
		{
	  	if (strncmp(buffer+i,"MAGPATC2",8) == 0)
	    {
	      drv = (DRVHEADER *) (buffer+i);
	      break;
	    }
	  }
	}
	Fclose(fp);
	if (drv == NULL)
	{
	  myd_alert(1,A_READERR);
	  goto retry_read;
	}
	rs_trindex[MAIN][M_OPT1].ob_state = (drv->flags & 1) ? SELECTED : NORMAL;
	rs_trindex[MAIN][M_OPT2].ob_state = (drv->flags & 2) ? SELECTED : NORMAL;
	rs_trindex[MAIN][M_OPT3].ob_state = (drv->flags & 4) ? SELECTED : NORMAL;
	rs_trindex[MAIN][M_OPT4].ob_state = (drv->flags & 8) ? SELECTED : NORMAL;
	rs_trindex[MAIN][M_OPT5].ob_state = (drv->flags & 0x10) ? SELECTED : NORMAL;
	if (!(drv->flagmask & 1)) rs_trindex[MAIN][M_OPT1].ob_state |= DISABLED;
	if (!(drv->flagmask & 2)) rs_trindex[MAIN][M_OPT2].ob_state |= DISABLED;
	if (!(drv->flagmask & 4)) rs_trindex[MAIN][M_OPT3].ob_state |= DISABLED;
	if (!(drv->flagmask & 8)) rs_trindex[MAIN][M_OPT4].ob_state |= DISABLED;
	if (!(drv->flagmask & 0x10)) rs_trindex[MAIN][M_OPT5].ob_state |= DISABLED;
	last_flagmask = drv->flagmask;
	return 0;
}

/*
   Parameter in Datei schreiben
   out: 0 = OK / 1 = Abbruch
*/
unsigned put_pars(void)
{
  unsigned i;
  DRVHEADER *drv;
  int fp;

  /* Datei lesen, DRVHEADER-Struktur suchen*/
retry_read:
  fp = open_file(FO_RW,rs_frstr[S_SAVEFILE]);
  if (fp < 0)
    return 1;

  /*  string "MAGPATC2" in File suchen (max. 400 bytes ab Dateianfang)*/
  drv = NULL;
  if (Fread(fp,BUFSIZE,buffer) == BUFSIZE)
  {
		for(i=0;i<BUFSIZE-8;i+=2)
		{
	  	if (strncmp(buffer+i,"MAGPATC2",8) == 0)
	    {
	      drv = (DRVHEADER *) (buffer+i);
	      break;
	    }
	  }
	}
	if (drv == NULL || drv->flagmask != last_flagmask)
	{
	  myd_alert(1,A_READERR);
	  goto retry_read;
	}
	drv->flags = 0;
	if (rs_trindex[MAIN][M_OPT1].ob_state & SELECTED) drv->flags |= 1;
	if (rs_trindex[MAIN][M_OPT2].ob_state & SELECTED) drv->flags |= 2;
	if (rs_trindex[MAIN][M_OPT3].ob_state & SELECTED) drv->flags |= 4;
	if (rs_trindex[MAIN][M_OPT4].ob_state & SELECTED) drv->flags |= 8;
	if (rs_trindex[MAIN][M_OPT5].ob_state & SELECTED) drv->flags |= 0x10;
	if (0 != Fseek(0,fp,SEEK_SET) || 
	    Fwrite(fp,BUFSIZE,buffer) != BUFSIZE || 
	    Fclose(fp) != 0)
	{
	  myd_alert(1,A_WRITEERR);
	  return 1;
	}
	return 0;
}

int open_file(int mode, char *msg)
{
  int button;
  long fp=-1l;
  char *p, fullname[256];

  do
  {
    if (*path == 0)
    {
      /*  Default-Einstellung: Bootlaufwerk */
      *path = bootdrive;
      strcpy(path+1,":\\AUTO\\MAGNUM*.PRG");
      strcpy(name,"MAGNUMST.PRG");
    }
    if (fsel_exinput(path,name,&button,msg) == 0 || button==0)
    {
      *path = 0;
      return -1;
    }
    strcpy(fullname,path);

    /* in fullname alles nach letztem '\' abschneiden*/
    p = fullname;
    while (*p) p++;
    while (*--p != '\\')
      ;
    *++p = 0;

    strcat(fullname,name);
      fp = Fopen(fullname,mode);
    if (fp < 0)
      *name = 0;
  } while (fp < 0);
  return (int) fp;
}
