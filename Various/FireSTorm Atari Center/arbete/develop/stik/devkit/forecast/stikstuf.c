#include <aes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <osbind.h>

#include "main.h"
#include "drivers.h"
#include "transprt.h"

#define CON 2

int init_network(void);
int open_socket(char *, int);
int close_socket(int);
int read_from_socket(int, char *, int);
int send_to_socket(int, char *, int);

static long init_drivers(void);

extern WINDOW win;
extern void draw_win(void);

char out[80];


/* These definitions are necessary.  transprt.h has external
 * declarations for them.
 */
DRV_LIST *drivers = (DRV_LIST *)NULL;
TPL *tpl = (TPL *)NULL;

/* Put 'STIK' cookie value into drivers */

typedef struct {
    long cktag;
    long ckvalue;
} ck_entry;

long init_drivers(void)
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

int init_network(void)
{
	static long init_drivers(void);
	 

	Supexec(init_drivers);

	/* See if we got a value	*/

	 if (drivers == (DRV_LIST *)NULL) {
		strcpy(out, "STiK is not loaded");
		wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)out, NULL, NULL);
		return (FALSE);
	}

	/* Check Magic number	*/

	if (strcmp(MAGIC, drivers->magic)) {
		strcpy(out, "Magic string doesn't match");
		wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out), NULL, NULL);
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
		strcpy(out, "Transport layer *not* loaded");
		wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out), NULL, NULL);
		return (FALSE);
	}

	sprintf(out, "TPL %s, v%s", tpl->author, tpl->version);
	wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out), NULL, NULL);

	return (TRUE);
}

int close_socket(int cn)
	{
	int tstat;
	 

	tstat = (int)TCP_close(cn, 0);
	sprintf(out, "%s", get_err_text(tstat));
	wind_info(win.handle, out);
	draw_win();

	return (tstat);
}

int open_socket(char *hostname, int port)
	{
	int cn, x;
	unsigned long rhost;
	 

	if ((x = resolve(hostname, (char **)NULL, &rhost, 1)) < 0) 
		{
		sprintf(out, "Open error: %s", get_err_text(x));
		wind_info(win.handle, out);
		draw_win();
		return (-1);
		}

	if ((cn = TCP_open(rhost, port, 0, 2000)) < 0)
		{
		sprintf(out, "TCP_open() returns %s", get_err_text(cn));
		wind_info(win.handle, out);
		draw_win();
		return (-1);
		}

	return (cn);
}

int send_to_socket(int cn, char *str, int len)
	{
	return (TCP_send(cn, str, len));
	}

int read_from_socket(int cn, char *str, int len)
	{
	int count, c, i = 0;
	clock_t to = clock() + (clock_t)10 * CLK_TCK;

	while (TRUE)
		{
		count = CNbyte_count(cn);
		if (count < 0)		return (count);
		if (to < clock())	return (E_USERTIMEOUT);

		if (Bconstat(CON))
			{
			Bconin(CON);
			return (E_USERTIMEOUT);
			}
		else 
	        	{
	        	while (count > 0)
				{
				count--;
				to = clock() + (clock_t)CLK_TCK;
				c = CNget_char(cn);
				if (c < E_NODATA)	return (c);
				else if (c>=0 && i<len)	str[i++] = (char)c;
				}
			}
		}
	}
