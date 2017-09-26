#include <ec_gem.h>
#include <atarierr.h>

#include "io.h"
#include "ioglobal.h"
#include "imgload.h"
#include "anhang.h"
#include "indexer.h"


#define IDX_BUFFERS 100
#define GUCKGUCKTIMER 5

extern struct tm	*a_to_time(char *s);
long	files_total;
int		DB_ignore_interest=0;
WINDOW iwin;


/* -------------------------------------- */

void Create_if_missing(char *path)
{/* path=Pfad zu einem Ordner (mit oder ohne abschlieûenden "\", egal)
    Fehlt dieser Ordner, dann wird er angelegt. Ohne Fehlerabfrage */
   
  char m=1;
  
  if(path[strlen(path)-1]=='\\')
  	m=path[strlen(path)-1]=0;

  Dcreate(path);	/* this does nothing if the folder already exists */
  
  if(m==0) path[strlen(path)]='\\';
}

/* -------------------------------------- */

long Fcopy(int fin, int fout, long clen, char *buf, long blen)
{
	long ret;
	
	while(clen)
	{
		if(clen > blen)
		{
			if((ret=Fread(fin, blen, buf)) < 0) return(ret);
			if((ret=Fwrite(fout, blen, buf)) < 0) return(ret);
			clen-=blen;
		}
		else
		{
			if((ret=Fread(fin, clen, buf)) < 0) return(ret);
			if((ret=Fwrite(fout, clen, buf)) < 0) return(ret);
			clen=0;
		}
	}
	return(0);
}

/* -------------------------------------- */

long get_buffer(char **buf, int mode)
{
	long len=10*sizeof(INDEXER)*IDX_BUFFERS;
	static char	hbuf[2*sizeof(INDEXER)];
	
	if(mode)
	{
		*buf=NULL;
		while(*buf==NULL)
		{
			*buf=malloc(len);
			if(*buf) return(len);
			len/=2;
			if(len <= 2*sizeof(INDEXER))
			{
				*buf=hbuf;
				return(2*sizeof(INDEXER));
			}
		}
	}
	
	/* Mode=0, free buf */
	if(*buf != hbuf) free(*buf);
	return(0);
}

/* -------------------------------------- */

void strspccpy(char *dst, char *src, int num)
{ /* Maximal num Zeichen kopieren, ggf. mit Leerzeichen fÅllen */
long l;

	strncpy(dst, src, num);
	dst[num]=0;
	l=strlen(dst);
	src=&(dst[l]);
	while(l < num) dst[l++]=' ';
	dst[l]=0;
}

void set_info_win(char *path, long num, int led)
{
	char	ns[33], *c;
	int		a, ox, oy;
	
	if(!(iwin.open)) return;

	while(appl_read(-1, 16, pbuf)) w_dispatch(pbuf);

	if(path)
	{
		strspccpy(iwin.dinfo->tree[IMP_PATH].ob_spec.tedinfo->te_ptext, path, 20);
		w_objc_draw(&iwin, IMP_PATH, 8, sx,sy,sw,sh);
	}
	if(num>-1)
	{
		ltoa(num, ns, 10);
		strcpy(iwin.dinfo->tree[IMP_NUM].ob_spec.tedinfo->te_ptext, ns);
		if(files_total > -1)
		{
			strcat(iwin.dinfo->tree[IMP_NUM].ob_spec.tedinfo->te_ptext, " (");
			strcat(iwin.dinfo->tree[IMP_NUM].ob_spec.tedinfo->te_ptext, gettext(SHORTTOTAL));
			strcat(iwin.dinfo->tree[IMP_NUM].ob_spec.tedinfo->te_ptext, " ");
			ltoa(files_total, ns, 10);
			strcat(iwin.dinfo->tree[IMP_NUM].ob_spec.tedinfo->te_ptext, ns);
			strcat(iwin.dinfo->tree[IMP_NUM].ob_spec.tedinfo->te_ptext, ")");
		}
		a=(int)strlen(iwin.dinfo->tree[IMP_NUM].ob_spec.tedinfo->te_ptext);
		c=&(iwin.dinfo->tree[IMP_NUM].ob_spec.tedinfo->te_ptext[a]);
		while(a < 20) c[a++]=' ';
		c[a]=0;
		w_objc_draw(&iwin, IMP_NUM, 8, sx,sy,sw,sh);
	}
	if(led > 0)
	{
		if(iwin.dinfo->tree[LED_1+led-1].ob_state & SELECTED) return;
		for(a=LED_1; a<=LED_3; ++a)
		{
			if(iwin.dinfo->tree[a].ob_state & SELECTED)
			{
				iwin.dinfo->tree[a].ob_state &= (~SELECTED);
				objc_offset(iwin.dinfo->tree, a, &ox, &oy);
				w_objc_draw(&iwin, 0, 8, ox,oy,iwin.dinfo->tree[a].ob_width, iwin.dinfo->tree[a].ob_height);
			}
		}
		iwin.dinfo->tree[LED_1+led-1].ob_state |= SELECTED;
		objc_offset(iwin.dinfo->tree, LED_1+led-1, &ox, &oy);
		w_objc_draw(&iwin, 0, 8, ox,oy,iwin.dinfo->tree[LED_1+led-1].ob_width, iwin.dinfo->tree[LED_1+led-1].ob_height);
	}
}

void strn64cpy(char *dst, char *src)
{ /* Maximal 64 Zeichen kopieren, ggf. mit Leerzeichen fÅllen */
	strspccpy(dst, src, 64);
}
void strtn64cpy(char *dst, char *src)
{ /* Maximal 64 Zeichen kopieren, terminieren, ggf. mit Leerzeichen fÅllen */
	int		a;
	
	strncpy(dst, src, 64);
	dst[64]=0;
	a=(int)strlen(dst);
	++a;
	while(a < 64) dst[a++]=' ';
	if(a==64) dst[a]=0;
}

char	*local_get_head_field(LOADED_MAIL *lm, char *f)
{/* PrÅft, ob der Header der aktuell geladenen Datei das Feld
		<f> enhÑlt (Groû-/Kleinschreibung egal) und gibt Zeiger
		auf Inhalt ohne fÅhrende Whitespace zurÅck oder NULL.
		Hinweis: Bei leerem Eintrag wird "" und nicht NULL geliefert! 
		<f> muû den Doppelpunkt enthalten !
		*/

	char	*i=lm->header;
	long	c=0, flen=strlen(f);

	if(i==NULL) return(NULL);
	while(c < lm->head_len)
	{
		if(strnicmp(i, f, flen)==0) goto _found;
		c+=strlen(i)+1;
		i+=strlen(i)+1;
	}
	return(NULL);

_found:
	i+=flen; c+=flen;
	while((c < lm->head_len) && ((*i==' ')||(*i==9)))
	{ ++c; ++i;}
	return(i);
}

void	set_mail_time(INDEXER *ix, LOADED_MAIL *lm)
{
	struct 
	{
		hour: 5;
		min	:6;
		sec	:5;
		
		year : 7;
		mon : 4;
		day : 5;
	}my_time;
	struct tm		*ftime=a_to_time(local_get_head_field(lm, "Date:"));
	DOSTIME			dtime;

	if(ftime==NULL) return;
	
	my_time.sec=ftime->tm_sec/2;
	my_time.min=ftime->tm_min;
	my_time.hour=ftime->tm_hour;
	
	my_time.day=ftime->tm_mday;
	my_time.mon=ftime->tm_mon+1;
	my_time.year=ftime->tm_year-1980;
	
	*(long*)&dtime=*(long*)&my_time;
	
	ix->ftime=dtime.time;
	ix->fdate=dtime.date;
}

int index_file(char *file, int fho_ix, int fho_db, int flags, long list_id)
{/* return: 1=Ok, indexiert
						0=Nicht genug Speicher
					 <0=Anderer Fehler (nicht îffnen o.Ñ.)
 */
	LOADED_MAIL	loaded;
	INDEXER	ix;
	long		fhl, flen;
	int			fh;
	char		*filemem, *c, *d;

	fhl=Fopen(file, FO_READ);
	if(fhl < 0) {gemdos_alert(gettext(NOOPEN),fhl);return(-1);}
	fh=(int)fhl;
	flen=Fseek(0, fh, 2);
	Fseek(0, fh, 0);
	filemem=malloc(flen+2);
	if(filemem==NULL) {Fclose(fh); return(0);}
	fhl=Fread(fh, flen, filemem);
	Fclose(fh);
	if(fhl < 0)
	{
		gemdos_alert(gettext(READERR), fhl);
		free(filemem); 
		return(-1);
	}
	filemem[flen]=filemem[flen+1]=0;
	set_info_win(NULL, -1, 2);
	if(split_loaded(filemem, flen, &loaded, 0)==0)
	{
		free(filemem);
		return(0);
	}
	
	ix.magic1='IdXm';
	ix.magic2='hGwM';
	
	c=&(file[strlen(file)-3]);
	if(!stricmp(c, "SNT"))
		ix.ftype=FLD_SNT;
	else if(!stricmp(c, "NEW"))
		ix.ftype=FLD_NEW;
	else if(!stricmp(c, "RED"))
		ix.ftype=FLD_RED;
	else if(!stricmp(c, "SND")) 
	/* Zu sendende auûerhalb PM und OM/SEND als versendet einstufen */
	/* (innerhalb wird hier nicht aufgerufen) */
		ix.ftype=FLD_SNT;
	else
		ix.ftype=FF_NON;	/* Wird ignoriert */

	ix.flags=flags;
	if(loaded.first) ix.flags |= FF_ATX;
	if(local_get_head_field(&loaded, "Newsgroups:")) ix.flags |= FF_ISOM;
	if((c=local_get_head_field(&loaded, "From:"))==NULL) c="";
	strn64cpy(ix.from, c);
	if((c=local_get_head_field(&loaded, "To:"))==NULL) 
		if((c=local_get_head_field(&loaded, "Newsgroups:"))==NULL) 
			c="";
	strn64cpy(ix.to, c);
	if((c=local_get_head_field(&loaded, "Subject:"))==NULL) c="";
	strn64cpy(ix.subj, c);
	if((c=local_get_head_field(&loaded, "Date:"))==NULL) c="";

	set_mail_time(&ix, &loaded);

	ix.list_id=list_id;
	if((c=local_get_head_field(&loaded, "Message-ID:"))==NULL) c="";
	strtn64cpy(ix.msg_id, c);
	if((c=local_get_head_field(&loaded, "In-Reply-To:"))==NULL) c="";
	strtn64cpy(ix.in_reply_to, c);
	if((c=local_get_head_field(&loaded, "References:"))==NULL) c="";
	/* Nur die letzte ist interessant, die ist per " " abgetrennt */
	d=&(c[strlen(c)-1]);
	while(*d==' ')--d;
	while((*d != ' ') && (d > c)) --d;
	if(*d==' ')++d; c=d;
	strtn64cpy(ix.references, c);
	ix.db_offset=Fseek(0, fho_db, 2);
	ix.db_size=flen+sizeof(INDEXER);
	
	set_info_win(NULL, -1, 3);
	Fwrite(fho_ix, sizeof(INDEXER), &ix);
	Fwrite(fho_db, sizeof(INDEXER), &ix);

	/* Nachricht nochmal laden, weil sie durch split_loaded verÑndert wurde */
	fhl=Fopen(file, FO_READ);
	fh=(int)fhl;
	Fread(fh, flen, filemem);
	Fclose(fh);
	Fwrite(fho_db, flen, filemem);
	
	free_mail(&loaded);
	free(filemem);
	return(1);
}

int make_index(char *sub_path, int flags, long list_id)
{/* ret: 0=alles ok
				|1=Speichermangel bei einer/mehreren Dateien
				|2=GEMDOS-Error bei einer/mehreren Dateien
				-1=Garnix gemacht, Startproblem
	*/
	long		fhl, fcnt;
	int			fho_ix, fho_db, ret=0, r;
	char 		src[256], path[256], file[256];
	DTA			*old=Fgetdta(), dta;

	strcpy(src, db_path);
	strcat(src, "\\DBASE.IDX");
	fhl=Fopen(src, FO_WRITE);
	if(fhl == EFILNF)	fhl=Fcreate(src, 0);
	if(fhl < 0)
	{
		gemdos_alert("Error opening IDX:",fhl);
		return(-1);
	}
	fho_ix=(int)fhl;

	strcpy(src, db_path);
	strcat(src, "\\DBASE.DAT");
	fhl=Fopen(src, FO_WRITE);
	if(fhl == EFILNF)	fhl=Fcreate(src, 0);
	if(fhl < 0)
	{
		gemdos_alert("Error opening DAT:",fhl);
		Fclose(fho_ix);
		return(-1);
	}
	fho_db=(int)fhl;

	Fseek(0, fho_ix, 2);
	Fseek(0, fho_db, 2);
		
	strcpy(src, db_path);
	strcat(src, sub_path);
	strcpy(path, src);
	strcat(path, "*.*");
	set_info_win(sub_path, -1, 1);
	fcnt=0;
	Fsetdta(&dta);
	if(!Fsfirst(path, 0))	do
	{
		set_info_win(NULL, fcnt, 1);
		if((flags & FF_LOCATION)==FF_PM)
			if(!stricmp( &(dta.d_fname[strlen(dta.d_fname)-4]), ".SND")) continue;
		++fcnt;
		++files_total;
		strcpy(file, src);
		strcat(file, dta.d_fname);
		r=index_file(file, fho_ix, fho_db, flags, list_id);
		set_info_win(NULL, fcnt, 1);
		switch(r)
		{
			case 1:	/* Alles ok */
				Fdelete(file);
			break;
			case 0:	/* Speichermangel */
				ret|=1;
			break;
			default:	/* Anderes Problem */
				ret|=2;
			break;
		}
	}while(!Fsnext());
	Fsetdta(old);
	
	Fclose(fho_ix);
	Fclose(fho_db);
	return(ret);
}

void Import_files(int show_win)
{
	int		ret, ret2;
	char	path[256], dpath[256];
	DTA		*old=Fgetdta(), dta;
	OBJECT *tree;
	DINFO dinfo;

	files_total=0;
	
	if(show_win)
	{
		rsrc_gaddr(0, IMPORTING, &tree);
		tree[LED_1].ob_state&=(~SELECTED);
		tree[LED_2].ob_state&=(~SELECTED);
		tree[LED_2].ob_state&=(~SELECTED);
		tree[IM_TITEL].ob_spec.free_string=gettext(IM_INDIZ);		
		tree[IMP_PATH].ob_spec.tedinfo->te_ptext[0]=0;
		tree[IMP_NUM].ob_spec.tedinfo->te_ptext[0]=0;
		lock_menu(omenu);
		w_dinit(&iwin);
		dinfo.tree=tree;
		dinfo.support=0;
		dinfo.osmax=0;
		dinfo.odmax=8;
		iwin.dinfo=&dinfo;
		w_dial(&iwin, D_CENTER);
		dinfo.dservice=NULL;
		dinfo.dedit=0;
		w_open(&iwin);
		w_modal(&iwin, MODAL_ON);
	}
	ret=0;
		
	if((ret2=make_index("\\PM\\", FF_PM, 0))==-1) goto _bye;
	ret|=ret2;
	if((ret2=make_index("\\DEL\\", FF_DEL, 0))==-1) goto _bye;
	ret|=ret2;

	strcpy(path, db_path);
	strcat(path, "\\OM\\");
	strcat(path, "\\*.*");
	Fsetdta(&dta);
	if(!Fsfirst(path, FA_SUBDIR))	do
	{
		if(!(dta.d_attrib & FA_SUBDIR)) continue;
		if(!stricmp(dta.d_fname, "SEND")) continue;
		if(!stricmp(dta.d_fname, ".")) continue;
		if(!stricmp(dta.d_fname, "..")) continue;
		strcpy(dpath, "\\OM\\");
		strcat(dpath, dta.d_fname);
		strcat(dpath, "\\");
		if((ret2=make_index(dpath, FF_OM, atol(dta.d_fname)))==-1) goto _bye;
		ret|=ret2;
	}while(!Fsnext());

	strcpy(path, db_path);
	strcat(path, "\\ORD\\");
	strcat(path, "\\*.*");
	Fsetdta(&dta);
	if(!Fsfirst(path, FA_SUBDIR))	do
	{
		if(!(dta.d_attrib & FA_SUBDIR)) continue;
		if(!stricmp(dta.d_fname, ".")) continue;
		if(!stricmp(dta.d_fname, "..")) continue;
		strcpy(dpath, "\\ORD\\");
		strcat(dpath, dta.d_fname);
		strcat(dpath, "\\");
		if((ret2=make_index(dpath, FF_ORD, atol(dta.d_fname)))==-1) goto _bye;
		ret|=ret2;
	}while(!Fsnext());

	Fsetdta(old);

_bye:
	if(show_win)
	{
		w_modal(&iwin, MODAL_OFF);
		w_kill(&iwin);
		unlock_menu(omenu);
	}
	if(ret2==-1) return;

	if(ret)
	{
		rsrc_gaddr(0, IMPORT_ERR, &tree);
		if(ret & 1)
		{
			tree[IERR_MEM1].ob_flags &= (~HIDETREE);
			tree[IERR_MEM2].ob_flags &= (~HIDETREE);
		}
		else
		{
			tree[IERR_MEM1].ob_flags |= HIDETREE;
			tree[IERR_MEM2].ob_flags |= HIDETREE;
		}
		if(ret & 2)
			tree[IERR_FILE].ob_flags &= (~HIDETREE);
		else
			tree[IERR_FILE].ob_flags |= HIDETREE;
		tree[IERR_OK].ob_state &= (~SELECTED);
		w_do_dial(tree);
	}
}

/* -------------------------------------- */

void Fsetdate(int fhandle, INDEXER *idx)
{
	DOSTIME			dtime;
	
	dtime.time=idx->ftime;
	dtime.date=idx->fdate;

	Fdatime(&dtime, fhandle, 1);
}

void file_export(int fin, INDEXER *idx, long files)
{
	char	file[256], path[256], *buf;
	long	fhl, blen;
	int		fout;

	set_info_win(NULL, files, 1);

	strcpy(file, db_path);
	switch(idx->flags & FF_LOCATION)
	{
		case FF_PM:
			strcpy(path, "\\PM\\");
			strcat(file, path);
		break;
		case FF_OM:
			strcpy(path, "\\OM\\");
			ltoa(idx->list_id, &(path[strlen(path)]), 10);
			strcat(path, "\\");
			strcat(file, path);	/* file enthÑlt jetzt den ganzen Pfad mit backslash */
			Create_if_missing(file);
		break;
		case FF_ORD:
			strcpy(path, "\\ORD\\");
			ltoa(idx->list_id, &(path[strlen(path)]), 10);
			strcat(path, "\\");
			strcat(file, path);	/* file enthÑlt jetzt den ganzen Pfad mit backslash */
			Create_if_missing(file);
		break;
		case FF_DEL:
			strcpy(path, "\\DEL\\");
			strcat(file, path);
		break;
		default: return;
	}
	strcat(file, get_free_file(file));
	switch(idx->ftype)
	{
		case FLD_SNT: strcat(file, ".SNT"); break;
		case FLD_NEW: strcat(file, ".NEW"); break;
		case FLD_RED: strcat(file, ".RED"); break;
		default: return;
	}
	set_info_win(path, -1, -1);	

	if(idx->db_size-sizeof(INDEXER) > 0)
	{
		fhl=Fcreate(file, 0);
		if(fhl < 0) return;
		fout=(int)fhl;
		
		blen=get_buffer(&buf, 1);
		set_info_win(NULL, -1, 3);
		Fseek((idx->db_offset)+sizeof(INDEXER), fin, 0);
		Fcopy(fin, fout, idx->db_size-sizeof(INDEXER), buf, blen);
		Fsetdate(fout, idx);
		Fclose(fout);
		get_buffer(&buf, 0);
	}
}

void Export_files(int show_win)
{
	long 	fhl, files=0;
	int	 	fin;
	char	path[256];
	INDEXER idx;
	OBJECT *tree;
	DINFO dinfo;

	files_total=-1;
	
	if(show_win)
	{
		rsrc_gaddr(0, IMPORTING, &tree);
		tree[LED_1].ob_state&=(~SELECTED);
		tree[LED_2].ob_state&=(~SELECTED);
		tree[LED_2].ob_state&=(~SELECTED);
		tree[IM_TITEL].ob_spec.free_string=gettext(IM_EXTRA);		
		tree[IMP_PATH].ob_spec.tedinfo->te_ptext[0]=0;
		tree[IMP_NUM].ob_spec.tedinfo->te_ptext[0]=0;
		lock_menu(omenu);
		w_dinit(&iwin);
		dinfo.tree=tree;
		dinfo.support=0;
		dinfo.osmax=0;
		dinfo.odmax=8;
		iwin.dinfo=&dinfo;
		w_dial(&iwin, D_CENTER);
		dinfo.dservice=NULL;
		dinfo.dedit=0;
		w_open(&iwin);
		w_modal(&iwin, MODAL_ON);
	}

	strcpy(path, db_path);
	strcat(path, "\\DBASE.DAT");
	fhl=Fopen(path, FO_READ);
	if(fhl < 0) goto _bye;
	fin=(int)fhl;
	
	do
	{
		fhl=Fread(fin, sizeof(INDEXER), &idx);
		if(fhl > 0) file_export(fin, &idx, files++);
		Fseek(idx.db_offset+idx.db_size, fin, 0);
	}while(fhl > 0);
	Fclose(fin);

	strcpy(path, db_path); strcat(path, "\\DBASE.IDX"); Fdelete(path);
	strcpy(path, db_path); strcat(path, "\\DBASE.DAT"); Fdelete(path);
		
_bye:
	if(show_win)
	{
		w_modal(&iwin, MODAL_OFF);
		w_kill(&iwin);
		unlock_menu(omenu);
	}
}

/* -------------------------------------- */

void Idx_correction(INDEXER *buf, long num)
{/* Earlier versions did not terminate the strings in the INDEXER-field
    correctly (e.g. when a sender's email-address was longer than
    64 characters, only 64 were copied, but the terminating zero-byte
    was not inserted).
    Functions that receive the INDEXER-fields read by idx_buf do of
    course assume that the strings are terminated correctly, so we
    correct this here to make sure that old (corrupt) databases can 
    still be used with emailer. */
    
   long x=0;
   while(x < num)
   {
	   	buf[x].from[64]=0;
	   	buf[x].to[64]=0;
	   	buf[x].subj[64]=0;
	   	buf[x].msg_id[64]=0;
	   	buf[x].in_reply_to[64]=0;
	   	buf[x].references[64]=0;
	   	++x;
   }
}

INDEXER *idx_buf(int mode, int fh)
{
	static INDEXER *buf, one;
	static long	num, pos;
	long		read;

	switch(mode)
	{
		case IDX_FIRST:
			buf=NULL;
			num=IDX_BUFFERS*2;
			do
			{
				num/=2;
				if(num < 2) buf=&one;
				else buf=malloc(num*sizeof(INDEXER));
			}while(buf==NULL);
			pos=num;
		break;
		case IDX_NEXT:
			if(pos==num)
			{
				pos=0;
				read=Fread(fh, num*sizeof(INDEXER), buf);
				if(read <= 0) return(NULL);
				num=read/sizeof(INDEXER);
				Idx_correction(buf, num);
			}
			++pos;
		return(&(buf[pos-1]));
		case IDX_LAST:
			if(buf != &one) free(buf);
		break;
	}	
	return(NULL);
}

INDEXER *Idx_scan(int mode, int location, long f_index, long *fidx)
{/* Location=FF_PM/OM/ORD/DEL oder -1 fÅr alle
		Bei FF_OM/ORD muû f_index angegeben werden oder -1
		In fidx wird die Position in der Index-Datei Åbergeben
		(als Index ab 0). Falls uninteressant, kann NULL Åbergeben werden.
	 */
	INDEXER *ix;
	static int fh;
	static long idx;
	long fhl;
	char	path[256];
	
	switch(mode)
	{
		case IDX_FIRST:
			strcpy(path, db_path);
			strcat(path, "\\DBASE.IDX");
			fhl=Fopen(path, FO_READ);
			if(fhl < 0) return(NULL);
			fh=(int)fhl;
			idx=-1;
			idx_buf(IDX_FIRST, fh);
			/* Fall into read-mode here */
		case IDX_NEXT:
			do
			{
				++idx; if(fidx) *fidx=idx;
				ix=idx_buf(IDX_NEXT, fh);
				if(ix==NULL) return(NULL);
				if(ix->ftype==FF_NON) continue;
				if((DB_ignore_interest==1)&&(ix->flags & FF_ITR)) continue;
				if(location==-1) return(ix);
			}while(	(ix->ftype==FF_NON) ||
							((ix->flags&FF_LOCATION) != location) ||
							( ((location == FF_OM)||(location==FF_ORD)) &&
								 (f_index != ix->list_id) && (f_index > -1) )
						);
		return(ix);
		case IDX_LAST:
			idx_buf(IDX_LAST,0);
			Fclose(fh);
		return(NULL);
	}
	return(NULL);
}

/* -------------------------------------- */

char *idx_detach(long index, char *nfile_path, int outfile)
{/* Setze den Filetype auf 0
    Nachricht wird unter nfile_path rausgeschrieben,
    falls nfile_path=NULL, wird der Pfad selbst an
    die passende Stelle gelegt, auûer outfile ist ebenfalls 0.
    ZurÅckgegeben wird der Pfad, unter dem die Nachricht
    abgelegt wurde, oder NULL falls nichts rausgeschrieben wurde.
  */
  
	long 		fhl, blen;
	int	 		fidx, fdat, ffout;
	char 		path[256], *buf;
	static 	char	file[256];
	INDEXER	idx;

	strcpy(path, db_path);
	strcat(path, "\\DBASE.IDX");
	fhl=Fopen(path, FO_RW);
	if(fhl < 0) return(NULL);
	fidx=(int)fhl;

	strcpy(path, db_path);
	strcat(path, "\\DBASE.DAT");
	fhl=Fopen(path, FO_RW);
	if(fhl < 0) {Fclose(fidx); return(NULL);}
	fdat=(int)fhl;

	Fseek(index*sizeof(INDEXER), fidx, 0);
	Fread(fidx, sizeof(INDEXER), &idx);
	Fseek(0, fidx, 0);

	if((nfile_path==NULL) && (outfile))
	{
		strcpy(file, db_path);
		switch(idx.flags & FF_LOCATION)
		{
			case FF_PM:
				strcat(file, "\\PM\\");
			break;
			case FF_OM:
				strcat(file, "\\OM\\");
				ltoa(index, &(file[strlen(file)]), 10);
				strcat(file, "\\");
				Create_if_missing(file);
			break;
			case FF_ORD:
				strcat(file, "\\ORD\\");
				ltoa(index, &(file[strlen(file)]), 10);
				strcat(file, "\\");
				Create_if_missing(file);
			break;
			case FF_DEL:
				strcat(file, "\\DEL\\");
			break;
		}
		
		strcat(file, get_free_file(file));
		switch(idx.ftype)
		{
			case FLD_SNT: strcat(file, ".SNT"); break;
			case FLD_NEW: strcat(file, ".NEW"); break;
			case FLD_RED: strcat(file, ".RED"); break;
		}
	}
	else if(nfile_path!=NULL)
	{
		strcpy(file, nfile_path);
		outfile=1;
	}

	if(outfile)
	{
		fhl=Fcreate(file, 0);
		if(fhl < 0) {Fclose(fidx);Fclose(fdat);return(NULL);}
		ffout=(int)fhl;
	}
	blen=get_buffer(&buf, 1);
	graf_mouse(BUSYBEE, NULL);
	/* Index Åberschreiben */
	idx.ftype=FF_NON;	/* Wird dadurch kÅnftig ignoriert */
	idx.flags&=(~FF_LOCATION); /* ebenso */
	Fseek(index*sizeof(INDEXER), fidx, 0);
	Fwrite(fidx, sizeof(INDEXER), &idx);
	Fclose(fidx);
	/* Index in Datenbank schreiben und File rausschreiben */
	Fseek(idx.db_offset, fdat, 0);
	Fwrite(fdat, sizeof(INDEXER), &idx);
	if(outfile)
	{
		Fcopy(fdat, ffout, idx.db_size-sizeof(INDEXER), buf, blen);
		Fsetdate(ffout, &idx);
		Fclose(ffout);
	}
	Fclose(fdat);
	graf_mouse(ARROW, NULL);
	
	get_buffer(&buf, 0);

	if(outfile)	return(file);
	return(NULL);
}

/* -------------------------------------- */

void idx_new_ftype(long index, int ftype)
{
	long fhl, pos;
	int		fh;
	char	path[256];
	INDEXER	idx;
	
	strcpy(path, db_path);
	strcat(path, "\\DBASE.IDX");
	fhl=Fopen(path, FO_RW);
	if(fhl < 0) return;
	fh=(int)fhl;
	pos=Fseek(index*sizeof(INDEXER), fh, 0);
	Fread(fh, sizeof(INDEXER), &idx);
	idx.ftype=ftype;
	if(ftype==FF_NON) idx.flags &= (~FF_LOCATION);
	Fseek(pos, fh, 0);
	Fwrite(fh, sizeof(INDEXER), &idx);
	Fclose(fh);
	
	strcpy(path, db_path);
	strcat(path, "\\DBASE.DAT");
	fhl=Fopen(path, FO_RW);
	if(fhl < 0) return;
	fh=(int)fhl;
	Fseek(idx.db_offset, fh, 0);
	Fwrite(fh, sizeof(INDEXER), &idx);
	Fclose(fh);
}

/* -------------------------------------- */

void idx_flag_def(long index, int flag, int set)
{
	long fhl, pos;
	int		fh;
	char	path[256];
	INDEXER	idx;
	
	strcpy(path, db_path);
	strcat(path, "\\DBASE.IDX");
	fhl=Fopen(path, FO_RW);
	if(fhl < 0) return;
	fh=(int)fhl;
	pos=Fseek(index*sizeof(INDEXER), fh, 0);
	Fread(fh, sizeof(INDEXER), &idx);
	if(set)
		idx.flags|=flag;
	else
		idx.flags&=(~flag);
	Fseek(pos, fh, 0);
	Fwrite(fh, sizeof(INDEXER), &idx);
	Fclose(fh);
	
	strcpy(path, db_path);
	strcat(path, "\\DBASE.DAT");
	fhl=Fopen(path, FO_RW);
	if(fhl < 0) return;
	fh=(int)fhl;
	Fseek(idx.db_offset, fh, 0);
	Fwrite(fh, sizeof(INDEXER), &idx);
	Fclose(fh);
}

/* -------------------------------------- */

void idx_new_location(long index, int location, long list_id)
{
	long fhl, pos;
	int		fh;
	char	path[256];
	INDEXER	idx;
	
	strcpy(path, db_path);
	strcat(path, "\\DBASE.IDX");
	fhl=Fopen(path, FO_RW);
	if(fhl < 0) return;
	fh=(int)fhl;
	pos=Fseek(index*sizeof(INDEXER), fh, 0);
	Fread(fh, sizeof(INDEXER), &idx);
	idx.flags&=(~FF_LOCATION);
	idx.flags|=location;
	idx.list_id=list_id;
	Fseek(pos, fh, 0);
	Fwrite(fh, sizeof(INDEXER), &idx);
	Fclose(fh);
	
	strcpy(path, db_path);
	strcat(path, "\\DBASE.DAT");
	fhl=Fopen(path, FO_RW);
	if(fhl < 0) return;
	fh=(int)fhl;
	Fseek(idx.db_offset, fh, 0);
	Fwrite(fh, sizeof(INDEXER), &idx);
	Fclose(fh);
}

/* -------------------------------------- */

void Idx_delete(long index)
{
	graf_mouse(BUSYBEE, NULL);
	idx_new_location(index, FF_DEL, 0);
	graf_mouse(ARROW, NULL);
}

void Idx_ord(long index, long list_id)
{
	graf_mouse(BUSYBEE, NULL);
	idx_new_location(index, FF_ORD, list_id);
	graf_mouse(ARROW, NULL);
}

void Idx_kill(long index)
{
	graf_mouse(BUSYBEE, NULL);
	idx_detach(index, NULL, 0);
	graf_mouse(ARROW, NULL);
}

void Idx_settype(long index, int ftype)
{
	graf_mouse(BUSYBEE, NULL);
	idx_new_ftype(index, ftype);
	graf_mouse(ARROW, NULL);
}

void Idx_setflag(long index, int flag)
{
	graf_mouse(BUSYBEE, NULL);
	idx_flag_def(index, flag, 1);
	graf_mouse(ARROW, NULL);
}

void Idx_clearflag(long index, int flag)
{
	graf_mouse(BUSYBEE, NULL);
	idx_flag_def(index, flag, 0);
	graf_mouse(ARROW, NULL);
}

void Idx_list_move(int old_loc, long old_id, int new_loc, long new_id)
{
	long 		fhl, fix;
	int	 		fidx, fdat;
	char 		path[256];
	INDEXER	*idx;

	strcpy(path, db_path);
	strcat(path, "\\DBASE.IDX");
	fhl=Fopen(path, FO_RW);
	if(fhl < 0) return;
	fidx=(int)fhl;

	strcpy(path, db_path);
	strcat(path, "\\DBASE.DAT");
	fhl=Fopen(path, FO_RW);
	if(fhl < 0) {Fclose(fidx); return;}
	fdat=(int)fhl;
	
	graf_mouse(BUSYBEE, NULL);
	idx=Idx_scan(IDX_FIRST, old_loc, old_id, &fix);
	while(idx)
	{
		idx->flags=(idx->flags & (~FF_LOCATION)) | new_loc;
		if(new_loc==FF_NON) idx->ftype=FF_NON;
		idx->list_id=new_id;
		Fseek(fix*sizeof(INDEXER), fidx, 0);
		Fwrite(fidx, sizeof(INDEXER), idx);
		Fseek(idx->db_offset, fdat, 0);
		Fwrite(fdat, sizeof(INDEXER), idx);
		idx=Idx_scan(IDX_NEXT, old_loc, old_id, &fix);
	}
	Idx_scan(IDX_LAST, 0, 0, NULL);
	Fclose(fidx);
	Fclose(fdat);
	graf_mouse(ARROW, NULL);
}

void Idx_extract_to(long index, char *path)
{
	long 	fhl, blen;
	int		fin, fout;
	char	spath[256], *buf;
	INDEXER idx;
	
	strcpy(spath, db_path); strcat(spath, "\\DBASE.IDX");
	fhl=Fopen(spath, FO_READ);
	if(fhl < 0) return;
	Fseek(index*sizeof(INDEXER), (int)fhl, 0);
	Fread((int)fhl, sizeof(INDEXER), &idx);
	Fclose((int)fhl);
	strcpy(spath, db_path); strcat(spath, "\\DBASE.DAT");
	fhl=Fopen(spath, FO_READ);
	if(fhl < 0) return;

	graf_mouse(BUSYBEE, NULL);
	fin=(int)fhl;
	Fseek(idx.db_offset+sizeof(INDEXER), fin, 0);
	fhl=Fcreate(path, 0);
	if(fhl < 0) {graf_mouse(ARROW, NULL); gemdos_alert(gettext(CREATEERR), fhl); Fclose(fin); return;}
	fout=(int)fhl;
	blen=get_buffer(&buf,1);
	Fcopy(fin, fout, idx.db_size-sizeof(INDEXER), buf, blen);
	Fsetdate(fout, &idx);
	Fclose(fin);
	Fclose(fout);
	get_buffer(&buf, 0);
	graf_mouse(ARROW, NULL);
}

void Idx_detach_to(long index, char *path)
{
	graf_mouse(BUSYBEE, NULL);
	idx_detach(index, path, 1);
	graf_mouse(ARROW, NULL);
}

void Idx_import_file(int location, long list_id, char *path)
{
	long	fhl;
	char 	src[256];
	int		fho_ix, fho_db;
	
	graf_mouse(BUSYBEE, NULL);
	strcpy(src, db_path);
	strcat(src, "\\DBASE.IDX");
	fhl=Fopen(src, FO_WRITE);
	if(fhl == EFILNF)	fhl=Fcreate(src, 0);
	if(fhl < 0)
	{
		graf_mouse(ARROW, NULL);
		gemdos_alert("Error opening IDX:",fhl);
		return;
	}
	fho_ix=(int)fhl;

	strcpy(src, db_path);
	strcat(src, "\\DBASE.DAT");
	fhl=Fopen(src, FO_WRITE);
	if(fhl == EFILNF)	fhl=Fcreate(src, 0);
	if(fhl < 0)
	{
		graf_mouse(ARROW, NULL);
		gemdos_alert("Error opening DAT:",fhl);
		Fclose(fho_ix);
		return;
	}
	fho_db=(int)fhl;

	Fseek(0, fho_ix, 2);
	Fseek(0, fho_db, 2);

	index_file(path, fho_ix, fho_db, location, list_id);
	
	Fclose(fho_ix);
	Fclose(fho_db);
	
	graf_mouse(ARROW, NULL);
}

int Idx_load_mail(INDEXER *idx, char *buf)
{/* Mail in idx nach buf laden. Return: 0=Fehler, 1=Ok */
	char 	path[256];
	long	fhl;
	int		fh;
	
	strcpy(path, db_path);
	strcat(path, "\\DBASE.DAT");
	fhl=Fopen(path, FO_READ);
	if(fhl < 0) return(0);
	fh=(int)fhl;
	Fseek(idx->db_offset+sizeof(INDEXER), fh, 0);
	Fread(fh, idx->db_size-sizeof(INDEXER), buf);
	Fclose(fh);
	return(1);
}

int Idx_move_if(int old_loc, int new_loc, uint d_date, void (*guckguck)(void))
{/* Verschiebt alle old_loc nach new_loc, wenn
    Ñlter als Datum oder Datum 0 ist.
    Fals old_loc=FF_ORD wird nur dann verschoben, wenn fÅr
    Ordner nicht "beim AufrÑumen ignorieren" gesetzt ist
    (d.h. fspec.flags='Ig').
    Zwischendurch wird guckguck aufgerufen.
    Falls was verschoben wurde wird 1, sonst 0 zurÅckgegeben */
    
	long 		fhl, fix;
	int	 		fidx, fdat, guck_count=0, ret=0;
	char 		path[256];
	INDEXER	*idx;

	strcpy(path, db_path);
	strcat(path, "\\DBASE.IDX");
	fhl=Fopen(path, FO_RW);
	if(fhl < 0) return(0);
	fidx=(int)fhl;

	strcpy(path, db_path);
	strcat(path, "\\DBASE.DAT");
	fhl=Fopen(path, FO_RW);
	if(fhl < 0) {Fclose(fidx); return(0);}
	fdat=(int)fhl;
	
	graf_mouse(BUSYBEE, NULL);
	idx=Idx_scan(IDX_FIRST, old_loc, -1, &fix);
	while(idx)
	{
		if(fld_check_ignore(idx->list_id)==0)
		{
			if((idx->fdate < d_date)||(d_date==0))
			{
				ret=1;
				idx->flags=(idx->flags & (~FF_LOCATION)) | new_loc;
				if(new_loc==FF_NON) idx->ftype=FF_NON;
				Fseek(fix*sizeof(INDEXER), fidx, 0);
				Fwrite(fidx, sizeof(INDEXER), idx);
				Fseek(idx->db_offset, fdat, 0);
				Fwrite(fdat, sizeof(INDEXER), idx);
			}
		}
		++guck_count;
		if(guck_count == GUCKGUCKTIMER)
		{
			guck_count=0;
			guckguck();
		}
		idx=Idx_scan(IDX_NEXT, old_loc, -1, &fix);
	}
	Idx_scan(IDX_LAST, 0, 0, NULL);
	Fclose(fidx);
	Fclose(fdat);
	graf_mouse(ARROW, NULL);
	return(ret);
}

void Idx_clear(void (*guckguck)(void))
{/* Kopiert die Datenbank um und schmeiût dabei alle
		ftyp=0 raus.
		Zwischendurch wird guckguck aufgerufen.
	*/

	long 		fhl, blen, db_offset;
	int	 		fiin, fiout, fdin, fdout, guck_count;
	char 		path[256], path2[256], *buf;
	INDEXER	idx;

	strcpy(path, db_path);
	strcat(path, "\\DBASE.IDX");
	fhl=Fopen(path, FO_READ);
	if(fhl < 0) return;
	fiin=(int)fhl;

	strcpy(path, db_path);
	strcat(path, "\\DBASE.DAT");
	fhl=Fopen(path, FO_READ);
	if(fhl < 0) {Fclose(fiin); return;}
	fdin=(int)fhl;

	strcpy(path, db_path);
	strcat(path, "\\DBASE.NID");
	fhl=Fcreate(path, 0);
	if(fhl < 0) {Fclose(fiin); Fclose(fdin); return;}
	fiout=(int)fhl;

	strcpy(path, db_path);
	strcat(path, "\\DBASE.NDT");
	fhl=Fcreate(path, 0);
	if(fhl < 0) {Fclose(fiin); Fclose(fdin); Fclose(fiout); return;}
	fdout=(int)fhl;
	
	blen=get_buffer(&buf, 1);
	graf_mouse(BUSYBEE, NULL);
	db_offset=0; guck_count=0;
	/* Index umkopieren */
	do
	{
		fhl=Fread(fiin, sizeof(INDEXER), &idx);
		if(fhl > 0)
		{
			if((idx.ftype != FF_NON) && ((idx.flags & FF_LOCATION) != FF_NON))
			{	/* Behalten */
				idx.db_offset=db_offset;
				db_offset+=idx.db_size;
				if(Fwrite(fiout, sizeof(INDEXER), &idx) < 0) goto _fatal;
			}
			++guck_count;
			if(guck_count == GUCKGUCKTIMER)
			{
				guck_count=0;
				guckguck();
			}
		}
	}while(fhl > 0);
	Fclose(fiin); Fclose(fiout);
	db_offset=0; guck_count=0;
	/* Data umkopieren */
	do
	{
		fhl=Fread(fdin, sizeof(INDEXER), &idx);
		if(fhl == sizeof(INDEXER))
		{
			if((idx.ftype != FF_NON) && ((idx.flags & FF_LOCATION) != FF_NON))
			{ /* Behalten */
				idx.db_offset=db_offset;
				db_offset+=idx.db_size;
				if((Fwrite(fdout, sizeof(INDEXER), &idx)) < 0) goto _fatal;
				if((Fcopy(fdin, fdout, idx.db_size-sizeof(INDEXER), buf, blen)) < 0) goto _fatal;
			}
			else
				Fseek(idx.db_size-sizeof(INDEXER), fdin, 1);
			guckguck();	/* Immer aufrufen, weil das hier eh lange dauert */
		}
	}while(fhl > 0);
	Fclose(fdin); Fclose(fdout);
	graf_mouse(ARROW, NULL);
	
	get_buffer(&buf, 0);

	strcpy(path, db_path);	strcat(path, "\\DBASE.IDX");
	Fdelete(path);
	strcpy(path, db_path);	strcat(path, "\\DBASE.DAT");
	Fdelete(path);

	strcpy(path, db_path); strcat(path, "\\DBASE.NID");
	strcpy(path2, db_path); strcat(path2, "\\DBASE.IDX");
	Frename(0, path, path2);
	strcpy(path, db_path); strcat(path, "\\DBASE.NDT");
	strcpy(path2, db_path); strcat(path2, "\\DBASE.DAT");
	Frename(0, path, path2);
	return;
	
_fatal:
	Fclose(fiin);Fclose(fiout);Fclose(fdin);Fclose(fdout);
	strcpy(path, db_path);	strcat(path, "\\DBASE.NID");
	Fdelete(path);
	strcpy(path, db_path);	strcat(path, "\\DBASE.NDT");
	Fdelete(path);
	get_buffer(&buf, 0);
}

void set_dbcheck_win(long count)
{
	if(count > -1) 
	{
		ltoa(count, iwin.dinfo->tree[CDBCOUNT].ob_spec.tedinfo->te_ptext, 10);
		w_objc_draw(&iwin, CDBCOUNT, 8, sx,sy,sw,sh);
	}
	while(appl_read(-1, 16, pbuf)) w_dispatch(pbuf);
}
void set_dbcheck_special(long count)
{
	static int pos;
	
	ltoa(count, iwin.dinfo->tree[CDBCOUNT].ob_spec.tedinfo->te_ptext, 10);
	switch(pos)
	{
		case 0: strcat(iwin.dinfo->tree[CDBCOUNT].ob_spec.tedinfo->te_ptext, " [*  ]"); pos=1; break;
		case 1: strcat(iwin.dinfo->tree[CDBCOUNT].ob_spec.tedinfo->te_ptext, " [ * ]"); pos=2; break;
		case 2: strcat(iwin.dinfo->tree[CDBCOUNT].ob_spec.tedinfo->te_ptext, " [  *]"); pos=3; break;
		case 3: strcat(iwin.dinfo->tree[CDBCOUNT].ob_spec.tedinfo->te_ptext, " [ * ]"); pos=0; break;
	}
	w_objc_draw(&iwin, CDBCOUNT, 8, sx,sy,sw,sh);
	while(appl_read(-1, 16, pbuf)) w_dispatch(pbuf);
}

int cmp_dbfiles(void)
{/* Return: 0=ok, 1=Fehler in Datenbank, -1=lokaler Fehler */
	char	ipath[256], dpath[256];
	long	fhl, cnt=0;
	int		fhi, fhd;
	INDEXER ix1, ix2;
	ix2.db_offset=0;	/* supress warning */
	
	strcpy(ipath, db_path); strcpy(dpath, db_path);
	strcat(ipath, "\\DBASE.IDX");
	strcat(dpath, "\\DBASE.DAT");
	set_dbcheck_win(0);

	fhl=Fopen(ipath, FO_READ); if(fhl < 0) return(1);
	fhi=(int)fhl;
	fhl=Fopen(dpath, FO_READ); if(fhl < 0) {Fclose(fhi); return(1);}
	fhd=(int)fhl;
	while(Fread(fhi, sizeof(INDEXER), &ix1) > 0)
	{/* Wenn hier weniger Bytes gelesen werden, fÑllt das spÑtestens
	   beim Vergleich auf */
		if(cnt > 0) /* Ist nicht die erste Nachricht, prÅfen ob neuer offset zu vorheriger LÑnge paût */
		{
			if(ix1.db_offset != ix2.db_offset+ix2.db_size)
				{Fclose(fhi); Fclose(fhd);return(1);}
		}
		Fseek(ix1.db_offset, fhd, 0);
		fhl=Fread(fhd, sizeof(INDEXER), &ix2);
		set_dbcheck_win(++cnt);
		if((memcmp(&ix1, &ix2, sizeof(INDEXER)))||(fhl!=sizeof(INDEXER))) {Fclose(fhi); Fclose(fhd);return(1);}
	}
	Fclose(fhi);
	Fclose(fhd);
	return(0);
}

char *memfind(char *src, char *fnd, long len)
{
	long flen=strlen(fnd);
	char	*mfnd=fnd;
	
	while(len--)
	{
		if(*src++==*fnd) 
		{
			++fnd;
			if(*fnd==0) return(src-flen);
		}
		else fnd=mfnd;
	}
	return(NULL);
}

int repair_dbase(void)
{/* Return: 0 Reparatur ok
						1 Reparatur mit Verlusten
						2 Keine Reparatur mîglich
	*/
	#define SBUFSIZ 16384
	char	ipath[256], dpath[256], npath[256], *found, *copy_buf;
	static char buf[SBUFSIZ];
	long	fhl, cnt=0, offset=0, copy_len, last_ok_offset=0;
	int		fhi, fhd, fhn, ret=0;
	INDEXER ix;
	
	iwin.dinfo->tree[CDBICON].ob_flags&=(~HIDETREE);
	iwin.dinfo->tree[CDBTITEL].ob_spec.free_string=gettext(DBREPAIRTXT);
	s_redraw(&iwin);
	
	strcpy(ipath, db_path); strcpy(dpath, db_path); strcpy(npath, db_path);
	strcat(ipath, "\\DBASE.IDX");
	strcat(dpath, "\\DBASE.DAT");
	strcat(npath, "\\DBASE.NDT");
	set_dbcheck_win(0);

	fhl=Fopen(dpath, FO_READ); if(fhl < 0) return(2);
	fhd=(int)fhl;
	fhi=(int)Fcreate(ipath, 0);
	fhn=(int)Fcreate(npath, 0);
	
	graf_mouse(BUSYBEE, NULL);	
	copy_len=get_buffer(&copy_buf, 1);
	while(Fread(fhd, sizeof(INDEXER), &ix) > 0)
	{
		if( (ix.magic1 != 'IdXm') || (ix.magic2 != 'hGwM') )
		{ /* NÑchste Stelle finden, die auf magic paût, 
				angefangen bei letzter Nachricht, die ok war (hinter
				magic1/2, wird ja sonst nochmal genommen). Vielleicht
				war bei der letzten nÑmlich eine db_size eingetragen,
				die nicht der Wahrheit entspricht (zu groû) und die nÑchste
				Nachricht steht schon frÅher in der DB. */
			ret=1;
			Fseek(last_ok_offset+8, fhd, 0);
			Fread(fhd, SBUFSIZ, buf);
			while((found=memfind(buf, "IdXmhGwM", SBUFSIZ))==NULL)
			{
				set_dbcheck_special(cnt);
				if(Fread(fhd, SBUFSIZ, buf) < SBUFSIZ) goto _end_rep;
			}
			Fseek(-SBUFSIZ+(found-buf), fhd, 1);
			if(Fread(fhd, sizeof(INDEXER), &ix) < sizeof(INDEXER)) 
				goto _end_rep;
		}
		else
			last_ok_offset=Fseek(0, fhd, 1);
		set_dbcheck_win(++cnt);
		ix.db_offset=offset;
		Fwrite(fhi, sizeof(INDEXER), &ix);
		Fwrite(fhn, sizeof(INDEXER), &ix);
		Fcopy(fhd, fhn, ix.db_size-sizeof(INDEXER), copy_buf, copy_len);
		offset+=ix.db_size;
	}
_end_rep:
	get_buffer(&copy_buf, 0);
	graf_mouse(ARROW, NULL);
	Fclose(fhd);
	Fclose(fhi);
	Fclose(fhn);
	Fdelete(dpath);
	Frename(0, npath, dpath);
	return(ret);
}

void kill_dbase(void)
{
	char	ipath[256], dpath[256];
	int		fh;

	graf_mouse(BUSYBEE, NULL);
	set_dbcheck_win(0);
	strcpy(ipath, db_path); strcpy(dpath, db_path);
	strcat(ipath, "\\DBASE.IDX");
	strcat(dpath, "\\DBASE.DAT");

	fh=(int)Fcreate(ipath, 0); Fclose(fh);
	fh=(int)Fcreate(dpath, 0); Fclose(fh);
	evnt_timer(1000, 0);
	graf_mouse(ARROW, NULL);
}

int Check_dbase(void)
{/* Return: 0=alles ok, 1=Wurde repariert, 2=Irreparabel */
	int		ret;
	OBJECT *tree;
	DINFO dinfo;

	rsrc_gaddr(0, CHECKDBASE, &tree);
	tree[CDBICON].ob_flags|=HIDETREE;
	tree[CDBTITEL].ob_spec.free_string=gettext(DBCHECKTXT);
	tree[CDBCOUNT].ob_spec.tedinfo->te_ptext[0]=0;
	lock_menu(omenu);
	w_dinit(&iwin);
	dinfo.tree=tree;
	dinfo.support=0;
	dinfo.osmax=0;
	dinfo.odmax=8;
	iwin.dinfo=&dinfo;
	w_dial(&iwin, D_CENTER);
	dinfo.dservice=NULL;
	dinfo.dedit=0;
	w_open(&iwin);
	w_modal(&iwin, MODAL_ON);
	
	if((ret=cmp_dbfiles())<=0) 
	{
		if(ret==0) form_alert(1, gettext(DBCOK));
		ret=0; 
		goto _dbye;
	}
	
	if(form_alert(1, gettext(DBCBAD))==2) {ret=0; goto _dbye;}
	ret=1;
	switch(repair_dbase())
	{
		case 0:	/* Reparatur ok */
			form_alert(1, gettext(DBREPOK));
		break;
		case 1:	/* Reparatur mit Verlusten */
			form_alert(1, gettext(DBREPBAD));
		break;
		case 2:	/* Keine Reparatur mîglich */
			if(form_alert(1, gettext(DBNOREP))==2) goto _dbye;
			kill_dbase();
		break;
	}

_dbye:
	w_modal(&iwin, MODAL_OFF);
	w_kill(&iwin);
	unlock_menu(omenu);

	return(ret);
}