int    xrsrc_load(const char *re_lpfname, int *pglobal);
int    xrsrc_free(int *pglobal);
int    xrsrc_gaddr(int re_gtype, int re_gindex, void *re_gaddr, int *pglobal);
int    xrsrc_saddr(int re_stype, int re_sindex, void *re_saddr, int *pglobal);
int    xrsrc_obfix(OBJECT *re_otree, int re_oobject);

int 		init_xrsrc(int vdi_handle, GRECT *desk, int gl_wbox, int gl_hbox);
void    term_xrsrc(void);
