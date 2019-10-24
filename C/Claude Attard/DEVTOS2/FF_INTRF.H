typedef union cont {		/* DEFINITION DU CONTENU D'UNE FENETRE */
	OBJECT *form;						/* Si fenˆtre formulaire */
	char **lignes;					/* Si texte */
} Cont;

typedef struct wind {		/* DEFINITION D'UNE FENETRE */
	int hg;									/* Handle GEM */
	int attr;								/* Attributs GEM */
	int type;								/* Type formulaire ou texte */
	int full;								/* Flag de pleine ouverture */
	int last;								/* Flag de derniŠre fenˆtre */
	GRECT curr;							/* Position courante */
	Cont cont;							/* Contenu de la fenˆtre */
	int nbrel;							/* Nbre de lignes du texte */
	char *title;						/* Pointeur sur le titre */
	long wtot;							/* Largeur totale */
	long htot;							/* Hauteur totale */
	long lin;								/* 1ø ligne de pixels */
	long col;								/* 1ø colonne de pixels */
} Wind;

#define WTYPFORM 0
#define WTYPTEXT 1

void dcl_wind (int nbre);
int find_index (int wh);
int cdecl userdf (PARMBLK *para);
int dialog (int flags, OBJECT *address);
int parent (OBJECT *adr, int object);
void stdkey (unsigned char *k);
char *trim (char *str);
int m_title (OBJECT *adresse, int option);
int rc_intersect (GRECT *p1, GRECT *p2);
void set_clip (int clip_flag, GRECT *area);
void open_file (char *file, int fen);
void draw_object (int index, int object);
void redraw (void);
void fulled (void);
void arrow (void);
void hslider (void);
void vslider (void);
void sliders (int index);

