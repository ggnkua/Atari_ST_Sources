#line 1/*ACE 4 0074 */

extern long gemdos();

#define  Cconws(s)         gemdos(9,s)
#define  Fwrite(h,cnt,buf) gemdos(64,h,cnt,buf)
#define  Fcreate(fn,mode)  gemdos(60,fn,mode)
#define  Fclose(h)         gemdos(62,h)

typedef struct {
   char d_reserved[21];    /* reserviert */
   char d_attrib;          /* Datei-Attribut */
   int  d_time;            /* Uhrzeit */
   int  d_date;            /* Datum */
   long d_length;          /* Datei-L„nge */
   char d_fname[14];       /* Dateiname */
} DTA;
#define  Fsetdta(dta)               gemdos(26,dta)
#define  Fgetdta()                  (DTA *)gemdos(47)
#define  Fsfirst(filespec,attr)     gemdos(78,filespec,attr)
#define  Fsnext()                   gemdos(79)

#define NL "\r\n"
extern char *getenv(), *suffix();
extern void *malloc();

typedef struct {
	char dir[14];       // so heižt der Ordner
	char desc[26];      // diese Bedeutung haben die Dateien
	char suff[6];       // Suffix, z.B. '(1M)'
	char flags;         // ham wir oder ham wir nicht
} CAT;

CAT cat[] = {
	"CAT1M", "Mupfelinterne Kommandos", "(1M)", 0,
	"CAT1", "Benutzerkommandos", "(1)", 0,          // user commands
	"CAT2", "System Funktionen", "(2)", 0,          // system calls
	"CAT3", "Unterfunktionen", "(3)", 0,            // subroutines
	"CAT4", "Ger„te(treiber)", "(4)", 0,            // devices
	"CAT5", "Dateiformate", "(5)", 0,               // file formats
	"CAT6", "Spiele", "(6)", 0,                     // games
	"CAT7", "Sonstiges (Misc)", "(7)", 0,           // miscellaneous
	"CAT8", "Systemverwaltung", "(8)", 0,           // system administration
	"CATN", "Neuigkeiten", "(N)", 0                 // news
};
#define CATCNT 10

typedef struct _FILES {
	char            file[14];
	char            node[14];
	int             flags;
	struct _FILES   *next;
} FILES;

FILES *base;

typedef struct _NAMES {
	char            name[14];
	struct _NAMES   *next;
} NAMES;

NAMES *names;

int handle;
DTA new;

fputs(char *str)
{
	Fwrite(handle, (long)strlen(str), str);
}


/*
 > Datei in die Liste einsortieren
 */
FILES *AddFile(char *file)
{
	register FILES *new = malloc(sizeof(FILES));
	register FILES *p;

	if (new==0L) {
		Cconws("MAN2STG: out of memory." NL);
		_exit(1);
	}
	strcpy(new->file, file);
	new->flags = 0;

	if (base==0L) {
		base = new;
		new->next = 0L;
	}
	else if (strcmp(base->file, file) > 0) {
		new->next = base;
		base = new;
	}
	else {
		p = base;
		while (p->next) {
			if (strcmp(p->next->file, file) > 0) break;
			p = p->next;
		}
		new->next = p->next;
		p->next = new;
	}

	return(new);
}


/*
 > Mal sehen, ob es den gewnschten Namen bereits gibt
 */
int Nodename(n)
register char *n;
{
	register NAMES *p = names;
	int             rv=0;

	while (p) {
		if (strcmp(p->name, n) == 0) {
			rv = 1;
			break;
		}
		p = p->next;
	}
	if (p==0L) {
		p = malloc(sizeof(NAMES));
		strcpy(p->name, n);
		p->next = names;
		names = p;
	}

	return(rv);
}


/*
 > Fr alle Dateien eines Kapitels
 > jeweils eine node schreiben
 */
AllFiles(CAT *c)
{
	register FILES  *f = base, *n;
	char            line[255], *t;

	while (f) {
		sprintf(line, "@node %s%s@toc %s" NL, f->node, NL, c->dir);
		fputs(line);

		/*
		 * erste Node in der Liste hat keinen Vorg„nger
		 */
		if (f==base) {
			sprintf(line, "@prev %s" NL, f->node);
			fputs(line);
		}

		/*
		 * letzte Node in der Liste hat keinen Nachfolger
		 */
		if (f->next == 0) {
			sprintf(line, "@next %s" NL, f->node);
			fputs(line);
		}

		/*
		 * falls der Nodename der des Kommandos ist, schreiben
		 * wir den direkt, ansonsten muž ein link her
		 */
		if (f->flags==0) {
			sprintf(line, "@symbol %s%s" NL, f->node, c->suff);
		}
		else {
			t = f->node;
			while (*t++ != '(');
			t[-1] = 0;
			sprintf(line, "@symbol RI %s" NL, f->node);
		}
		fputs(line);

		/*
		 * jetzt noch die Datei includen und das Nodeende setzen
		 */
		sprintf(line, "@include %s/%s%s@endnode" NL NL,
				c->dir, f->file, NL);
		fputs(line);
		n = f->next;
		free(f);
		f = n;
	}
	base = 0L;
}


/*
 > Alle Dateien eines Kapitels einlesen
 */
GetFiles(char *path, CAT *c)
{
	int             rv;
	register char   *n;
	FILES           *b;

	rv = Fsfirst(path, 63);
	n = new.d_fname;
	while (rv==0) {
		if (n[0] != '.') {                  // '.' und '..' berlesen
			b = AddFile(n);
			*suffix(n) = 0;
			strlwr(n);
			strcpy(b->node, n);
			if (Nodename(n)) {              // gibts den Namen schon?
				strcat(b->node, c->suff);   // ja: Endung dranh„ngen
				b->flags = 1;               // und merken
			}
		}
		rv = Fsnext();
	}
}


/*
 > Lokales Inhaltsverzeichnis fr ein Kapitel schreiben
 */
Toc(CAT *c)
{
	register FILES *f = base;
	int             cnt, l;
	char            line[128];

	cnt = 0;
	while (f) {
		if (f->flags==0)
			sprintf(line, "%-8s  ", f->node);
		else {
			l = 9-strlen(f->node);

			sprintf(line, "@{%s link %s%s} %*.*s", f->node,
					f->node, c->suff, l, l, "        ");
		}
		fputs(line);
		if (++cnt >= 7) {
			fputs(NL);
			cnt=0;
		}
		f = f->next;
	}
	if (cnt) fputs(NL);
}


_main()
{
	char            *p = getenv("MANPATH");
	register char   *n;
	register CAT    *c;
	char            path[128], line[128];
	DTA             *old;
	int             i, rv, cnt;

	Cconws("MAN2STG V("__DATE__"): manual hypertext creator" NL
		   "        by Holger Weets using SOZOBON-C V2.00x10" NL NL);

	if (p==0L) {
		Cconws("MAN2STG: $MANPATH not set." NL);
		_exit(1);
	}
	strcpy(path, p);
	p = path+strlen(path);
	if (p[-1] != '\\') {
		*p++ = '\\';
		*p = 0;
	}

	strcpy(p, "MAN.STG");
	if ((handle = Fcreate(path, 0))<5) {
		Cconws("MAN2STG: can't open outfile" NL);
		_exit(1);
	}
	Cconws("writing file ");
	Cconws(path);
	Cconws(NL);

	old = Fgetdta();
	Fsetdta(&new);

	fputs("@database Manual-Pages" NL
		  "@subject Dokumentation/Shells" NL
		  "@author \"automatisch erzeugt\"" NL
		  "@options -s+zz" NL NL
		  "@node Main \"Manual-Pages\"" NL NL);
	c = cat;
	for (i=0; i<CATCNT; i++, c++) {
		strcpy(p, c->dir);
		if (Fsfirst(path, 63)==0) {
			c->flags = 1;
			sprintf(line, " %-8s %s" NL, c->dir, c->desc);
			fputs(line);
		}
	}
	fputs("@endnode" NL NL);

	c = cat;
	for (i=0; i<CATCNT; i++, c++) {
		if (c->flags) {
			sprintf(line, "@node %s \"%s\"" NL, c->dir, c->desc);
			fputs(line);
			sprintf(p, "%s\\*.*", c->dir);
			GetFiles(path, c);
			Toc(c);
			fputs("@endnode" NL NL);
			AllFiles(c);
		}
	}
	Fclose(handle);
	Fsetdta(old);
	_exit(0);
}



