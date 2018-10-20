/* Module-typedefs */
#include <moddef.h>

typedef struct _MODULES
{
	struct		_MODULES *prev;
	char			path[256];			/* Pfad+Name des Moduls */
	MODULEBLK	popblock;				/* Hier wird nur das Icon+Name benutzt
																um die Popups anzulegen. Auûerdem
																wird fÅr selbige hier geprÅft, ob
																tree vorhanden ist, um "..." an den
																Popuptext anzuhÑngen	 */
	/* Wenn das Modul geladen ist: */
	void			*base;					/* Zeiger auf Basepage */
	MODULEBLK	*mblock;				/* Zeiger auf Modulblock */
	int				obfixed;				/* 0/1 Wichtig fÅr residente Module */
	WINDOW		*dial_win;
	struct		_MODULES *next;
}MODULES;

typedef struct _MODULE_LIST
{
	struct		_MODULE_LIST	*prev;
	CICONBLK	*iconblk;
	char			*name;
	MODULES		*mlist;	/* List auf Module */
	struct		_MODULE_LIST	*next;
}MODULE_LIST;


/* Module-Funktionen */

void	scan_modules(void);
int		scan_folders(char *path);
int		cat_modules(char *path, int fh);
void	close_all_modules(void);
void	delete_modules(void);
void	show_modules(void);
void	dial_module(int ob);

void	module_arrowed(WINDOW *win, int	*pbuf);
void	module_vslid(WINDOW *win, int	*pbuf);
void	module_sized(WINDOW *win, int	*pbuf);

int		count_module_list(void);
MODULE_LIST *find_module_list(int num);
void	init_module(void);
void	fix_mod_size(void);

int		modules_in_list(char *path, MODULE_LIST *ml);
int		cat_module(char *path, int fh, MODULE_LIST *ml);
void	module_select(MODULE_LIST *ml);
void	make_mod_pop(OBJECT *root, char *texts, MODULE_LIST *ml, int num, int maxname);
void	start_module(MODULE_LIST *ml, int num);
void 	close_module(int id);
void	cdecl term_module(int id);
void	cdecl do_module(int id);
MODULES *find_module_id(int id);

void			run_module(MODULES *m);
void 			fetch_module(MODULES *m);
void			do_mod_func(MODULEBLK *mblock);
void			init_block(MODULES *m);
MODULEBLK	*find_mod_magic(uchar *mem, long len);
BASPAG		*load_module(char *path, long *rlen);
void			relocate(PH *prghead, BASPAG *base);

int				obfix(OBJECT *tree);
int 			open_dum_mod_dial(MODULES *m);
int				open_mod_dial(MODULES *m);
void 			top_mod_dial(WINDOW *win);
void 			ontop_mod_dial(WINDOW *win);
void			close_mod_dial(WINDOW *win);
void			adapt_service(WINDOW *win, int ob);
void			my_service(WINDOW *win, int ob);
void			dial_modopt(int ob);
void			modopt_window(void);

/* Fn's fÅr Module */
void	cdecl d_unsel(int id, int ob);
void	cdecl d_objc_draw(int id, int ob);
void	cdecl modslide(int id, int ob, int min, int max, int now, void cdecl(*newval)(int now2));
void	cdecl modbar(int id, int ob, int min, int max, void cdecl(*newval)(int now2));
void	cdecl	mod_set_slide(int id, int ob, int min, int max, int val);
int 	cdecl mod_get_prev_opt(void);
void	cdecl set_pal_col(int index, int cmy[3]);
void	cdecl	set_pal_cols(int start_index, int end_index, int *cmy_values);
void	cdecl	get_pal_col(int index, int *cmy3);
void	cdecl	get_pal_cols(int start_index, int end_index, int *cmy_values);


/* Module Globvars */

extern MODULE_LIST	*first_module;
extern OBJECT *omodule, *omodopt;
extern WINDOW	wmodule, wmodopt;
extern DINFO	dmodule, dmodopt;
extern GRAPE_FN grape_mod_info;
extern int		module_id;