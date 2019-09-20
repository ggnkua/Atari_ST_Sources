/*
   $Id: setflags.c,v 1.4 1998/05/14 11:52:10 rincewind Exp $
   
   $Log: setflags.c,v $
 * Revision 1.4  1998/05/14  11:52:10  rincewind
 * change RSC, bump version number
 *
 * Revision 1.3  1995/09/08  13:48:58  rincewind
 * first working release version
 *
 * Revision 1.2  1995/09/02  18:29:12  rincewind
 * no abort when not choosing a file in first fileselector
 *
 * Revision 1.1  1995/09/02  18:25:30  rincewind
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
#include <mslib\mslib.h>

#define CICONBLK int
#define CICON int
#include "setflags.rh"
#include "setflags.h"

void rsrc_init(void)
{
	int i;
	for(i=0;i<NUM_OBS;i++)
		rsrc_obfix(rs_object,i);
}

unsigned form(OBJECT *tree, unsigned startobj);
void main2(void);
unsigned get_pars(void);
unsigned put_pars(void);
int open_file(int mode);
int reopen_file(int mode);

#define BUFSIZE 10240
unsigned char buffer[BUFSIZE];
int msg[8];                        /* Message-Puffer fr evnt_mesag() */
char path[256], name[20];      
unsigned long filesize;

typedef struct
{
  unsigned int ph_branch;
  unsigned long ph_tlen;
  unsigned long ph_dlen;
  unsigned long ph_blen;
  unsigned long ph_slen;

  unsigned long ph_res1;
  unsigned long ph_prgflags;
  unsigned int ph_absflag;
} PH;
PH header;

void ltos(unsigned long val, char *str)
{
	char tmp[10];
	char *p;
	int i;
	
	ultoa(val,tmp,10);
	i = (int) strlen(tmp);
	for (p=tmp;i>0;i--)
	{
		if ((i % 3) == 0 && p != tmp)
			*str++ = '.';
		*str++ = *p++;
	}
	*str++ = 0;
}

int myd_alert(int button, int alert_num)
{
  return do_alert(button,rs_frstr[alert_num]);
}

unsigned form(OBJECT *tree, unsigned startobj)
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
      menu_register(gl_apid,"  Set PRG flags");
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
    Cconws("SETFLAGS:Fehler bei der Programminitialisierung!");
    while (!_app)
      evnt_mesag(msg);  /* Endlosschleife bei Accessory */
  }
  return 0;
}

void main2(void)
{
  register unsigned button;
  register OBJECT *tree = rs_trindex[MAIN];
  unsigned parflag=1;

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
      get_pars();
    parflag=0;
    /*  Dialog-Hauptschleife - Ende bei Anklicken des 'ENDE'-Buttons*/
    do
    {
			rs_trindex[MAIN][M_OPT1].ob_state = (header.ph_prgflags & 1) ? SELECTED : NORMAL;
			rs_trindex[MAIN][M_OPT2].ob_state = (header.ph_prgflags & 2) ? SELECTED : NORMAL;
			rs_trindex[MAIN][M_OPT3].ob_state = (header.ph_prgflags & 4) ? SELECTED : NORMAL;
			if (header.ph_branch != 0x601a)
			{
				rs_trindex[MAIN][M_OPT1].ob_state |= DISABLED;
				rs_trindex[MAIN][M_OPT2].ob_state |= DISABLED;
				rs_trindex[MAIN][M_OPT3].ob_state |= DISABLED;
				rs_trindex[MAIN][M_SAVE].ob_state |= DISABLED;
				rs_trindex[MAIN][M_SAVE].ob_flags &= ~DEFAULT;
				rs_trindex[MAIN][M_FILE].ob_flags |= DEFAULT;
			} else
			{
				rs_trindex[MAIN][M_OPT1].ob_state &= ~DISABLED;
				rs_trindex[MAIN][M_OPT2].ob_state &= ~DISABLED;
				rs_trindex[MAIN][M_OPT3].ob_state &= ~DISABLED;
				rs_trindex[MAIN][M_SAVE].ob_state &= ~DISABLED;
				rs_trindex[MAIN][M_SAVE].ob_flags |= DEFAULT;
				rs_trindex[MAIN][M_FILE].ob_flags &= ~DEFAULT;
			}
      ob_set_text(rs_trindex[MAIN],M_NAME,name);
      ltos(filesize,(char *)ob_get_text(rs_trindex[MAIN],M_SIZE));
      
      button = form(tree,0);
      switch(button)
      {
        case M_FILE:
        case M_NAME:
        	get_pars();
        	break;
        case M_SAVE:
        	put_pars();
          break;
        case M_HELP:
          set_obspec(rs_trindex[HELP],H_ID,(long) "$Id: setflags.c,v 1.4 1998/05/14 11:52:10 rincewind Exp $");
          form(rs_trindex[HELP],0);
          break;
      }
    } while (button!=M_QUIT);
    memset(&header,0,sizeof(header));
    wind_update(END_UPDATE);
  } while (!_app);
}

/*
   Parameter aus Datei holen
   out: 0 = OK / 1 = Abbruch
*/
unsigned get_pars(void)
{
	int fp;
  /* HEADER-Struktur aus Datei lesen*/
retry_read:
  fp = open_file(FO_READ);
  if (fp < 0)
    return 1;

  if (Fread(fp,sizeof(header),&header) != sizeof(header))
  {
	  myd_alert(1,A_READERR);
	  goto retry_read;
	}
	filesize = Fseek(0,fp,2);
	if (header.ph_branch != 0x601a)
		memset(&header,0,sizeof(header));
	Fclose(fp);
	return 0;
}

/*
   Parameter in Datei schreiben
   out: 0 = OK / 1 = Fehler
*/
unsigned put_pars(void)
{
	int fp;

	fp = reopen_file(FO_RW);
	if (fp < 0)
	{
	  myd_alert(1,A_READERR);
		return 1;
	}
  if (Fread(fp,sizeof(header),&header) != sizeof(header))
  {
	  myd_alert(1,A_READERR);
	  Fclose(fp);
	  return 1;
	}
	header.ph_prgflags = 0;
	if (rs_trindex[MAIN][M_OPT1].ob_state & SELECTED) header.ph_prgflags |= 1;
	if (rs_trindex[MAIN][M_OPT2].ob_state & SELECTED) header.ph_prgflags |= 2;
	if (rs_trindex[MAIN][M_OPT3].ob_state & SELECTED) header.ph_prgflags |= 4;
	
  if (0 != Fseek(0,fp,SEEK_SET) ||
      Fwrite(fp,sizeof(header),&header) != sizeof(header) ||
      Fclose(fp) != 0)
  {
	  myd_alert(1,A_WRITEERR);
	  return 1;
	}
	return 0;
}

int open_file(int mode)
{
  int button;
  long fp=-1l;
  char *p, fullname[256];

  do
  {
    if (*path == 0)
    {
      /*  Default-Einstellung */
      *path = Dgetdrv();
      path[1] = ':';
      Dgetpath(path+2,*path+1);
      *path += 'A';
      if (*(path+strlen(path)) != '\\')
	      strcat(path,"\\*.PRG");
	   	else
	      strcat(path,"*.PRG");
      *name = 0;
    }
    if (fsel_exinput(path,name,&button,rs_frstr[S_LOCATEFILE]) == 0 || button==0)
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

int reopen_file(int mode)
{
  long fp;
  char *p, fullname[256];

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
  return (int) fp;
}

