/****************************************
 *		Ressource
 *		Partie qui gäre l'interface
 *
 *  Ce module est recompilÇ  Ö chaque fois 
 *	que l'on modifie la ressource
 */

#include <stdlib.h>
#include <stdio.h>
#include <gemfast.h> 
#include <osbind.h>
#include "windform.h"
#include "not_falc.h"
#include "c_gen.h"

OBJECT			*adr_mes,	*adr_desk,	*adr_menu,	*adr_autre_type;
OBJECT			*adr_typ_pp,	*adr_icon,	*adr_operator;
WINDFORM_VAR	info_var,	tbx_var,	sys_var,	donnee_var,	type_var,	fct_var;
WINDFORM_VAR	expr_var;

extern int				mousex,	 mousey,	 key,	 key_s,	color_3d1,	 color_3d2; /* Couleurs pour la 3D	*/
extern int				_global[],	work_out[],	VDIhandle,	buf[],	ap_id;
extern long				n_obj;
extern WINDFORM_VAR	prog;


void		gaddr_rsrc(void);
int		select_menu(void);
void		Teste_config(void);
int		alerte(int mes);
char *	messag(int mes);
void		form(int evnt);
void		f_informe(int event);
void		f_tool_box(int event);
void		f_donnee(int event);
void		f_type(int event);
void		f_fct(int event);
void		f_systeme(int event);
void		f_donnee_state(int state);
void		type_popup_check(int state);

extern	void	f_expr(int event);
extern	void	autre_type(WINDFORM_VAR wind, int pop);
extern	void	wind(int evnt,	WINDFORM_VAR *nw);
extern	void	nouveau(void);
extern	void	nouvelle_donnee(int);
extern	void	nouveau_prototype(int);
extern	void	nouveau_type(int);
extern	void	modif_objet_2(void);
extern	void	init_f_donnee(char *nom,	char *commen,	char *vi,	int type,	long tab,	int flag, void *autre);		/*	int type car TYPE_D n'est pas dÇfinie	idem pour C_OBJ * */
extern	void	init_f_type(char *nom,	char *commen,	int type,	int flag,	void *autre);		/*	int type car TYPE_D n'est pas dÇfinie	*/
extern	void	init_f_fct(char *nom,	char *commen,	int type,	int flag, void *autre);		/*	int type car TYPE_D n'est pas dÇfinie	idem pour C_OBJ * */
extern	void	efface_objet(void);
extern	void	w_redraw(WINDFORM_VAR w);
extern	void	liste_type(void);

void gaddr_rsrc(void)
{
MENU_T menu;
OBJECT *ptr;
int fh;
long *dummy;
int x,	y,	w,	h;
int atr[10];
char s[7];

	init_var(&info_var,		INFORMA,	0,	0);
	init_var(&tbx_var,		TOOL_BOX,	0,	0);
	init_var(&sys_var,		SYSTEM,	0,	0);
	init_var(&donnee_var,	F_DONNEE,	0,	0);
	init_var(&type_var,		F_TYPE,	0,	0);
	init_var(&fct_var,		F_FONCTION,	0,	0);
	init_var(&expr_var,		F_EXPRESSION,	0,	0);

	rsrc_gaddr(R_TREE,	MENU,	&adr_menu);
	rsrc_gaddr(R_TREE,	MESSAGE,	&adr_mes);
	rsrc_gaddr(R_TREE,	BUREAU,	&adr_desk);
	rsrc_gaddr(R_TREE,	ICONIFY,	&adr_icon);
	rsrc_gaddr(R_TREE,	PP_TYPE,	&adr_typ_pp);
	rsrc_gaddr(R_TREE,	F_AUTRE,	&adr_autre_type);
	rsrc_gaddr(R_TREE,	OPERATEUR,	&adr_operator);

	adr_typ_pp->ob_state=PP_ATTR;							/*	Fixe l'ob_state pour les pop_up 3D	*/
	donnee_var.adr_form[DON_POP].ob_state=PP_ATTR;
	type_var.adr_form[TYP_POP].ob_state=PP_ATTR;

	wind_get(0,	WF_WORKXYWH,	&x,	&y,	&w,	&h);		/* met en place le nouveau bureau	*/
	adr_desk->ob_x=x;
	adr_desk->ob_y=y;
	adr_desk->ob_width=w;
	adr_desk->ob_height=h;
	vqt_attributes(VDIhandle,	 atr);
	if(atr[7]<=6)	/* 200 lignes */
	{
	}
	else				/* 400 linges */
	{
	}
		
	wind_set(0,	WF_NEWDESK,	adr_desk,	0);
	form_dial(FMD_FINISH,	0,	0,	0,	0,	x,	y,	w,	h);

}

int select_menu(void)
{
int retour;

		switch (buf[4])
		{
		case MEN_QUIT:
			if (alerte(0)==1)
				return TRUE;
			break;
		case MEN_INFO:
			f_informe(OPEN_DIAL);
			break;
		case MEN_NOUVEAU:
			nouveau();
			break;
		case MEN_TOOL_BOX:
			f_tool_box(OPEN_DIAL);
			break;
		case MEN_INFO_SYS:
			f_systeme(OPEN_DIAL);
			break;
	}
	return FALSE;
}

void	Teste_config(void)
{
#ifndef NOT_FALCON
	if (_global[0]<0x300)
	{
		form_alert(1,	"[3][TOS>=3.00 only|Falcon!!!][Sorry]");		
	}
#endif

	if (_global[0]>=0x400)	/* multitos	*/
	{
	}
}

int	alerte(int mes)
{
int o;

	switch(mes)
	{
		case 0:
			o=MES_QUIT;
			break;
		default:
			o=MES_NO_ALERTE;
			break;
	}
	return form_alert(1,	 adr_mes[o].ob_spec); 							/* Afficher l'alerte	*/
}

char *	messag(int mes)
{
int o;
	switch(mes)
	{
		case 0:
			o=MES_W_PROG;
			break;
	}
	return adr_mes[o].ob_spec;
}

void f_informe(int event)
{
	WINDFORM_VAR *ptr_var = &info_var;
	int choix;

	if (event == OPEN_DIAL)
		open_dialog(ptr_var,	 adr_mes[MES_W_INFO].ob_spec,	 0);
	else {
		choix = windform_do(ptr_var,	 event);
		if (choix != 0) {
			if (choix > 0)
				objc_change(ptr_var->adr_form,	 choix,	 0,	 ptr_var->w_x,	
						ptr_var->w_y,	 ptr_var->w_w,	 ptr_var->w_h,	 0,	 FALSE);
			close_dialog(ptr_var);
		}
	}
}

void f_tool_box(int event)
{
	WINDFORM_VAR *ptr_var = &tbx_var;
	int choix;

	if (event == OPEN_DIAL)
		open_dialog(ptr_var,	 adr_mes[MES_W_TBX].ob_spec,	 0);
	else
	{
		choix = windform_do(ptr_var,	 event);
		if (choix != 0) {
			if (choix > 0)
			{
				objc_change(ptr_var->adr_form,	 choix,	 0,	 ptr_var->w_x,	
						ptr_var->w_y,	 ptr_var->w_w,	 ptr_var->w_h,	 0,	 TRUE);

				if (choix==TBX_DATA)
				{
					f_donnee_state(FALSE);
					init_f_donnee(NULL,	NULL,	NULL,	-1,	0,	0, NULL);
					donnee_var.w_lin=1;			/*	Nouvelle donnÇe	*/
					f_donnee(OPEN_DIAL);
				}
				else if (choix==TBX_NTYPE)
				{
					init_f_type(NULL,	NULL,	-1,	0,	NULL);
					type_var.w_lin=1;			/*	Nouveau type	*/
					f_type(OPEN_DIAL);
				}
				else if (choix==TBX_FCT)
				{
					init_f_fct(NULL,	NULL,	-1,	0, NULL);
					fct_var.w_lin=1;			/*	Nouvelle donnÇe	*/
					f_fct(OPEN_DIAL);
				}
				else if (choix==TBX_EFFACE)
				{
					efface_objet();
				}
				else if (choix==TBX_AFFECT)
				{
					f_expr(OPEN_DIAL);
				}
			}
			else if (choix==CLOSE_DIAL)
				close_dialog(ptr_var);
		}
	}
}

void f_systeme(int event)
{
	WINDFORM_VAR *ptr_var = &sys_var;
	int choix;
	long	free_mem;
	char	s[10];

	if (event == OPEN_DIAL)
	{
		free_mem=(long)(Malloc(-1L));
		_ltoa(free_mem,	ptr_var->adr_form[SYS_MEM].ob_spec,	10);	/* mÇmoire libre	*/
		_ltoa(n_obj,	ptr_var->adr_form[SYS_N_OBJ].ob_spec,	10);		/* nbr d'objet		*/
		open_dialog(ptr_var,	 adr_mes[MES_W_SYSTEM].ob_spec,	 0);
	}
	else {
		choix = windform_do(ptr_var,	 event);
		if (choix != 0) 
		{
			if (choix==SYS_ACTU)
			{
				free_mem=(long)(Malloc(-1L));
				_ltoa(free_mem,	ptr_var->adr_form[SYS_MEM].ob_spec,	10);	/* mÇmoire libre	*/
				_ltoa(n_obj,	ptr_var->adr_form[SYS_N_OBJ].ob_spec,	10);		/* nbr d'objet		*/
				objc_change(ptr_var->adr_form,	 choix,	 0,	 ptr_var->w_x,	
						ptr_var->w_y,	 ptr_var->w_w,	 ptr_var->w_h,	 0,	 FALSE);

				w_redraw(*ptr_var);
			}
			else if (choix==CLOSE_DIAL)
				close_dialog(ptr_var);
		}
	}
}

void f_donnee_state(int state)
{
	if (state)
	{
		donnee_var.adr_form[DON_VI].ob_state |= DISABLED;
		donnee_var.adr_form[DON_TAB].ob_state |= DISABLED;
	}
	else
	{
		donnee_var.adr_form[DON_VI].ob_state &= ~DISABLED;
		donnee_var.adr_form[DON_TAB].ob_state &= ~DISABLED;
	}
}

void	type_popup_check(int state)
{
	if(state==1)
	{
		adr_typ_pp[PPT_STRUC].ob_state |= DISABLED;
		adr_typ_pp[PPT_UNION].ob_state |= DISABLED;
	}
	else
	{
		adr_typ_pp[PPT_STRUC].ob_state &= ~DISABLED;
		adr_typ_pp[PPT_UNION].ob_state &= ~DISABLED;
	}
}

void f_donnee(int event)
{
WINDFORM_VAR *ptr_var = &donnee_var;
MENU_T	pu,	data;
int		x,	y;
int choix;

	if (event == OPEN_DIAL)
	{
		open_dialog(ptr_var,	 adr_mes[MES_W_DONNEE].ob_spec,	 DON_NOM);
		w_redraw(*ptr_var);
	}
	else {
		choix = windform_do(ptr_var,	 event);
		if (choix != 0) {
			if (choix > 0)
			{
				if (choix==DON_POP)
				{
					type_popup_check(0);
					pu.mn_tree=adr_typ_pp;		/* prÇpare le popup	*/
					pu.mn_menu=ROOT;
					pu.mn_scroll=0;

					check_popup(&pu,	ptr_var->adr_form,	DON_POP);

					objc_offset(ptr_var->adr_form,	DON_POP,	&x,	&y);	/* Cherche la position du bouton	*/
					if (Menu_popup(&pu,	x,	y,	&data))	/* le balance	*/
					{
						strcpy(((TEDINFO *)((donnee_var.adr_form[DON_POP]).ob_spec))->te_ptext,	
							adr_typ_pp[data.mn_item].ob_spec);
						objc_draw(ptr_var->adr_form,	DON_POP,	2,	ptr_var->w_x,	ptr_var->w_y,	ptr_var->w_w,	ptr_var->w_h);
						if (data.mn_item==PPT_AUTRE)
							autre_type(donnee_var,DON_POP);
					}
					objc_change(ptr_var->adr_form,	 choix,	 0,	 ptr_var->w_x,	
							ptr_var->w_y,	 ptr_var->w_w,	 ptr_var->w_h,	 PP_ATTR,	 TRUE);		/* deselectionne le popup	*/
				}
				else if(choix==DON_CONF)
				{
					objc_change(ptr_var->adr_form,	 choix,	 0,	 ptr_var->w_x,	
							ptr_var->w_y,	 ptr_var->w_w,	 ptr_var->w_h,	 0,	 TRUE);
					close_dialog(ptr_var);
					if (ptr_var->w_lin==1)
						nouvelle_donnee(0);
					else if (ptr_var->w_lin==2)
						modif_objet_2();
					else if (ptr_var->w_lin==3)
						nouvelle_donnee(1);
				}
			}
			else if(choix==CLOSE_DIAL)
				close_dialog(ptr_var);
		}
	}
}

void f_type(int event)
{
WINDFORM_VAR *ptr_var = &type_var;
MENU_T	pu,	data;
int		x,	y;
int choix;

	if (event == OPEN_DIAL)
	{
		open_dialog(ptr_var,	 adr_mes[MES_W_TYPE].ob_spec,	 TYP_NOM);
		w_redraw(*ptr_var);
	}
	else {
		choix = windform_do(ptr_var,	 event);
		if (choix != 0) {
			if (choix > 0)
			{
				if (choix==TYP_POP)
				{
					type_popup_check(0);
					pu.mn_tree=adr_typ_pp;		/* prÇpare le popup	*/
					pu.mn_menu=ROOT;
					pu.mn_scroll=0;

					check_popup(&pu,	ptr_var->adr_form,	TYP_POP);

					objc_offset(ptr_var->adr_form,	TYP_POP,	&x,	&y);	/* Cherche la position du bouton	*/
					if (Menu_popup(&pu,	x,	y,	&data))	/* le balance	*/
					{
						strcpy(((TEDINFO *)((type_var.adr_form[TYP_POP]).ob_spec))->te_ptext,	
							adr_typ_pp[data.mn_item].ob_spec);
						objc_draw(ptr_var->adr_form,	TYP_POP,	2,	ptr_var->w_x,	ptr_var->w_y,	ptr_var->w_w,	ptr_var->w_h);
						if (data.mn_item==PPT_AUTRE)
							autre_type(type_var,TYP_POP);
					}
					objc_change(ptr_var->adr_form,	 choix,	 0,	 ptr_var->w_x,	
							ptr_var->w_y,	 ptr_var->w_w,	 ptr_var->w_h,	 PP_ATTR,	 TRUE);		/* deselectionne le popup	*/
				}
				else if(choix==TYP_CONF)
				{
					objc_change(ptr_var->adr_form,	 choix,	 0,	 ptr_var->w_x,	
							ptr_var->w_y,	 ptr_var->w_w,	 ptr_var->w_h,	 0,	 TRUE);
					close_dialog(ptr_var);
					if (ptr_var->w_lin==1)
						nouveau_type(0);
					else if (ptr_var->w_lin==2)
						modif_objet_2();
					else if (ptr_var->w_lin==3)
						nouveau_type(1);
				}
			}
			else if(choix==CLOSE_DIAL)
				close_dialog(ptr_var);
		}
	}
}

void f_fct(int event)
{
WINDFORM_VAR *ptr_var = &fct_var;
MENU_T	pu,	data;
int		x,	y;
int choix;

	if (event == OPEN_DIAL)
	{
		open_dialog(ptr_var,	 adr_mes[MES_W_FCT].ob_spec,	 FCT_NOM);
		w_redraw(*ptr_var);
	}
	else {
		choix = windform_do(ptr_var,	 event);
		if (choix != 0) {
			if (choix > 0)
			{
				if (choix==FCT_POP)
				{
					type_popup_check(1);
					pu.mn_tree=adr_typ_pp;		/* prÇpare le popup	*/
					pu.mn_menu=ROOT;
					pu.mn_scroll=0;

					check_popup(&pu,	ptr_var->adr_form,	FCT_POP);

					objc_offset(ptr_var->adr_form,	FCT_POP,	&x,	&y);	/* Cherche la position du bouton	*/
					if (Menu_popup(&pu,	x,	y,	&data))	/* le balance	*/
					{
						strcpy(((TEDINFO *)((fct_var.adr_form[FCT_POP]).ob_spec))->te_ptext,	
							adr_typ_pp[data.mn_item].ob_spec);
						objc_draw(ptr_var->adr_form,	FCT_POP,	2,	ptr_var->w_x,	ptr_var->w_y,	ptr_var->w_w,	ptr_var->w_h);
						if (data.mn_item==PPT_AUTRE)
							autre_type(fct_var,FCT_POP);
					}
					objc_change(ptr_var->adr_form,	 choix,	 0,	 ptr_var->w_x,	
							ptr_var->w_y,	 ptr_var->w_w,	 ptr_var->w_h,	 PP_ATTR,	 TRUE);		/* deselectionne le popup	*/
				}
				else if(choix==FCT_CONF)
				{
					objc_change(ptr_var->adr_form,	 choix,	 0,	 ptr_var->w_x,	
							ptr_var->w_y,	 ptr_var->w_w,	 ptr_var->w_h,	 0,	 TRUE);
					close_dialog(ptr_var);
					if (ptr_var->w_lin==1)
						nouveau_prototype(0);
					else if (ptr_var->w_lin==2)
						modif_objet_2();
					else if (ptr_var->w_lin==3)
						nouveau_prototype(1);
				}
			}
			else if(choix==CLOSE_DIAL)
				close_dialog(ptr_var);
		}
	}
}


void form(int evnt)
{
int dummy;

	if (evnt & MU_KEYBD)
		wind_get(0,	 WF_TOP,	 &buf[3],	 &dummy,	 &dummy,	 &dummy);
	else if (evnt & MU_BUTTON)
		buf[3] = wind_find(mousex,	 mousey);
	if (evnt == MU_TIMER)
		buf[3] = wind_find(mousex,	 mousey);

/* *** Aiguillage en fonction du Handle : ***	*/
	
	if (buf[3] == 0)	/* PrÇvu pour gärer le Clic sur un objet du Bureau. */
		wind(evnt,	NULL);		/*		/!\	NULL: pas de danger car gäre que TIMER	*/
	else if (buf[3] == info_var.w_handle)
		f_informe(evnt);
	else if (buf[3] == tbx_var.w_handle)
		f_tool_box(evnt);
	else if (buf[3] == sys_var.w_handle)
		f_systeme(evnt);
	else if (buf[3] == donnee_var.w_handle)
		f_donnee(evnt);
	else if (buf[3] == type_var.w_handle)
		f_type(evnt);
	else if (buf[3] == fct_var.w_handle)
		f_fct(evnt);
	else if (buf[3] == expr_var.w_handle)
		f_expr(evnt);
	else if (buf[3] == prog.w_handle)
		wind(evnt,	&prog);
}
