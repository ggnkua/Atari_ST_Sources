/*******************************************************************************
*
*  Project name : GENERAL C LIBRARY FOR TOS APPLICATIONS
*  Module name  : Library for compiled resources
*  Symbol prefix: rsrc
*
*  Author       : Harald Siegmund (HS)
*  Co-Authors   : -
*  Write access : HS
*
*  Notes        : -
*-------------------------------------------------------------------------------
*  Things to do : -
*
*-------------------------------------------------------------------------------
*  History:
*
*  1990:
*     Apr 05: introduced, implementation
*     Jul 23: fast object coordinate fix function
*     Oct 09: bug fixed: tree index overflow checking didn't work
*             changing initialization (no longer use pointers which
*              don't appear in the relocation table)
*  1991:
*     Jun 08: cosmetic changes
*  1992:
*     May 22: reorganize source
*             adding rsrc_saddr() and rsrc_obfix()
*     Jun 05/23: cosmetic changes
*  1993:
*     Apr 26: new file header
*     Aug 30: replace RHDR _RSCHDR by LONGHDR _RSCLHDR (long header format)
*
*******************************************************************************/
/*KEY _NAME="library for compiled resources" */
/*END*/

/*******************************************************************************
*                                                                              *
*                                   INCLUDES                                   *
*                                                                              *
*******************************************************************************/

#include <stddef.h>
#include <aes.h>
/*KEY _END */


/*******************************************************************************
*                                                                              *
*                                    MACROS                                    *
*                                                                              *
*******************************************************************************/

#define UNUSED(x) x = x             /* unused formal parameter */


/*******************************************************************************
*                                                                              *
*                               TYPE DEFINITIONS                               *
*                                                                              *
*******************************************************************************/

typedef unsigned long ulong;        /* shortcut */

typedef struct                      /* resource file header (long format) */
   {
   ulong    vrsn;                   /* version # */
   ulong    object;                 /* offset to first OBJECT */
   ulong    tedinfo;                /* offset to first TEDINFO */
   ulong    iconblk;                /* offset to first ICONBLK */
   ulong    bitblk;                 /* offset to first BITBLK */
   ulong    frstr;                  /* offset to ULONG array of offsets to */
                                    /*  free strings */
   ulong    string;                 /* offset to first string */
   ulong    imdata;                 /* offset to base of image data */
   ulong    frimg;                  /* offset to ULONG array of offsets to */
                                    /*  free images */
   ulong    trindex;                /* offset to ULONG array of offsets to */
                                    /*  first OBJECT of trees */
   ulong    nobs;                   /* # of OBJECTs */
   ulong    ntree;                  /* # of trees */
   ulong    nted;                   /* # of TEDINFOs */
   ulong    nib;                    /* # of ICONBLKs */
   ulong    nbb;                    /* # of BITBLKs */
   ulong    nstring;                /* # of free strings */
   ulong    nimages;                /* # of free images */
   ulong    rssize;                 /* size of resource file */
   } LONGHDR;


/*******************************************************************************
*                                                                              *
*                               EXTERN REFERENCES                              *
*                                                                              *
*******************************************************************************/

extern LONGHDR _RSCLHDR;            /* address of resource header */
extern OBJECT  _object[];           /* ^ to first OBJECT */
extern TEDINFO _tedinfo[];          /* ^ to first TEDINFO */
extern ICONBLK _iconblk[];          /* ^ to first ICONBLK */
extern BITBLK  _bitblk[];           /* ^ to first BITBLK */
extern OBJECT  *_trindex[];         /* ^ to tree ^ table */
extern char    *_frstr[];           /* ^ to free string ^ table */
extern BITBLK  *_frimg[];           /* ^ to free image ^ table */


/*******************************************************************************
*                                                                              *
*                                LOCAL PROTOTYPES                              *
*                                                                              *
*******************************************************************************/

   /* fix one object coordinate/size */
static int obfix(int v,int size);


/*******************************************************************************
*                                                                              *
*                             UNINITIALIZED STATICS                            *
*                                                                              *
*******************************************************************************/

static int  chr_w,chr_h;            /* character width and height in pixels */


/*******************************************************************************
*                                                                              *
*                                 LOCAL FUNCTIONS                              *
*                                                                              *
*******************************************************************************/

/*******************************************************************************
*
*  obfix: fix one object coordinate/size
*
*  An object coodinate or size is converted from screen-independend format to
*  screen-dependend format.
*
*  screen-independend format:
*     low byte  = character offset
*     high byte = pixel offset
*
*  screen-dependend format:
*     pixel offset
*
*  Out:
*     value in screen-dependend format
*
*******************************************************************************/

static int obfix(

int         v,                      /* coordinate/size to fix */
int         size)                   /* size factor (character width/height) */
{

   return (v & 0xff) * size + ((v >> 8) & 0xff);

}     /* obfix() */


/*******************************************************************************
*                                                                              *
*                                GLOBAL FUNCTIONS                              *
*                                                                              *
*******************************************************************************/

/*START*/
/*******************************************************************************
*
*  rsrc_load: initialize resource
*
*  The object coordinate in the built-in resource are adjusted to the current
*  system font size.
*
*  Out:
*     status (always 1 = ok)
*
*******************************************************************************/

int rsrc_load(

const char  *re_lpfname)            /* ^ to filename of resource (IGNORED) */
{
/*END*/

   int      dummy;                  /* dummy buffer */
   ulong    i;


   UNUSED(re_lpfname);              /* we don't need the filename */

                                    /* get size of system font's characters */
   (void)graf_handle(&chr_w,&chr_h,&dummy,&dummy);

                                    /* fix x/y/w/h of all objects */
   for (i = 0; i < _RSCLHDR.nobs; rsrc_obfix(_object,(int)i++));

   return 1;

}     /* rsrc_load() */


/*START*/
/*******************************************************************************
*
*  rsrc_free: remove resource from memory
*
*  This version of rsrc_free() performs absolutely *nothing*!
*
*  Out:
*     status (always 1 = ok)
*
*******************************************************************************/

int rsrc_free(void)
{
/*END*/

   return 1;

}     /* rsrc_free() */


/*START*/
/*******************************************************************************
*
*  rsrc_gaddr: get address of resource structure
*
*  Out:
*     status:
*     1                 ok
*     0                 error (unknown type or invalid index)
*
*     ^ to structure in *gaddr (NULL if error occured)
*
*******************************************************************************/

int rsrc_gaddr(

int         re_gtype,               /* structure type (R_...) */
int         re_gindex,              /* structure index */
void        *gaddr)                 /* ^ to buffer for structure's address */
{
/*END*/

   int      stat;                   /* return status */


   stat = (re_gindex >= 0);         /* index must be >= 0 !!! */

   if (stat) switch (re_gtype)      /* which structure type? */
      {
      case R_TREE:                  /* object tree */
         if (re_gindex >= _RSCLHDR.ntree) stat = 0;
         else *(OBJECT **)gaddr = _trindex[re_gindex];
         break;

      case R_OBJECT:                /* object */
         if (re_gindex >= _RSCLHDR.nobs) stat = 0;
         else *(OBJECT **)gaddr = _object + re_gindex;
         break;

      case R_TEDINFO:               /* text edit info */
         if (re_gindex >= _RSCLHDR.nted) stat = 0;
         else *(TEDINFO **)gaddr = _tedinfo + re_gindex;
         break;

      case R_ICONBLK:               /* icon block */
         if (re_gindex >= _RSCLHDR.nib) stat = 0;
         else *(ICONBLK **)gaddr = _iconblk + re_gindex;
         break;

      case R_BITBLK:                /* icon block */
         if (re_gindex >= _RSCLHDR.nbb) stat = 0;
         else *(BITBLK **)gaddr = _bitblk + re_gindex;
         break;

      case R_STRING:                /* free string */
         if (re_gindex >= _RSCLHDR.nstring) stat = 0;
         else *(char **)gaddr = _frstr[re_gindex];
         break;

      case R_IMAGEDATA:             /* free image */
         if (re_gindex >= _RSCLHDR.nimages) stat = 0;
         else *(BITBLK **)gaddr = _frimg[re_gindex];
         break;

      case R_OBSPEC:                /* ob_spec */
         if (re_gindex >= _RSCLHDR.nobs) stat = 0;
         else *(long *)gaddr = _object[re_gindex].ob_spec.index;
         break;

      case R_TEPTEXT:               /* text ^ */
         if (re_gindex >= _RSCLHDR.nted) stat = 0;
         else *(char **)gaddr = _tedinfo[re_gindex].te_ptext;
         break;

      case R_TEPTMPLT:              /* template ^ */
         if (re_gindex >= _RSCLHDR.nted) stat = 0;
         else *(char **)gaddr = _tedinfo[re_gindex].te_ptmplt;
         break;

      case R_TEPVALID:              /* validation ^ */
         if (re_gindex >= _RSCLHDR.nted) stat = 0;
         else *(char **)gaddr = _tedinfo[re_gindex].te_pvalid;
         break;

      case R_IBPMASK:               /* icon mask ^ */
         if (re_gindex >= _RSCLHDR.nib) stat = 0;
         else *(int **)gaddr = _iconblk[re_gindex].ib_pmask;
         break;

      case R_IBPDATA:               /* icon data ^ */
         if (re_gindex >= _RSCLHDR.nib) stat = 0;
         else *(int **)gaddr = _iconblk[re_gindex].ib_pdata;
         break;

      case R_IPBTEXT:               /* icon text ^ */
         if (re_gindex >= _RSCLHDR.nib) stat = 0;
         else *(char **)gaddr = _iconblk[re_gindex].ib_ptext;
         break;

      case R_BIPDATA:               /* image data ^ */
         if (re_gindex >= _RSCLHDR.nbb) stat = 0;
         else *(int **)gaddr = _bitblk[re_gindex].bi_pdata;
         break;

      case R_FRSTR:                 /* free string ^ table */
         if (re_gindex >= _RSCLHDR.nstring) stat = 0;
         else *(char ***)gaddr = _frstr + re_gindex;
         break;

      case R_FRIMG:                 /* free image ^ table */
         if (re_gindex >= _RSCLHDR.nimages) stat = 0;
         else *(BITBLK ***)gaddr = _frimg + re_gindex;
         break;

      default:                      /* unknown */
         stat = 0;
      }

   if (!stat)                       /* error? */
      *(char **)gaddr = NULL;       /* then clear return ^ */

   return stat;

}     /* rsrc_gaddr() */


/*START*/
/*******************************************************************************
*
*  rsrc_saddr: set address of resource structure
*
*  Out:
*     status:
*     1                 ok
*     0                 error (unknown type or invalid index)
*
*******************************************************************************/

int rsrc_saddr(

int         re_stype,               /* structure type (R_FRSTR or R_FRIMG) */
int         re_sindex,              /* structure index */
void        *saddr)                 /* new address of structure */
{
/*END*/

   int      stat;                   /* return status */


   stat = (re_sindex >= 0);         /* index must be >= 0 !!! */

   if (stat) switch (re_stype)      /* which structure type? */
      {
      case R_FRSTR:                 /* free string ^ table */
         if (re_sindex >= _RSCLHDR.nstring) stat = 0;
         else _frstr[re_sindex] = saddr;
         break;

      case R_FRIMG:                 /* free image ^ table */
         if (re_sindex >= _RSCLHDR.nimages) stat = 0;
         else _frimg[re_sindex] = saddr;
         break;

      default:                      /* unknown */
         stat = 0;
      }

   return stat;

}     /* rsrc_saddr() */


/*START*/
/*******************************************************************************
*
*  rsrc_obfix: adjust object coordinates to screen font size
*
*  Position and size of an object is converted from the screen-independend
*  format (created by a resource editor) to the screen-dependend format
*  (required to display dialogs).
*
*  Note: don't use this function before rsrc_load() has been called
*
*  Out:
*     status:
*     1                 ok
*     0                 error (invalid object index)
*
*******************************************************************************/

int rsrc_obfix(

OBJECT      *re_otree,              /* ^ to object tree */
int         re_oobject)             /* object index */
{
/*END*/

   if (re_oobject < 0)              /* invalid index? */
      return 0;                     /* then abort */

   re_otree += re_oobject;          /* ^ to object */

   re_otree->ob_x      = obfix(re_otree->ob_x,chr_w);       /* fix x */
   re_otree->ob_y      = obfix(re_otree->ob_y,chr_h);       /* fix y */
   re_otree->ob_width  = obfix(re_otree->ob_width,chr_w);   /* fix width */
   re_otree->ob_height = obfix(re_otree->ob_height,chr_h);  /* fix height */

   return 1;

}     /* rsrc_obfix() */


/*EOF*/
