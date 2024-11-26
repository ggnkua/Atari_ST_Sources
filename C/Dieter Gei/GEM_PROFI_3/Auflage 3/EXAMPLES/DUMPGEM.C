/* Listet GEM-Metadateien im Klartext auf.         */
/* Alle Funktionen bis GEM/3 werden berÅcksichtigt */

#include <stdio.h>
#include <portab.h>
#include <string.h>

#if GEMDOS
#include <osbind.h>
#else
#include <gemdos.h>
#include <dosbind.h>
#endif

#define MAX_MLEN  65535L /* max metafile length       */
#define MAX_VDI     200  /* vdi functions             */
#define MAX_ESC     200  /* escape functions          */
#define MAX_GDP      20  /* drawing primitives        */
#define MAX_VWM     200  /* v_write_meta subfunctions */
#define MAX_BEZ      20  /* max bezier list           */

#define OP_ESC        5
#define OP_BEZ        6
#define OP_BEZFILL    9
#define OP_GDP       11  /* watch for v_bez_on/off       */
#define BEZ_SUB      13  /* subcode for bezier functions */
#define VWM_SUBCODE  99  /* subcode for v_write_meta     */

#define V_SETRGBI 18500  /* subcode for v_setrgbi */
#define V_TOPBOT  18501  /* subcode for v_topbot  */

/****** Typen ****************************************************************/

typedef struct metaheader
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
} METAHEADER;

/****** Variablen ************************************************************/

LOCAL WORD       contrl [12];
LOCAL WORD       intin [256];
LOCAL WORD       ptsin [256];
LOCAL WORD       n_pts;
LOCAL WORD       n_int;

LOCAL BYTE       namebuffer [32767];
LOCAL BYTE       meta_name [80];
LOCAL ULONG      meta_len;
LOCAL ULONG      meta_index;
LOCAL UWORD      *meta_buffer;
LOCAL METAHEADER *meta_header;

LOCAL BYTE       *vdi_list [MAX_VDI];
LOCAL BYTE       *esc_list [MAX_ESC];
LOCAL BYTE       *gdp_list [MAX_GDP];
LOCAL BYTE       *vwm_list [MAX_VWM];
LOCAL BYTE       *bez_list [MAX_BEZ];
LOCAL BYTE       *undefined  = "undefined";
LOCAL BYTE       *vwm_text   = "v_write_meta (vdi_handle, num_ints, ints, num_pts, pts)";
LOCAL BYTE       *ndc_rc [3] = {"NDC", "reserved", "RC"};

/****** Prototypen ***********************************************************/

LOCAL BOOLEAN file_exist   _((BYTE *filename));
LOCAL VOID    strupper     _((BYTE *s));
LOCAL VOID    flip_word    _((BYTE *adr));
LOCAL BOOLEAN get_list     _((VOID));
LOCAL BOOLEAN read_meta    _((BYTE *meta_name));
LOCAL VOID    show_header  _((VOID));
LOCAL WORD    get_word     _((VOID));
LOCAL BOOLEAN get_code     _((VOID));
LOCAL BYTE    *get_command _((VOID));
LOCAL VOID    show_meta    _((VOID));

/*****************************************************************************/

LOCAL BOOLEAN file_exist (filename)
BYTE *filename;

{
#if GEMDOS
  return (Fsfirst (filename, 0x00) == 0);
#else
  return (Fsfirst (filename, 0x00) > 0);
#endif
} /* file_exist */

/*****************************************************************************/

LOCAL VOID strupper (s)
BYTE *s;

{
  while (*s)
  {
    if (*s >= 'a') *s &= 0xDF;
    s++;
  } /* while */
} /* strupper */

/*****************************************************************************/

LOCAL VOID flip_word (adr)
BYTE *adr;

{
  BYTE c;

  c       = adr [0];
  adr [0] = adr [1];
  adr [1] = c;
} /* flip_word */

/*****************************************************************************/

LOCAL BOOLEAN get_list ()

{
  FILE    *fp;
  BYTE    *funcname;
  BYTE    s [255];
  WORD    i, intin_0;
  WORD    opcode, subcode;
  BOOLEAN ok;

  fp = fopen ("DUMPGEM.DAT", "r");

  if (fp == NULL)
  {
    printf ("DUMPGEM.DAT not found\n");
    ok = FALSE;
  } /* if */
  else
  {
    for (i = 0; i < MAX_VDI; i++) vdi_list [i] = undefined;
    for (i = 0; i < MAX_ESC; i++) esc_list [i] = undefined;
    for (i = 0; i < MAX_GDP; i++) gdp_list [i] = undefined;
    for (i = 0; i < MAX_VWM; i++) vwm_list [i] = vwm_text;
    for (i = 0; i < MAX_BEZ; i++) bez_list [i] = undefined;

    funcname = namebuffer;

    while (fgets (s, 255, fp) != NULL)
    {
      if (*s != '/')
      {
        sscanf (s, "%d,", &opcode);
        sscanf (s +  4, "%d,", &subcode);
        sscanf (s + 10, "%d,", &intin_0);
        strcpy (funcname, s + 15);
        funcname [strlen (funcname) - 1] = EOS; /* cut off \n */

        if (opcode == OP_ESC ||
            opcode == OP_GDP ||
            opcode == OP_BEZ ||
            opcode == OP_BEZFILL)
        {
          switch (opcode)
          {
            case OP_ESC     : if (subcode == V_SETRGBI) subcode = 150;
                              if (subcode == V_TOPBOT)  subcode = 151;

                              if (subcode == VWM_SUBCODE)
                                vwm_list [intin_0] = funcname;
                              else
                                esc_list [subcode] = funcname;
                              break;
            case OP_GDP     : if (subcode == BEZ_SUB)
                              {
                                if (intin_0 == 0)              /* v_bez_off */
                                  gdp_list [MAX_GDP - 1] = funcname;
                                else                           /* v_bez_on */
                                  gdp_list [MAX_GDP - 2] = funcname;
                              } /* if */
                              else
                                gdp_list [subcode] = funcname;
                              break;
            case OP_BEZ     : if (subcode == BEZ_SUB)
                                bez_list [opcode] = funcname;
                              else
                                vdi_list [opcode] = funcname;
                              break;
            case OP_BEZFILL : if (subcode == BEZ_SUB)
                                bez_list [opcode] = funcname;
                              else
                                vdi_list [opcode] = funcname;
                              break;
          } /* switch */
        } /* if */
        else
          vdi_list [opcode] = funcname; /* no special case */
      } /* if */

      funcname += strlen (funcname) + 1;
    } /* while */

/*
for (i = 0; i < MAX_VDI; i++) printf ("vdi_list [%3d] = %s\n", i, vdi_list [i]);
for (i = 0; i < MAX_ESC; i++) printf ("esc_list [%3d] = %s\n", i, esc_list [i]);
for (i = 0; i < MAX_GDP; i++) printf ("gdp_list [%3d] = %s\n", i, gdp_list [i]);
for (i = 0; i < MAX_VWM; i++) printf ("vwm_list [%3d] = %s\n", i, vwm_list [i]);
for (i = 0; i < MAX_BEZ; i++) printf ("bez_list [%3d] = %s\n", i, bez_list [i]);
*/

    ok = TRUE;
  } /* if */

  return (ok);
} /* get_list */

/*****************************************************************************/

LOCAL BOOLEAN read_meta (meta_name)
BYTE *meta_name;

{
  WORD    handle;

  meta_len    = MAX_MLEN;
  meta_buffer = (UWORD *)Malloc (meta_len);

  if (meta_buffer != NULL)
  {
    if (file_exist (meta_name))
    {
      handle   = Fopen (meta_name, 0);
      meta_len = Fread (handle, meta_len, meta_buffer);

#if M68000
      {
	LONG i;
	for (i = 0; i < meta_len / 2; i++) flip_word ((BYTE *)&meta_buffer [i]);
      } /* #if */
#endif

      meta_header = (METAHEADER *)meta_buffer;
      meta_index  = meta_header->headlen;

      Fclose (handle);
      return (TRUE);
    } /* if */
    else
    {
      printf ("%s not found\n", meta_name);
      return (FALSE);
    } /* else */
  } /* if */
  else
  {
    printf ("Not enough memory to allocate buffer\n");
    return (FALSE);
  } /* else */
} /* read_meta */

/*****************************************************************************/

LOCAL VOID show_header ()

{
  printf ("\nMetafile: %s\n\n", meta_name);

  printf ("metafile id           : %6d\n", meta_header->id);
  printf ("header length         : %6d\n", meta_header->headlen);
  printf ("GEM version           : %4d.%d\n", meta_header->version / 100, meta_header->version % 100);
  printf ("NDC/RC flag           : %6s\n", ndc_rc [meta_header->transform]);
  printf ("extent min x          : %6d\n", meta_header->min_x);
  printf ("extent min y          : %6d\n", meta_header->min_y);
  printf ("extent max x          : %6d\n", meta_header->max_x);
  printf ("extent max y          : %6d\n", meta_header->max_y);
  printf ("page width            : %3d.%02d cm\n", meta_header->pwidth / 100, meta_header->pwidth % 100);
  printf ("page height           : %3d.%02d cm\n", meta_header->pheight / 100, meta_header->pheight % 100);
  printf ("window lower left x   : %6d\n", meta_header->ll_x);
  printf ("window lower left y   : %6d\n", meta_header->ll_y);
  printf ("window upper right x  : %6d\n", meta_header->ur_x);
  printf ("window upper right y  : %6d\n", meta_header->ur_y);
  printf ("bit image opcode flag : %6d\n", meta_header->bit_image);
  printf ("\n\n");
} /* show_header */

/*****************************************************************************/

LOCAL WORD get_word ()

{
  if (meta_index > meta_len) return (-1);
  return (meta_buffer [meta_index++]);
} /* get_word */

/*****************************************************************************/

LOCAL BOOLEAN get_code ()

{
  WORD i;

  contrl [0] = get_word ();
  if (contrl [0] == -1) return (FALSE);

  contrl [1] = get_word ();
  contrl [3] = get_word ();
  contrl [5] = get_word ();

  n_pts = contrl [1] * 2;
  n_int = contrl [3];

  for (i = 0; i < n_pts; i++) ptsin [i] = get_word ();
  for (i = 0; i < n_int; i++) intin [i] = get_word ();

  return (TRUE);
} /* get_code */

/*****************************************************************************/

LOCAL BYTE *get_command ()

{
  BYTE *command;
  WORD opcode;
  WORD subcode;

  opcode  = contrl [0];
  subcode = contrl [5];

  if (opcode == OP_ESC ||
      opcode == OP_GDP ||
      opcode == OP_BEZ ||
      opcode == OP_BEZFILL)
  {
    switch (opcode)
    {
      case OP_ESC     : if (subcode == V_SETRGBI) subcode = 150;
                        if (subcode == V_TOPBOT)  subcode = 151;

                        if (subcode == VWM_SUBCODE)
                          command = vwm_list [intin [0]];
                        else
                          command = esc_list [subcode];
                        break;
      case OP_GDP     : if (subcode == BEZ_SUB)
                        {
                          if (contrl [1] == 0)          /* v_bez_off */
                            command = gdp_list [MAX_GDP - 1];
                          else                           /* v_bez_on */
                            command = gdp_list [MAX_GDP - 2];

                          n_pts = 0;
                        } /* if */
                        else
                          command =  gdp_list [subcode];
                        break;
      case OP_BEZ     : if (subcode == BEZ_SUB)
                          command = bez_list [opcode];
                        else
                          command = vdi_list [opcode];
                        break;
      case OP_BEZFILL : if (subcode == BEZ_SUB)
                          command = bez_list [opcode];
                        else
                          command = vdi_list [opcode];
                        break;
    } /* switch */
  } /* if */
  else
    command = vdi_list [opcode]; /* no special case */

  return (command);
} /* get_command */

/*****************************************************************************/

LOCAL VOID show_meta ()

{
  WORD  count;
  WORD  i;
  BYTE *command;

  count = 0;

  while (get_code ())
  {
    count++;
    command = get_command ();
    printf ("***** Command #%d *****\n\n", count);
    printf ("%s\n", command);

    printf ("contrl [0]: %d\n", contrl [0]);
    printf ("contrl [1]: %d\n", contrl [1]);
    printf ("contrl [3]: %d\n", contrl [3]);
    printf ("contrl [5]: %d\n", contrl [5]);
    printf ("\n");

    if (n_pts > 0)
    {
      for (i = 0; i < n_pts; i += 2)
      {
        printf ("ptsin [%d] = x = %d\n", i, ptsin [i]);
        printf ("ptsin [%d] = y = %d\n", i + 1, ptsin [i + 1]);
     } /* for */
      printf ("\n");
    } /* if */

    if (n_int > 0)
    {
      for (i = 0; i < n_int; i++) printf ("intin [%d] = %d\n", i, intin [i]);
      printf ("\n");
    } /* if */

    printf ("\n");
  } /* while */
} /* show_meta */

/*****************************************************************************/

GLOBAL WORD main (argc, argv)
WORD argc;
BYTE *argv [];

{
  if (argc < 2)
  {
    printf ("Dump which metafile (without suffix .GEM): ");
    gets (meta_name);
  } /* if */
  else
    strcpy (meta_name, argv [1]);

  if (*meta_name)
  {
    strupper (meta_name);
    strcat (meta_name, ".GEM");

    if (get_list () && read_meta (meta_name))
    {
      show_header ();
      show_meta ();
    } /* if */
  } /* if */

  return (0);
} /* main */
