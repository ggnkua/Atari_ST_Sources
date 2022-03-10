/*
 * This was modified heavily for GEM from DUMAS UUE.C
 */ 

#include <stdio.h>
#include <ctype.h>

/* ENC is the basic 1 character encoding function to make a char printing */

#define ENC(c) (((c) & 077) + ' ')

extern FILE  *fopen();
FILE *fp, *outp;
char ofname[80];
int lenofname;
int stdo = 0;

#define READ "rb"

int part = 'a', chap = 'a';
#define SEQMAX 'z'
#define SEQMIN 'a'
char seqc = SEQMAX;

int split = 0; fileln = 32*1024;
char lnbuf[128];
encode(filename)
	char *filename;
	{
	char *p;
	char *fname;
	if ((fp=fopen(filename, READ))==NULL) 
		{
		sprintf(lnbuf,"[1][Unable to open|%s][ABORT]",filename);
		form_alert(1,lnbuf);
		return;
		}
	disp_process(filename);
	p = filename+strlen(filename);
	while (--p > filename)
		{
		if ((*(p-1) == '\\')||(*(p-1) == ':'))
			break;
		}
	/* p now points to the root filename, no path */
	strcpy(ofname, p);
	fname = ofname;
	do 
		{
		if (*fname == '.')
			*fname = '\0';
		} while (*fname++);
	/* 8 char prefix + .uue -> 12 chars MAX */
	lenofname = strlen(ofname);
	if (lenofname > 8) ofname[8] = '\0';
	strcat(ofname,".uue");
	lenofname = strlen(ofname);
	makename();
	if((outp = fopen(ofname, "w")) == NULL) 
		{
		sprintf(lnbuf,"[1][Unable to open|%s][ABORT]",ofname);
		form_alert(1,lnbuf);
		fclose(fp);
		return;
		}
	maketable();
	fprintf(outp,"begin %o %s\n", 0644, p);
	uuencode();
	fprintf(outp,"end\n");
	fclose(outp);
	return;
	}

/* create ASCII table so a mailer can screw it up and the decode
 * program can restore the error.
 */
maketable()
{
	register int i, j;

	fputs("table\n", outp);
	for(i = ' ', j = 0; i < '`' ; j++) {
		if (j == 32)
			putc('\n', outp);
		fputc(i++, outp);
	}
	putc('\n', outp);
}

/*
 * Generate the names needed for single and multiple part encoding.
 */
makename()
{
	if (split) {
		ofname[lenofname - 1] = part;
		ofname[lenofname - 2] = chap;
	}
}

/*
 * copy from in to out, encoding as you go along.
 */
uuencode()
{
	char buf[80];
	register int i, n;
	register int lines;
	lines = 6;

	for (;;) {
		n = fr(buf, 45);
		putc(ENC(n), outp);
		for (i = 0; i < n; i += 3)
		      outdec(&buf[i]);
		putc(seqc, outp);
		seqc--;
		if (seqc < SEQMIN) seqc = SEQMAX;
		putc('\n', outp);
		++lines;
		if (split && (lines > fileln)) {
			part++;
			if (part > 'z') {
				part = 'a';
				if (chap == 'z')
					chap = 'a'; /* loop ... */
				else
					chap++;
			}
			makename();
			fprintf(outp,"include %s\n",ofname);
			fclose(outp);
			if((outp = fopen(ofname, "w")) == NULL) 
				{
				sprintf(lnbuf,"[1][Unable to open|%s][ABORT]",
						ofname);
				form_alert(1,lnbuf);
				return;
				}
			maketable();
			fprintf(outp,"begin part %c %s\n",part,ofname);
			lines = 6;
		}
		if (n <= 0)
			break;
	}
}

/*
 * output one group of 3 bytes, pointed at by p, on file f.
 */
outdec(p)
register char *p;
{
	register int c1, c2, c3, c4;

	c1 = *p >> 2;
	c2 = (*p << 4) & 060 | (p[1] >> 4) & 017;
	c3 = (p[1] << 2) & 074 | (p[2] >> 6) & 03;
	c4 = p[2] & 077;
	putc(ENC(c1), outp);
	putc(ENC(c2), outp);
	putc(ENC(c3), outp);
	putc(ENC(c4), outp);
}

/* fr: like read but stdio */
int fr(buf, cnt)
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

