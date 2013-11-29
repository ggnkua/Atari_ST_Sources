/*
 * $Id$
 * Stefan Eissing, 10/21/1993
 * translated by Peter Seitz 08/06/1994
 *
 *
 * Definition of the Venus <-> Accessory protocol and its messages
 *
 * 12/07/1993: new messages AV_PATH_UPDATE, AV_WHAT_IZIT, AV_DRAG_ON_WINDOW
 */

#ifndef __vaproto__
#define __vaproto__

/* Message numbers for the XAcc protocol of Konrad Hinsen.
 * Venus' ACC_ID name is "VENUS.APP", Gemini's "GEMINI.APP".
 * Gemini supports the basic messages of the XAcc protocol.
 */
#define ACC_ID          0x400
#define ACC_OPEN        0x401
#define ACC_CLOSE       0x402
#define ACC_ACC         0x403

/* The following defines the message numbers for the communication of
 * Venus and other accessories.
 * All path- or filenames that occure in messages are supposed to be
 * absolute pathnames (including the drive-letter) and drive letters
 * have to be upper case.
 * All paths end ALWAYS with a backslash!
 *
 * Messages from Venus start with the prefix 'VA_' (Venus -> Accessory).
 * Messages to Venus start with 'AV_' (Accessory -> Venus).
 *
 * The message 'AV_PROTOKOLL' may be used by an accessory to ask which
 * messages are supported. (This is different for Venus and GEMINI!)
 * It would be nice, if other programs would support the VA Protocol,
 * too!
 * The AV_SENDKEY [and ACC_KEY] messages are the only way to send
 * key-events to other applications - and these are easy to implement!
 * The VA_START message should be supported by all accessories, as
 * this is a simple method for applications to start accessories.
 *
 *
 * If a single-tasking TOS/AES is running (ap_count == 1) the accessory
 * should send a AV_PROTOKOLL message to application 0 when it is
 * started and each time it receives a AC_CLOSE message.
 *
 * If a multi-tasking AES is present (ap_count != 1) the main application
 * is no longer guaranteed to have to id 0 and the AC_CLOSE messages are
 * send quite rarely. On the other hand it is possible for applications,
 * too, to communicate with GEMINI.
 * Therefore each application/accessory should try to find GEMINI using
 * the appl_find("GEMINI  ") system call. If this fails, it should look
 * for an application called "AVSERVER". Last it should check, if there
 * is an environment variable called "AVSERVER" and if this exists, it
 * should treat its contents as the name of the avserver-application.
 * Especially the last method gives an easy method to configure the
 * avserver.
 */

/* AV_PROTOKOLL: This message should be used to ask an application
 * (including GEMINI/VENUS) which messages are supported. (see above)
 */
#define AV_PROTOKOLL            0x4700

/*
 * word 6+7: a pointer to the name of the accessory/application for
 *           the use with appl_find (aligned to 8 characters and terminated
 *           by a '\0' byte).
 * The bits of words 3, 4 and 5 have the following meaning:
 * word 3:
 *   bit 0:             (VA_SETSTATUS)
 *   bit 1:             (VA_START)
 * All other bits are reserved for future use and should be set to
 * zero (all bits of words 4 and 5 too).
 */

/* VA_PROTOSTATUS: Tell the sender of AV_PROTOKOLL, that the application
 * knows s.th. about the VA-Protocol. The words 3-7 of the message buffer
 * contain informations which messages are understood. If a bit is set,
 * the message(group) is supported).
 */
#define VA_PROTOSTATUS          0x4701

/*
 * word 6+7: a pointer to the program's name (see AV_PROTOKOLL)
 * The bits of words 3, 4 and 5 have the following meaning:
 * word 3:
 *   bit 0:             (AV_SENDKEY)
 *   bit 1:             (AV_ASKFILEFONT)
 *   bit 2:             (AV_ASKCONFONT, AV_OPENCONSOLE)
 *   bit 3:             (AV_ASKOBJECT)
 *   bit 4:             (AV_OPENWIND)
 *   bit 5:             (AV_STARTPROG)
 *   bit 6:             (AV_ACCWINDOPEN, AV_ACCWINDCLOSED)
 *   bit 7:             (AV_STATUS, AV_GETSTATUS)
 *   bit 8:             (AV_COPY_DRAGGED)
 *   bit 9:             (AV_PATH_UPDATE, AV_WHAT_IZIT, AV_DRAG_ON_WINDOW)
 *   bit 10:            (AV_EXIT)
 *
 * All other bits are reserved for future use and should be set to
 * zero (all bits of words 4 and 5 too).
 *
 * AV_SENDKEY is easy to implement in many programs.
 * Receiving AV_OPENWIND an application could start its 'normal'
 * routine for opening a document and use the given path (e.g. in the
 * fileselector). This is together with tools like TreeView a quite
 * simple method to open files in different folders.
 */

/* AV_GETSTATUS: An accessory asks Venus for the current state, that
 * it has given to Venus via AV_STATUS.
 */
#define AV_GETSTATUS            0x4703

/* AV_STATUS: An accessory can give its current state to Venus, which
 * will store it in the INF-file and can be restored using AV_GETSTATUS.
 * Before sending AV_STAUS it MUST send AV_PROTOKOLL to Venus!
 * words 3 + 4: A pointer to a string, which must not contain any control
 *              characters and must not be longer than 256 characters.
 *              The pointer may be NULL.
 */
#define AV_STATUS               0x4704

/* VA_SETSTATUS: Venus tells an accessory about its stored state as a
 *               reply to AV_GETSTATUS. The state can be set by the
 *               accessory.
 * words 3 + 4: a pointer to the string that was stored (by AV_STATUS).
 *              The pointer may be NULL, if no state was stored.
 */
#define VA_SETSTATUS            0x4705

/* AV_SENDKEY: An accessory sends Venus/Gemini a keyboard event, which
 * it could not use itself. This could be used for Ctrl-W to cycle the
 * windows.
 * word 3: keyboard-state      (ev_mmokstate)
 * word 4: scancode of the key (ev_mkreturn)
 */
#define AV_SENDKEY              0x4710

/* VA_START: An accessory is activated. (Similar to AC_OPEN.)
 * words 3 + 4: A pointer to the command line, which may be NULL.
 *              The command line contains paths or filenames.
 */
#define VA_START                0x4711

/* AV_ASKFILEFONT: Ask about the selected font for filenames.
 */
#define AV_ASKFILEFONT          0x4712

/* VA_FILEFONT: Gives the currently selected font for files.
 * word 3: file font id
 * word 4: file font size (in points)
 */
#define VA_FILEFONT             0x4713

/* AV_ASKCONFONT: (Gemini only) Ask about the selected font for
 * the console window.
 */
#define AV_ASKCONFONT           0x4714

/* VA_CONFONT: Gives the currently selected font for the console window.
 * word 3: console font id
 * word 4: console font size (in points)
 */
#define VA_CONFONT              0x4715

/* AV_ASKOBJECT: Ask about the currently selected object(s).
 * The name(s) of the selected object(s) is (are) returned.
 * If no object is selected, the string is empty.
 * If several objects are selected, their names are separated by
 * spaces.
 */
#define AV_ASKOBJECT            0x4716

/* VA_OBJECT: Return the currently selected object(s).
 * words 3 + 4: see VA_START
 */
#define VA_OBJECT               0x4717

/* AV_OPENCONSOLE: (Gemini only) Venus should open the console window.
 * If it is already open, it will be topped. This action can be used, if
 * a accessory is about to start a TOS-program using the system() function.
 * (NOTE: No GEM-programs should be started by an accessory via the
 * system() function! see AV_STARTPROG)
 * The message should only be used, if the user wants to, otherwise he
 * will be confused.
 */
#define AV_OPENCONSOLE          0x4718

/* VA_CONSOLEOPEN: Returns the state of the console window:
 * word 3: == 0: not topped/opened, != 0: is topped
 */
#define VA_CONSOLEOPEN          0x4719

/* AV_OPENWIND: Venus should open a file window. This should only happen
 * if there's a obvious reason for the user.
 * words 3 + 4: pointer to the path for the window
 * words 5 + 6: pointer to a string containing the wildcards for the
 *              files which should be displayed
 */
#define AV_OPENWIND             0x4720

/* VA_WINDOPEN: Returns the state of the file window (see VA_CONSOLEOPEN).
 */
#define VA_WINDOPEN             0x4721


/* word 7 in AV_STARTPROG and words 4 and 7 in VA_PROGSTART are used
 * since 03/29/1992.
 */

/* AV_STARTPROG: Venus should start a program. ####
 * words 3 + 4: pointer to the program's name (with complete path!)
 * words 5 + 6: pointer to the command line for the program (may be NULL)
 * word 7:      any 16-bit-word, which will be returned by VA_PROSTART.
 */
#define AV_STARTPROG            0x4722

/* VA_PROGSTART: Tells, if Venus could start the program.
 * word 3: == 0: not started, != 0: started
 * Normaly the accessory will receive this reply at once if an error
 * occures. If the program could be started, the accessory receives this
 * message after the program is started, as the Pexec routine can't know
 * that there's a message which has to be delivered.
 * If the program is a GEM-program, the success could be seen, if a
 * AC_CLOSE message is received (but not necessarily).
 *
 * word 4: return-code of the started program (if possible)
 * word 7: the 16-bit-word given in AV_STARTPROG
 */
#define VA_PROGSTART            0x4723


/* The following three messages define a possibility to implement a
   Drag & Drop protocol which works without MiNT and pipes and with
   any TOS version!
 */

/* AV_ACCWINDOPEN: This message can be used by an accessory, to inform
 * Venus about own (opened) window.
 * word 3: the AES handle of the window
 */
#define AV_ACCWINDOPEN          0x4724

/* VA_DRAGACCWIND: Venus tell the accessory that objects have been
 * dragged to a window Venus knows about (-> AV_ACCWINDOPEN).
 * word 3:      AES handle of the window
 * word 4:      x position of the mouse
 * word 5:      y position of the mouse
 * words 6 + 7: pointer to a string containing the names of the objects
 */
#define VA_DRAGACCWIND          0x4725

/* AV_ACCWINDCLOSED: The accessory informs Venus that a window has been
 * closed. This is only necessary, if it closed the window itself. If
 * the window is closed due to an AC_CLOSE message, Venus knows the all
 * windows are closed.
 * word 3: AES handle of the window
 */
#define AV_ACCWINDCLOSED        0x4726


/* New messages since 04/11/1991!!!
 */

/* AV_COPY_DRAGGED: An accessory tells Venus, that the objects that have
 * been dragged to its window should be copied.
 * This may be the case, e.g. if objects are dragged to the TreeView-
 * window. This message may only be used as reply to a VA_DRAGACCWIND.
 * word 3:      The keyboard state (alternate, control, shift) which have
 *              been given in the VA_DRAGACCWIND message
 * words 4 + 5: pointer to a string which must contain the name of the
 *              destination object. This HAS to be a *pathname*!
 */
#define AV_COPY_DRAGGED         0x4728

/* VA_COPY_COMPLETE: Reply to AV_COPY.
 * word 3: state of the copying process (!= 0 means that s.th. has really
 *         be copied of moved. This may be useful, if a window has to be
 *         redrawed.)
 */
#define VA_COPY_COMPLETE        0x4729


/* AV_PATH_UPDATE: A program/accessory tells Gemini that the contents of a
 * folder has been changed. Gemini redraws this folder if it is shown in a
 * window, even if subdirectories are shown.
 * The update of "C:\" for example results in redisplaying everything on
 * drive C:.
 * words 3 + 4: pointer to the complete (!) pathname
 */
#define AV_PATH_UPDATE          0x4730


/* AV_WHAT_IZIT: A program/accessory asks Gemini about objects at position
 * x/y on the screen. The  coordinates are the normal VDI coordinates
 * (the origin is the left upper corner of the screen).
 * The reply is VA_THAT_IZIT.
 * word 3: x position
 * word 4: y position
 */
#define AV_WHAT_IZIT            0x4732

/* VA_THAT_IZIT:
 * word 3:      ID of the application handling the object
 * word 4:      type of the object (see below)
 * words 5 + 6: pointer to the name of the object(s) or NULL if there
 *              was nothing.
 *
 * 'type' may be one of the following (all other values are reserved):
 */
#define VA_OB_UNKNOWN   0
#define VA_OB_TRASHCAN  1
#define VA_OB_SHREDDER  2
#define VA_OB_CLIPBOARD 3
#define VA_OB_FILE      4
#define VA_OB_FOLDER    5
#define VA_OB_DRIVE     6
#define VA_OB_WINDOW    7

#define VA_THAT_IZIT            0x4733

/* AV_DRAG_ON_WINDOW: A program/accessory tells Gemini that objects have
 * been dragged to one of its windows (as result of a AV_WHAT_IZIT).
 * The names are names of files, folders or drives, separated by a
 * single space. Names of folders or drives must end with a backslash.
 *
 * word 3:      AES handle of the window
 * word 4:      x position of the mouse
 * word 5:      y position of the mouse
 * words 6 + 7: pointer to a string containing the names of the objects.
 *
 * (not implemented yet)
 *
 */
#define AV_DRAG_ON_WINDOW       0x4734

/* AV_EXIT: A program/accessory tells Gemini that it doesn't join the
 * protocol any longer (normally because it will terminate).
 * word 3: AES id of the application/accessory
 */
#define AV_EXIT                 0x4736

/* AV_SENDCLICK will be sent, if the bubble was closed by clicking (as 
   opposed bursting bubbles by releasing the mouse button!). AV_SENDCLICK 
   is the counterpart to AV_SENDKEY.
 */
/*
msg[0] = AV_SENDCLICK
msg[1] = ap_id;
msg[2] = 0;
msg[3] = ev_mmox;
msg[4] = ev_mmoy;
msg[5] = ev_mmobutton;
msg[6] = ev_mmokstate;
msg[7] = ev_mbreturn;
*/

#define AV_SENDCLICK       0x4709


#endif

