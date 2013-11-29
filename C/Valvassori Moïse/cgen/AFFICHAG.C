/**********************************
 *		Affiche des trucs … l'‚cran
 *		Composera plus tarsd un module
 *		ind‚pendant
 **********************************/

#include <stdlib.h>
#include <string.h>
#include <support.h>		/* itoa	*/
#include <gemfast.h> 
#include "object.h"
#include "s_malloc.h"
#include "windform.h"

C_OBJ	*curr_aff;			/*	Premier objet affich‚	*/
static int	tab=2;		/*	Tabulation					*/

void	affiche(void);
static int		ecrit(C_OBJ	*obj,	int x,	int *y,	int wc,	int hc,	int ystop);
static void 	ecrit_donnee(C_OBJ *obj,	char *ligne,	int x,	int y,	int wc,	int hc,	int *x1);
static void		ecrit_type(C_OBJ *obj,	char *ligne,	int x,	int y,	int wc,	int hc,	int *x1);
static void		ecrit_procedure(C_OBJ *obj,	char *ligne,	int x,	int y,	int wc,	int hc,	int *x1);
static void		ecrit_bloc(C_OBJ *obj,	char *ligne,	int x,	int y,	int wc,	int hc,	int *x1);
C_OBJ				*cherche_objet(C_OBJ *obj,	int ligne,	int *compte);
void				selectionne_item(WINDFORM_VAR *nw);

extern C_OBJ			*start,	*sel_obj;
extern WINDFORM_VAR	prog;
extern int				VDIhandle,	ap_id,	buf[8],	mousex,	mousey;
extern long				n_obj;

extern int	generation(C_OBJ *obj);

void affiche(void)
{
int		xw,	yw,	ww,	hw,	pxy[4],	x,	y;
int		wcell,	hcell,	attributs[10];
int		dummy;
C_OBJ		*obj;

	vqt_attributes(VDIhandle,	 attributs);
	wcell=attributs[8];
	hcell=attributs[9];

				/* Coordonn‚es zone de travail fenˆtre : */
	wind_get (buf[3],	 WF_WORKXYWH,	 &xw,	 &yw,	 &ww,	 &hw);
	
	vst_alignment (VDIhandle,	 0,	 5,	 &dummy,	 &dummy); /* Texte en haut … gauche */

	x=xw-(prog.w_col-tab*generation(curr_aff))*wcell; y=yw;

	ecrit(curr_aff,	x,	&y,	wcell,	 hcell,	yw+hw);

	if(curr_aff->pere)		/* ce bloc traite le cas o— les parents de curr_aff ne sont pas affiche	*/
	{
		obj=curr_aff->pere;
		while (y<yw+hw && obj->suivant)
		{
			x-=tab*wcell;
			ecrit(obj->suivant,	x,	&y,	wcell,	 hcell,	yw+hw);
			
			if (obj->pere)
				obj=obj->pere;
			else
				y=yw+hw+1;	/*	cree un condition fausse pour sortir de la boucle	*/
		}
	}
}

static int ecrit(C_OBJ	*obj,	int x,	int *y,	int wc,	int hc,	int ystop)
{
char		ligne[256];
int		x1;
int		fin_ecran;

	x1=x;
	
	if (obj)		/* Si l'oject existe	*/
	{
		if (obj==sel_obj)		/*	Si c'est l'objet s‚lectionn‚	*/
			vst_color(VDIhandle,	RED);		/*	Rouge pour ˆtre vu en moyenne res	*/
		else
			vst_color(VDIhandle,	BLACK);
	
		if (obj->type==t_donnee)
			ecrit_donnee(obj,	ligne,	x,	*y,	wc,	hc,	&x1);
		else if (obj->type==t_d_procedure || obj->type==t_procedure)
			ecrit_procedure(obj,	ligne,	x,	*y,	wc,	hc,	&x1);
		else if (obj->type==t_t_type)
			ecrit_type(obj,	ligne,	x,	*y,	wc,	hc,	&x1);
		else if (obj->type==t_bloc)
			ecrit_bloc(obj,	ligne,	x,	*y,	wc,	hc,	&x1);

		if (obj->commentaire)		/*	Afficher le commemtaire	*/
		{
			vst_effects(VDIhandle,	4);	/*	texte italique	*/
			if (x1>x+55*wc)		/*	Le commentaire est si il y a la place … la 50 iŠme colonne	*/
				x1+=5*wc;
			else
				x1=(60*wc) +x;
				
			v_gtext (VDIhandle,	 x1,	 *y,	 obj->commentaire);  /* Afficher la ligne */
		}
		
		*y+=hc;
		if(*y<=ystop)	/* Si on est pas … la fin de l'‚cran	*/
		{
		
			if (obj->fils)
				fin_ecran=ecrit(obj->fils,	x+tab*wc,	y,	wc,	hc,	ystop);			/* g‚nial c'est r‚cursif	*/
			if (obj->suivant)
				fin_ecran=ecrit(obj->suivant,	x,	y,	wc,	hc,	ystop);			/* g‚nial c'est r‚cursif	*/
		}
	}
}

static void ecrit_donnee(C_OBJ *obj,	char *ligne,	int x,	int y,	int wc,	int hc,	int *x1)
{
int dummy[10];

	if (obj->spec.donnee.d_flag & 2)
		strcpy(ligne,	"Externe ");
	else
		strcpy(ligne,	"");
	
	if (obj->spec.donnee.d_tab !=0)
	{
		strcat(ligne,	"tableau de ");
		strcat(ligne,	_ltoa(obj->spec.donnee.d_tab,	dummy,	10));
		strcat(ligne,	" ");
	}
	
	if (obj->spec.donnee.d_flag & 8)
		strcat(ligne,	"non sign‚ ");
	
	if (obj->spec.donnee.d_flag & 4)
		strcat(ligne,	"long ");
	
	switch(obj->spec.donnee.d_type)
	{
		case t_int:
			strcat(ligne,	"entier ");
			break;
		case t_char:
			strcat(ligne,	"carac. ");
			break;
		case t_reel:
			strcat(ligne,	"reŠl ");
			break;
		case t_nul:
			strcat(ligne,	"nul ");
			break;
		case t_struct:
			strcat(ligne,	"structure ");
			break;
		case t_union:
			strcat(ligne,	"union ");
			break;
		case t_autre:
			if (obj->spec.donnee.d_autre)
				strcat(ligne,	((C_OBJ*)(obj->spec.donnee.d_autre))->spec.type.tt_nom);
			strcat(ligne,	" ");
			break;
	}
	if (obj->spec.donnee.d_flag & 1)
		strcat(ligne,	"*");
		
	vst_effects(VDIhandle,	1);	/*	texte gras	*/
	v_gtext (VDIhandle,	 *x1,	 y,	 ligne);  /* Afficher la ligne */
	*x1+=wc*strlen(ligne);

	if (obj->spec.donnee.d_nom)		/*	affiche le nom	*/
	{
		vst_effects(VDIhandle,	0);	/*	texte normal	*/
		v_gtext (VDIhandle,	 *x1,	 y,	 obj->spec.donnee.d_nom);  /* Afficher la ligne */
		*x1+=wc*strlen(obj->spec.donnee.d_nom);
	}
	if (obj->spec.donnee.d_vi)			/*	affiche la valeur initiale	*/
	{
		vst_effects(VDIhandle,	0);	/*	texte normal	*/
		strcpy(ligne,	" = ");
		strcat(ligne,	obj->spec.donnee.d_vi);
		v_gtext (VDIhandle,	 *x1,	 y,	 ligne);  /* Afficher la ligne */
		*x1+=wc*strlen(ligne);
	}
}

static void ecrit_procedure(C_OBJ *obj,	char *ligne,	int x,	int y,	int wc,	int hc,	int *x1)
{
int dummy;

	if (obj->spec.proc.pr_flag & 2)
		strcpy(ligne,	"Externe ");
	else
		strcpy(ligne,	"");
	
	if (obj->spec.proc.pr_flag & 8)
		strcat(ligne,	"non sign‚ ");
	
	if (obj->spec.proc.pr_flag & 4)
		strcat(ligne,	"long ");
	
	switch(obj->spec.proc.pr_type)
	{
		case t_int:
			strcat(ligne,	"entier ");
			break;
		case t_char:
			strcat(ligne,	"carac. ");
			break;
		case t_reel:
			strcat(ligne,	"reŠl ");
			break;
		case t_nul:
			if (obj->spec.proc.pr_flag!=0 && obj->spec.proc.pr_flag!=2)	/* si rien que nul on affiche rien*/
				strcat(ligne,	"nul ");
			break;
		case t_autre:
			if (obj->spec.proc.pr_autre)
				strcat(ligne,	((C_OBJ*)(obj->spec.proc.pr_autre))->spec.type.tt_nom);
			strcat(ligne,	" ");
			break;
	}
	if (obj->spec.proc.pr_flag & 1)
		strcat(ligne,	"*");
		
	vst_effects(VDIhandle,	1);	/*	texte gras	*/
	v_gtext (VDIhandle,	 *x1,	 y,	 ligne);  /* Afficher la ligne */
	*x1+=wc*strlen(ligne);
	
	if (obj->spec.proc.pr_nom)		/*	affiche le nom	*/
	{
		vst_effects(VDIhandle,	0);	/*	texte normal	*/
		v_gtext (VDIhandle,	 *x1,	 y,	 obj->spec.proc.pr_nom);  /* Afficher la ligne */
		*x1+=wc*strlen(obj->spec.proc.pr_nom);
	}
}

static void ecrit_bloc(C_OBJ *obj,	char *ligne,	int x,	int y,	int wc,	int hc,	int *x1)
{
	if (obj->spec.bloc)		/*	affiche le nom	*/
	{
		vst_effects(VDIhandle,	3);	/*	texte GRAS leger */
		v_gtext (VDIhandle,	 *x1,	 y,	 obj->spec.bloc);  /* Afficher la ligne */
		*x1+=wc*strlen(obj->spec.bloc);
	}
}

static void ecrit_type(C_OBJ *obj,	char *ligne,	int x,	int y,	int wc,	int hc,	int *x1)
{
int dummy;

	vst_effects(VDIhandle,	2);	/*	texte leger	*/
	strcpy(ligne,	"Type ");
	v_gtext (VDIhandle,	 *x1,	 y,	 ligne);  /* Afficher la ligne */
	*x1+=wc*strlen(ligne);
	
	if (obj->spec.type.tt_nom)		/*	affiche le nom	*/
	{
		vst_effects(VDIhandle,	1);	/*	texte gras	*/
		v_gtext (VDIhandle,	 *x1,	 y,	 obj->spec.type.tt_nom);  /* Afficher la ligne */
		*x1+=wc*strlen(obj->spec.type.tt_nom);
	}
	vst_effects(VDIhandle,	0);	/*	texte normal	*/
	strcpy(ligne,	" : ");

	if (obj->spec.type.tt_flag & 8)
		strcat(ligne,	"non sign‚ ");
	
	if (obj->spec.type.tt_flag & 4)
		strcat(ligne,	"long ");
	
	switch(obj->spec.type.tt_type)
	{
		case t_int:
			strcat(ligne,	"entier ");
			break;
		case t_char:
			strcat(ligne,	"carac. ");
			break;
		case t_reel:
			strcat(ligne,	"reŠl ");
			break;
		case t_nul:
			strcat(ligne,	"nul ");
			break;
		case t_struct:
			strcat(ligne,	"structure ");
			break;
		case t_union:
			strcat(ligne,	"union ");
			break;
		case t_autre:
			if (obj->spec.type.tt_autre)
				strcat(ligne,	((C_OBJ*)(obj->spec.type.tt_autre))->spec.type.tt_nom);
			strcat(ligne,	" ");
			break;

	}

	v_gtext (VDIhandle,	 *x1,	 y,	 ligne);  /* Afficher la ligne */
	*x1+=wc*strlen(ligne);
}

C_OBJ *cherche_objet(C_OBJ *obj,	int ligne,	int *compte)
{
C_OBJ *dummy;


	if(*compte!=ligne)
	{
		if(ligne>*compte)
			(*compte)++;	/* on ne peut pas directement l'intŠgrer dans cherche_objet car il sera incr‚menter apr‚s l'appel	*/
		else if(ligne<*compte)
			(*compte)--;

		if (obj->fils)
			dummy=cherche_objet(obj->fils,	ligne,	compte);			/* r‚cursif	*/
		if(*compte==-1)
			return dummy;

		if (obj->suivant)
			dummy=cherche_objet(obj->suivant,	ligne,	compte);		/*	r‚cursif	*/
		if(*compte==-1)
			return dummy;
	}
	else
	{
		*compte=-1;
		return obj;
	}
}

void selectionne_item(WINDFORM_VAR *nw)
{
int x,	y;
int xw,	 yw,	 ww,	 hw;
int wc,	hc;
int attr[10];
C_OBJ	*obj;

	vqt_attributes(VDIhandle,	 attr);

		/* Coordonn‚es zone de travail :	*/
	wind_get (nw->w_handle,	 WF_WORKXYWH,	 &xw,	 &yw,	 &ww,	 &hw);
	hc=hw/attr[9];
	y=(mousey-yw)/attr[9];

	if(nw->w_lin+y<=n_obj)
	{
		y +=nw->w_lin;
		obj=cherche_objet(curr_aff,	nw->w_lin,	&y);
		if (obj!=sel_obj)
		{
			sel_obj=obj;
			redraw (xw,	 yw,	 ww,	 hw);	/* R‚affichage	*/
		}
	}
}
