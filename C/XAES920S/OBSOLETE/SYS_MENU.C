/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <osbind.h>
#include <string.h>

#include "xa_types.h"
#include "xa_globl.h"
#include "xa_codes.h"

#include "sys_menu.h"
#include RSCHNAME
#include "taskman.h"
#include "xa_rsrc.h"
#include "scrlobjc.h"

void open_about(LOCK lock);
#if NOTYET
short shutdown_contrl[] = {XA_SHUTDOWN, 0, 0, 0, 0};
AESPB shutdown_pb;
#endif

/*
 *	Handle clicks on the system default menu
 */
global
void do_system_menu(LOCK lock, short clicked_title, short menu_item)
{
	switch(menu_item)
	{
	case XA_SYSTEM_ABOUT:	/* Open the "About XaAES..." dialog */
		open_about(lock);
	break;
	case SHUTDOWN:			/* Shutdown the system */
		shutdown = TRUE;
	break;
	case MN_TASK_MANAGER:	/* Open the "Task Manager" window */
		open_taskmanager(lock);
	break;
	case MN_SALERT:			/* Open system alerts log window */
		open_systemalerts(lock);
	break;
#if MN_ENV
	case MN_ENV:
	{
		SCROLL_ENTRY entry;
		OBJECT *form = ResourceTree(system_resources, SYS_ERROR);
		empty_scroll_list(form, SYSALERT_LIST, FLAG_ENV);
#if GENERATE_DIAGS
		{
			char *e = strings[0];
			while (*e)
			{
				add_scroll_entry(form, SYSALERT_LIST, nil, e, FLAG_ENV);
				e += strlen(e)+1;
			}
		}
#else
		{
			short i = 0;
			while (strings[i])
			{
				add_scroll_entry(form, SYSALERT_LIST, nil, strings[i], FLAG_ENV);
				i++;
			}
		}
#endif
		open_systemalerts(lock);
	}
	break;
#endif
#if FILESELECTOR
	case XA_SYSTEM_LAUNCH:	/* Launch a new app */
		open_launcher(lock);
	break;
#endif
	}
}
