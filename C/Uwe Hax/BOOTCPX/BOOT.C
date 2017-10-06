/*******************************************/
/* File : BOOT.C                           */
/* --------------------------------------- */
/* Module : BOOT.CPX        versie 1.00    */
/* (C) 1990 by MAXON Computer              */
/* Auteurs : Uwe Hax & Oliver Scholz       */
/* Gebruikte Compiler : Turbo-C 2.0        */
/*******************************************/

/* De gebruikelijke header gegevens */

#include <portab.h>
#include <aes.h>
#include <tos.h>
#include <stdlib.h>
#include <string.h>
#include <vdi.h>


/* Geen variabelen om op te slaan */

#include "boot.rsh"
#include "boot.h"
#include "xcontrol.h"


/* Definities voor eem betere leesbaarheid */

#define TRUE			1	/* Standaard def. */
#define FALSE			0
#define EOS				'\0'
#define NIL				0L

#define MESSAGE			-1	/* Message-Event */

#define MAX_ACTIVE		50	/* Maximaal aantal */
#define MAX_INACTIVE	50	/* entries         */
#define VISIBLE			5	/* Zichtbare entries */
#define NAME_LENGTH		8+1	/* Lengte entry */

#define MIN_SIZE		6	/* Slider grootte */

#define ACTIVE			TRUE  /* FLAGS */
#define INACTIVE		FALSE
#define HORIZONTAL		1
#define VERTICAL		0
#define ACC				1
#define PRG				0

#define _bootdev		0x447 /* Systeem variabele */


/* Globale variabelen */

typedef	struct
{
  WORD max_num;			/* Aantal maximale entries */
  WORD num;				/* Aantal entries */
  WORD begin;			/* Eerste zichtbare entry */
  WORD type;			/* ACC of PRG */
  WORD selected;		/* nummer van geselecteerde entry */
  char (*buffer)[NAME_LENGTH]; /* Buffer voor programma namen */
} BD;  /* Buffer descriptoe */

BD active, inactive; 	/* Descriptor voor actieve
						   en niet-actieve programma's */
						   
CPX_PARAMS *params;		/* Van controle-scherm overgenomen
                           pointer op de controle-scherm
                           functies */
                     
OBJECT *boot;			/* Pointer op dialoxg-boxen */
OBJECT *error;

WORD scroll_param;		/* Overgave parameter voor scrollen */


/*   Indecis voor dialogbox entries */
WORD act[VISIBLE]={ ACTIVE1, ACTIVE2,
                    ACTIVE3, ACTIVE4, ACTIVE5 };
WORD inact[VISIBLE]={ INACTIV1, INACTIV2,
                  INACTIV3, INACTIV4, INACTIV5 };
          
char empty[]="";		/* Strings voor dialogboxen */
char underlined[]="________";
char acc[]="*.ACC";
char prg[]="*.PRG";
char activate[]="ACC aktivieren";
char deactivate[]="ACC deaktivieren";


/* Prototypen voor Turbo-C */
char boot_device(VOID);
VOID change_object (OBJECT *tree, WORD object,
                    WORD state );
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


/* Functies */

/*********************************************/
/* Initialisering van het module:            */
/* Overgave parameter : pointer op de ter    */
/*          beschikking staande functies     */
/* 1. Aanroep bij het laden v/d header       */
/*    (par->booting ==TRUE)                  */
/*    Retour : 0 bij set_only, anders 1      */
/* 2. Aanroep bij laden van het eigenlijke   */
/*    programma (par->booting == FALSE)      */
/*    Retour : Adres v/d CPX-info structuur  */
/*********************************************/

CPX_INFO * cdecl init(CPX_PARAMS *par)
{
  static CPX_INFO info={ main,0L,0L,0L,0L,
                         0L,0L,0L,0L,0L };
  
  if (par->booting)  /* bij het laden van de header */
    return((CPX_INFO *)1L);
  else  /* Aanroep bij laden v.h. programma */
  {     /* Wissen van alle globale variabelen */
    params=par;  /* pointers redden */
    
    /* Resource reloceren */
    if (!params->rsc_init)
      (*params->do_resource)(NUM_OBS,NUM_FRSTR,
      NUM_FRIMG,NUM_TREE,rs_object,rs_tedinfo,
      rs_strings,rs_iconblk,rs_bitblk,rs_frstr,
      rs_frimg,rs_trindex,rs_imdope);
      
    /* Globale variabelen initialiseren */
    boot=get_traddr(BOOT);
    error=get_traddr(ERROR);
    strncpy(activate,"ACC",3);
    strncpy(deactivate,"ACC",3);
    
    
    /* Dialogbox initialiseren */
    boot[ACTION].ob_flags=NONE;
    boot[ACTION].ob_spec.tedinfo->te_ptext=empty;
    strcpy(boot[TYP].ob_spec.free_string,acc);
    
    
    /* Adres der CPX_INFO-structuur retour */
    return(&info);
  }
}


/********************************************/
/* Aanroep na dubbelklik op het icon in het */
/* keuze venster : tekenen van de dialogbox */
/* en afhandeling van de buttons.           */
/* Overgave parameters : Coordinaten van    */
/*          het werkbereik van het venster  */
/* Retour : FALSE, als de dialog d.m.v.     */
/*          do_form() wordt afgewerkt,      */
/*          TRUE, in het geval dat eigen    */
/*          event routines worden gebruikt  */
/********************************************/

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
  
  /* Coordinaten voor de dialogbox plaatsen */
  boot[ROOT].ob_x=curr_wind->g_x;
  boot[ROOT].ob_y=curr_wind->g_y;
  
  /* Buffer-descriptor initialiseren */
  init_bd(active_buff,inactive_buff);
  
  /* Configuratie inlezen */
  read_config("*.ACC",&active);
  read_config("*.ACX",&inactive);
  
  /* ... en in de dialogbox plaatsen */
  into_resource(&active,FALSE);
  into_resource(&inactive,FALSE);
  
  /* Slider-grootte en positie initialiseren */
  init_slider(&slider1_pos,&slider2_pos,FALSE);
  
  /* en dialogbox tekenen */
  objc_draw(boot,ROOT,MAX_DEPTH,boot[ROOT].ob_x,
            boot[ROOT].ob_y,boot[ROOT].ob_width,
            boot[ROOT].ob_height);
  
  /* Dialogbox afwerken, totdat een exit-object
    aangeklikt wordt. */
  do
  {
    /* Nieuwe form_do()-aanroep */
    button=(*params->do_form)(boot,0,msg_buff);
    
    /* Dubbelklik uitfilteren */
    if (button>=0)
      button &= 0x7fff;
    
    /* Slider variabelen instellen */
    increment=1;
    function=scroll_up;
    
    /* aangeklikte object bepalen */
    switch (button)
    {
      /* Naam in "AKTIEF"-venster aangeklikt */
      case ACTIVE1:
      case ACTIVE2:
      case ACTIVE3:
      case ACTIVE4:
      case ACTIVE5:
        refresh(ACTIVE,button);
        break;
        
      /* Naam in "INAKTIEF"-venster aangeklikt */
      case INACTIV1:
      case INACTIV2:
      case INACTIV3:
      case INACTIV4:
      case INACTIV5:
        refresh(INACTIVE,button);
        break;
      
      /* File activeren/deactiveren */
      case ACTION:
        rename_file();
        into_resource(&active,TRUE);
        into_resource(&inactive,TRUE);
        init_slider(&slider1_pos,&slider2_pos,
                    TRUE);
        refresh(ACTIVE,button);
        break;
      
      /* "PIJL" in "ACTIEF"-venster aangeklikt */
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
        
        /* "PIJL" in "INACTIEF"-venster */
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
          
        /* Slider aangeklikt */
        case SLIDER1:
          move_vslider(boot,PARENT1,SLIDER1,
                       &slider1_pos,&active);
          break;
        
        case SLIDER2:
          move_vslider(boot,PARENT2,SLIDER2,
                       &slider1_pos,&active);
          break;
        
        /* Slider-achtergrond aangeklikt */
        case PARENT1:
          pos_vslider(boot,PARENT1,SLIDER1,
                      &slider1_pos,&active);
          break;
          
        case PARENT2:
          pos_vslider(boot,PARENT2,SLIDER2,
                      &slider1_pos,&inactive);
          break;
        
        /* "Aamwijs-type" aangeklikt */
        case TYP:
          pulldown(&slider1_pos,&slider2_pos);
          break;
        
        /* Dialogbox verlaten */
        case QUIT:
          abort_flag=TRUE;
          break;
        
        /* Nawoord plaatsen */
        case MESSAGE:
          switch (msg_buff[0])
          {
           case WM_REDRAW:  /* niet noodzakelijk */
             break;
           
           case WM_CLOSED:  /* niets te bewaren */
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

/*******************************************/
/* Levert het adres van een dialogbox      */
/* (nieuwe rsrc_gaddr()-routine)           */
/* Overgave parameters : Boom-index        */
/* Retour: pointer op dialogbox            */
/* *****************************************/

OBJECT *get_traddr(WORD tree_index)
{
  WORD i,j;
  
  for (i=0,j=0; i<=tree_index; i++)
    while (rs_object[j++].ob_next!=-1);
    
  return(&rs_object[--j]);
}


/**********************************************/
/* Inlezen v/d geactiveerde en gedeactiveerde */
/* programma's.                               */
/* Overgave parameter : programmatype, adres  */
/*                      v/d buffer-descriptor */
/* Retour : geen                              */
/**********************************************/

VOID read_config(char *type, BD *descriptor)
{
  DTA *dta=Fgetdta();
  WORD i=0;
  WORD j,k;
  char path[20];
  path[0]=boot_device();
  
  /* Pad naargelang type opbouwen */
  if (!strcmp(type,"*.ACC") ||
      !strcmp(type,"*.ACX"))
    strcpy(&path[1],":\\");
  else
    strcpy(&path[1],":\\AUTO\\");
  strcat(path,type);
  
  /* alle namen van dit type inlezen */
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


/**********************************************/
/* In venster geselecteerde naan deselecteren */
/* Overgave parameters : adres van een veld   */
/*                       dat de indices van   */
/*                       een venster entry    */
/*                       bevat                */
/* Retour : geen                              */
/**********************************************/

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

/*********************************************/
/* Object met nieuwe status tekenen.         */
/* Overgave parameter : pointer op dialogbox */
/*                      object-index, nieuwe */
/*                      status               */
/*********************************************/

VOID change_object(OBJECT *tree, WORD object,
                   WORD state)
{
  WORD x,y;
  
  objc_offset(tree,object,&x,&y);
  objc_change(tree,object,0,x,y,
              tree[object].ob_width,
              tree[object].ob_height,state,TRUE);
}


/*********************************************/
/* Opnieuw tekenen van een object met behulp */
/* van de door het control-veld geleverde    */
/* rechthoek-lijst.                          */
/* Overgave parameters : pointer op object-  */
/*                       boom, Oject-index,  */
/* Retour : geen                             */
/*********************************************/

VOID redraw_object(OBJECT *tree, WORD object)
{
  GRECT *clip_ptr,clip,xywh;
  
  /* Absolute object coordinaten berekenen */
  objc_offset(tree,object,&xywh.g_x,&xywh.g_y);
  xywh.g_w=tree[object].ob_width;
  xywh.g_h=tree[object].ob_height;
  
  
  /* eerste rechthoek halen */
  clip_ptr=(*params->rci_first)(&xywh);
  
  /* zolang er nog rechthoeken zijn */
  while (clip_ptr)
  {
    /* clip_ptr: pointer op lokale variabele!! */
    clip=*clip_ptr;   /* daarom copieren */
    
    /* Object opnieuw tekenen */
    objc_draw(tree,object,MAX_DEPTH,clip.g_x,
              clip.g_y,clip.g_w,clip.g_h);
    
    /* Volgende rechthoek halen */
    clip_ptr=(*params->rci_next)();
  }
}


/***********************************************/
/* Geselecteerde entry in venster deselecteren */
/* en naar gelang de aangeklikte entry de      */
/* aktie-knop opnieuw tekenen.                 */
/* Overgave parameter : venster identificatie, */
/*                      aangeklikt object      */
/* Retour : geen                               */
/***********************************************/

VOID refresh(WORD active_flag, WORD object)
{
  /* Uitgifte melding bepalen */
  char *status=((active_flag==ACTIVE) ?
                 deactivate : activate);
  /* Geselecteerde entry in ander venster
     deselecteren */
  unselect((active_flag==ACTIVE) ? inact : act);
  
  /* Geen geldige entry aangeklikt */
  if ((boot[object].ob_spec.tedinfo->te_ptext==
       underlined) || (object==ACTION))
  {
    /* Geselecteerde entry in actuele venster
       deselecteren */
    unselect((active_flag==ACTIVE) ?
              act : inact);
  
  /* Aktie-knop afschakelen */
  boot[ACTION].ob_spec.tedinfo->te_ptext=empty;
  boot[ACTION].ob_state &= ~SELECTED;
  boot[ACTION].ob_flags=NONE;
  redraw_object(boot,ACTION);
}
else
{
  /* geldige entry aangeklikt */
  if (boot[ACTION].ob_spec.tedinfo->te_ptext!=
      status)
  {
    /* Aktie-knop inschakelen */
    boot[ACTION].ob_spec.tedinfo->te_ptext=
      status;
    boot[ACTION].ob_flags=SELECTABLE|TOUCHEXIT;
    redraw_object(boot,ACTION);
  }
  
  /* Index v/d geselecteerde entry markeren */
  if (status==activate)
    inactive.selected=inactive.begin+
                      get_entry(object);
  else
    active.selected=active.begin+
                    get_entry(object);
  }
}

/**********************************************/
/* Index van de aangeklikte entry bepalen     */
/* Overgave parameters : aangeklikte object   */
/* Retour : gezochte index                    */
/**********************************************/

WORD get_entry(WORD object)
{
  WORD i;
  
  for (i=0; i<VISIBLE; i++)
    if ((object==act[i]) || (object==inact[i]))
      break;
  return(i);
}

/*********************************************/
/* Uitgekozen file hernoemen                 */
/* Overgave parameters : geen                */
/* Retour : geen                             */
/*********************************************/

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
    /* adressen voor file activeren */
    array=inact;
    begin=inactive.begin;
    buffer=inactive.buffer;
  }
  else
  {
    /* adressen voor file deactiveren */
    array=act;
    begin=active.begin;
    buffer=active.buffer;
  }
  
  /* Index van de geselecteerde entry bapalen */
  for (i=0; i<VISIBLE; i++)
    if (boot[array[i]].ob_state & SELECTED)
      break;
  index=begin+i;
  
  /* Pad naar gelang type programma aanmaken */
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
  
  /* File hernoemen */
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
/* Hernoemde file uit de ene lijst verwijderen */
/* en in de andere lijst plaatsen.             */
/* Overgave parameters : pointer op doel- en   */
/*                       bron-descriptor,      */
/*                       Index van de te       */
/*                       verwijderen entry     */
/* Retour : geen                               */
/***********************************************/

VOID copy(BD *dest, BD *source, WORD index)
{
  WORD i;
  
  /* Entry in doel-lijst plaatsen */
  if (dest->num<dest->max_num)
    strcpy(dest->buffer[dest->num++],
           source->buffer[index]);
  else
    warning();
  
  /* Entry uit de bron-lijst wissen */
  source->num--;
  for (i=index; i<source->num; i++)
    strcpy(source->buffer[i],
           source->buffer[i+1]);
  source->begin=dest->begin=0;
}


/**********************************************/
/* Waarschuwing voor overloop lijst uitgeven  */
/* Overgave parameters : geen                 */
/* Retour : geen                              */
/**********************************************/

VOID warning(VOID)
{
  WORD x,y,w,h;
  
  /* Naam-lijst vol */
  wind_center(error,&x,&y,&w,&h);
  objc_draw(error,ROOT,MAX_DEPTH,x-3,y-3,w+6,h+6);
  form_do(error,0);
  error[MIST].ob_state &= ~SELECTED;
  objc_draw(boot,ROOT,MAX_DEPTH,boot[ROOT].ob_x,
            boot[ROOT].ob_y,boot[ROOT].ob_width,
            boot[ROOT].ob_height);
}


/**********************************************/
/* Boot-drive bepalen                         */
/* Overgave parameters : geen                 */
/* Retour : boot-drive                        */
/**********************************************/

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
/* In het venster naar boven scrollen          */
/* Overgave parameters : vensterkenmerkem      */
/*                       indirekt via scroll-  */
/*                       parameters            */
/* Retour : Geen                               */
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
/* In het venster naar beneden scrollen        */
/* Overgave parameters : vensterkenmerken      */
/*                       indirekt via scroll-  */
/*                       parameters            */
/* Retour : Geen                               */
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
/* Namenlijst in de dialogbox plaatsen         */
/* Overgave parameters : pointer op buffer-    */
/*                       descriptor,teken-flag */
/* Retour : Geen                               */
/***********************************************/

VOID into_resource(BD *bd, WORD draw)
{
  WORD i;
  WORD *array=((bd==&active) ? act : inact);
  
  for (i=0; i<VISIBLE; i++)
    if (bd->begin+i<bd->num)
    {
      /* Entry beschikbaar */
      boot[array[i]].ob_spec.tedinfo->te_ptext=
        bd->buffer[bd->begin+i];
      boot[array[i]].ob_flags=SELECTABLE |
        RBUTTON | TOUCHEXIT;
      if (bd->begin+1==bd->selected)
        boot[array[i]].ob_state |= SELECTED;
      else
        boot[array[i]].ob_state &= ~SELECTED;
    }
    else
    {
      /* Geen entry meer */
      boot[array[i]].ob_spec.tedinfo->te_ptext=
        underlined;
      boot[array[i]].ob_flags=TOUCHEXIT;
      boot[array[i]].ob_state &= ~SELECTED;
    }
  /* Lijst opnieuw uitgeven */
  if (draw)
    redraw_object(boot,(array==act) ?
                  ACTWIND : INACWIND);
}


/***************************************************/
/* Verticale slider positioneren                   */
/* Overgave parameters : pointer op dialogbox,     */
/*                       index slider-achtergrond. */
/*                       index slider, pointer op  */
/*                       slider-positie, buffer-   */
/*                       descriptor                */
/* Retour : Geen                                   */
/***************************************************/

VOID pos_vslider(OBJECT *tree, WORD parent,
                 WORD slider, WORD *slider_pos,
                 BD *bd)
{
  WORD my,y;
  WORD dummy;
  WORD max,temp;
  
  
  /* Coordinaten inlezen */
  graf_mkstate(&dummy,&my,&dummy,&dummy);
  objc_offset(tree,slider,&dummy,&y);
  
  /* Naar gelang positie van de muis naar boven
     of naar beneden scrollen */
  if (my<y)
    *slider_pos=((max=bd->num-VISIBLE)<=
                (temp=*slider_pos+VISIBLE)) ?
                max : temp;
  else
    *slider_pos=((max=*slider_pos-VISIBLE)<0) ?
                0 : max;
  /* slider opnieuw positioneren */
  max=((max=bd->num-VISIBLE)<0) ? 0 : max;
  (*params->pos_vslider)(tree,parent,slider,
                         *slider_pos,0,max,NIL);
  
  /* Namenlijst uitgeven */
  bd->begin=((max=bd->num-VISIBLE-*slider_pos)<0)
             ? 0 : max;
  into_resource(bd,TRUE);
  redraw_object(tree,parent);
}


/**************************************************/
/* Verticale slider verschuiven                   */
/* Overgave parameters : pointer op dialogbox,    */
/*                       index slider-achtergrond */
/*                       index slider, pointer op */
/*                       slider positie, buffer-  */
/*                       descriptor               */
/* Retour : Geen                                  */
/**************************************************/

VOID move_vslider(OBJECT *tree, WORD parent,
                  WORD slider, WORD *slider_pos,
                  BD *bd)
{
  WORD max;
  
  max=((max=bd->num-VISIBLE)<0) ? 0 : max;
  (*params->move_vslider)(tree,parent,slider,0,
                          max,slider_pos,NIL);
  
  /* Naar gelang de slider-positie de naamlijst 
     opnieuw uitgeven */
  bd->begin=((max=bd->num-VISIBLE-*slider_pos)<0)
             ? 0 : max;
  into_resource(bd,TRUE);
}


/***************************************************/
/* Buffer-descriptor initialiseren                 */
/* Overgave parameters : pointers op beide buffers */
/* Retour : geen                                   */
/***************************************************/

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


/*********************************************/
/* Slider-positie en grootte initialiseren   */
/* Overgave parameters : pointer op de beide */
/*                       slider-posities     */
/*                       tekenvlak.          */
/* Retour : Geen                             */
/*********************************************/

VOID init_slider(WORD *slider1_pos,
                 WORD *slider2_pos, WORD draw)
{
  WORD max;
  
  /* Slider-grootte instellen */
  (*params->size_slider)(boot,PARENT1,SLIDER1,
                         active.num,VISIBLE,
                         VERTICAL,MIN_SIZE);
  (*params->size_slider)(boot,PARENT2,SLIDER2,
                         inactive.num,VISIBLE,
                         VERTICAL,MIN_SIZE);
                         
  /* Slider-positie instellen */
  *slider1_pos=((max=active.num-VISIBLE),0) ?
                0 : max;
  (*params->pos_vslider)(boot,PARENT1,SLIDER1,
                         *slider1_pos,0,max,NIL);
  *slider2_pos=((max=inactive.num-VISIBLE),0) ?
                0 : max;
  (*params->pos_vslider)(boot,PARENT2,SLIDER2,
                         *slider2_pos,0,max,NIL);
                         
  /* Slider opnieuw tekenen */
  if (draw)
  {
    redraw_object(boot,PARENT1);
    redraw_object(boot,PARENT2);
  }
}


/***********************************************/
/* Dialogbox in het venster centreren          */
/* Overgave parameters : pointer op dialogbox  */
/*                       coordinaten           */
/* Retour : indirect via coordinaten           */
/***********************************************/

VOID wind_center(OBJECT *tree, WORD *x, WORD *y,
                               WORD *w, WORD *h)
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


/**********************************************/
/* Pulldown-menu genereren, plaatsen en       */
/* waarderen                                  */
/* Overgave parameters : pointer op slider-   */
/*                       positie              */
/* Retour : geen                              */
/**********************************************/

VOID pulldown(WORD *slider1_pos,
              WORD *slider2_pos)
{
  WORD index,checked;
  GRECT button_xywh,window_xywh;
  char *pull_adr[2];
  char pull_buff[2][15];
  
  /* tekst van menu in buffer plaatsen */
  strcpy(pull_buff[0],"  ");
  strcat(pull_buff[0],acc);
  strcat(pull_buff[0],"  ");
  
  strcpy(pull_buff[1],"  ");
  strcat(pull_buff[1],prg);
  strcat(pull_buff[1],"  ");
  
  /* Index van de afgehakte entry */
  index=(!strcmp(boot[TYP].ob_spec.free_string,
         acc) ? 0 : 1);
  
  /* Absolute button coordinaten berekenen */
  objc_offset(boot,TYP,&button_xywh.g_x,
              &button_xywh.g_y);
  button_xywh.g_w=boot[TYP].ob_width;
  button_xywh.g_h=boot[TYP].ob_height;
  
  
  /* Absolute coordinaten van de dialogbox
     bepalen */
     
  objc_offset(boot,ROOT,&window_xywh.g_x,
    &window_xywh.g_h);
  window_xywh.g_w=boot[ROOT].ob_width;
  window_xywh.g_h=boot[ROOT].ob_height;
  
  
  /* Adressen van de enkele entries in de 
     overgave-array plaatsen */
  pull_adr[0]=pull_buff[0];
  pull_adr[1]=pull_buff[1];
  
  /* Pull-down menu's laten tekenen en index van
     de aangeklikte entries terug leveren */
  checked=(*(params->do_pulldown))
    (pull_adr,2,index,IBM,
    &button_xywh,&window_xywh);
  
  /* Als een entry werd aangeklikt... */
  if (checked>=0)
  {
    /* ...dan nieuwe entry button */
    boot[TYP].ob_spec.free_string=
                      ((checked==0) ? acc : prg);
    boot[TYP].ob_state &= ~SELECTED;
    redraw_object(boot,TYP);
    
    
    if (checked!=index)
    {
      /* Naar gelang geselecteerde entry nieuwe 
         configuratie inlezen */
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
      
      /* Nieuwe configuratie tonen */
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

