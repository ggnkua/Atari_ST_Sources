/*
	Sprache: 		C, ANSI-C
	Entwickelt mit: Turbo-C
	Autor:			Martin Backschat

	Diese Routinen sind Public Domain!!

 Diese Datei enthÑlt den Quelltext zum Einladen und zum Speichern
 einer IMG-Datei.

 img_save(char *name,unsigned *scrbase);
	Speichert das Bild mit der Basis scrbase unter dem Dateinamen name.
	Die Auflîsung erkennt die Routine selbststÑndig und speichert in der
	niedrigsten und mittleren Auflîsung die Farbpalette im Dateikopf ab.
	Die Routine generiert eine einfache IMG-Datei. Pattern und Scanline
	Runs werden nicht erkannt. Jede Bildschirmzeile wird zu einem Un-
	compressed Bit String zusammengefasst.

 img_load(char *name,char *scrbase);
	LÑdt das Bild mit Namen name an die Bildschirmbasis scrbase. Die
	Routine verarbeitet Pattern- und Scanline Runs usw. Die Bildgrîûe
	darf kleiner/gleich der aktuellen Bildschirmausmaûe sein.
*/

#include <tos.h>
#include <stdio.h>

#define	TRUE	1
#define	FALSE	0
#define	NULL	0l
#define	LOREZ	0
#define	MIDREZ	1
#define	HIREZ	2

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

int img_save(char *name,unsigned *scrbase);
int img_load(char *name,char *scrbase);
static void read_line(char *ptr,unsigned bytes);	/* lokal */

FILE *h;
IMGHEADER imghead;
long spvi;

/* Ein kleines Demo, das zeigt, wie die Funktionen aufzurufen sind */
main()
{
	img_load("test.img",(char *)Logbase());
	Crawcin();
}

/* IMG-Datei speichern */
int img_save(char *name,unsigned *scrbase)
{
  unsigned *aktscr,tmpline[80];
  unsigned rez,aktplane,aktline,i,count;

	rez = Getrez();	/* Auflîsung erfragen */
  	spvi = Super(NULL);	/* In den Supervisor wegen Auslesen der Farbpalette */

	if ((h = fopen(name,"wb")) == NULL) {	/* gepufferte Datei îffnen */
		Super(spvi);
		return FALSE;
	}

	/* Einige Werte kînnen wir direkt Åbernehmen */
	imghead.version = 1;
	imghead.patlen = 2;	/* Brauchen wir zwar nicht,.... */
	imghead.pixelw = 372;	/* Standard Breit und Hîhe von Pixel auf ST */
	imghead.pixelh = 372;

	switch (rez) {	/* Es folgen auflîsungsabhÑngige Einstellungen */
		case LOREZ:	/* 320x200 16 Farben */
			imghead.headlen = 8+16;	/* 8 Wîrter Header und 16 Wîrter Palette */
			imghead.nplanes = 4;	/* 4 Bitplanes */
			imghead.linew = 320;
			imghead.lines = 200;
			fwrite(&imghead,(size_t)sizeof(int),8,h);	/* Kopf schreiben */
			fwrite((int *)0xff8240,(size_t)sizeof(int),16,h);	/* Palette schreiben */
			break;
		case MIDREZ: /* 640x200 4 Farben */
			imghead.headlen = 8+16;
			imghead.nplanes = 2;
			imghead.linew = 640;
			imghead.lines = 200;
			fwrite(&imghead,(size_t)sizeof(int),8,h);
			fwrite((int *)0xff8240,(size_t)sizeof(int),16,h);
			break;
		case HIREZ: /* 640x400 monochrom */
			imghead.headlen = 8;
			imghead.nplanes = 1;
			imghead.linew = 640;
			imghead.lines = 400;
			fwrite(&imghead,(size_t)sizeof(int),8,h);
			break;
		default:
			printf("\nKenne aktuelle Aufîsung nicht!");
			Super(spvi);
			fclose(h);
			return FALSE;
	}

	/* Jetzt kommen die Daten: Der Algorithmus begnÅgt sich damit, die
		Zeilen planeweise als Uncompressed Bit String abzulegen. */
	for (aktplane = 0; aktplane < imghead.nplanes; aktplane++)
		for (aktscr = scrbase,aktline = 0; aktline < imghead.lines; aktline++) {
			i = 0;
			count = imghead.linew/8;	/* Anzahl Bytes pro Zeile */
			tmpline[i++] = (0x80*256)+count;	/* Hi: 0x80, Lo: ZÑhler */
			count /= 2;	/* wir zÑhlen Wîrter */
			while (count--) {
				tmpline[i++] = aktscr[aktplane];
				aktscr += imghead.nplanes;
			}
			fwrite(&tmpline,(size_t)sizeof(int),(size_t)i,h);	/* Zeile schreiben */
		}

	Super(spvi);
	fclose(h);
	return TRUE;
}

/* IMG-Datei einladen und auspacken */
int img_load(char *name,char *scrbase)
{
  static unsigned line_len[] = {160,160,80};	/* FÅr Lo,Mid und Hi-Rez: Anzahl Bytes pro Bitplane-Zeile */
  unsigned rez,line,plane,aktbyte,aktline,bprow,bytes;
  char *tmpbuf[4],*aktpuf,*oldscr;

	rez = Getrez();
  	spvi = Super(NULL);

	if ((h = fopen(name,"rb")) == NULL) {
		Super(spvi);
		return FALSE;
	}

	fread(&imghead,(size_t)sizeof(int),8,h);
	switch (rez) {
		case LOREZ:
			/* Wir erwarten: 4 Bitplanes, Farbpalette im Dateikopf und
				und Bildausmaûe kleiner/gleich der Bildschirmausmaûe */
			if ((imghead.nplanes != 4) || (imghead.headlen != 8+16) ||
				(imghead.linew > 320) || (imghead.lines > 200)) {
error:
				printf("\nFalsche Auflîsung");
nomsg_error:
				Super(spvi);
				fclose(h);
				return FALSE;
			}
			fread((int *)0xff8240,(size_t)sizeof(int),16,h);	/* Farbpalette einlesen */
			break;
		case MIDREZ:
			if ((imghead.nplanes != 2) || (imghead.headlen != 8+16) ||
				(imghead.linew > 640) || (imghead.lines > 200))
				goto error;
			fread((int *)0xff8240,(size_t)sizeof(int),16,h);
			break;
		case HIREZ:
			if ((imghead.nplanes != 1) || (imghead.headlen != 8) ||
				(imghead.linew > 640) || (imghead.lines > 400))
				goto error;
			break;
		default:
			goto error;
	}

	bprow = imghead.linew/8+((imghead.linew%8) ? 1 : 0); /* Bytes pro Bitplane-Zeile */
	bytes = bprow*imghead.lines;	/* Bytes pro Bitplane */

	for (plane = 0; plane < imghead.nplanes; plane++) {	/* Bitplaneweise einlesen */
		if ((aktpuf = tmpbuf[plane] = Malloc((long)bytes)) == NULL) {
			printf("Kein Speicherplatz fÅr temporÑren Puffer!");
			goto nomsg_error;
		}
		for (aktline = 0; aktline < imghead.lines; aktline++) {	/* Zeilenweise einlesen */
			read_line(aktpuf,bprow);
			aktpuf += bprow;
		}
	}

	/* Und nun auf dem Bildschirm scrbase anzeigen */
	bytes = bprow+(bprow&1);
	for (line = 0; line < imghead.lines; line++) {
		oldscr = scrbase;
		for (aktbyte = 0; aktbyte < bytes; aktbyte += 2)
			for (plane = 0; plane < imghead.nplanes; plane++) {
				*scrbase++ = tmpbuf[plane][line*bprow+aktbyte];
				*scrbase++ = tmpbuf[plane][line*bprow+aktbyte+1];
			}
		scrbase = oldscr+line_len[rez];
	}

	for (plane = 0; plane < imghead.nplanes; plane++)
		Mfree(tmpbuf[plane]);	/* Puffer wieder freigeben */

	return TRUE;
}

void read_line(char *dest,unsigned bytes)
{
  static int nlines = 0;
  char pattern[160];
  char *maxdest,val,b;
  unsigned n,i,j;

	if (nlines) {	/* Wenn Scanline Run, dann einfach letzte Zeile kopieren */
		nlines--;
		for (i = 0; i < bytes; i++) {
			*dest = *(dest-bytes);
			dest++;
		}
		return;
	}

	maxdest = dest+bytes;	/* Ende der Bildzeile */
	while (dest < maxdest) {	/* Solange lesen, bis Ende erreicht */
		fread(&b,1,1,h);
		switch (b) {
			case 0:	/* Pattern/Scanline RUn */
				fread(&b,1,1,h);
				if (b == 0) {	/* Scanline Run */
					fread(&b,1,1,h);	/* Flag */
					fread(&b,1,1,h);	/* repeat value */
					read_line(dest,bytes);
					nlines = b-1;
					return;
				}
				else {	/* Pattern Run */
					fread(&pattern,1,imghead.patlen,h);
					for (i = 0; i < b; i++)
						for (j = 0; j < imghead.patlen; j++)
							*dest++ = pattern[j];
				}
				break;
			case 0x80:	/* Uncompressed Bit String */
				fread(&b,1,1,h);
				fread(dest,1,(size_t)b,h);
				dest += b;
				break;
			default:	/* Solid Run */
				n = b&0x7f;	/* Wiederholungsfaktor */
				if (b&0x80)
					val = 0xff;
				else
					val = 0;
				for (i = 0; i < n; i++)
					*dest++ = val;
				break;
		}
	}
}
