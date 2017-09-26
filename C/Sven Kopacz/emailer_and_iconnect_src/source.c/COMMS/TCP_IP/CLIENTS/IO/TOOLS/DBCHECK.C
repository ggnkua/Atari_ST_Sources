#include <stdio.h>
#include <string.h>
#include <tos.h>
#include <stdlib.h>

typedef struct
{
	long		magic1;		/* 'IdXm' Zum auffinden des Index */
	long		magic2;		/* 'hGwM' bei einer Reparatur */
	
	ftype		:4 ;	/* File types
										FLD_SND	0 nicht benutzt, wird ignoriert
										FLD_SNT	1
										FLD_NEW	2
										FLD_RED	3
									*/
	flags		:12	;	/* s. flag-defs */

	char		from[66];
	char		to[66];
	char		subj[66];
	unsigned int		ftime;			/* Uhrzeit (GEMDOS-Format) */ 
	unsigned int		fdate;			/* Datum (GEMDOS-Format) */

	long		list_id;	/* Ordner-ID oder Gruppen-ID (=Nummern-Name des Ordners im Dateisystem) oder nix */
	
	char		msg_id[66];
	char		in_reply_to[66];
	char		references[66];
	
	long		db_offset;	/* Offset in der Datenbank */
	long		db_size;		/* L„nge in Bytes */
}INDEXER;
/* flag-defs: */
#define FF_ATX	1		/* Enth„lt Anhang */
#define FF_ANS	2		/* Wurde beantwortet */

#define FF_NON  0		/* Wie ftype=0, wird ignoriert */
#define FF_PM		4		/* Ist PM */
#define FF_OM		8		/* Ist OM */
#define FF_ORD	16	/* Ist geordnet */
#define FF_DEL	32	/* Ist gel”scht */
#define FF_LOCATION (FF_PM|FF_OM|FF_ORD|FF_DEL)	/* Maske */

#define FF_ISOM 64	/* Ist OM (kann auch eingeordnet sein etc.) */

/* Console output */
#define Con(a) Cconws(a)
/* Carriage Return+New Line on Console */
#define crlf Con("\r\n")

void LCon(long l)
{
	char num[33];
	ltoa(l, num, 10);
	Con(num);
}

void BCon(long l)
{
	char pf[2];
	char *m=&(pf[0]);
	pf[1]=0;
	pf[0]=0;
		
	LCon(l); Con(" Bytes (");
	if(l > 1024)
	{	l/=1024; *m='K';}
	if(l > 1024)
	{ l/=1024; *m='M';}
	LCon(l);
	Con(" "); Con(pf); Con("Bytes)");
}

void main(void)
{
	char entry[260], path[256], idx_path[256], dat_path[256];
	long err, flen, entries, ix, siz;
	long dblen, ms1, ms2, ms3, ms4;
	long largest, smallest, empty;
	long del_count, del_size;
	long pm_count, pm_size;
	long om_count, om_size;
	long fl_count, fl_size;
	long deldel_count, deldel_size;
	long atx_count, atx_size, keep;
	int	fhl;
	INDEXER *idx, idx1;

	Con("ASH Emailer DBCHECK V 1.0");crlf;
	Con("Database check and statistics.");crlf;
	Con("Sven Kopacz, 10/99");crlf;
	crlf;
	Con("Enter file path for DATABASE folder");crlf;
	Con("(Example: C:\\APPS\\EMAILER\\DATABASE\\)");crlf;
	Con(">");
	entry[0]=255;
	do
	{
		Cconrs((LINE*)entry);
	}while(!entry[1]);
	crlf;
	entry[entry[1]+2]=0;
	strcpy(entry, &entry[2]);
	
	Con("Opening IDX"); crlf;
	if(entry[strlen(entry)-1]!='\\') strcat(entry, "\\");
	strcpy(dat_path, entry);
	strcat(dat_path, "DBASE.DAT");
	strcpy(path, entry);
	strcat(entry, "DBASE.IDX");
	strcpy(idx_path, entry);
	err=Fopen(entry, FO_READ);
	if(err < 0)
	{
		Con("Error opening IDX: "); LCon(err); crlf;
		return;
	}
	fhl=(int)err;
	flen=Fseek(0, fhl, 2);
	Fseek(0, fhl, 0);
	idx=malloc(flen);
	if(idx==NULL)
	{
		Con("Error: Not enough memory to load IDX."); crlf;
		Fclose(fhl);
		return;
	}

	Con("Reading IDX...");
	Fread(fhl, flen, idx);
	Fclose(fhl);
	Con("ok.");crlf;
	
	/* Get the stats */
	entries=flen/sizeof(INDEXER);
	ix=0;	
	dblen=ms1=ms2=ms3=ms4=0;
	largest=smallest=-1;
	del_count=del_size=0;
	deldel_count=deldel_size=0;
	pm_count=pm_size=0;
	om_count=om_size=0;
	fl_count=fl_size=0;
	atx_count=atx_size=0;
	empty=keep=0;
	Con("Mails in Database: "); LCon(entries); crlf;
	Con("Counting stats...");
	while(ix < entries)
	{
		dblen+=siz=idx[ix].db_size-sizeof(INDEXER);

		if((idx[ix].ftype != FF_NON) && ((idx[ix].flags & FF_LOCATION) != FF_NON))
			++keep;


		if(idx[ix].flags & FF_ATX)
		{
			++atx_count;
			atx_size+=siz;
		}
		if(idx[ix].flags & FF_DEL)
		{	
			++del_count;
			del_size+=siz;
		}
		else if(idx[ix].flags & FF_PM)
		{	
			++pm_count;
			pm_size+=siz;
		}
		else if(idx[ix].flags & FF_OM)
		{	
			++om_count;
			om_size+=siz;
		}
		else if(idx[ix].flags & FF_ORD)
		{	
			++fl_count;
			fl_size+=siz;
		}
		else
		{
			++deldel_count;
			deldel_size+=siz;
		}
		++ix;
		if(largest < siz) largest=siz;
		if((smallest==-1) || (siz < smallest)) smallest=siz;
		if(siz== 0) ++empty;
		else if(siz < 1024) ++ms1;
		else if(siz < 1024*10) ++ms2;
		else if(siz < 1024*100) ++ms3;
		else if(siz < 1024*1024) ++ms4;
	}
	free(idx);
	Con("ok.");crlf;
	Con("Result:");crlf;
	Con("Keep: "); LCon(keep); crlf;
	Con("Empty mails (0 Bytes): "); LCon(empty); crlf;
	Con("Mails smaller 1 K    : "); LCon(ms1); crlf;
	Con("Mails smaller 10 K   : "); LCon(ms2); crlf;
	Con("Mails smaller 100 K  : "); LCon(ms3); crlf;
	Con("Mails smaller 1 Meg  : "); LCon(ms4); crlf;
	Con("Mails larger 1 Meg   : "); LCon(entries-ms1-ms2-ms3-ms4); crlf;
	crlf;
	Con("Smallest mail : "); BCon(smallest); crlf;
	Con("Largest mail  : "); BCon(largest); crlf;
	Con("Average mail  : "); BCon(dblen/entries); crlf;
	crlf;
	Con("Distribution:"); crlf;
	Con("Deleted mails  : "); LCon(del_count); crlf;
	Con("Occupied space : "); BCon(del_size); crlf;
	Con("Ignored mails  : "); LCon(deldel_count); crlf;
	Con("Occupied space : "); BCon(deldel_size); crlf;
	Con("(Space will be freed when cleaning up the database");crlf;
	Con(" and choosing \"Physically delete all deleted mails\".)");crlf;
	Con("Private mails  : "); LCon(pm_count); crlf;
	Con("Occupied space : "); BCon(pm_size); crlf;
	Con("Mails in groups: "); LCon(om_count); crlf;
	Con("Occupied space : "); BCon(om_size); crlf;
	Con("Filed mails    : "); LCon(fl_count); crlf;
	Con("Occupied space : "); BCon(fl_size); crlf;
	crlf;
	Con("Mails containing attachments : "); LCon(atx_count); crlf;
	Con("Occupied space               : "); BCon(atx_size); crlf;
	crlf;
	crlf;
	Con("Mail data in DBASE.DAT   : "); BCon(dblen); crlf;
	Con("Total size for DBASE.DAT : "); BCon(dblen+flen); crlf;
	Con("Checking real size...");
	strcat(path, "DBASE.DAT");
	err=Fopen(path, FO_READ);
	if(err < 0)
	{
		crlf; Con("Error opening DAT: "); LCon(err); crlf;
		return;
	}
	fhl=(int)err;
	flen=Fseek(0, fhl, 2);
	Fseek(0, fhl, 0);
	Fclose(fhl);
	Con("ok.");crlf;
	Con("Real size for DBASE.DAT  : "); BCon(flen); crlf;
	crlf;
	crlf;

/* Additional debug option */
_add_dbug:
	Con("Examine offset (q to quit)>");
	do
	{
		Cconrs((LINE*)entry);
	}while(!entry[1]);
	crlf;
	entry[entry[1]+2]=0;
	strcpy(entry, &entry[2]);
	if(entry[0]=='q') return;
	ix=atol(entry);

	Con("Reading Index  "); LCon(ix); crlf;
	err=Fopen(idx_path, FO_READ);
	if(err < 0)
	{
		Con("Error opening IDX: "); LCon(err); crlf;
		return;
	}
	fhl=(int)err;
	Fseek(ix*sizeof(INDEXER), fhl, 0);
	Con("Reading IDX...");
	Fread(fhl, sizeof(INDEXER), &idx1);
	Fclose(fhl);
	Con("ok.");crlf;
	Con("IDX-idx-content:");crlf;
	Con("magic1:");LCon(idx1.magic1);Con(" magic2:");LCon(idx1.magic2);crlf;
	Con("ftype:");LCon(idx1.ftype);Con(" flags:");LCon(idx1.flags);crlf;
	Con("db_offset:");LCon(idx1.db_offset);Con(" db_size:");LCon(idx1.db_size);crlf;
	crlf;

	Con("Reading Data  "); LCon(ix); crlf;
	err=Fopen(dat_path, FO_READ);
	if(err < 0)
	{
		Con("Error opening DAT: "); LCon(err); crlf;
		return;
	}
	fhl=(int)err;
	Fseek(idx1.db_offset, fhl, 0);
	Con("Reading IDX...");
	Fread(fhl, sizeof(INDEXER), &idx1);
	Fclose(fhl);
	Con("ok.");crlf;
	Con("DAT-idx-content:");crlf;
	Con("magic1:");LCon(idx1.magic1);Con(" magic2:");LCon(idx1.magic2);crlf;
	Con("ftype:");LCon(idx1.ftype);Con(" flags:");LCon(idx1.flags);crlf;
	Con("db_offset:");LCon(idx1.db_offset);Con(" db_size:");LCon(idx1.db_size);crlf;
	crlf;
	crlf;
	goto _add_dbug;		
}
