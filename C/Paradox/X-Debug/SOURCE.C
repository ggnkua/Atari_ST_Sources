/* source file handling for Mon */

#define	PANIC	0				// panic-level debug

#include "mon.h"
#include "window.h"
#include "errno.h"
#include "fcntl.h"

#include "regs.h"

txt(TX_NOSOURCE);
txt(TX_CHOOSEFILE);
txt(TX_MODIFIED);
txt(TX_NOTFOUND);
txt(TX_BADSYM);
txt(TX_FNNOTFOUND);
txt(TX_READINGDEBUG);

void db_close(word);			/* forward reference */
void zero_source_debug(void);

/* how breaks are displayed in source mode */
#define SOURCE_BRK_CHAR	''

/* files are denoted by a magic byte number */
/* #define MAXFILES	20 obsolete: replaced by*/
long maxfiles = 20;
#define	MAXFILENAME	99

/* a global variable! */
word tabsize=8;			/* used in ordinary ASCII */
word sourcetabsize=4;	/* used on Smart windows */
char sourcepath[MAXFILENAME+1];

void strcattab(char *dest, char *source, bool extra, word tab)
{
short i;
char c;

	while (*dest++)
		;
	dest--;
	i=0;
	if (extra)
		c='\t';
	else
		c=*source++;
	while (c)
		{
		if (c=='\t')
			{
			short extra;
			extra=tab-(i % tab);
			while (extra--)
				{
				*dest++=' ';
				i++;
				}
			}
		else
			{
			*dest++=c;
			i++;
			}
		c=*source++;
		}
	*dest=0;
}

word file_length(FILE *fp, long*len)
{
	if ( fseek(fp,0L,2)==-1L )
		return 1;
	*len=ftell(fp);
	rewind(fp);
	return 0;
}

/* if a file exists, returns its length
	if it doesn't exist, returns -1L */
long check_flen(char *name)
{
int handle;
long len;

	handle=open(name,O_RDONLY,0);
	if (handle==-1)
		return -1L;
	len=filelength(handle);
	close(handle);
	return len;			/* -1 means error, usefully */
}

#if !DEMO
/* reads lines and converts to null-terminated ones */
/* nulls in the file get taken to be EOLs */
uword read_lines(FILE *fp, char *p)
{
uword sofar;
word len;

	sofar=0;
	for (;;)
		{
		if (fgets(p,0x1000,fp)==NULL)
			return sofar;
		len=strlen(p);
		if (len && (*(p+len-1)=='\n') )
			*(p+ --len)=0;
		p+=len+1;
		sofar++;
		}
}
#endif

typedef struct {
	uword linesinfile;
	char *filestart;
	bool small;				/* TRUE if a one-at-a-time source file */
	bool new;				/* TRUE if newer than loaded prog */
	char name[MAXFILENAME+1];	/* may be fixed up to full pathname */
	char **lineoffset;
	} fileinfo;

fileinfo **flist;

#if !DEMO

/* allocate the above, if possible */
/* returns index or 0 if failed */
/* if allocmem!=0 we load into that */
word open_file(char *name, char *allocmem)
{
uword i;
word last;
FILE *fp;
long flen;
word err;
char **linelist;
char *f;

	if (strlen(name)>MAXFILENAME)
		return 0;

	last=0;
	for (i=1; i<maxfiles; i++)
		{
		if ( (last==0) && (flist[i]==NULL) )
			last=i;					/* remember empty entry */
		if ( flist[i] && (strcmp(flist[i]->name,name)==0) )
			{ /* already open */
			if (flist[i]->small==FALSE)
				return (word)i;
			else if (allocmem)
				/* need to reload it - mem already got */
				last=i;
			}
		}
	if (last==0)
		return 0;					/* no spaces left */

	if (flist[last]==NULL)
		if ( (flist[last]=getzmem(sizeof(fileinfo)))==NULL )
			return 0;					/* if no memory */

	if ( (fp=fopen(name,"r"))==NULL)	/* TEXT MODE */
		{
		freemem(flist[last]);
		flist[last]=NULL;
		return 0;					/* cannot open (TEXT MODE) */
		}
	
	strcpy(flist[last]->name,name);	/* remember name */

	if (err=file_length(fp,&flen))
		goto badclose;

	if (allocmem)
		{
		word j;
		flist[last]->filestart=allocmem;
		flist[last]->small=TRUE;
		flen++;
		/* force other files sharing this buffer to be closed */
		for (j=1; j<maxfiles; j++)
			if (flist[j] && (flist[j]->filestart==allocmem) && (last!=j) )
				db_close(j);
		}
	else
		{
		if ( (flist[last]->filestart=getzmem(++flen))==NULL)
			goto badclose;
		flist[last]->small=FALSE;
		}

	if ( (linelist=flist[last]->lineoffset)==NULL )
		{
		i=flist[last]->linesinfile=read_lines(fp,flist[last]->filestart);

		if ( (linelist=getzmem((long)i*sizeof(long)))==NULL )
			goto badclose;

		flist[last]->lineoffset=linelist;
		}
	else
		{
		if ( (i=read_lines(fp,flist[last]->filestart))!=flist[last]->linesinfile )
			goto badclose;				/* if no of lines has changed! */
		}

	/* read all the lines now */
	f=flist[last]->filestart;

	while (i--)				/* i is OK now! (0.61+) */
		{
		*linelist++=f;
		while (*f++)
			;
		}

	flist[last]->new = (filetime(fp)>debugtime) ? TRUE : FALSE;

	fclose(fp);
	return last;

badclose:
	fclose(fp);
	if (flist[last]->lineoffset)
		freemem(flist[last]->lineoffset);
	if ( (flist[last]->filestart) && (flist[last]->small==FALSE) )
		freemem(flist[last]->filestart);
	freemem(flist[last]);
	flist[last]=NULL;
	return 0;	
}

#else

// the demo source file is <line1><13.10><line2<13.10>...0
// we copy to create <line1>0<line2>0<line3>0 etc

uword demo_read_lines(char *dest)
{
char *source;
uword sofar = 0;
char *eol;
	
	source = (char*) get_demo_long( 0 );
	for (;;)
		{
		sofar++;
		eol = strchr(source, 13);
		if (eol)
			{
			size_t len = eol - source;
			memcpy(dest, source, len);
			dest += len;
			*dest++ = 0;
			source = eol + 2;				// skip LF
			}
		else
			{
			strcpy(dest, source);			// no CR/LF, must be last line so copy
			break;
			}
		}
	return sofar;
}

// demo version, copied in similar manner but from RAM

word open_file(char *name, char *allocmem)
{
word last;
uword i;
long flen;
char **linelist;
char *f;

	last=0;
	for (i=1; i<maxfiles; i++)
		{
		if ( (last==0) && (flist[i]==NULL) )
			last=i;					/* remember empty entry */
		if ( flist[i] && (strcmp(flist[i]->name,name)==0) )
			{ /* already open */
			if (flist[i]->small==FALSE)
				return (word)i;
			else if (allocmem)
				/* need to reload it - mem already got */
				last=i;
			}
		}
	if (last==0)
		return 0;					/* no spaces left */

	if (flist[last]==NULL)
		if ( (flist[last]=getzmem(sizeof(fileinfo)))==NULL )
			return 0;					/* if no memory */

	strcpy(flist[last]->name,name);	/* remember name */

	flen = get_demo_long( 1 );

	if (allocmem)
		{
		word j;
		flist[last]->filestart=allocmem;
		flist[last]->small=TRUE;
		flen++;
		/* force other files sharing this buffer to be closed */
		for (j=1; j<maxfiles; j++)
			if (flist[j] && (flist[j]->filestart==allocmem) && (last!=j) )
				db_close(j);
		}
	else
		{
		if ( (flist[last]->filestart=getzmem(++flen))==NULL)
			goto badclose;
		flist[last]->small=FALSE;
		}

	if ( (linelist=flist[last]->lineoffset)==NULL )
		{
		i=flist[last]->linesinfile=demo_read_lines(flist[last]->filestart);

		if ( (linelist=getzmem((long)i*sizeof(long)))==NULL )
			goto badclose;

		flist[last]->lineoffset=linelist;
		}
	else
		{
		if ( (i=demo_read_lines(flist[last]->filestart))!=flist[last]->linesinfile )
			goto badclose;				/* if no of lines has changed! */
		}

	/* read all the lines now */
	f=flist[last]->filestart;

	while (i--)				/* i is OK now! (0.61+) */
		{
		*linelist++=f;
		while (*f++)
			;
		}

	flist[last]->new = FALSE;

	return last;

badclose:
	if (flist[last]->lineoffset)
		freemem(flist[last]->lineoffset);
	if ( (flist[last]->filestart) && (flist[last]->small==FALSE) )
		freemem(flist[last]->filestart);
	freemem(flist[last]);
	flist[last]=NULL;
	return 0;	
}

#endif

/* frees memory etc. Any windows using this MUST be closed beforehand */
void close_file(word i)
{

	if (flist[i]==NULL)
		return;
	if (flist[i]->lineoffset)
		{
		freemem(flist[i]->lineoffset);
		flist[i]->lineoffset=NULL;
		}
	if ( (flist[i]->filestart) && (flist[i]->small==FALSE) )
		{
		freemem(flist[i]->filestart);
		flist[i]->filestart=NULL;
		}

	db_close(i);

	freemem(flist[i]);
	flist[i]=NULL;
}

/********* ASCII Window Handler *********/

/* wlong contains the line number (starting at 1),
	magic contains the file number */

void ascii_line(struct ws *w, char *p, uword line)
{
word x; char c;
char *b;
	x=0;
	sprintf(linebuf,"%3d ",line);
	b=linebuf+4;
	while (*b)
		b++;
	/* copy chars expanding tabs */
	do
		{
		x++;
		if ( (c=*b++=*p++)=='\t' )
			{
			word space;
			*b--;
			x--;
			space=tabsize-(x % tabsize);
			while (space--)
				{
				*b++=' ';
				x++;
				}
			}
		}
	while ( (c) && (x<200) );
}

bool refill_ascii(struct ws *w)
{
word i;
fileinfo *f;
char **line;
uword lnum;

	f=flist[(word)w->magic];
	lnum=(uword)w->wlong;
	if (lnum==0)
		w->wlong=(long)(lnum=w->wlong=1);				/* just in case */
	if (lnum>f->linesinfile)
		w->wlong=(long)(lnum=f->linesinfile);

	line=f->lineoffset;
	line+=(lnum-1);					/* who needs arrays! */
	
	for (i=w->h-2; i; i--)
		{
		if (lnum>f->linesinfile)
			break;
		ascii_line(w,*line++,lnum++);
		wprint_line(w,linebuf,TRUE);
		}
	return TRUE;
}

void key_ascii(word key)
{
fileinfo *f;
uword lines,numlines;
char **where;
uword i;

	auto_numeric(&key);

	if (do_controlkey(key)==TRUE)
		return;

	f=flist[(word)frontwindow->magic];
	i=(uword)frontwindow->wlong;
	if (i==0)
		++frontwindow->wlong;
	else
		i--;
	where=f->lineoffset;
	lines=frontwindow->h-2;
	numlines=f->linesinfile;

	if ( (key&0xFF)==' ' )
		key=KEY_PAGEDOWN;

	switch (key)
		{
		case KEY_DOWN:
			{
			if ( (i+lines)>=numlines )
				break;
			frontwindow->wlong++;
			scroll_window(frontwindow,TRUE);
			ascii_line(frontwindow,*(where+i+lines),(uword)(i+lines+1));
			wprint_str(linebuf);
			break;
			}
		case KEY_UP:
			{
			if (i==0)
				break;
			i--;
			frontwindow->wlong--;
			scroll_window(frontwindow,FALSE);
			ascii_line(frontwindow,*(where+i),(uword)(i+1));
			wprint_str(linebuf);
			break;
			}
		case KEY_PAGEUP:
			{
			if (i==0)
				break;
			if (i<lines)
				frontwindow->wlong=1;
			else
				frontwindow->wlong-=lines;
			window_cls(frontwindow);
			refill_ascii(frontwindow);
			update_contents(frontwindow);
			break;
			}
		case KEY_PAGEDOWN:
			{
			if ( (i+lines)>=numlines )
				break;
			frontwindow->wlong+=lines;
			window_cls(frontwindow);
			refill_ascii(frontwindow);
			update_contents(frontwindow);
			break;
			}
		}
}

/****************** Lattice C 5 LINE Debug ********************/

struct linfo {
	long line;
	long pc;
	};

struct dbfile {
	char name[MAXFILENAME+1];	/* the raw name, normally short */
	word opened;				/* 0=not */
	long startpc,endpc;
	struct linfo *linelist;
	long linecount;
	char *fullname;				/* ptr to actual file (malloced block) */
};

/* if the ptr is non-null then it is valid */
struct dbfile **dblist;		/* a dynamic array */

/* called to create a structure for a file */
/* returns ptr to blast area, or NULL if cannot */
void *init_dbfile(char *name, long namelen, long start, long end, long linecount, word *dbindex, char *pathname)
{
short i;
struct linfo *new;
char fullname[MAXFILENAME+1];
char *p;

	if (namelen>MAXFILENAME)
		return 0;

	for (i=0; i<maxfiles; i++)
		if (dblist[i]==NULL)
			break;

	if (i==maxfiles)
		return NULL;			/* no empty entry */

	if ( (dblist[i]=getmem(sizeof(struct dbfile)))==NULL )
		return NULL;

	if ( (new=getzmem(sizeof(struct linfo)*linecount))==NULL)
		{
		freemem(dblist[i]);
		dblist[i]=NULL;
		return NULL;
		}
		

	/* alloced linelist so init structure */
	dblist[i]->linelist=new;

	stccpy(dblist[i]->name,name,namelen);	/* ensure null is added */
	dblist[i]->startpc=start;
	dblist[i]->endpc=end;
	dblist[i]->linecount=linecount;
	*dbindex=i;
	dblist[i]->fullname=NULL;
	dblist[i]->opened=0;

	/* find the exact location of the source file now */
	#if !DEMO

	if ( (pathname==NULL) || access(pathname,0) )
		{
		/* no path given (or fullpath invalid) - lets figure it out */
		p=fullname;
		if (!find_general(name,fullname,sourcepath))
			{
			/* try the progpath */
			char progpath[MAXFILENAME+1];
			if ( (name_to_path(progpath,progname)==FALSE) ||
				(!find_general(name,fullname,progpath)) )
				p=name;										/* if still cannot find */
			}
		}
	else
		p=pathname;
		
	#else
	p = pathname;					// always there
	#endif

	if (dblist[i]->fullname=getmem(strlen(p)+1))
		strcpy(dblist[i]->fullname,p);

	return (void*)new;	
}

/* when an ASCII file goes away, mark as closed in dblist */
void db_close(word fnum)
{
word i;
	for (i=0; i<maxfiles; i++)
		if (dblist[i]->opened==fnum)
			{
			freemem(flist[dblist[i]->opened]->lineoffset);		/* if ASCII gone, ptr to ASCII for each line can be safely junked */
			flist[dblist[i]->opened]->lineoffset=NULL;
			dblist[i]->opened=0;
			}
}

static bool source_loaded;

void clear_db(short i)
{
	if (dblist[i])
		{
		if (dblist[i]->linelist)
			freemem(dblist[i]->linelist);
		if (dblist[i]->fullname)
			freemem(dblist[i]->fullname);
		freemem(dblist[i]);
		dblist[i]=NULL;
		}
}

txt(TX_ALERTERROR);
txt(TX_CANNOTOPENSOURCE);
txt(TX_CANNOTOPENSOURCES);

bool onesource=TRUE;		/* TRUE for small, FALSE for large */
char *onesourcebuf;
long static_counter;

#if !DEMO

/* called before executing a program to load its source files */
void prepare_source()
{
short i;
char badname[MAXFILENAME+1];
ubyte badfiles;

	badfiles=0;
	source_loaded=FALSE;

	if (onesource)
		{ /* lets find all the files and get the largest */
		long largest; long this;
		largest=0L;
		for (i=0; i<maxfiles; i++)
			{
			if (dblist[i])
				{
				this=check_flen(dblist[i]->fullname);
				if (this==-1L)
					{
					if (badfiles++==0)
						strcpy(badname,dblist[i]->fullname);
					clear_db(i);
					}
				else
					{
					largest=max(largest,this);
					}
				}
			}
		if ( (largest) && (onesourcebuf=getanymem(largest)) )
			{
			source_loaded=TRUE;
			/* loading files is left til later */
			}
		#if PANIC
		sprintf(linebuf, "Largest=%ld, loaded=%d\n", largest, (int)source_loaded);
		safe_print(linebuf);
		#endif
		}
	else for (i=0; i<maxfiles; i++)
		{ /* loads all source files before prog */
		if (dblist[i])
			{
			if (dblist[i]->opened=open_file(dblist[i]->fullname,NULL))
				source_loaded=TRUE;
			else
				{
				if (badfiles++==0)
					strcpy(badname,dblist[i]->fullname);
				clear_db(i);
				}
			}
		}
	
	if (badfiles)
		simple_alert(TX_ALERTERROR,
			badfiles==1 ? TX_CANNOTOPENSOURCE : TX_CANNOTOPENSOURCES,
			badname);
}
#else

void prepare_source()
{
	source_loaded = FALSE;
	if (onesourcebuf=getanymem( get_demo_long( 1 ) ) )		// only ever 1 file
		{
		source_loaded=TRUE;
		/* loading files is left til later */
		}
}

#endif

/* called to undo the above */
void clear_dbfile()
{
short i;
struct ws *wptr;
word front;
word x,y,w,h;

	/* get rid of the windows first */
	front=frontnum;
	for (i=0; i<MAXWINDOW; i++)
		{
		wptr=wlist[i];
		if ( wptr->open && (wptr->type==WTYPE_SMART) )
			{
			x=wptr->x; y=wptr->y; w=wptr->w; h=wptr->h;
			close_window(i,TRUE);
			open_window(i,x,y,w,h,NULL,WTYPE_DISS);
			}
		}
	/* restore previous front window */
	if (wlist[front]->open)
		front_window(wlist[front]);

	/* then generally clean-up */
	for (i=0; i<maxfiles; i++)
		{
		if (dblist[i])
			{
			if (dblist[i]->opened)
				close_file(dblist[i]->opened);
			clear_db(i);
			}
		}
	source_loaded=FALSE;
	if (onesourcebuf)
		{
		freemem(onesourcebuf);
		onesourcebuf=NULL;
		}
	zero_source_debug();
}

/* see if we can find a particular PC in the source files */
/* if not exact, returns the line immediately before it */
/* IMPORTANT: file may not be open */
bool find_linenumber(ulong pc, bool *exact, struct dbfile**db, uword *lnum, long *lindex)
{
short i;
struct linfo *llist;
long count;

	if (source_loaded==FALSE)
		return FALSE;
	for (i=0; i<maxfiles; i++)
		{
		if (dblist[i])
			{
			if ( (pc>=dblist[i]->startpc) && (pc<dblist[i]->endpc) )
				{ /* find in line number list */
				llist=dblist[i]->linelist;
				count=dblist[i]->linecount;
				*db=dblist[i];
				while (count--)
					{
					if (pc <= llist->pc)
						{
						if ( !(*exact=(bool)(pc==llist->pc))
								&& (count!=((*db)->linecount)-1) )
								{
								llist--;
								count++;		/* previous line is inexact */
								}
						*lnum=(uword)(llist->line);
						if (lindex)
							*lindex=(dblist[i]->linecount-count-1);
						return TRUE;
						}
					llist++;
					}
				/* must be last line in last proc */
				*exact=FALSE;
				*lnum=(uword)(--llist->line);
				if (lindex)
					*lindex=(dblist[i]->linecount-count-1);
				return TRUE;
				}
			}
		}
	return FALSE;
}

/* add line number/file to string */
char *find_line_txt(ulong where, char *p)
{
struct dbfile *db;
uword lnum;
bool exact;
long junk;

	if (find_linenumber(where,&exact,&db,&lnum,&junk))
		{
		sprintf(p," #%d:%.15s",lnum,db->name);
		while (*p)
			p++;
		if (!exact)
			*p++='+';
		}
	return p;
}

/* returns whether pc matches exact source line */
/* returns 0 if nowhere near source,
	1 if exact on source
	2 if not exact source
*/
char check_source(ulong pc)
{
bool exact;
struct dbfile *db;
uword lnum;

	if (find_linenumber(pc,&exact,&db,&lnum,NULL) )
		return (char) (exact ? 1 : 2);
	else
		return FALSE;
}

/* return the address of the next line, if possible */
word next_source(ulong *pc)
{
bool exact;
struct dbfile *db;
uword lnum;
long lindex;

	if (find_linenumber(*pc,&exact,&db,&lnum,&lindex)==FALSE)
		return ERRM_NOSOURCE;
	if (db->linecount==(lindex-1))
		return ERRM_NOSOURCE;			/* if no more */
	*pc=(db->linelist+lindex+1)->pc;
		return 0;
}

/* this is here cos get_source_addr needs it */

struct smartw {
	struct dbfile *file;
	uword topline;		/* of next source line */
	ulong toppc;
	uword current;
	char mode;			/* the user wants this */
	char tmode;			/* he will get this though */
	struct linfo *linfo;	/* of next source line (for mixed) */
	char **line;			/* (for mixed) */
};

/* given a line number and (optional) filename, get an address */
/* the source window does *not* have to be open */
/* fname=NULL=no filename=ONLY window */
word get_source_addr(ulong line, char *fname, ubyte flen, ulong *result)
{
struct linfo *llist;
short i;
long count;

	if (source_loaded==FALSE)
		return ERRM_NOFINDSOURCE;
	if (fname==NULL)
		{ /* no fname given, so use only open window */
		short it;
		it=-1;
		for (i=0; i<MAXWINDOW; i++)
			{
			if ( (wlist[i]) && (wlist[i]->type==WTYPE_SMART) )
				{
				if (it!=-1)
					return ERRM_NOFINDSOURCE;	/* if >=2 */
				it=i;
				}
			}
		if (it==-1)
			return ERRM_NOFINDSOURCE;
		else
			i=it+1000;			/* as in wlist not dblist */
		}
	else
		{ /* find the filename */
		for (i=0; i<maxfiles; i++)
			{
			if (dblist[i])
				{
				if ( (strlen(dblist[i]->name)==flen) &&
						(strnicmp(fname,dblist[i]->name,flen)==0) )
					break;
				}
			}
		}
	if (i==maxfiles)
		return ERRM_NOFINDSOURCE;
	if (i>=1000)
		{ /* convert from wlist to dblist index */
		short j;
		struct smartw *sm;
		
		i-=1000;
		sm=(struct smartw*)(wlist[i]->magic);
		for (j=0; j<maxfiles; j++)
			{
			if ( (dblist[j]) &&	(sm->file == dblist[j]) )
				break;
			}
		if (j==maxfiles)
			return ERRM_NOFINDSOURCE;
		i=j;
		}
	/* got the file - find line number */
	llist=dblist[i]->linelist;
	count=dblist[i]->linecount;

	if (line==0)
		{
		/* line 0 means the last line */
		*result=llist[count-1].pc;
		return 0;
		}

	while (count--)
		{
		if ( llist->line >=line )
			{
			*result=llist->pc;
			return 0;
			}
		llist++;
		}
	return ERRM_NOFINDSOURCE;
}

#define LOCALS 1
#if LOCALS

/****************** Lattice 5 SRC Debug ********************/
#include "cprinfo.h"
#include "syms.h"

struct src_fn {
	long startpc,endpc,setuppc;
	/* some bitfields for flags */
	int isstatic:1;
	sym *localtable;
	struct src_fn *nextfn;
	char name[1];					/* null termed, follows on */
	};

sym *globaltable;

struct src_file {
	long startpc,endpc;
	struct src_file *nextfile;
	struct src_fn *fnlist;
	sym *statictable;
	long section_offset[4];			/* far, ufar, near, unear */
	char basereg;					/* 0-7 */
	char name[1];
	};

struct src_file *src_filelist,			/* points to linked list of files, NULL means none */
				*src_currentfile;		/* valid during loading only */
struct src_fn	*src_currentfn;			/* ditto */


void zero_source_debug(void)
{
struct src_file *file,*nfile;
struct src_fn *fn,*nfn;

	file=src_filelist;
	while (file)
		{
		/* empty out this file's stuff */
		fn=file->fnlist;
		while (fn)
			{
			if (fn->localtable)
				foreachsym(fn->localtable, clear_debug);
			nfn=fn->nextfn;
			freemem(fn);
			fn=nfn;
			}
		if (file->statictable)
			foreachsym(file->statictable, clear_debug);
		nfile=file->nextfile;
		freemem(file);
		file=nfile;
		}
	if (globaltable)
		{
		foreachsym(globaltable, clear_debug);
		globaltable=NULL;
		}
	src_filelist=NULL;
	src_currentfile=NULL;
	src_currentfn=NULL;
	clear_hash(&static_hash);
}

/* name can be dynamic */
word add_file_src(long start, long end, char *name, byte basereg)
{
struct src_file *new;
	new=getzmem(sizeof(struct src_file)+strlen(name));
	if (new==NULL)
		{
		src_currentfile=NULL;
		return ERRM_NOMEMORY;
		}
	if (src_filelist==NULL)
		src_filelist=new;
	else
		src_currentfile->nextfile=new;
	new->startpc=start;
	new->endpc=end;
	new->basereg=basereg;
	src_currentfile=new;
	src_currentfn=NULL;
	strcpy(new->name,name);
	return 0;
}


/* a variable has the following info:
	type V_REG, V_OFFSET, V_GLOBAL, V_BAD
	size EXPR_xxx
	the v area contains:
		V_REG	byte b 0-15 for reg number
		V_FPREG	byte 0-7
		V_OFFSET	oreg.offset=word offset, oreg.reg=A reg number
		V_FUNCTION	a static function. No other bits set
	the func ptr is used to read its value, parameter=sym*
	V_POINTER gets ORed in if relevent
	V_ARRAY also ORed in
*/

#define	V_REG		1
#define	V_OFFSET	2
#define	V_GLOBAL	3
#define	V_FPREG		4
#define	V_FUNCTION	5
#define	V_BAD		6
#define	V_ARRAY		0x20
#define	V_POINTER	0x40
#define	V_MASK	(~(V_ARRAY|V_POINTER))

#define Z	(*(remember.toadd))

/* name can be dynamic as reallocated */
word add_fn_src(long start, long end, long setup, char *name, bool isstatic)
{
struct src_fn *new;

	if (src_currentfile==NULL)
		return ERRM_NOMEMORY;

	new=getzmem(sizeof(struct src_fn)+strlen(name));
	if (new==NULL)
		{
		src_currentfile=NULL;
		src_currentfn=NULL;
		return ERRM_NOMEMORY;
		}

	if (src_currentfn==NULL)
		src_currentfile->fnlist=new;
	else
		src_currentfn->nextfn=new;
	new->startpc=start;
	new->endpc=end;
	new->setuppc=setup;
	if (isstatic)
		{
		ubyte slen;
		sym *s;
		struct remstruct remember;
		
		new->isstatic=1;
		/* static fn names are added to statictable, so diss & eval can find them */
		slen=strlen(name);
		s=find_sym( &(src_currentfile->statictable), name, slen, &remember, TRUE );
		if (s==NULL)
			{
			if ( add_sym(name,slen,&remember)==0 )
				{
				static_counter++;
				Z->type=V_FUNCTION;
				Z->size=EXPR_LONG;
				Z->v.l=start;
				}
			}
		}
	src_currentfn=new;
	strcpy(new->name,name);
	return 0;
}


/* given an attr, return its section number or -1 if bad */
word global_secnum(UNS32 attr)
{
word sec;
	if (attr&NEAR)
		sec=2;
	else if (attr&FAR)
		sec=0;
	else
		return -1;
	if (attr&UINIT)
		sec++;
	return sec;
}


/* given a pointer to a symbol, return its 'value' and its address */
/* addresses of register variables are returned as NULL */
void get_var_value(sym *s, byte *size, void *value, long *address)
{
ulong it;

	*size=s->size;
	switch (s->type&V_MASK)
		{
		case V_REG:
			it=(ulong)(&regs.dregs[s->v.b]);		/* will need adjusting for bytes/words */
			break;
		case V_FPREG:
			get_fpu_reg(s->v.b,NULL,NULL,value);
			*address=0L;
			return;				/* FP regs cannot be anything else */
			break;
		case V_OFFSET:
			it=(regs.aregs[s->v.oreg.reg]+s->v.oreg.offset);
			break;
		case V_GLOBAL:
			it=(s->v.l);
			break;
		}
	if (s->type&V_POINTER)
		{
		/* a pointers value requires an indirection */
		if ((s->type&V_MASK)==V_REG)
			{
			*address=0L;
			*(long*)value=*(long*)it;
			}
		else
			{
			*address=(long)it;
			safe_peekl(it,(ulong*)value);
			}
		*size=EXPR_LONG;
		return;
		}
	else if (s->type&V_ARRAY)
		{
		/* an arrays value is the same as its address */
		*address=(long)it;
		*((long*)value)=it;
		*size=EXPR_LONG;
		return;
		}
	/* its a 'normal' var */
	if ((s->type&V_MASK)==V_REG)
		{
		switch (s->size)
			{
			/* this code relies on native proc being Motorola!! */
			case EXPR_BYTE:
				it+=3; *((char*)value)=*(char*)it; break;
			case EXPR_WORD:
				it+=2; *(word*)value=*(word*)it; break;
			case EXPR_LONG:
				*(long*)value=*(long*)it; break;
			#if DOUBLES
			case EXPR_DOUBLE:
			case EXPR_SINGLE:
				*(double*)value=42; break;		/* NOTE: register singles/doubles dont work */
			#endif
			}
		*address=0L;
		return;
		}
	*address=(long)it;
	switch (s->size)
		{
		case EXPR_BYTE:
			*(char*)value=peekb(it); break;
		case EXPR_WORD:
			safe_peekw( it, value);
			break;
		case EXPR_LONG:
			safe_peekl( it, (ulong*)value);
			break;
		#if DOUBLES
		case EXPR_DOUBLE:
			safe_peekd( it, (double*)value);
			break;
		case EXPR_SINGLE:
			safe_peekl( it, (ulong*)value);
			break;
		#endif
		}
}

void add_var_src(byte type, byte size, long offset, char *name)
{
sym *s;
sym **table;
struct remstruct remember;
ubyte slen;

	slen=(ubyte)strlen(name);

	/* which sym table to add it to? */
	if (src_currentfile==NULL)
		table=&globaltable;
	else if (src_currentfn==NULL)
		table=&(src_currentfile->statictable);
	else
		table=&(src_currentfn->localtable);

	s=find_sym( table, name, slen, &remember, TRUE );

	if (s==NULL)
		{
		if ( add_sym(name,slen,&remember)==0 )
			{
			Z->type=type;
			Z->size=size;
			switch (type&V_MASK)
				{
				case V_REG: case V_FPREG: Z->v.b=(byte)offset; break;
				case V_OFFSET: Z->v.oreg.offset=(word)offset;
					Z->v.oreg.reg=src_currentfile->basereg;
					break;
				case V_GLOBAL:
					Z->v.l=offset;
					static_counter++;
					break;
				}
			scoped_symbol_count++;
			if (src_currentfile==NULL)
				Z->func=src_currentfn;		/* save ptr to owner */
			}
		}

#undef Z
}

word list_src_sym(sym *s)
{
word err;
char *p,*q;

	err=0;
		while (s)
			{
			if (s->type==V_FUNCTION)
				{
				s=s->next;		/* dont dump static fns */
				continue;
				}
			p=linebuf;
			*p++=' '; *p++=' ';
			strcpy(p,s->name);
			p+=s->len;
			*p++=' ';
			switch (s->size)
				{
				case EXPR_BYTE: q="char"; break;
				case EXPR_WORD: q="short"; break;
				case EXPR_LONG: q="long"; break;
				#if DOUBLES
				case EXPR_DOUBLE: q="double"; break;
				case EXPR_SINGLE: q="single"; break;
				#endif
				default: q="<size?>"; break;
				}
			strcpy(p,q);
			p+=strlen(q);
			if (s->type&V_POINTER)
				*p++='*';
			else if (s->type&V_ARRAY)
				{ *p++='['; *p++=']'; }
			*p++=' ';
			switch (s->type&V_MASK)
				{
				case V_REG: *p++ = s->v.b > 7 ? 'A' : 'D';
					*p++=(s->v.b&7)+'0';
					*p++='\n';
					*p++=0;
					break;
				case V_OFFSET:
					if (s->v.oreg.offset<0)
						sprintf(p,"-$%x(A%d)\n",(int)(-s->v.oreg.offset),(int)(s->v.oreg.reg));
					else
						sprintf(p,"$%x(A%d)\n",(int)(s->v.oreg.offset),(int)(s->v.oreg.reg));
					break;
				case V_GLOBAL:
					sprintf(p,"@ $%lx\n",s->v.l);
					break;
				case V_FPREG:
					*p++='F';
					*p++='P';
					*p++ = (s->v.b&7)+'0';
					*p++='\n';
					*p++=0;
					break;
				case V_BAD:
					strcpy(p,TX_BADSYM);
					break;
				default:
					strcpy(p,"<type?>\n");
					break;
				}
			if (err=list_print(linebuf))
				break;
			s=s->next;
			}
	return err;
}

word list_src_fn(struct src_fn *fn)
{
word err;

	sprintf(linebuf," Function: %s $%lx-$%lx %s\n",fn->name,fn->startpc,fn->endpc,(char*)(fn->isstatic?"static":"") );
	if (err=list_print(linebuf))
		return err;
	return list_src_sym(fn->localtable);
}

word list_src_file(struct src_file *file)
{
word err;
struct src_fn *fn;

	sprintf(linebuf,"File: %s $%lx-$%lx\n",file->name,file->startpc,file->endpc);
	if (err=list_print(linebuf))
		return err;
	if (err=list_src_sym(file->statictable))
		return err;
	fn=file->fnlist;
	while (fn)
		{
		if (err=list_src_fn(fn))
			return err;
		fn=fn->nextfn;
		}
	return 0;
}

/* * means globals, :name means that file, :: means files */
word list_functions(char *p)
{
struct src_file *file;
struct src_fn *fn;
word err;

	if (*p)
		{
		if (*p=='*')
			return list_src_sym(globaltable);
		file=src_filelist;
		while (file)
			{
			if (
				(*p==':') &&
				(stricmp(p+1,file->name)==0)
			   )
					return list_src_file(file);
			if (*p!=':')
				{
				fn=file->fnlist;
				while (fn)
					{
					if (stricmp(p,fn->name)==0)
						return list_src_fn(fn);
					fn=fn->nextfn;
					}
				}
			if ( (p[0]==':') && (p[1]==':') )
				{
				sprintf(linebuf,"File: %s $%lx-$%lx\n",file->name,file->startpc,file->endpc);
				if (err=list_print(linebuf))
					return err;
				}
			file=file->nextfile;
			}
		if ( (p[0]==':') && (p[1]==':') )
			return 0;
		else
			return ERRM_FNNOTFOUND;
		}
		
	if (err=list_src_sym(globaltable))
		return err;

	file=src_filelist;
	while (file)
		{
		if (err=list_src_file(file))
			return err;
		file=file->nextfile;
		}
	return 0;
}

long scoped_symbol_count;

void *do_static_hash(sym *s)
{
	return (void *)s->v.l;
}

static void fixup_glo(sym *s, struct src_file *file, long start)
{
short secnum;
long secstart;
struct src_file *f;

	f=file;
	while (s)
		{
		if (s->type==V_FUNCTION)
			{
			s->v.l+=start;
			if (static_hash)
				add_hash(static_hash,s,do_static_hash,FALSE);
			}
		else if ((s->type&V_MASK)==V_GLOBAL)
			{
			if (file==NULL)
				f=(struct src_file *)(s->func);		/* get owner file for globals */
			secnum = (ulong)(s->v.l)>>24;
			secstart = f->section_offset[secnum];
			if (secstart<0L)
				s->type=V_BAD;
			else
				{
				s->v.l &= 0x00FFFFFFL;
				s->v.l += secstart;
				if (static_hash)
					add_hash(static_hash,s,do_static_hash,FALSE);
				}
			}
		s=s->next;
		}
}

void fixup_src(long start)
{
struct src_file *file;
struct src_fn *fn;
short i;

	file=src_filelist;
	while (file)
		{
		file->startpc+=start;
		file->endpc+=start;
		/* each section_offset needs fixing */
		for (i=0; i<4; i++)
			{
			if (file->section_offset[i]>=0L)
				if (symbol_style==OLD)
					file->section_offset[i]+=(i&1) ? progbp->bbase : progbp->dbase;
				else
					file->section_offset[i]+=progbp->tbase;		/* new debug is wrong, IMHO */
			}
		fn=file->fnlist;
		while (fn)
			{
			fn->startpc+=start;
			fn->endpc+=start;
			fn->setuppc += start;
			fixup_glo(fn->localtable,file,start);
			fn=fn->nextfn;
			}
		fixup_glo(file->statictable,file,start);
		file=file->nextfile;
		}

	fixup_glo(globaltable,NULL,start);		/* globals each refer to their owner file */
	
	src_currentfile=NULL;
	src_currentfn=NULL;
}


/******** read the file code **********/

#include <setjmp.h>

DBG_NAME;
DBG_SIZE;

/* given a line number for a particular file, get its address (note: needs fixing up after loading) */
long xlnum(UNS16 lnum, struct dbfile *dbf)
{
struct linfo *ll;
long count,line;

	count=dbf->linecount;
	ll=dbf->linelist;
	line=(long)lnum;
	while (count--)
		{
		if (lnum<=ll->line)
			return ll->pc+dbf->startpc;
		ll++;
		}
	return 0L;
}

static jmp_buf jmpsrc;
FILE *srcfp;
struct {
	union DBGUNION un;
	char *name;
	} *dblocks;				/* a dynamic array */

void extract_var( BLK_TYP index, struct dbfile *dbf, RANGE kludge )
{
struct DBGID *thisid;

	while (index)
		{
		byte type,size;
		thisid = &(dblocks[index].un.did);
		
		/* work out if this is worth bothering with */
		if (
				((thisid->attr&REF)==0) &&							/* ignore if not defined in module */
				(dblocks[index].name[0]!='?')						/* ignore Lattice internal symbols */
			)
/*		if (thisid->attr&(FORMAL|AUTO|STATIC))	*/
			{
			type=V_OFFSET;
			size=-1;
			if (thisid->attr&REG)
				{
				type=V_REG;
				thisid->offset = (thisid->offset >> 24) & 0xF;		/* get reg number */
				}
			else if (thisid->attr&(FORMAL|AUTO))
				thisid->offset += kludge;					/* for nn(An) */
			else
				{
				/* presumably a global variable */
				short secnum;
				secnum=global_secnum(thisid->attr);
				if (secnum<0)
					goto next;
				type=V_GLOBAL;
				thisid->offset |= (long)secnum <<24;		/* secnum in high byte */
				if (thisid->attr&STATIC)
					;		/* RSN */
				}
			switch (thisid->attr&7)
				{
				case CHAR:
				case VOID:
					size=EXPR_BYTE; break;
				case SHORT: size=EXPR_WORD; break;
				case LONG: size=EXPR_LONG; break;
				#if DOUBLES
				case DOUBLE:
					size=EXPR_DOUBLE;
					if (thisid->attr&REG)
						if (fputype)
							type=V_FPREG;
						else
							size=-1;							/* register floats only if fpu */
					break;
				case FLOAT:
					size=EXPR_SINGLE;
					if (thisid->attr&REG)
						if (fputype)
							type=V_FPREG;
						else
							size=-1;							/* register floats only if fpu */
					break;
				#endif
				}
			if (thisid->attr&POINTER)
				type|=V_POINTER;
			if (thisid->cont)
				{
				/* Note that this has a completely different interpretation to the docs */
				UNS16 flag;
				flag=dblocks[thisid->cont].un.dctx.type;
				if (flag==0)
					size=EXPR_LONG;				/* function ptr */
				else if (flag&2)
					type|=V_ARRAY;				/* array */
				else if ( (size!=-1) && (flag&1) )
					type|=V_POINTER;			/* a pointer to something */
				}
			/* RSN cope with unsigned */
			if (size!=-1)
				{
				char *name;
				name=dblocks[index].name;
				add_var_src( type, size, thisid->offset, dblocks[index].name );
				}
			}
next:	index=thisid->link;
		}
}

void clear_dblocks(BLK_TYP num)
{
BLK_TYP i;

	if (dblocks==NULL)
		return;

	for (i=1; i<num; i++)				/* element 0 never used */
		{
		if (dblocks[i].name)
			freemem(dblocks[i].name);
		}
	freemem(dblocks);
	dblocks=NULL;
}

/* extract things from a func or block */
void do_vars(union DBGUNION *thisfn,struct dbfile *dbf, bool params)
{
	if (thisfn->dfunc.stats) extract_var( thisfn->dfunc.stats, dbf, 0 );
	if (params && thisfn->dfunc.parms) extract_var( thisfn->dfunc.parms, dbf, 8 );
	if (thisfn->dfunc.autos) extract_var( thisfn->dfunc.autos, dbf, 0 );
}

/* recusrive routine to handle a block */
void do_blk(BLK_TYP b, struct dbfile *dbf)
{
struct DBGBLK *thisblk;

	thisblk=&(dblocks[b].un.dblk);
	do_vars((union DBGUNION*)thisblk,dbf,FALSE);		/* do me */
	b=thisblk->clink;
	if (b)
		do_blk(b,dbf);			/* do children */
	b=thisblk->slink;
	if (b)
		do_blk(b,dbf);			/* do my brother. (He will do any more brothers) */
}

word read_locals( FILE *fp, word dindex)
{
int err;
union DBGUNION z;
BLK_TYP howmany,function,global;
struct dbfile *dbf;
struct src_file *oldfile;
bool newfunc;

	dblocks=NULL;
	srcfp=fp;
	if (err=setjmp(jmpsrc))
		{
		clear_dblocks(z.dhead.totalblks);
		return (word)err;
		}

	dbf=dblist[dindex];
	
	/* we build an array of pointers to each block */
	
	if (fgetc(fp)!=NDBGHEAD)
		return ERRM_BADFORMAT;

	/* note that dhead.version=" V5.06.0" (no null) */
	fread(&z,SIZDBGHEAD,1,fp);
	if (z.dhead.blockno)
		return ERRM_BADFORMAT;
	if ( (function=z.dhead.func)==0)
		return 0;												/* ignore function-less files */

	if (NEWFUNC(z.dhead.version))
		{
		/* we never use localoff so we dont need to refer to func2 explicitly */
		newfunc=TRUE;
		dbgsize[NDBGFUNC]=SIZDBGFUNC2;
		}
	else
		{
		newfunc=FALSE;
		dbgsize[NDBGFUNC]=SIZDBGFUNC;
		}

	howmany=z.dhead.totalblks;
	if ( (dblocks=getzmem(howmany*sizeof(*dblocks)))==NULL )
		return ERRM_NOMEMORY;

	if (add_file_src(dbf->startpc,dbf->endpc,dbf->name,6))			/* add the file to the list */
		return ERRM_NOMEMORY;

	src_currentfile->section_offset[0]=
	src_currentfile->section_offset[1]=
	src_currentfile->section_offset[2]=
	src_currentfile->section_offset[3]=-1L;								/* we know none of them yet */

	while (--howmany)
		{
		int dtype;
		BLK_TYP bnum;
		
		dtype=fgetc(fp);
		if ( (dtype<0) || (dtype>NDBGMAX) || (dbgsize[dtype]==0) )
			longjmp(jmpsrc,ERRM_BADFORMAT);
		fread(&bnum,2,1,fp);
		if (bnum>=z.dhead.totalblks)
			longjmp(jmpsrc,ERRM_BADFORMAT);

		fread(&(dblocks[bnum].un.dhead.totalblks),dbgsize[dtype]-2,1,fp);		/* the dblocks entries do not have a block number */

		if (dbgname[dtype])
			{
			char *new;
			dtype=fgetc(fp);
			if (dtype==EOF)
				longjmp(jmpsrc,ERRM_BADFORMAT);
			new=getmem(dtype);
			if (new==NULL)
				longjmp(jmpsrc,ERRM_NOMEMORY);
			fread(new,dtype,1,fp);					/* read the string */
			new[dtype]=0;
			dblocks[bnum].name=new;
			}
		}
	/* now perform some useful calculations. Note that z still has the
		header */
	
	while (function)
		{
		struct DBGFUNC *thisfn;
		
		thisfn = &(dblocks[function].un.dfunc);
		if (add_fn_src(	
				xlnum(thisfn->flno,dbf),
				xlnum(thisfn->llno,dbf),
				xlnum((BLK_TYP)(thisfn->flno+1),dbf),
				dblocks[function].name,
				(bool)(thisfn->attr & DEF ? FALSE : TRUE)			/* strange static func flag */
				))
			break;
		/* do the variables etc now */
		do_vars( (union DBGUNION*)thisfn,dbf,TRUE);
		/* do the blocks now */
		if (thisfn->fblk)
			do_blk(thisfn->fblk,dbf);
		function=thisfn->link;						/* get the next name */
		}

	/* now do the static variables */
	src_currentfn=NULL;								/* add to static table */
	if (z.dhead.stats)
		extract_var(z.dhead.stats,dbf,0);

	/* try and calculate the section starts, based on the global variables defined in this file */
	global=z.dhead.exts;
	howmany=0;
	while (global)
		{
		short secnum;
		if ((dblocks[global].un.did.attr&REF)==0)		/* skip imported globals */
			{
			secnum=global_secnum(dblocks[global].un.did.attr);
			if (src_currentfile->section_offset[secnum]==-1L)
				{
				/* find it in asm table */
				sym *s; char buf[256];
				buf[0]='_';
				strcpy(buf+1,dblocks[global].name);
				s=find_sym(&asm_syms,buf,(ubyte)strlen(buf),NULL,TRUE);
				if (s)
					{
					src_currentfile->section_offset[secnum] = s->v.l - dblocks[global].un.did.offset;
					if (++howmany==4)
						break;
					}
				}
			}
		global=dblocks[global].un.did.link;
		}

	oldfile=src_currentfile;
	src_currentfn=(struct src_fn*)src_currentfile;	/* remember the current file */
	src_currentfile=NULL;							/* say 'add to global table' */
	if (z.dhead.exts)
		extract_var(z.dhead.exts,dbf,0);			/* simpler than a function */
	src_currentfile=oldfile;						/* so next file gets linked in */
	
	clear_dblocks(z.dhead.totalblks);	
	return 0;
}

bool scoped_offset_ok;

/* call this to (possibly) switch scopes */
void new_scope(long pc)
{
struct src_file *file;
struct src_fn *fn;

	if (src_filelist==NULL)
		{
elsewhere:
		src_currentfile=NULL;
		src_currentfn=NULL;
		return;
		}
	if (
		((file=src_currentfile)==NULL) ||					/* not in a file */
		(pc < src_currentfile->startpc) ||
		(pc > src_currentfile->endpc)				/* or fallen out of old one */
	   )
		{
		/* calc which file we are in */
		file=src_filelist;
		while (file)
			{
			if ( (pc >= file->startpc) && (pc <= file->endpc) )
				{
				src_currentfn=NULL;
				break;
				}
			file=file->nextfile;
			}
		if (file==NULL)
			goto elsewhere;
		}
	
	if (
		(src_currentfn==NULL) ||
		(pc < src_currentfn->startpc) ||
		(pc > src_currentfn->endpc)
	   )
	   	{
	   	fn=file->fnlist;
	   	while (fn)
	   		{
	   		if ( (pc >= fn->startpc) && (pc <= fn->endpc) )
	   			{
	   			src_currentfile=file;
	   			src_currentfn=fn;
	   			break;
	   			}
	   		fn=fn->nextfn;
	   		}
	   	if (fn==NULL)
	   		goto elsewhere;							/* probably an ALV */
	   	}
	scoped_offset_ok = (bool)( pc >= src_currentfn->setuppc ? TRUE : FALSE);
}

/* match help list with non-static fns in a file */
/* this is made more complex as match_fn wants a sym, but we only have a name */

long match_fn_names( struct src_file *file, long (*match_fn)(sym*) )
{
struct {
	sym s;
	char buffer[256];			// used as a kludged-sym entry
	} dummy;
struct src_fn *fn;
long ret;

	fn = file->fnlist;
	while (fn)
		{
		dummy.s.len = 0;			// indicates dummy sym entry
		dummy.s.v.ptr = fn->name;	// real name ptr
		strcpy(dummy.s.name, fn->name);
		ret = match_fn(&dummy.s);
		if (ret)
			return ret;
		fn = fn->nextfn;
		}
	return 0;		
}

/* match help list with scoped vars */
long match_scoped_syms( long (*match_fn)(sym *) )
{
long ret;
struct src_file *file;

	ret=0;
	if ( (src_filelist==NULL) || (src_currentfile==NULL) || (src_currentfn->localtable==NULL) )
		goto tryglobals;

	if (scoped_offset_ok==FALSE)
		goto trystatics;									/* if haven't set base reg etc */

	/* try scoped-to-function variables */
	ret=foreachsym(src_currentfn->localtable,match_fn);
	if (ret)
		return ret;

trystatics:
	ret=foreachsym(src_currentfile->statictable,match_fn);
	if (ret)
		return ret;

tryglobals:
	/* non-static fns are in each file record */
	/* we start by adding the current file's ones */

	if (src_currentfile)
		{
		ret = match_fn_names(src_currentfile,match_fn);
		if (ret)
			return ret;
		}
	file = src_filelist;
	while (file)
		{
		if (file!=src_currentfile)
			{
			ret = match_fn_names(file,match_fn);			// add the other file's now
			if (ret)
				return ret;
			}
		file = file->nextfile;
		}
		
	/* global vars last */	
	
	if (globaltable)
		{
		ret = foreachsym(globaltable,match_fn);
		//if (ret)
		//	return ret;
		}

	// if any code gets added here, uncomment the if (ret) above

	return ret;

}

/* slightly processor dependent cos of regs */
/* (excuse the gotos but give me a break) */

bool find_scoped_sym(char*name,ubyte slen,void**where,byte*size,bool getaddr)
{
sym *s;
static union alltypes val;
static long addr;

	if ( (src_filelist==NULL) || (src_currentfile==NULL) || (src_currentfn->localtable==NULL) )
		goto tryglobals;

	if (scoped_offset_ok==FALSE)
		goto trystatics;									/* if haven't set base reg etc */

	/* try scoped-to-function variables */
	s=find_sym( &(src_currentfn->localtable), name, slen, NULL, symcase );
	if (s)
		goto gotit;

trystatics:
	s=find_sym( &(src_currentfile->statictable), name, slen, NULL, symcase );
#if 1
	if (s)
		{
		if (s->type!=V_FUNCTION)
			goto gotit;
		/* static fn */
		*size=EXPR_LONG;
		val.l=s->v.l;
		*where=&val.l;			/* &func same as func */
		return TRUE;
		}
#else
	if (s)
		goto gotit;

	/* could be a (static) function in this file */
	fn=src_currentfile->fnlist;
	while (fn)
		{
		if (
			(memcmp(fn->name,name,(size_t)slen)==0) &&
			(fn->name[slen]==0)
		   )
		   {
		   *size=EXPR_LONG;
		   val.l=fn->startpc;
		   *where=&val.l;				/* &func evals same as func */
		   return TRUE;
		   }
		fn=fn->nextfn;
		}
#endif

tryglobals:
	s=find_sym( &globaltable, name, slen, NULL, symcase );
	if (s)
		goto gotit;
	
	return FALSE;

gotit:
	if (s->type==V_BAD)
		return FALSE;
	get_var_value(s, size, &val, &addr);

	/* untidy code to fool caller. Problems if remote debugger cos addr & val in debugger RAM space */
	if (getaddr)
		{
		*size=EXPR_LONG;
		*where=&addr;
		}
	else
		*where=&val;

	return TRUE;
}

#define	local_is_printable(x)	( (x->type&V_ARRAY)==0 )

bool refill_local(struct ws *wptr)
{
char *p;
uword start;
word lines;
sym *sym;
union alltypes val;
long addr;
byte size;

	if (
		(src_currentfile==NULL) ||
		(src_currentfn->localtable==NULL) ||
		(scoped_offset_ok==FALSE)
	   )
	   	{
	   	wptr->wlong=0;
		return TRUE;
		}

	start=(uword)(wptr->wlong);
	sym=src_currentfn->localtable;
	while (start-- && sym)
		sym=sym->next;

/*	sprintf(linebuf,"%s:%s",src_currentfile->name,src_currentfn->name);
	wprint_line(wptr,linebuf,TRUE); */
	lines=wptr->h-2;
	
	while (sym && lines)
		{
		if (local_is_printable(sym))
			{
			strcpy(linebuf,sym->name);
			p=linebuf+sym->len;
			*p++=' ';
			*p++='=';
			*p++=' ';
			get_var_value( sym, &size, &val, &addr );
			switch (size)
				{
				case EXPR_DOUBLE:
					p+=sprintf(p,double_format_string,val.d);
					break;
				case EXPR_SINGLE:
					p+=sprintf(p,double_format_string,(double)(val.f) );
					break;
				default:
					coerce_value(&val,size,&addr,EXPR_LONG);
					p=sprintlong(p,addr,0);
					*p=0;
					break;
				}
			wprint_line(wptr,linebuf,TRUE);
			lines--;
			}
		sym=sym->next;
		}
	return TRUE;
}


void key_local(word key)
{
word adjust;
word lines;
uword start,count;
sym *sym;

	auto_numeric(&key);

	if (do_controlkey(key)==TRUE)
		return;

	if (
		(src_currentfile==NULL) ||
		(src_currentfn->localtable==NULL) ||
		(scoped_offset_ok==FALSE)
	   )
	   return;

	lines=frontwindow->h-2;
	adjust=0;
	start=(uword)(frontwindow->wlong);

	count=0;
	sym=src_currentfn->localtable;
	if (sym==NULL)
		return;

	while (sym)
		{
		if (local_is_printable(sym))
			count++;
		sym=sym->next;
		}

	if (key==KEY_DOWN)
		{
		if ( (count-start)>lines)
			adjust=1;
		}
	else if (key==KEY_UP)
		{
		if (start)
			adjust=-1;
		}
	else
		return;

	if (adjust)
		{
		frontwindow->wlong+=adjust;
		window_cls(frontwindow);
		refill_local(frontwindow);
		update_contents(frontwindow);
		}
}

#else
word list_functions(void) { return 0; }
bool find_scoped_sym(char*x,ubyte y,void**z,byte*a) { return FALSE; }
bool refill_local(struct ws *wptr) { return FALSE; }
#endif

/******** Lattice 5 ST Specific **************/

#define	LONGSTR_SRC		(long)(('S'<<24)|('R'<<16)|('C'<<8)|' ')
#define	LONGSTR_LINE	(long)(('L'<<24)|('I'<<16)|('N'<<8)|'E')
#define	LONGSTR_HEAD	(long)(('H'<<24)|('E'<<16)|('A'<<8)|'D')
#define	LONGSTR_HCLN	(long)(('H'<<24)|('C'<<16)|('L'<<8)|'N')

#define readlong(x)	if (fread(&x,sizeof(long),1,fp)!=1) goto rderr


/* read any source debug, returns TRUE if so */
/* assumes just read ordinary ST syms */
bool read_dbfile(FILE *fp, word reloc)
{
long hlen;
long htype;
byte gotsome;			/* 0=nothing; 1=header only; 2=sensible */
long junk;
long hstart;
char spare[8*4];
long offset;

long numlines,flen,codesize;
struct linfo *where;
char name[MAXFILENAME+1];
word dbindex;
bool said_waiting=FALSE;

	gotsome=0;
	static_counter=0L;

	if (reloc==0)
		{
		int c;
		
		readlong(junk);			/* first word of reloc */
		if (junk)
			{
			while (c=fgetc(fp))
				if (c==EOF)
					goto rderr;

			if (ftell(fp) & 1 )
				fgetc(fp);
			}
		}
	
	scoped_symbol_count=0L;
	for (;;)			/* read all hunk debugs */
		{

		if ( fread(&junk,sizeof(long),1,fp)!=1)
			break;			/* if EOF reached when expected */
		if ( (junk==0) && gotsome)
			break;			// zero might mean padded, so stop without error
		if (junk!=0x3F1)
			goto badf;		/* or if someone else, eg MWC */

		readlong(hlen);
		hstart=ftell(fp);
	
		readlong(offset);
		readlong(htype);
		if (said_waiting==FALSE)
			{
			safe_print(TX_READINGDEBUG);
			said_waiting=TRUE;
			}
			
		switch (htype)
			{
			case LONGSTR_HEAD:
				if (gotsome!=0)
					break;						/* not an error as HBasic2 (beta-2) does this */
				if ( fread(&spare,6,1,fp)!=1 )
					goto rderr;
				if (strncmp(spare,"DBGV01",6))
					goto rderr;
				gotsome=1;
				break;
			case LONGSTR_SRC:
				{
				if (gotsome==0)
					goto badf;
				if (fread(&spare,4,8,fp)!=8)	/* get full path */
					goto rderr;
				readlong(codesize);
				readlong(numlines);
				numlines>>=3;				/* number of entries */
				readlong(junk);
				readlong(flen);
				if (flen>MAXFILENAME)
					break;					/* if too long */
				fread(&name,flen,1,fp);
				if (name[--flen])
					name[++flen]=0;			/* ensure null termed */
				if (numlines)
					{
					where=init_dbfile( spare, strlen(spare),
						offset,(long)(offset+codesize),numlines,&dbindex,name);
					if (where==NULL)
						goto exitloop;
					fread(where,sizeof(struct linfo),numlines,fp);
					#if LOCALS
					read_locals(fp,dbindex);		/* RSN report errors? */
					#endif
					gotsome=2;
					}
				break;
				}
			case LONGSTR_HCLN:
				/* HiSoft Compiler Line Numbers - no HEAD is output (beta 3) so cannot check gotsome */
				readlong(flen);			/* BCPL form */
				flen<<=2;				/* into bytes */
				if ( flen > MAXFILENAME )
					break;
				fread(&name,flen,1,fp);
				name[flen]=0;			/* ensure null-termed */
				readlong(numlines);
				if (numlines)
					{
					long sofar; long lnum; //long fix;
					/* dont know end addr yet */
					where=init_dbfile(name,strlen(name),offset,0L,numlines,&dbindex,name);
					if (where==NULL)
						goto exitloop;
					sofar=lnum=0;
					while (numlines--)
						{
						long l1,l2;
						l1=(long)(ubyte)fgetc(fp);
						if (l1==0)
							{
							l1=((long)(ubyte)fgetc(fp))<<8;
							l1|=(ubyte)fgetc(fp);
							if (l1==0)
								readlong(l1);
							}
						lnum+=l1;
						
						l2=(long)(ubyte)fgetc(fp);
						if (l2==0)
							{
							l2=((long)(ubyte)fgetc(fp))<<8;
							l2|=(ubyte)fgetc(fp);
							if (l2==0)
								readlong(l2);
							}
						#if 0
						/* HB2-prerelease spits out offsets of zero which need fixing */
						// this code breaks Devpac3 and HB seems to be fixed now
						// so we don't do it (refs to fix also removed)
						if ( (sofar==0) && (offset==0) )
							{
							dblist[dbindex]->startpc=l2;
							fix=l2;
							}
						#endif
						sofar+=l2;
						where->line=lnum;
						where->pc=sofar; //-fix
						where++;
						}
					/* we know the end address now */
					dblist[dbindex]->endpc=(--where)->pc+offset;	//+fix;
					}
				gotsome=2; break;
			case LONGSTR_LINE:
				if (gotsome==0)
					goto badf;
				readlong(flen);			/* BCPL form */
				numlines=(hlen-3-flen)>>1;	/* 2 bytes/line */
				flen<<=2;				/* into bytes */
				if ( flen > MAXFILENAME )
					break;
				fread(&name,flen,1,fp);
				name[flen]=0;			/* ensure null-termed */
				if (numlines)
					{
					/* dont know end addr yet */
					where=init_dbfile(name,strlen(name),offset,0L,numlines,&dbindex,NULL);
					if (where==NULL)
						goto exitloop;
					fread(where,sizeof(struct linfo),numlines,fp);
					/* we know the end address now */
					where+=(numlines-1);			/* last line */
					dblist[dbindex]->endpc=where->pc+offset;
					}
				gotsome=2; break;
			default:
				goto badf;
			}
		fseek(fp,hstart+(hlen<<2),0);			/* go to next one */
		}
exitloop:
	if (static_counter && (static_counter<60000) )
		build_hash(&static_hash,(uword)static_counter);
	return (bool)(gotsome&2);

nomem:
rderr:
badf:
	return FALSE;
}

void fixup_dbfile(long tstart)
{
short i;
long j;
struct linfo *llist;

	for (i=0; i<maxfiles; i++)
		{
		if (dblist[i])
			{
			dblist[i]->startpc += tstart;
			dblist[i]->endpc += tstart;
			j=dblist[i]->linecount;
			llist=dblist[i]->linelist;
			while (j--)
				{
				llist->pc += dblist[i]->startpc;
				llist++;
				}
			}
		}
	#if LOCALS
	fixup_src(tstart);
	#endif
}

/*************** smart source window handler **************/
/*************** (teeny bit processor dependent) **********/

/* the wlong field contains the PC of the top */
/* if wword is non-zero, we try to change the mode */

/* the magic field contains a ptr to a smartw entry */
/* or 0 if unknown */


#define	SM_MIN		1
#define	SM_ASM		1
#define	SM_MIXED	2
#define	SM_SOURCE	3
#define	SM_MAX		4

void winit_smart(struct ws *w)
{
struct smartw *s;

	s=(struct smartw*)getzmem(sizeof(struct smartw));
	if (s==NULL)
		w->type=WTYPE_NONE;
	else
		{
		s->file=NULL;
		w->magic=(void*)s;
		w->wlong=0L;
		w->wword=0;
		s->mode=s->tmode=SM_SOURCE;			/* default mode */
		}
}

/* switch title on window to source */
void window_source_title(struct ws *w, struct dbfile *db)
{
char title[MAXTITLE+1];

	if (db->opened)
		if (flist[db->opened]->new)
			{ /* file has changed so mark it as such */
			stccpy(title,db->name,MAXTITLE-strlen(TX_MODIFIED));
			strcat(title,TX_MODIFIED);
			window_title2(w,title,TRUE);
			return;
			}
	window_title2(w,db->name,TRUE);
}

/* this requires that the file is open */
void calc_linfo( uword lnum, struct linfo **linfo, char ***line, struct smartw *sm)
{
long lcount;
	*linfo = sm->file->linelist;
	lcount = sm->file->linecount;
	while (lcount--)
		{
		if ( (*linfo)->line >= lnum )
			break;
		(*linfo)++;
		}
	if (sm->file->opened==0) ILLEGAL;
	*line = flist[sm->file->opened]->lineoffset + (lnum-1);		/* who needs arrays? */
}

/* if we start after a source line, bump ptrs to next */
#define calc_mixed(pcx,lnum,linfox)	if (pcx!=sm->linfo->pc) { linfox++; lnum=(linfox)->line; }

void smart_line(char *p, uword line, char *fmt)
{
word x; char c;
char *b;
	x=0;
	sprintf(linebuf,fmt,line);
	b=linebuf+4;
	while (*b)
		b++;
	/* copy chars expanding tabs */
	do
		{
		x++;
		if ( (c=*b++=*p++)=='\t' )
			{
			word space;
			*b--;
			x--;
			space=sourcetabsize-(x % sourcetabsize);
			while (space--)
				{
				*b++=' ';
				x++;
				}
			}
		}
	while ( (c) && (x<200) );
}

/* go down a line in mixed mode, returns FALSE if past end of file */
/* if fast is FALSE, returns ASCII in linebuf. source should be FALSE to start with */
bool next_mixed( ulong *pc, struct linfo **linfo, char ***line, uword *lnum, bool fast, struct smartw *sm, uword *subline)
{
ulong toppc;

	toppc=*pc;
	if ( toppc >=sm->file->endpc)
		return FALSE;

	if (toppc==(*linfo)->pc)
		{
		/* show the source form of this line */
		if (fast)
			(*line)++;
		else
			smart_line(*(*line)++,*lnum,"%6d: ");
		
		if (*lnum==(*linfo)->line)
			(*linfo)++;								/* pc unchanged */

		(*lnum)++;
		*subline=0;
		return TRUE;
		}
	else
		{
		if (!fast)
			sprintf(linebuf,(ucasediss ? "%04lX %c" : "%04lx %c"),
				toppc,(toppc==regs.pc) ? '>' : ' ');
		toppc=diss(toppc,fast);
		if (toppc>(*linfo)->pc)
			toppc=(*linfo)->pc;					/* in case fallen into data */
		if (!fast) strcattab(linebuf,dissbuf,FALSE,8);
		*pc=toppc;
		*subline++;
		return TRUE;
		}
}

/* smart windows are not very smart when it comes to redrawing;
	they dont work intelligently, like diss windows, but just
	redraw when something changes, keeping the display neat. This
	is known as the MonST method... */

bool mayrefill_smart(struct ws *w, ulong new, bool actual)
{
bool exact;
uword lnum;
struct dbfile *df;
long lindex;
struct smartw *sm;
word lines;
ulong toppc;
word i; uword l2; uword subline;
char oldmode;

	sm=(struct smartw*)(w->magic);
	lines=w->h-2-2;					/* the extra 2 is to leave space at the bottom */
	w->wlong=sm->toppc;
	oldmode=sm->tmode;

	/* see if the user has requested a different mode */
	if (w->wword)
		{
		if ( (w->wword >0) && (w->wword<SM_MAX) )
			{
			sm->mode=(char)(w->wword);
			actual=TRUE;
			}
		else if (w->wword==-1)
			{
			/* user wants next mode */
			if ( ++(sm->mode)>=SM_MAX )
				sm->mode=SM_MIN;
			actual=TRUE;
			}
		w->wword=0;
		}

	if (find_linenumber(new, &exact, &df, &lnum, &lindex))
		{
		if ( (df!=sm->file) || (sm->tmode==SM_ASM) )
			{ /* file changed or was asm previously */
			window_source_title(w,df);
			}
			/* check for auto change of modes */
			/* if asm is wanted, it always is */
			/* if mixed is wanted, it might go to asm */
			/* if source is wanted, it might kick to mixed or asm */
		if (sm->mode==SM_SOURCE)
			{
			sm->tmode=exact ? SM_SOURCE : SM_MIXED;
			if ( (sm->mode==sm->tmode) && (new>=sm->toppc)
				&& (df==sm->file) && (lnum>=sm->topline)
				&& (lnum<(sm->topline+lines))
				&& (actual==FALSE) )
				return TRUE;			/* if source fits */
			}
		else
			/* we're in source - display as user wants
				(either mixed or asm) */
			sm->tmode=sm->mode;	


		/* we need to ensure the file is open before calc_linfo */
		if ( (df) && (df->opened==0) && (sm->tmode!=SM_ASM) && onesource )
			{ /* lets switch to it - old file will bne handled by open_file */
			word op;
			op=open_file(df->fullname,onesourcebuf);	/* and open new file */
			if (op==0)
				{
				sm->tmode=SM_ASM; /* RSN report the error? */
				goto goasm;
				}
			else
				df->opened=op;
			}


		if ( (sm->tmode==SM_MIXED) && (sm->file==df) )
			{ /* mixed, on a line will always stay mixed */
#if 0
	Old code, which worked but was too simplistic
	/* hack for mixed; always start with source line */
	sm->file=df;
	sm->topline=lnum;
/*	sm->toppc=((df->linelist)+lindex)->pc;	TEMP */
	sm->toppc=new;
	w->wlong=sm->toppc;
	return TRUE;
#endif
			toppc=sm->toppc;
			if ( (new>=toppc) && (actual==FALSE) && (oldmode==SM_MIXED) )				/* if before or actual then must recalc */
				{
				/* is the value currently displayed? If so then dont change anything */
				/* (we know the file is open cos we just did it) */
				/* assumes linof etc is valid a previous mode was OK */
				struct linfo *linfo2; char **line2;
				l2=sm->topline;											/* start where the window top is */
				subline=0;
				i=w->h-3;
				linfo2=sm->linfo; line2=sm->line;
				while (i-- && next_mixed( &toppc, &linfo2, &line2, &l2, TRUE, sm, &subline ) )
					{
					if (new==toppc)
						return TRUE;				/* it fits, so just redraw (slow but OK) leaving vars alone */
					}
				}
			/* we need to redisplay as we've fallen off */
			;
			/* we do nothing, so we get to the else clause down below */
			}
	
		if (sm->tmode==SM_SOURCE)
			{
			/* force a redraw of this one from the top */
			if (lnum<(w->h-2))
				lnum=1;					/* if near top then make top */
			if ( (actual==FALSE) && (w->h>5) && (lnum>3) )
				lnum-=3;				/* start a few lines back */
			sm->file=df;
			/* if exact and pc is at start of file, start there */
			if ( (actual==TRUE) && (new==sm->file->linelist->pc) )
				sm->topline=1;
			else
				sm->topline=lnum;
			sm->toppc=new;
			}
		else if (sm->tmode==SM_MIXED)
			{
			/* into mixed; start at nearest source line, mostly */
			sm->file=df;
			sm->topline=lnum;
			toppc=sm->toppc=((df->linelist)+lindex)->pc;
			calc_linfo(lnum,&(sm->linfo),&(sm->line), sm);
			/*calc_mixed(new, sm->topline, sm->linfo);*/
			/* should check subline doesnt fall off bottom RSN */
			}
		else
			{
			// we're in a source file but user actually wants asm
			// note that the source file title has been set by here
			// but the file is probably NOT open
			goto goasm2;
			}
		}
	else
		{ /* no line number found; fair enough, kick to asm */
		if (sm->tmode!=SM_ASM)
			{
goasm:		window_title2(w,TX_NOSOURCE,TRUE);
			sm->toppc=new;
			sm->tmode=SM_ASM;
			}
		else
			{
			/* OK, were in asm, still are. Can we be optimal? */
goasm2:		toppc=sm->toppc;
			if ( (actual==FALSE) && (new>=toppc) && (new<(toppc+lines*MAXDISSBYTES)) )
				while (lines--)
					{
					if (toppc==new)
						return TRUE;			/* neat redraw */
					toppc=diss(toppc,TRUE);
					}
			/* OK, a dumb redraw is required */
			sm->toppc=new;
			}
		}

	w->wlong=sm->toppc;
	return TRUE;
}


/* this requires sm->toppc and sm->topline to have been set */
/* mixed mode also requires ->linfo and ->line */

bool refill_smart(struct ws *w)
{
struct smartw *sm;
word i;
fileinfo *f;
uword lnum;
ulong toppc;
struct linfo *linfo2;
char **line2;

	sm=(struct smartw*)(w->magic);

	if ( (sm->file==NULL) || (sm->file->opened==0) )
		/* no source is available */
		sm->tmode=SM_ASM;

	if (sm->tmode==SM_ASM)
		{ /* asm mode is slower than proper diss windows, but we dont care */
		toppc=sm->toppc;
		for (i=w->h-2; i; i--)
			{
			char *s; ubyte slen;
			sprintf(linebuf,ucasediss ? "%8lx%c" : "%8lX%c",toppc,
				toppc==regs.pc ? '>' : ' ' );
			s=find_asm_symbol(toppc,&slen);
			*(diss_sym(s,slen,12)) = 0;
			toppc=diss(toppc,FALSE);
			strcattab(linebuf,dissbuf,FALSE,8);
			wprint_line(w,linebuf,TRUE);
			}
		return TRUE;
		}
		
	f=flist[sm->file->opened];
	lnum=sm->topline;
	if (lnum==0)
		lnum=sm->topline=1;				/* just in case */
	if (lnum>f->linesinfile)
		lnum=f->linesinfile;

	/* calc where in the linelist we are; should be done by mayrefill */
	/* now done by mayrefill */	
	
	if (sm->tmode==SM_MIXED)
		{
		uword subline;

		linfo2=sm->linfo; line2=sm->line;
		toppc=sm->toppc;
		i=w->h-2;
		subline=0;
		while ( i-- && next_mixed( &toppc, &linfo2, &line2, &lnum, FALSE, sm , &subline) )
			wprint_line(w,linebuf,TRUE);
		}
	else /* SM_SOURCE */
		{
		calc_linfo( lnum, &linfo2, &line2, sm);		/* should be mayrefill */
		for (i=w->h-2; i; i--)
		{
		char *flag,brk;
			if (lnum>f->linesinfile)
				break;					/* no more lines */
			flag="%6d: ";
			brk=0;
			
			if (linfo2->line==lnum)
				{
				if (linfo2->pc==regs.pc)
					flag="%6d:>";
				/* show if a breakpoint on this line */
				brk = ( i && (find_range_brk( linfo2->pc, (linfo2+1)->pc )) ) ? SOURCE_BRK_CHAR : 0;
				linfo2++;
				}
			smart_line(*line2++,lnum++,flag);
			if (brk)
				*linebuf=brk;
			wprint_line(w,linebuf,TRUE);
		}
		}
		
	return TRUE;
	
}


/* called after first breakpoint into program to maybe hack window 2 */
void just_started(void)
{
struct ws *wptr;
word front;
word x,y,w,h;

#if PANIC
	safe_print("JUST_STARTED\n");
#endif	
	if (source_loaded==FALSE)
		return;
#if 0
this line forces main to be compiled with line debug. This is naff.
	if (find_linenumber(regs.pc,&exact,&db,&lnum,NULL)==0)
		return;
#endif
	wptr=wlist[2]; front=frontnum;
	if (wptr->open)
		{
		x=wptr->x; y=wptr->y; w=wptr->w; h=wptr->h;
		close_window(2,TRUE);
		}
	else
		{
		x=30; y=0; w=49; h=21;
		}
	open_window(2,x,y,w,h,NULL,WTYPE_SMART);

	/* no checks needed on whether this works or not */

	/* restore previous front window */
	if (wlist[front]->open)
		front_window(wlist[front]);

	/* rest of init will be performed by the mayrefill */

}

static char **smart_help_list;

void init_source(void)
{
char *path;

	if (maxfiles<5)
		maxfiles=5;
	if (maxfiles>500)
		maxfiles=500;			/* limit to sane values */

	if ( (flist=getzmem(maxfiles*sizeof(fileinfo*)))==NULL)
		finish(RET_NOMEM);
	if ( (dblist=getzmem(maxfiles*sizeof(struct dbfile*)))==NULL)
		finish(RET_NOMEM);
	if ((smart_help_list=(char**)getmem(maxfiles*sizeof(char *)))==NULL)
		finish(RET_NOMEM);

	add_reserved_sym("sourcetab",&sourcetabsize,EXPR_WORD,alter_nothing);
	/* RSN special alter code to redraw smart windows */
	
	if ( (path=getenv("SOURCE_PATH")) && path[0] )
		strcpy(sourcepath,path);
	else
		sourcepath[0]=0;
}


/* go one line up/down, return TRUE if redraw required */
/* one function for each mode */

bool updown_asm(bool up, struct smartw *sm)
{
ulong pc; bool exact;
	pc=sm->toppc;
	if (up)
		pc=backdiss(pc,&exact);
	else
		pc=diss(pc,FALSE);
	sm->toppc=pc;
	return TRUE;
}

bool updown_mixed(bool up, struct smartw *sm)
{
struct linfo *linfo2;
char **line2;
uword lnum,subline;
ulong pc;
bool exact;

	lnum=sm->topline;
	pc=sm->toppc;
	subline=0;
	linfo2=sm->linfo; line2=sm->line;
	if (up)
		{
		/* backwards is a bit of a bastard */
		if (linfo2==sm->file->linelist)
			{
			/* we're at the start of the structure */
			if (sm->topline>1)
				{
				sm->topline--;
				sm->line--;
				return TRUE;
				}
			else
				return FALSE;					/* dont go off top world */
			}
		if (pc==linfo2->pc)
			{
			/* we are on a source line - before us is either another one, or some asm */
			if ( (linfo2-1)->line != (lnum-1) )
				{
				/* go back do a (no-code) source line */
				sm->topline--;
				sm->line--;
				return TRUE;
				}
			}
		/* backwards diss to get the PC, then restart from that */
		pc=backdiss(pc,&exact);
		linfo2--;				/* local copy only */
		if (pc<=linfo2->pc)
			{
			/* we've rewound to a one-line code/source line */
			sm->linfo--; sm->line--;
			sm->topline=linfo2->line;
			sm->toppc=linfo2->pc;
			return TRUE*2;		/* *2 denotes 2 lines */
			}
		/* else we're mid-source line */
		sm->toppc=pc;
		return TRUE;
		}
	else
		{
		/* forwards is easier */
		if (next_mixed( &pc, &linfo2, &line2, &lnum, TRUE, sm, &subline))
			{
			sm->toppc=pc;
			if (subline==0)
				sm->topline=lnum;			/* if onto source line */
			sm->linfo=linfo2; sm->line=line2;
			return TRUE;
			}
		else	
			return FALSE;
		}
}

bool updown_smart(bool up, struct smartw *sm)
{
struct dbfile *db;
long lcount;
struct linfo *linfo;
bool refill;

	refill=FALSE;
	db=sm->file;
	linfo=db->linelist;

	/* find the current line in the linelist */
	lcount=db->linecount;
	while (lcount--)
		{
		if (linfo->line >= sm->topline)
			break;
		linfo++;
		}

	if (up)
		{
		if (sm->topline!=1)
			{
			sm->topline--;
			if (linfo!=db->linelist)		/* if can go backwards */
				{
				linfo--;
				if (linfo->line >= sm->topline)
					sm->toppc=linfo->pc;
				}
			refill=TRUE;
			}
		}
	else /* down */
		{
		if ( (sm->topline+frontwindow->h-2) <=
			flist[sm->file->opened]->linesinfile )
			{
			if (sm->toppc < sm->file->endpc)
				{
				if (sm->topline==linfo->line)		/* down on blank lines does nothing */
					{
					linfo++;
					sm->topline++;
					if (linfo->line >= sm->topline)
						sm->toppc=linfo->pc;
					}
				else
					sm->topline++;					/* as its blank */
				}
			refill=TRUE;
			}
		}

	return refill;
}


bool reload_smart(char *match, word *howmany)
{
word i;char *a,*b,c;
bool add;

	*howmany=0;
	for (i=0; i<maxfiles; i++)
		{
		if (dblist[i])
			{
			add=TRUE;
			if (match)
				{
				a=match; b=dblist[i]->name;
				while (c=*a++)
					{
					if ( c != upper(*b++) )
						{ add=FALSE; break; }
					}
				}
			if (add)
				smart_help_list[(*howmany)++]=dblist[i]->name;
			}
		}
	return TRUE;
}

/* key handler for smart windows - quite a lot of possibilties */
void key_smart(word key)
{
short i;
struct smartw *sm;
struct dbfile *db;
bool refill;
bool (*fn)(bool, struct smartw*);

	auto_numeric(&key);

	if (do_controlkey(key)==TRUE)
		return;

	refill=FALSE;
	sm=(struct smartw*)(frontwindow->magic);
	db=sm->file;

	if (key==KEY_HELP)
		{
		word result;
			{
			reload_smart(NULL, &result);		/* get the max number */
			if (result)
				{
				word err;
				err=do_menu(TX_CHOOSEFILE,30,(word)min(maxh-4,result),smart_help_list,&result,reload_smart,NULL);
				if ( (err) || (result<0) )
					return;
				/* switch to the very top of the required file */
				for (i=0; i<maxfiles; i++)
					if ( dblist[i] &&
						(strcmp(smart_help_list[result],dblist[i]->name)==0) )
						{
						if ( (db!=dblist[i]) || (sm->tmode==SM_ASM) )
							{ /* only if changed files (or was asm mode) */
							window_source_title(frontwindow,dblist[i]);
							sm->file=dblist[i];
							sm->tmode=sm->mode;			/* mode as requested */
							/* sm->topline=1; */
							/* sm->toppc=dblist[i]->startpc; */
							if (mayrefill_smart(wlist[frontwindow->number],dblist[i]->startpc,TRUE))
								refill_window((word)(frontwindow->number),TRUE);
							}
						break;
						}
				}
			}
		return;
		}

	switch (sm->tmode)
		{
		case SM_SOURCE: fn=updown_smart; break;
		case SM_ASM: fn=updown_asm; break;
		case SM_MIXED: fn=updown_mixed; break;
		default: return;
		}	

	if ( (key&0xFF)==' ')
		key=KEY_PAGEDOWN;

	i=frontwindow->h-3;		/* lines/page -1 */

	switch (key)
		{
		bool res;
		case KEY_UP:
			refill=(fn)(TRUE,sm);
			break;
		case KEY_DOWN:
			refill=(fn)(FALSE,sm);
			break;
		case KEY_PAGEUP:
			if (refill=(fn)(TRUE,sm))
				{
				if (refill==TRUE*2)
					i--;
				while ( i-- > 0 )
					{
					res=(fn)(TRUE,sm);
					if (res==FALSE)
						break;
					if (res==TRUE*2)
						i--;					/* special double-line handler */
					}
				}
			break;
		case KEY_PAGEDOWN:
			if (refill=(fn)(FALSE,sm))
				while (i--)
					if ((fn)(FALSE,sm)==FALSE)
						break;
			break;
		case KEY_LEFT:
			if (sm->tmode==SM_ASM)
				{
				sm->toppc-=2;
				refill=TRUE;
				}
			break;
		case KEY_RIGHT:
			if (sm->tmode==SM_ASM)
				{
				sm->toppc+=2;
				refill=TRUE;
				}
			break;
		}

	/* all calced, now slowly redraw */
	/* NOTE: we do not do a mayrefill, so the handlers must do
		all the nitty gritty of the work */

	if (refill)
		{
		frontwindow->wlong=sm->toppc;
		window_cls(frontwindow);
		refill_smart(frontwindow);
		update_contents(frontwindow);
		}
}

/* Smart search code. Window is open and smart, return TRUE if OK */
bool smart_search(word wnum,char *match,byte len)
{
struct smartw *sm;
fileinfo *f;
struct linfo *linfo;
char **line;
struct ws *w;
uword lnum;

	w=wlist[wnum];
	sm=(struct smartw*)(w->magic);
	if (sm->mode==SM_ASM)
		return FALSE;						/* we can only cope with SOURCE or MIXED */

	f=flist[sm->file->opened];
	lnum=sm->topline+1;						/* start on second line */
	if ( (lnum==0) || (lnum>f->linesinfile) )
		goto no;

	match[len]=0;							/* turn into C string */

	calc_linfo( lnum, &linfo, &line, sm);
	while (lnum<=f->linesinfile)
		{
		if (strstr(*line++,match))
			{
			/* set the addr to be that particular line */
			sm->tmode=SM_SOURCE;
			sm->topline=lnum;
			sm->toppc=linfo->pc;
			w->wlong=sm->toppc;
			window_cls(w);
			refill_smart(w);
			update_contents(w);
			return TRUE;
			}
		if (linfo->line==lnum)
			linfo++;
		lnum++;
		}

no:	safe_print(TX_NOTFOUND);
	return TRUE;
}
