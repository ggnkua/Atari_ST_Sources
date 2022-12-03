/*
	xmdm.c of Gulam -- Xmodem Send / Receive Module

	Generic Xmodem send/receive code posted to SIG*ATARI on CompuServe
	adapted by bammi@cwru.edu, and later by pm@cwru.edu	03/13/87
 */

#include "gu.h"
#include <setjmp.h>

#ifdef STANC
# define P_(s) s
#else
# define P_(s) ()
#endif
local xmdm P_((int rsc, char *fnm));
local int cancel P_((char *p));
local checksector P_((uint16 checksum));
local recvsector P_((void));
local sendsector P_((void));
local sendeot P_((void));
#undef P_

			 	/* Xmodem specific defines */
#define	SECSIZ		0x80	/* Size of a xmodem sector/block */
#define	ERRORMAX	20	/* MAX ERRORS BEFORE ABORT very conservative */
#define	RETRYMAX	15	/* MAXIMUM RETRYS BEFORE ABORT */
#define	SOH		1	/* START OF SECTOR CHAR */
#define	EOT		4	/* end of transmission char */
#define	ACK		6	/* acknowledge sector transmission */
#define	NAK		21	/* error in transmission detected */
#define CAN		('X'&037) /* Cancel transmission	  */

/*
0         1         2         3         4         5         6     
012345678901234567890123456789012345678901234567890123456789012345
bytes 123456789 packets 123 errors 123 timeouts 123 rx filename...
*/
#define	SZXMRS	85

#define	BYTES		8
#define	BYTESEND	15	/* byte ctr ends 1 char left of this */
#define	PACKETS		24	/* #pkts bgn here	*/
#define	ERRORS		35	/* #errs bgn here	*/
#define	TIMEOUTS	48	/* #tmos bgn here	*/
#define	MESSAGE		55
#define	FILENAME	55
#define	RSX		52

local	char	xmrs[SZXMRS];
local	char	xmi[SZXMRS] =
"bytes         0 packets 000 errors 000 timeouts 000 rx ?";


local	char	COF[]	= "> Cannot open file <";
local	char	TCS[]	= "> Transfer cancelled by sender <";
local	char	TCR[]	= "> Transfer cancelled by receiver <";
local	char	EWF[]	= "> Error writing file -- aborting <";
local	char	ERF[]	= "> Error reading file -- aborting <";
local	char	TMO[]	= "> Too many time outs -- aborting <";
local	char	TME[]	= "> Too many errors -- aborting <";
local	char	RNK[]	= "> Receiver not sending NAK's -- aborting <";
local	char	NNS[]	= "> No acknowledgment of sector -- aborting <";

uchar	*bufr;			/* file buffer */
long	BUFSIZ;			/* size of this buffer	*/

jmp_buf abort_env, 		/* Long jump when transfers are aborted */
        time_env; 		/* Long jump on timeout		  */


#ifdef	DEBUG
local	int 	debug = 1;
#define	dprintf	printf
#define	mlwrite	printf
#endif

local	int
	fd,			/* File descriptor for opened file */
	bufptr,			/* Ptr to file buffer	 */
	mtimeout,		/* Time out period 		*/
	npsent, 		/* #packets sent successfully 	*/
	nprecd, 		/* #packets received successfully */
	npackets, 		/* #packets received/sent 	*/
	npdup,	 		/* #duplicate Packets 		*/
	npbad, 	/* #bad packets 		*/
	ntimeout, 		/* #Timeouts 			*/
	nnaked; 	/* #naked packets 		*/

local	uint
	sectnum,	/* The currently expected sector # 	*/
	sectors,	/* The received/sent sector # 		*/
	sectcomp,	/* The 1's complements of sectcurr	*/
	errors,		/* #errors encountered in this recv	*/
	attempts,	/* #of attempts to send  		*/
	errorflag;	/* Just a flag 				*/

local sint32 nbx;   /* #bytes sent/received sucessfully */

	local
xmdm(rsc, fnm)
register	char	rsc, *fnm;
{
	register char	*p, *q;
	register int	ok;
	
	BUFSIZ	= 0x4000;		/* ask for this much, and see ... */
	bufr = maxalloc(&BUFSIZ); if (bufr == NULL) {valu = ENSMEM; return;}

#ifdef DEBUG
	dprintf("max allocd %d\n", BUFSIZ);
#endif
	mtimeout = 10;
	nbx = 0L;
	ntimeout = npbad = nnaked = 0;
	npsent = nprecd = npackets = npdup = 0;
	fd = -1; ok = TRUE;

	if (setjmp(abort_env))
	{	emsg = "> User Aborted Transfer. <";
		ok = FALSE;
		goto ret;
	}
	setrs232speed();
	setrs232buf();
	offflowcontrol();

	ok = (rsc == 'r'? recvfile(fnm) :  sendfile(fnm));

	ret:
	onflowcontrol();

	maxfree(bufr);
   if (!ok) cancel(emsg);
	resetrs232buf();
}

/* Entry points for Gulam: initialize variables for a Xmodem transfers
and invoke the recv/send routine.  */

rxmdm(p) register char	*p; {xmdm('r', p);}
sxmdm(p) register char	*p; {xmdm('s', p);}

/* Cancel the transfer */

	local int
cancel(p)
register char	*p;
{
	register int i;
	
	if (fd >= 0) gfclose(fd); fd = -1;

	for(i = 0; i < 5; i++)  sendchar(CAN);

	/* Get rid of 4 of them, some receivers expect at least 2
	   CAN to confirm that the first CAN was not a corrupted
	   ACK, but eat only one (Ymodem for instance). */
	   
	for(i = 0; i < 4; i++)	    sendchar('\b');

	alarm(0);
	flushinput();
	emsg = p; valu = -1;
	return FALSE;
}

/* Open file for read/write, and send the remote cmd to remote system
*/

	int
openfile(file, rs)
register char	*file;
int		rs;
{	register char	*p, *q;

	fd = MINFH-1;
	if (rs == 's')
	{	fd = gfopen(file, 0);
		p  = "sx_remote_cmd";
	} else
	{	if (flnotexists(file) ||
		   mlyesno(sprintp(
		   "file '%s' exists; overwrite it?", file)))
		{	fd = gfcreate(file, 0);
			p  = "rx_remote_cmd";
	}	}
	if (fd < MINFH) return FALSE;
	p = varstr(p);
	if (p && *p)	/* send the cmd to get the remote mc started */
	{	if (q = rindex(file, '\\')) q++; else q = file;
		q = sprintp("%s %s\r\n", p, q);
		writemodem(q, ((int)strlen(q)));
	}
	xmmsginit(rs, file);
	return TRUE;
}

	local
checksector(checksum)
register uint16 checksum;
{	register uint16 recvcsum;

	recvcsum = readmodem();
	if  (checksum == recvcsum)
	{	nprecd++; sectnum++; errors = 0;
		bufptr += SECSIZ;
		nbx += SECSIZ;
		ufbbytes(nbx);

		if (bufptr == BUFSIZ)
		{	/* Buffer Full - flush it out to file */
			bufptr = 0;
			if (gfwrite(fd, bufr, BUFSIZ) != (sint32)BUFSIZ)
				return cancel(EWF);
		}
		flushinput ();
		sendchar(ACK); /* Every thing ok - send the ACK */
	} else
	{	/* Received checksum does not match computed checksum */
		ufb(ERRORS, ++npbad);
		errorflag = TRUE;
#ifdef DEBUG
		if (debug) dprintf("Checksum mismatch %d %d", checksum, recvcsum);
#endif
}	}

/* Try hard to receive one sector */

	local
recvsector()
{
	register uint16	checksum;
	register int	j;

	sectors = readmodem();
	sectcomp = readmodem();
	
	ufb(PACKETS, ++npackets);
	
#ifdef DEBUG
	if (debug) dprintf("Sector %d  %d\n", sectors, sectcomp);
#endif
	if ((sectors + sectcomp) == (unsigned) 255) /* => Valid sector # */
	{	if (sectors == ((sectnum + 1) & 0xff))
		{	/* And sector in expected sequence */
			checksum = 0;
			for (j = bufptr;j < (bufptr + SECSIZ);j++)
			{	bufr[j] = readmodem(); /* Pick up data */
				checksum = (checksum + bufr[j]) & 0xff;
			}
			checksector(checksum);
		}
		else
		{	/* Sector received is not the expected one */
			/* Could be a duplicate sector, or just a corrupted sector */
			if (sectors == (sectnum & 0xff))
			{	/* Duplicate sector - just ignore it and ACK */
				flushinput();
				sendchar(ACK);
			} else
			{	/* Garbage */
				ufb(ERRORS, ++npbad);
				errorflag = TRUE;
#ifdef DEBUG
				if (debug) dprintf("sync error\n");
#endif
	}	}	}
	else
	{
		ufb(ERRORS, ++npbad);
		errorflag = TRUE;
#ifdef DEBUG
		if (debug) dprintf("sector number error\r\n");
#endif
}	}

/* Xmodem Receive: We use extremely conservative timeout/retry
parameters to deal with lazy dogs like CompuServe.  The program could
be enhanced to be adaptive by increasing the timeout as and when
timeouts occur, dynamically.  */

recvfile(file)
register char *file;
{
	register int firstchar;	/* of the packet	*/
	
	if (openfile(file, 'r') == FALSE) return FALSE;
	sectnum = errors = bufptr = 0;
	
    r_again:
	flushinput();
	sendchar(NAK);	/* Send NAK to let sender know that we are ready */
#ifdef	DEBUG
	dprintf("sent first NAK\r\n");
#endif	
	if (setjmp(time_env))
	{	if(++errors < ERRORMAX)	/* On a Timeout */
		{	ufb(TIMEOUTS, ++ntimeout);
			goto r_again;
		}
		return cancel(TMO);
	}
	
	firstchar = 0;
	while (firstchar != EOT && errors != ERRORMAX)
	{	errorflag = FALSE;
		alarm (mtimeout);			/* set timeout trap */
		do					/* get sync char */
		{	firstchar = readmodem();
#ifdef DEBUG
			if (debug) dprintf("Got char %d \r\n", firstchar);
#endif
		} while (firstchar != SOH && firstchar != EOT && firstchar != CAN);
		
		if( firstchar == CAN) return cancel(TCS);
		if (firstchar == SOH) recvsector();
		if (errorflag == TRUE){errors++; flushinput(); sendchar(NAK);}
	}
	if ((firstchar == EOT) && (errors < ERRORMAX))
	{	sendchar(ACK);	/* Last packet */
		if(gfwrite(fd, bufr, bufptr) != bufptr)
			return cancel(EWF);
		gfclose(fd);
		alarm(0);
		mlwrite("%s\r\n%D bytes received.\r\n",
			xmrs, nbx);
		return(TRUE);
	}
	return cancel(TME);
}

/* Send packet: Make no more than RETRYMAX attempts on errors; if too many
timeouts, just cancel send */

	local
sendsector()
{	register uint16	checksum;
	register uint	c;
	register int	j;

	attempts = 0;
	do
	{
	    s_ag2:
		alarm(mtimeout);
		if (setjmp(time_env))
		{	if(attempts < (2*ERRORMAX))	/* on time out */
			{	ufb(TIMEOUTS, ++ntimeout);
				flushinput();
				goto s_ag2;
			}
			return cancel(TMO);
		}
		/* Send a packet */
		ufb(PACKETS, ++npackets);
		sendchar(SOH);	sendchar(sectnum); sendchar(~sectnum);
		writemodem(&bufr[bufptr], SECSIZ);
		checksum = 0;
		for (j = bufptr; j < (bufptr+SECSIZ); j++)
		    checksum += bufr[j];
		sendchar(checksum);
		flushinput();
		npsent++;
		
		attempts++;
		c = readmodem();		/* Did it get sent over ? */
		if (c != ACK)  ufb(ERRORS, ++nnaked);
#ifdef DEBUG
		if (debug)  dprintf("Response char is %d\r\n", c);
#endif
		if( c == CAN )
			return cancel(TCR);
	} while ((c != ACK) && (attempts < RETRYMAX));
	return (c == ACK);
}

/* All sectors that needed to be sent are done.  Now send the EOT to
complete transfer.  The EOT may or may not get ACK'ed, warn the user
if it does'nt */

	local
sendeot()
{	register char	*p;
	
	attempts = 0;
	do
	{ s_ag3:
		alarm(mtimeout);
		if (setjmp(time_env))
		{	if(attempts < (2*ERRORMAX))
			{	ufb(TIMEOUTS, ++ntimeout);
				flushinput();
				goto s_ag3;
		}	}
		sendchar(EOT);
		attempts++;
	} while ((readmodem() != ACK) && (attempts != RETRYMAX));
	alarm(0);
	p =  (attempts == RETRYMAX
	? "%s\r\n%D bytes sent; EOF acknowledgment not received though!\r\n"
	: "%s\r\n%D bytes sent.\r\n");
	mlwrite(p, xmrs, nbx);
}

/* Xmodem Send -- See comments for readfile() concerning timeouts/retries.
*/
	int 
sendfile(file)
register char *file;
{
	register char	c;
	register int	j;
	register int	nb;

	if (openfile(file, 's') == FALSE) return FALSE;
	sectnum = 1;	j = 0;	attempts = 0;
	do {
	    s_again:
		if (setjmp(time_env))
		{	if(attempts < (2*ERRORMAX)) /* On Time Out */
			{	ufb(TIMEOUTS, ++ntimeout);
				flushinput();
				goto s_again;
			}
			return cancel(TMO);
		}
		alarm(mtimeout); /* Wait for First char from receiver */
		c = readmodem();
#ifdef DEBUG
		if (debug) dprintf("Ate char %d\r\n", c);
#endif
		/* Eat everything but a NAK or CAN */
	} while ((c != NAK) && (c != CAN) && (j++ < (ERRORMAX*2)));
	
	if( c == CAN)
		return cancel(TCR);
	if (j >= (ERRORMAX*2))
		return cancel(RNK);
	
#ifdef DEBUG
	if (debug) dprintf ("Got ACK\r\n");
#endif

	flushinput (); /* Get rid of any junk on the line */
	alarm(mtimeout);
	while ((j = gfread(fd, bufr, BUFSIZ)) && (attempts != RETRYMAX))
	{	if (j < 0)
		 return cancel(ERF);
		nb = j;
		while (j < BUFSIZ) bufr[j++] = (char) 0;  /* pm */

		for (bufptr = 0; bufptr < nb; bufptr += SECSIZ)
		{	ufbbytes(nbx);
			sendsector();
			if (attempts >= RETRYMAX) break;
			nbx += SECSIZ;
			sectnum++;
		}
	}
	gfclose(fd); fd = -1;
	if (attempts >= RETRYMAX)
		return cancel(NNS);
	else	sendeot();
	return TRUE;
}

/* display module for rx/sx	*/

xmmsginit(rsc, s)
register char	rsc, *s;
{	register int	n;

	cpymem(xmrs, xmi, MESSAGE);
	xmrs[RSX] = rsc;

	n = strlen(s); if (n > SZXMRS-MESSAGE-1 ) n =  SZXMRS-MESSAGE-1;
	cpymem(xmrs+MESSAGE, s, n);
	xmrs[n+MESSAGE] = '\000';
	mlmesgne(xmrs);
}

ufb(x, n)
register int	x, n;
{
	xmrs[x+2] = n%10 + '0';		n /= 10;
	xmrs[x+1] = n%10 + '0';		n /= 10;
	xmrs[x]   = n%10 + '0';
	mlmesgne(xmrs);
}

/* Updates the bytes display  */

ufbbytes(count)
register sint32 count;
{
	register char	*p;
	register int	j, k;

	p = itoa(count);
	k = strlen(p);
	j = BYTESEND-k;
	while (xmrs[j++] = *p++);
	xmrs[BYTESEND] = ' ';
	mlmesgne(xmrs);
}

/* -eof- */
