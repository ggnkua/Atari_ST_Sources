/*
 * GEMScript protocol for WinDom applications
 * Copyright (c) 2000-2001 Arnaud BERCEGEAY
 *
 * File: gslib.h
 *
 * Contact :
 * Arnaud BERCEGEAY <bercegeay@atari.org>
 * http://perso.wanadoo.fr/arnaud.bercegeay/
 *
 * More about WinDom:
 * http://windom.free.fr
 *
 */

/*
 * Note:
 * The documentation is inside
 * there is no man page or hyp documentation elsewhere
 * but... feel free to write an HYP documentation, and send
 * it to me so that i could include it in the package.
 */

/*
 * GSlib identification string 
 */
extern char __Ident_gslib[];

/*
 * reserved GSlib mesage number.
 * GSlib may send some GSLIB_EVENT message to your application.
 *
 * Message "GSlib pipe closed by the other application"
 * evnt[3] = 0
 * evnt[4,5] = GSlib handle (pointer) of the closed pipe.
 *
 *
 */
#define GSLIB_EVENT  0x134F

/*
 *  Initialisation
 *
 * Your application MUST call that function before calling
 * any other GSlib function.
 * GSInit will attach some internal function to standard
 * GEMSCRIPT messages number, and more...
 *
 * func is a pointer to a function which will be called when
 * GSlib will received a GS_COMMAND message.
 * The parameters are just like the main() parameters.
 * void (*func)(void* gsc, int argc, int *argv[]);
 * 
 * mode: 0 | 1
 * with "debug" version of GSlib, if mode is set to 1L, the
 * debug feature will be initialised (file created).
 * In any other cases (not the debug version of GSlib, or
 * mode set to 0L), the debug feature won't be turned on.
 * 
 */
extern int GSInit( void *func, long mode );

/*
 *  De-init
 *
 * Your application MUST call that function before exiting.
 * GSExit will delete Windom Event attached in GSInit(), and
 * close all debug files
 */
extern int GSExit( void );

/*
 *  Open a GS dialog
 *
 * Try to open a GemScript communication between your application
 * and another application.
 *
 * ap_id: Application ID of the other application
 *
 * return a "GSlib handle" (pointer) when succed, or NULL
 */
extern void* GSOpen (int ap_id);

/*
 *  Close a GS dialog
 *
 * Closed a GemScript communication opened using GSOpen()
 *
 * gsc: a "GSlib handle" returned by GSOpen()
 */
extern int GSClose (void* gsc );

/*
 *  Share a GS dialog
 *
 * When the other application opened a GS dialog, you should use
 * that pipe to send commands to the other application (you don't
 * have to open another GS pipe).
 * GSShare tell GSlib that you'll use that GSlib handle to send
 * some commands.
 *
 * gsc: a "GSlib handle"
 */
extern int GSShare(void* gsc);

/*
 *  UnShare a GS dialog
 *
 * say GSlib your application will no more use that GSlib handle
 * to send commands
 *
 * gsc: a "GSlib handle" previously shared using GSShare()
 */
extern int GSUnShare(void* gsc);

/*
 *  Send Commands
 *
 * Send commands to another application using a GS pipe.
 *
 * gsc: a "GSlib handle" returned by GSOpen(), or shared using GSShare()
 * command: string which contain the command
 * nb_args: number of parameters (following)
 * [param1: string which contain the first parameter] (optional)
 * [etc...]
 */
extern int GSSendCommand (void* gsc, char * command, int nb_arg, ...);

/*
 *  Get Result 
 *
 * After sending a Command using GSSendCommand, you can get the
 * string returned by the other application in reply to your command.
 *
 * gsc: a "GSlib handle" where you send a command.
 *
 * return a pointer to the string, or NULL (no string returned)
 */
extern char * GSGetCommandResult (void* gsc);

/*
 *  Set Result
 *
 * When your application received a GS command, you can specify
 * the string to return in reply to that command.
 */
extern int GSSetCommandResult (void* gsc, char *ptr_result);
