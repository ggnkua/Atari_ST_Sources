#include "dialog.h"
#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#include "dialog.rsh"

/*
        This program needs to be run in the same directory as the
        "dialog.rsc" file is in.
*/
main()
{
        OBJECT *dialog;
        char name[11];

        appl_init();
/*
        if (!rsrc_load("dialog.rsc")) {
                form_alert(1, "[0][Cannot find dialog.rsc file|Terminating
...][OK]");
                exit(1);
        }
*/

        fix_tree(NUM_TREE);

        rsrc_gaddr(0, DIALOG1, &dialog);
        ((TEDINFO *)dialog[NAME].ob_spec)->te_ptext = name;
        ((TEDINFO *)dialog[NAME].ob_spec)->te_txtlen = 10;
        do_dialog(dialog, 1);

        rsrc_gaddr(0, DIALOG2, &dialog);
        dialog[STRING].ob_spec = name;
        do_dialog(dialog, 0);

        unfix_tree();
}

do_dialog(dialog, flag)
OBJECT *dialog;
int     flag;   /* set to 1 if form_do is needed */
{
        int cx, cy, cw, ch;

        form_center(dialog, &cx, &cy, &cw, &ch);
        form_dial(FMD_START, 0, 0, 0, 0, cx, cy, cw, ch);
        form_dial(FMD_GROW, 0, 0, 0, 0, cx, cy, cw, ch);
        objc_draw(dialog, 0, 10, cx, cy, cw, ch);
        if (flag) form_do(dialog, 0);
        else wait(4L);
        form_dial(FMD_SHRINK, 0, 0, 0, 0, cx, cy, cw, ch);
        form_dial(FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch);
}

wait(waittime)
long     waittime;  /* seconds to wait */
{
  long init_time;

  init_time = Gettime;
  while ((Gettime - init_time) < waittime/2)
    {
    ;
    }
}
