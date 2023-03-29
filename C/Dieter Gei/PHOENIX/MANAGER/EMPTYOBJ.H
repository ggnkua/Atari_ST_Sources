/*****************************************************************************/
/*                                                                           */
/* Modul: EMPTYOBJ.H                                                         */
/* Datum: 26/10/90                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __EMPTYOBJ__
#define __EMPTYOBJ__

/****** DEFINES **************************************************************/

/* EMPTY OBJECT messages */

#define EO_INIT             1
#define EO_EXIT             2
#define EO_CLEAR            3
#define EO_DRAW             4
#define EO_SHOWCURSOR       5
#define EO_HIDECURSOR       6
#define EO_KEY              7
#define EO_CLICK            8

/* EMPTY OBJECT errors & warnings */

#define EO_OK               0
#define EO_WRONGMESSAGE    -1
#define EO_GENERAL         -2
#define EO_BUFFERCHANGED   -3
#define EO_CHARNOTUSED     -4

/****** TYPES ****************************************************************/

typedef struct
{
  WINDOWP window;               /* parent window of empty object */
  RECT    pos;                  /* position & size of empty object relative to window document */
  BOOLEAN curs_hidden;          /* true, if cursor is hidden */
} EMPTYOBJ;

typedef EMPTYOBJ *EMPTYOBJP;    /* pointer to empty object */

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL WORD empty_obj _((EMPTYOBJP emptyobj, WORD message, WORD wparam, MKINFO *mk));

#endif /* __EMPTYOBJ__ */

