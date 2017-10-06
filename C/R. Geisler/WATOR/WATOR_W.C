/********************************************************************/
/*								WATOR_W.C							*/
/*						Grafik-Fenster-Handler						*/
/*																	*/
/*	R. Geisler  1988							Sprache: Megamax C	*/
/********************************************************************/


#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#define TRUE 1						/*	logische Werte				*/
#define FALSE 0


extern struct windows				/*	Variablen fÅr Fenster...	*/
{	
	int kind;
	GRECT curr;
	GRECT work;
	char *name;
	char *info;
	int handle;
	FDB fdb;
}
wi[];
extern int slot[8], xdesk, ydesk, wdesk, hdesk, gl_wbox, gl_hbox;
extern FDB scrfdb;
extern int handle, contrl[12], intin[128], ptsin[128], intout[128],
	ptsout[128], work_out[57], work_in[11];	/*	Variablen fÅr VDI	*/


wi_create(no)						/*	Fenster erzeugen			*/
int no;
{	
	if(wi[no].handle>0)				/*	existiert schon: aktivieren	*/
		wi_top(no);
	else							/*	nein: also erzeugen			*/
	{	
		wi[no].handle=wind_create(wi[no].kind, xdesk, ydesk, wdesk, 
			hdesk);
		if(wi[no].handle>0)			/*	erfolgreich					*/
		{	
			wind_set(wi[no].handle, WF_NAME, wi[no].name, 0, 0);
			if(wi[no].kind&INFO)
				wind_set(wi[no].handle, WF_INFO, wi[no].info, 0, 0);
			graf_growbox(wi[no].curr.g_x+wi[no].curr.g_w/2, 
				wi[no].curr.g_y+wi[no].curr.g_h/2, 0, 0, 
				wi[no].curr.g_x, wi[no].curr.g_y, wi[no].curr.g_w, 
				wi[no].curr.g_h);
			wind_open(wi[no].handle, wi[no].curr.g_x, wi[no].curr.g_y, 
				wi[no].curr.g_w, wi[no].curr.g_h);
			wind_get(wi[no].handle, WF_WORKXYWH, &wi[no].work.g_x, 
				&wi[no].work.g_y, &wi[no].work.g_w, &wi[no].work.g_h);
			slot[wi[no].handle]=no;	
		}
		else
			wi[no].handle=0;
	}
	return wi[no].handle;
}
		

wi_delete(no)						/*	Fenster lîschen				*/
int no;
{	
	int x, y, w, h;
	if(!wi[no].handle)
		return;
	wind_get(wi[no].handle, WF_CURRXYWH, &x, &y, &w, &h);
	graf_shrinkbox(x+w/2, y+h/2, 0, 0, x, y, w, h);
	wind_close(wi[no].handle);
	wind_delete(wi[no].handle);
	wi[no].handle=0;
}


wi_move(no, x, y, w, h)				/*	Fenster bewegen				*/
int no, x, y, w, h;
{	
	if(!wi[no].handle)
		return;
	wi[no].curr.g_x=x;
	wi[no].curr.g_y=y;
	wi[no].curr.g_w=max(w, 2*gl_wbox);		/*	Mindestgrîûe		*/
	wi[no].curr.g_h=max(h, 2*gl_hbox);
	wind_set(wi[no].handle, WF_CURRXYWH, wi[no].curr.g_x, 
		wi[no].curr.g_y, wi[no].curr.g_w, wi[no].curr.g_h);
	wind_get(wi[no].handle, WF_WORKXYWH, &wi[no].work.g_x, 
		&wi[no].work.g_y, &wi[no].work.g_w, &wi[no].work.g_h);
}


wi_full(no)							/*	Fenster maximal vergrîûern	*/
int no;								/*	 oder wieder verkleinern	*/
{	
	int x, y, w, h;
	if(wi[no].curr.g_w!=wdesk||wi[no].curr.g_h!=hdesk)
	{	
		graf_growbox(wi[no].curr.g_x, wi[no].curr.g_y, 
			wi[no].curr.g_w, wi[no].curr.g_h, xdesk, ydesk, wdesk, 
			hdesk);
		wi_move(no, xdesk, ydesk, wdesk, hdesk);
	}
	else
	{	
		wind_get(wi[no].handle, WF_PREVXYWH, &x, &y, &w, &h);
		graf_shrinkbox(x, y, w, h, xdesk, ydesk, wdesk, hdesk);
		wi_move(no, x, y, w, h);
	}
}


wi_top(no)
int no;
{	
	wind_set(wi[no].handle, WF_TOP, 0, 0, 0, 0);
}


wi_redraw(no, x, y, w, h)			/*	Fensterausschnitt zeichnen	*/
int no, x, y, w, h;
{	
	GRECT t1, t2;
	if(!wi[no].handle)
		return;
	wind_update(BEG_UPDATE);
	graf_mouse(M_OFF, 0L);
	t2.g_x=x;						/*	t2 = Åbergebenes Rechteck	*/
	t2.g_y=y;
	t2.g_w=w;
	t2.g_h=h;
	wind_get(wi[no].handle, WF_FIRSTXYWH,	/*	t1 aus Rechteckl.	*/
		&t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
	while (t1.g_w&&t1.g_h)			/*	Rechteckliste durchgehen	*/
	{	
		if(rc_intersect(&t2, &t1))	/*	öberlappung?				*/
	 		blit(no, t1.g_x, t1.g_y, t1.g_w, t1.g_h);
	 	wind_get(wi[no].handle,	WF_NEXTXYWH,
	  		&t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
	}
	graf_mouse(M_ON, 0L);
	wind_update(END_UPDATE);
}


buf_alloc(no)						/*	Puffer allozieren			*/
int no;
{	
	int *buf;
	if(buf=(int *)Malloc(32000L))
	{	
		set_mfdb(&wi[no].fdb, buf);
		return TRUE;
	}
	return FALSE;
}


buf_clear(no)						/*	Puffer lîschen				*/
int no;
{ 	
	int i;
	long *addr;
	addr=(long *)wi[no].fdb.fd_addr;
	for(i=0; i<8000; i++)
		*addr++=0;
}


buf_scrol(no, dy)					/*	Puffer scrollen				*/
int no, dy;
{	
	int xy[8];
	xy[0]=xy[4]=0;					/*	x1							*/
	xy[2]=xy[6]=work_out[0];		/*	x2							*/
	xy[1]=dy>0?0:dy;				/*	y1							*/
	xy[5]=dy>0?dy:0;
	xy[3]=work_out[1]-(dy>0?dy:0);	/*	y2							*/
	xy[7]=work_out[1]-(dy>0?0:dy);
	vro_cpyfm(handle, S_ONLY, xy, &wi[no].fdb, &wi[no].fdb);
}



buf_beg(no)							/*	Ausgabe auf Puffer			*/
int no;								/*	 umschalten					*/
{	
	graf_mouse(M_OFF, 0L);
	Setscreen(wi[no].fdb.fd_addr, -1L, -1);
}
	

buf_end()							/*	auf Bildschirm umschalten	*/
{	
	Setscreen(Physbase(), -1L, -1);
	graf_mouse(M_ON, 0L);
}


blit(no, x, y, w, h)				/*	Rechteck aus Puffer holen	*/
int no, x, y, w, h;
{	
	int xy[8];
	xy[0]=x-wi[no].work.g_x;
	xy[1]=y-wi[no].work.g_y;
	xy[2]=xy[0]+w-1;
	xy[3]=xy[1]+h-1;
	xy[4]=x;
	xy[5]=y;
	xy[6]=xy[4]+w-1;
	xy[7]=xy[5]+h-1;
	vro_cpyfm(handle, S_ONLY, xy, &wi[no].fdb, &scrfdb);
}


set_mfdb(fdp, addr)					/*	MFDB mit addr und Worksta-	*/
long addr;							/*	 tion-Parametern erzeugen	*/
FDB *fdp;
{	
	int work_eout[57];
	vq_extnd(handle, 1, work_eout);
	fdp->fd_addr=addr;
	fdp->fd_w=work_out[0];
	fdp->fd_h=work_out[1];
	fdp->fd_wdwidth=(work_out[0]+1)/16;	/*	Worte / Zeile			*/
	fdp->fd_stand=0;				/*	unter AES immer RC			*/
	fdp->fd_nplanes=work_eout[4];
}
