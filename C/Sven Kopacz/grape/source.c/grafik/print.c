#include <grape_h.h>
#include "grape.h"
#include "print.h"
#include "new.h"
#include "layer.h"
#include "mask.h"
#include "xrsrc.h"
#include "scale.h"
#include "undo.h"
#include "main_win.h"
#include "timeshow.h"
/* 

Datei Drucken

*/

#define CBORDVAL 45
#define MBORDVAL 50
#define YBORDVAL 45

#define X 0
#define Y 1

/* Grîûe des bedruckbaren Bereichs in Pixeln */
int	print_w, print_h;

PLIST *pfirst;
OBJECT *plpop;

void printer_popup(void);

/* Fns aus new.c */
extern int mode_popup(OBJECT *tree, int ob);
extern int num_to_pix(long num, int mode, long dpi);
extern int ob_num_to_pix(OBJECT *tree, int v_ob, int m_ob, long dpi);
extern int pix_to_num(long num, int mode, long dpi);
extern int ob_pix_to_num(OBJECT *tree, int v_ob, int m_ob, long dpi, int n_mode);
extern void num_stretch(char *num, int len);


PLIST *act_printer(void)
{/* Liefert Listenzeiger auf aktuellen Drucker */
	int a;
	PLIST *pl=pfirst;
	
	a=oprint[PRPOP].ob_type >> 8;
	while(pl->id != a)
		pl=pl->next;
	return(pl);
}

int prn_dpi(int xy)
{
	PLIST *pl=act_printer();
	
	if(xy) /* Y */
		return(pl->v_res);
	/* X */
	return(pl->h_res);
}

int make_popup(int num)
{/* Bastelt Popup-Tree fÅr PLIST-EintrÑge
		num=Anzahl der Drucker
		Gibt 0 zurÅck, wenn nicht genug Speicher,
		1 wenn alles ok und -1 wenn num=0
	*/
	OBJECT *mpop;
	PLIST	*pl=pfirst;
	int		i;
	char	*troot;
	
	if(num==0) return(-1);

	/* Vorlage fÅr ob[0] */	
	xrsrc_gaddr(0, MODEPOP, &mpop, xrsrc);

	plpop=(OBJECT*)malloc((num+1)*sizeof(OBJECT));
	if(plpop==NULL) return(0);
	troot=(char*)malloc(num*40);
	if(troot==NULL)
	{free(plpop); return(0);}
	
	plpop[0].ob_next=-1;
	plpop[0].ob_head=1;
	plpop[0].ob_tail=num;
	plpop[0].ob_type=G_BOX;
	plpop[0].ob_flags=mpop[0].ob_flags;
	plpop[0].ob_state=mpop[0].ob_state;
	plpop[0].ob_spec=mpop[0].ob_spec;
	plpop[0].ob_x=plpop[0].ob_y=0;
	plpop[0].ob_width=oprint[PRPOP].ob_width;
	plpop[0].ob_height=oprint[PRPOP].ob_height*num;
	
	for(i=1; i <= num; ++i)
	{
		plpop[i].ob_next=i+1;
		plpop[i].ob_head=-1;
		plpop[i].ob_tail=-1;
		plpop[i].ob_type=G_STRING;
		plpop[i].ob_flags=mpop[1].ob_flags;
		plpop[i].ob_state=mpop[1].ob_state;
		plpop[i].ob_spec.free_string=troot;
		strcpy(troot, "  ");
		strncat(troot, pl->name, 36);
		troot[38]=0;
		troot+=40;
		plpop[i].ob_x=0;
		plpop[i].ob_y=mpop[1].ob_height*(i-1);
		plpop[i].ob_width=oprint[PRPOP].ob_width;
		plpop[i].ob_height=mpop[1].ob_height;
		pl=pl->next;
	}
	
	plpop[num].ob_next=0;
	plpop[num].ob_flags|=LASTOB;
	return(1);
}

void vq_ext_devinfo(int handle, int device, int *dev_exists, char *file_path, char *file_name, char *name)
{
	VDIPB v;
	
	_VDIParBlk.contrl[0]=248;
	_VDIParBlk.contrl[1]=0;
	_VDIParBlk.contrl[3]=7;
	_VDIParBlk.contrl[5]=4242;
	_VDIParBlk.contrl[6]=handle;
	_VDIParBlk.intin[0]=device;
	*(char**)(&(_VDIParBlk.intin[1]))=file_path;
	*(char**)(&(_VDIParBlk.intin[3]))=file_name;
	*(char**)(&(_VDIParBlk.intin[5]))=name;
	v.contrl=_VDIParBlk.contrl;
	v.intin=_VDIParBlk.intin;
	v.intout=_VDIParBlk.intout;
	v.ptsin=_VDIParBlk.ptsin;
	v.ptsout=_VDIParBlk.ptsout;
	vdi(&v);

	*dev_exists=_VDIParBlk.intout[0];
}



void print_block(int h, uchar *src, int lines, int xoff, int yoff)
{/* h=WOrkstationhandle, src=Source-Adresse, lines=Hîhe
	 (Breite immer first_lay->this.width)
	 xoff, yoff=Zieloffset
*/
	int		pxy[8];
	MFDB	s, d;
	
	s.fd_addr=src;
	s.fd_w=first_lay->this.width;
	s.fd_h=first_lay->this.height;
	s.fd_wdwidth=first_lay->this.word_width/16;
	s.fd_stand=0;
	s.fd_nplanes=32;
	d.fd_addr=NULL;
	pxy[0]=pxy[1]=0;
	pxy[2]=first_lay->this.width-1;
	pxy[3]=lines-1;
	pxy[4]=xoff;
	pxy[5]=yoff;
	pxy[6]=pxy[2]+xoff;
	pxy[7]=pxy[3]+yoff;
	vro_cpyfm(h,3,pxy,&s,&d); /* Invers 12 Normal 3 */
}


void	print_file(int xoff, int yoff)
{/* Offset in Pixeln */
	int							i, w_in[11], w_out[57], h, ldone=0, lines;
	long						siz, bufhi, bufsiz;
	register long		a,b;
	register uchar	*cy, *ma, *ye, *ds;

	if(first_lay==NULL) return;

  for ( i = 0; i < 10; i++ )
  {
    w_in[i]  = 1;
  }
  w_in[10] = 2;

 	w_in[0]=21;
	v_opnwk( w_in, &h, w_out);
	if(h==0)
	{
		form_alert(1,"[3][Grape:|Die Drucker-Workstation konnte|nicht geîffnet werden.][Abbruch]");
		return;
	}

	/* 400 K Druckerpuffer, bei Miûerfolg auf minimal 50K verkleinern */	
	bufsiz=200000l;
	ds=NULL;
	while((ds==NULL) && (bufsiz > 12000))
	{
		bufsiz/=2;
		bufhi=bufsiz/(long)(first_lay->this.word_width);
		siz=bufhi*(long)(first_lay->this.word_width);
		ds=(uchar*)Malloc(4*siz);
	}
	if(ds==NULL)
	{
		form_alert(1,"[3][Grape:|Nicht genug Speicher|fÅr Druckerpuffer.][Abbruch]");
		v_clswk(h);
		return;
	}
	
	cy=first_lay->this.blue;
	ma=first_lay->this.red;
	ye=first_lay->this.yellow;
	
	while(ldone < first_lay->this.height)
	{
		timeshow(ldone, first_lay->this.height);
		if(first_lay->this.height-ldone > bufhi)
		{
			b=siz*4;
			lines=(int)bufhi;
		}
		else
		{
			b=(long)((long)(first_lay->this.height-ldone)*(long)(first_lay->this.word_width))*4;
			lines=first_lay->this.height-ldone;
		}
		for(a=0; a < b; a+=4)
		{
			ds[a]=0;
			ds[a+1]=255-*cy++;
			ds[a+2]=255-*ma++;
			ds[a+3]=255-*ye++;
		}
		print_block(h, ds, lines,xoff,yoff+ldone);
		ldone+=lines;
	}
	timeoff();
	Mfree(ds);
	v_updwk(h);
	if(oprint[PRFF].ob_state & SELECTED)
		v_clrwk(h);
	v_clswk(h);
}

void free_printlist(void)
{
	PLIST *plp=pfirst, *pl;
	
	while(plp)
	{
		pl=plp->next;
		free(plp);
		plp=pl;
	}
}

int scan_printers(void)
{/* Baut Druckerliste auf, 
		gibt Anzahl der gefundenen Drucker zurÅck
		oder -1 falls Speichermangel 
		(Liste oder Popup kann nicht aufgebaut werden)
 */
	int	i,w_in[11], w_out[57],h, dum;
	char dumc[128], dn[80];
	int	printers=0;
	PLIST	**plp=&pfirst, *pl;
	
	*plp=NULL;
	
  for ( i = 0; i < 10; i++ )
  {
    w_in[i]  = 1;
  }
  w_in[10] = 2;

	/* Workstations 21-30 abklappern */
  for(i=21; i<31;++i)
  {
  	w_in[0]=i;
		v_opnwk( w_in, &h, w_out);
		if(h != 0)
		{/* Speicher fÅr neuen Listeneintrag */
			pl=*plp=(PLIST*)malloc(sizeof(PLIST));
			if(pl==NULL) 
			{/* Kein Speicher mehr */
				if(printers) /* Aber schon ein paar Drucker in Liste */
					free_printlist();
				form_alert(1,"[3][Grape:|Nicht genug Speicher, um|die GDOS-Drucker anzuzeigen.][Abbruch]");
				return(-1);
			}
			++printers;
			plp=&(pl->next);
			pl->next=NULL;
			pl->id=i;
			pl->width=w_out[0];
			pl->height=w_out[1];
			/*  w_out[13]=256 Farben,w_out[39]=0 mehr als 32000 Farbabstufungen*/
			vq_extnd(h, 1, w_out);
			/* w_out[1]=0 mehr als 32000 Farbstufen */
			pl->bit=w_out[4]; /* Sollte 32 sein */
			pl->h_res=w_out[23];
			pl->v_res=w_out[24];
			
			if(w_out[20] != 0) /* Angaben in 40-43 sind gÅltig */
			{
				pl->ro=w_out[40];
				pl->ru=w_out[41];
				pl->rl=w_out[42];
				pl->rr=w_out[43];
			}
			else
				pl->ro=pl->ru=pl->rl=pl->rr=0;

			vq_ext_devinfo(handle, i, &dum, dumc, dumc, dn);
			strncpy(pl->name, dn, 38);
			v_clswk(h);
		}
	}
	if(make_popup(printers)==0)
	{/* Kein Speicher mehr */
		if(printers) /* Aber schon ein paar Drucker in Liste */
			free_printlist();
		form_alert(1,"[3][Grape:|Nicht genug Speicher, um|die GDOS-Drucker anzuzeigen.][Abbruch]");
		return(-1);
	}

	return(printers);
}


/* Fensterroutinen */

void pr_used_size(int *nw, int *nh)
{ /* Die im Fenster ausgenutzte Breite/Hîhe fÅr das weiûe Blatt */
	int		 hw, hh;
	double h_zu_w;
	
	/* VerhÑltnis */
	h_zu_w=(double)print_h/(double)print_w;
	
	hw=oprint[PRPREVIEW].ob_width;
	hh=oprint[PRPREVIEW].ob_height;
	*nw=print_w;
	*nh=print_h;

	if(*nw > hw)
	{/* Zuviele Breiten-Pixel */
		*nw=hw;
		*nh=(int)((double)hw*h_zu_w);
	}
	if(*nh > hh)
	{/* Zuviele Hîhenpixel */
		*nh=hh;
		*nw=(int)((double)hh/h_zu_w);
	}
}

void pr_border_scale(int uw, int uh, int *l, int *r, int *o, int *u)
{
	double o_zu_s;
	
	if(uh > uw)
		o_zu_s=(double)print_h/(double)uh;
	else
		o_zu_s=(double)print_w/(double)uw;
	
	*l=(int)((double)*l/o_zu_s);
	*r=(int)((double)*r/o_zu_s);
	*o=(int)((double)*o/o_zu_s);
	*u=(int)((double)*u/o_zu_s);
}

void pr_same_scale(int uw, int uh, int *nw, int *nh, int *ofx, int *ofy)
{
	double o_zu_s;
	
	if(uh > uw)
		o_zu_s=(double)print_h/(double)uh;
	else
		o_zu_s=(double)print_w/(double)uw;
	
	*nw=(int)((double)first_lay->this.width/o_zu_s);
	*nh=(int)((double)first_lay->this.height/o_zu_s);
	*ofx=(int)((double)*ofx/o_zu_s);
	*ofy=(int)((double)*ofy/o_zu_s);
}

void fill_pr_preview(void)
{/* FÅllt das Preview-Feld im Print-Fenster */
	uchar	*sc, *sm, *sy;
	register int		x,y,w;
	register uchar	*dc, *dm, *dy;
	register long		doff;
	int			uw, uh, nw, nh, ofx, ofy, sox, soy, scw, sch, bo, bu, bl, br;
	PLIST		*pl=act_printer();
	
	pr_used_size(&uw, &uh);
	
	/* Inhalt komplett grau */	
	w=oprint[PRPREVIEW].ob_width;
	doff=(long)((U_OB*)(oprint[PRPREVIEW]_UP_))->color.w-w;
	dc=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.b;
	dm=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.r;
	dy=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.g;
	for(y=oprint[PRPREVIEW].ob_height; y > 0; --y)
	{
		for(x=w; x > 0; --x)
		{
			*dc++=128;*dm++=128;*dy++=128;
		}
		dc+=doff; dm+=doff; dy+=doff;
	}
	/* Neu-Bereich weiû */
	w=uw;
	doff=(long)((U_OB*)(oprint[PRPREVIEW]_UP_))->color.w-w;
	dc=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.b;
	dm=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.r;
	dy=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.g;
	for(y=uh; y > 0; --y)
	{
		for(x=w; x > 0; --x)
		{
			*dc++=0;*dm++=0;*dy++=0;
		}
		dc+=doff; dm+=doff; dy+=doff;
	}

	sox=ofx=ob_num_to_pix(oprint,PRXOFF,PRMODE,prn_dpi(X));
	if(sox < pl->rl)
		sox=ofx=pl->rl;
	soy=ofy=ob_num_to_pix(oprint,PRYOFF,PRMODE,prn_dpi(Y));
	if(soy < pl->ro)
		soy=ofy=pl->ro;
	/* Wieviel Platz nimmt Original bei gleicher Skalierung ein? */
	/* (Offsets gleich mit Skalieren) */
	pr_same_scale(uw, uh, &nw, &nh, &ofx, &ofy);
	/* Zugehîrige Originalmaûe bestimmen */
	scw=first_lay->this.width;
	sch=first_lay->this.height;
	/* Ergebnis einpassen */
	if(print_w > first_lay->this.width)
	{/* Breitenoffset gilt fÅr Reinsetzen in Dest */
		if(ofx > uw) /* Durch Offset rausverschoben */
			return;
		if(ofx+nw > uw)
			nw=uw-ofx;
		if(sox+scw > print_w)
			scw=print_w-sox;
		sox=0;
	}
	else
	{/* Breitenoffset gilt fÅr Holen aus Source */
		if(sox >= first_lay->this.width) /* Durch Offset rausverschoben */
			return;
		nw-=ofx;
		if(nw > uw)
			nw=uw;
		scw-=sox;
		if(scw > print_w)
			scw=print_w;
		ofx=0;
	}
	
	if(print_h > first_lay->this.height)
	{/* Hîhenoffset gilt fÅr Reinsetzen in Dest */
		if(ofy > uh) /* Durch Offset rausverschoben */
			return;
		if(ofy+nh > uh)
			nh=uh-ofy;
		if(soy+sch > print_h)
			sch=print_h-soy;
		soy=0;
	}
	else
	{/* Hîhenoffset gilt fÅr Holen aus Source */
		if(soy >= first_lay->this.height) /* Durch Offset rausverschoben */
			return;
		nh-=ofy;
		if(nh > uh)
			nh=uh;
		sch-=soy;
		if(sch > print_h)
			sch=print_h;
		ofy=0;
	}

	/* Quelladressen holen */
	dc=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.b;
	dm=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.r;
	dy=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.g;
	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{
		sc=sm=sy=act_mask->this.mask;
		if(!(mask_col_tab[act_mask->this.col] & 1))
			sm=NULL;
		if(!(mask_col_tab[act_mask->this.col] & 2))
			sy=NULL;
		if(!(mask_col_tab[act_mask->this.col] & 4))
			sc=NULL;
	}
	else
	{
		sc=act_lay->this.blue;
		sm=act_lay->this.red;
		sy=act_lay->this.yellow;
	}

	/* Reinsetz-Offset addieren */
	dc+=ofx; dm+=ofx; dy+=ofx;
	doff=(long)((long)((U_OB*)(oprint[PRPREVIEW]_UP_))->color.w*(long)ofy);
	dc+=doff; dm+=doff; dy+=doff;

	doff=(long)((U_OB*)(oprint[PRPREVIEW]_UP_))->color.w-oprint[PRPREVIEW].ob_width;
	doff+=oprint[PRPREVIEW].ob_width-nw;

	if(sc) simple_scale_one(sc, dc, scw, sch, nw, nh, 
							 doff, first_lay->this.word_width, sox, soy);
		
	if(sm) simple_scale_one(sm, dm, scw, sch, nw, nh, 
							 doff, first_lay->this.word_width, sox, soy);

	if(sy) simple_scale_one(sy, dy, scw, sch, nw, nh, 
							 doff, first_lay->this.word_width, sox, soy);

	/* Nicht bedruckbare RÑnder */
	pr_used_size(&uw, &uh);
	bl=pl->rl; br=pl->rr; bo=pl->ro; bu=pl->ru;
	pr_border_scale(uw, uh, &bl, &br, &bo, &bu);
	/* Oben */
	w=uw;
	doff=(long)((U_OB*)(oprint[PRPREVIEW]_UP_))->color.w-w;
	dc=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.b;
	dm=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.r;
	dy=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.g;
	for(y=bo; y > 0; --y)
	{	for(x=w; x > 0; --x){*dc++=CBORDVAL;*dm++=MBORDVAL;*dy++=YBORDVAL;}
		dc+=doff; dm+=doff; dy+=doff;}
	/* Unten */
	doff=(long)((U_OB*)(oprint[PRPREVIEW]_UP_))->color.w-w;
	dc=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.b;
	dm=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.r;
	dy=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.g;
	dc+=(doff+w)*(long)(uh-bu);dm+=(doff+w)*(long)(uh-bu);dy+=(doff+w)*(long)(uh-bu);
	for(y=bu; y > 0; --y)
	{	for(x=w; x > 0; --x){*dc++=CBORDVAL;*dm++=MBORDVAL;*dy++=YBORDVAL;}
		dc+=doff; dm+=doff; dy+=doff;}
	/* Links */
	doff=(long)((U_OB*)(oprint[PRPREVIEW]_UP_))->color.w-bl;
	dc=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.b;
	dm=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.r;
	dy=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.g;
	for(y=uh; y > 0; --y)
	{	for(x=bl; x > 0; --x){*dc++=CBORDVAL;*dm++=MBORDVAL;*dy++=YBORDVAL;}
		dc+=doff; dm+=doff; dy+=doff;}
	/* Rechts */
	doff=(long)((U_OB*)(oprint[PRPREVIEW]_UP_))->color.w-br;
	dc=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.b+uw-br;
	dm=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.r+uw-br;
	dy=((U_OB*)(oprint[PRPREVIEW]_UP_))->color.g+uw-br;
	for(y=uh; y > 0; --y)
	{	for(x=br; x > 0; --x){*dc++=CBORDVAL;*dm++=MBORDVAL;*dy++=YBORDVAL;}
		dc+=doff; dm+=doff; dy+=doff;}
}

void new_pr_preview(void)
{
	if(wprint.open)
	{
		fill_pr_preview();
		w_objc_draw(&wprint, PRPREVIEW, 8, sx, sy, sw, sh);
	}
}

void prchange_offset(int x, int y)
{/* x und y in Pixeln */
	PLIST *pl=act_printer();

	if(x < pl->rl) x=pl->rl;
	if(y < pl->ro) y=pl->ro;
	x=pix_to_num(x, oprint[PRMODE].ob_type >> 8, prn_dpi(X));
	y=pix_to_num(y, oprint[PRMODE].ob_type >> 8, prn_dpi(Y));
	itoa(x, oprint[PRXOFF].ob_spec.tedinfo->te_ptext, 10);
	num_stretch(oprint[PRXOFF].ob_spec.tedinfo->te_ptext, 5);
	itoa(y, oprint[PRYOFF].ob_spec.tedinfo->te_ptext, 10);
	num_stretch(oprint[PRYOFF].ob_spec.tedinfo->te_ptext, 5);
	w_objc_draw(&wprint, PRXOFF, 8, sx, sy, sw, sh);
	w_objc_draw(&wprint, PRYOFF, 8, sx, sy, sw, sh);
	new_pr_preview();
}

void prmove_offset(int x, int y)
{
	int ox, oy, scroll_val, mx, my;
	PLIST *pl=act_printer();
	
	mx=pix_to_num(pl->rl, oprint[PRMODE].ob_type >> 8, prn_dpi(X));
	my=pix_to_num(pl->ro, oprint[PRMODE].ob_type >> 8, prn_dpi(Y));

	if(artpad) /* Arrows per Wacom bedienen? */
		scroll_val=((int)asgc->pressure+20)/20;
	else
		scroll_val=1;
	ox=atoi(oprint[PRXOFF].ob_spec.tedinfo->te_ptext);
	oy=atoi(oprint[PRYOFF].ob_spec.tedinfo->te_ptext);
	x*=scroll_val;
	y*=scroll_val;
	x+=ox;
	y+=oy;
	if(x < mx) x=mx;
	if(y < my) y=my;
	if((x != ox) || (y != oy))
	{
		itoa(x, oprint[PRXOFF].ob_spec.tedinfo->te_ptext, 10);
		num_stretch(oprint[PRXOFF].ob_spec.tedinfo->te_ptext, 5);
		itoa(y, oprint[PRYOFF].ob_spec.tedinfo->te_ptext, 10);
		num_stretch(oprint[PRYOFF].ob_spec.tedinfo->te_ptext, 5);
		w_objc_draw(&wprint, PRXOFF, 8, sx, sy, sw, sh);
		w_objc_draw(&wprint, PRYOFF, 8, sx, sy, sw, sh);
		new_pr_preview();
	}
}

void dial_print(int ob)
{
	int a,x,y;
	int	ow=first_lay->this.width;
	int oh=first_lay->this.height;
	int	mov=oprint[PROF1].ob_state & SELECTED;
	PLIST *pl=act_printer();
	
	switch(ob)
	{
		case PRPOP:
			printer_popup();
		break;
		
		case PRMODE:
			a=mode_popup(oprint, PRMODE);
			if(a > 0)
			{
				x=ob_pix_to_num(oprint, PRXOFF, PRMODE, prn_dpi(X), a);
				y=ob_pix_to_num(oprint, PRYOFF, PRMODE, prn_dpi(Y), a);
				set_ext_type(oprint, PRMODE, a);
				itoa(x, oprint[PRXOFF].ob_spec.tedinfo->te_ptext, 10);
				itoa(y, oprint[PRYOFF].ob_spec.tedinfo->te_ptext, 10);
				num_stretch(oprint[PRXOFF].ob_spec.tedinfo->te_ptext, 5);
				num_stretch(oprint[PRYOFF].ob_spec.tedinfo->te_ptext, 5);
				w_objc_draw(&wprint, PRXOFF, 8, sx,sy,sw,sh);
				w_objc_draw(&wprint, PRYOFF, 8, sx,sy,sw,sh);				
				w_objc_draw(&wprint, PRMODE, 8, sx,sy,sw,sh);				
			}
		break;

		/* Offsetvorgaben */
		case PRLO:
			if(mov)	prmove_offset(-1,-1);
			else prchange_offset(pl->rl,pl->ro);
		break;
		case PRO:
			if(mov)	prmove_offset(0,-1);
			else prchange_offset(pl->rl+abs(ow-pl->width)/2, pl->ro);
		break;
		case PRRO:
			if(mov)	prmove_offset(1,-1);
			else prchange_offset(pl->rl+abs(ow-pl->width), pl->ro);
		break;
		case PRL:
			if(mov) prmove_offset(-1,0);
			else prchange_offset(pl->rl, pl->ro+abs(oh-pl->height)/2);
		break;
		case PRM:
			if(!mov)
				prchange_offset(pl->rl+abs(ow-pl->width)/2, pl->ro+abs(oh-pl->height)/2);
		break;
		case PRR:
			if(mov) prmove_offset(1,0);
			else prchange_offset(pl->rl+abs(ow-pl->width), pl->ro+abs(oh-pl->height)/2);
		break;
		case PRLU:
			if(mov) prmove_offset(-1,1);
			else prchange_offset(pl->rl, pl->ro+abs(oh-pl->height));
		break;
		case PRU:
			if(mov) prmove_offset(0,1);
			else prchange_offset(pl->rl+abs(ow-pl->width)/2, pl->ro+abs(oh-pl->height));
		break;
		case PRRU:
			if(mov) prmove_offset(1,1);
			else prchange_offset(pl->rl+abs(ow-pl->width), pl->ro+abs(oh-pl->height));
		break;
		
		
		
		/* Buttons */
		case PROK:
			print_file(ob_num_to_pix(oprint,PRXOFF,PRMODE,prn_dpi(X))-pl->rl,
									ob_num_to_pix(oprint,PRYOFF,PRMODE,prn_dpi(Y))-pl->ro);
		case PRABBRUCH:
			w_unsel(&wprint, ob);
			w_close(&wprint);
			w_kill(&wprint);
			free_printlist();
			free(plpop[1].ob_spec.free_string);
			free(plpop);
		break;
	}
}

void prprev_keybd(int key, int swt)
{
	key&=255;
	swt&=15;
 	if((key == 27) || (key == 8) || (key ==  127) ||
 			 ((key >= 48) && (key <= 57))
 		)
 		new_pr_preview();
}

void wp_init(PLIST *pl)
{
	/* öbernimmt Daten aus PLIST-Eintrag pl in Dialog */
	/* und baut Preview neu auf. KEIN Redraw! */
	int x,y;
	
	set_ext_type(oprint, PRPOP, pl->id);
	strcpy(oprint[PRPOP].ob_spec.free_string, pl->name);
	strcpy(oprint[PRXOFF].ob_spec.tedinfo->te_ptext, "00000");
	strcpy(oprint[PRYOFF].ob_spec.tedinfo->te_ptext, "00000");
	itoa(pl->h_res, oprint[PRHDPI].ob_spec.tedinfo->te_ptext, 10);
	itoa(pl->v_res, oprint[PRVDPI].ob_spec.tedinfo->te_ptext, 10);
	print_w=pl->width+pl->rl+pl->rr;
	print_h=pl->height+pl->ro+pl->ru;
	x=pix_to_num(pl->rl, oprint[PRMODE].ob_type >> 8, prn_dpi(X));
	y=pix_to_num(pl->ro, oprint[PRMODE].ob_type >> 8, prn_dpi(Y));
	itoa(x, oprint[PRXOFF].ob_spec.tedinfo->te_ptext, 10);
	num_stretch(oprint[PRXOFF].ob_spec.tedinfo->te_ptext, 5);
	itoa(y, oprint[PRYOFF].ob_spec.tedinfo->te_ptext, 10);
	num_stretch(oprint[PRYOFF].ob_spec.tedinfo->te_ptext, 5);
	fill_pr_preview();
}

void	print_window(void)
{/* ôffnet Dialog fÅr Drucken */
	
	oprint[PROF1].ob_state&=(~SELECTED);
	oprint[PROF2].ob_state|=SELECTED;
	
	if(!wprint.open)
	{
		/* Druckerliste aufbauen */
		if(scan_printers()==0)
		{
			form_alert(1,"[3][Grape:|Es sind keine GDOS-Drucker|installiert!][Abbruch]");
			return;
		}
		/* Fenster initialisieren */
		wp_init(pfirst);

		wprint.dinfo=&dprint;
		w_dial(&wprint, D_CENTER);
		wprint.name="[Grape]";
		w_set(&wprint, NAME);
		dprint.dakeybd=prprev_keybd;
		w_open(&wprint);
	}
	else
		w_top(&wprint);
}

void printer_popup(void)
{/* ôffnet das Printer-Popup an x/y von oprint[PRPOP] */
    
	int 	x,y,a,b;
	PLIST *pl=pfirst;
	
	a=oprint[PRPOP].ob_type >> 8;
	b=1;
	while(pl->id != a)
	{
		++b;
		pl=pl->next;
	}
		
	a=0;
	do
	{
		++a;
		plpop[a].ob_state &= (~CHECKED);
	}while(!(plpop[a].ob_flags & LASTOB));
	plpop[b].ob_state |= CHECKED;
	
	objc_offset(oprint, PRPOP, &x, &y);
	y-=(b-1)*plpop[1].ob_height;
	if(y < sy) y=sy;
	if(y+plpop[0].ob_height > sy+sh)
		y=sy+sh-plpop[0].ob_height;
	if(x < sx) x=sx;
	if(x+plpop[0].ob_width > sx+sw)
		x=sx+sw-plpop[0].ob_width;
	a=form_popup(plpop, x, y);
	if(a > 0)
	{
		pl=pfirst;
		while(--a)
			pl=pl->next;
		wp_init(pl);
		s_redraw(&wprint);
	}
}
