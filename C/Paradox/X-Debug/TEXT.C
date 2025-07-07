/* text strings used in Mon */

#include "mon.h"
#include "version.h"

#if DEMO
#define	NAMETX	"X-Debug Demo"
#else
#define NAMETX	"X-Debug"
#endif

char *TX_MOVEME=	" - MOVE WINDOW - ";
char *TX_DOSERROR=	"DOS error %d";

char *TX_NONSTDDEBUG=	"Non-standard debug information ignored";
char *TX_NODEBUGINFO=	"No debugging information found";
char *TX_DEBUGOK=		"%ld global symbols read";
char *TX_LOADING=		" - loading program\n";
char *TX_SOURCEDB=		"%ld global symbols and line number info read";
char *TX_SCOPEDDB=		"%ld asm syms, %ld scoped syms & line info read";
char *TX_READINGDEBUG=	"(reading source debug)\n";
char *TX_READINGSYMS=	"(reading symbols)\n";

char *TX_TERMINATED=	"Program terminated (return code=%d)\n";
char *TX_EXCEPTION=		"%s at PC=%s\n";

char *TX_LATTICE5ST=	"(Lattice 5 ST) ";
char *TX_TURBOC=		"(Turbo C) ";
char *TX_BASIC=			"(HiSoft BASIC) ";

char *TX_BRKLIST=		"#%d at $%lX %s %s %s%c";
char *TX_BRKLIST2=		"#%d at $%lX %s %lX %s%c";

char *TX_DURING=		"%s while reading %s\n";

char *TX_ADVERT=		NAMETX" "VERSIONTX" ½ Andy Pennell 1993";
char *TX_ADVERTDEBUG=	NAMETX" "VERSIONTX" DEBUG by Andy Pennell";
char *TX_AADVERT=		NAMETX" Resident "VERSIONTX" ½ Andy Pennell 1993";
char *TX_COPYRIGHT=		"Copyright ½ 1993 Andy Pennell. All Rights Reserved\n\
Distributed by The ST Club, 2 Broadway, Nottingham NG1 1PS. 0602 410241\n";
char *TX_TSR=			NAMETX" "VERSIONTX" resident (%ld bytes)\n";

char *TX_SYMBOLMENU=	"Symbol Chooser";
char *TX_CHOOSEFILE=	"Source File Chooser";

char *TX_ALERTERROR=	"Error";

char *TX_CANNOTOPENSOURCE="Cannot open source file:";
char *TX_CANNOTOPENSOURCES="Cannot open source files. First:";

char *TX_WHILETERMINATING="**DANGER** trying to terminate but:\n";

char *TX_DSTART=		"Debugger TPA start";
char *TX_DEND=			"Debugger TPA end";
char *TX_MEMFREE=		"GEMDOS free bytes";
char *TX_STFREE=		"ST RAM free";
char *TX_TTFREE=		"TT RAM free";
char *TX_DFREE=			"Debugger heap end";
char *TX_MEMFREE2=		"Debugger free bytes";

char *TX_FOUND=			"Found at $%08lx\n";
char *TX_NOTFOUND=		"Not found\n";

char *TX_MORE=			"More...";
char *TX_YN=			"YN";
char *TX_ASKQUIT=		"Exit debugger Y/N?";
char *TX_ASKQUIT2=		"Kill program and exit debugger Y/N?";

char *TX_HELPNOTFOUND=	"Help on '%s' not found\n";
char *TX_HELPMORE=		"HELP <command> for more info\n";
char *TX_HELPNOFILE=	"No " HELP_STARTUP " file\n";
char *TX_HELPBRIEF=		"SYSTEM to quit, LIST HELP for all\n";

char *TX_EXPIRED=		"(additional files ignored - out of RAM)\n";

char *TX_BADSYM=		"(unknown address)\n";

char *TX_FATALERROR(short code)
{
static char ebuf[60];
char *p;

	switch (code)
		{
		case RET_NOMEM:
			p="out of memory"; break;
		case RET_NOGRAPHICS:
			p="graphics mode not recognised"; break;
		case RET_BADMEM:
			p="must load into ST RAM"; break;
		default:
			p="unknown"; break;
		}
	sprintf(ebuf,"Fatal error: %s\nPress any key",p);
	return ebuf;
}

char *TX_EXNAME(short e)
{
static char ebuf[30];

	if ( (e>=32) && (e<=47) )
		e=EXNUM_UNUSEDTRAP;

	switch (e)
		{
		case 0: return "Program terminated";
		case 1: return "Breakpoint";
		case 2: return "Bus error";
		case 3: return "Address error";
		case 4: return "Illegal exception";
		case 5: case 50: return "Divide by zero";
		case 6: return "CHK instruction";
		case 7: return "TRAPcc instruction";
		case 8: return "Privilege violation";
		case 9: return "Trace";
		case 10: return "Line A exception";
		case 11: return "Line F exception";
		case 13: return "Coproc violation";
		case 14: return "Format error";
		case 48: return "BSUN";
		case 49: return "Inexact";
		case 51: return "Underflow";
		case 52: return "Operand error";
		case 53: return "Overflow";
		case 54: return "Signalling NAN";
		case 56: return "MMU configuration error";
		case EXNUM_UNKNOWN: return "Unknown exception (DANGER)";
		case EXNUM_TRAP: return "TRAP breakpoint";
		case EXNUM_UNUSEDTRAP: return "bad TRAP";
		default:
			sprintf(ebuf,"Exception %d",e);
			return ebuf;
		}
}

char *TX_BRKTYPE(word t)
{
	switch (t)
		{
		case BTYPE_COUNT:	return "after=";
		case BTYPE_RECORD:	return "count=";
		case BTYPE_ALWAYS:	return "permanent";
		case BTYPE_COND:	return "conditional=";
		case BTYPE_TRACE:	return "(temporary)=";
		default:			return "*unknown*";
		}
}

const char *TX_ERROR(word e)
{
	switch (e)
		{
case ERRM_BADP: 		return "bad parameter";
case ERRM_BADCOMMAND:	return "bad command";
case ERRM_BADEXPRESSION:return "bad expression";
case ERRM_BADWINDOW:	return "bad window";
case ERRM_NOSPARE:		return "no spare window";
case ERRM_NOMEMORY:		return "out of memory";
case ERRM_SYMNOTFOUND:	return "symbol not found";
case ERRM_INVALIDSYM:	return "invalid symbol";
case ERRM_ODD:			return "odd address";
case ERRM_BRKFULL:		return "too many breakpoints";
case ERRM_NOWRITE:		return "cannot write";
case ERRM_ALREADYLOADED:return "already loaded";
case ERRM_NOSYSMEM:		return "out of system memory";
/*case ERRM_DOSERR:		return "DOS error";*/
case ERRM_NORUN:		return "cannot run";
/*case ERRM_UNIXERR:		return "UNIX error";*/
case ERRM_READERROR:	return "read error";
case ERRM_BADFILEFORMAT:return "bad file format";
case ERRM_AMBIGUOUS:	return "ambiguous command";

case ERRE_ITEMOVERFLOW:	return "item overflow";
case ERRE_OPOVERFLOW:	return "op overflow";
case ERRE_BADEXP:		return "bad expression";
case ERRE_OPUNDERFLOW:	return "op underflow";
case ERRE_ITEMUNDERFLOW:return "item underflow";
case ERRE_BADOP:		return "invalid operator";
case ERRE_LEFTOVER:		return "further expression expected";
case ERRE_NOOPENBRACKET:return "too many close brackets";
case ERRE_NOCLOSEBRACKET:return "no close bracket";
case ERRE_BADCOERCION:	return "cannot coerce";
case ERRE_DIV0:			return "divide by zero";
case ERRE_BADQUOTES:	return "error in quoted string";
case ERRE_LONGSTRING:	return "string too long";
case ERRE_NUMBERTOOBIG:	return "number too big";
case ERRE_BADNUMBER:	return "invalid number";
case ERRE_CRAPAFTER:	return "garbage following expression";

case ERRI_ODD:			return "INTERNAL:odd";
case ERRI_BADTYPE:		return "INTERNAL:bad type";

case ERRM_INTERRUPTED:	return "(interrupted)";
case ERRM_TOOLONG:		return "command too long";
case ERRM_BADAPARAM:	return "invalid alias/proc parameter";
case ERRM_FILENOTFOUND:	return "could not open file";
case ERRM_READONLYVAR:	return "read only symbol";
case ERRM_DEFINE:		return "definition error";
case ERRM_NOSOURCE:		return "no source line";
case ERRM_NOSTACK:		return "debugger stack overflow";
case ERRM_CANNOTKILL:	return "cannot kill program";
case ERRM_NOFINDSOURCE:	return "source line/file not found";
case ERRM_BRKNOTFOUND:	return "breakpoint not found";
case ERRM_NOPROG:		return "no program loaded";
case ERRM_LONGONLY:		return "long-sized registers only";
case ERRM_PNOTREADY:	return "printer device not ready";
case ERRM_NOSYMBOLS:	return "no user symbols";
case ERRM_TABLEFULL:	return "table full";
case ERRM_NOMMU:		return "MMU not available";
case ERRM_NOTYET:		return "not yet implemented";
case ERRM_NODCR:		return "no descriptor";
case ERRM_BADLEVEL:		return "bad descriptor level";
case ERRM_BADVIRTUAL:	return "virtual memory";
case ERRM_DCRDIFFERENT:	return "descriptors differ";
case ERRM_OVERLAPSMON:	return "address clashes";
case ERRM_BADFORMAT:	return "invalid format specifier";
case ERRM_WRITEERROR:	return "write error";
case ERRM_TTREG:		return "TT register overlap";
case ERRM_FNNOTFOUND:	return "file/function not found";
#if DEMO
case ERRM_NOTINDEMO:	return "not available in demo version";
#endif
default:	return "unknown error";		
	}
}

char *TX_NOSOURCE=	"Source (file not available)";
char *TX_MODIFIED=	" (CHANGED)";

char *wdef_title(byte wtype)
{
static char procstring[50];

	switch (wtype)
		{
		case WTYPE_REGS:
			sprintf(procstring,"%ld Registers",68000+proctype);
			return procstring;
		case WTYPE_DISS:	return "Disassembly";
		case WTYPE_MEM:		return "Memory";
		case WTYPE_ASCII:	return "ASCII";
		case WTYPE_SMART:	return "Source";
		case WTYPE_DEAD:	return "Dead";
		case WTYPE_WATCH:	return "Watch";
		case WTYPE_BREAK:	return "Breakpoints";
		case WTYPE_MMU:		return "MMU";
		case WTYPE_LOCAL:	return "Locals";
		case WTYPE_FPU:
			switch (fputype)
				{
				case 81: return "FPU 68881"; break;
				case 82: return "FPU 68882"; break;
				case 40: return "FPU 68040"; break;
				default: return "FPU (None)"; break;
				}
			break;
		default:			return "Unknown";
		}
}
