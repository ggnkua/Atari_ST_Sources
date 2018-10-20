#if  !defined( __LAYER__ )
#define __LAYER__

#if !defined(__LAY_AND_MASK__)
#define __LAY_AND_MASK__
typedef struct
{
	int		id;				/* Eine eindeutige ID fÅr den Undo-Puffer */
	int		changes;	/* énderungen vorgenommen (draw/clr etc..) */
	char	name[11];	/* 10 Zeichen Name 0-terminiert */
	int		type;			/* 0=transparent, 1=deckend, 2=deckend incl. weiû */
	int		selected;	/* !=0: Selektiert */
	int		visible;	/* !=0: sichtbar */
	int		draw;			/* !=0: reinzeichnen */
	int		solo;			/* !=0: Nur diese Ebene sichtbar & zeichnen */
	int		width;
	int		height;
	int		word_width;
	void	*red;
	void	*yellow;
	void	*blue;
}LAYER;

typedef struct
{
	int		id;				/* Einmalige Kennung */
	void *mask; 		/* Zeiger auf 8-Bit Plane */
	char	name[11];	/* 10 Zeichen Name 0-terminiert */
	int		col;			/* Farbe der Maske im AES-Objekt-Code */
}MASK;
#endif

typedef struct
{
	int id;
	int selected;
	int visible;
	int draw;
	int solo;
}LAY_MEM;

typedef struct _LAY_LIST
{
	struct	_LAY_LIST *prev;
	LAYER		this;
	struct 	_LAY_LIST	*next;
}LAY_LIST;

typedef struct
{
	LAY_MEM	lm[254];
}LAY_STORE;


/* Layer Functions */

void	init_layob(void);
LAYER *find_layer(int a);
LAYER *find_layer_id(int id);
LAY_LIST *find_lay_list(int a);
LAY_LIST *find_lay_list_id(int id);
void	insert_layer_win(void);
void	modify_layer_win(void);
void	dial_newlay(int ob);
void	modify_layer(void);
void	insert_layer(void);
int		count_sel_layers(void);
int		count_vis_layers(void);
void	delete_layer(void);
void	import_layer(void);
void	clear_layer(void);
void	dial_clear(int ob);
void	clear_edit(void);
void	clear_selected(void);
void	cls(LAYER *lay);
void	draw_layob(void);
int		count_layers(void);
int		move_layer(int src, int dst);
void	dial_copylay(int ob);
void	copy_layer(int src, int dst, int how);
void	copy_layer_win(void);
void	copy_layer_init(void);
void	dial_layer(int ob, int klicks);
int		mgraf_dragbox(int src, int w, int h, int x, int y, int *dst);
void	redraw_pic(void);
int		dial_store(void);
int		get_lay_store(int num);
void	put_lay_store(int num);
int		layer_popup(OBJECT *tree, int ob, int disable_id);

/* Layer Globvars */

extern int layer_id, layers_off;
extern LAYER	*mod_lay;
extern LAY_STORE lay_store[11];
extern LAY_LIST	*first_lay, *act_lay, *painted_lay;

extern OBJECT *ocopylay, *onewlay, *oclear;
extern WINDOW wcopylay, wnewlay, wclear;
extern DINFO	dcopylay, dnewlay, dclear;


#endif