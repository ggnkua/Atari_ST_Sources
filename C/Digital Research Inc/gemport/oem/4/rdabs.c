/*  rdabs.c -						*/
/*
MODIFICATION HISTORY

	20 AUG 85	LTG	Added drive check in rwas() to not return MEDIA_CHANGE
				error if on fixed disk and eject floppy.
NAMES

	LTG	Lou T. Garavaglia
*/

#define MEDIA_CHANGE -14L

/*
**  OLDRWABS - set to true if you want to use the old rwabs routine.  this 
** 	should be removed (and code inside the oldrwabs conditional) after
**	the 'aug 15' release.
*/

#define	OLDRWABS	1

extern char nsect[];
char *pbase = (char*) 0xFC0000  ;
char *prof,*pdat;
char pstat[4]; /* profile status bytes */
int iprstat;	/* profile interrupt state */
int proflg,shkerr, pcmd, nx;
int newdsk; /* sony disk has changed */

 /* convert disk to hw #, only 1 profile supported at this time */
 /* 	drv = 0xd9;  internal */
 /*	drv = 0x68;  slot 2, port B */
int drv[] = { 0xD9, 0x68 /*0x28, 0x20*/ } ;
				/* slot 1 port B (upper), slot 1 A (lower) */

dskinit()
{
	proinit(0x00D9); /* internal profile */
	proinit(drv[0]);
	/* proinit(drv[1]); */
}

proinit(d)
int d;
{
	char b;
	register char *prof;
	prof = pbase + ((((long) (d << 8))) & 0x0000ffffL);
	pdat = prof + 9;
	prof[0x11] |= 0xa0; /* ddrb */
	prof[0x01] |= 0xa0;	/* orb some reset signals */
	prof[0x71] = 0x80;
	prof[0x61] = 0x6a;	/* int on busy high - pcr */
	prof[0x59] = 0;	/* acr */
	prof[0x19] = 0;	/* ddra all input now */
	prof[0x11] &= 0xfc;	/* more ddrb changes */
	prof[0x11] |= 0x1c;
	prof[0x01] &= 0xfb;	/* disk enable */
	prof[0x01] |= 0x18;	/* set r/w (r), CMD* inactive */
	while (!(prof[0x01] & 2)); /* wait for BUSY* inactive */
	prof[0x69] = 0;	/* clear IFR */
	do
	{
		prof[0x69] = (b = prof[0x69]);
	} while (b);
	prof[0x71] = 0x82;	/* int on ca1 (BSY) only */
}

/*
**  rwabs -
**	check for media change, then do something rediculous like
**	call another routine to read each sector, one at a time,
**	into the user's buffer. (ahem).
*/

long	rwabs( wrtflg , bufr , num , recn , drive )
	int	wrtflg , num , recn , drive ;
	char	*bufr;
{

#if	OLDRWABS		
	int i,rtn;
	if (newdsk && (drive == 0))
	{
		newdsk = 0;
		return(MEDIA_CHANGE);
	}
        for (i = 0; i < num; i++,recn++)
        {
	    if (rtn = dskrw(((long) recn),bufr,wrtflg,drive)) break;
	    bufr += 512;
        }
        return(rtn);
#else


	int i,rtn;

	if ((newdsk) && (drive < 2))
	{
		newdsk = 0 ;
		rtn = (int) MEDIA_CHANGE ;
	}
        else for (i = 0; i < num; i++,recn++)
        {
	    if(   rtn = dskrw( (long) recn, bufr, wrtflg, drive )   ) 
		break;
	    bufr += 512;
        }

        return(rtn);
#endif
}

/***** twiggy disk handler ******/
flprw(blk,buffer,rw,drive)
long blk;
int rw,drive;
char *buffer;
{ /* map this sector # onto the disk (# is 0 - 1701) */
	int trk,sec,head,iblk,ns,ns2;
	iblk = blk;
	drive = 0x0080;
	head = 0;
	sec = 0;
	for (trk = 0; trk < 80; sec += nsect[trk++]) if (iblk < sec) break;
	sec -= nsect[--trk];
	iblk -= sec;
	/* almost ready, but now the kicker... heavy duty skewing here */
	ns = (nsect[trk] + 1) >> 1;
	ns2 = ns << 1;
	/* skew by 2 */
	sec = ((iblk << 1) + (iblk / ns)) % ns2;
	/* and now for something completely different */
	fdisk(drive,trk,head,buffer,rw,sec);
	return(0);
}	


/****** profile disk handler *****/

prostat()
{
	int i;
	*(prof + 1)    |= 8;
	*(prof + 0x19)  = 0;
	for (i=0; i<4; i++) pstat[i] = *(prof + 9);
}


dskrw(blk,buffer,rw,drive)
long blk;
int rw,drive;
char *buffer;
{
	int i,j;
	char x;
	if (drive < 2) return(flprw(blk,buffer,rw,drive));
	prof = pbase + ((((long) (drv[drive-2] << 8))) & 0x0000ffffL);
	pdat = prof + 9;
	x = 0 ;
	if (blk == 0) x = 0xAA;
	if (shake(1)) return(1);
	*pdat = rw;
	*pdat = blk >> 16; /* blk # hi byte */
	*pdat = blk >> 8;  /* blk # mid byte */
	*pdat = blk++ ;	   /* blk # lo byte */
	if (!rw)
	{
		*pdat = 105;  /* retry         */
		*pdat = 53;   /* sparing count */
	}
	if (shake(rw+2)) return(1);
	switch(rw)
	{
		case 0:
			prostat();
			for (j=0; j<20 ; j++) x = *pdat ;
			for (j=0; j<512; j++) *buffer++ = *pdat ;
			break;
		case 1:
			for (j=0; j<20 ; j++) *pdat = x;
			for (j=0; j<512; j++) *pdat = *buffer++;
		 /* there's a whole lotta shakin goin on */
			shake(6);
			prostat();
			break;
	}
	shake(4);  /* special shake */
	return(0); /* ok */
}

shake(n)
int n;
{
	char *prx; /* local prof variable */
	prx = prof;
	iprstat = 0;
	shkerr = 0;
	pcmd = 0x55;
	if (n == 4)
	{
		nx = 1;
		pcmd = 0xAA;
	}
	else nx = n;
	*(prx + 0x19)  = 0;	/* ddra = in */
	*(prx + 1)    |= 8;	/* dir = in */
	bcli();
	*(prx + 0x61) &= 0xFE; /* int on busy high */
	*(prx + 1)    &= 0xEF; /* set CMD high */
	bsti();
	while (!proflg);
	proflg = 0;
	return(shkerr);
}

proint()
{
	char *prx;
	char a;
	prx = prof;
	*(prx + 0x61) |= 0x0e;	/* hold ca2 high */
	a = *(prx + 9);		/* read a to clear */
	*(prx + 0x61) &= 0xfb;	/* restore ca2 pulse */
	switch(iprstat)
	{
		case 0:
			iprstat++;
			if (a != nx) shkerr = 1;
			*(prx + 1)    &= 0xF7; /* dir = out */
			*(prx + 0x19)  = 0xFF; /* ddra = out */
			*(prx + 0x79)  = pcmd;	/* send 55 or special */
			*(prx + 0x61) |= 1;	/* int on busy low */
			*(prx + 1)    |= 0x10; /* lower CMD */
			break;
		case 1:
			proflg = 1;
	}
}
