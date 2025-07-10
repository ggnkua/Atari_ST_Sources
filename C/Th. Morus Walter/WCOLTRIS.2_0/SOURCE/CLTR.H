typedef unsigned int	uint;

extern int buffer_width,buffer_height;
extern long buffer_size;

typedef struct {
	int start_level;
	int random;
	int score;			/* 0 hide    1 show */
	int preview;
	int statistic;
} GAME_OPTS;

typedef struct {
	char name[14];
	uint date;
	uint score;
} HI_SCORE;

typedef enum {
	PM_TETRIS,
	PM_COLUMNS,
} PLAY_MODE;

typedef struct {
	int x;
	int y;
} WIND_POS;

typedef struct {
	WIND_POS wind_pos[4];	/* WORK-Koord. */
	int desk_x,desk_y,desk_w,desk_h;
} POSITION;

typedef struct {
	PLAY_MODE play_mode;

	int dummy[4];
	int cycle;			/* 0 none, 1 play, 2 all */
	int top;			/* 1 toppe alle fenster */
	int multi;			/* 0 single, 1 multi */
	int graph;			/* 0 direkt, 1 vdi */
	int left;
	int right;
	int rotate;
	int drop;
	HI_SCORE tet_hi[10];	
	HI_SCORE col_hi[10];	

	GAME_OPTS tetris;
	GAME_OPTS columns;

	POSITION pos[8];
} OPTS;

extern OPTS opts;

typedef enum {
	NO_KEY,
	K_LEFT,
	K_RIGHT,
	K_ROTATE,
	K_DROP,
	K_LEVEL,
	K_NEXT,
	K_INFO,
	K_STAT,
	K_STOP,
	K_QUIT,
} KEY;

extern int handle;

extern MFDB screen;

extern int preview_flag;		/* 0 off, 1 on */
extern int prev_x,prev_y,prev_w,prev_h;
extern int stat_flag;			/* 0 off, 1 tetris, 2 columns */
extern int stat_x_off,stat_y_off;

KEY get_key(void);
int xget_key(void);
void clr_keys(void);
long gettime(void);
void init_wait(void);
void do_wait(int ms);
uint calc_delay(uint level);
void dr_score(uint,uint,uint,uint);

void set_preview(void);
void set_score(void);
void set_statistic(void);

void init_stat(void);
void exit_stat(void);
void dr_stat(uint *stat);

void init_quickcopy(void);
void inv_feld(void);

void do_score(uint score,HI_SCORE *hi);

long xrandom(void);

int check_recs(int x,int y,int w,int h,int *x1,int *y1,int *w1,int *h1);
typedef void (*Draw_Funct)(void *data,int x,int y,int w,int h);
void draw_preview(Draw_Funct draw,void *data);

typedef void (*Copy_Out)(void);
extern Copy_Out copy_out;
extern int copy_min,copy_max;

