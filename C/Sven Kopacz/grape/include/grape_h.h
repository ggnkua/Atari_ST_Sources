#include <ec_gem.h>
#include <artpad.h>

#define VERSION 0x09100296l


#define X 1
#define Y 2

#define ON 1
#define OFF 0

#define OTBB 2	/* Rand des Toolbars * 2 */


typedef struct
{
	unsigned char	lasur;	/* != 0: Lasur, sonst opaque */
	unsigned char	red;
	unsigned char	yellow;
	unsigned char	blue;
	unsigned char grey;  /* Obige Farbe als Graustufe */
}CMY_COLOR;

typedef struct
{
	int						w; /* Gr”že auf n„chste 16 gerundet */
	long					*table_offset; /* Zeiger auf Offsettabelle fr Zeilen */
	unsigned char	*r, *g,	*b; 	/* Zeiger auf Speicher fr Farbfelder */
} COL_OB;

typedef struct
{
	int					type; 	/* 1=Grože Kurve, 2=Kleine Kurve, 3=Farbe */
	COL_OB			color;	/* Nur fr Farbe */
}U_OB; /* User-Objekt fr User-Defs */

/* Einfacherer Zugriff: */
#define _UP_ .ob_spec.userblk->ub_parm








/* Assembler-Anteile */

extern	void	install(void);
extern	int		counter;
#define my_id 'TIME'	/* SYST */


extern void	*p_red, *p_yellow, *p_blue, *p_mask, *p_edmask, *p_screen;

extern long p_width, pen_width, screen_width;
extern unsigned char c_red, c_yellow, c_blue, c_mask, mask_color;
extern long *table_offset;
extern long screen_offset[2000l];
extern unsigned char c_lasur, c_add, *pen_r, *pen_g, *pen_b;
extern int c_qopt, c_plusminus, c_solo, c_layers;
extern int mask_activ, mask_edit, mask_visible;
extern int start_x, rel_start_x, start_y, rel_start_y, end_x, end_y;
extern unsigned char r_table[256], g_table[256], b_table[256];
extern unsigned char intensity[65536l];
extern unsigned int	 mul_tab[65536l];
extern unsigned char div_tab[131072l];
extern unsigned int *mul_adr[256l];
extern void paint_it(void);
extern void do_dither(void);
extern void do_harmless(void);
extern void typ0_dither(void);
extern void typ1_dither(void);
extern void **red_list, **yellow_list, **blue_list;
extern int *type_list;
extern int din_x[], din_y[];
extern long test1, test2;

extern long dst_lines, dst_width, dst_2width;
extern void *dst_red, *dst_blue, *dst_yellow;
extern long src_offset;
extern void *src_red, *src_blue, *src_yellow;
extern int layeradd_mode;
extern void layer_add(void);
/* IFILL */
extern uchar	*if_buf, *if_cc, *if_mm, *if_yy, *if_debug;
extern uchar	if_cmin, if_cmax, if_mmin, if_mmax, if_ymin, if_ymax;
extern int		if_line, if_mline, if_x, if_y, if_minx, if_maxx, if_miny, if_maxy;
extern long		if_debug2;
extern void		as_iter_fill(void);





/* Hauptfunktionen */


/* Dialogfenster */


void	w_unsel(WINDOW *win, int ob);
void	memo_abbruch(OBJECT *tree);
void	recall_abbruch(OBJECT *tree);

/* Slider */

void	slide(OBJECT *tree, int ob, int min, int max, int now, void(*newval)(int now2));
void	bar(WINDOW *win, int ob, int min, int max, void(*newval)(int now2));

/* Userdefs */

int		cdecl user_ob(PARMBLK	*pblk);
int		cdecl col_field(PARMBLK *pblk);
void  busy(int mode);

/* Color D&D */

void	color_dd(OBJECT *src_tree, int src_ob);
void	set_user_color(WINDOW *win, OBJECT *tree, int ob, CMY_COLOR *col);
void	fill_dd_ob(OBJECT *src_tree, int src_ob);
void	screen_buf(int mode, int x, int y, int w, int h);




/* Hauptfenster */
void	area_redraw(int x, int y, int w, int h);



/* Zeichnen */

void	set_pen_col(CMY_COLOR *c);
void 	set_source_lay(int id);
void 	del_source_lay(int id);

void work_on(int wid);
void get_color(int x, int y);
void cont_get_color(void);
void solo_draw(int wid);
void draw(int wid);
int	 solo_setpix(int x, int y, int w, int h, int pres);
int	 setpix(int x, int y, int w, int h, int pres);



/* Diverse globale Funktionen */
void	fill_col_ob(void);
void	fill_ed_col_ob(int c, int m, int y);
void	fill_usr_col_ob(OBJECT *tree, int ob, int c, int m, int y);
void	set_tol_slider(CMY_COLOR *col);

/* Undo */
int		frame_to_undo(int lay_or_mask);

/* File */
int		quick_io(char	*titel, char	*path, void *load, void *save, long	size, ulong magic);
int		f_input(char *spruch, char *path, char *name);


void	free_buf(void *p);

void	set_ext_type(OBJECT *tree, int ob, int et);

void	set_grey(CMY_COLOR *col);

int		find_cookie(long id, long *val);
int		d_vector(int del);
void	draw_test(void);
void	fetz_her(WINDOW *win);
void	form_blink(int times, int speed, int x, int y, int w, int h);
void	actize_win_name(void);


/* Debugs */
void	debug_display(unsigned char *src, int ssw, int ssh);
void	set_ppix(unsigned char *b, unsigned char *c);
void	set_kpix(int x, int y);


/* Globale Variablen */

extern void	*physbase;
extern int sx, sy, sw, sh;

extern int sel_tool;

extern int	artpad;
extern ASG_COOKIE *asgc, default_tablet;

extern int xrsrc[15];

extern int TB_IMG_X, TB_M_IMG_X;

extern OBJECT *oicons, *omerk, *otoolbar, *oaopt;
extern OBJECT *oframe, *ocoldd;


/* Einmalige Strukturen */

typedef struct
{
	int	gadget; /* Fensterelemente */
	int	id;	/* Gem-Handle */
	int	ox; /* X-Offset der RGB-Planes */
	int	oy;	/* Y-Offset */
	char name[256];
}_main_win;
extern _main_win main_win;


typedef struct
{
	int	off;	/* Offset fr oberste Zeile (ab 0 )*/
	int len;	/* L„nge der sichtbaren Liste */
	
	int	wx,wy,ww,wh;	/* Fensterkoordinaten fr's Speichern */
}_colpal_obs;
extern _colpal_obs colpal_obs;

typedef struct 
{
	int	ok;				/* !=0 : Framedaten sind gltig */
	int	vis;			/* !=0 : Rahmen sichtbar */
	int wid;			/* Fenster in dem der Rahmen sich befindet */
	int	x,y,w,h;	/* Koordinaten */
}_frame_data;
extern _frame_data frame_data;

typedef struct 
{
	char	pic_path[256];
	char	penpar_path[256];
	char	pens_path[256];
	char	poly_path[256];
	char	col_path[256];
	char	colpal_path[256];
	char	stempel_path[256];
	
	char	module_path[256];
	
	char	main_load_path[256];
	char	main_load_name[32];
	char	main_save_path[256];
	char	main_save_name[32];
	
	char	main_import_path[256];
	char	main_import_name[32];
	char	main_export_path[256];
	char	main_export_name[32];
	
	char	layer_import_path[256];
	char	layer_import_name[32];
	char	layer_export_path[256];
	char	layer_export_name[32];

	char	mask_import_path[256];
	char	mask_import_name[32];
	char	mask_export_path[256];
	char	mask_export_name[32];
}_paths;
extern _paths paths;

typedef struct 
{
	ulong	poly;
	ulong penpar;
	ulong pens;
	ulong	col;
	ulong colpal;
	ulong stempel;
}_magics;
extern _magics magics;

/* Makros fr globale Einstellungen */

#define T_WINPOS	(oaopt[OAWINPOS].ob_state & SELECTED)
#define T_PRESS 	(oaopt[OAPRESS].ob_state & SELECTED)
#define T_CCP			(oaopt[OACCP].ob_state & SELECTED)
#define T_CCPDIR	(oaopt[OACCDIR].ob_state & SELECTED)
#define T_GEMCLIP (oaopt[OAGEMCLIP].ob_state & SELECTED)
#define T_FORMAT	(oaopt[OAFORMPOP].ob_type >> 8)
#define T_TOOLXY	(oaopt[OAKOOR].ob_state & SELECTED)
#define T_TOOLOC	(oaopt[OAOPCLOS].ob_state & SELECTED)
#define T_MEMMAIN	(oaopt[OAMMAIN].ob_state & SELECTED)
#define T_QUIT		(oaopt[OAQUIT].ob_state & SELECTED)
