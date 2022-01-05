#ifndef __LDV_H
#define __LDV_H

#ifndef __LDG__
#include "ldv\ldg.h"
#endif

#ifndef __VAPI_H
#include "ldv\vapi.h"
#endif

/* Error codes */
typedef long LDV_STATUS ;
#define ELDV_NOERROR              0x0 /* No error                               */
#define ELDV_INVALIDPARAMETER     0x1 /* At least one parameter is invalid      */
#define ELDV_NBPLANESNOTSUPPORTED 0x2 /* Unsupported number of planes           */
#define ELDV_NOTENOUGHMEMORY      0x3 /* Not enough memory                      */
#define ELDV_PREVIEWNOTSUPPORTED  0x4 /* Preview is not supported               */
#define ELDV_RUNNOTSUPPORTED      0x5 /* Run is not supported (!)               */
#define ELDV_BADVAPIVERSION       0x6 /* No VAPI or wrong version               */
#define ELDV_IMGFORMATMISMATCH    0x7 /* Image format is not compatible         */
#define ELDV_CANCELLED            0x8 /* User cancelled the operation           */
#define ELDV_BADINTERFACE         0x9 /* LDV does not expose a proper interface */
#define ELDV_GENERALFAILURE       0xF /* General failure, reason unknown        */


/* Macro aiming to test if a */
/* LDV call was successful   */
#define LDV_SUCCESS(x)  ((x) == ELDV_NOERROR)


/* LDV types */
#define TLDV_MODIFYIMG 0x01     /* Modify image : filter, scaler, ... */

/* Flags field bitmask for  */
/* A given number of planes */
#define LDVF_STDFORMAT       0x00000001UL /* Image is standard format                                                 */
#define LDVF_ATARIFORMAT     0x00000002UL /* Image is ATARI format (Falcon)                                           */
#define LDVF_SPECFORMAT      0x00000004UL /* Image is specific format (video card/emulator))                          */
#define LDVF_SUPPORTPREVIEW  0x00000008UL /* Preview is supported                                                     */
#define LDVF_AFFECTPALETTE   0x00000010UL /* Module changes palette (if NbPlanes <= 8)                                */
#define LDVF_SUPPORTPROG     0x00000020UL /* Module wil call progress fonction                                        */
#define LDVF_OPINPLACE       0x00000040UL /* Module operate inplace and changes the source (out parameter is ignored) */
#define LDVF_REALTIMEPARAMS  0x00000080UL /* Module supports real time parameter changes in preview mode              */
#define LDVF_SUPPORTCANCEL   0x00000100UL /* Module supports user cancellation (see PrSetProgEx)                      */
#define LDVF_NOSELECTION     0x00000200UL /* Module can only operate on full image, not sub block                     */
#define LDVF_NOCHANGE        0x00000400UL /* Module won't change any part of the image (e.g. report LDV)              */

/* This struct reports what a LDV   */
/* Can do for each number of planes */
typedef struct
{
  char NbPlanes ;      /* Image number of planes :  */
                       /* 0 : ends this structure   */
                       /* 1, 2, 4, 8, 16, 24, or 32 */

  char NbPlanesOut ;   /* Number of planes after modification */

  unsigned long Flags ; /* LDVF_...                           */
}
LDV_CAPS ;


#define LDVNBMAX_PARAMETERS 4 /* Maximum 4 parameters can be passed by VISION */

typedef union
{
  short s ;
  float f ;
  void* str ;
}
LDV_BASICPARAM ;

#define LDVT_SHORT 1
#define LDVT_FLOAT 2
#define LDVT_FILE  3
typedef struct
{
  char           Name[1+15] ;
  char           Type ;
  LDV_BASICPARAM MinValue ;
  LDV_BASICPARAM DefaultValue ;
  LDV_BASICPARAM MaxValue ;
}
LDV_DEF_PARAM ;

typedef struct
{
  short StrSize ;           /* Size in bytes of LDV_INFOS */
  short Type ;              /* TLDV_...                   */
  char  Authors[1+45] ;     /* Author(s) list             */

  LDV_CAPS Caps[10] ;      /* What this LDV can do        */
                           /* For each number of planes   */
                           /* Last element is zeroed to   */
                           /* Mark the end                */
  char RFU[16] ;           /* Futur usage                 */
}
LDV_INFOS ;

typedef struct
{
  short Red ;   /* 0...1000 */
  short Green ; /* 0...1000 */
  short Blue ;  /* 0...1000 */
}
VDI_ELEMENTPAL ;

typedef struct
{
  short           NbColors ; /* Number of colors for this palette */
  VDI_ELEMENTPAL* Pal ;      /* Indexed from VDI                  */
}
LDV_PALETTE ;

typedef struct
{
  short          x1, y1, x2, y2 ; /* Rectangle defining the sub block to work on */
  short          NbParams ;
  LDV_BASICPARAM Param[LDVNBMAX_PARAMETERS] ;
  short          ParamType[LDVNBMAX_PARAMETERS] ; /* A bit redundant but useful to free allocated memory for file name */

  /* Since VAPI_LDVVERSION 0x0106                    */
  /* LDV can return a text to be displayed by VISION */
  char ldv_txt_out[128] ;
}
LDV_PARAMS ;

/* Image definition for the LDV to operate on */
typedef struct
{
  short       RasterFormat ; /* LDVF_STDFORMAT, LDVF_ATARIFORMAT or LDVF_SPECFORMAT */
                             /* VISION selects the optimal format from              */
                             /* LDV capabilities reported via GetLDVCapabilities    */

  MFDB        Raster ;       /* Image                                               */

  LDV_PALETTE Palette ;      /* Valid if Raster.fd_nplanes <= 8                     */

  void*       Context ;      /* Used by Image I/O interface                         */
}
LDV_IMAGE ;


long cdecl ImGetInf(char* filename, void* ldv_img) ;
long cdecl ImLoad(void* ldv_img) ;
void cdecl ImFree(void* ldv_img) ;


#endif
