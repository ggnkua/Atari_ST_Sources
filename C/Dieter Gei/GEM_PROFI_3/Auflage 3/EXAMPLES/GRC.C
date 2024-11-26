/*****************************************************************************/
/*                                                                           */
/* GEM resource converter for ATARI ST                                       */
/*                                                                           */
/* used to convert GEM resource files                                        */
/* from MC68000 to INTEL format and vice versa                               */
/*                                                                           */
/* Version: [1.2]                                                            */
/* Date   : 1-February-89                                                    */
/* Author : JÅrgen Geiû                                                      */
/*                                                                           */
/*****************************************************************************/

#include <stdio.h>
#include <string.h>
#include <portab.h>
#include <vdi.h>
#include <aes.h>

#if GEMDOS
#include <osbind.h>
#define Mavail() (LONG)Malloc (-1L)
#else
#include <gemdos.h>
#include <dosbind.h>
#endif

/*****************************************************************************/
/* DEFINES                                                                   */
/*****************************************************************************/

#define STRLEN  82
#define MAX_RS  65536L               /* max 64k resource files, must be LONG */

/*****************************************************************************/
/* TYPES                                                                     */
/*****************************************************************************/

typedef BYTE STRING [STRLEN];

/*****************************************************************************/
/* VARIABLES                                                                 */
/*****************************************************************************/

WORD   handle;                  /* file handle                            */
LONG   size;                    /* size of file                           */
STRING srcname;                 /* source resource filename               */
STRING destname;                /* destination resource filename          */
STRING direction;               /* 0 = MC68K -> INTEL, 1 = INTEL -> MC68K */
RSHDR  *header;                 /* resource header                        */
UBYTE  *rsc_buffer;             /* buffer for resource file               */

/*****************************************************************************/

LOCAL VOID strupper     _((BYTE *s));
LOCAL VOID flip_word    _((BYTE *adr));
LOCAL VOID flip_long    _((WORD *adr));
LOCAL VOID MC68KtoINTEL _((VOID));
LOCAL VOID INTELtoMC68K _((VOID));

/*****************************************************************************/

LOCAL VOID strupper (s)
REG BYTE *s;

{
  while (*s)
  {
    if (('a' <= *s) && (*s <= 'z')) *s -= 'a' - 'A';
    s++;
  } /* while */
} /* strupper */

/*****************************************************************************/

LOCAL VOID flip_word (adr)
REG BYTE *adr;

{
  REG BYTE c;

  c       = adr [0];
  adr [0] = adr [1];
  adr [1] = c;
} /* flip_word */

/*****************************************************************************/

LOCAL VOID flip_long (adr)
REG WORD *adr;

{
  REG WORD i;

  i       = adr [0];
  adr [0] = adr [1];
  adr [1] = i;

  flip_word ((BYTE *)&adr [0]);
  flip_word ((BYTE *)&adr [1]);
} /* flip_long */

/*****************************************************************************/

LOCAL VOID MC68KtoINTEL ()

{
  WORD    i, j, words;
  WORD    *pmask;
  WORD    *pdata;
  OBJECT  *pobject;
  TEDINFO *ptedinfo;
  ICONBLK *piconblk;
  BITBLK  *pbitblk;
  BYTE    **pfrstr;
  BITBLK  *pfrimg;
  OBJECT  **ptrindex;
  UBYTE   *pstring;

  handle = Fopen (srcname, 0);

  if (handle < 0)
  {
    printf ("Error in opening %s\n", srcname);
    return;
  } /* if */

  size = Fread (handle, MAX_RS, rsc_buffer);
  Fclose (handle);

  /***** flip data and mask of iconblocks *****/

  piconblk = (ICONBLK *)((ULONG)rsc_buffer + header->rsh_iconblk);

  for (i = 0; i < header->rsh_nib; i++)
  {
    words = piconblk [i].ib_wicon / 16 * piconblk [i].ib_hicon;

    pmask = (WORD *)((ULONG)rsc_buffer + (ULONG)piconblk [i].ib_pmask);
    for (j = 0; j < words; j++) flip_word ((BYTE *)&pmask [j]);

    pdata = (WORD *)((ULONG)rsc_buffer + (ULONG)piconblk [i].ib_pdata);
    for (j = 0; j < words; j++) flip_word ((BYTE *)&pdata [j]);
  } /* for */

  /***** flip data of bitblocks *****/

  pbitblk = (BITBLK *)((ULONG)rsc_buffer + header->rsh_bitblk);

  for (i = 0; i < header->rsh_nbb; i++)
  {
    words = pbitblk [i].bi_wb / 2 * pbitblk [i].bi_hl;

    pdata = (WORD *)((ULONG)rsc_buffer + (ULONG)pbitblk [i].bi_pdata);
    for (j = 0; j < words; j++) flip_word ((BYTE *)&pdata [j]);
  } /* for */

  /***** flip objects *****/

  pobject = (OBJECT *)((ULONG)rsc_buffer + header->rsh_object);

  for (i = 0; i < header->rsh_nobs; i++)
  {
    flip_word ((BYTE *)&pobject [i].ob_next);
    flip_word ((BYTE *)&pobject [i].ob_head);
    flip_word ((BYTE *)&pobject [i].ob_tail);
    flip_word ((BYTE *)&pobject [i].ob_type);
    flip_word ((BYTE *)&pobject [i].ob_flags);
    flip_word ((BYTE *)&pobject [i].ob_state);
    flip_long ((WORD *)&pobject [i].ob_spec);
    flip_word ((BYTE *)&pobject [i].ob_x);
    flip_word ((BYTE *)&pobject [i].ob_y);
    flip_word ((BYTE *)&pobject [i].ob_width);
    flip_word ((BYTE *)&pobject [i].ob_height);
  } /* for */

  /***** flip tedinfos *****/

  ptedinfo = (TEDINFO *)((ULONG)rsc_buffer + header->rsh_tedinfo);

  for (i = 0; i < header->rsh_nted; i++)
  {
    flip_long ((WORD *)&ptedinfo [i].te_ptext);
    flip_long ((WORD *)&ptedinfo [i].te_ptmplt);
    flip_long ((WORD *)&ptedinfo [i].te_pvalid);
    flip_word ((BYTE *)&ptedinfo [i].te_font);
    flip_word ((BYTE *)&ptedinfo [i].te_junk1);
    flip_word ((BYTE *)&ptedinfo [i].te_just);
    flip_word ((BYTE *)&ptedinfo [i].te_color);
    flip_word ((BYTE *)&ptedinfo [i].te_junk2);
    flip_word ((BYTE *)&ptedinfo [i].te_thickness);
    flip_word ((BYTE *)&ptedinfo [i].te_txtlen);
    flip_word ((BYTE *)&ptedinfo [i].te_tmplen);
  } /* for */

  /***** flip iconblocks *****/

  piconblk = (ICONBLK *)((ULONG)rsc_buffer + header->rsh_iconblk);

  for (i = 0; i < header->rsh_nib; i++)
  {
    flip_long ((WORD *)&piconblk [i].ib_pmask);
    flip_long ((WORD *)&piconblk [i].ib_pdata);
    flip_long ((WORD *)&piconblk [i].ib_ptext);
    flip_word ((BYTE *)&piconblk [i].ib_char);
    flip_word ((BYTE *)&piconblk [i].ib_xchar);
    flip_word ((BYTE *)&piconblk [i].ib_ychar);
    flip_word ((BYTE *)&piconblk [i].ib_xicon);
    flip_word ((BYTE *)&piconblk [i].ib_yicon);
    flip_word ((BYTE *)&piconblk [i].ib_wicon);
    flip_word ((BYTE *)&piconblk [i].ib_hicon);
    flip_word ((BYTE *)&piconblk [i].ib_xtext);
    flip_word ((BYTE *)&piconblk [i].ib_ytext);
    flip_word ((BYTE *)&piconblk [i].ib_wtext);
    flip_word ((BYTE *)&piconblk [i].ib_htext);
  } /* for */

  /***** flip bitblocks *****/

  pbitblk = (BITBLK *)((ULONG)rsc_buffer + header->rsh_bitblk);

  for (i = 0; i < header->rsh_nbb; i++)
  {
    flip_long ((WORD *)&pbitblk [i].bi_pdata);
    flip_word ((BYTE *)&pbitblk [i].bi_wb);
    flip_word ((BYTE *)&pbitblk [i].bi_hl);
    flip_word ((BYTE *)&pbitblk [i].bi_x);
    flip_word ((BYTE *)&pbitblk [i].bi_y);
    flip_word ((BYTE *)&pbitblk [i].bi_color);
  } /* for */

  /***** flip free strings *****/

  pfrstr = (BYTE **)((ULONG)rsc_buffer + header->rsh_frstr);
  for (i = 0; i < header->rsh_nstring; i++) flip_long ((WORD *)&pfrstr [i]);

  /***** flip free images *****/

  pfrimg = (BITBLK *)((ULONG)rsc_buffer + header->rsh_frimg);
  for (i = 0; i < header->rsh_nimages; i++) flip_long ((WORD *)&pfrimg [i]);

  /***** flip trees *****/

  ptrindex = (OBJECT **)((ULONG)rsc_buffer + header->rsh_trindex);
  for (i = 0; i < header->rsh_ntree; i++) flip_long ((WORD *)&ptrindex [i]);

  /* fix font from ATARI to IBM */

  pstring = (UBYTE *)((ULONG)rsc_buffer + header->rsh_string);

  while (pstring < (UBYTE *)((ULONG)rsc_buffer + header->rsh_imdata))
  {
    if (*pstring == 221) *pstring =  21; /* change  from ATARI ST to IBM font */
    if (*pstring == 158) *pstring = 225; /* change · from ATARI ST to IBM font */
    pstring++;
  } /* while */

  /***** flip_header *****/

  flip_word ((BYTE *)&header->rsh_vrsn);
  flip_word ((BYTE *)&header->rsh_object);
  flip_word ((BYTE *)&header->rsh_tedinfo);
  flip_word ((BYTE *)&header->rsh_iconblk);
  flip_word ((BYTE *)&header->rsh_bitblk);
  flip_word ((BYTE *)&header->rsh_frstr);
  flip_word ((BYTE *)&header->rsh_string);
  flip_word ((BYTE *)&header->rsh_imdata);
  flip_word ((BYTE *)&header->rsh_frimg);
  flip_word ((BYTE *)&header->rsh_trindex);
  flip_word ((BYTE *)&header->rsh_nobs);
  flip_word ((BYTE *)&header->rsh_ntree);
  flip_word ((BYTE *)&header->rsh_nted);
  flip_word ((BYTE *)&header->rsh_nib);
  flip_word ((BYTE *)&header->rsh_nbb);
  flip_word ((BYTE *)&header->rsh_nstring);
  flip_word ((BYTE *)&header->rsh_nimages);
  flip_word ((BYTE *)&header->rsh_rssize);

  handle = Fcreate (destname, 0x0);

  if (handle < 0)
  {
    printf ("Error in creating %s\n", destname);
    return;
  } /* if */

  size = Fwrite (handle, size, rsc_buffer);
  Fclose (handle);
} /* MC68KtoINTEL */

/*****************************************************************************/

LOCAL VOID INTELtoMC68K ()

{
  WORD    i, j, words;
  WORD    *pmask;
  WORD    *pdata;
  OBJECT  *pobject;
  TEDINFO *ptedinfo;
  ICONBLK *piconblk;
  BITBLK  *pbitblk;
  BYTE    **pfrstr;
  BITBLK  *pfrimg;
  OBJECT  **ptrindex;
  UBYTE   *pstring;

  handle = Fopen (srcname, 0);

  if (handle < 0)
  {
    printf ("Error in opening %s\n", srcname);
    return;
  } /* if */

  size = Fread (handle, MAX_RS, rsc_buffer);
  Fclose (handle);

  /***** flip_header *****/

  flip_word ((BYTE *)&header->rsh_vrsn);
  flip_word ((BYTE *)&header->rsh_object);
  flip_word ((BYTE *)&header->rsh_tedinfo);
  flip_word ((BYTE *)&header->rsh_iconblk);
  flip_word ((BYTE *)&header->rsh_bitblk);
  flip_word ((BYTE *)&header->rsh_frstr);
  flip_word ((BYTE *)&header->rsh_string);
  flip_word ((BYTE *)&header->rsh_imdata);
  flip_word ((BYTE *)&header->rsh_frimg);
  flip_word ((BYTE *)&header->rsh_trindex);
  flip_word ((BYTE *)&header->rsh_nobs);
  flip_word ((BYTE *)&header->rsh_ntree);
  flip_word ((BYTE *)&header->rsh_nted);
  flip_word ((BYTE *)&header->rsh_nib);
  flip_word ((BYTE *)&header->rsh_nbb);
  flip_word ((BYTE *)&header->rsh_nstring);
  flip_word ((BYTE *)&header->rsh_nimages);
  flip_word ((BYTE *)&header->rsh_rssize);

  /* fix font from IBM to ATARI */

  pstring = (UBYTE *)((ULONG)rsc_buffer + header->rsh_string);

  while (pstring < (UBYTE *)((ULONG)rsc_buffer + header->rsh_imdata))
  {
    if (*pstring ==  21) *pstring = 221; /* change  from IBM to ATARI ST font */
    if (*pstring == 225) *pstring = 158; /* change · from IBM to ATARI ST font */
    pstring++;
  } /* while */

  /***** fix objects *****/

  pobject = (OBJECT *)((ULONG)rsc_buffer + header->rsh_object);

  for (i = 0; i < header->rsh_nobs; i++)
  {
    flip_word ((BYTE *)&pobject [i].ob_next);
    flip_word ((BYTE *)&pobject [i].ob_head);
    flip_word ((BYTE *)&pobject [i].ob_tail);
    flip_word ((BYTE *)&pobject [i].ob_type);
    flip_word ((BYTE *)&pobject [i].ob_flags);
    flip_word ((BYTE *)&pobject [i].ob_state);
    flip_long ((WORD *)&pobject [i].ob_spec);
    flip_word ((BYTE *)&pobject [i].ob_x);
    flip_word ((BYTE *)&pobject [i].ob_y);
    flip_word ((BYTE *)&pobject [i].ob_width);
    flip_word ((BYTE *)&pobject [i].ob_height);
  } /* for */

  /***** flip tedinfos *****/

  ptedinfo = (TEDINFO *)((ULONG)rsc_buffer + header->rsh_tedinfo);

  for (i = 0; i < header->rsh_nted; i++)
  {
    flip_long ((WORD *)&ptedinfo [i].te_ptext);
    flip_long ((WORD *)&ptedinfo [i].te_ptmplt);
    flip_long ((WORD *)&ptedinfo [i].te_pvalid);
    flip_word ((BYTE *)&ptedinfo [i].te_font);
    flip_word ((BYTE *)&ptedinfo [i].te_junk1);
    flip_word ((BYTE *)&ptedinfo [i].te_just);
    flip_word ((BYTE *)&ptedinfo [i].te_color);
    flip_word ((BYTE *)&ptedinfo [i].te_junk2);
    flip_word ((BYTE *)&ptedinfo [i].te_thickness);
    flip_word ((BYTE *)&ptedinfo [i].te_txtlen);
    flip_word ((BYTE *)&ptedinfo [i].te_tmplen);
  } /* for */

  /***** flip iconblocks *****/

  piconblk = (ICONBLK *)((ULONG)rsc_buffer + header->rsh_iconblk);

  for (i = 0; i < header->rsh_nib; i++)
  {
    flip_long ((WORD *)&piconblk [i].ib_pmask);
    flip_long ((WORD *)&piconblk [i].ib_pdata);
    flip_long ((WORD *)&piconblk [i].ib_ptext);
    flip_word ((BYTE *)&piconblk [i].ib_char);
    flip_word ((BYTE *)&piconblk [i].ib_xchar);
    flip_word ((BYTE *)&piconblk [i].ib_ychar);
    flip_word ((BYTE *)&piconblk [i].ib_xicon);
    flip_word ((BYTE *)&piconblk [i].ib_yicon);
    flip_word ((BYTE *)&piconblk [i].ib_wicon);
    flip_word ((BYTE *)&piconblk [i].ib_hicon);
    flip_word ((BYTE *)&piconblk [i].ib_xtext);
    flip_word ((BYTE *)&piconblk [i].ib_ytext);
    flip_word ((BYTE *)&piconblk [i].ib_wtext);
    flip_word ((BYTE *)&piconblk [i].ib_htext);
  } /* for */

  /***** flip bitblocks *****/

  pbitblk = (BITBLK *)((ULONG)rsc_buffer + header->rsh_bitblk);

  for (i = 0; i < header->rsh_nbb; i++)
  {
    flip_long ((WORD *)&pbitblk [i].bi_pdata);
    flip_word ((BYTE *)&pbitblk [i].bi_wb);
    flip_word ((BYTE *)&pbitblk [i].bi_hl);
    flip_word ((BYTE *)&pbitblk [i].bi_x);
    flip_word ((BYTE *)&pbitblk [i].bi_y);
    flip_word ((BYTE *)&pbitblk [i].bi_color);
  } /* for */

  /***** flip free strings *****/

  pfrstr = (BYTE **)((ULONG)rsc_buffer + header->rsh_frstr);
  for (i = 0; i < header->rsh_nstring; i++) flip_long ((WORD *)&pfrstr [i]);

  /***** flip free images *****/

  pfrimg = (BITBLK *)((ULONG)rsc_buffer + header->rsh_frimg);
  for (i = 0; i < header->rsh_nimages; i++) flip_long ((WORD *)&pfrimg [i]);

  /***** flip trees *****/

  ptrindex = (OBJECT **)((ULONG)rsc_buffer + header->rsh_trindex);
  for (i = 0; i < header->rsh_ntree; i++) flip_long ((WORD *)&ptrindex [i]);

  /***** flip data and mask of iconblocks *****/

  piconblk = (ICONBLK *)((ULONG)rsc_buffer + header->rsh_iconblk);

  for (i = 0; i < header->rsh_nib; i++)
  {
    words = piconblk [i].ib_wicon / 16 * piconblk [i].ib_hicon;

    pmask = (WORD *)((ULONG)rsc_buffer + (ULONG)piconblk [i].ib_pmask);
    for (j = 0; j < words; j++) flip_word ((BYTE *)&pmask [j]);

    pdata = (WORD *)((ULONG)rsc_buffer + (ULONG)piconblk [i].ib_pdata);
    for (j = 0; j < words; j++) flip_word ((BYTE *)&pdata [j]);
  } /* for */

  /***** flip data of bitblocks *****/

  pbitblk = (BITBLK *)((ULONG)rsc_buffer + header->rsh_bitblk);

  for (i = 0; i < header->rsh_nbb; i++)
  {
    words = pbitblk [i].bi_wb / 2 * pbitblk [i].bi_hl;

    pdata = (WORD *)((ULONG)rsc_buffer + (ULONG)pbitblk [i].bi_pdata);
    for (j = 0; j < words; j++) flip_word ((BYTE *)&pdata [j]);
  } /* for */

  handle = Fcreate (destname, 0x0);

  if (handle < 0)
  {
    printf ("Error in creating %s\n", destname);
    return;
  } /* if */

  size = Fwrite (handle, size, rsc_buffer);
  Fclose (handle);
} /* INTELtoMC68K */

/*****************************************************************************/

GLOBAL WORD main (argc, argv)
WORD argc;
BYTE *argv [];

{
  printf ("\n\n***** GEM resource converter [1.2] *****\n\n");

  rsc_buffer = (UBYTE *)Malloc (MAX_RS);
  header     = (RSHDR *)rsc_buffer;

  if (rsc_buffer == NULL)
  {
    printf ("Error in allocating buffer for resource file\n");
    return (1);
  } /* if */

  if (argc < 3)
  {
    printf ("Source resource file (without suffix .RSC): ");
    gets (srcname);
    printf ("Direction: 0 = MC68000 -> INTEL\n");
    printf ("           1 = INTEL   -> MC68000\n");
    printf ("Direction: ");
    gets (direction);
  } /* if */
  else
  {
    strcpy (srcname,   argv [1]);
    strcpy (direction, argv [2]);
  } /* else */

  strcat (srcname,  ".RSC");
  strupper (srcname);
  strcpy (destname, srcname);

  if (direction [0] == '0')
    MC68KtoINTEL ();
  else
    INTELtoMC68K ();

  printf ("Conversion finished\n");
  return (0);
} /* main */

