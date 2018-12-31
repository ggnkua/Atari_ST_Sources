/************************************
	Defines
************************************/
#define	SHOW		1
#define HIDE		!SHOW
#define	TRUE		1
#define FALSE		!TRUE
#define	BEFORE		0
#define	AFTER		1
#define	READ		0
#define	WRITE		1
#define RW			2
#define unt			unsigned int
#define uch			unsigned char
#define uln			unsigned long
#define UNSELECT	(0xffff ^ SELECTED)
#define ENABLED		(0xffff ^ DISABLED)
#define NEXT		1
#define PREV		-1

typedef struct
	{
	char	a,b,c,d;
	} longc;

/* mess.c routines */
extern void mess(char *m);
extern int	mess2(char *c1, char *c2, char*b1, char *b2, int db);
extern void messl(long l);
extern void messi(int i);

/* gem.c routinmes */
extern void erase_dialog(int x,	int y, int w, int h);
extern void draw_dialog(int box_ind, int *x, int *y, int *w, int *h, char draw);
extern void dial_draw(int box_ind, int obj);
extern int exit_dialog(int box_ind, int x, int y, int w, int h, int draw);
extern void redraw_dialog(int box_ind, int x, int y, int w, int h);
extern void dial2_draw(int box_ind, int obj1, int obj2);



