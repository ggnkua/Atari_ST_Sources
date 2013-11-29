/***************************************
 *		ressource
 *		partie qui d‚code les donn‚es
 */

#include <stdlib.h>
#include <stdio.h>
#include <support.h>		/* ltoa	*/
#include <gemfast.h> 
#include	"s_malloc.h"
#include "windform.h"
#include "c_gen.h"
#include "object.h"

extern	OBJECT			*adr_typ_pp,*adr_autre_type;
extern	WINDFORM_VAR	donnee_var,type_var,fct_var;

void		init_f_donnee(char *nom,	char *commen,	char *vi,	TYPE_D type,	long tab,	int flag, C_OBJ *autre);
void		init_f_fct(char *nom,	char *commen,	TYPE_D type,	int flag, C_OBJ *autre);
void		init_f_type(char *nom,	char *commen,	TYPE_D type,	int flag,	C_OBJ *autre);
void		return_f_donnee(char **nom,	char **commen,		char **vi,	TYPE_D *type,	long *tab,	int *flag, C_OBJ **autre);
void		return_f_type(char **nom,	char **commen,	TYPE_D *type,	int *flag,	C_OBJ** autre);
void		return_f_fct(char **nom,	char **commen,	TYPE_D *type,	int *flag, C_OBJ **autre);
void		autre_type(WINDFORM_VAR wind,int pop);
static void autre_type_affiche(C_OBJ **liste,int n,int n_case,int pos, int x,int y,int w,int h,int select);

extern	int liste_type(C_OBJ ***liste);


void init_f_donnee(char *nom,	char *commen,	char *vi,	TYPE_D type,	long tab,	int flag, C_OBJ *autre)
{
char dummy[10];

	if(nom==NULL)
		strcpy(((TEDINFO *)((donnee_var.adr_form[DON_NOM]).ob_spec))->te_ptext,	"");
	else 
		strcpy(((TEDINFO *)((donnee_var.adr_form[DON_NOM]).ob_spec))->te_ptext,	nom);
	
	if(commen==NULL)
		strcpy(((TEDINFO *)((donnee_var.adr_form[DON_COM]).ob_spec))->te_ptext,	"");
	else
		strcpy(((TEDINFO *)((donnee_var.adr_form[DON_COM]).ob_spec))->te_ptext,	commen);
	
	if(vi==NULL)
		strcpy(((TEDINFO *)((donnee_var.adr_form[DON_VI]).ob_spec))->te_ptext,	"");
	else
		strcpy(((TEDINFO *)((donnee_var.adr_form[DON_VI]).ob_spec))->te_ptext,	vi);
	
	if(type==-1)
		strcpy(((TEDINFO *)((donnee_var.adr_form[DON_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_CHAR].ob_spec);
	else
	{
		if(type==t_char)
			strcpy(((TEDINFO *)((donnee_var.adr_form[DON_POP]).ob_spec))->te_ptext,	
						adr_typ_pp[PPT_CHAR].ob_spec);
		else if(type==t_int)
			strcpy(((TEDINFO *)((donnee_var.adr_form[DON_POP]).ob_spec))->te_ptext,	
						adr_typ_pp[PPT_INT].ob_spec);
		else if(type==t_reel)
			strcpy(((TEDINFO *)((donnee_var.adr_form[DON_POP]).ob_spec))->te_ptext,	
						adr_typ_pp[PPT_REEL].ob_spec);
		else if(type==t_nul)
			strcpy(((TEDINFO *)((donnee_var.adr_form[DON_POP]).ob_spec))->te_ptext,	
						adr_typ_pp[PPT_NUL].ob_spec);
		else if(type==t_struct)
			strcpy(((TEDINFO *)((donnee_var.adr_form[DON_POP]).ob_spec))->te_ptext,	
						adr_typ_pp[PPT_STRUC].ob_spec);
		else if(type==t_union)
			strcpy(((TEDINFO *)((donnee_var.adr_form[DON_POP]).ob_spec))->te_ptext,	
						adr_typ_pp[PPT_UNION].ob_spec);
		else if(type==t_autre)
		{
			if (autre)
			{
				strcpy(dummy,"  ");	
				strncat(dummy,autre->spec.type.tt_nom,6);
				strcpy(((TEDINFO *)((donnee_var.adr_form[DON_POP]).ob_spec))->te_ptext	,dummy);
			}
			else 
				strcpy(((TEDINFO *)((donnee_var.adr_form[DON_POP]).ob_spec))->te_ptext,	
							adr_typ_pp[PPT_AUTRE].ob_spec);
		}
	}
	
	if(tab==0)
		strcpy(((TEDINFO *)((donnee_var.adr_form[DON_TAB]).ob_spec))->te_ptext,	
					"0");
	else
		strcpy(((TEDINFO *)((donnee_var.adr_form[DON_TAB]).ob_spec))->te_ptext,	
					_ltoa(tab,	dummy,	10));
	
	if(flag==0)
	{
		donnee_var.adr_form[DON_EXTERN].ob_state	&= ~SELECTED;
		donnee_var.adr_form[DON_POINTER].ob_state	&= ~SELECTED;
		donnee_var.adr_form[DON_LONG].ob_state	&= ~SELECTED;
		donnee_var.adr_form[DON_UNSIGNED].ob_state	&= ~SELECTED;
	}
	else
	{
		if(flag & 2)
			donnee_var.adr_form[DON_EXTERN].ob_state	|= SELECTED;
		else
			donnee_var.adr_form[DON_EXTERN].ob_state	&= ~SELECTED;
	
		if(flag & 1)
			donnee_var.adr_form[DON_POINTER].ob_state	|= SELECTED;
		else
			donnee_var.adr_form[DON_POINTER].ob_state	&= ~SELECTED;
	
		if(flag & 4)
			donnee_var.adr_form[DON_LONG].ob_state	|= SELECTED;
		else
			donnee_var.adr_form[DON_LONG].ob_state	&= ~SELECTED;
	
		if(flag & 8)
			donnee_var.adr_form[DON_UNSIGNED].ob_state	|= SELECTED;
		else
			donnee_var.adr_form[DON_UNSIGNED].ob_state	&= ~SELECTED;
	}
}

void return_f_donnee(char **nom,	char **commen,	char **vi,	TYPE_D *type,	long *tab,	int *flag, C_OBJ **autre)
{
char *s;

	s=((TEDINFO *)((donnee_var.adr_form[DON_NOM]).ob_spec))->te_ptext;
	if (*nom)
		FREE(*nom);
	if (strlen(s)==0)
		*nom=NULL;
	else
	{
		*nom=(char *)(MALLOC(strlen(s)+1));
		if (*nom)
			strcpy(*nom,	s);
	}
	
	s=((TEDINFO *)((donnee_var.adr_form[DON_COM]).ob_spec))->te_ptext;
	if (*commen)
		FREE(*commen);
	if (strlen(s)==0)
		*commen=NULL;
	else
	{
		*commen=(char *)(MALLOC(strlen(s)+1));
		if (*commen)
			strcpy(*commen,	s);
	}
	
	s=((TEDINFO *)((donnee_var.adr_form[DON_VI]).ob_spec))->te_ptext;
	if (*vi)
		FREE(*vi);
	if (strlen(s)==0)
		*vi=NULL;
	else
	{
		*vi=(char *)(MALLOC(strlen(s)+1));
		if	(*vi)
			strcpy(*vi,	s);
	}

	if(strcmp(((TEDINFO *)((donnee_var.adr_form[DON_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_CHAR].ob_spec)==0)
		*type=t_char;
	else 	if(strcmp(((TEDINFO *)((donnee_var.adr_form[DON_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_INT].ob_spec)==0)
		*type=t_int;
	else 	if(strcmp(((TEDINFO *)((donnee_var.adr_form[DON_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_REEL].ob_spec)==0)
		*type=t_reel;
	else 	if(strcmp(((TEDINFO *)((donnee_var.adr_form[DON_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_STRUC].ob_spec)==0)
		*type=t_struct;
	else 	if(strcmp(((TEDINFO *)((donnee_var.adr_form[DON_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_UNION].ob_spec)==0)
		*type=t_union;
	else 	if(strcmp(((TEDINFO *)((donnee_var.adr_form[DON_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_NUL].ob_spec)==0)
		*type=t_nul;
	else				/****	autre type	****/
	{
		*type=t_autre;
		*autre=((TEDINFO *)((donnee_var.adr_form[DON_POP]).ob_spec))->te_ptmplt;
	}
	
	s=((TEDINFO *)((donnee_var.adr_form[DON_TAB]).ob_spec))->te_ptext;
	if (strlen(s)==0)
		*tab=0;
	else
		*tab=atol(s);

	if(donnee_var.adr_form[DON_EXTERN].ob_state	& SELECTED)
		*flag=2;		/* on intialise le flag	*/
	else
		*flag = 0;

	if(donnee_var.adr_form[DON_POINTER].ob_state	& SELECTED)
		*flag+=1;
	else
		*flag&=~1;

	if(donnee_var.adr_form[DON_UNSIGNED].ob_state & SELECTED)
		*flag+=8;
	else
		*flag&=~8;

	if(donnee_var.adr_form[DON_LONG].ob_state	& SELECTED)
		*flag+=4;
	else
		*flag&=~4;
}

void init_f_type(char *nom,	char *commen,	TYPE_D type,	int flag, C_OBJ * autre)
{
char dummy[10];

	if(nom==NULL)
		strcpy(((TEDINFO *)((type_var.adr_form[TYP_NOM]).ob_spec))->te_ptext,	"");
	else 
		strcpy(((TEDINFO *)((type_var.adr_form[TYP_NOM]).ob_spec))->te_ptext,	nom);
	
	if(commen==NULL)
		strcpy(((TEDINFO *)((type_var.adr_form[TYP_COM]).ob_spec))->te_ptext,	"");
	else
		strcpy(((TEDINFO *)((type_var.adr_form[TYP_COM]).ob_spec))->te_ptext,	commen);
	
	if(type==-1)
		strcpy(((TEDINFO *)((type_var.adr_form[TYP_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_CHAR].ob_spec);
	else
	{
		if(type==t_char)
			strcpy(((TEDINFO *)((type_var.adr_form[TYP_POP]).ob_spec))->te_ptext,	
						adr_typ_pp[PPT_CHAR].ob_spec);
		else if(type==t_int)
			strcpy(((TEDINFO *)((type_var.adr_form[TYP_POP]).ob_spec))->te_ptext,	
						adr_typ_pp[PPT_INT].ob_spec);
		else if(type==t_reel)
			strcpy(((TEDINFO *)((type_var.adr_form[TYP_POP]).ob_spec))->te_ptext,	
						adr_typ_pp[PPT_REEL].ob_spec);
		else if(type==t_nul)
			strcpy(((TEDINFO *)((type_var.adr_form[TYP_POP]).ob_spec))->te_ptext,	
						adr_typ_pp[PPT_NUL].ob_spec);
		else if(type==t_struct)
			strcpy(((TEDINFO *)((type_var.adr_form[TYP_POP]).ob_spec))->te_ptext,	
						adr_typ_pp[PPT_STRUC].ob_spec);
		else if(type==t_union)
			strcpy(((TEDINFO *)((type_var.adr_form[TYP_POP]).ob_spec))->te_ptext,	
						adr_typ_pp[PPT_UNION].ob_spec);
		else if(type==t_autre)
		{
			if (autre)
			{
				strcpy(dummy,"  ");	
				strncat(dummy,autre->spec.type.tt_nom,6);
				strcpy(((TEDINFO *)((type_var.adr_form[TYP_POP]).ob_spec))->te_ptext	,dummy);
			}
			else 
				strcpy(((TEDINFO *)((type_var.adr_form[TYP_POP]).ob_spec))->te_ptext,	
							adr_typ_pp[PPT_AUTRE].ob_spec);
		}
	}
	
	if(flag==0)
	{
		type_var.adr_form[TYP_LONG].ob_state	&= ~SELECTED;
		type_var.adr_form[TYP_UNSIGNED].ob_state	&= ~SELECTED;
	}
	else
	{
		if(flag & 4)
			type_var.adr_form[TYP_LONG].ob_state	|= SELECTED;
		else
			type_var.adr_form[TYP_LONG].ob_state	&= ~SELECTED;
	
		if(flag & 8)
			type_var.adr_form[TYP_UNSIGNED].ob_state	|= SELECTED;
		else
			type_var.adr_form[TYP_UNSIGNED].ob_state	&= ~SELECTED;
	}
}

void return_f_type(char **nom,	char **commen,	TYPE_D *type,	int *flag,	C_OBJ **autre)
{
char *s;

	s=((TEDINFO *)((type_var.adr_form[TYP_NOM]).ob_spec))->te_ptext;
	if (*nom)
		FREE(*nom);
	if (strlen(s)==0)
		*nom=NULL;
	else
	{
		*nom=(char *)(MALLOC(strlen(s)+1));
		if (*nom)
			strcpy(*nom,	s);
	}
	
	s=((TEDINFO *)((type_var.adr_form[TYP_COM]).ob_spec))->te_ptext;
	if (*commen)
		FREE(*commen);
	if (strlen(s)==0)
		*commen=NULL;
	else
	{
		*commen=(char *)(MALLOC(strlen(s)+1));
		if (*commen)
			strcpy(*commen,	s);
	}


	if(strcmp(((TEDINFO *)((type_var.adr_form[TYP_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_CHAR].ob_spec)==0)
		*type=t_char;
	else 	if(strcmp(((TEDINFO *)((type_var.adr_form[TYP_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_INT].ob_spec)==0)
		*type=t_int;
	else 	if(strcmp(((TEDINFO *)((type_var.adr_form[TYP_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_REEL].ob_spec)==0)
		*type=t_reel;
	else 	if(strcmp(((TEDINFO *)((type_var.adr_form[TYP_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_NUL].ob_spec)==0)
		*type=t_nul;
	else 	if(strcmp(((TEDINFO *)((type_var.adr_form[TYP_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_STRUC].ob_spec)==0)
		*type=t_struct;
	else 	if(strcmp(((TEDINFO *)((type_var.adr_form[TYP_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_UNION].ob_spec)==0)
		*type=t_union;
	else				/****	autre type	****/
	{
		*type=t_autre;
		*autre=((TEDINFO *)((type_var.adr_form[TYP_POP]).ob_spec))->te_ptmplt;
	}

	*flag=0;		/* on l'initailise our pas avoir de pb	*/
	if(type_var.adr_form[TYP_UNSIGNED].ob_state & SELECTED)
		*flag+=8;
	else
		*flag&=~8;

	if(type_var.adr_form[TYP_LONG].ob_state	& SELECTED)
		*flag+=4;
	else
		*flag&=~4;
}

void init_f_fct(char *nom,	char *commen,	TYPE_D type,	int flag, C_OBJ *autre)
{
char dummy[10];

	if(nom==NULL)
		strcpy(((TEDINFO *)((fct_var.adr_form[FCT_NOM]).ob_spec))->te_ptext,	"");
	else 
		strcpy(((TEDINFO *)((fct_var.adr_form[FCT_NOM]).ob_spec))->te_ptext,	nom);
	
	if(commen==NULL)
		strcpy(((TEDINFO *)((fct_var.adr_form[FCT_COM]).ob_spec))->te_ptext,	"");
	else
		strcpy(((TEDINFO *)((fct_var.adr_form[FCT_COM]).ob_spec))->te_ptext,	commen);
	
	if(type==-1)
		strcpy(((TEDINFO *)((fct_var.adr_form[FCT_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_NUL].ob_spec);
	else
	{
		if(type==t_char)
			strcpy(((TEDINFO *)((fct_var.adr_form[FCT_POP]).ob_spec))->te_ptext,	
						adr_typ_pp[PPT_CHAR].ob_spec);
		else if(type==t_int)
			strcpy(((TEDINFO *)((fct_var.adr_form[FCT_POP]).ob_spec))->te_ptext,	
						adr_typ_pp[PPT_INT].ob_spec);
		else if(type==t_reel)
			strcpy(((TEDINFO *)((fct_var.adr_form[FCT_POP]).ob_spec))->te_ptext,	
						adr_typ_pp[PPT_REEL].ob_spec);
		else if(type==t_nul)
			strcpy(((TEDINFO *)((fct_var.adr_form[FCT_POP]).ob_spec))->te_ptext,	
						adr_typ_pp[PPT_NUL].ob_spec);
		else if(type==t_autre)
		{
			if (autre)
			{
				strcpy(dummy,"  ");	
				strncat(dummy,autre->spec.type.tt_nom,6);
				strcpy(((TEDINFO *)((fct_var.adr_form[FCT_POP]).ob_spec))->te_ptext	,dummy);
			}
			else 
				strcpy(((TEDINFO *)((fct_var.adr_form[FCT_POP]).ob_spec))->te_ptext,	
							adr_typ_pp[PPT_AUTRE].ob_spec);
		}
	}
	
	if(flag==0)
	{
		fct_var.adr_form[FCT_EXTERN].ob_state	&= ~SELECTED;
		fct_var.adr_form[FCT_POINTER].ob_state	&= ~SELECTED;
		fct_var.adr_form[FCT_LONG].ob_state	&= ~SELECTED;
		fct_var.adr_form[FCT_UNSIGNED].ob_state	&= ~SELECTED;
	}
	else
	{
		if(flag & 2)
			fct_var.adr_form[FCT_EXTERN].ob_state	|= SELECTED;
		else
			fct_var.adr_form[FCT_EXTERN].ob_state	&= ~SELECTED;
	
		if(flag & 1)
			fct_var.adr_form[FCT_POINTER].ob_state	|= SELECTED;
		else
			fct_var.adr_form[FCT_POINTER].ob_state	&= ~SELECTED;
	
		if(flag & 4)
			fct_var.adr_form[FCT_LONG].ob_state	|= SELECTED;
		else
			fct_var.adr_form[FCT_LONG].ob_state	&= ~SELECTED;
	
		if(flag & 8)
			fct_var.adr_form[FCT_UNSIGNED].ob_state	|= SELECTED;
		else
			fct_var.adr_form[FCT_UNSIGNED].ob_state	&= ~SELECTED;
	}
}

void return_f_fct(char **nom,	char **commen,	TYPE_D *type,	int *flag, C_OBJ **autre)
{
char *s;

	s=((TEDINFO *)((fct_var.adr_form[FCT_NOM]).ob_spec))->te_ptext;
	if (*nom)
		FREE(*nom);
	if (strlen(s)==0)
		*nom=NULL;
	else
	{
		*nom=(char *)(MALLOC(strlen(s)+1));
		if (*nom)
			strcpy(*nom,	s);
	}
	
	s=((TEDINFO *)((fct_var.adr_form[FCT_COM]).ob_spec))->te_ptext;
	if (*commen)
		FREE(*commen);
	if (strlen(s)==0)
		*commen=NULL;
	else
	{
		*commen=(char *)(MALLOC(strlen(s)+1));
		if (*commen)
			strcpy(*commen,	s);
	}
	
	if(strcmp(((TEDINFO *)((fct_var.adr_form[FCT_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_CHAR].ob_spec)==0)
		*type=t_char;
	else 	if(strcmp(((TEDINFO *)((fct_var.adr_form[FCT_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_INT].ob_spec)==0)
		*type=t_int;
	else 	if(strcmp(((TEDINFO *)((fct_var.adr_form[FCT_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_REEL].ob_spec)==0)
		*type=t_reel;
	else 	if(strcmp(((TEDINFO *)((fct_var.adr_form[FCT_POP]).ob_spec))->te_ptext,	
					adr_typ_pp[PPT_NUL].ob_spec)==0)
		*type=t_nul;
	else				/****	autre type	****/
	{
		*type=t_autre;
		*autre=((TEDINFO *)((fct_var.adr_form[FCT_POP]).ob_spec))->te_ptmplt;
	}
	
	if(fct_var.adr_form[FCT_EXTERN].ob_state	& SELECTED)
		*flag=2;		/* on intialise le flag	*/
	else
		*flag = 0;

	if(fct_var.adr_form[FCT_POINTER].ob_state	& SELECTED)
		*flag+=1;
	else
		*flag&=~1;

	if(fct_var.adr_form[FCT_UNSIGNED].ob_state & SELECTED)
		*flag+=8;
	else
		*flag&=~8;

	if(fct_var.adr_form[FCT_LONG].ob_state	& SELECTED)
		*flag+=4;
	else
		*flag&=~4;
}

void autre_type(WINDFORM_VAR wind,int pop)
{
int x,y,w,h;
int retour,a,n;
int n_case,pos=0,select=-1;
int k,ys,ys1,pos1=0,yob,dummy;
char s[10];
C_OBJ **liste=NULL,*sel=NULL;
	
	n_case=AUT_END-AUT_START;
	n=liste_type(&liste);

	if(n>0)
	{
		for(a=0;	a<n;	a++)
			adr_autre_type[AUT_START+a].ob_state &=~SELECTED;	/*	d‚selectionne tous les items	*/
		strcpy(((TEDINFO *)((adr_autre_type[AUT_NOM]).ob_spec))->te_ptext,"");	/* efface le nom de l'object selectionn‚e	*/

		if(n<n_case)		/*	Remplit les lignes	*/
		{
			for(a=0;	a<n;	a++)
				strcpy(((TEDINFO *)((adr_autre_type[AUT_START+a]).ob_spec))->te_ptext,(*(liste+a))->spec.type.tt_nom);
			adr_autre_type[AUT_SLID].ob_height=adr_autre_type[AUT_LIFT].ob_height;
		}
		else
		{
			for(a=0;	a<=n_case;	a++)
				strcpy(((TEDINFO *)((adr_autre_type[AUT_START+a]).ob_spec))->te_ptext,(*(liste+a))->spec.type.tt_nom);
			adr_autre_type[AUT_SLID].ob_height=(int)((long)(n_case*adr_autre_type[AUT_LIFT].ob_height)/n);
		}
		adr_autre_type[AUT_SLID].ob_y=0;

		form_center (adr_autre_type, &x, &y, &w, &h);
		form_dial (FMD_START, 0, 0, 0, 0, x, y, w, h);
		objc_draw (adr_autre_type, 0, MAX_DEPTH, x, y, w, h);
		do {
			retour = form_do (adr_autre_type, 0);
			if (retour>=AUT_START && retour<=AUT_END)		/* si on a cliquer sur une ligne	*/
			{
				if(retour-AUT_START<n)
				{
					strcpy(((TEDINFO *)((adr_autre_type[AUT_NOM]).ob_spec))->te_ptext,	
								((TEDINFO *)((adr_autre_type[retour]).ob_spec))->te_ptext);
					sel=(*(liste+pos+(retour-AUT_START))); 				/*	Object selectionn‚e	*/
					objc_draw (adr_autre_type, AUT_NOM, 1, x, y, w, h);
					select=pos+retour-AUT_START;
				}
			}
			else if(retour==AUT_DOWN)		/*	Fleche ver le bas	*/
			{
				pos++;
				if(pos>=n-n_case)
					pos--;
				else
					autre_type_affiche(liste,n,n_case,pos,x,y,w,h,select);
			}
			else if(retour==AUT_UP)		/* FlŠche vers le haut	*/
			{
				pos--;
				if(pos<0)
					pos++;
				else
					autre_type_affiche(liste,n,n_case,pos,x,y,w,h,select);
			}
			else if (retour==AUT_SLID)		/* Sliders	*/
			{
				graf_mkstate ( &dummy, &ys1,&k,&dummy );
				yob=adr_autre_type[AUT_SLID].ob_y;
				do
				{
					graf_mkstate ( &dummy, &ys,&k,&dummy );		/* coord de la souris	*/
					adr_autre_type[AUT_SLID].ob_y =yob+(ys-ys1);	
					pos=adr_autre_type[AUT_SLID].ob_y*(n-n_case)/(adr_autre_type[AUT_LIFT].ob_height-adr_autre_type[AUT_SLID].ob_height);

					if (pos>=n-n_case)
						pos=n-n_case-1;
					if (pos<0)
						pos=0;

					if(pos!=pos1)
					{
						autre_type_affiche(liste,n,n_case,pos,x,y,w,h,select);
						pos1=pos;
					}
				}while(k==1);
			}
			else if (retour==AUT_LIFT)		/* Ascenseur	*/
			{
				objc_offset(adr_autre_type,AUT_LIFT,&dummy,&ys);
				graf_mkstate ( &dummy, &ys1,&dummy,&dummy );
				if (ys1-ys>adr_autre_type[AUT_SLID].ob_y)
				{
					pos+=n_case;
					if(pos>=n-n_case)
						pos=n-n_case-1;
					autre_type_affiche(liste,n,n_case,pos,x,y,w,h,select);
				}
				else
				{
					pos-=n_case;
					if(pos<0)
						pos=0;
					autre_type_affiche(liste,n,n_case,pos,x,y,w,h,select);
				}
			}
			else if (retour & 0x8000)
			{
				retour &= ~0x8000;
				if (retour>=AUT_START && retour<=AUT_END)		/* si on a cliquer sur une ligne	*/
				{
					if(retour-AUT_START<n)
					{
						strcpy(((TEDINFO *)((adr_autre_type[AUT_NOM]).ob_spec))->te_ptext,	
									((TEDINFO *)((adr_autre_type[retour]).ob_spec))->te_ptext);
						sel=(*(liste+pos+(retour-AUT_START))); 				/*	Object selectionn‚e	*/
						objc_draw (adr_autre_type, AUT_NOM, 1, x, y, w, h);
						retour=-1;
					}
				}
			}

		}while (retour!=AUT_CON && retour!=-1);
		form_dial (FMD_FINISH, 0, 0, 0, 0, x, y, w, h);
		objc_change (adr_autre_type, retour, 0, x, y, w, h, 0, 0);
	
		FREE(liste);
	}

	strcpy(s,"  ");	
	strncat(s,((TEDINFO *)((adr_autre_type[AUT_NOM]).ob_spec))->te_ptext,6);
	strcpy(((TEDINFO *)((wind.adr_form[pop]).ob_spec))->te_ptext	,s);

	((TEDINFO *)((wind.adr_form[pop]).ob_spec))->te_ptmplt=sel;		/*	Sauve l'objet s‚lectionne directement dans la ressource ==> laisser au moins 4 caractŠres dans le masque du pop up	*/
/*	printf(">>%s\n",((C_OBJ*)(((TEDINFO *)((wind.adr_form[pop]).ob_spec))->te_ptmplt))->spec.type.tt_nom );*/
}

static void autre_type_affiche(C_OBJ **liste,int n,int n_case,int pos, int x,int y,int w,int h,int select)
{
int a;

	adr_autre_type[AUT_SLID].ob_y=pos*(adr_autre_type[AUT_LIFT].ob_height-adr_autre_type[AUT_SLID].ob_height)/(n-n_case);
	objc_draw (adr_autre_type, AUT_LIFT, 2, x, y, w, h);
	for(a=n_case;	a>=0;	a--)
	{
		if(select==pos+a)		/*	si l'object selectionne	*/
			adr_autre_type[AUT_START+a].ob_state |=SELECTED;	/*	d‚place	le l'item SELECTED	*/
		else
			adr_autre_type[AUT_START+a].ob_state &=~SELECTED;

		strcpy(((TEDINFO *)((adr_autre_type[AUT_START+a]).ob_spec))->te_ptext,(*(liste+a+pos))->spec.type.tt_nom);
		objc_draw (adr_autre_type, AUT_START+a, 1, x, y, w, h);
	}
}