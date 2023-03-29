/*****************************************************************************
 *
 * Module : GEMOBJ.H
 * Author : JÅrgen Geiû
 *
 * Creation date    : 24.11.90
 * Last modification: 10.03.97
 *
 *
 * Description: This module defines the metafile object.
 *
 * History:
 * 10.03.97: GEM_UPDATE added
 * 24.11.90: Creation of body
 *****************************************************************************/

#ifndef __GEMOBJ__
#define __GEMOBJ__

/****** DEFINES **************************************************************/

/* GEM METFAFILE OBJECT messages */

#define GEM_INIT              1
#define GEM_EXIT              2
#define GEM_UPDATE            3
#define GEM_CLEAR             4
#define GEM_DRAW              5
#define GEM_SHOWCURSOR        6
#define GEM_HIDECURSOR        7
#define GEM_KEY               8
#define GEM_CLICK             9
#define GEM_PRINT            10

/* GEM OBJECT flags */

#define GEM_FILE         0x0001 /* gem metafile comes from file */
#define GEM_MEM          0x0002 /* gem metafile comes from  memory */
#define GEM_BESTFIT      0x0004 /* fit metafile to frame */

/* GEM OBJECT errors & warnings */

#define GEM_OK                0
#define GEM_WRONGMESSAGE     -1
#define GEM_GENERAL          -2
#define GEM_BUFFERCHANGED    -3
#define GEM_NOMEMORY         -3
#define GEM_CHARNOTUSED      -4
#define GEM_FILENOTFOUND     -5

/****** TYPES ****************************************************************/

typedef struct meta_header
{
  WORD id;
  WORD headlen;
  WORD version;
  WORD transform;
  WORD min_x;
  WORD min_y;
  WORD max_x;
  WORD max_y;
  WORD pwidth;
  WORD pheight;
  WORD ll_x;
  WORD ll_y;
  WORD ur_x;
  WORD ur_y;
  WORD bit_image;
} META_HEADER;

typedef struct
{
  WINDOWP     window;           /* parent window of gem metafile object */
  RECT        pos;              /* position & size of gem metafile object relative to window document */
  RECT        doc;              /* position and width of sliders/document */
  BOOLEAN     curs_hidden;      /* true, if cursor is hidden */
  LONGSTR     filename;         /* filename of metafile */
  FHANDLE     f;                /* file handle of metafile */
  LONG        fsize;            /* file size */
  LONG        bufsize;          /* buffer size */
  UWORD       *buffer;          /* metafile buffer (buffers whole file) */
  BOOLEAN     allocated;        /* TRUE, if buffer was allocated dynamically */
  UBYTE       *ext_buffer;      /* metafile buffer externally supplied */
  LONG        ext_bufp;         /* pointer within external buffer (where to read next) */
  META_HEADER header;           /* metafile header */
  BOOLEAN     first;            /* for buffer filling */
  WORD        device;           /* SCREEN, PRINTER, ...*/
  WORD        out_handle;       /* handle for output device */
  LONG        vdi_calls;        /* number of calls in metafile */
  BOOLEAN     best_fit;         /* fit to pos window */
  LRECT       out_device;       /* size of output device */
  LRECT       dst_pixel;        /* size of pixels */
  LONG        pic_w;            /* width of picture in pixels */
  LONG        pic_h;            /* height of picture in pixels */
  UWORD       flags;            /* gem metafile object flags */
} GEMOBJ;

typedef GEMOBJ *GEMOBJP;        /* pointer to gem metafile object */

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL WORD gem_obj _((GEMOBJP gemobj, WORD message, WORD wparam, VOID *p));

#endif /* __GEMOBJ__ */

