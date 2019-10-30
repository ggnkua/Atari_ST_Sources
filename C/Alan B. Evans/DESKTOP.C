/*	DESKTOP.PRG Program		   by W. Alan B. Evans,
					   [wabe@ukc.ac.uk]  March 1992.

   If put in AUTO-FOLDER of "booting" RDY-ramdisk will ensure that any
DESKTOP.INF file in the ramdisk's root directory will be copied to C:\
(if C:\ exists) where the newer TOS-Versions will look for it.

   With TOS 2.06 NEWDESK.INF (or DESKTOP.INF) should be copied to
C:\NEWDESK.INF and this is now done in the DESKTOP.TOS (Version_2? of
DESKTOP.PRG). The TOS Version is also printed out - and it is still smaller
than 2048 bytes so will only pinch 2 clusters of your ramdisk!!
						wabe	May 1993.
*/

#include <osbind.h>

#define		TOSPTR		(*(unsigned short **)0x4f2)

extern	char *strcpy(),*gts();

main()

{	long st;	char file[60];
	unsigned short tos;	char *itoa();

/*   This is escape from "BOOT & WARMSTART" loop caused by faulty ACC's etc.
     since it enables one to invoke a simple non-GEM shell e.g ME.TOS,
     COMMAND.PRG, RDYSH.PRG or GULAM.PRG etc. to rename the offending ACC
     or boot program
*/
	if (Cconis()== -1 && (Crawcin() & 0x5f) == 'X') {
	Cconws("\r\n  FULL PATH\\NAME OF PROGRAM TO BE EXECUTED: ");
	Pexec(0,gts(file),"\0","\0");
	}

/*   Get Tos_Version	*/
	st= Super(0L);
	tos = *(TOSPTR+1);
	Super(st);

/*   Might as well print it out			*/
	Cconws("\r\n  Tos_Version = \033p"); Cconws(itoa(tos >> 8,file,16));
	Cconout('.'); if ((tos & 0x00FF) < '\020') Cconout('0');
	Cconws(itoa((tos & 0x00FF),file,16));	Cconws("\033q\r\n");

	if ((long)Drvmap() & 04L)
	if (tos >= 0x104)      /*  STE TOS Present!	*/
/*  Ensure the proper DESKTOP.INF file is looked at by new TOS  */
	{ if (tos < 0x200)
	st= fc("DESKTOP.INF\0","C:\\DESKTOP.INF\0");
	else	if (st= fc("NEWDESK.INF\0","C:\\NEWDESK.INF\0"))
		st= fc("DESKTOP.INF\0","C:\\NEWDESK.INF\0");
	}
/*  Execute the 40-Folder Patch Prog if found on C:\ with old TOS  */
	else  Pexec(0,"C:\\FOLDR???.PRG\0","\0","\0");

Pterm(st);
}


/*
*   A useful File_Copying subroutine - preserves date_stamp on old TOS  
*/

int fc(file1,file2)
char *file1,*file2;

{	register char *buf;
	int i,handle1,handle2,nsects,nsecmax,erc,no_tms,info[2];
	long lo,nrw,flngth;

	erc= 0;	buf= 0;
	if ((nsecmax = (int)(Malloc(-1L)/0x200L)-4) < 0)
	{ gemdos(9,"\r\n  INSUFFICIENT MEMORY!! ");  goto end;	}

	if ((handle1 = Fopen(file1,0)) < 0) return(-1);
	Fdatime(info,handle1,0);
	flngth= Fseek(0L,handle1,2);
	nsects= 1+(int)(flngth/0x200L);
	if ((no_tms= nsects/nsecmax) == 0) nsecmax= nsects;

	if ((handle2 = Fopen(file2,0)) > 0)
	{ Fclose(handle2); Fdelete(file2);	}
	if ((handle2 = Fcreate(file2,0)) < 0 )
	{ gemdos(9,"\r\n Fcreate FAILURE - COULD NOT OPEN FILE: ");
	gemdos(9,file2);	--erc; goto end; }

	if ((buf= (char *)Malloc((long)nsecmax*0x200L+0x200L)) == 0)
	{ gemdos(9,"\r\n Malloc FAILURE!!! "); --erc; goto end; }
	Cconws("\r  Copying "); Cconws(file1);
	Cconws(" to "); Cconws(file2);  Cconws("\r\n ");
	i=-1; while (i++ < no_tms)
	{ if (i == no_tms) nrw= flngth- (long)nsecmax*0x200L*i;
	else  nrw= (long)nsecmax*0x200;

	{ if ((lo= Fseek((long)nsecmax*0x200L*i,handle1,0) < 0) 
	|| (lo=Fread(handle1,nrw,buf)) != nrw)
	{ gemdos(9,"\r\n Fseek or Fread FAILURE");  --erc; goto end;	}
	}

	{ if ((lo= Fseek((long)(nsecmax*0x200L*i),handle2,0) < 0) 
	|| (lo= Fwrite(handle2,nrw,buf)) != nrw)
	{ gemdos(9,"\r\n Fseek or Fwrite FAILURE!  DISK FULL? "); --erc; goto end; }
	}
	}    /*  end of i loop  */

end:	if (!Fclose(handle2))
	{ if (erc < 0) Fdelete(file2); else
	{ handle2=Fopen(file2,0); Fdatime(info,handle2,1); Fclose(handle2); }
	}
	if (buf != 0) Mfree(buf);
return(erc);
}


/*
		Cheap & minimal gets alternative
	(  An economical alternative to "gets" - does not, however
 	respond to CNTRL-C on the Older TOSes	)
*/
char *gts(data)
char *data;
{	register char *p = data;
	while ((*p=gemdos(1)) != '\r')
	if (*p == '\010') { --p; Cconws(" \010"); } else p++;
	*p= '\0';
	if (*data)	return(data);	else	return((char *)0);
}

/*   Some code, pinched from Sozobon, for converting numbers to asci
     & used above to print out the TOS Version - it is extremely economical
*/

char	_numstr[] = "0123456789ABCDEF";

char *ultoa(n, buffer, radix)
	register unsigned long n;
	register char *buffer;
	register int radix;
	{
	register char *p = buffer;
	char *strrev();

	do
		{
		*p++ = _numstr[n % radix];	/* grab each digit */
		}
		while((n /= radix) > 0);
	*p = '\0';
	return(strrev(buffer));			/* reverse and return it */
	}

char *ltoa(n, buffer, radix)
	register long n;
	register char *buffer;
	int radix;
	{
	register char *p = buffer;

	if (n < 0)
		{
		*p++ = '-';
		n = -n;
		}
	ultoa(n, p, radix);
	return(buffer);
	}

char *itoa(n, buffer, radix)
	int n;
	char *buffer;
	int radix;
	{
	char *ltoa();

	return(ltoa(((long) n), buffer, radix));
	}


char *strrev(string)
	char *string;
	{
	register char *p = string, *q, c;

	if(*(q = p))		/* non-empty string? */
		{
		while(*++q)
			;
		while(--q > p)
			{
			c = *q;
			*q = *p;
			*p++ = c;
			}
		}
	return(string);
	}
