#ifndef	__FSEL__
#define	__FSEL__

/****************************************************************************
 * Fsel_do_exinput                                                          *
 *  Implementation of fsel_exinput()                                        *
 ****************************************************************************/
WORD                /* 1 if OK, 0 if CANCEL.                                */
Fsel_do_exinput(    /*                                                      */
WORD apid,          /* Application id.                                      */
WORD vid,           /* VDI workstation id.                                  */
WORD eventpipe,     /* Event message pipe.                                  */
WORD *button,       /* Pressed button.                                      */
BYTE *description,  /* Description.                                         */
BYTE *path,         /* Path buffer.                                         */
BYTE *file);        /* File name buffer.                                    */
/****************************************************************************/

/****************************************************************************
 * Fsel_input                                                               *
 *  0x005a fsel_input()                                                     *
 ****************************************************************************/
void              /*                                                        */
Fsel_input(       /*                                                        */
AES_PB *apb);     /* AES parameter block.                                   */
/****************************************************************************/

/****************************************************************************
 * Fsel_exinput                                                             *
 *  0x005b fsel_exinput()                                                   *
 ****************************************************************************/
void              /*                                                        */
Fsel_exinput(     /*                                                        */
AES_PB *apb);     /* AES parameter block.                                   */
/****************************************************************************/

#endif
