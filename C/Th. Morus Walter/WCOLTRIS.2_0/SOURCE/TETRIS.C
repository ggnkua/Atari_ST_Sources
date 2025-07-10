#include <vdi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>	/* mem... */

#include <image.h>

#include "cltr.h"

extern int planes,tetris_vdi;

#define WIDTH		10
#define HEIGHT		20
#define FIRSTLINE	4
#define XHEIGHT		(HEIGHT+FIRSTLINE+1)
#define XWIDTH		(WIDTH+2)
static int BLOCK_SW	= 16;
static int BLOCK_W		= 16;
static int BLOCK_H		= 16;
static int BLOCK_XW;
static int BLOCK_XH;

static int feld[HEIGHT+5][WIDTH+2];

void get_tetris_size(int *w,int *h)
{
	*w=WIDTH*BLOCK_W;
	*h=HEIGHT*BLOCK_H;
}
void get_tetris_prev(int *w,int *h)
{
	*w=BLOCK_W*5;
	*h=BLOCK_H*5;
}

typedef struct {
	int x[4];
	int y[4];
} DIR;

typedef struct {
	DIR dir[4];
	int dirs;
} STONES;

/*
	XXXX     XXX	XXX		XXX		XX		 XX		XX
			   X	X		 X		 XX		XX		XX
*/
static STONES tet[]={
	{	{{{0,0,0,0},{0,0,0,0}},{{0,0,0,0},{0,0,0,0}},{{0,0,0,0},{0,0,0,0}},{{0,0,0,0},{0,0,0,0}}},0	},
	{	{{{-2,-1,0,1},{0,0,0,0}},{{0,0,0,0},{-2,-1,0,1}},{{0,0,0,0},{0,0,0,0}},{{0,0,0,0},{0,0,0,0}}},2	},
	{	{{{-1,0,1,1},{0,0,0,1}},{{1,0,0,0},{-1,-1,0,1}},{{-1,-1,0,1},{-1,0,0,0}},{{0,0,0,-1},{-1,0,1,1}}},4	},
	{	{{{-1,0,1,1},{0,0,0,-1}},{{-1,0,0,0},{-1,-1,0,1}},{{-1,-1,0,1},{1,0,0,0}},{{0,0,0,1},{-1,0,1,1}}},4	},
	{	{{{-1,0,0,1},{0,0,1,0}},{{0,0,1,0},{-1,0,0,1}},{{-1,0,0,1},{0,0,-1,0}},{{0,0,-1,0},{-1,0,0,1}}},4	},
	{	{{{-1,0,0,1},{1,1,0,0}},{{0,0,1,1},{-1,0,0,1}},{{0,0,0,0},{0,0,0,0}},{{0,0,0,0},{0,0,0,0}}},2	},
	{	{{{-1,0,0,1},{0,0,1,1}},{{1,1,0,0},{-1,0,0,1}},{{0,0,0,0},{0,0,0,0}},{{0,0,0,0},{0,0,0,0}}},2	},
	{	{{{0,1,0,1},{0,0,1,1}},{{0,0,0,0},{0,0,0,0}},{{0,0,0,0},{0,0,0,0}},{{0,0,0,0},{0,0,0,0}}},1	}
};

static char tet_bloecke[]={
	0x00,0x00,0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,
0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,
	0x00,0x00,0x80,0x01,0x80,0x01,0x80,0x01,0x80,0x01,0x80,0x01,0x80,0x01,0x80,0x01,
0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xfe,0xff,
	0x00,0x00,0xbf,0xfd,0xbf,0xfd,0xbf,0xfd,0xbf,0xfd,0xbf,0xfd,0xbf,0xfd,0xbf,0xfd,
0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xfe,0xff,0xfc,0x7f,
	0x00,0x00,0xb1,0x15,0xb5,0x55,0xb5,0x55,0xb5,0x55,0xb7,0x75,0xbf,0xfd,0xbf,0xfd,
0xff,0xff,0xff,0xff,0xff,0xff,0xfe,0xff,0xfc,0x7f,0xf8,0x3f,
	0x00,0x00,0xa0,0x05,0xa0,0x05,0xa8,0x8d,0xaa,0xad,0xaa,0xad,0xaa,0xad,0xae,0xed,
0xff,0xff,0xff,0xff,0xfe,0xff,0xfc,0x7f,0xf8,0x3f,0xf0,0x1f,
	0x00,0x00,0xa4,0x45,0xb5,0x55,0xb5,0x55,0xb5,0x55,0xbd,0xdd,0xbf,0xfd,0xbf,0xfd,
0xff,0xff,0xfe,0xff,0xfc,0x7f,0xf8,0x3f,0xf0,0x1f,0xe0,0x0f,
	0x00,0x00,0xa0,0x05,0xa0,0x05,0xa2,0x25,0xaa,0xad,0xaa,0xad,0xaa,0xad,0xbb,0xbd,
0xfe,0xff,0xfc,0x7f,0xf8,0x3f,0xf0,0x1f,0xe0,0x0f,0xc0,0x07,
	0x00,0x00,0xb1,0x15,0xb5,0x55,0xb5,0x55,0xb5,0x55,0xb7,0x75,0xbf,0xfd,0xbf,0xfd,
0xfc,0x7f,0xf8,0x3f,0xf0,0x1f,0xe0,0x0f,0xc0,0x07,0x80,0x03,
	0x00,0x00,0xa0,0x05,0xa0,0x05,0xa8,0x8d,0xaa,0xad,0xaa,0xad,0xaa,0xad,0xae,0xed,
0xfe,0xff,0xfc,0x7f,0xf8,0x3f,0xf0,0x1f,0xe0,0x0f,0xc0,0x07,
	0x00,0x00,0xa4,0x45,0xb5,0x55,0xb5,0x55,0xb5,0x55,0xbd,0xdd,0xbf,0xfd,0xbf,0xfd,
0xff,0xff,0xfe,0xff,0xfc,0x7f,0xf8,0x3f,0xf0,0x1f,0xe0,0x0f,
	0x00,0x00,0xa0,0x05,0xa0,0x05,0xa2,0x25,0xaa,0xad,0xaa,0xad,0xaa,0xad,0xbb,0xbd,
0xff,0xff,0xff,0xff,0xfe,0xff,0xfc,0x7f,0xf8,0x3f,0xf0,0x1f,
	0x00,0x00,0xb1,0x15,0xb5,0x55,0xb5,0x55,0xb5,0x55,0xb7,0x75,0xbf,0xfd,0xbf,0xfd,
0xff,0xff,0xff,0xff,0xff,0xff,0xfe,0xff,0xfc,0x7f,0xf8,0x3f,
	0x00,0x00,0xa0,0x05,0xa0,0x05,0xa8,0x8d,0xaa,0xad,0xaa,0xad,0xaa,0xad,0xae,0xed,
0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xfe,0xff,0xfc,0x7f,
	0x00,0x00,0xbf,0xfd,0xbf,0xfd,0xbf,0xfd,0xbf,0xfd,0xbf,0xfd,0xbf,0xfd,0xbf,0xfd,
0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xfe,0xff,
	0x00,0x00,0x80,0x01,0x80,0x01,0x80,0x01,0x80,0x01,0x80,0x01,0x80,0x01,0x80,0x01,
0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
	0x00,0x00,0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,
0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,0x7f,0xfe,
};

static MFDB tbloecke={tet_bloecke,14*16,16,14,0,1,0,0,0};

typedef struct {
	int x;
	int y;
	int typ;
	int dir;
} STONE;

static STONE stone,next;

extern MFDB buffer;
extern long screen_addr,buffer_addr;
extern int screen_width;
extern dr_tetris(char *dest,char *source);

static int x_pos[XWIDTH];
static int y_pos[XHEIGHT];

static void (*dr_block)(int x,int y,int col);

static void qdr_block(int x,int y,int col)
{
char *source,*dest;
int xx,yy;

	xx=x_pos[x];
	yy=y_pos[y];
	source=tet_bloecke+col*2;
	dest=(char*)buffer_addr+(long)yy*buffer_width+xx/8;
	dr_tetris(dest,source);
	if ( yy<copy_min )
		copy_min=yy;
	if ( yy+BLOCK_XH>copy_max )
		copy_max=yy+BLOCK_XH;
}

static void vdidr_block(int x,int y,int col)
{
int xy[8],yy;

	xy[0]=col*BLOCK_SW;
	xy[1]=0;
	xy[2]=xy[0]+BLOCK_XW;
	xy[3]=BLOCK_XH;
	xy[4]=x_pos[x];
	yy=xy[5]=y_pos[y];
	xy[6]=xy[4]+BLOCK_XW;
	xy[7]=xy[5]+BLOCK_XH;
	vro_cpyfm(handle,S_ONLY,xy,&tbloecke,&buffer);
	if ( yy<copy_min )
		copy_min=yy;
	if ( yy+BLOCK_XH>copy_max )
		copy_max=yy+BLOCK_XH;
}

static void dr_vdi(int x,int y,int col,int x_off,int y_off)
{
int xy[8];

	xy[0]=col*BLOCK_SW;
	xy[1]=0;
	xy[2]=xy[0]+BLOCK_XW;
	xy[3]=BLOCK_XH;
	xy[4]=x_pos[x]+x_off;
	xy[5]=y_pos[y]+y_off;
	xy[6]=xy[4]+BLOCK_XW;
	xy[7]=xy[5]+BLOCK_XH;
	vro_cpyfm(handle,S_ONLY,xy,&tbloecke,&screen);
}


static void rm_stone(void)
{
int i,y;

	for ( i=0; i<4; i++ ) {
		y=stone.y+tet[stone.typ].dir[stone.dir].y[i];
		if ( y>=FIRSTLINE ) {
			dr_block(stone.x+tet[stone.typ].dir[stone.dir].x[i],y,0);
		}
	}
}

static void dr_stone(void)
{
int i,y;
DIR *dir;

	dir=&tet[stone.typ].dir[stone.dir];

	for ( i=0; i<4; i++ ) {
		y=stone.y+dir->y[i];
		if ( y>=FIRSTLINE ) {
			dr_block(stone.x+dir->x[i],y,stone.typ);
		}
	}
}

/*------------------------------------------------------------------------------

	preview

------------------------------------------------------------------------------*/
#define PREV_X	3
#define PREV_Y	FIRSTLINE+2

void do_draw(void *data,int x,int y,int w,int h)
{
int i;
DIR *dir=(DIR*)data;

	for ( i=0; i<4; i++ )
		dr_vdi(PREV_X+dir->x[i],PREV_Y+dir->y[i],next.typ,prev_x+(prev_w-BLOCK_W*4)/2,prev_y+(prev_h-BLOCK_H*4)/2);
}

void do_clear(void *data,int x,int y,int w,int h)
{
int i;
DIR *dir=(DIR*)data;

	for ( i=0; i<4; i++ )
		dr_vdi(PREV_X+dir->x[i],PREV_Y+dir->y[i],0,prev_x+(prev_w-BLOCK_W*4)/2,prev_y+(prev_h-BLOCK_H*4)/2);
}

static void dr_preview(void)
{
DIR *dir;

	dir=&tet[next.typ].dir[next.dir];
	draw_preview(do_draw,dir);
}

static void clr_preview(void)
{
DIR *dir;

	dir=&tet[stone.typ].dir[stone.dir];
	draw_preview(do_clear,dir);
}

/*------------------------------------------------------------------------------

	statistik

------------------------------------------------------------------------------*/
void dr_tstat(int x,int y,int dy)
{
int i;
	y+=dy/2;
	for ( i=1; i<8; i++,y+=dy ) 
		dr_vdi(2,FIRSTLINE,i,x,y );
}

static void init_feld(void)
{
int i,j;

	for ( i=0; i<XHEIGHT; i++ ) {
		for ( j=0; j<XWIDTH; j++ )
			feld[i][j]=0;
		feld[i][0]=feld[i][XWIDTH-1]=-1;
	}
	for ( j=0; j<XWIDTH; j++ )
		feld[XHEIGHT-1][j]=-1;

	for ( i=XHEIGHT-1-opts.tetris.random; i<XHEIGHT-1; i++ ) {
		for ( j=1; j<XWIDTH-1; j++ ) {
			feld[i][j]=(int)(xrandom()%14+1);
			if ( feld[i][j]>7 )
				feld[i][j]=0;
			else
				dr_block(j,i,feld[i][j]);
		}
	}
	copy_out();
}

static int check_pos(STONE *stone)
{
int i;
DIR *dir;

	dir=&tet[stone->typ].dir[stone->dir];
	for ( i=0; i<4; i++ ) {
		if ( feld[stone->y+dir->y[i]][stone->x+dir->x[i]]!=0 )
			return 1;
	}
	return 0;
}

static int xcheck(void)
{
int i,j;

	for ( i=0; i<FIRSTLINE; i++ )
		for ( j=1; j<XWIDTH-1; j++ )
			if ( feld[i][j]!=0 )
				return 1;
	return 0;
}

static void init_stone(void)
{
	next.x=XWIDTH/2;
	next.y=2;
	next.typ=(int)(xrandom()%7+1);
	next.dir=(int)(xrandom()%tet[next.typ].dirs);
}

static int check_feld(uint *lines)
{
int flags[XHEIGHT][XWIDTH];
int i,j;
int ii;
int done=0;

	memset(flags,0,sizeof(flags));
	for ( i=FIRSTLINE; i<XHEIGHT-1; i++ ) {
		for ( j=1; j<XWIDTH-1; j++ ) {
			if ( feld[i][j]==0 )
				break;
		}
		if ( j==XWIDTH-1 ) {	/* kein break */
			for ( j=1; j<XWIDTH-1; j++ ) {
				flags[i][j]=1;
			}
			(*lines)++;
			done=1;
		}
	}

	if ( done ) {
		for ( ii=8; ii<=12; ii++ ) {
			init_wait();
			for ( i=FIRSTLINE; i<XHEIGHT-1; i++ ) {
				for ( j=1; j<XWIDTH-1; j++ ) {
					if ( flags[i][j] )
						dr_block(j,i,ii);
				}
			}
			copy_out();
			do_wait(3);
		}

		for ( j=1; j<XWIDTH-1; j++ ) {
			for ( ii=i=XHEIGHT-2; ii>=FIRSTLINE; ii--,i-- ) {
				while ( flags[i][j]!=0 )
					i--;
				if ( i<0 )
					i=0;
				if ( i!=ii ) {
					feld[ii][j]=feld[i][j];
					if ( feld[ii][j]==0 )
						dr_block(j,ii,0);
					else
						dr_block(j,ii,feld[ii][j]);
				}
			}
		}
		copy_out();
	}
	return done;
}

int tetris(void)
{
int key;
long time;
int draw,let_it_fall;
STONE x;
int i;
uint level,delay;
uint stones,lines,score;
DIR *dir;
uint stat[7]={0,0,0,0,0,0,0};
int drop_line;

	init_feld();
	check_feld(&lines);

	level=opts.tetris.start_level;
	delay=calc_delay(level);
	stones=lines=score=0;

	init_stone();

	while ( 1 ) {
		stone=next;
		init_stone();
		if ( preview_flag ) {
			clr_preview();
			dr_preview();
		}

		stat[stone.typ-1]++;
		if ( stat_flag )
			dr_stat(stat);

		if ( check_pos(&stone) || xcheck() )
			break;					/* stein checken */
		x=stone;					/* stein merken */

		stones++;
		if ( level<9 && lines>level*10+10 )
			{ level++; inv_feld(); delay=calc_delay(level); }
		dr_score(level,lines,stones,score);

		let_it_fall=0;				/* nicht fallen lassen */
		time=gettime();				/* zeit merken */
		draw=1;						/* zeichnen */

		while ( 1 ) {
			if ( draw ) {			/* nur wenn n”tig */
				dr_stone();			/* stein zeichnen */
				draw=0;				/* flag l”schen */
				copy_out();
			}

			if ( !let_it_fall )		/* falls fallen lassen */
				key=get_key();
			else
				key=0;				/* kein zeichen einlesen */

			switch ( key ) {
			  case K_QUIT:
				return 0;			/* beenden */
			  /*break;*/
			  case K_LEFT:
			  	x.x--;			/* links */
			  	if ( check_pos(&x) )
			  		x.x++;
			  break;
			  case K_RIGHT:
				x.x++;				/* rechts */
			  	if ( check_pos(&x) )
			  		x.x--;
			  break;
			  case K_ROTATE: {
			   int h=x.dir;
				x.dir++;
				if ( x.dir>=tet[x.typ].dirs )
					x.dir=0;
				if ( check_pos(&x) )
					x.dir=h;
			  } break;
			  case K_DROP:
				let_it_fall=1;		/* fallen lassen */
				drop_line=stone.y;
			  break;
			  case K_LEVEL:
				if ( level<9 ) {
					level++;
					inv_feld();
					delay=calc_delay(level);
					dr_score(level,lines,stones,score);
				}
			  break;
			  case K_NEXT:
				set_preview();
				if ( preview_flag )
					dr_preview();
			  break;
			  case K_INFO:
			  	set_score();
			  break;
			  case K_STAT:
			  	set_statistic();
			  	if ( stat_flag )
					dr_stat(stat);
			  break;
			  case K_STOP:
				xget_key();			/* taste mit warten holen */
				time=gettime();
			  break;
			}

			if ( gettime()>time+delay || (let_it_fall && gettime()>time+1) ) {
				x.y++;
				if ( check_pos(&x) )/* eins tiefer */
					{ x.y--; break; }
				time=gettime();
			}
			if ( memcmp(&x,&stone,sizeof(x)) ) {
				draw=1;				/* falls sich was getan hat */
				rm_stone();			/* stein neuzeichnen */
				stone=x;
			}
		}

		if ( memcmp(&x,&stone,sizeof(x)) ) {
			rm_stone();			/* stein neuzeichnen */
			stone=x;
			dr_stone();
			copy_out();
		}
									/* stein ist unten angekommen */
									/* eintragen ins feld */

		dir=&tet[stone.typ].dir[stone.dir];
		for ( i=0; i<4; i++ )
			feld[stone.y+dir->y[i]][stone.x+dir->x[i]]=stone.typ;

									/* steine wegr„umen */
		check_feld(&lines);

		score+=5+level*2;
		if ( let_it_fall )
			score+=XHEIGHT-1-drop_line;
		else 
			score+=XHEIGHT-1-stone.y;
		if ( preview_flag )
			score-=3;

									/* tastaturpuffer l”schen */
		clr_keys();
	}
	dr_score(level,lines,stones,score);
	do_score(score,opts.tet_hi);
	return 1;
}

int init_tetris(void)
{
char name[16];
MFDB pic;
int i;

	sprintf(name,"TETRIS%1d.IMG",planes);

	if ( !load_img(name,&pic) ) {
		tbloecke=pic;
		if ( planes>1 ) {
			tbloecke.fd_addr=malloc(pic.fd_wdwidth*2l*planes*pic.fd_h);
			pic.fd_stand=1;
			tbloecke.fd_stand=0;
			vr_trnfm(handle,&pic,&tbloecke);
		}
		BLOCK_SW=BLOCK_W=tbloecke.fd_w/16;
		BLOCK_H=tbloecke.fd_h;
		tetris_vdi=1;
		dr_block=vdidr_block;
	}
	else if ( planes==1 ) {
		dr_block=qdr_block;
		tetris_vdi=0;
	}
	else {
		tetris_vdi=-1;
		return 0;
	}

	for ( i=1; i<XWIDTH; i++ )
		x_pos[i]=(i-1)*BLOCK_W;
	for ( i=FIRSTLINE; i<XHEIGHT; i++ )
		y_pos[i]=(i-FIRSTLINE)*BLOCK_H;
	BLOCK_XW=BLOCK_W-1;
	BLOCK_XH=BLOCK_H-1;
	return 1;
}

