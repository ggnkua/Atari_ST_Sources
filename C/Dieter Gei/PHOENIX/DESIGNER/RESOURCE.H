/*****************************************************************************
 *
 * Module : RESOURCE.H
 * Author : JÅrgen Geiû
 *
 * Creation date    : 24.07.91
 * Last modification: 20.09.94
 *
 *
 * Description: This module implements the resource handling.
 *
 * History:
 * 20.09.94: Object tree seljoin changed to selsubm
 * 16.12.93: Object tree selpath added
 * 04.11.93: Object tree selfile added
 * 30.10.93: Object popup deleted
 * 02.10.93: Object tree USERINTR added, CONFMORE deleted
 * 27.09.93: Function switch_trees_3d added
 * 24.09.93: Variable confmore added
 * 06.09.93: dbiconsl & maskicnl deleted
 * 24.07.91: Creation of body
 *****************************************************************************/

#ifndef __RESOURCE__
#define __RESOURCE__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

GLOBAL OBJECT *moreinfo;
GLOBAL OBJECT *userimg;
GLOBAL OBJECT *alert;
GLOBAL OBJECT *selfile;
GLOBAL OBJECT *selpath;
GLOBAL OBJECT *selfont;
GLOBAL OBJECT *helpinx;
GLOBAL OBJECT *popups;
GLOBAL OBJECT *dbicons;
GLOBAL OBJECT *config;
GLOBAL OBJECT *params;
GLOBAL OBJECT *userintr;
GLOBAL OBJECT *maskicon;
GLOBAL OBJECT *basemenu;
GLOBAL OBJECT *maskmenu;
GLOBAL OBJECT *dbinfo;
GLOBAL OBJECT *newtable;
GLOBAL OBJECT *newfield;
GLOBAL OBJECT *newkey;
GLOBAL OBJECT *opendb;
GLOBAL OBJECT *doicons;
GLOBAL OBJECT *formats;
GLOBAL OBJECT *dbparams;
GLOBAL OBJECT *relrules;
GLOBAL OBJECT *selfield;
GLOBAL OBJECT *selfill;
GLOBAL OBJECT *selline;
GLOBAL OBJECT *selgrid;
GLOBAL OBJECT *selsize;
GLOBAL OBJECT *seltext;
GLOBAL OBJECT *objsize;
GLOBAL OBJECT *picsize;
GLOBAL OBJECT *linesize;
GLOBAL OBJECT *rbvalues;
GLOBAL OBJECT *cbvalues;
GLOBAL OBJECT *selsubm;
GLOBAL OBJECT *selbutto;
GLOBAL OBJECT *baccess;
GLOBAL OBJECT *stdforma;
GLOBAL OBJECT *selmask;
GLOBAL OBJECT *maskinfo;
GLOBAL OBJECT *tblinfo;
GLOBAL OBJECT *empty;
GLOBAL OBJECT *helpmenu;
GLOBAL OBJECT *habout;

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_resource   _((VOID));
GLOBAL BOOLEAN term_resource   _((VOID));

GLOBAL VOID    switch_trees_3d _((VOID));

#endif /* __RESOURCE__ */

