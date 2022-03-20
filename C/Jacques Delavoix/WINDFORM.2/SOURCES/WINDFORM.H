/************************************************************************/
/*																		*/
/*	WINDFORM.H : D‚finitions utilis‚es par les proc‚dures WIND_FORM.	*/
/*																		*/
/************************************************************************/

#define min(A, B) ((A) < (B) ? (A) : (B))
#define max(A, B) ((A) > (B) ? (A) : (B))

#define TRUE 1
#define FALSE 0

/* #define _GemParBlk _VDIParBlk	*/

#define flag_multitache _GemParBlk.global[1]

typedef struct
{
	OBJECT	*adr_form;	/* adresse du formulaire */
	int		w_handle;	/* handle de fenˆtre, sert aussi de t‚moin d'ouverture. */
	int		w_x;		/* Coordonn‚es et dimensions de la fenˆtre. */
	int		w_y;
	int		w_w;
	int		w_h;
	int		offset;		/* D‚calage x et y pour boite "OUTLINED". */
	int		edit_objc;	/* Objet ‚ditable courant. */
	int		edit_pos;	/* Position courante du curseur d'‚dition. */
	char	reduced;	/* Indique si la fenˆtre est r‚duite … la barre
						   de d‚placement ou non (R‚mi VANEL). */
} WINDFORM_VAR;

#define FW_ATTRIB	NAME|CLOSER|MOVER|FULLER
#define OPEN_DIAL	8192
#define CLOSE_DIAL	-1

#define NO_BISTABLE		(DEFAULT | EXIT | EDITABLE | RBUTTON)
#define SMALL_FLAG		0x400	/* Mini Bouton	*/

/* *** Prototypes des Fonctions de Dialogue : *** */

int load_rsc(char *rsc_name, int wind_fail);
void init_var(WINDFORM_VAR *ptr_var, int form_index, int inf_x, int inf_y);
void open_dialog(WINDFORM_VAR *ptr, char *w_title, int edit_index);
int windform_do(WINDFORM_VAR *ptr, int evnt);
void close_dialog(WINDFORM_VAR *ptr);
void redraw_editable(WINDFORM_VAR *ptr_var, int index);

void draw(WINDFORM_VAR *ptr_var, int ob);	/* remplace objc_draw */
void change(WINDFORM_VAR *ptr_var, int ob, int state, int flag);
/* remplace objc_change */

/*	**	Autres fonctions ........	**	*/

char *strpcpy(char *dest, char *start, char *stop);
int rc_intersect(GRECT *p1, GRECT *p2);
int stdkey(int key_code);
char *rsrc_get_string(int index);

