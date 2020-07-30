/* Window Bibliothek */
/*****************************************************************************
*
*											  7UP
*									  Modul: WINDOWS.C
*									 (c) by TheoSoft '90
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#if GEMDOS
#include <tos.h>
#else
#include <alloc.h>
#endif
#include <aes.h>
#include <vdi.h>

#include "7up.h"
#include "windows.h"
#include "undo.h"

#define NOWINDOW	 -1
#define MIN_WIDTH  128
#define MIN_HEIGHT 144
#define VERTICAL	1
#define HORIZONTAL 2
#define TRUE	 1
#define FALSE	0
#define notnull(a) ((a>0)?(a):(1))
#define HORIZ_OFFSET 5

#define SCREEN			1
#define PLOTTER		 11
#define PRINTER		 21
#define METAFILE		31
#define CAMERA		  41
#define TABLET		  51

extern int vdihandle,nodesktop,norm_point,toolbar_zeigen;
extern int work_out[57];
extern OBJECT *desktop, *winmenu;
extern WINDOW *blkwp;
extern LINESTRUCT *begcut,*endcut;

#define EXOB_TYPE(x) (x>>8)

int open_work(int device);
void close_work(int handle, int device);
WINDOW *Wfindblk(WINDOW *wp, WINDOW **blkwp, LINESTRUCT **beg, LINESTRUCT **end);
long *get_cookie(long cookie);
char *find_7upinf(char *path, char *ext, int mode);

static int x_desk,y_desk,w_desk,h_desk;

WINDOW _wind[MAXWINDOWS]=
{
	NOWINDOW,0,0,0,0,0,0,0,0,0L,0L,0,0,0,0,0,0,0L,0L,0L,0L,8,16,0,0,0L,0L,10,1,3,0L,0L,0L,0L,0L,0L,
	NOWINDOW,0,0,0,0,0,0,0,0,0L,0L,INSERT+INDENT,0,0,0,0,STRING_LENGTH,0L,0L,0L,0L,8,16,0,0,Wclear,0L,10,1,3,0L,0L,0L,0L,0L,0L,
	NOWINDOW,0,0,0,0,0,0,0,0,0L,0L,INSERT+INDENT,0,0,0,0,STRING_LENGTH,0L,0L,0L,0L,8,16,0,0,Wclear,0L,10,1,3,0L,0L,0L,0L,0L,0L,
	NOWINDOW,0,0,0,0,0,0,0,0,0L,0L,INSERT+INDENT,0,0,0,0,STRING_LENGTH,0L,0L,0L,0L,8,16,0,0,Wclear,0L,10,1,3,0L,0L,0L,0L,0L,0L,
	NOWINDOW,0,0,0,0,0,0,0,0,0L,0L,INSERT+INDENT,0,0,0,0,STRING_LENGTH,0L,0L,0L,0L,8,16,0,0,Wclear,0L,10,1,3,0L,0L,0L,0L,0L,0L,
	NOWINDOW,0,0,0,0,0,0,0,0,0L,0L,INSERT+INDENT,0,0,0,0,STRING_LENGTH,0L,0L,0L,0L,8,16,0,0,Wclear,0L,10,1,3,0L,0L,0L,0L,0L,0L,
	NOWINDOW,0,0,0,0,0,0,0,0,0L,0L,INSERT+INDENT,0,0,0,0,STRING_LENGTH,0L,0L,0L,0L,8,16,0,0,Wclear,0L,10,1,3,0L,0L,0L,0L,0L,0L,
	NOWINDOW,0,0,0,0,0,0,0,0,0L,0L,INSERT+INDENT,0,0,0,0,STRING_LENGTH,0L,0L,0L,0L,8,16,0,0,Wclear,0L,10,1,3,0L,0L,0L,0L,0L,0L
};					  /* | | */

int align(register int x, register int n)	  /* Umrechnung einer Koordinate auf die n„chste  */
{									/* durch n teilbare Stelle */
	x += (n >> 2) - 1;		/* Runden und */
	x = n * (x / n);			/* Rest entfernen */
	return(x);
}

int rc_intersect(register int p1[], register int p2[])
{
  register int tx = max(p1[0], p2[0]);
  register int ty = max(p1[1], p2[1]);
  register int tw = min(p1[0] + p1[2], p2[0] + p2[2]);
  register int th = min(p1[1] + p1[3], p2[1] + p2[3]);

  p2[0] = tx;
  p2[1] = ty;
  p2[2] = tw - tx;
  p2[3] = th - ty;

  return ((tw > tx) && (th > ty));
}

WINDOW *Wcreate(int kind, int x, int y, int w, int h)
{
	register WINDOW *wp=(WINDOW *)0L;
	register int i,handle;
	int xw,yw,ww,hw,wh,ret;
	char pathname[PATH_MAX];

	if(Wcount(CREATED)<(MAXWINDOWS-1))
	{
		_wind_get(0,WF_WORKXYWH,&x_desk,&y_desk,&w_desk,&h_desk);
		wh=wind_create(kind,x,y,w,h);
		if(wh>0 /* && wh<MAXWINDOWS */ )
		{
			handle=open_work(SCREEN);
#if MSDOS
			if(handle<3)
			{
				wind_delete(wh);
				return(NULL);
			}
#endif
			for(i=1; i<MAXWINDOWS; i++)
				if(!(_wind[i].w_state & CREATED)) /* jetzt: wh != arrayindex */
				{
					wp = &_wind[i];
					break;
				}
			wp->wihandle = wh;
			wp->vdihandle= handle;
			for(i=DESKICN1; i<=DESKICN7; i++)
				if(desktop[i].ob_flags & HIDETREE) /* Icon suchen */
				{
					wp->icon=i;
					break;
				}
			if(wp->fontid==1)
			{
#ifdef DEBUG
printf("Set Window font: Id=%2d size=%2dpt\n", wp->fontid, wp->fontsize);
#endif
				wp->fontsize = vst_point(wp->vdihandle,wp->fontsize,&ret,&ret,&wp->wscroll,&wp->hscroll);
				vqt_width(wp->vdihandle, 'W', &wp->wscroll, &ret, &ret);  /* Breite der Zeichen */
#ifdef DEBUG
printf("Got Window font: Id=%2d size=%2dpt\n", wp->fontid, wp->fontsize);
#endif
			}
			wp->kind	  = kind;
			wp->w_state |= CREATED;
			
			if(toolbar_zeigen && rsrc_load(find_7upinf(pathname,"BAR",FALSE)))
			{  /* Register fr rsrc_free() sichern */
				wp->toolbaraddress=*(long *)&_GemParBlk.global[7];
/*
				if(toolbar_senkrecht)
		      	rsrc_gaddr(R_TREE,1,&wp->toolbar);
		      else
*/
		      	rsrc_gaddr(R_TREE,0,&wp->toolbar);
		      toolbar_inst(winmenu, wp, wp->toolbar);
			}
			if( ! (wp->xwork && wp->ywork && wp->wwork, wp->hwork))
			{/* Fensterarray wurde noch nicht benutzt, erstmalige Einstellung */
			   _wind_get(0,WF_TOP,&wh,&ret,&ret,&ret);
			   if(Wp(wh))
			   {
				   _wind_get(wh,WF_WORKXYWH,&xw,&yw,&ww,&hw);
				   x=xw;
				   y=yw;
				   w=ww;
				   h=hw;
			   }
				_wind_calc(wh,WC_WORK,wp->kind,x,y,w,h,
					&wp->xwork,&wp->ywork,&wp->wwork,&wp->hwork);
   
				wp->xwork=align(wp->xwork,wp->wscroll);
				wp->wwork=align(wp->wwork,wp->wscroll);
				wp->hwork=align(wp->hwork,wp->hscroll);
				wp->xwork+=wp->wscroll; /* Fenster nicht ganz grož, wg. Cursor */
				wp->wwork-=wp->wscroll;
			}
			else /* im Fensterarray stehen schon Werte drin */
			{
				wp->xwork=align(wp->xwork,wp->wscroll);
				wp->wwork=align(wp->wwork,wp->wscroll);
				wp->hwork=align(wp->hwork,wp->hscroll);
			}
			if(wp->kind & VSLIDE)
				wind_set(wp->wihandle,WF_VSLSIZE,1000,0,0,0);
			if(wp->kind & HSLIDE)
				wind_set(wp->wihandle,WF_HSLSIZE,1000,0,0,0);
		}
	}
	return(wp);
}

int Wopen(register WINDOW *wp)
{
	WINDOW *dummy;
	int x,y,w,h,xi,yi,wi,hi;
	register int i;
	int ret;
/*
	int msgbuf[8];
*/
	if(!wp)
		return(FALSE);
	if(!(wp->w_state & CREATED))
		return(FALSE);
	if(wp->w_state & OPENED)
	{
		Wtop(wp);
		return(TRUE);
	}
/*
/* Reaktion auf AC_CLOSE */
   if(wp->wihandle == -2) /* Es kam ein AC_CLOSE, OPENED-Flag gel”scht */
   {
      wp->wihandle = wind_create(wp->kind,x_desk,y_desk,w_desk,h_desk);
      if(wp->wihandle < 0)
         return(FALSE);
   }
*/
	if((wp->kind & NAME) && wp->name)
		wind_set(wp->wihandle,WF_NAME,wp->name,0,0,0);
	if((wp->kind & INFO) && wp->info)
		wind_set(wp->wihandle,WF_INFO,wp->info,0,0,0);
	_wind_calc(wp->wihandle,WC_BORDER,wp->kind,wp->xwork,wp->ywork,wp->wwork,wp->hwork,
		&x,&y,&w,&h);
	if(y<y_desk) /* Korrektur, wenn jetzt mit Infozeile */
	{
		y=y_desk;
		h-=y_desk;
		_wind_calc(wp->wihandle,WC_WORK,wp->kind,x,y,w,h,
			&wp->xwork,&wp->ywork,&wp->wwork,&wp->hwork);
		wp->hwork=align(wp->hwork,wp->hscroll);
		_wind_calc(wp->wihandle,WC_BORDER,wp->kind,wp->xwork,wp->ywork,wp->wwork,wp->hwork,
			&x,&y,&w,&h);
	}
	iconposition(Wh(wp),&xi,&yi,&wi,&hi);
	graf_growbox(xi,yi,wi,hi,x,y,w,h);
	if(wind_open(wp->wihandle,x,y,w,h)>0)
	{
		for(i=1; i<MAXWINDOWS; i++)
			_wind[i].w_state &= ~ONTOP; /* bit zurcksetzen */
		wp->w_state |= OPENED;
		wp->w_state |= ONTOP;
		_wind_get(wp->wihandle,WF_WORKXYWH,&wp->xwork,&wp->ywork,&wp->wwork,&wp->hwork);
		Wslupdate(wp,1+2+4+8);
		
		toolbar_adjust(wp);
		
		Wfindblk(wp,&blkwp,&begcut,&endcut);
#if GEMDOS
		AVAccOpenedWindow(wp->wihandle);
#endif
		return(TRUE);
	}
	return(FALSE);
}

void Wattrchg(WINDOW *wp, int newkind)
{
	int xb,yb,wb,hb;
	if(wp && newkind!=wp->kind)
	{
		graf_mouse(M_OFF,NULL);
		Wcursor(wp);
		_wind_calc(wp->wihandle,WC_BORDER,wp->kind,wp->xwork,wp->ywork,wp->wwork,wp->hwork,&xb,&yb,&wb,&hb);
		if(wp->w_state & OPENED)
			wind_close(wp->wihandle);
		wind_delete(wp->wihandle);
		wp->wihandle=wind_create(newkind,x_desk,y_desk,w_desk,h_desk);
		wp->kind=newkind;
		_wind_calc(wp->wihandle,WC_WORK,newkind,xb,yb,wb,hb,&wp->xwork,&wp->ywork,&wp->wwork,&wp->hwork);
		wp->hwork=align(wp->hwork,wp->hscroll);
		_wind_calc(wp->wihandle,WC_BORDER,newkind,wp->xwork,wp->ywork,wp->wwork,wp->hwork,&xb,&yb,&wb,&hb);
/* neu *********************************************************************/
		if((wp->kind & NAME))
		{
			wind_set(wp->wihandle,WF_NAME,wp->name,0,0,0);
		}
		if((wp->kind & INFO))
			Wnewinfo(wp,"");
		adjust_best_position(wp);
		if(wp->row > wp->hwork/wp->hscroll-1)/* Korrektur, wenn Cursor zu tief */
		{
			if(wp->cstr->prev)
			{
				wp->cstr=wp->cstr->prev;
				wp->row--;
			}
		}
		if(wp->w_state & OPENED)
		{
			wind_open(wp->wihandle,xb,yb,wb,hb);
			_wind_get(wp->wihandle,WF_WORKXYWH,&wp->xwork,&wp->ywork,&wp->wwork,&wp->hwork);
			Wsetrcinfo(wp);
			wp->slhpos=wp->slwpos=0;
			Wslupdate(wp,1+2+4+8);
		}
		Wcursor(wp);
		graf_mouse(M_ON,NULL);
	}
}

char *Wname(WINDOW *wp)
{
#define APPNAMELEN 6 
	char *cp;
	if(wp && (wp->kind & NAME))
	{
#if GEMDOS
		if(_GemParBlk.global[1] != 1)
		{
         return( wp->name[APPNAMELEN] == '*' ? &wp->name[APPNAMELEN+2] : &wp->name[APPNAMELEN]);
		}
		else
#endif
		{
         return( *wp->name == '*' ? &wp->name[2] : wp->name);
		}
	}
	return(NULL);
}

void Wnewname(register WINDOW *wp, const char* name)
{
	char newname[PATH_MAX];

	if(wp && (wp->kind & NAME) && name)
	{
#if GEMDOS
		if(_GemParBlk.global[1] != 1) /* mehr als eine Applikation gleichzeitig */
			strcpy(newname,"[7UP] ");
		else
#endif
			newname[0]=0;
		if(wp->w_state & CHANGED)
		{
			strcat(strcat(newname,"* "),name);
		}
		else
		{
			strcat(newname,name);
		}
		if(strcmp(wp->name,newname))
		{
			wind_set(wp->wihandle,WF_NAME,strcpy(wp->name,newname),0,0,0);
		}
	}
}

void Wnewinfo(register WINDOW *wp, const char* newinfo)
{
	if(wp && (wp->kind & INFO) && strcmp(wp->info,newinfo))
		wind_set(wp->wihandle,WF_INFO,strcpy(wp->info,newinfo),0,0,0);
}

int Wnewfont(WINDOW *wp, int fontid, int fontsize)
{
	if(wp)
	{
		wp->fontid=fontid;
		vst_font(wp->vdihandle,fontid);
		return(Wfontsize(wp,fontsize));
	}
	return(FALSE);
}

int Wfontsize(register WINDOW *wp, int font)
{
	int array[4],oldw,oldh;
	int ret;
	long k;
	if(wp)
	{
		k=wp->hsize/wp->hscroll;
		oldh=wp->hscroll;
		oldw=wp->wscroll;
		wp->fontsize = vst_point(wp->vdihandle,font,&ret,&ret,&wp->wscroll,&wp->hscroll);
		vqt_width(wp->vdihandle, 'W', &wp->wscroll, &ret, &ret);  /* Breite der Zeichen */

		wp->hsize =k*wp->hscroll;
		wp->wsize=STRING_LENGTH*(long)wp->wscroll;
		wp->hfirst=wp->hfirst*wp->hscroll/oldh; /* NICHT a*=x/y; !!! */
		wp->wfirst=wp->wfirst*wp->wscroll/oldw;

		_wind_calc(wp->wihandle,WC_BORDER,wp->kind,wp->xwork,wp->ywork,wp->wwork,wp->hwork,
			&array[0],&array[1],&array[2],&array[3]);
		graf_mouse(M_OFF,0L);
		Wcursor(wp);
		Wmovesize(wp,array);
		if(wp->w_state & OPENED)
			Wredraw(wp,&wp->xwork); /* komplettes Redraw */
		Wcursor(wp);
		graf_mouse(M_ON,0L);
		return(wp->fontsize);
	}
	return(FALSE);
}
/*
static void _Wicndraw(const register WINDOW *wp, int dir, int clip[])
{
  MFDB	 s, d;
  BITBLK  *bitblk;
  WORD	 pxy [8];
  WORD	 index [2];
  extern OBJECT *userimg;
  
	if(wp)
	{
		bitblk = userimg [WICON].ob_spec.bitblk;
		
		d.mp  = NULL; /* screen */
		s.mp  = (VOID *)bitblk->bi_pdata;
		s.fwp = bitblk->bi_wb << 3;
		s.fh  = bitblk->bi_hl;
		s.fww = s.fwp/16;
		s.ff  = FALSE;
		s.np  = 1;
		
		pxy [0] = 0;
		pxy [1] = 0;
		pxy [2] = s.fwp - 1;
		pxy [3] = s.fh - 1;
		pxy [4] = wp->xwork;
		pxy [5] = wp->ywork;
		pxy [6] = wp->xwork+wp->wwork-1;
		pxy [7] = wp->ywork+wp->hwork-1;
		
		index [0] = BLACK;
		index [1] = WHITE;
		vr_recfl(wp->vdihandle,clip);				/* weižes rechteck in workspace */
		vrt_cpyfm (wp->vdihandle, MD_REPLACE, pxy, &s, &d, index);	 /* copy it */
	}
}
*/
void Wredraw(register WINDOW *wp, int *rect)
{
  int area[4],clip[4];

  if(!wp)
	  return;
#if MiNT
	wind_update(BEG_UPDATE);
#endif
	_wind_get(wp->wihandle, WF_FIRSTXYWH, &area[0], &area[1], &area[2], &area[3]);
	while( area[2] && area[3] )
	{
		if(rc_intersect(&x_desk,area))
		{
			if(rc_intersect(rect,area))
			{
				clip[0]=area[0];
				clip[1]=area[1];
				clip[2]=area[0]+area[2]-1;
				clip[3]=area[1]+area[3]-1;
				vs_clip(wp->vdihandle,TRUE,clip);
/*
		   	if(wp->w_state & ICONIFIED)
			   	_Wicndraw(wp,VERTICAL+HORIZONTAL,clip);
			   else
*/
				   wp->draw(wp,VERTICAL+HORIZONTAL,clip);
			}
		}
		_wind_get(wp->wihandle, WF_NEXTXYWH, &area[0], &area[1], &area[2], &area[3]);
	}
#if MiNT
	wind_update(END_UPDATE);
#endif
}

void Wtop(register WINDOW *wp)
{
	WINDOW *dummy;
	register int i;

	for(i=1; i<MAXWINDOWS; i++)
	{
		_wind[i].w_state &= ~ONTOP; /* bit zurcksetzen */
	}
	if(wp)
	{
		wp->w_state |= ONTOP;
		wp->cspos=wp->col; /* Cursormll vermeiden */
		wind_set(wp->wihandle,WF_TOP,0,0,0,0);
		Wfindblk(wp,&blkwp,&begcut,&endcut);

		toolbar_adjust(wp);
   }
}

void Wbottom(register WINDOW *wp) /*14.4.94*/
{
	if(wp) /* WiNX */
	{
		wind_set(wp->wihandle,25/*WF_BOTTOM*/,0,0,0,0);
   }
}

void Wfull(register WINDOW *wp)
{
	int nx,ny,nw,nh,ox,oy,ow,oh;
	register long i, oldrow;
	long oldhfirst;

	if(wp)
	{
		_wind_get(wp->wihandle,WF_CURRXYWH,&ox,&oy,&ow,&oh);
		if(wp->w_state & FULLED && wp->w_state & OPENED)
		{
			_wind_get(wp->wihandle,WF_PREVXYWH,&nx,&ny,&nw,&nh);
			graf_shrinkbox(nx,ny,nw,nh,ox,oy,ow,oh);
		}
		else
		{
			_wind_get(0,WF_WORKXYWH,&nx,&ny,&nw,&nh);
			graf_growbox(ox,oy,ow,oh,nx,ny,nw,nh);
		}
		_wind_calc(wp->wihandle,WC_WORK,wp->kind,nx,ny,nw,nh,&wp->xwork,&wp->ywork,
			&wp->wwork,&wp->hwork);

		wp->xwork=align(wp->xwork,wp->wscroll);
		wp->wwork=align(wp->wwork,wp->wscroll);
		wp->hwork=align(wp->hwork,wp->hscroll);

		_wind_calc(wp->wihandle,WC_BORDER,wp->kind,wp->xwork,wp->ywork,wp->wwork,wp->hwork,
			&nx,&ny,&nw,&nh);
		wind_set(wp->wihandle,WF_CURRXYWH,nx,ny,nw,nh);
		_wind_get(wp->wihandle,WF_WORKXYWH,&wp->xwork,&wp->ywork,&wp->wwork,&wp->hwork);
		
		toolbar_adjust(wp);
		
		if(wp->type)		/* windowtype == GRAPHIC ? */
			wp->hfirst=0;
		else
		{
			oldhfirst=wp->hfirst;
			oldrow=wp->row;
			if(wp->hsize < wp->hwork) /* wenn text < hwork */
				wp->hfirst=0;
			if(wp->hfirst + wp->hwork > wp->hsize)
				wp->hfirst=wp->hsize - wp->hwork;
			if(wp->hfirst < 0)
				wp->hfirst=0;
			if(wp->col > wp->wwork/wp->wscroll-1)
				wp->col=wp->wwork/wp->wscroll-1;
			if(wp->row > wp->hwork/wp->hscroll-1)
				wp->row=wp->hwork/wp->hscroll-1;
			if(wp->row < oldrow)
				for(i=0; i<(oldrow-wp->row); i++)
				{
					 wp->cstr=wp->cstr->prev;
				}
			if(wp->hfirst<oldhfirst)
			{
				for(i=0; i<(oldhfirst-wp->hfirst)/wp->hscroll; i++)
				{
					 wp->wstr=wp->wstr->prev;
				}
				Wredraw(wp,&wp->xwork);
			}
		}
		Wslupdate(wp,1+2+4+8);
		wp->w_state ^= FULLED;
	}
}

void Wadjust(WINDOW *wp)
{
	GRECT grect;
	int xdesk,ydesk,wdesk,hdesk;

	if(wp)
	{
		_wind_get(0,WF_WORKXYWH,&xdesk,&ydesk,&wdesk,&hdesk);
		_wind_calc(wp->wihandle,WC_WORK,wp->kind,xdesk,ydesk,wdesk,hdesk,
			&wp->xwork,&wp->ywork,&wp->wwork,&wp->hwork);
							  /* anpassen an Umbruch */
		wp->wwork=min(wp->umbruch*wp->wscroll,wp->wwork);
		wp->xwork=align(wp->xwork,wp->wscroll);
		wp->wwork=align(wp->wwork,wp->wscroll);
		wp->hwork=align(wp->hwork,wp->hscroll);
		_wind_calc(wp->wihandle,WC_BORDER,wp->kind,wp->xwork,wp->ywork,wp->wwork,wp->hwork,
			&grect.g_x,&grect.g_y,&grect.g_w,&grect.g_h);
		Wmovesize(wp,(int *)&grect);
	}
}

void Wmovesize(register WINDOW *wp, int nxywh[])
{
	int ox,oy,ow,oh;
	register long i, oldrow, oldhfirst;

	if(wp /*&& wp->w_state & OPENED*/)
	{
		if(nxywh[2]<MIN_WIDTH)
			nxywh[2]=MIN_WIDTH;
		if(nxywh[3]<MIN_HEIGHT)
			nxywh[3]=MIN_HEIGHT;
		_wind_calc(wp->wihandle,WC_WORK,wp->kind,nxywh[0],nxywh[1],nxywh[2],nxywh[3],
			&wp->xwork,&wp->ywork,&wp->wwork,&wp->hwork);

		wp->xwork=align(wp->xwork,wp->wscroll);
		wp->wwork=align(wp->wwork,wp->wscroll);
		wp->hwork=align(wp->hwork,wp->hscroll);

		toolbar_adjust(wp);

		if(!(wp->w_state & OPENED))
			return;

		_wind_calc(wp->wihandle,WC_BORDER,wp->kind,wp->xwork,wp->ywork,wp->wwork,wp->hwork,
			&nxywh[0],&nxywh[1],&nxywh[2],&nxywh[3]);

		wind_set(wp->wihandle,WF_CURRXYWH,nxywh[0],nxywh[1],nxywh[2],nxywh[3]);
		_wind_get(wp->wihandle,WF_WORKXYWH,&wp->xwork,&wp->ywork,&wp->wwork,&wp->hwork);
		
		toolbar_adjust(wp);
		
		if(wp->type)		/* windowtype == GRAPHIC ? */
			wp->hfirst=0;
		else
		{
			oldhfirst=wp->hfirst;
			oldrow=wp->row;
			if(wp->hsize < wp->hwork) /* wenn text < hwork */
				wp->hfirst=0;
			if(wp->hfirst + wp->hwork > wp->hsize)
				wp->hfirst=wp->hsize - wp->hwork;
			if(wp->hfirst < 0)
				wp->hfirst=0;
			if(wp->col > wp->wwork/wp->wscroll-1)
				wp->col=wp->wwork/wp->wscroll-1;
			if(wp->row > wp->hwork/wp->hscroll-1)
				wp->row=wp->hwork/wp->hscroll-1;
			if(wp->row < oldrow)					 /* kleiner */
				for(i=0; i<(oldrow-wp->row); i++)
				{
					 wp->cstr=wp->cstr->prev;
				}
			if(wp->hfirst<oldhfirst)
			{
				for(i=0; i<(oldhfirst-wp->hfirst)/wp->hscroll; i++)
				{
					 wp->wstr=wp->wstr->prev;
				}
				if(wp->w_state & OPENED)
					Wredraw(wp,&wp->xwork);
			}
			if(wp->row > oldrow)					 /* gr”žer */
				for(i=0; i<-(oldrow-wp->row); i++)
				{
					 wp->cstr=wp->cstr->next;
				}
			if(wp->hfirst>oldhfirst)
			{
				for(i=0; i<-(oldhfirst-wp->hfirst)/wp->hscroll; i++)
				{
					 wp->wstr=wp->wstr->next;
				}
				if(wp->w_state & OPENED)
					Wredraw(wp,&wp->xwork);
			}
		}
		Wslupdate(wp,1+2+4+8);
		wp->w_state &= ~FULLED;
	}
}

static void _Wtile(void)
{
	extern WINDOW _wind[MAXWINDOWS];

   typedef struct
   {
      GRECT rect[MAXWINDOWS];
   }TWindpos;

   TWindpos pos;
   int i,k,xd,yd,wd,hd;

   wind_get(0,WF_WORKXYWH,&xd,&yd,&wd,&hd);

   switch(Wcount(OPENED))
   {
      case 1:
         pos.rect[1].g_x = xd;
         pos.rect[1].g_y = yd;
         pos.rect[1].g_w = wd;
         pos.rect[1].g_h = hd;

         break;
      case 2:
         pos.rect[1].g_x = xd;
         pos.rect[1].g_y = yd;
         pos.rect[1].g_w = wd;
         pos.rect[1].g_h = hd/2;

         pos.rect[2].g_x = xd;
         pos.rect[2].g_y = yd+hd/2;
         pos.rect[2].g_w = wd;
         pos.rect[2].g_h = hd/2;

         break;
      case 3:
         pos.rect[1].g_x = xd;
         pos.rect[1].g_y = yd;
         pos.rect[1].g_w = wd;
         pos.rect[1].g_h = hd/3;

         pos.rect[2].g_x = xd;
         pos.rect[2].g_y = yd+hd/3;
         pos.rect[2].g_w = wd;
         pos.rect[2].g_h = hd/3;

         pos.rect[3].g_x = xd;
         pos.rect[3].g_y = yd+2*hd/3;
         pos.rect[3].g_w = wd;
         pos.rect[3].g_h = hd/3;

         break;
      case 4:
         pos.rect[1].g_x = xd;
         pos.rect[1].g_y = yd;
         pos.rect[1].g_w = wd/2;
         pos.rect[1].g_h = hd/2;

         pos.rect[2].g_x = xd;
         pos.rect[2].g_y = yd+hd/2;
         pos.rect[2].g_w = wd/2;
         pos.rect[2].g_h = hd/2;

         pos.rect[3].g_x = xd+wd/2;
         pos.rect[3].g_y = yd;
         pos.rect[3].g_w = wd/2;
         pos.rect[3].g_h = hd/2;

         pos.rect[4].g_x = xd+wd/2;
         pos.rect[4].g_y = yd+hd/2;
         pos.rect[4].g_w = wd/2;
         pos.rect[4].g_h = hd/2;

         break;
      case 5:
         pos.rect[1].g_x = xd;
         pos.rect[1].g_y = yd;
         pos.rect[1].g_w = wd/2;
         pos.rect[1].g_h = hd/2;

         pos.rect[2].g_x = xd;
         pos.rect[2].g_y = yd+hd/2;
         pos.rect[2].g_w = wd/2;
         pos.rect[2].g_h = hd/2;

         pos.rect[3].g_x = xd+wd/2;
         pos.rect[3].g_y = yd;
         pos.rect[3].g_w = wd/2;
         pos.rect[3].g_h = hd/3;

         pos.rect[4].g_x = xd+wd/2;
         pos.rect[4].g_y = yd+hd/3;
         pos.rect[4].g_w = wd/2;
         pos.rect[4].g_h = hd/3;

         pos.rect[5].g_x = xd+wd/2;
         pos.rect[5].g_y = yd+2*hd/3;
         pos.rect[5].g_w = wd/2;
         pos.rect[5].g_h = hd/3;

         break;
      case 6:
         pos.rect[1].g_x = xd;
         pos.rect[1].g_y = yd;
         pos.rect[1].g_w = wd/2;
         pos.rect[1].g_h = hd/3;

         pos.rect[2].g_x = xd;
         pos.rect[2].g_y = yd+hd/3;
         pos.rect[2].g_w = wd/2;
         pos.rect[2].g_h = hd/3;

         pos.rect[3].g_x = xd;
         pos.rect[3].g_y = yd+2*hd/3;
         pos.rect[3].g_w = wd/2;
         pos.rect[3].g_h = hd/3;

         pos.rect[4].g_x = xd+wd/2;
         pos.rect[4].g_y = yd;
         pos.rect[4].g_w = wd/2;
         pos.rect[4].g_h = hd/3;

         pos.rect[5].g_x = xd+wd/2;
         pos.rect[5].g_y = yd+hd/3;
         pos.rect[5].g_w = wd/2;
         pos.rect[5].g_h = hd/3;

         pos.rect[6].g_x = xd+wd/2;
         pos.rect[6].g_y = yd+2*hd/3;
         pos.rect[6].g_w = wd/2;
         pos.rect[6].g_h = hd/3;

         break;
      case 7:
         pos.rect[1].g_x = xd;
         pos.rect[1].g_y = yd;
         pos.rect[1].g_w = wd/2;
         pos.rect[1].g_h = hd/3;

         pos.rect[2].g_x = xd;
         pos.rect[2].g_y = yd+hd/3;
         pos.rect[2].g_w = wd/2;
         pos.rect[2].g_h = hd/3;

         pos.rect[3].g_x = xd;
         pos.rect[3].g_y = yd+2*hd/3;
         pos.rect[3].g_w = wd/2;
         pos.rect[3].g_h = hd/3;

         pos.rect[4].g_x = xd+wd/2;
         pos.rect[4].g_y = yd;
         pos.rect[4].g_w = wd/2;
         pos.rect[4].g_h = hd/4;

         pos.rect[5].g_x = xd+wd/2;
         pos.rect[5].g_y = yd+hd/4;
         pos.rect[5].g_w = wd/2;
         pos.rect[5].g_h = hd/4;

         pos.rect[6].g_x = xd+wd/2;
         pos.rect[6].g_y = yd+2*hd/4;
         pos.rect[6].g_w = wd/2;
         pos.rect[6].g_h = hd/4;

         pos.rect[7].g_x = xd+wd/2;
         pos.rect[7].g_y = yd+3*hd/4;
         pos.rect[7].g_w = wd/2;
         pos.rect[7].g_h = hd/4;

         break;
   }
   for(i=1, k=1; i<MAXWINDOWS; i++)
      if(_wind[i].w_state & CREATED && _wind[i].w_state & OPENED)
         if(pos.rect[k].g_w && pos.rect[k].g_h)
            Wmovesize(&_wind[i],&pos.rect[k++]);
}

void Warrange(int how)
{
	GRECT grect;
	int i,k,count,xstep,ystep,diff;
/*
	int msgbuf[8];
*/	
	if(how==1)
	{
		_Wtile();
		return;
	}

	count = Wcount(OPENED);
	if(count>1)
	{
		xstep = w_desk/count;
		diff=(count-1)*xstep+MIN_WIDTH - w_desk;
		if(diff>0)
			xstep-=diff/count;

		ystep = h_desk/count;
		diff=(count-1)*ystep+MIN_HEIGHT - h_desk;
		if(diff>0)
			ystep-=diff/count;

		for(i=1, k=0; i<MAXWINDOWS; i++)
			if((_wind[i].w_state & CREATED) && (_wind[i].w_state & OPENED))
			{
				switch(how)
				{
					case 1: /* untereinander */
						grect.g_x = x_desk;
						grect.g_y = k * ystep + y_desk;
						grect.g_w = w_desk;
						grect.g_h = ystep;
						break;
					case 2: /* nebeneinander */
						grect.g_x = k * xstep + x_desk;
						grect.g_y = y_desk;
						grect.g_w = xstep;
						grect.g_h = h_desk;
						break;
					case 3: /* berlappend */
						grect.g_x = k * y_desk + x_desk;
						grect.g_y = k * y_desk + y_desk;
						grect.g_w = w_desk-(count-1)*y_desk;
						grect.g_h = h_desk-(count-1)*y_desk;
						break;
				}
				Wmovesize(&_wind[i],(int *)&grect);
				Wtop(&_wind[i]);
				k++;
			}
	}
	else
		Wfull(Wgettop());
}

/*
/* 11.9.1993 */
void Wiconify(WINDOW *wp, int nxywh[])
{
	if(wp)
	{
/*
      Wmovesize(wp, nxywh);
*/
		graf_shrinkbox(nxywh[0],nxywh[1],nxywh[2],nxywh[3],
		          wp->xwork, wp->ywork,
                wp->wwork, wp->hwork);
      wind_set(wp->wihandle, 
               WF_ICONIFY,
               nxywh[0],nxywh[1],nxywh[2],nxywh[3]);
		
      _wind_get(wp->wihandle, WF_WORKXYWH,
		         &wp->xwork, &wp->ywork,
               &wp->wwork, &wp->hwork);

		graf_mouse(M_OFF,0L);
		Wcursor(wp);
		Wcuroff(wp);
		graf_mouse(M_ON,0L);
		wp->w_state |= ICONIFIED;
	}
}

void Wuniconify(WINDOW *wp, int nxywh[])
{
	if(wp)
	{
/*
      Wmovesize(wp, nxywh);
*/
		graf_growbox(wp->xwork, wp->ywork,
                   wp->wwork, wp->hwork,
                   nxywh[0],nxywh[1],nxywh[2],nxywh[3]);

      wind_set(wp->wihandle, 
               WF_UNICONIFY,
               nxywh[0],nxywh[1],nxywh[2],nxywh[3]);

      _wind_get(wp->wihandle, WF_WORKXYWH,
		         &wp->xwork, &wp->ywork,
               &wp->wwork, &wp->hwork);

		graf_mouse(M_OFF,0L);
		Wcuron(wp);
		Wcursor(wp);
		graf_mouse(M_ON,0L);
		wp->w_state &= ~ICONIFIED;
	}
}
*/
void Wcycle(register WINDOW *wp)
{
	register int i,k;

	if(wp)
	{
		for(i=1,k=1; i<MAXWINDOWS; i++,k++)
			if(_wind[i].wihandle==wp->wihandle)
				break;
		for(++i; i<MAXWINDOWS; i++)
			if(_wind[i].w_state & OPENED)
			{
				Wtop(&_wind[i]);
				return;
			}
		for(i=1; i<k; i++)
			if(_wind[i].w_state & OPENED)
			{
				Wtop(&_wind[i]);
				return;
			}
	}
}

int Wcount(int state)
{
	int i,count=0;
	for(i=1; i<MAXWINDOWS; i++)
		if(_wind[i].w_state & state)
			count++;
	return(count);
}

static void _Wscroll(register WINDOW *wp, int dir, int delta, GRECT *rect)
{
  register int x, y, w, h;
  FDB s, d;
  register int pxyarray[8];

  x = rect->g_x; /* Arbeitsbereich */
  y = rect->g_y;
  w = rect->g_w;
  h = rect->g_h;

  s.fd_addr = 0x0L;
  d.fd_addr = 0x0L;

  pxyarray [0] = x;
  pxyarray [1] = y;
  pxyarray [2] = x+w-1;
  pxyarray [3] = y+h-1;
  vs_clip(wp->vdihandle,TRUE,pxyarray);

  if (dir & VERTICAL)										 /* Vertikales Scrolling */
  {
	 if(h>abs(delta) && h>wp->hscroll)										/* Bereich kleiner delta */
	 {
		if (delta > 0)											 /* Aufw„rts Scrolling */
		{
		  pxyarray [0] = x;									 /* Werte fr vro_cpyfm */
		  pxyarray [1] = y + delta;
		  pxyarray [2] = x + w - 1;
		  pxyarray [3] = y + h - 1;
		  pxyarray [4] = x;
		  pxyarray [5] = y;
		  pxyarray [6] = pxyarray [2];
		  pxyarray [7] = pxyarray [3] - delta;

		  y = y + h - delta;			  /* Unterer Bereich nicht gescrollt,... */
		  h = delta;								  /* ...muž neu gezeichnet werden */
		}												/* Es muž mehr gezeichnet werden */
		else															/* Abw„rts Scrolling */
		{
		  pxyarray [0] = x;									 /* Werte fr vro_cpyfm */
		  pxyarray [1] = y;
		  pxyarray [2] = x + w - 1;
		  pxyarray [3] = y + h + delta - 1;
		  pxyarray [4] = x;
		  pxyarray [5] = y - delta;
		  pxyarray [6] = pxyarray [2];
		  pxyarray [7] = pxyarray [3] - delta;

		  h = -delta;							/* Oberen Bereich noch neu zeichnen */
		}
		vro_cpyfm(wp->vdihandle, 3, pxyarray, &s, &d);/* Eigentliches Scrolling */
		pxyarray[0] = x;								 /* neuzuzeichnendes Rechteck */
		pxyarray[1] = y;
		pxyarray[2] = x+w-1;
		pxyarray[3] = y+h-1;
	 }
  }
  else														  /* Horizontales Scrolling */
  {
	 if(w>abs(delta) && w>wp->wscroll)										/* Bereich kleiner delta */
	 {
		if (delta > 0)												 /* Links Scrolling */
		{
		  pxyarray [0] = x + delta;						  /* Werte fr vro_cpyfm */
		  pxyarray [1] = y;
		  pxyarray [2] = x + w - 1;
		  pxyarray [3] = y + h - 1;
		  pxyarray [4] = x;
		  pxyarray [5] = y;
		  pxyarray [6] = pxyarray [2] - delta;
		  pxyarray [7] = pxyarray [3];

		  x = x + w - delta;			  /* Rechter Bereich nicht gescrollt,... */
		  w = delta;								  /* ...muž neu gezeichnet werden */
		}												/* Es muž mehr gezeichnet werden */
		else															 /* Rechts Scrolling */
		{
		  pxyarray [0] = x;									 /* Werte fr vro_cpyfm */
		  pxyarray [1] = y;
		  pxyarray [2] = x + w + delta - 1;
		  pxyarray [3] = y + h - 1;
		  pxyarray [4] = x - delta;
		  pxyarray [5] = y;
		  pxyarray [6] = pxyarray [2] - delta;
		  pxyarray [7] = pxyarray [3];

		  w = -delta;							/* Linken Bereich noch neu zeichnen */
		}
		vro_cpyfm(wp->vdihandle, 3, pxyarray, &s, &d);/* Eigentliches Scrolling */
		pxyarray[0] = x;								 /* neuzuzeichnendes Rechteck */
		pxyarray[1] = y;
		pxyarray[2] = x+w-1;
		pxyarray[3] = y+h-1;
	 }
  }
  vs_clip(wp->vdihandle,TRUE,pxyarray);
  wp->draw(wp,dir,pxyarray);
  return;
}

void Wscroll(register WINDOW *wp, int dir, int delta, GRECT *rect)
{
	int area[4];
#if MiNT
	wind_update(BEG_UPDATE);
#endif
	_wind_get(wp->wihandle, WF_FIRSTXYWH, &area[0], &area[1], &area[2], &area[3]);
	while( area[2] && area[3] )
	{
		if(rc_intersect(&x_desk,area))
		{
			if(rc_intersect(rect,area))
			{
				_Wscroll(wp,dir,delta,area);
			}
		}
		_wind_get(wp->wihandle, WF_NEXTXYWH, &area[0], &area[1], &area[2], &area[3]);
	}
#if MiNT
	wind_update(END_UPDATE);
#endif
}

void Wslide(register WINDOW *wp, int newslide, int which)
{
	register long newpos,i,delta;
/*
	int area[4];
*/
	if(wp->kind & VSLIDE & which)
	{
		newpos=(long)newslide*(wp->hsize-wp->hwork)/1000L;
		newpos-=(newpos%wp->hscroll);
		delta=newpos-wp->hfirst;
		if(delta)
		{
			wp->hfirst=newpos;
			if(delta > 0)
			{
				for(i=0; i<delta/wp->hscroll; i++)
				{
					wp->wstr=wp->wstr->next;
					wp->cstr=wp->cstr->next;
				}
			}
			else
			{
				for(i=0; i<(-delta/wp->hscroll); i++)
				{
					wp->wstr=wp->wstr->prev;
					wp->cstr=wp->cstr->prev;
				}
			}
			if(labs(delta) >= wp->hwork)
			{
				Wredraw(wp, &wp->xwork);	 /* Bereich ganz neu zeichnen */
			}
			else
			{
				Wscroll(wp,VERTICAL,delta,&wp->xwork);
			}
		}
	}
	if(wp->kind & HSLIDE & which)
	{
		newpos=(long)newslide*(wp->wsize-wp->wwork)/1000L;
		newpos-=(newpos%wp->wscroll);
		delta=newpos-wp->wfirst;
		if(delta)
		{
			wp->wfirst=newpos;				 /*-newpos%wp->wscroll;*/
			if(labs(delta) >= wp->wwork)
			{
				Wredraw(wp, &wp->xwork);	 /* Bereich ganz neu zeichnen */
			}
			else
			{
				Wscroll(wp,HORIZONTAL,delta,&wp->xwork);
			}
		}
	}
	Wslupdate(wp,1+2+4+8);
}

int Warrow(register WINDOW *wp, int arrow)
{
	register long newpos,oldpos,i,delta=0;
/*
	int area[4];
*/
	if(arrow<=WA_DNLINE)
	{
		oldpos=newpos=wp->hfirst;
		switch(arrow)
		{
			case WA_UPPAGE /*0*/:
				if((newpos-=wp->hwork) < 0)
					newpos=0;
				break;
			case WA_DNPAGE /*1*/:
				if((newpos+=wp->hwork) > (wp->hsize-wp->hwork))
					newpos=wp->hsize-wp->hwork;
				break;
			case WA_UPLINE /*2*/:
				if(wp->hsize > wp->hwork)
				{
					if((newpos-=wp->hscroll) < 0)
						newpos=0;
					if(++wp->row > wp->hwork/wp->hscroll-1)
						wp->row=wp->hwork/wp->hscroll-1;
				}
				break;
			case WA_DNLINE /*3*/:
				if(wp->hsize > wp->hwork)
				{
					if((newpos+=wp->hscroll) > (wp->hsize-wp->hwork))
						newpos=wp->hsize-wp->hwork;
					if(--wp->row < 0)
						wp->row=0;
				}
				break;
		}
		wp->hfirst=newpos;
		delta=newpos-oldpos;
		if(delta)
		{
			if(delta > 0)
			{
				for(i=0; i<delta/wp->hscroll; i++)
				{
					wp->wstr=wp->wstr->next;
				}
			}
			else
			{
				for(i=0; i<(-delta/wp->hscroll); i++)
				{
					wp->wstr=wp->wstr->prev;
				}
			}
			wp->cstr=wp->wstr;
			for(i=0; i<wp->row; i++)
			{
				wp->cstr=wp->cstr->next;
			}
			if(labs(delta) >= wp->hwork)
			{
				Wredraw(wp, &wp->xwork);	 /* Bereich ganz neu zeichnen */
			}
			else
			{
				Wscroll(wp,VERTICAL,delta,&wp->xwork);
			}
			return((int)delta);
		}
	}
	else
	{
		oldpos=newpos=wp->wfirst;
		switch(arrow)
		{
			case WA_LFPAGE /*4*/:
				if((newpos-=wp->wwork) < 0)
					newpos=0;
				break;
			case WA_RTPAGE /*5*/:
				if((newpos+=wp->wwork) > (wp->wsize-wp->wwork))
					newpos=wp->wsize-wp->wwork;
				break;
			case WA_LFLINE /*6*/:
				if(wp->wsize > wp->wwork)
					if((newpos-=(HORIZ_OFFSET*wp->wscroll)) < 0)
						newpos=0;
					else
						wp->cspos=(wp->col+=HORIZ_OFFSET);
				break;
			case WA_RTLINE /*7*/:
				if(wp->wsize > wp->wwork)
					if((newpos+=(HORIZ_OFFSET*wp->wscroll)) > (wp->wsize-wp->wwork))
						newpos=wp->wsize-wp->wwork;
					else
						wp->cspos=(wp->col-=HORIZ_OFFSET);
				break;
		}
		wp->wfirst=newpos;
		delta=newpos-oldpos;
		if(delta)
		{
			if(labs(delta) >= wp->wwork)
			{
				Wredraw(wp, &wp->xwork);	 /* Bereich ganz neu zeichnen */
			}
			else
			{
				Wscroll(wp,HORIZONTAL,delta,&wp->xwork);
			}
			return((int)delta);
		}
	}
	return(0);
}
/*
int _Warrow(register WINDOW *wp, int mesag[])
{
   register int scrollx, scrolly, speed, linesperpage, columnsperpage;
   if(wp)
   {
      if((mesag[ 5] < 0) || (mesag[ 7] < 0))
      {
	      linesperpage=wp->hwork/wp->hscroll;
	      columnsperpage=wp->wwork/wp->wscroll;
	      scrollx = scrolly = 0;
	      speed = (mesag[ 5] < 0) ? -mesag[ 5] : 1;
	      switch (mesag[ 4]) 
	      {
	         case WA_UPLINE: scrolly = -speed; break;
	         case WA_DNLINE: scrolly = speed; break;
		      case WA_LFLINE: scrollx = -speed; break;
		      case WA_RTLINE: scrollx = speed; break;
		      case WA_UPPAGE: scrolly = -(speed * linesperpage); break;
		      case WA_DNPAGE: scrolly = (speed * linesperpage); break;
		      case WA_LFPAGE: scrollx = -(speed * columnsperpage); break;
		      case WA_RTPAGE: scrollx = (speed * columnsperpage); break;
	      }
	      if (mesag[ 7] < 0) 
	      {
	         speed = -mesag[ 7];
	         switch (mesag[ 6]) 
	         {
	            case WA_UPLINE: scrolly = scrolly - speed; break;
	            case WA_DNLINE: scrolly = scrolly + speed; break;
	            case WA_LFLINE: scrollx = scrollx - speed; break;
	            case WA_RTLINE: scrollx = scrollx + speed; break;
	            case WA_UPPAGE: scrolly = scrolly - (speed * linesperpage); break;
	            case WA_DNPAGE: scrolly = scrolly + (speed * linesperpage); break;
	            case WA_LFPAGE: scrollx = scrollx - (speed * columnsperpage); break;
	            case WA_RTPAGE: scrollx = scrollx + (speed * columnsperpage); break;
	         }
	      }
/*
	      if (scrollx != 0) 
            Wscroll(wp, HORIZONTAL, scrollx * wp->wscroll, &wp->xwork)
	      if (scrolly != 0)
            Wscroll(wp, VERTICAL, scrolly * wp->hscroll, &wp->xwork)
*/
	      if (scrollx != 0) 
            Warrow(wp, msgbuf, scrollx);
	      if (scrolly != 0)
            Warrow(wp, msgbuf, scrolly);
		}
		else
			Warrow(wp, mesag[ 4]);
   }
}
*/
void Wslupdate(register WINDOW *wp, int what)
{
	register long newpos;
	int slider,ret;

	if(wp)
	{
		if((wp->kind & HSLIDE) && (what & 4))
		{
			_wind_get(wp->wihandle,WF_HSLSIZE,&slider,&ret,&ret,&ret);
			newpos=1000L*wp->wwork/notnull(wp->wsize);
			if((slider == 1000 && newpos < slider) ||
				(slider <  1000 && newpos != slider))
				wind_set(wp->wihandle,WF_HSLSIZE,(int)min(1000,newpos),0,0,0);
		}
		if((wp->kind & VSLIDE) && (what & 8))
		{
			_wind_get(wp->wihandle,WF_VSLSIZE,&slider,&ret,&ret,&ret);
			newpos=1000L*wp->hwork/notnull(wp->hsize);
			if((slider == 1000 && newpos < slider) ||
				(slider <  1000 && newpos != slider))
				wind_set(wp->wihandle,WF_VSLSIZE,(int)min(1000,newpos),0,0,0);
		}
		if((wp->kind & HSLIDE) && (what & 1))
		{
			if((newpos=(int)((1000L*wp->wfirst)/notnull(wp->wsize-wp->wwork)))!=wp->slwpos)
				wind_set(wp->wihandle,WF_HSLIDE,wp->slwpos=newpos,0,0,0);
		}
		if((wp->kind & VSLIDE) && (what & 2))
		{
			if((newpos=(int)((1000L*wp->hfirst)/notnull(wp->hsize-wp->hwork)))!=wp->slhpos)
				wind_set(wp->wihandle,WF_VSLIDE,wp->slhpos=newpos,0,0,0);
		}
	}
}

void Wclose(register WINDOW *wp)
{
	int x,y,w,h,xi,yi,wi,hi;

	if(wp && wp->w_state & OPENED)
	{
		_wind_get(wp->wihandle,WF_CURRXYWH,&x,&y,&w,&h);
		wind_close(wp->wihandle);
		iconposition(Wh(wp),&xi,&yi,&wi,&hi);
		graf_shrinkbox(xi,yi,wi,hi,x,y,w,h);
		wp->w_state &= ~OPENED;
		wp->w_state &= ~ONTOP;
#if GEMDOS
		AVAccClosedWindow(wp->wihandle);
#endif
		if(wp=Wgettop())
		{
			Wfindblk(wp,&blkwp,&begcut,&endcut);
		}
	}
}

void Wopenall(void)
{
	register int i;

	for(i=1; i<MAXWINDOWS; i++)
		if(_wind[i].w_state & CREATED && !(_wind[i].w_state & OPENED))
			Wopen(&_wind[i]);
}

void Wcloseall(void)
{
	register int i;

	for(i=1; i<MAXWINDOWS; i++)
		if(_wind[i].w_state & OPENED)
			Wclose(&_wind[i]);
}

void Wreset(WINDOW *wp)
{
	if(wp)
	{
		wp->wihandle  = NOWINDOW;
		wp->vdihandle = 0;
		wp->icon		= 0;
		wp->kind		= 0;
		wp->w_state	&= ~CREATED;
		wp->w_state	&= ~OPENED;
		wp->w_state	&= ~FULLED;
		wp->w_state	&= ~ONTOP;
		wp->w_state	&= ~CURSOR;
		wp->w_state	&= ~CHANGED;
		wp->w_state	&= ~CURSON;
		wp->w_state	&= ~GEMFONTS;
		wp->w_state	&= ~PROPFONT;
		wp->w_state	&= ~CBLINK;
		wp->type		= 0;
		wp->hfirst/=wp->hscroll;	 /* in Zeilenzahl umwandeln */
		wp->wfirst/=wp->wscroll;
		wp->hsize	  = 0;
		wp->wsize	  = 0;
		wp->slhpos	 = 0;
		wp->slwpos	 = 0;
		wp->draw		= Wclear;
		wp->outspec	= 0L;
		wp->fstr=wp->wstr=wp->cstr=0L;
		wp->toolbar=NULL;
		wp->toolbaraddress=0L;
		wp->tabbar =NULL;
	}
}

void Wdelete(register WINDOW *wp)
{
	WORD obj;
	OBJECT *ob;

	if(wp)
	{
		if(wp->w_state & OPENED)
			Wclose(wp);
		if(wp->w_state & CREATED)
		{
			free(wp->name);
			wp->name=NULL;
			free(wp->info);
			wp->info=NULL;
			wind_delete(wp->wihandle);
			close_work(wp->vdihandle,SCREEN);
			if(wp->toolbar && wp->toolbaraddress)
			{	
				obj = 0;
			   do 
			   {
					ob = &wp->toolbar[++obj];
					if(ob->ob_type==G_USERDEF)
						free((char *)((TEDINFO *)ob->ob_spec.userblk->ub_parm)->te_ptext);
				   if(EXOB_TYPE(ob->ob_type)==0xFF)
						free(ob->ob_spec.tedinfo->te_ptext);
				} 
				while (! (ob->ob_flags & LASTOB));

				/* Register fr rsrc_free() setzen */
				*(long *)&_GemParBlk.global[7]=wp->toolbaraddress;
				rsrc_free();
			}
			Wreset(wp);
		}
	}
}

void Wnew(void) /* neu: MT 22.9.94 */
{
	register int i;
	int wh;
	WINDOW *wp;
#if GEMDOS
	if(_GemParBlk.global[0]>=0x0140)
	{
		for(i=1; i<MAXWINDOWS; i++)
			if(_wind[i].w_state & CREATED)
			{
				wp=Wp(_wind[i].wihandle);
				Wfree(wp);
				if(wp->w_state&OPENED)
					AVAccClosedWindow(wp->wihandle);
				
				if(wp->toolbar)
				{	
				  /* Register fr rsrc_free() setzen */
					*(long *)&_GemParBlk.global[7]=wp->toolbaraddress;
					rsrc_free();
				}
				if(_GemParBlk.global[1] == 1) /* Singletasking */
					wind_delete(wp->wihandle);
				close_work(wp->vdihandle,SCREEN);
				Wreset(wp);
			}
		if(_GemParBlk.global[1] != 1) /* Multitasking */
			wind_new();
	}
	else
#endif
	{
		for(i=1; i<MAXWINDOWS; i++)
			if(_wind[i].w_state & CREATED)
			{
				Wfree(Wp(_wind[i].wihandle));
				Wdelete(Wp(_wind[i].wihandle));
			}
	 }
}
/*
void Wnew(void)
{
	register int i;
	int wh;
	WINDOW *wp;
#if GEMDOS
	if(_GemParBlk.global[0]>=0x0140)
	{
		for(i=1; i<MAXWINDOWS; i++)
			if(_wind[i].w_state & CREATED)
			{
				wp=Wp(_wind[i].wihandle);
				Wfree(wp);
				if(wp->w_state&OPENED)
					AVAccClosedWindow(wp->wihandle);
				close_work(wp->vdihandle,SCREEN);
				Wreset(wp);
			}
   	if( ! (get_cookie('MiNT') && 
   	   (_GemParBlk.global[0]>=0x0400) && 
   	   (_GemParBlk.global[1] != 1)))
			wind_update(BEG_UPDATE); /* wg. wind_new() */
		wind_new();
	}
	else
#endif
	{
		for(i=1; i<MAXWINDOWS; i++)
			if(_wind[i].w_state & CREATED)
			{
				Wfree(Wp(_wind[i].wihandle));
				Wdelete(Wp(_wind[i].wihandle));
			}
	 }
}
*/
extern int additional;

int Wsetscreen(WINDOW *wp)
{
	register long i,k;
	LINESTRUCT *help;
	int x,y,w,h;
	extern int boxh;

#if MSDOS
	void far *l;
	long size;
#endif

	if(wp)
	{
		if(wp->fontid==1)					/* wenn Standardfont */
			Wnewfont(wp,1,wp->fontsize); /* letzte Fontgr”že */
		else									 /* sonst Fonts laden */
		{
			graf_mouse(BUSY_BEE,0L);
			vq_extnd(wp->vdihandle,0,work_out);
#if GEMDOS
			if(vq_gdos())
			{
				additional=vst_load_fonts(wp->vdihandle,0)+work_out[10];
				wp->w_state|=GEMFONTS;
			}
			else
				additional=work_out[10]; /* Nur 6x6 system font */
#else
			size=farcoreleft()-64*1024L;
			if(size>0 && (l=farmalloc(size))!=NULL)	 /*64*/
			{
				additional=vst_ex_load_fonts(wp->vdihandle, 0, 4096, 0)+work_out[10]; /*4096*/
				wp->w_state|=GEMFONTS;
				farfree(l);
			}
			else
				additional=work_out[10];
#endif
			graf_mouse(ARROW,0L);

			if(additional==work_out[10])	 /* Fehler, kein Fontladen m”glich */
			{
				Wnewfont(wp,1,norm_point);  /* Standartfont bei Fehler */
				wp->w_state&=~PROPFONT;
			}
			else
			{
				if(wp->fontid==vst_font(wp->vdihandle,wp->fontid)) /* falls in ASSIGN.SYS etwas ge„ndert wurde */
					Wnewfont(wp,wp->fontid,wp->fontsize); /* letzter Font und Gr”že */
				else
					Wnewfont(wp,1,norm_point);  /* Standartfont bei Fehler */
			}
		}
		_wind_calc(wp->wihandle,WC_BORDER,wp->kind,wp->xwork,wp->ywork,wp->wwork,wp->hwork,
			&x,&y,&w,&h);
																	/*MT 12.9.94 '<=' statt '<' */
		if(x<(x_desk+w_desk-1) && y<(y_desk+h_desk-1) && w<=w_desk && h<=h_desk)
		{
			help=wp->fstr;
			k=wp->hfirst;
			wp->hfirst*=wp->hscroll;		  /* erweitern auf pixelformat */
			wp->wfirst*=wp->wscroll;
			for(i=0; i<k && help; i++, help=help->next)
				;
			if(help)
			{
				wp->wstr=help;
				k=wp->row;
				for(i=0;
					 i<k && i<(wp->hwork/wp->hscroll-1) && help;
					 i++,help=help->next)
					;
				if(help)
				{
					wp->cstr=help;

					for(i;
						 i<k && wp->wstr->next && wp->cstr->next;
						 i++)
					{
						wp->wstr=wp->wstr->next;
						wp->cstr=wp->cstr->next;
						wp->hfirst+=wp->hscroll;
					}
					adjust_best_position(wp);
					wp->col=wp->cspos;
					return(TRUE);
				}
			}
		}
		_wind_calc(wp->wihandle,WC_WORK,wp->kind,x_desk,y_desk,w_desk,h_desk,
			&wp->xwork,&wp->ywork,&wp->wwork,&wp->hwork);
		wp->xwork=align(wp->xwork,wp->wscroll);
		wp->wwork=align(wp->wwork,wp->wscroll);
		wp->hwork=align(wp->hwork,wp->hscroll);
		wp->xwork+=wp->wscroll; /* Fenster nicht ganz grož, wg. Cursor */
		wp->wwork-=wp->wscroll;
		wp->cstr=wp->wstr=wp->fstr;
		wp->hfirst=wp->wfirst=0;
		wp->cspos=wp->col=wp->row=0;
	}
	return(FALSE);
}

int Wblksize(WINDOW *wp, LINESTRUCT *beg, LINESTRUCT *end, long *lines, long *chars)
{
	register LINESTRUCT *line;
	if(wp && wp->fstr)
	{
		(*lines)=(*chars)=0;
		line=beg;
		do
		{
			(*lines)++;
			(*chars)+=min(line->used,line->endcol)-line->begcol;
			line=line->next;
		}
		while(line != end->next);
		return(TRUE);
	}
	return(FALSE);
}

int Wtxtsize(WINDOW *wp, long *lines, long *chars)
{
	register LINESTRUCT *line;
	if(wp && wp->fstr)
	{
		(*lines)=(*chars)=0;
		line=wp->fstr;
		do
		{
			(*lines)++;
			(*chars)+=line->used+2;
			line=line->next;
		}
		while(line);
		(*chars)-=2;
		return(TRUE);
	}
	return(FALSE);
}

WINDOW *Wgetwp(char *filename)
{
	register int i;
	for(i=1; i<MAXWINDOWS; i++)
		if((_wind[i].w_state & CREATED) && !strcmp((char *)Wname(&_wind[i]),filename))
			return(&_wind[i]);
	return((WINDOW *)0L);
}

WINDOW *Wp(int wh)
{
	register int i;
	for(i=1; i<MAXWINDOWS; i++)
		if((_wind[i].w_state&CREATED) && (wh==_wind[i].wihandle))
			return(&_wind[i]);
	return((WINDOW *)0L);
}

int Windex(WINDOW *wp)
{
	register int i;
	if(wp)
	{
		for(i=1; i<MAXWINDOWS; i++)
			if((wp->w_state&CREATED) && (wp->wihandle==_wind[i].wihandle))
				return(i);
	}
	return(0);
}

WINDOW *Wmentry(int mentry)
{
	register int i;
	for(i=1; i<MAXWINDOWS; i++)
		if((_wind[i].w_state&CREATED) && (mentry==_wind[i].mentry))
			return(&_wind[i]);
	return((WINDOW *)0L);
}

WINDOW *Wicon(int icon)
{
	register int i;
	for(i=1; i<MAXWINDOWS; i++)
		if((_wind[i].w_state&CREATED) && (icon==_wind[i].icon))
			return(&_wind[i]);
	return((WINDOW *)0L);
}

int Wh(register WINDOW *wp)
{
	if(wp)
		return(wp->wihandle);
	else
		return(0);
}

WINDOW *Wgettop(void)
{
	WINDOW *wp=NULL;
	int wh,ret;

	_wind_get(0,WF_TOP,&wh,&ret,&ret,&ret);
	if(wp=Wp(wh))
		wp->w_state|=ONTOP;
	return(wp);
}

void Wclear(register WINDOW *wp)
{
	register int pxyarray[4];
	if(wp && wp->w_state & OPENED)
	{
		graf_mouse(M_OFF,0L);
		vswr_mode(wp->vdihandle,1);		 /* berschreiben */
		vsf_interior(wp->vdihandle,1);	 /* muster */
		vsf_color(wp->vdihandle,0);		 /* farbe weiž */
		pxyarray[0]=wp->xwork;
		pxyarray[1]=wp->ywork;
		pxyarray[2]=wp->xwork + wp->wwork - 1;
		pxyarray[3]=wp->ywork + wp->hwork - 1;
		vr_recfl(wp->vdihandle,pxyarray); /* weižes rechteck in workspace */
		graf_mouse(M_ON,0L);
	}
}

#define C_Y 2
#define C_W 2
#define C_H 4
/*
#define C_Y 3
#define C_W 1
#define C_H 6
*/
void Wcursor(register WINDOW *wp)
{
	register int pxyarray[4/*26*/],area[4],clip[4];
	register LINESTRUCT *line;

	if(!wp)
		return;
	if(!(wp->w_state & OPENED))
		return;

	wp->row=0;
	for(line = wp->wstr; line && line != wp->cstr; line = line->next)
		wp->row++;

	wp->col=wp->cspos; /* festen Cursor gew„hrleisten */
	if(!(wp->col + wp->wfirst/wp->wscroll < wp->cstr->used))
		wp->col = wp->cstr->used-wp->wfirst/wp->wscroll; /* max. an ende des strings */
	if(!(wp->w_state & CURSON))
		return;
	if(!(wp->w_state & CURSOR))
		return;
	if(wp->w_state&INSERT) /* INSERT */
	{
/*
		pxyarray[0]=max(wp->xwork,wp->xwork+wp->col*wp->wscroll - 1); /* Strichcursor */
*/
		pxyarray[0]=wp->xwork+wp->col*wp->wscroll; /* Strichcursor */
		pxyarray[1]=wp->ywork+wp->row*wp->hscroll - C_Y;
		pxyarray[2]=C_W;
		pxyarray[3]=wp->hscroll + C_H;
		wp->w_state |= CBLINK;
	}
	else		/* OVERWRITE */
	{
		pxyarray[0]=wp->xwork+wp->col*wp->wscroll; /* Blockcursor */
		pxyarray[1]=wp->ywork+wp->row*wp->hscroll;
		pxyarray[2]=wp->wscroll;
		pxyarray[3]=wp->hscroll;
		wp->w_state &= ~CBLINK;
	}
#if MiNT
	wind_update(BEG_UPDATE);
#endif
	_wind_get(wp->wihandle, WF_FIRSTXYWH, &area[0], &area[1], &area[2], &area[3]);
	while( area[2] && area[3] )
	{
		if(rc_intersect(&x_desk,area))
		{
			if(rc_intersect(&wp->xwork,area)) /*4.6.94 wg. Toolbar*/
			{
				if(rc_intersect(pxyarray,area))
				{
					clip[0]=area[0];
					clip[1]=area[1];
					clip[2]=area[0]+area[2]-1;
					clip[3]=area[1]+area[3]-1;

/* berflssig, ist doch ge-rc_intersect-et, leider nicht 18.3.95 */
					vs_clip(vdihandle,TRUE,clip);
					vr_recfl(vdihandle,clip); /* cursor ^ cursor  */
				}
			}
		}
		_wind_get(wp->wihandle, WF_NEXTXYWH, &area[0], &area[1], &area[2], &area[3]);
	}
/*
	vs_clip(vdihandle,FALSE,clip);
*/
#if MiNT
	wind_update(END_UPDATE);
#endif
}

int Wmxycursor(register WINDOW *wp,int mx,int my)
{
	register int i,newrow;
	if(wp)
	{
		if(mx >= wp->xwork &&
			mx <= (wp->xwork + wp->wwork -1) &&
			my >= wp->ywork &&
			my <= (wp->ywork + wp->hwork -1))
		{
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			wp->col=(mx-wp->xwork)/wp->wscroll;
			if(wp->w_state & INSERT)
				if(((mx-wp->xwork) % wp->wscroll) >= wp->wscroll/2)
					wp->col++;
			wp->cspos=wp->col;
			wp->row=(my-wp->ywork)/wp->hscroll;
			for(i=0,wp->cstr=wp->wstr;
				 i<wp->row && wp->cstr->next;
				 i++,wp->cstr=wp->cstr->next)
				;
			Wshiftpage(wp,0,wp->cstr->used);
			Wcuron(wp);
			Wcursor(wp);
			graf_mouse(M_ON,0L);
			return(TRUE);
		}
	}
	return(FALSE);
}

void _Wcblink(WINDOW *wp, int mx, int my)
{
	int hide=FALSE,pxyarray[8];
	if(wp && (wp->w_state & CURSOR) && (wp->w_state & CBLINK))
	{
		pxyarray[0]=mx-16;
		pxyarray[1]=my-16;
		pxyarray[2]=3*16;
		pxyarray[3]=3*16;
		pxyarray[4]=max(wp->xwork,wp->xwork+wp->col*wp->wscroll-1); /* Strichcursor */
		pxyarray[5]=wp->ywork+wp->row*wp->hscroll-2;
		pxyarray[6]=2;
		pxyarray[7]=wp->hscroll+4;
		if( rc_intersect(pxyarray,&pxyarray[4]))
		{
			hide=graf_mouse(M_OFF,0L);
		}
		if(wp->w_state & CURSON)
		{
			Wcursor(wp);
			wp->w_state &= ~CURSON;
		}
		else
		{
			wp->w_state |= CURSON;
			Wcursor(wp);
		}
		if(hide)
			graf_mouse(M_ON,0L);
	}
}

void Wcuron(register WINDOW *wp)
{
	if(wp)
	{
		wp->w_state |= CURSOR;
		wp->w_state |= CURSON;
	}
}

void Wcuroff(register WINDOW *wp)
{
	if(wp)
	{
		wp->w_state &= ~CURSOR;
		wp->w_state &= ~CURSON;
	}
}

int Wshiftpage(WINDOW *wp, int len, int used)
{
	register int abscol,pos;
	if(wp)
	{
		abscol=wp->col+wp->wfirst/wp->wscroll;
		abscol=min(abscol, used);
		abscol=max(0,abscol);
		if(((abscol-abs(len))<(int)(wp->wfirst/wp->wscroll) ||
			 (abscol+abs(len))>(int)(wp->wfirst+wp->wwork)/wp->wscroll-1))
		{
			graf_mouse(M_OFF,NULL);
			pos=abscol+len;
			pos=max(0,pos);
			pos=min(pos,STRING_LENGTH);
			Wslide(wp,(int)(1000L*pos/STRING_LENGTH),HSLIDE);
	/*
			graf_mouse(M_ON,NULL);
	*/
		}
		wp->col=abscol-(int)(wp->wfirst/wp->wscroll);
		return(wp->col);
	}
}

int inw(char c); /* IN_WORD: kein Space oder Sonderzeichen */

int Whndlkbd(register WINDOW *wp, int state, int key)
{  /* bei CAPS ist 0x1000 ausmaskiert!!! */
	register long i=0,fline,lline;
	int abscol,arrowed=FALSE;
	register LINESTRUCT *help;

	if(! wp) /* Kein Fenster */
		return(FALSE);
		
	if(! (key & 0x8000)) /* Scancodebit muž gesetzt sein */
		return(FALSE);

	switch(key)
	{
/**************************** NORMAL *************************************/
		case 0x8048:	/*  up	*/
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			if(wp->cstr->prev)
			{
				if(--wp->row < 0)/* scrollen */
					Warrow(wp,WA_UPLINE);
				else
					wp->cstr=wp->cstr->prev; /* Cursor zurck */
				wp->col=min(wp->cstr->used-wp->wfirst/wp->wscroll,wp->cspos);
			}
			Wshiftpage(wp,0,wp->cstr->used);
			undo.item=FALSE;
			arrowed=TRUE;
			Wcuron(wp);
			Wcursor(wp);
			break;
		case 0x8050:	/* down  */
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			if(wp->cstr->next)
			{
				if(++wp->row > wp->hwork/wp->hscroll-1 )/* scrollen */
					Warrow(wp,WA_DNLINE);
				else
					wp->cstr=wp->cstr->next; /* Cursor vor	 */
				wp->col=min(wp->cstr->used-wp->wfirst/wp->wscroll,wp->cspos);
			}
			Wshiftpage(wp,0,wp->cstr->used);
			undo.item=FALSE;
			arrowed=TRUE;
			Wcuron(wp);
			Wcursor(wp);
			break;
		case 0x804B:	/* left  */
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			wp->col--;
			if(wp->col < 1 && wp->wfirst > 0)
			{
			}
			else
			{
				if(wp->col < 0)
				{
					if(wp->cstr->prev)
					{
						if(--wp->row < 0)/* scrollen */
							Warrow(wp,WA_UPLINE);
						else
							wp->cstr=wp->cstr->prev; /* Cursor zurck */
						wp->col = wp->cstr->used;
					}
				}
			}
			wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
			arrowed=TRUE;
			Wcuron(wp);
			Wcursor(wp);
			break;
		case 0x804D:	/* right */
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			if(wp->col+wp->wfirst/wp->wscroll < wp->cstr->used)
			{
				wp->col++;
			}
			else /* bei Zeilenende Cursor eine Zeile weiter vom Anfang */
			{
				if(wp->cstr->next)
				{
					if(++wp->row > wp->hwork/wp->hscroll-1 )/* scrollen */
					{
						Warrow(wp,WA_DNLINE);
					}
					else
						wp->cstr=wp->cstr->next; /* Cursor vor	 */
					wp->col=-wp->wfirst/wp->wscroll;
				}
			}
			wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
			arrowed=TRUE;
			Wcuron(wp);
			Wcursor(wp);
			break;
		case 0x8047:	/* Home */
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			wp->col=-wp->wfirst/wp->wscroll;
			if(wp->hsize > wp->hwork && wp->hfirst)
			{
				wp->wfirst=wp->hfirst=0;
				wp->row=0;
				wp->cstr=wp->wstr=wp->fstr;	/* alles an den Anfang */
				Wredraw(wp,&wp->xwork);
			}
			else /* doc < window, cursor auf 0 */
			{
				wp->cstr=wp->fstr;
				wp->row=0;
			}
			wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
			undo.item=FALSE;
			arrowed=TRUE;
			Wcuron(wp);
			Wcursor(wp);
			break;
/**************************** SHIFT **************************************/
		case 0x8248:	/*  shift up	*/
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			if(wp->cstr == wp->wstr)
				Warrow(wp,WA_UPPAGE);
			else
				wp->cstr=wp->wstr;
			wp->col=min(wp->cstr->used-wp->wfirst/wp->wscroll,wp->cspos);
			Wshiftpage(wp,0,wp->cstr->used);
			undo.item=FALSE;
			arrowed=TRUE;
			Wcuron(wp);
			Wcursor(wp);
			break;
		case 0x8250:	/* shift down  */
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			if(wp->hsize > wp->hwork)
			{
				for(i=0, help=wp->wstr;	/* letzte Fensterzeile suchen */
					 i<(wp->hwork/wp->hscroll-1) && help->next;
					 i++, help=help->next)
					 ;
				if(wp->cstr == help)
					Warrow(wp,WA_DNPAGE);
				else
					wp->cstr=help;
			}
			else
			{
				while(wp->cstr->next)
					wp->cstr=wp->cstr->next;
			}
			wp->col=min(wp->cstr->used-wp->wfirst/wp->wscroll,wp->cspos);
			Wshiftpage(wp,0,wp->cstr->used);
			undo.item=FALSE;
			arrowed=TRUE;
			Wcuron(wp);
			Wcursor(wp);
			break;
		case 0x824B:	/* shift left  */
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			wp->col=-wp->wfirst/wp->wscroll;
			wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
			arrowed=TRUE;
			Wcuron(wp);
			Wcursor(wp);
			break;
		case 0x824D:	/* shift right */
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			wp->col=wp->cstr->used-wp->wfirst/wp->wscroll;
			wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
			arrowed=TRUE;
			Wcuron(wp);
			Wcursor(wp);
			break;
		case 0x8247:	/* Clr (shift Home) */
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			wp->col=-wp->wfirst/wp->wscroll;
			fline=wp->hfirst/wp->hscroll;
			if(wp->hsize > wp->hwork && wp->hfirst != wp->hsize-wp->hwork)
			{
				wp->hfirst = wp->hsize-wp->hwork;
				if(wp->hfirst < 0)
					wp->hfirst = 0;
				lline=wp->hfirst/wp->hscroll;
				if(lline > fline)
				{
					for(i=fline; i<lline; i++)
					{
						wp->wstr=wp->wstr->next;
						wp->cstr=wp->cstr->next;
					}
					Wredraw(wp,&wp->xwork);
				}
			}
			while(wp->cstr->next)
			{
				wp->cstr=wp->cstr->next;
				wp->row++;
			}
			wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
			undo.item=FALSE;
			arrowed=TRUE;
			Wcuron(wp);
			Wcursor(wp);
			break;
/**************************** CONTROL ************************************/
		case 0x8448:	 /* ctrl up */
		case 0x8450:    /* ctrl dn */
			arrowed=TRUE;
		   break;
		case 0x8473:	 /* ctrl left  */
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			abscol=wp->col+wp->wfirst/wp->wscroll;
DACAPO_B:
			if(wp->col == 0 && wp->wfirst == 0)
			{
				if(wp->cstr->prev)
				{
					if(--wp->row < 0)/* scrollen */
					{
						Warrow(wp,WA_UPLINE);
					}
					else
						wp->cstr=wp->cstr->prev; /* Cursor zurck */
					abscol = wp->col = wp->cstr->used;
				}
			}
			abscol=find_prev_letter(wp->cstr->string, abscol);
			wp->col=abscol-wp->wfirst/wp->wscroll;
			wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
			if(inw(wp->cstr->string[abscol]) && wp->cstr->prev)
				goto DACAPO_B;
			arrowed=TRUE;
			Wcuron(wp);
			Wcursor(wp);
			break;
		case 0x8474:	 /* ctrl right */
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			abscol=wp->col+wp->wfirst/wp->wscroll;
DACAPO_F:
			if(!(wp->col+wp->wfirst/wp->wscroll < wp->cstr->used))
			{
				if(wp->cstr->next)
				{
					if(++wp->row > wp->hwork/wp->hscroll-1 )/* scrollen */
					{
						Warrow(wp,WA_DNLINE);
					}
					else
						wp->cstr=wp->cstr->next; /* Cursor vor	 */
					wp->col=-wp->wfirst/wp->wscroll;
					abscol=-1;
				}
			}
			abscol=find_next_letter(wp->cstr->string, abscol);
			wp->col=abscol-wp->wfirst/wp->wscroll;
			wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
			if(inw(wp->cstr->string[abscol]) && wp->cstr->next)
				goto DACAPO_F;
			arrowed=TRUE;
			Wcuron(wp);
			Wcursor(wp);
			break;
/************************ SHIFT-CONTROL ***********************************/
		case 0x8648:	 /* shiftctrl up */
		case 0x8650:    /* shiftctrl dn */
		case 0x864B:	 /* shiftctrl left  */
		case 0x8673:
		case 0x864D:	 /* shiftctrl right */
		case 0x8674:
			arrowed=TRUE;
			break;
	}
	return(arrowed);
}
