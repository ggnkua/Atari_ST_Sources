/* FONTLIST --- in einem TeX-Dokument benutzte Zeichens"atze auflisten
** Copyright (C) 1992 by Anselm Lingnau
**
** Sie d"urfen dieses Programm frei verwenden und weitergeben, solange
** Sie kein Geld damit verdienen oder behaupten, Sie h"atten es
** geschrieben.
**
** Dieses Programm ist `fast' ISO-C-konform, es hat nur eine unportable
** Stelle: eine Implementierung muss fseek(..., ..., SEEK_END) auf
** Bin"ardateien nicht sinnvoll unterst"utzen. Eine Abhilfe besteht
** in schlimmen Notf"allen darin, die Datei komplett zu lesen und dabei
** die Bytes zu z"ahlen (die einzige portable M"oglichkeit, die L"ange
** einer Datei herauszufinden) und dann fseek(..., laenge, SEEK_SET)
** zu sagen. W"urg.
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DVI_ID		2
#define FNT_DEF1	243
#define FNT_DEF4	246

#define MAX_FONT_NAME	511

char *prog_name;

char *fmt = "%F %M", *res = "101", *ext = "scr", *outf = NULL;

FILE *out = stdout;

	void
usage (void)
{
    fputs("FONTLIST --- Auflisten der Zeichens\"atze in einer DVI-Datei\n"
    	"Copyright (C) 1992 by Anselm Lingnau\n\n"
    	"Gebrauch: fontlist [Optionen] Datei\n\n"
	"Optionen: -l         Liste im Lindner-Stil\n"
	"          -s         Liste im Strunk-Stil\n"
	"          -f<Format> Liste im angegebenen Format; dabei ist\n"
	"                     %F - Zeichensatzname\n"
        "                     %R - Aufl\"osung (aus -r-Option)\n"
	"                     %M - Vergr\"osserung (Fliesskomma)\n", stderr);
    fputs("                     %m - Vergr\"osserung (Ganzzahl)\n"
	"                     %E - Ger\"ate-Endung (aus -e-Option)\n"
	"          -e<Endung> f\"ur %E im Format\n"
	"          -r<Zahl>   f\"ur %R im Format\n"
	"          -m<Zahl>   Vergr\"osserung\n"
	"          -o<Datei>  Name der Ausgabedatei (sonst stdout)\n\n"
	"Beispiel:\n"
	"          Lindner-Stil ist: -escr -r101 -f\"res%R.%E %M %F\"\n"
	"\n", stderr);
}

	unsigned long
get_quad (FILE *f)
{
	unsigned long q = 0;
	q = (unsigned long)getc(f);
	q = 256 * q + (unsigned long)getc(f);
	q = 256 * q + (unsigned long)getc(f);
	return 256 * q + (unsigned long)getc(f);
}

	int
safer_seeks (FILE *f, long offset, int whence)
{
	if (fseek(f, offset, whence) != 0) {
		fprintf(stderr, "%s: konnte nicht positionieren\n",
			prog_name);
		return 0;
	}
	return 1;
}

	int
find_postamble (FILE *f)
{
	int i, done;
	unsigned long post;

	if (safer_seeks(f, -1L, SEEK_END) == 0) return 0;
	done = 0;
	while (!done) {
		if ((i = getc(f)) == EOF) {
			fprintf(stderr, "%s: Lesefehler!\n", prog_name);
			return 0;
		}
		if (i == DVI_ID)
			done = 1;
		else if (safer_seeks(f, -2L, SEEK_CUR) == 0)
			return 0;
	}
	if (safer_seeks(f, -5L, SEEK_CUR) == 0)
		return 0;
	post = get_quad(f);
	return safer_seeks(f, post, SEEK_SET);
}

	int
read_font_def (FILE *f, unsigned long mag)
{
	int op, i, len;
	unsigned long s, d;
	char name[MAX_FONT_NAME], *p;

	op = (unsigned int)getc(f);
	if (op < FNT_DEF1 || op > FNT_DEF4)
		return 0;
	for (i = op - FNT_DEF1 + 1; i > 0; --i)
		(void)getc(f);
	(void)get_quad(f);		/* Pr"ufsumme */
	s = get_quad(f);
	d = get_quad(f);
	len = (unsigned int)getc(f);
	len += (unsigned int)getc(f);
	for (i = 0; i < len; ++i)
		name[i] = getc(f);
	name[i] = '\0';
	for (p = fmt; *p; ++p) {
	    if (*p == '%')
		switch (*++p) {
		    case 'R':
		    	fprintf(out, "%s", res); break;
		    case 'E':
		    	fprintf(out, "%s", ext); break;
		    case 'M':
		    	fprintf(out, "%5.3f", (double)mag * s / 1000.0 / d);
			break;
		    case 'm':
		    	fprintf(out, "%d", (int)((double)mag * s / d));
			break;
		    case 'F': 
			fputs(name, out);
			break;
		    case '%':
			putc('%', out);
			break;
		    default:
			fprintf(stderr, "%s: Ung\"ultiges Format %%%c\n",
				prog_name, *p);
		}
	    else
	    	putc(*p, out);
	}
	putc('\n', out);
	return 1;
}

	int
fontlist (const char *file, unsigned long umag)
{
	unsigned long mag;
	FILE *f = fopen(file, "rb");

	if (f == NULL) {
		fprintf(stderr, "%s: konnte %s nicht \"offnen\n",
			prog_name, file);
		return 0;
	}
	if (!find_postamble(f)) {
		fprintf(stderr, "%s: konnte Postambel in %s nicht finden\n",
			prog_name, file);
		return 0;
	}
	if (safer_seeks(f, 13L, SEEK_CUR) == 0)
		return 0;
	mag = get_quad(f);
	if (umag) mag = umag;
	if (safer_seeks(f, 12L, SEEK_CUR) == 0)
		return 0;
	while (read_font_def(f, mag))
		;
	(void)fclose(f);
	return 1;
}

	int
main (int argc, char **argv)
{
	unsigned long umag = 0;

	prog_name = *argv;
	if (argc <= 1) {
		usage();
		return EXIT_FAILURE;
	}
	while (**++argv == '-') {
	    switch (*(*argv + 1)) {
		case 'e': ext = *argv + 2; break;
		case 'r': res = *argv + 2; break;
		case 'f': fmt = *argv + 2; break;
		case 'l': fmt = "res%R.%E %F %M"; break;
		case 'm': umag = strtoul(*argv + 2, (char **)NULL, 0); break;
		case 'o': outf = *argv + 2;
		case 's': fmt = "%F in magnification %m"; break;
		default: usage(); return EXIT_FAILURE;
	    }
	}
	if (*argv == NULL) {
		usage();
		return EXIT_FAILURE;
	}
	if (outf && (out = fopen(outf, "w")) == NULL) {
		fprintf(stderr, "%s: konnte %s nicht \"offnen\n",
			prog_name, outf);
		return EXIT_FAILURE;
	}
	return fontlist(*argv, umag) ? EXIT_SUCCESS : EXIT_FAILURE;
}
