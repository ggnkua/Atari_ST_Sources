#include <stdio.h>

#define	FALSE 0
#define TRUE 1

#define DOTS		50	/* SECTOR COUNTING DOTS PER LINE */
#define	SECSIZ		0x80
#define	BUFSIZ		0x1000	/* Text buffer */
#define	ERRORMAX	20	/* MAX ERRORS BEFORE ABORT */
#define	RETRYMAX	15	/* MAXIMUM RETRYS BEFORE ABORT */

#define	SOH		1	/* START OF SECTOR CHAR */
#define	EOT		4	/* end of transmission char */
#define	ACK		6	/* acknowledge sector transmission */
#define	NAK		21	/* error in transmission detected */

static char
    bufr[ BUFSIZ ],
    filename[ 14 ];

static int
    fd;

int
    mtimeout;

int
    mdm_packets_sent,
    mdm_packets_received,
    mdm_bad_packets,
    mdm_naked_packets;

long
    mdm_bytes_xferred;

extern jmp_buf
    abort_env,
    env;

extern int
    debug;

extern unsigned char
    read_modem ();

mdmini()
{
mtimeout = 60;
mdm_bytes_xferred = 0L;
mdm_packets_sent = 0;
mdm_packets_received = 0;
mdm_bad_packets = 0;
mdm_naked_packets = 0;
}

sendchar(data)
unsigned int data;
{
unsigned char
    buf[1];

buf[0] = (unsigned char) data;
write_modem (buf, 1);
}

readfile(file)
char *file;
{
int
    firstchar,
    sectnum,
    sectcurr,
    sectcomp,
    errors,
    errorflag;

unsigned int
    checksum,
    j,
    bufptr;

mdmini ();
if ((fd = creat(file,BWRITE)) < 0)
    {
    error("cannot open %s (%x)",file,fd);
    return(FALSE);
    }
else
    printmsg("receiving %s",file);

sectnum = errors = bufptr = 0;
flushinput();
sendchar(NAK);
if (setjmp(env)) return(FALSE);		/* timeout */
if (setjmp(abort_env)) return(FALSE);

while (firstchar != EOT && errors != ERRORMAX)
    {
    errorflag = FALSE;
    alarm (mtimeout);			/* set timeout trap */
    do					/* get sync char */
	{
        firstchar = read_modem();
	if (debug)
	    printf("Got char '%x'\n", firstchar);
	} while (firstchar != SOH && firstchar != EOT);
    if (firstchar == SOH)
	{
        sectcurr = read_modem();
        sectcomp = read_modem();
	if (debug) printf("Sector %x, ~%x\n", sectcurr, sectcomp);
        if ((sectcurr + sectcomp) == 255)
	    {
            if (sectcurr == (sectnum + 1 & 0xff))
		{
                checksum = 0;
                for (j = bufptr;j < (bufptr + SECSIZ);j++)
		    {
                    bufr[j] = read_modem();
                    checksum = (checksum + bufr[j]) & 0xff;
                    }
                if (checksum == read_modem())
		    {
		    mdm_packets_received++;
		    mdm_notify_hook ();
                    errors = 0;
                    sectnum++;
                    bufptr += SECSIZ;
		    mdm_bytes_xferred += SECSIZ;
                    if (bufptr == BUFSIZ)
			{
                        bufptr = 0;
                        if (write(fd,bufr,BUFSIZ) == EOF)
			    {
                            error("error writing file");
                            close(fd);
			    alarm(0);
                            return(FALSE);
                            };
                        };
		    flushinput ();
                    sendchar(ACK);
                    }
                else
		    {
		    mdm_bad_packets++;
		    mdm_notify_hook ();
                    errorflag = TRUE;
		    if (debug)
			{
                        printmsg("checksum error, expected ");
                        printmsg("<%02x>",checksum);
			};
                    }
                }
            else
		{
                if (sectcurr == (sectnum & 0xff))
		    {
                    printmsg("received duplicate sector %d",sectnum);
		    flushinput();
                    sendchar(ACK);
                    }
                else
		    {
		    if (debug)
			error("synch error");
		    mdm_bad_packets++;
		    mdm_notify_hook ();
		    errorflag = TRUE;
		    }
                }
            }
        else
	    {
	    if (debug)
		error("sector number error");
	    mdm_bad_packets++;
	    mdm_notify_hook ();
	    errorflag = TRUE;
	    }
        }
    if (errorflag == TRUE)
	{
        errors++;
        printmsg("error %d",errors);
	flushinput();
        sendchar(NAK);
        }

    };	/* end while */
	    
if ((firstchar == EOT) && (errors < ERRORMAX))
    {
    sendchar(ACK);
    write(fd,bufr,bufptr);
    close(fd);
    alarm(0);
    return(TRUE);
    }
alarm(0);
return(FALSE);
}

sendfile(file)
char *file;
{
int
    sectnum,
    sectors,
    attempts;

unsigned int
    checksum,
    j,
    bufptr;

char
    c;

mdmini ();
if ((fd = open(file,BREAD)) < 0)
    {
    error("cannot open %s",file);
    return(FALSE);
    }
else
    printmsg("sending %s",file);

attempts = 0;
sectnum = 1;
j = 0;

if (setjmp(env)) return(FALSE);
if (setjmp(abort_env)) return(FALSE);

alarm(mtimeout);
while (((c = read_modem ()) != NAK) && (j++ < (ERRORMAX*2)))
    if (debug)
	printf ("Ate char '%x'\n", c);

if (j >= (ERRORMAX*2))
    { error("Receiver not sending NAKs");  alarm(0);  return(FALSE); };

if (debug)
    printf ("Got ACK: '%x'\n", c);

flushinput ();
alarm(mtimeout);

while ((sectors = read(fd,bufr,BUFSIZ))
        && (attempts != RETRYMAX))
    {
    if (sectors == EOF)
	{
        error("error reading file");
        close(fd);
	alarm(0);
        return(FALSE);
        };
    bufptr = 0;
    do
        {
        attempts = 0;
        do
            {
	    alarm(mtimeout);
            if (debug)
                if (((sectnum - 1) % DOTS) == 0)
                    printf("\012\015<%4d>.",sectnum);
                else
                    printf(".");
            sendchar(SOH);
            sendchar(sectnum);
            sendchar(~sectnum);
            checksum = 0;
	    write_modem(&bufr[bufptr],SECSIZ);
            for (j = bufptr; j < (bufptr+SECSIZ); j++)
                checksum += bufr[j];
            sendchar(checksum);
	    flushinput();
	    mdm_packets_sent++;
	    mdm_notify_hook ();
            attempts++;
	    c = read_modem();
	    if (c != ACK) mdm_naked_packets++;
	    if (debug)
		printf ("Response char is '%x'\n", c);
            } while ((c != ACK) && 
                (attempts != RETRYMAX));
        bufptr += SECSIZ;
	mdm_bytes_xferred += SECSIZ;
        sectnum++;
        } while ((bufptr < sectors) && (attempts != RETRYMAX));
    };

close(fd);
if (attempts == RETRYMAX)
    {
    error("no acknowledgment of sector, aborting");
    alarm(0);
    return(FALSE);
    }
else
    {
    attempts = 0;
    do
	{
        sendchar(EOT);
        attempts++;
	} while ((read_modem() != ACK) && (attempts != RETRYMAX));
    if (attempts == RETRYMAX)
        error("no acknowledgment of end of file");
    };
alarm(0);
return(TRUE);
}
