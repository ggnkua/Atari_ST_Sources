/*****************************************************************************
 *
 * Module : RESOURCE.H
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 29.10.02
 *
 *
 * Description: This module defines the resource.
 *
 * History:
 * 29.10.02: Object tree newprocmenu_new added
 * 					 Object tree newprocmenu_list added
 * 10.12.96: Object tree accicon added
 * 09.07.95: Object tree accicon added
 * 08.12.94: Object tree getparm added
 * 19.03.94: Object tree copies added
 * 05.12.93: Object tree selpath added
 * 02.11.93: Object trees selfile and selfont added
 * 02.10.93: Object tree userintr added
 * 15.09.93: Function switch_trees_3d added
 * 01.09.93: Variable listicon added
 * 30.08.93: Variable qbeicon added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __RESOURCE__
#define __RESOURCE__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

GLOBAL OBJECT *userimg;
GLOBAL OBJECT *alert;
GLOBAL OBJECT *selfile;
GLOBAL OBJECT *selpath;
GLOBAL OBJECT *selfont;
GLOBAL OBJECT *helpinx;
GLOBAL OBJECT *popup;
GLOBAL OBJECT *popups;
GLOBAL OBJECT *icons;
GLOBAL OBJECT *listwidt;
GLOBAL OBJECT *months;
GLOBAL OBJECT *loaddb;
GLOBAL OBJECT *flushkey;
GLOBAL OBJECT *infmeta;
GLOBAL OBJECT *moreinfo;
GLOBAL OBJECT *selbox;
GLOBAL OBJECT *config;
GLOBAL OBJECT *imexparm;
GLOBAL OBJECT *cfgprn;
GLOBAL OBJECT *queue;
GLOBAL OBJECT *pageform;
GLOBAL OBJECT *fontsize;
GLOBAL OBJECT *userintr;
GLOBAL OBJECT *procbox;
GLOBAL OBJECT *opendb;
GLOBAL OBJECT *dbinfo;
GLOBAL OBJECT *tblinfo;
GLOBAL OBJECT *inxinfo;
GLOBAL OBJECT *params;
GLOBAL OBJECT *getparm;
GLOBAL OBJECT *lockscrn;
GLOBAL OBJECT *chngpass;
GLOBAL OBJECT *delrecs;
GLOBAL OBJECT *remsel;
GLOBAL OBJECT *copies;
GLOBAL OBJECT *clipname;
GLOBAL OBJECT *listsrch;
GLOBAL OBJECT *newwidth;
GLOBAL OBJECT *order;
GLOBAL OBJECT *reorgpar;
GLOBAL OBJECT *sorting;
GLOBAL OBJECT *statist;
GLOBAL OBJECT *newproc;
GLOBAL OBJECT *newprocmenu_new;
GLOBAL OBJECT *newprocmenu_list;
GLOBAL OBJECT *listicon;
GLOBAL OBJECT *qbeicon;
GLOBAL OBJECT *rprticon;
GLOBAL OBJECT *calcicon;
GLOBAL OBJECT *baticon;
GLOBAL OBJECT *accicon;
GLOBAL OBJECT *previcon;
GLOBAL OBJECT *maskmenu;
GLOBAL OBJECT *maskicon;
GLOBAL OBJECT *maskconf;
GLOBAL OBJECT *join;
GLOBAL OBJECT *helpmenu;
GLOBAL OBJECT *habout;
/* [GS] 5.1f Start */
GLOBAL OBJECT *iconify_tree;
/* Ende */

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_resource   _((VOID));
GLOBAL BOOLEAN term_resource   _((VOID));

GLOBAL VOID    switch_trees_3d _((VOID));

#endif /* __RESOURCE__ */

