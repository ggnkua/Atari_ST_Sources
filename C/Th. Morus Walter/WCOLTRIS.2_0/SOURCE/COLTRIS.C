#include <gem.h>
#include <vdi.h>
#include <tos.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <linea.h>

#include <vaproto.h>
int ap_id,av_id=-1;
int av_state;

#include "cltr.h"

#include "coltris.rsh"

#define min(a,b)	(a)<(b)?(a):(b)
#define max(a,b)	(a)>(b)?(a):(b)

OBJECT *menue,*options,*info,*user_keys;
OBJECT *score,*stat;
OBJECT *hi_name,*hiscore;
POSITION *pos;
int handle;

typedef struct {
	int entry;
	int key;
	int state;
} KEY_COMMAND;

KEY_COMMAND commands[]={
M_START		,0x13,	K_CTRL,	/* r */
M_START		,0x13,	0,		/* r */
M_START		,0x1c,	0,		/* return */
M_START		,0x72,	0,		/* enter */
M_HISCORE	,0x23,	K_CTRL,	/* h */
M_HISCORE	,0x23,	0,		/* h */
M_SAVE		,0x1f,	K_CTRL,	/* s */
M_QUIT		,0x10,	K_CTRL,	/* q */
M_TETRIS 	,0x14,	K_CTRL,	/* t */
M_TETRIS 	,0x14,	0,		/* t */
M_COLUMNS	,0x2e,	K_CTRL,	/* c */
M_COLUMNS	,0x2e,	0,		/* c */
M_SCORE		,0x17,	K_CTRL,	/* i */
M_SCORE		,0x17,	0,		/* i */
M_PREVIEW	,0x31,	K_CTRL,	/* n */
M_PREVIEW	,0x31,	0,		/* n */
M_STATISTIC	,0x30,	K_CTRL,	/* b */
M_STATISTIC	,0x30,	0,		/* b */
M_OPTS		,0x18,	K_CTRL,	/* o */
M_OPTS		,0x18,	0,		/* o */
};

char set_file[128]="COLTRIS.SET";

OPTS opts={
	PM_TETRIS,{0},1,0,0,1,0,0,0,0,
	{"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0},
	{"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0},
	{7,0,1,0,0},{7,0,1,0,0},
};
POSITION *pos;

static uint last_score;

int columns_vdi,tetris_vdi;		/* -1 -> disabled */
								/*  0 -> qcopy mîglich */
								/*  1 -> vdi only */

int score_flag,preview_flag,stat_flag;
int end_flag=0;

long screen_addr;
long buffer_addr;
long buffer_size;
int buffer_width,buffer_height;		/* width in byte */
int screen_width;					/* in byte */
int screen_w,screen_h,planes;
int quick_flag;						/* copy in screen mit ass-routine erlaubt */
static int x_off,y_off,width;

MFDB screen,buffer;

void redraw_play(int *message);
void close_window(void);
void set_score(void);
void redraw_score(int *message);
void set_preview(void);
void redraw_preview(int *message);
void set_statistic(void);
void redraw_statistic(int *message);

#define WIND_ANZ	4
typedef enum {
	W_PLAY,
	W_SCORE,
	W_PREVIEW,
	W_STATISTIC,
} WINDOWS;
typedef struct {
	int handle;
	void (*redraw)(int *message);
	void (*close)(void);
} WINDOW;
WINDOW wind[WIND_ANZ]={-1,redraw_play,close_window,
					   -1,redraw_score,set_score,
					   -1,redraw_preview,set_preview,
					   -1,redraw_statistic,set_statistic};


/*
	zufallsgenerator nach knuth
*/
#define MBIG	1000000000l
#define MSEED	161803398l
#define FAC	1e-9

long xrandom(void)
{
/*	return Random();*/
static int first=0;
static long ma[55],inext,inextp;
long mj,mk;
int i,ii,k;

	if ( !first ) {
		first=1;
		mj=MSEED-Random();		/* -> bios zufallszahl fÅr init */
		mj=labs(mj%MBIG);

		ma[54]=mj;
		mk=1;
		for ( i=0; i<54; i++ ) {
			ii=(21*i+21)%55-1;
			ma[ii]=mk;
			mk=mj-mk;
			if ( mk<0 )
				mk+=MBIG;
			mj=ma[ii];
		}
		for ( k=0; k<4; k++ ) {
			for ( i=0; i<55; i++ ) {
				ma[i]=ma[i]-ma[(i+31)%55];
				if ( ma[i]<0 )
					ma[i]+=MBIG;
			}
		}
		inext=-1;
		inextp=30;
	}

	inext++;
	if ( inext==55 )
		inext=0;
	inextp++;
	if ( inextp==55 )
		inextp=0;
	mj=ma[inext]-ma[inextp];
	if ( mj<0 )
		mj+=MBIG;
	ma[inext]=mj;
	return mj;
}

long gettime()
{
long stack;
long time;

	stack=Super(0L);
	time=*(long*)0x4BA;
	Super((void*)stack);
	return(time);
}

static long time;
void init_wait(void)
{
	time=gettime();
}
void do_wait(int ms)
{
	while ( gettime()<time+ms )
		;
}

uint calc_delay(uint level)
{
	return 55-level*5;
}

KEY get_key(void)
{
int key;
EVENT evnt;

	evnt.ev_mflags=MU_KEYBD|MU_TIMER;
	evnt.ev_mtlocount=1;
	evnt.ev_mthicount=0;
	if ( EvntMulti(&evnt)==MU_TIMER )
		return NO_KEY;
	key=*(char*)&evnt.ev_mkreturn;

		/* user-keys first */
	if ( key==opts.left )
		return K_LEFT;
	if ( key==opts.right )
		return K_RIGHT;
	if ( key==opts.rotate )
		return K_ROTATE;
	if ( key==opts.drop )
		return K_DROP;

	if ( key==0x67 )				/* 7z */
		return K_LEFT;
	if ( key==0x69 )				/* 9z */
		return K_RIGHT;
	if ( key==0x68 )				/* 8z */
		return K_ROTATE;
	if ( key==0x39 || key==0x6A )	/* space, 4z */
		return K_DROP;
	if ( key==0x01 || key==0x10 )	/* esc, q */
		return K_QUIT;
	if ( key==0x17 )				/* i */
		return K_INFO;
	if ( key==0x31 )				/* n */
		return K_NEXT;
	if ( key==0x30 )				/* b */
		return K_STAT;
	if ( key==0x1F )				/* s */
		return K_STOP;
	if ( key==0x66 || key==0x26 )	/* *z l */
		return K_LEVEL;

	return NO_KEY;
}

void clr_keys(void)
{
EVENT evnt;

	evnt.ev_mflags=MU_KEYBD|MU_TIMER;
	evnt.ev_mtlocount=1;
	evnt.ev_mthicount=0;
	while ( EvntMulti(&evnt)&MU_KEYBD )
		;
}

int xget_key(void)
{
int key;
	key=evnt_keybd();
	return *(char*)&key;
}

void clr_feld(void)
{
	memset((char*)buffer_addr,0,buffer_size);
	redraw_play(0l);
	last_score=0;
}

void inv_feld(void)
{
int *d;
long i;

	init_wait();
	for ( i=0,d=(int*)buffer_addr; i<buffer_size/2; i++ )
		*d++^=-1;
	redraw_play(0l);
	do_wait(50);
	for ( i=0,d=(int*)buffer_addr; i<buffer_size/2; i++ )
		*d++^=-1;
	redraw_play(0l);
}

/*------------------------------------------------------------------------------

	quick-copy: schnelle kopierroutinen (nur standard ST-high artige auflîsungen)

------------------------------------------------------------------------------*/
	/* variable fÅr ass-routinen */

void copy_tet(char *dest,char *source,int lines);
void copy_col(char *dest,char *source,int lines);
void (*qcopy)(char *dest,char *source,int lines);
int copy_max,copy_min;
Copy_Out copy_out;

static void qcopy_out(void)
{
char *source,*dest;

	if ( copy_min<copy_max ) {
		source=(char*)buffer_addr+(long)copy_min*buffer_width;
		dest=(char*)screen_addr+(long)(copy_min+y_off)*screen_width+x_off/8;
		qcopy(dest,source,copy_max-copy_min);
		copy_min=buffer_height;
		copy_max=0;
	}
}

static void vcopy_out(void)
{
int xy[8];

	if ( copy_min<copy_max ) {
		xy[0]=0;
		xy[1]=copy_min;
		xy[2]=width-1;
		xy[3]=copy_max;
		xy[4]=x_off;
		xy[5]=y_off+copy_min;
		xy[6]=x_off+width-1;
		xy[7]=y_off+copy_max;
		vro_cpyfm(handle,S_ONLY,xy,&buffer,&screen);
		copy_min=buffer_height;
		copy_max=0;
	}
}

static void mcopy_out(void)
{
int xy[8];
void do_ctrl(int flag);

	if ( copy_min<copy_max ) {
		xy[3]=wind[W_PLAY].handle;
		xy[4]=x_off;
		xy[5]=y_off+copy_min;
		xy[6]=x_off+width-1;
		xy[7]=y_off+copy_max;
		redraw_play(xy);
		copy_min=buffer_height;
		copy_max=0;
	}
	do_ctrl(1);
}

void init_quickcopy(void)
{
	linea_init();
	screen_addr=(long)Logbase();
	screen_width=Linea->v_lin_wr;
}

static void init_copy_out(void)
{
	if ( !opts.graph && !((opts.play_mode==PM_TETRIS && tetris_vdi) || (opts.play_mode==PM_COLUMNS && columns_vdi)) ) {
		quick_flag=1;
		if ( !screen_addr )
			init_quickcopy();
		if ( opts.play_mode==PM_TETRIS )
			qcopy=copy_tet;
		else
			qcopy=copy_col;
	}
	else {
		quick_flag=0;
	}

	if ( opts.multi )
		copy_out=mcopy_out;
	else if ( quick_flag )
		copy_out=qcopy_out;
	else
		copy_out=vcopy_out;

	copy_min=buffer_height;
	copy_max=0;
}

/*------------------------------------------------------------------------------

	hiscore

------------------------------------------------------------------------------*/
void do_score(uint score,HI_SCORE *hi)
{
int i,j;
int x,y,w,h;

	last_score=score;

	for ( i=0; i<10; i++ ) {
		if ( score>hi[i].score ) {
			wind_update(BEG_UPDATE);
			form_center(hi_name,&x,&y,&w,&h);
			form_dial(FMD_START,x,y,w,h,x,y,w,h);
			objc_draw(hi_name,0,10,x,y,w,h);
			form_do(hi_name,HI_NAME);
			form_dial(FMD_FINISH,x,y,w,h,x,y,w,h);
			wind_update(END_UPDATE);

			objc_unselect(hi_name,HI_NAME);
			for ( j=9; j>i; j-- )
				hi[j]=hi[j-1];
			strcpy(hi[i].name,objc_tedstr(hi_name,HI_NAME));
			hi[i].score=score;
			hi[i].date=Tgetdate();
			return;
		}
	}
}

void show_hiscore(void)
{
HI_SCORE *hi;
int i,ret,x,y,w,h;
uint date;

	if ( opts.play_mode==PM_TETRIS ) {
		hi=opts.tet_hi;
		objc_spec(hiscore,HI_TITEL)="Tetris Hiscore";
	}
	else {
		hi=opts.col_hi;
		objc_spec(hiscore,HI_TITEL)="Columns Hiscore";
	}

	objc_hide(hiscore,HI_MARKE);
	for ( i=0; i<10; i++ ) {
		if ( hi[i].score!=0 ) {
			strcpy(objc_spec(hiscore,HISCORE1+i+i+i),hi[i].name);
			date=hi[i].date;
			sprintf(objc_spec(hiscore,HISCORE1+1+i+i+i),"%2d.%2d.%4d",date&31,(date>>5)&15,(date>>9)+1980);
			sprintf(objc_spec(hiscore,HISCORE1+2+i+i+i),"%5d",hi[i].score);
			if ( hi[i].score==last_score ) {
				objc_unhide(hiscore,HI_MARKE);
				hiscore[HI_MARKE].ob_y=hiscore[HISCORE1+i+i+i].ob_y;
			}
		}
		else {
			*objc_spec(hiscore,HISCORE1+i+i+i)=0;
			*objc_spec(hiscore,HISCORE1+1+i+i+i)=0;
			*objc_spec(hiscore,HISCORE1+2+i+i+i)=0;
		}

	}

	form_center(hiscore,&x,&y,&w,&h);
	wind_update(BEG_UPDATE);
	form_dial(FMD_START,x,y,w,h,x,y,w,h);
	objc_draw(hiscore,0,10,x,y,w,h);
	ret=form_do(hiscore,0)&0x7FFF;
	objc_unselect(hiscore,ret);
	form_dial(FMD_FINISH,x,y,w,h,x,y,w,h);
	wind_update(END_UPDATE);
	if ( ret==CLR_HI ) {
		for ( i=0; i<10; i++ ) {
			strcpy(hi[i].name,"");
			hi[i].score=0;
			hi[i].date=0;
		}
	}
}

/*------------------------------------------------------------------------------

	schreibe optionen in / lese optionen aus  dialogbox

------------------------------------------------------------------------------*/
void set_opts(void)
{
GAME_OPTS *go;
int i;

	if ( opts.play_mode==PM_COLUMNS ) {
		objc_select(options,O_COLUMNS);
		objc_unselect(options,O_TETRIS);
		go=&opts.columns;
	}
	else {
		objc_select(options,O_TETRIS);
		objc_unselect(options,O_COLUMNS);
		go=&opts.tetris;
	}
	for ( i=LEVEL0; i<=LEVEL9; i++ ) {
		objc_unselect(options,i);
	}
	if ( go->start_level<9 )
		objc_select(options,LEVEL0+go->start_level);

	for ( i=RANDOM0; i<=RANDOM14; i++ ) {
		objc_unselect(options,i);
	}
	if ( go->random<14 )
		objc_select(options,RANDOM0+go->random);

	objc_unselect(options,GRAPH_ST);
	objc_unselect(options,GRAPH_VDI);
	if ( opts.graph )
		objc_select(options,GRAPH_VDI);
	else
		objc_select(options,GRAPH_ST);

	objc_unselect(options,SINGLE);
	objc_unselect(options,MULTI);
	if ( opts.multi )
		objc_select(options,MULTI);
	else
		objc_select(options,SINGLE);

	objc_unselect(options,CYCLENONE);
	objc_unselect(options,CYCLEPLAY);
	objc_unselect(options,CYCLEALL);
	if ( opts.cycle==0 )
		objc_select(options,CYCLENONE);
	else if ( opts.cycle==1 )
		objc_select(options,CYCLEPLAY);
	else
		objc_select(options,CYCLEALL);

	if ( opts.top )
		objc_select(options,TOP_ALL);
	else
		objc_unselect(options,TOP_ALL);
}

void get_opts(void)
{
GAME_OPTS *go;
int i;

	if ( opts.play_mode==PM_COLUMNS )
		go=&opts.columns;
	else
		go=&opts.tetris;

	for ( i=LEVEL0; i<=LEVEL9; i++ ) {
		if ( objc_selected(options,i) )
			{ go->start_level=i-LEVEL0; break; }
	}

	for ( i=RANDOM0; i<=RANDOM14; i++ ) {
		if ( objc_selected(options,i) )
			{ go->random=i-RANDOM0; break; }
	}

	if ( objc_selected(options,GRAPH_VDI) )
		opts.graph=1;
	else
		opts.graph=0;

	if ( objc_selected(options,MULTI) )
		opts.multi=1;
	else
		opts.multi=0;

	if ( objc_selected(options,CYCLENONE) )
		opts.cycle=0;
	else if ( objc_selected(options,CYCLEPLAY) )
		opts.cycle=1;
	else 
		opts.cycle=2;

	if ( objc_selected(options,TOP_ALL) )
		opts.top=1;
	else
		opts.top=0;
}

void get_user_keys(void)
{
int x,y,w,h;

	wind_update(BEG_MCTRL);
	wind_update(BEG_UPDATE);

	strcpy(objc_spec(user_keys,KEYS_TXT),"Left");
	form_center(user_keys,&x,&y,&w,&h);
	objc_draw(user_keys,0,10,x,y,w,h);
	opts.left=xget_key();

	strcpy(objc_spec(user_keys,KEYS_TXT),"Right");
	form_center(user_keys,&x,&y,&w,&h);
	objc_draw(user_keys,0,10,x,y,w,h);
	opts.right=xget_key();

	strcpy(objc_spec(user_keys,KEYS_TXT),"Rotate");
	form_center(user_keys,&x,&y,&w,&h);
	objc_draw(user_keys,0,10,x,y,w,h);
	opts.rotate=xget_key();

	strcpy(objc_spec(user_keys,KEYS_TXT),"Drop");
	form_center(user_keys,&x,&y,&w,&h);
	objc_draw(user_keys,0,10,x,y,w,h);
	opts.drop=xget_key();

	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}

void do_options(void)
{
int x,y,w,h,r;

	wind_update(BEG_UPDATE);
	form_center(options,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,w,h,x,y,w,h);

	set_opts();

	do {
		objc_draw(options,0,10,x,y,w,h);
		r=form_do(options,0)&0x7FFF;
		objc_unselect(options,r);
		if ( r==USER_KEY ) {
			get_user_keys();
		}
	} while ( r!=OK && r!=ABBR );

	if ( r==OK ) {
		get_opts();
		init_copy_out();
	}

	form_dial(FMD_FINISH,x,y,w,h,x,y,w,h);
	wind_update(END_UPDATE);
}

void save_options(void)
{
int f_id;

	f_id=Fcreate(set_file,0);
	if ( f_id>0 ) {
		Fwrite(f_id,sizeof(opts),&opts);
		Fclose(f_id);
	}
}

/*------------------------------------------------------------------------------

	sende fÅr av_protokol

------------------------------------------------------------------------------*/
char *get_send_puffer(void)
{
static char *send_puffer=0l;

	if ( !send_puffer ) {
		send_puffer=Mxalloc(128,0x0022);
		if ( send_puffer==(char*)-32 )
			send_puffer=Malloc(128);
	}
	return send_puffer;
}

void av_send(int msg_typ,int d1,int d2,char *str)
{
int msg[8];
char *puf;

	if ( av_id<0 || (msg_typ==AV_SENDKEY && !(av_state&1)) ||
		 (msg_typ==AV_OPENWIND && !(av_state&16)) ||
		 ((msg_typ==AV_ACCWINDOPEN || msg_typ==AV_ACCWINDCLOSED) && !(av_state&64)) ||
		 ((msg_typ==AV_PATH_UPDATE|| msg_typ==AV_WHAT_IZIT) && !(av_state&16)) ||
		 (msg_typ==AV_EXIT && !(av_state&1024))
		)	return;

	if ( str ) {
		puf=get_send_puffer();
		if ( !puf )
			return;
		strcpy(puf,str);
	}

	msg[0]=msg_typ;
	msg[1]=ap_id;
	msg[2]=0;
	if ( str ) {
		*(char**)&msg[3]=puf;
	}
	else {
		msg[3]=d1;
		msg[4]=d2;
	}
	msg[5]=msg[6]=msg[7]=0;
	if ( msg_typ==AV_PROTOKOLL )
		*(char**)&msg[6]="COLTRIS ";
	appl_write(av_id,16,msg);
}

void av_init(void)
{
char *av,_av[32];

		/* av/va kommunikationspartner einstellen */
	av=getenv("AVSERVER");
	if ( av!=0l ) {
		strncpy(_av,av,16);
		_av[16]=0;
		strcat(_av,"        ");
		_av[8]=0;
		av_id=appl_find(_av);
	}
	if ( av_id<0 ) {
		av_id=appl_find("GEMINI  ");
		if ( av_id<0 ) {
			av_id=appl_find("EASE    ");
			if ( av_id<0 ) {
				av_id=appl_find("AVSERVER");
			}
		}
	}
	av_send(AV_PROTOKOLL,2,0,0l);
}

void av_getproto(void)
{
int evnt;
EVENT event;

	do {
		memset(&event,0,sizeof(event));
		event.ev_mflags=MU_MESAG|MU_TIMER;
		event.ev_mtlocount=10;
		/*event.ev_mthicount=0;*/
		evnt=EvntMulti(&event);
		if ( evnt&MU_MESAG && event.ev_mmgpbuf[0]==VA_PROTOSTATUS )
			av_state=event.ev_mmgpbuf[3];
	} while ( evnt&MU_MESAG );
}

/*------------------------------------------------------------------------------

	init/exit, main

------------------------------------------------------------------------------*/
void get_tetris_size(int *w,int *h);
void get_columns_size(int *w,int *h);

void init_buffer(int width,int height)
{
int xwidth;

	if ( buffer_addr )
		free((void*)buffer_addr);

	xwidth=(width+15)&~15;

	buffer_size=(long)xwidth*(long)height*(long)planes/8l;
	buffer_addr=(long)malloc(buffer_size);
	if ( !buffer_addr )
		exit(1);
	memset((void*)buffer_addr,0,buffer_size);
	buffer.fd_addr=(void*)buffer_addr;
	buffer.fd_w=xwidth;
	buffer.fd_h=height;
	buffer.fd_wdwidth=xwidth/16;
	buffer.fd_nplanes=planes;
	buffer.fd_stand=0;
	buffer.fd_r1=buffer.fd_r2=buffer.fd_r3=0;

	buffer_width=xwidth/8;
	buffer_height=height;
}

void check_windpos(int *x,int *y)
{
	if ( *x<pos->desk_x )
		*x=pos->desk_x;
	else if ( *x>pos->desk_x+pos->desk_w-32 )
		*x=pos->desk_x+pos->desk_w-32;
	if ( *y<pos->desk_y )
		*y=pos->desk_y;
	else if ( *y>pos->desk_y+pos->desk_h-32 )
		*y=pos->desk_y+pos->desk_h-32;
}

void init_window(int *x_x,int *y_y,int *w_w,int *h_h)
{
int x,y,w,h,xx,yy,ww,hh;
int height;

	if ( objc_state(menue,M_TETRIS)&CHECKED )
		get_tetris_size(&width,&height);
	else
		get_columns_size(&width,&height);

	wind_calc(WC_BORDER,NAME|MOVER|CLOSER,pos->wind_pos[W_PLAY].x,pos->wind_pos[W_PLAY].y,width,height,&x,&y,&w,&h);
	check_windpos(&x,&y);
	wind_calc(WC_WORK,NAME|MOVER|CLOSER,x,y,w,h,&xx,&yy,&ww,&hh);
	xx&=~15;
	wind_calc(WC_BORDER,NAME|MOVER|CLOSER,xx,yy,ww,hh,&x,&y,&w,&h);
	*x_x=x;
	*y_y=y;
	*w_w=w;
	*h_h=h;

	init_buffer(width,height);
	init_copy_out();
}

void open_window(void)
{
int x,y,w,h,dummy;

	wind[W_PLAY].handle=wind_create(NAME|MOVER|CLOSER,0,0,screen_w,screen_h);
	init_window(&x,&y,&w,&h);
	if ( opts.play_mode==PM_COLUMNS )
		wind_set(wind[W_PLAY].handle,WF_NAME," Columns ");
	else
		wind_set(wind[W_PLAY].handle,WF_NAME," Tetris ");
	wind_open(wind[W_PLAY].handle,x,y,w,h);
	if ( opts.cycle )
		av_send(AV_ACCWINDOPEN,wind[W_PLAY].handle,0,0l);
	wind_get(wind[W_PLAY].handle,WF_WORKXYWH,&pos->wind_pos[W_PLAY].x,&pos->wind_pos[W_PLAY].y,&dummy,&dummy);
}

void close_window(void)
{
	wind_close(wind[W_PLAY].handle);
	wind_delete(wind[W_PLAY].handle);
	av_send(AV_ACCWINDCLOSED,wind[W_PLAY].handle,0,0l);
}

#define ABSTAND	24
void xhide(int *hide,int x,int y,int w,int h)
{
int mx,my,dummy;

	if ( *hide )
		return;		/* maus ist hidden */
	graf_mkstate(&mx,&my,&dummy,&dummy);
	if ( mx>x-ABSTAND && mx<=x+w+ABSTAND && my>y-ABSTAND && my<=y+h+ABSTAND ) {
		*hide=1;
		v_hide_c(handle);
	}
}

int check_recs(int x,int y,int w,int h,int *x1,int *y1,int *w1,int *h1)
{
int hx1,hy1,hx2,hy2;

	hx2=min(x+w,*x1+*w1);
	hy2=min(y+h,*y1+*h1);
	hx1=max(x,*x1);
	hy1=max(y,*y1);
	*x1=hx1; *y1=hy1;
	*w1=hx2-hx1; *h1=hy2-hy1;
	return( (hx2>hx1)&&(hy2>hy1) );
}

void redraw_play(int *message)
{
int m[8];
int xy[8];
int x,y,w,h,_w;
int xo,yo,ww,hh;
int hide=0;

	if ( !message ) {
		m[3]=wind[W_PLAY].handle;
		m[4]=m[5]=0;
		m[6]=screen_w;
		m[7]=screen_h;
		message=m;
	}
	wind_update(BEG_UPDATE);
	wind_get(message[3],WF_WORKXYWH,&xo,&yo,&ww,&hh);
	wind_get(message[3],WF_FIRSTXYWH,&x,&y,&w,&h);
	while ( w!=0 ) {
		_w=w;
		if ( check_recs(message[4],message[5],message[6],message[7],&x,&y,&w,&h) ) {
			if ( _w==ww && quick_flag ) {
			  char *source,*dest;
				xhide(&hide,xo,y,_w,h);
				source=(char*)buffer_addr+(long)(y-yo)*buffer_width;
				dest=(char*)screen_addr+(long)y*screen_width+xo/8;
				qcopy(dest,source,h-1);
			}
			else {
				xhide(&hide,x,y,w,h);
				xy[0]=x-xo;
				xy[1]=y-yo;
				xy[2]=x-xo+w-1;
				xy[3]=y-yo+h-1;
				xy[4]=x;
				xy[5]=y;
				xy[6]=x+w-1;
				xy[7]=y+h-1;
				vro_cpyfm(handle,S_ONLY,xy,&buffer,&screen);
			}
		}
		wind_get(message[3],WF_NEXTXYWH,&x,&y,&w,&h);
	}
	if ( hide )
		v_show_c(handle,1);
	wind_update(END_UPDATE);
}

#define OFFSET		11
void do_endgame(void)
{
/************
int i,j;
char *source,*dest;

	end_flag=1;
	dest=(char*)buffer_addr+buffer_size/2-sizeof(tet_ende);
	if ( opts.play_mode==PM_TETRIS )
		source=(char*)tet_ende;
	else
		source=(char*)col_ende;
	init_wait();
	for ( i=0,j=0; j<(int)sizeof(tet_ende); i+=OFFSET,j++ ) {
		if ( i>=(int)sizeof(tet_ende) ) {
			i-=(int)sizeof(tet_ende);
			redraw_play(0l);
			do_wait(2);
			init_wait();
		}
		dest[i]=source[i];
	}
/********
	init_wait();
	for ( i=0; i<7; i++ ) {
		if ( i&1 ) {
			for ( j=0; j<(int)sizeof(tet_ende); j++ )
				dest[j]=~source[j];
		}
		else {
			for ( j=0; j<(int)sizeof(tet_ende); j++ )
				dest[j]=source[j];
		}
		redraw_play(0l);
		do_wait(125);
		init_wait();
	}
********/
	redraw_play(0l);
********/
}

void set_tetris(void)
{
int x,y,w,h;

	if ( opts.play_mode==PM_TETRIS )
		return;

	opts.play_mode=PM_TETRIS;
	menu_icheck(menue,M_TETRIS,1);
	menu_icheck(menue,M_COLUMNS,0);

	init_window(&x,&y,&w,&h);
	wind_set(wind[W_PLAY].handle,WF_CURRXYWH,x,y,w,h);
	wind_set(wind[W_PLAY].handle,WF_NAME," Tetris ");
	clr_feld();

	objc_hide(stat,C_STAT);
	objc_unhide(stat,TSTAT);

	if ( opts.tetris.score!=score_flag )
		set_score();
	if ( opts.tetris.preview!=preview_flag )
		set_preview();
	if ( opts.tetris.statistic!=stat_flag )
		set_statistic();
	else if ( stat_flag )
		redraw_statistic(0l);
}

void set_columns(void)
{
int x,y,w,h;

	if ( opts.play_mode==PM_COLUMNS )
		return;

	opts.play_mode=PM_COLUMNS;
	menu_icheck(menue,M_COLUMNS,1);
	menu_icheck(menue,M_TETRIS,0);

	init_window(&x,&y,&w,&h);
	wind_set(wind[W_PLAY].handle,WF_CURRXYWH,x,y,w,h);
	wind_set(wind[W_PLAY].handle,WF_NAME," Columns ");
	clr_feld();

	objc_unhide(stat,C_STAT);
	objc_hide(stat,TSTAT);

	if ( opts.columns.score!=score_flag )
		set_score();
	if ( opts.columns.preview!=preview_flag )
		set_preview();
	if ( opts.columns.statistic!=stat_flag )
		set_statistic();
	else if ( stat_flag )
		redraw_statistic(0l);
}

static uint xlevel,xlines,xstones,xscore;

void dr_score(uint level,uint lines,uint stones,uint sc)
{
static int _level=-1,_lines=-1;
int le,li;
int x,y,w,h;
int hide=0;

	xlevel=level;
	xlines=lines;
	xstones=stones;
	xscore=sc;

	if ( !score_flag )
		return;

	le=li=0;
	if ( _level!=level ) {
		_level=level;
		sprintf(objc_tedstr(score,LEVEL),"%d",level);
		le=1;
	}
	if ( _lines!=lines ) {
		_lines=lines;
		sprintf(objc_tedstr(score,LINES),"%5d",lines);
		li=1;
	}
	sprintf(objc_tedstr(score,STONES),"%5d",stones);
	sprintf(objc_tedstr(score,SCORE),"%5d",sc);

	wind_get(wind[W_SCORE].handle,WF_WORKXYWH,&x,&y,&w,&h);
	score->ob_x=x;
	score->ob_y=y;

	wind_update(BEG_UPDATE);
	wind_get(wind[W_SCORE].handle,WF_FIRSTXYWH,&x,&y,&w,&h);
	while ( w ) {
		xhide(&hide,x,y,w,h);
		if ( le )
			objc_draw(score,LEVEL,0,x,y,w,h);
		if ( li )
			objc_draw(score,LINES,0,x,y,w,h);
		objc_draw(score,STONES,0,x,y,w,h);
		objc_draw(score,SCORE,0,x,y,w,h);
		wind_get(wind[W_SCORE].handle,WF_NEXTXYWH,&x,&y,&w,&h);
	}
	if ( hide )
		v_show_c(handle,1);
	wind_update(END_UPDATE);
}

void redraw_score(int *message)
{
int m[8];
int dummy;
int x,y,w,h;
int hide=0;

	if ( !message ) {
		m[3]=wind[W_SCORE].handle;
		m[4]=m[5]=0;
		m[6]=screen_w;
		m[7]=screen_h;
		message=m;
	}

	wind_get(wind[W_SCORE].handle,WF_WORKXYWH,&x,&y,&dummy,&dummy);
	score->ob_x=x;
	score->ob_y=y;

	wind_update(BEG_UPDATE);
	wind_get(message[3],WF_FIRSTXYWH,&x,&y,&w,&h);
	while ( w!=0 ) {
		if ( check_recs(message[4],message[5],message[6],message[7],&x,&y,&w,&h) ) {
			xhide(&hide,x,y,w,h);
			objc_draw(score,0,MAX_DEPTH,x,y,w,h);
		}
		wind_get(message[3],WF_NEXTXYWH,&x,&y,&w,&h);
	}
	if ( hide )
		v_show_c(handle,1);
	wind_update(END_UPDATE);
}

void open_score(void)
{
int x,y,w,h,dummy;

	wind[W_SCORE].handle=wind_create(NAME|MOVER|CLOSER,0,0,screen_w,screen_h);
	wind_calc(WC_BORDER,NAME|MOVER|CLOSER,pos->wind_pos[W_SCORE].x,pos->wind_pos[W_SCORE].y,score->ob_width,score->ob_height,&x,&y,&w,&h);
	check_windpos(&x,&y);
	wind_set(wind[W_SCORE].handle,WF_NAME," Score ");
	dr_score(xlevel,xlines,xstones,xscore);
	wind_open(wind[W_SCORE].handle,x,y,w,h);
	if ( opts.cycle==2 )
		av_send(AV_ACCWINDOPEN,wind[W_SCORE].handle,0,0l);
	wind_get(wind[W_SCORE].handle,WF_WORKXYWH,&pos->wind_pos[W_SCORE].x,&pos->wind_pos[W_SCORE].y,&dummy,&dummy);
	redraw_score(0l);
	if ( wind[W_PLAY].handle ) {
		wind_set(wind[W_PLAY].handle,WF_TOP);
		redraw_play(0l);
	}
}


void set_score(void)
{
	score_flag=1-score_flag;
	if ( opts.play_mode==PM_TETRIS )
		opts.tetris.score=score_flag;
	else
		opts.columns.score=score_flag;
	menu_icheck(menue,M_SCORE,score_flag);
	if ( !score_flag ) {
		wind_close(wind[W_SCORE].handle);
		wind_delete(wind[W_SCORE].handle);
		av_send(AV_ACCWINDCLOSED,wind[W_SCORE].handle,0,0l);
		wind[W_SCORE].handle=-1;
	}
	else {
		open_score();
	}
}

int prev_x,prev_y,prev_w,prev_h;

void redraw_preview(int *message)
{
int xy[4];
int m[8];
int x,y,w,h;
int hide=0;

	if ( !message ) {
		m[3]=wind[W_PREVIEW].handle;
		m[4]=m[5]=0;
		m[6]=screen_w;
		m[7]=screen_h;
		message=m;
	}

	vsf_style(handle,8);
	vsf_color(handle,0);

	wind_update(BEG_UPDATE);
	wind_get(message[3],WF_FIRSTXYWH,&x,&y,&w,&h);
	while ( w!=0 ) {
		if ( check_recs(message[4],message[5],message[6],message[7],&x,&y,&w,&h) ) {
			xhide(&hide,x,y,w,h);
			xy[0]=x;
			xy[1]=y;
			xy[2]=x+w-1;
			xy[3]=y+h-1;
			v_bar(handle,xy);
		}
		wind_get(message[3],WF_NEXTXYWH,&x,&y,&w,&h);
	}
	if ( hide )
		v_show_c(handle,1);
	wind_update(END_UPDATE);
}

void draw_preview(Draw_Funct draw,void *data)
{
int xy[4];
int x,y,w,h;
int hide=0;

	wind_update(BEG_UPDATE);
	wind_get(wind[W_PREVIEW].handle,WF_FIRSTXYWH,&x,&y,&w,&h);
	while ( w!=0 ) {
		xhide(&hide,x,y,w,h);
		xy[0]=x;
		xy[1]=y;
		xy[2]=x+w-1;
		xy[3]=y+h-1;
		vs_clip(handle,1,xy);
		draw(data,x,y,w,h);
		wind_get(wind[W_PREVIEW].handle,WF_NEXTXYWH,&x,&y,&w,&h);
	}
	vs_clip(handle,0,xy);
	if ( hide )
		v_show_c(handle,1);
	wind_update(END_UPDATE);
}

void open_preview(void)
{
int x,y,w,h;
int cw,ch,tw,th,width,height;
void get_columns_prev(int *w,int *h);
void get_tetris_prev(int *w,int *h);

	get_columns_prev(&cw,&ch);
	get_tetris_prev(&tw,&th);

	width=max(cw,tw);
	height=max(ch,th);

	wind[W_PREVIEW].handle=wind_create(NAME|MOVER|CLOSER,0,0,screen_w,screen_h);
	wind_calc(WC_BORDER,NAME|MOVER|CLOSER,pos->wind_pos[W_PREVIEW].x,pos->wind_pos[W_PREVIEW].y,width,height,&x,&y,&w,&h);
	check_windpos(&x,&y);
	wind_set(wind[W_PREVIEW].handle,WF_NAME," Next ");
	wind_open(wind[W_PREVIEW].handle,x,y,w,h);
	if ( opts.cycle==2 )
		av_send(AV_ACCWINDOPEN,wind[W_PREVIEW].handle,0,0l);
	wind_get(wind[W_PREVIEW].handle,WF_WORKXYWH,&prev_x,&prev_y,&prev_w,&prev_h);
	pos->wind_pos[W_PREVIEW].x=prev_x;
	pos->wind_pos[W_PREVIEW].y=prev_y;
	redraw_preview(0l);
	if ( wind[W_PLAY].handle ) {
		wind_set(wind[W_PLAY].handle,WF_TOP);
		redraw_play(0l);
	}
}

void set_preview(void)
{
	preview_flag=1-preview_flag;
	if ( opts.play_mode==PM_TETRIS )
		opts.tetris.preview=preview_flag;
	else
		opts.columns.preview=preview_flag;
	menu_icheck(menue,M_PREVIEW,preview_flag);
	if ( !preview_flag ) {
		wind_close(wind[W_PREVIEW].handle);
		wind_delete(wind[W_PREVIEW].handle);
		av_send(AV_ACCWINDCLOSED,wind[W_PREVIEW].handle,0,0l);
		wind[W_PREVIEW].handle=-1;
	}
	else {
		open_preview();
	}
}

void redraw_statistic(int *message)
{
int m[8];
int dummy;
int x,y,w,h,xy[4];
int st_x,st_y,st_dy;
int hide=0;
void dr_tstat(int x,int y,int dy);
void dr_cstat(int x,int y,int dy);

	if ( !message ) {
		m[3]=wind[W_STATISTIC].handle;
		m[4]=m[5]=0;
		m[6]=screen_w;
		m[7]=screen_h;
		message=m;
	}

	wind_get(wind[W_STATISTIC].handle,WF_WORKXYWH,&x,&y,&dummy,&dummy);
	stat->ob_x=x;
	stat->ob_y=y;

	st_x=x;
	if ( opts.play_mode==PM_TETRIS ) {
		objc_offset(stat,TSTAT0,&h,&st_y);
		y=st_y+stat[TSTAT0].ob_height/2;
		objc_offset(stat,TSTAT0+1,&w,&h);
		h+=stat[TSTAT0+1].ob_height/2;
	}
	else {
		objc_offset(stat,CSTAT0,&h,&st_y);
		y=st_y+stat[CSTAT0].ob_height/2;
		objc_offset(stat,CSTAT0+1,&w,&h);
		h+=stat[CSTAT0+1].ob_height/2;
	}
	st_dy=h-y;

	wind_update(BEG_UPDATE);
	wind_get(message[3],WF_FIRSTXYWH,&x,&y,&w,&h);
	while ( w!=0 ) {
		if ( check_recs(message[4],message[5],message[6],message[7],&x,&y,&w,&h) ) {
			xhide(&hide,x,y,w,h);
			objc_draw(stat,0,MAX_DEPTH,x,y,w,h);
			xy[0]=x;
			xy[1]=y;
			xy[2]=x+w-1;
			xy[3]=y+h-1;
			vs_clip(handle,1,xy);
			if ( opts.play_mode==PM_TETRIS )
				dr_tstat(st_x,st_y,st_dy);
			else
				dr_cstat(st_x,st_y,st_dy);
			vs_clip(handle,0,xy);
		}
		wind_get(message[3],WF_NEXTXYWH,&x,&y,&w,&h);
	}
	if ( hide )
		v_show_c(handle,1);
	wind_update(END_UPDATE);
}

int _stat[10];

void dr_stat(uint *nstat)
{
int x,y,w,h;
int i,ii,o;

	if ( opts.play_mode==PM_TETRIS ) {
		ii=7;
		o=TSTAT0;
	}
	else {
		ii=6;
		o=CSTAT0;
	}
	for ( i=0; i<ii; i++,o++ ) {
	  int hide=0;
		if ( nstat[i]!=_stat[i] ) {
			_stat[i]=nstat[i];
			sprintf(objc_tedstr(stat,o),"%3d",nstat[i]);
			wind_get(wind[W_STATISTIC].handle,WF_WORKXYWH,&x,&y,&w,&h);
			stat->ob_x=x;
			stat->ob_y=y;

			wind_update(BEG_UPDATE);
			wind_get(wind[W_STATISTIC].handle,WF_FIRSTXYWH,&x,&y,&w,&h);
			while ( w ) {
				xhide(&hide,x,y,w,h);
				objc_draw(stat,o,0,x,y,w,h);
				wind_get(wind[W_STATISTIC].handle,WF_NEXTXYWH,&x,&y,&w,&h);
			}
			if ( hide )
				v_show_c(handle,1);
			wind_update(END_UPDATE);
		}
	}
}

void open_stat(void)
{
int x,y,w,h,dummy;

	wind[W_STATISTIC].handle=wind_create(NAME|MOVER|CLOSER,0,0,screen_w,screen_h);
	wind_calc(WC_BORDER,NAME|MOVER|CLOSER,pos->wind_pos[W_STATISTIC].x,pos->wind_pos[W_STATISTIC].y,stat->ob_width,stat->ob_height,&x,&y,&w,&h);
	check_windpos(&x,&y);
	wind_set(wind[W_STATISTIC].handle,WF_NAME," Statistic ");
	wind_open(wind[W_STATISTIC].handle,x,y,w,h);
	if ( opts.cycle==2 )
		av_send(AV_ACCWINDOPEN,wind[W_STATISTIC].handle,0,0l);
	wind_get(wind[W_STATISTIC].handle,WF_WORKXYWH,&pos->wind_pos[W_STATISTIC].x,&pos->wind_pos[W_STATISTIC].y,&dummy,&dummy);
	redraw_statistic(0l);
	if ( wind[W_PLAY].handle ) {
		wind_set(wind[W_PLAY].handle,WF_TOP);
		redraw_play(0l);
	}
}

void set_statistic(void)
{
	stat_flag=1-stat_flag;
	if ( opts.play_mode==PM_TETRIS )
		opts.tetris.statistic=stat_flag;
	else
		opts.columns.statistic=stat_flag;
	menu_icheck(menue,M_STATISTIC,stat_flag);
	if ( !stat_flag ) {
		wind_close(wind[W_STATISTIC].handle);
		wind_delete(wind[W_STATISTIC].handle);
		av_send(AV_ACCWINDCLOSED,wind[W_STATISTIC].handle,0,0l);
		wind[W_STATISTIC].handle=-1;
	}
	else {
		open_stat();
	}
}

void do_play(void)
{
int dummy,gret;
int preview,score,statistic;
int message[8];
WINDOWS w;

int columns(void);
int tetris(void);

	if ( opts.multi ) {
		menu_tnormal(menue,MT_FILE,1);
		menu_ienable(menue,M_QUIT,0);
		menu_ienable(menue,M_START,0);
		menu_ienable(menue,M_TETRIS,0);
		menu_ienable(menue,M_COLUMNS,0);
		menu_ienable(menue,M_OPTS,0);
	}
	else {
		v_hide_c(handle);
		wind_update(BEG_MCTRL);
		wind_update(BEG_UPDATE);
	}

	if ( opts.top ) {
		for ( w=WIND_ANZ-1; w>=0; w-- ) {
			wind_set(wind[w].handle,WF_TOP);
			wind[w].redraw(0l);
		}
	}
	else {
		wind_set(wind[W_PLAY].handle,WF_TOP);
	}
	preview=preview_flag;
	score=score_flag;
	statistic=stat_flag;

	end_flag=0;
	clr_feld();

	if ( preview_flag )
		wind_get(wind[W_PREVIEW].handle,WF_WORKXYWH,&prev_x,&prev_y,&prev_w,&prev_h);
	wind_get(wind[W_PLAY].handle,WF_WORKXYWH,&x_off,&y_off,&dummy,&dummy);

	init_copy_out();

	if ( opts.play_mode==PM_COLUMNS )
		gret=columns();
	else
		gret=tetris();

	if ( !gret )	/* spielabbruch -> loesche spielfeld */
		clr_feld();
	else {
		do_endgame();
	}
	if ( preview!=preview_flag )
		set_preview();
	else if ( preview_flag ) {
		message[3]=wind[W_PREVIEW].handle;
		message[4]=0;
		message[5]=0;
		message[6]=screen_w;
		message[7]=screen_h;
		redraw_preview(message);
	}
	if ( score!=score_flag )
		set_score();
	if ( statistic!=stat_flag )
		set_statistic();

	if ( opts.multi ) {
		menu_ienable(menue,M_QUIT,1);
		menu_ienable(menue,M_START,1);
		if ( tetris_vdi!=-1 )
			menu_ienable(menue,M_TETRIS,1);
		if ( columns_vdi!=-1 )
			menu_ienable(menue,M_COLUMNS,1);
		menu_ienable(menue,M_OPTS,1);
	}
	else {
		wind_update(END_MCTRL);
		wind_update(END_UPDATE);
		v_show_c(handle,1);
	}
}

void prog_info(void)
{
int x,y,w,h,r;

	form_center(info,&x,&y,&w,&h);
	wind_update(BEG_UPDATE);
	form_dial(FMD_START,x,y,w,h,x,y,w,h);
	objc_draw(info,0,10,x,y,w,h);
	r=form_do(info,0)&0x7FFF;
	form_dial(FMD_FINISH,x,y,w,h,x,y,w,h);
	wind_update(END_UPDATE);
	objc_unselect(info,r);
}

int do_menue(int titel,int entry)
{
	if ( objc_state(menue,entry)&DISABLED )
		return 0;

	switch ( entry ) {
	  case M_INFO:	  	prog_info();	  break;
	  case M_START:	  	do_play();		  break;
	  case M_HISCORE:	show_hiscore();	  break;
	  case M_QUIT:	  	return 1;
	  case M_TETRIS:  	set_tetris();	  break;
	  case M_COLUMNS:  	set_columns();	  break;
	  case M_SCORE:	  	set_score();	  break;
	  case M_PREVIEW:  	set_preview();	  break;
	  case M_STATISTIC:	set_statistic();  break;
	  case M_OPTS:	  	do_options();	  break;
	  case M_SAVE:	  	save_options();	  break;
	}
	if ( titel )
		menu_tnormal(menue,titel,1);
	return 0;
}

void do_ctrl(int flag)
{
int dummy;
WINDOWS w;
EVENT event;
int evnt,i;
int key;

	if ( !flag ) {
		event.ev_mflags=MU_MESAG|MU_KEYBD;
	}
	else {
		event.ev_mflags=MU_MESAG|MU_TIMER;
		event.ev_mtlocount=1;
		event.ev_mthicount=0;
	}

	while ( 1 ) {
		evnt=EvntMulti(&event);

		if ( evnt==MU_TIMER )
			return;

		if ( evnt&MU_KEYBD ) {
			key=*(char*)&event.ev_mkreturn;
			event.ev_mmokstate&=~(K_LSHIFT|K_RSHIFT);
			for ( i=0; i<(int)(sizeof(commands)/sizeof(commands[0])); i++ ) {
				if ( key==commands[i].key && event.ev_mmokstate==commands[i].state ) {
					if ( do_menue(0,commands[i].entry) )
						return;
					break;
				}
			}
			if ( i==(int)(sizeof(commands)/sizeof(commands[0])) )
				av_send(AV_SENDKEY,event.ev_mmokstate,event.ev_mkreturn,0l);
		}
		else if ( evnt&MU_MESAG ) {
			switch ( event.ev_mmgpbuf[0] ) {
			  case MN_SELECTED:
			  	if( do_menue(event.ev_mmgpbuf[3],event.ev_mmgpbuf[4]) )
			  		return;
			  break;
			  case WM_REDRAW:
				for ( w=0; w<WIND_ANZ; w++ ) {
					if ( event.ev_mmgpbuf[3]==wind[w].handle ) {
						wind[w].redraw(event.ev_mmgpbuf);
						break;
					}
				}
			  break;
			  case WM_TOPPED:
		  		wind_set(event.ev_mmgpbuf[3],WF_TOP);
			  break;
			  case WM_MOVED:
			  	if ( event.ev_mmgpbuf[3]==wind[W_PLAY].handle ) {
				  int x,y,w,h;
			  		wind_calc(WC_WORK,NAME|MOVER|CLOSER,event.ev_mmgpbuf[4],event.ev_mmgpbuf[5],event.ev_mmgpbuf[6],event.ev_mmgpbuf[7],&x,&y,&w,&h);
		  			x&=~15;
			  		wind_calc(WC_BORDER,NAME|MOVER|CLOSER,x,y,w,h,event.ev_mmgpbuf+4,event.ev_mmgpbuf+5,event.ev_mmgpbuf+6,event.ev_mmgpbuf+7);
				}
			    wind_set(event.ev_mmgpbuf[3],WF_CURRXYWH,event.ev_mmgpbuf[4],event.ev_mmgpbuf[5],event.ev_mmgpbuf[6],event.ev_mmgpbuf[7]);
				for ( w=0; w<WIND_ANZ; w++ ) {
					if ( event.ev_mmgpbuf[3]==wind[w].handle ) {
						wind_get(event.ev_mmgpbuf[3],WF_WORKXYWH,&pos->wind_pos[w].x,&pos->wind_pos[w].y,&dummy,&dummy);
						break;
					}
				}
			  break;
			  case WM_CLOSED:
				for ( w=0; w<WIND_ANZ; w++ ) {
					if ( event.ev_mmgpbuf[3]==wind[w].handle ) {
					  	wind[w].close();
						break;
					}
				}
				if ( w==0 )
					return;
			  break;
			}
		}
	}
}

void scale_tree(OBJECT *tree)
{
int i=0;

	do {
		rsrc_obfix(tree,i);
	} while ( !(tree[i++].ob_flags&LASTOB) );
}

void do_init(void)
{
int i,f_id;
int dummy,work_in[11],work_out[57];
int desk_x,desk_y,desk_w,desk_h;
long h;
WINDOWS w;

		/* init */
	ap_id=appl_init();

	av_init();

		/* init resources */
	menue=rs_trindex[MENUE];
	scale_tree(menue);
	score=rs_trindex[XSCORE];
	scale_tree(score);
	stat=rs_trindex[STATISTIC];
	scale_tree(stat);
	options=rs_trindex[OPTSBOX];
	scale_tree(options);
	info=rs_trindex[INFOBOX];
	scale_tree(info);
	user_keys=rs_trindex[KEYS];
	scale_tree(user_keys);
	hiscore=rs_trindex[HISCORE];
	scale_tree(hiscore);
	hi_name=rs_trindex[NEWHI];
	scale_tree(hi_name);
	*objc_tedstr(hi_name,HI_NAME)=0;

		/* lese voreinstellung */
  	set_file[0]=Dgetdrv()+'A';
  	set_file[1]=':';
  	Dgetpath(set_file+2,0);
	strcat(set_file,"\\COLTRIS.SET");
	f_id=Fopen(set_file,0);
	if ( f_id>0 ) {
		Fread(f_id,sizeof(opts),&opts);
		Fclose(f_id);
	}

	wind_get(0,WF_WORKXYWH,&desk_x,&desk_y,&desk_w,&desk_h);

	for ( i=0; i<8; i++ ) {
		pos=&opts.pos[i];
		if ( pos->desk_x==desk_x && pos->desk_y==desk_y && pos->desk_w==desk_w && pos->desk_h==desk_h )
			break;
	}
	if ( i==8 ) {
		for ( i=7; i>0; i-- )
			opts.pos[i]=opts.pos[i-1];
		pos=&opts.pos[0];
		for ( w=0; w<WIND_ANZ; w++ ) {
			h=(long)(pos->wind_pos[w].x-pos->desk_x)*desk_w;
			pos->wind_pos[w].x=(int)(h/pos->desk_w)+desk_x;
			h=(long)(pos->wind_pos[w].y-pos->desk_y)*desk_h;
			pos->wind_pos[w].y=(int)(h/pos->desk_h)+desk_y;
		}
		pos->desk_x=desk_x;
		pos->desk_y=desk_y;
		pos->desk_w=desk_w;
		pos->desk_h=desk_h;
	}

		/* init vdi */
	handle=graf_handle(&dummy,&dummy,&dummy,&dummy);
	for ( i=0; i<10; i++ )
		work_in[i]=1;
	work_in[10]=2;
	v_opnvwk(work_in,&handle,work_out);
	graf_mouse(0,0);

	screen_w=work_out[0]+1;
	screen_h=work_out[1]+1;

	vq_extnd(handle,1,work_out);
	planes=work_out[4];


	vswr_mode(handle,MD_REPLACE);
	vsf_interior(handle,FIS_PATTERN);
	vsf_perimeter(handle,0);

	vst_color(handle,0);
	vst_height(handle,20,&dummy,&dummy,&dummy,&dummy);
	/*vst_effects(handle,16);*/
	vst_alignment(handle,1,1,&dummy,&dummy);

	av_getproto();
}

void do_exit(int ret)
{
WINDOWS w;

	if ( ret==1 ) {
		form_error(8);
	}
	else if ( ret==2 ) {
		form_alert(1,"[1][ | Missing or incorrect | | Image-Files! | ][ Exit ]");
	}
	else if ( ret!=0 ) {
		form_alert(1,"[1][ | Something went wrong! | ][ Exit ]");
	}
	for ( w=0; w<WIND_ANZ; w++ ) {
		if ( wind[w].handle ) {
			wind_close(wind[w].handle);
			wind_delete(wind[w].handle);
			av_send(AV_ACCWINDCLOSED,wind[w].handle,0,0l);
		}
	}
	v_clsvwk(handle);
	av_send(AV_EXIT,0,0,0l);
	appl_exit();
	if ( buffer_addr )
		free((void*)buffer_addr);
	exit(ret);
}


void main(void)
{
int init_columns(void);
int init_tetris(void);

	do_init();

	if ( !init_columns() )
		menu_ienable(menue,M_COLUMNS,0);
	if ( !init_tetris() )
		menu_ienable(menue,M_TETRIS,0);
	if ( objc_state(menue,M_COLUMNS)&DISABLED && objc_state(menue,M_TETRIS)&DISABLED )
		do_exit(2);

	if ( opts.play_mode==PM_COLUMNS && !(objc_state(menue,M_COLUMNS)&DISABLED) ) {
		menu_icheck(menue,M_COLUMNS,1);
		objc_unhide(stat,C_STAT);
		objc_hide(stat,TSTAT);
	}
	else {
		menu_icheck(menue,M_TETRIS,1);
		objc_hide(stat,C_STAT);
		objc_unhide(stat,TSTAT);
		opts.play_mode=PM_TETRIS;
	}

	menu_bar(menue,1);

	if ( (opts.play_mode==PM_COLUMNS && opts.columns.score) ||
			(opts.play_mode==PM_TETRIS && opts.tetris.score) )
		set_score();
	if ( (opts.play_mode==PM_COLUMNS && opts.columns.preview) ||
			(opts.play_mode==PM_TETRIS && opts.tetris.preview) )
		set_preview();
	if ( (opts.play_mode==PM_COLUMNS && opts.columns.statistic) ||
			(opts.play_mode==PM_TETRIS && opts.tetris.statistic) )
		set_statistic();
	open_window();

	do_ctrl(0);

	do_exit(0);
}

