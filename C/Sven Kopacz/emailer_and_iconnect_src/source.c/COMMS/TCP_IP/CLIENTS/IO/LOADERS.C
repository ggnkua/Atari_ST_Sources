#include <ec_gem.h>
#include "io.h"
#include "ioglobal.h"
#include "anhang.h"
#include "indexer.h"

char	abs_buf[256];
char	btr_buf[256];
#define	NO_INF_STR "?                                                               "

extern void decode_quoted_printable_header(char *c);

void decode_head_line(char *c);

void extract_head(int ftype, char *c, char *from, char *subj)
{
	char	*x, *br, *er, *mf=from, *of=from, *os=subj, *eof;
	int		count;

	if(ftype > FLD_SNT)
	{/* "From" suchen */
		x=strstr(c, "Resent-From:");
		if(x==NULL) x=strstr(c, "From:");
		if(x)
		{
			eof=strchr(x, 13); if(eof==NULL) eof=strchr(x, 10);
			br=strchr(x, '<'); if(br) er=strchr(br, '>');
			if(br > eof) br=NULL;
			if(br && er) {x=br+1, *er=0;}
			else 
			{
				if(*x=='F')	x+=5; /* From: */
				else x+=12;	/* Resent-From: */
			}
			while(*x==' ')++x;
			count=0;
			while((*x!=13)&&(*x!=(10))&&(*x!='(')&&(*x)&&(count<64))
			{*from++=*x++; ++count;}
			*from=0;
			while(from[strlen(from)-1]==' ') from[strlen(from)-1]=0;
			if(er&&br) *er='>';
			x=adr_match(mf);
			if(x && x[0])
			{
				strncpy(mf, x, 64); mf[64]=0;
				count=(int)strlen(mf);
			}
			decode_head_line(of);
			/* Mit Leerzeichen fÅllen */
			count=(int)strlen(of); from=&(of[count]);
			while(count < 64)
			{*from++=' '; ++count;}
			*from=0;
		}
		else
		{ memset(from, ' ', 64); from[0]='?'; from[64]=0;}
	}
	else
	{/* "To" suchen */
		x=strstr(c, "To:");
		if(x==NULL)		x=strstr(c, "Newsgroups:");
		if(x)
		{
			eof=strchr(x, 13); if(eof==NULL) eof=strchr(x, 10);
			br=strchr(x, '<'); if(br) er=strchr(br, '>');
			if(br > eof) br=NULL;
			if(br && er) {x=br+1; *er=0;}
			else {if(*x=='T') x+=3; else x+=11;}
			while(*x==' ')++x;
			count=0;
			while((*x!=13)&&(*x!=(10))&&(*x!='(')&&(*x)&&(count<64))
			{*from++=*x++; ++count;}
			*from=0;
			while(from[strlen(from)-1]==' ') from[strlen(from)-1]=0;
			if(er&&br) *er='>';
			x=adr_match(mf);
			if(x && x[0])
			{
				strncpy(mf, x, 64); mf[64]=0;
				count=(int)strlen(mf);
			}
			decode_head_line(of);
			/* Mit Leerzeichen fÅllen */
			count=(int)strlen(of); from=&(of[count]);
			while(count < 64)
			{*from++=' '; ++count;}
			*from=0;
		}
		else
		{ memset(from, ' ', 64); from[0]='?'; from[64]=0;}
	}
	x=strstr(c, "Subject:");
	if(x)
	{
		x+=8; while(*x==' ')++x;
		count=0;
		while((*x!=13)&&(*x!=(10))&&(*x)&&(count<64))
		{*subj++=*x++; ++count;}
		*subj=0;
		decode_head_line(os);
		count=(int)strlen(os); subj=&(os[count]);
		while(count < 64)
		{*subj++=' '; ++count;}
		*subj=0;
	}
	else
	{ memset(subj, ' ', 64); subj[0]='?'; subj[64]=0;}
}


/* -------------------------------------- */

void	make_ascii_fdate(char *text, uint date, uint time)
{
	int min, hr, day, month, year;
	char  num[32];
	
	min=(int)((long)((time & 2016l)/32l));
	hr=(int)((long)((time & 63488l)/2048l));
	
	day=(int)((long)(date & 31l));
	month=(int)((long)((date & 480l)/32l));
	year=(int)((long)((date & 65024l)/512l))+1980;
	
	strcpy(text, itoa2(day, num));
	strcat(text, ".");
	strcat(text, itoa2(month, num));
	strcat(text, ".");
	strcat(text, itoa(year, num, 10));

	strcat(text, "  ");
	strcat(text, itoa2(hr, num));
	strcat(text, ":");
	strcat(text, itoa2(min, num));
}

/* -------------------------------------- */

void make_list_adr(char *dst, char *src)
{/* dst muû mindestens 65 Zeichen fassen */
	char *c, real_name[66], cmp_buf[66];
	int		a=0;

	real_name[0]=0;
	/* Klartextnamen suchen */
	if((c=strchr(src, '<')) <= src)	/* Nix vor "<adr>" */
	{
		c=strchr(src, '('); a=1;
		if(c==NULL)
		{ c=strchr(src, '\"'); a=2; }
	}
	if(c)
	{
		if(a==1)	/* Ab c++ bis ')' kopieren */
		{
			strncpy(real_name, c+1, 64); real_name[64]=0;
			if((c=strchr(real_name, ')'))!=NULL) *c=0;
		}
		else if(a==2)	/* Ab c++ bis '"' kopieren */
		{
			strncpy(real_name, c+1, 64); real_name[64]=0;
			if((c=strchr(real_name, '\"'))!=NULL) *c=0;
		}
		else /* ab src bis '<' kopieren */
		{
			*c=0;
			strncpy(real_name, src, 64); real_name[64]=0;
			*c='<';
		}
	}
	/* Realname steht jetzt ggf. in real_name */
	
	/* Jetzt eMail-Adresse rausfummeln und schauen, ob im Adreûbuch
	   vorhanden */
	/* Falls in '<>' Adresse rauspicken, sonst alles kopieren */	
	/* Da die Grîûe von dst unbekannt ist, kopieren wir max. 64 Zeichen */
	c=strchr(src, '<');
	if(c)	strncpy(dst, c, 64);
	else strncpy(dst, src, 64);
	dst[64]=0;
	/* Trailing Spaces lîschen */
	a=(int)strlen(dst);
	while(a && dst[a-1]==' ')
		dst[--a]=0;

	/* Alle '<''>' und Texte in '()' entfernen */
	ed_adr_compress(dst);
	/* Gegen Adreûbuch-Namen austauschen */
	strcpy(cmp_buf, dst);
	c=adr_match(dst);
	if(c && c[0] && strcmp(cmp_buf, c))	/* énderungen wurden vorgenommen */
	{
		strncpy(dst, c, 64);
		dst[64]=0;
	}
	else if(real_name[0])	/* Sonst den Realnamen aus der Mail eintragen */
		strcpy(dst, real_name);

	/* Mit Space auffÅllen */		
	a=(int)strlen(dst);
	while(a < 64) dst[a++]=' ';
	dst[a]=0;
}

void load_idx_list(char *bpath, int pms, char *buf, int file_loc, long f_index)
{/* Mail-Liste aus <bpath> laden,
		pms=0/1, d.h. bei eigenen "To" statt "From" zeigen ja/nein
		buf="" oder voller Name der Gruppe/Ordner 
		file_loc=location, FF_PM,FF_OM,FF_ORD,FF_DEL
		f_index=Folder-Index fÅr OM/ORD
	*/
		
	long	fhl, files, f_lix, next_mem_increase;
	char	path[256];
	int		fh;
	FLD		*fldbuf;
	DTA		*old=Fgetdta(), dta;
	INDEXER	*ix;
	const long c_mem_ahead=50;
	
	graf_mouse(BUSYBEE, NULL);

	/* Initialisieren */
	if(fld) {free(fld); fld=NULL;}
	fld_c=0; next_mem_increase=0;
	if((ios.list!=0)&&(ios.list!=3))	/* ".."-Eintrag einfÅgen */
	{
		fld=malloc(sizeof(FLD));
		if(fld==NULL) {graf_mouse(ARROW, NULL); form_alert(1, gettext(NOMEM)); return;}
		fld[0].ftype=FLD_BAK;
		strcpy(fld[0].from, ".. ["); strcat(fld[0].from, buf); strcat(fld[0].from, "]");
		fld[0].subj[0]=0;
		fld[0].date[0]=0;
		fld_c=1;
		next_mem_increase=1;
	}

	/* Dateien per Index holen */
	if((ix=Idx_scan(IDX_FIRST, file_loc, f_index, &f_lix)) != NULL) do
	{
		if(fld_c == next_mem_increase)
		{
			fldbuf=malloc((fld_c+1+c_mem_ahead)*sizeof(FLD));
			if(fldbuf==NULL)
			{
				Idx_scan(IDX_LAST,0,0,NULL);
				if(fld) free(fld);
				fld=NULL; fld_c=0; 	graf_mouse(ARROW, NULL);
				form_alert(1, gettext(NOMEM)); return;
			}
			if(fld) memcpy(fldbuf, fld, fld_c*sizeof(FLD));
			if(fld) free(fld); 
			fld=fldbuf;
			next_mem_increase=fld_c+1+c_mem_ahead;
		}
		
		fld[fld_c].fspec.finfo.offset=ix->db_offset;
		fld[fld_c].fspec.finfo.size=ix->db_size;
		fld[fld_c].fspec.finfo.flags=ix->flags;
		fld[fld_c].ftime=ix->ftime;
		fld[fld_c].fdate=ix->fdate;
		fld[fld_c].ftype=ix->ftype;
		if(pms && ix->ftype <= FLD_SNT)
			make_list_adr(fld[fld_c].from, ix->to);
		else
			make_list_adr(fld[fld_c].from, ix->from);
		strcpy(fld[fld_c].subj, ix->subj);
		fld[fld_c].idx=f_lix;
		memcpy(fld[fld_c].msg_id, ix->msg_id, 3*66);
		make_ascii_fdate(fld[fld_c].date, ix->fdate, ix->ftime);
		fld[fld_c].loc_flags=0;
		if(ix->flags & FF_ISOM) fld[fld_c].loc_flags |= LF_OM;
		++fld_c;
	}while( (ix=Idx_scan(IDX_NEXT, file_loc, f_index, &f_lix)) !=NULL );
	Idx_scan(IDX_LAST,0,0,NULL);

	if(pms==0) {graf_mouse(ARROW, NULL); return;}
	
	/* SND-Dateien anhÑngen */
	strcpy(path, bpath);
	strcat(path, "\\*.SND");
	/* Dateien zÑhlen */
	Fsetdta(&dta);
	files=0;
	if(!Fsfirst(path, FA_HIDDEN))	do
	{ ++files; } while(!Fsnext());
	Fsetdta(old);
	if(files==0) {graf_mouse(ARROW, NULL); return;}
	fldbuf=malloc((fld_c+files)*sizeof(FLD));
	if(fldbuf==NULL)
	{
		if(fld) free(fld);
		fld=NULL; fld_c=0; 	graf_mouse(ARROW, NULL);
		form_alert(1, gettext(NOMEM)); return;
	}
	if(fld) memcpy(fldbuf, fld, fld_c*sizeof(FLD));
	if(fld) free(fld); 
	fld=fldbuf;
	
	Dsetpath(bpath);
	strcpy(path, bpath);
	strcat(path, "\\*.SND");
	Fsetdta(&dta);
	buf[1000]=0;
	fhl=files; files=fld_c; fld_c+=fhl;
	if(!Fsfirst(path, FA_HIDDEN))	do
	{
		strcpy(fld[files].fspec.fname, dta.d_fname);
		fld[files].ftime=dta.d_time;
		fld[files].fdate=dta.d_date;
		fld[files].ftype=FLD_SND;
		fld[files].loc_flags=0;
		fhl=Fopen(dta.d_fname, FO_READ); fh=(int)fhl;
		if(fhl >= 0)
		{
			fhl=Fread(fh, 1000, buf);
			Fclose(fh);
			if(fhl>0)buf[fhl-1]=0;
			extract_head(fld[files].ftype, buf, fld[files].from, fld[files].subj);
			if(strstr(buf, "Newsgroups:")) fld[files].loc_flags |= LF_OM;
		}
		else extract_head(FLD_NEW, "", fld[files].from, fld[files].subj);
		make_ascii_fdate(fld[files].date, dta.d_date, dta.d_time);
		if(dta.d_attrib & FA_HIDDEN)
			fld[files].loc_flags|=LF_DELAYED;
		fld[files].idx=-1;
		++files;
	}while((!Fsnext()) && (files < fld_c));
	Fsetdta(old);
	graf_mouse(ARROW, NULL);
}

/* -------------------------------------- */

void load_list(char *bpath, long files, char *buf, int file_loc, long f_index)
{/* Mail-Liste aus <bpath> laden,
		files=0 oder 1, -> buf="" oder voller Name der Gruppe/Ordner 
		file_loc=location, FF_PM,FF_OM,FF_ORD,FF_DEL
		f_index=Folder-ID fÅr OM/ORD
	*/
		
	long	fhl;
	char	path[256], *c;
	int		fh, pms;
	DTA		*old=Fgetdta(), dta;

	/* Bei eigenen persînlichen Nachrichten "To" statt "From" zeigen
		 (bei OMs sinnlos, gibt kein "To") */
	if((file_loc==FF_PM)||(file_loc==FF_ORD)) pms=1;
	else if(!strcmp(&(bpath[strlen(bpath)-8]), "\\OM\\SEND")) pms=1;
	else pms=0;
	
	if(db_mode)
	{
		load_idx_list(bpath, pms, buf, file_loc, f_index);
		return;
	}
	
	strcpy(path, bpath);
	strcat(path, "\\*.*");
	/* Dateien zÑhlen */
	graf_mouse(BUSYBEE, NULL);
	Fsetdta(&dta);
	if(!Fsfirst(path, FA_HIDDEN))	do
	{ ++files;}while(!Fsnext());
	Fsetdta(old);
	graf_mouse(ARROW, NULL);

	/* Array anlegen */
	if(fld) {free(fld); fld=NULL;}
	if((fld_c=files)==0) return;
	fld=malloc(files*sizeof(FLD));
	if(fld==NULL)
	{	form_alert(1, gettext(NOMEM)); return;}

	/* Dateien laden */
	files=0;
	if((ios.list!=0)&&(ios.list!=3))	/* ".."-Eintrag einfÅgen */
	{
		fld[0].ftype=FLD_BAK;
		strcpy(fld[0].from, ".. ["); strcat(fld[0].from, buf); strcat(fld[0].from, "]");
		fld[0].subj[0]=0;
		fld[0].date[0]=0;
		files=1;
	}
	Dsetpath(bpath);
	strcpy(path, bpath);
	strcat(path, "\\*.*");
	graf_mouse(BUSYBEE, NULL);
	Fsetdta(&dta);
	buf[1000]=0;
	if(!Fsfirst(path, FA_HIDDEN))	do
	{
		strcpy(fld[files].fspec.fname, dta.d_fname);
		fld[files].ftime=dta.d_time;
		fld[files].fdate=dta.d_date;
		c=&(dta.d_fname[strlen(dta.d_fname)-3]);
		fld[files].loc_flags=0;
		if(!strcmp(c, "SND")) 
		{
			fld[files].ftype=FLD_SND;
			if(dta.d_attrib & FA_HIDDEN) fld[files].loc_flags|=LF_DELAYED;
		}
		else if(!strcmp(c, "SNT")) fld[files].ftype=FLD_SNT;
		else if(!strcmp(c, "NEW")) fld[files].ftype=FLD_NEW;
		else if(!strcmp(c, "RED")) fld[files].ftype=FLD_RED;
		else fld[files].ftype=FLD_NON;
		fhl=Fopen(dta.d_fname, FO_READ); fh=(int)fhl;
		if(fhl >= 0)
		{
			fhl=Fread(fh, 1000, buf);
			Fclose(fh);
			if(fhl>0)buf[fhl-1]=0;
			if(pms)
				extract_head(fld[files].ftype, buf, fld[files].from, fld[files].subj);
			else
				extract_head(FLD_NEW, buf, fld[files].from, fld[files].subj);
			if(strstr(buf, "Newsgroups:")) fld[files].loc_flags|=LF_OM;
		}
		else extract_head(FLD_NEW, "", fld[files].from, fld[files].subj);
		make_ascii_fdate(fld[files].date, dta.d_date, dta.d_time);
		fld[fld_c].idx=-1;
		++files;
	}while((!Fsnext()) && (files < fld_c));
	Fsetdta(old);
	graf_mouse(ARROW, NULL);
}

void load_act_list(void)
{
	long	files=0;
	int file_loc;
	char	bpath[256], buf[1001];

	strcpy(bpath, db_path);
	switch(ios.list)
	{
		case 0:
			strcat(bpath, "\\PM");
			file_loc=FF_PM;
		break;
		case 1:
			strcat(bpath, "\\OM\\");
			strcat(bpath, fld[ios.list_sel].fspec.fname);
			strcpy(act_fold, fld[ios.list_sel].fspec.fname);
			strcpy(buf, fld[ios.list_sel].from);
			++files;	/* FÅr ".." Eintrag */
			file_loc=FF_OM;
		break;
		case 2:
			strcat(bpath, "\\ORD\\");
			strcat(bpath, fld[ios.list_sel].fspec.fname);
			strcpy(act_fold, fld[ios.list_sel].fspec.fname);
			strcpy(buf, fld[ios.list_sel].from);
			++files;	/* FÅr ".." Eintrag */
			file_loc=FF_ORD;
		break;
		case 3:
			strcat(bpath, "\\DEL");
			file_loc=FF_DEL;
		break;
	}
	load_list(bpath, files, buf, file_loc, atol(act_fold));
}

void reload_act_list(void)
{
	long	files=0;
	int		file_loc;
	char	bpath[256], buf[1001];

	strcpy(bpath, db_path);
	switch(ios.list)
	{
		case 0:
			strcat(bpath, "\\PM");
			file_loc=FF_PM;
		break;
		case 1:
			strcat(bpath, "\\OM\\");
			strcat(bpath, act_fold);
			strcpy(buf, &(fld[0].from[4]));
			buf[strlen(buf)-1]=0;
			++files;	/* FÅr ".." Eintrag */
			file_loc=FF_OM;
		break;
		case 2:
			strcat(bpath, "\\ORD\\");
			strcat(bpath, act_fold);
			strcpy(buf, &(fld[0].from[4]));
			buf[strlen(buf)-1]=0;
			++files;	/* FÅr ".." Eintrag */
			file_loc=FF_ORD;
		break;
		case 3:
			strcat(bpath, "\\DEL");
			file_loc=FF_DEL;
		break;
	}
	load_list(bpath, files, buf, file_loc, atol(act_fold));
}

/* -------------------------------------- */

int load_folders(int check_unread)
{/* Return: -1=kein Speicher, 0=Keine Ordner, 1=Ok */
	long	files=0, fhl;
	char	path[256], bpath[256];
	int		fh;
	DTA		*old=Fgetdta(), dta;
	INDEXER *idx;

	if(fld_bak)
	{
		if(fld) free(fld);
		fld=fld_bak; fld_bak=NULL;
		fld_c=fld_c_bak; fld_c_bak=0;
	}

	strcpy(bpath, db_path);
	strcat(bpath, "\\ORD");
	strcpy(path, bpath);
	strcat(path, "\\ORD.IDX");
	/* Dateien zÑhlen */
	graf_mouse(BUSYBEE, NULL);
	fhl=Fopen(path, FO_READ);
	if(fhl >= 0)
	{
		files=Fseek(0, (int)fhl, 2);
		Fclose((int)fhl);
		files/=sizeof(FLD);
	}
	graf_mouse(ARROW, NULL);

	/* Array anlegen */
	if(fld) {free(fld); fld=NULL;}
	if((fld_c=files)==0) return(0);
	fld=malloc(files*sizeof(FLD));
	if(fld==NULL)
	{	form_alert(1, gettext(NOMEM)); return(-1);}

	/* Index-Datei laden */
	fhl=Fopen(path, FO_READ);
	if(fhl >= 0)
	{
		fh=(int)fhl;
		fhl=Fread(fh, files*sizeof(FLD), fld); Fclose(fh);
	}
	if(fhl < 0)	/* Kann Datei nicht îffnen oder nicht laden */
	{
		if(fld) free(fld);
		fld=NULL; fld_c=0; return(0);
	}
	/* Was wurde tatsÑchlich geladen? */
	files=fhl/sizeof(FLD);	
	if(files < fld_c) fld_c=files;	/* Nicht genug geladen, anpassen */

	if(check_unread==0) return(1);

	/* Nach ungelesenen Suchen */
	graf_mouse(BUSYBEE, NULL);
	if(db_mode)
	{
		files=0;	/* Alle loc_flags-Flags lîschen */
		while(files < fld_c) fld[files++].loc_flags=0;
		idx=Idx_scan(IDX_FIRST, -1, -1, &files);
		while(idx)
		{
			if((idx->ftype==FLD_NEW) && ((idx->flags & FF_LOCATION)==FF_ORD))
			{/* Ungelesene geordnete */
				files=0;
				while(files < fld_c)
				{
					if(atol(fld[files].fspec.fname)==idx->list_id)
					{
						fld[files].loc_flags=LF_UNREAD;
						break;
					}
					++files;
				}
			}
			idx=Idx_scan(IDX_NEXT, -1, -1, &files);
		}
		Idx_scan(IDX_LAST, 0, 0, NULL);
	}
	else
	{	
		files=0;
		while(files < fld_c)
		{
			/* enthÑlt neue Dateien? */
			strcpy(path, bpath);
			strcat(path, "\\");
			strcat(path, fld[files].fspec.fname);
			strcat(path, "\\*.NEW");
			Fsetdta(&dta);
			if(Fsfirst(path, 0))	fld[files].loc_flags=0;
			else fld[files].loc_flags=LF_UNREAD;
			Fsetdta(old);
			++files;
		}
	}
	graf_mouse(ARROW, NULL);
	return(1);
}

/* -------------------------------------- */

int load_groups(void)
{/* -1=Kein Speicher, 0=Keine Gruppen, 1=Ok */
	long	files, fhl, snd_files;
	char	path[256], bpath[256];
	int		fh;
	DTA		*old=Fgetdta(), dta, sub_dta;
	INDEXER *idx;
	
	if(fld_bak)
	{
		if(fld) free(fld);
		fld=fld_bak; fld_bak=NULL;
		fld_c=fld_c_bak; fld_c_bak=0;
	}

	strcpy(bpath, db_path);
	strcat(bpath, "\\OM");
	strcpy(path, bpath);
	strcat(path, "\\*.GRP");
	/* Dateien zÑhlen */
	files=1;	/* "Zu sendende Nachrichten" */
	graf_mouse(BUSYBEE, NULL);
	Fsetdta(&dta);
	if(!Fsfirst(path, 0))	do
	{ ++files;}while(!Fsnext());
	Fsetdta(old);
	graf_mouse(ARROW, NULL);

	/* Array anlegen */
	if(fld) {free(fld); fld=NULL;}
	if((fld_c=files)==0) return(0);
	fld=malloc(files*sizeof(FLD));
	if(fld==NULL)
	{	form_alert(1, gettext(NOMEM)); return(-1);}

	/* Zu sendende ZÑhlen */
	fld[0].ftype=FLD_GSD;
	snd_files=0;
	strcpy(fld[0].from, gettext(MAILSTOSEND));
	strcpy(fld[0].fspec.fname, "SEND");
	strcpy(path, bpath);
	strcat(path, "\\SEND\\*SND");
	graf_mouse(BUSYBEE, NULL);
	Fsetdta(&sub_dta);
	if(!Fsfirst(path, 0))	do
	{++snd_files;}while(!Fsnext());
	Fsetdta(old);
	graf_mouse(ARROW, NULL);
	if(snd_files) 
	{
		strcat(fld[0].from, " (");
		ltoa(snd_files, &(fld[0].from[strlen(fld[0].from)]), 10);
		strcat(fld[0].from, ")");
		fld[0].loc_flags=LF_UNREAD;
	}
	else fld[0].loc_flags=0;

	/* Dateien laden */
	files=1;
	Dsetpath(bpath);
	strcpy(path, bpath);
	strcat(path, "\\*.GRP");
	graf_mouse(BUSYBEE, NULL);
	Fsetdta(&dta);
	if(!Fsfirst(path, 0))	do
	{
		strcpy(fld[files].fspec.fname, dta.d_fname);
		if(strchr(fld[files].fspec.fname, '.'))
			*(strchr(fld[files].fspec.fname, '.'))=0;
		fld[files].ftype=FLD_GRP;
		fhl=Fopen(dta.d_fname, FO_READ); fh=(int)fhl;
		if(fhl >= 0)
		{
			Fread(fh, 66, fld[files].from);
			Fclose(fh);
			/* enthÑlt neue Dateien? */
			if(!db_mode)
			{			
				strcpy(path, bpath);
				strcat(path, "\\");
				strcat(path, fld[files].fspec.fname);
				strcat(path, "\\*.NEW");
				Fsetdta(&sub_dta);
				if(Fsfirst(path, 0))	fld[files].loc_flags=0;
				else fld[files].loc_flags=LF_UNREAD;
				Fsetdta(&dta);
			}
			++files;
		}
		else --fld_c;
	}while((!Fsnext()) && (files < fld_c));
	Fsetdta(old);

	if(db_mode)	/* Nach ungelesenen Suchen */
	{
		files=1;	/* Alle loc-Flags lîschen */
		while(files < fld_c) fld[files++].loc_flags=0;
		idx=Idx_scan(IDX_FIRST, -1, -1, &files);
		while(idx)
		{
			if((idx->ftype==FLD_NEW) && ((idx->flags & FF_LOCATION)==FF_OM))
			{/* Ungelesene geordnete */
				files=0;
				while(files < fld_c)
				{
					if(atol(fld[files].fspec.fname)==idx->list_id)
					{
						fld[files].loc_flags=LF_UNREAD;
						break;
					}
					++files;
				}
			}
			idx=Idx_scan(IDX_NEXT, -1, -1, &files);
		}
		Idx_scan(IDX_LAST, 0, 0, NULL);
	}

	graf_mouse(ARROW, NULL);
	return(1);
}

void load_new_list(void)
{
	if(fld_bak)
	{
		ios.list_sel=fld_bak[ios.list_sel].root_index;
		if(fld) free(fld);
		fld=fld_bak; fld_bak=NULL;
		fld_c=fld_c_bak; fld_c_bak=0;
	}
	load_act_list();
	sort_by_sel();
	view_by_sel();
}

/* -------------------------------------- */
/* -------------------------------------- */

void decode_head_line(char *c)
{
	char	*d, *e, *x;
	long	ms;

	while( ((d=strstr(c, "=?"))!=NULL) &&
			(((x=strstr(d, "?Q?"))!=NULL)||((x=strstr(d, "?B?"))!=NULL)) &&
			((e=strstr(x+3, "?="))!=NULL)
		)
	{
		d=x;
		*e=0;
		ms=strlen(&(d[3]));
		/* Situation jetzt: 
				c                    d               e
				Subject: =?ISO-8859-1?Q?R=FCckmeldung0= etc0 */

		if(d[1]=='Q') decode_quoted_printable_header(&(d[3]));
		else decode_base_64(&(d[3]));
		ms-=strlen(&(d[3]));
		if(ms) *e='?';	/* Wenn nichts decodiert wurde, bleibt Terminierung erhalten */
		/* Situation jetzt: 
				c                    d               e
				Subject: =?ISO-8859-1?Q?RÅckmeldung0g?= etc0
				                                   ^^=ms
	  	 Codierungs-Info Åberschreiben */
	  d=strstr(c, "=?");
	  e=strstr(d+2, "?"); e+=3; ms+=(e-d);
		/* Situation jetzt: 
				c        d              e
				Subject: =?ISO-8859-1?Q?RÅckmeldung0g?= etc0 */
	  while(*e) *d++=*e++;
	  *d=0;
	  e=d+ms+2;
	  /* Jetzt: 
	                            d                  e 
	        Subject: RÅckmeldung0?Q?RÅckmeldung0g?= etc0 */
	  /* Den Rest dieser Headerzeile kopieren */
	  c=d;
	  while(*e) *d++=*e++;
	  *d=0;
	}
}

void decode_header(LOADED_MAIL *loadm)
{/* Quoted-printable und Base64 Codierung im Header auflîsen */
	char	*c=loadm->header,*d, *e;
	long	a=loadm->head_len, ms;
	
	if((c==NULL)||(a==0)) return;
	while(a>0)
	{
		a-=strlen(c)+1;
		ms=strlen(c);
		decode_head_line(c);
		ms-=strlen(c);
		if(ms)
		{
		  loadm->head_len-=ms;	/* Differenz durch decodierte Bytes */
		  d=c+strlen(c);			/* Null-Zeichen Ende decodierter String */
		  e=d+ms;							/* Erstes Zeichen nach codiertem String */
		  /* Rest-Header versetzen, restliche LÑnge gleich a */
		  ms=a;
		  while(ms--) *d++=*e++;
		  *d=0;
		}
		c+=strlen(c)+1;
	}
}

/* -------------------------------------- */

long vis_head_copy(char *dst)
{
	long	cnt=0;
	char	*c, *d, *h;
	
	d=ios.headinfo;
	do
	{
		while((*d==' ')||(*d==','))++d;
		c=strchr(d, ',');
		if(c) *c=0;
		h=get_head_field(d);
		if(h)
		{
			cnt+=1+strlen(d)+1+strlen(h)+1;	/* '5'+Feld+' '+Inhalt+'0' */
			if(dst)
			{
				strcpy(dst, "\x05");
				strcat(dst, d); strcat(dst, " ");
				strcat(dst, h);
				dst+=strlen(dst)+1;	/* Das Nullzeichen bleibt! */
			}
		}
		if(c) *c=',';
	}while((d=strchr(d, ','))!=NULL);
	return(cnt);
}

/* -------------------------------------- */

char *get_field(char *field, char *head, long hlen)
{
	char mem=head[hlen], *c=head;
	long	a=strlen(field);

	head[hlen]=0;
	
	while(*c)
	{
		if(!strnicmp(c, field, a))
		{
			head[hlen]=mem;
			c+=strlen(field);
			while((*c==' ')||(*c==9)) ++c;
			return(c);
		}
		while(*c&&(*c!=13))++c;
		if(!*c) break;
		++c;	/* 13 Åbergehen */
	}
	head[hlen]=mem;
	return(NULL);
}

/* -------------------------------------- */

int get_boundary(char *f, long len, char *dst)
{/* f=Zeiger auf Feldinhalt von "Content Type", len=Header-LÑnge
		ab f, dst=Hier wird boundary eingetragen. '--' wird
		immer vorangestellt! 
		o=nix gefunden, 1=ok */
	
	char mem=f[len], *c;
	f[len]=0;
	if((c=stristr(f, "boundary="))==NULL) {f[len]=mem; return(0);}
	c+=strlen("boundary=");
	*dst++='-'; *dst++='-';
	if(*c=='\"')
	{
		++c;
		while(*c && (*c!='\"')) *dst++=*c++;
	}
	else
		while((*c!=13)&&(*c!=' ')&&*c) *dst++=*c++;
	*dst=0;
	f[len]=mem;
	return(1);
}

/* -------------------------------------- */

int split_mime_mail(char *mail, long len, LOADED_MAIL *loadm)
{/* Mail darf nur noch CR enthalten .
		Falls es sich um Multipart handelt, werden die Teile
		aufgelîst. Jeder Teil wird in loadm.(MAIL_ATX) angehÑngt.
		return: 1=ok, 0=Kein Speicher */
		
	long a, hlen, blen;
	char *head, *body, *c, *d, bnd[85];
	MAIL_ATX	**atx;

	/* Header-Ende finden */
	a=0;
	while(a < len)
	{
		if((mail[a]==13) && ((mail[a+1]==13)||(a==0)))
			break;
		++a;
	}
	head=mail;
	hlen=a;
	/* Body-Anfang */
	while((a < len) && (mail[a]==13))++a;
	body=&(mail[a]); blen=len-a;

	c=get_field("Content-Type:", head, hlen);
	if((c) && (!strmnicmp(c, "multipart")))
	{/* Multipart zerlegen */
		if(get_boundary(c, hlen-(c-head), bnd)==0) return(1);
		strcat(bnd, "\r");
		while(1)
		{
			c=strstr(body, bnd); if(c==NULL) return(1);
			c+=strlen(bnd);
			d=strstr(c, bnd); 
			if(d==NULL) 
			{
				strcpy(&(bnd[strlen(bnd)-1]), "--\r");
				d=strstr(c, bnd); 
				if(d==NULL)	return(1);
			}
			*d=0;
			if(split_mime_mail(c, (long)(d-c), loadm)==0) {*d='-'; return(0);}
			*d='-';
			body=d;
		}
	}

	if(hlen==len) return(1); /* Kein Body->und wech */
	if(blen < 2) return(1);	/* Kein Body->und wech */

	/* Single Part einordnen */
	atx=&(loadm->first); while((*atx)!=NULL) atx=&((*atx)->next);
	*atx=malloc(sizeof(MAIL_ATX));
	if(*atx==NULL) return(0);
	(*atx)->atx=malloc(blen+1); 
	if((*atx)->atx==NULL) {free(*atx); *atx=NULL; return(0);}
	(*atx)->atx_len=blen;
	a=0;
	while(a < blen)
	{
		(*atx)->atx[a]=body[a]; ++a;
	}
	(*atx)->atx[a]=0;
	(*atx)->next=NULL;

	(*atx)->file_name[0]=0;
	if(c!=NULL)	/* c ist immer noch Content-Type: */
	{
		d=(*atx)->mime_type;
		while((*c!=' ')&&(*c!=13)&&(*c!=';')) *d++=*c++;
		*d=0;
		/* <name="...">-Extension finden */
		while(*c)
		{
			while((*c==' ')||(*c==9)||((*c==13)&&((*(c+1)==' ')||(*(c+1)==9)))||(*c==';')) ++c;
			if(!strnicmp(c, "name=", 5))
			{/* Gefunden */
				c+=5; if(*c=='\"')++c;
				d=(*atx)->file_name;
				while((*c!='\"')&&(*c!=13)&&(*c!=';')) *d++=*c++;
				*d=0;
				goto _spl_next1;
			}
			while(*c && (*c!=';'))
			{
				if((*c==13)&&(*(c+1)!=' ')) /* Feldende */
					goto _spl_next1;
		 		++c;
			}
		}
	}
	else
		strcpy((*atx)->mime_type, "text/plain");

_spl_next1:
	if((*atx)->file_name[0]==0)
	{/* Kein Dateiname gefunden, vielleicht in "Content-Disposition" */
		c=get_field("Content-Disposition:", head, hlen);
		if(c==NULL) goto _spl_next2;
		/* <filename="...">-Extension finden */
		while(*c)
		{
			while((*c==' ')||(*c==9)||((*c==13)&&((*(c+1)==' ')||(*(c+1)==9)))||(*c==';')) ++c;
			if(!strnicmp(c, "filename=", 9))
			{/* Gefunden */
				c+=9; if(*c=='\"')++c;
				d=(*atx)->file_name;
				while((*c!='\"')&&(*c!=13)&&(*c!=';')) *d++=*c++;
				*d=0;
				goto _spl_next2;
			}
			while(*c && (*c!=';'))
			{
				if((*c==13)&&(*(c+1)!=' ')) /* Feldende */
					goto _spl_next2;
		 		++c;
			}
		}
	}
	
_spl_next2:
	if(!strnicmp((*atx)->file_name, "=?iso-8859-1?", 13))
	{/* Dateiname ist iso-codiert->decodieren */
		decode_head_line((*atx)->file_name);
	}

	c=get_field("Content-Transfer-Encoding:", head, hlen);
	if(c==NULL)
		(*atx)->encoding=0;
	else if(!strmnicmp(c, "7Bit"))
		(*atx)->encoding=1;
	else if(!strmnicmp(c, "8Bit"))
		(*atx)->encoding=2;
	else if(!strmnicmp(c, "Base64"))
		(*atx)->encoding=3;
	else if(!strmnicmp(c, "Binary"))
		(*atx)->encoding=4;
	else if(!strmnicmp(c, "Quoted-Printable"))
		(*atx)->encoding=5;
	else		
		(*atx)->encoding=0;
	return(1);
}

/* -------------------------------------- */

int split_loaded(char *loaded, long llen, LOADED_MAIL *loadm, int cr2zero)
{/* cr2zero: 1=Beim Ablegen des Bodys CR in 0 wandeln und
		Headerinfos voranstellen 
		
		 1=OK, 0=Kein Speicher */
	long a, b, c;
	char	*s, *d;
	MAIL_ATX	*atx, *matx, **patx;
	/* CR/LF-Tohuwabohu auflîsen, es bleiben nur CRs */
	s=d=loaded;
	a=llen;
	while(a)
	{
		switch(*s)
		{
			case 13:
				*d++=*s++;
				if(*s==10){--a; ++s;}	/* LF nach CR Åbergehen */
			break;
			case 10:
				*d++=13;	/* Einzelnes LF wird zu CR */
				++s;
			break;
			default:
				*d++=*s++;
			break;
		}
		--a;
	}
	*d=0;
	llen-=(s-d);
	
	/* Header-Ende finden */
	a=0;
	while(loaded[a])
	{
		if((loaded[a]==13) && ((loaded[a+1]==13)||(a==0)))
			break;
		++a;
	}
	/* a ist llen+1, falls keine Leerzeile gefunden wurde */
	loadm->header=malloc(a+1);
	if(loadm->header==NULL) return(0);
	/* Header kopieren, dabei "Soft-Breaks" weglassen,
		d.h. UmbrÅche denen Whitespace folgen, weil diese als 
		zusammengehîrige Headerzeilen gelten  */
	b=c=0;
	while(b < a)
	{
		switch(loaded[b])
		{
			case 13:
				++b;
				if((loaded[b]!=' ')&&(loaded[b]!=9))
					loadm->header[c++]=13;
				loadm->header[c++]=loaded[b++];
			break;
			default:
				loadm->header[c++]=loaded[b++]; 
			break;
		}
	}
	loadm->header[c]=0;
	/* head_len enthÑlt auch die abschlieûende 0, weil dieses Zeilen-
		 ende natÅrlich zur letzten Headerzeile gehîrt! */
	loadm->head_len=c+1;
	decode_header(loadm);

	/* Umwandeln: 13 wird 0 */
	a=0;
	while(a < loadm->head_len)
	{
		if(loadm->header[a]==13) loadm->header[a]=0;
		++a;
	}

	/*
	  Header fertig 
	*/
	loadm->body=NULL;	loadm->body_len=0;	
	loadm->first=NULL;
	if(a>=llen) return(1); /* Kein Body */

	/* Body zerlegen */
	if(split_mime_mail(loaded, llen, loadm)==0)
	{
		free(loadm->header); loadm->header=NULL;
		loadm->head_len=0;
		atx=loadm->first;
		while(atx)
		{
			matx=atx->next;
			if(atx->atx) free(atx->atx);
			free(atx);
			atx=matx;
		}
		loadm->first=NULL;
		return(0);
	}
	
	/* Ersten ATX-Eintrag mit Typ "Text/Plain" oder "text" finden */
	atx=loadm->first; patx=&(loadm->first);
	while(atx)
	{
		if(!strmnicmp(atx->mime_type, "text/plain")) break;	/* Gefunden */
		if( (strlen(atx->mime_type)==4) && 
				(!strmnicmp(atx->mime_type, "text")))	break;		/* Nehmen wir auch */
		patx=&(atx->next);
		atx=atx->next;
	}
	if(atx==NULL)
	{	/* Kein Text/plain gefunden, irgendwas mit "text" suchen,
			 falls gewÅnscht  */
		if(ios.all_text)
		{
			atx=loadm->first; patx=&(loadm->first);
			while(atx)
			{
				if(!strmnicmp(atx->mime_type, "text")) break;	/* Gefunden */
				patx=&(atx->next);
				atx=atx->next;
			}
		}
	}
	if(atx==NULL) return(1);	/* Kein Text-Eintrag da */
	
	/* Den Text-Eintrag als Body umkopieren */	
	
	/* Speicher fÅr Body */
	a=vis_head_copy(NULL); if(a)++a;	++a; /* eine 0 fÅr Leerzeile, eine 1 fÅr Headerende */
	loadm->body=malloc(atx->atx_len+1+a);
	if(loadm->body==NULL)
	{
		free(loadm->header); loadm->header=NULL;
		loadm->head_len=0;
		atx=loadm->first;
		while(atx)
		{
			matx=atx->next;
			if(atx->atx) free(atx->atx);
			free(atx);
			atx=matx;
		}
		loadm->first=NULL;
		return(0);
	}
	/* Body decodieren */
	if(atx->encoding==3)
	{
		decode_base_64(atx->atx);
		atx->atx_len=strlen(atx->atx);
	}
	else if(atx->encoding==5)
	{
		decode_quoted_printable(atx->atx);
		atx->atx_len=strlen(atx->atx);
	}
	else if((atx->encoding==2) || (atx->encoding==0))	/* 8 bit */
	{/* 8 bit text encoding is assumed as iso-8859-1 */
		decode_iso_8859_1(atx->atx);
	}
	
	if(cr2zero)
	{
		/* Body kopieren, dabei CR/LF in 0 wandeln und Headerinfos 
				eintragen (CR/LF-Verbuchslung wurde zwar eingangs ersetzt,
				dieser Mailteil kînnte aber aus Decodierung stammen und
				deshalb wieder Zeugs enthalten) */
		a=vis_head_copy(loadm->body);
		loadm->body[a++]=1;
		if(a > 1) loadm->body[a++]=0;
		b=0;
		while(atx->atx[b])
		{
			switch(atx->atx[b])
			{
				case 13:
					++b; if(atx->atx[b]==10) ++b;
					loadm->body[a++]=0;
				break;
				case 10:
					++b;
					loadm->body[a++]=0;
				break;
				default:
					loadm->body[a++]=atx->atx[b++];
				break;
			}
		}
	}
	else
	{/* Nur kopieren */
		a=b=0;
		while(atx->atx[b])
			loadm->body[a++]=atx->atx[b++];
	}
	loadm->body[a]=0;
	loadm->body_len=a-1;
	/* ATX aushÑngen */
	*patx=atx->next;
	free(atx->atx);
	free(atx);
	return(1);
}

void free_loaded_mail(void)
{
	free_mail(&loadm);
	loaded=NULL; llen=0;
}

void free_mail(LOADED_MAIL *loadm)
{
	MAIL_ATX	*ma, *mma;

	if(loadm->header) free(loadm->header);
	if(loadm->body) free(loadm->body);
	ma=loadm->first;
	while(ma)
	{
		mma=ma->next; 
		if(ma->atx) free(ma->atx);
		free(ma); 
		ma=mma; 
	}
	loadm->header=NULL;
	loadm->body=NULL;
	loadm->first=NULL;
	loadm->head_len=0;
	loadm->body_len=0;
}

void load_mail(void)
{
	long	fhl;
	int		fh;
	char	bpath[256], npath[256], *c;
	
	odial[ABSENDER].ob_spec.tedinfo->te_ptext="";
	odial[BETREFF].ob_spec.tedinfo->te_ptext="";
	odial[ANHANG].ob_flags |= HIDETREE;
	odial[ANZANHANG].ob_flags |= HIDETREE;
	odial[PUT_ADR].ob_flags |= HIDETREE;
	odial[SWAP_IGN_CRLF].ob_flags |= HIDETREE;

	lloff=0;
	free_loaded_mail();

	/* Falls jetzt keine Nachricht mehr geladen wird (leere Liste)
		 Anhang-Fenster schonmal leer setzen */
	if(anh_win.open) anhang_win();

	if(fld==NULL) return;
	if((ios.list_sel >= fld_c)||(ios.list_sel < 0)) return;
	if(fld[ios.list_sel].ftype==FLD_BAK) return;

	odial[ABSENDER].ob_spec.tedinfo->te_ptext=abs_buf;
	strcpy(abs_buf, fld[ios.list_sel].from);
	odial[BETREFF].ob_spec.tedinfo->te_ptext=btr_buf;
	strcpy(btr_buf, fld[ios.list_sel].subj);

	strcpy(bpath, db_path);
	if(db_mode && (fld[ios.list_sel].ftype != FLD_SND))	/* Datenbank-Modus */
	{
		strcat(bpath, "\\DBASE.DAT");
		fhl=Fopen(bpath, FO_READ);
		if(fhl < 0)
		{
			gemdos_alert(gettext(NOOPEN), fhl);
			return;
		}	
		fh=(int)fhl;
		llen=fld[ios.list_sel].fspec.finfo.size-sizeof(INDEXER);
		Fseek(fld[ios.list_sel].fspec.finfo.offset+sizeof(INDEXER), fh, 0);
	}
	else	/* Single-File-Modus */
	{
		switch(ios.list)
		{
			case 0:
				strcat(bpath, "\\PM\\");
			break;
			case 1:
				strcat(bpath, "\\OM\\");
				strcat(bpath, act_fold);
				strcat(bpath, "\\");
			break;
			case 2:
				strcat(bpath, "\\ORD\\");
				strcat(bpath, act_fold);
				strcat(bpath, "\\");
			break;
			case 3:
				strcat(bpath, "\\DEL\\");
			break;
		}
	
		strcat(bpath, fld[ios.list_sel].fspec.fname);
		fhl=Fopen(bpath, FO_READ);
		if(fhl < 0)
		{
			gemdos_alert(gettext(NOOPEN), fhl);
			return;
		}	
		fh=(int)fhl;
		llen=Fseek(0, fh, 2);
		Fseek(0, fh, 0);
	}
	loaded=malloc(llen+2);
	if(loaded==NULL) 
	{
		Fclose(fh);
		loaded=gettext(NO_MAILMEM);
		llen=strlen(loaded);
		return;
	}
	graf_mouse(BUSYBEE, NULL);
	fhl=Fread(fh, llen, loaded);
	graf_mouse(ARROW, NULL);
	Fclose(fh);
	if(fhl < 0)
	{
		gemdos_alert(gettext(READERR), fhl);
		free(loaded); loaded=NULL; llen=0;
		return;
	}
	loaded[llen]=loaded[llen+1]=0;
	if(llen)
	{
		fhl=llen-1;
		while(fhl)
		{
			if((uchar)(loaded[fhl]) < 32)
			{
				if((loaded[fhl]!=9)&&(loaded[fhl]!=10)&&(loaded[fhl]!=13))
					loaded[fhl]=32;
			}
			--fhl;
		}
	}
	graf_mouse(BUSYBEE, NULL);
	if(split_loaded(loaded, llen, &loadm, 1)==0)
	{
		graf_mouse(ARROW, NULL);
		free(loaded);
		loaded=gettext(NO_MAILMEM);
		llen=strlen(loaded);
		return;
	}
	graf_mouse(ARROW, NULL);

	free(loaded);

	loaded=loadm.body;
	llen=loadm.body_len;
	if(loadm.first)
	{
		odial[ANHANG].ob_flags&=(~HIDETREE);
		if(count_atx(loadm.first) > 1)
		{
			odial[ANZANHANG].ob_flags&=(~HIDETREE);
			itoa(count_atx(loadm.first), odial[ANZANHANG].ob_spec.tedinfo->te_ptext, 10);
		}
	}
	if(loadm.body==NULL)
	{
		loaded=gettext(NO_MAILBODY);
		llen=strlen(loaded);
	}
	if(anh_win.open) anhang_win();
	odial[SWAP_IGN_CRLF].ob_flags&=(~HIDETREE);
		
	if(fld[ios.list_sel].ftype==FLD_NEW)
	{/* éndern in RED */
		fld[ios.list_sel].ftype=FLD_RED;
		if(fld_bak) fld_bak[fld[ios.list_sel].root_index].ftype=FLD_RED;
		if(db_mode)
		{
			Idx_settype(fld[ios.list_sel].idx, FLD_RED);
		}
		else
		{
			strcpy(npath, bpath);
			c=&(npath[strlen(npath)-3]);	/* wg. "NEW"-suffix */
			strcpy(c, "RED");
			Frename(0, bpath, npath);
			c=fld[ios.list_sel].fspec.fname;
			c=&(c[strlen(c)-3]);
			strcpy(c, "RED");
			if(fld_bak)
				strcpy(fld_bak[fld[ios.list_sel].root_index].fspec.fname, fld[ios.list_sel].fspec.fname);
		}
	}
	
	/* Betreff anpassen */
	if((c=get_head_field("Subject:"))!=NULL)
	{
		strncpy(btr_buf, c, 255); btr_buf[255]=0;
		if(!strcmp(fld[ios.list_sel].subj, NO_INF_STR))
		{ 
			strncpy(fld[ios.list_sel].subj, c, 64); fld[ios.list_sel].subj[64]=0;
			while(strlen(fld[ios.list_sel].subj) < 64) 
				strcat(fld[ios.list_sel].subj, " ");
		}
	}
	/* Absender oder EmpfÑnger */
	if((fld[ios.list_sel].ftype==FLD_SND)||(fld[ios.list_sel].ftype==FLD_SNT))
		c=get_head_field("To:");
	else
	{
		c=get_head_field("From:");
		odial[PUT_ADR].ob_flags&=(~HIDETREE);
	}
	if(c!=NULL)
	{
		strncpy(abs_buf,c, 255); abs_buf[255]=0;
		if(!strcmp(fld[ios.list_sel].from, NO_INF_STR))
		{ 
			strncpy(fld[ios.list_sel].from, c, 64); fld[ios.list_sel].from[64]=0;
			while(strlen(fld[ios.list_sel].from) < 64) 
				strcat(fld[ios.list_sel].from, " ");
		}
	}
}

int load_mail_to(LOADED_MAIL *loads)
{/* ret: 1=Ok, 0=Error */
	LOADED_MAIL	loadm;
	long	fhl, llen;
	int		fh;
	char	bpath[256], *loaded;
	
	if(fld==NULL) return(0);
	if((ios.list_sel >= fld_c)||(ios.list_sel < 0)) return(0);
	if(fld[ios.list_sel].ftype==FLD_BAK) return(0);

	strcpy(bpath, db_path);

	switch(ios.list)
	{
		case 0:
			strcat(bpath, "\\PM\\");
		break;
		case 1:
			strcat(bpath, "\\OM\\");
			strcat(bpath, act_fold);
			strcat(bpath, "\\");
		break;
		case 2:
			strcat(bpath, "\\ORD\\");
			strcat(bpath, act_fold);
			strcat(bpath, "\\");
		break;
		case 3:
			strcat(bpath, "\\DEL\\");
		break;
	}

	strcat(bpath, fld[ios.list_sel].fspec.fname);
	fhl=Fopen(bpath, FO_READ);
	if(fhl < 0)
	{
		gemdos_alert(gettext(NOOPEN), fhl);
		return(0);
	}	
	fh=(int)fhl;
	llen=Fseek(0, fh, 2);
	Fseek(0, fh, 0);
	loaded=malloc(llen+2);
	if(loaded==NULL) {form_alert(1, gettext(NOMEM)); Fclose(fh); return(0);}
	fhl=Fread(fh, llen, loaded);
	Fclose(fh);
	if(fhl < 0)
	{
		gemdos_alert(gettext(READERR), fhl);
		free(loaded); 
		return(0);
	}
	loaded[llen]=loaded[llen+1]=0;
	if(split_loaded(loaded, llen, &loadm, 0)==0)
	{
		form_alert(1, gettext(NOMEM));
		free(loaded);
		return(0);
	}

	free(loaded);

	*loads=loadm;
	return(1);
}
