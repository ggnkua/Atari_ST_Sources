#include <grape_h.h>
#include "grape.h"
#include "mforms.h"
#include "layer.h"
#include "xrsrc.h"
#include "maininit.h"
#include "main_win.h"
#include "timeshow.h"
#include "zoom.h"

extern void draw_getframe(int wx, int wy, _frame_data *fd);
extern void correct(_frame_data *f);
void set_zoom_center(int in_out, int x, int y);

void zoom_frame(_frame_data *fd, int wid)
{
	int a, w, h, zoom, zoom1, zoom2;
	
	wind_get(wid, WF_WORKXYWH, &a, &a, &w, &h);
	h-=(otoolbar[0].ob_height+OTBB);
	
	if((fd->w < 2) && (fd->h < 2))
	{/* Zoom Festfaktor in */
		a=atoi(ospecial[SOFAK].ob_spec.tedinfo->te_ptext);
		if(a==0) a=1;
		if(zoomin)
			set_zoom_center(zoomin+a, fd->x, fd->y);
		else
			set_zoom_center(-(zoomout-a), fd->x, fd->y);
		return;		
	}
	
	/* Zoom passend zu Rahmen w„hlen */
	/* Es kann wg. assymmetrischer Fensterverh„ltnisse nicht einfach
		 das kleinere Zoomverh„ltnis genommen werden! */
	zoom1=w/fd->w;
	zoom2=h/fd->h;
	if((long)fd->h*(long)zoom1 > h)
		zoom1=0;	/* Bei Benutzung des Breitenverh„ltnisses reicht die H”he nicht! */
	if((long)fd->w*(long)zoom2 > w)
		zoom2=0;	/* Bei Benutzung des H”henverh„ltnisses reicht die Breite nicht! */
	
	/* Gr”žerer Zoom wird genommen */
	zoom=(zoom1 > zoom2)? zoom1 : zoom2;

	set_zoom_center(zoom, fd->x+fd->w/2, fd->y+fd->h/2);
}

void free_zoom_in(int wid)
{
	int				stx, sty, ox, oy, mx, my, k, dum, vx, vy, vw, vh;
	int				wx,wy;
	_frame_data	getframe;
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	
	vswr_mode(handle, 3);
	vsl_type(handle, 1);
  vsl_width(handle, 1);
  vsl_color(handle, 1);
  vsl_ends(handle, 0, 0);
  vsm_type(handle, 0);
  vsf_interior(handle, 1);
  vsf_color(handle, 1);
  vsf_perimeter(handle, 1);

	wind_get(wid, WF_WORKXYWH, &stx, &sty, &vw, &vh);
	sty+=(otoolbar[0].ob_height+OTBB); vh-=(otoolbar[0].ob_height+OTBB);
	wx=stx; wy=sty;
	/* Tats„chlich sichtbarer Bereich: */
	vx=main_win.ox*MZOP; vy=main_win.oy*MZOP;
	vw=vw*MZOP; vh=vh*MZOP;
	if(vw > first_lay->this.width) vw=first_lay->this.width;
	if(vh > first_lay->this.height) vh=first_lay->this.height;
	ox=oy=0;
	graf_mouse(USER_DEF, UD_ZOOM_IN);
	graf_mkstate(&mx, &my, &k, &dum);
	mx-=stx; mx+=main_win.ox;	mx=mx*MZOP;
	my-=sty; my+=main_win.oy;	my=my*MZOP;
	if(mx < vx) mx=vx; if(mx > vx+vw)mx=vx+vw;
	if(my < vy) my=vy; if(my > vy+vh) my=vy+vh;
	getframe.x=mx; getframe.y=my; getframe.w=0; getframe.h=0;
	draw_getframe(wx,wy,&getframe);
	do
	{
		graf_mkstate(&mx, &my, &k, &dum);
		mx-=stx; mx+=main_win.ox;	mx=mx*MZOP;
		my-=sty; my+=main_win.oy;	my=my*MZOP;
		if(mx < vx) mx=vx; if(mx > vx+vw)mx=vx+vw;
		if(my < vy) my=vy; if(my > vy+vh) my=vy+vh;
		if((mx != ox)||(my != oy))
		{
			ox=mx; oy=my;
			draw_getframe(wx,wy,&getframe);
			getframe.w=mx-getframe.x;
			getframe.h=my-getframe.y;
			draw_getframe(wx,wy,&getframe);
		}
	}while(k&1);
	draw_getframe(wx, wy, &getframe);
	correct(&getframe);
	zoom_frame(&getframe, wid);
	graf_mouse(ARROW, NULL);	
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}
void free_zoom_out(int wid)
{
	int a, mx, my, stx, sty, vx, vy, vw, vh;

	wind_get(wid, WF_WORKXYWH, &stx, &sty, &vw, &vh);
	sty+=(otoolbar[0].ob_height+OTBB); vh-=(otoolbar[0].ob_height+OTBB);
	/* Tats„chlich sichtbarer Bereich: */
	vx=main_win.ox*MZOP; vy=main_win.oy*MZOP;
	vw=vw*MZOP; vh=vh*MZOP;
	if(vw > first_lay->this.width) vw=first_lay->this.width;
	if(vh > first_lay->this.height) vh=first_lay->this.height;
	graf_mkstate(&mx, &my, &a, &a);
	mx-=stx; mx+=main_win.ox;	mx=mx*MZOP;
	my-=sty; my+=main_win.oy;	my=my*MZOP;
	if(mx < vx) mx=vx; if(mx > vx+vw)mx=vx+vw;
	if(my < vy) my=vy; if(my > vy+vh) my=vy+vh;

	a=atoi(ospecial[SOFAK].ob_spec.tedinfo->te_ptext);
	if(a==0) a=1;
	
	if(zoomin)
		set_zoom_center(zoomin-a, mx, my);
	else
		set_zoom_center(-(zoomout+a), mx, my);
}

void fit_zoom(void)
{/* Passenden Zoomfaktor w„hlen, so daž Bild in Fenster pažt */
	int iw, ih, sw, sh, dum, z;
	
	if(main_win.id < 0) return;

	wind_get(main_win.id, WF_WORKXYWH, &dum, &dum, &sw, &sh);
	sh-=otoolbar[0].ob_height+OTBB;
	iw=first_lay->this.width;
	ih=first_lay->this.height;
	
	z=1;

	if((iw > sw) || (ih > sh))
	{
		while((iw/z > sw)||(ih/z > sh))
			++z;
		z=-(z-1);
	}
	else
	{
		while((iw*(z+1) < sw) && (ih*(z+1) < sh))
			++z;
		--z;
	}
	set_zoom(z);
}


void mitoa(int a, char *num)
{/* Zahl a in 3-stelligen Text wandeln, fhrende Spaces einfgen */
	if(a < 100)
		num[0]=32;
	else
	{	num[0]=(a/100)+48;	a-=(a/100)*100;}
	if(a < 10)
		num[1]=32;
	else
	{	num[1]=(a/10)+48;	a-=(a/10)*10;}
	num[2]=a+48;
	num[3]=0;
}
void mzitoa(int a, char *num)
{/* Zahl a in 3-stelligen Text wandeln, fhrende "0"er einfgen */
	num[0]=(a/100)+48;
	a-=(a/100)*100;
	num[1]=(a/10)+48;
	a-=(a/10)*10;
	num[2]=a+48;
	num[3]=0;
}

void fzooms_to_menu(void)
{
	int a, in, out, ix;
	char	num[4];
	
	for(a=0; a < 6; ++a)
	{
		ix=FZ1+a*(FZ2-FZ1); /* Index des Rahmens */
		in=out=1;
		if(ofzooms[ix+(FZBIG-FZ1)].ob_state & SELECTED)
			in=atoi(ofzooms[ix+(FZNUM-FZ1)].ob_spec.tedinfo->te_ptext);
		else
			out=atoi(ofzooms[ix+(FZNUM-FZ1)].ob_spec.tedinfo->te_ptext);
		if((in==0)||(out==0))
			in=out=1;
		mitoa(in, num);
		strncpy(&(mmenu[MZ1+a].ob_spec.free_string[7]), num, 3);
		itoa(out, num, 10);
		while(strlen(num) < 3) strcat(num, " ");
		strncpy(&(mmenu[MZ1+a].ob_spec.free_string[11]), num, 3);
	}
}

void menu_to_fzooms(void)
{
	int a, in, out, ix;
	char	num[4], *p;
	
	for(a=0; a < 6; ++a)
	{
		ix=FZ1+a*(FZ2-FZ1); /* Index des Rahmens */
		num[4]=0;
		strncpy(num, &(mmenu[MZ1+a].ob_spec.free_string[7]), 3);
		p=num;
		while(*p==' ')++p;
		in=atoi(p);
		strncpy(num, &(mmenu[MZ1+a].ob_spec.free_string[11]), 3);
		out=atoi(num);
		ofzooms[ix+(FZBIG-FZ1)].ob_state &=(~SELECTED);
		ofzooms[ix+(FZSML-FZ1)].ob_state &=(~SELECTED);
		((TED_COLOR*)&(ofzooms[ix+(FZ1BIG-FZ1)].ob_spec.tedinfo->te_color))->text_color=8; /* Hellgrau */
		((TED_COLOR*)&(ofzooms[ix+(FZ1SML-FZ1)].ob_spec.tedinfo->te_color))->text_color=8; /* Hellgrau */
		if(out == 1)
		{/* In reinschreiben */
			ofzooms[ix+(FZBIG-FZ1)].ob_state |=SELECTED;
			((TED_COLOR*)&(ofzooms[ix+(FZ1BIG-FZ1)].ob_spec.tedinfo->te_color))->text_color=1; /* Schwarz */
			mzitoa(in, ofzooms[ix+(FZNUM-FZ1)].ob_spec.tedinfo->te_ptext);
		}
		else
		{/* Out reinschreiben */
			ofzooms[ix+(FZSML-FZ1)].ob_state |=SELECTED;
			((TED_COLOR*)&(ofzooms[ix+(FZ1SML-FZ1)].ob_spec.tedinfo->te_color))->text_color=1; /* Schwarz */
			mzitoa(out, ofzooms[ix+(FZNUM-FZ1)].ob_spec.tedinfo->te_ptext);
		}
	}
}

void set_menu_zoom(int ob)
{/* Zoom entsprechend Meneintrag ob(=Objektnummer) setzen */
	int z;
	
	/* Erstmal ob auf 0-5 bringen */
	ob-=MZ1;
	/* Jetzt Zoom aus Zoomedit-Dialog holen */
	ob=FZ1+ob*(FZ2-FZ1); /* Index des Rahmens */
	z=atoi(ofzooms[ob+FZNUM-FZ1].ob_spec.tedinfo->te_ptext)-1; /* Zahlenwert */
	if(ofzooms[ob+FZSML-FZ1].ob_state & SELECTED) /* Outzoom? */
	z=-z;
	set_zoom(z);
}

void set_zoom_center(int in_out, int x, int y)
{/* in_out > 0 = in, < 0 = out, 0=1:1 */
 /* x,y: Zoom-Center. Bei -1,-1 wird Bildmitte eingesetzt */
	int pb[8];
	
	if(main_win.id < 0) return;
	
	wind_get(main_win.id, WF_WORKXYWH, &pb[4], &pb[5], &pb[6], &pb[7]);
	pb[7]-=otoolbar[0].ob_height+OTBB;
	pb[6]/=2;pb[7]/=2;
	/* Bildmittelpunkt 1:1 */
	if((x==-1)||(y==-1))
	{
		main_win.ox=(main_win.ox+pb[6])*MZOP;
		main_win.oy=(main_win.oy+pb[7])*MZOP;
	}
	else
	{
		main_win.ox=x;
		main_win.oy=y;
	}
	
	if(in_out < 0)
	{ zoomin=0; zoomout=-in_out;}
	else
	{ zoomout=0; zoomin=in_out;}
	/* Bildmittelpunkt neu festlegen und ox/oy anpassen */
	main_win.ox=(main_win.ox-pb[6]*MZOP)/DZOP;
	main_win.oy=(main_win.oy-pb[7]*MZOP)/DZOP;

	if(main_win.ox < 0) main_win.ox=0;	
	if(main_win.oy < 0) main_win.oy=0;	
	/* Anzeige „ndern */
	if((zoomin==0) && (zoomout==0))
		strcpy(otoolbar[TBZOOM].ob_spec.tedinfo->te_ptext, "1:1");
	else if(zoomin)
	{
		itoa(zoomin+1, otoolbar[TBZOOM].ob_spec.tedinfo->te_ptext, 10);
		strcat(otoolbar[TBZOOM].ob_spec.tedinfo->te_ptext,":1");
	}
	else
	{
		strcpy(otoolbar[TBZOOM].ob_spec.tedinfo->te_ptext,"1:");
		itoa(zoomout+1,&(otoolbar[TBZOOM].ob_spec.tedinfo->te_ptext[2]), 10);
	}
	
	wind_get(main_win.id, WF_CURRXYWH, &pb[4], &pb[5], &pb[6], &pb[7]);
	new_wsize_red(pb,0); /* Zeichnet immer Toolbar neu */
	redraw_pic();
}

void set_zoom(int in_out)
{
	set_zoom_center(in_out, -1, -1);
}


void zoom_out(void)
{
	if(zoomin)
		set_zoom(zoomin-1);
	else
		set_zoom(-(zoomout+1));
}
void zoom_in(void)
{
	if(zoomin)
		set_zoom(zoomin+1);
	else
		set_zoom(-(zoomout-1));
}

void	zoom_closed(WINDOW *win)
{
	w_close(win);
	w_kill(win);
}

void zoom_window(void)
{
	if(!wzoom.open)
	{
		/* Fenster initialisieren */
		wzoom.dinfo=&dzoom;
		w_kdial(&wzoom, D_CENTER, MOVE|NAME|BACKDROP|CLOSE);
		wzoom.closed=zoom_closed;
		wzoom.name="[Grape] Zoom";
		w_set(&wzoom, NAME);
		dzoom.dedit=SZNUM;
		w_open(&wzoom);
	}
	else
		w_top(&wzoom);
}

void dial_zoom(int ob)
{
	switch(ob)
	{
		case SZIN:
			w_unsel(&wzoom, ob);
			if(atoi(ozoom[SZNUM].ob_spec.tedinfo->te_ptext) == 0)
			{
				strcpy(ozoom[SZNUM].ob_spec.tedinfo->te_ptext, "001");
				w_objc_draw(&wzoom, SZNUM, 8, sx, sy, sw, sh);
			}
			set_zoom(atoi(ozoom[SZNUM].ob_spec.tedinfo->te_ptext)-1);
			
		break;
		case SZOUT:
			w_unsel(&wzoom, ob);
			if(atoi(ozoom[SZNUM].ob_spec.tedinfo->te_ptext) == 0)
			{
				strcpy(ozoom[SZNUM].ob_spec.tedinfo->te_ptext, "001");
				w_objc_draw(&wzoom, SZNUM, 8, sx, sy, sw, sh);
			}
			set_zoom(-atoi(ozoom[SZNUM].ob_spec.tedinfo->te_ptext)+1);
		break;
	}
}

void fzooms_window(void)
{
	if(!wfzooms.open)
	{
		/* Fenster initialisieren */
		wfzooms.dinfo=&dfzooms;
		w_dial(&wfzooms, D_CENTER);
		wfzooms.name="[Grape]";
		w_set(&wfzooms, NAME);
		dfzooms.dedit=FZNUM;
		w_open(&wfzooms);
	}
	else
		w_top(&wfzooms);
}

void dial_fzooms(int ob)
{
	switch(ob)
	{
		case FZSML:
		case FZSML+(FZ2-FZ1):
		case FZSML+(FZ2-FZ1)*2:
		case FZSML+(FZ2-FZ1)*3:
		case FZSML+(FZ2-FZ1)*4:
		case FZSML+(FZ2-FZ1)*5:
			((TED_COLOR*)&(ofzooms[ob-FZSML+FZ1BIG].ob_spec.tedinfo->te_color))->text_color=8; /* Hellgrau */
			((TED_COLOR*)&(ofzooms[ob-FZSML+FZ1SML].ob_spec.tedinfo->te_color))->text_color=1; /* Schwarz */
			w_objc_draw(&wfzooms, ob-FZSML+FZ1BIG, 8, sx, sy, sw, sh);
			w_objc_draw(&wfzooms, ob-FZSML+FZ1SML, 8, sx, sy, sw, sh);
		break;
		case FZBIG:
		case FZBIG+(FZ2-FZ1):
		case FZBIG+(FZ2-FZ1)*2:
		case FZBIG+(FZ2-FZ1)*3:
		case FZBIG+(FZ2-FZ1)*4:
		case FZBIG+(FZ2-FZ1)*5:
			((TED_COLOR*)&(ofzooms[ob-FZBIG+FZ1SML].ob_spec.tedinfo->te_color))->text_color=8; /* Hellgrau */
			((TED_COLOR*)&(ofzooms[ob-FZBIG+FZ1BIG].ob_spec.tedinfo->te_color))->text_color=1; /* Schwarz */
			w_objc_draw(&wfzooms, ob-FZBIG+FZ1BIG, 8, sx, sy, sw, sh);
			w_objc_draw(&wfzooms, ob-FZBIG+FZ1SML, 8, sx, sy, sw, sh);
		break;
		case FZOK:
			fzooms_to_menu();
		case FZABBRUCH:
			w_unsel(&wfzooms, ob);
			w_close(&wfzooms);
			w_kill(&wfzooms);
		break;
	}
}