/************* INITIALISTATION GEM\AES\VDI + ROUTINES ***************/
#ifndef __GEM_UTIL__
#define __GEM_UTIL__
#include <AES.H>
#include <VDI.H>
#include "../WINDDIAL.SRC/WINDDIAL.H"
#include "../WINDDIAL.SRC/GPRODIAL.H"

typedef struct
{	long ident;
	union
	{	long l;
		int i[2];
		char c[4];
	}v;
}COOKIE;

typedef struct
{	char chemin[80];
	int nb_plan;
	long numero_en_cours;
	MFDB img_en_cours;
	int (*load_img)(char *name,  MFDB *out);
}PARA_IMG_RSC;


typedef struct
{	bool	center;			/*DOIT_ON CENTRER*/
	bool	s_fond;			/*DOIT_ON SAUVER LE FOND*/
	bool 	r_fond;			/*DOIT_ON RESTITUER LE FOND*/
	bool	g_box;			/*GROW_BOX?*/
	bool	change;			/*DOIT_ON FAIRE UN OBJECT_CHANGE*/
	int		num_change;		/*SI OUI QUEL OBJET?*/
	bool	exe_form_do;	/*DOIT_ON FAIRE LE FORM_DO*/
	int		pos_curseur;	/*POS DU CURSEUR*/
	int		nb_obj_redraw;	/*NBR D'OBJET A REDESSINER*/
	int		*lst_objet;		/*LISTE DES OBJETS A REDESSINER*/
}GEST_FORMULAIRE;

typedef struct
{	unsigned int framecol		:4;
	unsigned int textcol		:4;
	unsigned int textmode		:1;
	unsigned int fillpattern	:3;
	unsigned int interiorcol	:4;
}BFOB;

typedef struct
{	char version[5];
	char noeud[13];
	char id[4];
	char public;
	char ligne[50][4];
}MAIL_RESEAU;


extern COOKIE *multitos, *reseau, *type_machine;

/***************************PROTOTYPES*****************************/
extern void gem_init(void); /* Appel‚ une fois au d‚but */
extern void gem_exit(void);

extern COOKIE *get_cookie_p(long id);
extern COOKIE *fcookie(void);
extern COOKIE *ncookie(COOKIE *p);

extern void write_champ(OBJECT arbre[],int index,char string[],int len);
extern void read_champ(OBJECT arbre[],int index,char string[],bool cat);
extern void write_button(OBJECT arbre[],int index,char string[],int len);
extern void read_button(OBJECT arbre[],int index,char string[],bool cat);
extern void write_masque(OBJECT arbre[],int index,char string[],int len);
extern void read_masque(OBJECT arbre[],int index,char string[],bool cat);
extern void write_string(OBJECT arbre[], int index, char string[], int len);
extern void read_string(OBJECT arbre[], int index, char string[], bool cat);

extern int tstetat(OBJECT arbre[],int index);
extern void etat(OBJECT arbre[],int index,char etat);
extern void flags(OBJECT arbre[],int index,char flag);

extern void coord_obj(OBJECT arbre[],int index,int x,int y);
extern void taille_obj(OBJECT arbre[],int index,int x,int y);
extern void centre_newdesk(OBJECT arbre[],
					int lst_obj_ct[], int nb_obj_ct,
					int lst_obj_dt[], int nb_obj_dt
					);
extern void change_fill(OBJECT arbre[],int index,unsigned pattern);
extern void set_color_txt(OBJECT arbre[],int index,int color);
extern char get_color_txt(OBJECT arbre[],int index);
extern ICONBLK* read_icn(OBJECT arbre[],int index);
extern void write_icn(OBJECT arbre[],int index,ICONBLK *icn);
extern CICONBLK* read_cicn(OBJECT arbre[],int index);
extern void write_cicn(OBJECT arbre[],int index,CICONBLK *icn);
extern void objc_routine(OBJECT *arbre, int objet, int cdecl (*routine)(struct __parmblk *parmblock));
extern int cdecl charg_img_rscs(PARMBLK *parmblock);
int determine_nb_plan(int nb_couleur);

extern void en_page(OBJECT *arbre,char obj1,char obj2,char *liste[],int nbelem,int pg,int len);

extern int fileselect(char path[],char nom[]);
extern void vide_mouse(void);
extern int vide_buffer_aes(int ev_mflags, int ev_mtlocount);

extern void redraw_icone(OBJECT arbre[],int objet,int etat);
extern void swappe_icn(OBJECT *arbre_cible,int cible,OBJECT *arbre_source,int source);
extern void swappe_cicn(OBJECT *arbre_cible,int cible,OBJECT *arbre_source,int source);

extern int ident_dbclic(int retour,bool moins);
extern void taille_font(OBJECT arbre[],int index,int taille);

extern size_t gest_pop_up(OBJECT **arbre, int subm[], int nb_subm, int x, int y, int item, int scroll);
OBJECT *creer_pop_up(int nb_objets, int nb_cara);
void detruire_pop_up(OBJECT *pop_up, int nb_objets);

extern int gest_formulaire(OBJECT *arbre,GEST_FORMULAIRE *info_gest);
extern void prepare_gest_form(GEST_FORMULAIRE *info_gest, bool i_center,
					   bool i_s_fond, bool i_r_fond, bool i_g_box,
					   bool i_exe_form_do, bool i_change,
					   int num_obj_change, int i_pos_curseur
					   );
extern void prep_list_redraw(GEST_FORMULAIRE *info_gest, int num_obj1,
					  int num_obj2
					  );

extern void anim_mouse(OBJECT *arbre);

extern bool test_passe(OBJECT *arbre, 
					   int num_champ_titre, int num_champ_passe,
					   char titre[], char mot_de_passe[]
					   );

extern void change_res(bool mode_256);

/*********** TRAITEMENTS RESEAU DES OUVERTURE DE FICHIERS ***********/

/***************** MODE DE VERROUILLAGE POUR LE RESEAU ***********/
#define BLOQUER 0
#define LIBERER 1

int reseau_lock(FILE *pf,int mode);/*BLOQUER ou LIBERER*/
FILE *reseau_fopen(char *nomfic,const char *mode);
int reseau_fclose(FILE *pf);

#endif __GEM_UTIL__