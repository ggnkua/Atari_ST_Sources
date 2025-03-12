/***********************************************/
/* Datei: BOOT.C                               */
/* ------------------------------------------- */
/* Modul: BOOT.CPX                Version 1.00 */
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


/* keine Variablen zu sichern */

#include "boot.rsh"
#include "boot.h"
#include "xcontrol.h"


/* Definitionen zur besseren Lesbarkeit ------ */

#define TRUE           1      /* Standard-Def. */
#define FALSE          0
#define EOS            '\0'
#define NIL            0L

#define MESSAGE        -1     /* Message-Event */

#define MAX_ACTIVE     50   /* maximale Anzahl */
#define MAX_INACTIVE   50   /* von EintrÑgen   */
#define VISIBLE        5    /* sichtbare Eintr.*/
#define NAME_LENGTH    8+1  /* LÑnge Eintrag   */

#define MIN_SIZE       6    /* Slider-Grîûe    */

#define ACTIVE         TRUE   /* Flags */
#define INACTIVE       FALSE  
#define HORIZONTAL     1
#define VERTICAL       0
#define ACC            1
#define PRG            0

#define _bootdev       0x447 /* Systemvariable */


/* globale Variablen ------------------------- */

typedef struct
{
  WORD max_num;  /* Anzahl maximaler EintrÑge */
  WORD num;      /* Anzahl EintrÑge */
  WORD begin;    /* erster sichtbarer Eintrag */
  WORD type;     /* ACC oder PRG */
  WORD selected; /* Nr. selektierter Eintrag */
  char (*buffer)[NAME_LENGTH];  /* Buffer fÅr
                                Programmnamen */
} BD;   /* Buffer-Deskriptor */

BD active, inactive;  /* Deskriptoren fÅr aktive 
                        und inaktive Programme */

CPX_PARAMS *params; /* vom Kontrollfeld Åber-
                       gebener Zeiger auf die 
                       Kontrollfeld-Funktionen */

OBJECT *boot;        /* Zeiger auf Dialogboxen */
OBJECT *error;

WORD scroll_param;   /* öbergabe-Parameter fÅr's 
                        Scrollen */

             /* Indices der Dialogbox-EintrÑge */
WORD act[VISIBLE]={ ACTIVE1, ACTIVE2, ACTIVE3, 
                    ACTIVE4, ACTIVE5 };
WORD inact[VISIBLE]= { INACTIV1, INACTIV2, 
                  INACTIV3, INACTIV4, INACTIV5 };

char empty[]="";      /* Strings fÅr Dialogbox */
char underlined[]="________";
char acc[]="*.ACC";
char prg[]="*.PRG";
char activate[]="ACC aktivieren";
char deactivate[]="ACC deaktivieren";


/* Prototypen fÅr Turbo-C -------------------- */

char boot_device(VOID);
VOID change_object(OBJECT *tree, WORD object,
                   WORD state);
VOID copy(BD *dest, BD *source, WORD index);
WORD get_entry(WORD object);
OBJECT *get_traddr(WORD tree_index);
CPX_INFO * cdecl init(CPX_PARAMS *params);
VOID init_bd(char (*act_buff)[NAME_LENGTH], 
             char (*inact_buff)[NAME_LENGTH]);
VOID init_slider(WORD *slider1_pos, 
                 WORD *slider2_pos, WORD draw);
WORD cdecl main(GRECT *curr_wind);
VOID into_resource(BD *bd, WORD draw);
VOID move_vslider(OBJECT *tree, WORD parent, 
                  WORD slider, WORD *slider_pos, 
                  BD *bd);
VOID pos_vslider(OBJECT *tree, WORD parent, 
                 WORD slider, WORD *slider_pos, 
                 BD *bd);
VOID pulldown(WORD *slider1_pos, 
              WORD *slider2_pos);
VOID read_config(char *type, BD *descriptor);
VOID redraw_object(OBJECT *tree, WORD object);
VOID refresh(WORD active_flag, WORD object);
VOID scroll_down(VOID);
VOID scroll_up(VOID);
VOID unselect(WORD *array);
VOID rename_file(VOID);
VOID warning(VOID);
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
  static CPX_INFO info={ main,0L,0L,0L,0L,
                         0L,0L,0L,0L,0L };
                         
  if (par->booting)  /* bei Laden des Headers */
    return((CPX_INFO *)1L);
  else /* Aufruf bei Laden des Programms */
  {    /* => Lîschen aller globalen Variablen! */
    params=par;  /* Zeiger retten! */

    /* Resource relozieren */
    if (!params->rsc_init)
      (*params->do_resource)(NUM_OBS,NUM_FRSTR,
       NUM_FRIMG,NUM_TREE,rs_object,rs_tedinfo,
       rs_strings,rs_iconblk,rs_bitblk,rs_frstr,
       rs_frimg,rs_trindex,rs_imdope);
  
    /* globale Variablen initialisieren */
    boot=get_traddr(BOOT);
    error=get_traddr(ERROR);
    strncpy(activate,"ACC",3);
    strncpy(deactivate,"ACC",3);
        
    /* Dialogbox initialisieren */
    boot[ACTION].ob_flags=NONE;
    boot[ACTION].ob_spec.tedinfo->te_ptext=empty;
    strcpy(boot[TYP].ob_spec.free_string,acc);
    
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
  WORD msg_buff[8];
  WORD button;
  WORD abort_flag=FALSE;
  char active_buff[MAX_ACTIVE][NAME_LENGTH];
  char inactive_buff[MAX_INACTIVE][NAME_LENGTH];
  WORD slider1_pos;
  WORD slider2_pos;
  WORD increment;
  VOID (*function)();
  WORD max;
  
  /* Koordinaten der Dialogbox setzen */
  boot[ROOT].ob_x=curr_wind->g_x;
  boot[ROOT].ob_y=curr_wind->g_y;

  /* Buffer-Deskriptoren initialiseren */
  init_bd(active_buff,inactive_buff);

  /* Konfiguration einlesen... */
  read_config("*.ACC",&active);
  read_config("*.ACX",&inactive);

  /* ...und in die Dialogbox eintragen */
  into_resource(&active,FALSE);
  into_resource(&inactive,FALSE);

  /* Slider-Grîûe und Position initialisieren */
  init_slider(&slider1_pos,&slider2_pos,FALSE);

  /* und Dialogbox zeichnen */
  objc_draw(boot,ROOT,MAX_DEPTH,boot[ROOT].ob_x,
            boot[ROOT].ob_y,boot[ROOT].ob_width,
            boot[ROOT].ob_height);

  /* Dialogbox abarbeiten, bis ein Exit-Objekt
     angeklickt wurde */
  do
  {
    /* neuer form_do()-Aufruf */
    button=(*params->do_form)(boot,0,msg_buff);
      
    /* Doppelklick ausmaskieren */
    if (button>=0)
      button &= 0x7fff;
  
    /* Slider-Variablen setzen */
    increment=1;
    function=scroll_up;
    
    /* angeklicktes Objekt auswerten */
    switch (button)
    {
      /* Name im "Aktiv"-Fenster angeklickt */
      case ACTIVE1:  
      case ACTIVE2:
      case ACTIVE3:
      case ACTIVE4:
      case ACTIVE5: 
        refresh(ACTIVE,button);
        break;
                    
      /* Name im "Inaktiv"-Fenster angeklickt */
      case INACTIV1:  
      case INACTIV2:  
      case INACTIV3:
      case INACTIV4:
      case INACTIV5:  
        refresh(INACTIVE,button);
        break;
      
      /* Datei aktivieren/deaktivieren */
      case ACTION:    
        rename_file();
        into_resource(&active,TRUE);
        into_resource(&inactive,TRUE);
        init_slider(&slider1_pos,&slider2_pos,
                    TRUE);
        refresh(ACTIVE,button);
        break;
    
      /* "Pfeil" im "Aktiv"-Fenster angeklickt */
      case ACT_DOWN:  
        increment=-1;
        function=scroll_down;

      case ACT_UP:    
        scroll_param=ACTIVE;
        max=((max=active.num-VISIBLE)<0) ? 0 :
              max; 
        (*params->inc_slider)(boot,PARENT1,
          SLIDER1,button,increment,0,max,
          &slider1_pos,VERTICAL,function);      
        break;
      
      /* "Pfeil" im "Inaktiv"-Fenster */
      case INACT_DO:  
        increment=-1;
        function=scroll_down;
      
      case INACT_UP:  
        scroll_param=INACTIVE;
        max=((max=inactive.num-VISIBLE)<0) ? 0 : 
              max;
        (*params->inc_slider)(boot,PARENT2,
          SLIDER2,button,increment,0,max,
          &slider2_pos,VERTICAL,function);      
        break;
                                                 
      /* Slider angeklickt */   
      case SLIDER1:   
        move_vslider(boot,PARENT1,SLIDER1,
                     &slider1_pos,&active);
        break;     
                                       
      case SLIDER2:   
        move_vslider(boot,PARENT2,SLIDER2,
                     &slider2_pos,&inactive);
        break;

      /* Slider-Hintergrund angeklickt */
      case PARENT1:   
        pos_vslider(boot,PARENT1,SLIDER1,
                    &slider1_pos,&active);
        break;
                      
      case PARENT2:   
        pos_vslider(boot,PARENT2,SLIDER2,
                    &slider2_pos,&inactive);
        break;

      /* "Anzeige-Typ" angeklickt */
      case TYP:       
        pulldown(&slider1_pos,&slider2_pos);
        break;
                      
      /* Dialogbox verlassen */
      case QUIT:      
        abort_flag=TRUE;
        break;
 
      /* Nachricht eingetroffen */
      case MESSAGE:
        switch (msg_buff[0])
        {
          case WM_REDRAW:   /* nicht notwendig */
            break;

          case WM_CLOSED: /* nichts zu sichern */

          case AC_CLOSE:
            abort_flag=TRUE;
            break;
        }
        break;  
    }
  }
  while (!abort_flag);
  boot[button].ob_state &= ~SELECTED;
  return(FALSE);
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
/* Einlesen der aktivierten und deaktivierten  */
/* Programme                                   */
/* öbergabeparameter: Programmtyp, Adresse     */
/*                    des Buffer-Deskriptors   */
/* RÅckgabe: keine                             */
/***********************************************/

VOID read_config(char *type, BD *descriptor)
{
  DTA *dta=Fgetdta();
  WORD i=0;
  WORD j,k;
  char path[20];
  path[0]=boot_device();
  
  /* Pfad je nach Typ aufbauen */
  if (!strcmp(type,"*.ACC") || 
      !strcmp(type,"*.ACX"))
    strcpy(&path[1],":\\");
  else
    strcpy(&path[1],":\\AUTO\\");
  strcat(path,type);  
   
  /* alle Namen dieses Typs einlesen */
  if (!Fsfirst(path,0))
    do
    {
      j=0;
      while (dta->d_fname[j]!='.')
        descriptor->buffer[i][j]=
                              dta->d_fname[j++]; 
      for (k=j; k<NAME_LENGTH-1; k++)
        descriptor->buffer[i][k]=' ';
      descriptor->buffer[i++][k]=EOS;
    }
    while (!Fsnext() && (i<descriptor->max_num));
  descriptor->num=i;
  if (descriptor->num==descriptor->max_num)
    warning();
}


/***********************************************/
/* Im Fenster selektierten Namen deselektieren */
/* öbergabeparameter: Adresse eines Feldes,    */
/*                    das die Indices der Fen- */
/*                    stereintrÑge enthÑlt     */
/* RÅckgabe: keine                             */
/***********************************************/

VOID unselect(WORD *array)
{
  WORD i;
   
  for (i=0; i<VISIBLE; i++)
    if (boot[array[i]].ob_state & SELECTED)
    {
      change_object(boot,array[i],NORMAL);
      if (array==act)
        active.selected=-1;
      else
        inactive.selected=-1;
      break;
    }
}


/***********************************************/
/* Objekt mit neuem Status zeichnen            */
/* öbergabeparameter: Zeiger auf Dialogbox,    */
/*                    Objekt-Index, neuer      */
/*                    Status                   */
/***********************************************/

VOID change_object(OBJECT *tree, WORD object,
                   WORD state)
{
  WORD x,y;

  objc_offset(tree,object,&x,&y);
  objc_change(tree,object,0,x,y,
              tree[object].ob_width,
              tree[object].ob_height,state,TRUE);
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
/* Selektierten Eintrag im Fenster deselektie- */
/* ren und je nach angeklicktem Eintrag den    */
/* Aktions-Knopf neu zeichnen                  */
/* öbergabeparameter: Fensterkennung,          */
/*                    angeklicktes Objekt      */
/* RÅckgabe: keine                             */
/***********************************************/

VOID refresh(WORD active_flag, WORD object)
{ 
  /* Ausgabetext bestimmen */
  char *status=((active_flag==ACTIVE) ? 
                 deactivate : activate);
  
  /* selektierten Eintrag im anderen Fenster
     deselektieren */
  unselect((active_flag==ACTIVE) ? inact : act);
  
  /* kein gÅltiger Eintrag angeklickt */
  if ((boot[object].ob_spec.tedinfo->te_ptext==
       underlined) || (object==ACTION))
  {
    /* selektierten Eintrag im aktuellen Fenster
       deselektieren */
    unselect((active_flag==ACTIVE) ? 
              act : inact);
   
    /* Aktions-Knopf abschalten */
    boot[ACTION].ob_spec.tedinfo->te_ptext=empty;
    boot[ACTION].ob_state &= ~SELECTED;
    boot[ACTION].ob_flags=NONE;
    redraw_object(boot,ACTION);
  }
  else
  { 
    /* gÅltiger Eintrag angeklickt */
    if (boot[ACTION].ob_spec.tedinfo->te_ptext!=
        status)
    {
      /* Aktions-Knopf einschalten */
      boot[ACTION].ob_spec.tedinfo->te_ptext=
        status;
      boot[ACTION].ob_flags=SELECTABLE|TOUCHEXIT;
      redraw_object(boot,ACTION);
    }

    /* Index des selektierten Eintrags merken */
    if (status==activate)
      inactive.selected=inactive.begin+
                        get_entry(object);
    else
      active.selected=active.begin+
                      get_entry(object);
  }
}


/***********************************************/
/* Index des angeklickten Eintrags ermitteln   */
/* öbergabeparameter: angeklicktes Objekt      */
/* RÅckgabe: gesuchter Index                   */
/***********************************************/

WORD get_entry(WORD object)
{
  WORD i;
  
  for (i=0; i<VISIBLE; i++)
    if ((object==act[i]) || (object==inact[i]))
      break;
  return(i);
}


/***********************************************/
/* AusgewÑhlte Datei umbenennen                */
/* öbergabeparameter: keine                    */
/* RÅckgabe: keine                             */
/***********************************************/

VOID rename_file(VOID)
{
  WORD i;
  WORD *array;
  WORD index;
  WORD begin;
  char path1[30],path2[30];
  char (*buffer)[NAME_LENGTH];
  char flag=boot[ACTION].ob_spec.tedinfo->
                                   te_ptext[4];

  if (flag=='a')
  {
    /* Adressen fÅr Datei aktivieren */
    array=inact;
    begin=inactive.begin;
    buffer=inactive.buffer;
  }
  else
  {
    /* Adressen fÅr Datei deaktivieren */
    array=act;
    begin=active.begin;
    buffer=active.buffer;
  }
  
  /* Index des selektierten Eintrags ermitteln */
  for (i=0; i<VISIBLE; i++)
    if (boot[array[i]].ob_state & SELECTED)
      break;
  index=begin+i;
  
  /* Pfad je nach Programmtyp erstellen */
  path1[0]=boot_device();
  strcpy(&path1[1],((active.type==ACC) ? ":\\" : 
                    ":\\AUTO\\"));
  strcat(path1,buffer[index]);

  for (i=(WORD)strlen(path1)-1; i>=0; i--)
    if (path1[i]!=' ')
    {
      path1[++i]=EOS;
      break;
    }

  strcat(path1,((active.type==ACC) ? 
                ".ACC" : ".PRG"));
  strcpy(path2,path1);
  path1[strlen(path1)-1]='X';
  
  /* Datei umnennen */
  if (flag=='a')
  {
    if (Frename(0,path1,path2)>=0)
      copy(&active,&inactive,index);
  }
  else
  {
    if (Frename(0,path2,path1)>=0)  
      copy(&inactive,&active,index);
  } 
}    


/***********************************************/
/* Umbenannte Datei aus der einen Liste ent-   */
/* fernen und in die andere Liste eintragen    */
/* öbergabeparameter: Zeiger auf Ziel- und     */
/*                    Quell-Deskriptor,        */
/*                    Index des zu entfernen-  */
/*                    den Eintrags             */
/* RÅckgabe: keine                             */
/***********************************************/

VOID copy(BD *dest, BD *source, WORD index)
{
  WORD i;
   
  /* Eintrag in Ziel-Liste eintragen */
  if (dest->num<dest->max_num)
    strcpy(dest->buffer[dest->num++],
           source->buffer[index]);
  else
    warning();
     
  /* Eintrag aus der Quell-Liste lîschen */
  source->num--;
  for (i=index; i<source->num; i++)
    strcpy(source->buffer[i],
           source->buffer[i+1]);
  source->begin=dest->begin=0;
}


/***********************************************/
/* Warnung fÅr Listen-öberlauf ausgeben        */
/* öbergabeparameter: keine                    */
/* RÅckgabe: keine                             */
/***********************************************/

VOID warning(VOID)
{
  WORD x,y,w,h;
  
  /* Namens-Liste voll */
  wind_center(error,&x,&y,&w,&h);    
  objc_draw(error,ROOT,MAX_DEPTH,x-3,y-3,w+6,h+6);
  form_do(error,0);
  error[MIST].ob_state &= ~SELECTED;
  objc_draw(boot,ROOT,MAX_DEPTH,boot[ROOT].ob_x,
            boot[ROOT].ob_y,boot[ROOT].ob_width,
            boot[ROOT].ob_height);
}


/***********************************************/
/* Boot-Laufwerk ermitteln                     */
/* öbergabeparameter: keine                    */
/* RÅckgabe: Boot-Laufwerk                     */
/***********************************************/

char boot_device(VOID)
{
  LONG ssp;
  char boot;
  
  ssp=Super((VOID *)0L);
  boot=*(BYTE *)_bootdev+'A';
  Super((VOID *)ssp);
  return(boot);
}


/***********************************************/
/* Im Fenster nach oben scrollen               */
/* öbergabeparameter: Fensterkennung indirekt  */
/*                    Åber scroll_param        */
/* RÅckgabe: keine                             */
/***********************************************/

VOID scroll_up(VOID)
{
  BD *bd=((scroll_param==ACTIVE) ? 
          &active : &inactive);
  
  if (bd->begin>0)
  {
    bd->begin--;
    into_resource(bd,TRUE);
  }
}


/***********************************************/
/* Im Fenster nach unten scrollen              */
/* öbergabeparameter: Fensterkennung indirekt  */
/*                    Åber scroll_param        */
/* RÅckgabe: keine                             */
/***********************************************/

VOID scroll_down(VOID)
{
  BD *bd=((scroll_param==ACTIVE) ? 
          &active : &inactive);
  
  if (bd->begin+VISIBLE<bd->num)
  {
    bd->begin++;
    into_resource(bd,TRUE);
  }
}


/***********************************************/
/* Namensliste in die Dialogbox eintragen      */
/* öbergabeparameter: Zeiger auf Buffer-       */
/*                    Deskriptor, Zeichen-Flag */
/* RÅckgabe: keine                             */
/***********************************************/

VOID into_resource(BD *bd, WORD draw)
{
  WORD i;
  WORD *array=((bd==&active) ? act :inact);
   
  for (i=0; i<VISIBLE; i++)
    if (bd->begin+i<bd->num)
    {
      /* Eintrag vorhanden */
      boot[array[i]].ob_spec.tedinfo->te_ptext=
        bd->buffer[bd->begin+i];
      boot[array[i]].ob_flags=SELECTABLE | 
        RBUTTON | TOUCHEXIT;
      if (bd->begin+i==bd->selected)
        boot[array[i]].ob_state |= SELECTED;
      else
        boot[array[i]].ob_state &= ~SELECTED;
    }
    else
    {
      /* kein Eintrag mehr */
      boot[array[i]].ob_spec.tedinfo->te_ptext=
        underlined;
      boot[array[i]].ob_flags=TOUCHEXIT;
      boot[array[i]].ob_state &= ~SELECTED;
    }

  /* Liste neu ausgeben */
  if (draw)  
    redraw_object(boot,(array==act) ? 
                  ACTWIND : INACWIND);
}


/***********************************************/
/* Vertikalen Slider positionieren             */
/* öbergabeparameter: Zeiger auf Dialogbox,    */
/*                    Index Slider-Hintergrund,*/
/*                    Index Slider, Zeiger auf */
/*                    Slider-Position, Buffer- */
/*                    Deskriptor               */
/* RÅckgabe: keine                             */
/***********************************************/

VOID pos_vslider(OBJECT *tree, WORD parent, 
                 WORD slider, WORD *slider_pos, 
                 BD *bd)
{
  WORD my,y;
  WORD dummy;
  WORD max,temp;
  
  /* Koordinaten einlesen */
  graf_mkstate(&dummy,&my,&dummy,&dummy);
  objc_offset(tree,slider,&dummy,&y);
 
  /* je nach Mausposition entweder nach oben 
     oder unten scrollen */
  if (my<y)
    *slider_pos=((max=bd->num-VISIBLE)<=
                (temp=*slider_pos+VISIBLE)) ? 
                 max : temp;
  else
    *slider_pos=((max=*slider_pos-VISIBLE)<0) ? 
                 0 : max;

  /* Slider neu positionieren */
  max=((max=bd->num-VISIBLE)<0) ? 0 : max;
  (*params->pos_vslider)(tree,parent,slider,
                         *slider_pos,0,max,NIL);

  /* Namensliste neu ausgeben */
  bd->begin=((max=bd->num-VISIBLE-*slider_pos)<0)
             ? 0 : max;
  into_resource(bd,TRUE);
  redraw_object(tree,parent);
}


/***********************************************/
/* Vertikalen Slider verschieben               */
/* öbergabeparameter: Zeiger auf Dialogbox,    */
/*                    Index Slider-Hintergrund,*/
/*                    Index Slider, Zeiger auf */
/*                    Slider-Position, Buffer- */
/*                    Deskriptor               */
/* RÅckgabe: keine                             */
/***********************************************/

VOID move_vslider(OBJECT *tree, WORD parent, 
                  WORD slider, WORD *slider_pos, 
                  BD* bd)
{ 
  WORD max;
  
  max=((max=bd->num-VISIBLE)<0) ? 0 : max;
  (*params->move_vslider)(tree,parent,slider,0,
                          max,slider_pos,NIL);

  /* je nach Slider-Position die Namensliste
     neu ausgeben */
  bd->begin=((max=bd->num-VISIBLE-*slider_pos)<0)
              ? 0 : max;
  into_resource(bd,TRUE);
}


/***********************************************/
/* Buffer-Deskriptoren initialisieren          */
/* öbergabeparameter: Zeiger auf beide Buffer  */
/* RÅckgabe: keine                             */
/***********************************************/

VOID init_bd(char (*act_buff)[NAME_LENGTH],
             char (*inact_buff)[NAME_LENGTH])
{
  active.buffer=act_buff;
  active.max_num=MAX_ACTIVE;
  active.begin=0;
  active.type=ACC;
  active.selected=-1;
  
  inactive.buffer=inact_buff;
  inactive.max_num=MAX_INACTIVE;
  inactive.begin=0;
  inactive.type=ACC;
  inactive.selected=-1;
}


/***********************************************/
/* Slider-Position und -Grîûe initialisieren   */
/* öbergabeparameter: Zeiger auf die beiden    */
/*                    Sliderpositionen,        */
/*                    Zeichenflag              */
/* RÅckgabe: keine                             */
/***********************************************/

VOID init_slider(WORD *slider1_pos, 
                 WORD *slider2_pos, WORD draw)
{
  WORD max;
  
  /* Slider-Grîûe einstellen */
  (*params->size_slider)(boot,PARENT1,SLIDER1,
                         active.num,VISIBLE,
                         VERTICAL,MIN_SIZE);
  (*params->size_slider)(boot,PARENT2,SLIDER2,
                         inactive.num,VISIBLE,
                         VERTICAL,MIN_SIZE);

  /* Slider-Position einstellen */
  *slider1_pos=((max=active.num-VISIBLE)<0) ? 
                0 : max;
  (*params->pos_vslider)(boot,PARENT1,SLIDER1,
                         *slider1_pos,0,max,NIL);
  *slider2_pos=((max=inactive.num-VISIBLE)<0) ? 
                0 : max;
  (*params->pos_vslider)(boot,PARENT2,SLIDER2,
                         *slider2_pos,0,max,NIL);

  /* Slider neu zeichnen */
  if (draw)
  {
    redraw_object(boot,PARENT1);
    redraw_object(boot,PARENT2);
  }
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
  tree[ROOT].ob_x=boot[ROOT].ob_x+
                  (boot[ROOT].ob_width-
                  tree[ROOT].ob_width)/2;
  tree[ROOT].ob_y=boot[ROOT].ob_y+
                  (boot[ROOT].ob_height-
                  tree[ROOT].ob_height)/2;
    
  *x=tree[ROOT].ob_x;
  *y=tree[ROOT].ob_y;
  *w=tree[ROOT].ob_width;
  *h=tree[ROOT].ob_height;
}


/***********************************************/
/* Pulldown-MenÅ generieren, darstellen und    */
/* auswerten.                                  */
/* öbergabeparameter: Zeiger auf Slider-       */
/*                    Positionen               */
/* RÅckgabe: keine                             */
/***********************************************/

VOID pulldown(WORD *slider1_pos, 
              WORD *slider2_pos)
{
  WORD index,checked;
  GRECT button_xywh,window_xywh;
  char *pull_adr[2];
  char pull_buff[2][15];

  /* Texte des MenÅs in Buffer eintragen */
  strcpy(pull_buff[0],"  ");
  strcat(pull_buff[0],acc);
  strcat(pull_buff[0],"  ");
  
  strcpy(pull_buff[1],"  ");
  strcat(pull_buff[1],prg);
  strcat(pull_buff[1],"  ");
 
  /* Index des abgehakten Eintrags */
  index=(!strcmp(boot[TYP].ob_spec.free_string,
         acc) ? 0 : 1);
  
  /* absolute Button-Koordinaten berechnen */
  objc_offset(boot,TYP,&button_xywh.g_x,
              &button_xywh.g_y);
  button_xywh.g_w=boot[TYP].ob_width;
  button_xywh.g_h=boot[TYP].ob_height;
 
  /* absolute Koordinaten der Dialogbox 
     ermitteln */
  objc_offset(boot,ROOT,&window_xywh.g_x,
    &window_xywh.g_y);
  window_xywh.g_w=boot[ROOT].ob_width;
  window_xywh.g_h=boot[ROOT].ob_height;

  /* Adressen der einzelnen EintrÑge in das 
     öbergabe-Array eintragen */
  pull_adr[0]=pull_buff[0];
  pull_adr[1]=pull_buff[1];
 
  /* Pull-Down-MenÅ zeichnen lassen und Index des
     angeklickten Eintrags zurÅckliefern */
  checked=(*(params->do_pulldown))
    (pull_adr,2,index,IBM,
    &button_xywh,&window_xywh);

  /* wenn Eintrag angeklickt wurde... */
  if (checked>=0) 
  {
    /* ...dann neuer Eintrag im Button */
    boot[TYP].ob_spec.free_string=
                      ((checked==0) ? acc : prg);
    boot[TYP].ob_state &= ~SELECTED;
    redraw_object(boot,TYP);

    if (checked!=index)
    {
      /* je nach selektiertem Eintrag neue 
         Konfiguration einlesen */
      switch (checked)
      {
        case 0:    
          strncpy(activate,"ACC",3);
          strncpy(deactivate,"ACC",3);
          active.type=inactive.type=ACC;
          read_config("*.ACC",&active);
          read_config("*.ACX",&inactive);
          break;
         
        case 1:    
          strncpy(activate,"PRG",3);
          strncpy(deactivate,"PRG",3);
          active.type=inactive.type=PRG;
          read_config("*.PRG",&active);
          read_config("*.PRX",&inactive);
          break;
      }

      /* neue Konfiguration anzeigen */
      boot[ACTION].ob_flags=NONE;
      boot[ACTION].ob_spec.tedinfo->te_ptext=
                                          empty;
      redraw_object(boot,ACTION);
 
      active.begin=inactive.begin=0;
      active.selected=inactive.selected=-1;

      into_resource(&active,TRUE);
      into_resource(&inactive,TRUE);

      init_slider(slider1_pos,slider2_pos,TRUE);
     }    
  }
}

