/************************************
 *     GŠre la partie commune du code
 *************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <gemfast.h> 
#include "object.h"
#include "s_malloc.h"
#include "windform.h"

C_OBJ	*start=NULL,	*curr=NULL,	*sel_obj=NULL;
WINDFORM_VAR prog;
long n_obj;			/* Nombre n'object	*/

extern int				VDIhandle,	ap_id,	buf[8];
extern C_OBJ			*curr_aff;
extern WINDFORM_VAR	donnee_var,type_var,fct_var;

void	nouveau(void);
void	nouvelle_donnee(int);
void	nouvelle_fonction(int);
void	nouveau_prototype(int);
void	nouveau_type(int);
void	efface(C_OBJ *obj,	C_OBJ *obj_fin);
void	efface_objet(void);
void	modif_objet(C_OBJ *obj);
void	modif_objet_2(void);
int	generation(C_OBJ *obj);
void	cree_fils_vide(C_OBJ *obj);
int	liste_type(C_OBJ ***liste);
static int	liste_type1(C_OBJ *obj,int n,int type);
static void	liste_type2(C_OBJ *obj,C_OBJ **liste,int type);
static void trier_liste_type(C_OBJ **liste,int n);
int	liste_var(C_OBJ ***liste);
static void trier_liste_var(C_OBJ **liste,int n);

extern void		open_wind(WINDFORM_VAR *nw);
extern char *	messag(int mes);
extern void		init_f_donnee(char *nom,	char *commen,	char *vi,	TYPE_D type,	long tab,	int flag,	C_OBJ *autre);
extern void		init_f_fct(char *nom,	char *commen,	TYPE_D type,	int flag,	C_OBJ *autre);
extern void		init_f_type(char *nom,	char *commen,	TYPE_D type,	int flag,	C_OBJ *autre);
extern void		return_f_donnee(char *nom,	char *commen,	char *vi,	TYPE_D *type,	long *tab,	int *flag, C_OBJ ** autre);
extern void		return_f_fct(char *nom,	char *commen,	TYPE_D *type,	int *flag, C_OBJ ** autre);
extern void		return_f_type(char **nom,	char **commen,	TYPE_D *type,	int *flag,	C_OBJ **autre);
extern void		sliders (WINDFORM_VAR *nw);
extern void		w_redraw(WINDFORM_VAR w);
extern void		f_donnee_state(int state);

void nouveau(void)
{
C_OBJ	*new;

	efface(start,	NULL);

	start=MALLOC(L_C_OBJ);			/*	creer deux object	*/
	new=MALLOC(L_C_OBJ);

	start->type=t_bloc;		/*	Start qui est un bloc		*/
	start->prec=NULL;					/*	qui contient la DE			*/
	start->suivant=NULL;
	start->fils=new;
	start->pere=NULL;
	start->spec.bloc=MALLOC(3);				/*		d‚clare le nom de Start	*/
		strcpy(start->spec.bloc,	"DE");
	start->commentaire=MALLOC(30);					/*		d‚clare le commentaire	*/
		strcpy(start->commentaire,	"D‚claration de l\47environement");

	curr=new;
	new=MALLOC(L_C_OBJ);
	curr->commentaire=NULL;			/*	et curr,	 (DE) TYPE	*/
	curr->type=t_bloc;
	curr->prec=NULL;
	curr->suivant=new;
	new->prec=curr;
	curr->fils=NULL;
	curr->pere=start;
	curr->spec.bloc=MALLOC(5);				/*		d‚clare le nom	*/
		strcpy(curr->spec.bloc,	"Type");
	curr->commentaire=MALLOC(22);					/*		d‚clare le commentaire	*/
		strcpy(curr->commentaire,	"D‚claration des types");

	curr=new;
	new=MALLOC(L_C_OBJ);
	curr->commentaire=NULL;			/*	et curr,	 DE des Variables	*/
	curr->type=t_bloc;
	curr->prec=NULL;
	curr->suivant=new;
	new->prec=curr;
	curr->fils=NULL;
	curr->pere=start;
	curr->spec.bloc=MALLOC(19);				/*		d‚clare le nom	*/
		strcpy(curr->spec.bloc,	"Variables globales");
	curr->commentaire=MALLOC(35);					/*		d‚clare le commentaire	*/
		strcpy(curr->commentaire,	"D‚claration des variables globales");

	curr=new;
	curr->commentaire=NULL;			/*	et curr,	 DE prototype	*/
	curr->type=t_bloc;
	curr->prec=NULL;
	curr->suivant=NULL;
	new->prec=curr;
	curr->fils=NULL;
	curr->pere=start;
	curr->spec.bloc=MALLOC(9);				/*		d‚clare le nom	*/
		strcpy(curr->spec.bloc,	"Fonction");
	curr->commentaire=MALLOC(27);					/*		d‚clare le commentaire	*/
		strcpy(curr->commentaire,	"D‚claration des fonctions");

	curr_aff=start;
	sel_obj=NULL;
		
	prog.w_attr=NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|0x2000|SMALLER;
	prog.adr_form=messag(0);
	n_obj=4;

	nouvelle_fonction(0);
	open_wind(&prog);
}

void nouvelle_donnee(int where)
{
	if (where==0)
		cree_fils_vide( ((C_OBJ*)(start->fils))->suivant );
	else if(where==1)
		cree_fils_vide( curr);

	if (curr)
	{
		curr->spec.donnee.d_nom=NULL;
		curr->commentaire=NULL;
		curr->spec.donnee.d_vi=NULL;
		return_f_donnee(&curr->spec.donnee.d_nom,	&curr->commentaire,	&curr->spec.donnee.d_vi,	
							&curr->spec.donnee.d_type,	&curr->spec.donnee.d_tab,	&curr->spec.donnee.d_flag,	&curr->spec.donnee.d_autre);

		if(sel_obj)									/*	Si on a s‚lectionnner un objet	*/
		{
			if(sel_obj->type==t_donnee)
			{
				if( ((C_OBJ*)(curr->prec))->suivant)
					if( ((C_OBJ*)((C_OBJ*)(curr->prec))->suivant)->type==t_vide)
						((C_OBJ*)(curr->prec))->suivant=NULL;		/*	on casse la chaine	*/

				curr->prec=sel_obj;									/*	et la reconstruit		*/
				if(sel_obj->suivant) {
					curr->suivant=sel_obj->suivant;
					((C_OBJ*)(curr->suivant))->prec=curr;
				}
				curr->pere=sel_obj->pere;
				sel_obj->suivant=curr;
			}
		}

		curr->type=t_donnee;
		if (where==1)
			sel_obj=curr;

		if (curr->spec.type.tt_type==t_struct)
			new_struct();
		if (curr->spec.type.tt_type==t_union)
			new_union();

		w_redraw(prog);
		sliders(&prog);
	}
}

void nouveau_type(int where)
{
	if (where==0)
		cree_fils_vide(start->fils);
	else if(where==1)
		cree_fils_vide( curr);

	if (curr)
	{
		curr->spec.type.tt_nom=NULL;
		curr->commentaire=NULL;
		return_f_type(&curr->spec.type.tt_nom,	&curr->commentaire,
							&curr->spec.type.tt_type,	&curr->spec.type.tt_flag, &curr->spec.type.tt_autre);

		if(sel_obj)									/*	Si on a s‚lectionnner un objet	*/
		{
			if (sel_obj->type==t_t_type)
			{
				if( ((C_OBJ*)(curr->prec))->suivant)
					if( ((C_OBJ*)((C_OBJ*)(curr->prec))->suivant)->type==t_vide)
						((C_OBJ*)(curr->prec))->suivant=NULL;		/*	on casse la chaine	*/
				
				curr->prec=sel_obj;									/*	et la reconstruit		*/
				if(sel_obj->suivant) {
					curr->suivant=sel_obj->suivant;
					((C_OBJ*)(curr->suivant))->prec=curr;
				}
				curr->pere=sel_obj->pere;
				sel_obj->suivant=curr;
			}
		}

		curr->type=t_t_type;
		if (where==1)
			sel_obj=curr;

		if (curr->spec.type.tt_type==t_struct)
			new_struct();
		if (curr->spec.type.tt_type==t_union)
			new_union();

		w_redraw(prog);
		sliders(&prog);
	}
}

void nouveau_prototype(int where)
{
	if (where==0)
		cree_fils_vide( ((C_OBJ*)((C_OBJ*)(start->fils))->suivant)->suivant );
	else if(where==1)
		cree_fils_vide( curr);

	if (curr)
	{
		curr->spec.proc.pr_nom=NULL;
		curr->commentaire=NULL;
		return_f_fct(&curr->spec.proc.pr_nom,	&curr->commentaire,
							&curr->spec.proc.pr_type,	&curr->spec.proc.pr_flag,	&curr->spec.proc.pr_autre);

		if(sel_obj)									/*	Si on a s‚lectionnner un objet	*/
		{
			if(sel_obj->type==t_d_procedure)
			{
				if( ((C_OBJ*)(curr->prec))->suivant)
					if( ((C_OBJ*)((C_OBJ*)(curr->prec))->suivant)->type==t_vide)
						((C_OBJ*)(curr->prec))->suivant=NULL;		/*	on casse la chaine	*/

				curr->prec=sel_obj;									/*	et la reconstruit		*/
				if(sel_obj->suivant) {
					curr->suivant=sel_obj->suivant;
					((C_OBJ*)(curr->suivant))->prec=curr;
				}
				curr->pere=sel_obj->pere;
				sel_obj->suivant=curr;
			}
		}

		curr->type=t_d_procedure;
		if (where==1)
			sel_obj=curr;

		w_redraw(prog);
		sliders(&prog);

		f_donnee_state(TRUE);
		init_f_donnee(NULL,	NULL,	NULL,	-1,	0,	0,	NULL);
		donnee_var.w_lin=3;		/*	modifie donn‚e	*/
		f_donnee(OPEN_DIAL);

	}
}

void nouvelle_fonction(int where)
{
C_OBJ *obj,*new,*new1;

	if (where==0)
		if(start->suivant)
			obj=start->suivant;
		else
		{
			obj=MALLOC(L_C_OBJ);
			start->suivant=obj;
		}

	new=MALLOC(L_C_OBJ);

	obj->prec=start;
	obj->pere=NULL;
	obj->suivant=NULL;
	obj->fils=new;
	obj->type=t_procedure;
	obj->commentaire=NULL;
	obj->spec.proc.pr_nom=MALLOC(21);
		strcpy(obj->spec.proc.pr_nom,"Proc‚dure principale");
	obj->spec.proc.pr_flag=0;
	obj->spec.proc.pr_autre=NULL;
	obj->spec.proc.pr_type=t_nul;

	curr=new;
	new=MALLOC(L_C_OBJ);
	new1=MALLOC(L_C_OBJ);
	curr->commentaire=NULL;			/*	et curr,	 paramŠtre	*/
	curr->type=t_bloc;
	curr->prec=NULL;
	curr->suivant=new;
	new->prec=curr;
	curr->fils=new1;
	curr->pere=obj;
	curr->spec.bloc=MALLOC(10);				/*		d‚clare le nom	*/
		strcpy(curr->spec.bloc,	"ParamŠtre");
	curr->commentaire=NULL;

	new1->commentaire=NULL;			/*	et curr,	 1 ier paramŠtre	*/
	new1->type=t_donnee;
	new1->prec=NULL;
	new1->suivant=NULL;
	new1->fils=NULL;
	new1->pere=curr;
	new1->spec.donnee.d_type=t_nul;
	new1->spec.donnee.d_nom=MALLOC(10);				/*		d‚clare le nom	*/
		strcpy(new1->spec.donnee.d_nom,	"paramŠtre");
	new1->spec.donnee.d_vi=NULL;
	new1->spec.donnee.d_tab=0;
	new1->spec.donnee.d_flag=0;
	new1->spec.donnee.d_autre=NULL;
	new1->commentaire=NULL;

	curr=new;
	new=MALLOC(L_C_OBJ);
	curr->commentaire=NULL;			/*	et curr,	 DE loc	*/
	curr->type=t_bloc;
	curr->prec=curr;
	curr->suivant=NULL;
	new->prec=curr;
	curr->fils=new;
	curr->pere=obj;
	curr->spec.bloc=MALLOC(3);				/*		d‚clare le nom	*/
		strcpy(curr->spec.bloc,	"DE");
	curr->commentaire=MALLOC(19);
		strcpy(curr->commentaire,	"D‚claration locale");

	obj=curr;
	curr=new;
	new=MALLOC(L_C_OBJ);
	curr->commentaire=NULL;			/*	et curr,	 (DE) TYPE	*/
	curr->type=t_bloc;
	curr->prec=NULL;
	curr->suivant=new;
	new->prec=curr;
	curr->fils=NULL;
	curr->pere=obj;
	curr->spec.bloc=MALLOC(5);				/*		d‚clare le nom	*/
		strcpy(curr->spec.bloc,	"Type");
	curr->commentaire=MALLOC(22);					/*		d‚clare le commentaire	*/
		strcpy(curr->commentaire,	"D‚claration des types");

	curr=new;
	curr->commentaire=NULL;			/*	et curr,	 DE des Variables	*/
	curr->type=t_bloc;
	curr->prec=NULL;
	curr->suivant=NULL;
	new->prec=curr;
	curr->fils=NULL;
	curr->pere=obj;
	curr->spec.bloc=MALLOC(19);				/*		d‚clare le nom	*/
		strcpy(curr->spec.bloc,	"Variables globales");
	curr->commentaire=MALLOC(34);					/*		d‚clare le commentaire	*/
		strcpy(curr->commentaire,	"D‚claration des variables locales");

	n_obj+=6;
}

void cree_fils_vide(C_OBJ *obj)
{
C_OBJ *no,*ni;

	if (obj->fils)
	{
		ni=obj->fils;

		while(ni->suivant!=NULL)
			ni=ni->suivant;

		no=MALLOC(L_C_OBJ);						/*	Cr‚e l'objet suivant	*/
		no->commentaire=NULL;
		no->type=t_vide;
		no->suivant=NULL;
		no->fils=NULL;
		no->pere=obj;
		no->prec=ni;
		ni->suivant=no;
		curr=no;
		sel_obj==NULL;
		n_obj++;
		return ni;
	}
	else
	{
		no=MALLOC(L_C_OBJ);						/*	Cr‚e l'objet suivant	*/
		no->prec=NULL;
		no->commentaire=NULL;
		no->type=t_vide;
		no->suivant=NULL;
		no->fils=NULL;
		no->pere=obj;
		obj->fils=no;
		sel_obj=NULL;
		curr=no;
		n_obj++;
		return NULL;
	}
}

void efface(C_OBJ *obj,	C_OBJ *obj_fin)
{
	if (obj)		/* Si l'oject existe	*/
	{
		if (obj->commentaire)		/*	efface le commemtaire	*/
			FREE(obj->commentaire);

		if (obj->type==t_donnee)	/*	si c'est une donn‚e	*/
		{
			if (obj->spec.donnee.d_nom)		/*	efface le nom	*/
				FREE(obj->spec.donnee.d_nom);
			if (obj->spec.donnee.d_vi)			/*	efface la valeur initiale	*/
				FREE(obj->spec.donnee.d_vi);
		}
		else if (obj->type==t_d_procedure || obj->type==t_procedure)	/*	si c'est une procedure	*/
		{
			if (obj->spec.proc.pr_nom)		/*	efface le nom	*/
				FREE(obj->spec.proc.pr_nom);
		}
		else if (obj->type==t_t_type)	/*	si c'est un type	*/
		{
			if (obj->spec.type.tt_nom)		/*	efface le nom	*/
				FREE(obj->spec.type.tt_nom);
		}
		else if (obj->type==t_bloc)	/*	si c'est un bloc	*/
		{
			if (obj->spec.bloc)		/*	efface le nom	*/
				FREE(obj->spec.bloc);
		}

		if (obj->prec)
			((C_OBJ *)(obj->prec))->suivant=obj->suivant;

		if (obj->pere)
			if ( ((C_OBJ*)(obj->pere))->fils==obj)
				((C_OBJ*)(obj->pere))->fils=obj->suivant;
		
		if (obj->fils)
			efface(obj->fils,	obj_fin);			/* g‚nial c'est r‚cursif	*/
		if (obj->suivant)
		{
			if (obj==start)						/*	r‚-affecte start et curr_aff	*/
				start=obj->suivant;
			if (obj==curr_aff)
				curr_aff=obj->suivant;
				
			((C_OBJ *)(obj->suivant))->prec=obj->prec;
			if (obj!=obj_fin)
				efface(obj->suivant,	obj_fin);		/* g‚nial c'est r‚cursif	*/
		}

		FREE(obj);	/*	enfin efface l'objet en question		*/
		n_obj--;
	}
}

void efface_objet(void)
{
	if(sel_obj)
	{
		efface(sel_obj,	sel_obj);
		sel_obj=NULL;		/*	et oui,	 on l'a effacer	*/

		w_redraw(prog);
	}
}

void modif_objet(C_OBJ *obj)
{
	if(obj->type==t_donnee)
 	{
		init_f_donnee(obj->spec.donnee.d_nom,	obj->commentaire,	obj->spec.donnee.d_vi,	
								obj->spec.donnee.d_type,	obj->spec.donnee.d_tab,	obj->spec.donnee.d_flag,	obj->spec.donnee.d_autre);
		donnee_var.w_lin=2;		/*	modifie donn‚e	*/
		f_donnee(OPEN_DIAL);
	}
	else if(obj->type==t_t_type)
 	{
		init_f_type(obj->spec.type.tt_nom,	obj->commentaire,
								obj->spec.type.tt_type,	obj->spec.type.tt_flag, obj->spec.type.tt_autre);
		type_var.w_lin=2;		/*	modifie donn‚e	*/
		f_type(OPEN_DIAL);
	}
	else if(obj->type==t_d_procedure)
 	{
		init_f_fct(obj->spec.proc.pr_nom,	obj->commentaire,
								obj->spec.proc.pr_type,	obj->spec.proc.pr_flag,	obj->spec.proc.pr_autre);
		fct_var.w_lin=2;		/*	modifie donn‚e	*/
		f_fct(OPEN_DIAL);
	}
	
}

void modif_objet_2(void)
{
	if(sel_obj->type==t_donnee)
	{
		return_f_donnee(&sel_obj->spec.donnee.d_nom,	&sel_obj->commentaire,	&sel_obj->spec.donnee.d_vi,	
							&sel_obj->spec.donnee.d_type,	&sel_obj->spec.donnee.d_tab,	&sel_obj->spec.donnee.d_flag,	&sel_obj->spec.donnee.d_autre);
	}
	else if(sel_obj->type==t_t_type)
	{
		return_f_type(&sel_obj->spec.type.tt_nom,	&sel_obj->commentaire,
							&sel_obj->spec.type.tt_type,	&sel_obj->spec.type.tt_flag,	&sel_obj->spec.type.tt_autre);
	}	
	else if(sel_obj->type==t_d_procedure)
	{
		return_f_fct(&sel_obj->spec.proc.pr_nom,	&sel_obj->commentaire,
							&sel_obj->spec.proc.pr_type,	&sel_obj->spec.proc.pr_flag,	&sel_obj->spec.proc.pr_autre);
	}
	w_redraw(prog);
}

int generation(C_OBJ *obj)
{
int generation=0;
C_OBJ *obj1;

	obj1=obj;

	while(obj1->pere)		/* Tant qu'il y a un pŠre			*/
	{
		generation++;		/*	on incr‚mente les g‚n‚rations	*/
		obj1=obj1->pere;
	}
	return generation;
}

void new_struct(void)
{
		f_donnee_state(FALSE);
		init_f_donnee(NULL,	NULL,	NULL,	-1,	0,	0,	NULL);
		donnee_var.w_lin=3;		/*	modifie donn‚e	*/
		f_donnee(OPEN_DIAL);
}

void new_union(void)
{
		f_donnee_state(TRUE);
		init_f_donnee(NULL,	NULL,	NULL,	-1,	0,	0,	NULL);
		donnee_var.w_lin=3;		/*	modifie donn‚e	*/
		f_donnee(OPEN_DIAL);
}

int liste_type(C_OBJ ***liste)
{
int n,a;

	if(((C_OBJ*)(start->fils))->fils)
	{
		n=liste_type1( ((C_OBJ*)(start->fils))->fils,0,t_t_type);		/* cherche le nombre d'‚lement de la liste	*/
	
		if(n>0)
		{
			if(*liste)
				FREE(*liste);
			*liste=MALLOC(4*n);
			liste_type2(((C_OBJ*)(start->fils))->fils,*liste,t_t_type);		/* Collecte la liste	*/
		
			trier_liste_type(*liste,n);
		}	
		return n;
	}
	else return 0;
}

static int	liste_type1(C_OBJ *obj,int n,int type)
{
	if (obj->type==type)
		n++;
	if(obj->suivant)
		n=liste_type1(obj->suivant,n,type);		/* r‚cursif	*/
	return n;
}
static void	liste_type2(C_OBJ *obj,C_OBJ **liste,int type)
{
	if (obj->type==type)
	{
		*liste=obj;
		liste++;
	}
	if(obj->suivant)
		liste_type2(obj->suivant,liste,type);		/* r‚cursif	*/
}

static void trier_liste_type(C_OBJ **liste,int n)
{		/*	Tri … "bulles"	*/
int	flag=TRUE;
C_OBJ	*swap;

	while(flag==TRUE)
	{
	int i;
		flag=FALSE;
		for(i=0;	i<n-1;	i++)
		{
			if(strcmp((*(liste+i))->spec.type.tt_nom,(*(liste+i+1))->spec.type.tt_nom)>0)
			{
				swap=*(liste+i+1);			/*	echange les cellules	*/
				*(liste+i+1)=*(liste+i);
				*(liste+i)=swap;
				flag=TRUE;
			}
		}
		n--;			/*	les "bulles" remonte toujours. Pas la peine de les re-re-reclasser */ 
	}
}

int liste_var(C_OBJ ***liste)
{
int n,a;

	if(((C_OBJ*)(((C_OBJ*)(start->fils))->suivant))->fils)
	{
		n=liste_type1( 
		((C_OBJ*)(((C_OBJ*)(start->fils))->suivant))->fils,0,t_donnee);				/* cherche le nombre d'‚lement de la liste	*/
	
		if(n>0)
		{
			if(*liste)
				FREE(*liste);
			*liste=MALLOC(4*n);
			liste_type2(((C_OBJ*)(((C_OBJ*)(start->fils))->suivant))->fils,*liste,t_donnee);		/* Collecte la liste	*/
		
			trier_liste_var(*liste,n);
		}	
		return n;
	}
	else return 0;
}

static void trier_liste_var(C_OBJ **liste,int n)
{		/*	Tri … "bulles"	*/
int	flag=TRUE;
C_OBJ	*swap;

	while(flag==TRUE)
	{
	int i;
		flag=FALSE;
		for(i=0;	i<n-1;	i++)
		{
			if(strcmp((*(liste+i))->spec.donnee.d_nom,(*(liste+i+1))->spec.donnee.d_nom)>0)
			{
				swap=*(liste+i+1);			/*	echange les cellules	*/
				*(liste+i+1)=*(liste+i);
				*(liste+i)=swap;
				flag=TRUE;
			}
		}
		n--;			/*	les "bulles" remonte toujours. Pas la peine de les re-re-reclasser */ 
	}
}
