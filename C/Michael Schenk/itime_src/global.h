extern int vdi_handle;
extern int w_max;
extern int quick_draw;
extern bool hintergrund;

extern bool mouse_sleeps(void);
extern void sleep_mouse(void);
extern void wake_mouse(void);
extern int note(int def, int undo, int index);
extern int snote(int def, int undo, int index, char *val);
extern bool path_from_env(char *env, char *path);
extern void set_hintergrund(void);
extern int init_global(void);
extern void term_global(void);
