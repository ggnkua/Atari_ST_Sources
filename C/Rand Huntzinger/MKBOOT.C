/*
	mkboot.c	Create a boot.h file from an existing disk

	A quick and dirty program to create a boot.h file by reading the
	bootstrap sector off of the disk currently in drive A: or the
	Atari ST.  The boot.h file, contains the contents of the bootstrap
	sector, in hex, in the character array boot.  This is to be included
	in the wboot.c program.

	link with gemstart, gemlib, and osbind.

	Written by Rand Huntzinger, not to be distributed for profit.
*/

#include	<osbind.h>

#define	CRLF	"\r\n"
#define fputl(x) Fwrite(x, 2L, CRLF)
#define fprint(x,y) Fwrite(x, (long) strlen(y), y)
#define fprintl(x,y) { Fwrite(x, (long) strlen(y), y); fputl(x); }
#define fputc(x, y) { char c; c = (char) y; Fwrite(x, 1L, &c); }

static char hex[] = "0123456789abcdef";

main(argc, argv)
	int	argc;
	char	**argv;
{
	char	buf[512];
	int	i,j,k;
	int	out;

	Floprd(buf, 0L, 0, 1, 0, 0, 1);		/* Read boot from A: */

	/* Write boot data, as text, out to standard output */

	out = Fcreate(argc > 1 ? *argv : "boot.h", 0);
	if(out < 0) {
		Cconws("Open Error on ");
		Cconws(argc > 1 ? argv[1] : "boot.h");
		Cconws(CRLF);
		exit(1);
	}

	fprintl(out, "/* Atari 520 ST Boot Block */");
	fputl(out);
	fprintl(out, "char	boot[] = {");
	for(i=0; i < 512; i += 16) {
		for(j=i; j < (i+16); j++) {
			k = ((int) buf[j]) & 0xff;
			if(i < j) fputc(out, ' ');
			fprint(out, "0x");
			fputc(out, hex[k >> 4]);	/* In hex */
			fputc(out, hex[k & 15]);
			if(j < 511) fputc(out, ',');
		}
		fputl(out);
	}
	fprintl(out, "};");
	Fclose(out);
	exit(0);
}
