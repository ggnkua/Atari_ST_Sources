#include <grape_h.h>
#include "grape.h"
#include "undo.h"
#include "layer.h"
#include "mask.h"
#include "preview.h"
#include "jobs.h"
#include "xrsrc.h"

/* Mit Farbe fÅllen */
void fill_act_plane(CMY_COLOR *col)
{
	char	text[256];
	int		redraw=0;
	register uchar	*c, *m, *y, cc, mm, yy;
	register long		ldif;
	register int		h,w,xc,yc;
	
	set_grey(col);
	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{
		strcpy(text,"[2][Grape:|Soll die Maske ");
		strcat(text, act_mask->this.name);
		strcat(text, "|eingefÑrbt werden?][OK|Abbruch]");
		if(form_alert(1,text)==2)
			return;
		c=act_mask->this.mask;
		m=y=NULL;
		cc=mm=yy=col->grey;
		if(otoolbar[MASK_VIS-1].ob_state & SELECTED)
			redraw=1;
		if(!auto_reset(0))
			return;
		if(!all_to_undo(NULL, &(act_mask->this)))
			return;
	}
	else
	{
		strcpy(text,"[2][Grape:|Soll die Ebene ");
		strcat(text, act_lay->this.name);
		strcat(text, "|eingefÑrbt werden?][OK|Abbruch]");
		if(form_alert(1,text)==2)
			return;
		c=act_lay->this.blue;
		m=act_lay->this.red;
		y=act_lay->this.yellow;
		cc=col->blue; mm=col->red; yy=col->yellow;
		if(act_lay->this.visible)
			redraw=1;
		if(!auto_reset(0))
			return;
		if(!all_to_undo(&(act_lay->this), NULL))
			return;
	}

	h=first_lay->this.height;
	w=first_lay->this.width;
	ldif=first_lay->this.word_width-w;
	
	busy(ON);
	graf_mouse(BUSYBEE, NULL);
	for(yc=h; yc>0; --yc)
	{
		for(xc=w; xc>0; --xc)
			*c++=cc;
		c+=ldif;
	}

	if(m)	
	{
		for(yc=h; yc>0; --yc)
		{
			for(xc=w; xc>0; --xc)
				*m++=mm;
			m+=ldif;
		}
		for(yc=h; yc>0; --yc)
		{
			for(xc=w; xc>0; --xc)
				*y++=yy;
			y+=ldif;
		}
	}
	graf_mouse(ARROW, NULL);
	busy(OFF);

	if(redraw)
		redraw_pic();
	actize_win_name();
	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
		mask_changed(act_mask);
	else
		layer_changed(act_lay);
}

/* Masken */

void insert_mask_win(void)
{
	
	strcpy(onewmask[NMTITEL].ob_spec.tedinfo->te_ptext, "Maske hinzufÅgen");
	onewmask[NMCOL1].ob_spec.obspec.interiorcol=1; /* Schwarz */
	strcpy(onewmask[NMCOL2].ob_spec.tedinfo->te_ptext, " Schwarz");

	if(!wnewmask.open)
	{
		wnewmask.dinfo=&dnewmask;
		w_dial(&wnewmask, D_CENTER);
		wnewmask.name="[Grape]";
		w_set(&wnewmask, NAME);
		dnewmask.dedit=NMNAME;
		w_open(&wnewmask);
	}
	else
	{
		w_top(&wnewmask);
		s_redraw(&wnewmask);
	}
	onewmask[NMNEWMOD].ob_state &= (~SELECTED);
}

void modify_mask_win(void)
{
	OBJECT *onmcolpop;
	xrsrc_gaddr(0,NMCOLPOP, &onmcolpop, xrsrc);

	strcpy(onewmask[NMTITEL].ob_spec.tedinfo->te_ptext, "Maske modifizieren");
	strcpy(onewmask[NMNAME].ob_spec.tedinfo->te_ptext, mod_mask->name);
	onewmask[NMCOL1].ob_spec.obspec.interiorcol=mod_mask->col; /* Farbe */
	strcpy(onewmask[NMCOL2].ob_spec.tedinfo->te_ptext, onmcolpop[2*mod_mask->col].ob_spec.free_string);
	
	if(!wnewmask.open)
	{
		wnewmask.dinfo=&dnewmask;
		w_dial(&wnewmask, D_CENTER);
		wnewmask.name="[Grape]";
		w_set(&wnewmask, NAME);
		dnewmask.dedit=NMNAME;
		w_open(&wnewmask);
	}
	else
	{
		w_top(&wnewmask);
		s_redraw(&wnewmask);
	}
	
	onewmask[NMNEWMOD].ob_state |= SELECTED;
}

void dial_newmask(int ob)
{
	int c, x, y;
	OBJECT *onmcolpop;
	xrsrc_gaddr(0,NMCOLPOP, &onmcolpop, xrsrc);
	
	switch(ob)
	{
		case NMCOL1:
		case NMCOL2:
			objc_offset(onewmask, NMCOL1, &x, &y);
			y-=(onewmask[NMCOL1].ob_spec.obspec.interiorcol-1)*onmcolpop[1].ob_height;
			c=form_popup(onmcolpop, x, y);
			if(c > 0)
			{
				onewmask[NMCOL1].ob_spec.obspec.interiorcol=onmcolpop[c-1].ob_spec.obspec.interiorcol;
				strcpy(onewmask[NMCOL2].ob_spec.tedinfo->te_ptext, onmcolpop[c].ob_spec.free_string);
				w_objc_draw(&wnewmask, NMCOL1, 8, sx, sy, sw,sh);
				w_objc_draw(&wnewmask, NMCOL2, 8, sx, sy, sw,sh);
			}
		break;
		
		case NMOK:
			if(!onewmask[NMNAME].ob_spec.tedinfo->te_ptext[0])
			{
				form_alert(1,"[3][Grape:|Der Name darf nicht leer sein!][OK]");
				w_unsel(&wnewmask, ob);
				break;
			}
			if(onewmask[NMNEWMOD].ob_state & SELECTED)
				modify_mask();
			else
				insert_mask();
		case NMABBRUCH:
			w_unsel(&wnewmask, ob);
			w_close(&wnewmask);
			w_kill(&wnewmask);
		break;
	}
}

void modify_mask(void)
{
	int	o_col=mod_mask->col;
	
	strcpy(mod_mask->name, onewmask[NMNAME].ob_spec.tedinfo->te_ptext);
	mod_mask->col=onewmask[NMCOL1].ob_spec.obspec.interiorcol; /* Farbe */

	init_layob();
	draw_layob();
	/* Ist die Maske die aktuelle Maske und ist dieses sichtbar und
		 wurde die Farbe geÑndert ? */
	if((o_col != mod_mask->col) && (mod_mask==&(act_mask->this))) 
	{
		if(otoolbar[MASK_VIS-1].ob_state & SELECTED)
			redraw_pic();
		mask_changed(act_mask);
	}

	if(wcopylay.open)
	{/* GGf. Name im Copy-Fenster anpassen */
		if(ocopylay[CLSTYP].ob_type >> 8)
			if((ocopylay[CLSNAM].ob_type >> 8) == mod_mask->id)
			{
				strcpy(ocopylay[CLSNAM].ob_spec.free_string, mod_mask->name);
				s_redraw(&wcopylay);
			}

		if(ocopylay[CLDTYP].ob_type >> 8)
		if((ocopylay[CLDNAM].ob_type >> 8) == mod_mask->id)
		{
			strcpy(ocopylay[CLDNAM].ob_spec.free_string, mod_mask->name);
			s_redraw(&wcopylay);
		}
	}

	actize_win_name();
}

void insert_mask(void)
{
	LAY_LIST	*l;
	MASK_LIST	*m;
	long			siz;
	
	m=(MASK_LIST*)malloc(sizeof(MASK_LIST));
	if(!m)
	{
		form_alert(1,"[3][Nicht genug Speicher!][Abbruch]");
		return;
	}
		
	siz=(long)((long)first_lay->this.word_width*(long)first_lay->this.height);
	m->this.mask=(void*)calloc(siz,1);
	if(!m->this.mask)
	{
		form_alert(1,"[3][Nicht genug Speicher!][Abbruch]");
		free(m);
		return;
	}

	first_mask->prev=m;
	m->next=first_mask;
	m->prev=NULL;

	m->this.id=++mask_id;
		
	strcpy(m->this.name, onewmask[NMNAME].ob_spec.tedinfo->te_ptext);
	m->this.col=onewmask[NMCOL1].ob_spec.obspec.interiorcol;
	
		
	act_mask=first_mask=m;
	
	/* Ebenen Draw deaktivieren */
	l=first_lay;
	while(l)
	{
		l->this.draw=0;
		l=l->next;
	}

	/* Alle Maskenflags selektieren */
	otoolbar[MASK_ON-1].ob_state |= SELECTED;
	otoolbar[MASK_VIS-1].ob_state |= SELECTED;
	otoolbar[MASK_ED-1].ob_state |= SELECTED;

	otoolbar[MASK_ON].ob_y=otoolbar[MASK_VIS].ob_y=otoolbar[MASK_ED].ob_y=1;
	otoolbar[MASK_ON].ob_x=TB_M_IMG_X+1;
	otoolbar[MASK_VIS].ob_x=TB_IMG_X+1;
	otoolbar[MASK_ED].ob_x=TB_IMG_X+1;

	init_layob();
	draw_layob();
	
	redraw_pic();

	actize_win_name();
	mask_changed(act_mask);
}

int mask_popup(OBJECT *tree, int ob, int disable_id)
{
	/* ôffnet Åber dem Object ob aus tree ein Popup mit allen Masken */
	/* Die aktuelle Auswahl (fÅr die v-Ausrichtung des Popups) wird */
	/* aus dem erweiterten Typ von ob bestimmt, d.h. hier muû die */
	/* ID der aktuell gewÑhlten Ebene eingetragen werden! */
	/* Die Maske mit der ID disable_id erscheint im Popup disabled */
	/* (falls unerwÅnscht, disable_id < 0 Åbergeben */
	
	OBJECT	*omaskpop;
	MASK_LIST	*m=first_mask;
	int	c=0, d, mnum, x, y;
	
	xrsrc_gaddr(0, MASKPOP, &omaskpop, xrsrc);
	
	/* Popup initialisieren */
	while(m)
	{
		if(m->this.id == tree[ob].ob_type/256)
		{
			mnum=c;
			omaskpop[c+1].ob_state |= CHECKED;
		}
		else
			omaskpop[c+1].ob_state &= (~CHECKED);
		
		strcpy(omaskpop[++c].ob_spec.free_string, "  ");
		strcat(omaskpop[c].ob_spec.free_string, m->this.name);
		omaskpop[c].ob_flags &= (~HIDETREE);
		if(m->this.id != disable_id)
		{
			omaskpop[c].ob_state &= (~DISABLED);
			omaskpop[c].ob_flags |= SELECTABLE;
		}
		else
		{
			omaskpop[c].ob_state |= DISABLED;
			omaskpop[c].ob_flags &= (~SELECTABLE);
		}

		m=m->next;
	}
	d=c;
	while(d < 16)
		omaskpop[++d].ob_flags |= HIDETREE;
	
	omaskpop[0].ob_height=c*omaskpop[1].ob_height;
	
	objc_offset(tree, ob, &x, &y);
	y-=mnum*omaskpop[1].ob_height;
	return(form_popup(omaskpop, x, y));
}


MASK_LIST *find_mask_list(int num)
{/* Sucht aus der Maskenliste die Maske Nr. num 
    ZÑhlung ab 0 !
  */
  
  MASK_LIST	*m=first_mask;
	
	while(num-- && m)
		m=m->next;
	
	++num;
	
	if(num || (!m))
		return(NULL);
	
	return(m);
}

MASK *find_mask(int num)
{/* Sucht aus der Maskenliste die Maske Nr. num 
    ZÑhlung ab 0 !
  */
  
  MASK_LIST	*m=first_mask;
	
	while(num-- && m)
		m=m->next;
	
	++num;
	
	if(num || (!m))
		return(NULL);
	
	return(&(m->this));
}

MASK_LIST *find_mask_list_id(int id)
{
	MASK_LIST *m=first_mask;
	
	while(m)
	{
		if(m->this.id == id)
			return(m);
		m=m->next;
	}
	
	return(NULL);
}

MASK *find_mask_id(int id)
{
	MASK_LIST *m=first_mask;
	
	while(m)
	{
		if(m->this.id == id)
			return(&(m->this));
		m=m->next;
	}
	
	return(NULL);
}

int	count_masks(void)
{
	MASK_LIST *m=first_mask;
	int c=0;
	
	while(m)
	{	++c; m=m->next;}
	
	return(c);
}

void delete_mask(void)
{
	char	alrt[255];
	MASK_LIST	*ml;
	
	if(count_masks() == 1)
	{
		form_alert(1,"[3][Grape:|Es muû mindestens eine Maske|erhalten bleiben. Um die gesamte|Datei zu entfernen, wÑhlen Sie|\'Schlieûen\' aus dem Datei-MenÅ.][Abbruch]");
		return;
	}

	strcpy(alrt, "[2][Grape:|Soll die Maske ");
	strcat(alrt, act_mask->this.name);

	strcat(alrt, "|wirklich entfernt werden?|(Diese Aktion kann nicht rÅck-|gÑngig gemacht werden!)][OK|Abbruch]");
	
	if(!(form_alert(1, alrt)-1))
	{/* Maske entfernen */

		if(wcopylay.open)
		{ /* Ist die Maske gerade im Copy-Dialog? Dann Dial schlieûen */
			if(ocopylay[CLSTYP].ob_type >> 8)
				if((ocopylay[CLSNAM].ob_type >> 8) == act_mask->this.id)
					dial_copylay(CLABBRUCH);
			if(ocopylay[CLDTYP].ob_type >> 8)
				if((ocopylay[CLDNAM].ob_type >> 8) == act_mask->this.id)
					dial_copylay(CLABBRUCH);
			if((ocopylay[CLMNAM].ob_type >> 8) == act_mask->this.id)
				dial_copylay(CLABBRUCH);
		}
		
		del_undo_entry(act_mask->this.id, 1);

		/* AushÑngen & Nachfolger festlegen */

		if(act_mask->prev)
		{
			act_mask->prev->next=act_mask->next;
			ml=act_mask->prev;
		}
		if(act_mask->next)
		{
			act_mask->next->prev=act_mask->prev;
			ml=act_mask->next;
		}
		
		free(act_mask->this.mask);
		free(act_mask);
		if(act_mask == first_mask)
			first_mask=ml;
		act_mask=ml;

		init_layob();
		draw_layob();
		if(otoolbar[MASK_VIS-1].ob_state & SELECTED)
			redraw_pic();

		actize_win_name();
		first_lay->this.changes=1;
		mask_changed(act_mask);
	}
}

void clear_mask(void)
{
	char	alrt[256];
	long	siz;

	
	strcpy(alrt, "[2][Grape:|Soll der Inhalt der Maske|");
	strcat(alrt, act_mask->this.name);
	strcat(alrt, " wirklich gelîscht werden?][OK|Abbruch]");
	
	if(!(form_alert(1, alrt)-1))
	{/* Maskeninhalt lîschen */
		if(!auto_reset(5))
			return;
		if(!all_to_undo(NULL, &(act_mask->this)))
			return;

		siz=(long)((long)first_lay->this.word_width*(long)first_lay->this.height);
		memset(act_mask->this.mask, 0, siz);	

		if(otoolbar[MASK_VIS-1].ob_state & SELECTED)
			redraw_pic();
		mask_changed(act_mask);
		
		actize_win_name();
		first_lay->this.changes=1;
	}
}

void copy_mask_init(void)
{
	/* Maske kopieren ohne Vorgabe */
	
	MASK	*m;
	LAYER	*l;
	
	set_ext_type(ocopylay, CLSNAM, act_mask->this.id);
	set_ext_type(ocopylay, CLSTYP, 1);

	if(count_masks() > 1)
	{
		m=find_mask(0);
		if(m->id == act_mask->this.id)
			m=find_mask(1);
		set_ext_type(ocopylay, CLDNAM, m->id);
		set_ext_type(ocopylay, CLDTYP, 1);
	}
	else
	{/* Es gibt nur eine Maske, Ebene als Ziel */
		l=find_layer(0);
		set_ext_type(ocopylay, CLDNAM, l->id);
		set_ext_type(ocopylay, CLDTYP, 0);
	}
	
	copy_layer_win();
}

void copy_mask_lay(int sid, int did, int how)
{
	/* sid=ID der Source-Maske
	   did=ID der Dest-Ebene
	   how=Kopierart 0=transparent, 1=deckend, 2=deck. incl weiû
	*/
	
	MASK	*s;
	LAYER	*d;
	unsigned char *a, *r, *g, *b;
	unsigned int mr,mg,mb,mc,grey;
	long siz;
	
	s=find_mask_id(sid);
	d=find_layer_id(did);
	
	if(s && d)
	{
		a=s->mask;
		r=d->red;
		g=d->yellow;
		b=d->blue;
		
		siz=(long)((long)first_lay->this.word_width*(long)first_lay->this.height);
		
		switch(how)
		{
			case 0: /* transparent */
				while(siz--)
				{
					mr=255-*b;
					mg=255-*r;
					mb=255-*g;
					/* RGB->Grey Hibyte(77*R+151*G+28*B) */
					mc=77*mr+151*mg+28*mb;
					mc=mc >> 8;
					grey=(unsigned char)255-mc;

					if(*a > grey)
						*r=*g=*b=*a;
					++a;
					++r;++g;++b;
				}
			break;
				
			case 1: /* deckend ohne weiû */
				while(siz--)
				{
					if(*a)
						*r=*g=*b=*a;
					++a;
					++r;++g;++b;
				}
			break;
			
			case 2: /* deckend incl. weiû*/
				while(siz--)
					*r++=*g++=*b++=*a++;
			break;
		}
	}

	if(d->visible)
		redraw_pic();
}
	
void copy_lay_mask(int sid, int did, int how)
{
	/* sid=ID der Source-Ebene
	   did=ID der Dest-Maske
	   how=Kopierart 0=transparent, 1=deckend, 2=deck. incl weiû
	*/
	
	LAYER	*s;
	MASK	*d;
	unsigned char *a, *r, *g, *b;
	unsigned int mr,mg,mb,mc,grey;
	long siz;
	
	s=find_layer_id(sid);
	d=find_mask_id(did);
	
	if(s && d)
	{
		r=s->red;
		g=s->yellow;
		b=s->blue;
		a=d->mask;
		
		siz=(long)((long)first_lay->this.word_width*(long)first_lay->this.height);
		
		switch(how)
		{
			case 0: /* transparent */
				while(siz--)
				{
					mr=255-*b;
					mg=255-*r;
					mb=255-*g;
					/* RGB->Grey Hibyte(77*R+151*G+28*B) */
					mc=77*mr+151*mg+28*mb;
					mc=mc >> 8;
					grey=(unsigned char)255-mc;

					if(grey > *a)
						*a=grey;
					++a;
					++r;++g;++b;
				}
			break;
				
			case 1: /* deckend ohne weiû */
				while(siz--)
				{
					mr=255-*b;
					mg=255-*r;
					mb=255-*g;
					/* RGB->Grey Hibyte(77*R+151*G+28*B) */
					mc=77*mr+151*mg+28*mb;
					mc=mc >> 8;
					grey=(unsigned char)255-mc;
					if(grey)
						*a=grey;
					++a;
					++r;++g;++b;
				}
			break;
			
			case 2: /* deckend incl. weiû*/
				while(siz--)
				{
					mr=255-*b;
					mg=255-*r;
					mb=255-*g;
					/* RGB->Grey Hibyte(77*R+151*G+28*B) */
					mc=77*mr+151*mg+28*mb;
					mc=mc >> 8;
					grey=(unsigned char)255-mc;
					*a=grey;
					++a;
					++r;++g;++b;
				}
			break;
		}
	}
	/* Zielmaske sichtbar? */
	if((act_mask->this.id == d->id) && (otoolbar[MASK_VIS-1].ob_state & SELECTED))
		redraw_pic();
}

void copy_mask(int sid, int did, int how)
{
	/* sid=ID der Source-Maske
	   did=ID der Dest-Maske
	   how=Kopierart 0=transparent, 1=deckend, 2=deck. incl weiû
	*/
	
	MASK	*s, *d;
	unsigned char *a, *b;
	long siz;
	
	s=find_mask_id(sid);
	d=find_mask_id(did);
	
	if(s && d)
	{
		a=s->mask;
		b=d->mask;
		siz=(long)((long)first_lay->this.word_width*(long)first_lay->this.height);
		
		switch(how)
		{
			case 0: /* transparent */
				while(siz--)
				{
					if(*a > *b)
						*b=*a;
					++a;
					++b;
				}
			break;
				
			case 1: /* deckend ohne weiû */
				while(siz--)
				{
					if(*a)
						*b=*a;
					++a;
					++b;
				}
			break;
			
			case 2: /* deckend incl. weiû*/
				while(siz--)
					*b++=*a++;
			break;
		}
	}
	
	/* Zielmaske sichtbar? */
	if((act_mask->this.id == d->id) && (otoolbar[MASK_VIS-1].ob_state & SELECTED))
		redraw_pic();
}


void set_ext_type(OBJECT *tree, int ob, int et)
{/* Setzt den erweiterten Typ von ob in tree auf et */
	tree[ob].ob_type &=255;
	tree[ob].ob_type |= (((char)et)<<8);
}

