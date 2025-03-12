/**************************/
/* AHDICONF               */
/*                        */
/* zur Konfiguration von  */
/*                        */
/* AHDI V3.0 oder V4.0    */
/*                        */
/* (C) 1991 by Uwe Seimet */
/**************************/


#define EXTERN extern

#include "ahdiconf.rsh"
#include "ahdiconf.rh"
#include <vdi.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ext.h>


/* Offset des Parameterbereichs */
/* zum Beginn der AHDI-Programmdatei */
#define PARSTART 40

/* 42 Parameterbytes bei AHDI 4.0 */
#define PARLEN 42

#define TRUE 1
#define FALSE 0

typedef enum _bool boolean;


int contrl[11],
    intin[80],
    intout[45],
    ptsin[32],
    ptsout[32];

int work_in[12],
    work_out[57];

int g_handle;

int gl_hchar,
    gl_wchar;


char ahdiname[150];


/* Konfigurations-Variablen */
struct
    {
    unsigned int magic;
    unsigned int version;
    int          chunk;
    int          defbigse;
    int          acsi_devs;
    char         acsi_def_ndrv[8];
    int          scsi_devs;
    char         scsi_def_ndrv[8];
    } ahdi_vars;


/* Funktions-Prototypen */
boolean open_vwork(void);
boolean open_driver(void);
boolean close_driver(void);
void get_par(void);
void put_par(void);
boolean do_dialog(void);
void rsrc_init(void);



int main()
{
  if ((appl_init())!=-1)
    {
    if (open_vwork())
      {
      /* Treiberdatei îffnen */
      if (open_driver())
        {
        /* Parameter auswerten */
        get_par();
        /* Resource-Daten umrechnen */
        rsrc_init();
        /* Eingaben sind erwÅnscht */
        if (do_dialog())
          {
          /* Parameter auswerten */
          put_par();
          /* Treiber konfigurieren */
          close_driver();
          }
        }
        v_clsvwk(g_handle);
      }
    }
  appl_exit();
  return(0);
}


/* Workstation îffnen */
boolean open_vwork()
{
  int gl_wbox,gl_hbox;

  register int i;

  for(i=1; i<10; work_in[i++]=0);
  work_in[10]=2;
  g_handle=graf_handle(&gl_wchar,&gl_hchar,
                       &gl_wbox,&gl_hbox);
  work_in[0]=g_handle;
  v_opnvwk(work_in,&g_handle,work_out);
  if (!g_handle) return(FALSE);
  return(TRUE);
}


/* Dialog fÅhren */
boolean do_dialog()
{
  int fo_cx,fo_cy,fo_cw,fo_ch;
  int index;
  int exit;

  /* SCSI-Parameter nur ab AHDI V4.0 */
  if (ahdi_vars.version<0x0400)
    {
    rs_trindex[DIALOG][SCSI].ob_flags |= HIDETREE;
    for (index=SCSINUM; index<SCSINUM+8; index++)
      rs_trindex[DIALOG][index].ob_flags
        &= ~EDITABLE;
    }

  form_center(rs_trindex[DIALOG],&fo_cx,&fo_cy,
              &fo_cw,&fo_ch);
  form_dial(FMD_START,fo_cx,fo_cy,fo_cw,fo_ch,
            fo_cx,fo_cy,fo_cw,fo_ch);
  objc_draw(rs_trindex[DIALOG],0,3,fo_cx,fo_cy,
            fo_cw,fo_ch);
  graf_mouse(ARROW,NULL);
  exit=form_do(rs_trindex[DIALOG],CHUNK);
  form_dial(FMD_FINISH,fo_cx,fo_cy,fo_cw,fo_ch,
            fo_cx,fo_cy,fo_cw,fo_ch);
  return(exit!=ABORT);
}


/* Parameter aus Treiber holen */
void get_par()
{
  int index;
  char *te_ptext;

  te_ptext=rs_trindex[DIALOG][CHUNK].ob_spec
           .tedinfo->te_ptext;

  /* Zahl der zusÑtzlichen Ordner */
  itoa(ahdi_vars.chunk,te_ptext,10);

  /* Maximale Sektorgrîûe */
  index=ahdi_vars.defbigse/512-1;
  rs_trindex[DIALOG][DEFBIGSE+index].ob_state
    |= SELECTED;

  /* Default-Partitionen fÅr ACSI */
  for (index=0; index<ahdi_vars.acsi_devs;
       index++)
    {
    te_ptext=rs_trindex[DIALOG][ACSINUM+
            index].ob_spec.tedinfo->te_ptext;
    te_ptext[0]=ahdi_vars.acsi_def_ndrv
                [index]+'0';
    }

  /* dto fÅr SCSI */
  if (ahdi_vars.version>=0x0400)
    {
    for (index=0; index<ahdi_vars.scsi_devs;
         index++)
      {
      te_ptext=rs_trindex[DIALOG][SCSINUM+
               index].ob_spec.tedinfo->te_ptext;
      te_ptext[0]=ahdi_vars.scsi_def_ndrv
                  [index]+'0';
       }
    }
}


/* Neue Parameterdaten erzeugen */
void put_par()
{
  int index=0;
  char *te_ptext;

  while(!(rs_trindex[DIALOG][DEFBIGSE+index]
    .ob_state && SELECTED)) index++;
  ahdi_vars.defbigse=(index+1)*512;
  te_ptext=rs_trindex[DIALOG][CHUNK]
    .ob_spec.tedinfo->te_ptext;
  ahdi_vars.chunk=atoi(te_ptext);
  for (index=0; index<ahdi_vars.acsi_devs;
       index++)
    {
    te_ptext=rs_trindex[DIALOG][ACSINUM+
            index].ob_spec.tedinfo->te_ptext;
    ahdi_vars.acsi_def_ndrv[index]=te_ptext
      [0]-'0';
    }

  if (ahdi_vars.version>=0x0400)
    {
    for (index=0; index<ahdi_vars.scsi_devs;
         index++)
      {
      te_ptext=rs_trindex[DIALOG][SCSINUM+
              index].ob_spec.tedinfo->te_ptext;
      ahdi_vars.scsi_def_ndrv[index]=te_ptext
        [0]-'0';
      }
    }
}


/* Treiberdatei îffnen, Parameter lesen */
boolean open_driver()
{
  char *dummy;
  int handle;
  int button;
  char filename[]="SHDRIVER.SYS";

  getcwd(ahdiname,MAXPATH);
  fsel_input(ahdiname,filename,&button);
  if (!button) return(FALSE);

  /* Zugriffspfad zusammensetzen */
  dummy=strrchr(ahdiname,'\\');
  if (dummy==NULL) return(FALSE);
  graf_mouse(BUSYBEE,NULL);
  strcpy(dummy+1,filename);

  handle=open(ahdiname,O_RDONLY);
  if (handle<0) return(FALSE);
  lseek(handle,(size_t)(PARSTART),SEEK_SET);
  if (read(handle,&ahdi_vars,(size_t)(PARLEN))
      <=0)
    {
    close(handle);
    return(FALSE);
    }
  close(handle);

  /* Korrekte Treiberversion? */
  if (ahdi_vars.magic!=0xf0ad) return(FALSE);
  return(TRUE);
}


/* Parameter zurÅckschreiben */
boolean close_driver()
{
  int handle;
  int parlen=PARLEN;

  graf_mouse(BUSYBEE,NULL);

  /* AHDI 3.0 hat 10 Parameterbytes weniger */
  if (ahdi_vars.version<0x400) parlen-=10;

  handle=open(ahdiname,O_WRONLY);
  lseek(handle,(size_t)(PARSTART),SEEK_SET);
  if (write(handle,&ahdi_vars,(size_t)(parlen))
      !=parlen) return(FALSE);
  close(handle);
  form_alert(1,"[1][Der Treiber wurde|\
neu konfiguriert.][   OK   ]");
  return(TRUE);
}


/* Objektkoordinaten umrechnen */
void rsrc_init()
{
  register int i;

  for(i=0; i<NUM_OBS; i++) rsrc_obfix(rs_trindex
      [DIALOG],i);
}