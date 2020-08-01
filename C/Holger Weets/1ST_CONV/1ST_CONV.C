#line 1/*ACE 4 0693 */

extern void *malloc();
extern char *suffix(), *basename(), *strdup();

typedef struct flist {
	char            *file;
	char            *name;
	char            *title;
	int             flags;
	struct flist    *next;
} FLIST;

typedef struct {
	unsigned version;
	unsigned headlen;
	unsigned nplanes;
	unsigned patlen;
	unsigned pixelw;
	unsigned pixelh;
	unsigned linew;
	unsigned lines;
	unsigned palette[16];
} IMGHEADER;

typedef unsigned char   uchar;
typedef unsigned int    uint;

extern long gemdos();
#define  Cconws(s)          gemdos(9,s)
#define  Dsetdrv(d)         gemdos(14,d)
#define  Dsetpath(path)     gemdos(59,path)
#define  Fcreate(fn,mode)   gemdos(60,fn,mode)
#define  Fopen(fn,mode)     gemdos(61,fn,mode)
#define  Fclose(h)          gemdos(62,h)
#define  Fread(h,cnt,buf)   gemdos(63,h,cnt,buf)
#define  Fwrite(h,cnt,buf)  gemdos(64,h,cnt,buf)
#define  Fseek(where,h,how) gemdos(66,where,h,how)
#define NL  "\r\n"

FLIST   *FBase = 0L;        // Basis der Dateiliste
int     inhandle;           // Handle der aktuellen Eingabedatei
uchar   inbuf[4096];        // Dateibuffer fuer Eingabe
uchar   *inptr;
long    inlen;
uchar   inpath[128];        // Pfad der Eingabedatei
uchar   mainpath[128];      // Pfad der Hauptdatei
int     outhandle;          // Handle der Ausgabedatei
uchar   outbuf[4096];       // Dateibuffer fuer Ausgabe
uchar   *outptr;
uint    maxlines;
uint    Lineno;
uchar   output[128];        // Name der Ausgabedatei
int     ExtCnt;
int     NeedNL;             // vor Warnung NL ausgeben
int     use_filenames;      // Dateinamen als nodenamen nutzen
int     code;
int     quiet;
int     NoAuto;
char    *CurrFile;

/*
 * Fehler melden und terminieren
 */
Message(str1, str2)
char *str1, *str2;
{
	Cconws(str1);
	if (str2) Cconws(str2);
	Cconws(NL);
}


error(s1, s2)
char *s1, *s2;
{
	Message(s1, s2);
	if (outhandle) Fclose(outhandle);
	if (inhandle) Fclose(inhandle);
	_exit(1);
}


/*
 * Ausgabedatei oeffnen
 */
Wopen(char *outfile)
{
	if ((outhandle=Fcreate(outfile, 0)) > 5)
		outptr = outbuf;
	else
		error("can't open ", outfile);
	Lineno = 0;
}


/*
 * Datei zum Lesen oeffnen
 */
Ropen()
{
	register FLIST  *p;
	register char   *suf;
	char            tmp[150];

again:
	p = FBase;
	while (p) {
		if (p->flags==0) break;         // ersten suchen, der noch
		p = p->next;                    // nicht gelesen wurde
	}
	if (p == 0L) return(0);             // Ende der Liste erreicht
	p->flags = 1;                       // als gelesen markieren

	strcpy(inpath, p->file);            // Pfad der Eingabe merken
	*basename(inpath) = 0;
	if (*inpath == 0)
		strcpy(inpath, mainpath);

	if ((inhandle=Fopen(p->file, 0))<5) // Datei oeffnen
		error("can't open ", p->file);

	CurrFile = p->file;
	if (quiet==0) {
		Cconws("reading ");
		Cconws(p->file);
		Cconws("\033K\r");
		NeedNL = 1;
	}

	if (p == FBase) {                       // erste Datei?
		fputs("@options \"+xz -s");
		if (NoAuto) fputs("a");
		fputs("\"" NL NL);
	}

	fputs("@node \"");                      // Name der Seite
	strcpy(tmp, p->name);
	ConvKey(tmp);
	fputs(tmp);
	fputs("\"");
	if (p->title) {                         // evtl. Titel
		fputs(" \"");
		strcpy(tmp, p->title);
		ConvKey(tmp);
		fputs(tmp);
		fputs("\"");
	}
	fputs(NL);

	if (p == FBase) {
		strcpy(tmp, basename(p->file));
		*suffix(tmp) = 0;
		fputs("@symbol r \"");
		ConvKey(tmp);
		fputs(tmp);
		fputs("\"" NL);
	}


	inlen = -1;
	inptr = inbuf;                      // Lesezeiger init.

	/*
	 * wenn es ein Bild ist, das der HCP lesen kann,
	 * dann binden wir es ein
	 */
	suf = suffix(p->file);
	if (strcmp(suf, ".IMG") == 0) {
		ImagePage(p);
		goto again;
	}

	return(1);                          // OK
}


/*
 > INF-Datei fr aktuellen 1stGuide-Text lesen
 */
OpenINF(char *path)
{
	char    line[128];

	strcpy(line, path);
	strcpy(suffix(line), ".prj");
	if ((inhandle=Fopen(line, 0)) > 0) {
		inlen = -1;
		inptr = inbuf;                      // Lesezeiger init.
		while (fgets(line)) {
			fputs(line);
			fputs(NL);
		}
		xclose(inhandle);
	}
}


/*
 * Datei schliessen, dabei evtl. Buffer flushen
 */
xclose(handle)
int handle;
{
	long len;

	if (handle == outhandle) {
		len = (long)(outptr-outbuf);
		if (len) {
			if (Fwrite(handle, len, outbuf) != len)
				error("write error", 0L);
		}
	}

	Fclose(handle);
}


int fgets(line)
register uchar *line;
{
	register uchar  *p = inptr;
	int             rv = 1, cnt=0;

	do {
		if (inlen <= 0L) {
			inlen = Fread(inhandle, 4096L, inbuf);
			if (inlen < 0L)                 // Fehler?
				error("read error", 0L);

			if (inlen == 0L) {              // nix gelesen?
				rv = 0;                     // DateiEnde
				break;
			}
			inptr = p = inbuf;
		}
		if (*p == 10) {             // NL
			--inlen;
			++p;
			break;
		}

		if (*p != 13) {             // CR nicht kopieren
			*line++ = *p;
			++cnt;
		}

		--inlen;                    // einer weniger
		++p;
	} while (cnt<255);

	*line = 0;                      // Zeile abschliessen
	inptr = p;                      // Pos. naechstes Zeichen
	return(rv||cnt);                // und fertig
}


fputs(line)
register uchar  *line;
{
	register uchar  *p = outptr;

	while (*line) {
		if (*line == '\n') ++Lineno;
		if ( (long)(p-outbuf) == 4096L) {
			if (Fwrite(outhandle, 4096L, outbuf) != 4096L)
				error("write error", 0L);
			p = outptr = outbuf;
		}
		*p++ = *line++;
	}
	outptr = p;
}


/*******************************************************************/

/*
 * Seitenende erzeugen
 * Falls Datei zu lang, neue erzeugen
 */
EndNode()
{
	char    file[128];

	fputs("@endnode" NL NL NL);
	xclose(inhandle);                   // Eingabe schliessen

	if (maxlines && Lineno>maxlines) {
		strcpy(file, output);
		itoa(++ExtCnt, suffix(file)+1, 10);
		xclose(outhandle);
		Wopen(file);
	}
}


ImagePage(p)
FLIST   *p;
{
	IMGHEADER   *img = (IMGHEADER *)inbuf;
	uchar       *str = inbuf+100;
	int         cnt;

	Fread(inhandle, (long)sizeof(IMGHEADER), img);
	cnt = (img->lines+15)/16;
	fputs("@image ");
	fputs(p->file);
	fputs(" 1 ");
	ltoa((long)((img->linew+7)/8), str, 10);    // Breite in Zeichen
	fputs(str);
	fputs(" ");
	ltoa((long)cnt, str, 10);                   // H”he in Zeichen
	fputs(str);
	fputs(NL);

	EndNode();
}

char *Find(char *key)
{
	register FLIST  *p;

	p = FBase;
	while (p) {
		if (strcmp(p->name, key)==0)
			return(0);
		p = p->next;
	}
	return(1);
}


char *GetName(name, key)
char    *name, *key;
{
	char buf[20], *rv;

	/*
	 * wenn gwnscht, dann immer den Dateinamen als
	 * Seitennamen verwenden
	 */
	if (use_filenames) {
		rv = name;
		goto ende;
	}

	if (Find(key)) {                    // suchen nach Titel
		rv = key;
	}
	else {
		strcpy(buf, basename(name));
		*suffix(buf) = 0;
		if (Find(buf))                  // Datei ohne Endung
			rv = buf;
		else {
			strcpy(buf, basename(name));
			if (Find(buf))              // Datei mit Endung
				rv = buf;
			else {
				rv = name;
			}
		}
	}
ende:
	return(strdup(rv));
}


/*
 * Neuen Dateinamen an die Liste zu lesender
 * Dateien anhaengen, falls sie noch nicht ex.
 */
FLIST *AddFile(name, key)
char    *name, *key;
{
	register FLIST  *p = FBase, *last = p;

	while (p) {
		if (strcmp(p->file, name) == 0) return(p);
		last = p;
		p = p->next;
	}
	p = malloc(sizeof(FLIST));
	if (p == 0L)                    // Fehler
		error("out of memory", 0L);
	p->name = GetName(name, key);
	p->file = strdup(name);         // Namen kopieren
	if (strcmp(p->name, key)) {     // wenn nodename != key
		p->title = strdup(key);     // dann key als Titel nehmen
	}
	else
		p->title = 0L;
	p->flags = 0;                   // noch nicht gelesen
	p->next = 0L;                   // immer der letzte

	if (last) {
		last->next = p;
	}
	else {                          // erstes Element
		FBase = p;
	}
	return(p);
}

/**********************************************************/

#define IS_ASCII    1
#define NO_TYPE     2

int FileType(file, key)
char    *file, *key;
{
	char            path[128];
	register char   *p, *save;
	int             h;
	FLIST           *q;

	/*
	 * Dateinamen in Grožbuchstaben wandeln
	 * und Pfad erg„nzen.
	 */
	strupr(file);
	strcpy(path, inpath);
	strcat(path, file);

	/*
	 * Der Pfad k”nnte '..' Teile enthalten, wegen
	 * des Vergleiches der Namen l”schen wir diese
	 * Teile
	 */
again:
	p = path;
	save = p;
	while (*p) {
		if (*p == '\\') {
			if (p[1] == '.' && p[2] == '.') {
				h = *save == '\\' ? 3 : 4;
				strcpy(save, p+h);
				goto again;
			}
			save = p;   // letzter Slash
		}
		++p;
	}

	/*
	 * damit die Datei nicht so lang wird, schneiden
	 * wir den Pfad jetzt noch so weit ab, dass er relativ
	 * zur Hauptdatei ist
	 */
	save = (char *)mainpath;
	p = path;
	while (*p == *save) {
		++p;
		++save;
	}

	strcpy(file, p);
	p = suffix(file);

	/*
	 * mal sehen, ob es sich um einen der vom 1stView
	 * untersttzten Dateitypen handelt...
	 * Wenn ja, dann kann der Compiler damit nichts
	 * anfangen (keine ASCII-Datei) und wir liefern
	 * NO_TYPE
	 */
	if (   strcmp(p, ".RSC") == 0
		|| strcmp(p, ".GEM") == 0
		|| strcmp(p, ".SAM") == 0
		|| strcmp(p, ".SND") == 0
		|| strcmp(p, ".OUT") == 0
		|| strcmp(p, ".DOK") == 0
		|| strcmp(p, ".AVR") == 0
//-         || strcmp(p, ".IMG") == 0
		|| strcmp(p, ".IFF") == 0
		)
		return(NO_TYPE);

	/*
	 * ...dann ist es wohl eine ASCII-Datei;
	 * in diesem Fall wollen wir sie nachher noch lesen,
	 * also kommt sie in die Liste, falls sie ge”ffnet
	 * werden kann
	 */
	if ((h=Fopen(file, 0))>0)
		Fclose(h);
	else {
		if (NeedNL) {
			Cconws(NL);
			NeedNL = 0;
		}
		Cconws("*** warning in '");
		Cconws(CurrFile);
		Message("': missing file ", file);
		code = 2;
		return(NO_TYPE);
	}

	q = AddFile(file, key);
	strcpy(file, q->name);
	return(IS_ASCII);
}


/*
 * Sichtbaren Verweis konvertieren
 */
int ConvKey(key)
char *key;
{
	char    buf[100];
	register char   *src = key, *dst = buf;
	int             rv=1;

	if (*src == '@' || NoAuto) rv=0;      // link erzwingen

	while (*src) {
		if (*src == '"' || *src == '\\') {
			*dst++ = '\\';
			rv=0;
		}
		*dst++ = *src++;
	}
	*dst = 0;
	strcpy(key, buf);
	return(rv);
}


int HasBlanks(p)
register char *p;
{
	while (*p) {
		if (*p == ' ') return(1);
		++p;
	}
	return(0);
}

DoList()
{
	uchar           line[255], buf[512], file[128], key[100];
	register uchar  *src, *dst, *p;
	uchar           *save;
	int             cnt;

	while (Ropen()) {                       // ueber alle Dateien
again:
		while (fgets(line)) {               // alle Zeilen
			src = line;
			while (*src) {
				/*
				 * 28: streckendes Leerzeichen
				 * 29: Einzugsleerzeichen
				 * 30: variables Leerzeichen
				 */
				if (*src>=28 && *src <=30)
					*src = ' ';
				++src;
			}
			src = line;
			dst = buf;

			/*
			 * falls die Zeile ein Infoblock ist, dann
			 * ignorieren wir sie einfach
			 */
			if (*src == 0x1F) goto again;

			/*
			 * falls am Anfang ein Kommentarzeichen steht,
			 * rcken wir es einfach ein, damit der Compiler
			 * es ignoriert
			 */
			if (*src == '#' && src[1] == '#')
				*dst++ = ' ';

			while (*src) {                  // alle Zeichen
				switch (*src) {
//-                     case 0x1C:              // streckendes Leerzeichen
//-                     case 0x1D:              // Einzugsleerzeichen
//-                     case 0x1E:              // variables Leerzeichen
//-                         *dst++ = ' ';
//-                         ++src;
//-                         break;
					case 27:
						++src;
						if (*src>=0x80) {
							*dst++ = '@';
							*dst++ = '{';
							*src -= 0x80;
							if (*src==0)    *dst++ = '0';   // alles aus
							if (*src & 1)   *dst++ = 'B';   // Fett
							if (*src & 2)   *dst++ = 'G';   // Hell
							if (*src & 4)   *dst++ = 'I';   // Kursiv
							if (*src & 8)   *dst++ = 'U';   // Underlined
							*dst++ = '}';
						}
						else {
							*dst++ = 27;
							*dst++ = *src;
						}
						++src;
						break;
					case '@':
						*dst++ = '@';
						/* fall thru */
					default:
						*dst++ = *src++;
						break;
					case 'Ý':
						p = key;
						cnt=0;
						save = dst;
						do {
							*dst++ = *src++;
							if (*src == 'Ý') {
								*p = 0;
								if (cnt==1) {
									++src;
									break;
								}
								else {
									p = file;
									*dst++ = *src++;
								}
								++cnt;
							}
							if (*src == 0) goto more;
							*p++ = *src;
						} while (1);
						dst = save;
						if (FileType(file, key) != IS_ASCII)
							p = (uchar *)"\\Main";
						else {
							p = 0L;
							cnt = ConvKey(key);
							/*
							 * falls der Autoreferenzer diese
							 * Stelle auch alleine findet, lassen
							 * wir ihn das machen
							 */
							if (cnt && *src < '0' && dst[-1] < '0'
								&& (HasBlanks(file)==0)
								&& strcmp(key, file) == 0) {
								strcpy(dst, key);
								while (*dst++);
								--dst;
								break;
							}
						}
						*dst++ = '@';
						*dst++ = '{';
						*dst++ = '"';
						strcpy(dst, key);
						while (*dst++);
						--dst;
						strcpy(dst, "\" link ");
						dst += 7;
						ConvKey(file);
						*dst++ = '"';
						strcpy(dst, file);
						while (*dst++);
						--dst;
						if (p) {
							strcpy(dst, p);
							while (*dst++);
							--dst;
						}
						*dst++ = '"';
						*dst++ = '}';
						break;
				}
			}
more:
			*dst=0;
			fputs(buf);
			fputs(NL);
		}
		EndNode();
	}
}


AddIncludes()
{
	char    buf[128];
	int     i;

	strcpy(buf, output);
	outhandle = Fopen(buf, 1);
	outptr = outbuf;
	Fseek(0L, outhandle, 2);

	for (i=1; i<=ExtCnt; i++) {
		strcpy(buf, output);
		itoa(i, suffix(buf)+1, 10);
		fputs(NL "@include ");
		fputs(buf);
	}
	fputs(NL);
	xclose(outhandle);
}



/**************************************************************/

extern int  _argc;
extern char **_argv;
_main()
{
	main(_argc, _argv);
}


main(argc, argv)
int argc;
char **argv;
{
	char            outfile[128];
	register char   *p;
	int             save;

	maxlines = 0;

	if (argc < 2) {
		error("usage: 1stConv [-NNN -f -q -a] file" NL
			  "       -NNN: max lines per file" NL
			  "       -f  : use filenames as nodenames" NL
			  "       -q  : be quiet" NL
			  "       -a  : explicit links only" NL
			  , 0L);
		_exit(1);
	}

	save = 0;
	do {
		++argv;
		--argc;
		if (**argv == '-') {
			p = *argv+1;
			if (*p == 'f') {
				save = 1;
			}
			else if (*p == 'q')
				++quiet;
			else if (*p == 'a')
				++NoAuto;
			else
				maxlines = atoi(p);
		}
		else {
			if (quiet==0) {
				Message("1stConv: V(" __DATE__ ") 1stGuide --> ST-Guide sources" NL
						"         Written by Holger Weets using SOZOBON-C V2.00x10" NL
						, 0L);
			}

			/*
			 * Ausgabedatei bestimmen
			 */
			strupr(*argv);                      // falls aus CLI
			strcpy(outfile, *argv);
			AddFile(basename(outfile), "Main"); // nur Dateinamen eintragen
			use_filenames = save;
			p = (char *)mainpath;               // Pfad merken
			strcpy(p, outfile);
			*basename(p) = 0;

			/*
			 * wir setzen das Verzeichnis der Hauptdatei
			 * als aktuelles Verzeichnis, damit die Pfade
			 * relativ angegeben werden k”nnen und somit
			 * die Ausgabedatei krzer und transportabler
			 * wird.
			 */
			if (p[1] == ':')
				Dsetdrv(*p-'A');
			Dsetpath(p);

			strcpy(suffix(outfile), ".stg");
			Wopen(outfile);
			OpenINF(outfile);
			strcpy(output, outfile);
			ExtCnt=0;
			DoList();
			xclose(outhandle);

			if (ExtCnt) AddIncludes();

			if (NeedNL) Cconws(NL);
			break;
		}
	} while (argc>1);
	_exit(code);
}





