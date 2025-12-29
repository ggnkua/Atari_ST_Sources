/*
 * Gem shell for ghostscript.
 */

#include <stdio.h>
#include <string.h>
#include <osbind.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
#include <dirent.h>
#include "objects.h"
#include "keys.h"
#include "ps.h"

#define MAXLEN		80
#define MAXSTR		30
#define CONFIGFILE	"gemgs.rc"
#define PAGEFILE	"pspage.ps"

char command[2*MAXLEN]="";	/* command line for programs to be executed */
char device[MAXLEN]="";		/* name of current device */
char res[MAXLEN]="";		/* string containing current resolution */
char geometry[MAXLEN]="";	/* geometry string */
char tempgeom[MAXLEN];		/* temporary geometry string */
char clist[MAXLEN]="";		/* clist string */
char tempclist[MAXLEN]="";	/* temporary clist string */

char pages[MAXLEN];		/* string holding page selections */
char configfile[MAXLEN];	/* name of configuration file */

char devmenu[9][MAXLEN];	/* entries in the device menu */
char resmenu[9][MAXLEN];	/* entries in the resolution menu */
char toolmenu[10][MAXLEN];	/* entries in the tool menu */

char toolexec[MAXLEN];		/* name of tool to be executed */
char temptool[2*MAXLEN];	/* string for tool dialog */
char toolcom[10][MAXLEN];	/* commands for toolmenu selections */
char envvar[MAXSTR][MAXLEN];	/* storage for environment variables */

char line[2*MAXLEN];		/* general use string buffer */

char *commtitle[2] = {"Ghostscript Command Line",  /* title strings for */
		      "    Tool Parameters     "}; /* command param. dialogs */

char *othertitle[4] = {"  Device:  ",	/* title strings for a	*/
		       "Resolution:",   /* generic dialog	*/
		       " Geometry: ",
		       "Clist Size:"};

char *sptr;					/* general use pointer */
char home_dir[MAXLEN]="";			/* dir gemgs run from */
char current_dir[MAXLEN]="";			/* current directory */

char infile[MAXLEN]="";				/* input file */
char outfile[MAXLEN]="";			/* output file */
char toolfile[MAXLEN]="";			/* file selected for tool */

char papersize[MAXLEN]="";			/* papersize */

int dev_checked=FIRSTDEV+1;	/* select first device by default */
int res_checked=FIRSTRES+1;	/* select first resolution by default */
int size_checked=FIRSTSIZE+1;	/* select first pagesize by default */

int i, j, ret, tool, exit_obj, win_dev=0;	/* general variables */

GRECT full;					/* GEM related variables */
int x_res, y_res, color_bits;		
int cx, cy, cw, ch;
int gem_handle, vdi_handle;
int wchar, hchar, wbox, hbox;
int work_in[11], work_out[57], pxy[4];

int confirm=1, quiet=1, nopause=1;		/* default options */
int autoquit=1, pageselect=0, windows=0;
int autorun=0;

FILE *pagein, *pageout;			/* variables used in page selection */
int numpages, up_count, up_max;
int lastbut, page_flag[10], inchanged=0;
struct document *docinfo=NULL, *psscan();

main(int argc, char **argv, char **envp)
{
    OBJECT *object;				/* general object pointer */

    char dir_spec[MAXLEN], file_sel[MAXLEN];	/* used for file selector */

    char *toolptr, *presub(), *pathfind();
    int quit, len, pause, gemtool, changed=1;

    int msgbuff[8], exit_but;		/* GEM related variables */
    int mx, my, mb, mk, key, clicks;
    int wait_event, event, button_state, menuitem=0;

    /* Append all the command line files together. */

    if (argc >= 2) {
	strcpy(infile, argv[1]);
    }

    for(i=2; i<argc; i++) {
	strcat(infile, " ");
	strcat(infile, argv[i]);
    }

    /* GEM initialization */

    init();

    if (autorun) {			/* fake menu events for hot keys */
	menuitem = RUN;
    }

    wait_event = MU_MESAG | MU_KEYBD;
    button_state = 1;

    /* Main event loop */

    for (quit=0; !quit;) {

	if (menuitem) {			/* fake menu events for hot keys */
	    event = MU_MESAG;
	    msgbuff[0] = MN_SELECTED;
	    msgbuff[4] = menuitem;
	    menuitem = 0;
	}
	else {
	    event = evnt_multi(wait_event, 2, 2, button_state,
		1, mx, my, 1, 1, 0, 0, 0, 0, 0,
		msgbuff, 0L, &mx, &my, &mb, &mk,
		&key, &clicks);
	}

	if (event & MU_KEYBD) {		/* hot keys for menus */

	    if (key == ALT_R) {
		menuitem = RUN;
	    }
	    else if (key == ALT_I) {
		menuitem = INPUT;
	    }
	    else if (key == ALT_O) {
		menuitem = OUTPUT;
	    }
	    else if (key == ALT_Q) {
		menuitem = QUIT;
	    }
	    else if (key == ALT_G) {
		menuitem = GEOMETRY;
	    }
	    else if (key == ALT_C) {
		menuitem = CLIST;
	    }
	    else if (key == ALT_P) {
		menuitem = PAGE;
	    }

	}

	if (event & MU_MESAG) {

	    switch (msgbuff[0]) {

	    case MN_SELECTED:
		if (msgbuff[3] != -1) {
		    menu_tnormal(menubar, msgbuff[3], 1);
		}

		switch (msgbuff[4]) {

		case ABOUT:	/* display "about" dialog */
		    exit_obj = dialog(about);
		    break;

		case RUN:	/* build command line and execute GS */
		    if (changed) {
			strcpy(command, "gs.ttp ");

			if (quiet || (windows && win_dev)) {
			    strcat(command, "-q ");
			}

			if (nopause || (windows && win_dev)) {
			    strcat(command, "-dNOPAUSE ");
			}

			if (strlen(clist) && !win_dev) {
			    strcat(command, "-dBufferSize=");
			    strcat(command, clist);
			    strcat(command, " ");
			}

			if (strlen(device) && strcmp(device, "stvdi")) {
			    strcat(command, "-sDEVICE=");
			    strcat(command, device);
			    strcat(command, " ");
			}

			if (strlen(papersize) && strcmp(papersize, "Default")) {
			    strcat(command, "-sPAPERSIZE=");
			    strcat(command, papersize);
			    strcat(command, " ");
			}

			if (strlen(res) && strcmp(res, "Default")) {
			    strcat(command, "-r");
			    strcat(command, res);
			    strcat(command, " ");
			}

			if (strlen(geometry)) {
			    strcat(command, "-g");
			    strcat(command, geometry);
			    strcat(command, " ");
			}

			if (strlen(outfile)) {
			    strcat(command, "-sOUTPUTFILE=");
			    strcat(command, outfile);
			    strcat(command, " ");
			}

			if (pageselect) {
			    strcat(command, PAGEFILE);
			    strcat(command, " ");
			}
			else if (strlen(infile)) {
			    strcat(command, infile);
			    strcat(command, " ");
			}

			if (autoquit || (windows && win_dev)) {
			    strcat(command, "quit.ps");
			}

			changed = 0;
		    }

		    if (confirm && !autorun) {
			commtedinf.te_ptext = command;
			commline[1].ob_spec = UL commtitle[0];
			if ((exit_obj = dialog(commline)) == RUN_CANCEL) {
			    changed = 1;
			    break;
			}
		    }

		    if (!windows) {	/* clear screen if using windows */
			v_enter_cur(vdi_handle);
		    }
		    else {		/* turn menu off and busy bee on */
			menu_bar(menubar, 0);
			graf_mouse(BUSY_BEE, 0L);
		    }

		    /* Execute GS */

		     ret = system(command);

		    /* Turn off the cursor, restore the desktop
		     * background, and then restore the menu bar.
		     */

		    restore_bg();
		    menu_bar(menubar, 1);

		    if (ret < 0) {
			sprintf(line, "[1][Could not execute %s!][OK]", "gs.ttp");
			form_alert(1, line);
		    }

		    if (autorun) autorun = 0;    /* turn off autorun */

		    break;

		case INPUT:
		    sprintf(dir_spec, "%s%s", current_dir, "*.PS");

		    /* If a single input file has been specified,
		     * make it the default selection. If more than
		     * one input file exists, or no input is selected,
		     * use no default.
		     */

		    if (strlen(infile) &&
			((sptr = strchr(infile, ' ')) == NULL)) {

			if ((sptr = strrchr(infile, '\\')) == NULL)
			    strcpy(file_sel, infile);
			else {
			    strcpy(file_sel, ++sptr);
			}
		    }
		    else {
			strcpy(file_sel, "");
		    }

		    ret = fsel_input(dir_spec, file_sel, &exit_but);

		    if (exit_but) {
			if (strlen(file_sel)) {
			    sptr = strrchr(dir_spec, '\\');
			    *++sptr = '\0';
			    strcpy(current_dir, dir_spec);
			    strcpy(infile, dir_spec);
			    strcat(infile, file_sel);
			}
			else {
			    strcpy(infile, "");
			}

			changed = 1;
			inchanged = 1;
		    }

		    break;

		case OUTPUT:
		    exit_obj = dialog(output);

		    switch (exit_obj) {

		    case CEN_BUT:	/* directly to centronics port */
			strcpy(outfile, "CEN:");
			break;

		    case PRN_BUT:	/* centronics port via gemdos */
			strcpy(outfile, "PRN:");
			break;

		    case FILE_BUT:	/* output to 'outfile' */
			if (!strlen(home_dir)) {
			    strcpy(home_dir, current_dir);
			}

			sprintf(dir_spec, "%s%s", home_dir, "*.*");
			len = strlen(outfile);

			/* Use any selected output file as the default */

			if (len != 0 && outfile[len-1] != ':') {
			    if ((sptr = strrchr(outfile, '\\')) == NULL)
			        strcpy(file_sel, outfile);
			    else {
				strcpy(file_sel, ++sptr);
			    }
			}
			else {
			    strcpy(file_sel, "");
			}

			ret = fsel_input(dir_spec, file_sel, &exit_but);

			if (exit_but) {
			    if (strlen(file_sel)) {
			        sptr = strrchr(dir_spec, '\\');
			        *++sptr = '\0';
			        strcpy(current_dir, dir_spec);
			        strcpy(outfile, dir_spec);
			        strcat(outfile, file_sel);
			    }
			    else {
				strcpy(outfile, "");
			    }
			}

			break;
		    }

		    changed = 1;
		    break;

		case QUIT:
		    if (access(PAGEFILE, 0) == 0) {
			unlink(PAGEFILE);
		    }

		    v_clsvwk(vdi_handle);
		    appl_exit();
		    quit = 1;
		    break;

		case FIRSTDEV+1: case FIRSTDEV+2: case FIRSTDEV+3:
		case FIRSTDEV+4: case FIRSTDEV+5: case FIRSTDEV+6:
		case FIRSTDEV+7: case FIRSTDEV+8: case FIRSTDEV+9:

		    /* Set the selected device and check/enable the
		     * appropriate menu items.
		     */

		    menu_icheck(menubar, dev_checked, 0);
		    dev_checked = msgbuff[4];
		    menu_icheck(menubar, dev_checked, 1);

		    object = &menubar[dev_checked];
		    strcpy(device, (char *)(object->ob_spec + 2));

		    if (!strcmp(device, "stvdi")) {
			win_dev = 1;
			menu_ienable(menubar, WINDOWS, 1);
			menu_ienable(menubar, CLIST, 0);
		    }
		    else {
			win_dev = 0;
			menu_ienable(menubar, WINDOWS, 0);
			menu_ienable(menubar, CLIST, 1);
		    }

		    changed = 1;
		    break;

		case LASTDEV:
		    /* Display a dialog to let the user enter the
		     * device by hand
		     */

		    othertedinf.te_ptext = devmenu[8];
		    other[1].ob_spec = UL othertitle[0];

		    if ((exit_obj = dialog(other)) == OTHER_OK) {
		        strcpy(device, devmenu[8]);

			if (strlen(device)) {
			    menu_icheck(menubar, dev_checked, 0);
			    dev_checked = msgbuff[4];
			    menu_icheck(menubar, dev_checked, 1);

			    if (!strcmp(device, "stvdi")) {
				win_dev = 1;
				menu_ienable(menubar, WINDOWS, 1);
				menu_ienable(menubar, CLIST, 0);
			    }
			    else {
				win_dev = 0;
				menu_ienable(menubar, WINDOWS, 0);
				menu_ienable(menubar, CLIST, 1);
			    }

			}
			else {		/* use default */
			    menu_icheck(menubar, dev_checked, 0);
			    dev_checked = FIRSTDEV+1;
			    menu_icheck(menubar, dev_checked, 1);
			    win_dev = 1;
			    menu_ienable(menubar, WINDOWS, 1);
			    menu_ienable(menubar, CLIST, 0);
			}

		        changed = 1;

		    }

		    break;

		case FIRSTRES+1: case FIRSTRES+2: case FIRSTRES+3:
		case FIRSTRES+4: case FIRSTRES+5: case FIRSTRES+6:
		case FIRSTRES+7: case FIRSTRES+8: case FIRSTRES+9:

		    /* Set the selected resolution and check/enable
		     * the appropriate menu items
		     */

		    menu_icheck(menubar, res_checked, 0);
		    res_checked = msgbuff[4];
		    menu_icheck(menubar, res_checked, 1);

		    object = &menubar[msgbuff[4]];
		    strcpy(res, (char *)(object->ob_spec + 2));
		    changed = 1;
		    break;

		case LASTRES:
		    /* Display a dialog to let the user enter the
		     * resolution by hand
		     */

		    othertedinf.te_ptext = resmenu[8];
		    other[1].ob_spec = UL othertitle[1];

		    if ((exit_obj = dialog(other)) == OTHER_OK) {
		        strcpy(res, resmenu[8]);

			if (strlen(res)) {
			    menu_icheck(menubar, res_checked, 0);
			    res_checked = msgbuff[4];
			    menu_icheck(menubar, res_checked, 1);
			}
			else {
			    menu_icheck(menubar, res_checked, 0);
			    res_checked = FIRSTRES+1;
			    menu_icheck(menubar, res_checked, 1);
			}

		        changed = 1;
		    }
		    break;

		case FIRSTSIZE+1: case FIRSTSIZE+2: case FIRSTSIZE+3:
		case FIRSTSIZE+4: case FIRSTSIZE+5: case FIRSTSIZE+6:
		case FIRSTSIZE+7: case FIRSTSIZE+8: case FIRSTSIZE+9:
		case FIRSTSIZE+10: case FIRSTSIZE+11: case FIRSTSIZE+12:
		case FIRSTSIZE+13: case FIRSTSIZE+14:

		    /* Set the selected page size and check/enable
		     * the appropriate menu item
		     */

		    menu_icheck(menubar, size_checked, 0);
		    size_checked = msgbuff[4];
		    menu_icheck(menubar, size_checked, 1);

		    object = &menubar[msgbuff[4]];
		    strcpy(papersize, (char *)(object->ob_spec + 2));
		    changed = 1;
		    break;

		case CONFIRM:
		    menu_icheck(menubar, msgbuff[4], !confirm);
		    confirm = !confirm;
		    changed = 1;
		    break;

		case QUIET:
		    menu_icheck(menubar, msgbuff[4], !quiet);
		    quiet = !quiet;
		    changed = 1;
		    break;

		case NOPAUSE:
		    menu_icheck(menubar, msgbuff[4], !nopause);
		    nopause = !nopause;
		    changed = 1;
		    break;

		case AUTOQUIT:
		    menu_icheck(menubar, msgbuff[4], !autoquit);
		    autoquit = !autoquit;
		    changed = 1;
		    break;

		case WINDOWS:
		    menu_icheck(menubar, msgbuff[4], !windows);
		    windows = !windows;

		    /* If windows are selected, set the GS_WIN environment
		     * variable that instructs ghostscript to use windows.
		     */

		    if (windows) {
			ret = putenv("GS_WIN=batch");
		    }
		    else {
			ret = putenv("GS_WIN=off");
		    }

		    changed = 1;
		    break;

		case GEOMETRY:
		    /* Display a dialog that allows the gemometry to
		     * be entered by hand.
		     */

		    othertedinf.te_ptext = tempgeom;
		    other[1].ob_spec = UL othertitle[2];

		    if ((exit_obj = dialog(other)) == OTHER_OK) {
		        strcpy(geometry, tempgeom);

			if (strlen(geometry)) {
			    menu_icheck(menubar, msgbuff[4], 1);
			}
			else {
			    menu_icheck(menubar, msgbuff[4], 0);
			}

			changed = 1;
		    }
		    break;

		case CLIST:
		    /* Display a dialog that allows the size of the
		     * clist buffer to be entered by hand.
		     */

		    othertedinf.te_ptext = tempclist;
		    other[1].ob_spec = UL othertitle[3];

		    if ((exit_obj = dialog(other)) == OTHER_OK) {
		        strcpy(clist, tempclist);

			if (strlen(clist)) {
			    menu_icheck(menubar, msgbuff[4], 1);
			}
			else {
			    menu_icheck(menubar, msgbuff[4], 0);
			}

			changed = 1;
		    }

		    break;

		case PAGE:
		    /* Display a dialog that allows specific pages
		     * in a document to be rendered individually.
		     */

		    pagetedinf.te_ptext = pages;

		    /* If no input file is selected, open a file selector. */

		    if (!strlen(infile)) {
			sprintf(dir_spec, "%s%s", current_dir, "*.PS");
			strcpy(file_sel, "");
			ret = fsel_input(dir_spec, file_sel, &exit_but);

			if (exit_but) {
			    if (strlen(file_sel)) {
				sptr = strrchr(dir_spec, '\\');
				*++sptr = '\0';
				strcpy(current_dir, dir_spec);
				strcpy(infile, dir_spec);
				strcat(infile, file_sel);
			    }
			    else {
				break;
			    }

			}

		    }

		    if ((sptr = pathfind("GS_LIB", infile, ",")) == NULL) {
			sprintf(line, "[1][Could not find %s!][OK]", infile);
			form_alert(1, line);
			break;
		    }
		    else if ((pagein = fopen(sptr, "r")) == NULL) {
			sprintf(line, "[1][Could not open %s!][OK]", sptr);
			form_alert(1, line);
			break;
		    }

		    graf_mouse(BUSY_BEE, 0L);

		    /* If the input file has not been scanned, search it
		     * for page information.
		     */

		    if (docinfo == NULL || inchanged) {
			docinfo = psscan(pagein);
		    }

		    if (docinfo == NULL || docinfo->numpages == 0
			|| docinfo->pageorder == SPECIAL) {

			sprintf(line, "[1][%s|%s|%s|%s][OK]",
				"Page information cannot be",
				"extracted from this file.",
				"It probably does not conform",
				"to Adobe structuring conventions.");

			graf_mouse(ARROW, 0L);
			form_alert(1, line);
			pageselect = 0;
			menu_icheck(menubar, msgbuff[4], 0);
			break;
		    }

		    fclose(pagein);

		    graf_mouse(ARROW, 0L);

		    numpages = docinfo->numpages;

		    /* If page information has been successfully
		     * extracted, display a dialog to allow page
		     * selection.
		     */

		    if ((exit_obj = page_dialog()) == PAGE_OK) {
			if (strlen(pages)) {
			    pageselect = 1;
			    menu_icheck(menubar, msgbuff[4], 1);
			    graf_mouse(BUSY_BEE, 0L);
			    ret = page_filter(infile, pages, PAGEFILE);
			    graf_mouse(ARROW, 0L);
			}
			else {
			    pageselect = 0;
			    menu_icheck(menubar, msgbuff[4], 0);
			}

		    }

		    changed = 1;
		    break;

		case FIRSTOOL+1: case FIRSTOOL+2:
		case FIRSTOOL+3: case FIRSTOOL+4:
		case FIRSTOOL+5: case FIRSTOOL+6:
		case FIRSTOOL+7: case FIRSTOOL+8:
		case FIRSTOOL+9: case FIRSTOOL+10:

		    /* Process the command line for the selected
		     * tool program and then execute it.
		     */

		    tool = msgbuff[4] - FIRSTOOL - 1;
		    toolptr = presub(toolcom[tool], " ");

		    strcpy(toolexec, toolptr);
		    strcpy(command, toolptr);
		    strcat(command, " ");

		    pause = 0;
		    gemtool = 0;

		    while ((toolptr = presub(NULL, " ")) != NULL) {
			if (!strcmp(toolptr, "infile")) {

			    /* If the command line contains "infile",
			     * use/get the input file.
			     */

			    if (!strlen(infile) || strchr(infile, ' ')) {
				sprintf(dir_spec, "%s%s", current_dir, "*.*");
				strcpy(file_sel, "");

				ret = fsel_input(dir_spec, file_sel, &exit_but);

				if (exit_but) {
				    if (strlen(file_sel)) {
					sptr = strrchr(dir_spec, '\\');
					*++sptr = '\0';
					strcpy(current_dir, dir_spec);
					strcpy(infile, dir_spec);
					strcat(infile, file_sel);
				    }
				    else {
					strcpy(infile, "");
				    }
				}

			    }
			    strcat(command, infile);
			    strcat(command, " ");
			}
			else if (!strcmp(toolptr, "outfile")) {

			    /* If the command line contains "outfile",
			     * use/get the output file.
			     */

			    if (!strlen(outfile) || strchr(outfile, ' ')) {
				if (!strlen(home_dir)) {
				    strcpy(home_dir, current_dir);
				}

				sprintf(dir_spec, "%s%s", home_dir, "*.*");
				strcpy(file_sel, "");

				ret = fsel_input(dir_spec, file_sel, &exit_but);

				if (exit_but) {
				    if (strlen(file_sel)) {
					sptr = strrchr(dir_spec, '\\');
					*++sptr = '\0';
					strcpy(current_dir, dir_spec);
					strcpy(outfile, dir_spec);
					strcat(outfile, file_sel);
				    }
				    else {
			    		strcpy(outfile, "");
				    }
				}

			    }

			    strcat(command, outfile);
			    strcat(command, " ");

			}
			else if (!strcmp(toolptr, "fsel")) {

			    /* If the command line contains "fsel",
			     * display a file selector.
			     */

			    if (!strlen(home_dir)) {
				strcpy(home_dir, current_dir);
			    }

			    sprintf(dir_spec, "%s%s", home_dir, "*.*");
			    strcpy(file_sel, "");

			    ret = fsel_input(dir_spec, file_sel, &exit_but);

			    if (exit_but) {
				if (strlen(file_sel)) {
				    sptr = strrchr(dir_spec, '\\');
				    *++sptr = '\0';
				    strcpy(current_dir, dir_spec);
				    strcpy(toolfile, dir_spec);
				    strcat(toolfile, file_sel);
				}
				else {
			    	    strcpy(toolfile, "");
				}
			    }

			    strcat(command, toolfile);
			    strcat(command, " ");

			}
			else if (!strcmp(toolptr, "dialog")) {

			    /* If the command line contains "dialog",
			     * display a dialog for entry of command
			     * line parameters.
			     */

			    commtedinf.te_ptext = temptool;
			    commline[1].ob_spec = UL commtitle[1];

			    if ((exit_obj = dialog(commline)) != RUN_CANCEL) {
				strcat(command, temptool);
				strcat(command, " ");
			    }

			    strcpy(temptool, "");

			}
			else if (!strcmp(toolptr, "pause")) {

			    /* If the command line contains "pause",
			     * set a flag to pause after program
			     * execution.
			     */

			    pause = 1;
			}
			else if (!strcmp(toolptr, "gem")) {

			    /* If the command line contains "gem",
			     * set a flag to initialize the screen
			     * and mouse before execution.
			     */

			    gemtool = 1;
			}
			else {

			    /* Put all other command line arguments
			     * in the command line for the tool.
			     */

			    strcat(command, toolptr);
			    strcat(command, " ");
			}

		    }

		    /* Fake a dialog that covers the screen, so that
		     * the background can be restored when GS exits.
		     * Then clear the screen.
		     */

/*		    form_dial(FMD_START, 0, 0, wchar, hchar, 0, 0, x_res, y_res);
*/
		    menu_bar(menubar, 0);
		    if (!gemtool) {
			v_enter_cur(vdi_handle);
		    }

		    /* Execute tool */

		    ret = system(command);

		    if (pause) {
			puts("\nPress RETURN to continue.");
			getchar();
		    }

		    /* Turn off the cursor, restore the desktop
		     * background, and then restore the menu bar.
		     */

#if 0
		    v_exit_cur(vdi_handle);
		    form_dial(FMD_FINISH, 0, 0, wchar, hchar, 0, 0, x_res, y_res);
#endif
		    restore_bg();
		    menu_bar(menubar, 1);

		    if (ret < 0) {
			sprintf(line, "[1][Could not execute %s!][OK]",
				toolexec);
			form_alert(1, line);
		    }

		    pause = 0;
		    changed = 1;

		    break;

		}

		break;
	    }
        }			/* end if (event & MU_MESAG) */

    }				/* end for(;;) */

    exit(0);

}

/* Init takes care of GEM and other initializations. */

int init()
{
	DIR *dfp;	/* Pointer to directory structure. */
	int ii;

	/* Standard GEM initialization. */

	if (appl_init() == -1) return 0;
	for (ii=0; ii<10; ii++) work_in[ii] = 1;
	work_in[10] = 2;
	gem_handle = graf_handle(&wchar, &hchar, &wbox, &hbox);
	vdi_handle = gem_handle;
	v_opnvwk(work_in, &vdi_handle, work_out);
	if (vdi_handle == 0) return 0;

	/* Save the screen resolution and number of color planes. */

	x_res = work_out[0];
	y_res = work_out[1];

	vq_extnd(vdi_handle, 1, work_out);
	color_bits = work_out[4];

	wind_get(0, WF_WORKXYWH, &full.g_x, &full.g_y, &full.g_w, &full.g_h);

	/* Adjust the sizes of all objects for the current
	 * screen resolution.
	 */

	objc_fix(menubar);
	objc_fix(about);
	objc_fix(commline);
	objc_fix(output);
	objc_fix(other);
	objc_fix(pagedial);

	restore_bg();			/* restore the desktop background */
	menu_bar(menubar, 1);		

	/* Find the current directory. */

	getcwd(home_dir, MAXLEN);

	while ((sptr = strchr(home_dir, '/')) != NULL) {
	    *sptr = '\\';	/* change forward to backward slashes */
	}

	strcat(home_dir, "\\");
	strcpy(current_dir, home_dir);

	read_config();			/* read the configuration file */

}

/* Process a generic dialog. */

int dialog(OBJECT *object)
{
    int exit_but;

    form_center(object, &cx, &cy, &cw, &ch);
    form_dial(FMD_START, 0, 0, wchar, hchar, cx, cy, cw, ch);
    objc_draw(object, 0, 5, cx, cy, cw, ch);

    exit_but = form_do(object, 0);

    form_dial(FMD_FINISH, 0, 0, wchar, hchar, cx, cy, cw, ch);
    objc_change(&object[exit_but], 0, 0, cx, cy, cw, ch, NORMAL, 0);

    return exit_but;
}

/* Read the configuration file. */

int read_config()
{
    FILE *config;
    OBJECT *object;
    char *pathfind();

    int newdev=0, newres=0, newtool=0, newenv=0;

    unsigned long len;

    /* Look for the configuration file in the current and HOME directories. */

    if ((sptr = pathfind("HOME", CONFIGFILE, ",")) != NULL) {
	strcpy(configfile, sptr);
    }
    else {    
	sprintf(line, "[1][Could not find %s!][OK]", CONFIGFILE);
	form_alert(1, line);
	goto menu;
    }

    if ((config = fopen(configfile, "r")) == NULL) {
	sprintf(line, "[1][Could not open %s!][OK]", CONFIGFILE);
	form_alert(1, line);
	goto menu;
    }

    /* Process the information in the config file. */

    while (fgets(line, 2*MAXLEN-1, config) != NULL) {

#if 0
	if (strlen(line) > 3) {
	printf("%x\n", line[strlen(line)+1]);
	printf("%x\n", line[strlen(line)]);
	printf("%x\n", line[strlen(line)-1]);
	printf("%x\n", line[strlen(line)-2]);
	getchar();
	}
#endif
	line[strlen(line)-1] = '\0';

	if (!strncmp(line, "device ", 7)) {
	    strcpy(device, line+7);
	}
	if (!strncmp(line, "resolution ", 11)) {
	    strcpy(res, line+11);
	}
	if (!strncmp(line, "geometry ", 9)) {
	    strcpy(geometry, line+9);
	    strcpy(tempgeom, line+9);
	}
	if (!strncmp(line, "clist ", 6)) {
	    strcpy(clist, line+6);
	    strcpy(tempclist, line+6);
	}
	if (!strncmp(line, "confirm ", 8)) {
	    confirm = atoi(line+8);
	}
	if (!strncmp(line, "quiet ", 6)) {
	    quiet = atoi(line+6);
	}
	if (!strncmp(line, "nopause ", 8)) {
	    nopause = atoi(line+8);
	}
	if (!strncmp(line, "autoquit ", 9)) {
	    autoquit = atoi(line+9);
	}
	if (!strncmp(line, "autorun ", 8)) {
	    if (strlen(infile)) {
		autorun = atoi(line+8);
	    }
	}
	if (!strncmp(line, "papersize ", 10)) {
	    strcpy(papersize, line+10);
	}
	if (!strncmp(line, "windows ", 8)) {
	    windows = atoi(line+8);
	    if (windows) {
		ret = putenv("GS_WIN=batch");
	    }
	}
	if (!strncmp(line, "setenv ", 7)) {
	    strcpy(envvar[newenv], line+7);
	    ret = putenv(envvar[newenv++]);
	}
	if (!strncmp(line, "devmenu ", 8)) {
	    strcpy(devmenu[newdev], "  ");
	    strcat(devmenu[newdev], line+8);

	    object = &menubar[FIRSTDEV];
	    object->ob_height += hchar;

	    object = &menubar[FIRSTDEV + newdev + 1];
	    object->ob_next = FIRSTDEV + newdev + 2;

	    ++object;
	    object->ob_next = LASTDEV;
	    object->ob_state = 0;
	    object->ob_spec = UL devmenu[newdev];

	    object = &menubar[LASTDEV];
	    object->ob_y += hchar;

	    ++newdev;
	}

	if (!strncmp(line, "resmenu ", 8)) {
	    strcpy(resmenu[newres], "  ");
	    strcat(resmenu[newres], line+8);

	    object = &menubar[FIRSTRES];
	    object->ob_height += hchar;

	    object = &menubar[FIRSTRES + newres + 1];
	    object->ob_next = FIRSTRES + newres + 2;

	    ++object;
	    object->ob_next = LASTRES;
	    object->ob_state = 0;
	    object->ob_spec = UL resmenu[newres];

	    object = &menubar[LASTRES];
	    object->ob_y += hchar;

	    ++newres;
	}

	if (!strncmp(line, "toolmenu ", 9)) {
	    sptr = strchr(line+9, ' ');
	    if (sptr == NULL) continue;

	    len = sptr - (line+9);

	    strcpy(toolmenu[newtool], "  ");
	    strncat(toolmenu[newtool], line+9, len);
	    strcpy(toolcom[newtool], sptr+1);

	    object = &menubar[FIRSTOOL];

	    if (newtool == 0) {
		++object;
		object->ob_state = 0;
		object->ob_spec = UL toolmenu[newtool];
	    }
	    else {
		object->ob_tail = FIRSTOOL + newtool + 1; 
		object->ob_height += hchar;

		object = &menubar[FIRSTOOL + newtool];
		object->ob_next = FIRSTOOL + newtool + 1;

		object = &menubar[FIRSTOOL + newtool + 1];
		object->ob_next = FIRSTOOL;
		object->ob_state = 0;
		object->ob_spec = UL toolmenu[newtool];
	    }

	    ++newtool;
	}

    }

    menu:    /* Check and enable all the appropriate menu entries. */

    if (!windows && (sptr = getenv("GS_WIN")) != NULL) {
	if (!strcmp(sptr, "batch")) {
	    windows = 1;
	}
    }

    menu_icheck(menubar, CONFIRM, confirm);
    menu_icheck(menubar, QUIET, quiet);
    menu_icheck(menubar, NOPAUSE, nopause);
    menu_icheck(menubar, AUTOQUIT, autoquit);
    menu_icheck(menubar, WINDOWS, windows);
    menu_icheck(menubar, GEOMETRY, strlen(geometry) ? 1 : 0);
    menu_icheck(menubar, CLIST, strlen(clist) ? 1 : 0);

    /* If the device was not set in the config file, check the GS_DEVICE
     * environment variable.
     */

    if (!strlen(device) && ((sptr = getenv("GS_DEVICE")) != NULL)) {
	strcpy(device, sptr);
    }

    if (strlen(device) && strcmp(device, "stvdi")) {
	menu_icheck(menubar, FIRSTDEV+1, 0);
	menu_ienable(menubar, WINDOWS, 0);
	for (i=0; strcmp(device, devmenu[i]+2) && i<8; i++);
	dev_checked = FIRSTDEV+2+i;
	menu_icheck(menubar, dev_checked, 1);
	if (i == 8) strcpy(devmenu[8], device);
    }
    else {
	win_dev = 1;
	menu_ienable(menubar, CLIST, 0);
    }

    if (strlen(res)) {
	menu_icheck(menubar, FIRSTRES+1, 0);
	for (i=0; strcmp(res, resmenu[i]+2) && i<8; i++);
	res_checked = FIRSTRES+2+i;
	menu_icheck(menubar, res_checked, 1);
	if (i == 8) strcpy(resmenu[8], res);
    }

    if (strlen(papersize)) {
	menu_icheck(menubar, FIRSTSIZE+1, 0);
	for (i=FIRSTSIZE+1;
	    strcmp(papersize, (char *)(menubar[i].ob_spec+2))
	    && i<=LASTSIZE; i++);
	size_checked = i;
	menu_icheck(menubar, size_checked, 1);
    }

    fclose(config);

}

/* Restore the usual desktop background. */

int restore_bg()
{

	puts("\033f");
	v_hide_c(vdi_handle);
	form_dial(FMD_FINISH, 0, 0, 8, 16, 0, 0, x_res, y_res);
	graf_mouse(ARROW, 0L);
	v_show_c(vdi_handle, 0);
}

/* Adjust the size of an object for the current screen resolution. */

int objc_fix(OBJECT *object)
{
    int i=-1;

    do {
	i++;

	if      (object[i].ob_x == 769) object[i].ob_x = full.g_y;
	else if (object[i].ob_x == 513) object[i].ob_x = full.g_y;
	else				object[i].ob_x *= wchar;

	if      (object[i].ob_y == 769) object[i].ob_y = full.g_y;
	else if (object[i].ob_y == 513) object[i].ob_y = full.g_y;
	else				object[i].ob_y *= hchar;

	if      (object[i].ob_width == 769) object[i].ob_width = full.g_y;
	else if (object[i].ob_width == 513) object[i].ob_width = full.g_y;
	else if (object[i].ob_width == 80)  object[i].ob_width = full.g_w;
	else				    object[i].ob_width *= wchar;

	if      (object[i].ob_height == 769) object[i].ob_height = full.g_y;
	else if (object[i].ob_height == 513) object[i].ob_height = full.g_y;
	else				     object[i].ob_height *= hchar;

    }
    while (!(object[i].ob_flags & LASTOB));

}

/* Update the objects found in the page selection dialog. */

int update_objects()
{

    if (up_count == up_max) {
	lastbut = FIRSTBUT + (int)(fmod(numpages, 10) - .9);
    }
    else {
	lastbut = LASTBUT;
    }

    for (i=FIRSTBUT, j=0; i<=LASTBUT; i++, j++) {
	if (i<=lastbut) {
	    pagedial[i].ob_flags = 1;		/* selectable */
	    pagedial[i].ob_state = 0;		/* enabled */

	    if (page_flag[up_count] & (int)ldexp(1,j)) {
		pagedial[i].ob_state = SELECTED;
	    }
	}
	else {
	    pagedial[i].ob_flags = 0;	/* not selectable */
	    pagedial[i].ob_state = 0x08;	/* disabled */
	}
    }

    if (up_count == 0) {
	pagedial[LASTBUT+1].ob_flags = 0;	/* not selectable */
	pagedial[LASTBUT+1].ob_state = 0x08;	/* disabled */
    }
    else {
	pagedial[LASTBUT+1].ob_flags = 0x41;	/* selectable */
	pagedial[LASTBUT+1].ob_state = 0;	/* enabled */
    }

    if (up_count == up_max) {
	pagedial[LASTBUT+2].ob_flags = 0;	/* not selectable */
	pagedial[LASTBUT+2].ob_state = 0x08;	/* disabled */
    }
    else {
	pagedial[LASTBUT+2].ob_flags = 0x41;	/* selectable */
	pagedial[LASTBUT+2].ob_state = 0;	/* enabled */
    }

}

/* Unselect all the objects in the page selection dialog. */

int clear_objects()
{
    char *itoa();

    for (i=FIRSTBUT; i<=lastbut; i++) {
	pagedial[i].ob_state = 0;
    }
    for (i=0; i<=up_max; i++) {
	page_flag[i] = 0;
    }
    strcpy(pages, "");

    for (i=FIRSTBUT; i<=LASTBUT; i++) {
	itoa((char *)pagedial[i].ob_spec,
	    atoi((char *)pagedial[i].ob_spec)-10*up_count);
    }

    up_count = 0;

    objc_change(&pagedial[exit_obj], 0, 0, cx, cy, cw, ch, NORMAL, 0);

}

/* Handle the user interaction with the page dialog. */

int page_dialog()
{
    char *itoa();
    int pagequit=0;

    if (inchanged) {
	clear_objects();
	inchanged = 0;
    }

    up_max = (numpages - 1)/10;

    sprintf((char *)pagedial[1].ob_spec, "There are %d pages.", numpages);

    /* Set the initial state of the objects. */

    update_objects();

    /* Handle dialog interaction. */

    while (!pagequit && (exit_obj = dialog(pagedial))) {

	page_flag[up_count] = 0;

	/* Save selections and clear objects. */

	for (i=FIRSTBUT, j=0; i<=lastbut; i++, j++) {
	    if (pagedial[i].ob_state & SELECTED) {
		page_flag[up_count] |= (int)ldexp(1,j);
		pagedial[i].ob_state = 0;
	    }
	}

        switch (exit_obj) {

	case PAGE_UP:
	    up_count++;
	    for (i=FIRSTBUT; i<=LASTBUT; i++) {
		itoa((char *)pagedial[i].ob_spec,
		    atoi((char *)pagedial[i].ob_spec)+10);
	    }
	    break;

	case PAGE_DN:
	    up_count--;
	    for (i=FIRSTBUT; i<=LASTBUT; i++) {
		itoa((char *)pagedial[i].ob_spec,
		    atoi((char *)pagedial[i].ob_spec)-10);
	    }
	    break;

	case PAGE_CLEAR:
	    clear_objects();
	    break;

	case PAGE_CANCEL:
	    pagequit = 1;
	    break;

	case PAGE_OK:
	    if (!strlen(pages)) {
		for (i=0; i<=up_max; i++) {
		    for (j=0; j<=(LASTBUT-FIRSTBUT); j++) {

			if (page_flag[i] & (int)ldexp(1,j)) {
			    int pagenum;
			    pagenum = (j+1) + 10*i;

			    if (!strlen(pages)) {
				strcpy(pages, itoa(line, pagenum));
			    }
			    else {
				strcat(pages, ",");
				strcat(pages, itoa(line, pagenum));
			    }
			}

		    }
		}

	    }
	    pagequit = 1;
	    break;

	}

	/* Set object states for this value of up_count. */

	update_objects();

    }

    return exit_obj;
}
