#ifndef __VAPI
#define __VAPI

#ifndef __VDI__
#include <vdi.h>
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
#ifndef __RASTEROP         /* Dont worry, it's for VISION's compile */
typedef struct
{
  unsigned char *red ;
  unsigned char *green ;
  unsigned char *blue ;
  void          *pt_img ;
  long          nb_pts ;
}
REMAP_COLORS ;

/* Log levels for LoDoLog */
/* Make sure they are in sync with logging.h */
#define BIT(x)      (1L << (x))
/* Bit#        24       16        8        0           */
/*      |--------|--------|--------|--------|          */
/*      |          | |  |  |  |   ||||| ||-----TMP1    */
/*      |          | |  |  |  |   ||||| |------TMP2    */
/*      |          | |  |  |  |   |||||--------KEYCODE */
/*      |          | |  |  |  |   ||||---------DEBUG   */
/*      |          | |  |  |  |   |||----------GW1     */
/*      |          | |  |  |  |   ||-----------GW2     */
/*      |          | |  |  |  |   |-----------MEM      */
/*      |          | |  |  |  |---------------PERF     */
/*      |          | |  |  |------------------INFO     */
/*      |          | |  |---------------------WARNING  */
/*      |          | |------------------------ERROR    */
/*      |          |--------------------------FATAL    */
/* Bit#           22   17    12   8   5  2             */
/* Bit#             20   15             3  0           */
/*                                                     */
#define LL_DISABLED 0x0
#define LL_FATAL    BIT(22)
#define LL_ERROR    BIT(20)
#define LL_WARNING  BIT(17)
#define LL_INFO     BIT(15)
#define LL_PERF     BIT(12)
#define LL_MEM      BIT(8)
#define LL_GW2      BIT(7)
#define LL_GW1      BIT(6)
#define LL_DEBUG    BIT(5)
#define LL_KEYCODE  BIT(4)
#define LL_TMP2     BIT(3)
#define LL_TMP1     BIT(2)

#define LF_CLRLOGSONSTART  0x0001
/* Little macro that increases a number to its first multiple of 16 */
#define ALIGN16(x) ( (x) & 0x0F ? (16+(x) & 0xFFF0) : (x) ) 

#endif

/* For CoGetProcessors */
#define CO_HAS_030 0x02
#define CO_HAS_FPU 0x20
#define CO_HAS_DSP 0x200

typedef struct
{
  VAPI_HEADER Header ;

  /* Progress Interface */
  void cdecl (*PrSetProg)(long pc) ;
  void cdecl (*PrOptimize)(long mask) ;
  void cdecl (*PrSetText)(long no_line, char *text) ;
  long cdecl (*PrSetProgEx)(long pc) ;
  long       PrRFU[8] ;

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
  unsigned long cdecl (*CoGetFunctionOptimizations)(void *function) ;
  unsigned long cdecl (*CoGetProcessors)(void) ;
  long                CoRFU[18] ;

  /* INI Interface */
  long cdecl (*InOpen)(char *file) ;
  long cdecl (*InClose)(long hini) ;
  long cdecl (*InSaveAndClose)(long h_ini, char *new_name) ;
  long cdecl (*InGetKey)(long hini, char *section, char *key, char *val_key) ;
  long cdecl (*InSetKey)(long hini, char *section, char *key, char *val_key) ;
  long cdecl (*InGetOrSetKey)(long h_ini, char *section, char *key, char *val_default_key) ;
  long cdecl (*InGetKeyFromFile)(char *file, char *section, char *key, char *val_key) ;
  long       InRFU[19] ;

  /* MEM Interface */
  void cdecl (*MeSCopyMemory8)(void *dst, void *src, unsigned long nb_elems_dst, unsigned long nb_elems_src) ;
  void cdecl (*MeSCopyMemory16)(void *dst, void *src, unsigned long nb_elems_dst, unsigned long nb_elems_src) ;
  void cdecl (*MeSCopyMemory32)(void *dst, void *src, unsigned long nb_elems_dst, unsigned long nb_elems_src) ;
  long       MeRFU[30] ;

  /* Logging Interface */
  long          cdecl (*LoDoLog)(unsigned long level, char* format, ...) ;
  unsigned long cdecl (*LoGetLogLevel)(void) ;
  long                LoRFU[8] ;

  /* More interfaces to come ! */
}
VAPI ;

#endif
