#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <tos.h>

#include "\include\drivers.h"
#include "\include\transprt.h"

#define CON 2

/* These definitions are necessary.  transprt.h has external
 * declarations for them.
 */
DRV_LIST *drivers = (DRV_LIST *)NULL;
TPL *tpl = (TPL *)NULL;

static long msglist[100];
static int16 nextmsg = 0, endmsg = 0;
static char mailpath[50];

static void strip_crlf(char *s)
{
    register int16 len = (int16)strlen(s);

    s = s + len;

    while (len > 0 && *s == '\0' || *s == '\r' || *s == '\n') {
        len -= 1;
        s -= 1;
    }
    s[1] = '\0';
}

static int16 get_response(int16 cn, int16 t)
{
    int16 response, count, c, i = 0;
    char s[100], sr[4];
    clock_t to = clock() + (clock_t)t * CLK_TCK;

    while (TRUE) {
        count = CNbyte_count(cn);
        if (count < 0)
            return (count);

        if (to < clock())
            return (E_USERTIMEOUT);

        if (Bconstat(CON)) {
            Bconin(CON);
            return (E_USERTIMEOUT);
        }

        else while (count > 0) {
            count -= 1;
            c = CNget_char(cn);
            if (c < E_NODATA)
                return (c);
            s[i++] = (char)c;

			if (c == '\r')
				s[i-1] = '\0';

            else if (c == '\n') {
                s[i-1] = '\0';
                strncpy(sr, s, 3);
                sr[3] = '\0';
                response = atoi(sr);
                Cconws(s);
				Cconws("\r\n");
                return(response);
            }
        }
    }
}

static int16 send_msg(int16 cn, int16 t, int16 msgi)
{
    int16 rc, tstat;
    FILE *fp;
    char fname[100], wname[100];
    char line[500];     /* That's a bloody long line of text..  */
    char cline[50];
    char lts[20];

    strcpy(wname, mailpath);
    strcat(wname, ltoa(msglist[msgi], lts, 10));
    strcat(wname, ".wrk");

	ser_disable();
    if ((fp = fopen(wname, "rb")) == (FILE *)NULL) {
        Cconws("Can't open ");
        Cconws(fname);
        Cconws("\r\n");
		ser_enable();
        return (-1);
    }

    fgets(line, 500, fp);

    if (fgets(line, 500, fp) == (char *)NULL) {
        Cconws("Bad work file, line 2: ");
        Cconws(fname);
        Cconws("\r\n");
		fclose(fp);
		ser_enable();
        return (-1);
    }
	ser_enable();

    strip_crlf(line);

    strcpy(cline, "MAIL FROM:<");
    strcat(cline, line);
    strcat(cline, ">\r\n");

    TCP_send(cn, cline, (int16)strlen(cline));

    if (get_response(cn, t) != 250) {
        Cconws("Can't mail message\r\n");
        return(-1);
    }

	ser_disable();
    if (fgets(line, 500, fp) == (char *)NULL) {
        Cconws("Bad work file, line 3: ");
        Cconws(fname);
        Cconws("\r\n");
		fclose(fp);
		ser_enable();
        return (-1);
    }
	fclose(fp);		/* Finished with .wrk file	*/
	ser_enable();

    strip_crlf(line);

    strcpy(cline, "RCPT TO:<");
    strcat(cline, line);
    strcat(cline, ">\r\n");

    TCP_send(cn, cline, (int16)strlen(cline));

    rc = get_response(cn, t);
    if (rc != 250 && rc != 251) {
        Cconws("Can't mail message\r\n");
        return(-1);
    }

    strcpy(fname, mailpath);
    strcat(fname, ltoa(msglist[(long)msgi], lts, 10));
    strcat(fname, ".txt");

	ser_disable();
    if ((fp = fopen(fname, "r")) == (FILE *)NULL) {
        Cconws("Can't open ");
        Cconws(fname);
        Cconws("\r\n");
		ser_enable();
        return (-1);
    }
	ser_enable();

    TCP_send(cn, "DATA\r\n", 6);
    if (get_response(cn, t) != 354) {
        Cconws("Can't mail message\r\n");
		ser_disable();
        fclose(fp);
		ser_enable();
        return(-1);
    }

	ser_disable();
    while ((fgets(line, 500, fp) != (char *)NULL) && (line[0] != '\0')) {
        strip_crlf(line);
        strcat(line, "\r\n");

		ser_enable();

        if (line[0] == '.' && line[1] == '\r' && line[2] == '\n') {
            do {
                tstat = TCP_send(cn, "..\r\n", 4);
                if (Bconstat(CON) && ((Bconin(CON) & 0xff) == '\033')) {
					tstat = E_USERTIMEOUT;
					break;
				}
            } while (tstat == E_OBUFFULL);
        }
        else {
            do {
                tstat = TCP_send(cn, line, (int16)strlen(line));
                if (Bconstat(CON) && ((Bconin(CON) & 0xff) == '\033')) {
					tstat = E_USERTIMEOUT;
					break;
				}
            } while (tstat == E_OBUFFULL);

        }
        if (tstat != E_NORMAL)
            break;
		ser_disable();
    }
	ser_disable();
    fclose(fp);
	ser_enable();

    if (tstat != E_NORMAL) {
        Cconws("Error sending message\r\n");
        return(-1);
    }

    TCP_send(cn, ".\r\n", 3);
    if (get_response(cn, t) != 250) {
        Cconws("Error sending message\r\n");
        return(-1);
    }

    /* After a 250 response it should be cool to to delete the message  */

	ser_disable();
    Fdelete(fname);
    Fdelete(wname);
	ser_enable();

    return (0); /* Message sent OK ! */
}

static int16 get_first_msg(void)
{
    int16 len, fstat;
    long msg, lastseq;
    char fname[100];
    char aln[20], *ptr;
    FILE *fp;
    DTA *saved, dta;

    ptr = getvstr("SMTP_MAILPATH");
    if (ptr[1] == '\0' && (ptr[0] == '0' || ptr[0] == '1')) {
        Cconws("smtp(): SMTP_MAILPATH not set\r\n");
        return (-1);
    }
    strcpy(mailpath, ptr);

    len = (int16)strlen(mailpath);
    if (mailpath[len-1] != '\\') {
        mailpath[len++] = '\\';
        mailpath[len] = '\0';
    }

    strcpy(fname, mailpath);
    strcat(fname, "sequence.seq");

	ser_disable();

    if ((fp = fopen(fname, "rb")) == (FILE *)NULL) {
        Cconws("No sequence.seq file in spool\\mqueue\r\n");
        return (-1);
    }

    fgets(aln, 20, fp);
    fclose(fp);
    lastseq = atol(aln);

    if (lastseq == 0) {
        Cconws("Empty sequence.seq file\r\n");
        return (-1);
    }

    saved = Fgetdta();
    Fsetdta(&dta);

    strcpy(fname, mailpath);
    strcat(fname, "*.wrk");

    fstat = Fsfirst(fname, 0);

    while (fstat == 0) {
        msg = atol(dta.d_fname);

        if (msg <= lastseq) {
            msglist[(long)endmsg] = msg;
            endmsg++;
            if (endmsg == 100)  /* Our batch limit  */
                break;
        }

        fstat = Fsnext();
    }
    Fsetdta(saved);

	ser_enable();

    if (endmsg) {
        nextmsg += 1;
        return (nextmsg - 1);
    }
    else
        return (-1);	/* No mail to send	*/
}

static int16 get_next_msg(void)
{
    if (nextmsg < endmsg) {
        nextmsg += 1;
        return (nextmsg - 1);
    }
    else
        return (-1);
}

static int16 helo_smtp(int16 cn, int16 t)
{
    char helo_msg[100], *ptr;

    ptr = getvstr("SMTP_HOSTNAME");
    if (ptr[1] == '\0' && (ptr[0] == '0' || ptr[0] == '1')) {
        ptr = getvstr("HOSTNAME");
        if (ptr[1] == '\0' && (ptr[0] == '0' || ptr[0] == '1')) {
            ptr = "no_host_name";
        }
    }
    strcpy(helo_msg, "HELO ");
    strcat(helo_msg, ptr);
    strcat(helo_msg, "\r\n");

    TCP_send(cn, helo_msg, (int16)strlen(helo_msg));

    if (get_response(cn, t) != 250)
        return (-1);    /* Fail */

    return (0);
}

static int16 close_smtp(int16 cn, int16 t)
{
    int16 tstat;

    tstat = (int16)TCP_close(cn, t);
    Cconws("TCP_close() returns: ");
    Cconws(get_err_text(tstat));
    Cconws("\r\n");

    return (tstat);
}

static int16 quit_smtp(int16 cn, int16 t)
{
    TCP_send(cn, "QUIT\r\n", 6);

    if (get_response(cn, t) != 221)
        return (-1);    /* Fail */

    return (0);
}

static int16 connect_smtp(void)
{
    int16 cn, x;
    char *ptr;
    clock_t tout;
	uint32 rhost;

    ptr = getvstr("SMTPSERVER");
    if (ptr[1] == '\0' && (ptr[0] == '0' || ptr[0] == '1')) {
        ptr = getvstr("PROVIDER");
        if (ptr[1] == '\0' && (ptr[0] == '0' || ptr[0] == '1')) {
            Cconws("pop(): SMTPSERVER/PROVIDER not set\r\n");
            return (-1);
        }
    }

	x = resolve(ptr, (char **)NULL, &rhost, 1);
	if (x < 0) {
        Cconws(get_err_text(x));
        Cconws("\r\n");
		return (-1);
	}

    if ((cn = TCP_open(rhost, 25, 0, 2000)) < 0) {
        Cconws("TCP_open() returns ");
        Cconws(get_err_text(cn));
        Cconws("\r\n");
		return (-1);
    }
	tout = clock() + (clock_t)1000;	/* 5 second delay	*/
	while (tout > clock()) {
	    if ((CNbyte_count(cn) > 0) && (get_response(cn, 60) != 220)) {
    	    Cconws("Mail server not interested\r\n");
        	quit_smtp(cn, 10);
			close_smtp(cn, 10);
        	return(-1);
	    }
	}

    return (cn);
}

/*  Now for the real version...
 */
void smtp(void)
{
    int16 cn, next_msg;

    nextmsg = endmsg = 0;

    if ((next_msg = get_first_msg()) < 0) {
        Cconws("No messages to send\r\n");
        return;
    }
    if ((cn = connect_smtp()) < 0) {
        Cconws("Couldn't connect to mail host\r\n");
        return;
    }
    if (helo_smtp(cn, 60) < 0) {
        Cconws("Mail host not receiving\r\n");
		quit_smtp(cn, 60);
        close_smtp(cn, 10);

        return;
    }
    do {
        if (send_msg(cn,300, next_msg) < 0) {
            Cconws("Error sending message\r\n");
            msglist[next_msg] = 0L;
        }
    } while ((next_msg = get_next_msg()) > 0);

    Cconws("Mail transactions complete\r\n");

    quit_smtp(cn, 30);
    close_smtp(cn, 60);
}

/* Function to wait for a keypress	*/

static void pause(void)
{
	Cconws("Press any key to continue...\r\n"); /* Just like DOS :-)	*/

	while (Bconstat(CON))
		;
	Bconin(CON);
}

/* Put 'STIK' cookie value into drivers */

typedef struct {
    long cktag;
    long ckvalue;
} ck_entry;

static long init_drivers(void)
{
	long i = 0;
	ck_entry *jar = *((ck_entry **) 0x5a0);

	while (jar[i].cktag) {
		if (!strncmp((char *)&jar[i].cktag, CJTAG, 4)) {
			drivers = (DRV_LIST *)jar[i].ckvalue;
			return (0);
		}
		++i;
	}
	return (0);	/* Pointless return value...	*/
}
static int initialise(void)
{
	static long init_drivers(void);

	Supexec(init_drivers);

	/* See if we got a value	*/

	if (drivers == (DRV_LIST *)NULL) {
		Cconws("STiK is not loaded\r\n");
		return (FALSE);
	}

	/* Check Magic number	*/

	if (strcmp(MAGIC, drivers->magic)) {
		Cconws("Magic string doesn't match\r\n");
		return (FALSE);
	}

	/* OK, now we can get the address of the "TRANSPORT" layer
	 * driver.  If this seems unnecessarily complicated, it's
	 * because I tried to create today, what I would like to
	 * use later on.  In future, there will be multiple
	 * drivers accessible via this method.  With luck, your
	 * code will still work with future versions of my software.
	 */

	tpl = (TPL *)get_dftab(TRANSPORT_DRIVER);

	if (tpl == (TPL *)NULL) {
		Cconws("Transport layer *not* loaded\r\n");
		return (FALSE);
	}
	Cconws("Transport layer loaded, Author ");
	Cconws(tpl->author);
	Cconws(", version ");
	Cconws(tpl->version);
	Cconws("\r\n");

	return (TRUE);
}

void main(void)
{
	Cconws("\033E");

	if (initialise())
		smtp();

	pause();
}
