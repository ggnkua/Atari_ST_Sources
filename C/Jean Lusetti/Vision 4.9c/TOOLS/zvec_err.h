#ifndef __ZVEV_ERR_H
#define __ZVEV_ERR_H

/* error codes for all codecs, returned via imageinfo->thumbnail */
/* note: 2 to 9 are not used, we start at 10 */

/* if negative it's a standard gemdos error code */
/* if positive it's related the content of the file */


/* standard gemdos error codes, these are just here for my reference */
/* codecs return gemdos error codes where it makes sense */
#define	EC_Fwrite  -10 /* fwrite failed, size in/out didn't match, or negative error code */
#define	EC_Fread   -11 /* fread failed, size in/out didn't match, or negative error code */
#define	EC_Fopen   -33 /* fopen failed, image file not found */
#define	EC_Fcreate -36 /* fcreate failed */
#define	EC_Fclose  -37 /* fclose failed */
#define EC_Malloc  -39 /* malloc failed */
#define EC_Mfree   -40 /* mfree failed */
#define	EC_Fseek   -64 /* fseek failed, truncated file? */


/* error codes related to file content */
/* these will be used in multiple codecs and maybe new codecs in the future */
#define EC_CompType       10 /* header -> unsupported compression type */
#define	EC_DecompError    11 /* error during decompression phase */
#define EC_ResolutionType 12 /* header -> unsupported mode code neo/degas */
#define EC_ImageType      13 /* header -> unsupported image type */
#define	EC_PixelDepth     14 /* header -> unsupported pixel depth */
#define	EC_ColorMapDepth  15 /* header -> unsupported color map depth */
#define	EC_ColorMapType   16 /* header -> unsupported color map type */
#define	EC_FileLength     17 /* incorrect file length */
#define	EC_FileId         18 /* header -> unknown file identifier */
#define	EC_HeaderLength   19 /* header -> unsupported header length */
#define EC_WidthNegative  20 /* header -> image width < 0 */
#define	EC_HeightNegative 21 /* header -> image height < 0 */
#define	EC_InternalError  22 /* non-specific, subfunction failure: png/gif */
#define	EC_ColorSpace     23 /* header -> unsupported color space */
#define	EC_ColorMapLength 24 /* header -> unsupported color map length */
#define	EC_MaskType       25 /* header -> unsupported mask type */
#define	EC_ChunkId        26 /* unsupported chunk identifier: iff */
#define	EC_FileType       27 /* received wrong file type */
#define	EC_FrameCount     28 /* frame count exceeds limit */
#define	EC_ColorCount     29 /* header -> unsupported color count */
#define	EC_BitmapLength   30 /* header -> calc'd length doesn't match  */
#define	EC_HeaderVersion  31 /* header -> unsupported version */
#define	EC_HeightSmall    32 /* header -> unsupported height, to small: fnt */
#define	EC_CompLength     33 /* header -> incorrect compressed size: spx */
#define	EC_FrameType      34 /* header -> unsupported frame type: seq */
#define	EC_RequiresNVDI   35 /* NVDI not installed */
#define	EC_FuncNotDefined 36 /* function not implemented */

#define	EC_StructLength    37 /* incorrect structure length */
#define EC_RequiresJPD     38 /* JPEGD DSP decoder not installed */
#define	EC_OpenDriverJPD   39 /* JPEGD OpenDriver() failed */
#define	EC_GetImageInfoJPD 40 /* JPEGD GetImageInfo() failed */
#define	EC_GetImageSizeJPD 41 /* JPEGD GetImageSize() failed */
#define	EC_DecodeImageJPD	 42 /* JPEGD DecodeImage() failed */
#define EC_OrientationBad	 43 /* orientation unsupported */

/* new error codes will be added to the end of this list as needed */

/*
status=c:reader_init(path$,imageinfo)
if status=false								!file rejected?
  ' we let jpg/tiff pass through
  print @err_to_txt$(imageinfo->thumbnail)	!find out why
endif

function err_to_txt$(err_code)		!note jpg and tiff work the old way
  ' maybe format as alert strings, etc.
  local msg$
  select err_code
  case ec_fopen
    msg$="file not found"
  case ec_fread
    msg$="premature end of file"
  case ec_fclose
    msg$="disk full or locked"
  case ec_resolutiontype to ec_colormaptype
    msg$="unsuported image format"
  default		!end up here if not found (0 or 1, tiff and jpg)
    msg$="general failure"					!generic error msg
  endselect
  return msg$
endfunc
*/

#endif
