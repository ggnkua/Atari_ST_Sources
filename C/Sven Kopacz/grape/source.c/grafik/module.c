#include <grape_h.h>
#include <moddef.h>
#include "grape.h"
#include "module.h"
#include "undo.h"
#include "preview.h"
#include "jobs.h"
#include "xrsrc.h"
#include "fiomod.h"
#include "coled.h"

#define mod_len	(omodule[0].ob_type >> 8)
#define mod_off	(omodule[1].ob_type >> 8)

extern OBJECT *opens;



void scan_modules(void)
{
	MODULE_LIST	*l;
	int num=0, a, ix;
	TEDINFO	*atd;
	
	delete_modules();
	num=scan_folders(paths.module_path);

	if(num < 1)
	{
		if(num == -1)
			form_alert(1,"[3][Grape:|Nicht genug Speicher fÅr die|Modulliste!][Abbruch]");
		delete_modules();
		return;
	}
	
	omodule=(OBJECT*)malloc((1+num*2)*sizeof(OBJECT));
	atd=(TEDINFO*)malloc(num*sizeof(TEDINFO));

	if((!omodule) || (!atd))
	{
		delete_modules();
		form_alert(1,"[3][Grape:|Nicht genug Speicher fÅr die|Modulliste!][Abbruch]");
		return;
	}
	
	omodule[0].ob_next=-1;
	omodule[0].ob_head=1;
	omodule[0].ob_tail=num*2;
	omodule[0].ob_type=G_BOX;
	omodule[0].ob_flags=opens[0].ob_flags; /* 3D */
	omodule[0].ob_state=opens[0].ob_state;
	omodule[0].ob_spec.obspec=opens[0].ob_spec.obspec;
	omodule[0].ob_x=omodule[0].ob_y=0;
	omodule[0].ob_height=32*num;
	omodule[0].ob_width=opens[0].ob_width;

	l=first_module;
	for(a=0; a < num; ++a)
	{
		/* Icon */
		ix=a*2+1;
		omodule[ix].ob_next=ix+1;
		omodule[ix].ob_head=omodule[ix].ob_tail=-1;
		omodule[ix].ob_type=G_CICON;
		omodule[ix].ob_flags=TOUCHEXIT;
		omodule[ix].ob_state=NORMAL;
		(CICONBLK*)omodule[ix].ob_spec.iconblk=l->iconblk;
		omodule[ix].ob_x=0;
		omodule[ix].ob_y=32*a;
		omodule[ix].ob_width=omodule[ix].ob_height=32;
		
		/* Text */
		ix=a*2+2;
		omodule[ix].ob_next=ix+1;
		omodule[ix].ob_head=omodule[ix].ob_tail=-1;
		omodule[ix].ob_type=G_BOXTEXT;
		omodule[ix].ob_flags=0x400|TOUCHEXIT;
		omodule[ix].ob_state=NORMAL;
		omodule[ix].ob_spec.tedinfo=atd+a; /* *sizeof(TEDINFO) passiert automatisch */
		omodule[ix].ob_spec.tedinfo->te_ptext=l->name;
		omodule[ix].ob_spec.tedinfo->te_ptmplt=l->name;
		omodule[ix].ob_spec.tedinfo->te_pvalid=l->name;
		omodule[ix].ob_spec.tedinfo->te_font=3;
		omodule[ix].ob_spec.tedinfo->te_just=0;
		omodule[ix].ob_spec.tedinfo->te_color=0x1180;
		omodule[ix].ob_spec.tedinfo->te_thickness=2;
		omodule[ix].ob_spec.tedinfo->te_txtlen=16;
		omodule[ix].ob_spec.tedinfo->te_tmplen=0;
		omodule[ix].ob_x=32;
		omodule[ix].ob_y=32*a;
		omodule[ix].ob_width=omodule[0].ob_width-32;
		omodule[ix].ob_height=32;
		
		l=l->next;
	}	
	
	omodule[num*2].ob_next=0;
	omodule[num*2].ob_flags|=LASTOB;

	set_ext_type(omodule, 0, num); /* Fenstergrîûe */
	set_ext_type(omodule, 1, 0);	 /* Offset */
}

int	scan_folders(char *path)
{ /* ZÑhlt die Ordner im Pfad path, die einen Gruppendeskriptor
		 enthalten und erzeugt dabei die Modul-Liste.
		 Der Pfad muû bereits die Dateimaske enthalten
		 Gibt -1 bei Speichermangel zurÅck
	 */
	char	opath[256], tpath[256];
	DTA		*old=Fgetdta(), dta;	
	int		num=0, rf;
	long	l, fh;
	
	/* Pfad merken */
	strcpy(opath, path);
	l=strlen(opath)-1;
	while(opath[l] != '\\')--l;
	opath[l+1]=0;
	
	Fsetdta(&dta);
	
	if(!Fsfirst(path, FA_SUBDIR))
	{
		do
		{	
			strcpy(tpath, opath);
			strcat(tpath, dta.d_fname);
			strcat(tpath, "\\GROUP.DSC");
			fh=Fopen(tpath, FO_READ);
			if(fh > 0)
			{
				rf=cat_modules(tpath, (int)fh);
				if(rf == -1)
				{
					Fclose((int)fh);
					return(-1);
				}
				else if(rf == 1)
					++num;
				Fclose((int)fh);
			}
		}while(!Fsnext());
	}
	Fsetdta(old);
	return(num);
}

int cat_modules(char *path, int fh)
{ /* path=Pfad zum Gruppendescriptor, fh=Handle der bereits
		 geîffneten Descriptor-Datei.
		 Die Funktion hÑngt die Infos an die Modulliste an 
		 Gibt 0 zurÅck, wenn keine Module im Pfad sind
		 Gibt -1 bei Speichermangel zurÅck 
		 sonst 1*/
	
	MODULE_LIST	*l, **ll=&first_module, *p=NULL;
	long	filesize, adc;
	int		rf;
		
	l=(MODULE_LIST*)malloc(sizeof(MODULE_LIST));
	if(!l)
		return(-1);

	l->mlist=NULL;
	rf=modules_in_list(path, l);
	if(rf < 1) {free(l); return(rf);}
	 
	filesize=sizeof(CICONBLK)+2*4*32+2+sizeof(CICON)+
						16*32+4*32+sizeof(CICON)+2*4*32+17;

	l->iconblk=malloc(filesize);
	if(!l->iconblk) 
	{
		free(l);
		return(-1);
	}
	/* Adresse des letzten Zeigers */
	while(*ll)	{p=*ll; ll=&((*ll)->next);}
	*ll=l;
	if(p)	p->next=l;
	l->prev=p;
	l->next=NULL;
	
	
	Fread(fh, filesize, l->iconblk);
	adc=(long)l->iconblk+sizeof(CICONBLK);
	l->iconblk->monoblk.ib_pmask=(int*)adc;
	adc=(long)l->iconblk+sizeof(CICONBLK)+4*32;
	l->iconblk->monoblk.ib_pdata=(int*)adc;
	adc=(long)l->iconblk+sizeof(CICONBLK)+2*4*32;
	l->iconblk->monoblk.ib_ptext=(char*)adc;
	
	adc=(long)l->iconblk+sizeof(CICONBLK)+2*4*32+2;
	l->iconblk->mainlist=(CICON*)adc;
		
	adc=(long)l->iconblk+sizeof(CICONBLK)+2*4*32+2+sizeof(CICON);
	l->iconblk->mainlist->col_data=(int*)adc;
	adc=(long)l->iconblk+sizeof(CICONBLK)+2*4*32+2+sizeof(CICON)+16*32;
	l->iconblk->mainlist->col_mask=(int*)adc;
	adc=(long)l->iconblk+sizeof(CICONBLK)+2*4*32+2+sizeof(CICON)+16*32+4*32;
	l->iconblk->mainlist->next_res=(CICON*)adc;
	adc=(long)l->iconblk+filesize-17-2*4*32;
	l->iconblk->mainlist->next_res->col_data=(int*)adc;
	adc=(long)l->iconblk+filesize-17-4*32;
	l->iconblk->mainlist->next_res->col_mask=(int*)adc;

	l->name=(char*)l->iconblk+filesize-17;
	return(1);
}

int modules_in_list(char *path, MODULE_LIST *ml)
{/* FÅllt den Listenzeiger des Gruppenzeigers aus
		Sind keine Module vorhanden kommt 0, bei Speichermangel -1,
		sonst 1 zurÅck */
	char	opath[256], tpath[256], spath[256];
	DTA		*old=Fgetdta(), dta;	
	int		num=0, rf;
	long	l, fh;
	
	/* Pfad merken */
	strcpy(opath, path);
	l=strlen(opath)-1;
	while(opath[l] != '\\')--l;
	opath[l+1]=0;
	strcpy(tpath, opath);
	strcat(tpath, "*.*");	
	strcpy(spath, tpath);
	Fsetdta(&dta);
	
	if(!Fsfirst(spath, 0))
	{
		do
		{	
			strcpy(tpath, opath);
			strcat(tpath, dta.d_fname);
			fh=Fopen(tpath, FO_READ);
			if(fh > 0)
			{
				rf=cat_module(tpath, (int)fh, ml);
				if(rf == -1)
				{
					Fclose((int)fh);
					return(-1);
				}
				else if(rf == 1)
					++num;
				Fclose((int)fh);
			}
		}while(!Fsnext());
	}
	Fsetdta(old);
	return(num);
}

int cat_module(char *path, int fh, MODULE_LIST *ml)
{/*  fh=Handle der bereits geîffneten Modul-Datei.
		 Die Funktion hÑngt die Infos an die Modulliste an 
		 Gibt 0 zurÅck, wenn die Datei kein Modul ist
		 Gibt -1 bei Speichermangel zurÅck 
		 sonst 1*/
	
	MODULES	*l, **ll=&(ml->mlist), *p=NULL;
	MODULEBLK	*mb;
	uchar		*base;
	long	filesize;
		
	filesize=Fseek(0,fh,2);
	Fseek(0,fh,0);
	
	base=malloc(filesize);
	if(!base) return(-1);
	
	Fread(fh, filesize, base);
	mb=find_mod_magic(base, filesize);
	if(!mb)
	{
		free(base);
		return(0);
	}

	/* Adresse des letzten Zeigers */
	while(*ll)	{p=*ll; ll=&((*ll)->next);}
	*ll=l=(MODULES*)malloc(sizeof(MODULES));
	if(!l)
	{
		free(base);
		return(-1);
	}

	if(p)	p->next=l;
	l->prev=p;
	l->next=NULL;
	
	strcpy(l->path,path);
	l->popblock=*mb;

	l->base=NULL;
	l->mblock=NULL;
	l->dial_win=NULL;
	
	free(base);
	return(1);
}

void delete_modules(void)
{/* Speicher fÅr Modullisten freigeben */
	MODULE_LIST	*l=first_module, *ml;
	MODULES			*ll, *mll;
	
	close_all_modules();
	
	/* Modullisten */
	while(l)
	{
		ll=l->mlist;
		while(ll)
		{
			mll=ll;
			ll=ll->next;
			free(mll);
		}
		free(l->iconblk);
		ml=l;
		l=l->next;
		free(ml);
	}
	
	first_module=NULL;
	
	/* Objekte */
	if(omodule)
	{
		free(omodule[2].ob_spec.tedinfo);
		free(omodule);
		omodule=NULL;
	}
}

int	count_module_list(void)
{
	MODULE_LIST	*l=first_module;
	int	n=0;
	
	while(l)
	{
		++n;
		l=l->next;
	}
	return(n);
}

MODULE_LIST *find_module_list(int num)
{ /* Liefert Zeiger auf num-tes Modullisten-Element */
  /* ZÑhlung beginnt bei Null */
	/* Falls Element nicht existiert, wird NULL geliefert */
	
  MODULE_LIST	*l=first_module;
  
  while(num && l)
  {
  	--num;
  	l=l->next;
  }
  return(l);
}

void init_module(void)
{
	MODULE_LIST	*l;
	static unsigned int my_mask[128];
	int num=mod_len, a, ix;
	long	al,bl,cl;
	
	for(a=0; a < 128; ++a)
		my_mask[a]=0xffff;
		
	omodule[0].ob_tail=num*2;
	omodule[0].ob_height=32*num;

	l=find_module_list(mod_off);
	for(a=0; a < num; ++a)
	{
		/* Icon */
		ix=a*2+1;
		omodule[ix].ob_next=ix+1;
		omodule[ix].ob_head=omodule[ix].ob_tail=-1;
		omodule[ix].ob_flags=TOUCHEXIT;
		(CICONBLK*)omodule[ix].ob_spec.iconblk=l->iconblk;
		/* Text */
		ix=a*2+2;
		omodule[ix].ob_next=ix+1;
		omodule[ix].ob_head=omodule[ix].ob_tail=-1;
		omodule[ix].ob_flags=0x400|TOUCHEXIT;
		omodule[ix].ob_spec.tedinfo->te_ptext=l->name;
		omodule[ix].ob_spec.tedinfo->te_ptmplt=l->name;
		omodule[ix].ob_spec.tedinfo->te_pvalid=l->name;
		
		l=l->next;
	}	
	
	omodule[num*2].ob_next=0;
	omodule[num*2].ob_flags|=LASTOB;

	/* Slider anpassen */
	al=mod_len;
	al*=1000;
	bl=count_module_list();
	cl=al/bl;
	wmodule.vsiz=(int)cl;

	al=mod_off;
	al*=1000;
	bl=count_module_list()-mod_len;
	if(bl)
		cl=al/bl;
	else
		cl=0;
	wmodule.vpos=(int)cl;

	w_set(&wmodule, VSLIDE);
}

void	modlist_closed(WINDOW *win)
{
	w_close(win);
	w_kill(win);
}

void show_modules(void)
{
	if(!wmodule.open)
	{
		if(!omodule)
		{/* Es gibt keine */
			form_alert(1,"[3][Grape:|Es wurden keine Module|gefunden.][Abbruch]");
			return;
		}
		/* Fenster initialisieren */
		wmodule.dinfo=&dmodule;
		dmodule.tree=omodule;

		w_kdial(&wmodule, D_CENTER, MOVE|NAME|BACKDROP|CLOSE|UPARROW|DNARROW|VSLIDE|SIZE);
		wmodule.arrowed=module_arrowed;
		wmodule.vslid=module_vslid;
		wmodule.sized=module_sized;

		wmodule.closed=modlist_closed;
		wmodule.name="[Grape] Module";
		wmodule.vpos=1; wmodule.vsiz=1000;
		w_set(&wmodule, NAME|VSLIDE);
		fix_mod_size();
		w_open(&wmodule);
	}
	else
		w_top(&wmodule);
}

void close_all_modules(void)
{
	MODULE_LIST *ml=first_module;
	MODULES	*m;
	
	while(ml)
	{
		m=ml->mlist;
		while(m)
		{
			if(m->dial_win)
				close_mod_dial(m->dial_win);				
			m=m->next;
		}
		ml=ml->next;
	}
}

void fix_mod_size(void)
{ /* Modul-Fenstergrîûe nach Laden anpassen */
	long a,b,c;
	
	if(wmodule.wy+wmodule.wh <= sy+sh)
		return;
	
	/* Hîhe Ñndern */
	while(wmodule.wh > sh)
	{
		wmodule.wh-=omodule[1].ob_height;
		set_ext_type(omodule, 0, mod_len-1);
	}
		
	/* Y anpassen */
	if(wmodule.wy+wmodule.wh > sy+sh)
		wmodule.wy=sy+sh-wmodule.wh;

	/* Slider anpassen */
	a=mod_len;
	a*=1000;
	b=count_module_list();
	c=a/b;
	wmodule.vsiz=(int)c;
	
	w_set(&wmodule, VSLIDE|CURR);
}

void dial_module(int ob)
{
	MODULE_LIST *ml;
	int					l_ob;
	
	/* Geklickte Liste berechnen */
	l_ob=ob=(ob-1)/2; /* Icon+Text = 2 Objekte pro Eintrag */
	ob+=mod_off;

	ml=find_module_list(ob);
	if(ml)
	{
		l_ob*=2;
		omodule[l_ob+1].ob_state|=SELECTED;
		omodule[l_ob+2].ob_state|=SELECTED;
		w_objc_draw(&wmodule, l_ob+1, 8, sx, sy, sw, sh);
		w_objc_draw(&wmodule, l_ob+2, 8, sx, sy, sw, sh);
		module_select(ml);
		omodule[l_ob+1].ob_state&=(~SELECTED);
		omodule[l_ob+2].ob_state&=(~SELECTED);
		w_objc_draw(&wmodule, l_ob+1, 8, sx, sy, sw, sh);
		w_objc_draw(&wmodule, l_ob+2, 8, sx, sy, sw, sh);
	}
}

void module_select(MODULE_LIST *ml)
{/* Erzeugt Popup fÅr die in ml enthaltenen Module und erlaubt
		Auswahl */
		
	OBJECT	*poproot;
	MODULES	*m=ml->mlist;
	char		*texts;
	int			num=0, maxname=0, nl, sel, x, y;
	
	graf_mkstate(&x, &y, &sel, &sel);
	
	while(m)
	{
		++num;
		nl=(int)strlen(m->popblock.name);
		if((omodopt[MOPT2].ob_state & SELECTED)||(m->popblock.tree)) nl+=3;
		if(nl > maxname) maxname=nl;
		m=m->next;
	}
	if(!num)
	{
		form_alert(1,"[3][Grape:|Zu dieser Kategorie wurden|keine Module gefunden.][Abbruch]");
		return;
	}
	
	poproot=(OBJECT*)malloc((1+num*2)*sizeof(OBJECT)+(maxname+2)*num);
	if(!poproot)
	{
		form_alert(1,"[3][Grape:|Nicht genug Speicher fÅr|das Modul-Popup!][Abbruch]");
		return;
	}
	texts=(char*)(&(poproot[1+num*2]));
	make_mod_pop(poproot, texts, ml, num, maxname);
	sel=form_popup(poproot, x, y);
	if(sel > 0)
		start_module(ml, (sel-1)/2);
	free(poproot);
}

void make_mod_pop(OBJECT *root, char *texts, MODULE_LIST *ml, int num, int maxname)
{
	OBJECT	*omaskpop;
	MODULES	*l;
	int	a, ix;

	++maxname;
	
	xrsrc_gaddr(0, MASKPOP, &omaskpop, xrsrc);
	
	root[0].ob_next=-1;
	root[0].ob_head=1;
	root[0].ob_tail=num*2;
	root[0].ob_type=G_BOX;
	root[0].ob_flags=omaskpop[0].ob_flags; /* 3D */
	root[0].ob_state=omaskpop[0].ob_state;
	root[0].ob_spec.obspec=omaskpop[0].ob_spec.obspec;
	root[0].ob_x=root[0].ob_y=0;
	root[0].ob_height=16*num;
	root[0].ob_width=8*maxname+16;

	l=ml->mlist;

	for(a=0; a < num; ++a)
	{
		/* Icon */
		ix=a*2+1;
		root[ix].ob_next=ix+1;
		root[ix].ob_head=root[ix].ob_tail=-1;
		root[ix].ob_type=G_CICON;
		root[ix].ob_flags=NONE;
		root[ix].ob_state=NORMAL;
		(CICONBLK*)root[ix].ob_spec.iconblk=&(l->popblock._16x16);
		((CICONBLK*)(root[ix].ob_spec.iconblk))->monoblk.ib_pmask=
			l->popblock.mono_mask;
		((CICONBLK*)(root[ix].ob_spec.iconblk))->monoblk.ib_pdata=
			l->popblock.mono_data;
		((CICONBLK*)(root[ix].ob_spec.iconblk))->monoblk.ib_ptext=
			l->popblock.mono_text;
		((CICONBLK*)(root[ix].ob_spec.iconblk))->mainlist=
			&(l->popblock.cicon);
		((CICONBLK*)(root[ix].ob_spec.iconblk))->mainlist->col_data=
			l->popblock.col_data;
		((CICONBLK*)(root[ix].ob_spec.iconblk))->mainlist->col_mask=
			l->popblock.col_mask;
		((CICONBLK*)(root[ix].ob_spec.iconblk))->mainlist->sel_data=
		((CICONBLK*)(root[ix].ob_spec.iconblk))->mainlist->sel_mask=
			NULL;
		((CICONBLK*)(root[ix].ob_spec.iconblk))->mainlist->next_res=
			NULL;
		root[ix].ob_x=0;
		root[ix].ob_y=16*a;
		root[ix].ob_width=root[ix].ob_height=16;
		
		/* Text */
		ix=a*2+2;
		root[ix].ob_next=ix+1;
		root[ix].ob_head=root[ix].ob_tail=-1;
		root[ix].ob_type=G_STRING;
		root[ix].ob_flags=SELECTABLE;
		root[ix].ob_state=NORMAL;
		strcpy(texts, l->popblock.name);
		if((omodopt[MOPT2].ob_state & SELECTED)||(l->popblock.tree))
			strcat(texts, "...");
		root[ix].ob_spec.free_string=texts;
		texts+=maxname+2;
		root[ix].ob_x=16;
		root[ix].ob_y=16*a;
		root[ix].ob_width=8*maxname;
		root[ix].ob_height=16;
	
		l=l->next;
	}	
	
	root[num*2].ob_next=0;
	root[num*2].ob_flags|=LASTOB;

}

void start_module(MODULE_LIST *ml, int num)
{ /* Startet das Modul Nummer ml aus Liste num 
			ZÑhlung beginnt bei 0 */

	MODULES	*m=ml->mlist;
	
	while(num && m)
	{
		--num;
		m=m->next;
	}
	
	/* num noch nicht auf 0 gezÑhlt oder Nullzeiger dabei 
		rausgekommen? */
	if(num || (!m)) return;

	run_module(m);	
}

void run_module(MODULES *m)
{/* Modul starten */
	MODULEBLK	*mblock;
	BASPAG	*base;

	if(m->base==NULL)
	{/* Noch nicht geladen->laden und starten */
		fetch_module(m);	/* Ruft wieder run_module auf */
		return;
	}

	/* Modul ist schon im Speicher */
	mblock=m->mblock;
	base=m->base;

	if(m->dial_win)/* Modul ist schon aktiv->Fenster toppen */
	{
		w_top(m->dial_win);
		return;
	}
	
	if(mblock->tree)
	{
		if(!open_mod_dial(m))
		{
			form_alert(1,"[3][Nicht genug Speicher, um|den Moduldialog zu îffnen!][Abbruch]");
			if(!(omodopt[MORES].ob_state & SELECTED))
			{
				if(mblock->mod_fn->mod_quit)
					mblock->mod_fn->mod_quit();
				m->base=NULL;
				Mfree(base);
			}
		}
		else
		if(mblock->flags & 1)	/* "Do after init" gesetzt */
			if(mblock->mod_fn->do_function1)
				do_mod_func(mblock);
	}
	else
	{/* Kein Dialog->Modul sofort ausfÅhren oder Ersatzdialog îffnen */
		if(omodopt[MOPT1].ob_state & SELECTED)
		{/* Sofort ausfÅhren */
			if(mblock->mod_fn->mod_init)
				mblock->mod_fn->mod_init();
			if(mblock->mod_fn->do_function1)
				do_mod_func(mblock);
			if(!(omodopt[MORES].ob_state & SELECTED))
			{
				if(mblock->mod_fn->mod_quit)
					mblock->mod_fn->mod_quit();
				m->base=NULL;
				Mfree(base);
			}
			return;
		}
		/* Dialog anlegen */
		if(!open_dum_mod_dial(m))
		{
			form_alert(1,"[3][Nicht genug Speicher, um|den Moduldialog zu îffnen!][Abbruch]");
			if(!(omodopt[MORES].ob_state & SELECTED))
			{
				if(mblock->mod_fn->mod_quit)
					mblock->mod_fn->mod_quit();
				m->base=NULL;
				Mfree(base);
			}
		}
	}
}

void fetch_module(MODULES *m)
{/* Modul von Disk nachladen */
	BASPAG	*base;
	MODULEBLK	*mblock;
	long			len;

	base=load_module(m->path, &len);
	if(!base)
	{
		form_alert(1,"[3][Grape:|Modul konnte nicht geladen|werden.][Abbruch]");
		return;
	}
	m->base=base;
	mblock=find_mod_magic((uchar*)base, len);
	if(!mblock)
	{
		Mfree(base);
		m->base=NULL;
		form_alert(1,"[3][Grape:|Das ist kein Modul!][Abbruch]");
		return;
	}
	m->mblock=mblock;
	m->obfixed=0;
	init_block(m);
	
	run_module(m);
}

int open_dum_mod_dial(MODULES *m)
{/* Ersatzdialog fÅr Tree-lose Module anlegen */
	/* RÅckgabe: 1=ok, d.h. Dialog geîffnet
							 0=Problem (kein Speicher)
	*/
	WINDOW *win;
	DINFO	 *dinf;
	OBJECT *tree, *par;
	TEDINFO *tedinf;
	CICONBLK *cblk;
	CICON		*cicon;
	char	 *titel, *text, *m1;
	int			a=0;
	long		siz;
	
	xrsrc_gaddr(0,DIRECTMOD, &par, xrsrc);	/* Vorlage holen */
	while(!(par[a].ob_flags & LASTOB)) ++a;
	++a;
	win=m->dial_win;
	if(win)
	{ /* Fenster existiert bereits */
		w_top(win);
		return(1);
	}
	siz=sizeof(WINDOW)+sizeof(DINFO)+a*sizeof(OBJECT)+sizeof(TEDINFO)+	
			sizeof(CICONBLK)+sizeof(CICON)+32+20;
	
	m1=malloc(siz);
	if(!m1)	return(0);

	win=(WINDOW*)m1; m1+=sizeof(WINDOW);
	dinf=(DINFO*)m1; m1+=sizeof(DINFO);
	tree=(OBJECT*)m1; m1+=a*sizeof(OBJECT);
	tedinf=(TEDINFO*)m1; m1+=sizeof(TEDINFO);
	cblk=(CICONBLK*)m1; m1+=sizeof(CICONBLK);
	cicon=(CICON*)m1; m1+=sizeof(CICON);
	text=m1; m1+=32;
	titel=m1;
	
	/* Tree initialisieren */
	a=-1;
	do
	{	++a; tree[a]=par[a];}
	while(!(par[a].ob_flags & LASTOB));

	*tedinf=*(par[DUMNAME].ob_spec.tedinfo);
	tedinf->te_ptext=text;
	m1=m->popblock.name;
	/* FÅhrende Leerzeichen aus Modulname entfernen */
	while(*m1 && (*m1==' '))++m1;
	strcpy(text, m1);
	tree[DUMNAME].ob_spec.tedinfo=tedinf;
	tree[DUMNAME].ob_y=(tree[DUMDO].ob_y-tree[DUMNAME].ob_height)/2;
	if(strlen(text) < 23) /* Groûschrift benutzen */
		tedinf->te_font=3;
	*cblk=*((CICONBLK*)par[DUMICON].ob_spec.iconblk);
	cblk->monoblk.ib_pmask=m->popblock.mono_mask;
	cblk->monoblk.ib_pdata=m->popblock.mono_data;
	cblk->monoblk.ib_ptext=m->popblock.mono_text; /* Ist immer '0' */
	cblk->mainlist=cicon;
	cicon->num_planes=((CICONBLK*)par[DUMICON].ob_spec.iconblk)->mainlist->num_planes;
	cicon->col_data=m->popblock.col_data;
	cicon->col_mask=m->popblock.col_mask;
	cicon->sel_data=cicon->sel_mask=NULL;
	cicon->next_res=NULL;
	(CICONBLK*)tree[DUMICON].ob_spec.iconblk=cblk;
	
	m->dial_win=win;
	
	dinf->tree=tree;
	dinf->support=0;
	dinf->dservice=NULL;
	dinf->osmax=0;
	dinf->odmax=8;
	/* Fenster initialisieren */
	w_dinit(win);

	win->dinfo=dinf;
	if(!w_kdial(win, D_CENTER, MOVE|NAME|BACKDROP|CLOSE))
	{/* Kann kein Fenster mehr îffnen */
		form_alert(1,"[3][Grape:|Es sind keine Fenster mehr|verfÅgbar!][Abbruch]");
		m->dial_win=NULL;
		free(m1);
		return(0);
	}
	dinf->dwservice=my_service;
	win->topped=top_mod_dial;
	win->ontop=ontop_mod_dial;
	win->closed=close_mod_dial;

	strcpy(titel, "[Grape]");
	win->name=titel;
	w_set(win, NAME);
	w_open(win);

	(long)(win->user)=m->mblock->id;
	prev_func=m->mblock->mod_fn->do_function2;
	update_preview();	
	return(1);
}

int open_mod_dial(MODULES *m)
{
	/* RÅckgabe: 1=ok, d.h. Dialog geîffnet
							 0=Problem (kein Speicher)
	*/
	WINDOW *win;
	DINFO	 *dinf;
	char	 *titel;
	
	win=m->dial_win;
	if(win)
	{ /* Fenster existiert bereits */
		w_top(win);
		return(1);
	}
		
	win=(WINDOW*)malloc(sizeof(WINDOW));
	dinf=(DINFO*)malloc(sizeof(DINFO));
	titel=(char*)malloc(40);
	
	if((!dinf)||(!win)||(!titel))
	{
		if(titel) free(titel);
		if(dinf) free(dinf);
		if(win) free(win);
		return(0);
	}
	m->dial_win=win;
	
	dinf->tree=m->mblock->tree;
	dinf->support=0;
	dinf->dservice=NULL;
	dinf->osmax=0;
	dinf->odmax=8;
	/* Fenster initialisieren */
	w_dinit(win);

	win->dinfo=dinf;
	if(!w_kdial(win, D_CENTER, MOVE|NAME|BACKDROP|CLOSE))
	{/* Kann kein Fenster mehr îffnen */
		form_alert(1,"[3][Grape:|Es sind keine Fenster mehr|verfÅgbar!][Abbruch]");
		m->dial_win=NULL;
		free(titel);
		free(dinf);
		free(win);
		return(0);
	}
	dinf->dwservice=adapt_service;
	win->topped=top_mod_dial;
	win->ontop=ontop_mod_dial;
	win->closed=close_mod_dial;

	strcpy(titel, "[Grape]");
	strcat(titel, m->popblock.name);
	win->name=titel;
	w_set(win, NAME);
	w_open(win);

	(long)(win->user)=m->mblock->id;
	prev_func=m->mblock->mod_fn->do_function2;

	update_preview();	
	return(1);
}

int mod_usdef_mem(OBJECT *tree, int ob)
{/* Weist tree[ob] Speicher fÅr den Userblock (U_OB) und, falls
		typ=3 oder 4 fÅr die cmy-Ebenen und die Tabelle zu.
		return: 1=Fehler: Kein Speicher, Objekt wird dann auf invisible gesetzt
						0=Ok
 */
	int w, a;
	long siz, offs, opar;
	/* Meine Zeichenfunktion setzen */
	tree[ob].ob_spec.userblk->ub_code=user_ob;
	/* Alten Parameter merken */
	opar=tree[ob]_UP_;
	if((tree[ob]_UP_=(long)malloc(sizeof(U_OB)))==0)
	{
		tree[ob].ob_flags|=HIDETREE;	/* Kein Speicher->invisible */
		return(1);
	}
	((U_OB*)(tree[ob]_UP_))->type=(int)opar;

	if((opar!=3)&&(opar!=4)) /* Kein CMY-Zock->Fertig */
		return(0);
		
	/* Gesamtbedarf berechnen */
	w=((U_OB*)(tree[ob]_UP_))->color.w=((tree[ob].ob_width/16)+1)*16;
	siz=(long)w*(long)tree[ob].ob_height*3+(long)tree[ob].ob_height*(long)sizeof(long);
	offs=(long)w*(long)tree[ob].ob_height; /* Offset zwischen den Blîcken */
	
	((U_OB*)(tree[ob]_UP_))->color.r=(unsigned char*)malloc(siz);
	if(((U_OB*)(tree[ob]_UP_))->color.r==NULL)
	{/* Kein Speicher */
		free((void*)tree[ob]_UP_);
		tree[ob]_UP_=0;
		tree[ob].ob_flags|=HIDETREE;	/* Kein Speicher->invisible */
		return(1);
	}

	((U_OB*)(tree[ob]_UP_))->color.g=((U_OB*)(tree[ob]_UP_))->color.r+offs;
	((U_OB*)(tree[ob]_UP_))->color.b=((U_OB*)(tree[ob]_UP_))->color.g+offs;
	((U_OB*)(tree[ob]_UP_))->color.table_offset=(long*)(((U_OB*)(tree[ob]_UP_))->color.b+offs);
	for(a=0; a < tree[ob].ob_height; ++a)
		((U_OB*)(tree[ob]_UP_))->color.table_offset[a]=(long)((long)w*(long)a);
	return(0);
}

int obfix(OBJECT *tree)
{
	/* Obfix fÅr Modul-RSC. Userdefs mit Para 1-4 werden als
		 Grape-Userdefs bearbeitet, d.h. Speicher fÅr Zeugs alloziert
		 und meine Zeichenfunktion eingesetzt 
		 Return: 0=alles ok
		 				 1=Kein Speicher bei irgendeinem Userdef->invisible
	*/
#define NO_TEXT 0x800
		 
	int ob=0, fault=0;
	do
	{
		rsrc_obfix(tree, ob);

		if( ((tree[ob].ob_type & 255) == G_CICON) &&
				(tree[ob].ob_state & NO_TEXT))
			((CICONBLK*)(tree[ob].ob_spec.iconblk))->monoblk.ib_wtext=0;
		else if((tree[ob].ob_type & 255) == G_USERDEF)
		{
			if((tree[ob]_UP_ > 0) && (tree[ob]_UP_ < 5))
			{
				fault|=mod_usdef_mem(tree, ob);
			}
		}

	}while(!(tree[ob++].ob_flags & LASTOB));

	return(fault);
}

void mod_usdef_free(OBJECT *tree)
{/* PrÅft, ob Grape innerhalb des Trees Speicher fÅr Userdefs
		alloziert hat und gibt diesen ggf. frei */
		
	int ob=0;
	
	do
	{
		if((tree[ob].ob_type & 255) == G_USERDEF)
		{
			if(tree[ob].ob_spec.userblk->ub_code==user_ob)
			{
				if(tree[ob]_UP_)
				{
					/* color.r ist die Adresse des kompletten Blocks fÅr rgb&tab
						es reicht also diesen zu prÅfen und freizugeben */
					if(((U_OB*)(tree[ob]_UP_))->color.r)
						free(((U_OB*)(tree[ob]_UP_))->color.r);
					free((void*)tree[ob]_UP_);
				}
			}
		}
	}while(!(tree[ob++].ob_flags & LASTOB));
}

void top_mod_dial(WINDOW *win)
{
	MODULES *m=find_module_id((int)((long)(win->user)));
	if(m)
	{
		if(prev_func!= m->mblock->mod_fn->do_function2)
		{
			prev_func=m->mblock->mod_fn->do_function2;
			update_preview();
		}
	}
	topped(win);
}

void ontop_mod_dial(WINDOW *win)
{
	MODULES *m=find_module_id((int)((long)(win->user)));
	if(m)
	{
		if(prev_func!= m->mblock->mod_fn->do_function2)
		{
			prev_func=m->mblock->mod_fn->do_function2;
			update_preview();
		}
	}
}

void close_mod_dial(WINDOW *win)
{
	if(omodopt[MORES].ob_state & SELECTED)
		close_module((int)((long)(win->user)));
	else
		term_module((int)((long)(win->user)));
}

void close_module(int id)
{/* Modul beendet, nur angelegtes Fenster etc. aus dem Speicher raus */
	MODULES *m=find_module_id(id);
	if(m && m->base)
	{
		if(m->dial_win)
		{
			if(!(m->mblock->tree))
			{/* Ich hab Fenstername und Dinfo angelegt */
				free(m->dial_win->name);
				free(m->dial_win->dinfo);
			}
			w_close(m->dial_win);
			w_kill(m->dial_win);
			free(m->dial_win); /* Bei Dummy-Dial Modulen wurde alles am 
														StÅck alloziert, angefangen bei dial_win */
			m->dial_win=NULL;
		}
	}
	prev_func=NULL;
	update_preview();
}

void cdecl term_module(int id)
{/* Modul beendet, komplett aus dem Speicher entfernen */
	MODULES *m=find_module_id(id);
	if(m && m->base)
	{
		if(m->mblock->mod_fn->mod_quit)
			m->mblock->mod_fn->mod_quit();
		free(m->base);
		m->base=NULL;
		if(m->dial_win)
		{
			if(!(m->mblock->tree))
			{/* Ich hab Fenstername und Dinfo angelegt */
				free(m->dial_win->name);
				free(m->dial_win->dinfo);
			}
			else
				mod_usdef_free(m->mblock->tree);
			w_close(m->dial_win);
			w_kill(m->dial_win);
			free(m->dial_win); /* Bei Dummy-Dial Modulen wurde alles am 
														StÅck alloziert, angefangen bei dial_win */
			m->dial_win=NULL;
		}
		m->mblock=NULL;
	}
	prev_func=NULL;
	update_preview();
}

void cdecl do_module(int id)
{/* MIt dieser Funktion ruft sich das Modul selbst auf */
	MODULES *m=find_module_id(id);
	
	if(m && m->base)
		do_mod_func(m->mblock);
}

MODULES *find_module_id(int id)
{
	MODULE_LIST *ml=first_module;
	MODULES	*m;
	
	while(ml)
	{
		m=ml->mlist;
		while(m)
		{
			if(m->mblock)
			{
				if(m->mblock->id == id)
					return(m);
			}
			m=m->next;
		}
		ml=ml->next;
	}
	return(NULL);
}

void adapt_service(WINDOW *win, int ob)
{/* Serviceroutine fÅr Dialogfenster, die auf cdecl des Moduls adaptiert */
	MODULES *m=find_module_id((int)((long)(win->user)));
	OBJECT 	*tree;

	if(m==NULL) return;	/* Komisch, nicht gefunden */
	/* Vielleicht ein Color-Userdef? */
	tree=m->mblock->tree;
	if((ob > 0) && ((tree[ob].ob_type & 255) == G_USERDEF))
	{
		if(tree[ob].ob_spec.userblk->ub_code==user_ob)
			if(tree[ob]_UP_ && (((U_OB*)(tree[ob]_UP_))->type==3))
				if(((U_OB*)(tree[ob]_UP_))->color.r)
				{
					color_dd(tree,ob);
					return;
				}
	}
	m->mblock->dservice(ob);
}

void	my_service(WINDOW *win, int ob)
{/* Serviceroutine fÅr Dialogfenster die von mir angelegt wurden */
	MODULES 		*m=find_module_id((int)((long)(win->user)));
	
	if(m==NULL) return;	/* Komisch, nicht gefunden */
	
	if(ob!=DUMDO) return; /* Alles andere interessiert mich nicht */
	
	/* AusfÅhren */
	do_mod_func(m->mblock);
	w_unsel(win, ob);
}

void do_mod_func(MODULEBLK *mblock)
{/* Zentrale Aufrufroutine fÅr Modulfunktion,
		wird Åber do_module vom Modul selbst aufgerufen
		und bei run_module fÅr Direktaufrufmodule */
		
	GRECT area;
	MASK	*m;
	LAYER	*l;
	
	/* Zieldaten vorhanden? */
	if((main_win.id < 0) || (!first_lay))
		return;
		
	/* Bereich bestimmen */
	if((sel_tool != SSELECT) || (!frame_data.ok))
	{ /* Ganzen Bereich selektieren */
		area.g_x=area.g_y=0;
		area.g_w=first_lay->this.width;
		area.g_h=first_lay->this.height;
	}
	else
	{
		area.g_x=frame_data.x;
		area.g_y=frame_data.y;
		area.g_w=frame_data.w;
		area.g_h=frame_data.h;
	}

	/* Ziel bestimmen */
	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{
		l=&(first_lay->this);
		m=&(act_mask->this);
	}
	else
	{
		l=&(act_lay->this);
		m=NULL;
	}

	graf_mouse(BUSYBEE, NULL);
	busy(ON);
	
	if(mblock->mod_fn->do_function1(&area, l, m))
	{
		actize_win_name();
		area_redraw(area.g_x, area.g_y, area.g_w, area.g_h);
		if(m)
			mask_changed(act_mask);
		else
			layer_changed(act_lay);
	}
	busy(OFF);
	graf_mouse(ARROW, NULL);
}

void init_block(MODULES *m)
{
	m->mblock->global=_GemParBlk.global;
	m->mblock->gpfn=&grape_mod_info;
	m->mblock->id=module_id++;
	if(!(m->obfixed))
	{
		if(obfix(m->mblock->tree)==1)
			form_alert(1,"[1][Grape:|Mangels Speicher kann der Modul-|Dialog nicht vollstÑndig dargestellt|werden.][Aha]");
		m->obfixed=1;
	}
	if(m->mblock->mod_fn->mod_init)
		m->mblock->mod_fn->mod_init();
}

MODULEBLK *find_mod_magic(uchar *mem, long len)
{
	do
	{
		if(*mem=='G')
		{
			if(!strncmp((char*)mem, "GRAPEMODULE", 11))
				return((MODULEBLK*)mem);
		}
		++mem;
		--len;
	}while(len);
	return(NULL);
}

BASPAG *oload_module(char *path, long *rlen)
{
	BASPAG *base;
	long	 fhl, mem_size;
	uchar	*clear;
	
	fhl=Pexec(3,path, "", 0l);
	if(fhl < 0) return(NULL);
	base=(BASPAG*)fhl;
	
	/* Grîûe im Speicher berechnen */
	mem_size=sizeof(BASPAG);				/* Basepage */
	mem_size+=base->p_tlen;	/* Text-Segment */
	mem_size+=base->p_dlen;	/* Data-Segment */
	mem_size+=base->p_blen;	/* BSS-Segment */
	Mshrink(0, base, mem_size);
	base->p_hitpa=(void*)((long)base+mem_size);
	/* BSS lîschen */
	clear=(uchar*)(base->p_bbase);
	fhl=base->p_blen;
	while(fhl--) *clear++=0;
	
	*rlen=mem_size;	
	return(base);
}

BASPAG *load_module(char *path, long *rlen)
{
	PH			prghead;
	BASPAG	*base;
	uchar		*clear;
	long		fhl, len, mem_size;
	int			fh;
	
	fhl=Fopen(path, FO_READ);
	if(fhl < 0) return(NULL);
	fh=(int)fhl;
	len=Fseek(0, fh, 2);
	Fseek(0,fh,0);
	/* Header laden */
	Fread(fh, sizeof(PH), &prghead);
 	/* Magic korrekt? */
  if(prghead.ph_branch != 0x601a){Fclose(fh); return(NULL);}
	/* Basepage erzeugen */
	fhl=Pexec(5,0l, "", 0l);
	if(fhl < 0) {Fclose(fh); return(NULL);}
	base=(BASPAG*)fhl;
	/* Body laden */
	Fread(fh, len-sizeof(PH), (uchar*)base+sizeof(BASPAG));
	Fclose(fh);
	
	/* Relozieren */	
	relocate(&prghead, base);
	
	/* Grîûe im Speicher berechnen */
	mem_size=len-sizeof(PH);				/* Reine Programmgrîûe */
	mem_size+=sizeof(BASPAG);				/* Basepage */
	mem_size+=base->p_blen;	/* BSS-Segment */
	Mshrink(0, base, mem_size);
	base->p_hitpa=(void*)((long)base+mem_size);
	
	/* BSS lîschen */
	clear=(uchar*)(base->p_bbase);
	fhl=base->p_blen;
	while(fhl--) *clear++=0;
	
	*rlen=mem_size;	
	return(base);
}

void relocate(PH *prghead, BASPAG *base)
{
	typedef struct
	{
		long	offset;
		uchar	info[];
	}RELOCINFO;

	RELOCINFO	*reloc;
	long			*toreloc;
	uchar			*info;
		
	/* Zeiger eintragen */
	base->p_tbase=(void*)((long)base+sizeof(BASPAG));
	base->p_dbase=(void*)((long)base->p_tbase+prghead->ph_tlen);
	base->p_bbase=(void*)((long)base->p_dbase+prghead->ph_dlen);
	base->p_tlen=prghead->ph_tlen;
	base->p_dlen=prghead->ph_dlen;
	base->p_blen=prghead->ph_blen;
	base->p_dta=(DTA*)&(base->p_cmdlin);
	
	/* Relozieren */
	reloc=(RELOCINFO*)base->p_bbase;
	toreloc=(long*)((long)base->p_tbase+reloc->offset);
	info=reloc->info;
	*toreloc+=(long)base->p_tbase;
	while(*info)
	{
		uchar	offset;
		offset=*info++;
		if(offset == 1)
			toreloc=(long*)((long)toreloc+254l);
		else
		{	
			toreloc=(long*)((long)toreloc+(long)offset);
			*toreloc+=(long)base->p_tbase;
		}
	}
}

void module_arrowed(WINDOW *win, int	*pbuf)
{
	int r=0, a;
	
	switch(pbuf[4])
	{
		case WA_UPLINE:
			if(mod_off)
			{
				set_ext_type(omodule, 1, mod_off-1);
				r=1;
			}
		break;
		case WA_DNLINE:
			if(mod_off < (count_module_list()-mod_len))
			{
				set_ext_type(omodule, 1, mod_off+1);
				r=1;
			}
		break;
		
		case WA_UPPAGE:
			if(mod_off)
			{
				a=mod_off-mod_len;
				if(a < 0)
					a=0;
				set_ext_type(omodule,1,a);
				r=1;
			}
		break;
		case WA_DNPAGE:
			if(mod_off < count_module_list()-mod_len)
			{
				set_ext_type(omodule, 1, mod_off+mod_len);
				if(mod_off > count_module_list()-mod_len)
					set_ext_type(omodule, 1, count_module_list()-mod_len);
				r=1;
			}
		break;
	}
	
	if(r)
	{
		init_module();
		s_redraw(win);
	}
}

void module_vslid(WINDOW *win, int	*pbuf)
{
	long	l;
	
	l=pbuf[4];
	l*=(long)((long)count_module_list()-(long)mod_len);
	l/=1000l;
	
	if(l != mod_off)
	{
		set_ext_type(omodule, 1, (int)l);
		init_module();
		s_redraw(win);
	}
}

void module_sized(WINDOW *win, int	*pbuf)
{
	int	a, r=0;
	
	/* Aktuelle Hîhe bestimmen */
	w_get(win);
	set_ext_type(omodule, 0, win->ah/omodule[1].ob_height);
	
	/* Neue Grîûe berechnen */
	wind_calc(WC_WORK, win->kind, pbuf[4], pbuf[5], pbuf[6], pbuf[7], &pbuf[4], &pbuf[5], &pbuf[6], &pbuf[7]);
	a=pbuf[7]/omodule[1].ob_height;
	
	if(a < 1) a=1;
	if(a > count_module_list()) a=count_module_list();
	
	if(pbuf[6] > omodule[0].ob_width+2) pbuf[6]=omodule[0].ob_width+2;
	if(pbuf[6] < omodule[1].ob_width) pbuf[6]=omodule[1].ob_width;

	if((a != mod_len) || (pbuf[6] != win->aw))
	{
		w_calc(win);
		win->ah=omodule[1].ob_height*a;
		win->aw=pbuf[6];
		w_wcalc(win);
		w_set(win, CURR);

		if(a <= mod_len)
		{ /* Kleiner->auf Redraw verzichten */
			set_ext_type(omodule, 0, a);
			init_module();
		}
		else
		{ /* Grîûer->evtl. pos. etc. neu setzen */
			set_ext_type(omodule, 0, a);
			if(mod_off+mod_len > count_module_list())
			{
				set_ext_type(omodule, 1, count_module_list()-mod_len);
				r=1;
			}
			init_module();
			if(r)
				s_redraw(win);
		}

	}
}



/* Moduloptionen */

void modopt_window(void)
{
	if(!wmodopt.open)
	{
		/* Alte Einstellung merken */
		memo_abbruch(omodopt);
		
		/* Fenster initialisieren */
		wmodopt.dinfo=&dmodopt;
		w_dial(&wmodopt, D_CENTER);
		wmodopt.name="[Grape] Modul-Optionen";
		w_set(&wmodopt, NAME);
		w_open(&wmodopt);
	}
	else
		w_top(&wmodopt);
}

void dial_modopt(int ob)
{
	switch(ob)
	{
		case MOLOAD:
			if(form_alert(1,"[2][Grape:|Sollen alle Module neu|geladen werden?][OK|Abbruch]")==2)
				return;
			graf_mouse(BUSYBEE, NULL);
			if(wmodule.open)
				wmodule.closed(&wmodule);
			close_all_modules();
			scan_modules();
			close_all_fio_win();
			scan_fio_modules();
			w_unsel(&wmodopt, ob);
			graf_mouse(ARROW, NULL);
		break;
		case MOABBRUCH:
			recall_abbruch(omodopt);
		case MOOK:
			w_unsel(&wmodopt, ob);
			w_close(&wmodopt);
			w_kill(&wmodopt);
		break;
	}
}

/* Diverse Routinen fÅr die Module */

void cdecl d_unsel(int id, int ob)
{
	MODULES *m=find_module_id(id);
	if(m)
		w_unsel(m->dial_win, ob);
}

void cdecl d_objc_draw(int id, int ob)
{
	MODULES *m=find_module_id(id);
	if(m)
		w_objc_draw(m->dial_win, ob, 8, sx, sy, sw, sh);
}

void	cdecl modslide(int id, int ob, int min, int max, int now, void cdecl(*newval)(int now2))
{/* dir ist X oder Y, min und max sind min und max Werte (z.B.1,10)*/
 /* now ist der jetzige Wert (z.B.3), width ist die Breite/Hîhe*/
 /* des Parents abzÅglich des Sliders und dann noch die Funktion, */
 /* die einen neuen Wert bearbeitet */
	int		mx,my,ms,mk, mx2, my2, off, now2, width, dir;
	float	ps;
	OBJECT *tree;
	MODULES	*m=find_module_id(id);
	
	if(!m) return;
	tree=m->dial_win->dinfo->tree;
	
	if(tree[ob-1].ob_width == tree[ob].ob_width)
	{
		dir=Y;
		width=tree[ob-1].ob_height-tree[ob].ob_height;
	}
	else
	{
		dir=X;
		width=tree[ob-1].ob_width-tree[ob].ob_width;
	}
		
	if(width)
	{
		graf_mouse(FLAT_HAND,NULL);
		graf_mkstate(&mx,&my,&ms,&mk);
		ps=(float)((float)width/(float)((float)max-(float)min));
		if (dir == X)
			off=(int)((float)((float)mx-(float)ps*(float)now));
		else if (dir == Y)
			off=(int)((float)((float)my-(float)ps*(float)now));
		now2=now;
	
		while(ms & 1)
		{
			graf_mkstate(&mx2,&my2,&ms,&mk);
			if ((dir == X) && (mx2 != mx))
			{/* Ausrechnen, ob auch rel-pos neu ist */
				mx=mx2;
				mx=mx-off;
				now2=(int)((float)((float)mx/(float)ps))+min;
			}
			else if ((dir == Y) && (my2 != my))
			{/* Ausrechnen, ob auch rel-pos neu ist */
				my=my2;
				my=my-off;
				now2=(int)((float)((float)my/(float)ps))+min;
			}
			if (now2 < min)
				now2=min;
			if (now2 > max)
				now2=max;
			if (now2 != now)
			{
				now=now2-min;
				if(dir == X)
					tree[ob].ob_x=(int)((float)((float)now*(float)ps));
				else
					tree[ob].ob_y=(int)((float)((float)now*(float)ps));
				w_objc_draw(m->dial_win, ob-1, 2, sx, sy, sw, sh);
				newval(now2);
				if(omodopt[POPT1].ob_state & SELECTED)
					update_preview();
				now=now2;
			}
		}
		graf_mouse(ARROW,NULL);
		if(omodopt[POPT2].ob_state & SELECTED)
			update_preview();
	}
}

void	cdecl modbar(int id, int ob, int min, int max, void cdecl(*newval)(int now2))
{/* Berechnet den Wert fÅr einen Direkt-Klick in den Slider */
 /* Setzt den Slider (als Objektnummer wird das erste Child des */
 /* Bars angenommen) und macht mit slide() weiter */
 
 int	width, dif, mx, my, ox, oy, dum, val;
 float	ps, vl;
 	OBJECT *tree;
	MODULES	*m=find_module_id(id);
	
	if(!m) return;
	tree=m->dial_win->dinfo->tree;
	

 	graf_mkstate(&mx, &my, &dum, &dum);
 	objc_offset(tree, ob, &ox, &oy);
 	mx-=ox; my-=oy;
 	mx-=tree[ob+1].ob_width/2;
 	my-=tree[ob+1].ob_height/2;
 	if(mx < 0) mx=0;
 	if(my < 0) my=0;
 	
	if(tree[ob].ob_width == tree[ob+1].ob_width)
	{
		width=tree[ob].ob_height-tree[ob+1].ob_height;
		if(my > width) my=width;
		/* Slider setzen */
		val=tree[ob+1].ob_y=my;
	}
	else
	{
		width=tree[ob].ob_width-tree[ob+1].ob_width;
		if(mx > width) mx=width;
		/* Slider setzen */
		val=tree[ob+1].ob_x=mx;
	}
	
	w_objc_draw(m->dial_win, ob, 8, sx, sy, sw, sh);

	/* Position berechnen */
	dif=max-min;
	
	/* Wert berechnen */
	ps=(float)((float)dif/(float)width);
	vl=ps*(float)val; val=(int)vl+min;
	if(val > max) val=max;
	newval(val);
	if(omodopt[POPT1].ob_state & SELECTED)
		update_preview();
	
	modslide(id, ob+1, min, max, val, newval);
}

void	cdecl	mod_set_slide(int id, int ob, int min, int max, int val)
{/* Setzt den Slider, dessen Parent ob-1 sein muû, auf Pos. fÅr val */
	long	p, max_val=max-min;
	OBJECT *tree;
	MODULES	*m=find_module_id(id);
	
	if(!m) return;
	tree=m->dial_win->dinfo->tree;
	
	if(tree[ob-1].ob_width == tree[ob].ob_width)
	{
		p=tree[ob-1].ob_height-tree[ob].ob_height;
		p*=(long)val;							/* max_ob_x * val */
		p/=max_val;								/* max_ob_x*val/(max_val)=ob_x */
		tree[ob].ob_y=(int)p;
	}
	else
	{
		p=tree[ob-1].ob_width-tree[ob].ob_width;
		p*=(long)val;							/* max_ob_x * val */
		p/=max_val;								/* max_ob_x*val/(max_val)=ob_x */
		tree[ob].ob_x=(int)p;
	}
	
	w_objc_draw(m->dial_win, ob-1, 8, sx,sy,sw,sh);
}

int cdecl mod_get_prev_opt(void)
{/* Gibt die Einstellung fÅr Previewaktualisierung zurÅck */
	/* 0=immer, 1=loslassen, 2=nie */
	if(omodopt[POPT1].ob_state & SELECTED)
		return(0);
	if(omodopt[POPT2].ob_state & SELECTED)
		return(1);
	return(2);
}

void	cdecl set_pal_col(int index, int cmy[3])
{
	set_pal_cols(index, index, cmy);
}

void	cdecl	set_pal_cols(int start_index, int end_index, int *cmy_values)
{
	int a;
	
	if(start_index < 0) start_index=0;
	if(end_index >259) end_index=259;
	if(start_index>end_index) start_index=end_index;
	for(a=start_index; a<=end_index; ++a)
	{
		fill_colpal_ob(COL1+a, cmy_values[1], cmy_values[2], cmy_values[0]);
		cmy_values+=3;
		if(wcolpal.open)
			w_objc_draw(&wcolpal, COL1+a, 8, sx,sy,sw,sh);
	}
}

void	cdecl	get_pal_col(int index, int *cmy3)
{
	get_pal_cols(index, index, cmy3);
}

void	cdecl	get_pal_cols(int start_index, int end_index, int *cmy_values)
{
	int a;
	
	if(start_index < 0) start_index=0;
	if(end_index >259) end_index=259;
	if(start_index>end_index) start_index=end_index;
	for(a=start_index; a<=end_index; ++a)
	{
		*cmy_values++=((U_OB*)(ocolpal[COL1+a]_UP_))->color.b[0];
		*cmy_values++=((U_OB*)(ocolpal[COL1+a]_UP_))->color.r[0];
		*cmy_values++=((U_OB*)(ocolpal[COL1+a]_UP_))->color.g[0];
	}
}
