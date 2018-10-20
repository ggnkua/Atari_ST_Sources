#include <grape_h.h>
#include "grape.h"
#include "undo.h"
#include "layer.h"
#include "mask.h"
#include "mm_copy.h"
#include "main_win.h"
#include "preview.h"
#include "file_i_o.h"
#include "mforms.h"
#include "maininit.h"
#include "jobs.h"
#include "xrsrc.h"
#include "zoom.h"

/* Layers */

void cop_pop(int ob, int ob_typ, int a_ob, int a_typ);
void cop_typ(int ob_nam, int ob, int a_ob, int a_typ, int old_ob);
void set_cop_how(void);
void copy_distribute(int how);


void init_layob(void)
{
	int		a, dif=LAY2-LAY1;
	LAYER	*lay;
	LAY_LIST	*ll=first_lay;
	
	otoolbar[LAYLED].ob_spec.bitblk->bi_color=11; /* 3=HellgrÅn, 11=DunkelgrÅn */

	act_lay=NULL;
	
	/* Nach aktivem Layer und Solo-Mode in allen Ebenen suchen */
	/* (nicht nur in den im Toolbar angezeigten */

	while(ll)
	{
		if(ll->this.draw)
			act_lay=ll;
		if(ll->this.solo)
		{
			otoolbar[LAYLED].ob_spec.bitblk->bi_color=3; /* 3=HellgrÅn, 11=DunkelgrÅn */
			act_lay=ll;
		}
		ll=ll->next;
	}		
	
	/* Anzeige aktualisieren */
	
	for(a=0; a < 8 ; ++a)
	{
		lay=find_layer(a+layers_off);
		if(lay)
		{
			otoolbar[LAYNAM+a*dif].ob_state &= (~SELECTED);
			((TED_COLOR*)&(otoolbar[LAYNAM+a*dif].ob_spec.tedinfo->te_color))->pattern=0;
			((TED_COLOR*)&(otoolbar[LAYNAM+a*dif].ob_spec.tedinfo->te_color))->pat_color=0;

			otoolbar[LAYVIS-1+a*dif].ob_state &= (~(SELECTED|DISABLED));
			((TED_COLOR*)&(otoolbar[LAYVIS-1+a*dif].ob_spec.tedinfo->te_color))->pattern=0;
			((TED_COLOR*)&(otoolbar[LAYVIS-1+a*dif].ob_spec.tedinfo->te_color))->pat_color=0;
			otoolbar[LAYVIS+a*dif].ob_x=TB_IMG_X;
			otoolbar[LAYVIS+a*dif].ob_y=0;

			otoolbar[LAYPEN-1+a*dif].ob_state &= (~SELECTED);
			((TED_COLOR*)&(otoolbar[LAYPEN-1+a*dif].ob_spec.tedinfo->te_color))->pattern=0;
			((TED_COLOR*)&(otoolbar[LAYPEN-1+a*dif].ob_spec.tedinfo->te_color))->pat_color=0;
			otoolbar[LAYPEN+a*dif].ob_x=TB_IMG_X;
			otoolbar[LAYPEN+a*dif].ob_y=0;

			otoolbar[LAYSOLO-1+a*dif].ob_state &= (~SELECTED);
			((TED_COLOR*)&(otoolbar[LAYSOLO-1+a*dif].ob_spec.tedinfo->te_color))->pattern=0;
			((TED_COLOR*)&(otoolbar[LAYSOLO-1+a*dif].ob_spec.tedinfo->te_color))->pat_color=0;
			otoolbar[LAYSOLO+a*dif].ob_x=TB_IMG_X;
			otoolbar[LAYSOLO+a*dif].ob_y=0;

			if(lay->selected)
			{
				otoolbar[LAYNAM+a*dif].ob_state |= SELECTED;
				((TED_COLOR*)&(otoolbar[LAYNAM+a*dif].ob_spec.tedinfo->te_color))->pattern=7;
				((TED_COLOR*)&(otoolbar[LAYNAM+a*dif].ob_spec.tedinfo->te_color))->pat_color=13;
			}
			if(lay->visible)
			{
				otoolbar[LAYVIS-1+a*dif].ob_state |= SELECTED;
				if((!lay->solo) && (lay->visible & DISABLED))
					otoolbar[LAYVIS-1+a*dif].ob_state |= DISABLED;
				((TED_COLOR*)&(otoolbar[LAYVIS-1+a*dif].ob_spec.tedinfo->te_color))->pattern=7;
				((TED_COLOR*)&(otoolbar[LAYVIS-1+a*dif].ob_spec.tedinfo->te_color))->pat_color=13;
				otoolbar[LAYVIS+a*dif].ob_x=TB_IMG_X+1;
				otoolbar[LAYVIS+a*dif].ob_y=1;
			}
			if(lay->draw)
			{
				otoolbar[LAYPEN-1+a*dif].ob_state |= SELECTED;
				((TED_COLOR*)&(otoolbar[LAYPEN-1+a*dif].ob_spec.tedinfo->te_color))->pattern=7;
				((TED_COLOR*)&(otoolbar[LAYPEN-1+a*dif].ob_spec.tedinfo->te_color))->pat_color=13;
				otoolbar[LAYPEN+a*dif].ob_x=TB_IMG_X+1;
				otoolbar[LAYPEN+a*dif].ob_y=1;
			}
			if(lay->solo)
			{
				otoolbar[LAYSOLO-1+a*dif].ob_state |= SELECTED;
				((TED_COLOR*)&(otoolbar[LAYSOLO-1+a*dif].ob_spec.tedinfo->te_color))->pattern=7;
				((TED_COLOR*)&(otoolbar[LAYSOLO-1+a*dif].ob_spec.tedinfo->te_color))->pat_color=13;
				otoolbar[LAYSOLO+a*dif].ob_x=TB_IMG_X+1;
				otoolbar[LAYSOLO+a*dif].ob_y=1;
			}

			strcpy(otoolbar[LAYNAM+a*dif].ob_spec.tedinfo->te_ptext, lay->name);
			otoolbar[LAY1+a*dif].ob_flags &= (~HIDETREE);
		}
		else
			otoolbar[LAY1+a*dif].ob_flags |= HIDETREE;

	}
	strcpy(otoolbar[MASK_NAM].ob_spec.tedinfo->te_ptext, act_mask->this.name);
	
	if((!act_lay) && !(otoolbar[MASK_ED-1].ob_state & SELECTED))
	{/* Kein Stift selektiert->die Ebene wurde wohl gelîscht! */
	 /* Erste in sichtbarer Liste nehmen */
		lay=find_layer(layers_off);
		lay->draw=1;
		init_layob();
	}
	
	/* Hintergrundfarben fÅr Maskenbuttons setzen */
	if(otoolbar[MASK_ON-1].ob_state & SELECTED)
	{
		((TED_COLOR*)&(otoolbar[MASK_ON-1].ob_spec.tedinfo->te_color))->pattern=7;
		((TED_COLOR*)&(otoolbar[MASK_ON-1].ob_spec.tedinfo->te_color))->pat_color=14;
	}
	else
	{
		((TED_COLOR*)&(otoolbar[MASK_ON-1].ob_spec.tedinfo->te_color))->pattern=0;
		((TED_COLOR*)&(otoolbar[MASK_ON-1].ob_spec.tedinfo->te_color))->pat_color=0;
	}
	if(otoolbar[MASK_VIS-1].ob_state & SELECTED)
	{
		((TED_COLOR*)&(otoolbar[MASK_VIS-1].ob_spec.tedinfo->te_color))->pattern=7;
		((TED_COLOR*)&(otoolbar[MASK_VIS-1].ob_spec.tedinfo->te_color))->pat_color=14;
	}
	else
	{
		((TED_COLOR*)&(otoolbar[MASK_VIS-1].ob_spec.tedinfo->te_color))->pattern=0;
		((TED_COLOR*)&(otoolbar[MASK_VIS-1].ob_spec.tedinfo->te_color))->pat_color=0;
	}
	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{
		((TED_COLOR*)&(otoolbar[MASK_ED-1].ob_spec.tedinfo->te_color))->pattern=7;
		((TED_COLOR*)&(otoolbar[MASK_ED-1].ob_spec.tedinfo->te_color))->pat_color=14;
	}
	else
	{
		((TED_COLOR*)&(otoolbar[MASK_ED-1].ob_spec.tedinfo->te_color))->pattern=0;
		((TED_COLOR*)&(otoolbar[MASK_ED-1].ob_spec.tedinfo->te_color))->pat_color=0;
	}
	
}

LAYER *find_layer(int a)
{
	LAY_LIST *l=first_lay;
	
	while((a--) && l)
		l=l->next;

	++a;

	if(a || (!l))
		return(NULL);
	
	return(&l->this);
}

LAYER *find_layer_id(int id)
{
	LAY_LIST *l=first_lay;

	while(l)
	{
		if(l->this.id == id)
			return(&l->this);
		l=l->next;
	}
	
	return(NULL);
}

LAY_LIST *find_lay_list(int a)
{
	LAY_LIST *l=first_lay;
	
	while((a--) && l)
		l=l->next;
	
	return(l);
}

LAY_LIST *find_lay_list_id(int id)
{
	LAY_LIST *l=first_lay;

	while(l)
	{
		if(l->this.id == id)
			return(l);
		l=l->next;
	}
	
	return(NULL);
}

void insert_layer_win(void)
{
	
	strcpy(onewlay[NLTITEL].ob_spec.tedinfo->te_ptext, "Ebene hinzufÅgen");
	if(!wnewlay.open)
	{
		wnewlay.dinfo=&dnewlay;
		w_dial(&wnewlay, D_CENTER);
		wnewlay.name="[Grape]";
		w_set(&wnewlay, NAME);
		dnewlay.dedit=NLNAME;
		w_open(&wnewlay);
	}
	else
	{
		w_top(&wnewlay);
		s_redraw(&wnewlay);
	}
	onewlay[NEWMOD].ob_state &= (~SELECTED);
}

void modify_layer_win(void)
{
	strcpy(onewlay[NLTITEL].ob_spec.tedinfo->te_ptext, "Ebene modifizieren");
	strcpy(onewlay[NLNAME].ob_spec.tedinfo->te_ptext, mod_lay->name);
	onewlay[NLTYP1].ob_state&=(~SELECTED);
	onewlay[NLTYP2].ob_state&=(~SELECTED);
	onewlay[NLTYP3].ob_state&=(~SELECTED);
	onewlay[NLTYP1+mod_lay->type].ob_state |= SELECTED;
	
	if(!wnewlay.open)
	{
		wnewlay.dinfo=&dnewlay;
		w_dial(&wnewlay, D_CENTER);
		wnewlay.name="[Grape]";
		w_set(&wnewlay, NAME);
		dnewlay.dedit=NLNAME;
		w_open(&wnewlay);
	}
	else
	{
		w_top(&wnewlay);
		s_redraw(&wnewlay);
	}
	onewlay[NEWMOD].ob_state |= SELECTED;
}

void dial_newlay(int ob)
{
	switch(ob)
	{
		case NLOK:
			if(!onewlay[NLNAME].ob_spec.tedinfo->te_ptext[0])
			{
				form_alert(1,"[3][Grape:|Der Name darf nicht leer sein!][OK]");
				w_unsel(&wnewlay, ob);
				break;
			}
			if(onewlay[NEWMOD].ob_state & SELECTED)
				modify_layer();
			else
				insert_layer();
		case NLABBRUCH:
			w_unsel(&wnewlay, ob);
			w_close(&wnewlay);
			w_kill(&wnewlay);
		break;
	}
}

void modify_layer(void)
{
	int	o_type=mod_lay->type;
	
	strcpy(mod_lay->name, onewlay[NLNAME].ob_spec.tedinfo->te_ptext);
	if(onewlay[NLTYP1].ob_state & SELECTED)
		mod_lay->type=0;
	else if(onewlay[NLTYP2].ob_state & SELECTED)
		mod_lay->type=1;
	else
		mod_lay->type=2;
	init_layob();
	draw_layob();
	if((o_type != mod_lay->type) && (mod_lay->visible))
		redraw_pic();
		
	if(wcopylay.open)
	{/* GGf. Name im Copy-Fenster anpassen */
		if(mod_lay->id == (ocopylay[CLSNAM].ob_type >> 8))
		{
			strcpy(ocopylay[CLSNAM].ob_spec.free_string, mod_lay->name);
			s_redraw(&wcopylay);
		}
		if(mod_lay->id == (ocopylay[CLDNAM].ob_type >> 8))
		{
			strcpy(ocopylay[CLDNAM].ob_spec.free_string, mod_lay->name);
			s_redraw(&wcopylay);
		}
	}
	
	actize_win_name();
	mod_lay->changes=1;
}

void insert_layer(void)
{
	LAY_LIST	*l, *ol=first_lay;
	long			siz;
	
	l=(LAY_LIST*)malloc(sizeof(LAY_LIST));
	if(!l)
	{
		form_alert(1,"[3][Nicht genug Speicher!][Abbruch]");
		return;
	}

	siz=(long)((long)first_lay->this.word_width*(long)first_lay->this.height);
	
	l->this.red=(void*)calloc(siz,1);
	l->this.yellow=(void*)calloc(siz,1);
	l->this.blue=(void*)calloc(siz,1);

	if((!l->this.red) || (!l->this.yellow) || (!l->this.blue))
	{
		form_alert(1,"[3][Nicht genug Speicher!][Abbruch]");
		free(l);
		if(l->this.red) free(l->this.red);
		if(l->this.yellow) free(l->this.yellow);
		if(l->this.blue) free(l->this.blue);
		return;
	}
	

	/* Andere Draw & Solo deaktivieren */
	while(ol)
	{
		ol->this.draw=ol->this.solo=ol->this.selected=0;
		ol=ol->next;
	}
	otoolbar[MASK_ED-1].ob_state &= (~SELECTED);
	otoolbar[MASK_ED].ob_x=TB_IMG_X;
	otoolbar[MASK_ED].ob_y=0;
	

	first_lay->prev=l;
	l->next=first_lay;
	l->prev=NULL;

	l->this.id=++layer_id;
		
	strcpy(l->this.name, onewlay[NLNAME].ob_spec.tedinfo->te_ptext);
	if(onewlay[NLTYP1].ob_state & SELECTED)
		l->this.type=0;
	else if(onewlay[NLTYP2].ob_state & SELECTED)
		l->this.type=1;
	else
		l->this.type=2;
	l->this.changes=0;
	l->this.selected=1;
	l->this.visible=1;
	l->this.draw=1;
	l->this.solo=0;

	l->this.width=first_lay->this.width;
	l->this.height=first_lay->this.height;
	l->this.word_width=first_lay->this.word_width;
	
	layers_off=0;
	act_lay=first_lay=l;
	init_layob();
	draw_layob();
	
	if(l->this.type == 2)
		redraw_pic();

	actize_win_name();
	layer_changed(act_lay);
}

int	count_sel_layers(void)
{/* ZÑhlt die selektierten Ebenen */
	LAY_LIST	*l=first_lay;
	int					a=0;
	
	do
	{
		if(l->this.selected) ++a;
		l=l->next;
	}while(l);

	return(a);
}

int	count_vis_layers(void)
{/* ZÑhlt die sichtbaren Ebenen */
	LAY_LIST	*l=first_lay;
	int					a=0;
	
	do
	{
		if(l->this.visible) ++a;
		l=l->next;
	}while(l);

	return(a);
}

void delete_layer(void)
{	/* Sucht die selektierten raus und entfernt sie vollstÑndig */
	int nr, redraw=0;
	char	alrt[255], num[10];
	LAYER			*l;
	LAY_LIST	*ll, *ln;
	
	nr=count_sel_layers();

	if(count_layers()-nr < 1)
	{
		form_alert(1,"[3][Grape:|Es muû mindestens eine Ebene|erhalten bleiben. Um die gesamte|Datei zu entfernen, wÑhlen Sie|\'Schlieûen\' aus dem Datei-MenÅ.][Abbruch]");
		return;
	}
	
	if(!nr)
	{
		form_alert(1,"[3][Grape:|Es sind keine Ebenen zum|Entfernen angewÑhlt!][Abbruch]");
		return;
	}
	
	strcpy(alrt, "[2][Grape:|Soll");
	if(nr == 1)
	{
		ll=first_lay;
		do
		{
			if(ll->this.selected)
				l=&ll->this;
			ll=ll->next;
		}while(ll);
		strcat(alrt, " die Ebene ");
		strcat(alrt, l->name);
	}
	else
	{
		strcat(alrt, "en die ");
		itoa(nr, num, 10);
		strcat(alrt, num);
		strcat(alrt, " gewÑhlten Ebenen");
	}

	strcat(alrt, "|wirklich entfernt werden?|(Diese Aktion kann nicht rÅck-|gÑngig gemacht werden!)][OK|Abbruch]");
	
	if(!(form_alert(1, alrt)-1))
	{/* Ebenen entfernen */
		ll=first_lay;
		do
		{
			ln=ll->next;
			if(ll->this.selected)
			{
				del_undo_entry(ll->this.id, 0);

				if(wcopylay.open)
				{ /* Ist die Ebene gerade im Copy-Dialog? Dann Dial schlieûen */
					if(!(ocopylay[CLSTYP].ob_type >> 8))
						if((ocopylay[CLSNAM].ob_type >> 8) == ll->this.id)
							dial_copylay(CLABBRUCH);
					if(!(ocopylay[CLDTYP].ob_type >> 8))
						if((ocopylay[CLDNAM].ob_type >> 8) == ll->this.id)
							dial_copylay(CLABBRUCH);
				}
				
				/* Ist Ebene source fÅr Zeichenfarbe? */
				del_source_lay(ll->this.id);
				
				if(ll->this.visible)
					redraw=1;
				if(ll->next)
					ll->next->prev=ll->prev;
				if(ll->prev)
					ll->prev->next=ll->next;
				if(ll == first_lay)
					first_lay=ln;
				free(ll->this.red);
				free(ll->this.yellow);
				free(ll->this.blue);
				free(&ll->this);
				free(ll);
			}
			ll=ln;
		}while(ll);

		init_layob();
		draw_layob();
		if(redraw)
			redraw_pic();

		actize_win_name();
		first_lay->this.changes=1;
		layer_changed(act_lay);
	}
}

int sel_is_edit(void)
{/* Wenn eine Edit-Ebene aktiv ist und nur diese oder keine
		selektiert ist, oder wenn nur eine Ebene existiert
		wird 1, sonst 0 zurÅckgegeben */
		
	LAY_LIST	*ll=first_lay;
	int				ok=0;
	
	if(count_layers()==1) return(1);
	if(otoolbar[MASK_ED-1].ob_state & SELECTED) return(0);
	if(act_lay==NULL) return(0);
	ok=1;
	while(ll)
	{
		if((ll->this.selected) && (ll != act_lay))
			ok=0;
		ll=ll->next;
	}
	return(ok);
}

void import_layer(void)
{
	if(sel_is_edit())
	{/* Edit=Selektierte (oder keine selektierte) Ebene */
		import_edit();
		return;
	}

	/* Titel und Pre-Selection eintragen */
	strcpy(oclear[LCTITEL].ob_spec.tedinfo->te_ptext, "Ebene importieren");
	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{/* Keine Edit-Ebene */
		oclear[LC1].ob_state &= (~SELECTED);
		oclear[LC2].ob_state |= SELECTED;
	}
	else
	{
		oclear[LC1].ob_state |= SELECTED;
		oclear[LC2].ob_state &= (~SELECTED);
	}

	if(!wclear.open)
	{
		/* Fenster initialisieren */
		wclear.dinfo=&dclear;
		w_dial(&wclear, D_CENTER);
		wclear.name="[Grape]";
		w_set(&wclear, NAME);
		w_open(&wclear);
	}
	else
	{
		w_top(&wclear);
		s_redraw(&wclear);
	}
}

void clear_layer(void)
{
	char	alrt[255];
	
	if(sel_is_edit())
	{/* Edit=Selektierte (oder keine selektierte) Ebene */
		strcpy(alrt, "[2][Grape:|Soll der Inhalt der Ebene|");
		strcat(alrt, act_lay->this.name);
		strcat(alrt, " wirklich gelîscht werden?][OK|Abbruch]");
		if(form_alert(1,alrt)==1)
			clear_edit();
		return;
	}

	/* Titel und Pre-Selection eintragen */
	strcpy(oclear[LCTITEL].ob_spec.tedinfo->te_ptext, "Inhalt lîschen");
	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{/* Keine Edit-Ebene */
		oclear[LC1].ob_state &= (~SELECTED);
		oclear[LC2].ob_state |= SELECTED;
	}
	else
	{
		oclear[LC1].ob_state |= SELECTED;
		oclear[LC2].ob_state &= (~SELECTED);
	}

	if(!wclear.open)
	{
		/* Fenster initialisieren */
		wclear.dinfo=&dclear;
		w_dial(&wclear, D_CENTER);
		wclear.name="[Grape]";
		w_set(&wclear, NAME);
		w_open(&wclear);
	}
	else
	{
		w_top(&wclear);
		s_redraw(&wclear);
	}
}

void dial_clear(int ob)
{
	switch(ob)
	{
		case LCOK:
		/* Modus ? */
			if((oclear[LCTITEL].ob_spec.tedinfo->te_ptext)[0] == 'E')
			{/* Ebene importieren */
				if(oclear[LC1].ob_state & SELECTED)
					import_edit();
				else
					import_selected();
			}
			else
			{/* Inhalt lîschen */
				if(oclear[LC1].ob_state & SELECTED)
					clear_edit();
				else
					clear_selected();
			}
		case LCABBRUCH:
			w_unsel(&wclear, ob);
			w_close(&wclear);
			w_kill(&wclear);
		break;
	}
}

void clear_edit(void)
{/* Lîscht den Inhalt der Edit-Ebene oder falls nur eine existiert, diese*/
	LAYER			*l;
	LAY_LIST	*ll;
	
	if(count_layers() > 1)
	{
		if(otoolbar[MASK_ED-1].ob_state & SELECTED)
		{
			form_alert(1,"[3][Grape:|Es ist keine Edit-Ebene|aktiv!][Abbruch]");
			return;
		}
	
		l=&(act_lay->this);
		ll=act_lay;
	}
	else
	{
		l=&(first_lay->this);
		ll=first_lay;
	}
		
	if(!auto_reset(5))
		return;
	if(!all_to_undo(l, NULL))
		return;
	cls(l);
	l->changes=0;

	init_layob();
	draw_layob();

	if(l->visible)
		redraw_pic();

	layer_changed(ll);

	actize_win_name();
}

void clear_selected(void)
{/* Lîscht den Inhalt der angewÑhlten Ebenen */
	int				redraw=0;
	LAY_LIST	*ll;
	
	
	if(!count_sel_layers())
	{
		form_alert(1,"[3][Grape:|Es sind keine Ebenen zum|Lîschen angewÑhlt!][Abbruch]");
		return;
	}
	
	if(!auto_reset(5))
		return;
		
	ll=first_lay;
	do
	{
		if(ll->this.visible)
			redraw=1;
		layer_changed(ll);
		if(ll->this.selected)
		{
			if(!all_to_undo(&(ll->this), NULL))
				return;
			cls(&ll->this);
			ll->this.changes=0;
		}
		ll=ll->next;
	}while(ll);

	init_layob();
	draw_layob();
	if(redraw)
		redraw_pic();

	actize_win_name();
	first_lay->this.changes=1;
}

void cls(LAYER *lay)
{
	long					siz;

	siz=(long)((long)first_lay->this.word_width*(long)first_lay->this.height);

	memset(lay->red, 0, siz);
	memset(lay->yellow, 0, siz);
	memset(lay->blue, 0, siz); 
}

void	draw_layob(void)
{
	int wx, wy, ww, wh;

	wind_get(main_win.id, WF_WORKXYWH, &wx, &wy, &ww, &wh);
	wh=otoolbar[0].ob_height+OTBB;
	pic_redraw(main_win.id, wx, wy, ww, wh);	
}

int count_layers(void)
{
	LAY_LIST	*l=first_lay;
	int a=1;
	
	while(l->next)
	{
		l=l->next;
		++a;
	}
	
	return(a);
}

int move_layer(int src, int dst)
{ /* HÑngt Layerliste um
		 Eingang nach Muster:
		 
		Layer      0   1   2   3   4...
		Position 0   1   2   3   4   5...  
		
	*/

  LAY_LIST *s, *d;
  
  /* Umrechnen in 
  
		Layer       0   1   2   3   4...
		Position -1   0   1   2   3   4...  
  
   */
	--dst;  

  /* Zeiger Quell/Zielebene holen */
  
  s=find_lay_list(src);	
  if(dst > -1)
	  d=find_lay_list(dst);
	else 
		d=first_lay;

  /* AushÑngen */
  if(s->next)
  	s->next->prev=s->prev;
  if(s->prev)
  	s->prev->next=s->next;
  else
  	first_lay=s->next;
 
 	/* EinhÑngen */
	if(dst > -1)
	{
	  s->next=d->next;
	  d->next=s;
	  if(s->next)
	  	s->next->prev=s;
	  s->prev=d;
	}
	else
	{
		s->next=d;
		d->prev=s;
		s->prev=NULL;
		first_lay=s;
	}

	/* Sichtbar? */
	return(s->this.visible);
}

void copy_layer(int src, int dst, int how)
{
 /* Kopiert Ebene src in Ebene dst */
 /* scr und dst sind ID und nicht Nummer in der Liste !! */
 /* how gibt Kopierart an: 0=transparent, 1=deckend, 2=deck. incl weiû */
	LAYER	*s, *d;
	long		x, y;
 	unsigned char	*sc, *dc, *sr, *dr, *sy, *dy, *sb, *db;
 	
	s=find_layer_id(src);
	d=find_layer_id(dst);

	d->changes=1;
	actize_win_name(); 
	switch(how)
	{
		case 0:
		/* Transparent kopieren */
			sc=s->red;
			dc=d->red;
			for(y=0; y < s->height; ++y)
			{
				for(x=0; x < s->word_width; ++x)
				{
					if(*dc++ < *sc++)
						*(dc-1)=*(sc-1);
				}
			}
			sc=s->yellow;
			dc=d->yellow;
			for(y=0; y < s->height; ++y)
			{
				for(x=0; x < s->word_width; ++x)
				{
					if(*dc++ < *sc++)
						*(dc-1)=*(sc-1);
				}
			}
			sc=s->blue;
			dc=d->blue;
			for(y=0; y < s->height; ++y)
			{
				for(x=0; x < s->word_width; ++x)
				{
					if(*dc++ < *sc++)
						*(dc-1)=*(sc-1);
				}
			}
		break;
		case 1:
		/* Deckend kopieren */
			sr=s->red;
			dr=d->red;
			sy=s->yellow;
			dy=d->yellow;
			sb=s->blue;
			db=d->blue;
			
			for(y=0; y < s->height; ++y)
			{
				for(x=0; x < s->word_width; ++x)
				{
					if(*sr || *sy || *sb)
					{
						*dr=*sr;
						*dy=*sy;
						*db=*sb;
					}
					++sr; ++sy; ++sb;
					++dr; ++dy; ++db;
				}
			}
		break;
		case 2:
		/* Deckend incl. weiû */
			sc=s->red;
			dc=d->red;
			for(y=0; y < s->height; ++y)
				for(x=0; x < s->word_width; ++x)
					*dc++=*sc++;
			sc=s->yellow;
			dc=d->yellow;
			for(y=0; y < s->height; ++y)
				for(x=0; x < s->word_width; ++x)
					*dc++=*sc++;
			sc=s->blue;
			dc=d->blue;
			for(y=0; y < s->height; ++y)
				for(x=0; x < s->word_width; ++x)
					*dc++=*sc++;
		break;
	}
	
	if(d->visible)
		redraw_pic();
}

void copy_layer_init(void)
{
	/* Ebene kopieren ohne Vorgabe */
	
	LAYER	*l;
	MASK	*m;
	
	l=find_layer(0);
	set_ext_type(ocopylay, CLSNAM, l->id);
	set_ext_type(ocopylay, CLSTYP, 0);

	if(count_layers() > 1)
	{
		l=find_layer(1);
		set_ext_type(ocopylay, CLDNAM, l->id);
		set_ext_type(ocopylay, CLDTYP, 0);
	}
	else
	{/* Es gibt nur eine Ebene, Maske als Ziel */
		m=find_mask(0);
		set_ext_type(ocopylay, CLDNAM, m->id);
		set_ext_type(ocopylay, CLDTYP, 1);
	}
	
	copy_layer_win();
}

void copy_layer_win(void)
{
	LAYER	*sl, *dl;
	MASK	*sm, *dm;
	
	if(ocopylay[CLSTYP].ob_type >> 8)
	{ /* Source ist Maske */
		sm=find_mask_id(ocopylay[CLSNAM].ob_type>>8);
		strcpy(ocopylay[CLSNAM].ob_spec.free_string, sm->name);
		strcpy(ocopylay[CLSTYP].ob_spec.free_string, "Maske");
	}
	else
	{ /* Source ist Ebene */
		sl=find_layer_id(ocopylay[CLSNAM].ob_type>>8);
		strcpy(ocopylay[CLSNAM].ob_spec.free_string, sl->name);
		strcpy(ocopylay[CLSTYP].ob_spec.free_string, "Ebene");
	}
	
	if(ocopylay[CLDTYP].ob_type >> 8)
	{ /* Dest ist Maske */
		dm=find_mask_id(ocopylay[CLDNAM].ob_type>>8);
		strcpy(ocopylay[CLDNAM].ob_spec.free_string, dm->name);
		strcpy(ocopylay[CLDTYP].ob_spec.free_string, "Maske");
	}
	else
	{ /* Dest ist Ebene */
		dl=find_layer_id(ocopylay[CLDNAM].ob_type>>8);
		strcpy(ocopylay[CLDNAM].ob_spec.free_string, dl->name);
		strcpy(ocopylay[CLDTYP].ob_spec.free_string, "Ebene");
	}

	ocopylay[CLTYP1].ob_state&=(~SELECTED);
	ocopylay[CLTYP2].ob_state&=(~SELECTED);
	ocopylay[CLTYP3].ob_state&=(~SELECTED);
	

	if(!(ocopylay[CLSTYP].ob_type >> 8)) /* Wenn Source Ebene ist, transparent/deckend Button setzen */
		ocopylay[CLTYP1+sl->type].ob_state |= SELECTED;
	else /* Sonst auf deckend incl. weiû setzen */
		ocopylay[CLTYP3].ob_state |= SELECTED;

	/* Name der zu beachtenden Maske */
	set_ext_type(ocopylay,CLMNAM, act_mask->this.id);
	strcpy(ocopylay[CLMNAM].ob_spec.free_string, act_mask->this.name);
	
	/* Wenn Source Ebene ist und Maske im Hauptfenster aktiv,
		 dann Maske auf beachten setzen  */
	if((!(ocopylay[CLSTYP].ob_type >> 8)) && (otoolbar[MASK_ON-1].ob_state & SELECTED))
	{
		ocopylay[CLMASK].ob_state |= SELECTED;
		ocopylay[CLMNAM].ob_state &= (~DISABLED);
	}
	else /* Sonst Popup disablen */
	{
		ocopylay[CLMASK].ob_state &= (~SELECTED);
		ocopylay[CLMNAM].ob_state |= DISABLED;
	}
	
	if(!wcopylay.open)
	{
		wcopylay.dinfo=&dcopylay;
		w_dial(&wcopylay, D_CENTER);
		wcopylay.name="[Grape]";
		w_set(&wcopylay, NAME);
		w_open(&wcopylay);
	}
	else
	{
		w_top(&wcopylay);
		s_redraw(&wcopylay);
	}
}

void dial_copylay(int ob)
{
	int how, pop;
	MASK_LIST	*m;
	
	if(ocopylay[CLTYP1].ob_state & SELECTED)
		how=0;
	else if(ocopylay[CLTYP2].ob_state & SELECTED)
		how=1;
	else if(ocopylay[CLTYP3].ob_state & SELECTED)
		how=2;
	else
		how=-1;
		
	switch(ob)
	{
		case CLSTYP:
			cop_typ(CLSNAM, CLSTYP, CLDNAM, CLDTYP, CLSOLD);
		break;
		case CLDTYP:
			cop_typ(CLDNAM, CLDTYP, CLSNAM, CLSTYP, CLDOLD);
		break;
		
		case CLSNAM:
			cop_pop(CLSNAM, CLSTYP, CLDNAM, CLDTYP);
			if(!(ocopylay[CLSTYP].ob_type >> 8))
				set_cop_how();
		break;
		case CLDNAM:
			cop_pop(CLDNAM, CLDTYP, CLSNAM, CLSTYP);
		break;

		case CLMASK:
			if(ocopylay[CLMASK].ob_state & SELECTED)
				ocopylay[CLMNAM].ob_state &= (~DISABLED);
			else /* Sonst Popup disablen */
				ocopylay[CLMNAM].ob_state |= DISABLED;
			w_objc_draw(&wcopylay, CLMNAM, 8, sx ,sy, sw, sh);
		break;

		case CLMNAM:
			pop=mask_popup(ocopylay, ob, -1);
			if(pop > -1)
			{ /* Auswahl getroffen */
				m=find_mask_list(pop-1);
				if(m)
				{
					set_ext_type(ocopylay, ob, m->this.id);
					strcpy(ocopylay[ob].ob_spec.free_string, m->this.name);
					w_objc_draw(&wcopylay, ob, 8, sx, sy, sw, sh);
				}
			}
		break;
						
		case CLOK:
			copy_distribute(how);
		case CLABBRUCH:
			w_unsel(&wcopylay, ob);
			w_close(&wcopylay);
			w_kill(&wcopylay);
		break;
	}
}

void copy_distribute(int how)
{
	int typ1=ocopylay[CLSTYP].ob_type >> 8;
	int typ2=ocopylay[CLDTYP].ob_type >> 8;
	int id1=ocopylay[CLSNAM].ob_type >> 8;
	int id2=ocopylay[CLDNAM].ob_type >> 8;
	int	idm=ocopylay[CLMNAM].ob_type >> 8;
	
	/* Undo */
	if(!auto_reset(5))
		return;
	if(typ2)
	{/* Ziel ist Maske */
		if(!all_to_undo(NULL, find_mask_id(id2)))
			return;
	}
	else
	{/* Ziel ist Ebene */
		if(!all_to_undo(find_layer_id(id2), NULL))
			return;
	}
	
	busy(ON);
	graf_mouse(BUSYBEE, NULL);
	
	if(ocopylay[CLMASK].ob_state & SELECTED)
	{/* Mit Maske kopieren */
		if((typ1==typ2) && (typ2==0))
			copy_layer_mm(id1, id2, how, idm);
		else if((typ1==typ2) && (typ2==1))
			copy_mask_mm(id1, id2, how, idm);
		else if((typ1==0) && (typ2==1))
			copy_lay_mask_mm(id1, id2, how, idm);
		else if((typ1==1) && (typ2==0))
			copy_mask_lay_mm(id1, id2, how, idm);
	}
	else
	{/* Ohne Maske kopieren */
		if((typ1==typ2) && (typ2==0))
			copy_layer(id1, id2, how);
		else if((typ1==typ2) && (typ2==1))
			copy_mask(id1, id2, how);
		else if((typ1==0) && (typ2==1))
			copy_lay_mask(id1, id2, how);
		else if((typ1==1) && (typ2==0))
			copy_mask_lay(id1, id2, how);
	}	

	/* Preview aktualisieren? */
	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{/* Maske im Preview */
		if(typ2) /* Ziel ist Maske */
			mask_changed(find_mask_list_id(id2));
	}
	else
	{/* Ebene im Preview */
		if(typ2==0)
			layer_changed(find_lay_list_id(id2));
	}
	
	graf_mouse(ARROW, NULL);
	busy(OFF);

	actize_win_name();
}

void cop_typ(int ob_nam, int ob, int a_ob, int a_typ, int old_ob)
{
	/*
		ob_nam=Popuproot
		ob=angeklicktes Typ-Objekt
		a_ob=Popuproot des anderen Objekts
		a_typ=Typobjekt des anderen Objekts
		old_ob=Objekt, das die Old-Nummer des Popuproot speichert
	*/
	int old;
	
	if(ocopylay[ob].ob_type >> 8)
	{ /* Maske */
		if((count_layers() < 2) && (!(ocopylay[a_typ].ob_type >> 8)))
		{/* Ziel ist auch Maske, es gibt aber nur eine */
			form_alert(1,"[3][Grape:|Es gibt nur eine Ebene. Diese|kann nicht in sich selbst|kopiert werden.][Abbruch]");
			return;
		}
		strcpy(ocopylay[ob].ob_spec.free_string, "Ebene");
		set_ext_type(ocopylay, ob, 0);
		old=ocopylay[old_ob].ob_type >> 8;
		set_ext_type(ocopylay, old_ob, ocopylay[ob_nam].ob_type >> 8);
		if(!find_lay_list_id(old))
			old=first_lay->this.id;
		if(!(ocopylay[a_typ].ob_type >> 8))
		{ /* Quelle ist auch Ebene */
			if(old == (ocopylay[a_ob].ob_type >> 8))
			{/* Ziel ist identisch mit Quelle -> Ñndern */
				old=-1;
				while(1)
				{
					++old;
					if(find_lay_list_id(old))
						if(old != (ocopylay[a_ob].ob_type >> 8))
							break;
				}
			}
		}
		strcpy(ocopylay[ob_nam].ob_spec.free_string, find_lay_list_id(old)->this.name);
		set_ext_type(ocopylay, ob_nam, old);
	}
	else
	{ /* Ebene */
		if((count_masks() < 2) && (ocopylay[a_typ].ob_type >> 8))
		{/* Ziel ist auch Maske, es gibt aber nur eine */
			form_alert(1,"[3][Grape:|Es gibt nur eine Maske. Diese|kann nicht in sich selbst|kopiert werden.][Abbruch]");
			return;
		}
		strcpy(ocopylay[ob].ob_spec.free_string, "Maske");
		set_ext_type(ocopylay, ob, 1);
		old=ocopylay[old_ob].ob_type >> 8;
		set_ext_type(ocopylay, old_ob, ocopylay[ob_nam].ob_type >> 8);
		if(!find_mask_list_id(old))
			old=first_mask->this.id;
		if(ocopylay[a_typ].ob_type >> 8)
		{ /* Quelle ist auch Maske */
			if(old == (ocopylay[a_ob].ob_type >> 8))
			{/* Ziel ist identisch mit Quelle -> Ñndern */
				old=-1;
				while(1)
				{
					++old;
					if(find_mask_list_id(old))
						if(old != (ocopylay[a_ob].ob_type >> 8))
							break;
				}
			}
		}
		strcpy(ocopylay[ob_nam].ob_spec.free_string, find_mask_list_id(old)->this.name);
		set_ext_type(ocopylay, ob_nam, old);
	}
	w_objc_draw(&wcopylay, ob, 8, sx, sy, sw, sh);
	w_objc_draw(&wcopylay, ob_nam, 8, sx, sy, sw, sh);
	
	/* Falls Source umgeschaltet wurde, Flags anpassen */
	
	if(ob == CLSTYP)
		set_cop_how();
}

void set_cop_how(void)
{
	/* Paût die Transparent/Deckend..-Option an die gewÑhlte Source
	   an */
	  
	ocopylay[CLTYP1].ob_state&=(~SELECTED);
	ocopylay[CLTYP2].ob_state&=(~SELECTED);
	ocopylay[CLTYP3].ob_state&=(~SELECTED);

	if(!(ocopylay[CLSTYP].ob_type >> 8)) /* Wenn Source Ebene ist, transparent/deckend Button setzen */
		ocopylay[CLTYP1+find_layer_id(ocopylay[CLSNAM].ob_type>>8)->type].ob_state |= SELECTED;
	else /* Sonst auf deckend incl. weiû setzen */
		ocopylay[CLTYP3].ob_state |= SELECTED;

	w_objc_draw(&wcopylay, CLHOW, 8, sx, sy, sw, sh);
}

void cop_pop(int ob, int ob_typ, int a_ob, int a_typ)
{
	/* ob=angeklicktes Popuproot
	   ob_typ=Typenobjekt
	   a_ob=Anderes Popuproot
	   a_typ=Typenobjekt des anderen Popuproot */

	int				pop;
	LAY_LIST	*l;
	MASK_LIST	*m;
	   
	if(ocopylay[ob_typ].ob_type >> 8)
	{ /* Ziel = Maske */
		if(ocopylay[a_typ].ob_type >> 8) /* Quelle = Maske */
			pop=mask_popup(ocopylay, ob, ocopylay[a_ob].ob_type >> 8);
		else /* Quelle = Ebene */
			pop=mask_popup(ocopylay, ob, -1);
	}
	else
	{ /* Ziel = Ebene */
		if(ocopylay[a_typ].ob_type >> 8) /* Quelle = Maske */
			pop=layer_popup(ocopylay, ob, -1);
		else
			pop=layer_popup(ocopylay, ob, ocopylay[a_ob].ob_type >> 8);
	}
	if(pop > -1)
	{ /* Auswahl getroffen */
		if(ocopylay[ob_typ].ob_type >> 8) /* Maske */
		{
			m=find_mask_list(pop-1);
			if(m)
			{
				set_ext_type(ocopylay, ob, m->this.id);
				strcpy(ocopylay[ob].ob_spec.free_string, m->this.name);
			}
		}
		else
		{
			l=find_lay_list(pop-1);
			if(l)
			{
				set_ext_type(ocopylay, ob, l->this.id);
				strcpy(ocopylay[ob].ob_spec.free_string, l->this.name);
			}
		}
		w_objc_draw(&wcopylay, ob, 8, sx, sy, sw, sh);
	}
}

int layer_popup(OBJECT *tree, int ob, int disable_id)
{
	/* ôffnet Åber dem Object ob aus tree ein Popup mit allen Layern */
	/* Die aktuelle Auswahl (fÅr die v-Ausrichtung des Popups) wird */
	/* aus dem erweiterten Typ von ob bestimmt, d.h. hier muû die */
	/* ID der aktuell gewÑhlten Ebene eingetragen werden! */
	/* Die Ebene mit der ID disable_id erscheint im Popup disabled */
	/* (falls unerwÅnscht, disable_id < 0 Åbergeben */
	
	LAY_LIST	*l=first_lay;
	int	c=0, d, mnum, x, y;
	OBJECT	*omaskpop;

	xrsrc_gaddr(0, MASKPOP, &omaskpop, xrsrc);
	
	/* Popup initialisieren */
	while(l)
	{
		if(l->this.id == tree[ob].ob_type/256)
		{
			mnum=c;
			omaskpop[c+1].ob_state |= CHECKED;
		}
		else
			omaskpop[c+1].ob_state &= (~CHECKED);

		strcpy(omaskpop[++c].ob_spec.free_string, "  ");
		strcat(omaskpop[c].ob_spec.free_string, l->this.name);
		omaskpop[c].ob_flags &= (~HIDETREE);
		if(l->this.id != disable_id)
		{
			omaskpop[c].ob_state &= (~DISABLED);
			omaskpop[c].ob_flags |= SELECTABLE;
		}
		else
		{
			omaskpop[c].ob_state |= DISABLED;
			omaskpop[c].ob_flags &= (~SELECTABLE);
		}

		l=l->next;
	}
	d=c;
	while(d < 16)
		omaskpop[++d].ob_flags |= HIDETREE;
	
	omaskpop[0].ob_height=c*omaskpop[1].ob_height;
	
	objc_offset(tree, ob, &x, &y);
	y-=mnum*omaskpop[1].ob_height;
	return(form_popup(omaskpop, x, y));
}

int dial_store(void)
{
	int a, x, y, k, dum, ob, ret=0;
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	
	otoolbar[TBSTORE-1].ob_state |= SELECTED;
	++otoolbar[TBSTORE].ob_x; ++otoolbar[TBSTORE].ob_y;
	
	for(a=TBS1; a<=TBS10; ++a)
	{
		otoolbar[a].ob_state &= (~SELECTED);
	 /* Hellrot */
		((TEDINFO_COL*)(&otoolbar[a].ob_spec.tedinfo->te_color))->text_col=2;
	}
	
	do {graf_mkstate(&dum, &dum, &k, &dum);} while(k&3);
	draw_layob();	
	
	do {graf_mkstate(&x, &y, &k, &dum);} while(!(k&3));
	
	ob=objc_find(otoolbar, 0, 8, x, y);

	if((ob >=TBS1) && (ob <= TBS10))
	{
		ret=1;
		put_lay_store(ob-TBS1+1);
		otoolbar[ob].ob_state |= SELECTED;
	}
	
	otoolbar[TBSTORE-1].ob_state &= (~SELECTED);
	--otoolbar[TBSTORE].ob_x; --otoolbar[TBSTORE].ob_y;
	
	for(a=TBS1; a<=TBS10; ++a)
	{
		/* Schwarz */
		((TEDINFO_COL*)(&otoolbar[a].ob_spec.tedinfo->te_color))->text_col=1;
	}
	
	do {graf_mkstate(&dum, &dum, &k, &dum);} while(k&3);
	draw_layob();	

	wind_update(END_MCTRL);
	wind_update(END_UPDATE);	
	
	return(ret);
}

int get_lay_store(int num)
{/* Stellt die Layersettings aus Speicherplatz num her */
 /* (Platz 0 wird fÅr Solo-Puffer benutzt) */
 /* Falls sich was an visible der Layers geÑndert hat, */
 /* kommt 1 zurÅck, sonst 0 */
	
	int 	a, ret=0, o_mv, o_mid;
	LAYER			*l;
	MASK			*m;
	LAY_LIST	*ll=first_lay;
	
	/* Alle Radioflags lîschen */
		
	while(ll)
	{
		ll->this.draw=ll->this.solo=0;
		ll=ll->next;
	}
	
	/* Falls irgendwo Solo gespeichert wurde, alle Visibles lîschen */
	for(a=0; a < 254; ++a)
	{
		if(lay_store[num].lm[a].id > -1)
		{
			l=find_layer_id(lay_store[num].lm[a].id);
			if(l && lay_store[num].lm[a].solo)
			{
				ll=first_lay;
				while(ll)
				{
					ll->this.visible=0;
					ll=ll->next;
				}
			}
		}
	}
	

	for(a=0; a < 254; ++a)
	{
		if(lay_store[num].lm[a].id > -1)
		{
			l=find_layer_id(lay_store[num].lm[a].id);
			if(l)
			{
				if(l->visible != lay_store[num].lm[a].visible)
					ret=1;
				l->selected=lay_store[num].lm[a].selected;
				l->visible=lay_store[num].lm[a].visible;
				l->draw=lay_store[num].lm[a].draw;
				l->solo=lay_store[num].lm[a].solo;
			}
		}
	}

	m=find_mask_id(mask_store[num].mask_id);
	if(m)
	{
		o_mid=act_mask->this.id;
		o_mv=otoolbar[MASK_VIS-1].ob_state & SELECTED;

		act_mask=find_mask_list_id(mask_store[num].mask_id);
		otoolbar[MASK_ON-1].ob_state &= (~SELECTED);
		otoolbar[MASK_ON-1].ob_state |= mask_store[num].mask_on;
		otoolbar[MASK_ED-1].ob_state &= (~SELECTED);
		otoolbar[MASK_ED-1].ob_state |= mask_store[num].mask_ed;
		otoolbar[MASK_VIS-1].ob_state &= (~SELECTED);
		otoolbar[MASK_VIS-1].ob_state |= mask_store[num].mask_vis;

		otoolbar[MASK_ON].ob_x=TB_M_IMG_X;
		otoolbar[MASK_ON].ob_y=0;
		otoolbar[MASK_ED].ob_x=TB_IMG_X;
		otoolbar[MASK_ED].ob_y=0;
		otoolbar[MASK_VIS].ob_x=TB_IMG_X;
		otoolbar[MASK_VIS].ob_y=0;

		if(otoolbar[MASK_ON-1].ob_state & SELECTED)
		{
			otoolbar[MASK_ON].ob_x=TB_M_IMG_X+1;
			otoolbar[MASK_ON].ob_y=1;
		}
		if(otoolbar[MASK_ED-1].ob_state & SELECTED)
		{
			otoolbar[MASK_ED].ob_x=TB_IMG_X+1;
			otoolbar[MASK_ED].ob_y=1;
		}
		if(otoolbar[MASK_VIS-1].ob_state & SELECTED)
		{
			otoolbar[MASK_VIS].ob_x=TB_IMG_X+1;
			otoolbar[MASK_VIS].ob_y=1;
		}
		
		if(o_mv && (! mask_store[num].mask_vis))
		/* Maske nicht mehr sichtbar */
			ret=1;
		if((!o_mv) && mask_store[num].mask_vis)
		/* Maske jetzt sichtbar */
			ret=1;
		if(mask_store[num].mask_vis && (mask_store[num].mask_id != o_mid))
		/* Maske sichtbar und ungleich alter Maske */
			ret=1;
	}

	return(ret);
}

void put_lay_store(int num)
{/* Speichert die Layersettings in Platz num */
	
	int 	a;
	LAYER	*l;

	for(a=0; a < 254; ++a)
	{
			l=find_layer(a);
			if(l)
			{
				lay_store[num].lm[a].id=l->id;;
				lay_store[num].lm[a].selected=l->selected;
				lay_store[num].lm[a].visible=l->visible;
				lay_store[num].lm[a].draw=l->draw;
				lay_store[num].lm[a].solo=l->solo;
			}
			else
				lay_store[num].lm[a].id=-1;
	}
	mask_store[num].mask_id=act_mask->this.id;
	mask_store[num].mask_on=otoolbar[MASK_ON-1].ob_state & SELECTED;
	mask_store[num].mask_ed=otoolbar[MASK_ED-1].ob_state & SELECTED;
	mask_store[num].mask_vis=otoolbar[MASK_VIS-1].ob_state & SELECTED;
}

void dial_layer(int ob, int klicks)
{
	int a, rob, dif, x, y, src, dst, action, redraw, ovis, oon;
	LAYER	*l;
	LAY_LIST	*ll;
	
	if((ob >= LAY1) && (ob <= LAYLAST))
	{
		dif=LAY2-LAY1;
		a=(ob-LAY1)/dif;
		l=find_layer(a+layers_off);
		rob=ob-a*dif;
		switch(rob)
		{
			case LAYNAM:
				switch(klicks)
				{
					case 1:
						evnt_timer(150,0);
						graf_mkstate(&x, &x, &y, &x);
						if(y)
						{/* DRAG */
							src=a+layers_off;
							objc_offset(otoolbar, ob, &x, &y);
							action=mgraf_dragbox(src, otoolbar[LAY1].ob_width, otoolbar[LAY1].ob_height,
														x, y, &dst);
							switch(action)
							{
								case 1:
								/* Ebene verschieben */
									x=move_layer(src, dst);
									init_layob();
									draw_layob();
									if(x)
										redraw_pic();
								break;
								case 2:
								/* Ebene einkopieren */
									if(src != dst)
									{
										l=find_layer(src);
										set_ext_type(ocopylay, CLSNAM, l->id);
										set_ext_type(ocopylay, CLSTYP, 0);
										l=find_layer(dst);
										set_ext_type(ocopylay, CLDNAM, l->id);
										set_ext_type(ocopylay, CLDTYP, 0);
										copy_layer_win();
									}
								break;
								case 3:
								/* Ebene in Maske kopieren */
										l=find_layer(src);
										set_ext_type(ocopylay, CLSNAM, l->id);
										set_ext_type(ocopylay, CLSTYP, 0);
										set_ext_type(ocopylay, CLDNAM, act_mask->this.id);
										set_ext_type(ocopylay, CLDTYP, 1);
										copy_layer_win();
								break;
								case 4:
								/* Ebene als Quellfarbe einsetzen */
										l=find_layer(src);
										if(l)
											set_source_lay(l->id);
								break;
							}
						}
						else
						{	/* SELECT */
							if(l->selected) /* Deselektieren */
								l->selected=0;
							else
							{/* Selektieren */
								if(!(Kbshift(-1) & 3))
								{/* Kein Shift->Alle andern Ebenen deselektieren */
									ll=first_lay;
									do
									{
										ll->this.selected=0;
										ll=ll->next;
									}while(ll);
								}
								l->selected=1;
							}
							for(a=TBS1; a<=TBS10; ++a)
								otoolbar[a].ob_state &= (~SELECTED);
							init_layob();
							draw_layob();
						}
					break;
					case 2: /* DOUBLE */
						mod_lay=l;
						modify_layer_win();
					break;
				}
			break;
			case LAYVIS-1:
				ob=LAYVIS;
			case LAYVIS:
				/* Solo an? */
				if(otoolbar[LAYLED].ob_spec.bitblk->bi_color==3)
				{
					Bell();
					break;
				}
				otoolbar[LAYVIS+a*dif].ob_x=TB_IMG_X;
				otoolbar[LAYVIS+a*dif].ob_y=0;
				if(otoolbar[ob-1].ob_state & SELECTED)
				{/* Ist schon selektiert,
						falls CTRL gedrÅckt, Helligkeit toggeln, sonst aus */
					if(Kbshift(-1) & 4)
					{
						if(otoolbar[ob-1].ob_state & DISABLED)
							otoolbar[ob-1].ob_state &= (~DISABLED);
						else
							otoolbar[ob-1].ob_state |= DISABLED;
					}
					else
						otoolbar[ob-1].ob_state &= (~(SELECTED|DISABLED));
				}
				else
				{/* Noch nicht selektiert->anschalten und falls CTRL
						gleich mit halber Helligkeit */
					otoolbar[ob-1].ob_state |= SELECTED;
					if(Kbshift(-1) & 4) otoolbar[ob-1].ob_state |= DISABLED;
					otoolbar[LAYVIS+a*dif].ob_x=TB_IMG_X+1;
					otoolbar[LAYVIS+a*dif].ob_y=1;
				}
				l->visible=otoolbar[ob-1].ob_state & (SELECTED|DISABLED);
				objc_offset(otoolbar, ob-1, &x, &y);
				pic_dith(main_win.id, x, y, otoolbar[ob-1].ob_width, otoolbar[ob-1].ob_height, 0);
				do{graf_mkstate(&y, &y, &x, &y);}while(x & 3);
				for(a=TBS1; a<=TBS10; ++a)
					otoolbar[a].ob_state &= (~SELECTED);
				init_layob();
				draw_layob();
				redraw_pic();
			break;
			case LAYPEN-1:
				ob=LAYPEN;
			case LAYPEN:
				/* Ist schon selektiert ? */
				if(otoolbar[ob-1].ob_state & SELECTED)
					break;
				
				/* Solo an? */
				if(otoolbar[LAYLED].ob_spec.bitblk->bi_color==3)
				{
					/* Nur zulassen, falls von Maske-Edit auf Plane-Edit */
					/* Maske-Edit aktiv? */
					if(!(otoolbar[MASK_ED-1].ob_state & SELECTED))
					{	Bell(); break; }

					/* Aktiven Solo-Layer gleich gewÑhltem Edit-Layer? */
					ll=first_lay; x=0;
					while(ll)
					{
						if((ll->this.solo) && (l != &(ll->this)))
							x=1;
						ll=ll->next;
					}
					if(x)
					{	Bell(); break; }
				}
				otoolbar[LAYPEN+a*dif].ob_x=TB_IMG_X;
				otoolbar[LAYPEN+a*dif].ob_y=0;
				otoolbar[ob-1].ob_state |= SELECTED;
				otoolbar[LAYPEN+a*dif].ob_x=TB_IMG_X+1;
				otoolbar[LAYPEN+a*dif].ob_y=1;
				l->draw=otoolbar[ob-1].ob_state & SELECTED;
				objc_offset(otoolbar, ob-1, &x, &y);
				pic_dith(main_win.id, x, y, otoolbar[ob-1].ob_width, otoolbar[ob-1].ob_height, 0);
				do{graf_mkstate(&y, &y, &x, &y);}while(x & 3);
				if(l->draw)
				{/* Andere Draws deaktivieren */
					ll=first_lay;
					while(ll)
					{
						if(&ll->this == l)
							act_lay=ll;
						ll->this.draw=0;
						ll=ll->next;
					}
					l->draw=1;
					otoolbar[MASK_ED-1].ob_state &= (~SELECTED);
					otoolbar[MASK_ED].ob_x = otoolbar[MASK_ED].ob_x=0;
				}
				init_layob();
				for(a=TBS1; a<=TBS10; ++a)
					otoolbar[a].ob_state &= (~SELECTED);
				draw_layob();
				if(undo_on && (oundo[UALL].ob_state & SELECTED) && (ounopt[UORES4].ob_state & SELECTED))
				{
					free_undo();
					clear_undo();
					init_undo();
				}
				new_edit_select();
			break;
			case LAYSOLO-1:
				ob=LAYSOLO;
			case LAYSOLO:
				if(!(otoolbar[ob-1].ob_state & SELECTED))
				{	/* Solo wurde aktiviert */
					/* Masken Vis & Aktiv merken */
					ovis=otoolbar[MASK_VIS-1].ob_state & SELECTED;
					oon=otoolbar[MASK_ON-1].ob_state & SELECTED;
					/* Wenn woanders schon Solo an war, */
					/* altes Setup holen */
					ll=first_lay;
					while(ll)
					{
						if(ll->this.solo)
							get_lay_store(0);
						ll=ll->next;
					}
					/* Setup sichern */
					put_lay_store(0);
					/* Alle anderen Stati Lîschen */
					/* und zum aktuellen Layer machen */
					ll=first_lay;
					while(ll)
					{
						if(&ll->this == l)
							act_lay=ll;
						ll->this.visible=0;
						ll->this.draw=0;
						ll->this.solo=0;
						ll=ll->next;
					}
					l->solo=1;
					otoolbar[MASK_ED-1].ob_state &= (~SELECTED);
					otoolbar[MASK_ED].ob_x=TB_IMG_X;
					otoolbar[MASK_ED].ob_y=0;
					/* Alten Masken-Vis & Aktiv herstellen */
					otoolbar[MASK_ON-1].ob_state &= (~SELECTED);
					otoolbar[MASK_ON-1].ob_state |= oon;
					otoolbar[MASK_VIS-1].ob_state &= (~SELECTED);
					otoolbar[MASK_VIS-1].ob_state |= ovis;
					otoolbar[MASK_ON].ob_x=TB_M_IMG_X;
					otoolbar[MASK_ON].ob_y=0;
					otoolbar[MASK_VIS].ob_x=TB_IMG_X;
					otoolbar[MASK_VIS].ob_y=0;
					if(otoolbar[MASK_ON-1].ob_state & SELECTED)
					{
						otoolbar[MASK_ON].ob_x=TB_M_IMG_X+1;
						otoolbar[MASK_ON].ob_y=1;
					}
					if(otoolbar[MASK_VIS-1].ob_state & SELECTED)
					{
						otoolbar[MASK_VIS].ob_x=TB_IMG_X+1;
						otoolbar[MASK_VIS].ob_y=1;
					}
				}
				else
					l->solo=0;

				redraw=0;
				if(l->solo)
					redraw=l->draw=l->visible=1;
				else
					redraw=get_lay_store(0);
				for(a=TBS1; a<=TBS10; ++a)
					otoolbar[a].ob_state &= (~SELECTED);
				init_layob();
				draw_layob();
				if(redraw)
					redraw_pic();
				new_edit_select();
			break;
		}
	}
	else if((ob >= TBSTORE) && (ob <= TBS10))
	{
		if(ob == TBSTORE)
		{
			if(dial_store())
			{
				init_layob();
				draw_layob();
			}
		}
		else
		{
			if(!(otoolbar[ob].ob_state & SELECTED))
			{/* Ist noch nicht selektiert */
				for(a=TBS1; a<=TBS10; ++a)
					otoolbar[a].ob_state &= (~SELECTED);
				redraw=get_lay_store(ob-TBS1+1);
				otoolbar[ob].ob_state |= SELECTED;
				init_layob();
				draw_layob();
				if(redraw)
					redraw_pic();
			}
		}
	}
	else switch(ob)
	{
/*		case TBMAN:
			set_vdi_colors();
			if(Kbshift(-1) & 8)
				special_redraw(1);
			else if(Kbshift(-1) & 3)
				special_redraw(2);
			else if(Kbshift(-1) & 4)
/*			{
				set_grey_pal();
				special_redraw(3);
				set_vdi_colors();
			}*/
				line_draw(0,0,100,200,0,255);
			else
				redraw_pic();
		break;
*/
		case TBZOOM:
			zoom_window();
		break;
		case TBL:
			if(layers_off > 0)
			{
				--layers_off;
				init_layob();
				draw_layob();
			}
		break;
		case TBR:
			a=count_layers();
			if(layers_off+1 < a)
			{
				++layers_off;
				init_layob();
				draw_layob();
			}
		break;
		
		case TBLS:
		break;

		case MASK_ON-1:
			ob=MASK_ON;
		case MASK_ON:
			otoolbar[ob].ob_x=TB_M_IMG_X;
			otoolbar[ob].ob_y=0;
			if(otoolbar[ob-1].ob_state & SELECTED)
				otoolbar[ob-1].ob_state &= (~SELECTED);
			else
			{
				otoolbar[ob-1].ob_state |= SELECTED;
				otoolbar[MASK_ON].ob_x=TB_M_IMG_X+1;
				otoolbar[MASK_ON].ob_y=1;
			}
			for(a=TBS1; a<=TBS10; ++a)
				otoolbar[a].ob_state &= (~SELECTED);
			init_layob();
			draw_layob();
		break;
		case MASK_VIS:
			otoolbar[ob].ob_x=TB_IMG_X;
			otoolbar[ob].ob_y=0;
			if(otoolbar[ob-1].ob_state & SELECTED)
				otoolbar[ob-1].ob_state &= (~SELECTED);
			else
			{
				otoolbar[ob-1].ob_state |= SELECTED;
				otoolbar[MASK_VIS].ob_x=TB_IMG_X+1;
				otoolbar[MASK_VIS].ob_y=1;
			}
			for(a=TBS1; a<=TBS10; ++a)
				otoolbar[a].ob_state &= (~SELECTED);
			init_layob();
			draw_layob();
			redraw_pic();
		break;
		case MASK_ED:
			/* Ist schon selektiert ? */
			if(otoolbar[ob-1].ob_state & SELECTED)
				break;
			otoolbar[ob].ob_x=TB_IMG_X;
			otoolbar[ob].ob_y=0;

			otoolbar[ob-1].ob_state |= SELECTED;
			otoolbar[MASK_ED].ob_x=TB_IMG_X+1;
			otoolbar[MASK_ED].ob_y=1;
			/* Andere Draws deaktivieren */
			ll=first_lay;
			while(ll)
			{
				ll->this.draw=0;
				ll=ll->next;
			}

			init_layob();
			for(a=TBS1; a<=TBS10; ++a)
				otoolbar[a].ob_state &= (~SELECTED);
			draw_layob();
			if(undo_on && (oundo[UALL].ob_state & SELECTED) && (ounopt[UORES4].ob_state & SELECTED))
			{
				free_undo();
				clear_undo();
				init_undo();
			}
			new_edit_select();
		break;
		case MASK_NAM:
			if(klicks < 2)
			{/* Masken-Popup */
				/* Aktuelle Auswahl in ex_type notieren */
				set_ext_type(otoolbar, MASK_NAM, act_mask->this.id);
				a=mask_popup(otoolbar, ob, -1);
				if(a > 0)
				{
					if(act_mask != find_mask_list(a-1))
					{
						act_mask=find_mask_list(a-1);
						init_layob();
						draw_layob();
						if(otoolbar[MASK_VIS-1].ob_state & SELECTED)
							redraw_pic();
						if(otoolbar[MASK_ED-1].ob_state & SELECTED)
							new_edit_select();
					}
				}
			}
			else
			{
				mod_mask=&(act_mask->this);
				modify_mask_win();
			}
		break;

	}
}

int mgraf_dragbox(int src, int w, int h, int x, int y, int *dst)
{
	/* Gibt Action zurÅck :
			0=nix
			1=Layer an andere Position, Ziel in dst (dst=Zielposition, nicht Layer. S. auch move_layer() )
			2=Layer kopieren, Ziel in dst (dst=Ziel-Layer-Nummer)
			3=Layer in (aktive) Maske kopieren
			4=Layer als Quellfarbe einsetzen
	*/
	int pxy[10], ox, oy, mx, my, mk, dum, ofx, ofy, ob;
	int	dif, a, obx, oby, laynum, swid;
	
	laynum=count_layers();
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	graf_mouse(258, NULL);
	graf_mouse(USER_DEF, UD_HAND);
	
	if(x < sx) x=sx; if(y < sy) y=sy;
	if(x+w > sx+sw) x=sx+sw-w;
	if(y+h > sy+sh) y=sy+sh-1;
	
	pxy[0]=x; pxy[1]=y;
	pxy[2]=x+w-1; pxy[3]=y;
	pxy[4]=x+w-1; pxy[5]=y+h-1;
	pxy[6]=x; pxy[7]=y+h-1;
	pxy[8]=x; pxy[9]=y;
	
	vswr_mode(handle, 3);
	vsl_type(handle, 7);
	vsl_udsty(handle, 21845);
  vsl_width(handle, 1);
  vsl_color(handle, 1);
  vsl_ends(handle, 0, 0);
  vsm_type(handle, 0);

	graf_mkstate(&mx, &my, &mk, &dum);
	ox=mx; oy=my;
	ofx=x-mx; ofy=y-my;
	
	graf_mouse(M_OFF, NULL);
	v_pline(handle, 5, pxy);
	graf_mouse(M_ON, NULL);

	do
	{
		graf_mkstate(&mx, &my, &mk, &dum);
		if(mx+ofx < sx) mx=sx-ofx; if(my+ofy < sy) my=sy-ofy;
		if(mx+ofx+w-1 > sx+sw) mx=sx+sw-ofx-w+1;
		if(my+ofy+h-1 > sy+sh) my=sy+sh-ofy-h+1;
		if((mx != ox) || (my != oy))
		{
			graf_mouse(M_OFF, NULL);
			v_pline(handle, 5, pxy);
			/* Neue Koordinaten */
			pxy[0]=pxy[8]=pxy[6]=mx+ofx; pxy[2]=pxy[4]=mx+ofx+w-1;
			pxy[1]=pxy[3]=pxy[9]=my+ofy; pxy[5]=pxy[7]=my+ofy+h-1;
			v_pline(handle, 5, pxy);
			ox=mx; oy=my;
			graf_mouse(M_ON, NULL);
			/* Im EinfÅge-Bereich? */
			ob=objc_find(otoolbar,0, 8, mx, my);
			if((ob >= LAY1) && (ob <= LAYLAST))
			{/* Parentbox finden */
				dif=LAY2-LAY1;
				a=(ob-LAY1)/dif;
				objc_offset(otoolbar, LAY1+a*dif, &obx, &oby);
				if(((mx <= obx+8) && 
						((a+layers_off < src) || (a+layers_off > src+1)))
						 || 
					 ((mx >= obx+otoolbar[LAY1].ob_width-8) &&
					  ((a+layers_off < src-1) || (a+layers_off > src))
					 )
					)
					graf_mouse(USER_DEF, UD_INSERT);
				else
					graf_mouse(USER_DEF, UD_HAND);
			}
			else if((ob == TBL) && (layers_off > 0))
			{
				layers_off--;
				init_layob();
				graf_mouse(M_OFF, NULL);
				v_pline(handle, 5, pxy);
				draw_layob();
				evnt_timer(100,0);
				v_pline(handle, 5, pxy);
				graf_mouse(M_ON, NULL);
				graf_mouse(USER_DEF, UD_HAND);
			}
			else if((ob == TBR) && (layers_off+1 < laynum))
			{
				layers_off++;
				init_layob();
				graf_mouse(M_OFF, NULL);
				v_pline(handle, 5, pxy);
				draw_layob();
				evnt_timer(100,0);
				v_pline(handle, 5, pxy);
				graf_mouse(M_ON, NULL);
				graf_mouse(USER_DEF, UD_HAND);
			}
			else if(ob==MASK_NAM)
					graf_mouse(USER_DEF, UD_HAND);
			else
			{/* Vielleicht auf Farbfeld gedragged */
				swid=wind_find(mx, my);
				if(swid==wtool.whandle)
				{
					ob=objc_find(otool, 0, 8, mx, my);
					if(ob==GPPCOL)
						graf_mouse(USER_DEF, UD_HAND);
					else
						graf_mouse(USER_DEF, UD_CROSS);
				}
				else
				/* Alles nix gut */
					graf_mouse(USER_DEF, UD_CROSS);
			}
		}
	}while(mk & 3);

	graf_mouse(M_OFF, NULL);
	v_pline(handle, 5, pxy);
	graf_mouse(M_ON, NULL);

	vsl_type(handle, 1);

	graf_mouse(259, NULL);	
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);

	ob=objc_find(otoolbar,0, 8, mx, my);
	if((ob >= LAY1) && (ob <= LAYLAST))
	{/* Parentbox finden */
		dif=LAY2-LAY1;
		a=(ob-LAY1)/dif;
		objc_offset(otoolbar, LAY1+a*dif, &obx, &oby);
		if((mx <= obx+8) && ((a+layers_off < src) || (a+layers_off > src+1)))
		{
			*dst=a+layers_off;
			return(1);
		}
		else if ((mx >= obx+otoolbar[LAY1].ob_width-8) &&
			  ((a+layers_off < src-1) || (a+layers_off > src)))
		{
			*dst=a+layers_off+1;
			return(1);
		}
		else
		{
			*dst=a+layers_off;
			return(2);
		}
	}
	else if(ob == MASK_NAM)
		return(3);
	else
	{/* Vielleicht auf Farbfeld gedragged */
		swid=wind_find(mx, my);
		if(swid==wtool.whandle)
		{
			ob=objc_find(otool, 0, 8, mx, my);
			if(ob==GPPCOL)
				return(4);
		}
	}
		
	return(0);
}
