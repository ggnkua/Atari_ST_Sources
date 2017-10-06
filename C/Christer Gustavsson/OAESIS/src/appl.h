#ifndef	__APPL__
#define	__APPL__

#include	"mesagdef.h"
#include	"rdwrs.h"
#include	"types.h"


#define TOP_APPL       (-1)
#define DESK_OWNER     (-2)
#define TOP_MENU_OWNER (-3)

/****************************************************************************
 * Appl_init_module                                                         *
 *  Initiate the application module.                                        *
 ****************************************************************************/
void                    /*                                                  */
Appl_init_module(void); /*                                                  */
/****************************************************************************/

/****************************************************************************
 * Appl_exit_module                                                         *
 *  Shutdown the application module.                                        *
 ****************************************************************************/
void                    /*                                                  */
Appl_exit_module(void); /*                                                  */
/****************************************************************************/

/****************************************************************************
 * Appl_put_event                                                           *
 *  Put event message in event pipe                                         *
 ****************************************************************************/
WORD              /*  0 if ok or -1                                         */
Appl_put_event(   /*                                                        */
WORD apid,        /* Id of application that is to receive a message.        */
EVNTREC *m);      /* Message to be sent                                     */
/****************************************************************************/

/****************************************************************************
 * Appl_info_alloc                                                          *
 *  Reserve structure of internal application information.                  *
 ****************************************************************************/
AP_INFO *           /* Application description or NULL.                     */
Appl_info_alloc(    /*                                                      */
WORD pid,           /* MiNT process id.                                     */
WORD type);         /* Type of application (appl, acc, desktop etc)         */
/****************************************************************************/

void	apinfofree(WORD id);

/****************************************************************************
 * Appl_internal_info                                                       *
 *  Get internal information about application.                             *
 ****************************************************************************/
AP_INFO *           /* Application description or NULL.                     */
Appl_internal_info( /*                                                      */
WORD apid);         /* Id of application.                                   */
/****************************************************************************/

/****************************************************************************
 * Appl_search_apid                                                         *
 *  Find AES-id & return AP_LIST entry for that.                            *
 ****************************************************************************/
AP_LIST *         /* Entry or NULL.                                         */
Appl_search_apid( /*                                                        */
WORD apid);       /* Application id of the searched application.            */
/****************************************************************************/

/****************************************************************************
 * Appl_get_top                                                             *
 *  Get currently topped application.                                       *
 ****************************************************************************/
WORD                /* Id of topped application.                            */
Appl_get_top(void); /*                                                      */
/****************************************************************************/

/****************************************************************************
 * Appl_get_deskbg                                                          *
 *  Get the resource tree of the top desktop.                               *
 ****************************************************************************/
OBJECT *               /* Resource tree, or NULL.                           */
Appl_get_deskbg(void); /*                                                   */
/****************************************************************************/

/****************************************************************************
 * Appl_set_deskbg                                                          *
 *  Set the resource tree of the desktop of an application                  *
 ****************************************************************************/
WORD              /* 0 if ok or -1.                                         */
Appl_set_deskbg(  /*                                                        */
WORD apid,        /* Id of application.                                     */
WORD vid,         /* VDI workstation id.                                    */
OBJECT *tree);    /* Resource tree.                                         */
/****************************************************************************/

/****************************************************************************
 * Appl_get_menu                                                            *
 *  Get the resource tree of the menu of an application                     *
 ****************************************************************************/
OBJECT *          /* Resource tree, or NULL.                                */
Appl_get_menu(    /*                                                        */
WORD apid);       /* Id of application.                                     */
/****************************************************************************/

/****************************************************************************
 * Appl_set_menu                                                            *
 *  Set the resource tree of the menu of an application                     *
 ****************************************************************************/
WORD              /* 0 if ok or -1.                                         */
Appl_set_menu(    /*                                                        */
WORD apid,        /* Id of application.                                     */
OBJECT *tree);    /* Resource tree.                                         */
/****************************************************************************/

/****************************************************************************
 * Appl_set_newmsg                                                          *
 *  Set indication of which messages the application understands.           *
 ****************************************************************************/
WORD              /* 0 if ok or -1.                                         */
Appl_set_newmsg(  /*                                                        */
WORD apid,        /* Id of application.                                     */
WORD newmsg);     /* Messages understood.                                   */
/****************************************************************************/

/****************************************************************************
 * Appl_top                                                                 *
 *  Top application.                                                        *
 ****************************************************************************/
WORD              /* Previously topped application.                         */
Appl_top(         /*                                                        */
WORD apid,        /* Id of application.                                     */
WORD vid);        /* VDI workstation id.                                    */
/****************************************************************************/

/*message handling calls*/

/****************************************************************************
 * Appl_do_write                                                            *
 *  Implementation of appl_write().                                         *
 ****************************************************************************/
WORD           /* 0 if ok, or 1.                                            */
Appl_do_write( /*                                                           */
WORD apid,     /* Id of application to receive message.                     */
WORD length,   /* Length of message structure.                              */
void *m);      /* Pointer to message structure.                             */
/****************************************************************************/

/****************************************************************************
 * Appl_do_find                                                             *
 *  Implementation of appl_find().                                          *
 ****************************************************************************/
WORD              /* Application id, or -1.                                 */
Appl_do_find(     /*                                                        */
BYTE *fname);     /* File name of application to seek.                      */
/****************************************************************************/

/****************************************************************************
 * Appl_do_search                                                           *
 *  Implementation of appl_search().                                        *
 ****************************************************************************/
WORD              /* 0 if no more applications exist, or 1.                 */
Appl_do_search(   /*                                                        */
WORD apid,        /* pid of caller..                                        */
WORD mode,        /* Search mode.                                           */
BYTE *fname,      /* File name of application to seek.                      */
WORD *type,       /* Type of found application.                             */
WORD *ap_id);     /* Application id fo found application.                   */
/****************************************************************************/

/****************************************************************************
 * Appl_do_init                                                             *
 *  Implementation of appl_init().                                          *
 ****************************************************************************/
WORD                   /* Application id, or -1.                            */
Appl_do_init(          /*                                                   */
GLOBAL_ARRAY *global); /* Global array.                                     */
/****************************************************************************/

/****************************************************************************
 * Appl_do_exit                                                             *
 *  Implementation of appl_exit().                                          *
 ****************************************************************************/
WORD           /* 0 if error, or 1.                                         */
Appl_do_exit(  /*                                                           */
WORD apid,     /* Application id.                                           */
WORD vid);     /* VDI workstation id.                                       */
/****************************************************************************/

/*system calls*/
void	Appl_init(AES_PB *apb);		/*0x000a*/
void	Appl_read(AES_PB *apb);		/*0x000b*/
void	Appl_write(AES_PB *apb);	/*0x000c*/

/****************************************************************************
 * Appl_find                                                                *
 *  0x000d appl_find().                                                     *
 ****************************************************************************/
void              /*                                                        */
Appl_find(        /*                                                        */
AES_PB *apb);     /* AES parameter block.                                   */
/****************************************************************************/

/****************************************************************************
 * Appl_search                                                              *
 *  0x0012 appl_search().                                                   *
 ****************************************************************************/
void              /*                                                        */
Appl_search(      /*                                                        */
AES_PB *apb);     /* AES parameter block.                                   */
/****************************************************************************/

void	Appl_exit(AES_PB *apb);		/*0x0013*/

/****************************************************************************
 * Appl_getinfo                                                             *
 *   0x0082 appl_getinfo().                                                 *
 ****************************************************************************/
void              /*                                                        */
Appl_getinfo(     /*                                                        */
AES_PB *apb);     /* AES parameter block.                                   */
/****************************************************************************/

#endif
