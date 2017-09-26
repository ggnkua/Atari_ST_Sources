#include <ec_gem.h>
#include <atarierr.h>
#include "io.h"
#include "ioglobal.h"

/* -------------------------------------- */

int load_grouplist(void)
{/* -1=Kein Speicher, 0=Keine Liste, 1=Ok */
	char path[256], *c;
	long	fhl;
	int		fh;
	
	if(grp_inf.oaddr) free(grp_inf.oaddr);
	if(grp_inf.flds) free(grp_inf.flds);
	grp_inf.oaddr=grp_inf.addr=NULL;
	grp_inf.flds=NULL; 
	grp_inf.oaddr_c=grp_inf.addr_c=grp_inf.flds_c=0; 
	grp_inf.changes=0;
	if(get_groups(&(grp_inf.flds), &(grp_inf.flds_c))==-1) return(-1);
	strcpy(path, db_path);
	strcat(path, "\\GRPLIST.TXT");
	fhl=Fopen(path, FO_READ);
	if(fhl < 0)
	{
		if(fhl != EFILNF) gemdos_alert(gettext(GRPOPEN_ERR), fhl);
		return(0);
	}
	fh=(int)fhl;
	fhl=Fseek(0, fh, 2);
	Fseek(0,fh,0);
	c=malloc(2*(fhl+1));
	if(c==NULL)
	{
		form_alert(1, gettext(NO_GRPMEM));
		Fclose(fh);
		return(-1);
	}
	grp_inf.oaddr=c;
	Fread(fh, fhl, c);
	Fclose(fh);
	c[fhl]=0;
	grp_inf.addr=&(c[fhl+1]);
	strcpy(grp_inf.addr, grp_inf.oaddr);
	grp_inf.addr_c=0;
	while(*c)
	{
		++grp_inf.addr_c;
		while(*c&&(*c!=13)&&(*c!=10))++c;
		while(*c&&((*c==13)||(*c==10)))++c;
	}
	grp_inf.oaddr_c=grp_inf.addr_c;
	return(1);
}

/* -------------------------------------- */

void save_grouplist(void)
{
	char path[256];
	long	fhl;
	int		fh;
	
	strcpy(path, db_path);
	strcat(path, "\\GRPLIST.TXT");
	if((grp_inf.oaddr==NULL) || (grp_inf.oaddr_c==0)) return;
	fhl=Fcreate(path, 0);
	if(fhl < 0)
	{
		gemdos_alert(gettext(GRPMAKE_ERR), fhl);
		return;
	}
	fh=(int)fhl;
	Fwrite(fh, strlen(grp_inf.oaddr), grp_inf.oaddr);
	Fclose(fh);
	grp_inf.changes=0;
}

/* -------------------------------------- */

char *get_group_name(long ix)
{/* Gibt Leerstring zurck, wenn der Name nicht existiert! */
	static char name[65];
	char	*c, *d, mem;

	name[0]=0; name[64]=0;
	
	c=grp_inf.addr;
	if(c) while(ix)
	{
		while((*c)&&(*c!=13)&&(*c!=10))++c;
		if(*c==0) break;
		while(*c&&((*c==13)||(*c==10)))++c;
		if(*c==0) break;
		--ix;
	}
	if((c==NULL)||(*c==0)) return(name);
	d=c;
	while((*c)&&(*c!=13)&&(*c!=10))++c;
	mem=*c; *c=0;
	strncpy(name, d, 64);
	*c=mem;
	name[0]|=32;
	return(name);
}

/* -------------------------------------- */

void grp_init_inf(void)
{
	grp_inf.offset=0;
	if(grp_inf.oaddr)
		strcpy(grp_inf.addr, grp_inf.oaddr);
	else grp_inf.addr=NULL;
	grp_inf.addr_c=grp_inf.oaddr_c;
}

/* -------------------------------------- */

void grp_toggle(long a)
{
	char *c, *d, *e, mem, newstate;
	
	if((grp_inf.addr==NULL)||(grp_inf.addr_c==0)) return;
	c=grp_inf.addr;
	grp_inf.changes=1;
	while(a)
	{
		while((*c)&&(*c!=13)&&(*c!=10))++c;
		if(*c==0) break;
		while(*c&&((*c==13)||(*c==10)))++c;
		if(*c==0) break;
		--a;
	}
	if(*c==0) return;
	if(*c & 32)
		newstate=*c & (~32);
	else
		newstate= *c | 32;
	/* Jetzt noch im Original „ndern */
	d=c;
	while(*c&&(*c!=13)&&(*c!=10))++c;
	mem=*c; *c=0;
	e=strstr(grp_inf.oaddr, d);
	*c=mem;
	if(e==NULL) return; /* Seltsam seltsam */
	*d=newstate;
	*e=newstate;
}

/* -------------------------------------- */

long make_group(char *name)
{/* return: >=0 = erzeugte Gruppennummer, -1=Fehler aufgetreten */
	long	free_num=0, fhl;
	char	path[256], bpath[256];
	int		fh;
	DTA		*old=Fgetdta(), dta;

	strcpy(bpath, db_path);
	strcat(bpath, "\\OM\\");
	strcpy(path, bpath);
	strcat(path, "*.*");
	/* Freie Nummer finden */
	Fsetdta(&dta);
	if(!Fsfirst(path, 0))	do
	{
		if(atol(dta.d_fname) >= free_num)
			free_num=atol(dta.d_fname)+1;
	}while(!Fsnext());
	Fsetdta(old);

	strcpy(path, bpath);
	ltoa(free_num, &(path[strlen(path)]), 10);

	if(Dsetpath(path) < 0)
	{
		fhl=Dcreate(path);
		if(fhl < 0)
		{
			gemdos_alert("Kann Gruppe nicht anlegen.", fhl);
			return(-1);
		}
	}
	strcpy(bpath, path);
	strcat(path, ".GRP");
	fhl=Fcreate(path, 0);
	if(fhl < 0)
	{
		gemdos_alert("Kann Gruppendatei nicht anlegen.", fhl);
		Ddelete(bpath);
		return(-1);
	}
	fh=(int)fhl;
	Fwrite(fh, 66, name);
	Fclose(fh);
	return(free_num);
}

/* -------------------------------------- */

void grp_set_dial(void)
{
	long	a;
	long	t, l;
	char *c, *d, *e;
	
	/* Slider setzen */

	/* Ggf. Listenoffset korrigieren */
	l=(GRPLAST-GRP1)/2+1;	/* Sichtbare Zeilen */
	if(grp_inf.offset+l > grp_inf.addr_c)	grp_inf.offset=grp_inf.addr_c-l;
	if(grp_inf.offset < 0) 	grp_inf.offset=0;
	
	a=grp_inf.offset;
	
	if(grp_inf.addr_c <= l)
	{
		ogroup[GRPSLIDE].ob_y=0;
		ogroup[GRPSLIDE].ob_height=ogroup[GRPBAR].ob_height;
		goto _grp_text;
	}
	
	/* Slidergr”že */
	t=(long)grp_inf.addr_c*(long)(ogroup[GRP1].ob_height);	/* Gesamte Liste in Pixeln */
	ogroup[GRPSLIDE].ob_height=(int)( ((long)ogroup[GRPBAR].ob_height*(long)(l*(long)ogroup[GRP1].ob_height))/t);
	if(ogroup[GRPSLIDE].ob_height < ogroup[GRPSLIDE].ob_width)
		ogroup[GRPSLIDE].ob_height=ogroup[GRPSLIDE].ob_width;
	
	/* Sliderpos. */
	ogroup[GRPSLIDE].ob_y=(int)(
				((long)(ogroup[GRPBAR].ob_height-ogroup[GRPSLIDE].ob_height)*
				 (long)(grp_inf.offset)) 
				 / 
				 (grp_inf.addr_c-l));

_grp_text:
	/* Strings setzen */
	t=a;
	c=grp_inf.addr;
	if(c) while(t)
	{
		while((*c)&&(*c!=13)&&(*c!=10))++c;
		if(*c==0) break;
		while(*c&&((*c==13)||(*c==10)))++c;
		if(*c==0) break;
		--t;
	}
	while((a < grp_inf.addr_c) && (a-grp_inf.offset <= (GRPLAST-GRP1)/2))
	{
		strncpy(e=ogroup[GRP1+(a-grp_inf.offset)*2].ob_spec.tedinfo->te_ptext, c, 64);
		e[64]=0;
		if(!(*e & 32)) *e|=32;
		if((d=strchr(e, 13))!=NULL) *d=0;
		if((d=strchr(e, 10))!=NULL) *d=0;
		ogroup[IGRP1+(a-grp_inf.offset)*2].ob_flags &= (~HIDETREE);
		if(sw_mode)
		{
			ogroup[IGRP1+(a-grp_inf.offset)*2].ob_type=G_ICON;
			if(*c & 32)
				ogroup[IGRP1+(a-grp_inf.offset)*2].ob_spec.iconblk=ovorl[GRP_SW_UNSEL].ob_spec.iconblk;
			else
				ogroup[IGRP1+(a-grp_inf.offset)*2].ob_spec.iconblk=ovorl[GRP_SW_SEL].ob_spec.iconblk;
		}
		else
		{
			ogroup[IGRP1+(a-grp_inf.offset)*2].ob_spec.iconblk=ovorl[GRP_ABO].ob_spec.iconblk;
			if(*c & 32)
				ogroup[IGRP1+(a-grp_inf.offset)*2].ob_state &= (~SELECTED);
			else
				ogroup[IGRP1+(a-grp_inf.offset)*2].ob_state |= SELECTED;
		}
		++a;
		while(*c && (*c!=13)&&(*c!=10))++c;
		while(*c && ((*c==13)||(*c==10)))++c;
	}
	while(a-grp_inf.offset <= (GRPLAST-GRP1)/2)
	{
		ogroup[GRP1+(a-grp_inf.offset)*2].ob_spec.tedinfo->te_ptext[0]=0;
		ogroup[GRP1+(a-grp_inf.offset)*2].ob_state &= (~SELECTED);
		ogroup[IGRP1+(a-grp_inf.offset)*2].ob_flags |= HIDETREE;
		++a;
	}
}

/* -------------------------------------- */

void grp_closed(WINDOW *win)
{
	if(grp_inf.changes)
		save_grouplist();
	w_close(win);
	w_kill(win);
}


void draw_grpframe(void)
{
	w_objc_draw(&wgroup, GRPFRAME, 8, sx,sy,sw,sh);
	w_objc_draw(&wgroup, GRPBAR, 8, sx,sy,sw,sh);
	w_objc_draw(&wgroup, GRPTITEL, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void grp_autoloc(int key, int swt)
{/* key/swt wird ignoriert, aužer beide 0, dann wird autoloc
		auch ausgefhrt, wenn sich nichts an der Eingabe ge„ndert hat*/
	long	ix, f_c, d_c, s_c;
	char	*c, *d, *e, *src, mem, mem2;
	static char buf[66];
	

	if((grp_inf.oaddr==NULL)||(grp_inf.oaddr_c==0)) return;

	if(key || swt)
	{
		/* Žnderungen am Namen? */
		if(!stricmp(buf, ogroup[GRPNAME].ob_spec.tedinfo->te_ptext)) return;
	}

	strcpy(buf, ogroup[GRPNAME].ob_spec.tedinfo->te_ptext);
	strlwr(buf);

	if((buf[0]==0) && (!(ogroup[GRP_ABOONLY].ob_state & SELECTED)))
	{
		strcpy(grp_inf.addr, grp_inf.oaddr);
		grp_inf.addr_c=grp_inf.oaddr_c;
		grp_set_dial();
		draw_grpframe();
		return;
	}

	graf_mouse(BUSYBEE, NULL);
	c=grp_inf.oaddr;
	e=grp_inf.addr;
	*e=0;
	ix=0;
	s_c=strlen(buf);
	while(*c)
	{
		d=c;
		while(*c&&(*c!=13)&&(*c!=10))++c;
		while(*c&&((*c==13)||(*c==10)))++c;
		if((!(*d & 32)) || (!(ogroup[GRP_ABOONLY].ob_state & SELECTED)))
		{/* Ist abonniert oder Anzeige auf alle */
			mem=*c; *c=0;
			mem2=*d; *d|=32;
			/* d=src_start, c=src_end, e=dst_start */
			/* stristr */
			f_c=0;
			src=d;
			d_c=strlen(d);
			while(d_c-- > 0)
			{
				if(buf[f_c]==*src++) ++f_c;
				else f_c=0;
				if(f_c==s_c)
				{/* found */
					strcpy(e, d);
					*e=mem2;
					e+=c-d;
					++ix;
					break;
				}
			}
			*d=mem2;
			*c=mem;
		}
	}
	graf_mouse(ARROW, NULL);
	grp_inf.addr_c=ix;
	grp_set_dial();
	draw_grpframe();
}

/* -------------------------------------- */

void	group_dial(void)
{
	if(wgroup.open)
	{
		w_top(&wgroup);
		return;
	}
	if((grp_inf.addr==NULL)||(grp_inf.addr_c==0))
	{
		load_grouplist();
		if((grp_inf.addr==NULL)||(grp_inf.addr_c==0))
		{
			form_alert(1, gettext(GRP_NOFILE));
			return;
		}
	}
	ogroup[GRPNAME].ob_spec.tedinfo->te_ptext[0]=0;
	ogroup[GRP_ABOONLY].ob_state &= (~SELECTED);

	grp_init_inf();
	grp_set_dial();
	wgroup.dinfo=&dgroup;
	w_kdial(&wgroup, D_CENTER, MOVE|NAME|BACKDROP|CLOSE);
	wgroup.closed=grp_closed;
	dgroup.dakeybd=grp_autoloc;
	/*wgroup.name="";
	w_set(&wgroup, NAME);*/
	dgroup.dedit=GRPNAME;
	w_open(&wgroup);
}

/* -------------------------------------- */

void slide_group(void)
{
	int		mb, my, oy=-1, miny, maxy, offy, dum;
	long	l, off;

	maxy=ogroup[GRPBAR].ob_height-ogroup[GRPSLIDE].ob_height;
	if(maxy==0) return;
	
	wind_update(BEG_MCTRL);
	graf_mouse(FLAT_HAND, NULL);

	objc_offset(ogroup, GRPSLIDE, &dum, &offy);
	graf_mkstate(&dum, &my, &dum, &dum);
	offy=my-offy;
	objc_offset(ogroup, GRPBAR, &dum, &miny);
	
	do
	{
		graf_mkstate(&dum, &my, &mb, &dum);
		my-=miny+offy;
		if(my < 0) my=0;
		if(my > maxy) my=maxy;
		if(my==oy) continue;	
		
		/* Neuen Offset ausrechnen */
		l=(IGRPLAST-IGRP1)/2+1;		/* Sichtbare Zeilen */
		off=(int)(((long)my*(grp_inf.addr_c-l))/(long)maxy);
		if(off!=grp_inf.offset)
		{
			grp_inf.offset=off;
			grp_set_dial();
			draw_grpframe();
		}	
	}while(mb & 3);
	
	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
}

/* -------------------------------------- */

void dial_group(int ob)
{
	long	a;
	int		dum, my, oy;
	
	switch(ob)
	{
		case GRPUP:
			a=grp_inf.offset-1;
		goto _new_grp_offset;
		case GRPDOWN:
			a=grp_inf.offset+1;
		goto _new_grp_offset;
		case GRPSLIDE:
			slide_group();
		break;
		case GRPBAR:
			graf_mkstate(&dum, &my, &dum, &dum);
			objc_offset(ogroup, GRPSLIDE, &dum, &oy);
			if(my < oy)
				a=grp_inf.offset-((GRPLAST-GRP1)/2+1);
			else
				a=grp_inf.offset+((GRPLAST-GRP1)/2+1);
		goto _new_grp_offset;
		
		case GRP_ABOONLY:
			grp_autoloc(0, 0);
		break;
	}

	if((ob >= IGRP1)&&(ob <= GRPLAST))
	{
		a=ob-IGRP1; a/=2; a+=grp_inf.offset;
		if(a >= grp_inf.addr_c) a=grp_inf.addr_c-1;
		grp_toggle(a);
		grp_set_dial();
		if((obj_type(ogroup, ob)==G_CICON)||(obj_type(ogroup, ob)==G_ICON))
			w_objc_draw(&wgroup, ob, 8, sx,sy,sw,sh);
		else
			w_objc_draw(&wgroup, ob-1, 8, sx,sy,sw,sh);
	}
	return;
	
_new_grp_offset:
	if(a+(GRPLAST-GRP1)/2+1 > grp_inf.addr_c)	a=grp_inf.addr_c-((GRPLAST-GRP1)/2+1);
	if(a < 0) a=0;
	if(a==grp_inf.offset) return;
	grp_inf.offset=a;
	grp_set_dial();
	draw_grpframe();
}
