#include <grape_h.h>
#include "grape.h"
#include "undo.h"
#include "file_i_o.h"
#include "scale.h"
#include "new.h"
#include "ctcppt.h"
#include "preview.h"
#include "jobs.h"
#include "xrsrc.h"
#include "timeshow.h"
#include "import.h"

/* File-Operationen */
typedef struct
{
	int	fh;		/* Filehandle */
	int mode; /* Parameter aus Aufruf */
	LAYER *l;
	MASK *ms;
	
	/* TIFF-Daten */
	long	rps;
	long	height;
	long	width;
	int		photint;
	long	snum, sbcnum, *soff, *sbc;
}TIFF_BLOCK;

void tiff_rgb_stripe_l(long rps, long width, long ldif, unsigned char *buf, unsigned char **cc, unsigned char **mm, unsigned char **yy, unsigned char **maske, int mode);
void tiff_cmyk_stripe_l(long rps, long width, long ldif, unsigned char *buf, unsigned char **cc, unsigned char **mm, unsigned char **yy, unsigned char **maske, int mode);
void tiff_rgb_stripe_m(long rps, long width, long ldif, unsigned char *buf, unsigned char **mm, int mode);
void tiff_cmyk_stripe_m(long rps, long width, long ldif, unsigned char *buf, unsigned char **mm, int mode);
void esm_cmy_stripe_l(long t_h, long w, long ad_w, unsigned char *buf, unsigned char **cc, unsigned char **mm, unsigned char **yy, unsigned char **maske, int mode);
void esm_rgb_stripe_l(long t_h, long w, long ad_w, unsigned char *buf, unsigned char **cc, unsigned char **mm, unsigned char **yy, unsigned char **maske, int mode);
void esm_rgb_stripe_m(long t_h, long w, long ad_w, unsigned char *buf, unsigned char **mm, int mode);
void esm_cmy_stripe_m(long t_h, long w, long ad_w, unsigned char *buf, unsigned char **mm, int mode);

int	read_tiff_stripes(TIFF_BLOCK *t);

/* File I/O */

int main_load(void)
{
	/* 1=Datei geladen, 0=Abbruch, Fehler oder sonstwas */
	
	char	*punkt, p;
	unsigned long np;
	
	if(f_sinput("Datei îffnen...",paths.main_load_path, paths.main_load_name))
	{
		if(load_file())
		{
			punkt=strrchr(paths.main_load_name, '.');
			if(punkt)
			{
				p=*punkt;
				*punkt=0;
			}
			strcpy(main_win.name, "[Grape] ");
			strcat(main_win.name, paths.main_load_name);
			np=(unsigned long)(main_win.name);
			wind_set(main_win.id, WF_NAME, (int)(np>>16),(int)(np & 0xffff),0,0);
		
			if(punkt)
				*punkt=p;

			strcpy(paths.main_save_path, paths.main_load_path);
			strcpy(paths.main_save_name, paths.main_load_name);
			
			/* Falls GPE-Datei, auch gleich den Namen setzen */
			punkt=strrchr(paths.main_save_name, '.');
			if(punkt)
			{
				if(strcmp(punkt, ".GPE"))
					paths.main_save_name[0]=0;
			}
			else
				paths.main_save_name[0]=0;

			new_preview_sel();
			return(1);
		}
	}
	return(0);
}


int open_esm_as_main(int fh)
{
	/* Return: 0=Ok, sonst -99 */

	int x,y;
	
	graf_mouse(BUSYBEE, NULL);
	if(get_esm_size(fh, &x, &y) == -1)
	{
		Fclose(fh);
		return(-99);
	}
	if(x < 128) x=128;
	if(y < 128) y=128;
	
	if(new_file(x, y) == -1)
	{
		Fclose(fh);
		return(-99);
	}
	
	/* Rahmen abschalten */
	frame_data.ok=0;
	
	if(! l_import(fh, &(first_lay->this), NULL, 0))
	{
		Fclose(fh);
		return(-99);
	}
		
	Fclose(fh);
	graf_mouse(ARROW, NULL);
	return(0);
}

int open_tiff_as_main(int fh, int mode)
{
	/* mode: 0=Motorola-TIFF 1=IBM-TIFF */
	/* Return: 0=Ok, sonst -99 */

	int x,y;
	
	graf_mouse(BUSYBEE, NULL);
	if(get_tiff_size(fh, mode, &x, &y) == -1)
	{
		Fclose(fh);
		return(-99);
	}
	if(x < 128) x=128;
	if(y < 128) y=128;
	
	if(new_file(x, y) == -1)
	{
		Fclose(fh);
		return(-99);
	}
	
	/* Rahmen abschalten */
	frame_data.ok=0;
	
	if(! l_import(fh, &(first_lay->this), NULL, 0))
	{
		Fclose(fh);
		return(-99);
	}
		
	Fclose(fh);
	graf_mouse(ARROW, NULL);
	return(0);
}

int old_load_file(void)
{
	/* ôffnet Datei aus paths.main_load 
		 1=Alles ok
		 0=Fehler oder sonstwas
	*/

	char	complete[256];
	int		old_undo=undo_on;
	long  fhl;
	long	back;
		
	make_path(complete, paths.main_load_path, paths.main_load_name);
	fhl=Fopen(complete, 0);
	if(fhl < 0)
	{
		form_alert(1,"[3][Grape:|Fehler beim ôffnen der Datei!][Abbruch]");
		return(0);
	}
	
	back=identify((int)fhl);

	undo_on=0;
	switch((int)back)
	{
		case FF_GRAPE:
			graf_mouse(BUSYBEE, NULL);
			back=load_all((int)fhl);
			Fclose((int)fhl);
			graf_mouse(ARROW, NULL);
		break;
		case FF_ESM:
			back=open_esm_as_main((int)fhl);
		break;
		case FF_TIFF_MOT:
			back=open_tiff_as_main((int)fhl, 0);
		break;
		case FF_TIFF_INT:
			back=open_tiff_as_main((int)fhl, 1);
		break;
		default:
			form_alert(1,"[3][Grape:|Unbekanntes Dateiformat!][Abbruch]");
			return(0);
	}
	undo_on=old_undo;	
	if(back != 0)
	{ /* <0 = GEMDOS-Fehler, >0=Anzahl gelesener Bytes */
		/* -99= Irgendein Fehler beim Import */
		/* -100=Nicht genug Speicher */
		
		form_alert(1,"[3][Grape:|Fehler beim Lesen der Datei!][Abbruch]");
		return(0);
	}

	return(1);
}

void free_yet_alloced(void)
{ /* Gibt Speicher fÅr evtl. bereits geladene Ebenen zurÅck */

	LAY_LIST	*l;
	MASK_LIST	*m;
	
	while(first_lay)
	{
		free(first_lay->this.red);
		free(first_lay->this.blue);
		free(first_lay->this.yellow);
		l=first_lay;
		first_lay=first_lay->next;
		free(l);
	}
	while(first_mask)
	{
		free(first_mask->this.mask);
		m=first_mask;
		first_mask=first_mask->next;
		free(m);
	}
}

long load_all(int fh)
{
	int		val, ver, width, word_width, height, lays, masks, dum;
	int		lmc=0, mmc=0, total=0, done=0;
	long 	er, siz;
	LAY_LIST	*lp=first_lay;
	LAY_LIST	*ll;
	LAYER			*l;
	MASK_LIST	*mp=first_mask;
	MASK_LIST *ml;
	MASK			*m;

	layer_id=0;
	mask_id=0;	
	act_lay=NULL;
	act_mask=NULL;
	
	er=Fread(fh, 4, &siz); /* Magic Åbergehen */
	if(er < 4) return(er);
	
	er=Fread(fh, 2, &val);
	if(er < 2) return(er);
	
	do
	{
	
	switch(val)
	{
		case 0:	/* Version */
			er=Fread(fh, 2, &ver);
			if(er < 2) return(er);
		break;
		case 1:	/* Ebenen */
			er=Fread(fh, 2, &lays);
			if(er < 2) return(er);
			total+=lays*3;
		break;
		case 2:	/* Masken */
			er=Fread(fh, 2, &masks);
			if(er < 2) return(er);
			total+=masks;
		break;
		case 3:	/* Max.Breite (width)*/
			er=Fread(fh, 2, &width);
			if(er < 2) return(er);
		break;
		case 4:	/* Max.Breite (word_width) */
			er=Fread(fh, 2, &word_width);
			if(er < 2) return(er);
		break;
		case 5:	/* Hîhe */
			er=Fread(fh, 2, &height);
			if(er < 2) return(er);
			new_win_make(width, height);
			/* Maskenschalter aus */
			otoolbar[MASK_ON-1].ob_state &= (~SELECTED);
			otoolbar[MASK_VIS-1].ob_state &= (~SELECTED);
			otoolbar[MASK_ED-1].ob_state &= (~SELECTED);
		break;
		
		case 0x20: /* Ebene */
			if(lays)
			{
				ll=(LAY_LIST*)malloc(sizeof(LAY_LIST));
				if(!ll)
				{
					free_yet_alloced();
					form_alert(1,"[3][Nicht genug Speicher!][Abbruch]");
					return(-100);
				}
				
				if(first_lay == NULL)
				{
					act_lay=first_lay=lp=ll;
					ll->prev=NULL;
				}
				else
				{
					lp->next=ll;
					ll->prev=lp;
					lp=ll;
				}
				ll->next=NULL;
				l=&ll->this;
				l->id=layer_id++;
				strcpy(l->name, "Unbenannt");
				l->type=1;
				l->changes=l->selected=l->visible=l->draw=l->solo=0;
				l->width=width;
				l->height=height;
				l->word_width=word_width;
				siz=(long)((long)word_width*(long)height);
				l->red=malloc(siz);
				l->yellow=malloc(siz);
				l->blue=malloc(siz);
				if((!l->red) || (!l->yellow) || (!l->blue))
				{
					free_yet_alloced();
					form_alert(1,"[3][Nicht genug Speicher!][Abbruch]");
					return(-100);
				}
				do
				{
					er=Fread(fh, 2, &val);
					if(er < 2) return(er);
					switch(val)
					{
						case 0xa1:	/* ID */
							er=Fread(fh, 2, &(l->id));
							if(er < 2) return(er);
						break;
						case 0xa2:	/* Name */
							er=Fread(fh, 11, &(l->name));
							if(er < 11) return(er);
							Fread(fh, 1, &dum);
						break;
						case 0xa3:	/* Type */
							er=Fread(fh, 2, &(l->type));
							if(er < 2) return(er);
						break;
						case 0xa4:	/* Selected */
							er=Fread(fh, 2, &(l->selected));
							if(er < 2) return(er);
						break;
						case 0xa5:	/* Visible */
							er=Fread(fh, 2, &(l->visible));
							if(er < 2) return(er);
						break;
						case 0xa6:	/* Draw */
							er=Fread(fh, 2, &(l->draw));
							if(er < 2) return(er);
							act_lay=ll;
						break;
						case 0xa7:	/* Solo */
							er=Fread(fh, 2, &(l->solo));
							if(er < 2) return(er);
							act_lay=ll;
						break;
						/* width, word_width, height darf sich eh nicht Ñndern
						case 0xa8:
						case 0xa9:
						case 0xaa:
						*/
						case 0xf2:	/* Planes */
							timeshow(done++,total);
							er=Fread(fh, siz, l->red);
							if(er < siz) return(er);
							timeshow(done++,total);
							er=Fread(fh, siz, l->yellow);
							if(er < siz) return(er);
							timeshow(done++,total);
							er=Fread(fh, siz, l->blue);
							if(er < siz) return(er);
						break;
					}
				}while(val != 0xf2);
				
				--lays;
			}
		break;
		
		case 0x30: /* Maske */
			if(masks)
			{
				ml=(MASK_LIST*)malloc(sizeof(MASK_LIST));
				if(!ml)
				{
					free_yet_alloced();
					form_alert(1,"[3][Nicht genug Speicher!][Abbruch]");
					return(-100);
				}	
				if(first_mask == NULL)
				{
					act_mask=first_mask=mp=ml;
					ml->prev=NULL;
				}
				else
				{
					mp->next=ml;
					ml->prev=mp;
					mp=ml;
				}
				ml->next=NULL;
				m=&(ml->this);
				m->id=mask_id++;
				strcpy(m->name, "Unbenannt");
				m->col=1;
				siz=(long)((long)word_width*(long)height);
				m->mask=malloc(siz);
				if(!m->mask)
				{
					free_yet_alloced();
					form_alert(1,"[3][Nicht genug Speicher!][Abbruch]");
					return(-100);
				}
				do
				{
					er=Fread(fh, 2, &val);
					if(er < 2) return(er);
					switch(val)
					{
						case 0xa1:	/* ID */
							er=Fread(fh, 2, &(m->id));
							if(er < 2) return(er);
						break;
						case 0xa2:	/* Name */
							er=Fread(fh, 11, &(m->name));
							if(er < 11) return(er);
							Fread(fh, 1, &dum);
						break;
						case 0xa3:	/* Color */
							er=Fread(fh, 2, &(m->col));
							if(er < 2) return(er);
						break;
						/* width, word_width, height darf sich eh nicht Ñndern
						case 0xa8:
						case 0xa9:
						case 0xaa:
						*/
						case 0xf3:	/* Plane */
							timeshow(done++,total);
							er=Fread(fh, siz, m->mask);
							if(er < siz) return(er);
						break;
					}
				}while(val != 0xf3);
				
				--lays;
			}
		break;
		
		case 0x40: /* Ebene-Merker */
			if(lmc < 10)
			{
				er=Fread(fh, sizeof(LAY_STORE), &lay_store[lmc++]);
				if(er < sizeof(LAY_STORE)) return(er);
			}
		break;
		
		case 0x50: /* Masken-Merker */
			if(mmc < 10)
			{
				er=Fread(fh, sizeof(MASK_STORE), &mask_store[mmc++]);
				if(er < sizeof(MASK_STORE)) return(er);
			}
		break;
	}

	er=Fread(fh, 2, &val);
	if(er < 0) return(er);
	}while(er > 0);
	
	timeoff();
	init_layob();
	draw_layob();

	return(0);
}

int	get_tiff_size(int fh, int mot_or_ibm, int *x, int *y)
{
	/* mot_or_ibm: 0=mot, 1=ibm */
	/* RÅckgabe: 1=ok, -1=nicht ok */

	unsigned char dum[4], field[12];
	int		count, tag, typ;
	long	off, anz, wert;
	
	*x=-1;
	*y=-1;
	
	Fread(fh, 4, dum); /* TIFF-ID */
	Fread(fh, 4, &off); /* Erster IFD */
	if(mot_or_ibm)
		off=lturn(off);
	Fseek(off, fh, 0);
	/* IFD lesen */
	
	Fread(fh, 2, &count); /* Anzahl der Felder */
	if(mot_or_ibm)
		count=iturn(count);
	while((count--) && ((*x==-1)||(*y==-1)))
	{
		Fread(fh, 12, field);
		tag=*(int*)(&field[0]);
		typ=*(int*)(&field[2]);
		anz=*(long*)(&field[4]);
		
		if(mot_or_ibm)
		{
			tag=iturn(tag);
			typ=iturn(typ);
			anz=lturn(anz);
		}
		
		if((typ == 3) && (anz < 3))
		{
			wert=*(int*)(&field[8]);
			if(mot_or_ibm)
				wert=iturn((int)wert);
		}
    else if((typ==4) || (typ==3) || (typ==2)) /* Typ=long oder offset */ 
    { 
      wert=*(long*)(&field[8]);
      if(mot_or_ibm)
	      wert=lturn(wert); 
    } 
		switch(tag)
		{
			case 256: /* Breite */
				*x=(int)wert;
			break;
			case 257: /* Hîhe */
				*y=(int)wert;
			break;
		}
	}
	
	Fseek(0, fh, 0);

	if((*x==-1) || (*y==-1))
		return(-1);

	return(1);
}

int get_esm_size(int fh, int *x, int *y)
{
	/* Falls nix gelesen werden kann kommt -1 zurÅck, sonst 1 */
	
	unsigned char buf[10];
		
	if(Fread(fh, 10, buf) != 10) /* Esm-ID +head + w+ h*/
		return(-1);
		
	*x=*(int*)(&(buf[6]));
	*y=*(int*)(&(buf[8]));

	Fseek(0, fh, 0);

	return(1);	
}

int get_grape_size(int fh, int *x, int *y)
{
	/* Gibt 1 zurÅck wenn ok, sonst -1 */
	
	GRAPE_INFO	gp;
	if(get_grape_info(fh, &gp))
	{
		*x=gp.width;
		*y=gp.height;
		return(1);
	}
	return(-1);
}

int get_grape_info(int fh, GRAPE_INFO *gp)
{
	/* 1=alles (der Version entsprechend) gelesen
		 0=Fehler
	*/
	int		val, inp=0;
	long 	er, dum;

	er=Fread(fh, 4, &dum); /* Magic Åbergehen */
	if(er < 4) return(0);
	
	er=Fread(fh, 2, &val);
	if(er < 2) return(0);
	
	do
	{
		switch(val)
		{
			case 0:	/* Version */
				er=Fread(fh, 2, &(gp->version));
				if(er < 2) return(0);
				++inp;
			break;
			case 1:	/* Ebenen */
				er=Fread(fh, 2, &(gp->lay_num));
				if(er < 2) return(0);
				++inp;
			break;
			case 2:	/* Masken */
				er=Fread(fh, 2, &(gp->mask_num));
				if(er < 2) return(0);
				++inp;
			break;
			case 3:	/* Max.Breite (width)*/
				er=Fread(fh, 2, &(gp->width));
				if(er < 2) return(0);
				++inp;
			break;
			case 4:	/* Max.Breite (word_width) */
				er=Fread(fh, 2, &(gp->word_width));
				if(er < 2) return(0);
				++inp;
			break;
			case 5:	/* Hîhe */
				er=Fread(fh, 2, &(gp->height));
				if(er < 2) return(0);
				++inp;
			break;
		}
		er=Fread(fh, 2, &val);
		if(er < 0) return(0);
	}while((er > 0) && (inp < 6));
	
	Fseek(0, fh, 0);

	if(inp < 6)
		return(0);
	
	return(1);
}


int identify(int fh)
{
	/* Gibt den Typ der Datei mit handle fh zurÅck
		 oder -1 falls unbekannt
	*/
	
	unsigned long	id;
	
	Fread(fh, 4, &id);
	Fseek(0, fh, 0);
	if(id == 'TMS\0')
		return(FF_ESM);
	else if(id == 0x4d4d002al)
		return(FF_TIFF_MOT);
	else if(id == 0x49492a00l)
		return(FF_TIFF_INT);
	else if(id == 'GRPE')
		return(FF_GRAPE);
	else
		return(-1);
}

int main_save(void)
{/* Gibt 0 fÅr Abbruch oder Fehler, sonst 1 zurÅck */
	char	complete[256];
	long  fhl;
	long	back;
		
	if(paths.main_save_name[0] == 0)
	/* Noch kein Dateiname vergeben->save_as aufrufen */
		return(main_save_as());

	make_path(complete, paths.main_save_path, paths.main_save_name);
	fhl=Fcreate(complete, 0);
	if(fhl < 0)
	{
		form_alert(1,"[3][Grape:|Fehler beim Anlegen der Datei!][Abbruch]");
		return(0);
	}
	
	graf_mouse(BUSYBEE, NULL);
	back=save_all((int)fhl);
	Fclose((int)fhl);
	graf_mouse(ARROW, NULL);
	if(back != 0)
	{ /* <0 = GEMDOS-Fehler, >0=Anzahl geschriebener Bytes */
		form_alert(1,"[3][Grape:|Fehler beim Schreiben der Datei!][Abbruch]");
		return(0);
	}

	return(1);
}

long save_all(int fh)
{
	/* Sichert die aktuelle Datei im File fh */
	/* Bei alles ok kommt 0, sonst Fehlercode zurÅck */
	long  er, siz;
	int		dum, a, total, done;
	int		buf[40];
	LAY_LIST	*ll=first_lay;
	LAYER			*l;
	MASK_LIST	*ml=first_mask;
	MASK			*m;
	char			nm[256];
	unsigned long np;
	
	total=count_layers()*3+count_masks();
	done=0;
		
	strcpy((char*)buf, "GRPE");	/* Magic */
	er=Fwrite(fh, 4, buf);
	if(er < 4)	return(er);

	/* Version ablegen 1-2*/
	buf[0]=0;
	buf[1]=FF_VERSION;
	
	/* Ebenen-Anzahl 3-4*/ 
	buf[2]=1;
	buf[3]=count_layers();
	
	/* Masken-Anzahl 5-6 */
	buf[4]=2;
	buf[5]=count_masks();
	
	/* Max. Breite 7-8 */
	buf[6]=3;
	buf[7]=first_lay->this.width;
	
	/* Max. Breite word_width 9-10 */
	buf[8]=4;
	buf[9]=first_lay->this.word_width;
	
	/* Max. Hîhe 11-12 */
	buf[10]=5;
	buf[11]=first_lay->this.height;
	
	/* Buffer rausschreiben */
	er=Fwrite(fh, 24, buf);
	if(er < 24)	return(er);
	
	/* Ebenen rausschreiben */
	while(ll)
	{
		l=&(ll->this);
		buf[0]=0x20;
		buf[1]=0xa1;
		buf[2]=l->id;
		buf[3]=0xa2;
		buf[4]=0;
		strcpy((char*)(&buf[4]), l->name);
		buf[10]=0xa3;
		buf[11]=l->type;
		buf[12]=0xa4;
		buf[13]=l->selected;
		buf[14]=0xa5;
		buf[15]=l->visible;
		buf[16]=0xa6;
		buf[17]=l->draw;
		buf[18]=0xa7;
		buf[19]=l->solo;
		buf[20]=0xa8;
		buf[21]=l->width;
		buf[22]=0xa9;
		buf[23]=l->height;
		buf[24]=0xaa;
		buf[25]=l->word_width;
		buf[26]=0xf2;
		er=Fwrite(fh, 54, buf);
		if(er < 54) return(er);
		siz=(long)((long)first_lay->this.word_width*(long)first_lay->this.height);
		timeshow(done++,total);
		er=Fwrite(fh, siz, l->red);
		if(er < siz) return(er);
		timeshow(done++,total);
		er=Fwrite(fh, siz, l->yellow);
		if(er < siz) return(er);
		timeshow(done++,total);
		er=Fwrite(fh, siz, l->blue);
		if(er < siz) return(er);

		ll=ll->next;		
	}
	
	/* Masken rausschreiben */
	while(ml)
	{
		m=&(ml->this);
		buf[0]=0x30;
		buf[1]=0xa1;
		buf[2]=m->id;
		buf[3]=0xa2;
		buf[4]=0;
		strcpy((char*)(&buf[4]), m->name);
		buf[10]=0xa3;
		buf[11]=m->col;
		buf[12]=0xa8;
		buf[13]=first_lay->this.width;
		buf[14]=0xa9;
		buf[15]=first_lay->this.height;
		buf[16]=0xaa;
		buf[17]=first_lay->this.word_width;
		buf[18]=0xf3;
		er=Fwrite(fh, 38, buf);
		if(er < 38) return(er);
		siz=(long)((long)first_lay->this.word_width*(long)first_lay->this.height);
		timeshow(done++,total);
		er=Fwrite(fh, siz, m->mask);
		if(er < siz) return(er);
		
		ml=ml->next;
	}
	
	/* Merker fÅr Layer rausschreiben */
	for(a=0; a < 11; ++a)
	{
		dum=0x40;
		Fwrite(fh, 2, &dum);
		er=Fwrite(fh, sizeof(LAY_STORE), &lay_store[a]);
		if(er < sizeof(LAY_STORE)) return(er);
	}

	/* Merker fÅr Maske rausschreiben */
	for(a=0; a < 11; ++a)
	{
		dum=0x50;
		Fwrite(fh, 2, &dum);
		er=Fwrite(fh, sizeof(MASK_STORE), &mask_store[a]);
		if(er < sizeof(MASK_STORE)) return(er);
	}
	
	/* Alles hat geklappt->Layer-Changes auf 0 setzen */

	ll=first_lay;
	while(ll)
	{
		ll->this.changes=0;
		ll=ll->next;
	}

	if(main_win.name[0] == '*')
	{
		strcpy(nm, main_win.name);
		strcpy(main_win.name, &(nm[1]));
		np=(unsigned long)(main_win.name);
		wind_set(main_win.id, WF_NAME, (int)(np>>16),(int)(np&0xffff),0,0);
	}
	timeoff();	
	return(0);
}

int main_save_as(void)
{/* Gibt 0 fÅr Abbruch oder Fehler, sonst 1 zurÅck */
	char	*punkt, p, path[256], *bs;
	long	fhl;
	unsigned long np;
	
	if(f_sinput("Datei sichern als...",paths.main_save_path, paths.main_save_name))
	{
		punkt=strrchr(paths.main_save_name, '.');
		if(punkt)
		{
			p=*punkt;
			*punkt=0;
		}
		strcpy(main_win.name, "[Grape] ");
		strcat(main_win.name, paths.main_save_name);
		np=(unsigned long)(main_win.name);
		wind_set(main_win.id, WF_NAME, (int)(np>>16),(int)(np&0xffff),0,0);
		
		if(!punkt)
			strcat(paths.main_save_name, ".GPE");
		else
		{
			*punkt=p;
			strcpy(&(punkt[1]), "GPE");
		}

		strcpy(path, paths.main_save_path);
		/* Backslash finden */
		bs=NULL; fhl=0;
		while(path[fhl])
		{
			if(path[fhl]=='\\') bs=&(path[fhl]);
			++fhl;
		}
		/* String nach letztem bs terminiern */
		if(bs) bs[1]=0;
		strcat(path, paths.main_save_name);
		fhl=Fopen(path, FO_READ);
		if(fhl >= 0)
		{
			Fclose((int)fhl);
			if(form_alert(1,"[2][Grape:|Die Datei existiert bereits.|Soll sie Åberschrieben werden?][OK|Abbruch]") == 2)
			{/* Nicht Åberschreiben */
				paths.main_save_name[0]=0;
				return(0);
			}
		}

		return(main_save());
	}
		
	return(0);
}

int main_import(void)
{
	return(0);
}

int main_export(void)
{
	return(0);
}


int import_mask(void)
{
	int ret=0;
	
	if(f_sinput("Maske importieren", paths.mask_import_path, paths.mask_import_name))
	{
		if(!auto_reset(5))
			return(0);
		ret=(import_file(paths.mask_import_path, paths.mask_import_name,NULL, &(act_mask->this), 0));
		if(ret) 
			mask_changed(act_mask);
	}
	return(ret);
}

void import_edit(void)
{/* Importiert die Edit- oder die einzige existierende Ebene */
	int		ret=0;
	LAYER	*l;
	LAY_LIST *ll;
	char	titel[128];
	
	if(count_layers() > 1)
	{		
		if(otoolbar[MASK_ED-1].ob_state & SELECTED)
		{
			form_alert(1,"[3][Grape:|Es ist keine Edit-Ebene|aktiv!][Abbruch]");
			return;
		}
		ll=act_lay;
	}
	else
	{
		ll=first_lay;
	}
	
	strcpy(titel, "Ebene ");
	strcat(titel, ll->this.name);
	strcat(titel, " importieren");
	if(f_sinput(titel, paths.layer_import_path, paths.layer_import_name))
	{
		if(!auto_reset(5))
			return;
		l=&(ll->this);
		ret=import_file(paths.layer_import_path, paths.layer_import_name, l, NULL, 0);
		if(ret)
		{
			if(l->visible)
				redraw_pic();
			layer_changed(ll);
			actize_win_name();
		}
	}
}

void import_selected(void)
{
	int		ret=0, r, redraw=0;
	LAYER	*l;
	LAY_LIST	*ll=first_lay, *sl;
	char	titel[128];
	
	if(count_sel_layers() < 1)
	{
		form_alert(1,"[3][Grape:|FÅr den Import muû mindestens|eine Ebene angewÑhlt sein.][Abbruch]");
		return;
	}

	if(!auto_reset(5))
		return;

	do
	{	
		if(ll->this.selected)
		{
			l=&(ll->this);
			strcpy(titel, "Ebene ");
			strcat(titel, l->name);
			strcat(titel, " importieren");
			if(f_sinput(titel, paths.layer_import_path, paths.layer_import_name))
			{
				r=import_file(paths.layer_import_path, paths.layer_import_name, l, NULL, 0);
				if(r)
				{
					ret=1;
					if(l->visible)
						redraw=1;
					layer_changed(ll);
				}
			}	
			else
			{/* Fsel wurde abgebrochen */
				/* Kommen noch zu importierende Ebenen? */
				sl=ll->next; r=0;
				while(sl)
				{
					if(sl->this.selected) r=1;
					sl=sl->next;
				}
				if(r)
					if(form_alert(1,"[2][Grape:|Import aller Ebenen abbrechen|oder mit nÑchster Ebene weiter-|machen?][Weiter|Abbruch]")==2)
						break;
			}
		}
		/* NÑchste Ebene */
		ll=ll->next;
	}while(ll);
	
	if(redraw)
		redraw_pic();
	if(ret)
		actize_win_name();
}

int l_import(int fh, LAYER *l, MASK *ms, int mode)
{
	/* fh=Filehandle
		 l=Zeiger auf Layer oder NULL
		 ms=Zeiger auf Maske oder NULL
		 mode: 0=Einfach importieren
		 			 1=Status von "EinfÅgemodus" und "Maske aktiv" beachten
	*/
		 
	/* RÅckgabe: 1=Import ok, 0=Feher aufgetreten */

	int	id, ret;

	graf_mouse(BUSYBEE, NULL);
	
	id=identify(fh);

	if(id == FF_ESM)
		ret=esm_import(fh, l, ms, mode);
	else if(id == FF_TIFF_MOT)
		ret=tiff_import(fh, l, ms, mode);
	else if(id == FF_TIFF_INT)
		ret=ibm_tiff_import(fh, l, ms, mode);
	else if(id == FF_GRAPE)
	{
		graf_mouse(ARROW, NULL);
		form_alert(1,"[3][Grape:|Einzelne Ebenen aus GRAPE-Dateien|kînnen noch nicht importiert werden.|ôffnen Sie die Datei Åber das \'Datei\'-|MenÅ.][Abbruch]");
		return(0);
	}
	else
	{
		graf_mouse(ARROW, NULL);
		form_alert(1,"[3][Grape:|Unbekanntes Format.|Import nicht mîglich.][Abbruch]");
		return(0);
	}

	graf_mouse(ARROW, NULL);
	return(ret);
}

unsigned int iturn(unsigned int num)
{ /* Dreht IBM-Int in Motorola-Int um */
	unsigned int	buf=num>>8, buf2=num<<8;
	return(buf+buf2);
}

long lturn(long num)
{ /* Dreht IBM-Long in Motorola-Long um */

	long b1=num>>16, b2=num & 65535l;
	unsigned int buf1, buf2;
	long res;
	
	buf1=iturn((unsigned int)b1);
	buf2=iturn((unsigned int)b2);
	
	res=(long)(((long)buf2)<<16)+(long)buf1;
	return(res);
}

int too_big_alert(int w, int h, int *nw, int *nh)
{
	/* w,h=Breite, Hîhe der zu importierenden Datei
	   Spuckt Alert aus und fragt, ob skaliert oder
	   abgebrochen werden soll.
	   Bei Abbruch kommt null zurÅck, sonst 1
	   und in nw/nh die Daten, auf die Skaliert werden muû,
	   damit das ganze in die Hauptdatei paût
	*/
	
	char	alert[256], num[10];
	int		ret, hw, hh;
	double h_zu_w;
	
	h_zu_w=(double)h/(double)w;
	
	hw=first_lay->this.width;
	hh=first_lay->this.height;
	
	strcpy(alert, "[2][Die Importdatei (");
	itoa(w, num, 10);
	strcat(alert, num);
	strcat(alert, " x ");
	itoa(h, num, 10);
	strcat(alert, num);
	strcat(alert, ")|ist Grîûer als Ihre Hauptdatei|(");
	itoa(hw, num, 10);
	strcat(alert, num);
	strcat(alert, " x ");
	itoa(hh, num, 10);
	strcat(alert, num);
	strcat(alert, "). Soll die Import-|datei passend skaliert werden?]");
	strcat(alert, "[OK|Abbruch]");

	ret=form_alert(1,alert);

	if(ret==2) return(0); /* Abbruch */
	
	/* Skalierung berechnen */

	*nw=w;
	*nh=h;

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
	
	return(1);
}

void set_frame_size(int x, int y, int w, int h)
{
	if(frame_data.vis)
		draw_win_frame();
	if(!frame_data.ok)
		frame_data.wid=main_win.id;
	
	frame_data.x=x; frame_data.y=y;
	frame_data.w=w;	frame_data.h=h;
	
	frame_data.ok=1;
	if(frame_data.vis)
		draw_win_frame();

}

int ibm_tiff_import(int fh, LAYER *l, MASK *ms, int mode)
{
	unsigned char dum[40], field[12];
	unsigned int	int_in;
	char	alert[256];
	int		count, tag, typ, bps[4], photint;
	long	off, offm, snum, *soff=NULL, *sbc=NULL, anz, wert;
	long	width, height, a, rps, sbcnum, long_in;
	TIFF_BLOCK tbl;
	
	Fread(fh, 4, dum); /* TIFF-ID */
	Fread(fh, 4, &off); /* Erster IFD */
	off=lturn(off);
	Fseek(off, fh, 0);
	/* IFD lesen */
	
	Fread(fh, 2, &count); /* Anzahl der Felder */
	count=iturn(count);
	while(count--)
	{
		Fread(fh, 12, field);
		tag=*(int*)(&field[0]);
		typ=*(int*)(&field[2]);
		anz=*(long*)(&field[4]);
		
		tag=iturn(tag);
		typ=iturn(typ);
		anz=lturn(anz);
		
		if((typ == 1) && (anz < 9))
			wert=*(unsigned char*)(&field[8]);
		else if((typ == 3) && (anz < 3))
		{
			wert=*(int*)(&field[8]);
			wert=iturn((int)wert);
		}
		else if((typ==4) || (typ==3) || (typ==2)) /* Typ=long oder offset */
		{
			wert=*(long*)(&field[8]);
			wert=lturn(wert);
		}
		switch(tag)
		{
			case 256: /* Breite */
				width=wert;
			break;
			case 257: /* Hîhe */
				height=wert;
			break;
			
			case 258: /* Bits per Sample */
				if(anz > 2)
				{
					offm=Fseek(0, fh, 1);
					Fseek(wert, fh, 0);
					Fread(fh, 2*anz, bps);
					while(anz--)
					{
						bps[anz]=iturn(bps[anz]);
						if(bps[anz] != 8)
						{
							form_alert(1,"[3][Grape:|Es kînnen nur TIFF-Bilder|mit 8-Bits pro Sample|importiert werden.][Abbruch]");
							if(soff) free(soff); if(sbc) free(sbc);
							return(0);
						}
					}
					Fseek(offm, fh, 0);
				}
				else if(wert != 8)
				{
					form_alert(1,"[3][Grape:|Es kînnen nur TIFF-Bilder|mit 8-Bits pro Sample|importiert werden.][Abbruch]");
					if(soff) free(soff); if(sbc) free(sbc);
					return(0);
				}
			break;

			case 259: /* Kompression */
				if(wert != 1)
				{
					form_alert(1,"[3][Grape:|Es kînnen nur ungepackte|TIFF-Bilder importiert werden.][Abbruch]");
					if(soff) free(soff); if(sbc) free(sbc);
					return(0);
				}
			break;

			case 262: /* Photometric Interpretation */
				if((wert != 2) && (wert != 5))
				{
					form_alert(1,"[3][Grape:|Es kînnen nur True-Color|TIFF-Bilder (RGB oder CMYK)|importiert werden.][Abbruch]");
					if(soff) free(soff); if(sbc) free(sbc);
					return(0);
				}
				photint=(int)wert;
			break;
			
			case 273: /* Strip-Offsets */
				snum=anz;
				soff=(long*)malloc(anz*sizeof(long));
				if(!soff)
				{
					form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
					if(sbc) free(sbc); if(soff) free(soff);
					return(0);
				}
				if(anz == 1) /* Offset im Wert */
					soff[0]=wert;
				else
				{/* Offsets in Datei */
					offm=Fseek(0, fh, 1);
					Fseek(wert, fh, 0);
					a=0;
					if(typ == 3)
					{/* Offsets als Int */
						while(a < snum)
						{
							Fread(fh, 2, &int_in);
							soff[a++]=iturn(int_in);
						}
					}
					else if(typ == 4)
					{/* Offsets als Long */
						while(a < snum)
						{
							Fread(fh, 4, &long_in);
							soff[a++]=lturn(long_in);
						}
					}
					Fseek(offm, fh, 0);
				}
			break;
			
			case 277: /* Samples per Pixel */
				if((wert < 3) || (wert > 4))
				{
					strcpy(alert, "[3][Grape:|Es kînnen nur 24- oder 32-Bit|TIFF-Bilder importiert werden.][Abbruch]");
					form_alert(1,alert);
					if(soff) free(soff); if(sbc) free(sbc);
					return(0);
				}
			break;
			
			case 278: /* Rows per Strip */
				rps=wert;
			break;
			
			case 279: /* StripByteCounts */
				sbcnum=anz;
				sbc=(long*)malloc(anz*sizeof(long));
				if(!sbc)
				{
					form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
					if(sbc) free(sbc); if(soff) free(soff);
					return(0);
				}
				if(anz == 1) /* Offset im Wert */
					sbc[0]=wert;
				else
				{/* Offsets in Datei */
					offm=Fseek(0, fh, 1);
					Fseek(wert, fh, 0);
					a=0;

					if(typ == 3)
					{/* Offsets als Int */
						while(a < sbcnum)
						{
							Fread(fh, 2, &int_in);
							sbc[a++]=iturn(int_in);
						}
					}
					else if(typ == 4)
					{/* Offsets als Long */
						while(a < sbcnum)
						{
							Fread(fh, 4, &long_in);
							sbc[a++]=lturn(long_in);
						}
					}
					Fseek(offm, fh, 0);
				}
			break;
			
		}
	}

	tbl.fh=fh;
	tbl.mode=mode;
	tbl.ms=ms;
	tbl.l=l;
	tbl.rps=rps;
	tbl.height=height;
	tbl.width=width;
	tbl.photint=photint;
	tbl.snum=snum;
	tbl.sbcnum=sbcnum;
	tbl.sbc=sbc;
	tbl.soff=soff;
		
	return(read_tiff_stripes(&tbl));
}
	
int tiff_import(int fh, LAYER *l, MASK *ms, int mode)
{
	unsigned char dum[40], field[12];
	char	alert[256];
	int		count, tag, typ, bps[4], photint, int_in;
	long	off, offm, snum, *soff=NULL, *sbc=NULL, anz, wert;
	long	width, height, a, rps, sbcnum;
	TIFF_BLOCK tbl;
	
	Fread(fh, 4, dum); /* TIFF-ID */
	Fread(fh, 4, &off); /* Erster IFD */
	Fseek(off, fh, 0);
	/* IFD lesen */
	
	Fread(fh, 2, &count); /* Anzahl der Felder */
	while(count--)
	{
		Fread(fh, 12, field);
		tag=*(int*)(&field[0]);
		typ=*(int*)(&field[2]);
		anz=*(long*)(&field[4]);
		
		if((typ == 1) && (anz < 9))
			wert=*(unsigned char*)(&field[8]);
		else if((typ == 3) && (anz < 3))
			wert=*(int*)(&field[8]);
		else if((typ==4) || (typ==3) || (typ==2)) /* Typ=long oder offset */
			wert=*(long*)(&field[8]);
		switch(tag)
		{
			case 256: /* Breite */
				width=wert;
			break;
			case 257: /* Hîhe */
				height=wert;
			break;
			
			case 258: /* Bits per Sample */
				if(anz > 2)
				{
					offm=Fseek(0, fh, 1);
					Fseek(wert, fh, 0);
					Fread(fh, 2*anz, bps);
					while(anz--)
					{
						if(bps[anz] != 8)
						{
							form_alert(1,"[3][Grape:|Es kînnen nur TIFF-Bilder|mit 8-Bits pro Sample|importiert werden.][Abbruch]");
							if(soff) free(soff); if(sbc) free(sbc);
							return(0);
						}
					}
					Fseek(offm, fh, 0);
				}
				else if(wert != 8)
				{
					form_alert(1,"[3][Grape:|Es kînnen nur TIFF-Bilder|mit 8-Bits pro Sample|importiert werden.][Abbruch]");
					if(soff) free(soff); if(sbc) free(sbc);
					return(0);
				}
			break;

			case 259: /* Kompression */
				if(wert != 1)
				{
					form_alert(1,"[3][Grape:|Es kînnen nur ungepackte|TIFF-Bilder importiert werden.][Abbruch]");
					if(soff) free(soff); if(sbc) free(sbc);
					return(0);
				}
			break;

			case 262: /* Photometric Interpretation */
				if((wert != 2) && (wert != 5))
				{
					form_alert(1,"[3][Grape:|Es kînnen nur True-Color|TIFF-Bilder (RGB oder CMYK)|importiert werden.][Abbruch]");
					if(soff) free(soff); if(sbc) free(sbc);
					return(0);
				}
				photint=(int)wert;
			break;
			
			case 273: /* Strip-Offsets */
				snum=anz;
				soff=(long*)malloc(anz*sizeof(long));
				if(!soff)
				{
					form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
					if(sbc) free(sbc); if(soff) free(soff);
					return(0);
				}
				if(anz == 1) /* Offset im Wert */
					soff[0]=wert;
				else
				{/* Offsets in Datei */
					offm=Fseek(0, fh, 1);
					Fseek(wert, fh, 0);
					a=0;
					if(typ == 3)
					{/* Offsets als Int */
						while(a < snum)
						{
							Fread(fh, 2, &int_in);
							soff[a++]=int_in;
						}
					}
					else if(typ == 4)
					{/* Offsets als Long */
						while(a < snum)
						{
							Fread(fh, 4, &soff[a]);
							++a;
						}
					}
					Fseek(offm, fh, 0);
				}
			break;
			
			case 277: /* Samples per Pixel */
				if((wert < 3) || (wert > 4))
				{
					strcpy(alert, "[3][Grape:|Es kînnen nur 24- oder 32-Bit|TIFF-Bilder importiert werden.][Abbruch]");
					form_alert(1,alert);
					if(soff) free(soff); if(sbc) free(sbc);
					return(0);
				}
			break;
			
			case 278: /* Rows per Strip */
				rps=wert;
			break;
			
			case 279: /* StripByteCounts */
				sbcnum=anz;
				sbc=(long*)malloc(anz*sizeof(long));
				if(!sbc)
				{
					form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
					if(sbc) free(sbc); if(soff) free(soff);
					return(0);
				}
				if(anz == 1) /* Offset im Wert */
					sbc[0]=wert;
				else
				{/* Offsets in Datei */
					offm=Fseek(0, fh, 1);
					Fseek(wert, fh, 0);
					a=0;

					if(typ == 3)
					{/* Offsets als Int */
						while(a < sbcnum)
						{
							Fread(fh, 2, &int_in);
							sbc[a++]=int_in;
						}
					}
					else if(typ == 4)
					{/* Offsets als Long */
						while(a < sbcnum)
						{
							Fread(fh, 4, &sbc[a]);
							++a;
						}
					}
					Fseek(offm, fh, 0);
				}
			break;
			
		}
	}

	tbl.fh=fh;
	tbl.mode=mode;
	tbl.ms=ms;
	tbl.l=l;
	tbl.rps=rps;
	tbl.height=height;
	tbl.width=width;
	tbl.photint=photint;
	tbl.snum=snum;
	tbl.sbcnum=sbcnum;
	tbl.sbc=sbc;
	tbl.soff=soff;
		
	return(read_tiff_stripes(&tbl));
}

int	read_tiff_stripes(TIFF_BLOCK *t)
{
	int		scale_it=0, mode=t->mode;
	
	int		sc_w, sc_h, main_x_scale, main_y_scale;
	long	siz, ldif, a, off;
	unsigned char *c2, *m2, *y2;
	unsigned char *buf, *c, *y, *m;
	unsigned char	*mask=act_mask->this.mask;

	if((frame_data.ok) && (frame_data.vis))
	{
		if((t->width != frame_data.w) || (t->height != frame_data.h))
			scale_it=1;	/* Ungleich Rahmengrîûe->Skalieren */
	}
	else if((t->width > first_lay->this.width) || (t->height > first_lay->this.height))
	{ /* Grîûer als Hauptdatei */
		if(too_big_alert((int)t->width, (int)t->height, &main_x_scale, &main_y_scale))
		{
			set_frame_size(0,0,main_x_scale,main_y_scale);
			scale_it=1;
		}
		else
		{
			if(t->sbc) free(t->sbc); if(t->soff) free(t->soff);
			return(0);
		}
	}
	else
		set_frame_size(0,0,(int)t->width,(int)t->height);
	
	if(!frame_to_undo_ws(t->l, t->ms))
	{
		if(t->sbc) free(t->sbc); if(t->soff) free(t->soff);
		return(0);
	}

	/* Streifen einlesen */
	a=0;

	if(scale_it)
	{
		mode=0; /* Wird ja eh bloû in den Puffer kopiert! */
		ldif=0;
		siz=t->width*t->height;
		if(t->l)
		{
			c2=c=(unsigned char*)calloc(siz, 1);
			m2=m=(unsigned char*)calloc(siz, 1);
			y2=y=(unsigned char*)calloc(siz, 1);
			if((!c2) || (!m2) || (!y2))
			{
				form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
				if(c2) free(c2);
				if(m2) free(m2);
				if(y2) free(y2);
				if(t->sbc) free(t->sbc); if(t->soff) free(t->soff);
				return(0);
			}
		}
		else if(t->ms)
		{
			m2=m=(unsigned char*)calloc(siz, 1);
			if(!m2)
			{
				form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
				if(t->sbc) free(t->sbc); if(t->soff) free(t->soff);
				return(0);
			}
		}		
	}
	else
	{
		if(t->l)
		{
			c=t->l->blue;
			y=t->l->yellow;
			m=t->l->red;
		}
		else if(t->ms)
		{
			m=t->ms->mask;
		}
		ldif=first_lay->this.word_width-t->width;

		if((frame_data.ok) && (frame_data.vis))
		{
			off=(long)((long)frame_data.y*(long)first_lay->this.word_width);
			off+=(long)frame_data.x;
			c+=off; m+=off; y+=off; mask+=off;
		}
	}
	
	if(!(t->sbc))
	{ /* Strip Byte Counts wurde nicht angegeben */
		t->sbc=(long*)malloc(sizeof(long));
		if(!(t->sbc))
		{
			form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
			if(t->sbc) free(t->sbc); if(t->soff) free(t->soff);
			return(0);
		}
		t->rps=t->height;
		if(t->photint == 2)
			t->sbc[0]=t->rps*t->width*3;
		else if(t->photint == 5)
			t->sbc[0]=t->rps*t->width*4;
	}
	
	while(a < t->snum)
	{
		timeshow(a, t->snum);
		Fseek(t->soff[a], t->fh, 0);
		buf=(unsigned char*)malloc(t->sbc[a]);
		if(buf)
		{
			Fread(t->fh, t->sbc[a], buf);

			if(t->l)
			{
				if(t->photint == 2)	/* RGB_Streifen in Layer */
					tiff_rgb_stripe_l(t->sbc[a]/t->width/3, t->width, ldif, buf, &c, &m, &y, &mask, mode);
				else if(t->photint == 5)	/* CMYK-Streifen in Layer */
					tiff_cmyk_stripe_l(t->sbc[a]/t->width/4, t->width, ldif, buf, &c, &m, &y, &mask, mode);
			}
			else if(t->ms)
			{
				if(t->photint == 2)	/* RGB_Streifen in Maske */
					tiff_rgb_stripe_m(t->sbc[a]/t->width/3, t->width, ldif, buf, &m, mode);
				else if(t->photint == 5)	/* CMYK-Streifen in Maske */
					tiff_cmyk_stripe_m(t->sbc[a]/t->width/4, t->width, ldif, buf, &m, mode);
			}
			
		}
		else
		{
			form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
			if(t->sbc) free(t->sbc); if(t->soff) free(t->soff);
			if(scale_it)
			{
				if(t->l)
				{ free(c2); free(m2); free(y2);}
				else if(t->ms)
					free(m2);
			}
			timeoff();
			return(0);
		}
		free(buf);
		++a;
	}

	timeoff();

	if(scale_it)
	{
		m=m2; c=c2; y=y2;
		if(t->l)
		{
			c2=t->l->blue;
			y2=t->l->yellow;
			m2=t->l->red;
		}
		else if(t->ms)
		{
			m2=t->ms->mask;
		}
		
		if((frame_data.ok) && (frame_data.vis))
		{
			off=(long)((long)frame_data.y*(long)first_lay->this.word_width);
			off+=(long)frame_data.x;
			c2+=off; m2+=off; y2+=off;
			sc_w=frame_data.w;
			sc_h=frame_data.h;
		}
		else
		{
			sc_w=main_x_scale; sc_h=main_y_scale;
		}
		
		ldif=first_lay->this.word_width-sc_w;

		if(t->mode && (otoolbar[MASK_ON-1].ob_state & SELECTED))
		{
			mask=act_mask->this.mask;
			mask+=off;
		}
		else
			mask=NULL;
			
		/* Skalieren */
		if(t->l)
			scale_three(c, m, y, c2, m2, y2, mask, (int)t->width, (int)t->height, sc_w, sc_h, ldif, t->mode);
		else if(t->ms)
			scale_one(m, m2, (int)t->width, (int)t->height, sc_w, sc_h, ldif, t->mode);
		
		free(c);
		free(m);
		free(y);
	}

	if(t->sbc) free(t->sbc); if(t->soff) free(t->soff);
	
	return(1);
}

void tiff_rgb_stripe_l(long rps, long width, long ldif, unsigned char *buf, unsigned char **cc, unsigned char **mm, unsigned char **yy, unsigned char **maske, int mode)
{
	long hc, wc, b=0;
	register unsigned char *c=*cc, *m=*mm, *y=*yy, *ms=*maske;
	register unsigned char cx, mx, yx, mv;
	register unsigned char *d_tab;
 	register unsigned int	*m_tab1, *m_tab2, z1, z2, z3;
 	register unsigned int	**m_tabs;
 	m_tabs=mul_adr;
 	d_tab=div_tab;
	
	if(mode)
	{
		if(otoolbar[MASK_ON-1].ob_state & SELECTED)
		{/* Maske beachten */
			if(opmode[PM1].ob_state & SELECTED)
			{/* Transparent */
				for(hc=0; hc < rps; ++hc)
				{
					for(wc=0; wc < width; ++wc)
					{
						mv=*ms++;
						cx=255-buf[b++]; mx=255-buf[b++]; yx=255-buf[b++];
						if(cx > mv) cx-=mv;
						else cx=0;
						if(mx > mv) mx-=mv;
						else mx=0;
						if(yx > mv) yx-=mv;
						else yx=0;
						if(cx > *c++)
							*(c-1)=cx;
						if(mx > *m++)
							*(m-1)=mx;
						if(yx > *y++)
							*(y-1)=yx;
					}
					c+=ldif;
					y+=ldif;
					m+=ldif;
					ms+=ldif;
				}
			}
			else if(opmode[PM2].ob_state & SELECTED)
			{/* Deckend ohne weiû */
				for(hc=0; hc < rps; ++hc)
				{
					for(wc=0; wc < width; ++wc)
					{
						mv=*ms++;
						cx=255-buf[b++]; mx=255-buf[b++]; yx=255-buf[b++];

						if(cx || mx || yx)
						{
							m_tab1=m_tabs[mv]; m_tab2=m_tabs[255-mv];
							z1=m_tab1[cx]; z2=m_tab1[mx]; z3=m_tab1[yx];
							z1+=m_tab2[*c]; z2+=m_tab2[*m]; z3+=m_tab2[*y];
							*c++=d_tab[z1];
							*m++=d_tab[z2];
							*y++=d_tab[z3];
						}
						else
						{
							++c; ++m; ++y;
						}
					}
					c+=ldif;
					y+=ldif;
					m+=ldif;
					ms+=ldif;
				}
			}
			else
			{/* Deckend mit weiû */
				for(hc=0; hc < rps; ++hc)
				{
					for(wc=0; wc < width; ++wc)
					{
						mv=*ms++;
						cx=255-buf[b++]; mx=255-buf[b++]; yx=255-buf[b++];

						m_tab1=m_tabs[mv]; m_tab2=m_tabs[255-mv];
						z1=m_tab1[cx]; z2=m_tab1[mx]; z3=m_tab1[yx];
						z1+=m_tab2[*c]; z2+=m_tab2[*m]; z3+=m_tab2[*y];
						*c++=d_tab[z1];
						*m++=d_tab[z2];
						*y++=d_tab[z3];
					}
					c+=ldif;
					y+=ldif;
					m+=ldif;
					ms+=ldif;
				}
			}
		}
		else
		{/* Maske ignorieren */
			if(opmode[PM1].ob_state & SELECTED)
			{/* Transparent */
				for(hc=0; hc < rps; ++hc)
				{
					for(wc=0; wc < width; ++wc)
					{
						cx=255-buf[b++]; mx=255-buf[b++]; yx=255-buf[b++];
						if(cx > *c++)
							*(c-1)=cx;
						if(mx > *m++)
							*(m-1)=mx;
						if(yx > *y++)
							*(y-1)=yx;
					}
					c+=ldif;
					y+=ldif;
					m+=ldif;
				}
			}
			else if(opmode[PM2].ob_state & SELECTED)
			{/* Deckend ohne weiû */
				for(hc=0; hc < rps; ++hc)
				{
					for(wc=0; wc < width; ++wc)
					{
						cx=255-buf[b++]; mx=255-buf[b++]; yx=255-buf[b++];
						if(cx || mx || yx)
						{
							*c++=cx;
							*m++=mx;
							*y++=yx;
						}
						else
						{
							++c; ++m; ++y;
						}
					}
					c+=ldif;
					y+=ldif;
					m+=ldif;
				}
			}
			else
			{/* Deckend mit weiû */
				for(hc=0; hc < rps; ++hc)
				{
					for(wc=0; wc < width; ++wc)
					{
						*c++=255-buf[b++];
						*m++=255-buf[b++];
						*y++=255-buf[b++];
					}
					c+=ldif;
					y+=ldif;
					m+=ldif;
				}
			}
		}
	}
	else for(hc=0; hc < rps; ++hc)
	{
		for(wc=0; wc < width; ++wc)
		{
			*c++=255-buf[b++];
			*m++=255-buf[b++];
			*y++=255-buf[b++];
		}
		c+=ldif;
		y+=ldif;
		m+=ldif;
	}
	
	*cc=c; *mm=m; *yy=y; *maske=ms;
}

void tiff_cmyk_stripe_l(long rps, long width, long ldif, unsigned char *buf, unsigned char **cc, unsigned char **mm, unsigned char **yy, unsigned char **maske, int mode)
{
	long hc, wc, b=0;
	register unsigned char *c=*cc, *m=*mm, *y=*yy, *ms=*maske;
	register unsigned char cx, mx, yx, mv;
	register unsigned char *d_tab;
 	register unsigned int	*m_tab1, *m_tab2, z1, z2, z3;
 	register unsigned int	**m_tabs;
 	m_tabs=mul_adr;
 	d_tab=div_tab;
		
	if(mode)
	{
		if(otoolbar[MASK_ON-1].ob_state & SELECTED)
		{/* Maske beachten */
			if(opmode[PM1].ob_state & SELECTED)
			{/* Transparent (wie deckend ohne weiû solange ich CMYK nicht
					umrechnen kann */
				for(hc=0; hc < rps; ++hc)
				{
					for(wc=0; wc < width; ++wc)
					{
						mv=*ms++;
						cx=buf[b++]; mx=buf[b++]; yx=buf[b++];
						if(cx+buf[b] > 255) cx=255;
						else cx+=buf[b];
						if(mx+buf[b] > 255) mx=255;
						else mx+=buf[b];
						if(yx+buf[b] > 255) mx=255;
						else mx+=buf[b];
						++b;

						if(cx || mx || yx)
						{
							m_tab1=m_tabs[mv]; m_tab2=m_tabs[255-mv];
							z1=m_tab1[cx]; z2=m_tab1[mx]; z3=m_tab1[yx];
							z1+=m_tab2[*c]; z2+=m_tab2[*m]; z3+=m_tab2[*y];
							*c++=d_tab[z1];
							*m++=d_tab[z2];
							*y++=d_tab[z3];
						}
						else
						{
							++c; ++m; ++y;
						}
					}
					c+=ldif;
					y+=ldif;
					m+=ldif;
					ms+=ldif;
				}
			}
			else if(opmode[PM2].ob_state & SELECTED)
			{/* Deckend ohne weiû */
				for(hc=0; hc < rps; ++hc)
				{
					for(wc=0; wc < width; ++wc)
					{
						mv=*ms++;
						cx=buf[b++]; mx=buf[b++]; yx=buf[b++];
						if(cx+buf[b] > 255) cx=255;
						else cx+=buf[b];
						if(mx+buf[b] > 255) mx=255;
						else mx+=buf[b];
						if(yx+buf[b] > 255) mx=255;
						else mx+=buf[b];
						++b;

						if(cx || mx || yx)
						{
							m_tab1=m_tabs[mv]; m_tab2=m_tabs[255-mv];
							z1=m_tab1[cx]; z2=m_tab1[mx]; z3=m_tab1[yx];
							z1+=m_tab2[*c]; z2+=m_tab2[*m]; z3+=m_tab2[*y];
							*c++=d_tab[z1];
							*m++=d_tab[z2];
							*y++=d_tab[z3];
						}
						else
						{
							++c; ++m; ++y;
						}
					}
					c+=ldif;
					y+=ldif;
					m+=ldif;
					ms+=ldif;
				}
			}
			else
			{/* Deckend mit weiû */
				for(hc=0; hc < rps; ++hc)
				{
					for(wc=0; wc < width; ++wc)
					{
						mv=*ms++;
						cx=buf[b++]; mx=buf[b++]; yx=buf[b++];
						if(cx+buf[b] > 255) cx=255;
						else cx+=buf[b];
						if(mx+buf[b] > 255) mx=255;
						else mx+=buf[b];
						if(yx+buf[b] > 255) mx=255;
						else mx+=buf[b];
						++b;

						m_tab1=m_tabs[mv]; m_tab2=m_tabs[255-mv];
						z1=m_tab1[cx]; z2=m_tab1[mx]; z3=m_tab1[yx];
						z1+=m_tab2[*c]; z2+=m_tab2[*m]; z3+=m_tab2[*y];
						*c++=d_tab[z1];
						*m++=d_tab[z2];
						*y++=d_tab[z3];
					}
					c+=ldif;
					y+=ldif;
					m+=ldif;
					ms+=ldif;
				}
			}
		}
		else
		{/* Maske ignorieren */
			if(opmode[PM1].ob_state & SELECTED)
			{/* Transparent (wie deckend ohne weiû solange ich CMYK nicht
					umrechnen kann */
				for(hc=0; hc < rps; ++hc)
				{
					for(wc=0; wc < width; ++wc)
					{
						if(buf[b] || buf[b+1] || buf[b+2])
						{
							*c=buf[b++];
							*m=buf[b++];
							*y=buf[b++];
							if(*c+buf[b] > 255) *c=255;
							else *c+=buf[b];
							if(*m+buf[b] > 255) *m=255;
							else *m+=buf[b];
							if(*y+buf[b] > 255) *y=255;
							else *y+=buf[b];
						}
						else
							b+=3;
						++c; ++m; ++y;
						b++;
					}
					c+=ldif;
					y+=ldif;
					m+=ldif;
				}
			}
			else if(opmode[PM2].ob_state & SELECTED)
			{/* Deckend ohne weiû */
				for(hc=0; hc < rps; ++hc)
				{
					for(wc=0; wc < width; ++wc)
					{
						if(buf[b] || buf[b+1] || buf[b+2])
						{
							*c=buf[b++];
							*m=buf[b++];
							*y=buf[b++];
							if(*c+buf[b] > 255) *c=255;
							else *c+=buf[b];
							if(*m+buf[b] > 255) *m=255;
							else *m+=buf[b];
							if(*y+buf[b] > 255) *y=255;
							else *y+=buf[b];
						}
						else
							b+=3;
						++c; ++m; ++y;
						b++;
					}
					c+=ldif;
					y+=ldif;
					m+=ldif;
				}
			}
			else
			{/* Deckend mit weiû */
				for(hc=0; hc < rps; ++hc)
				{
					for(wc=0; wc < width; ++wc)
					{
						*c=buf[b++];
						*m=buf[b++];
						*y=buf[b++];
						if(*c+buf[b] > 255) *c=255;
						else *c+=buf[b];
						if(*m+buf[b] > 255) *m=255;
						else *m+=buf[b];
						if(*y+buf[b] > 255) *y=255;
						else *y+=buf[b];
						++c; ++m; ++y;
						b++;
					}
					c+=ldif;
					y+=ldif;
					m+=ldif;
				}
			}
		}
	}
	else for(hc=0; hc < rps; ++hc)
	{
		for(wc=0; wc < width; ++wc)
		{
			*c=buf[b++];
			*m=buf[b++];
			*y=buf[b++];
			if(*c+buf[b] > 255) *c=255;
			else *c+=buf[b];
			if(*m+buf[b] > 255) *m=255;
			else *m+=buf[b];
			if(*y+buf[b] > 255) *y=255;
			else *y+=buf[b];
			++c; ++m; ++y;
			b++;
		}
		c+=ldif;
		y+=ldif;
		m+=ldif;
	}
	
	*cc=c; *mm=m; *yy=y; *maske=ms;
}

void tiff_rgb_stripe_m(long rps, long width, long ldif, unsigned char *buf, unsigned char **mm, int mode)
{
	long hc, wc, b=0;
	unsigned char *m=*mm;
	unsigned int	mc;
	
	if(mode)
	{	/* EinfÅgemodus beachten */
		if(opmode[PM1].ob_state & SELECTED)
		{/* Transparent */
			for(hc=0; hc < rps; ++hc)
			{
				for(wc=0; wc < width; ++wc)
				{
					/* RGB->Grey Hibyte(77*R+151*G+28*B) */
					mc=77*buf[b++]+151*buf[b++]+28*buf[b++];
					mc=mc >> 8;
					mc=255-mc;
					if(mc > *m)
						*m++=mc;
					else
						++m;
				}
				m+=ldif;
			}
		}
		else if(opmode[PM2].ob_state & SELECTED)
		{/* Deckend ohne weiû */
			for(hc=0; hc < rps; ++hc)
			{
				for(wc=0; wc < width; ++wc)
				{
					/* RGB->Grey Hibyte(77*R+151*G+28*B) */
					mc=77*buf[b++]+151*buf[b++]+28*buf[b++];
					mc=mc >> 8;
					mc=255-mc;
					if(mc)
						*m++=mc;
					else
						++m;
				}
				m+=ldif;
			}
		}
		else
		{/* Deckend mit weiû */
			for(hc=0; hc < rps; ++hc)
			{
				for(wc=0; wc < width; ++wc)
				{
					/* RGB->Grey Hibyte(77*R+151*G+28*B) */
					mc=77*buf[b++]+151*buf[b++]+28*buf[b++];
					mc=mc >> 8;
					*m++=255-mc;
				}
				m+=ldif;
			}
		}
	}
	else for(hc=0; hc < rps; ++hc)
	{
		for(wc=0; wc < width; ++wc)
		{
			/* RGB->Grey Hibyte(77*R+151*G+28*B) */
			mc=77*buf[b++]+151*buf[b++]+28*buf[b++];
			mc=mc >> 8;
			*m++=255-mc;
		}
		m+=ldif;
	}

	*mm=m;
}

void tiff_cmyk_stripe_m(long rps, long width, long ldif, unsigned char *buf, unsigned char **mm, int mode)
{
	long hc, wc, b=0;
	unsigned char *m=*mm;
	unsigned int	mr, mg, mb, mc, mmc, mmm, mmy;

	if(mode)
	{ /* EinfÅgemodus beachten */
		if(opmode[PM1].ob_state & SELECTED)
		{/* Transparent */
			for(hc=0; hc < rps; ++hc)
			{
				for(wc=0; wc < width; ++wc)
				{
					mmc=buf[b++];
					mmm=buf[b++];
					mmy=buf[b++];
					if(mmc+buf[b] > 255) mmc=255;
					else mmc+=buf[b];
					if(mmm+buf[b] > 255) mmm=255;
					else mmm+=buf[b];
					if(mmy+buf[b] > 255) mmy=255;
					else mmy+=buf[b];
					mr=255-mmc;
					mg=255-mmm;
					mb=255-mmy;
					mc=77*mr+151*mg+28*mb;
					mc=mc >> 8;
					mc=255-mc;
					if(mc > *m)
						*m++=mc;
					else
						++m;
					b++;
				}
				m+=ldif;
			}
		}
		else if(opmode[PM2].ob_state & SELECTED)
		{/* Deckend ohne weiû */
			for(hc=0; hc < rps; ++hc)
			{
				for(wc=0; wc < width; ++wc)
				{
					mmc=buf[b++];
					mmm=buf[b++];
					mmy=buf[b++];
					if(mmc+buf[b] > 255) mmc=255;
					else mmc+=buf[b];
					if(mmm+buf[b] > 255) mmm=255;
					else mmm+=buf[b];
					if(mmy+buf[b] > 255) mmy=255;
					else mmy+=buf[b];
					mr=255-mmc;
					mg=255-mmm;
					mb=255-mmy;
					mc=77*mr+151*mg+28*mb;
					mc=mc >> 8;
					mc=255-mc;
					if(mc)
						*m++=mc;
					else
						++m;
					b++;
				}
				m+=ldif;
			}
		}
		else
		{/* Deckend mit weiû */
			for(hc=0; hc < rps; ++hc)
			{
				for(wc=0; wc < width; ++wc)
				{
					mmc=buf[b++];
					mmm=buf[b++];
					mmy=buf[b++];
					if(mmc+buf[b] > 255) mmc=255;
					else mmc+=buf[b];
					if(mmm+buf[b] > 255) mmm=255;
					else mmm+=buf[b];
					if(mmy+buf[b] > 255) mmy=255;
					else mmy+=buf[b];
					mr=255-mmc;
					mg=255-mmm;
					mb=255-mmy;
					mc=77*mr+151*mg+28*mb;
					mc=mc >> 8;
					*m++=255-mc;
					b++;
				}
				m+=ldif;
			}
		}
	}
	else for(hc=0; hc < rps; ++hc)
	{
		for(wc=0; wc < width; ++wc)
		{
			mmc=buf[b++];
			mmm=buf[b++];
			mmy=buf[b++];
			if(mmc+buf[b] > 255) mmc=255;
			else mmc+=buf[b];
			if(mmm+buf[b] > 255) mmm=255;
			else mmm+=buf[b];
			if(mmy+buf[b] > 255) mmy=255;
			else mmy+=buf[b];
			mr=255-mmc;
			mg=255-mmm;
			mb=255-mmy;
			mc=77*mr+151*mg+28*mb;
			mc=mc >> 8;
			*m++=255-mc;
			b++;
		}
		m+=ldif;
	}
	*mm=m;
}

int esm_import(int fh, LAYER *l, MASK *ms, int mode)
{
	unsigned char t_red[256], t_green[256], t_blue[256], dum[40], *buf;
	unsigned char *c, *y, *m, *c2, *y2, *m2;
	int		head, w, h, ver, d, art, sc_w, sc_h, amode=mode;
	long	siz, ad_w, off, t_h, bsiz=1048576l; /* Puffergrîûe = 100K */
	int		scale_it=0, main_x_scale, main_y_scale;
	unsigned char *maske=act_mask->this.mask;
	
	Fread(fh, 4, dum); /* Esm-ID */
	Fread(fh, 2, &head);
	Fread(fh, 2, &w);
	Fread(fh, 2, &h);
	if((frame_data.ok) && (frame_data.vis))
	{
		if((w != frame_data.w) || (h != frame_data.h))
			scale_it=1;	/* Ungleich Rahmengrîûe->Skalieren */
	}
	else if((w > first_lay->this.width) || (h > first_lay->this.height))
	{ /* Grîûer als Hauptdatei */
		if(too_big_alert(w, h, &main_x_scale, &main_y_scale))
		{
			set_frame_size(0,0,main_x_scale,main_y_scale);
			scale_it=1;
		}
		else
			return(0);
	}
	else
		set_frame_size(0,0,w,h);
	
	Fread(fh, 2, &d);
	if(d != 24)
	{
		form_alert(1,"[3][Grape:|Es kînnen nur 24-Bit ESM-|Dateien importiert werden.][Abbruch]");
		return(0);
	}
	Fread(fh, 2, &art);
	if(art == 3) art=6; /* Calamus Export speichert RGB als 24-Bit "Farbbild" (=art 3) */
	if((art != 4) && (art != 6))
	{
		form_alert(1,"[3][Grape:|Es kînnen nur RGB- oder CMY-|ESM-Dateien importiert werden.][Abbruch]");
		return(0);
	}
	/* Farbtiefen r/g/b/s */
	Fread(fh, 8, dum);
	
	Fread(fh, 2, &ver);
	
	/* x/y DPI */
	Fread(fh, 4, dum);
	
	if(ver >= 3)
	{/* Streifen */
		Fread(fh, 2, &d);
		if(d != h)
		{
			form_alert(1,"[3][Grape:|ESM-Streifen werden nicht|unterstÅtzt.][Abbruch]");
		}
		Fread(fh, 4, dum);
	}
	
	if(ver >= 4)
	{/* Maske */
		Fread(fh, 2, &d);
		/* Clut */
		Fread(fh, 256, t_red);
		Fread(fh, 256, t_green);
		Fread(fh, 256, t_blue);
	}
	
	Fseek(head, fh, 0);
	
	if(!frame_to_undo_ws(l, ms))
		return(0);

	if(scale_it)
	{
		ad_w=0;
		siz=(long)w*(long)h;
		if(l)
		{
			c2=c=(unsigned char*)calloc(siz, 1);
			m2=m=(unsigned char*)calloc(siz, 1);
			y2=y=(unsigned char*)calloc(siz, 1);
			if((!c2) || (!m2) || (!y2))
			{
				form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
				if(c2) free(c2);
				if(m2) free(m2);
				if(y2) free(y2);
				return(0);
			}
		}
		else if(ms)
		{
			m2=m=(unsigned char*)calloc(siz, 1);
			if(!m2)
			{
				form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
				return(0);
			}
		}		
	}
	else
	{
		ad_w=first_lay->this.word_width-w;
	
		if(l)
		{
			c=l->blue;
			y=l->yellow;
			m=l->red;
		}
		else if(ms)
		{
			m=ms->mask;
		}
		
		if((frame_data.ok) && (frame_data.vis))
		{
			off=(long)((long)frame_data.y*(long)first_lay->this.word_width);
			off+=(long)frame_data.x;
			c+=off; m+=off; y+=off; maske+=off;
		}
	}

	bsiz/=(w*3);	/* Puffergrîûe auf nÑchstniedrigen Zeilenwert runden */
	bsiz*=(w*3);
	buf=(unsigned char*)malloc(bsiz);
	if(!buf)
	{
		form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
		if(scale_it)
		{
			if(l)
			{free(c2); free(m2); free(y2);}
			else if(ms)
				free(m2);
		}
		return(0);
	}
	
	/* Datei einlesen */
	if(scale_it) amode=0; /* Wird ja eh bloû in den Puffer kopiert */
	
	if(l)
	{
		if(art == 6)
		{ /* RGB */
			do
			{
				t_h=Fread(fh, bsiz, buf);
				if(t_h < 0)
				{
					Fclose(fh);
					form_alert(1,"[3][Grape:|Fehler beim Lesen der Datei!][Abbruch]");
					free(buf);
					if(scale_it) {	free(c2); free(m2); free(y2);}
					return(0);
				}
				t_h/=(w*3);
				esm_rgb_stripe_l(t_h, w, ad_w, buf, &c, &m, &y, &maske, amode);
			}
			while(t_h);
		}
		else if(art == 4)
		{/* CMY */
			do
			{
				t_h=Fread(fh, bsiz, buf);
				if(t_h < 0)
				{
					Fclose(fh);
					form_alert(1,"[3][Grape:|Fehler beim Lesen der Datei!][Abbruch]");
					free(buf);
					if(scale_it)	{free(c2); free(m2); free(y2);}
					return(0);
				}
				t_h/=(w*3);				
				esm_cmy_stripe_l(t_h, w, ad_w, buf, &c, &m, &y, &maske, amode);
			}
			while(t_h);
		}
	}
	else if(ms)
	{
		if(art == 6)
		{ /* RGB */
			do
			{
				t_h=Fread(fh, bsiz, buf);
				if(t_h < 0)
				{
					Fclose(fh);
					form_alert(1,"[3][Grape:|Fehler beim Lesen der Datei!][Abbruch]");
					free(buf);
					if(scale_it)	free(m2);
					return(0);
				}
				t_h/=(w*3);
				esm_rgb_stripe_m(t_h, w, ad_w, buf, &m, amode);
			}
			while(t_h);
		}
		else if(art == 4)
		{/* CMY */
			do
			{
				t_h=Fread(fh, bsiz, buf);
				if(t_h < 0)
				{
					Fclose(fh);
					form_alert(1,"[3][Grape:|Fehler beim Lesen der Datei!][Abbruch]");
					free(buf);
					if(scale_it)	free(m2);
					return(0);
				}
				t_h/=(w*3);				
				esm_cmy_stripe_m(t_h, w, ad_w, buf, &m, amode);
			}
			while(t_h);
		}
	}

	if(scale_it)
	{
		m=m2; c=c2; y=y2;
		if(l)
		{
			c2=l->blue;
			y2=l->yellow;
			m2=l->red;
		}
		else if(ms)
		{
			m2=ms->mask;
		}
		
		if((frame_data.ok) && (frame_data.vis))
		{
			off=(long)((long)frame_data.y*(long)first_lay->this.word_width);
			off+=(long)frame_data.x;
			c2+=off; m2+=off; y2+=off;
			sc_w=frame_data.w;
			sc_h=frame_data.h;
		}
		else
		{
			sc_w=main_x_scale; sc_h=main_y_scale;
		}
		
		ad_w=first_lay->this.word_width-sc_w;

		if(mode && (otoolbar[MASK_ON-1].ob_state & SELECTED))
		{
			maske=act_mask->this.mask;
			maske+=off;
		}
		else
			maske=NULL;

		/* Skalieren */
		if(l)
			scale_three(c, m, y, c2, m2, y2, maske, w, h, sc_w, sc_h, ad_w, mode);
		else if(ms)
			scale_one(m, m2, w, h, sc_w, sc_h, ad_w, mode);
		
		free(c);
		free(m);
		free(y);
	}
	
	free(buf);
	return(1);
}

void esm_rgb_stripe_l(long t_h, long w, long ad_w, unsigned char *buf, unsigned char **cc, unsigned char **mm, unsigned char **yy, unsigned char **maske, int mode)
{
	long	a, b=0;
	register long	x;
	register unsigned char *c=*cc, *m=*mm, *y=*yy, *ms=*maske;
	register unsigned char cx, mx, yx, mv;
	register unsigned char *d_tab;
 	register unsigned int	*m_tab1, *m_tab2, z1, z2, z3;
 	register unsigned int	**m_tabs;
 	m_tabs=mul_adr;
 	d_tab=div_tab;
	
	if(mode)
	{
		if(otoolbar[MASK_ON-1].ob_state & SELECTED)
		{/* Maske beachten */
			if(opmode[PM1].ob_state & SELECTED)
			{/* Transparent */
				for(a=0; a < t_h; ++a)
				{
					for(x=0; x < w; ++x)
					{
						mv=*ms++;
						cx=255-buf[b++]; mx=255-buf[b++]; yx=255-buf[b++];
						if(cx > mv) cx-=mv;
						else cx=0;
						if(mx > mv) mx-=mv;
						else mx=0;
						if(yx > mv) yx-=mv;
						else yx=0;

						if(cx > *c++)
							*(c-1)=cx;
						if(mx > *m++)
							*(m-1)=mx;
						if(yx > *y++)
							*(y-1)=yx;
					}
					c+=ad_w;
					m+=ad_w;
					y+=ad_w;
					ms+=ad_w;
				}
			}
			else if(opmode[PM2].ob_state & SELECTED)
			{/* Deckend ohne weiû */
				for(a=0; a < t_h; ++a)
				{
					for(x=0; x < w; ++x)
					{
						mv=*ms++;
						cx=255-buf[b++]; mx=255-buf[b++]; yx=255-buf[b++];
						if(cx || mx || yx)
						{
							m_tab1=m_tabs[mv]; m_tab2=m_tabs[255-mv];
							z1=m_tab1[cx]; z2=m_tab1[mx]; z3=m_tab1[yx];
							z1+=m_tab2[*c]; z2+=m_tab2[*m]; z3+=m_tab2[*y];
							*c++=d_tab[z1];
							*m++=d_tab[z2];
							*y++=d_tab[z3];
						}
						else
						{	++c; ++m; ++y;}
					}
					c+=ad_w;
					m+=ad_w;
					y+=ad_w;
					ms+=ad_w;
				}
			}
			else
			{/* Deckend mit weiû */
				for(a=0; a < t_h; ++a)
				{
					for(x=0; x < w; ++x)
					{
						mv=*ms++;
						cx=255-buf[b++]; mx=255-buf[b++]; yx=255-buf[b++];
						m_tab1=m_tabs[mv]; m_tab2=m_tabs[255-mv];
						z1=m_tab1[cx]; z2=m_tab1[mx]; z3=m_tab1[yx];
						z1+=m_tab2[*c]; z2+=m_tab2[*m]; z3+=m_tab2[*y];
						*c++=d_tab[z1];
						*m++=d_tab[z2];
						*y++=d_tab[z3];
					}
					c+=ad_w;
					m+=ad_w;
					y+=ad_w;
					ms+=ad_w;
				}
			}
		}
		else
		{/* Maske ignorieren */
			if(opmode[PM1].ob_state & SELECTED)
			{/* Transparent */
				for(a=0; a < t_h; ++a)
				{
					for(x=0; x < w; ++x)
					{
						cx=255-buf[b++]; mx=255-buf[b++]; yx=255-buf[b++];
						if(cx > *c++)
							*(c-1)=cx;
						if(mx > *m++)
							*(m-1)=mx;
						if(yx > *y++)
							*(y-1)=yx;
					}
					c+=ad_w;
					m+=ad_w;
					y+=ad_w;
				}
			}
			else if(opmode[PM2].ob_state & SELECTED)
			{/* Deckend ohne weiû */
				for(a=0; a < t_h; ++a)
				{
					for(x=0; x < w; ++x)
					{
						cx=255-buf[b++]; mx=255-buf[b++]; yx=255-buf[b++];
						if(cx || mx || yx)
						{
							*c++=cx;
							*m++=mx;
							*y++=yx;
						}
						else
						{	++c; ++m; ++y;}
					}
					c+=ad_w;
					m+=ad_w;
					y+=ad_w;
				}
			}
			else
			{/* Deckend mit weiû */
				for(a=0; a < t_h; ++a)
				{
					for(x=0; x < w; ++x)
					{
						*c++=255-buf[b++];
						*m++=255-buf[b++];
						*y++=255-buf[b++];
					}
					c+=ad_w;
					m+=ad_w;
					y+=ad_w;
				}
			}
		}
	}
	else for(a=0; a < t_h; ++a)
	{
		for(x=0; x < w; ++x)
		{
			*c++=255-buf[b++];
			*m++=255-buf[b++];
			*y++=255-buf[b++];
		}
		c+=ad_w;
		m+=ad_w;
		y+=ad_w;
	}
				
	*cc=c; *mm=m, *yy=y; *maske=ms;
}

void esm_cmy_stripe_l(long t_h, long w, long ad_w, unsigned char *buf, unsigned char **cc, unsigned char **mm, unsigned char **yy, unsigned char **maske, int mode)
{
	long	a, b=0;
	register long	x;
	register unsigned char *c=*cc, *m=*mm, *y=*yy, *ms=*maske;
	register unsigned char cx, mx, yx, mv;
	register unsigned char *d_tab;
 	register unsigned int	*m_tab1, *m_tab2, z1, z2, z3;
 	register unsigned int	**m_tabs;
 	m_tabs=mul_adr;
 	d_tab=div_tab;
	
	if(mode)
	{
		if(otoolbar[MASK_ON-1].ob_state & SELECTED)
		{/* Maske beachten */
			if(opmode[PM1].ob_state & SELECTED)
			{/* Transparent */
				for(a=0; a < t_h; ++a)
				{
					for(x=0; x < w; ++x)
					{
						mv=*ms++;
						cx=buf[b++]; mx=buf[b++]; yx=buf[b++];
						if(cx > mv) cx-=mv;
						else cx=0;
						if(mx > mv) mx-=mv;
						else mx=0;
						if(yx > mv) yx-=mv;
						else yx=0;
						if(cx > *c++)
							*(c-1)=cx;
						if(mx > *m++)
							*(m-1)=mx;
						if(yx > *y++)
							*(y-1)=yx;
					}
					c+=ad_w;
					m+=ad_w;
					y+=ad_w;
					ms+=ad_w;
				}
			}
			else if(opmode[PM2].ob_state & SELECTED)
			{/* Deckend ohne weiû */
				for(a=0; a < t_h; ++a)
				{
					for(x=0; x < w; ++x)
					{
						mv=*ms++;
						cx=buf[b++]; mx=buf[b++]; yx=buf[b++];
						if(cx || mx || yx)
						{
							m_tab1=m_tabs[mv]; m_tab2=m_tabs[255-mv];
							z1=m_tab1[cx]; z2=m_tab1[mx]; z3=m_tab1[yx];
							z1+=m_tab2[*c]; z2+=m_tab2[*m]; z3+=m_tab2[*y];
							*c++=d_tab[z1];
							*m++=d_tab[z2];
							*y++=d_tab[z3];
						}
						else
						{	++c; ++m; ++y;}
					}
					c+=ad_w;
					m+=ad_w;
					y+=ad_w;
					ms+=ad_w;
				}
			}
			else
			{/* Deckend mit weiû */
				for(a=0; a < t_h; ++a)
				{
					for(x=0; x < w; ++x)
					{
						mv=*ms++;
						cx=buf[b++]; mx=buf[b++]; yx=buf[b++];
						m_tab1=m_tabs[mv]; m_tab2=m_tabs[255-mv];
						z1=m_tab1[cx]; z2=m_tab1[mx]; z3=m_tab1[yx];
						z1+=m_tab2[*c]; z2+=m_tab2[*m]; z3+=m_tab2[*y];
						*c++=d_tab[z1];
						*m++=d_tab[z2];
						*y++=d_tab[z3];
					}
					c+=ad_w;
					m+=ad_w;
					y+=ad_w;
					ms+=ad_w;
				}
			}
		}
		else
		{/* Maske ignorieren */
			if(opmode[PM1].ob_state & SELECTED)
			{/* Transparent */
				for(a=0; a < t_h; ++a)
				{
					for(x=0; x < w; ++x)
					{
						cx=buf[b++]; mx=buf[b++]; yx=buf[b++];
						if(cx > *c++)
							*(c-1)=cx;
						if(mx > *m++)
							*(m-1)=mx;
						if(yx > *y++)
							*(y-1)=yx;
					}
					c+=ad_w;
					m+=ad_w;
					y+=ad_w;
				}
			}
			else if(opmode[PM2].ob_state & SELECTED)
			{/* Deckend ohne weiû */
				for(a=0; a < t_h; ++a)
				{
					for(x=0; x < w; ++x)
					{
						cx=buf[b++]; mx=buf[b++]; yx=buf[b++];
						if(cx || mx || yx)
						{
							*c++=cx;
							*m++=mx;
							*y++=yx;
						}
						else
						{	++c; ++m; ++y;}
					}
					c+=ad_w;
					m+=ad_w;
					y+=ad_w;
				}
			}
			else
			{/* Deckend mit weiû */
				for(a=0; a < t_h; ++a)
				{
					for(x=0; x < w; ++x)
					{
						*c++=buf[b++];
						*m++=buf[b++];
						*y++=buf[b++];
					}
					c+=ad_w;
					m+=ad_w;
					y+=ad_w;
				}
			}
		}
	}
	else for(a=0; a < t_h; ++a)
	{
		for(x=0; x < w; ++x)
		{
			*c++=buf[b++];
			*m++=buf[b++];
			*y++=buf[b++];
		}
		c+=ad_w;
		m+=ad_w;
		y+=ad_w;
	}
				
	*cc=c; *mm=m; *yy=y; *maske=ms;
}

void esm_rgb_stripe_m(long t_h, long w, long ad_w, unsigned char *buf, unsigned char **mm, int mode)
{
	register long	a, b=0;
	register long	x;
	register unsigned char *m=*mm;
	register unsigned int mc;
	
	if(mode)
	{/* EinfÅgemodus beachten */
		if(opmode[PM1].ob_state & SELECTED)
		{/* Transparent */
			for(a=0; a < t_h; ++a)
			{
				for(x=0; x < w; ++x)
				{
					/* RGB->Grey Hibyte(77*R+151*G+28*B) */
					mc=77*buf[b++]+151*buf[b++]+28*buf[b++];
					mc=mc >> 8;
					mc=255-mc;
					if(mc > *m)
						*m++=mc;
					else
						++m;
				}
				m+=ad_w;
			}
		}
		else if(opmode[PM2].ob_state & SELECTED)
		{/* Deckend ohne weiû */
			for(a=0; a < t_h; ++a)
			{
				for(x=0; x < w; ++x)
				{
					/* RGB->Grey Hibyte(77*R+151*G+28*B) */
					mc=77*buf[b++]+151*buf[b++]+28*buf[b++];
					mc=mc >> 8;
					mc=255-mc;
					if(mc)
						*m++=mc;
					else
						++m;
				}
				m+=ad_w;
			}
		}
		else
		{/* Deckend mit weiû */
			for(a=0; a < t_h; ++a)
			{
				for(x=0; x < w; ++x)
				{
					/* RGB->Grey Hibyte(77*R+151*G+28*B) */
					mc=77*buf[b++]+151*buf[b++]+28*buf[b++];
					mc=mc >> 8;
					*m++=255-mc;
				}
				m+=ad_w;
			}
		}
	}
	else for(a=0; a < t_h; ++a)
	{
		for(x=0; x < w; ++x)
		{
			/* RGB->Grey Hibyte(77*R+151*G+28*B) */
			mc=77*buf[b++]+151*buf[b++]+28*buf[b++];
			mc=mc >> 8;
			*m++=255-mc;
		}
		m+=ad_w;
	}
	
	*mm=m;
}

void esm_cmy_stripe_m(long t_h, long w, long ad_w, unsigned char *buf, unsigned char **mm, int mode)
{
	long	a, b=0;
	register long	x;
	register unsigned char *m=*mm;
	register unsigned int	mr, mg, mb, mc;
	
	if(mode)
	{ /* EinfÅgemodus beachten */
		if(opmode[PM1].ob_state & SELECTED)
		{/* Transparent */
			for(a=0; a < t_h; ++a)
			{
				for(x=0; x < w; ++x)
				{
		
					mr=255-buf[b++];
					mg=255-buf[b++];
					mb=255-buf[b++];
					mc=77*mr+151*mg+28*mb;
					mc=mc >> 8;
					mc=255-mc;
					if(mc > *m)
						*m++=mc;
					else
						++m;
				}
				m+=ad_w;
			}
		}
		else if(opmode[PM2].ob_state & SELECTED)
		{/* Deckend ohne weiû */
			for(a=0; a < t_h; ++a)
			{
				for(x=0; x < w; ++x)
				{
		
					mr=255-buf[b++];
					mg=255-buf[b++];
					mb=255-buf[b++];
					mc=77*mr+151*mg+28*mb;
					mc=mc >> 8;
					mc=255-mc;
					if(mc)
						*m++=mc;
					else
						++m;
				}
				m+=ad_w;
			}
		}
		else
		{/* Deckend mit weiû */
			for(a=0; a < t_h; ++a)
			{
				for(x=0; x < w; ++x)
				{
		
					mr=255-buf[b++];
					mg=255-buf[b++];
					mb=255-buf[b++];
					mc=77*mr+151*mg+28*mb;
					mc=mc >> 8;
					*m++=255-mc;
				}
				m+=ad_w;
			}
		}
	}
	else for(a=0; a < t_h; ++a)
	{
		for(x=0; x < w; ++x)
		{

			mr=255-buf[b++];
			mg=255-buf[b++];
			mb=255-buf[b++];
			mc=77*mr+151*mg+28*mb;
			mc=mc >> 8;
			*m++=255-mc;
		}
		m+=ad_w;
	}
	
	*mm=m;
}				
				
int layer_export(void)
{
	return(0);
}


int	quick_io(char *titel, char *path, void *load, void *save, long size, ulong magic)
{/* titel: Titel fÅr's q_io popup und Fileselector 
		path: 		FÅr Fileselector. path sollte Endung (*.* etc) enthalten
							(paths...-Objekte enthalten Maske)
							Path wird mit dem neuen Pfad Åberschrieben.
		load: 		Zeiger auf Speicherbereich, falls User LOAD wÑhlt
		save:			 -"-             -"-                   SAVE
		size:  		Grîûe des Load/Save-Bereichs. Ist size=0, wird die Datei
							nur zum Lesen	oder Schreiben geîffnet.
							Ist size=-1, wird nur das AnwÑhlen von LOAD erlaubt.
							Gelingt dies, wird das Dateihandle zurÅckgegeben.
							Wurde LOAD gewÑhlt, ist das Handle Positiv, sonst negativ
							sonst 0. ACHTUNG! Beim Laden ist <magic> schon geprÅft,
							beim Speichern schon geschrieben,der Dateizeiger also 
							4 Bytes weiter!
		magic:		4 Bytes, mÅssen am Dateianfang stehen, werden also
							beim Laden verglichen bzw. beim Speichern geschrieben
							
		Wenn die Funktion erfolgreich lÑdt wird QIOLOAD, beim Speichern
		QIOSAVE, sonst 0 geliefert.
	*/
	int x, y, dum, p;
	long	fh;
	ulong fmagic;
	char	mname[64], mpath[256], mtitel[256];
	OBJECT *oqio;

	xrsrc_gaddr(0,GQIO, &oqio, xrsrc);

	mname[0]=0;

	strcpy(mpath, path);
	strcpy(mtitel, titel);
	
	strncpy(oqio[QTITEL].ob_spec.tedinfo->te_ptext, titel, 21);
	if(size==-1)
	{
		oqio[QIOSAVE].ob_state &=(~SELECTABLE);
		oqio[QIOSAVE].ob_state |=DISABLED;
	}
	else
	{
		oqio[QIOSAVE].ob_state &=(~DISABLED);
		oqio[QIOSAVE].ob_state |=SELECTABLE;
	}

	graf_mkstate(&x, &y, &dum, &dum);
	p=form_popup(oqio, x, y);
	if((p==QIOLOAD) || (p==QIOSAVE))
	{
		if(p==QIOLOAD)
			strcat(mtitel, " îffnen");
		else
			strcat(mtitel, " sichern");
			
		if(f_sinput(mtitel, mpath, mname))
		{
			strcpy(path, mpath);
			make_path(mtitel, mpath, mname);
			strcpy(mpath, mtitel);
			if(p==QIOLOAD)
			{
				fh=Fopen(mpath, FO_READ);
				if(fh < 0)
					form_alert(1,"[3][Grape:|Fehler beim ôffnen der Datei!][Abbruch]");
				else
				{
					Fread((int)fh, sizeof(ulong), &fmagic);
					if(fmagic == magic)
					{
						if(size<=0) return((int)fh);
						
						wind_update(BEG_MCTRL);
						graf_mouse(BUSYBEE, NULL);
						
						Fread((int)fh, size, load);
						Fclose((int)fh);
						
						graf_mouse(ARROW, NULL);
						wind_update(END_MCTRL);
						
						return(QIOLOAD);
					}
					else
					{
						form_alert(1,"[3][Grape:|UngÅltiges Dateiformat!][Abbruch]");
						Fclose((int)fh);
					}
				}
			}
			else
			{
				fh=Fopen(mpath, FO_READ);
				if(fh >=0)
				{
					Fclose((int)fh);
					if(form_alert(1,"[2][Grape:|Die Datei existiert bereits.|Soll sie Åberschrieben werden?][OK|Abbruch]") == 2)
						/* Nicht Åberschreiben */
						return(0);
				}
				fh=Fcreate(mpath, 0);
				if(fh < 0)
					form_alert(1,"[3][Grape:|Fehler beim Anlegen der Datei!][Abbruch]");
				else
				{
					wind_update(BEG_MCTRL);
					graf_mouse(BUSYBEE, NULL);
						
					Fwrite((int)fh, sizeof(ulong), &magic);
					if(size==0)
					{
						graf_mouse(ARROW, NULL);
						wind_update(END_MCTRL);
					 	return(-(int)fh);
					}

					Fwrite((int)fh, size, save);
					Fclose((int)fh);
						
					graf_mouse(ARROW, NULL);
					wind_update(END_MCTRL);
						
					return(QIOSAVE);
				}
			}
		}
	}
	
	return(0);
}

int	f_input(char *spruch, char *path, char *name)
{
	/* ôffnet Fileselector und schreibt den Zugriffspfad
		 des Auswahlergebnisses in path */
		 
	char	*backslash;
	int		gb0, button, back;
	long	dum;
	
	gb0=_GemParBlk.global[0];
	wind_update(BEG_UPDATE);
	if ((gb0 >= 0x0140) || find_cookie('FSEL', &dum))
		back=fsel_exinput(path, name, &button, spruch);
	else
		back=fsel_input(path, name, &button);		
	wind_update(END_UPDATE);
	
	if (back)
	{
		if (button)
		{
			if (path[strlen(path)-1] != '\\')
			{
				backslash=strrchr(path, '\\');
				*(++backslash)=0;
			}
			
			strcat(path, name);
		}
		else
			back=0;
	}
	
	return(back);
}

int	f_sinput(char *spruch, char *path, char *name)
{
	/* ôffnet Fileselector und schreibt den Ergebnispfad
	   in path und den name in name
	   ( bzw. die Fsel_Routine macht das )
	*/
	
	int		gb0, button, back;
	long	dum;
	
	gb0=_GemParBlk.global[0];
	wind_update(BEG_UPDATE);
	if ((gb0 >= 0x0140) || find_cookie('FSEL', &dum))
		back=fsel_exinput(path, name, &button, spruch);
	else
		back=fsel_input(path, name, &button);		
	wind_update(END_UPDATE);
	
	if (back && button) return(1);
	
	return(0);
}

void	make_path(char *com, char *path, char *name)
{
	/* Bastelt aus dem Pfad mit z.B. Dateimaske und dem
	   Name einen fertigen Zugriffspfad und schreibt ihn 
	   in com
	 */

	char	*backslash;

	strcpy(com, path);
	
	if (com[strlen(com)-1] != '\\')
	{
		backslash=strrchr(com, '\\');
		*(++backslash)=0;
	}
	
	strcat(com, name);
}
