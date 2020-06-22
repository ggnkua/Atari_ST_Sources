/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _XA_GLOBL_H_
#define _XA_GLOBL_H_

#include <VDI.H>
#include "KERNAL.H"
#include "K_DEFS.H"
#include "XA_TYPES.H"
#include "EVENT_Q.H"

/*
	GLOBAL VARIABLES AND DATA STRUCTURES
*/

#define MAX_PID 500						/* maximum number of processes we can handle */

extern short AESpid;					/* XaAES's MiNT process id. */

extern short P_handle,V_handle;			/* Workstation handles used by the AES */
extern XA_SCREEN display;				/* The display descriptor */

extern void *super_stack;				/* Supervisor mode stack */

extern int AES_in_pipe;					/* The AES instruction pipe handle */
extern unsigned long client_handle_mask;

extern int MOUSE_in_pipe;				/* The MOUSE pipe handle */

extern long KBD_device;					/* The MiNT keyboard device's file handle */

extern short debug_file;				/* File handle to dump debug stuff to */

extern unsigned long kernal_a4;
extern unsigned long kernal_a6;

extern XA_WINDOW *window_list;			/* The global windows list */
extern XA_WINDOW *root_window;			/* The desktop window */

extern short update_lock;				/* wind_update() locks */
extern short mouse_lock;
extern short update_cnt;
extern short mouse_cnt;

extern AESPB new_client_pb;
extern K_CMD_PACKET new_client_packet;
extern short client_exit_contrl[];

extern char XaAES_home[200];			/* XaAES's home location */
extern short XaAES_home_drv;

extern char scrap_path[128];			/* Clipboard directory path */

extern void *system_resources;			/* Pointer to the XaAES resources */
extern const char dummy_cmd_tail[], dummy_cmd_name[];

extern far AESroutine Ktable[300];		/* The main AES kernal command jump table */
extern far short Kcall_direct[300];		/* array of flags to indicate that routines should be direct called */
extern far XA_CLIENT clients[MAX_PID+1];	/* The main data structure is the clients database */

extern OBJECT *desktop;					/* The desktop/root window object tree */

extern short iconify_x,iconify_y,iconify_w,iconify_h;	/* Positioning information for iconifying windows */

extern short shutdown;

extern const unsigned char character_type[];

/* Martin's stuff to help get rid of the clients array */
#define Pid2Client(pid)	((pid<MAX_PID)?&clients[pid]:NULL)	/* AES pid -> client pointer */
#define Client2Pid(client_p)	((short)((XA_CLIENT*)client_p-&clients[0]))
										/* client pointer -> AES pid */

/* The following two are useful for running through the entire client list: */
#define FirstClient()	(&clients[0])
#define NextClient(cp)	\
	(((XA_CLIENT*)(cp)<&clients[MAX_PID-1]) ? (XA_CLIENT*)(cp)+1 : NULL)

#endif
