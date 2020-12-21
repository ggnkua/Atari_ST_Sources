#ifndef __VAPI_H
#define __VAPI_H

#ifndef __VDI__
#include <vdi.h>
#endif

#ifndef ARRAY_SIZE
#define ARRAY_SIZE(v)  sizeof(v)/sizeof((v)[0])
#endif

typedef struct
{
  unsigned short Version ; /* 0x0100 for example */
  unsigned short StrSize ;

  void  *Global ;              /* Global VISION array for AES, useful with MT_AES */

  void cdecl (*GEMMessageLoop)(void *msg) ; /* Call this if your LDV uses AES and */
                                            /* you want VISION to handle some AES */
                                            /* messages (redraws for examples)    */
  char RFU[116] ;
}
VAPI_HEADER ;

/* For RaTCxxRemapColors */
#ifndef __RASTEROP_H         /* Dont worry, it's for VISION's compile */
typedef struct
{
  unsigned char* red ;
  unsigned char* green ;
  unsigned char* blue ;
  void*          pt_img ;
  long           nb_pts ;
}
REMAP_COLORS ;

/* Log levels for LoDoLog */
/* Make sure they are in sync with logging.h */
#define BIT(x)      (1L << (x))
/* Bit#        24       16        8        0          */
/*      |--------|--------|--------|--------|         */
/*      |          | |  |  |  |  |||||| ||----TMP1    */
/*      |          | |  |  |  |  |||||| |-----TMP2    */
/*      |          | |  |  |  |  ||||||-------KEYCODE */
/*      |          | |  |  |  |  |||||--------DEBUG   */
/*      |          | |  |  |  |  ||||---------GW1     */
/*      |          | |  |  |  |  |||----------GW2     */
/*      |          | |  |  |  |  ||-----------MEM     */
/*      |          | |  |  |  |  |------------IMG     */
/*      |          | |  |  |  |---------------PERF    */
/*      |          | |  |  |------------------INFO    */
/*      |          | |  |---------------------WARNING */
/*      |          | |------------------------ERROR   */
/*      |          |--------------------------FATAL   */
/* Bit#           22   17    12   8   5  2            */
/* Bit#             20   15             3  0          */
/*                                                    */
#define LL_DISABLED 0x0
#define LL_FATAL    BIT(22)
#define LL_ERROR    BIT(20)
#define LL_WARNING  BIT(17)
#define LL_INFO     BIT(15)
#define LL_PERF     BIT(12)
#define LL_IMG      BIT(9)
#define LL_MEM      BIT(8)
#define LL_GW2      BIT(7)
#define LL_GW1      BIT(6)
#define LL_DEBUG    BIT(5)
#define LL_KEYCODE  BIT(4)
#define LL_TMP2     BIT(3)
#define LL_TMP1     BIT(2)


#define LF_CLRLOGSONSTART  0x0001
/* Little macro that increases a number to its first multiple of 16 */
#define ALIGN16(x) ( ((x) & 0x0F) ? ((16+(x)) & 0xFFF0) : (x) ) 

#endif

/* For CoGetProcessors */
#define CO_HAS_030 0x02
#define CO_HAS_FPU 0x20
#define CO_HAS_DSP 0x200

/* For CoGetScreenInfo */
typedef struct
{
  short Width ;
  short Height ;
  short NPlanes ;
  short UseStdVDI ;
  short RFU[120] ;
}
SCREEN_INFO ;

/* From image_io.h, make sure */
/* Same definition is shared  */
#ifndef HISTO_SIZE
#define HISTO_SIZE 256
typedef struct _HISTO
{
  unsigned long red[HISTO_SIZE] ;
  unsigned long green[HISTO_SIZE] ;
  unsigned long blue[HISTO_SIZE] ;
  unsigned long grey[HISTO_SIZE] ;
  unsigned long index[HISTO_SIZE] ;
  unsigned long nb_colors ;
  unsigned long norm ;            /* Must be set by caller */
  unsigned long nb_colors_used ;
}
HISTO, *PHISTO ;
#endif

#ifndef __INI_H
typedef void* HINI ;
#endif

typedef struct
{
  VAPI_HEADER Header ;

  /* Progress Interface */
  void cdecl (*PrSetProg)(long pc) ;
  void cdecl (*PrOptimize)(long mask) ;
  void cdecl (*PrSetText)(long no_line, char *text) ;
  long cdecl (*PrSetProgEx)(long pc) ;
  long cdecl (*PrSetProgRange)(long current, long max) ;
  long       PrRFU[7] ;

  /* Raster Interface */
  void           cdecl (*RaImgWhite)(MFDB *img) ;
  void           cdecl (*RaTCConvert)(MFDB *img) ;
  void           cdecl (*RaTCInvConvert)(MFDB *img) ;
  void           cdecl (*RaInd2RasterInit)(MFDB *out, long width) ;
  void           cdecl (*RaInd2Raster)(unsigned char *indexes, long nb_indexes) ;
  void           cdecl (*RaRaster2Ind)(short *pt_raster, long nb_pts, long nplans, unsigned char *out) ;
  unsigned char* cdecl (*RaGetTOS2VDIArray)(long nplanes) ;
  unsigned char* cdecl (*RaGetVDI2TOSArray)(long nplanes) ;
  long           cdecl (*RaIs15Bits)(void) ;
  unsigned long  cdecl (*RaGetImgSize)(long width, long height, long nplanes) ;
  long           cdecl (*RaRasterAlloc)(MFDB *raster) ;
  void           cdecl (*RaRasterFree)(MFDB *raster) ;
  void           cdecl (*RaTC15RemapColors)(REMAP_COLORS *rc) ;
  void           cdecl (*RaTC16RemapColors)(REMAP_COLORS *rc) ;
  void           cdecl (*RaTC32RemapColors)(REMAP_COLORS *rc) ;
  void           cdecl (*RaRasterRotateGetDstMFDB)(MFDB *in, MFDB *out, long angle) ;
  long           cdecl (*RaRasterRotate)(MFDB *in, MFDB *out, long angle, long flags) ;
  long           RaRFU[42] ;

  /* Config Interface */
  char*         cdecl (*CoGetLDVPath)(void) ;
  char*         cdecl (*CoGetCurrentLanguage)(void) ;
  unsigned long cdecl (*CoGetFunctionOptimizations)(void* function) ;
  unsigned long cdecl (*CoGetProcessors)(void) ;
  void          cdecl (*CoGetScreenInfo)(SCREEN_INFO* sinfo) ;
  long                CoRFU[17] ;

  /* INI Interface */
  long cdecl (*InOpen)(char *file) ;
  long cdecl (*InClose)(HINI h_ini) ;
  long cdecl (*InSaveAndClose)(HINI h_ini, char *new_name) ;
  long cdecl (*InGetKey)(HINI h_ini, char *section, char *key, char *val_key) ;
  long cdecl (*InSetKey)(HINI h_ini, char *section, char *key, char *val_key) ;
  long cdecl (*InGetOrSetKey)(HINI h_ini, char *section, char *key, char *val_default_key) ;
  long cdecl (*InGetKeyFromFile)(char *file, char *section, char *key, char *val_key) ;
  long       InRFU[19] ;

  /* MEM Interface */
  void  cdecl (*MeSCopyMemory8)(void *dst, void *src, unsigned long nb_elems_dst, unsigned long nb_elems_src) ;
  void  cdecl (*MeSCopyMemory16)(void *dst, void *src, unsigned long nb_elems_dst, unsigned long nb_elems_src) ;
  void  cdecl (*MeSCopyMemory32)(void *dst, void *src, unsigned long nb_elems_dst, unsigned long nb_elems_src) ;
  void* cdecl (*MeXalloc)(unsigned long size) ;
  void* cdecl (*MeXrealloc)(void* ptr, unsigned long size) ;
  void  cdecl (*MeXfree)(void* ptr) ;
  void* cdecl (*MeXcalloc)(unsigned long nb_elems, unsigned long elem_size) ;
  char* cdecl (*MeXstrdup)(char* s) ;
  long        MeRFU[25] ;

  /* Logging Interface */
  long          cdecl (*LoDoLog)(unsigned long level, char* format, ...) ;
  unsigned long cdecl (*LoGetLogLevel)(void) ;
  long                LoRFU[8] ;

  /* Image I/O interface */
  /* ldv_img must point to a LDV_IMG structure */
  long cdecl (*ImGetInf)(char* filename, void* ldv_img) ;
  long cdecl (*ImLoad)(void* ldv_img) ;
  void cdecl (*ImFree)(void* ldv_img) ;
  long cdecl (*ImSave)(char* filename, void* ldv_img, char* save_options) ;
  /* 0: auto, 1: matrixmono, 2: grey level, 3: 216 colors, 4: dual-tone */
  long cdecl (*ImDither)(long method, long param, void* ldv_img_in, void* ldv_img_out) ;
  long cdecl (*ImGetStdData)(void* ldv_img, char* query, char* out_data, long out_data_size) ;
  long cdecl (*ImComputeHistogram)(void* ldv_img, HISTO *histo) ;  /* histo->norm must be set by caller */
  long       ImRFU[9] ;

  /* File Interface */
  long cdecl (*FiFileExist)(char* file) ;
  long cdecl (*FiFolderExist)(char* folder) ;
  long cdecl (*FiCopyFile)(char* src, char* dst) ;
  long cdecl (*FiCopyFileR)(char* src, char* dst) ;
  long cdecl (*FiMoveFile)(char* src, char* dst) ;
  long cdecl (*FiCreateFolder)(char* path) ;
  long cdecl (*FiCmpFiles)(char* f1, char* f2) ;
  long       FiRFU[9] ;

  /* More interfaces to come ! */
}
VAPI ;

#define LDVPROG_CANCEL(status) (status == 1)

#endif
