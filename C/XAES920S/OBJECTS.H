/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _OBJECTS_H_
#define _OBJECTS_H_

void init_objects(void);

/* Externally used routines */
void display_object(LOCK lock, XA_TREE *wt, short object, short parent_x, short parent_y, bool is_menu);
short draw_object_tree(LOCK lock, XA_TREE *wt, OBJECT *tree, short item, short depth, bool is_menu, short which);
short object_offset(OBJECT *tree, short object, short *mx, short *my);
void change_object(LOCK lock, XA_TREE *wt, OBJECT *tree, short i, RECT *r, short state, bool draw, bool is_menu);
short find_object(OBJECT *tree, short object, short depth, short mx, short my);
bool ed_char(XA_TREE *wt, TEDINFO *ed_txt, short keycode);
bool check_widget_tree(XA_CLIENT *client, OBJECT *tree);
/* HR */
void set_ob_spec(OBJECT *root, short s_ob, unsigned long cl);
OB_SPEC *get_ob_spec(OBJECT *ob);
void redraw_object(LOCK lock, XA_TREE *wt, short );
void wr_mode(short);
void l_color(short m);
void f_color(short m);
void t_color(short m);
void t_font(short p, short f);
void f_interior(short m);
bool d3_any(OBJECT *ob);
bool d3_indicator(OBJECT *ob);
bool d3_foreground(OBJECT *ob);
bool d3_background(OBJECT *ob);
bool d3_activator(OBJECT *ob);
void d3_pushbutton(short d, RECT *r, OBJC_COLOURS *col, short state, short thick, short mode);

/* Clipping stuff */
void set_clip(const RECT *r);
void clear_clip(void);

/* Internal utility routines */
void set_colours(OBJECT *ob, OBJC_COLOURS *colourword);
void shadow_object(short d, short state, RECT *r, short colour, short border_thick);
void draw_2d_box(short x, short y, short w, short h, short border_thick, short colour);
void g2d_box(short b, RECT *r, short colour);
void object_area(RECT *c,OBJECT *ob, short i);
void write_menu_line(RECT *cl);
short __stdargs get_parent(OBJECT *ob, short item);
void write_selection(RECT *r);
long calc_back(RECT *r, short planes);

/* HR: intermediate level draw functions & misc. */
void adjust_size(short d, RECT *r);
void p_gbar(short d, RECT *r);
void p_bar(short d, short x, short y, short w, short h);	/* for perimeter = 1 */
void gbar (short d, RECT *r);
void gbox(short d, RECT *r);
void box  (short d, short x, short y, short w, short h);
void line (short x, short y, short x1,short y1, short col);
void tl_hook(short d, RECT *r, short col);
void br_hook(short d, RECT *r, short col);
void chiseled_gbox(short d, RECT *r);
void t_extent(char *t, short *w, short *h);
void rtopxy(int *p, const RECT *r);
void ritopxy(int *p, short x, short y, short w, short h);
void *form_save(short d, RECT r, void *area);
void form_restore(short d, RECT r, void *area);
void form_copy(RECT *fr, RECT *to);
void strip_name(char *to, char *fro);
char *cramped_name(void *s, char *t, short w);
char *clipped_name(void *s, char *t, short w);
short thickness(OBJECT *ob);
bool is_menu(OBJECT *tree);
void deselect(OBJECT *tree, short item);
char *object_type(OBJECT *tree, short t);
bool is_spec(OBJECT *tree, short item);

ObjectDisplay
	d_g_box,
	d_g_boxchar,
	d_g_boxtext,
	d_g_button,
	d_g_cicon,
	d_g_fboxtext,
	d_g_ftext,
	d_g_ibox,
	d_g_icon,
	d_g_image,
	d_g_progdef,
	d_g_slist,
	d_g_string,
	d_g_text,
	d_g_title;

#endif
