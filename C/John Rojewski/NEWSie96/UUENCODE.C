/*
 *
 * Uuencode -- encode a file so that it's printable ascii, short lines
 *
 * Slightly modified from a version posted to net.sources a while back,
 * and suitable for compilation on the IBM PC
 *
 * modified for Lattice C on the ST - 11.05.85 by MSD
 * modified for ALCYON on the ST -    10-24-86 by RDR
 * modified a little more for MWC...  02/09/87 by JPHD
 * (An optional first argument of the form: -nnumber (e.g. -500), will
 * produce a serie of files that long, linked by the include statement,
 * such files are automatically uudecoded by the companion program.)
 * (A lot more to do about I/O speed, avoiding completely the stdio.h...)
 *
 */


#include <stdio.h>
#include <ctype.h>

#define USAGE "Usage: uuencode [-n] inputfile\n"

/* ENC is the basic 1 character encoding function to make a char printing */
#define ENC(c) (((c) & 077) + ' ')

extern FILE  *freopen(), *fopen();
FILE *fp,*op;
char ofname[80];
extern char *rindex();
int uue_part = 'a';
int split = 0; fileln = 32000;

void uuencode( char *path )
{
	char fname[128];
/*
void main(argc, argv)
int argc; char *argv[];
{
        if (argc < 2) {
                fprintf(stderr, USAGE);
                exit(2);
                }
	if (argv[1][0] == '-') {
		fileln = -atoi(argv[1]);
		if (fileln <= 0) {
			fprintf(stderr, "Wrong file length arg.\n");
			exit();
		}
		split = 1;
		argv++;
	}
*/		uue_makename( path );
        if ((fp=fopen(path /*argv[1]*/, "rb"))==NULL) {  /* binary input !!! */
                fprintf(stderr,"Cannot open %s\n",path /*argv[1]*/);
                exit(1);
        }
        if ((op=fopen(ofname, "wa"))==NULL) {  /* binary input !!! */
                fprintf(stderr,"Cannot create %s\n",path /*argv[1]*/);
                exit(1);
        }
/*        if(freopen(ofname, "w", stdout)!=stdout) {
                fprintf(stderr,"Cannot reassign stdout\n");
                exit(1);
                }
*/
        uue_maketable();
		stcgfn( fname, path );
        fprintf( op, "begin %o %s\n", 0644, fname /*argv[1]*/);
        uue_encode();
        fprintf( op, "end\n");
		strcpy( path, ofname );
		fclose( op );
/*		exit(0); */
}

/* create ASCII table so a mailer can screw it up and the decode
 * program can restore the error.
 */
void uue_maketable()
{
        register int i, j;

        fputs("table", op);
        fputc('\n', op);
        for(i = ' ', j = 0; i < '`' ; j++) {
                if (j == 32)
			fputc('\n', op);
		fputc(i++, op);
        }
        fputc('\n', op);
}

/* I include this in all of my programs to take the guess work out of
 * filenames.
 */
void uue_makename(name)
char name[];
{
        register char *ptr;

        strcpy(ofname, name);
        /* I think index is neat; just look for a character, and
         * bomb it.  Voila, you have a substring, no mess.
         */
        if(ptr = rindex(ofname,'.')) {
                *ptr = '\0';
                *--ptr = uue_part;
        }
        else /* i.e. make the last character in the first name = part */
                ofname[strlen(ofname)-1] = uue_part;
        strcat(ofname,".uue");
        /* return; */
}

/*
 * copy from stdin to stdout, encoding as you go along.
 */
void uue_encode()
{
        char buf[80];
        char file[80];
        register int i, n;
        register int lines=0;
        lines = 6;

        strcpy(file,ofname);
        for (;;) {
                n = uue_fr(buf, 45);
                fputc(ENC(n), op);
                for (i = 0; i < n; i += 3)
                      uue_outdec(&buf[i]);
                fputc(uue_part, op);
                fputc('\n', op);
                ++lines;
                if (split && (lines > fileln)) {
                        ++uue_part;
                        uue_makename(file);
                        fprintf( op, "include %s\n",ofname);
                   /*   if(freopen(ofname, "w", stdout)!=stdout) {
                                fprintf(stderr,"Cannot reassign stdout\n");
                                exit(1);
                        } */
                        uue_maketable();
                        fprintf( op, "begin part %c\n",uue_part);
                        lines = 6;
                }
                if (n <= 0)
                        break;
        }
}

/*
 * output one group of 3 bytes, pointed at by p, on file f.
 */
uue_outdec(p)
register char *p;
{
        register int c1, c2, c3, c4;

        c1 = *p >> 2;
        c2 = (*p << 4) & 060 | (p[1] >> 4) & 017;
        c3 = (p[1] << 2) & 074 | (p[2] >> 6) & 03;
        c4 = p[2] & 077;
        fputc(ENC(c1), op );
        fputc(ENC(c2), op );
        fputc(ENC(c3), op );
        fputc(ENC(c4), op );
		return(0);
}

/* uue_fr: like read but stdio */
int uue_fr(buf, cnt)
register char *buf;
register int cnt;
{
        register int c, i;
        for (i = 0; i < cnt; i++) {
                c = fgetc(fp);
                if (feof(fp))
                        return(i);
                buf[i] = c;
        }
        return (cnt);
}

/* end of uuencode.c */