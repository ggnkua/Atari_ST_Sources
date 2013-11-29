/* Simple GDOS font chooser. Can handle up to 250 fonts, assumes 
		each font name is less
   than 35 characters long. */

/* includes */
#include "aes.h"
#include "vdi.h"
#include "stdlib.h"
#include "stdio.h"
#include <osbind.h>
#include "string.h"

#include "main.h"
#include "telvt102.h"
#include "tndefs.h"
#include "transprt.h"
/*
#include <aes.h>
#include <vdi.h>
#include <stdio.h>
#include <osbind.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "main.h"
#include "telvt102.h"
#include "tndefs.h"
#include "transprt.h"
*/

/*#include "choosfnt.h"*/

/* defines */
#define MAX_NAMES 8
#define MAX_FILENAMES 250
#define FONT_ELEMENT 35
#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif

/* globals */
	extern OBJECT *menu_ptr, *about_ptr, *host_ptr, *sizer_ptr, *chooser, *fsize_ptr;

/*OBJECT *chooser;*/
short handle, gl_charw, gl_charh;
short first_time=TRUE;

/* function prototypes */
short choose(short);
void init_gem(void);
int handle_chooser(int, int, char *, char *, int);
void show_names(int, int, char *, char *);
void set_slider_pos(int, int);
void set_slider_size(int);
void highlight(int);
int get_fontnames(char *);
int choose_font(int);

/*externals	*/
	extern short fid, ptsize,fnum;
	extern char fontname[35];
	char mes[150];
	
	extern short dialog(OBJECT *, short);

	extern short 	vdi_handle, work_out[57];
	extern WINDOW	win;
	extern MFDB work, screen;
	extern OBJECT *menu_ptr, *about_ptr, *host_ptr, 
				*sizer_ptr, *chooser, *fsize_ptr;
	extern short chrwid,chrhgt;

int id[MAX_FILENAMES];
/* ------------------------------------------------------------------- */
short choose(short num)
{
	first_time=TRUE;
/*	int num;*/
/*	appl_init();*/
	graf_mouse(ARROW, 0);
	init_gem();
/*	if(rsrc_load("choosfnt.rsc")) {

		rsrc_gaddr(R_TREE, CHOOSER, &chooser);
*/
		choose_font(num);
		num=fid;
/*				sprintf(mes, "[1][From choose num fid:| %d %d][OK]", 
								num,fid);
				form_alert(1, mes);
*/
/*		rsrc_free();
	}

	else form_alert(1, "[3][Cannot open resource file.][OK]");*/
/*	v_clsvwk(handle);
	appl_exit();
*/	return (num);
}
/* ------------------------------------------------------------------- */
void init_gem(void)
{
short work_in[12], work_out[57], dum;
int i;

	handle=graf_handle(&gl_charw, &gl_charh, &dum, &dum);
	for(i=0; i<10; i++) work_in[i]=1;
	work_in[10]=2;
	v_opnvwk(work_in, &handle, work_out);
}
/* ------------------------------------------------------------------- */
/* Function to handle the chooser dialog.
   Parameters are:
   		int num_names:	the number of font names in the list
		int element:	a constant giving the size in bytes of each element in 
					the list
   		char *namelist:	a pointer to the list of names
		char *selected:	the selected string

   Returns:
   		1 if the user clicked on OK and had selected a name;
   		0 if the user clicked on Cancel, or on OK but there was no 
   					selected name */

int handle_chooser(int num_names, int element, 
			char *namelist, char *selected, int font_num)
{
short button, cx, cy, cw, ch, mousey, slidey, dum, junk;
int top, success=FALSE, index, i, j, double_click;
char chooser_title[50], chooser_action[50];
long pos;
int16 dummy, width, height, pt_need, pt_size;
int pt_valid[5];
/* the chooser can display only 8 names at a time, but there may be more 
		than this. If the user clicks on a name and then scrolls the list, 
		the selected name may disappear. The following array is used to keep 
		track of selected names even if they scroll out of the box */
char clicked[MAX_FILENAMES];

	wind_update(BEG_UPDATE);
	top=0;												/* first name set to the top */
	for(i=0; i<MAX_FILENAMES; i++) clicked[i]=0;		/* zero the clicked-on 
										flags, as none are selected at the start */
	set_slider_size(num_names);	/* set slider size and position, like a 
										GEM window */
	set_slider_pos(num_names, top);

	strcpy(chooser_title, " Choose GDOS font ");
	strcpy(chooser_action, "* fonts preferred ");
	((TEDINFO *)chooser[CHTITLE].ob_spec)->te_ptext=chooser_title;
	((TEDINFO *)chooser[CHACTION].ob_spec)->te_ptext=chooser_action;
	form_center(chooser, &cx, &cy, &cw, &ch);
	form_dial(FMD_START, 0, 0, 0, 0, cx, cy, cw, ch);
	objc_draw(chooser, ROOT, MAX_DEPTH, cx, cy, cw, ch);

	/* the chooser can show up to 8 names. If there are fewer than 8, the 
					empty slots are disabled by clearing the TOUCHEXIT flags */
	for(i=0; i<MAX_NAMES; i++) {
		if(strlen(namelist+(i*element))>0) chooser[NAME1+i].ob_flags|=TOUCHEXIT;
		else chooser[NAME1+i].ob_flags&=(0xffff-TOUCHEXIT);
	}

	show_names(top, element, namelist, clicked);	/* display the font names */
	do {
		button=form_do(chooser, 0);
		if(button&0x8000) {		/* double click */
			double_click=TRUE;
			button&=0x7fff;
		}
		else double_click=FALSE;
		if(button==DNARR) {
			if((top+MAX_NAMES)<num_names) {
				top++;	/* next name in the list */
				show_names(top, element, namelist, clicked);
				set_slider_pos(num_names, top);
				objc_draw(chooser, SLIDEBAR, MAX_DEPTH, cx, cy, cw, ch);
			}
		}
		else if(button==UPARR) {
			if(top>0) {
				top--;
				show_names(top, element, namelist, clicked);
				set_slider_pos(num_names, top);
				objc_draw(chooser, SLIDEBAR, MAX_DEPTH, cx, cy, cw, ch);
			}
		}
		else if(button==SLIDEBAR && num_names>MAX_NAMES) {	/* handle clicks on 
								the slidebar */
			graf_mkstate(&dum, &mousey, &dum, &dum);		/* where is the mouse 
								- above or below the slider? */
			objc_offset(chooser, SLIDER, &dum, &slidey);
			if(mousey<slidey) {								/* mouse is above the slider */
				top-=MAX_NAMES;								/* move up one page of names */
				if(top<0) top=0;
			}
			else {
				top+=MAX_NAMES;
				if(top>(num_names-MAX_NAMES)) top=num_names-MAX_NAMES;
			}
			show_names(top, element, namelist, clicked);
			set_slider_pos(num_names, top);
			objc_draw(chooser, SLIDEBAR, MAX_DEPTH, cx, cy, cw, ch);
		}
		else if(button==SLIDER && num_names>MAX_NAMES) {	/* handle the slider */
			pos=graf_slidebox(chooser, SLIDEBAR, SLIDER, 1);/* the position the user wants */
			chooser[SLIDER].ob_y=pos*(long)(chooser[SLIDEBAR].ob_height
						-chooser[SLIDER].ob_height)/1000;
			top=pos*(num_names-MAX_NAMES)/1000;
			if(top<0) top=0;
			if(top>(num_names-MAX_NAMES)) top=num_names-MAX_NAMES;
			show_names(top, element, namelist, clicked);
			objc_draw(chooser, SLIDEBAR, MAX_DEPTH, cx, cy, cw, ch);
		}
		else if(button>=NAME1 && button<=NAME8) {	/* the user has clicked on a 
																		font name */
			index=top+button-NAME1;			/* index into name array */
			if(clicked[index]==TRUE) {		/* the name is already selected */
				clicked[index]=FALSE;		/* deselect it */
				highlight(button);			/* remove the highlight from the name */
				}
			else {							/* first, remove the selected flag from any 
										existing selected name */
				for(i=0; i<MAX_FILENAMES; i++) {
					if(clicked[i]==TRUE) {	/* is the currently selected font 
										name currently displayed in the box? */
						if((i+NAME1-top)>=NAME1 && (i+NAME1-top)<=NAME8) {
							highlight(i+NAME1-top);		/* remove highlight */
						}
						clicked[i]=FALSE;	/* clear the flag */
					}
				}
				clicked[index]=TRUE;		/* set the flag for the new selection */
				highlight(button);			/* and highlight it */

/*	put print font here	*/				
				fid = id[index];
				fnum = index;
				
				vst_font(handle, fid );
				for (i=0,j=6;j<=10;i++,j++)
					{
					pt_need=j;
					pt_size = vst_point(handle,pt_need,&dummy, &dummy, &width, &height);
					if (pt_size==pt_need) pt_valid[i]=j;
					else pt_valid[i]=0;
					}
				vst_point(handle, win.font_size, 
								&junk, &junk, &chrwid, &chrhgt);
/*				sprintf(t1, " %dpt",win.font_size);
				strcpy(((TEDINFO *)(chooser[Fsize].ob_spec))->te_ptext,t1);
				sprintf(t1, "%dx%d",chrwid,chrhgt);
				strcpy(((TEDINFO *)(chooser[Chrwxh].ob_spec))->te_ptext,t1);
*/
/*				sprintf(mes, "[1][Temp font ID:| %d %s][OK]", fid,t2);
				form_alert(1, mes);
*/
/*
			sprintf(out,"%2d",nlines);
			strcpy(((TEDINFO *)
					(sizer_ptr[NumberofLines].ob_spec))->te_ptext,out);
*/
			for (i=0;i<5;i++)
				{
				switch (i)
					{
					case 0:	dummy=p6;break;
					case 1:	dummy=p7;break;
					case 2:	dummy=p8;break;
					case 3:	dummy=p9;break;
					case 4:	dummy=p10;break;
					}
				sprintf(mes,"%2d",pt_valid[i]);
				strcpy(((TEDINFO *)
						(fsize_ptr[dummy].ob_spec))->te_ptext,mes);
				}		
/*			do*/
				{
/*				sprintf(mes,"%d %d %d %d %d"
						,pt_valid[0],pt_valid[1],pt_valid[2],pt_valid[3],pt_valid[4]);
				wind_set(win.handle, WF_INFO, (short)((long)mes>>16), (short)(mes), 
							NULL, NULL);
*/						
				dialog(fsize_ptr,0);
				junk=form_do((fsize_ptr ), 0);

				if (junk== p6) pt_size = pt_valid[0];
				else
				if (junk== p7) pt_size = pt_valid[1];
				else
				if (junk== p8) pt_size = pt_valid[2];
				else
				if (junk== p9) pt_size = pt_valid[3];
				else
				if (junk== p10) pt_size = pt_valid[4];
/*
				sprintf(mes,"%d %d %d %d %d %d"
						,pt_valid[0],pt_valid[1],pt_valid[2],pt_valid[3],pt_valid[4],junk);
				wind_set(win.handle, WF_INFO, (short)((long)mes>>16), (short)(mes), 
							NULL, NULL);
*/
				} /*while pt_size != 0;*/
			}
			if(double_click) button=CHOOSEOK;	/* if double clicked on a name, 
									exit immediately */
				if (pt_size == 0)
					{
					sprintf(mes, "[1][ Invalid pt size for font:| %d ][OK]", 
								fid);
					form_alert(1, mes);	
					}
				else ptsize=pt_size;

			show_names(top, element, namelist, clicked);	/* display the font names */
			objc_draw(chooser, SLIDEBAR, MAX_DEPTH, cx, cy, cw, ch);
		}
	} 
	while(button!=CHOOSEOK && button!=CHOOSECA);
	
	if(button==CHOOSEOK) {
		for(i=0; i<num_names; i++) {
			if(clicked[i]==TRUE) {
				strcpy(selected, namelist+(i*element));
				success=TRUE;
				font_num=id[i];
				fid=font_num;
				fnum=i;
				break;
			}
		}
	}
/*			objc_draw(chooser, SLIDEBAR, MAX_DEPTH, cx, cy, cw, ch);*/
	chooser[button].ob_state&=(0xffff-SELECTED);
	form_dial(FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch);
	wind_update(END_UPDATE);
	return success;
}
/* -------------------------------------------------------------------- */
/* Display the font names in the dialog box */
void show_names(int top, int element, char *namelist, char *clicked)
{
short pxy[4];
int i, j;


	objc_offset(chooser, NAMEBOX, &pxy[0], &pxy[1]);
	pxy[2]=pxy[0]+chooser[NAMEBOX].ob_width-1;
	pxy[3]=pxy[1]+chooser[NAMEBOX].ob_height-1;
	vsf_color(handle, 0);
	vsf_interior(handle, FIS_HOLLOW);
	graf_mouse(M_OFF, 0);
	vr_recfl(handle, pxy);	
	for(i=NAME1, j=top; i<=NAME8; i++, j++) {
		((TEDINFO *)chooser[i].ob_spec)->te_ptext=namelist+(j*element);
		objc_draw(chooser, i, MAX_DEPTH, chooser[ROOT].ob_x, 
			chooser[ROOT].ob_y, chooser[ROOT].ob_width, chooser[ROOT].ob_height);
/*		if (first_time) 
			{
			if (id[j]==win.font_no)
				{
				clicked[j]=TRUE;
				first_time=FALSE;
				}
			}
		else 
			if (id[j]==win.font_no) clicked[j] =FALSE;
*/
		if(clicked[j]==TRUE) highlight(i);	/* highlight if selected */
	}
	graf_mouse(M_ON, 0);
}
/* ------------------------------------------------------------------ */
/* simulate the GEM method of tracking slider positions */
void set_slider_pos(int num_names, int top)
{
long pos;

	if((num_names-MAX_NAMES)<=0) pos=0;
	else {
		pos=top*1000/(num_names-MAX_NAMES);
		if(pos>1000) pos=1000;
		if(pos<0) pos=0;
	}
	chooser[SLIDER].ob_y=pos*(long)(chooser[SLIDEBAR].ob_height
			-chooser[SLIDER].ob_height)/1000;
}
/* ------------------------------------------------------------------ */
/* simulate the GEM method of setting slider sizes */
void set_slider_size(int num_names)
{
long size;

	if(!num_names) size=100;	/* avoid divide-by-zero error */
	else size=(100*MAX_NAMES)/num_names;
	if(size>100) size=100;
	if(size<1) size=1;
	chooser[SLIDER].ob_height=(chooser[SLIDEBAR].ob_height*size)/100;
	if(chooser[SLIDER].ob_height<(chooser[SLIDEBAR].ob_height/8)) 
					chooser[SLIDER].ob_height=chooser[SLIDEBAR].ob_height/8;
}
/* ------------------------------------------------------------------- */
/* display a highlight over a selected font name */
void highlight(int obj)
{
short hx, hy, pxy[4];

	objc_offset(chooser, obj, &hx, &hy);
	vsf_interior(handle, FIS_SOLID);
	vsf_color(handle, 1);
	pxy[0]=hx;
	pxy[1]=hy;
	pxy[2]=hx+chooser[obj].ob_width-1;
	pxy[3]=hy+chooser[obj].ob_height-1;
	vswr_mode(handle, MD_XOR);
	graf_mouse(M_OFF, 0);
	vr_recfl(handle, pxy);
	graf_mouse(M_ON, 0);
	vswr_mode(handle, MD_REPLACE);
}
/* -------------------------------------------------------------------- */
/* Function to get the list of font names. Assumes an element size of 
				FONT_ELEMENT bytes. */
int get_fontnames(char *namelist)
{
int num_fonts, i, j;
char temp[FONT_ELEMENT]/*, mes[150]*/;

	for(i=0; i<(FONT_ELEMENT*MAX_FILENAMES); i+=FONT_ELEMENT) namelist[i]=0;	/* clear all strings */

	num_fonts=vst_load_fonts(handle, 0);
	if(num_fonts>MAX_FILENAMES) num_fonts=MAX_FILENAMES;	
					/* handle MAX_FILENAMES fonts at most */
	for(i=1, j=0; i<=num_fonts; i++, j++) {			/* get all font names */
		id[j]=vqt_name(handle, i, temp);
		if ((id[j]==1)||(id[j]==45)||(id[j]==46)||(id[j]==52)
					||(id[j]==55)||(id[j]==56))
			{
			temp[strlen(temp)]='*';
/*				sprintf(mes, "[1][ font name is:|%s %d %d][OK]", 
								temp,id[j],k);
				form_alert(1, mes);	
*/
			}
		strcpy(namelist+(j*FONT_ELEMENT), temp);
		/*
				sprintf(mes, "[1][ font name is:|%s %d][OK]", 
								temp,id[j]);
				form_alert(1, mes);	*/
	}
/*	vst_unload_fonts(handle, 0);
*/	return num_fonts;
}
/* ------------------------------------------------------------------ */
int choose_font(int f_num)
{
char *font_list, returned_name[FONT_ELEMENT];
int num_fonts;

	if(vq_gdos()) 
		{		/* is GDOS loaded? */
		/* reserve memory for font names */
		font_list=(char *)Malloc(FONT_ELEMENT*MAX_FILENAMES);	
					/* get memory for font list - use element size of FONT_ELEMENT */
		if(font_list==NULL) form_alert(1, 
						"[3][Insufficient memory to list |font names.][OK]");
		else {
			graf_mouse(BUSY_BEE, 0);
			num_fonts=get_fontnames(font_list);
			graf_mouse(ARROW, 0);
			if(handle_chooser(num_fonts, FONT_ELEMENT, font_list, 
					returned_name, f_num)) {
/*
				sprintf(mes, "[1][You finally chose font name:|%s %d %dpt.][OK]", 
								returned_name,fid,ptsize);
				form_alert(1, mes);
*/
			strcpy(fontname,returned_name);
			}
			else form_alert(1, "[1][You didn't select a font.][OK]");
			Mfree(font_list);
		}
		return (fid);
	}
	else form_alert(1, "[3][GDOS is required for this |function.][OK]");
}
/* --------------------------------------------------------------- */
