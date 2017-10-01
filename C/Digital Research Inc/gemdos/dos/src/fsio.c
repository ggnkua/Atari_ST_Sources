/*  fsio.c - read/write routines for the file system			*/

#include	"gportab.h"
#include	"fs.h"
#include	"bios.h"		/*  M01.01.01			*/
#include	"gemerror.h"

/*
**  xlseek -
**	seek to byte position n on file with handle h
**
**  Function 0x42	f_seek
**
**	Error returns
**		EIHNDL
**		EINVFN
**		ixlseek()
*/

long	xlseek( n , h , flg )
	int	h, flg ;
	long	n ;
{
	OFD *f;
	long	ixlseek() ;


	if (!(f = getofd(h)))
		return(EIHNDL);

	if (flg == 2)
		n += f->o_fileln;
	else if (flg == 1)
		n += f->o_bytnum;
	else if (flg)
		return(EINVFN);

	return(ixlseek(f,n));
}

/*
**  ixlseek -
**	file position seek
**
**	Error returns
**		ERANGE
**		EINTRN
**
**	Last modified	LTG	31 Jul 85
**
**	NOTE:	This function returns ERANGE and EINTRN errors, which are new 
**		error numbers I just made up (that is, they were not defined 
**		by the BIOS or by PC DOS).
*/

long	ixlseek(p,n)
	REG OFD	*p;		/*  file descriptor for file in use	*/
	long	n;		/*  number of bytes to seek		*/
{
	int clnum,clx,curnum,i;				/*  M01.01.03	*/
	int	curflg ;	/****  M00.01.01b  ****/
	REG DMD *dm;

	if (n > p->o_fileln)
		return(ERANGE);

	if (n < 0)
		return(ERANGE);

	dm = p->o_dmd;
	if (!n)
	{
		clx = 0;
		p->o_curbyt = 0;
		goto fillin;
	}

	/* do we need to start from the beginning ? */

	/***  M00.01.01b ***/
	if( ((!p->o_curbyt) || (p->o_curbyt == dm->m_clsizb)) && p->o_bytnum ) 
		curflg = 1 ;
	else 
		curflg = 0 ;
	/***  end  ***/
		
	clnum = divmod(&p->o_curbyt,n,dm->m_clblog);

	if (p->o_curcl && (n >= p->o_bytnum))
	{
		curnum = p->o_bytnum >> dm->m_clblog;
		clnum -= curnum;
		clnum += curflg ;		/***   M00.01.01b	***/

/*****
M00.01.01 - original code (fix to Jason's  attempt to fix)
		clnum += 
		((!p->o_curbyt) || (p->o_curbyt == dm->m_clsizb))&&p->o_bytnum;	
*****/

		clx = p->o_curcl;

	}
	else
		clx = p->o_strtcl;

	for (i=1; i < clnum; i++)			/*** M00.01.01b ***/
		if ((clx = getcl(clx,dm)) == -1)
			return(-1);

	/* go one more except on cluster boundary */

	if (p->o_curbyt && clnum)			/*** M00.01.01b ***/
		clx = getcl(clx,dm);

fillin:	p->o_curcl = clx;
	p->o_currec = cl2rec(clx,dm);
	p->o_bytnum = n;

	return(n);
}






/*
**  xread -
**	read 'len' bytes  from handle 'h'
**
**	Function 0x3F	f_read
**
**	Error returns
**		EIHNDL
**		bios()
**
**	Last modified	SCC	8 Apr 85
*/

long	xread(h,len,ubufr) 
	int h;
	long len;
	char *ubufr;
{
	OFD	*p;
	long	ixread() ;

	if (p = getofd(h))
		return(ixread(p,len,ubufr));

	return(EIHNDL);
}

/*
**  ixread -
**
**	Last modified	SCC	26 July 85
*/

long	ixread(p,len,ubufr)
	REG OFD *p;
	long len;
	char *ubufr;
{
	long maxlen;

        /*Make sure file not opened as write only.*/
        if (p->o_mod == 1)
		return (EACCDN);

	if (len > (maxlen = p->o_fileln - p->o_bytnum))
		len = maxlen;

	if (len > 0)
		return(xrw(0,p,len,ubufr,xfr2usr));

	return(0L);	/* zero bytes read for zero requested */
}







/*
**  xwrite -
**	write 'len' bytes to handle 'h'.
**
**	Function 0x40	f_write
**
**	Error returns
**		EIHNDL
**		bios()
**
**	Last modified	SCC	10 Apr 85
*/

long	xwrite(h,len,ubufr) 
	int h;
	long len;
	char *ubufr;
{
	REG OFD	*p;
	long	ixwrite() ;

	if (p = getofd(h))
        {	/* Make sure not read only.*/
        	if (p->o_mod == 0)	
			return (EACCDN);
		return(ixwrite(p,len,ubufr));
        }

	return(EIHNDL);
}

/*
**  ixwrite -
*/

long	ixwrite(p,len,ubufr)
	OFD *p;
	long len;
	char *ubufr;
{
	return(xrw(1,p,len,ubufr,usr2xfr));
}

/*
**  xrw - read/write 'len' bytes from/to the file indicated by the OFD at 'p'.
**
**  details
**	We wish to do the i/o in whole clusters as much as possible.
**	Therefore, we break the i/o up into 5 sections.  Data which occupies 
**	part of a logical record (e.g., sector) with data not in the request 
**	(both at the start and the end of the the request) are handled
**	separateley and are called header (tail) bytes.  Data which are
**	contained complete in sectors but share part of a cluster with data not
**	in the request are called header (tail) records.  These are also
**	handled separately.  In between handling of header and tail sections,
**	we do i/o in terms of whole clusters.
**
**  returns
**	nbr of bytes read/written from/to the file.
*/

long	xrw(wrtflg,p,len,ubufr,bufxfr)
	int wrtflg,(*bufxfr)();
	OFD *p;
	long len;
	char *ubufr;
{
	REG DMD *dm;
	char *bufp;
	int bytn,recn,lenxfr,lentail,num;	/*  M01.01.03 */
	int hdrrec,lsiz,tailrec;
	int last, nrecs, lflg; /* multi-sector variables */
	long nbyts;
	long rc,bytpos,lenrec,lenmid;

	/*
	**  determine where we currently are in the filef
	*/

	dm = p->o_dmd;			/*  get drive media descriptor	*/

	bytpos = p->o_bytnum; 		/*  starting file position 	*/

	/*
	**  get logical record number to start i/o with
	**	(bytn will be byte offset into sector # recn)
	*/

	recn = divmod(&bytn,(long) p->o_curbyt,dm->m_rblog);
	recn += p->o_currec;

	/*
	**  determine "header" of request.
	*/

	if (bytn) /* do header */
	{	/*
		**  xfer len is
		**	min( #bytes req'd , #bytes left in current record )
		*/
		lenxfr = min(len,dm->m_recsiz-bytn);
		bufp = getrec(recn,dm,wrtflg);	/*  get desired record	*/
		addit(p,(long) lenxfr,1);	/*  update ofd		*/
		len -= lenxfr;			/*  nbr left to do	*/
		recn++;				/*    starting w/ next	*/

		if (!ubufr) 
		{
			rc = (long) (bufp+bytn);	/* ???????????	*/
			goto exit;
		}

		(*bufxfr)(lenxfr,bufp+bytn,ubufr);	
		ubufr += lenxfr;
	}

	/*
	**  "header" complete.  See if there is a "tail".  
	**  After that, see if there is anything left in the middle.
	*/

	lentail = len & dm->m_rbm;

	if (lenmid = len - lentail)		/*  Is there a Middle ?	*/
	{ 	
		hdrrec = recn & dm->m_clrm;

		if (hdrrec)
		{
			/*  if hdrrec != 0, then we do not start on a clus bndy;
			**	so determine the min of (the nbr sects 
			**	remaining in the current cluster) and (the nbr 
			**	of sects remaining in the file).  This will be 
			**	the number of header records to read/write.
			*/

			hdrrec = ( dm->m_clsiz - hdrrec ) ;	/* M00.14.01 */
			if ( hdrrec > lenmid >> dm->m_rblog )	/* M00.14.01 */
				hdrrec = lenmid >> dm->m_rblog;	/* M00.14.01 */

			usrio(wrtflg,hdrrec,recn,ubufr,dm);
			ubufr += (lsiz = hdrrec << dm->m_rblog);
			lenmid -= lsiz;
			addit(p,(long) lsiz,1);
		}

		/* 
		**  do whole clusters 
		*/

		lenrec = lenmid >> dm->m_rblog;		   /* nbr of records  */
		num = divmod(&tailrec,lenrec,dm->m_clrlog);/* nbr of clusters */

		last = nrecs = nbyts = lflg = 0;

		while (num--)		/*  for each whole cluster...	*/
		{
			rc = nextcl(p,wrtflg);

			/* 
			**  if eof or non-contiguous cluster, or last cluster 
			**	of request, 
			**	then finish pending I/O 
			*/

			if ((!rc) && (p->o_currec == last + nrecs))
			{
				nrecs += dm->m_clsiz;
				nbyts += dm->m_clsizb;
				if (!num) goto mulio;
			}
			else
			{
				if (!num)
					lflg = 1;
mulio:				if (nrecs)
					usrio(wrtflg,nrecs,last,ubufr,dm);
				ubufr += nbyts;
				addit(p,nbyts,0);
				if (rc)
					goto eof;
				last = p->o_currec;
				nrecs = dm->m_clsiz;
				nbyts = dm->m_clsizb;
				if ((!num) && lflg)
				{
					lflg = 0;
					goto mulio;
				}
			}
		}  /*  end while  */

		/* 
		**  do "tail" records 
		*/

		if (tailrec)
		{
			if (nextcl(p,wrtflg))
				goto eof;
			lsiz = tailrec << dm->m_rblog;
			addit(p,(long) lsiz,1);
			usrio(wrtflg,tailrec,p->o_currec,ubufr,dm);
			ubufr += lsiz;
		}
	}

	/* 
	**	do tail bytes within this cluster 
	*/

	if (lentail)
	{
		recn = divmod(&bytn,(long) p->o_curbyt,dm->m_rblog);

		if ((!recn) || (recn == dm->m_clsiz))
		{
			if (nextcl(p,wrtflg))
				goto eof;
			recn = 0;
		}

		bufp = getrec(p->o_currec+recn,dm,wrtflg);
		addit(p,(long) lentail,1);

		if (!ubufr)
		{
			rc = (long) bufp;
			goto exit;
		}

		(*bufxfr)(lentail,bufp,ubufr,wrtflg);
	} /*  end tail bytes  */

eof:	rc = p->o_bytnum - bytpos;
exit:	return(rc);

}

/*
**  addit -
**	update the OFD for the file to reflect the fact that 'siz' bytes
**	have been written to it.
*/

VOID	addit(p,siz,flg)
	REG OFD *p;
	REG long siz;
	int flg; /* update curbyt ? (yes if less than 1 cluster transferred) */
{
	p->o_bytnum += siz;

	if (flg)
		p->o_curbyt += siz;

	if (p->o_bytnum > p->o_fileln)
	{
		p->o_fileln = p->o_bytnum;
		p->o_flag |= O_DIRTY;
	}
}

/*
**  usrio -
**
**	Last modified	SCC	10 Apr 85
**
**	NOTE:	rwabs() is a macro that includes a longjmp() which is executed 
**		if the BIOS returns an error, therefore usrio() does not need 
**		to return any error codes.
*/

usrio(rwflg,num,strt,ubuf,dm)
int rwflg,num,strt;
char *ubuf;
REG DMD *dm;
{
	REG BCB *b;

	for (b = bufl[1]; b; b = b->b_link)
		if ((b->b_bufdrv == dm->m_drvnum) &&
		   (b->b_bufrec >= strt) &&
		   (b->b_bufrec < strt+num))
			flush(b);

	rwabs(rwflg,ubuf,num,strt+dm->m_recoff[2],dm->m_drvnum);
}




