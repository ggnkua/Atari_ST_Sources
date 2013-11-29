/*******************************
***	GŠrent les expr‚ssions
********************************/

#include <stdlib.h>
#include <stdio.h>
#include <gemfast.h> 
#include <osbind.h>
#include "windform.h"
#include "object.h"
#include "c_gen.h"

#define	DLIGNE	EXP2_END-EXP2_START
#define	GLIGNE	EXP1_END-EXP1_START

static C_OBJ				**liste;		/*		liste des objets … afficher dans la fenˆtre de droite	*/

extern WINDFORM_VAR	expr_var;
extern OBJECT			*adr_mes,*adr_operator;

void f_expr(int event);
static void affiche_droite(int *pos,void (*aff)(int,int,int),int nl,int select);
static select_item(int pos,int select);
static void affiche_operateur(int pos,int nl,int flag);
static void affiche_variable(int pos,int nl,int flag);

extern	int liste_type(C_OBJ ***liste);
extern	int liste_var(C_OBJ ***liste);

void f_expr(int event)
{
WINDFORM_VAR	*ptr_var = &expr_var;
int				choix;
static int 		pos,nl,select;
static void		(*affiche_liste)(int pos,int nl,int flag);		/*	pointeur sur la fonction d'affichage	*/

	if (event == OPEN_DIAL)
	{
		if(ptr_var->w_handle==0)		/*	si la fenˆtre n'est pas ouverte	*/
		{
			objc_change(ptr_var->adr_form,	 EXP_OPER,	 0,	 ptr_var->w_x,	
					ptr_var->w_y,	 ptr_var->w_w,	 ptr_var->w_h,	 SELECTED,	 FALSE);
			pos=0;	select=-1;
			affiche_liste=affiche_operateur;		nl=N_OPERATOR;		/*	init la fonction d'affichage	*/
			select_item(pos,select);
			affiche_liste(pos,nl,FALSE);
		}
		open_dialog(ptr_var,	 adr_mes[MES_W_EXPR].ob_spec,	 EXP_EDIT);
	}
	else {
		choix = windform_do(ptr_var,	 event);
		if (choix != 0) {
			if (choix==EXP_CONF)
			{
				objc_change(ptr_var->adr_form,	 choix,	 0,	 ptr_var->w_x,	
						ptr_var->w_y,	 ptr_var->w_w,	 ptr_var->w_h,	 0,	 FALSE);
				close_dialog(ptr_var);
			}
			else if (choix==EXP_VARIABLE)
			{
				pos=0;	select=-1;
				affiche_liste=affiche_variable;		/*	init la fonction d'affichage	*/
				nl=liste_var(&liste);
				select_item(pos,select);
				affiche_liste(pos,nl,TRUE);
			}
			else if (choix==EXP_TYPE)
			{
 				pos=0;	select=-1;
				affiche_liste=affiche_variable;		/*	init la fonction d'affichage	*/
				nl=liste_type(&liste);
				select_item(pos,select);
				affiche_liste(pos,nl,TRUE);
			}
			else if (choix==EXP_OPER)
			{
				pos=0;	select=-1;
				affiche_liste=affiche_operateur;		nl=N_OPERATOR;		/*	init la fonction d'affichage	*/
				select_item(pos,select);
				affiche_liste(pos,nl,TRUE);
			}
			else if (choix==EXP2_DOWN)
			{
				pos++;
				affiche_droite(&pos,affiche_liste,nl,select);
			}
			else if (choix==EXP2_UP)
			{
				pos--;
				affiche_droite(&pos,affiche_liste,nl,select);
			}
			else if (choix==EXP2_LIFT)
			{
			int dummy,ys,ys1;
			
				objc_offset(ptr_var->adr_form,EXP2_LIFT,&dummy,&ys);
				graf_mkstate ( &dummy, &ys1,&dummy,&dummy );
				if (ys1-ys>ptr_var->adr_form[EXP2_SLID].ob_y)
				{
					pos+=DLIGNE;
					affiche_droite(&pos,affiche_liste,nl,select);
				}
				else
				{
					pos-=DLIGNE;
					affiche_droite(&pos,affiche_liste,nl,select);
				}
			}
			else if (choix==EXP2_SLID)
			{
			int dummy,ys1,k,yob,pos1,ys;
			
				graf_mkstate ( &dummy, &ys1,&k,&dummy );
				yob=ptr_var->adr_form[EXP2_SLID].ob_y;
				do
				{
					graf_mkstate ( &dummy, &ys,&k,&dummy );		/* coord de la souris	*/
					ptr_var->adr_form[EXP2_SLID].ob_y =yob+(ys-ys1);	
					pos=-1;	affiche_droite(&pos,affiche_liste,nl,select);
				}while(k==1);

			}
			else if (choix>=EXP2_START && choix<=EXP2_END)
			{
				strcpy(((TEDINFO *)((expr_var.adr_form[EXP_EDIT]).ob_spec))->te_ptext,
						((TEDINFO *)((expr_var.adr_form[choix]).ob_spec))->te_ptext);
				objc_draw(expr_var.adr_form, EXP_EDIT, 1,
						expr_var.adr_form->ob_x, expr_var.adr_form->ob_y,
						expr_var.adr_form->ob_width, expr_var.adr_form->ob_height);
				select=pos+choix-EXP2_START;
			}
			else if (choix==CLOSE_DIAL)
				close_dialog(ptr_var);
		}
	}
}

static void affiche_droite(int *pos,void (*aff)(int,int,int),int nl,int select)
{
int dummy,a;
static int pos1;
	
	dummy=DLIGNE;
	if(*pos==-1)	
		*pos=expr_var.adr_form[EXP2_SLID].ob_y*(nl-dummy)/
				(expr_var.adr_form[EXP2_LIFT].ob_height-expr_var.adr_form[EXP2_SLID].ob_height);
	
	if(*pos>=nl-dummy)		/* v‚rifie si l'ascenseur ne sort pas de la fenˆtre	*/
		*pos=nl-dummy-1;
	if(*pos<0)
		*pos=0;

	if(*pos!=pos1)				/*	Si on a bouger l'ascenseur	*/
	{
		select_item(*pos,select);
		aff(*pos,nl,TRUE);
		pos1=*pos;
	}
}

static select_item(int pos,int select)
{
int a,dummy=DLIGNE;

	if(select==-1)
		strcpy(((TEDINFO *)((expr_var.adr_form[EXP_EDIT]).ob_spec))->te_ptext,"");

	for(a=0;	a<dummy;	a++)
		if(select==pos+a)		/*	si l'object selectionne	*/
			expr_var.adr_form[EXP2_START+a].ob_state |=SELECTED;
		else
			expr_var.adr_form[EXP2_START+a].ob_state &=~SELECTED;
}

static void affiche_operateur(int pos,int nl,int flag)
{
int a,dummy;

	if(nl<DLIGNE)		/*	Remplit les lignes	*/
	{
		for(a=0;	a<nl;	a++)
		{
			strcpy(((TEDINFO *)((expr_var.adr_form[EXP2_START+a]).ob_spec))->te_ptext,adr_operator[a+1].ob_spec);	/*	copie les op‚rateurs la fenˆtre	*/
			if(flag)
				objc_draw (expr_var.adr_form, EXP2_START+a-pos, 1, expr_var.adr_form->ob_x, expr_var.adr_form->ob_y, expr_var.adr_form->ob_width, expr_var.adr_form->ob_height);
		}
		for(a=nl;	a<=DLIGNE;	a++)		/* finit de remplir la fenˆtre	*/
		{
			strcpy(((TEDINFO *)((expr_var.adr_form[EXP2_START+a]).ob_spec))->te_ptext,"");		/* copie les variable dans la fenˆtre de droite	*/
			if(flag)
				objc_draw (expr_var.adr_form, EXP2_START+a-pos, 1, expr_var.adr_form->ob_x, expr_var.adr_form->ob_y, expr_var.adr_form->ob_width, expr_var.adr_form->ob_height);
		}
		expr_var.adr_form[EXP2_SLID].ob_height=expr_var.adr_form[EXP2_LIFT].ob_height;	/* fixe la taille de l'ascenseur	*/
		expr_var.adr_form[EXP2_SLID].ob_y=0;		/*	position de l'ascenseur	*/
		if(flag)
			objc_draw (expr_var.adr_form, EXP2_LIFT, 1, expr_var.adr_form->ob_x, expr_var.adr_form->ob_y, expr_var.adr_form->ob_width, expr_var.adr_form->ob_height);
	}
	else
	{
		dummy=DLIGNE;		/*	sinon il calcule n'importe quoi	*/
		if (pos>=nl-dummy)
			pos=nl-dummy-1;

		expr_var.adr_form[EXP2_SLID].ob_height= (dummy * expr_var.adr_form[EXP2_LIFT].ob_height)/(nl-1);	/* fixe la taille de l'ascenseur	*/
		expr_var.adr_form[EXP2_SLID].ob_y= pos*(expr_var.adr_form[EXP2_LIFT].ob_height-expr_var.adr_form[EXP2_SLID].ob_height)/(nl-dummy-1);	/* fixe la postion de l'ascenseur	*/
		if(flag)
			objc_draw (expr_var.adr_form, EXP2_LIFT, 1, expr_var.adr_form->ob_x, expr_var.adr_form->ob_y, expr_var.adr_form->ob_width, expr_var.adr_form->ob_height);

		for(a=pos;	a<=dummy+pos;	a++)
		{
			strcpy(((TEDINFO *)((expr_var.adr_form[EXP2_START+a-pos]).ob_spec))->te_ptext,adr_operator[a+1].ob_spec);	/* copie la liste dans la fenˆtre	*/
			if(flag)
				objc_draw (expr_var.adr_form, EXP2_START+a-pos, 1, expr_var.adr_form->ob_x, expr_var.adr_form->ob_y, expr_var.adr_form->ob_width, expr_var.adr_form->ob_height);
		}
	}
}

static void affiche_variable(int pos,int nl,int flag)
{
int a,dummy;

	if(nl<=DLIGNE)		/*	Remplit les lignes	*/
	{
		for(a=0;	a<nl;	a++)
		{
			strcpy(((TEDINFO *)((expr_var.adr_form[EXP2_START+a]).ob_spec))->te_ptext,(*(liste+a))->spec.donnee.d_nom);		/* copie les variable dans la fenˆtre de droite	*/
			if(flag)
				objc_draw (expr_var.adr_form, EXP2_START+a-pos, 1, expr_var.adr_form->ob_x, expr_var.adr_form->ob_y, expr_var.adr_form->ob_width, expr_var.adr_form->ob_height);
		}
		for(a=nl;	a<=DLIGNE;	a++)		/* finit de remplir la fenˆtre	*/
		{
			strcpy(((TEDINFO *)((expr_var.adr_form[EXP2_START+a]).ob_spec))->te_ptext,"");		/* copie les variable dans la fenˆtre de droite	*/
			if(flag)
				objc_draw (expr_var.adr_form, EXP2_START+a-pos, 1, expr_var.adr_form->ob_x, expr_var.adr_form->ob_y, expr_var.adr_form->ob_width, expr_var.adr_form->ob_height);
		}
		expr_var.adr_form[EXP2_SLID].ob_height=expr_var.adr_form[EXP2_LIFT].ob_height;	/* fixe la taille de la l'ascenseur	*/
		expr_var.adr_form[EXP2_SLID].ob_y=0;		/*	fixe la position de l'ascenseur	*/
		if(flag)
			objc_draw (expr_var.adr_form, EXP2_LIFT, 1, expr_var.adr_form->ob_x, expr_var.adr_form->ob_y, expr_var.adr_form->ob_width, expr_var.adr_form->ob_height);
	}
	else
	{
		dummy=DLIGNE;		/*	sinon il calcule n'importe quoi	*/
		if (pos>=nl-dummy)
			pos=nl-dummy-1;

		expr_var.adr_form[EXP2_SLID].ob_height= (dummy * expr_var.adr_form[EXP2_LIFT].ob_height)/(nl-1);	/* taille de l'ascenseur	*/
		expr_var.adr_form[EXP2_SLID].ob_y= pos*(expr_var.adr_form[EXP2_LIFT].ob_height-expr_var.adr_form[EXP2_SLID].ob_height)/(nl-dummy-1);	/* position	 de l'ascenseur	*/
		if(flag)
			objc_draw (expr_var.adr_form, EXP2_LIFT, 1, expr_var.adr_form->ob_x, expr_var.adr_form->ob_y, expr_var.adr_form->ob_width, expr_var.adr_form->ob_height);

		for(a=pos;	a<=dummy+pos;	a++)
		{
			strcpy(((TEDINFO *)((expr_var.adr_form[EXP2_START+a-pos]).ob_spec))->te_ptext,(*(liste+a))->spec.donnee.d_nom);
			if(flag)
				objc_draw (expr_var.adr_form, EXP2_START+a-pos, 1, expr_var.adr_form->ob_x, expr_var.adr_form->ob_y, expr_var.adr_form->ob_width, expr_var.adr_form->ob_height);
		}
	}
}
