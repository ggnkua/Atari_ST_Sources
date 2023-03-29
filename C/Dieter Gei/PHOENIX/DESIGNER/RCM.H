/*****************************************************************************/
/*                                                                           */
/* Modul: RCM.H                                                              */
/* Datum: 08/02/89                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __RCM__
#define __RCM__

/***************************************************************************/
/* RESOURCE CREATE MODUL for C files which are created by the              */
/* Resource Construction Set (Source file for resource switch on)          */
/*                                                                         */
/* SAMPLE CALL:                                                            */
/* rsc_create (gl_wbox, gl_hbox, NUM_TREE, NUM_OBS, NUM_FRSTR, NUM_FRIMG,  */
/*             rs_strings, rs_frstr, rs_bitblk, rs_frimg, rs_iconblk,      */
/*             rs_tedinfo, rs_object, rs_trindex, rs_imdope);              */
/*                                                                         */
/* by JÅrgen & Dieter Geiû                                                 */
/* last modification: 8-February-1991                                      */
/***************************************************************************/

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

typedef struct
{
  WORD dummy;
  WORD *image;
} RS_IMDOPE;  

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL VOID rsc_create _((WORD gl_wbox, WORD gl_hbox, WORD tree, WORD n_obs, WORD n_frstr, WORD n_frimg,
                          BYTE **rs_strings, LONG *rs_frstr, BITBLK *rs_bitblk,
                          LONG *rs_frimg, ICONBLK *rs_iconblk, TEDINFO *rs_tedinfo,
                          OBJECT *rs_object, OBJECT **rs_trindex, RS_IMDOPE *rs_imdope));

#endif /* __RCM__ */

