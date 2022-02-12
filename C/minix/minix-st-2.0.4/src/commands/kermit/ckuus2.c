/*  C K U U S 2  --  "User Interface" STRINGS module for Unix Kermit  */
 
/*
 Author: Frank da Cruz (SY.FDC@CU20B),
 Columbia University Center for Computing Activities, January 1985.
 Copyright (C) 1985, Trustees of Columbia University in the City of New York.
 Permission is granted to any individual or institution to use, copy, or
 redistribute this software so long as it is not sold for profit, provided this
 copyright notice is retained. 
*/
 
/*  This module separates long strings from the body of the ckuser module. */  
 
#include "ckcdeb.h"
#include <stdio.h>
#include <ctype.h>
#include "ckcker.h"
#include "ckucmd.h"
#include "ckuusr.h"
 
extern CHAR mystch, stchr, eol, seol, padch, mypadc, ctlq;
extern CHAR data[], *rdatap, ttname[];
extern char cmdbuf[], line[], debfil[], pktfil[], sesfil[], trafil[];
extern int nrmt, nprm, dfloc, deblog, seslog, speed, local, parity, duplex;
extern int turn, turnch, pktlog, tralog, mdmtyp, flow, cmask, timef, spsizf;
extern int rtimo, timint, npad, mypadn, bctr, delay;
extern int maxtry, spsiz, urpsiz, maxsps, maxrps, ebqflg, ebq;
extern int rptflg, rptq, fncnv, binary, pktlog, warn, quiet, fmask, keep;
extern int tsecs, bctu, len, atcapu, lpcapu, swcapu, wsize, sq, rpsiz;
extern int capas;
extern long filcnt, tfc, tlci, tlco, ffc, flci, flco;
extern char *dftty, *versio, *ckxsys;
extern struct keytab prmtab[];
extern struct keytab remcmd[];
 
#ifndef MINIX
static
char *hlp1[] = {
"\n",
"  Usage: kermit [-x arg [-x arg]...[-yyy]..]]\n",
"   x is an option that requires an argument, y an option with no argument:\n",
"     actions (* options also require -l and -b) --\n",
"       -s file(s)   send (use '-s -' to send from stdin)\n",
"       -r           receive\n",
"       -k           receive to stdout\n",
"     * -g file(s)   get remote file(s) from server (quote wildcards)\n",
"       -a name      alternate name, used with -s, -r, -g\n",
"       -x           enter server mode\n",
"     * -f           finish remote server\n",
"     * -c           connect before transaction\n",
"     * -n           connect after transaction\n",
"     settings --\n",
"       -l line      communication line device\n",
"       -b baud      line speed, e.g. 1200\n",
"       -i           binary file or Unix-to-Unix (text by default)\n",
"       -p x         parity, x is one of e,o,m,s,n\n",
"       -t           line turnaround handshake = xon, half duplex\n",
"       -w           don't write over preexisting files\n",
"       -q           be quiet during file transfer\n",
"       -d           log debugging info to debug.log\n",
"       -e length    (extended) receive packet length\n",
" If no action command is included, enter interactive dialog.\n",
""
};
 
/*  U S A G E */
 
usage() {
    conola(hlp1);
}
#else /* MINIX */
usage () {}
#endif /* MINIX */

 
/*  Help string definitions  */
 
#ifndef MINIX
static char *tophlp[] = { "\n\
Type ? for a list of commands, type 'help x' for any command x.\n\
While typing commands, use the following special characters:\n\n\
 DEL, RUBOUT, BACKSPACE, CTRL-H: Delete the most recent character typed.\n\
 CTRL-W: Delete the most recent word typed.\n",
 
"\
 CTRL-U: Delete the current line.\n\
 CTRL-R: Redisplay the current line.\n\
 ?       (question mark) display help on the current command or field.\n\
 ESC     (Escape or Altmode) Attempt to complete the current field.\n",
 
"\
 \\       (backslash) include the following character literally.\n\n\
From system level, type 'kermit -h' to get help about command line args.\
\n",
"" };
 
static char *hmxxbye = "\
Shut down and log out a remote Kermit server";
 
static char *hmxxclo = "\
Close one of the following logs:\n\
 session, transaction, packet, debugging -- 'help log' for further info.";
 
static char *hmxxcon = "\
Connect to a remote system via the tty device given in the\n\
most recent 'set line' command";
 
static char *hmxxget = "\
Format: 'get filespec'.  Tell the remote Kermit server to send the named\n\
files.  If filespec is omitted, then you are prompted for the remote and\n\
local filenames separately.";
 
static char *hmxxlg[] = { "\
Record information in a log file:\n\n\
 debugging             Debugging information, to help track down\n\
  (default debug.log)  bugs in the C-Kermit program.\n\n\
 packets               Kermit packets, to help track down protocol problems.\n\
  (packet.log)\n\n",
 
" session               Terminal session, during CONNECT command.\n\
  (session.log)\n\n\
 transactions          Names and statistics about files transferred.\n\
  (transact.log)\n",
"" } ;

 
static char *hmxxlogi[] = { "\
Syntax: script text\n\n",
"Login to a remote system using the text provided.  The login script\n",
"is intended to operate similarly to uucp \"L.sys\" entries.\n",
"A login script is a sequence of the form:\n\n",
"	expect send [expect send] . . .\n\n",
"where 'expect' is a prompt or message to be issued by the remote site, and\n",
"'send' is the names, numbers, etc, to return.  The send may also be the\n",
"keyword EOT, to send control-d, or BREAK, to send a break.  Letters in\n",
"send may be prefixed by ~ to send special characters.  These are:\n",
"~b backspace, ~s space, ~q '?', ~n linefeed, ~r return, ~c don\'t\n",
"append a return, and ~o[o[o]] for octal of a character.  As with some \n",
"uucp systems, sent strings are followed by ~r unless they end with ~c.\n\n",
"Only the last 7 characters in each expect are matched.  A null expect,\n",
"e.g. ~0 or two adjacent dashes, causes a short delay.  If you expect\n",
"that a sequence might not arrive, as with uucp, conditional sequences\n",
"may be expressed in the form:\n\n",
"	-send-expect[-send-expect[...]]\n\n",
"where dashed sequences are followed as long as previous expects fail.\n",
"" };
 
static char *hmxxrc[] = { "\
Format: 'receive [filespec]'.  Wait for a file to arrive from the other\n\
Kermit, which must be given a 'send' command.  If the optional filespec is\n",
 
"given, the (first) incoming file will be stored under that name, otherwise\n\
it will be stored under the name it arrives with.",
"" } ;
 
static char *hmxxsen = "\
Format: 'send file1 [file2]'.  File1 may contain wildcard characters '*' or\n\
'?'.  If no wildcards, then file2 may be used to specify the name file1 is\n\
sent under; if file2 is omitted, file1 is sent under its own name.";
 
static char *hmxxser = "\
Enter server mode on the currently selected line.  All further commands\n\
will be taken in packet form from the other Kermit program.";
 
static char *hmhset[] = { "\
The 'set' command is used to establish various communication or file\n",
"parameters.  The 'show' command can be used to display the values of\n",
"'set' parameters.  Help is available for each individual parameter;\n",
"type 'help set ?' to see what's available.\n",
"" } ;
 
static char *hmxychkt[] = { "\
Type of packet block check to be used for error detection, 1, 2, or 3.\n",
"Type 1 is standard, and catches most errors.  Types 2 and 3 specify more\n",
"rigorous checking at the cost of higher overhead.  Not all Kermit programs\n",
"support types 2 and 3.\n",
"" } ;

 
static char *hmxyf[] = { "\set file: names, type, warning, display.\n\n",
"'names' are normally 'converted', which means file names are converted\n",
"to 'common form' during transmission; 'literal' means use filenames\n",
"literally (useful between like systems).\n\n",
"'type' is normally 'text', in which conversion is done between Unix\n",
"newlines and CRLF line delimiters; 'binary' means to do no conversion.\n",
"Use 'binary' for executable programs or binary data.\n\n",
"'warning' is 'on' or 'off', normally off.  When off, incoming files will\n",
"overwrite existing files of the same name.  When on, new names will be\n",
"given to incoming files whose names are the same as existing files.\n",
"\n\
'display' is normally 'on', causing file transfer progress to be displayed\n",
"on your screen when in local mode.  'set display off' is useful for\n",
"allowing file transfers to proceed in the background.\n\n",
"" } ;
 
static char *hmhrmt[] = { "\
The 'remote' command is used to send file management instructions to a\n",
"remote Kermit server.  There should already be a Kermit running in server\n",
"mode on the other end of the currently selected line.  Type 'remote ?' to\n",
"see a list of available remote commands.  Type 'help remote x' to get\n",
"further information about a particular remote command 'x'.\n",
"" } ;
#endif /* MINIX */

 
/*  D O H L P  --  Give a help message  */
 
dohlp(xx) int xx; {
    int x,y;

#ifdef MINIX
    return(0);
#else
 
    if (xx < 0) return(xx);
    switch (xx) {
 
case XXBYE:
    return(hmsg(hmxxbye));
 
case XXCLO:
    return(hmsg(hmxxclo));
 
case XXCON:
    return(hmsg(hmxxcon));
 
case XXCWD:
#ifdef vms
    return(hmsg("\
Change Working Directory, equivalent to VMS SET DEFAULT command"));
#else
#ifdef datageneral
    return(hmsg("Change Working Directory, equivalent to DG 'dir' command"));
#else
    return(hmsg("Change Working Directory, equivalent to Unix 'cd' command"));
#endif
#endif
 
case XXDEL:
    return(hmsg("Delete a local file or files"));
 
case XXDIAL:
    return(hmsg("Dial a number using modem autodialer"));
 
case XXDIR:
    return(hmsg("Display a directory of local files"));
 
case XXECH:
    return(hmsg("Display the rest of the command on the terminal,\n\
useful in command files."));
 
case XXEXI:
case XXQUI:
    return(hmsg("Exit from the Kermit program, closing any open logs."));
 
case XXFIN:
    return(hmsg("\
Tell the remote Kermit server to shut down without logging out."));
 
case XXGET:
    return(hmsg(hmxxget));
 
case XXHLP:
    return(hmsga(tophlp));
 
case XXLOG:
    return(hmsga(hmxxlg));
 
case XXLOGI:
    return(hmsga(hmxxlogi));
 
case XXREC:
    return(hmsga(hmxxrc));

 
case XXREM:
    if ((y = cmkey(remcmd,nrmt,"Remote command","")) == -2) return(y);
    if (y == -1) return(y);
    if (x = (cmcfm()) < 0) return(x);
    return(dohrmt(y));
 
case XXSEN:
    return(hmsg(hmxxsen));
 
case XXSER:
    return(hmsg(hmxxser));
 
case XXSET:
    if ((y = cmkey(prmtab,nprm,"Parameter","")) == -2) return(y);
    if (y == -2) return(y);
    if (x = (cmcfm()) < 0) return(x);
    return(dohset(y));
 
case XXSHE:
#ifdef vms
    return(hmsg("\
Issue a command to VMS (space required after '!')"));
#else
#ifdef AMIGA
    return(hmsg("\
Issue a command to CLI (space required after '!')"));
#else
#ifdef datageneral
    return(hmsg("\
Issue a command to the CLI (space required after '!')"));
#else
    return(hmsg("\
Issue a command to the Unix shell (space required after '!')"));
#endif
#endif
#endif
 
case XXSHO:
    return(hmsg("\
Display current values of 'set' parameters; 'show version' will display\n\
program version information for each of the C-Kermit modules."));
 
case XXSPA:
#ifdef datageneral
    return(hmsg("\
Display disk usage in current device, directory,\n\
or return space for a specified device, directory."));
#else
    return(hmsg("Display disk usage in current device, directory"));
#endif
 
case XXSTA:
    return(hmsg("Display statistics about most recent file transfer"));
 
case XXTAK:
    return(hmsg("\
Take Kermit commands from the named file.  Kermit command files may\n\
themselves contain 'take' commands, up to a reasonable depth of nesting."));
 
default:
    if (x = (cmcfm()) < 0) return(x);
    printf("Not available yet - %s\n",cmdbuf);
    break;
    }
    return(0);
#endif /* MINIX */
}

 
/*  H M S G  --  Get confirmation, then print the given message  */
 
hmsg(s) char *s; {
    int x;
    if ((x = cmcfm()) < 0) return(x);
    puts(s);
    return(0);
}
 
hmsga(s) char *s[]; {			/* Same function, but for arrays */
    int x, i;
    if ( x = (cmcfm()) < 0) return(x);
    for ( i = 0; *s[i] ; i++ ) fputs(s[i], stdout);
    fputc( '\n', stdout);
    return(0);
}

 
/*  D O H S E T  --  Give help for SET command  */
 
dohset(xx) int xx; {

#ifdef MINIX
    return(0);
#else
    
    if (xx == -3) return(hmsga(hmhset));
    if (xx < 0) return(xx);
    switch (xx) {
 
case XYCHKT:
    return(hmsga(hmxychkt));
 
case XYDELA: 
    puts("\
Number of seconds to wait before sending first packet after 'send' command.");
    return(0);
 
case XYDUPL:
    puts("\
During 'connect': 'full' means remote host echoes, 'half' means this program");
    puts("does its own echoing.");
    return(0);
 
case XYESC:
    printf("%s","\
Decimal ASCII value for escape character during 'connect', normally 28\n\
(Control-\\)\n");
    return(0);
 
case XYFILE:
    return(hmsga(hmxyf));
 
case XYFLOW:
    puts("\
Type of flow control to be used.  Choices are 'xon/xoff' and 'none'.");
    puts("normally xon/xoff.");
    return(0);
 
case XYHAND:
    puts("\
Decimal ASCII value for character to use for half duplex line turnaround");
    puts("handshake.  Normally, handshaking is not done.");
    return(0);

case XYLINE:
    printf("\
Device name of communication line to use.  Normally %s.\n",dftty);
    if (!dfloc) {
	printf("\
If you set the line to other than %s, then Kermit\n",dftty);
	printf("\
will be in 'local' mode; 'set line' will reset Kermit to remote mode.\n");
    puts("\
If the line has a modem, and if the modem-dialer is set to direct, this");
    puts("\
command causes waiting for a carrier detect (e.g. on a hayes type modem).");
    puts("\
This can be used to wait for incoming calls.");
    puts("\
To use the modem to dial out, first set modem-dialer (e.g., to hayes), then");
    puts("set line, next issue the dial command, and finally connect.");
    }
    return(0);
 
case XYMODM:
    puts("\
Type of modem for dialing remote connections.  Needed to indicate modem can");
    puts("\
be commanded to dial without 'carrier detect' from modem.  Many recently");
    puts("\
manufactured modems use 'hayes' protocol.  Type 'set modem ?' to see what");
    puts("\
types of modems are supported by this program.");
    return(0);
 
 
case XYPARI:
    puts("Parity to use during terminal connection and file transfer:");
    puts("even, odd, mark, space, or none.  Normally none.");
    return(0);
 
case XYPROM:
    puts("Prompt string for this program, normally 'C-Kermit>'.");
    return(0);
 
case XYRETR:
    puts("\
How many times to retransmit a particular packet before giving up");
    return(0);

case XYSPEE:
    puts("\
Communication line speed for external tty line specified in most recent");
#ifdef AMIGA
    puts("\
'set line' command.  Any baud rate between 110 and 292000, although you");
    puts(" will receive a warning if you do not use a standard baud rate:");
    puts("\
110, 150, 300, 600, 1200, 1800, 2400, 4800, 9600, 19200, 38400, 57600.");
#else
#ifdef datageneral
    puts("\
'set line' command.  Any of the common baud rates:");
    puts(" 0, 50, 75, 110, 134, 150, 300, 600, 1200, 1800, ");
    puts(" 2400, 3600, 7200, 4800, 9600, 19200, 38400.");
#else
#ifdef MINIX
    puts("\
'set line' command.  Any of the common baud rates:");
    puts(" 0, 110, 150, 300, 600, 1200, 1800, 2400, 4800, 9600, 19200.");
#else
    puts("\
'set line' command.  Any of the common baud rates:");
    puts(" 0, 110, 150, 300, 600, 1200, 1800, 2400, 4800, 9600.");
#endif
#endif
#endif
    return(0);

case XYRECV:
    puts("\
Specify parameters for inbound packets:");
    puts("\
End-Of-Packet (ASCII value), Packet-Length (1000 or less),");
    puts("\
Padding (amount, 94 or less), Pad-Character (ASCII value),");
    puts("\
Start-Of-Packet (ASCII value), and Timeout (94 seconds or less),");
    puts("\
all specified as decimal numbers.");
    return(0);
 
case XYSEND:
    puts("\
Specify parameters for outbound packets:");
    puts("\
End-Of-Packet (ASCII value), Packet-Length (2000 or less),");
    puts("\
Padding (amount, 94 or less), Pad-Character (ASCII value),");
    puts("\
Start-Of-Packet (ASCII value), and Timeout (94 seconds or less),");
    puts("\
all specified as decimal numbers.");
    return(0);
 
default:
    printf("%s","Not available yet - %s\n",cmdbuf);
    return(0);
    }
#endif /* MINIX */
}

 
/*  D O H R M T  --  Give help about REMOTE command  */
 
dohrmt(xx) int xx; {

#ifdef MINIX
    return(0);
#else

    int x;
    if (xx == -3) return(hmsga(hmhrmt));
    if (xx < 0) return(xx);
    switch (xx) {
 
case XZCWD:
    return(hmsg("\
Ask remote Kermit server to change its working directory."));
 
case XZDEL:
    return(hmsg("\
Ask remote Kermit server to delete the named file(s)."));
 
case XZDIR:
    return(hmsg("\
Ask remote Kermit server to provide directory listing of the named file(s)."));
 
case XZHLP:
    return(hmsg("\
Ask remote Kermit server to tell you what services it provides."));
 
case XZHOS:
    return(hmsg("\
Send a command to the remote system in its own command language\n\
through the remote Kermit server."));
 
case XZSPA:
    return(hmsg("\
Ask the remote Kermit server to tell you about its disk space."));
 
case XZTYP:
    return(hmsg("\
Ask the remote Kermit server to type the named file(s) on your screen."));
 
case XZWHO:
    return(hmsg("\
Ask the remote Kermit server to list who's logged in, or to give information\n\
about the specified user."));
 
default:
    if (x = (cmcfm()) < 0) return(x);
    printf("%s","not working yet - %s\n",cmdbuf);
    return(-2);
    }
#endif /* MINIX */
}

/*** The following functions moved here from ckuusr.c because that module ***/
/*** got too big for PDP-11s. ***/

/*  D O L O G  --  Do the log command  */
 
dolog(x) int x; {
    int y; char *s;
 
    switch (x) {
 
	case LOGD:
#ifdef DEBUG
	    y = cmofi("Name of debugging log file","debug.log",&s);
#else
    	    y = -2; s = "";
	    printf("%s","- Sorry, debug log not available\n");
#endif
	    break;
 
	case LOGP:
	    y = cmofi("Name of packet log file","packet.log",&s);
	    break;
 
	case LOGS:
	    y = cmofi("Name of session log file","session.log",&s);
	    break;
 
	case LOGT:
#ifdef TLOG
	    y = cmofi("Name of transaction log file","transact.log",&s);
#else
    	    y = -2; s = "";
	    printf("%s","- Sorry, transaction log not available\n");
#endif
	    break;
 
	default:
	    printf("\n?Unexpected log designator - %d\n",x);
	    return(-2);
    }
    if (y < 0) return(y);
 
    strcpy(line,s);
    s = line;
    if ((y = cmcfm()) < 0) return(y);
 
/* cont'd... */

/* ...dolog, cont'd */
 
 
    switch (x) {
 
#ifdef DEBUG
	case LOGD:
	    return(deblog = debopn(s));
#endif

	case LOGP:
	    zclose(ZPFILE);
	    y = zopeno(ZPFILE,s);
	    if (y > 0) strcpy(pktfil,s); else *pktfil = '\0';
	    return(pktlog = y);
 
	case LOGS:
	    zclose(ZSFILE);
	    y = zopeno(ZSFILE,s);
	    if (y > 0) strcpy(sesfil,s); else *sesfil = '\0';
	    return(seslog = y);
 
#ifdef TLOG
	case LOGT:
	    zclose(ZTFILE);
	    tralog = zopeno(ZTFILE,s);
	    if (tralog > 0) {
		strcpy(trafil,s);
		tlog(F110,"Transaction Log:",versio,0l);
		tlog(F100,ckxsys,"",0);
		ztime(&s);
		tlog(F100,s,"",0l);
    	    }
	    else *trafil = '\0';
	    return(tralog);
#endif 
	default:
	    return(-2);
    }
}
 
 
/*  D E B O P N  --  Open a debugging file  */
 
debopn(s) char *s; {
#ifdef DEBUG
    char *tp;
    zclose(ZDFILE);
    deblog = zopeno(ZDFILE,s);
    if (deblog > 0) {
	strcpy(debfil,s);
	debug(F110,"Debug Log ",versio,0);
	debug(F100,ckxsys,"",0);
	ztime(&tp);
	debug(F100,tp,"",0);
    } else *debfil = '\0';
    return(deblog);
#else
    return(0);
#endif
}

/*  S H O P A R  --  Show Parameters  */
 
shopar() {
 
    int i;
#ifndef MINIX
    extern struct keytab mdmtab[]; extern int nmdm;
#endif

    printf("\n%s,%s, ",versio,ckxsys); 
    puts("Communications Parameters:");
    printf(" Line: %s, speed: %d, mode: ",ttname,speed);
    if (local) printf("local"); else printf("remote");
 
#ifndef MINIX
    for (i = 0; i < nmdm; i++) {
	if (mdmtab[i].val == mdmtyp) {
	    printf(", modem-dialer: %s",mdmtab[i].kwd);
	    break;
	}
    }
#endif
    printf("\n Bits: %d",(parity) ? 7 : 8);
    printf(", parity: ");
    switch (parity) {
	case 'e': printf("even");  break;
	case 'o': printf("odd");   break;
	case 'm': printf("mark");  break;
	case 's': printf("space"); break;
	case 0:   printf("none");  break;
	default:  printf("invalid - %d",parity); break;
    }		
    printf(", duplex: ");
    if (duplex) printf("half, "); else printf("full, ");
    printf("flow: ");
    if (flow == 1) printf("xon/xoff");
	else if (flow == 0) printf("none");
	else printf("%d",flow);
    printf(", handshake: ");
    if (turn) printf("%d\n",turnch); else printf("none\n");
    printf("Terminal emulation: %d bits\n", (cmask == 0177) ? 7 : 8);
 
    printf("\nProtocol Parameters:   Send    Receive");
    if (timef || spsizf) printf("    (* = override)");
    printf("\n Timeout:      %11d%9d", rtimo,  timint);
    if (timef) printf("*");
    printf("\n Padding:      %11d%9d", npad,   mypadn);
    printf("        Block Check: %6d\n",bctr);
    printf(  " Pad Character:%11d%9d", padch,  mypadc);
    printf("        Delay:       %6d\n",delay);
    printf(  " Packet Start: %11d%9d", mystch, stchr);
    printf("        Max Retries: %6d\n",maxtry);
    printf(  " Packet End:   %11d%9d", seol,   eol);
    if (ebqflg)
      printf("        8th-Bit Prefix: '%c'",ebq);
    printf(  "\n Packet Length:%11d", spsiz);
    printf( spsizf ? "*" : " " ); printf("%8d",  urpsiz);
    printf( (urpsiz > 94) ? " (94)" : "     ");
    if (rptflg)
      printf("   Repeat Prefix:  '%c'",rptq);
    printf(  "\n Length Limit: %11d%9d\n", maxsps, maxrps);
 
    printf("\nFile parameters:\n File Names:   ");
    if (fncnv) printf("%-12s","converted"); else printf("%-12s","literal");
#ifdef DEBUG
    printf("   Debugging Log:    ");
    if (deblog) printf("%s",debfil); else printf("none");
#endif
    printf("\n File Type:    ");
    if (binary) printf("%-12s","binary"); else printf("%-12s","text");
    printf("   Packet Log:       ");
    if (pktlog) printf(pktfil); else printf("none");
    printf("\n File Warning: ");
    if (warn) printf("%-12s","on"); else printf("%-12s","off");
    printf("   Session Log:      ");
    if (seslog) printf(sesfil); else printf("none");
    printf("\n File Display: ");
    if (quiet) printf("%-12s","off"); else printf("%-12s","on");
#ifdef TLOG
    printf("   Transaction Log:  ");
    if (tralog) printf(trafil); else printf("none");
#endif
    printf("\n\nFile Byte Size: %d",(fmask == 0177) ? 7 : 8);
    printf(", Incomplete File Disposition: ");
    if (keep) printf("keep"); else printf("discard");
#ifdef KERMRC    
    printf(", Init file: %s",KERMRC);
#endif
    puts("\n");
}

/*  D O S T A T  --  Display file transfer statistics.  */

dostat() {
    printf("\nMost recent transaction --\n");
    printf(" files: %ld\n",filcnt);
    printf(" total file characters  : %ld\n",tfc);
    printf(" communication line in  : %ld\n",tlci);
    printf(" communication line out : %ld\n",tlco);
    printf(" elapsed time           : %d sec\n",tsecs);
    if (filcnt > 0) {
	if (tsecs > 0) {
	    long lx;
	    lx = (tfc * 10l) / tsecs;
	    printf(" effective baud rate    : %ld\n",lx);
	    if (speed > 0) {
		lx = (lx * 100l) / speed;
		printf(" efficiency             : %ld %%\n",lx);
	    }
	}
	printf(" packet length          : %d (send), %d (receive)\n",
	       spsiz,urpsiz);
	printf(" block check type used  : %d\n",bctu);
	printf(" compression            : ");
	if (rptflg) printf("yes [%c]\n",rptq); else printf("no\n");
	printf(" 8th bit prefixing      : ");
	if (ebqflg) printf("yes [%c]\n",ebq); else printf("no\n\n");
    } else printf("\n");
    return(0);
}

/*  F S T A T S  --  Record file statistics in transaction log  */

fstats() {
    tlog(F100," end of file","",0l);
    tlog(F101,"  file characters        ","",ffc);
    tlog(F101,"  communication line in  ","",flci);
    tlog(F101,"  communication line out ","",flco);
}


/*  T S T A T S  --  Record statistics in transaction log  */

tstats() {
    char *tp; int x;

    ztime(&tp);				/* Get time stamp */
    tlog(F110,"End of transaction",tp,0l);  /* Record it */

    if (filcnt < 1) return;		/* If no files, done. */

/* If multiple files, record character totals for all files */

    if (filcnt > 1) {
	tlog(F101," files","",filcnt);
	tlog(F101," total file characters   ","",tfc);
	tlog(F101," communication line in   ","",tlci);
	tlog(F101," communication line out  ","",tlco);
    }

/* Record timing info for one or more files */

    tlog(F101," elapsed time (seconds)  ","",(long) tsecs);
    if (tsecs > 0) {
	x = (tfc / tsecs) * 10;
	tlog(F101," effective baud rate     ","",x);
	if (speed > 0) {
	    x = (x * 100) / speed;
	    tlog(F101," efficiency (percent)    ","",x);
	}
    }
    tlog(F100,"","",0);			/* Leave a blank line */
}

/*  S D E B U  -- Record spar results in debugging log  */

sdebu(len) int len; {
    debug(F111,"spar: data",rdatap,len);
    debug(F101," spsiz ","", spsiz);
    debug(F101," timint","",timint);
    debug(F101," npad  ","",  npad);
    debug(F101," padch ","", padch);
    debug(F101," seol  ","",  seol);
    debug(F101," ctlq  ","",  ctlq);
    debug(F101," ebq   ","",   ebq);
    debug(F101," ebqflg","",ebqflg);
    debug(F101," bctr  ","",  bctr);
    debug(F101," rptq  ","",  rptq);
    debug(F101," rptflg","",rptflg);
    debug(F101," atcapu","",atcapu);
    debug(F101," lpcapu","",lpcapu);
    debug(F101," swcapu","",swcapu);
    debug(F101," wsize ","", wsize);
}
/*  R D E B U -- Debugging display of rpar() values  */

rdebu(len) int len; {
    debug(F111,"spar: data",rdatap,len);
    debug(F101," rpsiz ","",xunchar(data[1]));
    debug(F101," rtimo ","", rtimo);
    debug(F101," mypadn","",mypadn);
    debug(F101," mypadc","",mypadc);
    debug(F101," eol   ","",   eol);
    debug(F101," ctlq  ","",  ctlq);
    debug(F101," sq    ","",    sq);
    debug(F101," ebq   ","",   ebq);
    debug(F101," ebqflg","",ebqflg);
    debug(F101," bctr  ","",  bctr);
    debug(F101," rptq  ","",data[9]);
    debug(F101," rptflg","",rptflg);
    debug(F101," capas ","",capas);
    debug(F101," bits  ","",data[capas]);
    debug(F101," atcapu","",atcapu);
    debug(F101," lpcapu","",lpcapu);
    debug(F101," swcapu","",swcapu);
    debug(F101," wsize ","", wsize);
    debug(F101," rpsiz(extended)","",rpsiz);
}
