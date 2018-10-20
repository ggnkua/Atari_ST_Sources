#include <grape_h.h>
#include <atarierr.h>
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
#include "fiomod.h"
#include "varycopy.h"

FIO_LIST	*id_by_modules(FILE_DSCR *fd, int *result)
{/* Module durchchecken, ob einer fd beherrscht und best_match (als
		result)	so wie der Modulpointer werden zurÅckgeben */
	FIO_LIST	*fl=first_fiomod, *bmf=NULL;
	int	back, best_match=UNKNOWN;
	
	while(fl)
	{/* Erstmal nur Module testen, die auch laden kînnen */
		if(fl->fblk->mod_fn->load_file != NULL)
		{
			back=fl->fblk->mod_fn->identify(fd);
			Fseek(0,fd->fh,0);
			if(back > best_match)
			{
				best_match=(int)back;
				bmf=fl;
			}
		}
		fl=fl->next;
	}
	if(best_match==UNKNOWN)
	{/* Nochmal die Åbrigen Module durchgehen, vielleicht weiû ja
			jemand, was das ist */
		fl=first_fiomod;
		while(fl)
		{/* Nur Module testen, die nicht laden kînnen */
			if(fl->fblk->mod_fn->load_file == NULL)
			{
				back=fl->fblk->mod_fn->identify(fd);
				Fseek(0,fd->fh,0);
				if(back > best_match)
				{
					best_match=(int)back;
					bmf=fl;
				}
			}
			fl=fl->next;
		}
	}
	*result=best_match;
	return(bmf);
}


int load_file(void)
{
	/* ôffnet Datei aus paths.main_load 
		 1=Alles ok
		 0=Fehler oder sonstwas
	*/

	char	complete[256];
	int		old_undo=undo_on, best_match=UNKNOWN;
	long  fhl, fsize;
	long	back;
	uchar	buf[256];
	char	name[64], fd_path[128], *c;
	FILE_DSCR	fd;
	FIO_LIST	*bmf;
	
	make_path(complete, paths.main_load_path, paths.main_load_name);
	fhl=Fopen(complete, 0);
	if(fhl < 0)
	{
		form_alert(1,"[3][Grape:|Fehler beim ôffnen der Datei!][Abbruch]");
		return(0);
	}
	/* Zeiger auf Pfad etc.  setzen */
	strcpy(fd_path, paths.main_load_path);
	if (fd_path[strlen(fd_path)-1] != '\\')
	{
		c=strrchr(fd_path, '\\');
		*(++c)=0;
	}
	fd.path=fd_path;
	strcpy(name, paths.main_load_name);
	c=name;
	while((*c) && (*c != '.')) ++c;
	if(*c=='.') *c=0;
	fd.name=name;
	fd.ext=paths.main_load_name;
	while((*(fd.ext)) && (*(fd.ext) != '.')) ++(fd.ext);
	/* Filegrîûe */
	fsize=Fseek(0, (int)fhl, 2);
	Fseek(0,(int)fhl,0);
	/* Erste 256 Bytes */
	Fread((int)fhl, 256, buf);
	Fseek(0,(int)fhl,0);
	/* Rest setzen */
	fd.fh=(int)fhl;
	fd.flen=fsize;
	fd.buf256=buf;
	
	bmf=id_by_modules(&fd, &best_match);

	if((best_match & CAN_LOAD) && bmf)
		return(open_as_main((int)fhl, &fd, bmf));
	if(best_match && fd.descr)
	{
		Fclose((int)fhl);
		return(show_file_info(complete, best_match, fd.descr)); /* Immer 0 */
	}
	
	/* Ansonsten alte Methode anwenden */	
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

int show_file_info(char *file, int match, char *descript)
{/* Dateiformat nicht unterstÅzt... anzeigen 
 		Gibt 0 zurÅck, damit Aufrufer direkt return(show_file_info())
 		absetzen kann*/
 		
	OBJECT *tree;
	char	 *c, mfile[256], *oos;
	int		 a, x,y,w,h;
	
	xrsrc_gaddr(0,NOLOAD,&tree,xrsrc);
		
	switch(match)
	{
		case EXT_REC:
			strcpy(tree[NOT1].ob_spec.free_string, "Beim Format handelt es sich evtl. um:");
		break;
		case EDT_REC:
			strcpy(tree[NOT1].ob_spec.free_string, "Das Format ist sehr wahrscheinlich:");
		break;
		case REL_REC:
			strcpy(tree[NOT1].ob_spec.free_string, "Das Format wurde erkannt als:");
		break;
	}
	/* Description des Moduls kopieren */
	
	a=NOT2;
	do
	{
		c=strstr(descript, "|");
		if(c) *c=0;
		strncpy(tree[a++].ob_spec.free_string, descript, 45);
		if(c) descript=c+1;
	}while(c && (a <= NOTL));
	while(a<=NOTL) tree[a++].ob_spec.free_string[0]=0;
	
	/* File reinschreiben */
	/* Originalstring aus RSC merken, daran wird die LÑnge erkannt */
	oos=tree[NOFILE].ob_spec.free_string;
	tree[NOFILE].ob_spec.free_string=file_fit(file, mfile, strlen(tree[NOFILE].ob_spec.free_string));
	
	wind_update(BEG_UPDATE);
	form_center(tree, &x, &y, &w, &h);
	form_dial(FMD_START,x,y,w,h,x,y,w,h);
	objc_draw(tree, 0, 8, sx, sy, sw, sh);
	form_do(tree, 0);
	tree[NOABBRUCH].ob_state &= (~SELECTED);
	form_dial(FMD_FINISH,x,y,w,h,x,y,w,h);
	wind_update(END_UPDATE);

	tree[NOFILE].ob_spec.free_string=oos;

	return(0);
}

char *file_fit(char *src, char *dst, long len)
{/* Kopiert den Pfad aus src nach dst unter Beachtung von len, d.h.
		ggf. werden im Zwischenteil Ordner durch "..." ersetzt.
		Gibt immer dst zurÅck */

	long	a, b;
	
	dst[0]=0;
	
	/* Paût's eh? */
	if(strlen(src)<=len)
	{
		strcpy(dst, src);
		return(dst);
	}
	
	/* Solange rÅckwÑrts kopieren, bis der erste '\' auftaucht */
	a=len; b=strlen(src);
	while((a > -1) && (src[b]!='\\')) dst[a--]=src[b--];
	
	if(a==-1) return(dst); /* Fertig, hat nichtmal der ganze Dateiname reingepaût */
	
	/* Das '\' nehmen wir noch mit */
	dst[a--]='\\';
	
	if(a < 3) /* Da geht fast nix mehr rein->nur Punkte setzen */
	{
		while(a > -1) dst[a--]='.';
		return(dst);
	}
	/* Ansonsten jetzt von vorne soviel wie mîglich reinkopieren */
	strncpy(dst, src, a-2);
	strncpy(&(dst[a-2]),"... ",3); /* Drei Punkte ohne 0 kopieren */
	return(dst);
}

int open_as_main(int fh, FILE_DSCR *fd, FIO_LIST *fl)
{	/* Return: 1=Ok, sonst Gemdos-Error oder ENSMEM intern */
	GRAPE_DSCR	gd;
	int					back;

	graf_mouse(BUSYBEE, NULL);
	
	if(new_file(fd->width, fd->height) == -1)
	{
		Fclose(fh);
		graf_mouse(ARROW, NULL);
		return(ENSMEM); 
	}
	
	/* Rahmen abschalten */
	frame_data.ok=0;
	
	/* Descriptor initialisieren */
	gd.height=first_lay->this.height;
	gd.width=first_lay->this.width;
	gd.line_width=first_lay->this.word_width;
	gd.c=first_lay->this.blue;
	gd.m=first_lay->this.red;
	gd.y=first_lay->this.yellow;
	gd.mask=NULL;
	gd.mode=0;
	gd.done_bytes=0;
	
	back=fl->fblk->mod_fn->load_file(fd, &gd);
	if(back>=0) back=1;
	Fclose(fh);
	graf_mouse(ARROW, NULL);
	return(back);
}

/*


 ***** IMPORT *****
 
*/

int scale_alert(int w, int h, int *nw, int *nh)
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
	strcat(alert, "[Ja, proportional|Unproportional|Abbruch]");

	ret=form_alert(1,alert);

	if(ret==3) return(0); /* Abbruch */
	if(ret==2)	/* Unproportional */
	{
		*nw=first_lay->this.width;
		*nh=first_lay->this.height;
		return(1);
	}
	
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

void copy_one(uchar *buf, uchar *mask, int w, int h, int ldif, int mode)
{
	COPY_DSCR cd;
	
	cd.sc=buf; cd.sm=cd.sy=NULL;
	cd.dc=mask; cd.dm=cd.dy=NULL;
	cd.dw=w; cd.dh=h;
	cd.sldif=0;
	cd.dldif=ldif;
	if(mode)
	{
		if(opmode[PM1].ob_state & SELECTED)
			cd.mode=2;
		else if(opmode[PM2].ob_state & SELECTED)
			cd.mode=4;
		else
			cd.mode=6;
	}
	else
		cd.mode=0;

	cd.mask=NULL;
	cd.mldif=0;
	vary_copy(&cd);
}

void copy_three(uchar *s1, uchar *s2, uchar *s3, uchar *d1, uchar *d2, uchar* d3, uchar *mask, int w, int h, int ldif, int mode)
{
	COPY_DSCR cd;
	
	cd.sc=s1; cd.sm=s2; cd.sy=s3;
	cd.dc=d1; cd.dm=d2; cd.dy=d3;
	cd.dw=w; cd.dh=h;
	cd.sldif=0;
	cd.dldif=ldif;
	if(mode)
	{
		if(opmode[PM1].ob_state & SELECTED)
			cd.mode=2;
		else if(opmode[PM2].ob_state & SELECTED)
			cd.mode=4;
		else
			cd.mode=6;
		if(mask)
			cd.mode|=1;
		cd.mask=mask;
		cd.mldif=ldif;
	}
	else
	{
		cd.mode=0;
		cd.mask=NULL;
		cd.mldif=0;
	}
	vary_copy(&cd);
}

int open_as_layer(int fh, FILE_DSCR *fd, FIO_LIST *fl, LAYER *l, int mode)
{	/* fh=Filehandle der geîffneten Importdatei, fd=Descriptor selbiger
		fl=Importzielebene, mode=Maske & EinfÅgemodus beachten 0=Nein, sonst
		Ja, wird aber trotzdem nur beachtet, wenn Rahmen sichtbar ist */
	/* Return: 1=Ok, sonst Gemdos-Error oder ENSMEM intern */
	
	GRAPE_DSCR	gd;
	long				siz, offset=0;
	int					back, nw, nh;
	uchar				*buf=NULL, *mask;
	_frame_data oframe=frame_data;
	
	if(frame_data.ok && frame_data.vis)
	{/* In Rahmen importieren */
		if((frame_data.w==fd->width)&&(frame_data.h==fd->height)&&
				((mode==0)||(opmode[PM3].ob_state & SELECTED))&&
				!(otoolbar[MASK_ON-1].ob_state & SELECTED))
		{/* Deckend mit weiû ohne Maske und passend fÅr Rahmen->
				Ziel ist Ebene direkt */
			offset=(long)((long)l->word_width*(long)(frame_data.y))+(long)frame_data.x;
			/* Undo */
			if(!frame_to_undo_ws(l, NULL))
			{
				frame_data=oframe;
				return(ENSMEM);
			}
		}
		else
		{
			/* Soll skaliert werden oder EinfÅgemodus beachten
				, da brauchamr mal a bissle buffer */
			siz=(long)((long)(fd->width)*(long)(fd->height));
			buf=malloc(siz*3);
			if(buf==NULL)
			{
				form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
				return(ENSMEM);
			}
			/* Undo */
			if(!frame_to_undo_ws(l, NULL))
			{
				frame_data=oframe;
				free(buf);
				return(ENSMEM);
			}
			offset=(long)((long)l->word_width*(long)(frame_data.y))+(long)frame_data.x;
			nw=frame_data.w;
			nh=frame_data.h;
		}
	}
	else
	{/* Direkt in Ebene importieren */
		if((fd->width  > l->width) || (fd->height > l->height))
		{/* Datei ist grîûer als Ebene */
			back=scale_alert(fd->width, fd->height, &nw, &nh);
			if(back==0) return(0);
			/* Soll skaliert werden, da brauchamr mal a bissle buffer */
			siz=(long)((long)(fd->width)*(long)(fd->height));
			buf=malloc(siz*3);
			if(buf==NULL)
			{
				form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
				return(ENSMEM);
			}
			/* Undo */
			frame_data.x=frame_data.y=0;
			frame_data.w=nw; frame_data.h=nh;
			if(!frame_to_undo_ws(l, NULL))
			{
				frame_data=oframe;
				free(buf);
				return(ENSMEM);
			}
		}
		else
		{/* Datei ist kleiner gleich Ebene */
			/* Undo */
			frame_data.x=frame_data.y=0;
			frame_data.w=fd->width; frame_data.h=fd->height;
			if(!frame_to_undo_ws(l, NULL))
			{
				frame_data=oframe;
				return(ENSMEM);
			}
		}
	}
	
	frame_data=oframe;
	
	graf_mouse(BUSYBEE, NULL);
	
	/* Descriptor initialisieren */
	if(buf) /* Ziel ist Zwischenpuffer */
	{
		gd.height=fd->height;
		gd.width=fd->width;
		gd.line_width=gd.width;
		gd.c=buf;
		gd.m=gd.c+siz;
		gd.y=gd.m+siz;
		gd.mode=0;
	}
	else
	{
		gd.height=l->height;
		gd.width=l->width;
		gd.line_width=l->word_width;
		gd.c=(uchar*)(l->blue)+offset;		/* Offset kommt von deckend/weiû/keine Maske/gleich groû */
		gd.m=(uchar*)(l->red)+offset;
		gd.y=(uchar*)(l->yellow)+offset;
		gd.mode=mode;
	}
	gd.mask=NULL;
	gd.done_bytes=0;
	
	back=fl->fblk->mod_fn->load_file(fd, &gd);
	if(back>=0) back=1;
	Fclose(fh);
	graf_mouse(ARROW, NULL);
	if(buf==NULL)	/* Ziel war Ebene direkt->Fertig */
		return(back);
	/* Sonst erstmal skalieren oder Modus beachten, falls Import ok war */
	if(back == 1)
	{
		if(mode && (otoolbar[MASK_ON-1].ob_state & SELECTED))
			mask=(uchar*)(act_mask->this.mask)+offset;
		else
			mask=NULL;
		if((nw==fd->width)&&(nh==fd->height))
			copy_three(buf, buf+siz, buf+2*siz, (uchar*)(l->blue)+offset, (uchar*)(l->red)+offset, (uchar*)(l->yellow)+offset, mask, fd->width, fd->height, l->word_width-fd->width, mode);
		else
			scale_three(buf, buf+siz, buf+2*siz, (uchar*)(l->blue)+offset, (uchar*)(l->red)+offset, (uchar*)(l->yellow)+offset, mask, fd->width, fd->height, nw, nh, l->word_width-nw, mode);
	}
	free(buf);
	return(back);
}

int open_as_mask(int fh, FILE_DSCR *fd, FIO_LIST *fl, MASK *ms, int mode)
{	/* Return: 1=Ok, sonst Gemdos-Error oder ENSMEM intern */
	GRAPE_DSCR	gd;
	long				siz, offset=0;
	int					back, nw, nh;
	uchar				*buf=NULL;
	_frame_data oframe=frame_data;

	if(frame_data.ok &&	frame_data.vis)
	{/* In Rahmen importieren */
		if((frame_data.w==fd->width)&&(frame_data.h==fd->height)&&
				((mode==0)||(opmode[PM3].ob_state & SELECTED)))
		{/* Deckend mit weiû und passend fÅr Rahmen->
				Ziel ist Maske direkt */
			offset=(long)((long)first_lay->this.word_width*(long)(frame_data.y))+(long)frame_data.x;
			/* Undo */
			if(!frame_to_undo_ws(NULL, ms))
			{
				frame_data=oframe;
				return(ENSMEM);
			}
		}
		else
		{
			/* Soll skaliert werden, da brauchamr mal a bissle buffer */
			siz=(long)((long)(fd->width)*(long)(fd->height));
			buf=malloc(siz);
			if(buf==NULL)
			{
				form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
				return(ENSMEM);
			}
			/* Undo */
			if(!frame_to_undo_ws(NULL, ms))
			{
				frame_data=oframe;
				free(buf);
				return(ENSMEM);
			}
			offset=(long)((long)first_lay->this.word_width*(long)(frame_data.y))+(long)frame_data.x;
			nw=frame_data.w;
			nh=frame_data.h;
		}
	}
	else
	{/* Direkt in Maske importieren */
		if((fd->width  > first_lay->this.width) || (fd->height > first_lay->this.height))
		{/* Datei grîûer als Maske */
			back=scale_alert(fd->width, fd->height, &nw, &nh);
			if(back==0) return(0);
			/* Soll skaliert werden, da brauchamr mal a bissle buffer */
			siz=(long)((long)(fd->width)*(long)(fd->height));
			buf=malloc(siz);
			if(buf==NULL)
			{
				form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
				return(ENSMEM);
			}
			/* Undo */
			frame_data.x=frame_data.y=0;
			frame_data.w=nw; frame_data.h=nh;
			if(!frame_to_undo_ws(NULL, ms))
			{
				frame_data=oframe;
				free(buf);
				return(ENSMEM);
			}
		}
		else
		{/* Maske ist groû genug fÅr Datei */
			/* Undo */
			frame_data.x=frame_data.y=0;
			frame_data.w=fd->width; frame_data.h=fd->height;
			if(!frame_to_undo_ws(NULL, ms))
			{
				frame_data=oframe;
				return(ENSMEM);
			}
		}
	}
	frame_data=oframe;
	
	graf_mouse(BUSYBEE, NULL);
	
	/* Descriptor initialisieren */
	if(buf) /* Ziel ist Zwischenpuffer */
	{
		gd.height=fd->height;
		gd.width=fd->width;
		gd.line_width=gd.width;
		gd.mask=buf;
		gd.mode=0;
	}
	else
	{
		gd.height=first_lay->this.height;
		gd.width=first_lay->this.width;
		gd.line_width=first_lay->this.word_width;
		gd.mask=(uchar*)(ms->mask)+offset; /* Offset kommt von deckend/weiû/gleich groû */
		gd.mode=mode;
	}
	gd.c=gd.m=gd.y=NULL;
	gd.done_bytes=0;
	
	back=fl->fblk->mod_fn->load_file(fd, &gd);
	if(back>=0) back=1;
	Fclose(fh);
	graf_mouse(ARROW, NULL);
	
	if(buf==NULL)	/* Ziel war Maske direkt->Fertig */
		return(back);

	/* Sonst erstmal skalieren oder Modus beachten, falls Import ok war */
	if(back == 1)
	{
		if((nw==fd->width)&&(nh==fd->height))
			copy_one(buf, (uchar*)(ms->mask)+offset, fd->width, fd->height, first_lay->this.word_width-nw, mode);
		else
			scale_one(buf, (uchar*)(ms->mask)+offset, fd->width, fd->height, nw, nh, first_lay->this.word_width-nw, mode);
	}
	free(buf);
	return(back);
}

int import_file(char *path, char *file, LAYER *l, MASK *ms, int mode)
{
	/* ôffnet Datei "path+file"
		 l=Zeiger auf Layer oder NULL
		 ms=Zeiger auf Maske oder NULL
		 mode: 0=Einfach importieren
		 			 1=Status von "EinfÅgemodus" und "Maske aktiv" beachten
		 1=Alles ok
		 0=Fehler oder sonstwas
	*/

	char	complete[256];
	int		best_match=UNKNOWN;
	long  fhl, fsize;
	long	id;
	uchar	buf[256];
	char	name[64], fd_path[128], *c;
	FILE_DSCR	fd;
	FIO_LIST	*bmf;
	
	make_path(complete, path, file);
	fhl=Fopen(complete, 0);
	if(fhl < 0)
	{
		form_alert(1,"[3][Grape:|Fehler beim ôffnen der Datei!][Abbruch]");
		return(0);
	}
	/* Zeiger auf Pfad etc.  setzen */
	strcpy(fd_path, path);
	if (fd_path[strlen(fd_path)-1] != '\\')
	{
		c=strrchr(fd_path, '\\');
		*(++c)=0;
	}
	fd.path=fd_path;
	strcpy(name, file);
	c=name;
	while((*c) && (*c != '.')) ++c;
	if(*c=='.') *c=0;
	fd.name=name;
	fd.ext=file;
	while((*(fd.ext)) && (*(fd.ext) != '.')) ++(fd.ext);
	/* Filegrîûe */
	fsize=Fseek(0, (int)fhl, 2);
	Fseek(0,(int)fhl,0);
	/* Erste 256 Bytes */
	Fread((int)fhl, 256, buf);
	Fseek(0,(int)fhl,0);
	/* Rest setzen */
	fd.fh=(int)fhl;
	fd.flen=fsize;
	fd.buf256=buf;
	
	bmf=id_by_modules(&fd, &best_match);

	if((best_match & CAN_LOAD) && bmf)
	{
		if(l)
			return(open_as_layer((int)fhl, &fd, bmf, l, mode));
		else
			return(open_as_mask((int)fhl, &fd, bmf, ms, mode));
	}
	if(best_match && fd.descr)
	{
		Fclose((int)fhl);
		return(show_file_info(complete, best_match, fd.descr)); /* Immer 0 */
	}
	
	/* Ansonsten alte Methode anwenden */	
	id=identify((int)fhl);

	if(id == FF_ESM)
		return(esm_import((int)fhl, l, ms, mode));
	else if(id == FF_TIFF_MOT)
		return(tiff_import((int)fhl, l, ms, mode));
	else if(id == FF_TIFF_INT)
		return(ibm_tiff_import((int)fhl, l, ms, mode));
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
}

int get_graf_size(char *path, char *file, int *w, int *h)
{
	/* ôffnet Datei "path+file"
		 1=Alles ok, in w und h stehen die Ausmaûe 
		 0=Fehler oder sonstwas
	*/

	char	complete[256];
	int		best_match=UNKNOWN, ret;
	long  fhl, fsize;
	uchar	buf[256];
	char	name[64], fd_path[128], *c;
	FILE_DSCR	fd;
	FIO_LIST	*bmf;
	
	make_path(complete, path, file);
	fhl=Fopen(complete, 0);
	if(fhl < 0)
	{
		form_alert(1,"[3][Grape:|Fehler beim ôffnen der Datei!][Abbruch]");
		return(0);
	}
	/* Zeiger auf Pfad etc.  setzen */
	strcpy(fd_path, path);
	if (fd_path[strlen(fd_path)-1] != '\\')
	{
		c=strrchr(fd_path, '\\');
		*(++c)=0;
	}
	fd.path=fd_path;
	strcpy(name, file);
	c=name;
	while((*c) && (*c != '.')) ++c;
	if(*c=='.') *c=0;
	fd.name=name;
	fd.ext=file;
	while((*(fd.ext)) && (*(fd.ext) != '.')) ++(fd.ext);
	/* Filegrîûe */
	fsize=Fseek(0, (int)fhl, 2);
	Fseek(0,(int)fhl,0);
	/* Erste 256 Bytes */
	Fread((int)fhl, 256, buf);
	Fseek(0,(int)fhl,0);
	/* Rest setzen */
	fd.fh=(int)fhl;
	fd.flen=fsize;
	fd.buf256=buf;
	
	bmf=id_by_modules(&fd, &best_match);
	Fclose((int)fhl);

	if((best_match & CAN_LOAD) && bmf)
	{
		*w=fd.width;
		*h=fd.height;
		return(1);
	}
	if(best_match && fd.descr)
		return(show_file_info(complete, best_match, fd.descr)); /* Immer 0 */
	
	/* Ansonsten alte Methode anwenden */	
	ret=identify((int)fhl);
	
	switch(ret)
	{
		case FF_ESM:
			ret=get_esm_size((int)fhl, w, h);
		break;
		case FF_TIFF_MOT:
			ret=get_tiff_size((int)fhl, 0, w, h);
		break;
		case FF_TIFF_INT:
			ret=get_tiff_size((int)fhl, 1, w, h);
		break;
		case FF_GRAPE:
			ret=get_grape_size((int)fhl, w, h);
		break;
	}
	
	return(ret);
}
