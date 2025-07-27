/* ICFS-Demo, Dirk Haun, 06.03./18.03.1994
 *
 * Kleines, mehr oder weniger sinnvolles Demo zum Iconify-Server.
 * ôffnet wahlweise 1, 5 oder 20 "iconifizierte" Fenster Åber den
 * Server und schlieût diese wieder, wenn sie angeklickt werden.
 *
 */

#include <stdio.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "icfs.h"

int cdecl (*server)(int opt,...);
void open_work(void);
void close_work(void);
void redraw_win(int wh,GRECT *area);
void *get_cookie(long cookie);
int rc_intersect(GRECT *p1,GRECT *p2);

#define MAX_WIN 20

int x[MAX_WIN], y[MAX_WIN], nr[MAX_WIN], w[MAX_WIN];
char name[MAX_WIN][8];

void main(void)
{
 int i, wx, wy, sx, sy, max_win, anz_win, dummy, ev;
 EVENT evm = { MU_BUTTON|MU_MESAG, 1,1,1, 0,0,0,0,0, 0,0,0,0,0, 0,0,
               0, 0,0,0,0,0,0, {0,0,0,0,0,0,0,0} };

 open_work();
 server=get_cookie('ICFS');
 if(server)
 {
  i=form_alert(1,"[2][Wie viele Fenster?][1|5| 20 ]");
  if(i==1) max_win=1;
  else if(i==2) max_win=5;
  else max_win=MAX_WIN;
  for(i=0;i<max_win;i++)
  {

   nr[i]=(*server)(ICF_GETPOS,&x[i],&y[i],&sx,&sy);   /* eine Fensterkoordinate holen */

   if(nr[i]>0)
   {
    w[i]=wind_create(NAME|MOVER,x[i],y[i],sx,sy);
    if(w[i]>0)
    {
     sprintf(name[i]," #%d ",nr[i]);
     wind_set(w[i],WF_NAME,name[i]);
     wind_open(w[i],x[i],y[i],sx,sy);
    }
    else
    {
     (*server)(ICF_FREEPOS,nr[i]);   /* wieder abmelden */
     form_alert(1,"[2][Out of window handles ...][ Abbruch ]");
     break;
    }
   }
   else
   {
    form_alert(1,"[2][Der Server liefert keine|Koordinaten mehr!][ Abbruch ]");
    break;
   }
  }

  /* Jetzt die Warteschleife. Wird ein Fenster angeklickt, dann
   * wird es geschloûen und beim Server wieder abgemeldet.
   */

  anz_win=i;
  do
  {
   ev=EvntMulti(&evm);
   if(ev&MU_MESAG)
   {
    if(evm.ev_mmgpbuf[0]==WM_REDRAW) redraw_win(evm.ev_mmgpbuf[3],(GRECT*)&evm.ev_mmgpbuf[4]);
    if(evm.ev_mmgpbuf[0]==WM_MOVED)
    {
     wind_set(evm.ev_mmgpbuf[3],WF_CURRXYWH,evm.ev_mmgpbuf[4],evm.ev_mmgpbuf[5],evm.ev_mmgpbuf[6],evm.ev_mmgpbuf[7]);
     redraw_win(evm.ev_mmgpbuf[3],(GRECT*)&evm.ev_mmgpbuf[4]);
    }
    if(evm.ev_mmgpbuf[0]==WM_TOPPED) wind_set(evm.ev_mmgpbuf[3],WF_TOP);
   }
   if(ev&MU_BUTTON)
   {
    for(i=0;i<max_win;i++)
    {
     if(w[i]>0)
     {
      wind_get(w[i],WF_CURRXYWH,&wx,&wy,&dummy,&dummy);
      if(evm.ev_mmox>wx && evm.ev_mmox<wx+sx && evm.ev_mmoy>wy && evm.ev_mmoy<wy+sy)
      {
       wind_close(w[i]);               /* Fenster schlieûen */
       wind_delete(w[i]);              /* ... lîschen */
       (*server)(ICF_FREEPOS,nr[i]);   /* und abmelden */
       w[i]=0;
       anz_win--;
      }
     }
    }
   }
  }
  while(anz_win>0);
 }
 else form_alert(1,"[2][ICFS-Cookie nicht gefunden!][ Abbruch ]");
 close_work();
}

/*------------------------------------------------------------------------------------------------------------------------
 *  Der Rest ist hier uninteressant: Workstation îffnen, Redraws, Cookie suchen, etc.
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
