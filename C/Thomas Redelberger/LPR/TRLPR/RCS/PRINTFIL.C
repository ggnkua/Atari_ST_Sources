head	1.1;
access;
symbols
	RAalpha:1.1;
locks
	Thomas:1.1; strict;
comment	@ * @;


1.1
date	99.11.28.15.23.10;	author Thomas;	state Exp;
branches;
next	;


desc
@Save file with code from lpd.c
@


1.1
log
@Initial revision
@
text
@void printFile(char *fileNam, int ipr)
{
	char fullFileNam[MAXNPATH+1+8+1];	/* plus \ plus TOSname plus 0 */
	int ipast;
	int fi, fo;
	char c;

	
#if 0
	strncpy(fullFileNam, spoolDir[ipr], MAXNPATH);
	fullFileNam[MAXNPATH]='\0';

	ipast=strlen(fullFileNam);
	if (fullFileNam[ipast-1] != '\\') {	/* make shure it has a slash */
		fullFileName[ipast] = '\\';
		ipast++;
	}
#else
	ipast=0;
#endif

	strncpy(fullFileNam+ipast, fileNam, 8);
	fullFileNam[ipast+8] = '\0';

	fullFileNam[ipast] = 'd';			/* force data file */

	if ( (fi=Fopen(fullFileNam, FO_READ)) >= 0 ) {
		if ( (fo=Fopen(prDevice[ipr], FO_WRITE)) >= 0) {
	
			while ( Fread(fi, 1, &c) > 0)
				Fwrite(fo, 1, &c);
	
			Fclose(fo);
		} else {
	        debPrintf ("[3][LPD error:|open device|%s][OK]", prDevice[ipr]);
		}
		Fclose(fi);
	} else {
        debPrintf ("[3][LPD error:|open dFile][OK]");
	}

	Fdelete(fullFileNam);
	fullFileNam[ipast] = 'c';			/* force control file */
	Fdelete(fullFileNam);
}	
@
