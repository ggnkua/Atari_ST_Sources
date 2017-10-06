#include "cltr.h"

void dr_vdi(int x,int y,int col,int x_off,int y_off);

/*
	assembler routinen zum kopieren eines blockes in den puffer
*/

#define WIDTH		6				/* breite des spielfeldes in bl”cken */
#define HEIGHT		16				/* h”he */
		/* FIRSTCOLUMN=1, hardcoded */
#define FIRSTLINE	4				/* erste angezeigte zeile */
#define XWIDTH		(WIDTH+2)		/* breite des internen feldes */
#define XHEIGHT		(HEIGHT+FIRSTLINE+1)	/* h”he */

int feld[XHEIGHT][XWIDTH];

void columns_preview(void);
void dr_cstat(int x,int y,int dy);
uint do_columns(void);

GAME columns=
{
	"Columns",
	columns_preview,
	dr_cstat,
	do_columns,
	WIDTH,
	HEIGHT,
	FIRSTLINE,
	2,
	4,
};

/*
	beschreibung eines steins
*/
typedef struct {
	int x;
	int y;
	int c[3];
} STONE;

static STONE stone,next;

/*
	l”sche stein in puffer
*/
static void rm_stone(void)
{
int i,y;

	for ( i=0; i<3; i++ ) {
		y=stone.y+i;
		if ( y>=FIRSTLINE )
			columns.dr_block(stone.x,y,0);
	}
}

/*
	zeichne stein in puffer
*/
static void dr_stone(void)
{
int i,y;
	for ( i=0; i<3; i++ ) {
		y=stone.y+i;
		if ( y>=FIRSTLINE )
			columns.dr_block(stone.x,y,stone.c[i]);
	}
}

/*------------------------------------------------------------------------------

	preview

------------------------------------------------------------------------------*/
static void columns_preview(void)
{
int i;

	for ( i=0; i<3; i++ )
		dr_vdi(1,FIRSTLINE+i,next.c[i],prev_x+(prev_w-columns.block_w)/2,prev_y+(prev_h-columns.block_h*3)/2);
}

/*------------------------------------------------------------------------------

	statistik

------------------------------------------------------------------------------*/
static void dr_cstat(int x,int y,int dy)
{
int i;

	x-=columns.block_w*2;
	for ( i=1; i<7; i++,y+=dy )
		dr_vdi(2,FIRSTLINE,i,x,y);
}

/*------------------------------------------------------------------------------

	spiel initialisieren

------------------------------------------------------------------------------*/
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

	for ( i=XHEIGHT-1-opts.opts[PM_COLUMNS].random; i<XHEIGHT-1; i++ ) {
		for ( j=1; j<XWIDTH-1; j++ ) {
			feld[i][j]=(int)(xrandom()%6+1);
			columns.dr_block(j,i,feld[i][j]);
		}
	}
	copy_out();
}

/*
	erzeuge neuen stein
*/
static void init_stone(void)
{
	next.x=XWIDTH/2;
	next.y=1;
	next.c[0]=(int)(xrandom()%6+1);
	next.c[1]=(int)(xrandom()%6+1);
	next.c[2]=(int)(xrandom()%6+1);
}

/*------------------------------------------------------------------------------

	position der steine testen
		COLUMNS != TETRIS 
	columns: teste akt. stein mit angabe gewnschter bewegung
------------------------------------------------------------------------------*/
/*
	 test ob stein noch fallen kann
*/
static int check_stone(STONE *stone)
{
	if ( feld[stone->y+3][stone->x]!=0 )
		return 1;
	return 0;
}

/*
	teste ob stein nach rechts/links darf
*/
static int check_side(STONE *stone,int side)
{
	if ( feld[stone->y][stone->x+side]!=0 ||
			feld[stone->y+1][stone->x+side]!=0 ||
			feld[stone->y+2][stone->x+side]!=0 )
		return 1;
	return 0;
}

/*
	teste ob nichtsichbarer oberer rand leer
		falls nicht -> game over
*/
static int xcheck(void)
{
int i,j;

	for ( i=0; i<FIRSTLINE; i++ )
		for ( j=1; j<XWIDTH-1; j++ )
			if ( feld[i][j]!=0 )
				return 1;
	return 0;
}

/*
	teste spielfeld ob steine entfernt werden k”nnen
		entferne geg. steine
*/
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
				continue;
			if ( feld[i][j]==feld[i-1][j] && feld[i][j]==feld[i+1][j] ) {
				if ( flags[i-1][j]==0 )
					{ flags[i-1][j]=1; (*lines)++; }
				if ( flags[i][j]==0 )
					{ flags[i][j]=1; (*lines)++; }
				if ( flags[i+1][j]==0 )
					{ flags[i+1][j]=1; (*lines)++; }
				done=1;
			}
			if ( feld[i][j]==feld[i][j-1] && feld[i][j]==feld[i][j+1] ) {
				if ( flags[i][j-1]==0 )
					{ flags[i][j-1]=1; (*lines)++; }
				if ( flags[i][j]==0 )
					{ flags[i][j]=1; (*lines)++; }
				if ( flags[i][j+1]==0 )
					{ flags[i][j+1]=1; (*lines)++; }
				done=1;
			}
			if ( feld[i][j]==feld[i-1][j-1] && feld[i][j]==feld[i+1][j+1] ) {
				if ( flags[i-1][j-1]==0 )
					{ flags[i-1][j-1]=1; (*lines)++; }
				if ( flags[i][j]==0 )
					{ flags[i][j]=1; (*lines)++; }
				if ( flags[i+1][j+1]==0 )
					{ flags[i+1][j+1]=1; (*lines)++; }
				done=1;
			}
			if ( feld[i][j]==feld[i-1][j+1] && feld[i][j]==feld[i+1][j-1] ) {
				if ( flags[i-1][j+1]==0 )
					{ flags[i-1][j+1]=1; (*lines)++; }
				if ( flags[i][j]==0 )
					{ flags[i][j]=1; (*lines)++; }
				if ( flags[i+1][j-1]==0 )
					{ flags[i+1][j-1]=1; (*lines)++; }
				done=1;
			}
		}
	}
	if ( done ) {
#if SOUND_LEVEL>0
		do_sound(S_REMOVE);
#endif
		for ( ii=8; ii<=columns.last_flash; ii++ ) {
			init_wait();
			for ( i=FIRSTLINE; i<XHEIGHT-1; i++ ) {
				for ( j=1; j<XWIDTH-1; j++ ) {
					if ( flags[i][j] )
						columns.dr_block(j,i,ii);
				}
			}
			copy_out();
			do_wait(5);
		}

		for ( j=1; j<XWIDTH-1; j++ ) {
			for ( ii=i=XHEIGHT-2; ii>=FIRSTLINE; ii--,i-- ) {
				while ( flags[i][j]!=0 )
					i--;
				if ( i<0 )
					i=0;
				if ( i!=ii ) {
					feld[ii][j]=feld[i][j];
					columns.dr_block(j,ii,feld[ii][j]);
				}
			}
			for ( ; ii>=0; ii-- )
				feld[ii][j]=0;
		}
		copy_out();
	}
	return done;
}

/*
	haupt-spielroutine
		returns 0 -> abbruch, 1 -> game over
*/
static uint do_columns(void)
{
long time;
int draw,let_it_fall,drop_line;
uint level,delay;
uint stones,lines,score;
STONE x;
KEY key;
uint stat[6]={0,0,0,0,0,0};

	init_feld();
	while ( check_feld(&lines) )		/* wg. preset */
		;

	level=opts.opts[PM_COLUMNS].start_level;
	delay=calc_delay(level);
	stones=lines=score=0;

	init_stone();

	while ( 1 ) {
		stone=next;

		init_stone();
#if SOUND_LEVEL>1
		do_sound(S_NEW);
#endif
		if ( preview_flag )
			redraw_preview(0l);

		stat[stone.c[0]-1]++;
		stat[stone.c[1]-1]++;
		stat[stone.c[2]-1]++;
		dr_stat(stat);

		if ( check_stone(&stone) || xcheck() )	/* game over? */
			break;
		x=stone;					/* stein merken */

		stones++;
		if ( level<9 && lines>level*50+50 )
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
				key=NO_KEY;			/* kein zeichen einlesen */

			switch ( key ) {
			  case K_QUIT:
				return 0;
			  /*break;*/
			  case K_LEFT:
				if ( !check_side(&x,-1) ) {
					x.x--;
#if SOUND_LEVEL>3
					do_sound(S_LEFT);
				}
				else {
					do_sound(S_CANT_LEFT);
#endif
				}
			  break;
			  case K_RIGHT:
				if ( !check_side(&x,+1) ) {
					x.x++;
#if SOUND_LEVEL>3
					do_sound(S_RIGHT);
				}
				else {
					do_sound(S_CANT_RIGHT);
#endif
				}
			  break;
			  case K_ROTATE: {
			   int i;
				i=x.c[2];
				x.c[2]=x.c[1];
				x.c[1]=x.c[0];
				x.c[0]=i;
#if SOUND_LEVEL>3
					do_sound(S_ROTATE);
#endif
			  } break;
			  case K_ROT_CCW: {
			   int i;
				i=x.c[0];
				x.c[0]=x.c[1];
				x.c[1]=x.c[2];
				x.c[2]=i;
#if SOUND_LEVEL>3
					do_sound(S_ROT_CCW);
#endif
			  } break;
			  case K_DROP:
				let_it_fall=1;
				drop_line=x.y;
#if SOUND_LEVEL>2
					do_sound(S_DROP);
#endif
			  break;
			  case K_LEVEL:
				if ( level<9 ) {
				  	level++;
					inv_feld();
					delay=calc_delay(level);
					dr_score(level,lines,stones,score);
				}
			  break;
			}

			if ( gettime()>time+delay || (let_it_fall && gettime()>time+1) ) {
				if ( check_stone(&x) )/* eins tiefer */
					break;
				x.y++;
#if SOUND_LEVEL>2
				if ( let_it_fall )
					do_sound(S_DROPDOWN);
				else
					do_sound(S_STEPDOWN);
#endif
				time=gettime();
			}
			if ( memcmp(&x,&stone,sizeof(x)) ) {
				draw=1;				/* falls sich was getan hat */
				rm_stone();			/* stein neuzeichnen */
				stone=x;
			}
		}

#if SOUND_LEVEL>1
		do_sound(S_DOWN);
#endif
		if ( memcmp(&x,&stone,sizeof(x)) ) {
			rm_stone();			/* stein neuzeichnen */
			stone=x;
			dr_stone();
			copy_out();
		}
									/* stein ist unten angekommen */
									/* eintragen ins feld */
		feld[stone.y][stone.x]=stone.c[0];
		feld[stone.y+1][stone.x]=stone.c[1];
		feld[stone.y+2][stone.x]=stone.c[2];

									/* steine wegr„umen */
		while ( check_feld(&lines) )
			;

									/* score berechnen */
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
	clr_keys();

	dr_score(level,lines,stones,score);
	return score;
}
