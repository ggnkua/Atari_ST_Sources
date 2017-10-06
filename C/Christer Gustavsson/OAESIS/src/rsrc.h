#ifndef	__RSRC__
#define	__RSRC__

#include	"types.h"

/****************************************************************************
 * Library routines                                                         *
 ****************************************************************************/

/****************************************************************************
 *  Rsrc_do_rcfix                                                           *
 *   Implementation of rsrc_rcfix().                                        *
 ****************************************************************************/
WORD              /* 0 if ok or != 0 if error.                              */
Rsrc_do_rcfix(    /*                                                        */
WORD   vid,       /* VDI workstation id.                                    */
RSHDR  *rshdr);   /* Resource structure to fix.                             */
/****************************************************************************/

/****************************************************************************
 *  Rsrc_duplicate                                                          *
 *   Create copy of resource tree. When the copy isn't needed anymore it    *
 *   should be freed using Rsrc_free_tree().                                *
 ****************************************************************************/
OBJECT *          /* New resource tree, or NULL.                            */
Rsrc_duplicate(   /*                                                        */
OBJECT *src);     /* Original resource tree.                                */
/****************************************************************************/

/****************************************************************************
 *  Rsrc_free_tree                                                          *
 *   Erase resource tree created with Rsrc_duplicate.                       *
 ****************************************************************************/
void              /*                                                        */
Rsrc_free_tree(   /*                                                        */
OBJECT *src);     /* Tree to erase.                                         */
/****************************************************************************/

/****************************************************************************
 *  Rsrc_do_gaddr                                                           *
 *   Implementation of rsrc_gaddr().                                        *
 ****************************************************************************/
WORD              /* 0 if ok or != 0 if error.                              */
Rsrc_do_gaddr(    /*                                                        */
RSHDR  *rshdr,    /* Resource structure to search.                          */
WORD   type,      /* Type of object.                                        */
WORD   index,     /* Index of object.                                       */
OBJECT **addr);   /* Object address.                                        */
/****************************************************************************/

/****************************************************************************
 * System calls                                                             *
 ****************************************************************************/

void	Rsrc_load(AES_PB *apb);		/*0x006e*/
void	Rsrc_free(AES_PB *apb);		/*0x006f*/
void	Rsrc_gaddr(AES_PB *apb);	/*0x0070*/
void	Rsrc_saddr(AES_PB *apb);	/*0x0071*/
void	Rsrc_obfix(AES_PB *apb);	/*0x0072*/
void	Rsrc_rcfix(AES_PB *apb);	/*0x0073*/

#endif
