/* def's of XCARPET.C */

/* no var's */

void line(int, int, int, int);
void bar(int, int, int, int);
void set_clip(int, int, int, int);

/* slider of top window */
void hslidesize(void);
void vslidesize(void);
void hslidepos (void);
void vslidepos (void);
void open_window(void);
void close_window(void);

/* errors */
void normal_error(char *),eingabe_error(void),memory_error(void);

void calc_function(int, int, int, int);

void full_update(void);
void do_redraw(int, int, int, int);

void hard_copy(void);
void save_screen(void);




