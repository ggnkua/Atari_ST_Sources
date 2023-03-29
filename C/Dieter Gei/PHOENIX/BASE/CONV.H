/*****************************************************************************
 *
 * Module : CONV.H
 * Author : Dieter Geiﬂ
 *
 * Creation date    : 06.03.89
 * Last modification: 14.11.92
 *
 *
 * Description: This module defines the convert routines.
 *
 * History:
 * 14.11.92: Function build_pass moved to kernel
 * 01.11.92: CMP_FUNC and SIZE_FUNC are CALLBACK rather than WINAPI
 * 31.10.92: Far pointer definitions for DLL implementation added
 * 25.10.92: Module header added
 * 06.03.89: Creation of body
 *****************************************************************************/

#ifndef _CONV_H
#define _CONV_H

#ifdef __cplusplus
extern "C" {
#endif

/****** DEFINES **************************************************************/

#define TYPE_CHAR           0           /* variable character stream for text */
#define TYPE_WORD           1           /* 16 bit word */
#define TYPE_LONG           2           /* 32 bit long word */
#define TYPE_FLOAT          3           /* stored as double */
#define TYPE_CFLOAT         4           /* stored as char */
#define TYPE_DATE           5           /* date of year */
#define TYPE_TIME           6           /* time of day */
#define TYPE_TIMESTAMP      7           /* date & time */
#define TYPE_VARBYTE        8           /* variable byte stream */
#define TYPE_VARWORD        9           /* variable word stream */
#define TYPE_VARLONG       10           /* variable long stream */
#define TYPE_PICTURE       11           /* GEM and/or other pictures */
#define TYPE_EXTERN        12           /* extern file */
#define TYPE_DBADDRESS     13           /* unique address of record */
#define TYPE_BLOB          14           /* variable BLOB */

/* picture types */

#define PIC_META            1           /* metafile format */
#define PIC_IMAGE           2           /* bit image file format */
#define PIC_IFF             3           /* interchange file format */
#define PIC_TIFF            4           /* tag interchange file format */

#define NUM_TYPES          20           /* reserved number of different types */

#define USE_WILDCARD       0x8000       /* wildcard specifier for string match */

#define VARLEN(type)    ((type == TYPE_CHAR) || (type == TYPE_CFLOAT) || (type == TYPE_EXTERN))
#define VARBYTES(type)  ((type == TYPE_CHAR) || (type == TYPE_CFLOAT) || (type == TYPE_VARBYTE) || (type == TYPE_VARWORD) || (type == TYPE_VARLONG) || (type == TYPE_PICTURE) || (type == TYPE_EXTERN))
#define HASWILD(type)   ((type == TYPE_CHAR) || (type == TYPE_EXTERN))
#define PRINTABLE(type) ((type != TYPE_VARBYTE) && (type != TYPE_VARWORD) && (type != TYPE_VARLONG) && (type != TYPE_PICTURE) && (type <= TYPE_DBADDRESS))

#define MAX_FORMATSTR      41           /* max chars of a format string */

#define FORM_DAY           "DD"         /* format for day */
#define FORM_MONTH_LONG    "MONTH"      /* format for month as long id */
#define FORM_MONTH_SHORT   "MON"        /* format for month as short id */
#define FORM_MONTH_NUM     "MM"         /* format for month as number */
#define FORM_YEAR_LONG     "YYYY"       /* format for year with century */
#define FORM_YEAR_SHORT    "YY"         /* format for year without century */

#define FORM_HOUR_24       "HH"         /* format for hour (0 - 24) */
#define FORM_HOUR_AM       "AM"         /* format for hour (1 - 12) */
#define FORM_HOUR_PM       "PM"         /* format for hour (1 - 12) */
#define FORM_HOUR_am       "am"         /* format for hour (1 - 12) */
#define FORM_HOUR_pm       "pm"         /* format for hour (1 - 12) */
#define FORM_MINUTE        "MI"         /* format for minute */
#define FORM_SECOND        "SS"         /* format for second */
#define FORM_MICROSECOND   "m"          /* format for microsecond (max 6) */

#define FORM_NUM_BLANK     "9"          /* format for leading blanks */
#define FORM_NUM_NULL      "0"          /* format for leading zeros */
#define FORM_NUM_ASTERISK  "*"          /* format for leading '*' */

#define FORM_CHAR_ANY      "X"          /* format for any character */
#define FORM_CHAR_UPPER    "A"          /* format for upper case chars */
#define FORM_CHAR_LOWER    "a"          /* format for lower case chars */

#define ID_NOCHAR          0            /* no char */
#define ID_ACHAR           1            /* a single char */
#define ID_DAY             2            /* day id */
#define ID_MONTH_LONG      3            /* long month id */
#define ID_MONTH_SHORT     4            /* short month id */
#define ID_MONTH_NUM       5            /* num month id */
#define ID_YEAR_LONG       6            /* long year id */
#define ID_YEAR_SHORT      7            /* short year id */
#define ID_HOUR_24         8            /* hour id (24 hours format) */
#define ID_HOUR_AM         9            /* hour id (12 hours format) */
#define ID_HOUR_PM        10            /* hour id (12 hours format) */
#define ID_HOUR_am        11            /* hour id (12 hours format) */
#define ID_HOUR_pm        12            /* hour id (12 hours format) */
#define ID_MINUTE         13            /* minute id */
#define ID_SECOND         14            /* second id */
#define ID_MICROSECOND    15            /* microsecond id */
#define ID_NUM_BLANK      16            /* number as blank id */
#define ID_NUM_NULL       17            /* number as zero id */
#define ID_NUM_ASTERISK   18            /* number as asterisk */
#define ID_CHAR_ANY       19            /* any char id */
#define ID_CHAR_UPPER     20            /* upper case char id */
#define ID_CHAR_LOWER     21            /* lower case char id */

#define OVERFLOW_CHAR     '#'           /* character to show overflow */

#define MAX_BLOBEXT        3            /* max blob exension */
#define MAX_BLOBNAME      63            /* max blob name */

/****** TYPES ****************************************************************/

typedef SHORT (CALLBACK *CMP_FUNC)  _((HPVOID elt1, HPVOID elt2));
typedef LONG  (CALLBACK *SIZE_FUNC) _((HPVOID elt));

typedef struct
{
  CHAR  letter;                         /* the letter itself */
  UCHAR id;                             /* id number */
} FORM;

typedef FORM FAR *LPFORM;               /* pointer to format element */

typedef FORM FORMAT [MAX_FORMATSTR + 1]; /* one format string */
typedef FORMAT FAR *LPFORMAT;            /* pointer to format string */

typedef CHAR BLOBEXT [MAX_BLOBEXT + 1];  /* extension of blob */
typedef CHAR BLOBNAME [MAX_BLOBNAME + 1]; /* name of blob */

typedef struct
{
  LONG     address;                      /* address of blob */
  LONG     size;                         /* actual size of blob for dynamic allocation */
  BLOBEXT  ext;                          /* file extension of blob */
  BLOBNAME name;                         /* name of blob */
} BLOB;

typedef BLOB HUGE *HPBLOB;               /* huge blob pointer */

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL VOID  WINAPI init_conv    _((LPSTR FAR *short_month, LPSTR FAR *long_month, INT dec_sep, INT thsnd_sep));
GLOBAL LONG  WINAPI typesize     _((SHORT type, HPVOID elt));
GLOBAL SHORT WINAPI keysize      _((SHORT type, HPVOID elt));
GLOBAL SHORT WINAPI cmp_vals     _((SHORT type, HPVOID elt1, HPVOID elt2));
GLOBAL BOOL  WINAPI set_type     _((SHORT type, CMP_FUNC cmp_func, SIZE_FUNC size_func));
GLOBAL BOOL  WINAPI str_type     _((SHORT type, LPSTR name));
GLOBAL BOOL  WINAPI str2bin      _((SHORT type, HPCHAR src, HPVOID dst));
GLOBAL BOOL  WINAPI bin2str      _((SHORT type, HPVOID src, HPCHAR dst));
GLOBAL VOID  WINAPI str2format   _((SHORT type, LPSTR strval, LPFORM format));
GLOBAL BOOL  WINAPI format2str   _((SHORT type, LPSTR strval, LPFORM format));
GLOBAL VOID  WINAPI build_format _((SHORT type, LPSTR formatstr, LPFORM format));
GLOBAL VOID  WINAPI set_null     _((SHORT type, HPVOID dst));
GLOBAL VOID  WINAPI set_default  _((SHORT type, HPVOID dst));
GLOBAL BOOL  WINAPI is_null      _((SHORT type, HPVOID src));
GLOBAL VOID  WINAPI build_str    _((SHORT type, INT len, HPVOID src, HPCHAR dst));

#ifdef __cplusplus
}
#endif

#endif /* _CONV_H */

