/***********************************************/
/* Datei: DISK.C                               */
/* ------------------------------------------- */
/* Modul: DISK.CPX                Version 1.00 */
/* (C) 1990 by MAXON Computer                  */
/* Autoren: Uwe Hax & Oliver Scholz            */
/* verwendeter Compiler: Turbo-C 2.0           */
/***********************************************/


/* die Åblichen Header-Dateien --------------- */

#include <portab.h>
#include <aes.h>
#include <tos.h>
#include <stdlib.h>
#include <string.h>
#include <vdi.h>


/* Definitionen zur besseren Lesbarkeit ------ */

#define PAL          1      /* 50 Hertz */
#define NTSC         0      /* 60 Hertz */

#define VERIFY_ON    1      /* Verify-Flag */
#define VERIFY_OFF   0

#define MS_2         2      /* Steprate */
#define MS_3         3        
#define MS_6         0    
#define MS_12        1

#define MESSAGE     -1      /* Message-Event */

#define TRUE         1      /* sonstige Def. */
#define FALSE        0
#define EOS          '\0'
#define OK_BUTTON    1

#define _nflops      0x4a6  /* Systemvariablen */
#define sshiftmd     0x44c
#define hdv_init     0x46a
#define seekrate     0x440
#define _fverify     0x444
#define palmode      0x448
#define _sysbase     0x4f2
#define sync_mode    0xffff820aL


/* globale Variablen ------------------------- */

/* Deklaration der zu sichernden Variablen...  */
typedef struct 
{  
  WORD step_a;        /* Steprate Laufwerk A */
  WORD step_b;        /* Steprate Laufwerk B */
  WORD verify;        /* Verify-Flag */
  WORD frequency;     /* Bildschirm-Frequenz */
  BYTE controller0;   /* 1. Controller-ID */
  BYTE controller1;   /* 2. Controller-ID */
  BYTE unit0;         /* 1. Harddisk-ID */
  BYTE unit1;         /* 2. Harddisk-ID */
} STATUS;                       

/* ...und Definition */
STATUS status={ MS_3,MS_3,VERIFY_ON,PAL,
                0,0,0,1 };

/* Die zu sichernden Variablen mÅssen unbedingt
   als erste definiert werden (=> erste Variable
   im Datensegment)!
   (Achtung vor dubiosen Header-Dateien!) ---- */


/* Resource-Datei deshalb erst hier einladen */

#include "disk.rsh"
#include "disk.h"
#include "xcontrol.h" /* darf erst nach "*.rsh" 
                         eingebunden werden */


/* sonstige globale Variablen ---------------- */

CPX_PARAMS *params; /* vom Kontrollfeld Åber-
                       gebener Zeiger auf die
                       Kontrollfeld-Funktionen */

char ms2[]="2 ms";  /* Strings fÅr Dialogbox */
char ms3[]="3 ms";
char ms6[]="6 ms";
char ms12[]="12 ms";
char hz50[]="50 Hz";
char hz60[]="60 Hz";
char ein[]="Ein";
char aus[]="Aus";
char empty[]="   ";

OBJECT *disk;        /* Zeiger auf Dialogboxen */
OBJECT *sure;
OBJECT *switchoff;
OBJECT *error;


/* Prototypen fÅr Turbo-C -------------------- */

VOID get_id(STATUS *work);
OBJECT *get_traddr(WORD tree_index);
VOID get_values(STATUS *work);
UWORD get_version(VOID);
CPX_INFO * cdecl init(CPX_PARAMS *params);
WORD hd_park(BYTE controller, BYTE unit);
VOID into_resource(STATUS *work);
WORD cdecl main(GRECT *curr_wind);
VOID pulldown(WORD button, STATUS *work);
VOID redraw_object(OBJECT *tree, WORD object);
VOID set_id(STATUS *work);
WORD set_step(WORD drive, WORD step);
WORD set_verify(WORD verify);
WORD set_frequency(WORD frequency);
VOID set_values(STATUS status, STATUS work);
WORD switch_off(VOID);                           
VOID wind_center(OBJECT *tree, WORD *x, WORD *y,
                 WORD *w, WORD *h);


/* Funktionen -------------------------------- */

/***********************************************/
/* Initialisierung des Moduls:                 */
/* öbergabeparameter: Zeiger auf die zur       */
/*    VerfÅgung stehenden Funktionen           */
/* 1. Aufruf bei Laden des Headers             */
/*    (par->booting == TRUE)                   */
/*    RÅckgabe: 0 bei Set-Only, 1 sonst        */
/* 2. Aufruf bei Laden des eigentlichen        */
/*    Programms (par->booting == FALSE)        */
/*    RÅckgabe: Adresse der CPX_INFO-Struktur  */
/***********************************************/
                    
CPX_INFO * cdecl init(CPX_PARAMS *par)
{
  char vdo[5]="_VDO";
  LONG version;
  static CPX_INFO info={ main,0L,0L,0L,0L,0L,
                         0L,0L,0L,0L };

  if (par->booting)  /* bei Laden des Headers */
  {                  /* alle Parameter setzen */
    set_step(0,status.step_a);
    set_step(1,status.step_b);
    set_verify(status.verify);

    /* keine Frequenz auf dem TT setzen! */
    if (!(*par->find_cookie)(*(LONG *)vdo,&version))
      version=0L;
    if (version<0x00020000L)
      set_frequency(status.frequency);

    return((CPX_INFO *)1L);  /* weitermachen */
  }
  else /* Aufruf bei Laden des Programms */
  {    /* => Lîschen aller globalen Variablen! */
    params=par;  /* Zeiger retten! */
  
    /* Resource relozieren */
    if (!params->rsc_init)
    {
      (*(params->do_resource))(NUM_OBS,NUM_FRSTR,
        NUM_FRIMG,NUM_TREE,rs_object,rs_tedinfo,
        rs_strings,rs_iconblk,rs_bitblk,rs_frstr,
        rs_frimg,rs_trindex,rs_imdope);
                          
      /* globale Variablen initialisieren */
      disk=get_traddr(DISK);
      sure=get_traddr(SURE);
      switchoff=get_traddr(SWITCHOF);
      error=get_traddr(ERROR);
 
      /* Harddisk-ID's in die Dialogbox 
         eintragen */
      set_id(&status);
    }
                                                
    /* Adresse der CPX_INFO-Struktur zurÅck */
    return(&info);
  }
}  


/***********************************************/
/* Aufruf nach Doppelclick auf das Icon im     */
/* Auswahlfenster: Zeichnen der Dialogbox,     */
/* Behandlung der Buttons                      */
/* öbergabeparameter: Koordinaten des Fenster- */
/*                    arbeitsbereichs          */
/* RÅckgabe: FALSE, wenn der Dialog mittels    */
/*           do_form() abgearbeitet wird,      */
/*           TRUE, falls eigene Event-Routinen */
/*           benutzt werden sollen             */
/***********************************************/

WORD cdecl main(GRECT *curr_wind)
{  
  STATUS work;
  WORD msg_buff[8];
  WORD button;
  WORD abort_flag=FALSE;

  /* aktuelle Systemparameter einlesen */
  get_values(&status);
  work=status;
  
  /* Koordinaten der Dialogbox setzen */
  disk[ROOT].ob_x=curr_wind->g_x;
  disk[ROOT].ob_y=curr_wind->g_y;

  /* Systemparameter in Dialogbox eintragen */
  into_resource(&work);

  /* und Dialogbox zeichnen */
  objc_draw(disk,ROOT,MAX_DEPTH,disk[ROOT].ob_x,
            disk[ROOT].ob_y,disk[ROOT].ob_width,
            disk[ROOT].ob_height);

  /* Dialogbox abarbeiten, bis ein Exit-Objekt
     angeklickt wurde */

  do
  {
    /* neuer form_do()-Aufruf */
    button=(*params->do_form)(disk,UNIT0,
                                msg_buff);
     
    /* Doppelklick ausmaskieren */
    if (button>=0)
      button &= 0x7fff;
       
    /* angeklicktes Objekt auswerten */
    switch (button)
    {
      case SAVE:
        /* Parameter in CPX-Datei speichern */
        get_id(&work);
        if ((*params->alert)(0)==OK_BUTTON)
          (*params->write_config)(&work,
            sizeof(STATUS));
        disk[SAVE].ob_state &= ~SELECTED;
        redraw_object(disk,ROOT);
        break;
                     
      case OK:
        /* Harddisk parken? */
        if (!switch_off())
          disk[OK].ob_state &= ~SELECTED;
        else
        {
          /* neue Parameter Åbernehmen */
          set_values(status,work);

          /* fÅr "resident" notwendig */
          get_id(&work);       
          status=work;  
          abort_flag=TRUE;
        }
        break;
                     
      case CANCEL:
        abort_flag=TRUE;
        break;
                       
      case VERIFY:   
      case FREQ:      
      case STEPA:
      case STEPB:
        pulldown(button,&work);
         break;

      case MESSAGE:
        switch (msg_buff[0])
        {
          case WM_REDRAW:         
            break;        /* nicht notwendig */

          case WM_CLOSED:
            set_values(status,work);

            /* fÅr "resident" notwendig */
            get_id(&work);
            status=work;  

          case AC_CLOSE:
            abort_flag=TRUE;
            break;
        }
        break;
    }  
  }
  while (!abort_flag);
  disk[button].ob_state &= ~SELECTED;
  return(FALSE);
}


/***********************************************/
/* Parameter in die Dialogbox eintragen        */
/* öbergabeparameter: Zeiger auf Status        */
/* RÅckgabe: keine                             */
/***********************************************/

VOID into_resource(STATUS *status)
{ 
  LONG ssp;
  WORD drives;
  char cpu[5]="_CPU";
  char vdo[5]="_VDO";
  LONG version=0L;
  char *ms[4]={ ms2,ms3,ms6,ms12 };
  WORD MS[4]={ MS_2,MS_3,MS_6,MS_12 };
  WORD i;

  /* Stepraten eintragen */
  for (i=0; i<4; i++)
  {
    if (status->step_a==MS[i])
      disk[STEPA].ob_spec.free_string=ms[i];
    if (status->step_b==MS[i])
      disk[STEPB].ob_spec.free_string=ms[i]; 
  }
 
  /* Verify-Flag eintragen */
  disk[VERIFY].ob_spec.free_string=
    (status->verify==VERIFY_ON) ? ein : aus;
    
  /* Frequenz eintragen */
  disk[FREQ].ob_spec.free_string=
    (status->frequency==PAL) ? hz50 : hz60;  

  /* alle Buttons initialisieren */
  disk[STEPA].ob_state |= DISABLED;
  disk[STEPA].ob_flags &= ~TOUCHEXIT;
  disk[STEPB].ob_state |= DISABLED;
  disk[STEPB].ob_flags &= ~TOUCHEXIT;
  disk[VERIFY].ob_state &= ~DISABLED;
  disk[VERIFY].ob_flags |= TOUCHEXIT;
 
  /* Anzahl der angeschlossenen Laufwerke
     ermitteln */
  ssp=Super((VOID *)0L);
  drives=*(WORD *)_nflops;
  Super((VOID *)ssp);
 
  /* Buttons abhÑngig von der Anzahl der 
     Diskettenlaufwerke (de)aktivieren */
  switch (drives)
  {
    case 2:
      disk[STEPB].ob_state &= ~DISABLED;
      disk[STEPB].ob_flags |= TOUCHEXIT;

    case 1:
      disk[STEPA].ob_state &= ~DISABLED;
      disk[STEPA].ob_flags |= TOUCHEXIT;
      break;

    case 0:
      disk[VERIFY].ob_state |= DISABLED;
      disk[VERIFY].ob_flags &= ~TOUCHEXIT;
      break;
  }

  /* Frequenz nur im Farbmodus und nicht auf 
     dem TT verfÅgbar */
  if (!(*params->find_cookie)(*(LONG *)vdo,&version))
    version=0L;

  ssp=Super((VOID *)0L);
  if ((*(BYTE *)sshiftmd==2) ||
      (version>=0x00020000L))
  {
    disk[FREQ].ob_state |= DISABLED;
    disk[FREQ].ob_flags &= ~TOUCHEXIT;
  }
  else
  {
    disk[FREQ].ob_state &= ~DISABLED;
    disk[FREQ].ob_flags |= TOUCHEXIT;
  }
  Super((VOID *)ssp); 

  /* CPU-Typ im Cookie-Jar suchen */
  if (!(*params->find_cookie)(*(LONG *)cpu,&version))
    version=0L;

  disk[CPU].ob_spec.tedinfo->te_ptext[11]=
                          (char)(version/10+'0');
}


/***********************************************/
/* Neuzeichnen eines Objekts mit Hilfe der vom */
/* Kontrollfeld gelieferten Rechteck-Liste.    */
/* öbergabeparameter: Zeiger auf Objektbaum,   */
/*                    Objekt-Index             */
/* RÅckgabe: keine                             */
/***********************************************/

VOID redraw_object(OBJECT *tree, WORD object)
{
  GRECT *clip_ptr,clip,xywh;
    
  /* absolute Objekt-Koordinaten berechnen */
  objc_offset(tree,object,&xywh.g_x,&xywh.g_y);
  xywh.g_w=tree[object].ob_width;
  xywh.g_h=tree[object].ob_height;
  
  /* erstes Rechteck holen */
  clip_ptr=(*params->rci_first)(&xywh);

  /* solange noch Rechtecke da sind */
  while (clip_ptr)
  {
    /* clip_ptr: Zeiger auf lokale Variable!! */
    clip=*clip_ptr;  /* deshalb kopieren */

    /* Objekt neu zeichnen */
    objc_draw(tree,object,MAX_DEPTH,clip.g_x,
              clip.g_y,clip.g_w,clip.g_h);

    /* nÑchstes Rechteck holen */
    clip_ptr=(*params->rci_next)();
  }
}


/***********************************************/
/* Pulldown-MenÅ generieren, darstellen und    */
/* auswerten.                                  */
/* öbergabeparameter: angeklickter Button, aus */
/*                    dem das MenÅ "heraus-    */
/*                    klappen" soll,           */
/*                    Zeiger auf aktuelle      */
/*                    Parameter                */
/* RÅckgabe: keine                             */
/***********************************************/

VOID pulldown(WORD button, STATUS *work)
{
  WORD i;
  WORD num_items;
  WORD index,checked;
  WORD step;
  GRECT button_xywh,window_xywh;
  char *pull_adr[4];
  char pull_buff[4][15];
  WORD ms[]={ MS_2,MS_3,MS_6,MS_12 };

  /* je nach Button entsprechendes Pull-Down-
     MenÅ generieren */ 
  switch (button)
  {
    case STEPA:      
    case STEPB:   
      /* Texte eintragen; alle EintrÑge gleich
         lang machen */
      for (i=0; i<4; i++)
        strcpy(pull_buff[i],empty);
      strcat(pull_buff[0],ms2);
      strcat(pull_buff[1],ms3);
      strcat(pull_buff[2],ms6);
      strcat(pull_buff[3],ms12);
      for (i=0; i<4; i++)
        strcat(pull_buff[i],empty);
      pull_buff[3][10]=EOS;
                 
      /* Anzahl der EintrÑge */
      num_items=4;
                  
      /* Umrechnung von Steprate in Index */
      step=((button==STEPA) ? work->step_a :
                              work->step_b);
      for (i=0; i<4; i++)
        if (ms[i]==step)
          break;

      /* Index abgehakter Eintrag */
      index=i;
      break;

   case VERIFY:   /* wie oben */
     strcpy(pull_buff[0],empty);  
     strcat(pull_buff[0],ein);
     strcat(pull_buff[0],empty);
     strcpy(pull_buff[1],empty);
     strcat(pull_buff[1],aus);
     strcat(pull_buff[1],empty);
     pull_buff[0][8]=pull_buff[1][8]=EOS;

     num_items=2;
     index=((work->verify==VERIFY_ON) ? 0 : 1);
     break;

   case FREQ:     /* wie oben */
     strcpy(pull_buff[0],empty);
     strcat(pull_buff[0],hz50);
     strcat(pull_buff[0],empty);
     strcpy(pull_buff[1],empty);
     strcat(pull_buff[1],hz60);
     strcat(pull_buff[1],empty);
     pull_buff[0][10]=pull_buff[1][10]=EOS;
                  
     num_items=2;
     index=((work->frequency==PAL) ? 0 : 1);
     break;
  }

  /* absolute Button-Koordinaten berechnen */
  objc_offset(disk,button,&button_xywh.g_x,
              &button_xywh.g_y);
  button_xywh.g_w=disk[button].ob_width;
  button_xywh.g_h=disk[button].ob_height;
 
  /* absolute Koordinaten der Dialogbox 
     ermitteln */
  objc_offset(disk,ROOT,&window_xywh.g_x,
    &window_xywh.g_y);
  window_xywh.g_w=disk[ROOT].ob_width;
  window_xywh.g_h=disk[ROOT].ob_height;

  /* Adressen der einzelnen EintrÑge in das 
     öbergabe-Array eintragen */          
  for(i=0; i<num_items; i++)
    pull_adr[i]=pull_buff[i];
 
  /* Pull-Down-MenÅ zeichnen lassen und Index des
     angeklickten Eintrags zurÅckliefern */
  checked=(*params->do_pulldown)
    (pull_adr,num_items,index,IBM,
    &button_xywh,&window_xywh);

  /* wenn Eintrag angeklickt wurde... */
  if (checked>=0)
  {
    /* ...dann entsprechend reagieren */
    switch (button)
    {
      case STEPA:  
        work->step_a=ms[checked];
        if (get_version()<0x104)
        {
          work->step_b=ms[checked];
          into_resource(work);
          redraw_object(disk,STEPB);
        }
        break;

      case STEPB:  
        work->step_b=ms[checked];
        if (get_version()<0x104)
        {
          work->step_a=ms[checked];
          into_resource(work);
          redraw_object(disk,STEPA);
        }
        break;

      case VERIFY: 
        work->verify=((checked==0) ? VERIFY_ON : 
                                     VERIFY_OFF);
        break;

      case FREQ:   
        work->frequency=((checked==0) ? PAL : 
                                        NTSC);
        break;
    }

    /* neue Werte in die Dialogbox eintragen */
    into_resource(work);
  }

  /* Button neu zeichnen */
  disk[button].ob_state &= ~SELECTED;
  redraw_object(disk,button);
}


/***********************************************/
/* Dialogbox im Fenster zentrieren             */
/* öbergabeparameter: Zeiger auf Dialogbox,    */
/*                    Koordinaten              */
/* RÅckgabe: indirekt Åber Koordinaten         */
/***********************************************/

VOID wind_center(OBJECT *tree,WORD *x,WORD *y,
                              WORD *w,WORD *h)
{
  tree[ROOT].ob_x=disk[ROOT].ob_x+
                  (disk[ROOT].ob_width-
                  tree[ROOT].ob_width)/2;
  tree[ROOT].ob_y=disk[ROOT].ob_y+
                  (disk[ROOT].ob_height-
                  tree[ROOT].ob_height)/2;
    
  *x=tree[ROOT].ob_x;
  *y=tree[ROOT].ob_y;
  *w=tree[ROOT].ob_width;
  *h=tree[ROOT].ob_height;
}


/***********************************************/
/* Liefert Adresse einer Dialogbox             */
/* (neue rsrc_gaddr()-Routine)                 */
/* öbergabeparamter: Baum-Index                */
/* RÅckgabe: Zeiger auf Dialogbox              */
/***********************************************/

OBJECT *get_traddr(WORD tree_index)
{
  WORD i,j;
  
  for (i=0,j=0; i<=tree_index; i++)
    while (rs_object[j++].ob_next!=-1);

  return(&rs_object[--j]);    
}


/***********************************************/
/* Auslesen der Systemparameter                */
/* öbergabeparameter: Zeiger auf Status        */
/* RÅckgabe: Systempar. indirekt Åber Status   */
/***********************************************/

VOID get_values(STATUS *work)
{
  work->step_a=set_step(0,-1);
  work->step_b=set_step(1,-1);
  work->verify=set_verify(-1);
  work->frequency=set_frequency(-1); 
}


/***********************************************/
/* Harddisk-ID's aus der Dialogbox auslesen    */
/* öbergabeparameter: Zeiger auf Status        */
/* RÅckgabe: Harddisk-IDs indirekt Åber Status */
/***********************************************/

VOID get_id(STATUS *work)
{
  work->controller0=
    disk[UNIT0].ob_spec.tedinfo->te_ptext[0]-'0';
  work->controller1=
    disk[UNIT1].ob_spec.tedinfo->te_ptext[0]-'0';
  work->unit0=
    disk[UNIT0].ob_spec.tedinfo->te_ptext[1]-'0';
  work->unit1=
    disk[UNIT1].ob_spec.tedinfo->te_ptext[1]-'0';
}


/***********************************************/
/* Ermitteln der Betriebssystem-Version        */
/* öbergabeparameter: keine                    */
/* RÅckgabe: Tos-Version                       */
/***********************************************/

UWORD get_version(VOID)
{
  LONG ssp;
  SYSHDR **syshdr=(SYSHDR **)_sysbase;
  UWORD version;
  
  ssp=Super((VOID *)0L);
  version=(*syshdr)->os_version;
  Super((VOID *)ssp);
  return(version);
}


/***********************************************/
/* Neusetzen der verÑnderten Parameter         */
/* öbergabeparameter: Zeiger auf Status vor    */
/*                    und nach dem Dialog      */
/* RÅckgabe: keine                             */
/***********************************************/

VOID set_values(STATUS status, STATUS work)
{
  if (status.step_a!=work.step_a)
    set_step(0,work.step_a);
  if (status.step_b!=work.step_b)
    set_step(1,work.step_b);
  if (status.verify!=work.verify)
    set_verify(work.verify);
  if (status.frequency!=work.frequency)
    set_frequency(work.frequency);
}


/***********************************************/
/* Harddisk-ID's in die Dialogbox eintragen    */
/* öbergabeparameter: Zeiger auf Status        */
/* RÅckgabe: keine                             */
/***********************************************/

VOID set_id(STATUS *work)
{
  disk[UNIT0].ob_spec.tedinfo->te_ptext[0]=
                          work->controller0+'0';
  disk[UNIT1].ob_spec.tedinfo->te_ptext[0]=
                          work->controller1+'0';
  disk[UNIT0].ob_spec.tedinfo->te_ptext[1]=
                                work->unit0+'0';
  disk[UNIT1].ob_spec.tedinfo->te_ptext[1]=
                                work->unit1+'0';
}    


/***********************************************/
/* Setzen und Ermitteln der Steprate           */
/* öbergabeparameter: Laufwerksnummer,         */
/*                    Steprate oder -1         */
/* RÅckgabe: (alte) Steprate                   */
/***********************************************/

WORD set_step(WORD drive,WORD step)
{
  LONG ssp;
  WORD step_rate;
  VOID (**hdv)(VOID)=(VOID *)hdv_init;

  if (get_version()<0x104)
    if (step>=0)
    {
      ssp=Super((VOID *)0L);
      step_rate=*(WORD *)seekrate;
      *(WORD *)seekrate=step;
      (*hdv)();
      Super((VOID *)ssp);
      Getbpb(drive);  /* Nachlaufen verhindern */
    }
    else
    {
      ssp=Super((VOID *)0L);
      step_rate=*(WORD *)seekrate;
      Super((VOID *)ssp);
    }
  else
    step_rate=Floprate(drive,step);

  return(step_rate);
}


/***********************************************/
/* Setzen und Ermitteln des Verify-Flags       */
/* öbergabeparameter: neue Einstellung oder -1 */
/* RÅckgabe: (altes) Verify-Flag               */
/***********************************************/

WORD set_verify(WORD verify)
{
  WORD old_verify;
  LONG ssp;
  
  ssp=Super((VOID *)0L);
  old_verify=*(WORD *)_fverify;
  
  if (verify>=0)
    *(WORD *)_fverify=verify;
  Super((VOID *)ssp);
  
  return(old_verify);
}


/***********************************************/
/* Setzen und Ermitteln der Bild-Frequenz      */
/* öbergabeparameter: neue Einstellung oder -1 */
/* RÅckgabe: (alte) Frequenz                   */
/***********************************************/

WORD set_frequency(WORD frequency)
{
  WORD old_frequency;
  LONG ssp;
   
  ssp=Super((VOID *)0L);
  old_frequency=*(WORD *)palmode;
  
  /* bei TT Setzen nicht mîglich! */
  if (frequency>=0)
  {
    frequency &= 1;
    *(WORD *)palmode=frequency;
    *(BYTE *)sync_mode=(BYTE)frequency<<1;    
  }  
  Super((VOID *)ssp);
  
  return(old_frequency);
}


/***********************************************/
/* Parken der Festplatte und nach Parken       */
/* zum Abschalten auffordern.                  */
/* öbergabeparameter: keine                    */
/* RÅckgabe: Erfolg/Miûerfolg                  */
/***********************************************/

WORD switch_off(VOID)
{
  WORD x,y,w,h;
  WORD button;
  WORD ret1=-1;
  WORD ret2=-1;
  STATUS work;
    
  /* Harddisk parken? */
  if ((disk[UNIT0].ob_state & SELECTED) ||
      (disk[UNIT1].ob_state & SELECTED))
  {
    /* ja, ID's auslesen */
    get_id(&work);

    /* Alertbox zeichen */
    wind_center(sure,&x,&y,&w,&h);
    form_dial(FMD_START,0,0,0,0,x-3,y-3,w+6,h+6);
    objc_draw(sure,ROOT,MAX_DEPTH,
                                x-3,y-3,w+6,h+6);
    button=form_do(sure,0);
    form_dial(FMD_FINISH,0,0,0,0,
                                x-3,y-3,w+6,h+6);
    sure[button].ob_state &= ~SELECTED;
    
    /* angeklickten Button auswerten */
    switch (button)
    {
      case SUREOK:    
        /* gewÑhlte Harddisk(s) parken, sofern
           ID's innerhalb des Bereiches */
        if (disk[UNIT0].ob_state & SELECTED)
          if ((work.controller0>=0) && 
              (work.controller0<=7) && 
              (work.unit0>=0) && 
              (work.unit0<=7))
            ret1=hd_park(work.controller0,
                         work.unit0);

        if (disk[UNIT1].ob_state & SELECTED)
          if ((work.controller1>=0) && 
              (work.controller1<=7) && 
              (work.unit1>=0) &&
              (work.unit1<=7))
            ret2=hd_park(work.controller1,
                         work.unit1);

        /* Parken bei mind. einer Harddisk 
           gelungen? */
        if (!ret1 || !ret2)
        {
          /* Aufforderung zum Abschalten */     
          form_center(switchoff,&x,&y,&w,&h);
          form_dial(FMD_START,0,0,0,0,x,y,w,h);
          objc_draw(switchoff,ROOT,
                    MAX_DEPTH,x,y,w,h);
          while (TRUE); 
        }
        else
        {
          /* Fehlermeldung ausgeben */
          wind_center(error,&x,&y,&w,&h);
          objc_draw(error,ROOT,MAX_DEPTH,
                    x-3,y-3,w+6,h+6);
          form_do(error,0);
          error[MIST].ob_state &= ~SELECTED;
        }
        break;
                      
      case SURECANC:  
        sure[SURECANC].ob_state &= ~SELECTED;
        break;
    }
    disk[UNIT0].ob_state &= ~SELECTED;
    disk[UNIT1].ob_state &= ~SELECTED;
    return(FALSE);                  
  }
  else 
    return(TRUE);
}





