/*****************************************************************************
 *
 * Module : IMAGEOBJ.H
 * Author : JÅrgen Geiû
 *
 * Creation date    : 20.11.90
 * Last modification: 10.03.97
 *
 *
 * Description: This module defines the bit image object.
 *
 * History:
 * 10.03.97: IMG_UPDATE added
 * 20.11.90: Creation of body
 *****************************************************************************/

#ifndef __IMAGEOBJ__
#define __IMAGEOBJ__

/****** DEFINES **************************************************************/

/* IMAGE OBJECT messages */

#define IMG_INIT              1
#define IMG_EXIT              2
#define IMG_UPDATE            3
#define IMG_CLEAR             4
#define IMG_DRAW              5
#define IMG_SHOWCURSOR        6
#define IMG_HIDECURSOR        7
#define IMG_KEY               8
#define IMG_CLICK             9
#define IMG_PRINT            10

/* IMAGE OBJECT flags */

#define IMG_FILE              1 /* image comes from file */
#define IMG_MEM               2 /* image comes from memory */

/* IMAGE OBJECT errors & warnings */

#define IMG_OK                0
#define IMG_WRONGMESSAGE     -1
#define IMG_GENERAL          -2
#define IMG_BUFFERCHANGED    -3
#define IMG_NOMEMORY         -4
#define IMG_CHARNOTUSED      -5
#define IMG_FILENOTFOUND     -6

/****** TYPES ****************************************************************/

typedef UBYTE HUGE *HUPTR;

typedef struct
{
  WINDOWP window;               /* parent window of image object */
  RECT    pos;                  /* position & size of image object relative to window document */
  HUPTR   raster_buf;           /* pointer to transformed picture buffer */
  VOID    *buffer;              /* buffer, if file comes from memory */
  LONG    bufsize;              /* buffer size */
  BOOLEAN curs_hidden;          /* true, if cursor is hidden */
  LONGSTR filename;             /* filename of picture */
  WORD    width;                /* width of picture in pixels */
  WORD    height;               /* height of picture in pixels */
  WORD    planes;               /* number of planes of picture */
  MFDB    s;                    /* MFDB of transformed picture */
  UWORD   flags;                /* image object flags */
} IMGOBJ;

typedef IMGOBJ *IMGOBJP;        /* pointer to image object */

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL WORD image_obj _((IMGOBJP imgobj, WORD message, WORD wparam, VOID *p));

#endif /* __IMAGEOBJ__ */

