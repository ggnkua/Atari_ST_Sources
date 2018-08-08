/*  ping.c                (c) Steve Adam 1995         steve@netinfo.com.au
 *
 *      This program sends ICMP echo requests to a particular foreign
 *  host and waits for the replies.  One ping is sent every second.
 *  An informational message is displayed when a reply comes in.
 *  The user is queried to enter a dotted decimal ip address.
 *  Entering a blank line terminates the routine.
 *  The ping ends when the user presses any key after which
 *  the user is queried to enter another address.
 */
#include "lattice.h"
#include <stdio.h>
#include <stdlib.h>
#include <tos.h>

#include "globdefs.h"
#include "globdecl.h"
#include "krmalloc.h"
#include "resolve.h"

static void do_ping(uint32 fha, int dcnt)
{
    GPKT *reply = (GPKT *)NULL;
    clock_t oldtime = 0L, newtime;
    char bigping[256], ol[20];
    int16 sequence = 0, x;

    for (x = 0; x < dcnt; ++x)
        bigping[x] = x;

    start_icmp_listen();

    while (TRUE) {
        if (Cconis()) { /* Press any key to end ping...     */
            Cconin();
            break;
        }

        newtime = Sclock();
        if (newtime >= oldtime) {
            oldtime = newtime + CLK_TCK;    /* Set for +1 second    */

            ping(fha, sequence++, 0, bigping, dcnt);
        }
        reply = get_icmp();
        if (reply == (GPKT *)NULL)
            continue;

        sprintf(ol, "Got ping %d\r\n", ((ICMP_HDR *)reply->mp)->seq);
		Cconws(ol);
        delete_packet(reply, NI_REPLYPING);
    }
    stop_icmp_listen();
}

void start_ping(void)
{
    char rs_str[64], *rdn;
    uint32  ip_address;
    int x;

    while(TRUE) {
        while(Cconis()) /* Discard any waiting input.  But where from?? */
            Cconin();

        Cconws("\nPING: Enter hostname or dotted decimal >");
        gets(rs_str);

        if (rs_str[0] == '\0')
            break;

        x = resolve(rs_str, &rdn, &ip_address, (int16)1);
        if (x < 0) {
            Cconws(get_err_text(x));
			Cconws("\r\n");
            continue;
        }
		Cconws("Pinging ");
		if (rdn != (char *)NULL) {
			Cconws(rdn);
			STiKfree(rdn);
		}
		else
			Cconws(rs_str);

		Cconws("\r\n");

        Cconws("\nHow much data to send (Max 200) [64] >");
        gets(rs_str);

        x = atoi(rs_str);
        if (x <= 0)
            x = 64;
        if (x > 200)
            x = 200;


        do_ping(ip_address, x);
    }

    Cconws("\nPing program completed, press any key to exit.\r\n");

    while (!Cconis())
        ;
    Cconin();
}
