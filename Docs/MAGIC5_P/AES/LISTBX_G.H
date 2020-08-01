typedef	void	(cdecl *SLCT_ITEM)( void *box, OBJECT *tree, struct _lbox_item *item, void *user_data, WORD obj_index, WORD last_state );
typedef	WORD	(cdecl *SET_ITEM)( void *box, OBJECT *tree, struct _lbox_item *item, WORD obj_index, void *user_data, GRECT *rect, WORD first );

typedef struct	_lbox_item
{
	struct _lbox_item *next;	/* Zeiger auf den nÑchsten Eintrag in der Liste */
	WORD	selected;				/* gibt an, ob das Objekt selektiert ist */

	WORD	data1;					/* Daten fÅr das Programm... */
	void	*data2;
	void	*data3;

} LBOX_ITEM;

#define	LBOX_VERT	1			/* Listbox mit vertikalem Slider */
#define	LBOX_AUTO	2			/* Auto-Scrolling */
#define	LBOX_AUTOSLCT	4		/* automatische Darstellung beim Auto-Scrolling */
#define	LBOX_REAL	8			/* Real-Time-Slider */
#define	LBOX_SNGL	16			/* nur ein anwÑhlbarer Eintrag */
#define	LBOX_SHFT	32			/* Mehrfachselektionen mit Shift */
#define	LBOX_TOGGLE	64			/* Status eines Eintrags bei Selektion wechseln */
#define	LBOX_2SLDRS	128		/* Listbox hat einen hor. und einen vertikalen Slider */

#define	lbox_get_visible \
			lbox_get_avis

#define	lbox_get_first \
			lbox_get_afirst
			
#define	lbox_set_slider \
			lbox_set_asldr

#define	lbox_scroll_to \
			lbox_ascroll_to
			
extern void	*lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set, LBOX_ITEM *items, WORD visible_a, WORD first_a,
								  WORD *ctrl_objs, WORD *objs, WORD flags, WORD pause_a, void *user_data, void *dialog,
								  WORD visible_b, WORD first_b, WORD entries_b, WORD pause_b );

extern void	lbox_update( void *box, GRECT *rect );
extern WORD	lbox_do( void *box, WORD obj );
extern WORD	lbox_delete( void *box );

extern WORD	lbox_cnt_items( void *box );
extern OBJECT	*lbox_get_tree( void *box );
extern WORD	lbox_get_avis( void *box );
extern void	*lbox_get_udata( void *box );
extern WORD	lbox_get_afirst( void *box );
extern WORD	lbox_get_slct_idx( void *box );
extern LBOX_ITEM	*lbox_get_items( void *box );
extern LBOX_ITEM	*lbox_get_item( void *box, WORD n );
extern LBOX_ITEM *lbox_get_slct_item( void *box );
extern WORD	lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search );
extern WORD	lbox_get_bvis( void *box );
extern WORD	lbox_get_bentries( void *box );
extern WORD	lbox_get_bfirst( void *box );

extern void	lbox_set_asldr( void *box, WORD first, GRECT *rect );
extern void	lbox_set_items( void *box, LBOX_ITEM *items );
extern void	lbox_free_items( void *box );
extern void	lbox_free_list( LBOX_ITEM *items );
extern void	lbox_ascroll_to( void *box, WORD first, GRECT *box_rect, GRECT *slider_rect );
extern void	lbox_set_bsldr( void *box, WORD first, GRECT *rect );
extern void	lbox_set_bentries( void *box, WORD entries );
extern void	lbox_bscroll_to( void *box, WORD first, GRECT *box_rect, GRECT *slider_rect );


