/*
 *	ME.LDG
 * Header file to include in your sources
 *
 * (c)2000 Arnaud BERCEGEAY <bercegeay@atari.org>
 *
 */

#ifndef __ME_LDG__
#define __ME_LDG__

#include <ldg.h>

typedef struct meinfos_struct
{
	char  filename[32];     /* file name of the RIM/WIM      */
	char  Header  [8] ;     /* 'READ_IMG' if it's a RIM      */
	                        /* 'WRIT_IMG' if it's a WIM      */
	char  Format  [4] ;     /* '_VDI' | '_SHI' | '_VSH'      */
	short Type ;            /* see PARX developer doc.       */
	char  Id      [8] ;     /* ID sur 8 caractäres           */
	short Version     ;     /* version in decimal format     */
	char  Description[31];  /* 30 caractäres + octet nul     */
	char  Configurable   ;  /* 1 s'il est configurable       */
} MEINFOS ;

typedef struct meimg_struct
{
	/********************** BEGIN of the MFDB-like structure ********/
	long  rsvd1;          /* reserved                               */
	short width;          /* width of the image in pixels           */
	short height;         /* height of the image in pixels          */
	short wdwidth;        /* width of the img in nb of words        */
	short stand;          /* standard used : 0 | 1                  */
	short nplanes;        /* nb planes for xxx_palette & xxx_img    */
	long  rsvd2;          /* reserved                               */
	short rsvd3;          /* reserved                               */
	/*********************** END of the MFDB-like structure *********/
	long  rsvd4;          /* reserved                               */
	long  rsvd5;          /* reserved                               */
	long  rsvd6;          /* reserved                               */
	long  handle;         /* VDI Handle needed for some trnfm...    */
	/*********************** Image & palette in the native format   */
	long   size_palette;  /* size of the palette in bytes           */
	char * buff_palette;  /* buffer for the palette                 */
	long   size_img;      /* size of the image in bytes             */
	char * buff_img;      /* buffer for the image                   */
	/*********************** Image converted in the 24 bits format  */
	long   size_R8V8B8;   /* size of image in the 24bits format     */
	char * buff_R8V8B8;   /* buffer for the image in the 24b fmt    */
	/*********************** Image & palette in the screen format   */	
	long   size_DDpalette;/* size of the "DD" palette in bytes      */
	char * buff_DDpalette;/* buffer for the "DD" palette            */
	long   size_DDimg;    /* size of the "DD" image in bytes        */
	char * buff_DDimg;    /* buffer for the "DD" image              */
	/*********************** Informations about the RIM/WIM used    */
	MEINFOS * meinfos;    /* info about the WIM/RIM used            */
} MEIMG;


typedef struct melist_struct
{
	long nb_elt;
	char *** list_description;
	MEINFOS * list_elt;
} MELIST;

typedef struct trmlist_struct
{
	long nb_elt;
	char *** list_description;
} TRMLIST;


/* parametres "mode" de RIM_LoadImg() */
#define ME_FMT_NATIF          0x0001L
#define ME_FMT_R8V8B8         0x0002L
#define ME_FMT_DIRECTDISPLAY  0x0004L
#define ME_RGB_TO_DISK        0x0100L

extern long    cdecl (*RIM_OpenImg)(MEIMG * meimg, char * filename, long mode);
extern long    cdecl (*RIM_CloseImg)(MEIMG * meimg);
extern long    cdecl (*RIM_LoadImg)(MEIMG * meimg, long mode, long no_algo, long vdi_handle, short * global);
extern MELIST* cdecl (*RIM_CreateNewList)( long mode );
extern void    cdecl (*RIM_DeleteList)( MELIST * melist );
extern long    cdecl (*RIM_DoConfig)( char * rim_filename );
extern MELIST* cdecl (*WIM_CreateNewList)( long mode );
extern void    cdecl (*WIM_DeleteList)( MELIST * melist );
extern long    cdecl (*WIM_DoConfig)( char * wim_filename );
extern TRMLIST* cdecl (*TRM_CreateNewList)( void );
extern void    cdecl (*TRM_DeleteList)( TRMLIST * trmlist );
extern void    cdecl (*ME_CompressPalette)( char * palette, long size);
extern void    cdecl (*ME_ExplainError)( short * global);
extern void    cdecl (*ME_Init)( short * global, long mode);

extern long init_ldg_me (LDG * ldg_me) ;
extern LDG *ldg_me;

#endif /* __ME_LDG__ */

/* EOF */
