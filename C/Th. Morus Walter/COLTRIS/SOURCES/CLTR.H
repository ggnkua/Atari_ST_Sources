#include <vdi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>	/* mem... */

/*
		hmm, might be somewhere more common...
*/
typedef unsigned int	uint;
#define min(a,b)	(a)<(b)?(a):(b)
#define max(a,b)	(a)>(b)?(a):(b)

/*
	typedefinitionen
*/

/*
		FENSTER
*/

#define WIND_ANZ	4

typedef enum {
	W_ERROR=-1,
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

/*
		funktionen fÅr ein spiel
*/
typedef struct {
	char *name;
	void (*preview)(void);
	void (*dr_stat)(int x,int y,int dy);
	uint (*play)(void);
	int game_width;			/* spielfeldbreite in bloecken */
	int game_height;		/* spielfeldhîhe in bloecken */
	int game_firstline;		/* erste genutzte zeile */
	int prev_width;			/* breite des preview-feldes in bloecken */
	int prev_height;		/* hoehe des preview-feldes in bloecken */


							/* rest wird beim laden der spielblîcke eingetragen */

	void (*dr_block)(int x,int y,int col);
	MFDB bloecke;
	MFDB xbloecke[4];

	int vdi;
	int block_w;
	int block_h;
	int block_xw;		/* w-1 */
	int block_xh;

	int source_width;	/* abstand der blîcke im source-mfdb */

	int last_flash;		/* letzter block fÅr aufblitzen vor remove */

	int x_pos[32];		/* pixel positionen als fkt von block pos. */
	int y_pos[32];
} GAME;

/*
		spielmodi
*/
typedef enum {
	PM_TETRIS,
	PM_COLUMNS,
} PLAY_MODE;

#define PM_NUMBER	2				/* zahl der spielmodi */

/*
		OPTIONEN
*/
/*
		optionen eines spiels
*/
typedef struct {
	int start_level;
	int random;
	int score;			/* 0 hide    1 show */
	int preview;
	int statistic;
} GAME_OPTS;

/*
		hiscore eines spiels
*/
typedef struct {
	char name[14];
	uint date;
	uint score;
} HI_SCORE;

/*
		fensterposition (breite ist eh fix)
*/
typedef struct {
	int x;
	int y;
} WIND_POS;

typedef struct {
	WIND_POS wind_pos[4];/* WORK-Koord. */
	int width,height;	/* spielfeldgrîûe */
	int desk_x,desk_y,desk_w,desk_h;
} POSITION;

#define POSITIONS	10	/* zahl der verwalteten bildschirm/block-grîûen */

/*
	optionen
*/
typedef struct {
	PLAY_MODE play_mode;

	int dummy;
	int alert;
	int sound;
	int cycle;			/* 0 none, 1 play, 2 all */
	int top;			/* 1 toppe alle fenster */
	int multi;			/* 0 single, 1 multi */
	int graph;			/* 0 direkt, 1 vdi */
	int left;
	int right;
	int rotate;
	int rot_ccw;
	int drop;

	HI_SCORE hiscore[PM_NUMBER][10];	
	GAME_OPTS opts[PM_NUMBER];

	POSITION pos[PM_NUMBER][POSITIONS];

	char stone_file[PM_NUMBER][4][32];
} OPTS;

typedef enum {
	NO_KEY,
	K_LEFT,
	K_RIGHT,
	K_ROTATE,
	K_ROT_CCW,
	K_DROP,
	K_LEVEL,
	K_NEXT,
	K_INFO,
	K_STAT,
	K_STOP,
	K_QUIT,
} KEY;

typedef enum {
	S_START,			/* 1  spielanfang */
	S_NEW,				/* 2Z neuer stein */
	S_LEFT,				/* 4z stein nach links */
	S_CANT_LEFT,		/* 4z stein nach links unmîglich */
	S_RIGHT,			/* 4z stein nach rechts */
	S_CANT_RIGHT,		/* 4z stein nach rechts unmîglich */
	S_ROTATE,			/* 4z rotiere */
	S_CANT_ROTATE,		/* 4z rotieren unmîglich */
	S_ROT_CCW,			/* 4z rotiere counterclockwise */
	S_CANT_ROT_CCW,		/* 4z rotiere counterclockwise unmîglich */
	S_STEPDOWN,			/* 3Z schritt nach unten */
	S_DROP,				/* 3Z start vom freien fall */
	S_DROPDOWN,			/* 3Z schritt nach unten im freien fall */
	S_DOWN,				/* 2Z stein unten angekommen */
	S_NEWLEVEL,			/* 1  neuer level */
	S_REMOVE,			/* 1  entferne steine */
	S_ABORT,			/* 1  spiel wurde abgebrochen */
	S_GAMEOVER,			/* 1  spiel ist zu ende */
	S_HISCORE,			/* 1  neuer hiscore erreicht */
	S_NOHISCORE,		/* 1  kein neuer hiscore erreicht */
						/* ^ soundlevel, aufrufe werden nur compiliert, wenn
						     SOUND_LEVEL>=soundlevel 
						   z Routine SEHR zeitkritisch (sollte schnell beendet werden)
						   Z Routine zeitkritisch (sollte schnell beendet werden)
					    */
} SOUND_FKT;

typedef void (*Copy_Out)(void);

extern Copy_Out copy_out;			/* zeiger auf fkt. zur ausgabe 
										des puffers auf screen */
extern int copy_min,copy_max;		/* auszugebender bereich */

extern int handle;

extern MFDB screen;
extern MFDB buffer;

extern int planes_nr,planes,columns_vdi,tetris_vdi;
extern long screen_addr,buffer_addr;
extern int buffer_width,buffer_height;
extern long buffer_size;
extern int screen_width;

extern GAME *game;
extern WINDOW wind[WIND_ANZ];
extern int x_off,y_off;
extern int width;
extern int screen_w,screen_h;
extern uint last_score;
extern int quick_flag;

extern OPTS opts;

extern int preview_flag;		/* 0 off, 1 on */
extern int prev_x,prev_y,prev_w,prev_h;
extern int stat_flag;			/* 0 off, 1 tetris, 2 columns */
extern int score_flag;
extern int stat_x_off,stat_y_off;

KEY get_key(void);				/* hole spiel-taste (interpretiert zeichen...) */
int xget_key(void);				/* warte auf taste (returns scancode) */
void clr_keys(void);			/* lîsche tastatur-puffer */

void window_closed(void);		/* wÑhrend des spielens wurde ein fenster geschlossen */
void do_pause(void);			/* warte bis taste gedrÅckt */

uint calc_delay(uint level);	/* berechne verzîgerung fÅr level */

void init_wait(void);			/* initialisiere warten */
void do_wait(int ms);			/* warte ms millisek. */

long xrandom(void);
long gettime(void);

int check_recs(int x,int y,int w,int h,int *x1,int *y1,int *w1,int *h1);
void redraw_play(int *message);
int do_control(int flag);

void do_exit(int ret);

void set_score(void);
void dr_score(uint,uint,uint,uint);

void set_preview(void);
void redraw_preview(int *message);

void set_statistic(void);
void dr_stat(uint *stat);

int init_image(GAME *game,char *name,int argc,char **argv);
void change_stones(void);

void init_quickcopy(void);
void inv_feld(void);



/*
	columns routinen 
	tetris routinen 
*/
extern GAME columns;
extern GAME tetris;

/*
	sound funktionen
*/
void init_sound(int argc,char *argv[]);
void do_sound(SOUND_FKT sound);


