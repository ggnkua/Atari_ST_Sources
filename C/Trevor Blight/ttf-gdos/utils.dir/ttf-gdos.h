/************ (c) 1995-1997, Trevor Blight *********
*
*  $Id: ttf-gdos.h 1.9 1999/11/28 00:05:56 tbb Exp $
*  
*  definitions for ttf-gdos
*  
****************************************************/

#define MAGIC_NR  0x3e5d0957L

typedef short int16;  /* 16 bits */
typedef long int32;   /* 32 bits */
typedef char int8;    /* 8 bits */
typedef unsigned short uint16;  /* 16 bits */
typedef unsigned long uint32;   /* 32 bits */
typedef unsigned char uint8;    /* 8 bits */

typedef unsigned char uchar;    /* character type */
typedef unsigned char BYTE;

typedef char FILE_NAME[sizeof("12345678.123") + 1 /* ie null */];

typedef enum { DYNAMIC, RESIDENT, PERMANENT } DRV_LOAD_SPEC;

typedef struct {
        FILE_NAME driver_name;
        DRV_LOAD_SPEC load_type;
        uint16 id;
	uint16 nr_gemfonts;
	uint16 first_font;
        } WORKSTN_RECORD;

typedef struct {
        FILE_NAME font_name;
        uint16 id;
        uint32 psize_mask;        /* point sizes */
        } FONT_RECORD;

#define MY_VERSION 20

typedef struct {
   uint32 magic_nr;
   uint8  version;
   uint8  len_gem_path;
   uint16 file_len; 
   uint16 cache_size;
   uint16 reserved;
   uint16 nr_gemfonts;
   uint8  nr_ttfonts;
   uint8  nr_wkstns;
   WORKSTN_RECORD workstn_table[0];
   } TTF_GDOS_INF_RECORD;

#define INF_FILE "ttf-gdos.inf"
#define INF_FILE_MAX_LEN 0x7fffffff

   /*** ttf-gdos.inf has format ***
   *
   *  0  magic nr                    = 0x3e5d0957L
   *  4  struct version number	     = MY_VERSION
   *  5  length of GEMPATH string    <= 255
   *  6  length of file, error code
   *  8  cache size (kB)
   * 10  reserved
   * 12  nr gem fonts       (=j)
   * 14  nr true type fonts (=i)
   * 15  nr devices         (=n)
   * 16  n * device records
   *     i * true type font records
   *     j * gem font records
   *     gem pathname, with trailing '\'
   *     title string, null terminated
   *****/

/******************* end of ttf-gdos.h ********************/
