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
/*	#include <strings.h>	*/
#include "dx.h"
#include "dxed.h"

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
int xlines;
static int cur_line, cur_col;

voice_sel(file,voice,vw)
char voice[],file[];
int vw;	/*	workstation handle	*/
{
	OBJECT *box;
	int wh;	/*	handle for voice name window	*/
	int cx,cy,cw,ch;	/*	coordinates of dialog box	*/
	int wix,wiy,wiw,wih;	/*	coordinates of window	*/
	int w_kind,result,size,selection;

		rsrc_gaddr(R_TREE,V_SEL,&box);
		form_center(box,&cx,&cy,&cw,&ch);
		form_dial(FMD_START,cx,cy,0,0,cx,cy,cw,ch);
		form_dial(FMD_GROW,cx,cy,0,0,cx,cy,cw,ch);
		objc_draw(box,0,10,cx,cy,cw,ch);
		wix = cx + 16;
		wiy = cy + 32;
		wiw = 10 * gl_wchar;
		wih = 10 * gl_hchar;
		w_kind = NAME | UPARROW | DNARROW | VSLIDE;
		wind_calc(0,w_kind,wix,wiy,wiw,wih,&wix,&wiy,&wiw,&wih);
		wh = wind_create(w_kind,wix,wiy,wiw,wih);
		wind_set(wh,WF_NAME,file,0,0);
		slide_size(10,32,&size);
		wind_set(wh,WF_VSLSIZE,size,0,0,0);
		wind_open(wh,wix,wiy,wiw,wih);
		result = do_it(wh,cx,cy,cw,ch,box,voice,vw,&selection);
		box[result].ob_state = NORMAL;
		wind_close(wh);	/*	get rid of window	*/
		wind_delete(wh);
		form_dial(FMD_SHRINK,cx,cy,0,0,cx,cy,cw,ch);
		form_dial(FMD_FINISH,cx,cy,0,0,cx,cy,cw,ch);
		wind_update(TRUE);
		return(selection);
}

int do_it(wh,x,y,w,h,box,v,vw,val)
int wh;	/*	handle of window that contains the names of voices	*/
int x,y,w,h;	/*	size of dialog box	*/
OBJECT *box;
char v[];
int vw,*val;	/*	virtual workstation handle	*/
{
	char names[32][11];
	int wix,wiy,wiw,wih;
	int xy[4],m[10],event,mouse_flag,mx,my,dummy,bbotton,nclick;
	int result,exit,button,tag;
	int m_stat,m_x,m_y;

	tag = -1;
	get_names(v,names);
	wind_get(wh,WF_WORKXYWH,&wix,&wiy,&wiw,&wih);
	xy[0] = wix;
	xy[1] = wiy;
	xy[2] = wix + wiw - 1;
	xy[3] = wiy + wih - 1;
	vs_clip(vw,1,xy);	/*	set cliping rectangle	*/
	cur_line = 0;
	write_names(names,wix,wiy,wiw,cur_line,vw,tag);
	exit = TRUE;
	button = TRUE;
	mouse_flag = TRUE;
	wind_update(FALSE);
	do
	{
		event = evnt_multi(MU_TIMER | MU_M1 | MU_M2 | MU_MESAG,
				1,			/*	how many clicks possible	*/
				1,			/*	any bottons can click	*/
				1,		/*	if botton down, wait for up, etc	*/
				1,x,y,w,h,	/*	exit mouse rectangle 1	*/
				0,x,y,w,h,	/*	enter mouse rectangle 2	*/
				m,			/*	ipc & timer messages	*/
				100,			/*	low word of timer value	*/
				0,			/*	high word	*/
				&mx,&my,	/*	mouse coordinates	*/
				&bbotton,	/*	mouse button states	*/
				&dummy,		/*	shift key states	*/
				&dummy,		/*	the key that was hit	*/
				&nclick		/*	number of mouse clicks hit	*/
				);
		wind_update(TRUE);
		if(event & MU_MESAG)	/*	handle a message event	*/
		{
			switch(m[0])
			{
				case WM_ARROWED:
					do_arrows(m[4],wh,vw,NLINES,&dummy,&cur_line);
					write_names(names,wix,wiy,wiw,cur_line,vw,tag);
					break;
				case WM_VSLID:
					v_touched(wh,vw,m[4],NLINES,&cur_line);
					wind_set(wh,WF_VSLIDE,m[4],0,0,0);
					write_names(names,wix,wiy,wiw,cur_line,vw,tag);
					break;	
			}
		}
		vq_mouse(vw,&m_stat,&m_x,&m_y);
		if(m_stat & 0x01)
		{
			if(mouse_flag)
			{
			
				if((result = objc_find(box,VS_OK,0,m_x,m_y)) >= 0)	/*	see if we got anything	*/
				{
					objc_change(box, VS_OK,0,x,y,w,h,SELECTED,1);
					if(tag == -1)
					{
						form_alert(1,"[1][Must select | voice first][Gosh]");
						objc_change(box, VS_OK,0,x,y,w,h,NORMAL,1);
					}
					else
						exit = FALSE;
				}
				else if((result = objc_find(box,VS_CAN,0,m_x,m_y)) >= 0)
				{
					objc_change(box,VS_CAN,0,x,y,w,h,SELECTED,1);
					tag = -1;	/*	canceled, change tag back	*/
					exit = FALSE;
				}
				if(wind_find(m_x,m_y) == wh)	/*	clicked in window	*/
				/*
					if in window, see if in working area	*/
				{
					if((m_x > wix) && (m_x < wix + wiw) &&
						(m_y > wiy) && (m_y < wiy + wih))
					{
						/*	find index of item clicked	*/
						tag = (m_y - wiy)/(8 * res) + cur_line;
						write_names(names,wix,wiy,wiw,cur_line,vw,tag);
					}
				}
				if(button)
					button = FALSE;
				else
					button = TRUE;
			}
			else
			{
				Bconout(2,'G' & 0x0f);
			}
		}
		if (event & MU_M1 )	/*	left mouse clip rectangle	*/
		{
			mouse_flag = FALSE;
		}
		if (event & MU_M2)	/*	enter mouse clip rectangle	*/
		{
			mouse_flag = TRUE;
		}
		wind_update(FALSE);
	}while(exit);
	*val = tag;
	return(result);
}

get_names(v,names)
char v[],names[32][11];
{
	int iv,ii,i;

	hide_mouse();
	iv = 118;
	for(i=0;i<32;++i)
	{
		for(ii=0;ii<10;++ii)
		{
			names[i][ii] = v[iv + ii];
		}
		names[i][10] = '\0';	/*	null terminator	*/
		iv += 128;
	}
	show_mouse();
}

write_names(names,x,y,w,n,vw,tag)
char names[32][11];
int x,y,w,n,vw,tag;
{
	int i,xy[4];

	hide_mouse();
	y = y + 6 * res;
	for(i=0;i<10;++i)
	{
		if((i + n) == tag)
		{
			v_gtext(vw,x,y,names[i + n]);
			vswr_mode(vw,3);
			vsf_interior(vw,2);
			vsf_style(vw,8);
			vsf_color(vw,0);
			xy[0] = x;
			xy[1] = y - 6 * res - 1;
			xy[2] = x + w;
			xy[3] = y + 2 * res - 1;
			v_bar(vw,xy);
			vswr_mode(vw,1);
		}
		else
		{
			v_gtext(vw,x,y,names[n + i]);
		}
		y = y + 8 * res;
	}
	show_mouse();
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
