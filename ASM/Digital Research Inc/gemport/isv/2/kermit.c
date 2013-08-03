/*
 *  K e r m i t	 File Transfer Utility
 *
 *  Permission for use of KERMIT (file transfer protocal) has been
 *  granted by Columbia University Center for Computer Activities
 *
 *
 *  GEMDOS Kermit, Digital Research, 1984, 1985
 *
 *  usage:  kermit c [lbiphe line baud par escape-char]	to connect
 *	    kermit s [ddzinlbpqt line baud par] file ...to send files
 *	    kermit r [ddzinlbpqt line baud par]		to receive files
 *	    kermit g [ddzinlbpqt line baud par] file ...to get files
 *	    kermit v [ddzinlbpqt line baud par]         to enter server mode
 *
 *	    kermit f [ddz]      to shut down remote server
 *	    kermit x [ddz]      to shut down remote server and logout remote
 *
 *  where   c=connect, s=send, r=receive, g=get, f=finish, x=exit, v=server
 *	    d=debug, i=image mode, n=no filename conversion, l=tty line,
 *	    b=baud rate, e=escape char, h=half duplex, t=suppress timeouts
 *	    p=parity, q=8 bit quoting allowed, z=log packet transactions.
 *
 *  When sending, kermit will expand wildcards and handle drives.  The line
 *
 *	kermit s c:\crtl\*.c
 *
 *  sends all files with an extension of c on the path \crtl of drive c.  Since this is
 *  a feature of the runtime, when using the get command, filenames containing
 *  wildcards must be in double quotes.
 *
 */

#include <stdio.h>	    /* Standard UNIX definitions */
#include <ctype.h>
#include <setjmp.h>

extern BYTE *sccsid;

/* Symbol Definitions */

#define MAXPACKSIZ  94	    /* Maximum packet size */
#define SOH	    1	    /* Start of header */
#define CR	    13	    /* ASCII Carriage Return */
#define SP	    32	    /* ASCII space */
#define DEL	    127	    /* Delete (rubout) */

#define MAXTRY	    10	    /* Times to retry a packet */
#define MYQUOTE	    '#'	    /* Quote character I will use */
#define MYPAD	    0	    /* Number of padding characters I will need */
#define MYPCHAR	    0	    /* Padding character I need (NULL) */

#define MYREPTC     '~'	    /* Repeat character I need */
#define MYBQUOTE    '&'     /* Binary quote character I use */

#define MYCAPS      0       /* No extended capabilities */
#define MYCHECK     '1'     /* Only do single character checksums */

#define MYTIME	    10	    /* Seconds after which I should be timed out */
#define MAXTIM	    60	    /* Maximum timeout interval */
#define MINTIM	    2	    /* Minumum timeout interval */

#define DEFLCH	    FALSE   /* Default local echo */
#define DEFPAR	    FALSE   /* Default parity */
#define DEFIM	    FALSE   /* Default image mode */

#define DEFFNC	    TRUE    /* Default file name conversion */

#define MYEOL	    13      /* End-Of-Line character I need */


/* Macro Definitions */

/*
 * tochar: converts a control character to a printable one by adding a space.
 *
 * unchar: undoes tochar.
 *
 * ctl:	   converts between control characters and printable characters by
 *	   toggling the control bit (ie. ^A becomes A and A becomes ^A).
 *
 * unpar:  turns off the parity bit.
 *
 * push_char : pushes back one character
 */

#define tochar(ch)  ((ch) + ' ')
#define unchar(ch)  ((ch) - ' ')
#define ctl(ch)	    ((ch) ^ 64 )
#define unpar(ch)   ((ch) & 127)
#define push_char(chr) ch_stack[ch_sptr++] = chr


/* Global Variables */

WORD	bin_quote,	    /* True enables binary quoting */
	ch_sptr,	    /* Character pushback stack pointer */
	ch_stack[15],	    /* Character pushback stack */
	debug,		    /* Indicates level of debugging output (0=none) */
	dobquo,		    /* True means do binary quoting */
	dorept,		    /* True means we can do repeating */
	dotimout,	    /* True means we are doing timeouts */
	filecount,	    /* Number of files left to send */
	filnamcnv,	    /* TRUE means do file name case conversions */
	image,		    /* TRUE means 8-bit mode */
	lecho,		    /* TRUE for locally echo chars in connect mode */
	parflg,		    /* TRUE means use parity specified */
	n,		    /* Packet number */
	numtry,		    /* Times this packet retried */
	oldtry,		    /* Times previous packet retried */
	outlen,		    /* Length of user requested output string */
	pad,		    /* How much padding to send */
	pktdeb,		    /* TRUE means log all packet to a file */
	remote,		    /* TRUE means we are a remote kermit */
	rpsiz,		    /* Maximum receive packet size */
	size,		    /* Size of present data */
	speed,		    /* speed to set */
	spsiz,		    /* Maximum send packet size */
	timint;		    /* Timeout for foreign host on sends */

BYTE	bquote,		    /* Binary quoting character prefix */
	cchksum,	    /* Our (computed) checksum */
	command,	    /* The command we are doing */
	eol,		    /* End-Of-Line character to send */
	escchr,		    /* Connect command escape character */
	**filelist,	    /* List of files to be sent */
	*filnam,	    /* Current file name */
	*outstring,	    /* User requested string to prepend to output files */
	packet[MAXPACKSIZ], /* Packet buffer */
	padchar,	    /* Padding character to send */
	quote,		    /* Quote character in incoming data */
	recpkt[MAXPACKSIZ], /* Receive packet buffer */
	reptc,		    /* Repeat character prefix */
	srvpkt[MAXPACKSIZ], /* Server packet buffer */
	state;		    /* Present state of the automaton */

FILE	*dpfp,		    /* File pointer for debugging packet log file */
	*fp,		    /* File pointer for current disk file */
	*fopen(),	    /* File open routine - ASCII files */
	*fopenb();	    /* File open routine - Binary files */

jmp_buf	env;		    /* Environment ptr for timeout longjump */


/*
 *  m a i n
 *
 *  Main routine - parse command and options, set up the
 *  tty lines, and dispatch to the appropriate routine.
 */

main(argc,argv)
WORD argc;			    /* Character pointers to and count of */
BYTE **argv;				/* command line arguments */
{
    BYTE ch,				/* temp character */
	 *cp;				/* char pointer */

/*  Initialize the I/O system */

    init();

    if (argc < 2) usage();		/* Make sure there's a command line */

    cp = *++argv; argv++; argc -= 2;	/* Set up pointers to args */

/*  Initialize these values and hope the first packet will get across OK */

    debug = 0;
    eol = MYEOL;			/* EOL for outgoing packets */
    quote = MYQUOTE;			/* Standard control-quote char "#" */
    pad = 0;				/* No padding */
    padchar = NULL;			/* Use null if any padding wanted */

    bquote = MYBQUOTE;			/* Standard binary quoting character "&" */
    dobquo = FALSE;			/* Default is no binary quoting */
    bin_quote = FALSE;			/* and quoting disabled */

    reptc = MYREPTC;			/* Standard repeat character prefix "~" */
    dorept = FALSE;			/* Default is no repeat substituting */

    speed = 0;

    timint = MYTIME;

    outlen = 0;				/* No string to prepend to output files */

    command = FALSE;			/* Turn off all parse flags */

    ch_sptr = 0;			/* No chars pushed back */

    pktdeb = FALSE;			/* No packet file debugging */
    dotimout = TRUE;			/* Default we do timeouts */
    lecho = DEFLCH;			/* Default local echo */
    parflg = DEFPAR;			/* Default parity */
    image = DEFIM;			/* Default image mode */
    filnamcnv = DEFFNC;			/* Default filename case conversion */

    while ((*cp) != NULL) {		/* Parse characters in first arg. */
	ch = *cp++;
	if (isupper(ch))
	    ch = tolower(ch);

	switch (ch) {

	    case 'b':			/* B = specify baud rate */
		if (argc--)
		    set_baud(argv++);
		else
		    usage(); 
		break;
		
	    case 'c':		/* C = Connect command */
		if (!command)		/* Only one command allowed */
		    command = 'C';
		else
		    usage();
		break;

	    case 'd':		/* D = Increment debug mode count */
 		debug++;
		break;
		
	    case 'e':		/* E = specify escape char */
 		if (argc--)
		    escchr = **argv++;
		else
		    usage();
		if (debug)
		    printf("Escape char is \"%c\"\n",escchr);
		break;
		
	    case 'f':		/* F = Finish. */
		if (!command)		/* Only one command allowed */
		    command = 'F';
		else
		    usage();
		break;

	    case 'g':		/* G = Get command */
		if (!command)		/* Only one command allowed */
		    command = 'G';
		else
		    usage();
		break;

	    case 'h':		/* H = Half duplex mode */
		lecho = TRUE;
		break;

	    case 'i':		/* I = Image (8-bit) mode */
		image = TRUE;
		break;

	    case 'l':		/* L = specify tty line to use */
		if (argc--)
		    set_line(argv++);
		else
		    usage(); 
		break;
		
	    case 'n':		/* N = don't do case conversion */
		filnamcnv = FALSE;
		break;

	    case 'o':		/* O = specify string to prepend to output files */
 		if (argc--) {
		    outstring = *argv++;
		    outlen = strlen(outstring);
		}
		else
		    usage();
		break;
		
	    case 'p':		/* P = specify parity */
		if (argc--) {
		    parflg = **argv++;
		    if (isupper(parflg))
			parflg = tolower(parflg);

		    switch (parflg) {

			case 'n':	/* None, no parity */
			    parflg = FALSE;
			    break;

			case 'e':
			case 'm':
			case 'o':
			case 's':
			    break;

			default:
			    usage(); 
		    }
		}
		else
		    usage();

		if (debug)
		    printf("Parity is %c\n",parflg);
		break;
		
	    case 'q':		/* Q = Enable binary quoting */
		bin_quote = TRUE;
		break;

	    case 'r':		/* R = Receive command */
		if (!command)		/* Only one command allowed */
		    command = 'R';
		else
		    usage();
		break;

	    case 's':		/* S = Send command */
		if (!command)		/* Only one command allowed */
		    command = 'S';
		else
		    usage();
		break;

	    case 't':		/* T = No timeouts */
		dotimout = FALSE;
		break;

	    case 'v':		/* V = Enter Server Mode command */
		if (!command)		/* Only one command allowed */
		    command = 'V';
		else
		    usage();
		break;

	    case 'x':		/* X = Exit command */
		if (!command)		/* Only one command allowed */
		    command = 'X';
		else
		    usage();
		break;

	    case 'z':			/* Use packet file debugging */
		pktdeb = TRUE;
		break;

	    default:
		usage();
	}
    } /* end while parsing */

/* Done parsing */

    if (!command)			/* Must specify a command */
	usage();

/* If we are in server mode we are a remote kermit */
    
    remote = (command == 'V');

/* All set up, now execute the command that was given. */

    printf("%s\n",sccsid);		/* print version # */

    if (pktdeb) {			/* Open packet file if requested */
	if ((dpfp=fopen("PACKET.LOG","w"))==NULL) {
	    if (debug)
		printf("Cannot create PACKET.LOG\n");
	    pktdeb = FALSE;		/* Say file not being used */
	}
	if (debug)
	    printf("Logging all packets to PACKET.LOG\n\n");
    }

    if (debug)
	printf("Debugging level = %d\n\n",debug);

    /* Case on the command we were asked to do */

    switch (command) {

	case 'C':			/* Connect command */
	    if (debug)
		printf("Connect command\n\n");

	    connect();
	    break;

	case 'R':			/* Receive command */
	    if (debug)
		printf("Receive command\n\n");

	    if (recsw() == FALSE)	/* Receive the file(s) */
		printmsg("Receive failed.");
	    else			/* Report failure */
		printmsg("Done.");	/* or success */
	    break;

	case 'S':			/* Send command */ 
	    if (debug)
		printf("Send command\n\n");

	    if (argc--)
		filnam = *argv++;	/* Get file to send */
	    else			/* and give error */
		usage();

	    fp = NULL;			/* Indicate no file open yet */
	    filelist = argv;		/* Set up the rest of the file list */
	    filecount = argc;		/* Number of files left to send */
	    if (sendsw() == FALSE)	/* Send the file(s) */
		printmsg("Send failed.");	/* Report failure */
	    else			/*  or */
		printmsg("Done.");	/* success */

	    break;

	case 'F':			/* Finish command */
	    if (debug)
		printf("Finish command\n\n");

	    if (gensw(1,"F") == FALSE)	/* Exit remote kermit */
		printmsg("Finish failed.");
	    else			/* Report failure */
		printmsg("Done.");	/* or success */
	    break;

	case 'G':			/* Get command */
	    if (debug)
		printf("Get command\n\n");

	    if (argc--)
		filnam = *argv++;	/* file to get */
	    else			/* and give error */
		usage();

	    filelist = argv;		/* Set up the rest of the file list */
	    filecount = argc;		/* Number of files left to send */

	    if (getsw() == FALSE)	/* Get the file(s) */
		printmsg("Get failed.");/* Report failure */
	    else			/*  or */
		printmsg("Done.");	/* success */

	    break;

	case 'V':			/* Server command */
	    if (debug)
		printf("Entering server mode.\n\n");
	    if (server() == FALSE)
		printmsg("Server Mode Aborted.");
	    else
		printmsg("Done.");

	    break;

	case 'X':			/* Exit command */
	    if (debug)
		printf("Exit command\n\n");

	    if (gensw(1,"L") == FALSE)	/* Exit remote and Logout */
		printmsg("Exit failed.");
	    else			/* Report failure */
		printmsg("Done.");	/* or success */
	    break;
    }

    if (pktdeb) fclose(dpfp);		/* Close the debug file */

    dinit();				/* Close input */
}


/*
 *  s e n d s w
 *
 *  Sendsw is the state table switcher for sending files.  It loops until
 *  either it finishes, or an error is encountered.  The routines called
 *  by sendsw are responsible for changing the state.
 *
 */

WORD sendsw()
{
    BYTE sinit(), sfile(), sdata(), seof(), sbreak();

    state = 'S';			/* Send initiate is the start state */
    n = 0;				/* Initialize message number */
    numtry = 0;				/* Say no tries yet */
    if (remote)				/* Sleep to give the guy a chance */
	sleep(MYTIME);

    while(TRUE) {			/* Do this as long as necessary */
	if (debug)
	    printf("sendsw state: %c\n",state);

	switch(state) {

	    case 'S':			/* Send-Init */
		state = sinit();
		break;

	    case 'F':			/* Send-File */
		state = sfile();
		break;

	    case 'D':			/* Send-Data */
		state = sdata();
		break;

	    case 'Z':			/* Send-End-of-File */
		state = seof();
		break;

	    case 'B':			/* Send-Break */
		state = sbreak();
		break;

	    case 'C':			/* Complete */
		return (TRUE);

	    case 'A':			/* "Abort" */
		return (FALSE);

	    default:		 /* Unknown, fail */
		return (FALSE);
	}
    }
}


/*
 *  s i n i t
 *
 *  Send Initiate: send this host's parameters and get other side's back.
 */

BYTE sinit()
{
    WORD num, len;			/* Packet number, length */

    EXTERN BYTE rpack();

    if (debug)
	printf("In sinit retries: %d\n",numtry);

    if (numtry++ > MAXTRY)		/* If too many tries, give up */
	return('A');

    spar(packet);			/* Fill up init info packet */

    spack('S',n,10,packet);		/* Send an S packet */

    switch(rpack(&len,&num,recpkt)) {	/* What was the reply? */

	case 'N':			/* NAK, try it again */
	    return(state);

	case 'Y':			/* ACK */
	    if (n != num)		/* If wrong ACK, stay in S state */
		return(state);		/* and try again */

	    rpar(len, recpkt);		/* Get other side's init info */

	    numtry = 0;			/* Reset try counter */

	    n = (n+1)%64;		/* Bump packet count */

	    return('F');		/* OK, switch state to F */

	case 'E':			/* Error packet received */
	    prerrpkt(recpkt);		/* Print it out and */
	    return('A');		/* abort */

	case 'T':			/* Timeout failure, try again */
	case FALSE:			/* Receive failure, try again */
	    return(state);

	default:			/* Anything else, just "abort" */
	    return('A');
   }
 }


/*
 *  s f i l e
 *
 *  Send File Header.
 */

BYTE sfile()
{
    WORD num, len;			/* Packet number, length */
    BYTE filnam1[128],			/* Converted file name */
	*newfilnam,			/* Pointer to file name to send */
	*cp;				/* char pointer */
    REG BYTE tch;			/* character we are testing */

    EXTERN WORD bufill();
    EXTERN BYTE rpack();

    if (numtry++ > MAXTRY)		/* If too many tries, give up */
	return('A');
    
    if (fp == NULL) {			/* If not already open, */
	if (debug)
	    printf("   Opening %s for sending.\n",filnam);

	if(!image)
	    fp = fopen(filnam,"r");	/* open the file to be sent */
	else
	    fp = fopenb(filnam,"r");	/* open the file to be sent */

	if (fp == NULL) {		/* If bad file pointer, give up */
	    error("Cannot open file %s",filnam);
	    return('A');
	}
    }

    strcpy(filnam1, filnam);		/* Copy file name */
    newfilnam = cp = filnam1;

    while ((tch = *cp++) != '\0') {	/* Strip off all leading directory */
	if (tch == '\\' || tch == ':')	/* names (ie. up to the last \). */
	    newfilnam = cp;
    }

    if (filnamcnv)			/* Convert lower case to upper	*/
	for (cp = newfilnam; (tch = *cp) != '\0'; cp++)
	    if (islower(tch))
		*cp = toupper(tch);

    /* Compute length of new filename */

    len = (WORD) ( cp - newfilnam );

    printmsg("Sending %s",filnam);

    spack('F',n,len,newfilnam);		/* Send an F packet */

    switch(rpack(&len,&num,recpkt)) {	/* What was the reply? */
	case 'N':			/* NAK, just stay in this state, */
	    num = (--num<0 ? 63:num);	/* unless it's NAK for next packet */
	    if (n != num)		/* which is just like an ACK for */ 
		return(state);		/* this packet so fall thru to... */

	case 'Y':			/* ACK */
	    if (n != num)		/* If wrong ACK, stay in F state */
		return(state);

	    numtry = 0;			/* Reset try counter */
	    n = (n+1)%64;		/* Bump packet count */
	    size = bufill(packet);	/* Get first data from file */
	    return('D');		/* Switch state to D */

	case 'E':			/* Error packet received */
	    prerrpkt(recpkt);		/* Print it out and */
	    return('A');		/* abort */

	case 'T':			/* Timeout failure, try again */
	case FALSE:			/* Receive failure, stay in F state */
	    return(state);

	default:			/* Something else, just "abort" */
	    return('A');
    }
}


/*
 *  s d a t a
 *
 *  Send File Data
 */

BYTE sdata()
{
    WORD num, len;			/* Packet number, length */

    EXTERN WORD bufill();
    EXTERN BYTE rpack();

    if (numtry++ > MAXTRY)		/* If too many tries, give up */
	return('A');

    spack('D',n,size,packet);		/* Send a D packet */

    switch(rpack(&len,&num,recpkt)) {	/* What was the reply? */
	case 'N':			/* NAK, just stay in this state, */
	    num = (--num<0 ? 63:num);	/* unless it's NAK for next packet */
	    if (n != num)		/* which is just like an ACK for */
		return(state);		/* this packet so fall thru to... */
		
	case 'Y':			/* ACK */
	    if (n != num)		/* If wrong ACK, fail */
		return(state);

	    numtry = 0;			/* Reset try counter */
	    n = (n+1)%64;		/* Bump packet count */
	    if ((size = bufill(packet)) == EOF) /* Get data from file */
		return('Z');		/* If EOF set state to that */
	    return('D');		/* Got data, stay in state D */

	case 'E':			/* Error packet received */
	    prerrpkt(recpkt);		/* Print it out and */
	    return('A');		/* abort */

	case 'T':			/* Timeout failure, try again */
	case FALSE:			/* Receive failure, stay in D */
	    return(state);

	default:			/* Anything else, "abort" */
	    return('A');
    }
}


/*
 *  s e o f
 *
 *  Send End-Of-File.
 */

BYTE seof()
{
    WORD num, len;			/* Packet number, length */

    EXTERN BYTE rpack();

    if (numtry++ > MAXTRY)		/* If too many tries, "abort" */
	return('A');

    spack('Z',n,0,NULLPTR);		/* Send a 'Z' packet */

    switch(rpack(&len,&num,recpkt)) {	/* What was the reply? */
	case 'N':			/* NAK, just stay in this state, */
	    num = (--num<0 ? 63:num);	/* unless it's NAK for next packet, */
	    if (n != num)		/* which is just like an ACK for */
		return(state);		/* this packet so fall thru to... */

	case 'Y':			/* ACK */
	    if (n != num)		/* If wrong ACK, hold out */
		return(state);

	    numtry = 0;			/* Reset try counter */
	    n = (n+1)%64;		/* and bump packet count */
	    if (debug)
		printf("\t  Closing input file %s, ",filnam);
	    fclose(fp);			/* Close the input file */
	    fp = NULL;			/* Set flag indicating no file open */ 

	    if (debug)
		printf("looking for next file...\n");
	    if (gnxtfl() == FALSE)	/* No more files go? */
		return('B');		/* if not, break, EOT, all done */
	    if (debug)
		printf("\t  New file is %s\n",filnam);

	    return('F');		/* More files, switch state to F */

	case 'E':			/* Error packet received */
	    prerrpkt(recpkt);		/* Print it out and */
	    return('A');		/* abort */

	case 'T':			/* Timeout failure, try again */
	case FALSE:			/* Receive failure, stay in Z */
	    return(state);

	default:			/* Something else, "abort" */
	    return('A');
    }
}


/*
 *  s b r e a k
 *
 *  Send Break (EOT)
 */

BYTE sbreak()
{
    WORD num, len;			/* Packet number, length */

    EXTERN BYTE rpack();

    if (numtry++ > MAXTRY)		/* If too many tries "abort" */
	return('A');

    spack('B',n,0,NULLPTR);		/* Send a B packet */

    switch (rpack(&len,&num,recpkt)) {	/* What was the reply? */
	case 'N':			/* NAK, just stay in this state, */
	    num = (--num<0 ? 63:num);	/* unless NAK for previous packet, */
	    if (n != num)		/* which is just like an ACK for */
		return(state);		/* this packet so fall thru to... */

	case 'Y':			/* ACK */
	    if (n != num)		/* If wrong ACK, fail */
		return(state);
	    numtry = 0;			/* Reset try counter */
	    n = (n+1)%64;		/* and bump packet count */
	    return('C');		/* Switch state to Complete */

	case 'E':			/* Error packet received */
	    prerrpkt(recpkt);		/* Print it out and */
	    return('A');		/* abort */

	case 'T':			/* Timeout failure, try again */
	case FALSE:			/* Receive failure, stay in B */
	    return(state);

	default:			/* Other, "abort" */
	    return ('A');
   }
}


/*
 *  r e c s w
 *
 *  This is the state table switcher for receiving files.
 */

WORD recsw()
{
    BYTE rinit(), rfile(), rdata();	/* Use these procedures */

    if (remote)				/* If server don't init */
	state = 'F';
    else {
	state = 'R';			/* Receive-Init is the start state */
	n = 0;				/* Initialize message number */
	numtry = 0;			/* Say no tries yet */
    }

    while(TRUE) {
	if (debug)
	    printf(" recsw state: %c\n",state);

	switch(state) {			/* Do until done */
	    case 'R':			/* Receive-Init */
		state = rinit();
		 break;

	    case 'F':			/* Receive-File */
		state = rfile();
		break;

	    case 'D':			/* Receive-Data */
		state = rdata();
		break;

	    case 'C':			/* Complete state */
		return(TRUE);

	    case 'A':			/* "Abort" state */
		return(FALSE);

	    default:			/* Anything else */
		return(FALSE);
	}
    }
}

    
/*
 *  r i n i t
 *
 *  Receive Initialization
 */
  
BYTE rinit()
{
    WORD len, num;			/* Packet length, number */
    EXTERN BYTE rpack();

    if (numtry++ > MAXTRY)		/* If too many tries, "abort" */
	return('A');

    switch(rpack(&len,&num,recpkt)) {
	case 'S':			/* Send-Init */
	    rpar(len, recpkt);		/* Get the other side's init data */
	    spar(packet);		/* Fill up packet with my init info */
	    spack('Y',n,10,packet);	/* ACK with my parameters */
	    oldtry = numtry;		/* Save old try count */
	    numtry = 0;			/* Start a new counter */
	    n = (n+1)%64;		/* Bump packet number, mod 64 */
	    return('F');		/* Enter File-Receive state */

	case 'E':			/* Error packet received */
	    prerrpkt(recpkt);		/* Print it out and */
	    return('A');		/* abort */

	case 'T':			/* Timeout failure, try again */
	case FALSE:			/* Didn't get packet */
	    spack('N',n,0,NULLPTR);	/* Return a NAK */
	    return(state);		/* Keep trying */

	default:			/* Some other packet type, "abort" */
	    return('A');
    }
}


/*
 *  r f i l e
 *
 *  Receive File Header
 */

BYTE rfile()
{
    WORD num, len;			/* Packet number, length */
    BYTE filnam1[128];			/* Holds the converted file name */

    EXTERN BYTE rpack();

    if (numtry++ > MAXTRY)
	return('A'); /* "abort" if too many tries */

    switch(rpack(&len,&num,recpkt)) {	/* Get a packet */
	case 'S':			/* Send-Init, maybe our ACK lost */
	    if (oldtry++ > MAXTRY)	/* If too many tries "abort" */
		return('A');
	    if (num == ((n==0) ? 63:n-1)) {	/* Previous packet, mod 64? */
		spar(packet);		/* Yes, ACK it again with  */
		spack('Y',num,10,packet);/* our Send-Init parameters */
		numtry = 0;		/* Reset try counter */
		return(state);		/* Stay in this state */
	    }
	    else			/* Not previous packet, "abort" */
		return('A');

	case 'Z':			/* End-Of-File */
	    if (oldtry++ > MAXTRY)
		return('A');

	    if (num == ((n==0) ? 63:n-1)) {	/* Previous packet, mod 64? */
		spack('Y',num,0,NULLPTR);	/* Yes, ACK it again. */
		numtry = 0;
		return(state);		/* Stay in this state */
	    }
	    else			/* Not previous packet, "abort" */
		return('A');

	case 'F':			/* File Header (just what we want) */
	    if (num != n)		/* The packet number must be right */
		return('A');

	    /* Copy the file name, prepending the requested string if one */
	    /* was specified.						  */

	    if (outlen > 0) {
		strcpy(filnam1, outstring);
		strcpy((filnam1+outlen), recpkt);
	    }
	    else
		strcpy(filnam1, recpkt);

	    if (filnamcnv)		/* Convert upper case to lower */
		for (filnam=filnam1; *filnam != '\0'; filnam++)
		    if (isupper(*filnam))
			*filnam = tolower(*filnam);

	    /* Try to open a new file */

	    if (!image)
		fp = fopen(filnam1,"w");
	    else
		fp = fopenb(filnam1,"w");

	    if (fp==NULL) {
		error("Cannot create %s",filnam1); /* Give up if can't */
		return('A');
	    }
	    else			/* OK, give message */
		printmsg("Receiving %s",recpkt);

	    spack('Y',n,0,NULLPTR);	/* Acknowledge the file header */
	    oldtry = numtry;		/* Reset try counters */
	    numtry = 0;			/* ... */
	    n = (n+1)%64;		/* Bump packet number, mod 64 */
	    return('D');		/* Switch to Data state */

	case 'B':			/* Break transmission (EOT) */
	    if (num != n)		/* Need right packet number here */
		return ('A');
	    spack('Y',n,0,NULLPTR);	/* Say OK */
	    return('C');		/* Go to complete state */

	case 'E':			/* Error packet received */
	    prerrpkt(recpkt);		/* Print it out and */
	    return('A');		/* abort */

	case 'T':			/* Timeout failure, try again */
	case FALSE:			/* Didn't get packet */
	    spack('N',n,0,NULLPTR);	/* Return a NAK */
	    return(state);		/* Keep trying */

	default:			/* Some other packet, "abort" */
	    return ('A');
    }
}


/*
 *  r d a t a
 *
 *  Receive Data
 */

BYTE rdata()
{
    WORD num, len;			/* Packet number, length */

    EXTERN BYTE rpack();

    if (numtry++ > MAXTRY)		/* "abort" if too many tries */
	return('A');

    switch(rpack(&len,&num,recpkt)) {	/* Get packet */
	case 'D':			/* Got Data packet */
	    if (num != n) {		/* Right packet? */
		if (oldtry++ > MAXTRY)	/* No */
		    return('A');	/* If too many tries, abort */

		/* Else check packet number */

		if (num == ((n==0) ? 63:n-1)) {
		    /* Previous packet again? */

		    spack('Y',num,6,packet); /* Yes, re-ACK it */
		    numtry = 0;		/* Reset try counter */
		    return(state);	/* Don't write out data! */
		}
		else			/* sorry, wrong number */
		    return('A');
	    }

	    /* Got data with right packet number */

	    bufemp(recpkt,len);		/* Write the data to the file */
	    spack('Y',n,0,NULLPTR);	/* Acknowledge the packet */
	    oldtry = numtry;		/* Reset the try counters */
	    numtry = 0;			/* ... */
	    n = (n+1)%64;		/* Bump packet number, mod 64 */
	    return('D');		/* Remain in data state */

	case 'F':			/* Got a File Header */
	    if (oldtry++ > MAXTRY)
		return('A');		/* If too many tries, "abort" */

	     /* Else check packet number */

	    if (num == ((n==0) ? 63:n-1)) {
	    	/* It was the previous one */

		spack('Y',num,0,NULLPTR);	/* ACK it again */
		numtry = 0;		/* Reset try counter */
		return(state);		/* Stay in Data state */
	    }
	    else			/* Not previous packet, "abort" */
		return('A');

	case 'Z':			/* End-Of-File */
	    if (num != n)		/* Must have right packet number */
		return('A');

	    spack('Y',n,0,NULLPTR);	/* OK, ACK it. */
	    fclose(fp);			/* Close the file */
	    n = (n+1)%64;		/* Bump packet number */
	    return('F');		/* Go back to Receive File state */

	case 'E':			/* Error packet received */
	    prerrpkt(recpkt);		/* Print it out and */
	    return('A');		/* abort */

	case 'T':			/* Timeout failure, try again */
	case FALSE:			/* Didn't get packet */
	    spack('N',n,0,NULLPTR);	/* Return a NAK */
	    return(state);		/* Keep trying */

	default:			/* Some other packet, "abort" */
	    return('A');
    }
}

/*
 *   g e t s w
 *
 *  This is the state table switcher for getting files.
 */

WORD getsw()
{
    BYTE xinit(), gfile(), rfile(), rdata();	/* Use these procedures */

    state = 'I';			/* Initialize is the start state */
    n = 0;				/* Initialize message number */
    numtry = 0;				/* Say no tries yet */


    while(TRUE) {
	if (debug)
	    printf(" getsw state: %c\n",state);

	switch(state) {			/* Do until done */
	    case 'I':			/* Exchange Init packages */
		state = xinit('G');
		break;

	    case 'G':			/* Send Get package */
		state = gfile();
		break;

	    case 'F':			/* Receive-File */
		state = rfile();
		break;

	    case 'D':			/* Receive-Data */
		state = rdata();
		break;

	    case 'C':			/* Complete state */
		if (debug)
		    printf("looking for next file...\n");

		if (gnxtfl() == FALSE)	/* No more files go? */
		    return(TRUE);	/* if not, all done */

		if (debug)
		    printf("\t  New file is %s\n",filnam);

		n = 0;			/* Initialize message number */
		numtry = 0;		/* Say no tries yet */
		state = 'G';		/* More files, switch state to G */
		break;

	    case 'A':			/* "Abort" state */
		return(FALSE);

	    default:			/* Anything else */
		return(FALSE);
	}
    }
}

/*
 *   g e n s w
 *
 *  This is the state table switcher for generic commands
 */

WORD gensw(clen,cmd)
WORD clen;
BYTE *cmd;
{
    BYTE xinit(), generic();		/* Use these procedures */

    state = 'I';			/* Initialize is the start state */
    n = 0;				/* Initialize message number */
    numtry = 0;				/* Say no tries yet */


    while(TRUE) {
	if (debug)
	    printf(" exitsw state: %c\n",state);

	switch(state) {			/* Do until done */
	    case 'I':			/* Exchange Init packages */
		state = xinit('G');
		break;

	    case 'G':			/* Send Generic package */
		state = generic(clen,cmd);
		break;

	    case 'C':			/* Complete state */
		return(TRUE);		/* all done */

	    case 'A':			/* "Abort" state */
		return(FALSE);

	    default:			/* Anything else */
		return(FALSE);
	}
    }
}

/*
 *  g e n e r i c
 *
 *  generic - send a generic command packet
 */

BYTE generic(clen,cmd)
WORD clen;
BYTE *cmd;
{
    WORD num, len;			/* Packet number, length */

    EXTERN BYTE rpack();

    if (debug)
	printf("In exit_server retries: %d\n",numtry);

    if (numtry++ > MAXTRY)		/* If too many tries, give up */
	return('A');

    spack('G',n,clen,cmd);		/* Send a generic command packet */

    switch(rpack(&len,&num,recpkt)) {	/* What was the reply? */

	case 'N':			/* NAK, try it again */
	    return(state);

	case 'Y':			/* ACK */
	    if (n != num)		/* If wrong ACK, stay in S state */
		return(state);		/* and try again */

	    return('C');		/* OK, switch state to C */

	case 'E':			/* Error packet received */
	    prerrpkt(recpkt);		/* Print it out and */
	    return('A');		/* abort */

	case 'T':			/* Timeout failure, try again */
	case FALSE:			/* Receive failure, try again */
	    return(state);

	default:			/* Anything else, just "abort" */
	    return('A');
   }
 }


/*
 *  x i n i t
 *
 *  Exchange Initialization packages: send this host's parameters and
 *  get other side's back.
 */

BYTE xinit(next_state)

BYTE next_state;			/* The state to goto if things work out */
{
    WORD num, len;			/* Packet number, length */

    EXTERN BYTE rpack();

    if (debug)
	printf("In xinit retries: %d\n",numtry);

    if (numtry++ > MAXTRY)		/* If too many tries, give up */
	return('A');

    spar(packet);			/* Fill up init info packet */

    spack('I',n,10,packet);		/* Send an I packet */

    switch(rpack(&len,&num,recpkt)) {	/* What was the reply? */

	case 'N':			/* NAK, try it again */
	    return(state);

	case 'Y':			/* ACK */
	    if (n != num)		/* If wrong ACK, stay in I state */
		return(state);		/* and try again */

	    rpar(len, recpkt);		/* Get other side's init info */

	    numtry = 0;			/* Reset try counter */

	    n = (n+1)%64;		/* Bump packet count */

	    return(next_state);		/* OK, switch state to F */

	case 'E':			/* Error packet received */
	    return(next_state);		/* Must assume not implemented */

	case 'T':			/* Timeout failure, try again */
	case FALSE:			/* Receive failure, try again */
	    return(state);

	default:			/* Anything else, just "abort" */
	    return('A');
   }
 }


/*
 *  g f i l e
 *
 *  Send a get file packet
 */

BYTE gfile()
{
    WORD len, num;			/* Packet length, number */
    EXTERN BYTE rpack();

    if (numtry++ > MAXTRY)		/* If too many tries, "abort" */
	return('A');

    /* Compute length of new filename */

    len = strlen(filnam);

    spack('R',n,len,filnam);		/* Send an R packet */
    n = 0;

    switch(rpack(&len,&num,recpkt)) {
	case 'S':			/* Send-Init */
	    rpar(len, recpkt);		/* Get the other side's init data */
	    spar(packet);		/* Fill up packet with my init info */
	    spack('Y',n,10,packet);	/* ACK with my parameters */
	    oldtry = numtry;		/* Save old try count */
	    numtry = 0;			/* Start a new counter */
	    n = (n+1)%64;		/* Bump packet number, mod 64 */
	    return('F');		/* Enter File-Receive state */

	case 'E':			/* Error packet received */
	    prerrpkt(recpkt);		/* Print it out and */
	    return('A');		/* abort */

	case 'N':			/* NAK */
	case 'T':			/* Timeout failure, try again */
	case FALSE:			/* Didn't get packet */
	    return(state);		/* Keep trying */

	default:			/* Some other packet type, "abort" */
	    return('A');
    }
}

/*
 *	KERMIT utilities.
 */

BYTE dopar (ch)
BYTE ch;
{
    WORD a;

    if (!parflg)			/* false, no parity */
	return(ch);

    ch &= 0177;
    switch (parflg) {
	case 'm':			/* Mark */
	case 'M':
	    return(ch | 128);

	case 's':			/* Space */
	case 'S':
	    return(ch & 127);

	case 'o':			/* Odd */
	case 'O':
	    ch |= 128;

	case 'e':			/* Even */
	case 'E':
	    a = (ch & 15) ^ ((ch >> 4) & 15);
	    a = (a & 3) ^ ((a >> 2) & 3);
	    a = (a & 1) ^ ((a >> 1) & 1);
	    return((ch & 0177) | (a << 7));

	default:
	    return(ch);
    }
}

/*
 * Get a parity adjusted character from the line, add it to the checksum
 * and return it.
 */

BYTE cinchr()
{
    BYTE ch;
    EXTERN BYTE inchr();

    ch = inchr();			/* Get a character */
    cchksum += ch;			/* Add to the checksum */
    return(ch);
}

/*
 *  g n x t f l
 *
 *  Get next file in a file group
 */

WORD gnxtfl()
{
    if (filecount-- <= 0)
	return FALSE;
    else {
	if (debug) printf("  gnxtfl: filelist = \"%s\"\n",*filelist);
	filnam = *(filelist++);
	return TRUE;
    }
}

/*
 *  s p a r
 *
 *  Fill the data array with my send-init parameters
 *
 */

VOID spar(data)
BYTE data[];
{
    data[0] = tochar(MAXPACKSIZ);	/* Biggest packet I can receive */

    if (remote || command == 'R')	/* Use longer time if remote to prevent */
	data[1] = tochar(MYTIME+5);	/* collisions if I am at the other end  */
    else
	data[1] = tochar(MYTIME);	/* When I want to be timed out */

    data[2] = tochar(MYPAD);		/* How much padding I need */
    data[3] = ctl(MYPCHAR);		/* Padding character I want */
    data[4] = tochar(MYEOL);		/* End-Of-Line character I want */
    data[5] = MYQUOTE;			/* Control-Quote character I send */

    if (bin_quote)
	data[6] = 'Y';			/* I can Binary-Quote but prefer not to */
    else
	data[6] = 'N';

    data[7] = MYCHECK;			/* My preferred checksum */
    data[8] = MYREPTC;			/* Repeat charcter I use */
    data[9] = tochar(MYCAPS);		/* My capabilities */
}


/*  r p a r
 *
 *  Get the other host's send-init parameters
 *
 */

VOID rpar(len, data)
WORD len;
BYTE data[];
{
    spsiz = unchar(data[0]);		/* Maximum send packet size */
    timint = unchar(data[1]);		/* When I should time out */

    if ((timint > MAXTIM) || (timint < MINTIM))
	timint = MYTIME;

    pad = unchar(data[2]);		/* Number of pads to send */
    padchar = ctl(data[3]);		/* Padding character to send */

    eol = unchar(data[4]);		/* EOL character I must send */
    if (eol == 0)
	eol = MYEOL;

    quote = data[5];			/* Incoming data quote character */
    if (quote == 0)
	quote = MYQUOTE;

    dobquo = FALSE;			/* Default is no binary quoting */

    if (len >= 7 && bin_quote) {	/* If binary quoting specified and enabled */
	bquote = data[6];
	if ((bquote >= 33 && bquote <= 62) || (bquote >= 96 && bquote <= 126))
	    dobquo = TRUE;
	else if (bquote = 'Y') {
	    bquote = MYBQUOTE;
	    dobquo = TRUE;
	}
    }

    /* data[7] (eighth paramater) is checksum.  This is don't care cause */
    /* we only support one						 */

    dorept = FALSE;			/* default is no repeat prefixing */

    if (len >= 9) {
	reptc = data[8];
	if (reptc == MYREPTC)
	    dorept = TRUE;
    }
}

/*
 *  Kermit printing routines:
 *
 *  usage - print command line options showing proper syntax
 *  printmsg -	like printf with "Kermit: " prepended
 *  error - like printmsg if local kermit; sends a error packet if remote
 *  prerrpkt - print contents of error packet received from remote host
 */

/*
 *  u s a g e 
 *
 *  Print summary of usage info and quit
 */

VOID usage()
{
printf("Usage:\n");
printf("     kermit c [lbiphe line baud par escape-char]        to connect\n");
printf("     kermit s [ddzinlbpqt line baud par] file ...       to send files\n");
printf("     kermit r [ddzinlbpqto line baud par string]        to receive files\n");
printf("     kermit g [ddzinlbpqto line baud par string] file...to get files\n");
printf("     kermit v [ddzinlbpqto line baud par string]        to enter server mode\n");
printf("     kermit f [ddz]      to shut down remote server\n");
printf("     kermit x [ddz]      to shut down remote server and logout remote\n");
printf("\n");
printf("Commands:\n");
printf("     c=connect, g=get, f=finish, r=receive, s=send, v=server, x=exit\n");
printf("\n");
printf("Modifiers:\n");
printf("     b=baud rate, d=debug, e=escape char, h=half duplex, i=image mode,\n");
printf("     l=tty line, n=no filename conversion, o=prepend string to output files,\n");
printf("     p=parity, q=8 bit quoting allowed, t=suppress timeouts,\n");
printf("     z=log packet transactions.\n");
printf("\n");
printf("When sending, kermit will expand wildcards and handle drives.  The line\n");
printf("\n");
printf("     kermit s c:\crtl\*.c\n");
printf("\n");
printf("sends all files with an extension of c on the path \crtl of drive c.  Since\n");
printf("this is a feature of the runtime, when using the get command, filenames\n");
printf("containing wildcards must be in double quotes.\n");
printf("\n");
printf("Both the remote and local kermit must know an image file is being\n");
printf("transferred in order for the file to be useable.\n");

dinit();	/* turn off I/O system */

exit(1);
}

/*
 *  p r i n t m s g
 *
 *  Print message on standard output if not remote.
 */

/*VARARGS1*/

VOID printmsg(fmt, a1, a2, a3, a4, a5)
BYTE *fmt;
{
    printf("Kermit: ");
    printf(fmt,a1,a2,a3,a4,a5);
    printf("\n");
    fflush(stdout);			/* force output (UTS needs it) */
}

/*
 *  e r r o r
 *
 *  Print error message.
 *
 *  If local, print error message with printmsg.
 *  If remote, send an error packet with the message.
 */

/*VARARGS1*/

VOID error(fmt, a1, a2, a3, a4, a5)
BYTE *fmt;
{
    BYTE msg[80];
    WORD len;

    if (remote) {
	sprintf(msg,fmt,a1,a2,a3,a4,a5); /* Make it a string */
	len = strlen(msg);
	spack('E',n,len,msg);		/* Send the error packet */
    }
    else
	printmsg(fmt, a1, a2, a3, a4, a5);
}

/*
 *  p r e r r p k t
 *
 *  Print contents of error packet received from remote host.
 */

VOID prerrpkt(msg)
BYTE *msg;
{
    printf("Kermit aborting with this error from remote host:\n%s\n",msg);
}

/*
 *  s p a c k
 *
 *  Send a Packet
 */

VOID spack(type,num,len,data)
BYTE type, *data;
WORD num, len;
{
    WORD i, cnt;			/* Character loop counter */
    BYTE chksum, buffer[150];		/* Checksum, packet buffer */
    BYTE *bufp;				/* Buffer pointer */

    EXTERN BYTE dopar();

    if (debug>1)			/* Display outgoing packet */
    {
	if (data != NULL)
	    data[len] = '\0';		/* Null-terminate data to print it */
	printf("  spack type:  %c\n",type);
	printf("	 num:  %d\n",num);
	printf("	 len:  %d\n",len);
	if (data != NULL)
	    printf("	data: \"%s\"\n",data);
    }
  
    bufp = buffer;			/* Set up buffer pointer */

    for (i=1; i<=pad; i++)		/* Issue any padding */
	sputc(padchar);

    sputc( (*bufp++ = dopar(SOH)) );	/* Packet marker, ASCII 1 (SOH) */
    sputc( (*bufp++ = dopar(tochar(len+3))) ); /* Send the character count */
    chksum  = tochar(len+3);		/* Initialize the checksum */
    sputc( (*bufp++ = dopar(tochar(num))) );/* Packet number */
    chksum += tochar(num);		/* Update checksum */
    sputc( (*bufp++ = dopar(type)) );	/* Packet type */
    chksum += type;			/* Update checksum */

    for (i=0; i<len; i++) {		/* Loop for all data characters */
	sputc( (*bufp++ = dopar(data[i])));	/* Get a character */
	chksum += data[i];		/* Update checksum */
    }

    chksum = (((chksum&0300) >> 6)+chksum)&077; /* Compute final checksum */
    sputc( (*bufp++ = dopar(tochar(chksum))) );/* Put it in the packet */
    sputc( (*bufp++ = dopar(eol)) );	/* Extra-packet line terminator */
    if (pktdeb) {			/* If debugging put a copy in file */
	fprintf(dpfp,"\nSpack:");
	cnt = bufp - buffer;
	for (i = 0; i < cnt; i++)
	    fprintf(dpfp,"%c:%03o|",buffer[i],buffer[i]);
    }
}

/*
 *  r p a c k
 *
 *  Read a Packet
 */

BYTE rpack(len,num,data)
WORD *len, *num;			/* Packet length, number */
BYTE *data;				/* Packet data */
{
    WORD i, done;			/* Data character number, loop exit */
    BYTE t,				/* Current input character */
	type,				/* Packet type */
	rchksum;			/* Checksum received from other host */

    EXTERN BYTE inchr();

    if (setjmp(env))			/* If timed out fail */
	return('T');

    if (dotimout)
	set_timer(timint);		/* Establish a timer interrupt */

    if (pktdeb) fprintf(dpfp,"\nRpack:");
    while (inchr() != SOH);		/* Wait for packet header */

    done = FALSE;			/* Got SOH, init loop */
    while (!done)			/* Loop to get a packet */
    {
	cchksum = 0;
	if ((t = cinchr()) == SOH) continue; /* Resynchronize if SOH */
	*len = unchar(t)-3;		/* Character count */

	if ((t = cinchr()) == SOH) continue; /* Resynchronize if SOH */
	*num = unchar(t);		/* Packet number */

	if ((t = cinchr()) == SOH) continue; /* Resynchronize if SOH */
	type = t;			/* Packet type */

/* Put len characters from the packet into the data buffer */

	for (i=0; i<*len; i++)
	    if ((data[i] = cinchr()) == SOH) continue; /* Resynch if SOH */

	data[*len] = 0;			/* Mark the end of the data */

	if ((t = inchr()) == SOH) continue; /* Resynchronize if SOH */
	rchksum = unchar(t);		/* Convert to numeric */
	done = TRUE;			/* Got checksum, done */
    }

    if (dotimout)
	clear_timer();			/* Disable the timer interrupt */

    if (debug>1)			/* Display incoming packet */
    {
	if (data != NULL)
	    data[*len] = '\0';		/* Null-terminate data to print it */
	printf("  rpack type: %c\n",type);
	printf("	 num:  %d\n",*num);
	printf("	 len:  %d\n",*len);
	if (data != NULL)
	    printf("	    data: \"%s\"\n",data);
    }
					/* Fold in bits 7,8 to compute */
    cchksum = (((cchksum&0300) >> 6)+cchksum)&077; /* final checksum */

    if (cchksum != rchksum) return(FALSE);

    return(type);			/* All OK, return packet type */
}

/*
 * Get a character from the line.  Do any necessary parity stripping
 * and return the character.  
 */

BYTE inchr()
{
    BYTE ch;

    EXTERN BYTE sgetc();

    EXTERN WORD tim_alarm;

    ch = sgetc();

    if (!image)
	ch &= 0x7F;

    if (tim_alarm) {
	tim_alarm = FALSE;
	longjmp(env, TRUE);
    }

    if (pktdeb)				/* If debugging put a copy in file */
	fprintf(dpfp,"%c:%03o|",ch,ch);

    if(parflg) ch = unpar(ch);		/* Handle parity */
    return(ch);
}

/*
 *  b u f i l l
 *
 *  Get a bufferful of data from the file that's being sent.
 *  Only control-quoting is done; 8-bit & repeat count prefixes are
 *  handled.
 */

WORD bufill(buffer)
BYTE buffer[];
{
    WORD i,				/* Loop counter */
	 j,				/* Loop counter */
	 t,				/* Character read from file */
	 tchk;				/* Character for test purposes */

    BYTE t7;				/* Seven bit version of t */

    i = 0;				/* Init data buffer pointer */

    while ((t = next_char(fp)) != EOF) {	/* Get the next character */

	if(dorept && t != '\n') {	/* Never repeat newline */

	    /* Look for duplicate characters */

	    for (j = 2;j < 95; j++) {
		tchk = next_char(fp);
		if (tchk != t) {
		    push_char(tchk);	/* push back last char */
		    break;
		}
	    }

	    /* The above loop is always one high.  Correct. */

	    j--;

	    /* Only encode if more than 3 chars */

	    if (j < 3)
		for(; j > 1; j--)
		    push_char(t);
	    else {
		buffer[i++] = MYREPTC;
		buffer[i++] = tochar(j);
	    }

	} /* End if (dorept) */

	/* Check for newline.  Must do here because we might binary */
	/* to this character in the next step.			    */

	if (t == '\n' && !image) {
	    buffer[i++] = quote;
	    buffer[i++] = ctl('\r');
	    buffer[i++] = quote;
	    buffer[i++] = ctl('\n');

	    if (i > (spsiz-10))
		return (i);
	    else
		continue;
	}

	/* Check for binary quoting */

	if (t > 127 && dobquo) {
	    buffer[i++] = MYBQUOTE;		/* Output quote char */
	    t &= 0x7F;				/* and strip to seven bits */
	}

	t7 = unpar(t);			/* Get low order 7 bits */

	/* If we need to quote the character, quote it */

	if (t7 < SP || t7 == DEL) {
	    buffer[i++] = MYQUOTE;
	    t = ctl(t);
	    t7 = ctl(t);
	}
	else if (t7 == MYQUOTE || (t7 == MYBQUOTE && dobquo)
	         || (t7 == MYREPTC && dorept) )
	     buffer[i++] = MYQUOTE;

	/* Now deposit the character itself according to the parity flag */

	if (!parflg)
	    buffer[i++] = t;
	else
	    buffer[i++] = t7;

	if ( i > (spsiz-10))		/* Check length */
	    return(i);	    	    
    }

    if (i == 0)				/* Wind up here only on EOF */
	return(EOF);

    return(i);				/* Handle partial buffer */	
}

/*
 *	next_char
 *
 *  Get one character either from the pushback stack or the file
 */

WORD next_char(stream)
FILE *stream;
{
    if (ch_sptr > 0)
	return(ch_stack[--ch_sptr]);
    else
	return(getc(stream));
}

/*
 *	b u f e m p
 *
 *  Put data from an incoming packet into a file.
 */

VOID bufemp(buffer,len)
BYTE  buffer[];				/* Buffer */
WORD  len;				/* Length */
{
    WORD i, nrep, j;
    BYTE t, t7;				/* Character holder */

    for (i=0; i<len; i++)		/* Loop thru the data field */
    {
	t = buffer[i];			/* Get character */

	if (dorept && t==reptc) {	/* Repeat prefix? */
	    nrep = unchar(buffer[++i]);	/* Yes, get the count and the char to repeat */
	    t = buffer[++i];
	}
	else				/* No, set count to one */
	    nrep = 1;

	if (dobquo && t==bquote)	/* Binary Quote? */
	    t = buffer[++i] | 0x80;	/* Yes, turn on high bit */

	if (t == quote)			/* Control quote? */
	{				/* Yes */
	    t = buffer[++i];		/* Get the quoted character */
	    t7 = t & 0177;
	    if (t7 >= 63 && t7 <= 95)	/* Was it controllified? */
		t = ctl(t);		/* No, uncontrollify it */
	}

	if (t==CR && !image && nrep==1) /* Only pass CR in image mode */
	    continue;

	for (j=0; j<nrep; j++)
	    putc(t,fp);
    }
}

/*  S E R V E R							   */
/* 								   */
/*  This is the state controller for the server mode of operation. */

WORD server()
{
    EXTERN BYTE getcmd();
    EXTERN BYTE rpack();

    WORD len, num, junk;		/* Packet length, number, dummy */
    WORD timeos;			/* Number of timeouts seen */
    BYTE typ;				/* Packet type */

    n = 0;				/* Initialize message number */
    numtry = 0;				/* Say no tries yet */
    timeos = 0;				/* No timeouts seen yet */

    FOREVER {				/* Do until told to quit */
	typ = rpack(&len,&num,srvpkt);	/* Get a packet */

	if (debug)
	   printf ("\n Server - enterning command %c.", typ);

	switch(typ) {
	    case 'I':			/* The other side wants to initialize */
		rpar(len,srvpkt);	/* Get other side's initial parameters */
		spar(packet);		/* Get my initial parameters */
		spack('Y',n,10,packet);	/* Send ACK with my init parameters */
		oldtry = numtry;	/* Reset try counters */
		numtry = 0;
		n = 0;			/* Reset packet count */
		break;


	    case 'S':			/* The other side wants to do a send-init */
		rpar(len,srvpkt);	/* Get other side's initial parameters */
		spar(packet);		/* Get my initial parameters */
		spack('Y',n,10,packet);	/* Send ACK with my init parameters */
		oldtry = numtry;	/* Reset try counters */
		numtry = 0;
		n = (n+1) % 64;		/* Increment packet count */
		recsw();		/* Go to receive state to receive file */
		n = 0;			/* Reset packet count */
		break;

	    case 'R':			/* The other side wants to receive */
		filnam = srvpkt;	/* Load filename and filecount */
		filecount = 0;
		sendsw();		/* Send the requested file */
		n = 0;
		break;

	    case 'G':			/* Other side is sending a command */
		switch(getcmd(len,srvpkt)) {	/* What is the command ? */
		    case 'F':			/* Finish, shut down Kermit */
		    case 'L':			/* Logout: shut down Kermit */
			sleep(3);		/* Delay ack for slow systems */
			spack('Y',num,0,NULLPTR);/* Acknowledge receipt of command */
			return(TRUE);		/* Leave kermit */

		    default:			/* Anything else */
			packet[1] = '\0';	/* Send error message */
			error (srvpkt,
				": command not implemented by CPM Kermit server");
		}
		break;

	    case 'X':			/* Valid, but unimplemented */
	    case 'C':
	    case 'K':
		packet[0] = typ;	/* Send err message */
		packet[1] = '\0';
		error (packet,": not a valid Kermit server command");
		break;

	    case 'N':			/* NAK: ignore it (some confusion) */
		break;

	    case 'E':			/* Error packet */
		prerrpkt(srvpkt);		/* print it */

	    case 'T':			/* Timeout error */
		timeos = (++timeos)%5;	/* Increment timeout counter */
		if (!timeos)		/* If it rolls over (every fifth) */
		    spack('N',n,0,NULLPTR);	/* Send NAK to keep line active */
		n = 0;
		break;

	    case FALSE:			/* Checksum Error */
		spack('N',n,0,NULLPTR);	/* Send NAK */
		n = 0;
		break;

	    default:			/* Anything else, reset packet count, retry */
		packet[0] = typ;	/* and send an error message */
		packet[1] = '\0';
		error (packet, ": not a valid Kermit server command");
		n = 0;				/* Reset counter */
	}

	if (fp != NULL) {		/* If a file was left open (xfer aborted) */
	    fclose (fp);		/* Close it */
	    fp = NULL;			/* Remember closure */
	}
    } /* End FOREVER */
}

/*					*/
/*  G E T C M D				*/
/*					*/
/*  Gets command from G packet.		*/
/*					*/

BYTE getcmd(len,cmd)

WORD len;				/* Command length */
BYTE cmd[];				/* Command holder */
{
    if (len == 1)			/* This Kermit only handles single */
	return(cmd[0]);			/*  character commands */

    else if (len > 1)
	return(cmd[0]);

    else
	return(FALSE);
}

