/*
 * This file contains subroutines which deal with other processes
 */
#include <obdefs.h>
#include <gemdefs.h>
#include <stdio.h>
#include <osbind.h>
#include <xbios.h>
#include "wind.h"
#include "uw.h"
#include "windefs.h"

extern	char * environ;

extern struct wi_str w[];
extern int fast;
extern int	scr_x, scr_y, scr_w, scr_h;	/* size of screen */
extern OBJECT	*menubar;

char cmdpath[40] = "e:\\bin\\*.*";
					/* Path for command execution */
char cmdname[40] = "msh.prg";		/* Name of command to run */
char cmdargs[40] = " ";			/* Arguments for command */

/*
 * Exec process from dialog.
 */
int do_exec()
{
  int status = 0;
  int confbutt;

  fsel_input(cmdpath, cmdname, &confbutt);
  if (confbutt) {
    extern char * rindex();
    char cmdstr[80];
    char cmdargv[40];
    char *argv[20];
    char * ind;
    OBJECT *obj_tmp;
    TEDINFO *ted_tmp;
    int cx, cy, cw, ch, tmp;

    strcpy(cmdstr, cmdpath);
      ind = rindex(cmdstr, '\\');
      if (ind) * ++ind = '\0';
    strcat(cmdstr, cmdname);
    form_dial(FMD_START, 0, 0, 0, 0, scr_x, scr_y, scr_w, scr_h);
    				/* save screen */

    rsrc_gaddr(R_TREE, PARAM, &obj_tmp);
    ted_tmp = (TEDINFO *) obj_tmp[PARAMSTR].ob_spec;
    strcpy(ted_tmp->te_ptext, cmdargs);
    form_center(obj_tmp, &cx, &cy, &cw, &ch);
    if (!fast) form_dial(FMD_GROW, 0, 0, 20, 10, cx, cy, cw, ch);
    objc_draw(obj_tmp, 0, 5, cx, cy, cw, ch);
    tmp = form_do(obj_tmp, PARAMSTR);
    if (!fast) form_dial(FMD_SHRINK, 0, 0, 20, 10, cx, cy, cw, ch);
    objc_change(obj_tmp, tmp, 0, cx, cy, cw, ch, NONE, 0);
    if (tmp != OKEXEC) {
      form_dial(FMD_FINISH, 0, 0, 0, 0, scr_x, scr_y, scr_w, scr_h);
      return(0);
    }
    strcpy(cmdargs, ted_tmp->te_ptext);
    strcpy(cmdargv, cmdargs);

    graf_mouse(M_OFF, NULL);	/* turn mouse off */
    menu_bar(menubar, 0); 	/* menu bar off */
    Cconws("\033E\033e");	/* clear screen, cursor on */
    ind = cmdargv;
    argv[0] = cmdname;
    tmp = 1;
    while (*ind != '\0') {
      while (*ind == ' ' && *ind != '\0'){
        *ind = '\0';
        ++ind;
      }
      argv[tmp++] = ind;
      while (*ind != ' ' && *ind != '\0')
        ++ind;
    }
    argv[tmp] = NULL;
    status = execve(cmdstr, argv, environ);
    sleep(1);
    Cconws("\033E\033f");	/* clear screen, cursor off */
    form_dial(FMD_FINISH, 0, 0, 0, 0, scr_x, scr_y, scr_w, scr_h);
    menu_bar(menubar, 1); 	/* menu bar on */
    graf_mouse(M_ON, NULL);	/* turn mouse on */
  }
  return(status);
}

/*
 * Set current path with dialog.
 */
int do_path()
{
  int status = 0;
  int confbutt;
  char curpath[80];
  char ignore[40] = "";
  int drv;

  curpath[0] = Dgetdrv() + 'a';
  curpath[1] = ':';
  Dgetpath(curpath+2, 0);
  strcat(curpath, "\\*.*");
  fsel_input(curpath, ignore, &confbutt);
  if (confbutt) {
    extern char * index(), *rindex();
    char * ind;
    ind = index(curpath, ':');
    if (ind) {
      drv = *(ind - 1);
      if (drv > '\\')
        drv -= 'a';
      else
	drv -= 'A';
      if (drv >= 0 && drv <= 15)
        Dsetdrv(drv);
    }
    else
      ind = curpath;
    *rindex(ind, '\\') = 0;
    status = Dsetpath(++ind);
  }
  return(status);
}
