#include <aes.h>
#include <vdi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <osbind.h>

#include "main.h"
#include "drivers.h"
#include "transprt.h"
#include "telvt102.h"

#define CON 2

int init_network(void);
int open_socket(char *, int);
int close_socket(int);
int read_from_socket(int, char *, int);
int send_to_socket(int, char *, int);
int tflag=0;
/*extern FILE  *fp;
*/
extern WINDOW win;
extern void do_string( int, char *);
extern	OBJECT *menu_ptr, *about_ptr, *host_ptr;
extern short debug;
static long init_drivers(void);

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
	return (0); /* Pointless return value...  */
}

int init_network(void)
{
	static long init_drivers(void);
	char out[80];
	int i,j;

	Supexec(init_drivers);

	/* See if we got a value	*/

	 if (drivers == (DRV_LIST *)NULL) {
		form_alert(1,"[1][STiK is not loaded! ][Quit]");
		exit(EXIT_FAILURE);
/*	 strcpy(out, "STiK is not loaded");
		wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)out, NULL,
				 NULL);*/
		return (FALSE);
	}

	/* Check Magic number	*/

	if (strcmp(MAGIC, drivers->magic)) {
		form_alert(1,"[1][Magic string does not match! ][Quit]");
		exit(EXIT_FAILURE);

/*	 strcpy(out, "Magic string doesn't match");
		wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out), NULL,
				 NULL);*/
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
		form_alert(1,"[1][Transport layer NOT loaded! ][Quit]");
		exit(EXIT_FAILURE);

/*	 strcpy(out, "Transport layer *not* loaded");
		wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out), NULL,
				 NULL);*/
		return (FALSE);
	}

/*	 do_string( 0, "Transport layer loaded, Author\n ");
	do_string( 0, tpl->author);
	do_string( 0, ", version ");
	do_string( 0, tpl->version);
	do_string( 0, "\015\012");
*/
/*		form_alert(1,"[1][Transport layer IS loaded ][OK]");
*/
	sprintf(out, "Transport layer loaded");
	wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out), NULL,
				 NULL);
for (i=0;i<=10000;i++)
	{for (j=0; j<=100;j++);}

	return (TRUE);
}

int close_socket(int cn)
	{
	int tstat,i,j;
	char out[80];

	tstat = (int)TCP_close(cn, 0);
	  /**/ sprintf(out, "%s", get_err_text(tstat));
	wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out), NULL,
 NULL);/**/
		sprintf(out, "Closing connection");
		wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out), NULL, NULL);
		menu_ienable(menu_ptr,OpenHostO,1);
		menu_ienable(menu_ptr,CloseC,0);
		menu_ienable(menu_ptr,OpenLocalL,1);
for (i=0;i<=10000;i++)
	{for (j=0; j<=100;j++);}
	return (tstat);
}

int open_socket(char *hostname, int por)
	{
	int cn, x;
	unsigned long rhost;
	char *realhostname;
	char out[80];

	tflag=1;
	if ((x = resolve(hostname, &realhostname/*(char **)NULL*/, 
			&rhost, 1)) < 0)
		{
		sprintf(out, "Open error: %s", get_err_text(x));
		wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out), NULL,
				 NULL);
		return (-1);
		}
		sprintf(out, "Opening connection to: %s", realhostname);
		wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out), NULL, NULL);

	if ((cn = TCP_open(rhost, por, 0, 2000)) < 0)
		{
		sprintf(out, "TCP_open() returns %s", get_err_text(cn));
		wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out), NULL,
				 NULL);
		return (-1);
		}
		sprintf(out, "Opened connection to: %s", realhostname);
		wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out), NULL, NULL);
		menu_ienable(menu_ptr,OpenHostO,0);
		menu_ienable(menu_ptr,OpenLocalL,0);
		menu_ienable(menu_ptr,CloseC,1);

	return (cn);
}

int send_to_socket(int cn, char *str, int len)

	{
	return (TCP_send(cn, str, len));
	}

int read_from_socket(int cn, char *str, int len)
	{
	char out[80];
	int count, c, i = 0,j,k,n;
	
	str[i]=0;
	n=count = CNbyte_count(cn);
	if (count == 0)	 return (count);

/*	if (tflag >= 0)*/
	if (count > 0)
		{
		if (count >= len ) count=len-1;

		if (j=(CNget_block(cn, str, count))<0)
			{
			sprintf(out,"[1][Error %d in CNget_block! ][Quit]",j);
			form_alert(1, out);
			exit(EXIT_FAILURE);
			}
/*					k = CNbyte_count(cn);
					sprintf(out,"count1 %d ret %d count2 %d len %d rem %d"	
							, n, j, count, len, k);
					wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out), 
							NULL, NULL);*/
	j=strlen(str);
	if (j < count)
		{
/*			sprintf(out,"[1][there are %d zeros in %d! ][OK]",(count-j),count);
			form_alert(1, out);
*/
		do
			{
			j=strlen(str);
			
			if (j < count)
				{
/*				if (debug)*/
/*					{
					k = CNbyte_count(cn);
					sprintf(out,"count1 %d ret %d count2 %d len %d rem %d"	
							, n, j, count, len, k);
					wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out), 
							NULL, NULL);
					}
*/
				for (k=j;k<(count-1);k++)	/* strip out nulls !*/
					str[k]=str[k+1];
				count--;
				str[k+1]=0;
				}
			} while (j < count);
		}
		i = count;
		
		}
/*
	else
		{
		tflag++;
	  while (count > 0)
			{
			count--;
			c = CNget_char(cn);

			if (c>0 && i<len)
				{
				str[i++] = (char)c;
				}
			}
			k = CNbyte_count(cn);
			sprintf(out,"Connection lost! ");
			wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out), 
					NULL, NULL);
		}
*/

		str[i]=0;
		return (i);
	}
