#include "cltr.h"

void dr_vdi(int x,int y,int col,int x_off,int y_off);

extern GAME *game;

/*
	assembler routine zum kopieren eines blockes in den puffer
*/
#define WIDTH		10				/* breite des spielfeldes in blîcken */
#define HEIGHT		20				/* hîhe */
	/* FIRSTCOLUMN=1, hardcoded */
#define FIRSTLINE	4				/* erste angezeigte zeile */
#define XWIDTH		(WIDTH+2)		/* breite des internen feldes */
#define XHEIGHT		(HEIGHT+FIRSTLINE+1)	/* hîhe */

static int feld[XHEIGHT][XWIDTH];

void tetris_preview(void);
void dr_tstat(int x,int y,int dy);
uint do_tetris(void);

GAME tetris={
	"Tetris",
	tetris_preview,
	dr_tstat,
	do_tetris,
	WIDTH,
	HEIGHT,
	FIRSTLINE,
	5,
	5
};

/*
	beschreibung der spielsteine fÅr ausgabe
*/
typedef struct {	/* relative positions-offsets (in blîcken) */
	int x[4];
	int y[4];
} DIR;
typedef struct {
	int dirs;		/* zahl mîglicher orientierungen */
	DIR dir[4];
} STONES;

/*
unused	XXXX     XXX	XXX		XXX		XX		 XX		XX
				   X	X		 X		 XX		XX		XX
*/
static STONES tet[]={
	{	0,{{{0,0,0,0},{0,0,0,0}},{{0,0,0,0},{0,0,0,0}},{{0,0,0,0},{0,0,0,0}},{{0,0,0,0},{0,0,0,0}}} },
	{	2,{{{-2,-1,0,1},{0,0,0,0}},{{0,0,0,0},{-2,-1,0,1}},{{0,0,0,0},{0,0,0,0}},{{0,0,0,0},{0,0,0,0}}} },
	{	4,{{{-1,0,1,1},{0,0,0,1}},{{1,0,0,0},{-1,-1,0,1}},{{-1,-1,0,1},{-1,0,0,0}},{{0,0,0,-1},{-1,0,1,1}}} },
	{	4,{{{-1,0,1,1},{0,0,0,-1}},{{-1,0,0,0},{-1,-1,0,1}},{{-1,-1,0,1},{1,0,0,0}},{{0,0,0,1},{-1,0,1,1}}} },
	{	4,{{{-1,0,0,1},{0,0,1,0}},{{0,0,1,0},{-1,0,0,1}},{{-1,0,0,1},{0,0,-1,0}},{{0,0,-1,0},{-1,0,0,1}}} },
	{	2,{{{-1,0,0,1},{1,1,0,0}},{{0,0,1,1},{-1,0,0,1}},{{0,0,0,0},{0,0,0,0}},{{0,0,0,0},{0,0,0,0}}} },
	{	2,{{{-1,0,0,1},{0,0,1,1}},{{1,1,0,0},{-1,0,0,1}},{{0,0,0,0},{0,0,0,0}},{{0,0,0,0},{0,0,0,0}}} },
	{	1,{{{0,1,0,1},{0,0,1,1}},{{0,0,0,0},{0,0,0,0}},{{0,0,0,0},{0,0,0,0}},{{0,0,0,0},{0,0,0,0}}}	}
};

/*
	beschreibung eines steines
*/
typedef struct {
	int x;
	int y;
	int typ;
	int dir;
} STONE;

static STONE stone,next;

/*
	lîsche stein in puffer
*/
static void rm_stone(void)
{
int i,y;

	for ( i=0; i<4; i++ ) {
		y=stone.y+tet[stone.typ].dir[stone.dir].y[i];
		if ( y>=FIRSTLINE ) {
			tetris.dr_block(stone.x+tet[stone.typ].dir[stone.dir].x[i],y,0);
		}
	}
}

/*
	zeichne stein in puffer
*/
static void dr_stone(void)
{
int i,y;
DIR *dir;

	dir=&tet[stone.typ].dir[stone.dir];

	for ( i=0; i<4; i++ ) {
		y=stone.y+dir->y[i];
		if ( y>=FIRSTLINE ) {
			tetris.dr_block(stone.x+dir->x[i],y,stone.typ);
		}
	}
}

/*------------------------------------------------------------------------------

	preview

------------------------------------------------------------------------------*/
#define PREV_X	3
#define PREV_Y	FIRSTLINE+2

void tetris_preview(void)
{
int i;
DIR *dir=&tet[next.typ].dir[next.dir];

	for ( i=0; i<4; i++ )
		dr_vdi(PREV_X+dir->x[i],PREV_Y+dir->y[i],next.typ,prev_x+(prev_w-tetris.block_w*4)/2,prev_y+(prev_h-tetris.block_h*4)/2);
}

/*------------------------------------------------------------------------------

	statistik

------------------------------------------------------------------------------*/
void dr_tstat(int x,int y,int dy)
{
int i;
	y+=dy/2;
	x-=tetris.block_w*2;
	for ( i=1; i<8; i++,y+=dy )
		dr_vdi(2,FIRSTLINE,i,x,y );
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

	for ( i=XHEIGHT-1-opts.opts[PM_TETRIS].random; i<XHEIGHT-1; i++ ) {
		for ( j=1; j<XWIDTH-1; j++ ) {
			feld[i][j]=(int)(xrandom()%14+1);
			if ( feld[i][j]>7 )
				feld[i][j]=0;
			else
				tetris.dr_block(j,i,feld[i][j]);
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
	next.y=2;
	next.typ=(int)(xrandom()%7+1);
	next.dir=(int)(xrandom()%tet[next.typ].dirs);
}

/*------------------------------------------------------------------------------

	position der steine testen
		COLUMNS != TETRIS 
	tetris: mache kopie des akt. steines mit neuer pos.
	        teste neue pos
------------------------------------------------------------------------------*/
/*
	teste ob stein 'stone' an die angeg. pos darf
*/
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
	teste spielfeld ob steine entfernt werden kînnen
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
#if SOUND_LEVEL>0
		do_sound(S_REMOVE);
#endif

		for ( ii=8; ii<=tetris.last_flash; ii++ ) {
			init_wait();
			for ( i=FIRSTLINE; i<XHEIGHT-1; i++ ) {
				for ( j=1; j<XWIDTH-1; j++ ) {
					if ( flags[i][j] )
						tetris.dr_block(j,i,ii);
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
					tetris.dr_block(j,ii,feld[ii][j]);
				}
			}
		}
		copy_out();
	}
	return done;
}

/*
	haupt-spielroutine
		returns 0 -> abbruch, sonst score
*/
uint do_tetris(void)
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

	level=opts.opts[PM_TETRIS].start_level;
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

		stat[stone.typ-1]++;
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
			if ( draw ) {			/* nur wenn nîtig */
				dr_stone();			/* stein zeichnen */
				draw=0;				/* flag lîschen */
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
			  	if ( check_pos(&x) ) {
			  		x.x++;
#if SOUND_LEVEL>3
					do_sound(S_CANT_LEFT);
				}
				else {
					do_sound(S_LEFT);
#endif
				}
			  break;
			  case K_RIGHT:
				x.x++;				/* rechts */
			  	if ( check_pos(&x) ) {
			  		x.x--;
#if SOUND_LEVEL>3
					do_sound(S_CANT_RIGHT);
				}
				else {
					do_sound(S_RIGHT);
#endif
				}
			  break;
			  case K_ROTATE: {
			   int h=x.dir;
				x.dir++;
				if ( x.dir>=tet[x.typ].dirs )
					x.dir=0;
				if ( check_pos(&x) ) {
					x.dir=h;
#if SOUND_LEVEL>3
					do_sound(S_CANT_ROTATE);
				}
				else {
					do_sound(S_ROTATE);
#endif
				}
			  } break;
			  case K_ROT_CCW: {
			   int h=x.dir;
				x.dir--;
				if ( x.dir<0 )
					x.dir=tet[x.typ].dirs-1;
				if ( check_pos(&x) ) {
					x.dir=h;
#if SOUND_LEVEL>3
					do_sound(S_CANT_ROT_CCW);
				}
				else {
					do_sound(S_ROT_CCW);
#endif
				}
			  } break;
			  case K_DROP:
				let_it_fall=1;		/* fallen lassen */
				drop_line=stone.y;
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
				x.y++;
				if ( check_pos(&x) )/* eins tiefer */
					{ x.y--; break; }
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

		dir=&tet[stone.typ].dir[stone.dir];
		for ( i=0; i<4; i++ )
			feld[stone.y+dir->y[i]][stone.x+dir->x[i]]=stone.typ;

									/* steine wegrÑumen */
		check_feld(&lines);

		score+=5+level*2;
		if ( let_it_fall )
			score+=XHEIGHT-1-drop_line;
		else
			score+=XHEIGHT-1-stone.y;
		if ( preview_flag )
			score-=3;

									/* tastaturpuffer lîschen */
		clr_keys();
	}
	dr_score(level,lines,stones,score);
	return score;
}


