#include <grape_h.h>
#include <fiodef.h>
#include "grape.h"
#include "module.h"
#include "export.h"
#include "fiomod.h"
#include "xrsrc.h"
#include "convert.h"
#include "maininit.h"
#include "timeshow.h"

int scan_for_def(char *path);

void scan_fio_modules(void)
{
	int 	num=0;
	long	l;
	char	path[256];
	
	delete_fiomod();
	strcpy(path, paths.module_path);
	l=strlen(path)-1;
	while(path[l] != '\\')--l;
	path[l+1]=0;
	strcat(path, "FORMATE\\");
	num=scan_folder(path);

	if(num < 1)
	{
		if(num == -1)
			form_alert(1,"[3][Grape:|Nicht genug Speicher fr die|Im-/Exportmodule!][Abbruch]");
		delete_fiomod();
		return;
	}

	/* DEF-Files suchen */
	num=scan_for_def(path);
	if(num == -1)
		form_alert(1,"[3][Grape:|Nicht genug Speicher fr die|Exportformate!][Abbruch]");
}

int	cat_moddef(char *path)
{/* Ret: -1 = no memory, 0=Loaderror/no DEF-File, 1=Ok */
	EXP_FORM	**bep=&first_expf, *ep;
	long	fhl;
	int		fh, num;
	
	while(*bep) bep=&((*bep)->next);
	
	fhl=Fopen(path, FO_READ);
	if(fhl < 0) return(0);
	fh=(int)fhl;
	Fread(fh, 4, &fhl);
	if(fhl != 'GDEF'){Fclose(fh);return(0);}	/* Magic */
	Fread(fh, 4, &fhl);
	if(fhl != '0100'){Fclose(fh);return(0);}	/* Version */
	Fread(fh, 2, &num);	/* Anzahl */
	while(num)
	{
		ep=*bep=malloc(sizeof(EXP_FORM));
		if(ep==NULL){Fclose(fh);return(-1);}
		Fread(fh, sizeof(EXP_FORM), ep);
		if(find_fiomod_by_id(ep->base_id)==NULL)
		{free(ep); *bep=NULL; Fclose(fh); return(0);}
		ep->f_id=expf_id++;
		ep->next=NULL;
		bep=&(ep->next);
		--num;
	}
	Fclose(fh);
	return(1);
}

int scan_for_def(char *path)
{/* Sucht DEF-Dateien und tr„gt diese in EXP_FORM-Kette ein */
	char	opath[256], tpath[256], spath[256];
	DTA		*old=Fgetdta(), dta;	
	int		num=0, rf;
	long	l;

	/* Pfad merken */
	strcpy(opath, path);
	l=strlen(opath)-1;
	while(opath[l] != '\\')--l;
	opath[l+1]=0;
	strcpy(tpath, opath);
	strcat(tpath, "*.DEF");	
	strcpy(spath, tpath);
	Fsetdta(&dta);
	if(!Fsfirst(spath, 0))
	{
		do
		{	
			strcpy(tpath, opath);
			strcat(tpath, dta.d_fname);
			rf=cat_moddef(tpath);
			if(rf==-1) return(-1);
			if(rf == 1)	++num;
		}while(!Fsnext());
	}
	Fsetdta(old);
	return(num);
}

int scan_folder(char *path)
{/* Fllt den Listenzeiger FIO_LIST 
		Sind keine Module vorhanden kommt 0, bei Speichermangel -1,
		sonst 1 zurck */
	char	opath[256], tpath[256], spath[256];
	DTA		*old=Fgetdta(), dta;	
	int		num=0, rf;
	long	l;
	
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
			rf=cat_fiomod(tpath);
			if(rf==-1) return(-1);
			if(rf == 1)	++num;
		}while(!Fsnext());
	}
	Fsetdta(old);
	return(num);
}

int cat_fiomod(char *path)
{/*  Pfad=Pfad+Name der Modul-Datei.
		 Die Funktion h„ngt das Modul an die FIO-Modulliste an 
		 Gibt 0 zurck, wenn die Datei kein Modul ist
		 Gibt -1 bei Speichermangel zurck 
		 sonst 1*/

	BASPAG	*base;
	FIOMODBLK	*fblock;
	FIO_LIST	**fpl=&first_fiomod, *fl;
	long			len;

	base=load_module(path, &len);
	if(!base)
		return(0);

	fblock=find_fiomod_magic((uchar*)base, len);
	if(!fblock)
	{
		Mfree(base);
		return(0);
	}

	/* Neuen Listeneintrag vorbereiten */
	while(*fpl) fpl=&((*fpl)->next);
	*fpl=fl=malloc(sizeof(FIO_LIST));
	if(fl==NULL)
	{
		Mfree(base);
		return(-1);
	}
	/* Ok, Neuen Eintrag initialisieren */
	fl->base=base;
	fl->fblk=fblock;
	fl->next=NULL;
	
	/* Modul initialisieren */
	/* Meine Funktionspointer eintragen */
	fblock->gpfio=&grape_fiomod_info;
	if(fblock->mod_fn->mod_init)
		fblock->mod_fn->mod_init();
	return(1);
}

FIOMODBLK *find_fiomod_magic(uchar *mem, long len)
{
	do
	{
		if(*mem=='G')
		{
			if(!strncmp((char*)mem, "GRAPEFIOMOD", 11))
				return((FIOMODBLK*)mem);
		}
		++mem;
		--len;
	}while(len);
	return(NULL);
}

void delete_fiomod(void)
{/* Speicher fr FIO-Module und Exportformate freigeben */
	FIO_LIST	*l=first_fiomod, *ml;
	EXP_FORM	*el=first_expf, *bl;

	while(l)
	{
		if(l->base)
			free(l->base);
		ml=l;
		l=l->next;
		free(ml);
	}
	
	first_fiomod=NULL;
	
	while(el)
	{
		bl=el;
		el=el->next;
		free(bl);
	}
	
	first_expf=NULL;
}

void close_all_fio_win(void)
{/* Schliežt alle Fenster, die mit den FIO-Modulen zu tun haben */
	if(wexport.open)
		dial_export(EXABBRUCH);
	if(wfexport.open)
		dial_fexport(FXCLOSE);
	if(wfxsave.open)
		dial_fxsave(FXSABBRUCH);
	if(waopt.open)
		dial_aopt(OAABBRUCH);
}

int	count_fiomod(void)
{
	FIO_LIST	*l=first_fiomod;
	int	n=0;
	
	while(l)
	{
		++n;
		l=l->next;
	}
	return(n);
}

int	count_fio_saveables(void)
{/* Z„hlt die Module, die exportf„hig sind */
	FIO_LIST	*l=first_fiomod;
	int	n=0;
	
	while(l)
	{
		if((l->fblk->ex_formats) && (l->fblk->mod_fn->save_file))
			++n;
		l=l->next;
	}
	return(n);
}

FIOMODBLK	*find_fiomod_by_id(long id)
{
	FIO_LIST *l=first_fiomod;
	
	while(l)
	{
		if(l->fblk->id==id) break;
		l=l->next;
	}
	if(l)
		return(l->fblk);
	
	return(NULL);
}

int find_fioidx_by_id(long id)
{
	FIO_LIST	*l=first_fiomod;
	int				a=0;

	while(l)
	{
		if(l->fblk->id==id) break;
		l=l->next;
		++a;
	}
	if(l)
		return(a);
	
	return(-1);
}

long find_fiomodid_by_index(int ix)
{
	FIO_LIST	*l=first_fiomod;

	while(l && ix)
	{
		l=l->next;
		--ix;
	}
	if(l)
		return(l->fblk->id);
	
	return(-1);
}

long find_fiomodid_by_savindex(int ix)
{/* Index nur ber die saveables */
	FIO_LIST	*l=first_fiomod;

	do
	{
		while((l->fblk->ex_formats==0) || (l->fblk->mod_fn->save_file==NULL))
		{
			l=l->next;
			if(l==NULL) return(-1);
		}
		if(l && ix)
		{
			l=l->next;
			--ix;
		}
	}while(l && ix);
	if(l)
		return(l->fblk->id);
	
	return(-1);
}

/*****************************************************/
/* Funktionen, die von den Modulen aufgerufen werden */
/*****************************************************/
void swap_vdi_16(int *pal)
{
	int	a, b, npal[16][3];
	int	swap[]={0, 15, 1, 2, 4, 6, 3, 5, 7, 8, 10, 12, 14, 11, 13};

	for(a=0; a <16; ++a)
	{
		b=swap[a]*3;
		npal[a][0]=pal[b];
		npal[a][1]=pal[b+1];
		npal[a][2]=pal[b+2];
	}
	for(a=0; a < 16; ++a)
	{
		b=a*3;
		pal[b]=npal[a][0];
		pal[b+1]=npal[a][1];
		pal[b+2]=npal[a][2];
	}
	
}

void			fio_swap_pal(int num, int *pal)
{/* Tauscht die mittels set_pal gespeicherte Palette von Farbindex
		nach Screen-Index */
	int	swap[256], a, b, pxy[4], memcol, dum;
	int npal[256][3];
	
	if(num==16)
	{
		swap_vdi_16(pal);
		return;
	}
	
	/* Alle Farben setzen und Pixelwert abfragen */
	
	pxy[0]=pxy[1]=pxy[2]=pxy[3]=0;
	v_get_pixel(handle, 0, 0, &dum, &memcol);

	vswr_mode(handle, 1);	/* Replace */
	vsl_type(handle, 1);	/* Durchgehend */
	vsl_width(handle, 1);	/* 1 Pixel */
	vsl_ends(handle, 0, 0); /* eckig */
	
	for(a=0; a < num; ++a)
	{
		vsl_color(handle, a);
		v_pline(handle, 2, pxy);
		v_get_pixel(handle, 0, 0, &b, &dum);
		swap[a]=b;
	}
	
	vsl_color(handle, memcol);
	v_pline(handle, 2, pxy);
	
	/* Paletten vertauschen */
	for(a=0; a <num; ++a)
	{
		b=swap[a]*3;
		npal[a][0]=pal[b];
		npal[a][1]=pal[b+1];
		npal[a][2]=pal[b+2];
	}
	for(a=0; a < num; ++a)
	{
		b=a*3;
		pal[b]=npal[a][0];
		pal[b+1]=npal[a][1];
		pal[b+2]=npal[a][2];
	}
}

void test_pal(void)
{
	int a, pxy[3];
	long b;
	
	for(a=0; a < 256; ++a)
	{
		b=255-gc_pal[a][0]; b*=1000; b/=255; pxy[0]=(int)b;
		b=255-gc_pal[a][1]; b*=1000; b/=255; pxy[1]=(int)b;
		b=255-gc_pal[a][2]; b*=1000; b/=255; pxy[2]=(int)b;
		vs_color(handle, a, pxy);
	}
}

/* Modul-Aufrufe erfolgen hier: */

void cdecl			fio_set_pal(int mode, int num, int *pal)
{
	int	a, b;
	long	u;

	if(num > 256) num=256;

	switch(mode)
	{
		case RGB_8:
			for(a=0; a < num; ++a)
			{
				b=3*a;
				gc_pal[a][0]=(uchar)(255-pal[b]);
				gc_pal[a][1]=(uchar)(255-pal[b+1]);
				gc_pal[a][2]=(uchar)(255-pal[b+2]);
			}
		break;
		case CMY_8:
			for(a=0; a < num; ++a)
			{
				b=3*a;
				gc_pal[a][0]=(uchar)(pal[b]);
				gc_pal[a][1]=(uchar)(pal[b+1]);
				gc_pal[a][2]=(uchar)(pal[b+2]);
			}
		break;
		case RGB_PM:
			for(a=0; a < num; ++a)
			{
				b=3*a;
				u=pal[b]; u*=255l; u/=1000l;u=255l-u;
				gc_pal[a][0]=(uchar)u;
				u=pal[b+1];	u*=255l; u/=1000l;u=255l-u;
				gc_pal[a][1]=(uchar)u;
				u=pal[b+2];	u*=255l; u/=1000l;u=255l-u;
				gc_pal[a][2]=(uchar)u;
			}
		break;
		case CMY_PM:
			for(a=0; a < num; ++a)
			{
				b=3*a;
				gc_pal[a][0]=(uchar)(long)((long)((long)pal[b]*255l)/1000l);
				gc_pal[a][1]=(uchar)(long)((long)((long)pal[b+1]*255l)/1000l);
				gc_pal[a][2]=(uchar)(long)((long)((long)pal[b+2]*255l)/1000l);
			}
		break;
		case RGB_PM_VDI:
			fio_swap_pal(num, pal);
			fio_set_pal(RGB_PM, num, pal);
		break;
		case CMY_PM_VDI:
			fio_swap_pal(num, pal);
			fio_set_pal(CMY_PM, num, pal);
		break;
	}

	/* Aužerdem Graustufenpalette setzen */
	pal_to_grey(num);
}

int *cdecl	fio_get_pal(int mode, int num)
{
	static int	pal[256][3];
	int	a;
	
	if(num > 256) num=256;
	switch(mode)
	{
		case RGB_8:
			for(a=0; a < num; ++a)
			{
				pal[a][0]=255-gc_pal[a][0];
				pal[a][1]=255-gc_pal[a][1];
				pal[a][2]=255-gc_pal[a][2];
			}
		break;
		case CMY_8:
			for(a=0; a < num; ++a)
			{
				pal[a][0]=gc_pal[a][0];
				pal[a][1]=gc_pal[a][1];
				pal[a][2]=gc_pal[a][2];
			}
		break;
		case RGB_PM:
			for(a=0; a < num; ++a)
			{
				pal[a][0]=(uchar)(255-(long)((long)((long)gc_pal[a][0]*1000l)/255l));
				pal[a][1]=(uchar)(255-(long)((long)((long)gc_pal[a][1]*1000l)/255l));
				pal[a][2]=(uchar)(255-(long)((long)((long)gc_pal[a][2]*1000l)/255l));
			}
		break;
		case CMY_PM:
			for(a=0; a < num; ++a)
			{
				pal[a][0]=(uchar)(long)((long)((long)gc_pal[a][0]*1000l)/255l);
				pal[a][1]=(uchar)(long)((long)((long)gc_pal[a][1]*1000l)/255l);
				pal[a][2]=(uchar)(long)((long)((long)gc_pal[a][2]*1000l)/255l);
			}
		break;
	}

	return((int*)&(pal[0][0]));
}

void cdecl			fio_store_block(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{
	long	bytes;
	
	bytes=(long)(dd->width)*(long)(dd->height);
	timeshow(dd->done_bytes, bytes);
	switch(bd->format)
	{
		case B1: switch(bd->subcode)
		{
			case B1_WB:
				gc_pal[0][0]=gc_pal[0][1]=gc_pal[0][2]=0;
				gc_pal[1][0]=gc_pal[1][1]=gc_pal[1][2]=255;
				incon_1(bd, dd);
			break;
			case B1_BW:
				gc_pal[0][0]=gc_pal[0][1]=gc_pal[0][2]=255;
				gc_pal[1][0]=gc_pal[1][1]=gc_pal[1][2]=0;
				incon_1(bd, dd);
			break;
			case B1_CL:
				incon_1(bd, dd);
			break;
		}
		break;
		case B4: switch(bd->subcode)
		{
			case B4_PP:
				incon_4pp(bd, dd);
			break;
			case B4_IP_FL:
				incon_4ip(0, bd, dd);
			break;
			case B4_IP_FH:
				incon_4ip(1, bd, dd);
			break;
		}
		break;
		case B8: switch(bd->subcode)
		{
			case B8_GWBPP:
				incon_8ppgrey(bd, dd, 0);
			break;
			case B8_GBWPP:
				incon_8ppgrey(bd, dd, 1);
			break;
			case B8_GWBIP_FL:
				if(dd->done_bytes==0)
					con_set_grey_pal(0);
				incon_8ip(0, bd, dd);
			break;
			case B8_GWBIP_FH:
				if(dd->done_bytes==0)
					con_set_grey_pal(0);
				incon_8ip(1, bd, dd);
			break;
			case B8_GBWIP_FL:
				if(dd->done_bytes==0)
					con_set_grey_pal(1);
				incon_8ip(0, bd, dd);
			break;
			case B8_GBWIP_FH:
				if(dd->done_bytes==0)
					con_set_grey_pal(1);
				incon_8ip(1, bd, dd);
			break;
			case B8_CPP:
				incon_8pp(bd, dd);
			break;
			case B8_CIP_FL:
				incon_8ip(0, bd, dd);
			break;
			case B8_CIP_FH:
				incon_8ip(1, bd, dd);
			break;
		}
		break;
		case B24: switch(bd->subcode)
		{
			case B24_RGBPP:
				incon_rgbpp(bd, dd);
			break;
			case B24_RGBIP:
				incon_rgbip(PRED|PGREEN|PBLUE, bd, dd);
			break;
			case B24_CMYPP:
				incon_cmypp(bd, dd);
			break;
			case B24_CMYIP:
				incon_cmykip(PCYAN|PMAG|PYEL, bd, dd);
			break;
			case B24_RPP:
				incon_rgbip(PRED, bd, dd);
			break;
			case B24_GPP:
				incon_rgbip(PGREEN, bd, dd);
			break;
			case B24_BPP:
				incon_rgbip(PBLUE, bd, dd);
			break;
			case B24_CPP:
				incon_cmykip(PCYAN, bd, dd);
			break;
			case B24_MPP:
				incon_cmykip(PMAG, bd, dd);
			break;
			case B24_YPP:
				incon_cmykip(PYEL, bd, dd);
			break;
		}
		break;
		case B32: switch(bd->subcode)
		{
			case B32_CMYKPP:
				incon_cmykpp(bd, dd);
			break;
			case B32_CMYKIP:
				incon_cmykip(PCYAN|PMAG|PYEL|PBLACK, bd, dd);
			break;
			case B32_CPP:
				incon_cmykip(PCYAN, bd, dd);
			break;
			case B32_MPP:
				incon_cmykip(PMAG, bd, dd);
			break;
			case B32_YPP:
				incon_cmykip(PYEL, bd, dd);
			break;
			case B32_KPP:
				incon_cmykip(PBLACK, bd, dd);
			break;
		}
		break;
	}
	bytes=(long)(bd->w)*(long)(bd->h);
	dd->done_bytes+=bytes;
	bytes=(long)(dd->width)*(long)(dd->height);
	timeshow(dd->done_bytes, bytes);
}

void cdecl			fio_get_block(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{
	long	bytes;
	
	bytes=(long)(dd->width)*(long)(dd->height);
	timeshow(dd->done_bytes, bytes);
	switch(bd->format)
	{
		case B1: switch(bd->subcode)
		{
			case B1_WB:
				gc_pal[0][0]=gc_pal[0][1]=gc_pal[0][2]=0;
				gc_pal[1][0]=gc_pal[1][1]=gc_pal[1][2]=255;
				outcon_1(bd, dd);
			break;
			case B1_BW:
				gc_pal[0][0]=gc_pal[0][1]=gc_pal[0][2]=255;
				gc_pal[1][0]=gc_pal[1][1]=gc_pal[1][2]=0;
				outcon_1(bd, dd);
			break;
			case B1_CL:
				outcon_1(bd, dd);
			break;
		}
		break;
		case B4: switch(bd->subcode)
		{
			case B4_PP:
				outcon_4pp(bd, dd);
			break;
			case B4_IP_FL:
				outcon_4ip(0, bd, dd);
			break;
			case B4_IP_FH:
				outcon_4ip(1, bd, dd);
			break;
		}
		break;
		case B8: switch(bd->subcode)
		{
			case B8_GWBPP:
				outcon_8ppgrey(bd, dd, 0);
			break;
			case B8_GBWPP:
				outcon_8ppgrey(bd, dd, 1);
			break;
			case B8_GWBIP_FL:
				outcon_8ipgrey(0, 0, bd, dd);
			break;
			case B8_GWBIP_FH:
				outcon_8ipgrey(1, 0, bd, dd);
			break;
			case B8_GBWIP_FL:
				outcon_8ipgrey(0, 1, bd, dd);
			break;
			case B8_GBWIP_FH:
				outcon_8ipgrey(1, 1, bd, dd);
			break;
			case B8_CPP:
				outcon_8pp(bd, dd);
			break;
			case B8_CIP_FL:
				outcon_8ip(0, bd, dd);
			break;
			case B8_CIP_FH:
				outcon_8ip(1, bd, dd);
			break;
		}
		break;
		case B24: switch(bd->subcode)
		{
			case B24_RGBPP:
				outcon_rgbpp(bd, dd);
			break;
			case B24_RGBIP:
				outcon_rgbip(PRED|PGREEN|PBLUE, bd, dd);
			break;
			case B24_CMYPP:
				outcon_cmypp(bd, dd);
			break;
			case B24_CMYIP:
				outcon_cmykip(PCYAN|PMAG|PYEL, bd, dd);
			break;
			case B24_RPP:
				outcon_rgbip(PRED, bd, dd);
			break;
			case B24_GPP:
				outcon_rgbip(PGREEN, bd, dd);
			break;
			case B24_BPP:
				outcon_rgbip(PBLUE, bd, dd);
			break;
			case B24_CPP:
				outcon_cmykip(PCYAN, bd, dd);
			break;
			case B24_MPP:
				outcon_cmykip(PMAG, bd, dd);
			break;
			case B24_YPP:
				outcon_cmykip(PYEL, bd, dd);
			break;
		}
		break;
		case B32: switch(bd->subcode)
		{
			case B32_CMYKPP:
				outcon_cmykpp(bd, dd);
			break;
			case B32_CMYKIP:
				outcon_cmykip(PCYAN|PMAG|PYEL|PBLACK, bd, dd);
			break;
			case B32_CPP:
				outcon_cmykip(PCYAN, bd, dd);
			break;
			case B32_MPP:
				outcon_cmykip(PMAG, bd, dd);
			break;
			case B32_YPP:
				outcon_cmykip(PYEL, bd, dd);
			break;
			case B32_KPP:
				outcon_cmykip(PBLACK, bd, dd);
			break;
		}
		break;
	}
	bytes=(long)(bd->w)*(long)(bd->h);
	dd->done_bytes+=bytes;
	bytes=(long)(dd->width)*(long)(dd->height);
	timeshow(dd->done_bytes, bytes);
}


int cdecl	fio_form_alert(int fo_adefbttn, const char *fo_astring )
{
	return(form_alert(fo_adefbttn, fo_astring));
}
void *cdecl fio_malloc( size_t size )
{
	return(malloc(size));
}
void *cdecl fio_calloc( size_t nitems, size_t size )
{
	return(calloc(nitems, size));
}
void *cdecl fio_realloc( void *block, size_t newsize )
{
	return(realloc(block, newsize));
}
void cdecl fio_free( void *ptr )
{
	free(ptr);
}
