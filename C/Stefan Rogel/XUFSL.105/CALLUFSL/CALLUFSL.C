#define MAIN

#define UFSL_COOKIE     'UFSL'

#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <define.h>
#include <tos.h>
#include <vdi.h>
#include <aes.h>
#include <xufsl.h>
#include <cookie.h>

#include "callufsl.h"

#define SCREEN 1

int Work_in[103],Work_out[57];

int main(void);
int open_work(int device);
void close_work(int handle,int device);
void set_state(OBJECT *tree,int obj,int s,int flag);
int selected(OBJECT *tree,int obj);
char *tp_text(OBJECT *tree,int obj);

int main(void)
{
char          *ufsl_id,*ufsl_ver;
char					*u_title,*u_info,*u_bsp;
FW_INFO				width={0,0,0};
int           ufsl_version,version;
int           app,handle,maxfonts;
int           desk_x,desk_y,desk_w,desk_h;

int           syssmall=1,sysibm=1;
int           font=1,point=10,attr=0,color=1,skew=0;
int						sets=4,set_ind=2;
int           but;
int           dummy;
OBJECT        *setflags;
unsigned long flags=0xFFFF;
xUFSL_struct  *ufsl;
XUFSL_LIST 		set[4]={
	0x3FF,"Oberstes Fenster",1,0,{0,0,0},0,1,0,
	0x1FF,"Standardschrift",1,0,{0,0,0},0,1,0,
	UFS_GDOS_FONTS|UFS_PROP_FONTS,
		"Dialogschrift klein",273,8,{0,0,0},0,1,0,
	UFS_GDOS_FONTS|UFS_PROP_FONTS,
		"Dialogschrift grož",250,10,{0,0,0},0,1,0,
};
	

  if ((ufsl=(xUFSL_struct *)get_cookie(UFSL_COOKIE))==0)
    return FAILURE;
    
  app=appl_init();
  if (app>=0) {
  
    handle=graf_handle(&dummy,&dummy,&dummy,&dummy);
    
    if (handle>0 && rsrc_load("CALLUFSL.RSC")) {

      wind_get(0,WF_WORKXYWH,&desk_x,&desk_y,&desk_w,&desk_h);

			handle=open_work(SCREEN);
      maxfonts=Work_out[10]+vst_load_fonts(handle,0);
      
      rsrc_gaddr(R_TREE,SETFLAGS,&setflags);
      
      form_center(setflags,&setflags->ob_x,&setflags->ob_y,&dummy,&dummy);

      u_title=tp_text(setflags,U_TITLE);
      u_info=tp_text(setflags,U_INFO);
      u_bsp=tp_text(setflags,U_BSP);
      strcpy(u_title,"Extended Fontselektor  \275 RoSoft");
      strcpy(u_info,"Schriftauswahl");
      strcpy(u_bsp,"Textbeispiel");
      ufsl_id=tp_text(setflags,UFSL_ID)+9;
      ufsl_ver=tp_text(setflags,UFSL_VER)+9;
      strncpy(ufsl_id,(char *)&ufsl->id,4);
      
      /* zwar etwas aufwendig, spart jedoch den speicherplatzraubenden
         Aufruf von sprintf! */
      ufsl_version=ufsl->version;
      version=ufsl_version/0x100;
      ufsl_version-=version*0x100;
      itoa(version,ufsl_ver,16);
      strcat(ufsl_ver,".");
			if (ufsl_version<0x10) {
				strcat(ufsl_ver,"0");
				itoa(ufsl_version,ufsl_ver+strlen(ufsl_ver),16);
			}
			else
				itoa(ufsl_version,ufsl_ver+strlen(ufsl_ver),16);

      do {

        wind_update(BEG_MCTRL);
        itoa(syssmall,tp_text(setflags,U_ID8),10);
        itoa(sysibm,tp_text(setflags,U_ID10),10);
        itoa(font,tp_text(setflags,U_ID),10);
        itoa(point,tp_text(setflags,U_SIZE),10);
        itoa(width.width,tp_text(setflags,U_WIDTH),10);
        itoa(width.track,tp_text(setflags,U_KERN),10);
        set_state(setflags,U_PKERN,SELECTED,width.pair);
        itoa(attr,tp_text(setflags,U_ATTR),10);
        itoa(color,tp_text(setflags,U_COLOR),10);
        set_state(setflags,U_NSKEW,SELECTED,skew<0);
        skew=(skew<0)? -skew : skew;
        itoa(skew,tp_text(setflags,U_SKEW),10);

        graf_mouse(ARROW,0);
        objc_draw(setflags,ROOT,MAX_DEPTH,desk_x,desk_y,desk_w,desk_h);
        but=form_do(setflags,ROOT);
        wind_update(END_MCTRL);

	      form_dial(FMD_FINISH,desk_x,desk_y,desk_w,desk_h,
  	                         desk_x,desk_y,desk_w,desk_h);

        if (but==U_CALL || but==U_SET) {
          
          flags=UFS_WIND_DIALOG*selected(setflags,U_WINDOW)
               |UFS_GDOS_FONTS*selected(setflags,U_GDOS)
               |UFS_PROP_FONTS*selected(setflags,U_PROP)
               |UFS_SIZE_CHANGE*selected(setflags,U_CSIZE)
               |UFS_SIZE_DEFAULT*selected(setflags,U_DSIZE)
               |UFS_WIDTH_CHANGE*selected(setflags,U_CWIDTH)
               |UFS_KERNING_INFO*selected(setflags,U_CKERN)
               |UFS_ATTR_CHANGE*selected(setflags,U_CATTR)
               |UFS_ATTR_INVERS*selected(setflags,U_IATTR)
               |UFS_COLOR_CHANGE*selected(setflags,U_CCOLOR)
               |UFS_SKEW_CHANGE*selected(setflags,U_CSKEW)
               |UFS_ERROR_MSG;

          syssmall=atoi(tp_text(setflags,U_ID8));
          sysibm=atoi(tp_text(setflags,U_ID10));
          font=atoi(tp_text(setflags,U_ID));
          point=atoi(tp_text(setflags,U_SIZE));
          width.width=atoi(tp_text(setflags,U_WIDTH));
          width.track=atoi(tp_text(setflags,U_KERN));
          width.pair=selected(setflags,U_PKERN);
          attr=atoi(tp_text(setflags,U_ATTR));
          color=atoi(tp_text(setflags,U_COLOR));
          skew=atoi(tp_text(setflags,U_SKEW));
          if (selected(setflags,U_NSKEW))
            skew=-skew;

					ufsl->examplestr=(u_bsp[0]==EOS)? NULL : u_bsp;
					ufsl->msgfunc=(MSGFUNC)NULL;

          if (ufsl->id==xUFS_ID) {
        
        		if (but==U_SET && ufsl->version>=0x103)
						  ufsl->font_selexinput(handle,
						                       UFS_INDIRECT|flags,
	                                 (u_title[0]==EOS)? NULL : u_title,
						                       (string)&set,
						                       syssmall,sysibm,
						                       &sets,&set_ind,&width,&attr,&color,&skew);
          	else
	            ufsl->font_selexinput(handle,
	                                 flags,
	                                 (u_title[0]==EOS)? NULL : u_title,
	                                 (u_info[0]==EOS)? NULL : u_info,
	                                 syssmall,sysibm,
	                                 &font,&point,&width,&attr,&color,&skew);
          }
          else {
          
            ufsl->dialtyp=(flags & UFS_WIND_DIALOG)? UFS_WINDOW : UFS_DIALOG;
            ufsl->fontsel_input(handle,maxfonts,
                                (flags & UFS_PROP_FONTS)!=0,
                                (u_info[0]==EOS)? NULL : u_info,
                                &font,&point);
          
          }
        }
          
        (setflags+but)->ob_state&=~SELECTED;
          
      } while (but==U_CALL || but==U_SET);

      rsrc_free();
      close_work(handle,SCREEN);
    }
    appl_exit();
  }

  return SUCCESS;
}

int open_work(int device)
{
int	i,dummy;
int	handle;

	for (i=0;i<103;Work_in[i++]=1);
	Work_in[0]=device;	/* device handle */
	Work_in[10]=2;			/* Raster Koordinaten */
	
	if (device==SCREEN) {
		handle=graf_handle(&dummy,&dummy,&dummy,&dummy);
    v_opnvwk(Work_in,&handle,Work_out);	/* virtuell ”ffnen */
  }
  else {
		v_opnwk(Work_in,&handle,Work_out);	/* physikalisch ”ffnen */
  }
	return handle;
}

void close_work(int handle,int device)
{
  if (device==SCREEN) {
    v_clsvwk(handle);
	}
	else {
    v_clswk(handle);
  }
}

void set_state(OBJECT *tree,int obj,int s,int flag)
{
  if (obj>=0)
    if (flag) (tree+obj)->ob_state |= s;
    else      (tree+obj)->ob_state &= ~s;
}

int selected(OBJECT *tree,int obj)
{
  return ((tree+obj)->ob_state & SELECTED)!=0;
}

char *tp_text(OBJECT *tree,int obj)
{
  switch ((tree+obj)->ob_type) {
  case G_TEXT:
  case G_BOXTEXT:
  case G_FTEXT:
  case G_FBOXTEXT:
    return (char *)(((tree+obj)->ob_spec.tedinfo)->te_ptext);
  case G_BUTTON:
  case G_STRING:
  case G_TITLE:
    return (char *)((tree+obj)->ob_spec.free_string);
  }
  return NULL;
}

