/*****************************************************************************
 *
 * Module : MASKUTIL.H
 * Author : JÅrgen Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 19.03.97
 *
 *
 * Description: This module defines the mask utility functions.
 *
 * History:
 * 19.03.97: Parameter act_obj aded to mu_grafimp
 * 13.03.97: Parameter pFilename added to graf & text im/export
 * 27.01.95: Parameter window changed to mask_spec in all interface functions
 * 23.01.95: Parameter bGetFirstRec added in mu_crt_spec
 * 05.01.95: Function mu_sm_init moved to mclick.h
 * 12.10.94: Function mu_sm_init added
 * 11.10.94: Function mu_crt_spec added, x, y added in mu_ed_init
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __MASKUTIL__
#define __MASKUTIL__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL VOID      mu_init      (VOID);
GLOBAL WORD      mu_load      (MASK_SPEC *mask_spec, BYTE device, BYTE *name);
GLOBAL VOID      mu_free      (MASK_SPEC *mask_spec, BOOLEAN free_spec);
GLOBAL MASK_SPEC *mu_crt_spec (WINDOWP window, MASK_SPEC *pParentSpec, DB *db, WORD table, WORD inx, WORD dir, BYTE *maskname, KEY keyval, LONG address, VOID *db_buffer, BOOL bCalcEntry, WORD x, WORD y, BOOLEAN bGetFirstRec);
GLOBAL VOID      mu_change    (MASK_SPEC *mask_spec, BYTE *mask_name);
GLOBAL VOID      mu_join      (MASK_SPEC *mask_spec);
GLOBAL WORD      mu_ed_init   (MASK_SPEC *mask_spec, WORD x, WORD y);
GLOBAL VOID      mu_get_graf  (MASK_SPEC *mask_spec);

GLOBAL VOID      mu_sel_ext   (MASK_SPEC *mask_spec);
GLOBAL VOID      mu_grafimp   (MASK_SPEC *mask_spec, BYTE *pFilename, WORD act_obj);
GLOBAL VOID      mu_grafexp   (MASK_SPEC *mask_spec, BYTE *pFilename);
GLOBAL VOID      mu_blobimp   (MASK_SPEC *mask_spec);
GLOBAL VOID      mu_blobexp   (MASK_SPEC *mask_spec);
GLOBAL VOID      mu_textimp   (MASK_SPEC *mask_spec, BYTE *pFilename, WORD act_obj);
GLOBAL VOID      mu_textexp   (MASK_SPEC *mask_spec, BYTE *pFilename);

#endif /* __MASKUTIL__ */

