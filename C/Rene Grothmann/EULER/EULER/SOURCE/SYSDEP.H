/* definiert in rmat.c */

typedef enum { line_none, line_solid, line_dotted, line_dashed }
	linetyp;
typedef enum { marker_cross, marker_circle, marker_diamond, marker_dot,
	marker_plus, marker_square, marker_star }
	markertyp;
typedef enum { fill_blank, fill_filled } filltyp;
typedef enum { key_none, cursor_up, cursor_down, cursor_left, cursor_right,
	escape, delete, backspace, clear_home, switch_screen, enter,
	space, line_end, line_start, fk1, fk2, fk3, fk4, fk5, fk6, fk7,
	fk8, fk9, fk10, word_left, word_right, help } 
	scantyp;

void text_mode (void);
void graphic_mode (void);
void gline (double c, double r, double c1, double r1, int color,
	int st, int width);
void gtext (double c, double r, char *text, int color, int centered);
void gmarker (double c, double r, int color, int st);
void gfill (double c[], int st, int n, int connect[]);
void scale (double s);
void mouse (int *, int *);
void gbar (double c, double r, double c1, double r1, double hue,
	int color, int connect);
void gfillh (double c[], double hue, int color, int connect);
void getpixel (double *x, double *y);


int wait_key (int *scan);
int test_key (void);

char *cd (char *dir);
char *dir (char *pattern);

void clear_graphics (void);
void clear_screen (void);
int execute (char *, char *);
int shrink (size_t size);

double myclock (void);

void gprint (char *s); /* print an output text (no newline) */
void gflush (void); /* flush out graphics */

void move_cr (void);
void move_cl (void);
void clear_eol (void);
void  cursor_off (void); 
void cursor_on (void);

void edit_on (void);
void edit_off (void);

void sys_wait (double delay, int *scan);

