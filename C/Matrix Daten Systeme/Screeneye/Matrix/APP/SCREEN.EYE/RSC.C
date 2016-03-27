/***************************************************************************
/*																			*/
/* Achtung:																	*/
/*																			*/
/* modifiziert fÅr Falcon 320x200 : 										*/
/* inrsrc_load() : # define sys_chr_h	16									*/
/*																			*/
/***************************************************************************


/***************************************************************************
*
*                       MANAGER FOR COMPILED RESOURCES
*
*  Edition  : 6
*  Author   : Harald Siegmund
*  History  :
*
*  1990:
*     Apr 05: creation of file
*     Jul 23: fast object coordinate fix function
*     Oct 09: bug fixed: tree index overflow checking didn't work
*              (did only affect invalid tree indices)
*             changing initialization (no longer use pointers which
*              don't appear in the relocation table [for Calamus modules])
*  1991:
*     Jun 08: cosmetic changes
*
*  This module replaces the library functions rsrc_load(), rsrc_gaddr()
*  and rsrc_free().
*
***************************************************************************/
/*KEY _NAME "resource manager" */
/*END*/


/**************************************************************************/
/*                                                                        */
/*                            INCLUDE FILES                               */
/*                                                                        */
/**************************************************************************/

/*START*/
#include <stdio.h>
#include <aes.h>
/*END*/


/**************************************************************************/
/*                                                                        */
/*                               MACROS                                   */
/*                                                                        */
/**************************************************************************/

#define UNUSED(x) x = x             /* unused parameter */



/**************************************************************************/
/*                                                                        */
/*                          TYPE DEFINITIONS                              */
/*                                                                        */
/**************************************************************************/

typedef unsigned int UINT;          /* shortcut */


typedef struct                      /* resource file header */
   {
   UINT     vrsn;                   /* version # (0) */
   UINT     object;                 /* offset to first OBJECT */
   UINT     tedinfo;                /* offset to first TEDINFO */
   UINT     iconblk;                /* offset to first ICONBLK */
   UINT     bitblk;                 /* offset to first BITBLK */
   UINT     frstr;                  /* offset to ULONG array of offsets to */
                                    /*  free strings */
   UINT     string;                 /* offset to first string */
   UINT     imdata;                 /* offset to base of image data */
   UINT     frimg;                  /* offset to ULONG array of offsets to */
                                    /*  free images */
   UINT     trindex;                /* offset to ULONG array of offsets to */
                                    /*  first OBJECT of trees */
   UINT     nobs;                   /* # of OBJECTs */
   UINT     ntree;                  /* # of trees */
   UINT     nted;                   /* # of TEDINFOs */
   UINT     nib;                    /* # of ICONBLKs */
   UINT     nbb;                    /* # of BITBLKs */
   UINT     nstring;                /* # of free strings */
   UINT     nimages;                /* # of free images */
   UINT     rssize;                 /* size of resource file */
   } RHDR;



/**************************************************************************/
/*                                                                        */
/*                          EXTERN REFERENCES                             */
/*                                                                        */
/**************************************************************************/

extern RHDR    _RSCHDR;             /* address of resource header */
extern OBJECT  _object[];           /* ^ to first OBJECT */
extern TEDINFO _tedinfo[];          /* ^ to first TEDINFO */
extern ICONBLK _iconblk[];          /* ^ to first ICONBLK */
extern BITBLK  _bitblk[];           /* ^ to first BITBLK */
extern OBJECT  *_trindex[];         /* ^ to tree ^ table */
extern char    *_frstr[];           /* ^ to free string ^ table */
extern BITBLK  *_frimg[];           /* ^ to free image ^ table */



/**************************************************************************/
/*                                                                        */
/*                         LOCAL PROTOTYPES                               */
/*                                                                        */
/**************************************************************************/

   /* fix object coordinates */
int   obfix(int v,int size);



/**************************************************************************/
/*                                                                        */
/*                          LOCAL FUNCTIONS                               */
/*                                                                        */
/**************************************************************************/

/***************************************************************************
*
*  obfix: fix object coordinates
*
*  This function replaces the (slow!) AES routine rsrc_obfix().
*
*  Out:
*        fixed coordinate
*
***************************************************************************/

static int obfix(v,size)

int         v;                      /* coordinate to fix */
                                    /* low byte : character offset */
                                    /* high byte: pixel offset */
int         size;                   /* size factor (character width/height) */
{     /* obfix() */

   return (v & 0xff) * size + ((v >> 8) & 0xff);

}     /* obfix() */



/**************************************************************************/
/*                                                                        */
/*                          GLOBAL FUNCTIONS                              */
/*                                                                        */
/**************************************************************************/

/*START*/
/***************************************************************************
*
*  rsrc_load: "load" resource into memory
*
*  This function just calls rsrc_obfix() to set the coordinates of the
*  resource objects.
*
*  Out:
*        always 1 (= ok status)
*
***************************************************************************/

int rsrc_load(re_lpfname)

const char  *re_lpfname;            /* ^ to filename */
{     /* rsrc_load() */
/*END*/

   int      sys_chr_w,sys_chr_h,    /* system character size */
            dummy;
   UINT     i;
   OBJECT   *po;                    /* ^ to current object */


   UNUSED(re_lpfname);              /* we don't need the filename */

                                    /* get size of system characters */
   (void)graf_handle(&sys_chr_w,&sys_chr_h,&dummy,&dummy);
                                    /* fix x/y positions of objects */
   for (i = _RSCHDR.nobs, po = _object; i; i--,po++)
      {
# define sys_chr_h	16
      po->ob_x = obfix(po->ob_x,sys_chr_w);
      po->ob_y = obfix(po->ob_y,sys_chr_h);
      po->ob_width = obfix(po->ob_width,sys_chr_w);
      po->ob_height = obfix(po->ob_height,sys_chr_h);
      }

   return 1;

}     /* rsrc_load() */



/*START*/
/***************************************************************************
*
*  rsrc_gaddr: get address of resource structure
*
*  Out:
*        status:
*        1 = ok
*        0 = error (unknown type or invalid index)
*
*        ^ to structure in *gaddr
*
***************************************************************************/

int rsrc_gaddr(re_gtype,re_gindex,gaddr)

int         re_gtype;
int         re_gindex;
void        *gaddr;
{     /* rsrc_gaddr() */
/*END*/

   int      stat;                   /* return status */


   stat = (re_gindex >= 0);         /* index must be >= 0 !!! */

   if (stat) switch (re_gtype)      /* which structure type? */
      {
      case R_TREE:                  /* object tree */
         if (re_gindex >= _RSCHDR.ntree) stat = 0;
         else *(OBJECT **)gaddr = _trindex[re_gindex];
         break;

      case R_OBJECT:                /* object */
         if (re_gindex >= _RSCHDR.nobs) stat = 0;
         else *(OBJECT **)gaddr = _object + re_gindex;
         break;

      case R_TEDINFO:               /* text edit info */
         if (re_gindex >= _RSCHDR.nted) stat = 0;
         else *(TEDINFO **)gaddr = _tedinfo + re_gindex;
         break;

      case R_ICONBLK:               /* icon block */
         if (re_gindex >= _RSCHDR.nib) stat = 0;
         else *(ICONBLK **)gaddr = _iconblk + re_gindex;
         break;

      case R_BITBLK:                /* icon block */
         if (re_gindex >= _RSCHDR.nbb) stat = 0;
         else *(BITBLK **)gaddr = _bitblk + re_gindex;
         break;

      case R_STRING:                /* free string */
         if (re_gindex >= _RSCHDR.nstring) stat = 0;
         else *(char **)gaddr = _frstr[re_gindex];
         break;

      case R_IMAGEDATA:             /* free image */
         if (re_gindex >= _RSCHDR.nimages) stat = 0;
         else *(BITBLK **)gaddr = _frimg[re_gindex];
         break;

      case R_OBSPEC:                /* ob_spec */
         if (re_gindex >= _RSCHDR.nobs) stat = 0;
         else *(long *)gaddr = _object[re_gindex].ob_spec.index;
         break;

      case R_TEPTEXT:               /* text ^ */
         if (re_gindex >= _RSCHDR.nted) stat = 0;
         else *(char **)gaddr = _tedinfo[re_gindex].te_ptext;
         break;

      case R_TEPTMPLT:              /* template ^ */
         if (re_gindex >= _RSCHDR.nted) stat = 0;
         else *(char **)gaddr = _tedinfo[re_gindex].te_ptmplt;
         break;

      case R_TEPVALID:              /* validation ^ */
         if (re_gindex >= _RSCHDR.nted) stat = 0;
         else *(char **)gaddr = _tedinfo[re_gindex].te_pvalid;
         break;

      case R_IBPMASK:               /* icon mask ^ */
         if (re_gindex >= _RSCHDR.nib) stat = 0;
         else *(int **)gaddr = _iconblk[re_gindex].ib_pmask;
         break;

      case R_IBPDATA:               /* icon data ^ */
         if (re_gindex >= _RSCHDR.nib) stat = 0;
         else *(int **)gaddr = _iconblk[re_gindex].ib_pdata;
         break;

      case R_IPBTEXT:               /* icon text ^ */
         if (re_gindex >= _RSCHDR.nib) stat = 0;
         else *(char **)gaddr = _iconblk[re_gindex].ib_ptext;
         break;

      case R_BIPDATA:               /* image data ^ */
         if (re_gindex >= _RSCHDR.nbb) stat = 0;
         else *(int **)gaddr = _bitblk[re_gindex].bi_pdata;
         break;

      case R_FRSTR:                 /* free string ^ table */
         if (re_gindex >= _RSCHDR.nstring) stat = 0;
         else *(char ***)gaddr = _frstr + re_gindex;
         break;

      case R_FRIMG:                 /* free image ^ table */
         if (re_gindex >= _RSCHDR.nimages) stat = 0;
         else *(BITBLK ***)gaddr = _frimg + re_gindex;
         break;

      default:                      /* unknown/not supported */
         stat = 0;
      }

   if (!stat)                       /* error? */
      *(char **)gaddr = NULL;       /* then clear return ^ */

   return stat;

}     /* rsrc_gaddr() */




/*START*/
/***************************************************************************
*
*  rsrc_free: remove resource from memory
*
*  This version of rsrc_free() performs absolutely NOTHING!
*
*  Out:
*        always 1 (= ok status)
*
***************************************************************************/

int rsrc_free() { return 1; }
/*END*/


/* EOF */

