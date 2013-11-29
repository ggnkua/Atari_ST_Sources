/*

 ascii file read without C-lib calls, only OS!

 */

/* in SCAN.C: remove tk_* calls.
 * define 'symbol' as variable, not ptr to it.
 * Global: replace all references to symbol-> by symbol.
 */


char	*CKBfileblock = NULL;
long	CKBfilesize;
long	Readlnidx;

/*
 * raw_read_file:
 *	read the CKB file completely
 */
BOOL raw_read_file(char *name)
{
	DTA		mydta;

	if (CKBfileblock) {
		Mfree(CKBfileblock);
		CKBfileblock = NULL;
	}

	Readlnidx = 0;

	/* locate file */
	if (Fsfirst(name, &mydta)<=0) return FALSE;		/* file not found */
	CKBfilesize = dta.size;

	/* alloc space for the file */
	CKBfileblock = Malloc((dta.size+16)&(-16));
	if (CKBfileblock==0) return FALSE;				/* out of memory */

	/* open the file */
	handle = Fopen(name, FO_READ);
	if (handle<=0) return FALSE;					/* file open error */

	/* read all of it */
	Fread(handle, CKBfileblock, dta.size)

	/* close it */
	Fclose(handle);

	return TRUE;
}


/*
 * ReadLine
 */
int ReadLine(char *buf, int nbytes)
{
	long	i;
	char	*p;

	if (CKBfileblock==NULL) return 0;

	/* copy bytes until CR or LF is reached */
	i=Readlnidx;
	p=&CKBfileblock[i];
	while (i<CKBfilesize && nbytes>0 && *p && *p!=CR && *p!=LF)
	{
		*buf++ = *p++;
		nbytes--;
		i++;
	}
	/* append null termination */
	*buf++=NUL;

	/* skip CR/LF combinations (to avoid empty lines) */
	while (i<CKBfilesize && *p && (*p==CR || *p==LF))
	{
		p++; i++;
	}

	/* store readline index */
	Readlnidx=i;

	return 1;
}


/*
 * after read operation, cleanup
 */
BOOL raw_close_file(void)
{
	if (CKBfileblock) {
		Mfree(CKBfileblock);
		CKBfileblock = NULL;
	}

	Readlnidx = 0;
	CKBfilesize = 0;
}


/* eof */
