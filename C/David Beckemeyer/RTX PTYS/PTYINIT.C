#include <stdio.h>
#include <osbind.h>
#include <rtxbind.h>


main()
{
	start_rtx();

	Pexec(0, "ptydvr.prg", "", 0L);

	Pexec(0, "ptywin.prg", "", 0L);

	exit(0);
}

/* This is how MWC gives you the basepage; other compilers
 * will be different
 */
extern _start();


start_rtx()
{
	struct config config;

	/* first check to see if RTX is already running */
	if (Ftype(0) >= 0)
		return;

	/* not running, set up the configuratioin table */
	config.basepage = (char *)_start - 0x100;
	config.max_proc = 10;
	config.max_msgs = 20;
	config.max_queues = 10;
	config.create_call = 0L;
	config.delete_call = 0L;
	config.switch_call = 0L;

	/* fire it up */
	rtx_install(&config);
}
