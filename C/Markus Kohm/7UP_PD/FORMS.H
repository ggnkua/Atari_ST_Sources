/* Prototyps for Dialogs */
int  form_exopen(OBJECT *tree, int mode);
int  form_exclose(OBJECT *tree, int exit_obj, int mode);
void form_open(OBJECT *tree, int draw_growing_boxes);
void form_move(OBJECT *tree, int modus);
int  form_exdo(OBJECT *fm_tree, int fm_start_fld);
int  form_close(OBJECT *tree, int exit_obj, int draw_shrinking_boxes);
int  form_hndl(OBJECT *tree, int start, int draw_growing_boxes);
int  form_exhndl(OBJECT *tree, int start, int draw_growing_boxes);
char *form_read(OBJECT *tree, int item, char *string);
void form_write(OBJECT *tree, int item, char *string, int draw_at_once);
int  form_exwrite(OBJECT *tree, int item, int modus, const char *fmt, ...);
void form_clear(OBJECT *tree, int draw_at_once);
void form_exclear(OBJECT *tree, int from, int to, int draw_at_once);

void pop_open(OBJECT *tree, int draw_growing_boxes);
void pop_center(OBJECT *tree, int *x, int *y, int *w, int *h);
void pop_excenter(OBJECT *tree, int mx, int my, int *x, int *y, int *w, int *h);
int  pop_do(OBJECT *tree, int close_at_once);
void pop_close(OBJECT *tree, int exit_obj, int draw_shrinking_boxes);
int  pop_hndl(OBJECT *tree, int start, int draw_growing_boxes);
