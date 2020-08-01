#line 1/*ACE 4 0344 */

extern char *suffix(), *strupr(), *strdup();
extern void *malloc();
typedef unsigned char uchar;
typedef unsigned int uint;

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

int     inhandle;           // Handle der aktuellen Eingabedatei
uchar   inbuf[8192];        // Dateibuffer fuer Eingabe
uchar   *inptr;
long    inlen;
int     outhandle;          // Handle der Ausgabedatei
uchar   outbuf[4096];       // Dateibuffer fuer Ausgabe
uchar   *outptr;
int     Autoref = 1;        // Autoreferenzer machen lassen
int     NewFormat;          // 1: recompiliert durch HELPDISC
uint    maxlines = 0;
int     HasExternals;       // Anzahl externe Referenzen
uint    Line;               // Zeilennummer der Ausgabe
uint    total;              // Anzahl Ausgabezeilen
int     ExtCnt;             // Z„hler fr Extensions
long    Syms;               // Anzahl nodes/alabels
char    outfile[128];       // Name der ursprnglichen Ausgabedatei
char    *ExtPage;


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
	Cconws(NL);
	Message(s1, s2);
	if (outhandle>0) Fclose(outhandle);
	if (inhandle>0) Fclose(inhandle);
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
		error("can't open outfile", 0L);
	Line = 0;
}


/*
 * Datei zum Lesen oeffnen
 */
Ropen(char *file)
{
	if ((inhandle=Fopen(file, 0))<5) // Datei oeffnen
		error("can't open ", file);

	fputs("@options -s");               // kein Zeilenumbruch
	if (!Autoref) fputs("a");           // kein Autoreferenzer
	if (NewFormat) fputs("n");          // "pageN" nicht in Index
	fputs(NL NL);
	fputs("@node Main" NL
		  " Dieser Text wurde automatisch in das ST-Guide Format" NL
		  " konvertiert. Auf dieser Seite sollte eigentlich ein" NL
		  " Inhaltsverzeichnis stehen..." NL
		  "@endnode" NL
		 );

	inlen = -1;
	inptr = inbuf;                      // Lesezeiger init.
}


/*
 * Datei schliessen, dabei evtl. Buffer flushen
 */
xclose(handle)
int handle;
{
	long len;

	if (handle == outhandle) {
		if (outptr != outbuf) {
			len = (long)(outptr-outbuf);
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
			inlen = Fread(inhandle, 8192L, inbuf);
			Cconws(".");
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
		if (*line == '\n') ++Line;
		if ( (long)(p-outbuf) == 4096L) {
			if (Fwrite(outhandle, 4096L, outbuf) != 4096L)
				error("Write error", 0L);
			p = outptr = outbuf;
		}
		*p++ = *line++;
	}
	outptr = p;
}


KonvKey(buf)
register uchar  *buf;
{
	if (strcmp(buf, "Copyright") == 0)
		strcpy(buf, "Help");
	else if (strcmp(buf, "Help") == 0)
		strcpy(buf, "Help 2");
	else if (strcmp(buf, "Main") == 0)
		strcpy(buf, "main 2");
}


uchar *GetName(src, buf)
register uchar  *src;
uchar           *buf;
{
	register uchar  *dst = buf;

	while (*src && *src != '"') ++src;          // Anfang <node>
	++src;
	do {
		*dst++ = *src++;
		if (dst[-1] == '\\')                    // maskiertes Zeichen
			*dst++ = *src++;
	} while (*src && *src != '"');              // Ende <node>
	*dst = 0;
	KonvKey(buf);
	return(++src);
}


NewPage(uchar *line)
{
	uchar           buf[255];
	register uchar  *src = line;
	int             cnt;

	src = GetName(src+7, buf);

	if (!NewFormat && strcmp(buf, "Index") == 0) {      // dieser Index ist
		while (fgets(line)) {                           // Bl”dsinn
			if (strncmp(line, "\\end", 4) == 0) break;
		}
		return;
	}
	fputs("@node \"");
	fputs(buf);
	fputs("\"");
	if (NewFormat)
		cnt=0;
	else {
		fputs(NL);
		cnt=1;
	}

again:
	++Syms;
	while (*src) {
		if (*src == ',') {
			if (NewFormat==0) {
				fgets(line);
				src = line;
			}
			src = GetName(src, buf);
			if (cnt++ == 0) {
				fputs(" \"");
				fputs(buf);
				fputs("\"" NL);
			}
			fputs("@symbol \"");
			fputs(buf);
			fputs("\"" NL);
			goto again;
		}
		++src;
	}
	if (cnt==0) fputs(NL);
}


uchar *MakeLink(dst, node, key)
register uchar  *dst;
uchar           *node, *key;
{
	strcpy(dst, "@{\"");
	strcat(dst, node);
	strcat(dst, "\" link \"");
	strcat(dst, key);
	strcat(dst, "\"}");
	while (*dst++);
	return(--dst);
}


EndNode()
{
	char buf[128];

	fputs("@endnode" NL NL);
	if (maxlines && Line>maxlines) {
		strcpy(buf, outfile);
		itoa(ExtCnt++, suffix(buf)+1, 10);
		xclose(outhandle);
		total += Line;
		Wopen(buf);
		Cconws(NL);
		Cconws(" --> ");
		Cconws(buf);
		Cconws(NL);
	}
}


ConvLine(uchar *buf)
{
	uchar           line[255], alias[80];
	register uchar  *src = buf, *dst = line;
	uchar           *key;
	int             EndFlag=0;

	while (*src) {
		if (*src == '\\') {
			if (src[1] == '\\') {
				*dst++ = *src++;
				goto copy;
			}
			if (src[1] == '#') {
				src += 2;
				key = src;
				while (*src) {
					if (*src == '\\' && src[1] == '#') break;
					++src;
				}
				if (*src == 0) {
					Message(NL "-> ", buf);
					error("syntax error.", 0L);
				}
				*src = 0;
				strcpy(alias, key);
				KonvKey(alias);
				if (strcmp(key, alias) == 0 && Autoref) {
					/*
					 * das Link lassen wir vom Autoreferenzer
					 * machen
					 */
					strcpy(dst, alias);
					while (*dst++);
					--dst;
				}
				else {
					dst = MakeLink(dst, key, alias);
				}
				*src = '\\';
				src += 2;
			}
			else if (strncmp(src+1, "link", 4) == 0) {
				/*
				 * \link ("<node>")<text>\#
				 */
				src = GetName(src+4, alias);    // <node> holen
				while (*src++ != ')');          // Anfang <text>
				key = src;                      // merken
				while (*src) {
					if (*src == '\\' && src[1] == '#') {
						*src = 0;
						if (strcmp(alias, ExtPage) == 0)
							++HasExternals;
						dst = MakeLink(dst, key, alias);
						*src = '\\';
						src += 2;
						break;
					}
					++src;
				}
			}
			else if (strncmp(src+1, "end", 3) == 0) {
				if (NewFormat)
					EndFlag=1;
				else
					EndNode();
				goto ende;
			}
			else
				*dst++ = *src++;        // Backslash kopieren
		}
		else if (*src == '@') {         // schon maskieren
			*dst++ = '@';
			goto copy;
		}
		else
copy:
			*dst++ = *src++;
	}
ende:
	*dst++ = 13;
	*dst++ = 10;
	*dst = 0;
	fputs(line);
	if (EndFlag) EndNode();
}


AddIncludes(file, cnt)
char    *file;
int     cnt;
{
	char    buf[128];
	int     i;

	strcpy(buf, file);
	strcpy(suffix(buf), ".STG");
	outhandle = Fopen(buf, 1);
	outptr = outbuf;
	Fseek(0L, outhandle, 2);

	for (i=0; i<cnt; i++) {
		strcpy(buf, file);
		itoa(i, suffix(buf)+1, 10);
		fputs(NL "@include ");
		fputs(buf);
	}
	fputs(NL);
	xclose(outhandle);
}


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
	char    buf[255], *p;
	int     val;

	Message("PC-Conv V(" __DATE__ "): PureC-Help --> ST-Guide sources" NL
			"        Written by Holger Weets using SOZOBON-C V2.00x10" NL
			, 0L);

	if (argc < 2) {
error:
		Cconws("usage: PC-Conv [+-anmN] file1 [file2 ...]" NL
			   "       a: explicit (-) or automatic (+) links" NL
			   "       n: HELP_RC (-) or new HELPDISC (+) format" NL
			   "       mN: max N lines per output file" NL
			   "       <fileN> must be ASCII" NL
			  );
		_exit(1);
	}

	/*
	 * Ausgabedatei bestimmen
	 */
	do {
		++argv;
		strupr(p = *argv);                  // falls aus CLI
		if (*p == '-' || *p == '+') {
			do {
				switch (*p) {
					case '+':   val = 1;                break;
					case '-':   val = 0;                break;
					case 'A':   Autoref = val;          break;
					case 'M':   maxlines = atoi(p+1);   goto next;
					case 'N':   NewFormat = val;        break;
					default:    goto error;
				}
				++p;
			} while (*p);
next:
		}
		else {
			strcpy(buf, p);
			strcpy(suffix(buf), ".STG");

			Cconws(NL);
			Cconws(p);
			Cconws(" --> ");
			Cconws(buf);
			Cconws(NL);

			Wopen(buf);
			strcpy(outfile, buf);
			if (NewFormat)
				ExtPage = "page-1";
			else
				ExtPage = "%%GLOBAL%%";
			ExtCnt=0;
			total = 0;
			Syms=0;
			HasExternals = 0;
			Ropen(*argv);
			while (fgets(buf)) {
				if (strncmp(buf, "screen", 6) == 0)
					NewPage(buf);
				else
					ConvLine(buf);
			}
			ltoa(Syms, buf, 10);
			Message(NL "total symbols      : ", buf);
			if (HasExternals) {
				itoa(HasExternals, buf, 10);
				Message("external references: ", buf);
				fputs("@node \"");
				fputs(ExtPage);
				fputs("\"" NL
					  " Referenz zu externer Datei." NL
					  " Bitte von Hand vervollst„ndigen." NL
					  "@endnode" NL NL
					 );
			}
			total += Line;
			itoa(total, buf, 10);
			Message("total lines        : ", buf);
			xclose(inhandle);
			xclose(outhandle);
			if (ExtCnt) {
				AddIncludes(*argv, ExtCnt);
			}
		}
	} while (--argc>1);
	_exit(0);
}





