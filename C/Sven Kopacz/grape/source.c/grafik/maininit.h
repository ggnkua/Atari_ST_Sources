/* Hauptprg GRAPE Init-Functions */

void	mmain(void);
void	init_grape_mod_info(void);
void	fix_icontext(void);
void	fix_ob(OBJECT *tree);
void	set_vdi_colors(void);
void	set_grey_pal(void);
void	fill_table(void);
void	fill_col_pal(void);
int		test_resolution(int planes);
void	start_text(char *text);

void	event_loop(void);
void	do_menu(int title, int ob);
void	do_key_cmd(int title, int ob);
void	my_klick_dispatch(int x, int y, int but, int klicks, int swt);

void	term(void);
int		close_main_win(void);

void	a_options(void);
void	dial_aopt(int ob);

void	grape_info(void);
void	dial_info(int ob);


void	dial_tool(int ob);
void	dial_special(int ob);

/* Main Globvars */

extern OBJECT *ostartup, *oaopt, *keycmds, *mmenu;
extern WINDOW winfo, waopt;
extern DINFO	dinfo, daopt;
extern int	square_root[1000];
extern int	planes;
extern int	quit;
extern char col_or_grey;
extern int	rgb248[3];
extern OBJECT *otool;
extern OBJECT *ospecial;

extern WINDOW wtool;
extern WINDOW wspecial;

extern DINFO  dtool;
extern DINFO  dspecial;

extern int tool_tol[8][3];