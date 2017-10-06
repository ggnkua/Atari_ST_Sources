/*	VC	A Table Calculator
 *		Common definitions
 *
 *		original by James Gosling, September 1982
 *		modified by Mark Weiser and Bruce Israel,
 *			University of Maryland
 *
 */

#include<stdio.h>

#ifdef MCH_AMIGA
#define ROWS	23
#define COLS	79
#else
#define ROWS	24
#define COLS	80
#endif

#ifdef DECLARE
#define dec
#else
#define dec extern
#endif

#define MAXROWS 200
#define MAXCOLS 40

struct ent {
    double v;
    char *label;
    struct enode *expr;
    short flags;
    short row, col;
    struct ent *next;
};


struct enode {
    int op;
    union {
	double k;
	struct ent *v;
	struct {
	    struct enode *left, *right;
	} o;
    } e;
};

/* op values */
#define O_VAR 'v'
#define O_CONST 'k'
#define O_REDUCE(c) (c+0200)

/* flag values */
#define is_valid     0001
#define is_changed   0002
#define is_lchanged  0004
#define is_leftflush 0010
#define is_deleted   0020

#define ctl(c) ('c'&037)

dec struct ent *tbl[MAXROWS][MAXCOLS];

dec int strow, stcol;
dec int currow, curcol;
dec int savedrow, savedcol;
dec int FullUpdate;
dec int maxrow, maxcol;
dec int fwidth[MAXCOLS];
dec int precision[MAXCOLS];
dec char hidden_col[MAXCOLS];
dec char hidden_row[MAXROWS];
dec char line[1000];
dec int linelim;
dec int changed;
dec struct ent *to_fix;
dec struct enode *new();
dec struct ent *lookat();
dec struct enode *copye();
dec char *coltoa();

dec int modflg;
