/**************************************************************************
 * BROWSE - The main module for the BROWSE GemFast demo program.
 *
 *  I'm not proud of this code.  It works.  Barely.  It was to be the
 *  beginning of a text editor subsystem you could embed into any existing
 *  application. It was also to be the vehicle I used to develop my
 *  "next generation" idiom for GEM programming, a system which allows
 *  development of black-box subsystems which can be included into an
 *  application without need for any customizing.  GEM event handling
 *  makes this a pretty tall order.  Maybe impossible.  The "next idiom"
 *  project died, both of its own weight, and due to a lack of response
 *  to a paper I published outlining the issues and requesting suggestions
 *  from developers on how to proceed in a way that would work for
 *  everyone.  Be that as it may, this code is still an okay example of
 *  how to handle events with overlapping windows, how to render text
 *  in a window, and how to put a bit of object-orientedness into your
 *  design using plain-old-C code.  It's not a great example of any of
 *  these things, but it's better than nothing, which is what has been
 *  available to date in terms of scrolling window demos.
 *
 *  It's also not commented as much as I think a piece of demo code
 *  should be.  But, I don't have time to do it right, and sparsely-
 *  commented code is surely better than no code at all.  Isn't it?
 *
 *  Ian Lepore
 *  12/07/92
 *************************************************************************/

#include <gemfast.h>
#include <osbind.h>
#include "browse.h"
#include "browser.h"

#ifndef TRUE
  #define TRUE  1
  #define FALSE 0
#endif

#ifndef NULL
  #define NULL 0L
#endif

/**************************************************************************
 * Variables for dialogs & resource files.
 *************************************************************************/

#define   RSRCFILE  "browse.rsc"

static char no_rsrc_alert[] = "[3][ | | Can't open RSC file! | | ][ Fatal ]";

OBJECT *menutree;

/**************************************************************************
 * prg_exit - shut down GEM and exit.
 *************************************************************************/

static void prg_exit()
{
    menu_bar(menutree, FALSE);
    rsrc_free();
    appl_exit();
    _exit(0);
}

/**************************************************************************
 * prg_init - fire up AES/VDI, open window, load rsrc, etc.
 *************************************************************************/

static void prg_init()
{
    int dmy;

    appl_init();

    if (!rsrc_load(RSRCFILE)) {
        form_alert(1, no_rsrc_alert);
        prg_exit();
    }

    rsrc_gaddr(R_TREE, MENUTREE, &menutree);

    menu_bar(menutree, TRUE);
    graf_mouse(ARROW, NULL);
}

/**************************************************************************
 * open a browser to display a file, complain and die if it doesn't open.
 *
 *  br_errno will hold a standard TOS error code, and frm_error() uses
 *  strerror() to translate that code to a message.  this works great
 *  under HSC, which has the right error messages for TOS error codes.
 *  with other compilers, your mileage may vary.
 *************************************************************************/

static void open_browser()
{
    char    thefile[128];
    Browser *thebrowser;

    if (!fsl_dialog(FSL_NORMAL, thefile, NULL, NULL, "Browse File:"))
        return;

    if (NULL == (thebrowser = br_file(thefile))) {
        frm_qerror(br_errno, "Can't load %s\n\n", thefile);
    }
}

/**************************************************************************
 * process menu items.
 *************************************************************************/

static void do_menu(item)
    short   item;
{
    short    top_window;
    short    dmy;
    Browser  *thebrowser;

    switch (item) {

      case DESKINFO:

        frm_qtext("\x7F" "BROWSE\n"
                  "\x7F" "A GemFast example program\n"
                  "\x7F" "which demonstrates handling\n"
                  "\x7F" "scrolling text in a window.\n"
                         " \n"
                  "\x7F" "Source and program are\n"
                  "\x7F" "Public Domain\n"
                  "\x7F" "by Ian Lepore\n");
        break;

      case MENFOPEN:

        open_browser();
        break;

      case MENFCLOS:

        top_window = wnd_top();
        if (NULL == (thebrowser = br_handle(top_window))) {
            frm_qtext("The top window is not\na browser window!");
        } else {
            br_delete(thebrowser);
        }
        break;

      case MENFQUIT:

        br_shutdown();
        prg_exit();
        break;

    }
}

/**************************************************************************
 * main - Initialize, invoke event_multi handler, exit if it returns.
 *************************************************************************/

void main()
{
    XMULTI  xm;
    short   event;
    short   *msgbuff;

    prg_init();

    xm.mflags = MU_MESAG;

    do_menu(MENFOPEN);

    for (;;) {

        evnx_multi(&xm);    // get event
        br_event(&xm);      // dispatch it to browser subsystem

        event = xm.mwhich;
        msgbuff = (short *)xm.msgbuf;

        if (event & MU_MESAG) {
            switch (msgbuff[0]) {

            case MN_SELECTED:

                do_menu(msgbuff[4]);
                menu_tnormal(menutree, msgbuff[3], TRUE);
                break;

            } /* END switch (msgbuff[0]) */
        } /* END if (message event) */
    } /* END for(;;) */
}
