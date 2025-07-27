/* ICFS-Beispielprogr„mmchen, Dirk Haun, 07.03.1994
 *
 * Es wird ein Fenster ge”ffnet, das mit Alt+Closer ikonifiziert werden
 * kann. Ein Klick auf das Icon-Fenster und es erscheint wieder das
 * grože Fenster. Boah, ey ...
 *
 */

#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "icfs.h"
#include "demoicon.h"
#include "demoicon.rsh"

#ifndef TRUE
# define TRUE  (1)
# define FALSE (0)
#endif

/* Prototypes */
int cdecl (*server)(int opt,...);

int open_win(int x,int y,int w,int h);
int open_iconwin(void);
void close_iconwin(int wh,int pos);
void open_work(void);
void close_work(void);
void redraw_win(int wh,GRECT *area);
void redraw_icon(int wh,GRECT *area);
int rc_intersect(GRECT *p1,GRECT *p2);
void *get_cookie(long cookie);

int main(void)
{
 int icon, exit, shift, ev, pos, wh, wx, x, y, w, h, ret=0;
 EVENT evm = { MU_BUTTON|MU_MESAG, 1,1,1, 0,0,0,0,0, 0,0,0,0,0, 0,0,
               0, 0,0,0,0,0,0, {0,0,0,0,0,0,0,0} };

 open_work();
 graf_mouse(ARROW,0L);
 server=get_cookie('ICFS');
 if(server)
 {
  rsrc_obfix(rs_object,ICONBACK);
  rsrc_obfix(rs_object,ICON);
  wind_get(0,WF_WORKXYWH,&x,&y,&w,&h);
  x+=w/4;
  y+=h/4;
  w/=2;
  h/=2;
  wh=open_win(x,y,w,h);
  if(wh>0)
  {
   icon=FALSE; exit=FALSE;
   do
   {
    ev=EvntMulti(&evm);
    if(ev&MU_MESAG)
    {
     if(evm.ev_mmgpbuf[0]==WM_REDRAW)
       if(icon) redraw_icon(evm.ev_mmgpbuf[3],(GRECT*)&evm.ev_mmgpbuf[4]);
       else redraw_win(evm.ev_mmgpbuf[3],(GRECT*)&evm.ev_mmgpbuf[4]);
     if(evm.ev_mmgpbuf[0]==WM_MOVED)
       wind_set(evm.ev_mmgpbuf[3],WF_CURRXYWH,evm.ev_mmgpbuf[4],evm.ev_mmgpbuf[5],evm.ev_mmgpbuf[6],evm.ev_mmgpbuf[7]);
     if(evm.ev_mmgpbuf[0]==WM_TOPPED) wind_set(evm.ev_mmgpbuf[3],WF_TOP);
     if(evm.ev_mmgpbuf[0]==WM_CLOSED)
     {
      shift=(int)Kbshift(-1)&0xf; /* Status von Shift-, Alt- und Control-Taste holen */
      if(shift)
      {
       if(shift&8) /* Alt+Closer */
       {
        wind_get(wh,WF_CURRXYWH,&x,&y,&w,&h);
        wind_close(wh);
        wind_delete(wh);
        wh=0;
        pos=open_iconwin();
        if(pos>0) icon=TRUE;
        else
        {
         wh=open_win(x,y,w,h);
         if(wh<=0)
         {
          form_alert(1,"[2][Da hat mit jemand|das Handle geklaut ...][ Abbruch ]");
          exit=TRUE;
         }
        }
       }
      }
      else exit=TRUE;
     }
    }
    if(icon && (ev&MU_BUTTON))
    {
     wx=wind_find(evm.ev_mmox,evm.ev_mmoy);
     if(wx>0)
     {
      close_iconwin(wx,pos);
      wh=open_win(x,y,w,h);
      if(wh<=0)
      {
       form_alert(1,"[2][Da hat mit jemand|das Handle geklaut ...][ Abbruch ]");
       exit=TRUE;
      }
      icon=FALSE;
     }
    }
   }
   while(!exit);
   if(wh>0)
   {
    wind_close(wh);
    wind_delete(wh);
   }
  }
  else ret=form_alert(1,"[2][Out of window handles ...][ Abbruch ]");
 }
 else ret=form_alert(1,"[2][ICFS-Cookie nicht gefunden!][ Abbruch ]");
 close_work();
 return(ret);
}

int open_win(int x,int y,int w,int h)
{
 int wh;

 wh=wind_create(NAME|MOVER|INFO|CLOSER,x,y,w,h);
 if(wh>0)
 {
  wind_set(wh,WF_NAME," Normales Fenster ");
  wind_set(wh,WF_INFO," Alt+Closer=Iconify / Closer ohne Shift=Ende");
  wind_open(wh,x,y,w,h);
 }
 return(wh);
}

int open_iconwin(void)
{
 int wh, pos, x, y, w, h;

 pos=(*server)(ICF_GETPOS,&x,&y,&w,&h);
 if(pos>0)
 {
  wh=wind_create(NAME|MOVER,x,y,w,h);
  if(wh>0)
  {
   wind_set(wh,WF_NAME,"IconWin");
   wind_open(wh,x,y,w,h);
  }
  else
  {
   (*server)(ICF_FREEPOS,pos);
   pos=0;
  }
 }
 return(pos);
}

void close_iconwin(int wh,int pos)
{
 wind_close(wh);
 wind_delete(wh);
 (*server)(ICF_FREEPOS,pos);
}

/*------------------------------------------------------------------------------------------------------------------------
 *  Der Rest ist hier uninteressant: Workstation ”ffnen, Redraws, Cookie suchen, etc.
 */

int vdi_handle, work_out[57], work_in[12];

void open_work(void)
{
 int i, dummy;

 appl_init();
 for(i=0;i<10;i++) work_in[i]=1;
 work_in[10]=2;
 vdi_handle=graf_handle(&dummy,&dummy,&dummy,&dummy);
 v_opnvwk(work_in,&vdi_handle,work_out);
}

void close_work(void)
{
 v_clsvwk(vdi_handle);
 appl_exit();
}

#define show_mouse()     graf_mouse(257,0L)
#define hide_mouse()     graf_mouse(256,0L)

void redraw_win(int wh,GRECT *area)
{
 GRECT box, full;
 int xy[4];

 hide_mouse();
 wind_update(BEG_UPDATE);
 wind_get(0,WF_WORKXYWH,&full.g_x,&full.g_y,&full.g_w,&full.g_h);
 vsf_color(vdi_handle,WHITE);
 vswr_mode(vdi_handle,MD_REPLACE);
 wind_get(wh,WF_FIRSTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h);
 while(box.g_w && box.g_h)
 {
  if(rc_intersect(&full,&box))
  {
   if(rc_intersect(area,&box))
   {
    xy[0]=box.g_x;
    xy[1]=box.g_y;
    xy[2]=box.g_x+box.g_w-1;
    xy[3]=box.g_y+box.g_h-1;
    v_bar(vdi_handle,xy);
   }
  }
  wind_get(wh,WF_NEXTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h);
 }
 wind_update(END_UPDATE);
 show_mouse();
}

void redraw_icon(int wh,GRECT *area)
{
 GRECT box, full;

 hide_mouse();
 wind_update(BEG_UPDATE);
 wind_get(0,WF_WORKXYWH,&full.g_x,&full.g_y,&full.g_w,&full.g_h);
 wind_get(wh,WF_WORKXYWH,&rs_object[ICONBACK].ob_x,&rs_object[ICONBACK].ob_y,&rs_object[ICONBACK].ob_width,&rs_object[ICONBACK].ob_height);
 wind_get(wh,WF_FIRSTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h);
 rs_object[ICON].ob_x=(rs_object[ICONBACK].ob_width-rs_object[ICON].ob_width)/2;
 rs_object[ICON].ob_y=(rs_object[ICONBACK].ob_height-rs_object[ICON].ob_height)/2;
 while(box.g_w && box.g_h)
 {
  if(rc_intersect(&full,&box))
  {
   if(rc_intersect(area,&box))
     objc_draw(rs_object,ROOT,MAX_DEPTH,box.g_x,box.g_y,box.g_w,box.g_h);
  }
  wind_get(wh,WF_NEXTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h);
 }
 wind_update(END_UPDATE);
 show_mouse();
}

/* ----- Cookie Jar -------------------------------------------------------- */

typedef struct {
		long	id,
			*ptr;
		} COOKJAR;

/* ------------------------------------------------------------------------- */
/* ----- get_cookie   (frei nach Oliver Scheel) ---------------------------- */
/* ------------------------------------------------------------------------- */

void *get_cookie(long cookie)
{
	long	sav;
	COOKJAR	*cookiejar;
	int	i = 0;

	sav = Super((void *)1L);
	if(sav == 0L)
		sav = Super(0L);
	cookiejar = *((COOKJAR **)0x05a0l);
	if(sav != -1L)
		Super((void *)sav);
	if(cookiejar)
	{
		while(cookiejar[i].id)
		{
			if(cookiejar[i].id == cookie)
				return(cookiejar[i].ptr);
			i++;
		}
	}
	return(0l);
}

#define min(a,b) ((a)<(b) ? (a) : (b))
#define max(a,b) ((a)>(b) ? (a) : (b))

int rc_intersect(GRECT *p1,GRECT *p2)
{
 int tx, ty, tw, th;

 tw=min(p2->g_x+p2->g_w,p1->g_x+p1->g_w);
 th=min(p2->g_y+p2->g_h,p1->g_y+p1->g_h);
 tx=max(p2->g_x,p1->g_x);
 ty=max(p2->g_y,p1->g_y);
 p2->g_x=tx;
 p2->g_y=ty;
 p2->g_w=tw-tx;
 p2->g_h=th-ty;
 return((tw>tx) && (th>ty));
}
