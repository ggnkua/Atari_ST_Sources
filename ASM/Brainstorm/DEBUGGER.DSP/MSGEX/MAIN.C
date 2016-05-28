/*

DSP Debug gem pipe communication example.
This programs shows in a graphic window the sine table built in the DSP ROM
received word by word via the gem pipe from the DSP Debugger.

Brainstorm 07/92

*/

#include	<stdio.h>
#include	<string.h>
#include	<ctype.h>

#include	<ext.h>
#include	<tos.h>
#include	<aes.h>
#include	<vdi.h>

typedef unsigned char uchar;
typedef unsigned short ushort;
typedef unsigned long ulong;
typedef unsigned float ufloat;
typedef unsigned double udouble;
typedef int bfint;
typedef unsigned int bfuint;

#define	unused(x)	((x) = (x))
#define Debugger *(char *)NULL=0

#define	AP_TERM	50
#define	SH_TERMOK	9
#define	DSPMSG_MAGIC	127

typedef	enum {
	STARTRECEIVE=0,
	ENDRECEIVE
} DSPMSG_ENUM;

typedef struct {
	char	ttl[160];		/* wind title */
	char	inf[160];		/* wind info */
	short	whandle;		/* wind AES handle */
	short	gflags;			/* wind AES flags */
	GRECT	strt;			/* start rect */
	GRECT	work;			/* curr wind work area (not inc. borders) */
	GRECT	curr;			/* curr wind work area (inc. borders) */
} WIND_STRUCT;

void	FreezeWinds(void);
void	ReleaseWinds(void);
void	FreezeMulti(void);
void	ReleaseMulti(void);
void	OnMouse(void);
void	OffMouse(void);
void	FreeMouse(void);
void	BusyMouse(void);

void	InitGrafPort(void);
void	ClipOff(GRECT *);
void	ClipOn(GRECT *);

void	XY2WH(GRECT *,short *);
void	WH2XY(short *,GRECT *);
short	RectInter(GRECT *,GRECT *,GRECT *);
void	*Rect2Mfdb(MFDB *,GRECT *);

void	GetScreenCoords(GRECT *);
void	GetCurrCoords(WIND_STRUCT *,GRECT *);
void	GetWorkCoords(WIND_STRUCT *,GRECT *);
void	GetCurrWindCoords(WIND_STRUCT *);
void	GetWorkWindCoords(WIND_STRUCT *);
void	SetCurrWindCoords(WIND_STRUCT *,GRECT *);

WIND_STRUCT	*CreateWind(WIND_STRUCT *,char *,char *);
void	DeleteWind(WIND_STRUCT *);
short	_SetTopWind(short);
void	HideWind(WIND_STRUCT *);
void	ShowWind(WIND_STRUCT *);
void	DoRectWind(WIND_STRUCT *,GRECT *,void(*fct)(WIND_STRUCT *,GRECT *));
WIND_STRUCT	*GetWindByHandle(short whandle);
short	SetTopWind(WIND_STRUCT *);
void	RedrawWind(WIND_STRUCT *,GRECT *);

short	GEMInit(void);
void	GEMExit(void);
short	DoEvents(short *);
void	AccInit(void);
void	MainLoop(void);

extern	void	Display(long);

short	MultiFlag,Apid,Vdih,Planes,ToApid=-1;
WIND_STRUCT	Wind,*CurWind=NULL;
extern	short	_app;
extern	void	*DisplayBuffer;

/* #[ Low level AES: */
void	FreezeWinds()
{
	wind_update(BEG_UPDATE);
}

void	ReleaseWinds()
{
	wind_update(END_UPDATE);
}

void	FreezeMulti()
{
	wind_update(BEG_MCTRL);
}

void	ReleaseMulti()
{
	wind_update(END_MCTRL);
}

void	GemOff()
{
	FreezeWinds();
	FreezeMulti();
}

void	GemOn()
{
	ReleaseMulti();
	ReleaseWinds();
}

void	GrafMouse(short mtype,MFORM *mform)
{
	graf_mouse(mtype,mform);
}
void	OnMouse()
{
	GrafMouse(M_ON,NULL);
}

void	OffMouse()
{
	GrafMouse(M_OFF,NULL);
}

void	FreeMouse()
{
	GrafMouse(ARROW,NULL);
}

void	BusyMouse()
{
	GrafMouse(HOURGLASS,NULL);
}

void	InitGrafPort()
{
	short	handle=Vdih;

	vswr_mode(handle,MD_REPLACE);	/* mode remplacement */
	vsl_type(handle,SOLID);	/* ligne pleine */
	vsl_width(handle,1);	/* epaisseur ligne 1 point */
	vsl_ends(handle,ROUND,ROUND);	/* debut,fin ligne arrondie */
	vsm_type(handle,1);	/* marqueur point */
	vsf_interior(handle,0);	/* motif de remplissage plein blanc */
}

void	ClipOn(GRECT *rect)
{
	short	xyarray[4];

	WH2XY(xyarray,rect);
	vs_clip(Vdih,1,xyarray);
}

void	ClipOff(GRECT *rect)
{
	short	xyarray[4];

	WH2XY(xyarray,rect);
	vs_clip(Vdih,0,xyarray);
}

/* #] Low level AES: */
/* #[ Rectangles: */
short	min(short a,short b)
{
	if (a<b)
		return a;
	return b;
}

short	max(short a,short b)
{
	if (a>b)
		return a;
	return b;
}

void	XY2WH(GRECT *rect,short *array)
{
	rect->g_x=array[0];
	rect->g_y=array[1];
	rect->g_w=array[2]-array[0]+1;
	rect->g_h=array[3]-array[1]+1;
}

void	WH2XY(short *array,GRECT *rect)
{
	array[0]=rect->g_x;
	array[1]=rect->g_y;
	array[2]=rect->g_w+array[0]-1;
	array[3]=rect->g_h+array[1]-1;
}

short	RectInter(GRECT *rs,GRECT *rd,GRECT *inter)
{
	inter->g_x=max(rd->g_x,rs->g_x);
	inter->g_y=max(rd->g_y,rs->g_y);
	inter->g_w=min(rd->g_x+rd->g_w,rs->g_x+rs->g_w);
	inter->g_h=min(rd->g_y+rd->g_h,rs->g_y+rs->g_h);
	if (((inter->g_w-=inter->g_x)>0) && ((inter->g_h-=inter->g_y)>0))
		return(1);
	return(0);
}

void	RectInset(short xoffset,short yoffset,GRECT *r)
{
	r->g_w-=xoffset;
	r->g_h-=yoffset;
}

void	RectOffset(short xoffset,short yoffset,GRECT *r)
{
	r->g_x+=xoffset;
	r->g_y+=yoffset;
}

void	RectCenter(GRECT *rs,short xoffset,short yoffset,GRECT *rd)
{
	*rd=*rs;
	RectInset(xoffset*2,yoffset*2,rd);
	RectOffset(xoffset,yoffset,rd);
}

void	*Rect2Mfdb(MFDB *mfdb,GRECT *r)
{
	short	g_w,planes;
	void	*addr;

	mfdb->fd_w=r->g_w;
	mfdb->fd_h=r->g_h;
	g_w=r->g_w/16+((r->g_w%16)?1:0);
	mfdb->fd_wdwidth=g_w;
	mfdb->fd_stand=0;
	planes=Planes;
	mfdb->fd_nplanes=planes;
	addr=malloc(g_w*r->g_h*planes);
	mfdb->fd_addr=addr;
	return(addr);
}

/* #] Rectangles: */
/* #[ Windows:*/
	/*#[ AES calls:*/
short	_SetTopWind(short handle)
{
	return(wind_set(handle,WF_TOP));
}

short	_GetTopWind()
{
	short	top_handle,dummy;

	wind_get(0,WF_TOP,&top_handle,&dummy,&dummy,&dummy);
	return(top_handle);
}

short	_GetUnderWind(short mx,short my)
{
	return(wind_find(mx,my));
}

void	GetScreenCoords(GRECT *spos)
{
	wind_get(0,WF_WORKXYWH,&(spos->g_x),&(spos->g_y),&(spos->g_w),&(spos->g_h));
}

void	GetCurrCoords(WIND_STRUCT *wind,GRECT *rect)
{
	wind_get(wind->whandle,WF_CURRXYWH,&(rect->g_x),&(rect->g_y),&(rect->g_w),&(rect->g_h));
}

void	GetWorkCoords(WIND_STRUCT *wind,GRECT *rect)
{
	wind_get(wind->whandle,WF_WORKXYWH,&(rect->g_x),&(rect->g_y),&(rect->g_w),&(rect->g_h));
}

void	GetIntCoords(WIND_STRUCT *wind,GRECT *from,GRECT *to)
{
	wind_calc(WC_WORK,wind->gflags,from->g_x,from->g_y,from->g_w,from->g_h,&(to->g_x),&(to->g_y),&(to->g_w),&(to->g_h));
}

void	GetExtCoords(WIND_STRUCT *wind,GRECT *from,GRECT *to)
{
	wind_calc(WC_BORDER,wind->gflags,from->g_x,from->g_y,from->g_w,from->g_h,&(to->g_x),&(to->g_y),&(to->g_w),&(to->g_h));
}

short	SendMsg(short *msg,long msgsize,short msgcode,short apid)
{
	char	buf[64];

	msg[0]=msgcode;
	msg[1]=apid;
	if (msgsize>16)
		msg[2]=(short)(msgsize-16);
	else
		msg[2]=0;
	if ((appl_write(apid,(short)msgsize,msg))==0) {
		sprintf(buf,"[1][Error in appl_writing %d|to application %d][OK]",msgcode,apid);
		form_alert(1,buf);
		return(0);
	}
	return(1);
}

short	SendMeMsg(short *msg,long msgsize,short msgcode)
{
	return(SendMsg(msg,msgsize,msgcode,Apid));
}

short	SendWindMsg(short *msg,long msgsize,short msgcode,WIND_STRUCT *wind)
{
	msg[3]=wind->whandle;
	return(SendMeMsg(msg,msgsize,msgcode));
}
	/*#] AES calls:*/
	/*#[ Coords:*/
void	GetCurrWindCoords(WIND_STRUCT *wind)
{
	GetCurrCoords(wind,&(wind->curr));
}

void	GetWorkWindCoords(WIND_STRUCT *wind)
{
	GetWorkCoords(wind,&(wind->work));
}

void	SetCurrWindCoords(WIND_STRUCT *wind,GRECT *rect)
{
	wind_set(wind->whandle,WF_CURRXYWH,rect->g_x,rect->g_y,rect->g_w,rect->g_h);
	GetCurrWindCoords(wind);
}
	/*#] Coords:*/
	/*#[ Show/Hide:*/
void	SetWindTtl(WIND_STRUCT *wind,char *ttl)
{
	char	*buf;

	if (wind->gflags&NAME) {
		buf=wind->ttl;
		*buf++=' ';
		strcpy(buf,ttl);
		buf+=strlen(buf);
		*buf++=' ';
		*buf++=0;
		wind_set(wind->whandle,WF_NAME,wind->ttl);
	}
}

void	SetWindInf(WIND_STRUCT *wind,char *inf)
{
	char	*buf;

	if (wind->gflags&INFO) {
		buf=wind->inf;
		*buf++=' ';
		strcpy(buf,inf);
		buf+=strlen(buf);
		*buf++=' ';
		*buf++=0;
		wind_set(wind->whandle,WF_INFO,wind->inf);
	}
}

void	ShowWind(WIND_STRUCT *wind)
{
	GRECT	*strt,open;

	strt=&(wind->strt);
	GetExtCoords(wind,strt,&open);
	OffMouse();
	wind_open(wind->whandle,strt->g_x,strt->g_y,open.g_w,open.g_h);
	OnMouse();
}

void	HideWind(WIND_STRUCT *wind)
{
	GetCurrWindCoords(wind);
	OffMouse();
	wind_close(wind->whandle);
	OnMouse();
}

	/*#] Show/Hide:*/
	/*#[ Manage:*/
WIND_STRUCT	*GetWindByHandle(short whandle)
{
	WIND_STRUCT	*wind=CurWind;

	if (wind) {
		if (wind->whandle==whandle)
			return(wind);
	}
	return(NULL);
}

WIND_STRUCT	*CreateWind(WIND_STRUCT *wind,char *ttl,char *inf)
{
	short	whandle;
	GRECT	*strt,*curr;

	wind->gflags=CLOSER|MOVER|NAME|INFO;
	strt=&(wind->strt);
	curr=&(wind->curr);
	GetExtCoords(wind,strt,curr);
	whandle=wind_create(wind->gflags,strt->g_x,strt->g_y,curr->g_w,curr->g_h);
	wind->whandle=whandle;
	if (whandle<0) {
		return(NULL);
	}
	SetWindTtl(wind,ttl);
	SetWindInf(wind,inf);
	ShowWind(wind);
	return(wind);
}

void	DeleteWind(WIND_STRUCT *wind)
{
	if (wind) {
		HideWind(wind);
		wind_delete(wind->whandle);
	}
}

short	SetTopWind(WIND_STRUCT *wind)
{
	short	err;

	if ((err=_SetTopWind(wind->whandle))!=0) {
		GetCurrWindCoords(wind);
	}
	return(err);
}

void	_GenDraw(WIND_STRUCT *wind,GRECT *inter_rect)
{
	GRECT	*work=&(wind->work);
	GRECT	org={0,0,128,128};
	MFDB	orgmfdb,screen;
	short	pxyarray[8],colors[2]={2,0};

	orgmfdb.fd_addr=&(DisplayBuffer);
	orgmfdb.fd_w=128;
	orgmfdb.fd_h=128;
	orgmfdb.fd_wdwidth=8;
	orgmfdb.fd_stand=0;
	orgmfdb.fd_nplanes=1;
	screen.fd_addr=NULL;
	WH2XY(pxyarray,&org);
	WH2XY(&(pxyarray[4]),work);
	ClipOn(inter_rect);
	OffMouse();
	vrt_cpyfm(Vdih,MD_REPLACE,pxyarray,&orgmfdb,&screen,colors);
	OnMouse();
	ClipOff(inter_rect);
}

void	DoRectWind(WIND_STRUCT *wind,GRECT *redraw_rect,void(*fct)(WIND_STRUCT *,GRECT *))
{
	short	whandle;
	GRECT	wpos,inter_rect;

	FreezeWinds();
	whandle=wind->whandle;
	GetWorkWindCoords(wind);
	InitGrafPort();
	wind_get(whandle,WF_FIRSTXYWH,&(wpos.g_x),&(wpos.g_y),&(wpos.g_w),&(wpos.g_h));
	while ((wpos.g_w!=0) || (wpos.g_h!=0)) {
		if (RectInter(redraw_rect,&wpos,&inter_rect)) {
			fct(wind,&inter_rect);
		}
		wind_get(whandle,WF_NEXTXYWH,&wpos.g_x,&wpos.g_y,&wpos.g_w,&wpos.g_h);
	}
	ReleaseWinds();
}

void	RedrawWind(WIND_STRUCT *wind,GRECT *redraw_rect)
{
	DoRectWind(wind,redraw_rect,_GenDraw);
}

void	ManageWinds(short *msg)
{
	short	whandle;
	WIND_STRUCT	*wind;
	GRECT	*ncoords=(GRECT *)&msg[4];

	whandle=msg[3];
	wind=GetWindByHandle(whandle);
	if (wind==NULL)
		return;
	switch (msg[0]) {
		case WM_CLOSED:
		break;
		case WM_TOPPED:
			SetTopWind(wind);
		break;
		case WM_REDRAW:
			RedrawWind(wind,ncoords);
		break;
		case WM_MOVED:
			SetCurrWindCoords(wind,ncoords);
		break;
	}
}

short	DoEvents(short *msg)
{
	short	event,bstate=1,key,mx,my,mbutton,mstate,mclicks;
	long	dspword;

	event=evnt_multi(MU_MESAG,
			2,1,bstate,
			0,0,0,0,0,
			0,0,0,0,0,
			msg,
			1,0,
			&mx,&my,
			&mbutton,&mstate,
			(short *)&key,&mclicks);
	if (event&MU_MESAG) {
		switch (msg[0]) {
			case DSPMSG_MAGIC:	/* DSP word in msg[3]<<16|msg[4] */
				if (ToApid!=-1) {
					dspword=((long)(msg[3])<<16)+msg[4];
					Display(dspword);	/* put in buffer */
					if (CurWind)		/* redraw display window */
						RedrawWind(CurWind,&(CurWind->work));
				}
			break;
			case AP_TERM:
				msg[0]=AC_CLOSE;
			break;
			default:
				ManageWinds(msg);
			break;
		}
	}
	return(event&MU_MESAG);
}
	/*#] Manage:*/
/* #] Windows:*/
short	GEMInit()
{
	short	dum;
	short	win[11]={0,1,1,1,1,1,1,1,1,1,2};
	short	wout[57];

	if ((Apid=appl_init())>=0) {
		win[0]=Getrez()+2;
		if (_GemParBlk.global[1]==-1) {	/* AES 4.0 */
			MultiFlag=1;
			win[0]=_GemParBlk.global[13];
			shel_write(SH_TERMOK,1,0,NULL,NULL);
		}
		if (_app==0) {
			if (menu_register(Apid,"  DSPDisplay ")==-1) {
				appl_exit();
				return(-1);
			}
		}
		Vdih=graf_handle(&dum,&dum,&dum,&dum);
		v_opnvwk(win,&Vdih,wout);
		vq_extnd(Vdih,1,wout);
		Planes=wout[4];
	}
	else {
		Cconws("Appl_init error - Press a key\r\n");
		Bconin(2);
	}
	return(Apid);
}

void	GEMExit()
{
	v_clsvwk(Vdih);
	appl_exit();
}

void	AccInit()
{
	short	msg[8];
	GRECT	*strt=&(Wind.strt);

	if ((ToApid==-1) && (ToApid=appl_find("DSPDEBUG"))!=-1) {
		msg[3]=STARTRECEIVE;	/* Init DSP receive catch */
		msg[4]=Apid;		/* send to Appl Id */
		SendMsg(msg,sizeof(msg),DSPMSG_MAGIC,ToApid);	/* appl write it */
	}
	if (CurWind==NULL) {
		GetScreenCoords(strt);
		strt->g_w=128;
		strt->g_h=128;
		CurWind=CreateWind(&Wind,"DSP","Sine table");
		Display(0L);			/* Init X coords line */
	}
	else
		SetTopWind(CurWind);
}

void	MainLoop()
{
	short	evnt,msg[8];

	if (_app)	/* If program, init as accessory */
		AccInit();
	while (1) {
		evnt=DoEvents(msg);
		if (evnt) {
			switch (msg[0]) {
				case AC_OPEN:
					AccInit();	/* if acc, open */
				break;
				case WM_CLOSED:
				case AC_CLOSE:
					DeleteWind(CurWind);
					CurWind=NULL;
					if (ToApid!=-1) {
						msg[3]=ENDRECEIVE;	/* Exit DSP receive catch */
						SendMsg(msg,sizeof(msg),DSPMSG_MAGIC,ToApid);
						ToApid=-1;
					}
					if (_app)	/* If program, exit */
						return;	/* else loop */
			}
		}
	}
}

main()
{
	if (GEMInit()>=0) {
		FreeMouse();
		MainLoop();
		GEMExit();
	}
	return(0);
}

