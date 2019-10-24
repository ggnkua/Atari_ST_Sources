#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <math.h>

#include "DEFINES.H"
#include "MAIN.H"
#include "COOKIES.H"
#include "VOX_H.H"
#include "VOX.H"
#include "VARS.H"
#include "appgpath.h"
#include "fselect.h"
#include "rsrcinit.h"
#include "hard.h"

int ability;

/* Routine principale : main */

int main(void)
{
	ap_id=appl_init();
	if (rsrc_load(rsrc_name)==0)
		alerte(A_RSRC_NOT_FOUND);
	else
	{
		Fsetdta(&FirstDta);
		app_get_path(app_path);
		ability=init_dsp();
		if ((unsigned int)ability>=0x8000)
		{
			open_work();
			wind_get(0,WF_WORKXYWH,&xb,&yb,&wb,&hb);
			init_interface();
			menu_bar(adr_menu,1);
			graf_mouse(ARROW,0);
			do	
			{
				prg_loop();
			}while(quit==FALSE);
			my_wind_new();
			menu_bar(adr_menu,0);
			byebye();
			rsrc_free();
		}
		else if (ability==0)
			alerte(A_LOD_NOT_FOUND);
		else if (ability==1)
			alerte(A_DSP_LOCKED);
	}
	appl_exit();
	Dsp_Unlock();
	return 0;
}


void my_wind_new(void)
{
	int i;
	for (i=0;i<=nb_window;i++)
	{
		if (window[i].hwind>0)
			WindClose(i);
	}
}

void my_wind_new2(void)
{
	int i;
	for (i=0;i<=nb_window;i++)
	{
		if (window[i].hwind>0)
			WindClose2(i);
	}
}
 
  
void prg_loop(void)
{
	int temp;
    event=xform_do((MU_KEYBD|MU_BUTTON|MU_MESAG|MU_TIMER),adr_desk);

	/* Cas sp‚cial pour une s‚lection dans le menu */
	if ((event & MU_MESAG) && (buf[0]==MN_SELECTED))
	{
		temp=buf[3];
		menu_tnormal(adr_menu, temp, 0);
		switch(buf[4])
	    {
			case M0_QUIT:
				quit=TRUE;
				break;
		}	
		menu_tnormal(adr_menu,temp,1);
		wait_mouse();
	}

	if (!FlagDefault)
		wind_handle=wind_find(mx,my);
	else
		wind_get(0,WF_TOP,&wind_handle,&dummy,&dummy,&dummy);
	FlagDefault=FALSE;
	wind_index=find_index(wind_handle);
	wind_indexGem=find_index(buf[3]);

    if (event & MU_MESAG)
	{
		switch(buf[0])
		{
			case WM_REDRAW:
   			    redraw(buf[3],buf[4],buf[5],buf[6],buf[7]);
   			    break;
			case WM_TOPPED:
				wind_set(buf[3], WF_TOP, &dummy, &dummy, &dummy, &dummy);
				break;
			case AP_TERM:
				my_wind_new();
				Free();
				quit=TRUE;
				break;
			case WM_CLOSED:
				WindClose(find_index(buf[3]));
				for(flacc=0,i=0;i<=nb_window;i++)
				{
					if (window[i].hwind!=0);
					{
						flacc=TRUE;
						break;
					}
				}
				break;
			case WM_FULLED:
				fulled();
				break;
			case WM_ARROWED:
			case WM_HSLID:
			case WM_VSLID:
			case WM_SIZED:
				resize();
				break;
			case WM_BOTTOM:
				wind_set(buf[3],WF_BOTTOM,&dummy,&dummy,&dummy,&dummy);
				break;
			case WM_ICONIFY:
				if (window[W_PRG_GRP].opened)
				{
					wind_get(window[W_PRG_GRP].hwind,WF_CURRXYWH,&xi,&yi,&wi,&hi);
					wind_get(buf[3], WF_CURRXYWH, &xw, &yw, &ww, &hw);
					window[wind_index].x=xw;
					window[wind_index].y=yw;
					window[wind_index].w=ww;
					window[wind_index].h=hw;
					graf_shrinkbox(xi,yi,wi,hi,xw,yw,ww,hw);
					wind_close(buf[3]);
					window[wind_index].opened=0;
				}
				else if (window[wind_indexGem].iconified==0)
				{
					wind_get(buf[3], WF_CURRXYWH, &xw, &yw, &ww, &hw);
					graf_shrinkbox(buf[4], buf[5], buf[6], buf[7], xw, yw, ww, hw);
					wind_set(buf[3], WF_NAME, window[wind_indexGem].title_icn);
					wind_set(buf[3], WF_ICONIFY, buf[4], buf[5], buf[6], buf[7]);
					window[wind_indexGem].iconified=TRUE;
				}
				break;
			case WM_UNICONIFY:
				if (wind_indexGem==W_PRG_GRP)
				{
					wind_get(window[W_PRG_GRP].hwind,WF_CURRXYWH,&xi,&yi,&wi,&hi);
					wind_close(window[W_PRG_GRP].hwind);
					wind_delete(window[W_PRG_GRP].hwind);
					window[W_PRG_GRP].hwind=0;
					window[W_PRG_GRP].opened=0;
					for(i=0;i<nb_window;OpenPrgIconifiedWind(i++));
				}
				else if (window[wind_indexGem].iconified!=0)
				{
					UniconifyWind(buf[3],buf[4],buf[5],buf[6],buf[7]);
				}
				break;	
				
			case WM_ALLICONIFY:
				if (window[W_PRG_GRP].hwind==0)
				{
					/* cr‚er/ouvrir fenetre iconifi‚e */
					window[W_PRG_GRP].hwind=wind_create(NAME|MOVER,xb,yb,wb,hb);
					wind_set(window[W_PRG_GRP].hwind,WF_NAME,window[W_PRG_GRP].title_icn);
					wind_set(window[W_PRG_GRP].hwind,WF_ICONIFY,buf[4],buf[5],buf[6],buf[7]);
					wind_open(window[W_PRG_GRP].hwind,buf[4],buf[5],buf[6],buf[7]);
					window[W_PRG_GRP].iconified=TRUE;
					window[W_PRG_GRP].opened=TRUE;
				}
				
				for(i=0;i<nb_window;i++)
				{
					temp=window[i].hwind;
					if (window[i].opened)
					{
						wind_get(temp, WF_CURRXYWH, &xw, &yw, &ww, &hw);
						window[i].x=xw;
						window[i].y=yw;
						window[i].w=ww;
						window[i].h=hw;
						graf_shrinkbox(buf[4],buf[5],buf[6],buf[7],xw,yw,ww,hw);
						wind_close(temp);
						window[i].opened=0;
					}
				}
			
				break;
				
			case WM_MOVED:
				wind_get(buf[3], WF_CURRXYWH, &xw, &yw, &ww, &hw);
	    		graf_movebox(ww, hw, xw, yw, buf[4], buf[5]);
				wind_set(buf[3], WF_CURRXYWH, buf[4], buf[5], buf[6], buf[7]);
				if (window[wind_indexGem].iconified==0)
				{
					wind_get(buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);
					window[wind_indexGem].form->ob_x=xw;
					window[wind_indexGem].form->ob_y=yw;
				}
				break;
		}
    }
    
    /* Programme principal */

	call_main(event,wind_handle,objet,buf);
}


void open_work(void)
{
	int i, a, b;
	COOKIE *p;
	for (i=0;i<10;_VDIParBlk.intin[i++]=1);
	_VDIParBlk.intin[0]=Getrez()+2;
	_VDIParBlk.intin[10]=2;
	handle=graf_handle(&a,&b,&i,&WorkHCeil);
	v_opnvwk(_VDIParBlk.intin, &handle,_VDIParBlk.intout);
	nb_colors=_VDIParBlk.intout[13];
	Xresolution=(_VDIParBlk.intout[0]);
	Yresolution=(_VDIParBlk.intout[1]);
	p=get_cookie('_AKP');
	gl_lang=((p->v.l)&0x0000ff00)>>8;
}

void send_redraw_message(int wh,int x,int y,int w,int h)
{
	buf[0]=WM_REDRAW;		/* Num‚ro du message */
	buf[1]=ap_id;			/* Indentificateur exp‚diteur du message */
	buf[2]=0;				/* Pas d'exc‚dent au message */
	buf[3]=wh;				/* Handle fenˆtre concern‚e */
	buf[4]=x;				/* Cordonn‚e zone redraw (bureau) */
	buf[5]=y;
	buf[6]=w;
	buf[7]=h;
	appl_write(ap_id,16,buf);
}            

void redraw_w_objc(int index,int objc)
{
	OBJECT *adr;
	int x0,y0;
	adr=window[index].form;
	objc_offset(adr,objc,&x0,&y0);
	y0+=4;
	send_redraw_message(window[index].hwind,x0-3,y0-3,adr[objc].ob_width+6,adr[objc].ob_height+6);
}

void send_redraw(int wh, OBJECT *obj, int o, int prof)
{
	int index=find_index(wh);
	if ((window[index].opened) && !(window[index].iconified))
		redraw_w_rect(wh,obj,o,prof-1);
}


void redraw_w_rect(int wh,OBJECT *obj, int o, int prof)
{
	GRECT r,rd;
	int error;
	my_wind_update(BEG_UPDATE);
	objc_offset(obj,o,&rd.g_x,&rd.g_y);
	rd.g_x-=3;
	rd.g_y-=3;
	rd.g_w=obj[o].ob_width+6;
	rd.g_h=obj[o].ob_height+6;
	error=wind_get(wh, WF_FIRSTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	while(r.g_w && r.g_h && error!=0)
	{
		if (rc_intersect(&rd, &r))
			objc_draw(obj,o,prof,r.g_x,r.g_y,r.g_w, r.g_h);
		error=wind_get(wh, WF_NEXTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	}
	my_wind_update(END_UPDATE);
}


int my_wind_get(int handle, int mode, int *parm1, int *parm2, int *parm3, int *parm4)
{
    _GemParBlk.contrl[0]=104;
    _GemParBlk.contrl[1]=2;
    _GemParBlk.contrl[2]=5;
    _GemParBlk.contrl[3]=0;
    _GemParBlk.contrl[4]=0;
    _GemParBlk.intin[0]=handle;
    _GemParBlk.intin[1]=mode;
	_crystal(&aespb);
    *parm1=_GemParBlk.intout[1];
    *parm2=_GemParBlk.intout[2];
    *parm3=_GemParBlk.intout[3];
    *parm4=_GemParBlk.intout[4];
    return _GemParBlk.intout[0];
}

void Free(void)
{
}

int alerte(int index)
{
	char *alrt;
	rsrc_gaddr(R_FRSTR, index, &alrt);	/* Adr chaŒne pointeur sur pointeur */
	alrt=*((char **)alrt);				/* Pointeur sur le texte */
	return(form_alert(1,alrt));			/* Afficher l'alerte */
}

void WindClose(int index)
{
	int wh,xw,yw,ww,hw;
	wh=window[index].hwind;			
	wind_get(wh, WF_CURRXYWH, &xw, &yw, &ww, &hw);
	graf_shrinkbox(xw+ww/2, yw+hw/2, 0, 0, xw, yw, ww, hw);
	wind_close(wh);
	wind_delete(wh);
	WindClose2(index);
}

void WindClose2(int index)
{
	window[index].hwind=0;
	window[index].opened=0;
	window[index].iconified=0;
	window[index].fulled=0;
}

void UniconifyWind(int wh,int x,int y,int w,int h)
{
	int xw,yw,ww,hw,i;
	i=find_index(wh);
	wind_get(wh,WF_CURRXYWH,&xw,&yw,&ww,&hw);
	graf_growbox(xw,yw,ww,hw,x,y,w,h);
	wind_set(wh,WF_NAME,window[i].title);
	wind_set(wh,WF_UNICONIFY,x,y,w,h);
	window[i].iconified=FALSE;
}

void OpenPrgIconifiedWind(int index)
{
	int xw,yw,ww,hw;
	if ((window[index].hwind!=0) && (!window[index].opened))
	{
		xw=window[index].x;
		yw=window[index].y;
		ww=window[index].w;
		hw=window[index].h;
		graf_growbox(xi,yi,wi,hi,xw,yw,ww,hw);
		wind_open(window[index].hwind,xw,yw,ww,hw);
		window[index].opened=TRUE;
	}
}

void wind_form(int index)
{
	int x,y,w,h;
	int xf,yf,wf,hf;
	int attr=window[index].attr;
	if (window[index].hwind!=0)
	{
		if (!window[index].opened)
			OpenPrgIconifiedWind(index);		
		if (window[index].iconified)
		{
			my_wind_get(window[index].hwind,WF_UNICONIFY,&x,&y,&w,&h);
			UniconifyWind(window[index].hwind,x,y,w,h);
		}
		wind_set(window[index].hwind, WF_TOP);
	}
	else
	{
		x=window[index].form->ob_x;
		y=window[index].form->ob_y;
		w=window[index].form->ob_width;
		h=window[index].form->ob_height;
		wind_calc(WC_BORDER,attr,x,y,w,h,&xf,&yf,&wf,&hf);
		window[index].hwind=wind_create(attr,xf,yf,wf,hf);
		if (window[index].hwind>0)
		{
			graf_growbox(xf+wf/2,yf+hf/2,0,0,xf,yf,wf,hf);
			wind_set(window[index].hwind,WF_NAME,window[index].title);
			wind_open(window[index].hwind,xf,yf,wf,hf);
			window[index].opened=TRUE;
		}
		else
		{
			window[index].hwind=0;
			window[index].opened=0;
			form_error(4);
		}
	}
}

int find_index(int handle)								/* Chercher l'index de la fenˆtre */
{
	int i;
	no_index=0;
	for(i=0;i<=nb_window;i++)
	{
		if (handle==window[i].hwind)
			return i;
	}
	no_index=TRUE;
	return 0;
}

void redraw(int wind_handle, int x, int y, int w, int h)
{
	GRECT r, rd;
	int block;
	int index,error,iconified;
	int xi,yi,wi,hi;
	index=find_index(wind_handle);
	rd.g_x=x;
	rd.g_y=y;
	rd.g_w=w;
	rd.g_h=h;
	
	if (window[index].opened)
	{
		iconified=window[index].iconified;
		if (iconified)
		{
			my_wind_update(BEG_UPDATE);
			wind_get(wind_handle,WF_WORKXYWH,&xi,&yi,&wi,&hi);
			adr_icn[0].ob_x=xi;
			adr_icn[0].ob_y=yi;
			adr_icn[0].ob_width=wi;
			adr_icn[0].ob_height=hi;
			adr_icn[1].ob_x=(wi-adr_icn[1].ob_width)/2;
			adr_icn[1].ob_y=(hi-adr_icn[1].ob_height)/2;
			error=wind_get(wind_handle, WF_FIRSTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
			v_hide_c(handle);
			while(r.g_w && r.g_h && error!=0)
			{
				if (rc_intersect(&rd,&r))
					objc_draw(adr_icn,0,MAX_DEPTH,r.g_x,r.g_y,r.g_w, r.g_h);
				error=wind_get(wind_handle, WF_NEXTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
			}
			v_show_c(handle,1);
			my_wind_update(END_UPDATE);
		}
		else
		{
			if (!window[index].bloquante)
				block=0x0100;
		
			if (my_wind_update(BEG_UPDATE|block))
			{
				error=wind_get(wind_handle,WF_FIRSTXYWH,&r.g_x,&r.g_y,&r.g_w,&r.g_h);
				while((r.g_w) && (r.g_h) && (error))
				{
					if (rc_intersect(&rd,&r))
						redraw_window(index,&r);
					error=wind_get(wind_handle,WF_NEXTXYWH,&r.g_x,&r.g_y,&r.g_w,&r.g_h);
				}
				my_wind_update(END_UPDATE);
			}
			else
				send_redraw_message(wind_handle,x,y,w,h);
		}
	}
}


void set_clip(int clip_flag, GRECT *area)
{
	pxy[0]=area->g_x;
	pxy[1]=area->g_y;
	pxy[2]=area->g_w+area->g_x-1;
	pxy[3]=area->g_h+area->g_y-1;
	vs_clip(handle, clip_flag, pxy);
}


/********************************************************
 *														*
 *	xform_do()											*
 *														*
 *	D'aprŠs les articles de Claude ATTARD				*
 *														*
 ********************************************************/

int xform_do(int flags, OBJECT *address)
{
	OBJECT *adr;
	static char option[128];
	static char clavier[10];
	int evnt;
	int dummy,i;
	int top;
	int obflags,obstate;
	int inkey;

	objet=0;
	whandle=0;
	
  for( ; ; )
  {
	evnt=evnt_multi(flags, 2, 1, 1,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    buf, 100, 0, &mx, &my, &mk, &kbd, &key, &clik);

	kbd&=0xF;
	if (evnt & MU_KEYBD)
	{
		inkey=(key&0xFF00)>>8;
		wind_get(0,WF_TOP,&top,&dummy,&dummy,&dummy);
		adr=address;
		if ((address==adr_desk) && (top!=0))
		{
			for(i=0;i<=nb_window;i++)
			{		
       			if (top==window[i].hwind)
				{
					adr=window[i].form;
					break;
				}
			}
      	}

		if ((top!=0) && ((inkey==0x72) || (inkey==0x1C)))
		{
			i=0;
			do
			{
				if (adr[i].ob_flags & DEFAULT)
				{
					FlagDefault=TRUE;
					evnt=MU_BUTTON;
					objet=i;
					return(evnt);
				}
			} while (!(adr[i++].ob_flags & LASTOB));
		}
		else if (adr_menu)
		{
			BuildIkbd(inkey,kbd,clavier);
			if (clavier[0])
			{
				i=0;
				do
				{
					if (adr_menu[i].ob_type==G_STRING)
					{
						if (! (adr_menu[i].ob_state & DISABLED))
						{            
							strcpy(option,adr_menu[i].ob_spec.free_string);
							BuildItem(option);
							if (strcmp(option,clavier)==0)
							{
								evnt=MU_MESAG;
								buf[0]=MN_SELECTED;
								buf[3]=m_title(adr_menu,i);
								buf[4]=i;
								return evnt;
							}
						}
					}
				} while (! (adr_menu[i++].ob_flags & LASTOB));
			}
		}
	}


	if (evnt & MU_BUTTON)
	{
		wind_get(0,WF_TOP,&top,&dummy,&dummy,&dummy);
		adr=address;
		if (address==adr_desk)
		{
			whandle=wind_find(mx,my);
			if (whandle>0)
			{
				for(i=0;i<=nb_window;i++)
				{
					if (whandle==window[i].hwind)
					{
						adr=window[i].form;
						break;
					}
				}
			}
		}

		objet=objc_find(adr,ROOT,MAX_DEPTH,mx,my);
		if (objet>=0)
		{
			obflags=adr[objet].ob_flags;
	        obstate=adr[objet].ob_state;
			if ((obflags & SELECTABLE) && (!(obflags & RBUTTON)))
			{
				if (my_graf_watchbox(adr,objet,(obstate|SELECTED),obstate & !SELECTED)==0)
				{
					send_redraw(whandle,adr,objet,MAX_DEPTH);
					evnt=0;
					objet=-1;
				}
			}
		}
		
		if (objet>=0)
		{
			if (obstate & DISABLED)
				return(evnt);
  
			if ((obflags & SELECTABLE) && (!(obflags & RBUTTON)))
			{
				adr[objet].ob_state ^= SELECTED;
				send_redraw(whandle,adr,objet,MAX_DEPTH);
			}

			if (! (obflags & TOUCHEXIT))
				wait_mouse();
			return(evnt);
		}
	}
	
	if (evnt & MU_MESAG)
		return evnt;

	if (evnt & MU_TIMER)
		return evnt;
		
  }
}

char *BuildIkbd(int key, int shift, char *t)
{
 	char *s;
 	s=t;
	if (shift & K_CTRL)					*s++='^';
	if (shift & (K_RSHIFT|K_LSHIFT))	*s++=1;
	if (shift & K_ALT)					*s++=7;
   	if (key==97)						*s++=2;		/* undo */
	else if (key==98)					*s++=3;		/* help */
	else if (key==82)					*s++=4;		/* insert */
	else if (key==83)					*s++=5;		/* delete */
	else if (key==71)					*s++=6;		/* clr home */
	else if (key==14)					*s++=8;		/* back space */
	else if (key==28)					*s++=9;		/* return */
	else if (key==114)					*s++=10;	/* enter */
	else if (key==1)					*s++=11;	/* escape  */
	else if (key==15)					*s++=12;	/* tap */
	else
		stdkey(key,s++);
	*s=0;
	strlwr(t);
	return t;
}

char *BuildItem(char *t)
{
	char *s;
	char *u;
	u=t;
	trim(t);
	strlwr(t);
	for(s=t+strlen(t)-1 ; ((*s!=' ') && (s>=t)) ; *s--);
	
	if (*s==' ')
	{
		s++;
		if (Instr(s,"^"))		*u++='^';
		if (Instr(s,"\1"))		*u++=1;
		if (Instr(s,"\7"))		*u++=7;	
		if (Instr(s,"undo"))							*u++=2;		/* undo */
		else if (Instr(s,"help"))						*u++=3;		/* help */
		else if (Instr(s,"insert") || Instr(s,"ins"))	*u++=4;		/* insert */
		else if (Instr(s,"delete") || Instr(s,"del"))	*u++=5;		/* delete */
		else if (Instr(s,"clrhome"))					*u++=6;		/* clr home */
		else if (Instr(s,"backspace") || Instr(s,"bckspc"))	*u++=8;	/* back space */
		else if (Instr(s,"return"))						*u++=9;		/* return */
		else if (Instr(s,"enter"))						*u++=10;	/* enter */
		else if (Instr(s,"escape") || Instr(s,"esc"))	*u++=11;	/* esc */
		else if (Instr(s,"tab"))						*u++=12;	/* tab */
		else *u++=*(t+strlen(t)-1);
		*u=0;
	}
	else
		*t=0;
	return t;
}

int my_wind_update(int mode)
{
	return wind_update(mode);
}

int my_graf_watchbox(OBJECT *adr,int objet,int in,int out)
{
	int x,y,w,h;
	int mx,my,mk;
	int state;
	objc_offset(adr,objet,&x,&y);
	w=adr[objet].ob_width;
	h=adr[objet].ob_height;
	do
	{
		graf_mkstate(&mx,&my,&mk,&dummy);
		if (mx>x && mx<(x+w) && my>y && my<(y+h))
		{
			state=1;
			if (adr[objet].ob_state!=in)
			{
				adr[objet].ob_state=in;
				send_redraw(whandle,adr,objet,MAX_DEPTH);
			}
		}
		else
		{
			state=0;
			if (adr[objet].ob_state!=out)
			{
				adr[objet].ob_state=out;
				send_redraw(whandle,adr,objet,MAX_DEPTH);
			}
		}
	}while (mk & 0x1);
	return state;
}

void wait_mouse(void)
{
	int mclic,dummy;
	graf_mkstate (&dummy,&dummy,&mclic,&dummy);
	while (mclic & 0x1);
		graf_mkstate (&dummy, &dummy, &mclic, &dummy);
}



int parent(OBJECT *adr, int object)
{
	int i;
	i=object;
	do
	{
		i=adr[i].ob_next;
	} while (i>object);
	return i;
}


int next(OBJECT *adr)
{
	int pere;
	int vu=1;
	int ob=edit;
	while (!(adr[ob++].ob_flags & LASTOB))
	{
		pere=parent(adr, ob);
		while ((pere>0) && (vu))
		{
			if (adr[pere].ob_flags & HIDETREE)
    	    	vu=0;
			pere=parent(adr,pere);
	    }
		if	((vu) && (adr[ob].ob_flags & EDITABLE) && (!(adr[ob].ob_flags & HIDETREE)) && (!(adr[ob].ob_state & DISABLED)))
			return ob;
	}
	return -1;
}


int prev(OBJECT *adr)
{
	int pere;
	int vu=1;
	int ob=edit;
	while ((ob--)>0)
	{
		pere=parent(adr, ob);
		while ((pere>0) && (vu))
    	{
			if (adr[pere].ob_flags & HIDETREE)
				vu=0;
			pere=parent(adr, pere);
		}
    
		if	((vu) && (adr[ob].ob_flags & EDITABLE) &&
			(!(adr[ob].ob_flags & HIDETREE)) &&
			(!(adr[ob].ob_state & DISABLED)))
			return ob;
	}
	return -1;
}


void stdkey(int key,char *k)
{
	KEYTAB *kt=Keytbl((void *)-1,(void *)-1,(void *)-1);
	*k=(char)toupper((kt->unshift[key])&0x00FF);
}


char *trim(char *str)
{
	char *s;
	int i=0;
	char chaine[MAX_LEN];
	while (*(str+i)==' ')
		i++;
		strcpy (chaine,(str+i));
	s=chaine+strlen(chaine)-1;
	for( ; (*s==' ') && (s>=chaine); *s-- = 0);
	strcpy(str, chaine);
	return str;
}


int m_title(OBJECT *adresse, int option)
{
	int menu=1, k=2;
	int pere, titre;
	pere=parent(adresse, option);
	while (adresse[(k++)+1].ob_type!=G_BOX);
	while (k!=pere)
	{
		k=adresse[k].ob_next;
		menu++;
	}
	k=3;
	do
	{
		titre=k++;
	} while ((k-3)!=menu);
	return titre;
}

void init_interface(void)
{
	rsrc_init(rsrc_name);
	aespb.global=_GemParBlk.global;
	aespb.contrl=_GemParBlk.contrl;
	aespb.intin=_GemParBlk.intin;
	aespb.intout=_GemParBlk.intout;
	aespb.addrin=(int *)_GemParBlk.addrin;
	aespb.addrout=(int *)_GemParBlk.addrout;
	vdipb.contrl=_VDIParBlk.contrl;
	vdipb.intin=_VDIParBlk.intin;
	vdipb.ptsin=_VDIParBlk.ptsin;
	vdipb.intout=_VDIParBlk.intout;
	vdipb.ptsout=_VDIParBlk.ptsout;
	
	rsrc_gaddr(0, BUREAU,		&adr_desk);  /* Demander adresse bureau */
	rsrc_gaddr(0, F_INFOS,		&window[W_INFOS].form);
	rsrc_gaddr(0, F0,			&window[W_F0].form);
	rsrc_gaddr(0, F01,			&window[W_F01].form);
	rsrc_gaddr(0, F1,			&window[W_F1].form);
	rsrc_gaddr(0, F2,			&window[W_F2].form);
	rsrc_gaddr(0, M_MAIN,		&adr_menu);
	rsrc_gaddr(0, F_ICONE,		&adr_icn);

	for(i=0;i<=nb_window;i++)
	{
		form_center(window[i].form,&x,&y,&w,&h);
		window[i].iconified=0;
		window[i].hwind=0;
		window[i].opened=0;
		window[i].pos=0;
		window[i].attr=(NAME|MOVER|CLOSER|SMALLER);
	}
	InitRessource();
}
