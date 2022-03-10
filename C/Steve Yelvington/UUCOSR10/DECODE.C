/*
 * The uudecoding module, stripped and modified from Dumas' UUD
 * with GEM routines added. 
 */

#include <stdio.h>
#include <string.h>

#define MAXCHAR 256
#define LINELEN 256
#define FILELEN 128
#define NORMLEN 60	/* allows for 80 encoded chars per line */
#define MAXFILES 32

#define ifname	if_name
#define ofname	of_name

#define SEQMAX 'z'
#define SEQMIN 'a'

extern FILE *fopen();
extern char *strcpy();
extern char *strcat();
char *getnword();

char seqch;
int first, secnd, check, numl;

FILE *in, *out;
char *pos;
char *curarg;
char ifname[FILELEN], ofname[FILELEN];
int filenumber = 0;
char blank, partc = '\0';
int partn, lens;
int onedone = 0;
int chtbl[MAXCHAR], cdlen[NORMLEN + 3];

char lnbuf[128];	/* scratchpad for sprintf use */

int
decode(ifname) char *ifname;
	{
	int mode;
	register int i, j;
	char dest[FILELEN], buf[LINELEN];

	if ((in = fopen(ifname, "r")) == NULL) 
		{
		form_alert(1,"[1][Unable to open|the input file][ABORT]");
		return;
		}
	disp_process(ifname);
	/*
	 * Set up the default translation table.
	 */
	for (i = 0; i < ' '; i++) chtbl[i] = -1;
	for (i = ' ', j = 0; i < ' ' + 64; i++, j++) chtbl[i] = j;
	for (i = ' ' + 64; i < MAXCHAR; i++) chtbl[i] = -1;
	chtbl['`'] = chtbl[' '];	/* common mutation */
	chtbl['~'] = chtbl['^'];	/* an other common mutation */
	blank = ' ';
	/*
	 * set up the line length table, to avoid computing lotsa * and / ...
	 */
	cdlen[0] = 1;
	for (i = 1, j = 5; i <= NORMLEN; i += 3, j += 4)
		cdlen[i] = (cdlen[i + 1] = (cdlen[i + 2] = j));
	/*
	 * search for header or translation table line.
	 */
	for(;;)
		{	/* master loop for multiple decodes in one file */
		partn = 'a';
		for(;;)
			{
			if (fgets(buf, sizeof buf, in) == NULL) /* end of file */
				{
				if(onedone) 
					{
					return;
					} 
				else 
					{
					form_alert(1,"[1][Out of data...|No \"begin\" line][ABORT]");
					return;
					}
				}
			numl++;
			if (strncmp(buf, "table", 5) == 0) 
				{
				gettable();
				continue;
				}
			if (strncmp(buf, "begin ", 6) == 0) 
				break;
			if (strncmp(buf, "BEGIN", 5) == 0) 
				continue;
			}

		lens = strlen(buf);
		if (lens) buf[--lens] = '\0';

		if ((pos = getnword(buf, 3))) 
			{
			strcpy(dest, pos);
			} 
		else
			{
			form_alert(1,"[1][No filename|in \"begin\" line][ABORT]");
			return;
			}

/* NEED CODE HERE FOR USER TO EDIT DESTINATION LINE */

		strcpy(ofname, dest);

		if((out = fopen(ofname, "wb")) == NULL) 
			{
			sprintf(lnbuf,"[1][Cannot open|output file|%s][ABORT]",
				ofname);
			form_alert(1,lnbuf);
			return;
			}
		seqch = SEQMAX;
		check = 1;
		first = 1;
		secnd = 0;
		uudecode();
		fclose(out);
		onedone = 1;
		}	/* master loop for multiple decodes in one file */
	}

/*
 * Bring back a pointer to the start of the nth word.
 */
char *getnword(str, n) register char *str; register int n;
	{
	while((*str == '\t') || (*str == ' ')) str++;
	if (! *str) return NULL;
	while(--n) 
		{
		while ((*str != '\t') && (*str != ' ') && (*str)) str++;
		if (! *str) return NULL;
		while((*str == '\t') || (*str == ' ')) str++;
		if (! *str) return NULL;
		}
	return str;
	}

/*
 * Install the table in memory for later use.
 */
gettable()
	{
	char buf[LINELEN];
	register int c, n = 0;
	register char *cpt;

	for (c = 0; c <= MAXCHAR; c++) chtbl[c] = -1;

	for(;;)
		{
		if (fgets(buf, sizeof buf, in) == NULL) 
			{
			form_alert(1,"[1][Unexpected EOF|in translation table][ABORT]");
			return(-1);
			}
		numl++;
		if (strncmp(buf, "begin", 5) == 0) 
			{
			form_alert(1,"[1][Incomplete|translation table][ABORT]");
			return(-1);
			}
		cpt = buf + strlen(buf) - 1;
		*cpt = ' ';
		while (*(cpt) == ' ') 
			{
			*cpt = 0;
			cpt--;
			}
		cpt = buf;
		while (c = *cpt) 
			{
			if (chtbl[c] != -1) 
				{
				form_alert(1,"[1][Duplicate char|in translation table][ABORT]");
				return(-1);
				}
			if (n == 0) blank = c;
			chtbl[c] = n++;
			if (n >= 64) return;
			cpt++;
			}
		}
	}

/*
 * copy from in to out, decoding as you go along.
 */

uudecode()
	{
	char buf[LINELEN], outl[LINELEN];
	register char *bp, *ut;
	register int *trtbl = chtbl;
	register int n, c, rlen;
	register unsigned int len;
	for(;;) 
		{
		if (fgets(buf, sizeof buf, in) == NULL) 
			{
			form_alert(1,"[1][EOF before end|of encoded data][ABORT]");
			fclose(out);
			return(-1);
			}
		numl++;
/*
 * end of uuencoded file ?
 */
		if (strncmp(buf, "END", 3) == 0) 
			{
			for(;;)
				{
				/* look for another file */
				if (fgets(buf, sizeof buf, in) == NULL) 
					{
					fclose(out);
					return(-1);
					}
				if (strncmp(buf, "BEGIN", 5) == 0) break;
				}
			if (fgets(buf, sizeof buf, in) == NULL) 
				{
				form_alert(1,"[1][EOF right after BEGIN][ABORT]");
				fclose(out);
				return(-1);
				}
			}
			
		len = strlen(buf);
		if (len) buf[--len] = '\0';
/*
 * Is it an unprotected empty line before the end line ?
 */
		if (len == 0) continue;
/*
 * Get the binary line length.
 */
		n = trtbl[*buf];
		if (n >= 0) goto decod;
/**********CHECK THE ABOVE; MOVE INTO MAIN LOOP?? ***********/

/*
 * end of Dumas uuencoded file ?
 */
		if (strncmp(buf, "end", 3) == 0) return;
/*
 * end of current file ? : get next one.
 */
		if (strncmp(buf, "include", 7) == 0) 
			{
			if (getfile(buf) < 0)
				{
				sprintf(lnbuf,
					"[1][Can't get data:|%s][ABORT]",
					buf);
				return(-1);
				}
			continue;
			}
		buf[20] = '\0'; /* limit length of line passed to GEM */
		sprintf(lnbuf,"[1][Bad prefix|\"%s\"|in file:|%s][ABORT]",
			buf, ifname);
		form_alert(1,lnbuf);
		return(-1);
/*
 * Sequence checking ?
 */
decod:		rlen = cdlen[n];
/*
 * Is it the empty line before the end line ?
 */
		if (n == 0) continue;
/*
 * Pad with blanks.
 */
		for (bp = &buf[c = len];
			c < rlen; c++, bp++) *bp = blank;
/*
 * All this just to check for uuencodes that append a 'z' to each line....
 */
		if (secnd && check) 
			{
			secnd = 0;
			if (buf[rlen] == SEQMAX) 
				check = 0;
			}
		else if (first && check) 
			{
			first = 0;
			secnd = 1;
			if (buf[rlen] != SEQMAX) 
				check = 0;
			}
/*
 * There we check.
 */
		if (check) 
			{
			if (buf[rlen] != seqch) 
				{
				sprintf(lnbuf,"[1][Wrong sequence|line %d|in file:|%s][I know]",
					numl, ifname);
				form_alert(1,lnbuf);
				}
			seqch--;
			if (seqch < SEQMIN) seqch = SEQMAX;
			}
/*
 * output a group of 3 bytes (4 input characters).
 * the input chars are pointed to by p, they are to
 * be output to file f.n is used to tell us not to
 * output all of them at the end of the file.
 */
		ut = outl;
		len = n;
		bp = &buf[1];
		while (n > 0) {
			*(ut++) = trtbl[*bp] << 2 | trtbl[bp[1]] >> 4;
			n--;
			if (n) {
				*(ut++) = (trtbl[bp[1]] << 4) |
					  (trtbl[bp[2]] >> 2);
				n--;
			}
			if (n) {
				*(ut++) = trtbl[bp[2]] << 6 | trtbl[bp[3]];
				n--;
			}
			bp += 4;
		}
		if ((n = fwrite(outl, 1, len, out)) <= 0) 
			{
			form_alert(1,"[1][Error writing|decoded file][ABORT]");
			return(-1);
			}
		}
	}


/*
 * Find the next needed file, if if exists, otherwise try further
 * on next file.
 */

getfile(buf) register char *buf;
	{
	if ((pos = getnword(buf, 2)) == NULL) 
		{
		form_alert(1,"[1][No include-file|name specified][ABORT]");
		return(-1);
		} 

	/* Some encoders are specifying filenames illegal for GEMdos */
	/* The following transforms filename.arc.uab into filename.uab */
	{
	char *p, *q;
	p = strchr(pos,'.');
	q = strrchr(pos,'.');
	if ((p != q) && p && q)
		strcpy(p,q);
	}

	strcpy(ifname, pos);

	if (exists(ifname))
		{
		if (freopen(ifname, "r", in) == in) 
			{
			disp_process(ifname);
			numl = 0;
			} 
		else 
			{
			sprintf(lnbuf,"[1][freopen failure|while attempting|%s][ABORT]",
				ifname);
			form_alert(1,lnbuf);
			return(-1);
			}
		}

	for(;;)
		{
		/* read lines, looking for table or begin */
		if (fgets(buf, LINELEN, in) == NULL) 
			{
			sprintf(lnbuf,"[1][No data in|%s][ABORT]",
				ifname);
			form_alert(1,lnbuf);
			return(-1);
			}
		numl++;
		if (strncmp(buf, "table", 5) == 0) 
			{
			gettable();
			continue;
			}
		if (strncmp(buf, "begin ", 6) == 0) break; /* found it! */
		}
	lens = strlen(buf);
	if (lens) buf[--lens] = '\0'; /* I think this kills the newline */
/*
 * Check the part suffix.
 */
	if ((pos = getnword(buf, 3)) == NULL ) 
		{
		sprintf(lnbuf,"[1][Missing part name|in included file:|%s][ABORT]",
			ifname);
		form_alert(1,lnbuf);
		return(-1);
		} 
	else 
		{
		partc = *pos;
		partn++;
		if (partn > 'z') partn = 'a';
		if (partc != partn) 
			{
			sprintf(lnbuf,"[1][Part suffix mismatch:|<%c> instead of <%c>][ABORT]",
				partc, partn);
			form_alert(1,lnbuf);
			return(-1);
			}
		}
	}


