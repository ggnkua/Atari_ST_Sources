/*
HEADER: 	;
TITLE: 		Frankenstein Cross Assemblers;
VERSION: 	2.0;
DESCRIPTION: "	Reconfigurable Cross-assembler producing Intel (TM)
		Hex format object records.  ";
SYSTEM: 	UNIX, MS-Dos ;
FILENAME: 	fraosub.c;
WARNINGS: 	"This software is in the public domain.  
		Any prior copyright claims are relinquished.  

		This software is distributed with no warranty whatever.  
		The author takes no responsibility for the consequences 
		of its use."  ;
SEE-ALSO: 	frasmain.c;
AUTHORS: 	Mark Zenier;
*/

/*
	description	output pass utility routines
	history		September 27, 1987
			March 15, 1988   release 1.1 WIDTH
			September 14, 1990  Dosify, 6 char unique names
*/


#include <stdio.h>
#include "frasmdat.h"
#include "fragcon.h"

#define OUTRESULTLEN 256
#define NUMHEXPERL 16
#define SOURCEOFFSET 24
#define NUMHEXSOURCE 6

int linenumber = 0;
char lineLbuff[INBUFFSZ];
int lineLflag = FALSE;

static unsigned char	outresult[OUTRESULTLEN];
static int	nextresult;
static long 	genlocctr, resultloc;

static char	*oeptr;

#define	MAXIMPWID	24

static long widthmask[MAXIMPWID+1] =
{
/* 0 */		1L,
/* 1 */		1L,
/* 2 */		(1L <<  2 ) -1,
/* 3 */		(1L <<  3 ) -1,
/* 4 */		(1L <<  4 ) -1,
/* 5 */		(1L <<  5 ) -1,
/* 6 */		(1L <<  6 ) -1,
/* 7 */		(1L <<  7 ) -1,
/* 8 */		(1L <<  8 ) -1,
/* 9 */		(1L <<  9 ) -1,
/* 10 */	(1L <<  10 ) -1,
/* 11 */	(1L <<  11 ) -1,
/* 12 */	(1L <<  12 ) -1,
/* 13 */	(1L <<  13 ) -1,
/* 14 */	(1L <<  14 ) -1,
/* 15 */	(1L <<  15 ) -1,
/* 16 */	(1L <<  16 ) -1,
/* 17 */	(1L <<  17 ) -1,
/* 18 */	(1L <<  18 ) -1,
/* 19 */	(1L <<  19 ) -1,
/* 20 */	(1L <<  20 ) -1,
/* 21 */	(1L <<  21 ) -1,
/* 22 */	(1L <<  22 ) -1,
/* 23 */	(1L <<  23 ) -1,
/* 24 */	(1L <<  24 ) -1
};
	

static long dgethex()
/*
	description	convert the character string pointed to by
			the output expression pointer to a long integer
	globals		oeptr, the output expression pointer
	return		the value
*/
{
	long rv = 0;

	while( *oeptr != '\0')
	{
		switch(*oeptr)
		{
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			rv = (rv << 4) + ((*oeptr) - '0');
			break;

		case 'a':
		case 'b':
		case 'c':
		case 'd':
		case 'e':
		case 'f':
			rv = (rv << 4) + ((*oeptr) - 'a' + 10);
			break;
		
		case 'A':
		case 'B':
		case 'C':
		case 'D':
		case 'E':
		case 'F':
			rv = (rv << 4) + ((*oeptr) - 'A' + 10);
			break;

		default:
			return rv;
		}

		oeptr++;
	}

	return rv;
}
	

outphase()
/*
	description	process all the lines in the intermediate file
	globals		the input line
			the output expression pointer
			line number
			file name
			the binary output array and counts
*/
{
	int firstchar;

	for(;;)
	{
		if((firstchar = fgetc(intermedf)) == EOF)
			break;

		if(firstchar == 'L')
		{
			if(listflag)
				flushlisthex();

			if( fgets(&lineLbuff[1], INBUFFSZ-1, intermedf) 
			 == (char *)NULL)
			{
		frp2error( "error or premature end of intermediate file");
				break;
			}

			lineLflag = TRUE;
		}
		else
		{
			finbuff[0] = firstchar;
			if(fgets( &finbuff[1], INBUFFSZ-1, intermedf) 
			 == (char *)NULL)
			{
		frp2error("error or premature end of intermediate file");
				break;
			}
		}
	
		switch(firstchar)
		{
		case 'E': /* error */
			if(listflag)
			{
				flushsourceline();
				fputs(&finbuff[2], loutf);
			}
			else
			{
				fprintf(loutf, "%s - line %d - %s", 
					currentfnm, linenumber, &finbuff[2]);
			}
			break;

		case 'L': /* listing */
			linenumber++;
			break;

		case 'C': /* comment / uncounted listing */
			if(listflag)
			{
				char *stuff = strchr(finbuff, '\n');

				if(stuff != NULL)
					*stuff = '\0';

				fprintf(loutf,"%-*.*s", 
				 SOURCEOFFSET, SOURCEOFFSET, &finbuff[2]);
				if(lineLflag)
				{
					fputs(&lineLbuff[2], loutf);
					lineLflag = FALSE;
				}
				else
				{
					fputc('\n', loutf);
				}
			}
			break;

		case 'P': /* location set */
			oeptr = &finbuff[2];
			currseg = dgethex();
			oeptr++;
			genlocctr = locctr = dgethex();
			break;
		
		case 'D': /* data */
			oeptr = &finbuff[2];
			nextresult = 0;
			resultloc = genlocctr;
			outeval();
			if(hexflag)
				outhexblock();
			if(listflag)
				listhex();
			break;
		
		case 'F': /* file start */
			{
				char *tp;
				if( (tp = strchr(finbuff,'\n')) != (char *)NULL)
					*tp = '\0';
				strncpy(currentfnm, &finbuff[2], 100);
				currentfnm[99] = '\0';
			}
			lnumstk[currfstk++] = linenumber;
			linenumber = 0;
			break;
		
		case 'X': /* file resume */
			{
				char *tp;
				if( (tp = strchr(finbuff,'\n')) != (char *)NULL)
					*tp = '\0';
				strncpy(currentfnm, &finbuff[2], 100);
				currentfnm[99] = '\0';
			}
			linenumber = lnumstk[--currfstk];
			break;

		default:
			frp2error("unknown intermediate file command");
			break;
		}
	}

	if(hexflag)
		flushhex();

	if(listflag)
		flushlisthex();
}

outeval()
/*
	description	convert the polish form character string in the 
			intermediate file 'D' line to binary values in the
			output result array.
	globals		the output expression pointer
			the output result array
*/
{
	register long etop = 0;

	register struct evstkel *estkm1p = &estk[0];

	while( *oeptr != '\0')
	{
		switch(*oeptr)
		{
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			etop = (etop << 4) + ((*oeptr) - '0');
			break;

		case 'a':
		case 'b':
		case 'c':
		case 'd':
		case 'e':
		case 'f':
			etop = (etop << 4) + ((*oeptr) - 'a' + 10);
			break;
		
		case 'A':
		case 'B':
		case 'C':
		case 'D':
		case 'E':
		case 'F':
			etop = (etop << 4) + ((*oeptr) - 'A' + 10);
			break;

#include "fraeuni.h"
#include "fraebin.h"
		case IFC_SYMB:
			{
				struct symel *tsy;

				tsy = symbindex[etop];
				if(tsy -> seg <= 0)
				{
					frp2undef(tsy);
					etop = 0;
				}
				else
				{
					if(tsy -> seg == SSG_EQU ||
					   tsy -> seg == SSG_SET)
					{
			frp2warn( "forward reference to SET/EQU symbol");
					}
					etop = tsy -> value;
				}
			}
			break;

		case IFC_CURRLOC: 
			etop = genlocctr;
			break;

		case IFC_PROGCTR:
			etop = locctr;
			break;

		case IFC_DUP:
			if(estkm1p >= &estk[PESTKDEPTH-1])
			{
				frp2error("expression stack overflow");
			}
			else
			{
				(++estkm1p)->v = etop;
			}
			break;

		case IFC_LOAD:
			if(estkm1p >= &estk[PESTKDEPTH-1])
			{
				frp2error("expression stack overflow");
			}
			else
			{
				(++estkm1p)->v = etop;
			}
			etop = 0;
			break;

		case IFC_CLR:
			etop = 0;
			break;

		case IFC_CLRALL:
			etop = 0;
			estkm1p = &estk[0];
			break;

		case IFC_POP:
			etop = (estkm1p--)->v;
			break;

		case IFC_TESTERR:
			if(etop)
			{
				frp2error(
			"expression fails validity test");
			}
			break;

		case IFC_SWIDTH:
			if( etop > 0 && etop <= MAXIMPWID)
			{
				if( estkm1p->v < -(widthmask[etop-1]+1) ||
				    estkm1p->v > widthmask[etop-1] )
				{
					frp2error(
				"expression exceeds available field width");
				}
				etop = ((estkm1p--)->v)  & widthmask[etop];
			}
			else
				frp2error("unimplemented width");
			break;

		case IFC_WIDTH:
			if( etop > 0 && etop <= MAXIMPWID)
			{
				if( estkm1p->v < -(widthmask[etop-1]+1) ||
				    estkm1p->v > widthmask[etop] )
				{
					frp2error(
				"expression exceeds available field width");
				}
				etop = ((estkm1p--)->v)  & widthmask[etop];
			}
			else
				frp2error("unimplemented width");
			break;

		case IFC_IWIDTH:
			if( etop > 0 && etop <= MAXIMPWID)
			{
				if( estkm1p->v < 0 ||
				    estkm1p->v > widthmask[etop] )
				{
					frp2error(
				"expression exceeds available field width");
				}
				etop = ((estkm1p--)->v)  & widthmask[etop];
			}
			else
				frp2error("unimplemented width");
			break;

		case IFC_EMU8:
			if( etop >= -128 && etop <= 255)
			{
				outresult[nextresult++] = etop & 0xff;
			}
			else
			{
				outresult[nextresult++] = 0;
				frp2error(
			"expression exceeds available field width");
			}
			genlocctr ++;
			etop = 0;
			break;

		case IFC_EMS7:
			if(etop >= -128 && etop <= 127)
			{
				outresult[nextresult++] = etop & 0xff;
			}
			else
			{
				outresult[nextresult++] = 0;
				frp2error(
			"expression exceeds available field width");
			}
			genlocctr ++;
			etop = 0;
			break;

		case IFC_EM16:
			if(etop >= -32768L && etop <= 65535L)
			{
				outresult[nextresult++] = (etop >> 8) & 0xff;
				outresult[nextresult++] = etop & 0xff;
			}
			else
			{
				outresult[nextresult++] = 0;
				outresult[nextresult++] = 0;
				frp2error(
			"expression exceeds available field width");
			}
			genlocctr += 2;
			etop = 0;
			break;

		case IFC_EMBR16:
			if(etop >= -32768L && etop <= 65535L)
			{
				outresult[nextresult++] = etop & 0xff;
				outresult[nextresult++] = (etop >> 8) & 0xff;
			}
			else
			{
				outresult[nextresult++] = 0;
				outresult[nextresult++] = 0;
				frp2error(
			"expression exceeds available field width");
			}
			genlocctr += 2;
			etop = 0;
			break;

		default:
			break;
		}
		oeptr++;
	}
}

static long lhaddr, lhnextaddr;
static int lhnew, lhnext = 0;
static unsigned char listbuffhex[NUMHEXPERL];

flushlisthex()
/*
	description	output the residue of the hexidecimal values for
			the previous assembler statement.
	globals		the new hex list flag
*/
{
	listouthex();
	lhnew = TRUE;
}

listhex()
/*
	description	buffer the output result to block the hexidecimal 
			listing on the output file to NUMHEXPERL bytes per
			listing line.
	globals		The output result array and count
			the hex line buffer and counts
*/
{
	register int cht;
	register long inhaddr = resultloc;

	if(lhnew)
	{
		lhaddr = lhnextaddr = resultloc;
		lhnew = FALSE;
	}

	for(cht = 0; cht < nextresult; cht++)
	{
		if(lhnextaddr != inhaddr 
		 || lhnext >= (lineLflag ? NUMHEXSOURCE : NUMHEXPERL ) )
		{
			listouthex();
			lhaddr = lhnextaddr = inhaddr;
		}
		listbuffhex[lhnext++] = outresult[cht];
		lhnextaddr ++;
		inhaddr ++;
	}
}

listouthex()
/*
	description	print a line of hexidecimal on the listing
	globals		the hex listing buffer
*/
{
	register int cn;
	register int tc;

	if(lhnext > 0)
	{
		fputc(hexch((int)lhaddr>>12), loutf);
		fputc(hexch((int)lhaddr>>8), loutf);
		fputc(hexch((int)lhaddr>>4), loutf);
		fputc(hexch((int)lhaddr), loutf);
		fputc(' ', loutf);

		for(cn = 0; cn < lhnext; cn++)
		{
			fputc(hexch((int)(tc = listbuffhex[cn])>>4), loutf);
			fputc(hexch(tc), loutf);
			fputc(' ', loutf);
		}

		if( ! lineLflag)
			fputc('\n', loutf);
	}

	if(lineLflag)
	{
		if(lineLbuff[2] != '\n')
		{
			switch(lhnext)
			{
			case 0:
				fputs("\t\t\t",loutf);
				break;
			case 1:
			case 2:
			case 3:
				fputs("\t\t",loutf);
				break;
			case 4:
			case 5:
			case 6:
				fputs("\t",loutf);
			default:
				break;
			}

			fputs(&lineLbuff[2], loutf);
			lineLflag = FALSE;
		}
		else
		{
			fputc('\n', loutf);
		}
	}
		
	lhnext = 0;
}

#define INTELLEN 32

static long nextoutaddr, blockaddr;
static int hnextsub;
static char hlinebuff[INTELLEN];


outhexblock()
/*
	description	buffer the output result to group adjacent output
			data into longer lines.
	globals		the output result array
			the intel hex line buffer
*/
{
	long inbuffaddr = resultloc;
	static int first = TRUE;

	int loopc;

	if(first)
	{
		nextoutaddr = blockaddr = resultloc;
		hnextsub = 0;
		first = FALSE;
	}

	for(loopc = 0; loopc < nextresult; loopc++)
	{
		if(nextoutaddr != inbuffaddr || hnextsub >= INTELLEN)
		{
			intelout(0, blockaddr, hnextsub, hlinebuff);
			blockaddr = nextoutaddr = inbuffaddr;
			hnextsub = 0;
		}
		hlinebuff[hnextsub++] = outresult[loopc];
		nextoutaddr++;
		inbuffaddr++;
	}
}

flushhex()
/*
	description	flush the intel hex line buffer at the end of
			the second pass
	globals		the intel hex line buffer
*/
{
	if(hnextsub > 0)
		intelout(0, blockaddr, hnextsub, hlinebuff);
	if(endsymbol != SYMNULL && endsymbol -> seg > 0)
		intelout(1, endsymbol -> value, 0, "");
	else
		intelout(1, 0L, 0, "");
		
}


intelout(type, addr, count, data)
	int type;
	long addr;
	int count;
	char data[];
/*
	description	print a line of intel format hex data to the output
			file
	parameters	see manual for record description
*/
{
	register int temp, checksum;

	fputc(':', hexoutf);
	fputc(hexch(count>>4),hexoutf);
	fputc(hexch(count),hexoutf);
	fputc(hexch((int)addr>>12),hexoutf);
	fputc(hexch((int)addr>>8),hexoutf);
	fputc(hexch((int)addr>>4),hexoutf);
	fputc(hexch((int)addr),hexoutf);
	fputc(hexch(type>>4),hexoutf);
	fputc(hexch(type),hexoutf);

	checksum = ((addr >> 8) & 0xff) + (addr & 0xff) + (count & 0xff);
	checksum += type & 0xff;

	for(temp = 0; temp < count; temp ++)
	{
		checksum += data[temp] & 0xff;
		fputc(hexch(data[temp] >> 4), hexoutf);
		fputc(hexch(data[temp]), hexoutf);
	}

	checksum = (-checksum) & 0xff;
	fputc(hexch(checksum>>4), hexoutf);
	fputc(hexch(checksum), hexoutf);
	fputc('\n',hexoutf);
}


frp2undef(symp)
	struct symel * symp;
/*
	description	second pass - print undefined symbol error message on
			the output listing device.  If the the listing flag
			is false, the output device is the standard output, and
			the message format is different.
	parameters	a pointer to a symbol table element
	globals		the count of errors
*/
{
	if(listflag)
	{
		flushsourceline();
		fprintf(loutf," ERROR -  undefined symbol %s\n", symp ->symstr);
	}
	else
		fprintf(loutf, "%s - line %d - ERROR - undefined symbol  %s\n", 
			currentfnm, linenumber, symp -> symstr);
	errorcnt++;
}

frp2warn(str)
	char * str;
/*
	description	second pass - print a warning message on the listing
			file, varying the format for console messages.
	parameters	the message
	globals		the count of warnings
*/
{
	if(listflag)
	{
		flushsourceline();
		fprintf(loutf, " WARNING - %s\n", str);
	}
	else
		fprintf(loutf, "%s - line %d - WARNING - %s\n", 
			currentfnm, linenumber, str);
	warncnt++;
}


frp2error(str)
	char * str;
/*
	description	second pass - print a message on the listing file
	parameters	message
	globals		count of errors
*/
{
	if(listflag)
	{
		flushsourceline();
		fprintf(loutf, " ERROR - %s\n", str);
	}
	else
		fprintf(loutf, "%s - line %d - ERROR - %s\n", 
			currentfnm, linenumber, str);
	errorcnt++;
}

flushsourceline()
/*
	description	flush listing line buffer before an error for
			that line is printed
*/
{
	if(listflag && lineLflag)
	{
		fputs("\t\t\t", loutf);
		fputs(&lineLbuff[2], loutf);
		lineLflag = FALSE;
	}
}
