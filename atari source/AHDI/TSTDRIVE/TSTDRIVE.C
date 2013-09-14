/* 
 * TSTDRIVE.C	ml.	Oct 10 1989
 *
 * Front end to test all driver routines (ACSI or SCSI).
 */
 
#include	<osbind.h>
#include	"define.h"

WORD	hex;
WORD	useblit;
BYTE	spscsixst;

extern 	WORD	untrdy(), rqsense(), format(), hread(), hwrite(),
		inquiry(), mdselect(), mdsense(), stunit(),
		readcap(), xtdread(), xtdwrt();
		
extern	WORD	recal(), ideread(), idewrite(), verify(), fmtunt(), 
		seek(), diag(), initparm(), rsbuf(), wsbuf(), 
		identify(), standby(), active(), sbwto(), awto(), 
		ssc(), sbres();
main()
{
	BYTE	command[80], *askbuf(), *buf;
	UWORD	head, cyl, spt;
	UWORD	pdev, count, len, pcode, pcf, inlv, pmi;
	WORD	ret;
	LONG	oldssp;
	LONG	sect, size, asksect(), asksize();

	useblit = 0;
	spscsixst = (BYTE)chkspscsi();
	hex = TRUE;		/* default to hex mode */
	oldssp = Super(0L);
	while (1) {
		command[0] = 78;
		usrprompt("\nCommand: ", &command[0]);
		
		if (!strcmp(&command[2], "tstunit")) {
			pdev = askpdev();
			ret = untrdy(pdev);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "rqsense")) {
			pdev = askpdev();
			len = asklen();
			buf = askbuf();
			ret = rqsense(pdev, len, buf);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "format")) {
			pdev = askpdev();
			inlv = askinlv();
			ret = format(pdev, inlv);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "hread")) {
			sect = asksect();
			count = askcnt();
			buf = askbuf();
			pdev = askpdev();
			ret = hread(sect, count, buf, pdev);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "hwrite")) {
			sect = asksect();
			count = askcnt();
			buf = askbuf();
			pdev = askpdev();
			ret = hwrite(sect, count, buf, pdev);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "inquiry")) {
			pdev = askpdev();
			len = asklen();
			buf = askbuf();
			ret = inquiry(pdev, len, buf);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "mdselect")) {
			pdev = askpdev();
			len = asklen();
			buf = askbuf();
			ret = mdselect(pdev, len, buf);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "mdsense")) {
			pdev = askpdev();
			pcode = askpcode();
			pcf = askpcf();
			len = asklen();
			buf = askbuf();
			ret = mdsense(pdev, pcode, pcf, len, buf);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "start")) {
			pdev = askpdev();
			ret = stunit(pdev, 1);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "stop")) {
			pdev = askpdev();
			ret = stunit(pdev, 0);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "readcap")) {
			pdev = askpdev();
			pmi = askpmi();
			sect = asksect();
			buf = askbuf();
			ret = readcap(pdev, pmi, sect, buf);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "xread")) {
			sect = asksect();
			count = askcnt();
			buf = askbuf();
			pdev = askpdev();
			ret = xtdread(sect, count, buf, pdev);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "xwrite")) {
			sect = asksect();
			count = askcnt();
			buf = askbuf();
			pdev = askpdev();
			ret = xtdwrt(sect, count, buf, pdev);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "malloc")) {
			size = asksize();
			reply((LONG)Malloc(size));
/*
		} else if (!strcmp(&command[2], "dump")) {
			buf = askbuf();
			dump(buf);
/**/
		} else if (!strcmp(&command[2], "identify")) {
			pdev = askpdev();
			buf = askbuf();
			ret = identify(pdev, buf);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "recal")) {
			pdev = askpdev();
			ret = recal(pdev);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "initparm")) {
			pdev = askpdev();
			head = askhead();
			spt = askspt();
			ret = initparm(pdev, head, spt);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "seek")) {
			pdev = askpdev();
			cyl = askcyl();
			head = askhead();
			ret = seek(pdev, head, cyl);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "iread")) {
			head = askhead();
			spt = askspt();
			sect = asksect();
			count = askcnt();
			buf = askbuf();
			pdev = askpdev();
			ret = ideread(head, spt, sect, count, buf, pdev);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "iwrite")) {
			head = askhead();
			spt = askspt();
			sect = asksect();
			count = askcnt();
			buf = askbuf();
			pdev = askpdev();
			ret = idewrite(head, spt, sect, count, buf, pdev);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "verify")) {
			sect = asksect();
			count = askcnt();
			pdev = askpdev();
			ret = verify(sect, count, pdev);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "fmtunt")) {
			pdev = askpdev();
			ret = fmtunt(pdev);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "diag")) {
			ret = diag();
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "rsbuf")) {
			pdev = askpdev();
			buf = askbuf();
			ret = rsbuf(pdev, buf);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "wsbuf")) {
			pdev = askpdev();
			buf = askbuf();
			ret = wsbuf(pdev, buf);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "standby")) {
			pdev = askpdev();
			ret = standby(pdev);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "active")) {
			pdev = askpdev();
			ret = active(pdev);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "sbwto")) {
			pdev = askpdev();
			count = askcnt();
			ret = sbwto(pdev, count);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "awto")) {
			pdev = askpdev();
			count = askcnt();
			ret = awto(pdev, count);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "ssc")) {
			pdev = askpdev();
			ret = ssc(pdev);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "sbres")) {
			pdev = askpdev();
			ret = sbres(pdev);
			reply((LONG)ret);
		} else if (!strcmp(&command[2], "help")) {
			
		} else if (!strcmp(&command[2], "hex")) {
			hex = TRUE;
			reply(0L);
		} else if (!strcmp(&command[2], "dec")) {
			hex = FALSE;
			reply(0L);
		} else {
			Cconws("\n\rInvalid command...");
		}
	}
	Super(oldssp);
	Pterm0();
}	


askpdev()
{
	return (ask4int("Physical unit #: "));
}


askcyl()
{
	return (ask4int("Cylinder #: "));
}


askhead()
{
	return (ask4int("Head #: "));
}


askspt()
{
	return (ask4int("Sectors Per Track: "));
}


asklen()
{
	return (ask4int("Length requesting (in bytes): "));
}


askinlv()
{
	return (ask4int("Interleave factor: "));
}


LONG
asksect()
{
	LONG	ask4long();
	
	return (ask4long("Starting sector #: "));
}


LONG
asksize()
{
	LONG	ask4long();
	
	return (ask4long("Size of buffer to be allocated: "));
}


askcnt()
{
	return (ask4int("Count: "));
}


askpcode()
{
	return (ask4int("Pcode: "));
}


askpcf()
{
	return (ask4int("Pcf: "));
}


askpmi()
{
	return (ask4int("Pmi: "));
}


BYTE *
askbuf()
{
	BYTE	response[80];
	LONG	size, asksize(), buf;
	
askagn:	response[0] = 78;
	usrprompt("Buffer address: ", &response[0]);
	if (!strcmp(&response[2], "malloc")) {
		size = asksize();
		reply(Malloc(size));
		goto askagn;
	}
	
	if (hex)
		htol(&response[2], &buf);
	else
		atol(&response[2], &buf);
		
	return ((BYTE *)buf);
}


ask4int(prompt)
BYTE	*prompt;
{
	BYTE	response[80];
	
	response[0] = 78;
	usrprompt(prompt, &response[0]);
	if (hex)
		return (htoi(&response[2]));
	else
		return (atoi(&response[2]));
}


LONG
ask4long(prompt)
BYTE	*prompt;
{
	BYTE	response[80];
	LONG	ret;
	
	response[0] = 78;
	usrprompt(prompt, &response[0]);
	if (hex)
		htol(&response[2], &ret);
	else
		atol(&response[2], &ret);
		
	return (ret);
}


usrprompt(prompt, response)
BYTE	*prompt;
BYTE	*response;
{
	Cconws("\n\r");
	Cconws(prompt);
	while (!Cconis())		/* waiting for character */
		;
	Cconrs(response);
	*(response+(*(response+1)+2)) = 0;	/* NULL terminated */
}


reply(ret)
LONG	ret;
{
	BYTE	result[10];
	
	if (hex)
		ltoh(ret, result);
	else
		ltoa(ret, result);
		
	Cconws("\n\rReturns: ");
	Cconws(result);
}



