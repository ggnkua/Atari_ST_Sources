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
void display_object(LOCK lock, XA_TREE *wt, int object, G_i parent_x, G_i parent_y, int which);
int draw_object_tree(LOCK lock, XA_TREE *wt, OBJECT *tree, int item, int depth, int which);
int object_offset(OBJECT *tree, int object, G_i dx, G_i dy, G_i *mx, G_i *my);
void change_object(LOCK lock, XA_TREE *wt, OBJECT *tree, int i, RECT *r, int state, bool draw);
int find_object(OBJECT *tree, int object, int depth, G_i mx, G_i my, G_i dx, G_i dy);
bool ed_char(XA_TREE *wt, TEDINFO *ed_txt, G_u keycode);
XA_TREE *check_widget_tree(					/* HR 101201: return widget tree pointer. */
			LOCK lock, XA_CLIENT *client, OBJECT *tree);
int edit_object(LOCK lock,
			XA_CLIENT *client,
			int func,
			XA_TREE *wt, OBJECT *form,
			int ed_obj, G_i keycode,
			int *newpos);
/* HR */
void set_ob_spec(OBJECT *root, int s_ob, unsigned long cl);
OBSPEC *get_ob_spec(OBJECT *ob);
void redraw_object(LOCK lock, XA_TREE *wt, int );
void wr_mode(int);
void l_color(int m);
void f_color(int m);
void t_color(int m);
void t_effect(int m);
void t_font(int p, int f);
void f_interior(int m);
void f_style(int m);
bool d3_any(OBJECT *ob);
bool d3_indicator(OBJECT *ob);
bool d3_foreground(OBJECT *ob);
bool d3_background(OBJECT *ob);
bool d3_activator(OBJECT *ob);
void d3_pushbutton(int d, RECT *r, OBJC_COLOURS *col, int state, int thick, int mode);

/* Clipping stuff */
void set_clip(const RECT *r);
void clear_clip(void);

/* Internal utility routines */
void set_colours(OBJECT *ob, OBJC_COLOURS *colourword);
void shadow_object(int d, int state, RECT *r, int colour, int border_thick);
void draw_2d_box(G_i x, G_i y, G_i w, G_i h, int border_thick, int colour);
void g2d_box(int b, RECT *r, int colour);
void object_rectangle(RECT *c, OBJECT *ob, int i, G_i dx, G_i dy);
void object_area     (RECT *c, OBJECT *ob, int i, G_i dx, G_i dy);
void write_menu_line(RECT *cl);
int __stdargs get_parent(OBJECT *ob, int item);
void write_selection(int d, RECT *r);
long calc_back(RECT *r, int planes);

/* HR: intermediate level draw functions & misc. */
void adjust_size(int d, RECT *r);
void p_gbar(int d, RECT *r);
void bar(int d,  G_i x, G_i y, G_i w, G_i h);
void p_bar(int d, G_i x, G_i y, G_i w, G_i h);	/* for perimeter = 1 */
void gbar (int d, RECT *r);
void gbox(int d, RECT *r);
void box  (int d, G_i x, G_i y, G_i w, G_i h);
void line (G_i x, G_i y, G_i x1,G_i y1, int col);
void tl_hook(int d, RECT *r, int col);
void br_hook(int d, RECT *r, int col);
void chiseled_gbox(int d, RECT *r);
void t_extent(char *t, G_i *w, G_i *h);
void rtopxy(G_i *p, const RECT *r);
void ritopxy(G_i *p, G_i x, G_i y, G_i w, G_i h);
void *form_save(int d, RECT r, void *area);
void form_restore(int d, RECT r, void *area);
void form_copy(RECT *fr, RECT *to);
void strip_name(char *to, char *fro);
void cramped_name(void *s, char *t, int w);
char *clipped_name(void *s, char *t, int w);
int thickness(OBJECT *ob);
bool is_menu(OBJECT *tree);
void deselect(OBJECT *tree, int item);
char *object_type(OBJECT *tree, int t);
bool is_spec(OBJECT *tree, int item);
void write_disable(RECT *r, int colour);

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
