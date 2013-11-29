/***************************************************************************/
/*																									*/
/*	WINDFORM.C : Fonctions de gestion des formulaires en fenˆtres.				*/
/*				 par Jacques Delavoix,	 Janvier-F‚vrier 1995.						*/
/*																									*/
/***************************************************************************/


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <osbind.h>
#include <gemfast.h>
#include	"s_malloc.h"
#include "windform.h"
#include "not_falc.h"

#define	ED_VAR	0x800		/*	ob_flag 11: On filtre que les caractŠres valide pour une variable	*/

typedef struct{
	char *unshift;
	char *shift;
	char *caps;
}KEYTAB;

#define __TURBOC__
#define ED_END 3
#define ED_INIT 1
#define ED_CHAR 2

/*
#define __TCC_COMPAT__
#define cdecl __CDECL
*/
#define cdecl


/* D‚clarations des variables externes : ATTENTION !!!!	*/

extern short VDIhandle,	 mousex,	 mousey,	 key,	 key_s,	 buf[];
extern int	_global[],	work_out[],	xwork_out[],	ap_id;
extern int	xb,	yb,	wb,	hb;	/* les coordonn‚e du bureau	*/
extern OBJECT	*adr_icon;

/* Routines de gestions des Boutons USERDEFS (raccourcis clavier) : */

short			color_3d1,	 color_3d2; /* Couleurs pour la 3D */
int cdecl	under_button(PARMBLK *parmblock);
/* static */	int			m_text_crsr=FALSE;

void set_user(OBJECT *addr_tree);
void set_objc(OBJECT *addr_obj,	 int cdecl (*code)(PARMBLK *parmblock));
char *strpcpy(char *dest,	 char *start,	 char *stop);

#ifdef NOT_FALCON
static int  get_popup (OBJECT *adr,	 int button,	 int pu);
static void set_popup (OBJECT *adr,	 int button,	 int option,	 int pu);
#endif

#ifndef ACTIVATOR
#define ACTIVATOR		0x600
#endif

#ifndef NOT_FALCON
#define USR_INDICATOR	0x800
#define USR_ACTIVATOR	0x1800
#else
#define USR_INDICATOR	0
#define USR_ACTIVATOR	0
#endif

/*
#ifdef NOT_FALCON
#define Menu_popup(a,	x,	y,	b) MENU_POPUP(a,	x,	y,	b)
int MENU_POPUP( MENU_T *me_menu,	 int me_xpos,	 int me_ypos,	
                                MENU_T *me_mdata);

#else

#define Menu_popup(a,	x,	y,	b) menu_popup(a,	x,	y,	b)
#endif
*/

/* ******** Fonctions priv‚es r‚serv‚es … windform_do(): ******** */

static int do_keybd(OBJECT *tree,	 int objc);
static int do_button(OBJECT *tree,	 int objc);


void init_var(WINDFORM_VAR *ptr_var,	 int form_index,	 int inf_x,	 int inf_y)
{
	int wx,	 wy,	 ww,	 wh;
	int offset = 0,	 inf_flag = 0;
	OBJECT *adresse_form;
	rsrc_gaddr(R_TREE,	 form_index,	 &adresse_form);
	ptr_var->adr_form = adresse_form;
	if (adresse_form->ob_state & OUTLINED)	/* Ce d‚calage est invariable !!! */
		ptr_var->offset = offset = 3;
	form_center(adresse_form,	 &wx,	 &wy,	 &ww,	 &wh);
	wind_calc(WC_BORDER,	 FW_ATTRIB,	 wx,	 wy,	 ww,	 wh,	 &wx,	 &wy,	 &ww,	 &wh);
	if (inf_x != 0 || inf_y != 0) {		/* si valeurs lues dans fichier .INF ... */
		wx = inf_x; wy = inf_y;
		inf_flag = TRUE;
	}
	ptr_var->w_x = wx; ptr_var->w_y = wy;
	ptr_var->w_w = ww; ptr_var->w_h = wh;
	if (inf_flag) {				/* ... alors recaler le formulaire sur la fenˆtre. */
		wind_calc(WC_WORK,	 FW_ATTRIB,	 wx,	 wy,	 ww,	 wh,	 &wx,	 &wy,	 &ww,	 &wh);
		adresse_form->ob_x = wx + offset;
		adresse_form->ob_y = wy + offset;
	}

	if (work_out[13] < 16) {/* Etablissement des couleurs 3D */
		color_3d1 = WHITE;	/* color index 0	*/
		color_3d2 = BLACK;	/* color index 1	*/
	}
	else {
		color_3d1 = LWHITE;	/* color index 8	*/
		color_3d2 = LBLACK;	/* color index 9	*/
	}

	set_user(adresse_form);	/* Etablissement des boutons USERDEFS.	*/
}

void open_dialog(WINDFORM_VAR *ptr_var,	 char *w_title,	 int edit_first)
{
	OBJECT *ptr_objc;
	if (ptr_var->w_handle != 0) {
		wind_set(ptr_var->w_handle,	 WF_TOP);
	}
	else {
		if ((ptr_var->w_handle = wind_create(FW_ATTRIB,	 ptr_var->w_x,	
						ptr_var->w_y,	 ptr_var->w_w,	 ptr_var->w_h)) != 0)
		{
			wind_set(ptr_var->w_handle,	 WF_NAME,	 w_title);
/*			graf_growbox(0,	 0,	 0,	 0,	 ptr_var->w_x,	 ptr_var->w_y,		GADGET !
						ptr_var->w_w,	 ptr_var->w_h);	*/
			wind_open(ptr_var->w_handle,	 ptr_var->w_x,	 ptr_var->w_y,	
					ptr_var->w_w,	 ptr_var->w_h);
			ptr_var->edit_objc = edit_first;
			ptr_objc = &(ptr_var->adr_form[edit_first]);
			if ((ptr_objc->ob_flags & EDITABLE) != 0)
				ptr_var->edit_pos = (int)strlen( ((TEDINFO *)(ptr_objc->ob_spec))->te_ptext);
		}
		else
			form_alert(1,	 "[3][   Il n'y a plus de| fenˆtres disponibles !"
					"| Fermez une fenˆtre que|  vous n'utilisez pas.][Confirmer]");
	}
}

void close_dialog(WINDFORM_VAR *ptr_var)
{
	if (ptr_var->w_handle != 0) {
		wind_close(ptr_var->w_handle);
		wind_delete(ptr_var->w_handle);
/*		graf_shrinkbox(0,	 0,	 0,	 0,	 ptr_var->w_x,	 ptr_var->w_y,		GADGET !
						ptr_var->w_w,	 ptr_var->w_h);	*/
		ptr_var->w_handle = FALSE;
	}
}

static int new_objc,	 new_pos;

int windform_do(WINDFORM_VAR *ptr_var,	 int event)
{
	GRECT r,	 rd;
	int wx,	 wy,	 ww,	 wh,	 cur_pos;
	int dialog = TRUE,	 cur_objc,	 object,	 init_field = FALSE;
	int icon=0,	dummy;

	new_objc = cur_objc = ptr_var->edit_objc;
	new_pos = cur_pos = ptr_var->edit_pos;
	if (event & MU_MESAG)
		{
		switch(buf[0])
			{
			case WM_REDRAW :
#ifndef NOT_FALCON
				wind_get(buf[3],	WF_ICONIFY,	&icon,	&dummy,	&dummy,	&dummy);		/* Iconifier ??	*/
#endif
				rd.g_x = buf[4]; rd.g_y = buf[5];
				rd.g_w = buf[6]; rd.g_h = buf[7];
				if (cur_objc) {			/* si champ ‚ditable et ....*/
					wind_get(0,	 WF_TOP,	 &wx,	 &wy,	 &ww,	 &wh);
					if (buf[3] == wx) { /*...si fenˆtre au 1ø plan -> redessin total */
						wind_get(buf[3],	 WF_WORKXYWH,	 &rd.g_x,	 &rd.g_y,	
								&rd.g_w,	 &rd.g_h);
						init_field = ED_END;
					}
				}
				wind_update(BEG_UPDATE);
				wind_get(buf[3],	 WF_FIRSTXYWH,	 &r.g_x,	 &r.g_y,	 &r.g_w,	 &r.g_h);
				while (r.g_w && r.g_h)
				{
					if (rc_intersect(&rd,	 &r))
					{
						if (icon)
						{
							wind_get(buf[3],	 WF_WORKXYWH,	 &adr_icon->ob_x,	 &adr_icon->ob_y,	&dummy,	 &dummy);
							objc_draw(adr_icon,	 ROOT,	 1,	 r.g_x,	 r.g_y,	 r.g_w,	 r.g_h);
						}
						else
							objc_draw(ptr_var->adr_form,	 0,	 8,	 r.g_x,	 r.g_y,	 r.g_w,	 r.g_h);
					}
					wind_get(buf[3],	 WF_NEXTXYWH,	 &r.g_x,	 &r.g_y,	 &r.g_w,	 &r.g_h);
				}
				wind_update(END_UPDATE);
				if (!icon)
				{
					if (cur_objc && init_field)
					{
						objc_edit(ptr_var->adr_form,	 cur_objc,	 0,	 cur_pos,	init_field,	&cur_pos);
					}
				}
				break;
			case WM_TOPPED :
				wind_set(buf[3],	 WF_TOP);
				if (cur_objc && -1 == -1) { /* si MULTITOS ... */
					wind_get(buf[3],	 WF_WORKXYWH,	 &wx,	 &wy,	 &ww,	 &wh);
					form_dial(FMD_FINISH,	 0,	0,	0,	0,	 wx,	 wy,	 ww,	 wh);				
				}
				break;
			case WM_CLOSED : 
				return CLOSE_DIAL;

			case WM_BOTTOMED:
				wind_set(buf[3],	WF_BOTTOM,	0,	0,	0,	0);
				break;
				
			case WM_MOVED :
				wind_set(buf[3],	 WF_CURRXYWH,	 buf[4],	 buf[5],	 buf[6],	 buf[7]);
				ptr_var->w_x = buf[4]; ptr_var->w_y = buf[5];
				wind_get(buf[3],	 WF_WORKXYWH,	 &wx,	 &wy,	 &ww,	 &wh);
				ptr_var->adr_form->ob_x = wx + ptr_var->offset;
				ptr_var->adr_form->ob_y = wy + ptr_var->offset;
				break;

			case WM_ICONIFY :
				wind_set(buf[3],	 WF_ICONIFY,	 buf[4],	 buf[5],	 buf[6],	 buf[7]);
				ptr_var->w_x = buf[4]; ptr_var->w_y = buf[5];
				ptr_var->w_w = buf[6]; ptr_var->w_h = buf[7];
				wind_get(buf[3],	 WF_WORKXYWH,	 &wx,	 &wy,	 &ww,	 &wh);
				adr_icon->ob_x = wx + ptr_var->offset;
				adr_icon->ob_y = wy + ptr_var->offset;
				break;
				
			case WM_UNICONIFY :
				wind_set(buf[3],	 WF_UNICONIFY,	 buf[4],	 buf[5],	 buf[6],	 buf[7]);
				wind_set(buf[3],	 WF_CURRXYWH,	 buf[4],	 buf[5],	 buf[6],	 buf[7]);
				ptr_var->w_x = buf[4]; ptr_var->w_y = buf[5];
				ptr_var->w_w = buf[6]; ptr_var->w_h = buf[7];
				wind_get(buf[3],	 WF_WORKXYWH,	 &wx,	 &wy,	 &ww,	 &wh);
				ptr_var->adr_form->ob_x = wx + ptr_var->offset;
				ptr_var->adr_form->ob_y = wy + ptr_var->offset;
				break;
			}
		}
	else if (event & MU_KEYBD) {
		dialog = do_keybd(ptr_var->adr_form,	 cur_objc);
		if (key) {
		 	objc_edit(ptr_var->adr_form,	 cur_objc,	 key,	 cur_pos,	 ED_CHAR,	 &cur_pos);
			new_objc = cur_objc;
			new_pos = cur_pos;
		}
		if (key==0x6100)		/*	UNDO	-> : Ferme la fenˆtre	*/
			return CLOSE_DIAL;	
	}

	else if (event & MU_BUTTON)
	{
	if ((object = objc_find(ptr_var->adr_form,	 0,	 8,	 mousex,	 mousey)) > 0) {
		dialog = do_button(ptr_var->adr_form,	 object);
		}
	}

	if (event & MU_TIMER)
	{
		if ((object = objc_find(ptr_var->adr_form,	 ROOT,	 8,	 mousex,	 mousey)) >= 0)
		{
			if((ptr_var->adr_form[object].ob_flags & EDITABLE) && (~(ptr_var->adr_form[object].ob_state) & DISABLED))
			{
				if (!m_text_crsr)
				{
					m_text_crsr=TRUE;
					graf_mouse(TEXT_CRSR,	0);
				}
			}
			else
			{
				m_text_crsr=FALSE;
				graf_mouse(ARROW,	0);
			}
		}
	}
	
	if (dialog) {
		if (new_objc > 0 && new_objc != cur_objc || new_pos != cur_pos) {
		 	objc_edit(ptr_var->adr_form,	 cur_objc,	 0,	 cur_pos,	 ED_END,	 &cur_pos);
			cur_pos = new_pos;
			cur_objc = new_objc;
		 	objc_edit(ptr_var->adr_form,	 cur_objc,	 0,	 cur_pos,	 ED_END,	 &cur_pos);
		}
		ptr_var->edit_objc = cur_objc;
		ptr_var->edit_pos = cur_pos;
		return FALSE;		/* LE DIALOGUE CONTINUE !!!!!!!!!!!!!!!!!! */
	}
	else
		return new_objc;
}

static int do_keybd(OBJECT *tree,	 int objc)
{
	int dialog,	 len,	 pos,	 index,	 key_short;
	char *ed_text;
	OBJECT *ptr_objc;

	dialog = form_keybd(tree,	 objc,	 objc,	 key,	 &new_objc,	 &key);

	if (dialog) {
		if (key == 0) {
			ptr_objc = &tree[new_objc];
			new_pos = (int) strlen(((TEDINFO *)(ptr_objc->ob_spec))->te_ptext);
		}
		else {
			if (objc) {	/* S‚curit‚ !!!	*/
				ptr_objc = &tree[objc];
				ed_text = (((TEDINFO *)(ptr_objc->ob_spec)))->te_ptext;
				len = (int) strlen(ed_text);
				pos = new_pos;
				switch (key) {
					case 0x7300 :		/* Control <- : Curseur en d‚but de Champ */
						pos = 0;
						key = 0;
						break;
					case 0x7400 :		/* Control -> : Curseur en fin de Champ */
						pos = len;
						key = 0;
						break;
					case 0x4b34 :		/* SHIFT <- : Saute un mot	*/
						while (pos) {
							pos--;
							if (ed_text[pos] == ' ')
								break;
							}
						key = 0;
						break;
					case 0x4d36 :		/* SHIFT -> : Saute un mot	*/
						while (pos < len) {
							pos++;
							if (ed_text[pos] == ' ')
								break;
							}
						if (pos < len)
							pos++;
						key = 0;
						break;
				}
				new_pos = pos;
			}
			if (key !=0 && (tree[objc].ob_flags & ED_VAR) && key_s!=K_ALT)	/*	filtre texte pour les variables si FLAGS 11 	*/
			{
				key_short = key & 0xff;	/*	filtre le scancode	*/
				if (	(key_short>='A'	&&	key_short<='Z')	||	/*	Liste des caractŠres valide	*/
						(key_short>='a'	&&	key_short<='z')	||
						(key_short>='0'	&&	key_short<='9')	||
						key_short=='_'		||
						key==0x4b00	||	key==0x4d00	||	key==0x537f	||
						key==0xe08	||	key==0x11b	||	key==0x6100)	{ /*	rien	*/ }
				else
					key=0;
			}
			if (key != 0 && key_s == K_ALT) {	/* Raccourcis claviers	*/
				key_short = stdkey(key);
				index = 1;
				do {
					ptr_objc = &tree[index]; /* pointe sur l'objet … traiter */
					ed_text = 0;
					if (
						((ptr_objc->ob_state&DISABLED)==0)  /* si l'objet n'est pas desactive	*/
						&& ((ptr_objc->ob_type & 0x200) != 0)
						) {
/*	Si l'ob_type ‚tendu & 2 est diff‚rent de '0' alors raccourci clavier
	(compatibilit‚ avec BIG et INTERFACE).	*/
						switch (ptr_objc->ob_type & 0xff) {
							case G_BUTTON :
								ed_text =(char *)( ptr_objc->ob_spec);
								break;
							case G_USERDEF :
								ed_text = (char *)( ((USERBLK *)(ptr_objc->ob_spec))->ub_parm);
							}
						if (ed_text && (ed_text = strchr(ed_text,	 '[')) != 0) {
							if (key_short == toupper(ed_text[1])) {
								key = 0;
								/* Simuler un clic sur l'objet et retour : */
								return form_button(tree,	 index,	 1,	 &new_objc);
							}
						}
					}
					index ++; /* Pr‚pare l'objet suivant ... */
				/* ... sauf si l'objet actuel est le dernier : */
				} while((ptr_objc->ob_flags & LASTOB) == 0);
			}
		}
	}
	return dialog;
}

static int do_button(OBJECT *tree,	 int objc)
{
	int i,	 pos,	 dialog,	 offset;
	int objc_x,	 objc_y,	 depht_text[8];
	char test[80];
	OBJECT *ptr_objc;
	char *objc_text,	 *objc_temp;

	dialog = form_button(tree,	 objc,	 1,	 &new_objc);
	if (new_objc > 0 && dialog) {
		ptr_objc = &tree[objc];
		objc_text = ((TEDINFO *)(ptr_objc->ob_spec))->te_ptext;
		objc_temp = ((TEDINFO *)(ptr_objc->ob_spec))->te_ptmplt;
		objc_offset(tree,	 objc,	 &objc_x,	 &objc_y);
		vqt_extent(VDIhandle,	 objc_temp,	 depht_text);
		offset = (ptr_objc->ob_width) - depht_text[2];
		objc_x = mousex - objc_x;
		switch (((TEDINFO *)(ptr_objc->ob_spec))->te_just) {
			case 1:
				objc_x -= offset;
			case 2:
				objc_x -= offset / 2;
			}
		pos = 0;
		for (i = 1; i <= strlen(objc_temp); i++) {
			strncpy(test,	 objc_temp,	 i);
			test[i + 1] = '\0';
			vqt_extent(VDIhandle,	 test,	 depht_text);
			if (depht_text[2] > objc_x)
				break;
			if (objc_temp[i] == '_')
				pos++;
		}
		new_pos = min((int) strlen(objc_text),	 pos);
	}
	return dialog;
}

int rc_intersect(GRECT *p1,	 GRECT *p2)
{
	int tx,	 ty,	 tw,	 th;
	tw = min(p2->g_x + p2->g_w,	 p1->g_x + p1->g_w);
	th = min(p2->g_y + p2->g_h,	 p1->g_y + p1->g_h);
	tx = max(p2->g_x,	 p1->g_x);
	ty = max(p2->g_y,	 p1->g_y);
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	return ((tw > tx) && (th > ty));
}

/*  stdkey() Version personnalis‚e. */

int stdkey(int key_code)
{

	KEYTAB *kt;
	kt = Keytbl((void *)(-1),	 (void *)(-1),	 (void *)(-1)); 
	return toupper(kt->shift[(char)(key_code >> 8)]);
}

int short_cut(int kbd,	int key,	OBJECT	*adr_menu)
{
char option[50],	 ctr;   /* Pour la recherche dans le menu */
unsigned char touc;
int	i;
int evnt=MU_KEYBD;
OBJECT **ptr;

	kbd = (int)Kbshift (-1);  /* Prendre ‚tat des touches sp‚ciales */
   kbd &= ~0x10; /* Annuler bit CapsLock */
   if ((kbd == K_RSHIFT) || (kbd == K_LSHIFT))
		ctr = 0x01;   /* CaractŠre repr‚sentant la touche sp‚ciale */
   else if (kbd == K_CTRL)
		ctr = 0x05E;
	else if (kbd == K_ALT)
		ctr = 0x07;
	else
		ctr = 0;
	if (ctr)
	{
		touc=(unsigned char)stdkey (key);   /* Recherche code Ascii */
		i = 0;
		do    /* Pour chaque objet du menu */
		{
			if (adr_menu[i].ob_type == G_STRING)  /* Si c'est une option */
			{
				strcpy (option,	 adr_menu[i].ob_spec); /* La lire */
				trim (option);  /* Virer les espaces */
				if ((*(option + strlen (option) - 1) == touc) &&
					(*(option + strlen (option) - 2) == ctr))
				{   /* Si le caractŠre et la touche sp‚ciale correspondent */
					if (! (adr_menu[i].ob_state & DISABLED))  /* Si actif */
					{
						evnt = MU_MESAG;  /* Fabriquer un ‚v‚nement */
						buf[0] = MN_SELECTED;
						buf[4] = i;
						ptr= (OBJECT **)&buf[5];
						*ptr=adr_menu;
					}
				}
			}
		} while (! (adr_menu[i++].ob_flags & LASTOB));
	}
	return evnt;
}

/* #[ trim () Vire espaces d‚but et fin de chaŒne :                   */
char *trim (char *str)
{
register char *s;
register int i = 0;
char chaine[MAX_LEN];

  while (*(str + i) == ' ')
    i++;
  strcpy (chaine,	 (str + i));

  s = chaine + strlen (chaine) - 1;
  for( ; (*s == ' ') && (s >= chaine) ; *s-- = 0);
  strcpy (str,	 chaine);
  return str;
}
/* #] trim () Vire espaces d‚but et fin de chaŒne :                   */ 

/*************************************************
 *   Checke et dechecke un pop_up
 *************************************************/
int check_popup(MENU_T *pu,	OBJECT *adr,	int o)
{
int i=1;

	do	/* D‚but de boucle : pour chaque objet du formulaire pop-up */
	{
		if (strcmp(((TEDINFO *)(adr[o].ob_spec))->te_ptext,	
					pu->mn_tree[i].ob_spec)==0)
		{
			pu->mn_tree[i].ob_state |= CHECKED;
			pu->mn_item=i;
		}
		else
			pu->mn_tree[i].ob_state &= ~CHECKED;
	} while (! (pu->mn_tree[i++].ob_flags & LASTOB));	/* Fin de boucle : dernier objet */
	return pu->mn_item;
}

/************************************************************/
/*															*/
/*	Routines USERDEFS										*/
/*															*/
/************************************************************/

int cdecl under_button(PARMBLK *parmblock)
{
	int flags,	 x,	 y,	 w,	 h;
	int test = 0,	 under_pos,	 tx,	 ty; 
	int back_color,	 lb_color,	 lh_color,	 txt_color = BLACK,	 xtype;
	int char_height,	 cell_height,	 dummy;
	int xy_clip[4],	 xy_bar[8],	 attributs[10];
	char chaine[60];
	char *string; /* Pointeur texte pour BUTTON */
	char *key_short;

	xy_clip[0] = parmblock->pb_xc;
	xy_clip[1] = parmblock->pb_yc;
	xy_clip[2] = parmblock->pb_wc + xy_clip[0] - 1;
	xy_clip[3] = parmblock->pb_hc + xy_clip[1] - 1;
	vs_clip(VDIhandle,	 TRUE,	 xy_clip);

	flags = parmblock->pb_tree[parmblock->pb_obj].ob_flags;
	xtype = parmblock->pb_tree[parmblock->pb_obj].ob_type >> 8;
	string = (char *) parmblock->pb_parm;

	x = parmblock->pb_x;
	y = parmblock->pb_y;
	w = parmblock->pb_w;
	h = parmblock->pb_h;

	vqt_attributes(VDIhandle,	 attributs);
	if (xtype == SMALL_B)
		char_height = 4;	/* Petite fonte systŠme. */
	else
		char_height = attributs[7];
	vst_height(VDIhandle,	 char_height,	 &dummy,	 &char_height,	 &dummy,	 &cell_height);
	vst_alignment (VDIhandle,	 0,	 0,	 &dummy,	 &dummy); /* Texte en haut … gauche */

	/* CALCUL DU TEXTE */
	if ((key_short = strchr(string,	 '[')) != 0) {
		strpcpy(chaine,	 string,	 key_short);
		vqt_extent(VDIhandle,	 chaine,	 xy_bar);
		under_pos = xy_bar[2];	/* Position du soulign‚ */
		key_short++;
		strcat(chaine,	 key_short);
	}
	else
		strcpy(chaine,	 string);

	vqt_extent(VDIhandle,	 chaine,	 xy_bar);
	tx = x + (w - xy_bar[2])/2;
	ty = y + (char_height + (h - cell_height)/2);

	if (xtype != SMALL_B) {
		x -= 3; y -= 3; w += 5; h += 5;
	}
	else
		ty++;
	if ((flags & USR_ACTIVATOR) != 0) {
		x -= 2; y -= 2; w += 4; h += 4;		/* Pour la 3 D ! */
	}
	xy_bar[0] = x; xy_bar[1] = y;
	xy_bar[2] = x + w; xy_bar[3] = y + h;
	
	vswr_mode(VDIhandle,	 MD_REPLACE);
	if ((parmblock->pb_currstate & OUTLINED) != 0) {
		vsf_color(VDIhandle,	 WHITE);		/* Pour OUTLINED ...*/
		vsf_interior(VDIhandle,	 1);
		v_bar(VDIhandle,	 xy_bar);		/* ..dessin du fond de l'objet */
	}
	else {
		if (flags & DEFAULT)
			test++;			/* Un cadre pour "DEFAULT"	*/
		if (flags & EXIT)
			test++;			/* Un cadre pour "EXIT"		*/
	}
	vsf_interior(VDIhandle ,	0);
	vswr_mode(VDIhandle,	 MD_TRANS);
	vsf_color(VDIhandle,	 BLACK);		/* Couleur des cadres	*/

	if ((parmblock->pb_currstate & OUTLINED) != 0 || test == 2) {
		v_bar(VDIhandle,	 xy_bar);		/* Cadre Exterieur */
		test--;
	}
	xy_bar[0] ++; xy_bar[1] ++; xy_bar[2] --; xy_bar[3] --;

	if (test > 0)
		v_bar(VDIhandle,	 xy_bar);		/* Cadre Interm‚diaire */
	xy_bar[0] ++; xy_bar[1] ++; xy_bar[2] --; xy_bar[3] --;

	if ((parmblock->pb_currstate & OUTLINED) == 0) /* Cadre Int‚rieur */
		v_bar(VDIhandle,	 xy_bar);
	xy_bar[0] ++; xy_bar[1] ++; xy_bar[2] --; xy_bar[3] --;

	flags &= USR_ACTIVATOR;
	if (flags) {
		back_color = color_3d1;
		if ((parmblock->pb_currstate & SELECTED) == 0) {
			lh_color = WHITE;
			lb_color = color_3d2;
			if (flags == USR_ACTIVATOR) {	/* ACTIVATOR et NORMAL */
				tx--; ty--;
			}
		}
		else {
			lh_color = BLACK;
			lb_color = WHITE;
			if (flags == USR_INDICATOR) {	/* INDICATOR et SELECTED */
				back_color = color_3d2;
				txt_color = WHITE;
				lb_color = color_3d1;
			}
		}
	}
	else if ((parmblock->pb_currstate & SELECTED) != 0) {
			txt_color = WHITE;
			back_color = BLACK;
		}
		else {
			back_color = WHITE;
	}
	vsf_interior(VDIhandle,	 1);
	vsf_color(VDIhandle,	 back_color);
	v_bar(VDIhandle,	 xy_bar);	/* Remplissage Int‚rieur du bouton */

	if (flags) {
		xy_bar[0]++;
		xy_bar[4] = xy_bar[2];
		xy_bar[5] = xy_bar[1] +1;
		xy_bar[1] = xy_bar[3];
		vsl_color(VDIhandle,	 lb_color);
		v_pline(VDIhandle,	 3,	 xy_bar);	/* Trac‚ ligne basse et droite */
		xy_bar[0]--; xy_bar[5]--;
		xy_bar[2] = xy_bar[0];
		xy_bar[3] = xy_bar[5];
		xy_bar[1]--;xy_bar[4]--;
		vsl_color(VDIhandle,	 lh_color);
		v_pline(VDIhandle,	 3,	 xy_bar);	/* Trac‚ ligne gauche et haute */
	}
	vst_color(VDIhandle,	 txt_color);
	vst_effects(VDIhandle,	0);	/*	texte normal	*/
	v_gtext(VDIhandle,	 tx,	 ty,	 chaine);
/*	if ((parmblock->pb_currstate & SELECTED) == 0 && key_short != 0) { Comme ‡… mˆme quand c'est selectionne on voit le underscore. G‚nial non?  */
		vst_color(VDIhandle,	LRED);
		vst_effects(VDIhandle,	 8);	/* mode "Soulign‚"	*/
		v_gtext(VDIhandle,	 tx + under_pos,	 ty,	 " ");
/*	}*/
	vswr_mode(VDIhandle,	 MD_REPLACE);
	vst_color(VDIhandle,	 BLACK);
	vst_height(VDIhandle,	 attributs[7],	 &dummy,	 &dummy,	 &dummy,	 &dummy);
	vs_clip(VDIhandle,	 FALSE,	 xy_clip);

	return (parmblock->pb_currstate & DISABLED);
}

void set_user(OBJECT *addr_tree)
{
	int index = 1;		/* Objet Racine + 1 */
	OBJECT *addr_obj;
	do
	{
		addr_obj = &addr_tree[index];	/* pointe sur l'objet … traiter */
		if ((addr_obj->ob_type & 0xff) == G_BUTTON) {
			switch (addr_obj->ob_type >> 8)
			{
				case UNDER_B :
				case SMALL_B : /* Routine … appeler: "under_button()" */
					set_objc(addr_obj,	 under_button);
					break;
	/* Mettre ici d'autres "case" pour d'autres "buttons" en USERDEFS */
			}
		}
		index ++; /* pr‚pare l'objet suivant ... */
	/* ... sauf si l'objet actuel est le dernier : */
	} while((addr_obj->ob_flags & LASTOB) == 0);
}

void set_objc(OBJECT *addr_obj,	 int cdecl (*code)(PARMBLK *parmblock))
{
	int temp;
	register USERBLK *user;
	if ((user = (USERBLK *) malloc(sizeof(USERBLK))) != 0)
	{
		user->ub_code = code;	
		addr_obj->ob_type = (addr_obj->ob_type & 0xff00) | G_USERDEF;
		user->ub_parm = (long) (addr_obj->ob_spec);
		(addr_obj->ob_spec) = user;

/* Translation des flags 3D en ob_flags_11 et ob_flags_12 : */
		if ((temp = (addr_obj->ob_flags & ACTIVATOR)) != 0) {
			temp <<= 2;
			addr_obj->ob_flags = (addr_obj->ob_flags & ~ACTIVATOR) | temp;
		}
	}
}

/* Fonction de bibliothŠque : Copie dans "dest" la portion de chaine … partir
	du pointeur "start",	 jusqu'au caractŠre plac‚ juste avant le pointeur "stop". 
	"start" et "stop" doivent obligatoirement pointer dans la mˆme chaine.
	Dans tous les cas "dest" est termin‚e par le caractŠre de fin de chaine '\0'.*/

char *strpcpy(char *dest,	 char *start,	 char *stop)
{
	char *ptr_dest = dest;
	while (start < stop && (*(ptr_dest)++ = *(start++)) != 0);

	*ptr_dest = '\0';
	return dest;
}


#ifdef NOT_FALCON
/*-----------------------------------------------------------------------*
 * Capture d'un fond.                                                    *
 *-----------------------------------------------------------------------*/
void get_bkgr (int of_x,	 int of_y,	 int of_w,	 int of_h,	 MFDB *img)
{
	int pxy[8],	i;
	long taille;
	MFDB ecr={0};

	of_x -= 3;										/* Pr‚voir une marge de s‚curit‚ autour  */
	of_y -= 3;										/* de la zone,	 pour le cas o— on aurait  */
	of_w += 5;										/* besoin de sauvegarder le fond d'un    */
	of_h += 5;										/* formulaire avec un attribut OUTLINED. */


	/* Taille tampon de copie fond */
	taille = ((((long)(of_w / 16) + 1) * 2 * (long)xwork_out[4]) * (long)of_h) + 256;
	img->fd_addr = MALLOC (taille);							/* R‚server tampon */
	img->fd_w = of_w;		                      /* Remplir la structure MFDB */
	img->fd_h = of_h;
	img->fd_wdwidth = (of_w / 16) + ((of_w % 16) != 0);
	img->fd_stand = 1;
	img->fd_nplanes = xwork_out[4];

	pxy[0] = of_x;																	 /* Remplir la tableau */
	pxy[1] = of_y;
	pxy[2] = pxy[0] + of_w;
	pxy[3] = pxy[1] + of_h;
	pxy[4] = 0;
	pxy[5] = 0;
	pxy[6] = of_w;
	pxy[7] = of_h;
	v_hide_c (VDIhandle);													/* Virer la souris */
	vro_cpyfm (VDIhandle,	 S_ONLY,	 pxy,	 &ecr,	 img);	/* Copier l'image  */
	v_show_c (VDIhandle,	 TRUE);										/* Remet la souris */
}

/*-----------------------------------------------------------------------*
 * Reaffichage d'un fond.                                                *
 *-----------------------------------------------------------------------*/
void put_bkgr (int of_x,	 int of_y,	 int of_w,	 int of_h,	 MFDB *img)
{
	int pxy[8],	i;
	MFDB ecr={0};

	of_x -= 3;										/* Pr‚voir une marge de s‚curit‚ autour  */
	of_y -= 3;										/* de la zone,	 pour le cas o— on aurait  */
	of_w += 5;										/* besoin de sauvegarder le fond d'un    */
	of_h += 5;										/* formulaire avec un attribut OUTLINED. */

	pxy[0] = 0;										/* Remplir le tableau                    */
	pxy[1] = 0;
	pxy[2] = of_w;
	pxy[3] = of_h;
	pxy[4] = of_x;
	pxy[5] = of_y;
	pxy[6] = pxy[4] + pxy[2];
	pxy[7] = pxy[5] + pxy[3];

	v_hide_c (VDIhandle);		                      /* Cache la souris */
	vro_cpyfm (VDIhandle,	 S_ONLY,	 pxy,	 img,	 &ecr);	/* Copier l'image  */
	v_show_c (VDIhandle,	 TRUE);	                  /* Remet la souris */
	FREE (img->fd_addr);                             /* Lib‚re la m‚moire */
}

/*-----------------------------------------------------------------------*/
int MENU_POPUP( MENU_T *me_menu,	 int me_xpos,	 int me_ypos,	
                                MENU_T *me_mdata)
/*-----------------------------------------------------------------------*
 * Gestion d'un formulaire pop-up                                        *
 *-----------------------------------------------------------------------*/
{
	OBJECT *adr_pu;
	int x,	 y,	 w,	 h,	 dummy,	 old_ob = -1,	 ob = 0,	 b[8],	 xm,	 ym,	 km,	
			evnt,	 sortie = FALSE,	 etat,	 old = 0;
	MFDB image;

	me_mdata->mn_tree=me_menu->mn_tree;
	me_mdata->mn_menu=me_menu->mn_menu;
	me_mdata->mn_item=me_menu->mn_item;
	me_mdata->mn_scroll=me_menu->mn_scroll;
	adr_pu=me_menu->mn_tree;
	x=me_xpos;
	y=me_ypos;

	adr_pu->ob_x = x;									/* Positionner le */
	adr_pu->ob_y = y;									/* formulaire pop_up. */
	w = adr_pu->ob_width;							/* Prendre ses */
	h = adr_pu->ob_height;						/* dimensions. */

	if (me_menu->mn_item)	/* Si le texte du bouton correspond d‚j… … une option du pop-up */
	{	/* On fait co‹ncider les positions de l'option et du bouton */
		y = adr_pu->ob_y = y - adr_pu[me_menu->mn_item].ob_y;
	}

	if (x + w > xb + wb - 5)		/* Si on sort du bureau,	 d‚caler le pop-up */
		x=adr_pu->ob_x = wb + xb - w - 5;	/* avec une marge de 5 pixels */
	if (x < xb + 5)
		x=adr_pu->ob_x = xb + 5;
	if (y + h > yb + hb - 5)
		y=adr_pu->ob_y = hb + yb - h - 5;
	if (y < yb + 5)
		y=adr_pu->ob_y = yb + 5;
		
	get_bkgr (x,	 y,	 w,	 h,	 &image);	/* Copier l'image de fond */
	objc_draw (adr_pu,	 ROOT,	 MAX_DEPTH,	 x - 3,	 y - 3,	 w + 6,	 h + 6);	/* Dessiner le pop-up */

	wind_update(3);

	do	/* BOUCLE PRINCIPALE DE GESTION DU POP-UP */
	{
		evnt = evnt_multi (MU_BUTTON | MU_TIMER,		/* Seuls les clic et le timer nous int‚ressent */
											 1,	 1,	 1,	 0,	 0,	 0,	 0,	 0,	 0,	 0,	 0,	 0,	 0,	
											 b,	 0,	 10,	 &xm,	 &ym,	 &km,	 &dummy,	 &dummy,	 &dummy);
		if (evnt & MU_BUTTON)					/* Si ‚v‚nement de clic souris */
		{
			while (km)	/* On attend que le bouton de la souris soit relƒch‚ */
				graf_mkstate (&dummy,	 &dummy,	 &km,	 &dummy);
			sortie = TRUE;	/* On peut sortir,	 puisqu'on a cliqu‚ */
		}
		else if (evnt == MU_TIMER)	/* Si ‚v‚nement Timer */
		{
			graf_mkstate (&xm,	 &ym,	 &dummy,	 &dummy);	/* Demander coordonn‚es de la souris */

			/* Demander l'option de pop-up … cette position */
			ob = objc_find (adr_pu,	 ROOT,	 MAX_DEPTH,	 xm,	 ym);

			if (old_ob != ob && (adr_pu[ob].ob_flags & SELECTABLE))	/* Si option diff‚rente de la pr‚c‚dente */
			{
				if ((old_ob != -1) && (! (adr_pu[old_ob].ob_state & DISABLED)))
				{	/* On d‚s‚lectionne l'ancienne */
					etat = adr_pu[old_ob].ob_state & ~SELECTED;
					objc_change (adr_pu,	 old_ob,	 0,	 x,	 y,	 w,	 h,	 etat,	 TRUE);
				}
				if ((ob > ROOT) && (! (adr_pu[ob].ob_state & DISABLED)) && (adr_pu[ob].ob_flags & SELECTABLE))
				{	/* Si la nouvelle option existe (on n'est pas sorti du pop-up)
						 et si elle n'est pas DISABLED */
					etat = adr_pu[ob].ob_state | SELECTED;			/* On la s‚lectionne */
					objc_change (adr_pu,	 ob,	 0,	 x,	 y,	 w,	 h,	 etat,	 TRUE);
				}
				old_ob = ob;	/* L'option courante devient l'ancienne option */
			}
			else if (ob == -1)	/* si on est sorti du pop up */
			{
				if ((old_ob != -1) && (! (adr_pu[old_ob].ob_state & DISABLED)))
				{	/* On d‚s‚lectionne l'ancienne */
					etat = adr_pu[old_ob].ob_state & ~SELECTED;
					objc_change (adr_pu,	 old_ob,	 0,	 x,	 y,	 w,	 h,	 etat,	 TRUE);
				}
				old_ob = ob;	/* L'option courante devient l'ancienne option */
			}
		}
	} while (sortie == FALSE);	/* Fin de boucle : tant qu'on n'a pas cliqu‚ */
	wind_update(2);

	put_bkgr (x,	 y,	 w,	 h,	 &image);	/* Restaurer l'image de fond */

	if ((ob > 0) && (! (adr_pu[ob].ob_state & DISABLED)) && (adr_pu[ob].ob_flags & SELECTABLE))
	{	/* Si l'option existe (on n'est pas sorti du pop-up) et si elle n'est pas DISABLED */
		etat = adr_pu[ob].ob_state &= ~SELECTED;				/* La d‚s‚lectionner */
		objc_change (adr_pu,	 ob,	 0,	 x,	 y,	 w,	 h,	 etat,	 FALSE);
		me_mdata->mn_item=ob;
	}	
return TRUE;
}


/**********************************
 *	Place la petite flŠche dans le menu
 *	Pour les paramŠtres ce sont les mˆmes que l'AES
 ************************************/
int MENU_ATTACH( int mode,	 OBJECT *tree,	 int item,	
                                  MENU_T *mdata )
{
char *s;

	s=tree[item].ob_spec;
	
	*(s+strlen(s)-2)=(char)0x3;
}

/******************************************
 *			Appelle le menu hierarchique
 *
 *		menu:	adresse de menu
 *		item:	L'entr‚e du menu hierarchique
 *		pp:	adresse de pop_up
 *
 *	En retour,	 on fabrique un event messag indentique … celui qu'aurait renvoy‚ l'AES.
 *********************************************/
 void Menu_hierarchique(OBJECT *menu,	int item,	OBJECT *pp)
{
MENU_T	pu,	data;	
OBJECT **ptr;
int x,	y;

	pu.mn_tree=pp;		/* pr‚pare le popup	*/
	pu.mn_menu=ROOT;
	pu.mn_item=0;
	pu.mn_scroll=0;
	
	objc_offset(menu,	item,	&x,	&y);
	x+=menu[item].ob_width/2;
	
	if(Menu_popup(&pu,	x,	y,	&data))	/* le balance	*/
	{
		buf[0] = MN_SELECTED;		/* Fabriquer un ‚v‚nement */
		buf[4] = data.mn_item;
		ptr= (OBJECT **)&buf[5];
		*ptr=pp;
		appl_write(ap_id,	16,	buf);
	}
}

#endif

