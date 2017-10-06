/* bldrdash.h */

/*********************************************/
/* you just keep on pushing my luck over the */
/*           BOULDER        DASH             */
/*                                           */
/*     Jeroen Houttuin, ETH Zurich, 1990     */
/*********************************************/

typedef void *bloc;
typedef int Bool;
#define True 1
#define False 0

#define MAXTABLEAUX 39

/* define bit maps */

extern char blob_bits[];
extern char blob2_bits[];
extern char boulder_bits[];
extern char diamond_bits[];
extern char diamond2_bits[];
extern char eater_bits[];
extern char eater2_bits[];
extern char exit2_bits[];
extern char exit3_bits[];
extern char explosion_bits[];
extern char grass_bits[];
extern char icon_bits[];
extern char lmonster_bits[];
extern char lmonster2_bits[];
extern char nucbal_bits[];
extern char player_bits[];
extern char player2_bits[];
extern char rmonster_bits[];
extern char rmonster2_bits[];
extern char space_bits[];
extern char steel_bits[];
extern char tinkle1_bits[];
extern char tinkle2_bits[];
extern char wall_bits[];
extern char wall2_bits[];


#define blob_width 32
#define blob_height 32
#define blob_x_hot -1
#define blob_y_hot -1
#define blob2_width 32
#define blob2_height 32
#define blob2_x_hot -1
#define blob2_y_hot -1
#define boulder_width 32
#define boulder_height 32
#define boulder_x_hot -1
#define boulder_y_hot -1
#define diamond_width 32
#define diamond_height 32
#define diamond_x_hot -1
#define diamond_y_hot -1
#define diamond2_width 32
#define diamond2_height 32
#define diamond2_x_hot -1
#define diamond2_y_hot -1
#define eater_width 32
#define eater_height 32
#define eater_x_hot -1
#define eater_y_hot -1
#define eater2_width 32
#define eater2_height 32
#define eater2_x_hot -1
#define eater2_y_hot -1
#define exit2_width 32
#define exit2_height 32
#define exit3_width 32
#define exit3_height 32
#define exit3_x_hot -1
#define exit3_y_hot -1
#define explosion_width 32
#define explosion_height 32
#define grass_width 32
#define grass_height 32
#define grass_x_hot -1
#define grass_y_hot -1
#define icon_width 32
#define icon_height 32
#define lmonster_width 32
#define lmonster_height 32
#define lmonster_x_hot -1
#define lmonster_y_hot -1
#define lmonster2_width 32
#define lmonster2_height 32
#define lmonster2_x_hot -1
#define lmonster2_y_hot -1
#define nucbal_width 32
#define nucbal_height 32
#define player_width 32
#define player_height 32
#define player_x_hot -1
#define player_y_hot -1
#define player2_width 32
#define player2_height 32
#define player2_x_hot -1
#define player2_y_hot -1
#define rmonster_width 32
#define rmonster_height 32
#define rmonster_x_hot -1
#define rmonster_y_hot -1
#define rmonster2_width 32
#define rmonster2_height 32
#define rmonster2_x_hot -1
#define rmonster2_y_hot -1
#define space_width 32
#define space_height 32
#define steel_width 32
#define steel_height 32
#define steel_x_hot -1
#define steel_y_hot -1
#define tinkle1_width 32
#define tinkle1_height 32
#define tinkle2_width 32
#define tinkle2_height 32
#define wall_width 32
#define wall_height 32
#define wall2_width 32
#define wall2_height 32

#define w 35
#define h 26
#define LEVELPREFIX "xbdlev"

/* direction masks */
#define N 0
#define E 1
#define S 2
#define W 3
#define NODIR 4

#define SPACEEXPLO 0
#define BOULDEXPLO 10
#define DIAEXPLO 20
#define PROPAGATED 10

#define PLAYER              'p'
#define SPACE               ' '
#define LMONSTER            'l'	/* Right turning monster */
#define RMONSTER            'r'
#define GRASS               'g'
#define WALL                'w'
#define MAGICWALL           'W'	/* Expanding wall */
#define DIAMOND             'd'
#define STEEL               'S'
#define BOULDER             'b'
#define EXPLOSION           'x'
#define EXIT                'E'
#define EATER               'e'
#define NUCBAL              'n'	/* Nuclear ballon */
#define BLOB                'B'	/* lava */
#define TINKLE              't'	/* Tinkle wall */

extern bloc     whitegc, scoregc, gc, BBgc, BBgc1, BBgc2, ngc, egc, egc1,
                egc2, EEgc1, WWgc, WWgc2, EEgc2, EEgc, lgc, lgc1, lgc2, rgc,
                rgc1, rgc2, xgc, SSgc, bgc,
                dgc, dgc1, dgc2, wgc, pgc, pgc1, pgc2, sgc, ggc, tgc, tgc1,
                tgc2, tgc3;

extern char            filename[300];	/* Current file name of this level */
extern char            levname[64];	/* Levelname */
extern int             i, j, ii, jj, jjj;
extern int             blobbreak;
extern int             critical;
extern int             time__;		/* Current clock tick number */
extern int             blobcells;
extern int             tinkdur;	/* Tinkle duration */
extern Bool            tinkact;	/* Tinkle active   */
extern Bool            levincreased;
extern int             x, y, xin, yin, players, lives, levelnum, levelstart, speed,
		                diareq, diapoints, extradiapoints;
extern Bool            stoplevel, blobcollapse;

#define STAND 0
#define UP 1
#define DOWN 2
#define LEFT 3
#define RIGHT 4
#define KILL 5

extern int    curorder;	/* Current order which player has */
/* typed at the keyboard. */
struct cell
{
  char            content;
  Bool            changed;	/* has cell changed since last drawing */
  Bool            caught;	/* for BLOB */
  Bool            checked;	/* for BLOB algorithm */
  char            dir;
  short           speed;
  short           stage;	/* painting stage for blinking etc. */
};      

extern struct cell     field[h][w];

extern Bool				steal;
extern Bool            gamestop;
extern Bool            scoreobs;	/* is score line obsolete ? */
extern int             levelnum;	/* Current level number */
extern int             lives;		/* Current number of lives */
extern int             score;		/* Total score */
extern int             speed;		/* Speed of game.  1 is slowest, 15 is
				 * default */
extern char            filename[300];	/* Current file name of this level */


extern bloc            makegc();
extern void            make_gcs();
extern void            init_level();
extern void            draw_score();
extern void            draw_field();
extern void            set_cell();
extern void            move_cell();
extern void            explode();
extern Bool            move_monster();
extern Bool            search_destroy();
extern void            calculate_field();
extern void            add_score();
