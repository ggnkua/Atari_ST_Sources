void dial_print(int ob);
void print_window(void);
void new_pr_preview(void);

typedef struct _PLIST
{
	struct _PLIST	*next;
	
	int			id;				/* ID der Workstation */
	char		name[38];	/* Name des Treibers (36 Zeichen)*/
	int			bit;			/* Farbtiefe in Bit */
	int			h_res;		/* Horizontale Aufl”sung in DPI */
	int			v_res;		/* Vertikale Aufl”sung in DPI */
	
	int			width;		/* Bedruckbare Breite in Pixeln */
	int			height;		/* Bedruckbare H”he in Pixeln */
	
	int			ro;				/* Rand oben (Pixel) */
	int			ru;				/* Rand unten */
	int			rl;				/* Rand links */
	int			rr;				/* Rand rechts */
}PLIST;

extern OBJECT *oprint;
extern WINDOW wprint;
extern DINFO dprint;