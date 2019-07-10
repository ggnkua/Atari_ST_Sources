#define EXTRADEBUG
/*
 *  K e r m i t  File Transfer Utility seriously hacked for local use with uw
 *
 *  Currently allows only one kermit session to exist in one window concurent.
 *
 *  Adapted from UNIX Kermit, Columbia University, 1981, 1982, 1983
 *      Bill Catchings, Bob Cattani, Chris Maio, Frank da Cruz, Alan Crosswell
 *
 *  Also:   Jim Guyton, Rand Corporation
 *          Walter Underwood, Ford Aerospace
 *
 */

/*
 * March 28, 1988
 *	    Hacked into form usable in uw.  Converted fsm's to be driven
 *	    by received packet events.  Rewrote rpack routine.
 */

#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include <stdio.h>          /* Standard UNIX definitions */
#include <time.h>
#include "wind.h"
#include "windefs.h"

#define error printmsg
#define chari int	    /* items of type chari should be char, but, mwc
				 insists on adjusting them to int anyway */
/* Symbol Definitions */

#define MAXPACKSIZ  94      /* Maximum packet size */
#define SOH         1       /* Start of header */
#define CR          13      /* ASCII Carriage Return */
#define SP          32      /* ASCII space */
#define DEL         127     /* Delete (rubout) */

#define MAXTRY      10      /* Times to retry a packet */
#define MYQUOTE     '#'     /* Quote character I will use */
#define MYPAD       0       /* Number of padding characters I will need */
#define MYPCHAR     0       /* Padding character I need (NULL) */

#define MYEOL       '\r'    /* End-Of-Line character I need */

#define MYTIME      10      /* Seconds after which I should be timed out */
#define MAXTIM      60      /* Maximum timeout interval */
#define MINTIM      10      /* Minumum timeout interval */

#ifndef TRUE
#define TRUE        -1      /* Boolean constants */
#endif
#define FALSE       0
#define GETPACK     2	    /* return constant */

/* Macro Definitions */

/*
 *  f l u s h i n p u t
 *
 *  Dump all pending input to clear stacked up NACK's.
 */

#define flushinput()	/* no explicit call to flush needed for uw */

/*
 * tochar: converts a control character to a printable one by adding a space.
 *
 * unchar: undoes tochar.
 *
 * ctl:    converts between control characters and printable characters by
 *         toggling the control bit (ie. ^A becomes A and A becomes ^A).
 */
#define tochar(ch)  ((ch) + ' ')
#define unchar(ch)  ((ch) - ' ')
#define ctl(ch)     ((ch) ^ 64 )
#define abs(exp) (((exp) >= 0) ? (exp) : -(exp))


/* Global Variables */

extern int	mouse;				/* is mouse visible ? */
extern	struct	wi_str	w[];

int     size,               /* Size of present data */
        rpsiz,              /* Maximum receive packet size */
        spsiz,              /* Maximum send packet size */
        pad,                /* How much padding to send */
        reqtimint,          /* timeout interval I request */
        timint,             /* Timeout for foreign host on sends */
        n,                  /* Packet number */
        numtry,             /* Times this packet retried */
        oldtry,             /* Times previous packet retried */
        image,              /* -1 means 8-bit mode */
        debug,              /* indicates level of debugging output (0=none) */
        filnamcnv,          /* -1 means do file name case conversions */
        filecount,          /* Number of files left to send */
	kermwdes,	    /* Window descripter for kermit window */
	kermport;	    /* port number for kermit window */

clock_t	timestamp;	    /* Time last packet was received */

char    sflg, rflg;         /* flags for RECEIVE, SEND */
char    state,              /* Present state of the automaton */
        padchar,            /* Padding character to send */
        eol,                /* End-Of-Line character to send */
        quote,              /* Quote character in incoming data */
        **filelist,         /* List of files to be sent */
	*filnam,            /* Current file name */
        recpkt[MAXPACKSIZ+1], /* Receive packet buffer */
        packet[MAXPACKSIZ+1]; /* Packet buffer */

FILE    *fp,                /* File pointer for current disk file */
        *log;               /* File pointer for Logfile */


/*
 *  kerminit
 *
 *  initalization routine - initalize and dispatch to the appropriate routine.
 */

int kerminit(curwin)
int curwin;
{
    OBJECT *obj_tmp;
    static char path[40] = ".\*.*";
    static char file[40] = "";
    static char filename[80];	    /* space for file and directory */
    int butt;

/*  Initialize these values and hope the first packet will get across OK */

    if (kermwdes && w[kermwdes].kerm_act) return (-1);
    kermwdes = curwin;
    					/* If kermit already active, return. */
    w[kermwdes].kerm_act = TRUE;	/* mark current window to send output
    					   to kermit instead of emulator */
    kermport = find_port(curwin);
    eol = CR;                           /* EOL for outgoing packets */
    quote = '#';                        /* Standard control-quote char "#" */
    pad = 0;                            /* No padding */
    padchar = '\0';                     /* Use null if any padding wanted */
    timint = MYTIME;                    /* default timint */

 
/*
 * Set direction and paramaters debug, filnamcnv, image with dialog
 */
    rsrc_gaddr(R_TREE, KERMPARM, &obj_tmp);
    if (obj_tmp[ASCIIMOD].ob_state == NORMAL &&
      obj_tmp[IMAGEMOD].ob_state == NORMAL)
    {					/* initalize object and statics */
        objc_change(obj_tmp, ASCIIMOD, 0, 0, 0, 0, 0, SELECTED, 0);
        objc_change(obj_tmp, CONVNAME, 0, 0, 0, 0, 0, SELECTED, 0);
        objc_change(obj_tmp, RECFILE, 0, 0, 0, 0, 0, SELECTED, 0);

	path[0] = Dgetdrv() + 'a';
	path[1] = ':';
	Dgetpath(path+2, 0);
	strcat(path, "\\*.*");
    }
    if ((butt = s_dial(KERMPARM, 3)) == KERMEXIT) return(kermterm());
    if (obj_tmp[DEBUGENA].ob_state == SELECTED)
    {
        debug = obj_tmp[DEBUG1].ob_state + obj_tmp[DEBUG2].ob_state
	+ obj_tmp[DEBUG3].ob_state;
    }
    if (butt == RECFILE) obj_tmp[RECFILE].ob_state = SELECTED;
    if (butt == SENDFILE) obj_tmp[SENDFILE].ob_state = SELECTED;
    rflg = obj_tmp[RECFILE].ob_state;
    sflg = obj_tmp[SENDFILE].ob_state;
    image = (obj_tmp[IMAGEMOD].ob_state == SELECTED);
    filnamcnv = obj_tmp[CONVNAME].ob_state; /* conversion for UNIX systems */
    
/* All set up, now execute the command that was given. */

    if (debug)
    {
        printmsg("debuging level = %d\n",debug);

        if (sflg) printmsg("Send command\n");
        if (rflg) printmsg("Receive command\n");
    }
  
    if (sflg)                           /* Send command */ 
    {
    	extern char * rindex();

	if (!mouse)
	{
	    graf_mouse(M_ON, NULL);
	    ++mouse;
	}
        fsel_input(path, file, &butt);
	if (! butt) return(kermterm()); 
	strcpy(filename, path);
	if (debug > 2) printmsg("directory %s", filename);
	filnam = rindex(filename, '\\');
	if (filnam) *(++filnam) = '\0';
	strcat(filename, file);
        filnam = filename;		/* Get file to send */
        if (debug > 2) printmsg("sending %s",filnam);
        fp = NULL;                      /* Indicate no file open yet */
        filelist = NULL;                /* Set up the rest of the file list */
        filecount = 0;                  /* Number of files left to send */
	state = 'S';                    /* Send initiate is the start state */
	n = 0;                          /* Initialize message number */
	numtry = 0;                     /* Say no tries yet */
        w[kermwdes].kerm_act = TRUE;	/* mark current window to send output
    					   to kermit instead of emulator */
	timestamp = clock();		/* reset timer */
	sendsw();
    }

    if (rflg)                           /* Receive command */
    {
	state = 'R';                    /* Receive-Init is the start state */
	n = 0;                          /* Initialize message number */
	numtry = 0;                     /* Say no tries yet */
	timestamp = clock();		/* reset timer */
    }
    
    return(0);
}

/*
 * kermterm - Terminate kermit and tell uw not to call us again.
 */
kermterm()
{
    sflg = rflg = 0;
    w[kermwdes].kerm_act = FALSE;
    kermwdes = 0;
}

kermtimchk()
{
    if (!w[kermwdes].kerm_act)	/* is kermit active? */
    {
	kermwdes = 0;
	return;
    }
    if ((clock() - timestamp) / CLK_TCK > timint)	/* timeout ? */
    {
	rpack(NULL, "", "");	/* tell FSM about time out */
    }
}

/*
 *  s e n d s w
 *
 *  Sendsw is the state table switcher for sending files.  It loops until
 *  either it finishes, or an error is encountered.  The routines called
 *  by sendsw are responsible for changing the state.
 *
 */

int sendsw()
{
    chari sinit(), sfile(), sdata(), seof(), sbreak(), nstate;

    nstate = state;
    while(TRUE)                         /* Do this as long as necessary */
    {
        if (debug) printmsg("sendsw state: %c  nstate: %c\n",state,nstate);
	while (nstate != 'I')
	{
            switch(nstate)
            {
                case 'S':   nstate = sinit();  break; /* Send-Init */
                case 'F':   nstate = sfile();  break; /* Send-File */
                case 'D':   nstate = sdata();  break; /* Send-Data */
                case 'Z':   nstate = seof();   break; /* Send-End-of-File */
                case 'B':   nstate = sbreak(); break; /* Send-Break */
            }
	    switch(nstate)
	    {
                case 'C':   printmsg("\aDone.\a");
	    		    return (TRUE);           /* Complete */
                case 'A':   printmsg("Send Failed.");
	    		    return (FALSE);          /* "Abort" */
	    }
	    if (nstate != 'I')
	    {
	        state = nstate;
	        if (numtry++ > MAXTRY) return(FALSE); /* If too many tries, give up */
	    }
	}
	return(GETPACK);
    }
}


/*
 *  s i n i t
 *
 *  Send Initiate: send this host's parameters and get other side's back.
 */

chari sinit()
{
    int num, len;                       /* Packet number, length */
    static int sent = 0;

    if (! sent) {
	reqtimint = MYTIME;
	spar(packet);                   /* Fill up init info packet */
	flushinput();                   /* Flush pending input */
	spack('S',n,6,packet);          /* Send an S packet */

	sent = 1;
	return('I');			/* get packet to read */
    }
    sent = 0;
    switch(rpack(&len,&num,recpkt))     /* What was the reply? */
    {
        case 'N':  return(state);       /* NAK, try it again */

        case 'Y':                       /* ACK */
            if (n != num)               /* If wrong ACK, stay in S state */
                return(state);          /* and try again */
            rpar(recpkt);               /* Get other side's init info */

            if (eol == 0) eol = '\n';   /* Check and set defaults */
            if (quote == 0) quote = '#';
            if(abs(timint - reqtimint) < 3) timint = reqtimint + 3;
            /* guarentee diference of > 3 for sounds for timint */

            numtry = 0;                 /* Reset try counter */
            n = (n+1)%64;               /* Bump packet count */
            return('F');                /* OK, switch state to F */

        case 'E':                       /* Error packet received */
            prerrpkt(recpkt);           /* Print it out and */
            return('A');                /* abort */

        case FALSE: return(state);      /* Receive failure, try again */

        default: return('A');           /* Anything else, just "abort" */
   }
 }


/*
 *  s f i l e
 *
 *  Send File Header.
 */

chari sfile()
{
    int num, len;                       /* Packet number, length */
    char filnam1[50],                   /* Converted file name */
        *newfilnam,                     /* Pointer to file name to send */
        *cp;                            /* char pointer */
    static int sent = 0;

    if (! sent) {
        if (fp == NULL)                     /* If not already open, */
        {   if (debug) printmsg("   Opening %s for sending.\n",filnam);
            fp = fopen(filnam, image ? "rb" : "r");         /* open the file to be sent */
            if (fp == NULL)                 /* If bad file pointer, give up */
            {
                error("Cannot open file %s",filnam);
                return('A');
            }
        }

        strcpy(filnam1, filnam);            /* Copy file name */
        newfilnam = cp = filnam1;
        while (*cp != '\0')                 /* Strip off all leading directory */
            if (*cp++ == '\\')               /* names (ie. up to the last /). */
                newfilnam = cp;

        if (filnamcnv)                      /* Convert lower case to upper  */
            for (cp = newfilnam; *cp != '\0'; cp++)
                if (*cp >= 'a' && *cp <= 'z')
                    *cp ^= 040;

        len = cp - newfilnam;               /* Compute length of new filename */

        printmsg("Sending %s as %s",filnam,newfilnam);

        spack('F',n,len,newfilnam);         /* Send an F packet */
	sent = 1;
	
	return('I');			/* get packet to read */
    }
    sent = 0;
    switch(rpack(&len,&num,recpkt))     /* What was the reply? */
    {                   
        case 'N':                       /* NAK, just stay in this state, */
            num = (--num<0 ? 63:num);   /* unless it's NAK for next packet */
            if (n != num)               /* which is just like an ACK for */ 
                return(state);          /* this packet so fall thru to... */

        case 'Y':                       /* ACK */
            if (n != num) return(state); /* If wrong ACK, stay in F state */
            numtry = 0;                 /* Reset try counter */
            n = (n+1)%64;               /* Bump packet count */
            size = bufill(packet);      /* Get first data from file */
            return('D');                /* Switch state to D */

        case 'E':                       /* Error packet received */
            prerrpkt(recpkt);           /* Print it out and */
            return('A');                /* abort */

        case FALSE: return(state);      /* Receive failure, stay in F state */

        default:    return('A');        /* Something else, just "abort" */
    }
}


/*
 *  s d a t a
 *
 *  Send File Data
 */

chari sdata()
{
    int num, len;                       /* Packet number, length */
    static int sent = 0;

    if (! sent) {
        spack('D',n,size,packet);           /* Send a D packet */
	sent = 1;
	return('I');			/* get packet to read */
    }
    sent = 0;
    switch(rpack(&len,&num,recpkt))     /* What was the reply? */
    {               
        case 'N':                       /* NAK, just stay in this state, */
            num = (--num<0 ? 63:num);   /* unless it's NAK for next packet */
            if (n != num)               /* which is just like an ACK for */
                return(state);          /* this packet so fall thru to... */
                
        case 'Y':                       /* ACK */
            if (n != num) return(state); /* If wrong ACK, fail */
            numtry = 0;                 /* Reset try counter */
            n = (n+1)%64;               /* Bump packet count */
            if ((size = bufill(packet)) == EOF) /* Get data from file */
                return('Z');            /* If EOF set state to that */
            return('D');                /* Got data, stay in state D */

        case 'E':                       /* Error packet received */
            prerrpkt(recpkt);           /* Print it out and */
            return('A');                /* abort */

        case FALSE: return(state);      /* Receive failure, stay in D */

        default:    return('A');        /* Anything else, "abort" */
    }
}


/*
 *  s e o f
 *
 *  Send End-Of-File.
 */

chari seof()
{
    int num, len;                       /* Packet number, length */
    static int sent = 0;

    if (! sent) {
        spack('Z',n,0,packet);              /* Send a 'Z' packet */

	sent = 1;
	return('I');			/* get packet to read */
    }
    sent = 0;
    switch(rpack(&len,&num,recpkt))     /* What was the reply? */
    {
        case 'N':                       /* NAK, just stay in this state, */
            num = (--num<0 ? 63:num);   /* unless it's NAK for next packet, */
            if (n != num)               /* which is just like an ACK for */
                return(state);          /* this packet so fall thru to... */

        case 'Y':                       /* ACK */
            if (n != num) return(state); /* If wrong ACK, hold out */
            numtry = 0;                 /* Reset try counter */
            n = (n+1)%64;               /* and bump packet count */
            if (debug) printmsg("   Closing input file %s, ",filnam);
            fclose(fp);                 /* Close the input file */
            fp = NULL;                  /* Set flag indicating no file open */ 

            if (debug) printmsg("looking for next file...\n");
            if (gnxtfl() == FALSE)      /* No more files go? */
                return('B');            /* if not, break, EOT, all done */
            if (debug) printmsg("   New file is %s\n",filnam);
            return('F');                /* More files, switch state to F */

        case 'E':                       /* Error packet received */
            prerrpkt(recpkt);           /* Print it out and */
            return('A');                /* abort */

        case FALSE: return(state);      /* Receive failure, stay in Z */

        default:    return('A');        /* Something else, "abort" */
    }
}


/*
 *  s b r e a k
 *
 *  Send Break (EOT)
 */

chari sbreak()
{
    int num, len;                       /* Packet number, length */
    static int sent = 0;

    if (! sent) {
        spack('B',n,0,packet);              /* Send a B packet */

	sent = 1;
	return('I');			/* get packet to read */
    }
    sent = 0;
    switch (rpack(&len,&num,recpkt))    /* What was the reply? */
    {
        case 'N':                       /* NAK, just stay in this state, */
            num = (--num<0 ? 63:num);   /* unless NAK for previous packet, */
            if (n != num)               /* which is just like an ACK for */
                return(state);          /* this packet so fall thru to... */

        case 'Y':                       /* ACK */
            if (n != num) return(state); /* If wrong ACK, fail */
            numtry = 0;                 /* Reset try counter */
            n = (n+1)%64;               /* and bump packet count */
            return('C');                /* Switch state to Complete */

        case 'E':                       /* Error packet received */
            prerrpkt(recpkt);           /* Print it out and */
            return('A');                /* abort */

        case FALSE: return(state);      /* Receive failure, stay in B */

        default:    return ('A');       /* Other, "abort" */
   }
}


/*
 *  r e c s w
 *
 *  This is the state table switcher for receiving files.
 */




recsw()
{
    chari rinit(), rfile(), rdata();     /* Use these procedures */

    if (debug) printmsg(" recsw state: %c\n",state);
    switch(state)                   /* Do until done */
    {
        case 'R':   state = rinit(); break; /* Receive-Init */
        case 'F':   state = rfile(); break; /* Receive-File */
        case 'D':   state = rdata(); break; /* Receive-Data */
    }
    if (numtry++ > MAXTRY) return(FALSE); /* If too many tries, give up */
    switch(state)                   /* Do until done */
    {
        case 'C':   printmsg("\aDone.\a");
		    return(TRUE);           /* Complete state */
        case 'A':   printmsg("Receive Failed.");
		    return(FALSE);          /* "Abort" state */
    }
    return(GETPACK);			    /* get the next packet */
}

    
/*
 *  r i n i t
 *
 *  Receive Initialization
 */
  
chari rinit()
{
    int len, num;                       /* Packet length, number */

    switch(rpack(&len,&num,packet))     /* Get a packet */
    {
        case 'S':                       /* Send-Init */
            rpar(packet);               /* Get the other side's init data */
            if (timint > MYTIME + 3) reqtimint = timint - 4;
            else reqtimint = timint + 4;
            spar(packet);               /* Fill up packet with my init info */
            flushinput();               /* get rid of unwanted nak's */
            spack('Y',n,6,packet);      /* ACK with my parameters */
            oldtry = numtry;            /* Save old try count */
            numtry = 0;                 /* Start a new counter */
            n = (n+1)%64;               /* Bump packet number, mod 64 */
            return('F');                /* Enter File-Receive state */

        case 'E':                       /* Error packet received */
            prerrpkt(recpkt);           /* Print it out and */
            return('A');                /* abort */

        case FALSE:                     /* Didn't get packet */
            spack('N',n,0,NULL);        /* Return a NAK */
            return(state);              /* Keep trying */

        default:     return('A');       /* Some other packet type, "abort" */
    }
}


/*
 *  r f i l e
 *
 *  Receive File Header
 */

chari rfile()
{
    int num, len;                       /* Packet number, length */
    char filnam1[50];                   /* Holds the converted file name */

    switch(rpack(&len,&num,packet))     /* Get a packet */
    {
        case 'S':                       /* Send-Init, maybe our ACK lost */
            if (oldtry++ > MAXTRY) return('A'); /* If too many tries "abort" */
            if (num == ((n==0) ? 63:n-1)) /* Previous packet, mod 64? */
            {                           /* Yes, ACK it again with  */
                spar(packet);           /* our Send-Init parameters */
                spack('Y',num,6,packet);
                numtry = 0;             /* Reset try counter */
                return(state);          /* Stay in this state */
            }
            else return('A');           /* Not previous packet, "abort" */

        case 'Z':                       /* End-Of-File */
            if (oldtry++ > MAXTRY) return('A');
            if (num == ((n==0) ? 63:n-1)) /* Previous packet, mod 64? */
            {                           /* Yes, ACK it again. */
                spack('Y',num,0,NULL);
                numtry = 0;
                return(state);          /* Stay in this state */
            }
            else return('A');           /* Not previous packet, "abort" */

        case 'F':                       /* File Header (just what we want) */
            if (num != n) return('A');  /* The packet number must be right */
            strcpy(filnam1, packet);    /* Copy the file name */

            if (filnamcnv)              /* Convert upper case to lower */
                for (filnam=filnam1; *filnam != '\0'; filnam++)
                    if (*filnam >= 'A' && *filnam <= 'Z')
                        *filnam |= 040;

            if ((fp=fopen(filnam1, image ? "wb" : "w"))==NULL) /* Try to open a new file */
            {
                error("Cannot create %s",filnam1); /* Give up if can't */
                return('A');
            }
            else                        /* OK, give message */

                printmsg("Receiving %s as %s",packet,filnam1);

            spack('Y',n,0,NULL);        /* Acknowledge the file header */
            oldtry = numtry;            /* Reset try counters */
            numtry = 0;                 /* ... */
            n = (n+1)%64;               /* Bump packet number, mod 64 */
            return('D');                /* Switch to Data state */

        case 'B':                       /* Break transmission (EOT) */
            if (num != n) return ('A'); /* Need right packet number here */
            spack('Y',n,0,NULL);        /* Say OK */
            return('C');                /* Go to complete state */

        case 'E':                       /* Error packet received */
            prerrpkt(recpkt);           /* Print it out and */
            return('A');                /* abort */

        case FALSE:                     /* Didn't get packet */
            spack('N',n,0,NULL);        /* Return a NAK */
            return(state);              /* Keep trying */

        default:    return ('A');       /* Some other packet, "abort" */
    }
}


/*
 *  r d a t a
 *
 *  Receive Data
 */

chari rdata()
{
    int num, len;                       /* Packet number, length */

    switch(rpack(&len,&num,packet))     /* Get packet */
    {
        case 'D':                       /* Got Data packet */
#ifdef EXTRADEBUG
	    if (debug > 2) printmsg("Got Data Packet");
#endif
            if (num != n)               /* Right packet? */
            {                           /* No */
                if (oldtry++ > MAXTRY)
                    return('A');        /* If too many tries, abort */
                if (num == ((n==0) ? 63:n-1)) /* Else check packet number */
                {                       /* Previous packet again? */
                    spack('Y',num,6,packet); /* Yes, re-ACK it */
                    numtry = 0;         /* Reset try counter */
                    return(state);      /* Don't write out data! */
                }
                else return('A');       /* sorry, wrong number */
            }
            /* Got data with right packet number */
            spack('Y',n,0,NULL);        /* Acknowledge the packet */
#ifdef EXTRADEBUG
	    if (debug > 2) printmsg("Calling bufemp");
#endif
            bufemp(packet,len);         /* Write the data to the file */
            oldtry = numtry;            /* Reset the try counters */
            numtry = 0;                 /* ... */
            n = (n+1)%64;               /* Bump packet number, mod 64 */
            return('D');                /* Remain in data state */

        case 'F':                       /* Got a File Header */
            if (oldtry++ > MAXTRY)
                return('A');            /* If too many tries, "abort" */
            if (num == ((n==0) ? 63:n-1)) /* Else check packet number */
            {                           /* It was the previous one */
                spack('Y',num,0,NULL);  /* ACK it again */
                numtry = 0;             /* Reset try counter */
                return(state);          /* Stay in Data state */
            }
            else return('A');           /* Not previous packet, "abort" */

        case 'Z':                       /* End-Of-File */
            if (num != n) return('A');  /* Must have right packet number */
            spack('Y',n,0,NULL);        /* OK, ACK it. */
            fclose(fp);                 /* Close the file */
            n = (n+1)%64;               /* Bump packet number */
            return('F');                /* Go back to Receive File state */

        case 'E':                       /* Error packet received */
            prerrpkt(recpkt);           /* Print it out and */
            return('A');                /* abort */

        case FALSE:                     /* Didn't get packet */
            spack('N',n,0,NULL);        /* Return a NAK */
            return(state);              /* Keep trying */

        default:     return('A');       /* Some other packet, "abort" */
    }
}


/*
 *      KERMIT utilities.
 */


/*
 *  s p a c k
 *
 *  Send a Packet
 */

spack(type,num,len,data)
chari type;
char  *data;
int num, len;
{
    int i;                              /* Character loop counter */
    char chksum, buffer[100];           /* Checksum, packet buffer */
    register char *bufp;                /* Buffer pointer */

    if (debug>1)                        /* Display outgoing packet */
    {
        printmsg("  spack type: %c\n",type);
        printmsg("         num:  %d\n",num);
        printmsg("         len:  %d\n",len);
        if (data != NULL)
	{
            data[len] = '\0';           /* Null-terminate data to print it */
            printmsg("        data: \"%s\"\n",data);
	}
    }
  
    bufp = buffer;                      /* Set up buffer pointer */
    for (i=1; i<=pad; i++) proto_out(kermport,&padchar,1); /* Issue any padding */

    *bufp++ = SOH;                      /* Packet marker, ASCII 1 (SOH) */
    *bufp++ = tochar(len+3);            /* Send the character count */
    chksum  = tochar(len+3);            /* Initialize the checksum */
    *bufp++ = tochar(num);              /* Packet number */
    chksum += tochar(num);              /* Update checksum */
    *bufp++ = type;                     /* Packet type */
    chksum += type;                     /* Update checksum */

    for (i=0; i<len; i++)               /* Loop for all data characters */
    {
        *bufp++ = data[i];              /* Get a character */
        chksum += data[i];              /* Update checksum */
    }
    chksum = (((chksum&0300) >> 6)+chksum)&077; /* Compute final checksum */
    *bufp++ = tochar(chksum);           /* Put it in the packet */
    *bufp = eol;                        /* Extra-packet line terminator */
    proto_out(kermport, buffer, bufp-buffer+1);
    					/* Send the packet */
#ifdef EXTRADEBUG
    if (debug > 2) printmsg("Returning from spack");
#endif
}

/*
 *  r p a c k
 *
 *  Read a Packet
 *  This routine is called both to buffer data from the host to the kermit
 *  window and to retreive those buffers once they contain a packet.  This
 *  routine calls the kermit state machine when it has a complete packet.
 *  The kermit state machine in turn calls this routine to retreive the packet.
 *  Thus, this routine is indirectly recursive to two levels.  Receive timeouts
 *  and bad packets cause FALSE to be returned to the state machine.  The uw
 *  control loop calls us with num == NULL to pass us a string of data from
 *  the host.  The uw control loop calls us with len == NULL if the timout
 *  counter (kerm_time) exceeds timint without us reseting it.
 */
#ifdef EXTRADEBUG
#define getnext {t = *dptr++; \
	        if (debug>2) printmsg( "char %d state %c", t, recstate);\
		if ((t & 0177) == SOH) { \
			recstate = 'L'; /* restart packet collection */\
			break; } \
		if (!image) t &= 0177;	/* Handle parity */ \
		if (t == 0) break; /* end of this input buffer */ }
#else
#define getnext {t = *dptr++; \
		if ((t & 0177) == SOH) { \
			recstate = 'L'; /* restart packet collection */\
			break; } \
		if (!image) t &= 0177;	/* Handle parity */ \
		if (t == 0) break; /* end of this input buffer */ }
#endif
rpack(len,num,data)
int *len, *num;                         /* Packet length, number */
char *data;                             /* Packet data */
{
    static int i;                       /* Data character number */
    static int leng;			/* length of data packet in buffer */
    static char type;			/* packet type */
    static int numb;			/* number of data packet in buffer */
    static int timedout = 0;		/* did we time out? */
    char t;                             /* Current input character */
    static char cchksum,                        /* Our (computed) checksum */
        rchksum;                        /* Checksum received from other host */
    char *dptr;				/* pointer to next data byte */
    static char mybuf[MAXPACKSIZ];	/* buffer used to acumulate packet */
    static char recstate = 'S';		/* start with S state */

    if (len == NULL) {	/* timed out */
        timedout = TRUE;
	if (sflg)
	{
	    if (sendsw() != GETPACK)    /* Send the file(s) */
                return(kermterm());
	}
	else if (rflg)
	{
            if (recsw() != GETPACK)     /* Receive the file(s) */
                return(kermterm());
	}
        return (0);
    }
    if (len != NULL && num != NULL)	/* received packet or timed out */
    {
	*len = leng;
	*num = numb;
	timestamp = clock();		/* reset timer */
	if (timedout)
	{
	    printmsg("Timeout.");
	    timedout = 0;
	    return(FALSE);
	}
	for (i=0; i<leng; i++)
	    data[i] = mybuf[i];
        if (data != NULL)
            data[*len] = '\0';          /* Null-terminate data to print it */
        if (debug>1)                    /* Display incoming packet */
        {
            printmsg("  rpack type: %c\n",type);
            printmsg("         num:  %d\n",*num);
            printmsg("         len:  %d\n",*len);
            if (data != NULL)
                printmsg("        data: \"%s\"\n",data);
        }
                                        /* Fold in bits 7,8 to compute */
        cchksum = (((cchksum&0300) >> 6)+cchksum)&077; /* final checksum */

        if (cchksum != rchksum) return(FALSE);

        return(type);                       /* All OK, return packet type */
    }
    /* num == NULL so collect data for kermit */
    dptr = data;
    t = -1;
    while (t)
    {
      switch(recstate)
      {
        case 'S':
	    while (1)	        /* Wait for packet header */
	        getnext;
	    break;
	case 'L':			/* get packet length */
            getnext;			/* get next character */
            cchksum = t;                    /* Start the checksum */
            leng = unchar(t)-3;             /* Character count */
	    if (leng > MAXPACKSIZ)
	        leng = MAXPACKSIZ;
	    i = 0;
	    recstate = 'N';
	    /* Fall Through */

	case 'N':			    /* get packet number */
            getnext
            cchksum = cchksum + t;          /* Update checksum */
            numb = unchar(t);               /* Packet number */
	    recstate = 'T';
	    /* Fall Through */

	case 'T':			    /* get packet type */
            getnext;
            cchksum = cchksum + t;          /* Update checksum */
            type = t;                       /* Packet type */
	    recstate = 'D';
	    /* Fall Through */

	case 'D':			    /* get packet data */
            for (; i<leng; i++)             /* The data itself, if any */
            {                               /* Loop for character count */
                getnext;
                cchksum = cchksum + t;      /* Update checksum */
                mybuf[i] = t;                /* Put it in the data buffer */
            }
	    if (i == leng) 
	        recstate = 'C';
	    break;

	case 'C':
            mybuf[leng] = 0;                 /* Mark the end of the data */
            getnext;
            rchksum = unchar(t);            /* Convert to numeric */
	    recstate = 'E';		    /* Done with packet receipt */
	    t = 0;			    /* Dispose of remaining data */
      }
    }
    if (recstate == 'E') {
        recstate = 'S';
	if (sflg)
	{
	    if (sendsw() != GETPACK)        /* Send the file(s) */
                return(kermterm());
	}
	else if (rflg)
	{
            if (recsw() != GETPACK)         /* Receive the file(s) */
                return(kermterm());
	}
    }
    return(0);
}


/*
 *  b u f i l l
 *
 *  Get a bufferful of data from the file that's being sent.
 *  Only control-quoting is done; 8-bit & repeat count prefixes are
 *  not handled.
 */

bufill(buffer)
char buffer[];                          /* Buffer */
{
    int i,                              /* Loop index */
        t;                              /* Char read from file */
    char t7;                            /* 7-bit version of above */

    i = 0;                              /* Init data buffer pointer */
    while((t = getc(fp)) != EOF)        /* Get the next character */
    {
        t7 = t & 0177;                  /* Get low order 7 bits */

        if (t7 < SP || t7==DEL || t7==quote) /* Does this char require */
        {                                   /* special handling? */
            if (t=='\n' && !image)
            {                           /* Do LF->CRLF mapping if !image */
                buffer[i++] = quote;
                buffer[i++] = ctl('\r');
            }
            buffer[i++] = quote;        /* Quote the character */
            if (t7 != quote)
            {
                t = ctl(t);             /* and uncontrolify */
                t7 = ctl(t7);
            }
        }
        if (image)
            buffer[i++] = t;            /* Deposit the character itself */
        else
            buffer[i++] = t7;

        if (i >= spsiz-8) return(i);    /* Check length */
    }
    if (i==0) return(EOF);              /* Wind up here only on EOF */
    return(i);                          /* Handle partial buffer */
}


/*
 *      b u f e m p
 *
 *  Put data from an incoming packet into a file.
 */

bufemp(buffer,len)
char  buffer[];                         /* Buffer */
int   len;                              /* Length */
{
    int i;                              /* Counter */
    char t;                             /* Character holder */

#ifdef EXTRADEBUG
	    if (debug > 2) printmsg("Entered bufemp");
#endif
    for (i=0; i<len; i++)               /* Loop thru the data field */
    {
        t = buffer[i];                  /* Get character */
        if (t == MYQUOTE)               /* Control quote? */
        {                               /* Yes */
            t = buffer[++i];            /* Get the quoted character */
            if ((t & 0177) != MYQUOTE)  /* Low order bits match quote char? */
                t = ctl(t);             /* No, uncontrollify it */
        }
        if (t==CR && !image)            /* Don't pass CR if not in image mode */
            continue;
#ifdef EXTRADEBUG
	    if (debug > 2) printmsg("writing t=%c", t);
#endif
        putc(t,fp);
    }
}



/*
 *  g n x t f l
 *
 *  Get next file in a file group
 */

gnxtfl()
{
    if (filecount-- == 0) return FALSE; /* If no more, fail */
    if (debug) printmsg("   gnxtfl: filelist = \"%s\"\n",*filelist);
    filnam = *(filelist++);
    return TRUE;                   /* else succeed */
}


/*
 *  s p a r
 *
 *  Fill the data array with my send-init parameters
 *
 */

spar(data)
char data[];
{
    data[0] = tochar(MAXPACKSIZ);          /* Biggest packet I can receive */
    data[1] = tochar(reqtimint);           /* When I want to be timed out */
    data[2] = tochar(MYPAD);            /* How much padding I need */
    data[3] = ctl(MYPCHAR);             /* Padding character I want */
    data[4] = tochar(MYEOL);            /* End-Of-Line character I want */
    data[5] = MYQUOTE;                  /* Control-Quote character I send */
}


/*  r p a r
 *
 *  Get the other host's send-init parameters
 *
 */

rpar(data)
char data[];
{
    spsiz = unchar(data[0]);            /* Maximum send packet size */
    timint = unchar(data[1]);           /* When I should time out */
    if (timint > MAXTIM) timint = MAXTIM;
    if (timint < MINTIM) timint = MINTIM;
    pad = unchar(data[2]);              /* Number of pads to send */
    padchar = ctl(data[3]);             /* Padding character to send */
    eol = unchar(data[4]);              /* EOL character I must send */
    quote = data[5];                    /* Incoming data quote character */
}
 

/*
 *  Kermit printing routines:
 *
 *  printmsg -  like printf with "Kermit: " prepended
 *  prerrpkt - print contents of error packet received from remote host
 */


/*
 *  p r i n t m s g
 *
 *  Print message kermit window
 */

/*VARARGS1*/
printmsg(fmt, a1, a2, a3, a4, a5)
char *fmt;
{
	char *sbuf[100];
        w_output(kermwdes,"Kermit: ");
        sprintf(sbuf,fmt,a1,a2,a3,a4,a5);
        w_output(kermwdes,sbuf);
        w_output(kermwdes,"\n\r");
}


/*
 *  p r e r r p k t
 *
 *  Print contents of error packet received from remote host.
 */
prerrpkt(msg)
char *msg;
{
    printmsg("Kermit aborting with following error from remote host:\n%s",msg);
    return;
}
