
int main(void);

void init_interface(void);
void prg_loop(void);
void open_work(void);

void my_wind_new(void);
void my_wind_new2(void);
int my_wind_update(int mode);
int my_graf_watchbox(OBJECT *adr,int objet,int in,int out);
void WindClose(int index);
void WindClose2(int index);


void send_redraw(int wh, OBJECT *obj, int o, int prof);
void redraw_w_objc(int index,int objc);
void redraw_w_rect(int wh,OBJECT *obj, int o, int prof);

int my_wind_get(int handle, int mode, int *parm1, int *parm2, int *parm3, int *parm4);
void Free(void);
void attach(void);

int alerte(int index);

void OpenPrgIconifiedWind(int index);
void UniconifyWind(int wh,int x,int y,int w,int h);

void wind_form(int index);
int find_index(int handle);
void set_clip(int clip_flag, GRECT *area);
int edit_curs(int wi,int flag);
void redraw(int wind_handle, int x, int y, int w, int h);
void redraw_window(int index,GRECT *rect);
void send_redraw_message(int wh,int x,int y,int w,int h);

int rc_intersect(GRECT *p1, GRECT *p2);
int xform_do(int flags, OBJECT *address);
int parent(OBJECT *adr, int object);
int next(OBJECT *adr);
int prev(OBJECT *adr);
int m_title(OBJECT *adresse, int option);
int alerte(int index);
char *trim(char *str);
char *BuildIkbd(int key, int shift, char *t);
char *BuildItem(char *t);
long Instr(char *s1, char *s2);
void stdkey(int key,char *k);

void wait_mouse(void);

