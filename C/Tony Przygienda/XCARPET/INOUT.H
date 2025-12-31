/* 'defs' fÅr INOUT */
extern char    func_string[200]; /* enthÑlt string der Funktionsgleichung */
extern double  xstart,xend,ystart,yend;
extern double  consta,constb,constc;  /* Werte der Konstanten */

extern double  xangle,zangle;

extern double  look_x,look_y,look_z,plane_y;
extern int     light_x,light_y,light_z; /* der Beleuchtung */

extern int     xlines,ylines; 	/* Auflîsung, Anzahl Intervalle */
extern int     xres, yres;	/*  dito,     Anzahl Linien	*/

void norm_double(double *);
void norm_int(int *);
void read_forminp(void),write_forminp(void);
void read_rotate(void),write_rotate(void);
void read_view(void),write_view(void);
void read_light(void),write_light(void);
void read_resolution(void),write_resolution(void);
void read_drawmode(void),write_drawmode(void);
void read_savemode(void),write_savemode(void);

void update_memostat(void);




















