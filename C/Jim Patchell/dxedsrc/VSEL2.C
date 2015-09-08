 /*
	this file is a voice selector dialog box

	input parrameters:
		file name path
		voice name

	returns
		result of dialog

*/
#include <osbind.h>
#include <obdefs.h>
#include <gemdefs.h>
#include <string.h>
#include "dx.h"
#include "dxed.h"
#include <stdio.h>

#define	PAGE_UP	0
#define	PAGE_DN	1
#define	ROW_UP	2
#define	ROW_DN	3
#define	PAG_LF	4
#define	PAG_RT	5
#define	COL_LF	6
#define	COL_RT	7
#define NLINES 32
#define NCHARS 10

extern char temp[128];
extern int res;
extern int gl_hchar,gl_wchar;
extern int slidpos[10];
int xlines;
static int cur_line, cur_col;
char voice_name[11];	/*	voice currently being edited	*/
char names[32][11];
int name_indexes[] = {
	VSELNM1,VSELNM2,VSELNM3,VSELNM4,VSELNM5,VSELNM6,VSELNM7,VSELNM8,VSELNM9,VSELNM10 };

voice_sel(file,voice,vw)
char voice[],file[];
int vw;	/*	workstation handle	*/
{
	OBJECT *box;
	int x,y,w,h;	/*	coordinates of dialog box	*/
	int result,size,selection;
	int tag = -1;
	register int i;
	char *ptr,*p;

	selection = 0;
	rsrc_gaddr(R_TREE,V_SEL,&box);
	form_center(box,&x,&y,&w,&h);
	vreset(0,box,VSELTRK,VSELSLID,22,22);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	if((ptr = rindex(file,'\\')) == NULL)
		ptr = file;
	else
		++ptr;
	if((p = rindex(ptr,'.')) != NULL)
		*p = '\0';
	strcpy(((TEDINFO *)(box[VSELNAME].ob_spec))->te_ptext,ptr);
	get_names(voice,names);	/*	get voice names	*/
	write_names(box,names,x,y,w,h,0,-1,FALSE);
	objc_draw(box,0,10,x,y,w,h);
	do
	{
		result = form_do(box,0);
		switch(result)
		{
			case VSELUP:
			case VSELDN:
			case VSELTRK:
			case VSELSLID:
				do_vslider(0,box,VSELTRK,VSELSLID,VSELUP,VSELDN,result,4);
				selection = 22 - slidpos[0];
				write_names(box,names,x,y,w,h,selection,tag,TRUE);
				break;
			case VSELNM1:
			case VSELNM2:
			case VSELNM3:
			case VSELNM4:
			case VSELNM5:
			case VSELNM6:
			case VSELNM7:
			case VSELNM8:
			case VSELNM9:
			case VSELNM10:
				for(i=0;(i<10) && (result != name_indexes[i]);++i);
				tag = selection + i;
				write_names(box,names,x,y,w,h,selection,tag,TRUE);
				break;
			case VS_OK:
				if(tag == -1)
				{
					form_alert(1,"[3][You Must select|a voice!][Gee-Whiz]");
					result = -1;
				}
				break;
		}	/*	end switch result	*/
	}while((result != VS_OK) && (result != VS_CAN));
	box[result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
	return(tag);
}

get_names(v,n)
char v[],n[32][11];
{
	register int iv,ii,i;

	iv = 118;
	for(i=0;i<32;++i)
	{
		for(ii=0;ii<10;++ii)
		{
			n[i][ii] = v[iv + ii];
		}
		n[i][ii] = '\0';	/*	null terminator	*/
		iv += 128;
	}
}

write_names(box,names,x,y,w,h,n,tag,update)
OBJECT *box;
char names[32][11];
int x,y,w,h,n,tag;
int update;
{
	register int i;

	for(i=0;i<10;++i)
	{
		if((i + n) == tag)
		{
			strcpy(box[name_indexes[i]].ob_spec,names[i + n]);
			box[name_indexes[i]].ob_state = SELECTED;
			strcpy(voice_name,names[i + n]);
		}
		else
		{
			strcpy(box[name_indexes[i]].ob_spec,names[i + n]);
			box[name_indexes[i]].ob_state = NORMAL;
		}
	}
	if(update)
		objc_draw(box,VSELBOX,2,x,y,w,h);
}

do_arrows(operation,whand,vw,nlines,col,line)
int operation,whand,vw;
int nlines;
int *col,*line;
{
	int x,y,w,h,wlines,wcols;
	extern gl_wchar,gl_hchar,xlines;
	int vertical,horizontal;

	wind_get(whand,WF_WORKXYWH,&x,&y,&w,&h);
	wlines = h / gl_hchar;	/*	calculate number of line in window	*/
	wcols = w / gl_wchar;	/*	calculate number of columns in window	*/
	switch (operation)
	{
		case PAGE_UP:
			*line -= wlines;
			if (*line < 0)
				*line = 0;
			break;
		case PAGE_DN:
			*line += wlines;
			if (*line > nlines - wlines)
				*line = nlines - wlines;
			break;
		case ROW_UP:
			--*line;
			if(*line < 0 )
				*line = 0;
			break;
		case ROW_DN:
			++*line;
			if(*line > nlines - wlines)
				*line = nlines - wlines;
			break;
	}
	slide_pos(wlines,nlines,*line,&vertical);
	wind_set(whand,WF_VSLIDE,vertical,0,0,0);
}

slide_pos(visible,total,line,pos)
int visible,total,line,*pos;
{
	*pos = 1000l * line / (total - visible);
}

v_touched(whand,vw,vertical,nlines,line)
int whand,vw,vertical,nlines;
int *line;
{
	int x,y,w,h,wlines;
	extern int gl_hchar;

	wind_get(whand,WF_WORKXYWH,&x,&y,&w,&h);
	wlines = h / gl_hchar;
	pos_slide(wlines,nlines,line,vertical);
}

pos_slide(visible,total,line,pos)
int visible,total,*line,pos;
{
	*line = (pos * (total - visible)) / 1000l;
}

slide_size(visible,total,size)
int visible,total,*size;
{
	*size = 1000l * visible / total;
	if(*size <= 0 )
		*size = -1;
	if (*size > 1000)
		*size = 1000;
}
