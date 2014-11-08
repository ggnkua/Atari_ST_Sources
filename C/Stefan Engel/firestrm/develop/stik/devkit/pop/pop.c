/*  pop.c                (c) Steve Adam 1995         steve@netinfo.com.au
 *
 *      A POP3 mail client.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
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

char *iline;
int16 li = 0;

int16 get_tline(int16 cn, int16 ts)
{
    int16 count, c;
    clock_t to = clock() + (clock_t)ts * CLK_TCK;

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
            iline[li++] = (char)c;
            if (c == '\n') {
                iline[li] = '\0';
                li = 0;
                return (E_NORMAL);
            }
        }
    }
}

int16 pop_mail(int16 cn, FILE *fp)
{
    int16 msgcount, x, tstat;
	char lts[20];

    /* Connection is established, so POP it!    */
    /* First count the messages by listing them */

    msgcount = 0;
    TCP_send(cn, "LIST\r\n", 6);
    while (TRUE) {
        if ((tstat = get_tline(cn, 120)) < 0) {
            Cconws("get_tline() returns: ");
            Cconws(get_err_text(tstat));
            Cconws("\r\n");
            return (tstat);;
        }
        if (iline[0] == '.' && iline[1] == '\r')
            break;
        else if (isdigit(iline[0]))
            msgcount += 1;
        Cconws(iline);
    }

    for (x = 1; x <= msgcount; ++x) {
        strcpy(iline, "RETR ");
        strcat(iline, ltoa((long)x, lts, 10));
        strcat(iline, "\r\n");
		ser_disable();
        fprintf(fp, "From sent@string :%s", iline);
        TCP_send(cn, iline, (int16)strlen(iline));
		ser_enable();
        while (TRUE) {
            if ((tstat = get_tline(cn, 120)) < 0) {
                Cconws("get_tline() returns: ");
                Cconws(get_err_text(tstat));
                Cconws("\r\n");
                return (tstat);
            }
            if (iline[0] == '.') {
                if (iline[1] == '\r' && iline[2] == '\n')
                    break;
                else
                    strcpy(iline, &iline[1]);
            } 
			ser_disable();
            fwrite(iline, 1, strlen(iline), fp);
			ser_enable();
        }
        strcpy(iline, "DELE ");
        strcat(iline, ltoa((long)x, lts, 10));
        strcat(iline, "\r\n");
        TCP_send(cn, iline, (int16)strlen(iline));
        get_tline(cn, 60);

        Cconws("Message ");
        Cconws(ltoa((long)x, lts, 10));
        Cconws(" received.\r\n");
    }

    TCP_send(cn, "quit\r\n", 6);
    get_tline(cn, 60);

    return (E_NORMAL);
}

void pop(void)
{
    int16 tstat, cn;
    char username[50], password[50], *ptr;
    FILE *fp = (FILE *)NULL;
	uint32 rhost;

    /* Build username and password lines    */

    strcpy(username, "USER ");
    ptr = getvstr("POP_USERNAME");
    if (ptr[1] == '\0' && (ptr[0] == '0' || ptr[0] == '1')) {
        Cconws("pop(): POP_USERNAME not set\r\n");
        return ;
    }
    strcat(username, ptr);
    strcat(username, "\r\n");

    strcpy(password, "PASS ");
    ptr = getvstr("POP_PASSWORD");
    if (ptr[1] == '\0' && (ptr[0] == '0' || ptr[0] == '1')) {
        Cconws("pop(): POP_PASSWORD not set\r\n");
        return ;
    }
    strcat(password, ptr);
    strcat(password, "\r\n");

    iline = KRmalloc((long)1000);   /* That should be enough    */
    if (iline == (char *)NULL) {
        Cconws("Can't allocate line buffer for POP3\r\n");
        return;
    }

    ptr = getvstr("POP_MAILBOX");
    if (ptr[1] == '\0' && (ptr[0] == '0' || ptr[0] == '1')) {
        Cconws("pop(): POP_MAILBOX not set\r\n");
        KRfree(iline);
        return;
    }

	ser_disable();
    fp = fopen(ptr, "ab");
	ser_enable();
    if (fp == (FILE *)NULL) {
        Cconws("Couldn't open mail file\r\n");
        KRfree(iline);
        return;
    }

    ptr = getvstr("POPSERVER");
    if (ptr[1] == '\0' && (ptr[0] == '0' || ptr[0] == '1')) {
        ptr = getvstr("PROVIDER");
        if (ptr[1] == '\0' && (ptr[0] == '0' || ptr[0] == '1')) {
            Cconws("pop(): POPSERVER/PROVIDER not set\r\n");
            KRfree(iline);
			ser_disable();
            fclose(fp);
			ser_enable();
            return ;
        }
    }

	tstat = resolve(ptr, (char **)NULL, &rhost, 1);
	if (tstat < 0) {
		Cconws(get_err_text(tstat));
		Cconws("\r\n");
        KRfree(iline);
		ser_disable();
        fclose(fp);
		ser_enable();
        return;
	}

    cn = TCP_open(rhost, 110, 0, 1000);
    if (cn < 0) {
        Cconws("TCP_open() returns ");
		Cconws(get_err_text(cn));
		Cconws("\r\n");
        KRfree(iline);
		ser_disable();
        fclose(fp);
		ser_enable();
        return;
    }

    tstat = TCP_wait_state(cn, TESTABLISH, 60);
    if (tstat < 0) {
        Cconws("TCP_wait_state() returns: ");
        Cconws(get_err_text(tstat));
        Cconws("\r\n");
    }

    if (tstat == 0) {
        Cconws("Connected to POP3 server\r\n");

        do {
            if ((tstat = get_tline(cn, 60)) < 0) {
                Cconws("get_tline() returns: ");
                Cconws(get_err_text(tstat));
                Cconws("\r\n");
                break;
            }
        } while (iline[0] != '+');
    }

    if (tstat == 0) {
        Cconws(iline);

        TCP_send(cn, username, (int16)strlen(username));
        do {
            if ((tstat = get_tline(cn, 120)) < 0) {
                Cconws("get_tline() returns: ");
                Cconws(get_err_text(tstat));
                Cconws("\r\n");
                break;
            }
        } while (iline[0] != '+');
    }

    if (tstat == 0) {
        Cconws(iline);

        TCP_send(cn, password, (int16)strlen(password));
        do {
            if ((tstat = get_tline(cn, 120)) < 0) {
                Cconws("get_tline() returns: ");
                Cconws(get_err_text(tstat));
                Cconws("\r\n");
                break;
            }
        } while (iline[0] != '+');
    }

    if (tstat == 0) {
        Cconws(iline);

        tstat = pop_mail(cn, fp);
    }

    tstat = (int16)TCP_close(cn, 10);
    Cconws("TCP_close() returns: ");
    Cconws(get_err_text(tstat));
    Cconws("\r\n");

	ser_disable();
    fclose(fp);
	ser_enable();
    KRfree (iline);
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
		pop();

	pause();
}
