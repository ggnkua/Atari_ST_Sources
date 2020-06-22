/*************************************************/
/* File : CPXBUILD.C                             */
/* --------------------------------------------- */
/* Programma : CPXBUILD.PRG          Versie 1.00 */
/* (C) 1991 by MAXON Computer                    */
/* Auteurs: Oliver Scholz & Uwe Hax              */
/* Gebruikte compiler: Turbo-C 2.0               */
/* !Compileroptie -M (string merging) instellen! */
/*************************************************/


/* De gebruikelijke Header-files */

#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <portab.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "cpxbuild.rsh"
#include "cpxbuild.h"
#include "xcontrol.h"


/* Prototypes voor Turbo-C */

VOID open_vwork(VOID);
VOID init_header(CPX_HEADER *header);
VOID load_header(CPX_HEADER *header);
VOID into_dialog(CPX_HEADER *header,
				 OBJECT *dialog);
WORD get_path(char *pfad);
VOID get_colors(CPX_HEADER *header, WORD *tcolor,
				WORD *icolor);
VOID copy_icon(CPX_HEADER *header,
				OBJECT *dialog);
VOID draw_icon(CPX_HEADER *header);
VOID build_cpx(CPX_HEADER *header);
VOID plot(WORD x, WORD y, WORD color);
char hex(WORD i);


/* Een paar constanten en variabelen */

#define TRUE		1
#define FALSE		0


WORD gl_apid;
WORD work_in[12];
WORD work_out[57];
WORD vdi_handle;
WORD ob_x,ob_y,dot_w,dot_h;


/* Hier komen we bij de zaak */

WORD main(VOID)
{
  OBJECT *dialog;
  WORD x,y,w,h;
  WORD exitobj;
  WORD tcolor, icolor, i;
  CPX_HEADER header;
  char *s,*t;
  WORD dummy,mx,my;
  LONG line;
  
  /* GEM applicatie initialiseren */
  gl_apid=appl_init();
  vdi_handle=graf_handle(&dummy,&dummy,
  						 &dummy,&dummy);
  open_vwork();
  init_header(&header);
  
  /* Resource reloceren */
  dialog=object;
  for (i=0; i<NUM_OBS; i++)
    rsrc_obfix(dialog,i);
  
  /* Dialoog voorbereiden */
  graf_mouse(ARROW,NULL);
  form_center(dialog,&x,&y,&w,&h);
  form_dial(FMD_START,x,y,w,h,0,0,0,0);
  
  /* Hulp waardes voor plotten */
  objc_offset(dialog,ICONWORK,&ob_x,&ob_y);
  dot_w=dialog[ICONWORK].ob_width/32;
  dot_h=dialog[ICONWORK].ob_height/24;
  ob_x+=(dialog[ICONWORK].ob_width-dot_w*32)/2;
  ob_y+=(dialog[ICONWORK].ob_height-dot_h*24)/2;
  
  
  /* Header in dialog binnenhalen en plaatsen */
  into_dialog(&header,dialog);
  objc_draw(dialog,0,MAX_DEPTH,x,y,w,h);
  
  /* Hoofdlus: dialog bewerken */
  
  do
  {
    /* dubbelklik uitfilteren */
    exitobj=form_do(dialog,CPXNAME) & 0x7FFF;
    
    switch (exitobj)
    {
      /* informatie uit CPX halen */
      case LOAD:
        dialog[exitobj].ob_state &= ~SELECTED;
        load_header(&header);
        into_dialog(&header,dialog);
        objc_draw(dialog,0,MAX_DEPTH,x,y,w,h);
        draw_icon(&header);
        break;

      /* Iconkleur pijl links */
      case ICLEFT:
        dialog[exitobj].ob_state &= ~SELECTED;
        objc_draw(dialog,exitobj,MAX_DEPTH,
        		  x,y,w,h);
        get_colors(&header, &tcolor, &icolor);
        if (icolor>0)
        {
          icolor--;
          dialog[ICCOL].ob_spec.obspec.character=
            hex(icolor);
          header.icon_info &= 0x0FFF;
          header.icon_info |= (icolor << 12);
          objc_draw(dialog,ICCOL,MAX_DEPTH,
          			x,y,w,h);
        }
        break;
      
      /* Iconkleur pijl links */
      case ICRIGHT:
        dialog[exitobj].ob_state &= ~SELECTED;
        objc_draw(dialog,exitobj,MAX_DEPTH,
        		  x,y,w,h);
        get_colors(&header, &tcolor, &icolor);
        if (icolor<15)
        {
          icolor++;
          dialog[ICCOL].ob_spec.obspec.character=
            hex(icolor);
          header.icon_info &= 0x0FFF;
          header.icon_info |= (icolor << 12);
          objc_draw(dialog,ICCOL,MAX_DEPTH,
          			x,y,w,h);
        }
        break;
        
      /* Tekstkleur pijl links */
      case COLLEFT:
        dialog[exitobj].ob_state &= ~SELECTED;
        objc_draw(dialog,exitobj,MAX_DEPTH,
      			  x,y,w,h);
        get_colors(&header, &tcolor, &icolor);
        if (tcolor>0)
        {
          tcolor--;
          dialog[TEXTCOL].ob_spec.obspec.
            character=hex(tcolor);
          header.obj_state &= 0xF0FF;
          header.obj_state |= (tcolor << 8);
          objc_draw(dialog,TEXTCOL,MAX_DEPTH,
                    x,y,w,h);
        }
        break;
      
      /* Tekstkleur pijl rechts */
      case COLRIGHT:
        dialog[exitobj].ob_state &= ~SELECTED;
        objc_draw(dialog,exitobj,MAX_DEPTH,
        		  x,y,w,h);
        get_colors(&header,&tcolor,&icolor);
        if (tcolor<15)
        {
          tcolor++;
          dialog[TEXTCOL].ob_spec.obspec.
            character=hex(tcolor);
          header.obj_state &= 0xF0FF;
          header.obj_state |= (tcolor << 8);
          objc_draw(dialog,TEXTCOL,MAX_DEPTH,
          			x,y,w,h);
        }
        break;
      
      /* Icon inverteren */
      case INVERT:
        dialog[exitobj].ob_state &= ~SELECTED;
        objc_draw(dialog,exitobj,MAX_DEPTH,
        		  x,y,w,h);
        for (i=0;i<24;i++)
          header.icon_data[i] ^= 0xFFFFFFFFL;
        copy_icon(&header,dialog);
        objc_draw(dialog,ICONBOX,MAX_DEPTH,
        		  x,y,w,h);
        draw_icon(&header);
        break;
      
      /* Icongebied gekozen (TOUCHEXIT) */
      case ICONWORK:
        vq_mouse(vdi_handle,&dummy,&mx,&my);
        mx-=ob_x;
        my-=ob_y;
        mx/=dot_w;
        my/=dot_h;
        
        if (mx>=0 && mx<=31 && my>=0 && my <=23)
        {
          header.icon_data[my] ^= (1L<<(31-mx));
          line=header.icon_data[my];
          
          graf_mouse(M_OFF,NULL);
          plot(mx,my,(line & (1L<<(31-mx))) ?
          			  1 : 0);
          graf_mouse(M_ON,NULL);
          
          copy_icon(&header,dialog);
          objc_draw(dialog,ICONBOX,MAX_DEPTH,
          			x,y,w,h);
          
        }
        break;
    }
      
    /* Button normaal tonen */
    dialog[exitobj].ob_state &= ~SELECTED;
  }
  while ((exitobj!=OK) && (exitobj!=STOPPEN));
    
  form_dial(FMD_FINISH,x,y,w,h,0,0,0,0);
    
  if (exitobj==OK)
  {
    /* Waarde uit dialog lezen */
    header.flags.reserved=header.flags.boot_init=
      header.flags.set_only=FALSE;
    if (dialog[SETONLY].ob_state & SELECTED)
      header.flags.set_only=TRUE;
    if (dialog[BOOTFLAG].ob_state & SELECTED)
      header.flags.boot_init=TRUE;
    if (dialog[RESFLAG].ob_state & SELECTED)
      header.flags.reserved=TRUE;
      
    s=dialog[VERSION].ob_spec.tedinfo->te_ptext;
    t=(char *)&header.cpx_version;
    for (i=0; i<2; i++)
    t[i]=(((*s++)-'0')<<4) | ((*s++)-'0');
    
    strncpy(header.cpx_id,dialog[CPXID].ob_spec.
            tedinfo->te_ptext,4);
    strcpy(header.icon_name,dialog[ICNNAME].
            ob_spec.tedinfo->te_ptext);
    strcpy(header.cpx_name,dialog[CPXNAME].
            ob_spec.tedinfo->te_ptext);
      
    /* CPX module linken */
    build_cpx(&header);
  }
    
  /* nij GEM afmelden */
  v_clsvwk(vdi_handle);
  appl_exit();
  return(0);
}
  
  
  /* Header met zinvollegegevens initialiseren */
  
  
VOID init_header(CPX_HEADER *header)
{
  WORD i;
  char init[]="@\0";


  header->magic=100;
  header->flags.boot_init=TRUE;
  strcpy(header->cpx_id,init);
  header->cpx_version=0;
  strcpy(header->icon_name,init);
  for (i=0; i<24; i++)
    header->icon_data[i]=0L;
  header->icon_info=0x1000;
  strcpy(header->cpx_name,init);
  header->obj_state=0x1180;
}

/* Actuele pad en drive halen */

WORD get_path(char *pfad)
{
  pfad[0]='A'+Dgetdrv();
  pfad[1]=':';
  pfad[2]='\0';
  
  
  return(Dgetpath(pfad+3,0));
}

/* Header uit CPX module lezen */

VOID load_header(CPX_HEADER *header)
{
  char pfad[128],filename[16],*pathend;
  WORD button,handle;
  
  
  get_path(pfad);
  strcat(pfad,"*.CP?");
  filename[0]='\0';
  
  
  fsel_input(pfad,filename,&button);
  if(button)
  {
    if ((pathend=strrchr(pfad,(int)'\\'))!=NULL)
    {
      strcpy(pathend+1,filename);
      if ((handle=Fopen(pfad,0))>0)
      {
        Fread(handle,512L,header);
        Fclose(handle);
      }
    }
  }
}

/* Gegevens uit header opnemen in dialog */

VOID into_dialog(CPX_HEADER *header,
				OBJECT *dialog)
{
  WORD tcol,icol,i;
  char ver[4],*s;
  
  strcpy(dialog[CPXNAME].ob_spec.tedinfo->
  		te_ptext,header->cpx_name);
  strcpy(dialog[ICNNAME].ob_spec.tedinfo->
  		te_ptext,header->icon_name);
  strncpy(dialog[CPXID].ob_spec.tedinfo->
  		te_ptext,header->cpx_id,4);
  get_colors(header,&tcol,&icol);
  dialog[TEXTCOL].ob_spec.obspec.character=
    hex(tcol);
  dialog[ICCOL].ob_spec.obspec.character=
    hex(icol);
  
  dialog[ICONSMAL].ob_spec.bitblk->bi_wb=4;
  dialog[ICONSMAL].ob_spec.bitblk->bi_hl=24;
  
  copy_icon(header,dialog);
  
  if (header->flags.set_only)
    dialog[SETONLY].ob_state |= SELECTED;
  else
    dialog[SETONLY].ob_state &= ~SELECTED;
  
  if (header->flags.boot_init)
    dialog[BOOTFLAG].ob_state |= SELECTED;
  else
    dialog[BOOTFLAG].ob_state &= ~SELECTED;
  
  if (header->flags.reserved)
    dialog[RESFLAG].ob_state |= SELECTED;
  else
    dialog[RESFLAG].ob_state &= ~SELECTED;
  
  
  s=(char *) &(header->cpx_version);
  for(i=0; i<2; i++)
  {
    ver[2*i]=((s[i]>>4) & 0xF)+'0';
    ver[2*i+1]=(s[i] & 0xF)+'0';
  }
  
  strncpy(dialog[VERSION].ob_spec.tedinfo->
  		  te_ptext,ver,4);
}

/* Tekst- en iconkleur uit header lezen */

VOID get_colors(CPX_HEADER *header, WORD *tcolor,
				WORD *icolor)
{
  *icolor=(header->icon_info >>12) & 0xF;
  *tcolor=(header->obj_state >> 8) & 0xF;
}


/* getal 0..15 in hexadecimaal omzetten */

char hex(WORD i)
{
  if ((i>=0) && (i<10))
    return('0'+(char)i);
  if ((i>=10) && (i<16))
    return ('A'+(char)(i-10));
  return ('0');
}

/* Icon uit header in dialog copieren */

VOID copy_icon(CPX_HEADER *header,
				OBJECT *dialog)
{
  WORD i;
  
  for (i=0; i<24; i++)
  {
    dialog[ICONSMAL].ob_spec.bitblk->
      bi_pdata[2*i]=
      (WORD)((header->icon_data[i])>>16);
    dialog[ICONSMAL].ob_spec.bitblk->
      bi_pdata[2*i+1]=
      (WORD)((header->icon_data[i]) & 0xFFFFl);
  }
}

/* ICON in het groot tekenen */

VOID draw_icon(CPX_HEADER *header)
{
  WORD ix,iy;
  LONG line;
  
  graf_mouse (M_OFF,NULL);
  for(iy=0; iy<24; iy++)
  {
    line=header->icon_data[iy];
    for (ix=0; ix<32; ix++)
    plot(ix,iy,(line&(1L<<(31-ix))) ? 1 : 0);
  }
  graf_mouse(M_ON,NULL);
}


/* Een "grote pixel" tekenen */

VOID plot(WORD x, WORD y, WORD color)
{
  WORD pxyarray[4];
  
  vsf_color(vdi_handle,color);
  
  pxyarray[0]=ob_x+x*dot_w;
  pxyarray[1]=ob_y+y*dot_h;
  pxyarray[2]=pxyarray[0]+dot_w-1;
  pxyarray[3]=pxyarray[1]+dot_h-1;
  
  v_bar(vdi_handle,pxyarray);
}


/* CPX module bouwen: Header voor PRG schrijven */

VOID build_cpx(CPX_HEADER *header)
{
  char pfad[128],filename[16],*pathend;
  char wpfad[128];
  WORD button,whandle,handle;
  LONG length;
  
  get_path(pfad);
  strcat(pfad,"*.PRG");
  filename[0]='\0';
  
  fsel_input(pfad,filename,&button);
  if (button)
  {
    if ((pathend=strrchr(pfad,(int)'\\'))!=NULL)
    {
      strcpy(pathend+1,filename);
      strcpy(wpfad,pfad);
      if ((pathend=strrchr(wpfad,(int)'.'))
           !=NULL)
      {
        strcpy(pathend,".CPX");
        if ((handle=Fopen(pfad,0))>0 &&
            (whandle=Fcreate(wpfad,0))>0)
        {
          Fwrite(whandle,512L,header);
          
          do
          {
            length=Fread(handle,512L,header);
            Fwrite(whandle,length,header);
          }
          while (length==512L);
          
          Fclose(handle);
          Fclose(whandle);
        }
      }
    }
  }
}

/* Geen commentaar */

VOID open_vwork(VOID)
{
  WORD i;
  
  for (i=1; i<10; i++)
    work_in[i]=1;
  work_in[10]=2;
  v_opnvwk(work_in,&vdi_handle,work_out);
}