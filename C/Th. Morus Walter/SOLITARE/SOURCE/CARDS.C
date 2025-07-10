#include <tos.h>
#include <gem.h>
#include <vdi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <image.h>
#include <vaproto.h>
int ap_id,av_id=-1;
int av_state;

#include "card.h"
#include "card.rsh"

int CARD_HEIGHT	=	92;
int	CARD_WIDTH	=	64;
int CARD_DIST	=	16;

int WIND_WIDTH	=	640;
int WIND_HEIGHT	=	366;

OBJECT *menue,*infobox;

#define BORDER		NAME|CLOSER|MOVER		/* fenster elemente */

int wi_handle=-1,wind_x,wind_y;
int handle;

int draw_flag;

MFDB picture;
MFDB screen={0l};

typedef struct {
	int state;
	int key;
	int titel;
	int entry;
} KEY;

KEY keys[]={
	K_CTRL,	0x17,	MT_DESK,  M_PRGINFO,
	K_CTRL,	0x31,	MT_DATEI, M_NEU,
	0,		0x3F,	MT_DATEI, M_NEU,
	K_CTRL,	0x10,	MT_DATEI, M_QUIT,
	0,		0x61,	MT_EDIT,  M_UNDO,
	K_CTRL,	0x2D,	MT_EDIT,  M_DRAW,
	K_CTRL,	0x02,	MT_EDIT,  M_MISCHEN,
	K_CTRL,	0x03,	MT_EDIT,  M_MISCHEN2,
	0,		0x40,	MT_EDIT,  M_MISCHEN,
	0,		0x41,	MT_EDIT,  M_MISCHEN2,
	K_CTRL, 0x25,   MT_OPTS,  M_CLASSIC,
	K_CTRL, 0x23,   MT_OPTS,  M_HELP
	};

typedef struct
{
	char color;		/* 0 -> herz, 1 -> karo, 2 -> kreuz, 3 -> pik, 4 -> rÅckseite */
	char number;	/* 0 as, 1 '2' ... */
	char stack;		/* nummer des stapels */
	char top;		/* 1: karte kann angeklickt werden */
	int  x;
	int  y;
} CARD;

typedef struct
{
	char old_pos;
	char old_stack;
	char new_pos;
	char flag;		/* 1 -> karte war herausgezogen */
} MOVE;

#define MAX_MOVES	100
MOVE moves[MAX_MOVES];	/* fÅr undo */
int move;			/* zeiger auf nÑchste pos in moves */

CARD cards[52+4],c2[52+4];
int  cards_left;

void init_cards(void)
{
int i,j;

	for ( i=0; i<4; i++ ) {
		for ( j=0; j<13; j++ ) {
			cards[i*13+j].color=i;
			cards[i*13+j].number=j;
		}
	}
	for ( i=0; i<104; i++ ) {
	  int n1,n2;
	  CARD card;
		n1=(int)((unsigned int)Random()%52);
		n2=(int)((unsigned int)Random()%52);
		card=cards[n1];
		cards[n1]=cards[n2];
		cards[n2]=card;
	}

	cards_left=52;

	for ( i=0; i<4; i++ ) {
		cards[i+4*13].color=i;
		cards[i+4*13].number=255;
		cards[i+4*13].stack=100;
	}
}

void mische_cards(void)
{
int i,j;
int n1,n2;
CARD card;

	for ( i=0; i<cards_left; i++ ) {
		n1=(int)((unsigned int)Random()%cards_left);
		n2=(int)((unsigned int)Random()%cards_left);
		card=cards[n1];
		cards[n1]=cards[n2];
		cards[n2]=card;
	}
	for ( i=j=0; i<52; i++ ) {
		cards[i].stack=j;
		if ( i%3==2 )
			j++;
	}
	move=0;					/* entleere undo-puffer */
}

#define min(a,b)	(a)<(b)?(a):(b)
#define max(a,b)	(a)>(b)?(a):(b)

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

void copy_card(int flag,int clip_x,int clip_y,int clip_w,int clip_h,int card,int color,int x,int y)
{
int xy[8];

	xy[4]=x+wind_x;
	xy[5]=y+wind_y;
	if ( !flag )
		xy[6]=CARD_DIST-1;
	else
		xy[6]=CARD_WIDTH-1;
	xy[7]=CARD_HEIGHT-1;

	if ( check_recs(clip_x,clip_y,clip_w,clip_h,xy+4,xy+5,xy+6,xy+7) ) {
		xy[0]=card*CARD_WIDTH+xy[4]-x-wind_x;
		xy[1]=color*CARD_HEIGHT+xy[5]-y-wind_y;
		if ( card==255 || color==4 ) {
			xy[0]=14*CARD_WIDTH+xy[4]-x-wind_x;
			xy[1]=CARD_HEIGHT+xy[5]-y-wind_y;
		}
		xy[2]=xy[0]+xy[6];
		xy[3]=xy[1]+xy[7];
		xy[6]+=xy[4];
		xy[7]+=xy[5];
		vro_cpyfm(handle,3,xy,&picture,&screen);
	}
}

void show_cards(int flag,int *clip)
{
int i,xy[8];
int x,y;
int wx,wy,ww,wh;

	wind_update(BEG_UPDATE);
	v_hide_c(handle);
	wind_get(wi_handle,WF_FIRSTXYWH,&wx,&wy,&ww,&wh);
	while ( ww!=0 ) {

		if ( clip ) {
			if ( !check_recs(clip[0],clip[1],clip[2],clip[3],&wx,&wy,&ww,&wh) ) {
				wind_get(wi_handle,WF_NEXTXYWH,&wx,&wy,&ww,&wh);
				continue;
			}
		}

		ww--;
		wh--;

		if ( !flag ) {
			xy[0]=wx;	xy[1]=wy;	xy[2]=wx+ww;	xy[3]=wy+wh;
			v_bar(handle,xy);
		}

		screen.fd_addr=0l;

		y=0;
		x=4;

		for ( i=0; i<56; i++ ) {

			if ( cards[i].color==4 )
				continue;

			cards[i].x=x;
			cards[i].y=y;

			if ( cards[i].stack==cards[i+1].stack && cards[i+1].color!=4 )
				copy_card(0,wx,wy,ww,wh,cards[i].number,cards[i].color,x,y);
			else
				copy_card(1,wx,wy,ww,wh,cards[i].number,cards[i].color,x,y);

			if ( cards[i].stack==cards[i+1].stack && cards[i+1].color!=4 ) {
				cards[i].top=0;
				x+=CARD_DIST;
			}
			else {
			  int ii,xx,stack;
				cards[i].top=1;
				xy[0]=x+CARD_WIDTH+wind_x;
				xy[1]=y+wind_y;
				xy[2]=CARD_DIST;
				xy[3]=CARD_HEIGHT;
				if ( check_recs(wx,wy,ww,wh,xy,xy+1,xy+2,xy+3) ) {
					xy[2]+=xy[0];
					xy[3]+=xy[1];
					v_bar(handle,xy);
				}
				x+=CARD_WIDTH+CARD_DIST;
				xx=x;
				ii=i+1;
				while ( cards[ii].color==4 )
					ii++;
				for ( stack=cards[ii].stack; ii<56 && cards[ii].stack==stack && cards[ii].color!=4; ii++ )
					xx+=CARD_DIST;
				if ( xx>WIND_WIDTH-CARD_WIDTH ) {	/* neue zeile */
					xy[0]=x+wind_x;
					xy[1]=y+wind_y;
					xy[2]=WIND_WIDTH-x;
					xy[3]=CARD_HEIGHT;
					if ( check_recs(wx,wy,ww,wh,xy,xy+1,xy+2,xy+3) ) {
						xy[2]+=xy[0];
						xy[3]+=xy[1];
						v_bar(handle,xy);
					}
					x=4; 
					y+=CARD_HEIGHT;
				}
			}
		}
		xy[0]=x+wind_x;
		xy[1]=y+wind_y;
		xy[2]=WIND_WIDTH-x;
		xy[3]=CARD_HEIGHT;
		if ( check_recs(wx,wy,ww,wh,xy,xy+1,xy+2,xy+3) ) {
			xy[2]+=xy[0];
			xy[3]+=xy[1];
			v_bar(handle,xy);
		}
		if ( y+CARD_HEIGHT<WIND_HEIGHT ) {
			xy[0]=wind_x;
			xy[1]=y+CARD_HEIGHT+wind_y;
			xy[2]=WIND_WIDTH;
			xy[3]=WIND_HEIGHT;
			if ( check_recs(wx,wy,ww,wh,xy,xy+1,xy+2,xy+3) ) {
				xy[2]+=xy[0];
				xy[3]+=xy[1];
				v_bar(handle,xy);
			}
		}

		wind_get(wi_handle,WF_NEXTXYWH,&wx,&wy,&ww,&wh);
	}
	v_show_c(handle,0);
	wind_update(END_UPDATE);
}

void inc_move(void)
{
	move++;
	if ( move==MAX_MOVES ) {
		move--;
		memcpy(moves,moves+1,sizeof(moves[0])*(MAX_MOVES-1));
	}
}

void move_card(int new_pos,int card,int stack)
{
int i;
	if ( new_pos<card ) {
		for ( i=0; i<new_pos; i++ ) {
			c2[i]=cards[i];
		}
		c2[i]=cards[card];
		if ( stack==-1 )
			c2[i].stack=c2[i-1].stack;
		else
			c2[i].stack=stack;

		for ( ; i<card; i++ ) {
			c2[i+1]=cards[i];
		}
		for ( i++; i<56; i++ ) {
			c2[i]=cards[i];
		}
	}
	else {
		for ( i=0; i<card; i++ ) {
			c2[i]=cards[i];
		}
		for ( i++; i<new_pos; i++ ) {
			c2[i-1]=cards[i];
		}
		c2[i-1]=cards[card];
		if ( stack==-1 )
			c2[i-1].stack=c2[i-2].stack;
		else
			c2[i-1].stack=stack;
		for ( ; i<56; i++ ) {
			c2[i]=cards[i];
		}
	}
}

int get_card(int x,int y,int flag)
{
int i;

	for ( i=0; i<52; i++ ) {
		if ( cards[i].top==1 &&
				cards[i].x<x && cards[i].x+CARD_WIDTH>x &&
				cards[i].y<y && cards[i].y+CARD_HEIGHT>y ) {
			return i;
		}
		else if ( flag && cards[i].x<x && cards[i].x+CARD_DIST>x &&
				cards[i].y<y && cards[i].y+CARD_HEIGHT>y ) {
			return i;
		}
	}
	return -1;
}

int get_newpos(int card,int all)
{
int i;

	for ( i=52; i<56; i++ ) 		/* karte passt auf ablagestapel */
		if ( cards[i].color==cards[card].color && ((cards[i].number==cards[card].number-1) || (cards[i].number==255 && cards[card].number==0)) )
			return i;
	for ( i=0; i<52; i++ )
		if ( (all || cards[i].top==1) && cards[i].color==cards[card].color &&
				cards[i].number==cards[card].number+1 )
			return i;
	return -1;
}

int do_move(int x,int y)
{
int j;
int card,new_pos;

	x-=wind_x;
	y-=wind_y;

	new_pos=-1;

	card=get_card(x,y,draw_flag);
	if ( card==-1 )
		return 0;

	moves[move].old_pos=card;
	moves[move].old_stack=cards[card].stack;
	if ( !cards[card].top )
		moves[move].flag=1;
	else
		moves[move].flag=0;

	new_pos=get_newpos(card,0);
	if ( new_pos==-1 )
		return 0;
	else if ( new_pos>=52 ) {		/* karte passt auf ablagestapel */
		for ( j=0; j<card; j++ ) 
			c2[j]=cards[j];
		for ( j++; j<52; j++ )
			c2[j-1]=cards[j];
		c2[51].color=4;
		for ( j=52; j<56; j++ )
			c2[j]=cards[j];
		moves[move].new_pos=new_pos;
		c2[new_pos].number=cards[card].number;
		cards_left--;
	}
	else {							/* karte hat nicht auf ablagestapel gepasst */
		new_pos++;
		moves[move].new_pos=new_pos;
		if ( card<new_pos ) {
			moves[move].new_pos--;
		}
		else {
			moves[move].old_pos++;
		}
		move_card(new_pos,card,-1);
	}

	if ( moves[move].flag ) {		/* karte war herausgezogen */
		objc_disabled(menue,M_DRAW);
	}
	draw_flag=0;

	inc_move();
	memcpy(cards,c2,sizeof(cards));
	show_cards(1,0l);
	return 1;
}

void draw_card_rec(int i)
{
int xy[4];

	xy[0]=cards[i].x+wind_x;
	xy[1]=cards[i].y+wind_y+1;
	if ( cards[i].top )
		xy[2]=xy[0]+CARD_WIDTH-1;
	else
		xy[2]=xy[0]+CARD_DIST;
	xy[3]=xy[1]+CARD_HEIGHT-3;
	v_bar(handle,xy);
}

void show_move(int x,int y)
{
int i,card;
int dummy;

	x-=wind_x;
	y-=wind_y;

	card=get_card(x,y,1);

	vswr_mode(handle,MD_XOR);
	wind_update(BEG_UPDATE);
	v_hide_c(handle);

	if ( card==-1 ) {			/* alle mîglichen moves anzeigen */
		for ( i=0; i<52; i++ )
			if ( cards[i].top==1 && get_newpos(i,0)>=0 )
				draw_card_rec(i);

		evnt_button(2,2,0,&dummy,&dummy,&dummy,&dummy);

		for ( i=0; i<52; i++ )
			if ( cards[i].top==1 && get_newpos(i,0)>=0 )
				draw_card_rec(i);
	}
	else {						/* zeige karte an die karte passt */
		i=get_newpos(card,1);
		if ( i>=0 ) {
			draw_card_rec(i);
			evnt_button(2,2,0,&dummy,&dummy,&dummy,&dummy);
			draw_card_rec(i);
		}
	}
	v_show_c(handle,1);
	vswr_mode(handle,MD_REPLACE);
	wind_update(END_UPDATE);
}

int do_undo(void)
{
	move--;
	if ( moves[move].flag && !(objc_state(menue,M_CLASSIC)&CHECKED) )
		objc_enabled(menue,M_DRAW);

	if ( moves[move].new_pos>=52 ) {
	  int i;
		for ( i=0; i<moves[move].old_pos; i++ ) 
			c2[i]=cards[i];
		c2[i]=cards[moves[move].new_pos];
		c2[i].stack=moves[move].old_stack;
		for ( i++; i<52; i++ )
			c2[i]=cards[i-1];
		for ( i=52; i<56; i++ )
			c2[i]=cards[i];
		c2[moves[move].new_pos].number--;
		cards_left++;
	}
	else {
		move_card(moves[move].old_pos,moves[move].new_pos,moves[move].old_stack);
	}
	memcpy(cards,c2,sizeof(cards));
	show_cards(1,0l);
	return 1;
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

	init/exit

------------------------------------------------------------------------------*/
void open_window(void)
{
int x,y,w,h;

	wind_get(0,WF_WORKXYWH,&x,&y,&w,&h);
	wind_calc(WC_WORK,BORDER,x,y,w,h,&x,&y,&w,&h);
	w=WIND_WIDTH;
	h=WIND_HEIGHT;
	wind_x=x;
	wind_y=y;
	wind_calc(WC_BORDER,BORDER,x,y,w,h,&x,&y,&w,&h);

	wi_handle=wind_create(BORDER,x,y,w,h);
	wind_set(wi_handle,WF_NAME," Solitare ");
	wind_open(wi_handle,x,y,w,h);

	av_send(AV_ACCWINDOPEN,wi_handle,0,0l);
}

void scale_tree(OBJECT *ob)
{
	do {
		rsrc_obfix(ob,0);
	} while ( !((ob++)->ob_flags&LASTOB) );
}

void do_exit(void)
{
	if ( picture.fd_addr )
		free(picture.fd_addr);

	if ( wi_handle>0 ) {
		wind_close(wi_handle);
		wind_delete(wi_handle);
	}

	menu_bar(menue,0);

	v_clsvwk(handle);
	appl_exit();
	exit(0);
}

void load_cards(int planes)
{
int f,f_id;
DTA dta;
char name[128];
IMG_HEADER head;
char xname[128];
int w=0,h=0,p=0;

		/* lade karten */
	*xname=0;
	Fsetdta(&dta);
	f=Fsfirst("YUKONDAT\\CARDS*.IMG",0);
	while ( !f ) {
		strcpy(name,"YUKONDAT\\");
		strcat(name,dta.d_fname);
		f_id=Fopen(name,0);
		if ( f_id>=0 ) {
			Fread(f_id,sizeof(head),&head);
			Fclose(f_id);
			if ( head.plane_num<=planes && 
					(head.plane_num>p || head.pix_num>w || head.scan_num>h) ) {
				strcpy(xname,name);
				w=head.pix_num;
				h=head.scan_num;
				p=head.plane_num;
			}
		}
		f=Fsnext();
	}
	if ( !*xname || load_img(xname,&picture)!=IMG_OK ) {
		do_exit();
	}
}

int init(void)
{
int i,p_handle,dummy;
int work_in[11],work_out[57];
long pic_len;
int planes;
MFDB p;

		/* bearbeite objektbÑume */
	menue=rs_trindex[MENUE];
	scale_tree(menue);
	infobox=rs_trindex[INFOBOX];
	scale_tree(infobox);

		/* init aes */
	ap_id=appl_init();

	av_init();

	p_handle=graf_handle(&dummy,&dummy,&dummy,&dummy);

		/* init vdi */
	handle=p_handle;
	for ( i=0; i<10; i++ )
		work_in[i]=0;
	work_in[10]=2;
	v_opnvwk(work_in,&handle,work_out);

	vq_extnd(handle,1,work_out);
	planes=work_out[4];

		/* lade karten */
	load_cards(planes);

	CARD_WIDTH=picture.fd_w/15;
	if ( CARD_WIDTH>64 )
		CARD_DIST=CARD_WIDTH/4;
	CARD_HEIGHT=picture.fd_h/4;
	WIND_WIDTH=CARD_WIDTH*8+128;
	WIND_HEIGHT=CARD_HEIGHT*4;
	pic_len=(long)picture.fd_wdwidth*2l*(long)picture.fd_h*(long)planes;
	p=picture;
	p.fd_addr=malloc(pic_len);
	if ( !p.fd_addr ) {
		form_error(8);
		free(picture.fd_addr);
		do_exit();
	}
	if ( picture.fd_nplanes<planes ) 	/* bild hat weniger planes als screen */
		memset(p.fd_addr,0,pic_len);	/*	-> fÅlle mit 0-planes */
	p.fd_stand=0;
	vr_trnfm(handle,&picture,&p);
	free(picture.fd_addr);

	if ( p.fd_nplanes<planes )
		p.fd_nplanes=planes;
	picture=p;

	vsf_color(handle,1);
	vsf_interior(handle,1);

	graf_mouse(0,0l);

	av_getproto();

	menu_bar(menue,1);

	open_window();

	return 1;
}

/*------------------------------------------------------------------------------

	hauptprogramm

------------------------------------------------------------------------------*/
int main(void)
{
int evnt,message[8];
int mx,my,mb,ks,key,dummy;
int i,exit_flag;

	if ( init() ) {

		init_cards();

		mische_cards();
		if ( !(objc_state(menue,M_CLASSIC)&CHECKED) )
			objc_enabled(menue,M_DRAW);
		else
			objc_disabled(menue,M_DRAW);
		objc_enabled(menue,M_MISCHEN);
		objc_disabled(menue,M_MISCHEN2);

		exit_flag=0;
		do {
			if ( move!=0 )
				objc_enabled(menue,M_UNDO);
			else
				objc_disabled(menue,M_UNDO);
			evnt=evnt_multi(MU_MESAG|MU_KEYBD|MU_BUTTON,2+3+256,3,0,
					0,0,0,0,0, 0,0,0,0,0, 
					message,
					0,0, 
					&mx,&my,&mb,&ks,&key,&dummy);

			if ( evnt&MU_BUTTON ) {
				if ( mb==1 ) {
					do_move(mx,my);
				}
				else if ( objc_state(menue,M_HELP)&CHECKED ) {
					show_move(mx,my);
				}
			}
			if ( evnt&MU_KEYBD ) {
			  int xkey=key;
				key>>=8;
				key&=255;
				message[0]=MN_SELECTED;
				for ( i=0; i<sizeof(keys)/sizeof(keys[0]); i++ )
					if ( keys[i].state==ks && keys[i].key==key )
						break;
				if ( i!=sizeof(keys)/sizeof(keys[0]) && !(objc_state(menue,keys[i].entry)&DISABLED) ) {
					message[3]=keys[i].titel;
					message[4]=keys[i].entry;
					evnt|=MU_MESAG;
				}
				else {
					av_send(AV_SENDKEY,ks,xkey,0l);
				}
			}
			if ( evnt&MU_MESAG && message[0]==MN_SELECTED ) {
				menu_tnormal(menue,message[3],1);
				if ( message[4]==M_QUIT ) {
					exit_flag=1;
				}
				else if ( message[4]==M_MISCHEN || message[4]==M_MISCHEN2 ) {
					mische_cards();
					show_cards(0,0l);
					if ( message[4]==M_MISCHEN ) {
						objc_disabled(menue,M_MISCHEN);
						objc_enabled(menue,M_MISCHEN2);
					}
					else {
						objc_disabled(menue,M_MISCHEN2);
					}
				}
				else if ( message[4]==M_UNDO ) {
					do_undo();
				}
				else if ( message[4]==M_DRAW ) {
					draw_flag=1;
				}
				else if ( message[4]==M_CLASSIC ) {
					objc_state(menue,M_CLASSIC)^=CHECKED;
				}
				else if ( message[4]==M_HELP ) {
					objc_state(menue,M_HELP)^=CHECKED;
				}
				else if ( message[4]==M_NEU ) {
					init_cards();
					mische_cards();
					show_cards(0,0l);
					objc_enabled(menue,M_MISCHEN);
					objc_disabled(menue,M_MISCHEN2);
					if ( !(objc_state(menue,M_CLASSIC)&CHECKED) )
						objc_enabled(menue,M_DRAW);
					else
						objc_disabled(menue,M_DRAW);
				}
				else if ( message[4]==M_PRGINFO ) {
				  int x,y,w,h,r;
					form_center(infobox,&x,&y,&w,&h);
					form_dial(FMD_START,x,y,w,h,x,y,w,h);
					objc_draw(infobox,0,10,x,y,w,h);
					r=form_do(infobox,0)&0x7FFF;
					objc_unselect(infobox,r);
					form_dial(FMD_FINISH,x,y,w,h,x,y,w,h);
				}
			}
			else if ( evnt&MU_MESAG ) {
				if ( message[0]==WM_TOPPED ) {
					wind_set(message[3],WF_TOP);
				}
				else if ( message[0]==WM_REDRAW ) {
					show_cards(0,message+4);
				}
				else if ( message[0]==WM_CLOSED ) {
					exit_flag=1;
				}
				else if ( message[0]==WM_MOVED ) {
					wind_set(message[3],WF_CURRXYWH,message[4],message[5],message[6],message[7]);
					wind_get(message[3],WF_WORKXYWH,&wind_x,&wind_y,&dummy,&dummy);
				}
			}
		} while ( !exit_flag );

		do_exit();
	}
	return 0;
}
