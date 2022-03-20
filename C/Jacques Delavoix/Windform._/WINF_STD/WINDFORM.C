/****************************************************************************/
/*																			*/
/*	WINDFORM.C : Fonctions de gestion des formulaires en fenàtres.			*/
/*				 par Jacques Delavoix, Janvier-FÇvrier 1995.				*/
/*				Mise Ö jour du 24/03/96										*/
/*																			*/
/****************************************************************************/


#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "windform.h"

/* DÇclarations des variables externes : ATTENTION !!!!	*/

extern int vdi_handle, mousex, mousey, key, key_s, buff[8];
extern int color_3d1, color_3d2; /* Couleurs pour la 3D */

/* Variables Internes :	*/

int hauteur_min;	/* Pour la rÇduction (RÇmy VANEL).	*/
char *window_alert; /* Pointeur sur Alerte "Plus de Fenàtres" */

/* Routines de gestions des Boutons USERDEFS (raccourcis clavier) : */

int cdecl under_button(PARMBLK *parmblock);
void set_user(OBJECT *addr_tree);
void set_objc(OBJECT *addr_obj, int cdecl (*code)(PARMBLK *parmblock));

#ifndef ACTIVATOR
#define ACTIVATOR		0x600
#endif
#define NO_BISTABLE		(DEFAULT | EXIT | EDITABLE | RBUTTON)
#define USR_INDICATOR	0x800
#define USR_ACTIVATOR	0x1800
#define SMALL_FLAG		0x400	/* Mini Bouton	*/

/* ******** Fonctions privÇes rÇservÇes Ö windform_do(): ******** */

static int do_keybd(OBJECT *tree, int objc);
static int do_button(OBJECT *tree, int objc);


char rsc1[] = "[2][| Le Fichier Ressource |     ";
char rsc2[] = "| n'a pu àtre trouvÇ.][ Quitter ]";

int load_rsc(char *rsc_name, int wind_fail)
{
	char str_alert[256];
	if (rsrc_load(rsc_name) == 0)
	{
		sprintf(str_alert, "%s%s%s" , rsc1, rsc_name, rsc2);
		form_alert(1, str_alert);
		return FALSE;
	}
	window_alert = rsrc_get_string(wind_fail);
	return TRUE;
}

void init_var(WINDFORM_VAR *ptr_var, int form_index, int inf_x, int inf_y)
{
	int wx, wy, ww, wh, wh2, x_desk, y_desk, w_desk, h_desk;
	int offset = 0, inf_flag = 0;
	OBJECT *adresse_form;
	rsrc_gaddr(R_TREE, form_index, &adresse_form);
	ptr_var->adr_form = adresse_form;

	if (adresse_form->ob_state & OUTLINED)	/* Ce dÇcalage est invariable !!! */
		ptr_var->offset = offset = 3;

	form_center(adresse_form, &wx, &wy, &ww, &wh);
	wh2 = wh;
	wind_calc(WC_BORDER, FW_ATTRIB, wx, wy, ww, wh, &wx, &wy, &ww, &wh);
	hauteur_min = (wh - wh2) - 2; /* Taille rÇduite, addition de RÇmi VANEL. */
	wind_get(0, WF_WORKXYWH, &x_desk, &y_desk, &w_desk, &h_desk);

	if (inf_x != 0 || inf_y != 0)	/* si valeurs lues dans fichier .INF ... */
	{
/*	RetombÇe du developpement de "DECOCALC" : un recadrage automatique dans le
	cas ou les donnÇes lues dans un fichier "INF" tendraient Ö faire sortir le
	formulaire de l'Çcran.	*/
		if (inf_x > (w_desk - ww))
			inf_x = w_desk - (ww + 3);	/* cadrage Ö droite.	*/
		if (inf_x < 0)
			inf_x = 0;					/* SÇcuritÇ Ö Gauche. */
		if (inf_y > (y_desk + h_desk) - wh)
			inf_y = (y_desk + h_desk) - (wh + 3); /* cadrage en bas. */
		if (inf_y < y_desk)
			inf_y = y_desk;				/* cadrage en haut.		*/

		wx = inf_x; wy = inf_y;
		inf_flag = TRUE;
	}
	ptr_var->w_x = wx; ptr_var->w_y = wy;
	ptr_var->w_w = ww; ptr_var->w_h = wh;
	if (inf_flag != 0)		/* ... alors recaler le formulaire sur la fenàtre. */
	{
		wind_calc(WC_WORK, FW_ATTRIB, wx, wy, ww, wh, &wx, &wy, &ww, &wh);
		adresse_form->ob_x = wx + offset;
		adresse_form->ob_y = wy + offset;
	}
	set_user(adresse_form);	/* Etablissement des boutons USERDEFS.	*/
}

void open_dialog(WINDFORM_VAR *ptr_var, char *w_title, int edit_first)
{
	OBJECT *ptr_objc;
	if (ptr_var->w_handle != 0)
	{
		wind_set(ptr_var->w_handle, WF_TOP);
	}
	else
	{
		if ((ptr_var->w_handle = wind_create(FW_ATTRIB, ptr_var->w_x,
						ptr_var->w_y, ptr_var->w_w, ptr_var->w_h)) != 0)
		{
			wind_set(ptr_var->w_handle, WF_NAME, w_title);
/*			graf_growbox(0, 0, 0, 0, ptr_var->w_x, ptr_var->w_y,
						ptr_var->w_w, ptr_var->w_h);		GADGET ! */
			wind_open(ptr_var->w_handle, ptr_var->w_x, ptr_var->w_y,
					ptr_var->w_w, ptr_var->w_h);
			ptr_var->edit_objc = edit_first;
			ptr_objc = &(ptr_var->adr_form[edit_first]);
			if ((ptr_objc->ob_flags & EDITABLE) != 0)
				ptr_var->edit_pos = (int)strlen(ptr_objc->ob_spec.tedinfo->te_ptext);
			ptr_var->reduced = FALSE;	/* RÇmy VANEL	*/
		}
		else
			form_alert(1, window_alert); /* NO_WINDOW dans le Ressource. */
/*			form_alert(1, "[3][   Il n'y a plus de| fenàtres disponibles !"
					"| Fermez une fenàtre que|  vous n'utilisez pas.][Confirmer]"); */
	}
}

void close_dialog(WINDFORM_VAR *ptr_var)
{
	if (ptr_var->w_handle != 0)
	{
		wind_close(ptr_var->w_handle);
		wind_delete(ptr_var->w_handle);
/*		graf_shrinkbox(0, 0, 0, 0, ptr_var->w_x, ptr_var->w_y,
						ptr_var->w_w, ptr_var->w_h);		GADGET ! */
		ptr_var->w_handle = FALSE;
	}
}

static int new_objc, new_pos;

int windform_do(WINDFORM_VAR *ptr_var, int event)
{
	GRECT r, rd;
	int wx, wy, ww, wh, cur_pos;
	int dialog = TRUE, cur_objc, object, init_field = FALSE;

	new_objc = cur_objc = ptr_var->edit_objc;
	new_pos = cur_pos = ptr_var->edit_pos;
	if (event & MU_MESAG)
	{
		switch(buff[0])
		{
			case WM_REDRAW :
				rd.g_x = buff[4]; rd.g_y = buff[5];
				rd.g_w = buff[6]; rd.g_h = buff[7];
				if (cur_objc)	/* si champ Çditable et ....*/
				{
					wind_get(0, WF_TOP, &wx, &wy, &ww, &wh);
					if (buff[3] == wx && !ptr_var->reduced)
					{ /*...si fenàtre au 1¯ plan => redessin total. */
						wind_get(buff[3], WF_WORKXYWH, &rd.g_x, &rd.g_y,
								&rd.g_w, &rd.g_h);
						init_field = ED_END;
					}
				}
				wind_update(BEG_UPDATE);
				wind_get(buff[3], WF_FIRSTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
				while (r.g_w && r.g_h)
				{
					if (rc_intersect(&rd, &r))
					{
						objc_draw(ptr_var->adr_form, 0, 8, r.g_x, r.g_y, r.g_w, r.g_h);
					}
					wind_get(buff[3], WF_NEXTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
				}
				wind_update(END_UPDATE);
				if (cur_objc && init_field)
					objc_edit(ptr_var->adr_form, cur_objc, 0, &cur_pos, init_field);
				break;
			case WM_TOPPED :
				wind_set(buff[3], WF_TOP);
				if (cur_objc && flag_multitache == -1) /* si MULTITOS ... */
				{
					wind_get(buff[3], WF_WORKXYWH, &wx, &wy, &ww, &wh);
					form_dial(FMD_FINISH, 0,0,0,0, wx, wy, ww, wh);				
				}
				break;
			case WM_CLOSED : 
				return CLOSE_DIAL;

			case WM_MOVED :
				wind_set(buff[3], WF_CURRXYWH, buff[4], buff[5], buff[6], buff[7]);
				ptr_var->w_x = buff[4]; ptr_var->w_y = buff[5];
				wind_get(buff[3], WF_WORKXYWH, &wx, &wy, &ww, &wh);
				ptr_var->adr_form->ob_x = wx + ptr_var->offset;
				ptr_var->adr_form->ob_y = wy + ptr_var->offset;
				break;
			case WM_FULLED :	/* Nouvelle Fonction par RÇmi VANEL !!!	*/
				if (!ptr_var->reduced)
				{	/* on rÇduit au maximum la fenàtre en hauteur */
					wind_set(buff[3], WF_CURRXYWH, ptr_var->w_x, ptr_var->w_y,
							ptr_var->w_w, hauteur_min);
					ptr_var->reduced = TRUE;
				}
				else
				{	/* on la rÇouvre */
					wind_set(buff[3], WF_CURRXYWH, ptr_var->w_x, ptr_var->w_y,
							ptr_var->w_w, ptr_var->w_h);
					ptr_var->reduced = FALSE;
				}
		}
	}
	else if (event & MU_KEYBD && !ptr_var->reduced)
	{
		dialog = do_keybd(ptr_var->adr_form, cur_objc);
		if (key)
		{
			objc_edit(ptr_var->adr_form, cur_objc, key, &cur_pos, ED_CHAR);
			new_objc = cur_objc;
			new_pos = cur_pos;
		}
	}

	else if (event & MU_BUTTON)
	{
		if ((object = objc_find(ptr_var->adr_form, 0, 8, mousex, mousey)) > 0)
		{
			dialog = do_button(ptr_var->adr_form, object);
		}
	}
	if (dialog)
	{
		if (new_objc > 0 && new_objc != cur_objc || new_pos != cur_pos)
		{
			objc_edit(ptr_var->adr_form, cur_objc, 0, &cur_pos, ED_END);
			cur_pos = new_pos;
			objc_edit(ptr_var->adr_form, new_objc, 0, &cur_pos, ED_END);
			cur_objc = new_objc;
		}
		ptr_var->edit_objc = cur_objc;
		ptr_var->edit_pos = cur_pos;
		return FALSE;		/* LE DIALOGUE CONTINUE !!!!!!!!!!!!!!!!!! */
	}
	else
		return new_objc;
}

static int do_keybd(OBJECT *tree, int objc)
{
	int dialog, len, pos, index, key_short;
	char *ed_text;
	OBJECT *ptr_objc;
	dialog = form_keybd(tree, objc, objc, key, &new_objc, &key);
	if (dialog)
	{
		if (key == 0)
		{
			if (new_objc)	/* si NOUVEAU champ Çditable.	*/
			{
				ptr_objc = &tree[new_objc];
				new_pos = (int) strlen((ptr_objc->ob_spec.tedinfo)->te_ptext);
			}
		}
		else
		{
			if (objc)		/* Si champ Çditable.	*/
			{
				ptr_objc = &tree[objc];
				ed_text = (ptr_objc->ob_spec.tedinfo)->te_ptext;
				len = (int) strlen(ed_text);
				pos = new_pos;
				switch (key) {
					case 0x7300 :		/* Control <- : Curseur en dÇbut de Champ */
						pos = 0;
						key = 0;
						break;
					case 0x7400 :		/* Control -> : Curseur en fin de Champ */
						pos = len;
						key = 0;
						break;
					case 0x4b34 :		/* SHIFT <- : Saute un mot	*/
						while (pos)
						{
							pos--;
							if (ed_text[pos] == ' ')
								break;
						}
						key = 0;
						break;
					case 0x4d36 :		/* SHIFT -> : Saute un mot	*/
						while (pos < len)
						{
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
			if (key != 0 && key_s == K_ALT)		/* Raccourcis claviers	*/
			{
				key_short = stdkey(key);
				index = 1;
				do
				{
					ptr_objc = &tree[index]; /* pointe sur l'objet Ö traiter */
					ed_text = 0;
					if ((ptr_objc->ob_state & DISABLED) == 0 &&
						(ptr_objc->ob_type & 0x200) != 0)
					{
/*	Si l'ob_type Çtendu & 2 est diffÇrent de '0' alors raccourci clavier.
	(compatibilitÇ avec BIG et INTERFACE).	*/
						switch (ptr_objc->ob_type & 0xff)
						{
							case G_BUTTON :
								ed_text = ptr_objc->ob_spec.free_string;
								break;
							case G_USERDEF :
								ed_text = (char *)((ptr_objc->ob_spec.userblk)->ub_parm);
						}
						if (ed_text && (ed_text = strchr(ed_text, '[')) != 0)
						{
							if (key_short == toupper(ed_text[1]))
							{
								key = 0;
								/* Simuler un clic sur l'objet et retour : */
								return form_button(tree, index, 1, &new_objc);
							}
						}
					}
					index ++; /* PrÇpare l'objet suivant ... */
				/* ... sauf si l'objet actuel est le dernier : */
				} while((ptr_objc->ob_flags & LASTOB) == 0);
			}
		}
	}
	return dialog;
}

static int do_button(OBJECT *tree, int objc)
{
	int i, pos, dialog, offset;
	int objc_x, objc_y, depht_text[8];
	char test[80];
	OBJECT *ptr_objc;
	char *objc_text, *objc_temp;

	dialog = form_button(tree, objc, 1, &new_objc);
	if (new_objc > 0 && dialog)
	{
		ptr_objc = &tree[objc];
		objc_text = (ptr_objc->ob_spec.tedinfo)->te_ptext;
		objc_temp = (ptr_objc->ob_spec.tedinfo)->te_ptmplt;
		objc_offset(tree, objc, &objc_x, &objc_y);
		vqt_extent(vdi_handle, objc_temp, depht_text);
		offset = (ptr_objc->ob_width) - depht_text[2];
		objc_x = mousex - objc_x;
		switch ((ptr_objc->ob_spec.tedinfo)->te_just)
		{
			case 1:
				objc_x -= offset;
			case 2:
				objc_x -= offset / 2;
		}
		pos = 0;
		for (i = 1; i <= strlen(objc_temp); i++)
		{
			strncpy(test, objc_temp, i);
			test[i + 1] = '\0';
			vqt_extent(vdi_handle, test, depht_text);
			if (depht_text[2] > objc_x)
				break;
			if (objc_temp[i] == '_')
				pos++;
		}
		new_pos = min((int) strlen(objc_text), pos);
	}
	return dialog;
}

int rc_intersect(GRECT *p1, GRECT *p2)
{
	int tx, ty, tw, th;
	tw = min(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
	th = min(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
	tx = max(p2->g_x, p1->g_x);
	ty = max(p2->g_y, p1->g_y);
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	return ((tw > tx) && (th > ty));
}

/*  stdkey() Version personnalisÇe. */

int stdkey(int key_code)
{
	KEYTAB *kt;
	kt = Keytbl((void *)-1, (void *)-1, (void *)-1);
	return toupper(kt->shift[(char)(key_code >> 8)]);
}

/************************************************************/
/*															*/
/*	Routines USERDEFS										*/
/*															*/
/************************************************************/

int cdecl under_button(PARMBLK *parmblock)
{
	int flags, x, y, w, h, flags_no_bistable;
	int test = 0, under_pos, tx, ty; 
	int back_color, lb_color, lh_color, txt_color = BLACK, small_button;
	int char_height, cell_height, dummy;
	int xy_clip[4], xy_bar[8], attributs[10];
	char chaine[60];
	char *string; /* Pointeur texte pour BUTTON */
	char *key_short;

	xy_clip[0] = parmblock->pb_xc;
	xy_clip[1] = parmblock->pb_yc;
	xy_clip[2] = parmblock->pb_wc + xy_clip[0] - 1;
	xy_clip[3] = parmblock->pb_hc + xy_clip[1] - 1;
	vs_clip(vdi_handle, TRUE, xy_clip);

	flags = parmblock->pb_tree[parmblock->pb_obj].ob_flags;
	flags_no_bistable = flags & NO_BISTABLE;
	small_button = parmblock->pb_tree[parmblock->pb_obj].ob_type & SMALL_FLAG;
	string = (char *) parmblock->pb_parm;

	x = parmblock->pb_x;
	y = parmblock->pb_y;
	w = parmblock->pb_w;
	h = parmblock->pb_h;

	vqt_attributes(vdi_handle, attributs);
	if (small_button == FALSE)
		char_height = attributs[7];
	else
		char_height = 4;	/* Petite fonte systäme. */
	vst_height(vdi_handle, char_height, &dummy, &char_height, &dummy, &cell_height);

	/* CALCUL DU TEXTE */
	if ((key_short = strchr(string, '[')) != 0)
	{
		strpcpy(chaine, string, key_short);
		vqt_extent(vdi_handle, chaine, xy_bar);
		under_pos = xy_bar[2];	/* Position du soulignÇ */
		key_short++;
		strcat(chaine, key_short);
	}
	else
		strcpy(chaine, string);

	vqt_extent(vdi_handle, chaine, xy_bar);
	tx = x + (w - xy_bar[2])/2;
	ty = y + (char_height + (h - cell_height)/2);

	if (small_button == FALSE)
	{
		x -= 3; y -= 3; w += 5; h += 5;
	}
	else
	{
		tx++; ty++;
	}

	if ((flags & USR_ACTIVATOR) != 0)	/* Pour la 3 D ! */
	{
		if (small_button == FALSE)
		{
			x -= 2; y -= 2; w += 4; h += 4;
		}
		else
		{
			x -= 1; y -= 1; w += 2; h += 2;
		}
	}
	xy_bar[0] = x; xy_bar[1] = y;
	xy_bar[2] = x + w; xy_bar[3] = y + h;
	
	vswr_mode(vdi_handle, MD_REPLACE);
	if ((parmblock->pb_currstate & OUTLINED) != 0)
	{
		vsf_color(vdi_handle, WHITE);	/* Pour OUTLINED ...*/
		vsf_interior(vdi_handle, 1);
		v_bar(vdi_handle, xy_bar);		/* ..dessin du fond de l'objet */
	}
	else
	{
		if (flags & DEFAULT)
			test++;			/* Un cadre pour "DEFAULT"	*/
		if (flags & EXIT)
			test++;			/* Un cadre pour "EXIT"		*/
	}
	vsf_interior(vdi_handle ,0);
	vswr_mode(vdi_handle, MD_TRANS);
	vsf_color(vdi_handle, BLACK);		/* Couleur des cadres	*/

	if ((parmblock->pb_currstate & OUTLINED) != 0 || test == 2)
	{
		v_bar(vdi_handle, xy_bar);		/* Cadre Exterieur */
		test--;
	}
	xy_bar[0] ++; xy_bar[1] ++; xy_bar[2] --; xy_bar[3] --;

	if (test > 0)
		v_bar(vdi_handle, xy_bar);		/* Cadre IntermÇdiaire */
	xy_bar[0] ++; xy_bar[1] ++; xy_bar[2] --; xy_bar[3] --;

	if ((parmblock->pb_currstate & OUTLINED) == 0) /* Cadre IntÇrieur */
		v_bar(vdi_handle, xy_bar);
	xy_bar[0] ++; xy_bar[1] ++; xy_bar[2] --; xy_bar[3] --;

	flags &= USR_ACTIVATOR;
	if (flags != 0)
	{
		back_color = color_3d1;
		if ((parmblock->pb_currstate & SELECTED) == 0)
		{
			lh_color = WHITE;
			lb_color = color_3d2;
			if (flags == USR_ACTIVATOR)	/* ACTIVATOR et NORMAL */
			{
				tx--; ty--;
			}
		}
		else
		{
			lh_color = BLACK;
			lb_color = WHITE;
			if (flags == USR_INDICATOR)	/* INDICATOR et SELECTED */
			{
				back_color = color_3d2;
				txt_color = WHITE;
				lb_color = color_3d1;
			}
		}
	}
	else if ((parmblock->pb_currstate & SELECTED) != 0)
	{
			txt_color = WHITE;
			back_color = BLACK;
	}
	else
	{
			back_color = WHITE;
	}
	vsf_interior(vdi_handle, 1);
	vsf_color(vdi_handle, back_color);
	v_bar(vdi_handle, xy_bar);	/* Remplissage IntÇrieur du bouton */

	if (flags)
	{
		xy_bar[0]++;
		xy_bar[4] = xy_bar[2];
		xy_bar[5] = xy_bar[1] +1;
		xy_bar[1] = xy_bar[3];
		vsl_color(vdi_handle, lb_color);
		v_pline(vdi_handle, 3, xy_bar);	/* TracÇ ligne basse et droite */
		xy_bar[0]--; xy_bar[5]--;
		xy_bar[2] = xy_bar[0];
		xy_bar[3] = xy_bar[5];
		xy_bar[1]--;xy_bar[4]--;
		vsl_color(vdi_handle, lh_color);
		v_pline(vdi_handle, 3, xy_bar);	/* TracÇ ligne gauche et haute */
	}
	vst_color(vdi_handle, txt_color);
	v_gtext(vdi_handle, tx, ty, chaine);
	if (key_short != 0 && ((parmblock->pb_currstate & SELECTED) == 0 ||
					flags_no_bistable == 0))
	{
		if (small_button != 0)
		{
			tx--; ty++;
		}
		vst_effects(vdi_handle, 8);	/* mode "SoulignÇ"	*/
		v_gtext(vdi_handle, tx + under_pos, ty, " ");
		vst_effects(vdi_handle, 0);	/* mode "Normal"	*/
	}
	vswr_mode(vdi_handle, MD_REPLACE);
	vst_color(vdi_handle, BLACK);
	vst_height(vdi_handle, attributs[7], &dummy, &dummy, &dummy, &dummy);
	return (parmblock->pb_currstate & DISABLED);
}

void set_user(OBJECT *addr_tree)
{
	int index = 1;		/* L'objet Racine n'est pas traitÇ. */
	OBJECT *addr_obj;
	do
	{
		addr_obj = &addr_tree[index];	/* pointe sur l'objet Ö traiter */
		if ((addr_obj->ob_type & 0xff) == G_BUTTON)
		{
			switch (addr_obj->ob_type >> 8)
			{
				case UNDER_B :
				case SMALL_B : /* Routine Ö appeler: "under_button()" : */
					set_objc(addr_obj, under_button);
					break;
	/* Mettre ici d'autres "case" pour d'autres "buttons" en USERDEFS */
			}
		}
		index ++; /* prÇpare l'objet suivant ... */
	/* ... sauf si l'objet actuel est le dernier : */
	} while((addr_obj->ob_flags & LASTOB) == 0);
}

void set_objc(OBJECT *addr_obj, int cdecl (*code)(PARMBLK *parmblock))
{
	int temp;
	register USERBLK *user;
	if ((user = (USERBLK *) malloc(sizeof(USERBLK))) != 0)
	{
		user->ub_code = code;
		addr_obj->ob_type = (addr_obj->ob_type & 0xff00) | G_USERDEF;
		user->ub_parm = (long) addr_obj->ob_spec.userblk;
		addr_obj->ob_spec.userblk = user;

/* Translation des flags 3D en ob_flags_11 et ob_flags_12 : */
		if ((temp = (addr_obj->ob_flags & ACTIVATOR)) != 0)
		{
			temp <<= 2;
			addr_obj->ob_flags = (addr_obj->ob_flags & ~ACTIVATOR) | temp;
		}
	}
}

/* Fonction de bibliothäque : Copie dans "dest" la portion de chaine Ö partir
	du pointeur "start", jusqu'au caractäre placÇ juste avant le pointeur "stop". 
	"start" et "stop" doivent obligatoirement pointer dans la màme chaine.
	Dans tous les cas "dest" est terminÇe par le caractäre de fin de chaine '\0'.*/

char *strpcpy(char *dest, char *start, char *stop)
{
	char *ptr_dest = dest;
	while (start < stop && (*(ptr_dest)++ = *(start++)) != 0);

	*ptr_dest = '\0';
	return dest;
}

char *rsrc_get_string(int index)
{
	char **free_string;
	rsrc_gaddr(R_FRSTR, index, &free_string);
	return *free_string;
}
