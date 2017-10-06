#include "cltr.h"

#include <portab.h>
#include <tos.h>
#include <xgem.h>

#include <vaproto.h>

#define ICF_GETPOS   0x0001
#define ICF_FREEPOS  0x0002

#include "coltris.rh"
#include "coltris.h"

extern void (*qcopy)(char *dest,char *source,int lines);
void clr_feld(void);

void init_copy_out(void);

int ap_id,av_id=-1;			/* fÅr AV/VA-protocoll */
int av_state;

							/* object-bÑume */
OBJECT *menue,*options,*info,*user_keys;
OBJECT *score,*stat;
OBJECT *hi_name,*hiscore;
OBJECT *icon;

/*
		tastaturkommandos
*/
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
M_ABORT		,0x10,	K_ALT,	/* q */
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
M_STONES	,0x1F,	K_CTRL,	/* s */
M_STONES	,0x1F,	0,		/* s */
};

char set_file[128]="COLTRIS.SET";

OPTS opts={
	PM_TETRIS, 0, 0,0,1,0,0,1,0,0,0,0,0,
	{{"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0},
	 {"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0,"---",0,0}},
	{{7,0,1,0,0},{7,0,1,0,0}},
	{{{{{240,50},{68,50},{377,50},{148,198}},120,320,0,19,640,381}},
	 {{{{240,50},{68,50},{377,50},{148,198}},120,320,0,19,640,381}}},
	{{"TETRIS1.IMG","TETRIS2.IMG","TETRIS4.IMG","TETRIS8.IMG"},
	 {"COLUMNS1.IMG","COLUMNS2.IMG","COLUMNS4.IMG","COLUMNS8.IMG"}},
};

POSITION *pos[2];

int score_flag,preview_flag,stat_flag;
int prev_x,prev_y,prev_w,prev_h;
int in_game=0;
GAME *game;

uint last_score;

long screen_addr;
long buffer_addr;
long buffer_size;
int buffer_width,buffer_height;		/* width in byte */
int screen_width;					/* in byte */
int source_width;
int screen_w,screen_h,planes,planes_nr;
int quick_flag;						/* copy in screen mit ass-routine erlaubt */
int x_off,y_off,width;

MFDB screen,buffer;
int handle;					/* vdi-handle */

int do_control(int flag);

/*

	fenster-routinen

*/
void redraw_play(int *message);
void close_window(void);
void set_score(void);
void redraw_score(int *message);
void set_preview(void);
void redraw_preview(int *message);
void set_statistic(void);
void redraw_statistic(int *message);

#define WIND_ELEMENTS	NAME|MOVER|CLOSER
#define WIND_XELEMENTS	NAME|MOVER|CLOSER|(SMALLER*aes_iconify)

WINDOW wind[WIND_ANZ]={-1,redraw_play,close_window,
					   -1,redraw_score,set_score,
					   -1,redraw_preview,set_preview,
					   -1,redraw_statistic,set_statistic};

int aes_iconify;
int icon_nr;
int iconified_handle=-1;
int iconified_pos;
int cdecl (*iconify_server)(int opt,...);		/* fÅr iconfy */

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

/*------------------------------------------------------------------------------

	zufallszahlengenerator nach knuth

------------------------------------------------------------------------------*/
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

/*------------------------------------------------------------------------------

	timer-routinen

------------------------------------------------------------------------------*/
static long _gettimer(void)
{
	return *(long*)0x4BA;
}
long gettime(void)
{
	return Supexec(_gettimer);
}

static long time;
void init_wait(void)
{
	time=gettime();
}
void do_wait(int ms)
{
	if ( !time )
		init_wait();
	while ( gettime()<time+ms )
		;
	time=0l;
}

uint calc_delay(uint level)
{
	return 55-level*5;
}

/*
		pause im spiel

		*** IMPROVEMENT: hide playfield during pause
*/
void do_pause(void)
{
WINDOWS w;
int exit_iconify(void);
int is_iconified(void);

	if ( !opts.multi ) {
		wind_update(END_UPDATE);
		wind_update(END_MCTRL);
		v_show_c(handle,1);
	}
	do_control(-1);
	
	if ( is_iconified() )
		exit_iconify();

	if ( !opts.multi ) {
		wind_update(BEG_UPDATE);
		wind_update(BEG_MCTRL);
		v_hide_c(handle);
	}
	if ( opts.top ) {
		for ( w=WIND_ANZ-1; w>=0; w-- ) {
			if ( wind[w].handle>=0 ) {
				wind_set(wind[w].handle,WF_TOP);
				wind[w].redraw(0l);
			}
		}
	}
	else {
		wind_set(wind[W_PLAY].handle,WF_TOP);
		redraw_play(0l);
	}
}

/*------------------------------------------------------------------------------

	tastatur-routinen

------------------------------------------------------------------------------*/

KEY do_get_key(void)
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
	if ( key==opts.rot_ccw )
		return K_ROT_CCW;
	if ( key==opts.drop )
		return K_DROP;

	if ( key==0x67 )				/* 7z */
		return K_LEFT;
	if ( key==0x69 )				/* 9z */
		return K_RIGHT;
	if ( key==0x68 )				/* 8z */
		return K_ROTATE;
	if ( key==0x64 )				/* )z */
		return K_ROT_CCW;
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

/*
	gebe taste (funktions-code) zurÅck (ohne warten)	

	bearbeite:
		toggle preview
			   info
			   statistik
		pause
*/
KEY get_key(void)
{
KEY key;

	while ( 1 ) {
		key=do_get_key();
		switch ( key ) {
		  case K_NEXT:
			set_preview();
			if ( preview_flag )
				redraw_preview(0l);
			else
				window_closed();
		  break;
		  case K_INFO:
		  	set_score();
			if ( !score_flag )
				window_closed();
		  break;
		  case K_STAT:
		  	set_statistic();
			if ( !stat_flag )
				window_closed();
		  break;
		  case K_STOP:
			do_pause();
		  break;
		  default:
		  return key;
		}
	}
}

/*
		lîsche tastaturpuffer
*/
void clr_keys(void)
{
EVENT evnt;

	evnt.ev_mflags=MU_KEYBD|MU_TIMER;
	evnt.ev_mtlocount=1;
	evnt.ev_mthicount=0;
	while ( EvntMulti(&evnt)&MU_KEYBD )
		;
}

/*
		hole taste (scancode) mit warten
*/
int xget_key(void)
{
int key;

	key=evnt_keybd();
	return *(char*)&key;
}

void window_closed(void)
{
int top,d;

	if ( !opts.multi ) {
		wind_update(END_UPDATE);
		wind_update(END_MCTRL);
		v_show_c(handle,1);
	}
	do_control(100);
	if ( !opts.multi ) {
		wind_update(BEG_UPDATE);
		wind_update(BEG_MCTRL);
		v_hide_c(handle);
	}
	wind_get(0,WF_TOP,&top,&d,&d,&d);
	if ( d!=wind[W_PLAY].handle ) {
		wind_set(wind[W_PLAY].handle,WF_TOP);
		redraw_play(0l);
	}
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
#if SOUND_LEVEL>0
			do_sound(S_HISCORE);
#endif
			wind_update(BEG_UPDATE);
			form_center(hi_name,&x,&y,&w,&h);
			form_dial(FMD_START,x,y,w,h,x,y,w,h);
			objc_draw(hi_name,0,10,x,y,w,h);
			form_do(hi_name,HI_NAME);
			form_dial(FMD_FINISH,x,y,w,h,x,y,w,h);
			wind_update(END_UPDATE);

			obj_unselect(hi_name,HI_NAME);
			for ( j=9; j>i; j-- )
				hi[j]=hi[j-1];
			strcpy(hi[i].name,obj_tedstr(hi_name,HI_NAME));
			hi[i].score=score;
			hi[i].date=Tgetdate();
			return;
		}
	}
#if SOUND_LEVEL>0
	if ( i==10 )
		do_sound(S_NOHISCORE);
#endif
}

void show_hiscore(void)
{
HI_SCORE *hi;
int i,ret,x,y,w,h;
uint date;
char title[32];

	sprintf(title,"%s Hiscore",game->name);
	obj_spec(hiscore,HI_TITEL)=title;

	hi=opts.hiscore[opts.play_mode];

	obj_hide(hiscore,HI_MARKE);
	for ( i=0; i<10; i++ ) {
		if ( hi[i].score!=0 ) {
			strcpy(obj_spec(hiscore,HISCORE1+i+i+i),hi[i].name);
			date=hi[i].date;
			sprintf(obj_spec(hiscore,HISCORE1+1+i+i+i),"%2d.%2d.%4d",date&31,(date>>5)&15,(date>>9)+1980);
			sprintf(obj_spec(hiscore,HISCORE1+2+i+i+i),"%5d",hi[i].score);
			if ( hi[i].score==last_score ) {
				obj_unhide(hiscore,HI_MARKE);
				hiscore[HI_MARKE].ob_y=hiscore[HISCORE1+i+i+i].ob_y;
			}
		}
		else {
			*obj_spec(hiscore,HISCORE1+i+i+i)=0;
			*obj_spec(hiscore,HISCORE1+1+i+i+i)=0;
			*obj_spec(hiscore,HISCORE1+2+i+i+i)=0;
		}

	}

	form_center(hiscore,&x,&y,&w,&h);
	wind_update(BEG_UPDATE);
	form_dial(FMD_START,x,y,w,h,x,y,w,h);
	objc_draw(hiscore,0,10,x,y,w,h);
	ret=form_do(hiscore,0)&0x7FFF;
	obj_unselect(hiscore,ret);
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

	go=&opts.opts[opts.play_mode];
	if ( opts.play_mode==PM_COLUMNS ) {
		obj_select(options,O_COLUMNS);
		obj_unselect(options,O_TETRIS);
	}
	else {
		obj_select(options,O_TETRIS);
		obj_unselect(options,O_COLUMNS);
	}
	for ( i=LEVEL0; i<=LEVEL9; i++ ) {
		obj_unselect(options,i);
	}
	if ( go->start_level<9 )
		obj_select(options,LEVEL0+go->start_level);

	for ( i=RANDOM0; i<=RANDOM14; i++ ) {
		obj_unselect(options,i);
	}
	if ( go->random<14 )
		obj_select(options,RANDOM0+go->random);

	obj_unselect(options,SOUND_ON);
	obj_unselect(options,SOUND_OFF);
	if ( opts.sound )
		obj_select(options,SOUND_ON);
	else
		obj_select(options,SOUND_OFF);

	obj_unselect(options,GRAPH_ST);
	obj_unselect(options,GRAPH_VDI);
	if ( columns.vdi )
		obj_disable(options,O_GCOL);
	else
		obj_enable(options,O_GCOL);
	if ( tetris.vdi )
		obj_disable(options,O_GTET);
	else
		obj_enable(options,O_GTET);
	if ( columns.vdi && tetris.vdi ) {
		obj_disable(options,GRAPH_ST);
		obj_disable(options,GRAPH_VDI);
	}
	else {
		obj_enable(options,GRAPH_ST);
		obj_enable(options,GRAPH_VDI);
		if ( opts.graph )
			obj_select(options,GRAPH_VDI);
		else
			obj_select(options,GRAPH_ST);
	}

	obj_unselect(options,SINGLE);
	obj_unselect(options,MULTI);
	if ( opts.multi )
		obj_select(options,MULTI);
	else
		obj_select(options,SINGLE);

	obj_unselect(options,CYCLENONE);
	obj_unselect(options,CYCLEPLAY);
	obj_unselect(options,CYCLEALL);
	if ( opts.cycle==0 )
		obj_select(options,CYCLENONE);
	else if ( opts.cycle==1 )
		obj_select(options,CYCLEPLAY);
	else
		obj_select(options,CYCLEALL);

	if ( opts.top )
		obj_select(options,TOP_ALL);
	else
		obj_unselect(options,TOP_ALL);

	if ( opts.alert )
		obj_select(options,ALERT);
	else
		obj_unselect(options,ALERT);
}

void get_opts(void)
{
GAME_OPTS *go;
int i;

	go=&opts.opts[opts.play_mode];

	for ( i=LEVEL0; i<=LEVEL9; i++ ) {
		if ( obj_selected(options,i) )
			{ go->start_level=i-LEVEL0; break; }
	}

	for ( i=RANDOM0; i<=RANDOM14; i++ ) {
		if ( obj_selected(options,i) )
			{ go->random=i-RANDOM0; break; }
	}

	if ( obj_selected(options,SOUND_ON) )
		opts.sound=1;
	else
		opts.sound=0;

	if ( obj_selected(options,GRAPH_VDI) )
		opts.graph=1;
	else if ( obj_selected(options,GRAPH_ST) )	/* possibly none selected */
		opts.graph=0;

	if ( obj_selected(options,MULTI) )
		opts.multi=1;
	else
		opts.multi=0;

	if ( obj_selected(options,CYCLENONE) )
		opts.cycle=0;
	else if ( obj_selected(options,CYCLEPLAY) )
		opts.cycle=1;
	else
		opts.cycle=2;

	if ( obj_selected(options,TOP_ALL) )
		opts.top=1;
	else
		opts.top=0;

	if ( obj_selected(options,ALERT) )
		opts.alert=1;
	else
		opts.alert=0;
}

void get_user_keys(void)
{
int x,y,w,h;

	wind_update(BEG_MCTRL);
	wind_update(BEG_UPDATE);

	strcpy(obj_spec(user_keys,KEYS_TXT),"Left");
	form_center(user_keys,&x,&y,&w,&h);
	objc_draw(user_keys,0,10,x,y,w,h);
	opts.left=xget_key();

	strcpy(obj_spec(user_keys,KEYS_TXT),"Right");
	form_center(user_keys,&x,&y,&w,&h);
	objc_draw(user_keys,0,10,x,y,w,h);
	opts.right=xget_key();

	strcpy(obj_spec(user_keys,KEYS_TXT),"Rotate");
	form_center(user_keys,&x,&y,&w,&h);
	objc_draw(user_keys,0,10,x,y,w,h);
	opts.rotate=xget_key();

	strcpy(obj_spec(user_keys,KEYS_TXT),"Rotate ccw");
	form_center(user_keys,&x,&y,&w,&h);
	objc_draw(user_keys,0,10,x,y,w,h);
	opts.rot_ccw=xget_key();

	strcpy(obj_spec(user_keys,KEYS_TXT),"Drop");
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
		obj_unselect(options,r);
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
		send_puffer=Mxalloc(256,0x0022);
		if ( send_puffer==(char*)-32 )
			send_puffer=Malloc(256);
	}
	return send_puffer;
}

int av_send(int msg_typ,int d1,int d2,char *str1,int s2,char *str2)
{
int msg[8];
char *puf;

	if ( av_id<0 || (msg_typ==AV_SENDKEY && !(av_state&1)) ||
		 ((msg_typ==AV_ACCWINDOPEN || msg_typ==AV_ACCWINDCLOSED) && !(av_state&64)) ||
		 (msg_typ==AV_EXIT && !(av_state&1024))
		)	return 0;

	if ( str1 || str2 ) {
		puf=get_send_puffer();
		if ( !puf )
			return 0;
		if ( str1 )
			strcpy(puf,str1);
		if ( str2 )
			strcpy(puf+128,str2);
	}

	msg[0]=msg_typ;
	msg[1]=ap_id;
	msg[2]=0;
	msg[3]=msg[4]=msg[5]=msg[6]=msg[7]=0;

	if ( str1 ) {
		*(char**)&msg[3]=puf;
	}
	else {
		msg[3]=d1;
		msg[4]=d2;
	}
	if ( str2 ) {
		if ( s2!=5 && s2!=6 )
			s2=5;
		*(char**)&msg[s2]=puf+128;
	}
	appl_write(av_id,16,msg);
	return 1;
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
	av_send(AV_PROTOKOLL,2,0,0l,6,"COLTRIS ");
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

	init play-window...

------------------------------------------------------------------------------*/
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
	if ( *x<pos[0]->desk_x )
		*x=pos[0]->desk_x;
	else if ( *x>pos[0]->desk_x+pos[0]->desk_w-32 )
		*x=pos[0]->desk_x+pos[0]->desk_w-32;
	if ( *y<pos[0]->desk_y )
		*y=pos[0]->desk_y;
	else if ( *y>pos[0]->desk_y+pos[0]->desk_h-32 )
		*y=pos[0]->desk_y+pos[0]->desk_h-32;
}

void init_window(int *x_x,int *y_y,int *w_w,int *h_h)
{
int x,y,w,h,xx,yy,ww,hh;
int height;

	width=game->block_w*game->game_width;
	height=game->block_h*game->game_height;

	wind_calc(WC_BORDER,WIND_XELEMENTS,pos[opts.play_mode]->wind_pos[W_PLAY].x,pos[opts.play_mode]->wind_pos[W_PLAY].y,width,height,&x,&y,&w,&h);
	check_windpos(&x,&y);
	wind_calc(WC_WORK,WIND_XELEMENTS,x,y,w,h,&xx,&yy,&ww,&hh);
	xx&=~15;
	wind_calc(WC_BORDER,WIND_XELEMENTS,xx,yy,ww,hh,&x,&y,&w,&h);
	*x_x=x;
	*y_y=y;
	*w_w=w;
	*h_h=h;

	init_buffer(width,height);
	source_width=game->source_width*2;	/* game->source_width ist breite fÅr block in pixel
											-> *16 (bloecke) / 8 fÅr byte */

	init_copy_out();
}

int open_window(void)
{
int x,y,w,h,dummy;

	wind[W_PLAY].handle=wind_create(WIND_XELEMENTS,0,0,screen_w,screen_h);
	if ( wind[W_PLAY].handle<0 )
		return 0;
	init_window(&x,&y,&w,&h);
	if ( opts.play_mode==PM_COLUMNS )
		wind_set(wind[W_PLAY].handle,WF_NAME," Columns ");
	else
		wind_set(wind[W_PLAY].handle,WF_NAME," Tetris ");
	wind_open(wind[W_PLAY].handle,x,y,w,h);
	if ( opts.cycle )
		av_send(AV_ACCWINDOPEN,wind[W_PLAY].handle,0,0l,0,0l);
	wind_get(wind[W_PLAY].handle,WF_WORKXYWH,&pos[opts.play_mode]->wind_pos[W_PLAY].x,&pos[opts.play_mode]->wind_pos[W_PLAY].y,&dummy,&dummy);
	return 1;
}


void close_window(void)
{
	wind_close(wind[W_PLAY].handle);
	wind_delete(wind[W_PLAY].handle);
	av_send(AV_ACCWINDCLOSED,wind[W_PLAY].handle,0,0l,0,0l);
	wind[W_PLAY].handle=-1;
}

int reopen_window(void)
{
 	if ( wind[W_STATISTIC].handle!=-1 )
		redraw_statistic(0l);
	close_window();
	return open_window();
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

void _redraw_icon(int window_handle,int *clip,OBJECT *icon_tree,int icon_nr)
{
int x,y,w,h;

	wind_get(window_handle,WF_WORKXYWH,&x,&y,&w,&h);
	icon_tree->ob_x=x;
	icon_tree->ob_y=y;
	icon_tree[icon_nr].ob_x=(w-icon_tree[icon_nr].ob_width)/2;
	icon_tree[icon_nr].ob_y=(h-icon_tree[icon_nr].ob_height)/2;

	wind_get(window_handle,WF_FIRSTXYWH,&x,&y,&w,&h);
	while ( w!=0 ) {
		if ( check_recs(clip[0],clip[1],clip[2],clip[3],&x,&y,&w,&h) )
			objc_draw(icon_tree,0,MAX_DEPTH,x,y,w,h);
		wind_get(window_handle,WF_NEXTXYWH,&x,&y,&w,&h);
	}
}

void redraw_play(int *message)
{
int m[8];
int xy[8];
int x,y,w,h,_w;
int xo,yo,ww,hh;
int hide=0;
int iconified,dummy;

	if ( !message ) {
		m[3]=wind[W_PLAY].handle;
		m[4]=m[5]=0;
		m[6]=screen_w;
		m[7]=screen_h;
		message=m;
	}

	wind_update(BEG_UPDATE);

	if ( aes_iconify )
		my_wind_get(message[3],WF_ICONIFY,&iconified,&w,&h,&dummy);
	else
		iconified=0;

	if ( iconified ) {
		_redraw_icon(message[3],message+4,icon,icon_nr);
	}
	else {
		wind_get(message[3],WF_WORKXYWH,&xo,&yo,&ww,&hh);
		check_recs(0,0,screen_w,screen_h,&xo,&yo,&ww,&hh);
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
	}
	wind_update(END_UPDATE);
}

void do_endgame(void)
{
}

void set_wind_pos(int handle,WIND_POS *pos)
{
int dummy,x,y,w,h;

	wind_get(handle,WF_WORKXYWH,&dummy,&dummy,&w,&h);
	wind_calc(WC_BORDER,WIND_ELEMENTS,pos->x,pos->y,w,h,&x,&y,&w,&h);
	check_windpos(&x,&y);
	wind_set(handle,WF_CURRXYWH,x,y,w,h);
}

void set_playmode(PLAY_MODE pm)
{
int x,y,w,h;
GAME_OPTS *go;

	if ( opts.play_mode==pm )
		return;

	opts.play_mode=pm;
	if ( pm==PM_TETRIS ) {
		menu_icheck(menue,M_TETRIS,1);
		menu_icheck(menue,M_COLUMNS,0);
		obj_hide(stat,C_STAT);
		obj_unhide(stat,TSTAT);
		wind_set(wind[W_PLAY].handle,WF_NAME," Tetris ");
		game=&tetris;
	}
	else {
		menu_icheck(menue,M_TETRIS,0);
		menu_icheck(menue,M_COLUMNS,1);
		obj_unhide(stat,C_STAT);
		obj_hide(stat,TSTAT);
		wind_set(wind[W_PLAY].handle,WF_NAME," Columns ");
		game=&columns;
	}
	go=&opts.opts[opts.play_mode];

	init_window(&x,&y,&w,&h);
	wind_set(wind[W_PLAY].handle,WF_CURRXYWH,x,y,w,h);
	clr_feld();
	if ( go->score!=score_flag )
		set_score();
	else if ( score_flag )
		set_wind_pos(wind[W_SCORE].handle,&pos[pm]->wind_pos[W_SCORE]);

	if ( go->preview!=preview_flag )
		set_preview();
	else if ( preview_flag )
		set_wind_pos(wind[W_PREVIEW].handle,&pos[pm]->wind_pos[W_PREVIEW]);
	if ( go->statistic!=stat_flag )
		set_statistic();
	else if ( stat_flag ) {
		set_wind_pos(wind[W_STATISTIC].handle,&pos[pm]->wind_pos[W_STATISTIC]);
		redraw_statistic(0l);
	}
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
		sprintf(obj_tedstr(score,LEVEL),"%d",level);
		le=1;
	}
	if ( _lines!=lines ) {
		_lines=lines;
		sprintf(obj_tedstr(score,LINES),"%5d",lines);
		li=1;
	}
	sprintf(obj_tedstr(score,STONES),"%5d",stones);
	sprintf(obj_tedstr(score,SCORE),"%5d",sc);

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

int open_score(void)
{
int x,y,w,h,dummy;

	wind[W_SCORE].handle=wind_create(WIND_ELEMENTS,0,0,screen_w,screen_h);
	if ( wind[W_SCORE].handle<0 )
		return 0;
	wind_calc(WC_BORDER,WIND_ELEMENTS,
		pos[opts.play_mode]->wind_pos[W_SCORE].x,
		pos[opts.play_mode]->wind_pos[W_SCORE].y,
		score->ob_width,score->ob_height,&x,&y,&w,&h);
	check_windpos(&x,&y);
	wind_set(wind[W_SCORE].handle,WF_NAME," Score ");
	dr_score(xlevel,xlines,xstones,xscore);
	wind_open(wind[W_SCORE].handle,x,y,w,h);
	if ( opts.cycle==2 )
		av_send(AV_ACCWINDOPEN,wind[W_SCORE].handle,0,0l,0,0l);
	wind_get(wind[W_SCORE].handle,WF_WORKXYWH,&pos[opts.play_mode]->wind_pos[W_SCORE].x,&pos[opts.play_mode]->wind_pos[W_SCORE].y,&dummy,&dummy);
	redraw_score(0l);
	if ( wind[W_PLAY].handle>=0 ) {
		wind_set(wind[W_PLAY].handle,WF_TOP);
		redraw_play(0l);
	}
	return 1;
}


void set_score(void)
{
	if ( score_flag ) {
		wind_close(wind[W_SCORE].handle);
		wind_delete(wind[W_SCORE].handle);
		av_send(AV_ACCWINDCLOSED,wind[W_SCORE].handle,0,0l,0,0l);
		wind[W_SCORE].handle=-1;
	}
	else {
		if ( !open_score() )
			return;
	}
	score_flag=1-score_flag;
	opts.opts[opts.play_mode].score=score_flag;
	menu_icheck(menue,M_SCORE,score_flag);
}

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
			vs_clip(handle,1,xy);
			v_bar(handle,xy);
			if ( in_game ) {
				game->preview();
			}
		}
		wind_get(message[3],WF_NEXTXYWH,&x,&y,&w,&h);
	}
	vs_clip(handle,0,xy);
	if ( hide )
		v_show_c(handle,1);
	wind_update(END_UPDATE);
}

int open_preview(void)
{
int x,y,w,h;
int cw,ch,tw,th,width,height;

	cw=columns.prev_width*columns.block_w;
	ch=columns.prev_height*columns.block_h;
	tw=tetris.prev_width*tetris.block_w;
	th=tetris.prev_height*tetris.block_h;

	width=max(cw,tw);
	height=max(ch,th);

	wind[W_PREVIEW].handle=wind_create(WIND_ELEMENTS,0,0,screen_w,screen_h);
	if ( wind[W_PREVIEW].handle<0 )
		return 0;
	wind_calc(WC_BORDER,WIND_ELEMENTS,pos[opts.play_mode]->wind_pos[W_PREVIEW].x,pos[opts.play_mode]->wind_pos[W_PREVIEW].y,width,height,&x,&y,&w,&h);
	check_windpos(&x,&y);
	wind_set(wind[W_PREVIEW].handle,WF_NAME," Next ");
	wind_open(wind[W_PREVIEW].handle,x,y,w,h);
	if ( opts.cycle==2 )
		av_send(AV_ACCWINDOPEN,wind[W_PREVIEW].handle,0,0l,0,0l);
	wind_get(wind[W_PREVIEW].handle,WF_WORKXYWH,&prev_x,&prev_y,&prev_w,&prev_h);
	pos[opts.play_mode]->wind_pos[W_PREVIEW].x=prev_x;
	pos[opts.play_mode]->wind_pos[W_PREVIEW].y=prev_y;
	redraw_preview(0l);
	if ( wind[W_PLAY].handle>=0 ) {
		wind_set(wind[W_PLAY].handle,WF_TOP);
		redraw_play(0l);
	}
	return 1;
}

void set_preview(void)
{
	if ( preview_flag ) {
		wind_close(wind[W_PREVIEW].handle);
		wind_delete(wind[W_PREVIEW].handle);
		av_send(AV_ACCWINDCLOSED,wind[W_PREVIEW].handle,0,0l,0,0l);
		wind[W_PREVIEW].handle=-1;
	}
	else {
		if ( !open_preview() )
			return;
	}
	preview_flag=1-preview_flag;
	opts.opts[opts.play_mode].preview=preview_flag;
	menu_icheck(menue,M_PREVIEW,preview_flag);
}

void redraw_statistic(int *message)
{
int m[8];
int dummy;
int x,y,w,h,xy[4];
int st_x,st_y,st_dy;
int hide=0;

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

	/*st_x=x-8;*/
	if ( opts.play_mode==PM_TETRIS ) {
		objc_offset(stat,TSTAT0,&st_x,&st_y);
		y=st_y+stat[TSTAT0].ob_height/2;
		objc_offset(stat,TSTAT0+1,&w,&h);
		h+=stat[TSTAT0+1].ob_height/2;
	}
	else {
		objc_offset(stat,CSTAT0,&st_x,&st_y);
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
			game->dr_stat(st_x,st_y,st_dy);
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
			sprintf(obj_tedstr(stat,o),"%3d",nstat[i]);

			if ( stat_flag ) {
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
}

int open_stat(void)
{
int x,y,w,h,dummy;

	wind[W_STATISTIC].handle=wind_create(WIND_ELEMENTS,0,0,screen_w,screen_h);
	if ( wind[W_STATISTIC].handle<0 )
		return 0;
	wind_calc(WC_BORDER,WIND_ELEMENTS,
		pos[opts.play_mode]->wind_pos[W_STATISTIC].x,pos[opts.play_mode]->wind_pos[W_STATISTIC].y,
		stat->ob_width,stat->ob_height,&x,&y,&w,&h);
	check_windpos(&x,&y);
	wind_set(wind[W_STATISTIC].handle,WF_NAME," Stat. ");
	wind_open(wind[W_STATISTIC].handle,x,y,w,h);
	if ( opts.cycle==2 )
		av_send(AV_ACCWINDOPEN,wind[W_STATISTIC].handle,0,0l,0,0l);
	wind_get(wind[W_STATISTIC].handle,WF_WORKXYWH,&pos[opts.play_mode]->wind_pos[W_STATISTIC].x,&pos[opts.play_mode]->wind_pos[W_STATISTIC].y,&dummy,&dummy);
	redraw_statistic(0l);
	if ( wind[W_PLAY].handle>=0 ) {
		wind_set(wind[W_PLAY].handle,WF_TOP);
		redraw_play(0l);
	}
	return 1;
}

void set_statistic(void)
{
	if ( stat_flag ) {
		wind_close(wind[W_STATISTIC].handle);
		wind_delete(wind[W_STATISTIC].handle);
		av_send(AV_ACCWINDCLOSED,wind[W_STATISTIC].handle,0,0l,0,0l);
		wind[W_STATISTIC].handle=-1;
	}
	else {
		if ( !open_stat() )
			return;
	}
	stat_flag=1-stat_flag;
	opts.opts[opts.play_mode].statistic=stat_flag;
	menu_icheck(menue,M_STATISTIC,stat_flag);
}


void redraw_icon(int *msg)
{
	wind_update(BEG_UPDATE);
	_redraw_icon(msg[3],msg+4,icon,icon_nr);
	wind_update(END_UPDATE);
}

typedef struct {
	int x,y,w,h;			/* BORDER */
} WIND_DATA;
WIND_DATA iconified_data[4];

int init_iconify(EVENT *event)	/* event nur bei aes-iconify nîtig */
{
int x,y,w,h;
int first;
WINDOWS wi;

	if ( !aes_iconify ) {
		if ( iconified_handle!=-1 )
			return -1;

		iconified_pos=(*iconify_server)(ICF_GETPOS,&x,&y,&w,&h);
		if ( iconified_pos<=0 )
			return -1;			/* war wohl nix */
		first=0;
	}
	else {
		wind_get(wind[W_PLAY].handle,WF_CURRXYWH,&iconified_data[W_PLAY].x,&iconified_data[W_PLAY].y,&iconified_data[W_PLAY].w,&iconified_data[W_PLAY].h);
		my_wind_set(wind[W_PLAY].handle,WF_ICONIFY,event->ev_mmgpbuf[4],event->ev_mmgpbuf[5],event->ev_mmgpbuf[6],event->ev_mmgpbuf[7]);
		first=1;	/* play-window nicht schlieûen */
	}

	for ( wi=first; wi<WIND_ANZ; wi++ ) {
		if ( wind[wi].handle>=0 ) {
			wind_get(wind[wi].handle,WF_CURRXYWH,&iconified_data[wi].x,&iconified_data[wi].y,&iconified_data[wi].w,&iconified_data[wi].h);
			wind_close(wind[wi].handle);
			wind_delete(wind[wi].handle);
			av_send(AV_ACCWINDCLOSED,wind[wi].handle,0,0l,0,0l);
			wind[wi].handle=-2;
		}
	}

	if ( !aes_iconify ) {
		iconified_handle=wind_create(NAME|MOVER,x,y,w,h);
		if ( iconified_handle<0 )
			return -2;			/* BIG TROUBLE */

		wind_set(iconified_handle,WF_NAME," WinColTris ");
		wind_open(iconified_handle,x,y,w,h);
	}

	if ( opts.play_mode==PM_COLUMNS ) {
		icon_nr=ICON_COLUMNS;
		obj_hide(icon,ICON_TETRIS);
	}
	else {
		icon_nr=ICON_TETRIS;
		obj_hide(icon,ICON_COLUMNS);
	}
	obj_unhide(icon,icon_nr);

	return 0;
}

int is_iconified(void)
{
int iconified,dummy;

	if ( !aes_iconify )
		return iconified_handle>=0;
	else {
		my_wind_get(wind[W_PLAY].handle,WF_ICONIFY,&iconified,&dummy,&dummy,&dummy);
		return iconified!=0;
	}
}

int exit_iconify(void)
{
WINDOWS wi;
int first;

	if ( !is_iconified() )
		return -1;

	if ( !aes_iconify ) {
		wind_close(iconified_handle);
		wind_delete(iconified_handle);
		(*iconify_server)(ICF_FREEPOS,iconified_pos);
		iconified_handle=-1;
		first=0;
	}
	else {
		first=1;
	}
	for ( wi=WIND_ANZ-1; wi>=first; wi-- ) {
		if ( wind[wi].handle==-2 ) {
			wind[wi].handle=wind_create(WIND_ELEMENTS,0,0,screen_w,screen_h);
			if ( wind[wi].handle<0 )
				return -2;
			switch ( wi ) {
			  case W_PLAY:
				if ( opts.play_mode==PM_COLUMNS )
					wind_set(wind[W_PLAY].handle,WF_NAME," Columns ");
				else
					wind_set(wind[W_PLAY].handle,WF_NAME," Tetris ");
			  break;
			  case W_SCORE:
				wind_set(wind[W_SCORE].handle,WF_NAME," Score ");
			  break;
			  case W_PREVIEW:
				wind_set(wind[W_PREVIEW].handle,WF_NAME," Preview ");
			  break;
			  case W_STATISTIC:
				wind_set(wind[W_STATISTIC].handle,WF_NAME," Stat. ");
			  break;
			}
			wind_open(wind[wi].handle,iconified_data[wi].x,iconified_data[wi].y,iconified_data[wi].w,iconified_data[wi].h);
			if ( (wi==W_PLAY && opts.cycle) || opts.cycle==2 )
				av_send(AV_ACCWINDOPEN,wind[wi].handle,0,0l,0,0l);
		}
	}

	if ( aes_iconify )
		my_wind_set(wind[W_PLAY].handle,WF_UNICONIFY,iconified_data[W_PLAY].x,iconified_data[W_PLAY].y,iconified_data[W_PLAY].w,iconified_data[W_PLAY].h);

	return 0;
}


/*------------------------------------------------------------------------------

	spiel aufrufen

------------------------------------------------------------------------------*/
void do_play(void)
{
int dummy,gret;
int preview,score,statistic;
WINDOWS w;

	menu_tnormal(menue,MT_FILE,1);
	menu_ienable(menue,M_QUIT,0);
	menu_ienable(menue,M_ABORT,0);
	menu_ienable(menue,M_START,0);
	menu_ienable(menue,M_TETRIS,0);
	menu_ienable(menue,M_COLUMNS,0);
 	menu_ienable(menue,M_OPTS,0);
 	menu_ienable(menue,M_STONES,0);
	
	if ( !opts.multi ) {
		v_hide_c(handle);
		wind_update(BEG_MCTRL);
		wind_update(BEG_UPDATE);
	}
	if ( opts.top ) {
		for ( w=WIND_ANZ-1; w>=0; w-- ) {
			if ( wind[w].handle>=0 ) {
				wind_set(wind[w].handle,WF_TOP);
				wind[w].redraw(0l);
			}
		}
	}
	else {
		wind_set(wind[W_PLAY].handle,WF_TOP);
		redraw_play(0l);
	}

	preview=preview_flag;
	score=score_flag;
	statistic=stat_flag;

	clr_feld();

	if ( preview_flag )
		wind_get(wind[W_PREVIEW].handle,WF_WORKXYWH,&prev_x,&prev_y,&prev_w,&prev_h);
	wind_get(wind[W_PLAY].handle,WF_WORKXYWH,&x_off,&y_off,&dummy,&dummy);

	init_copy_out();

	in_game=1;
#if SOUND_LEVEL>0
	do_sound(S_START);
#endif

	gret=game->play();

#if SOUND_LEVEL>0
	do_sound(S_GAMEOVER);
#endif
	in_game=0;

	if ( !gret ) {	/* spielabbruch -> loesche spielfeld */
		clr_feld();
#if SOUND_LEVEL>0
	do_sound(S_ABORT);
#endif
	}
	else {
		do_score(gret,opts.hiscore[opts.play_mode]);
		do_endgame();
	}
	if ( preview!=preview_flag )
		set_preview();
	else if ( preview_flag )
		redraw_preview(0l);
	if ( score!=score_flag )
		set_score();
	if ( statistic!=stat_flag )
		set_statistic();

	menu_ienable(menue,M_QUIT,1);
	menu_ienable(menue,M_ABORT,1);
	menu_ienable(menue,M_START,1);
	if ( tetris.vdi!=-1 )
		menu_ienable(menue,M_TETRIS,1);
	if ( columns.vdi!=-1 )
		menu_ienable(menue,M_COLUMNS,1);
	menu_ienable(menue,M_OPTS,1);
	menu_ienable(menue,M_STONES,1);

	if ( !opts.multi ) {
		wind_update(END_MCTRL);
		wind_update(END_UPDATE);
		v_show_c(handle,1);
	}
}

/*------------------------------------------------------------------------------

	programm-info ausgeben

------------------------------------------------------------------------------*/
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
	obj_unselect(info,r);
}

/*------------------------------------------------------------------------------

	menu-handler

------------------------------------------------------------------------------*/
int do_menue(int titel,int entry)
{
int ret=0;

	if ( obj_state(menue,entry)&DISABLED )
		return 0;

	if ( is_iconified() && entry!=M_QUIT && entry!=M_ABORT && entry!=M_INFO && entry!=M_OPTS && entry!=M_HISCORE && entry!=M_SCORE ) {
		if ( exit_iconify()<-1 )
			return -1;
	}
	
	switch ( entry ) {
	  case M_INFO:		prog_info();		break;
	  case M_START:		do_play();			break;
	  case M_HISCORE:	show_hiscore();		break;
	  case M_QUIT:		save_options();ret=1;break;
	  case M_ABORT:		ret=2;				break;
	  case M_TETRIS:	set_playmode(PM_TETRIS);break;
	  case M_COLUMNS:	set_playmode(PM_COLUMNS);break;
	  case M_SCORE:		set_score();		break;
	  case M_PREVIEW:	set_preview();		break;
	  case M_STATISTIC:	set_statistic();	break;
	  case M_OPTS:		do_options();		break;
	  case M_STONES:	change_stones();	break;
	}
	if ( titel )
		menu_tnormal(menue,titel,1);
	return ret;
}

/*------------------------------------------------------------------------------

	event-schleife

------------------------------------------------------------------------------*/
WINDOWS get_window(int handle)
{
WINDOWS w;

	for ( w=0; w<WIND_ANZ; w++ )
		if ( handle==wind[w].handle )
			return w;
	return -1;									/* hmm, should not happen */
}

int do_control(int flag)
{
int dummy;
WINDOWS w;
EVENT event;
int evnt,i;
int key,ret;

	if ( flag<=0 ) {
		event.ev_mflags=MU_MESAG|MU_KEYBD;
	}
	else if ( flag>0 ) {
		event.ev_mflags=MU_MESAG|MU_TIMER;
		event.ev_mtlocount=flag;
		event.ev_mthicount=0;
	}
	while ( 1 ) {
		if ( iconified_handle>=0 ) {
			event.ev_mflags|=MU_BUTTON;
			event.ev_mbclicks=event.ev_bmask=event.ev_mbstate=1;
		}
		else {
			event.ev_mflags&=~MU_BUTTON;
		}
		evnt=EvntMulti(&event);

		if ( evnt==MU_TIMER )
			return 0;
		if ( evnt&MU_BUTTON ) {
			if ( wind_find(event.ev_mmox,event.ev_mmoy)==iconified_handle )
				if ( exit_iconify()<-1 )
					return 1;
		}
		if ( evnt&MU_KEYBD ) {
			if ( flag<0 )
				return 0;

			key=*(char*)&event.ev_mkreturn;
			event.ev_mmokstate&=~(K_LSHIFT|K_RSHIFT);
			for ( i=0; i<(int)(sizeof(commands)/sizeof(commands[0])); i++ ) {
				if ( key==commands[i].key && event.ev_mmokstate==commands[i].state ) {
					ret=do_menue(0,commands[i].entry);
					if ( ret==-1 )
						return 1;
					else if ( ret )
						return 0;
					break;
				}
			}
			if ( i==(int)(sizeof(commands)/sizeof(commands[0])) )
				av_send(AV_SENDKEY,event.ev_mmokstate,event.ev_mkreturn,0l,0,0l);
		}
		else if ( evnt&MU_MESAG ) {
			switch ( event.ev_mmgpbuf[0] ) {
			  case MN_SELECTED:
			  	ret=do_menue(event.ev_mmgpbuf[3],event.ev_mmgpbuf[4]);
				if ( ret==-1 )
					return 1;
				else if ( ret )
					return 0;
			  break;
			  case WM_REDRAW:
			  	w=get_window(event.ev_mmgpbuf[3]);
			  	if ( w!=W_ERROR )
					wind[w].redraw(event.ev_mmgpbuf);
				else if ( event.ev_mmgpbuf[3]==iconified_handle )
					redraw_icon(event.ev_mmgpbuf);
			  break;
			  case WM_TOPPED:
		  		wind_set(event.ev_mmgpbuf[3],WF_TOP);
			  break;
			  case WM_MOVED:
				w=get_window(event.ev_mmgpbuf[3]);
				if ( w==W_PLAY && !is_iconified() ) {
				  int x,y,w,h;
			  		wind_calc(WC_WORK,WIND_ELEMENTS,event.ev_mmgpbuf[4],event.ev_mmgpbuf[5],event.ev_mmgpbuf[6],event.ev_mmgpbuf[7],&x,&y,&w,&h);
		  			x&=~15;
			  		wind_calc(WC_BORDER,WIND_ELEMENTS,x,y,w,h,event.ev_mmgpbuf+4,event.ev_mmgpbuf+5,event.ev_mmgpbuf+6,event.ev_mmgpbuf+7);
				}
			    wind_set(event.ev_mmgpbuf[3],WF_CURRXYWH,event.ev_mmgpbuf[4],event.ev_mmgpbuf[5],event.ev_mmgpbuf[6],event.ev_mmgpbuf[7]);
				if ( w!=W_ERROR ) {
					if ( !(w==W_PLAY && is_iconified()) )
						wind_get(event.ev_mmgpbuf[3],WF_WORKXYWH,&pos[opts.play_mode]->wind_pos[w].x,&pos[opts.play_mode]->wind_pos[w].y,&dummy,&dummy);
					if ( w==W_PREVIEW )
						wind_get(wind[W_PREVIEW].handle,WF_WORKXYWH,&prev_x,&prev_y,&prev_w,&prev_h);
					if ( w==W_PLAY && !is_iconified() )
						wind_get(wind[W_PLAY].handle,WF_WORKXYWH,&x_off,&y_off,&dummy,&dummy);
				}
			  break;
			  case WM_ICONIFY:
			  case WM_ALLICONIFY:
				init_iconify(&event);
			  break;
			  case WM_UNICONIFY:
			  	exit_iconify();
			  break;
			  case WM_CLOSED:
				w=get_window(event.ev_mmgpbuf[3]);
				if ( w!=W_ERROR ) {
					if ( iconify_server!=0l && event.ev_mmokstate&(K_ALT|K_LSHIFT|K_RSHIFT|K_CTRL) ) {
						if ( flag>0 )
							break;
						if ( init_iconify(0l)<-1 )
							return 1;
					}
					else if ( !(flag && w==W_PLAY) ) {
					  	if ( w==W_PLAY )
					  		return 0;
					  	wind[w].close();
					}
				}
			  break;
			}
		}
	}
}


/*------------------------------------------------------------------------------

	initialisierung

------------------------------------------------------------------------------*/
typedef struct
{
	long id;
	long value;
} COOKJAR;

static long _get_cookjar(void)
{
	return *(long*)0x05a0l;
}

long get_cookie(long cookie)
{
COOKJAR	*cookiejar;
int	i = 0;

	cookiejar=(COOKJAR*)Supexec(_get_cookjar);

	if ( cookiejar ) {
		while ( cookiejar[i].id ) {
			if ( cookiejar[i].id==cookie )
				return cookiejar[i].value;
			i++;
		}
	}
	return 0l;
}

OBJECT *scale_tree(int index)
{
OBJECT *tree;

	tree=rs_trindex[index];
	do {
		rsrc_obfix(tree,0);
	} while ( !(tree++->ob_flags&LASTOB) );
	return rs_trindex[index];
}

void init_pos(void)
{
int i,j;
int width,height;
int desk_x,desk_y,desk_w,desk_h;
long h;
WINDOWS w;


	wind_get(0,WF_WORKXYWH,&desk_x,&desk_y,&desk_w,&desk_h);

	for ( j=0; j<2; j++ ) {
		if ( j==PM_TETRIS ) {
			width=tetris.block_w*tetris.game_width;
			height=tetris.block_h*tetris.game_height;
		}
		else {
			width=columns.block_w*columns.game_width;
			height=columns.block_h*columns.game_height;
		}

		for ( i=0; i<POSITIONS; i++ ) {
			pos[j]=&opts.pos[j][i];
			if ( pos[j]->desk_x==desk_x && pos[j]->desk_y==desk_y && pos[j]->desk_w==desk_w && pos[j]->desk_h==desk_h && pos[j]->width==width && pos[j]->height==height )
				break;
		}
		if ( i==POSITIONS ) {
			for ( i=POSITIONS-1; i>0; i-- )
				opts.pos[j][i]=opts.pos[j][i-1];
			pos[j]=&opts.pos[j][0];
			for ( w=0; w<WIND_ANZ; w++ ) {
				h=(long)(pos[j]->wind_pos[w].x-pos[j]->desk_x)*desk_w;
				pos[j]->wind_pos[w].x=(int)(h/pos[j]->desk_w)+desk_x;
				h=(long)(pos[j]->wind_pos[w].y-pos[j]->desk_y)*desk_h;
				pos[j]->wind_pos[w].y=(int)(h/pos[j]->desk_h)+desk_y;
			}
			pos[j]->desk_x=desk_x;
			pos[j]->desk_y=desk_y;
			pos[j]->desk_w=desk_w;
			pos[j]->desk_h=desk_h;
			pos[j]->width=width;
			pos[j]->height=height;
		}
	}
}

int do_init(void)
{
int i,f_id;
int p_handle,dummy,work_in[11],work_out[57];

	ap_id=appl_init();

	if ( _GemParBlk.global[0]>=0x400 || !appl_find("?AGI") ) {
	  int o1,o2,o3,o4;
		appl_getinfo(11,&o1,&o2,&o3,&o4);
		if ( (o1&0x0180)==0x0180 )
			aes_iconify=1;
	}
	av_init();

	if ( !aes_iconify )
		iconify_server=(void*)get_cookie('ICFS');

		/* init resources */
	menue	=	scale_tree(MENUE);
	score	=	scale_tree(XSCORE);
	stat	=	scale_tree(STATISTIC);
	options	=	scale_tree(OPTSBOX);
	info	=	scale_tree(INFOBOX);
	user_keys=	scale_tree(KEYS);
	hiscore	=	scale_tree(HISCORE);
	hi_name	=	scale_tree(NEWHI);
	icon	=	scale_tree(ICON);

	obj_spec(info,I_COMPDATE)=__DATE__;
	*obj_tedstr(hi_name,HI_NAME)=0;

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


		/* init vdi */
	p_handle=graf_handle(&dummy,&dummy,&dummy,&dummy);
	for ( i=0; i<10; i++ )
		work_in[i]=1;
	work_in[10]=2;
	handle=p_handle;
	v_opnvwk(work_in,&handle,work_out);
	graf_mouse(0,0);

	screen_w=work_out[0]+1;
	screen_h=work_out[1]+1;

	vq_extnd(handle,1,work_out);
	planes=work_out[4];
	if ( planes==1 )
		planes_nr=0;
	else if ( planes==2 )
		planes_nr=1;
	else if ( planes==4 )
		planes_nr=2;
	else if ( planes==8 )
		planes_nr=3;
	else					/* hmm, big trouble... */
		return 0;

	vswr_mode(handle,MD_REPLACE);
	vsf_interior(handle,FIS_PATTERN);
	vsf_perimeter(handle,0);

	vst_color(handle,0);
	vst_height(handle,20,&dummy,&dummy,&dummy,&dummy);
	/*vst_effects(handle,16);*/
	vst_alignment(handle,1,1,&dummy,&dummy);

	av_getproto();

	return 1;
}

void do_exit(int ret)
{
WINDOWS w;

	wind_update(BEG_UPDATE);
	if ( ret==1 )
		form_error(8);
	else if ( ret==2 )
		form_alert(1,"[1][ | Missing or incorrect | | Image-Files! | ][ Exit ]");
	else if ( ret==3 )
		form_alert(1,"[1][ | Unable to open window! | ][ Exit ]");
	else if ( ret==4 )
		form_alert(1,"[1][ | Unsupported resolution! | ][ Exit ]");
	else if ( ret!=0 )
		form_alert(1,"[1][ | Something went wrong! | ][ Exit ]");
	wind_update(END_UPDATE);

	for ( w=0; w<WIND_ANZ; w++ ) {
		if ( wind[w].handle>=0 ) {
			wind_close(wind[w].handle);
			wind_delete(wind[w].handle);
			av_send(AV_ACCWINDCLOSED,wind[w].handle,0,0l,0,0l);
		}
	}
	if ( iconified_handle>=0 ) {
		wind_close(iconified_handle);
		wind_delete(iconified_handle);
		(*iconify_server)(ICF_FREEPOS,iconified_pos);
	}

	v_clsvwk(handle);
	av_send(AV_EXIT,0,0,0l,0,0l);
	appl_exit();
	if ( buffer_addr )
		free((void*)buffer_addr);

	exit(ret);
}

void main(int argc,char *argv[])
{
int ret;

	if ( !do_init() )
		do_exit(4);

#if SOUND_LEVEL>0
	init_sound(argc,argv);
#endif

	if ( !init_image(&columns,opts.stone_file[PM_COLUMNS][planes_nr],argc,argv) )
		if ( !init_image(&columns,"COLUMNS1.IMG",0,0l) )
			menu_ienable(menue,M_COLUMNS,0);
	if ( !init_image(&tetris,opts.stone_file[PM_TETRIS][planes_nr],argc,argv) )
		if ( !init_image(&columns,"TETRIS1.IMG",0,0l) )
			menu_ienable(menue,M_TETRIS,0);

	if ( obj_state(menue,M_COLUMNS)&DISABLED && obj_state(menue,M_TETRIS)&DISABLED )
		do_exit(2);

	if ( opts.play_mode==PM_COLUMNS && !(obj_state(menue,M_COLUMNS)&DISABLED) ) {
		menu_icheck(menue,M_COLUMNS,1);
		obj_unhide(stat,C_STAT);
		obj_hide(stat,TSTAT);
		game=&columns;
	}
	else {
		menu_icheck(menue,M_TETRIS,1);
		obj_hide(stat,C_STAT);
		obj_unhide(stat,TSTAT);
		opts.play_mode=PM_TETRIS;
		game=&tetris;
	}

	init_pos();

	menu_bar(menue,1);

	if ( opts.opts[opts.play_mode].score )
		set_score();
	if ( opts.opts[opts.play_mode].preview )
		set_preview();
	if ( opts.opts[opts.play_mode].statistic )
		set_statistic();
	if ( !open_window() )
		do_exit(3);

	do {
		ret=do_control(0);
		if ( !ret ) {
			if ( opts.alert ) {
				wind_update(BEG_UPDATE);
				ret=form_alert(2,"[0][ |       See you...       | ][ Cancel |Ok]")!=1;
				wind_update(END_UPDATE);
			}
			else
				ret=1;
		}
		else {
			wind_update(BEG_UPDATE);
			form_alert(1,"[0][ | Something went wrong... | | See you... | ][ Cancel ]");
			wind_update(END_UPDATE);
		}
	} while ( !ret  );

	do_exit(0);
}
