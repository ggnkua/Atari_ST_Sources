/* Konverter fÅr IMG-Dateien          */
/* Speichert die aktuelle Farbtabelle */
/* im Kopf einer IMG-Datei ab         */

#include <stdio.h>
#include <string.h>
#include <portab.h>
#include <aes.h>
#include <vdi.h>

#if GEMDOS
#include <osbind.h>
#define Mavail() (LONG)Malloc (-1L)
#else
#include <gemdos.h>
#include <dosbind.h>
#endif

/****** Konstanten ***********************************************************/

#define SCREEN 1

#define DRIVESEP   ':'
#define PATHSEP    '\\'
#define SUFFSEP    '.'

#define RGB     0
#define CYM     1
#define HLS     2
#define PANTONE 3

#define MAX_COLORS 256

/****** Typen ****************************************************************/

typedef struct
{
  UWORD red;
  UWORD green;
  UWORD blue;
} RGB_LIST;

typedef struct img_header
{
  WORD version;
  WORD headlen;
  WORD planes;
  WORD pat_run;
  WORD pix_width;
  WORD pix_height;
  WORD sl_width;
  WORD sl_height;
} IMG_HEADER;

typedef struct ximg_header
{
 WORD      version;
 WORD      headlen;
 WORD      planes;
 WORD      pat_run;
 WORD      pix_width;
 WORD      pix_height;
 WORD      sl_width;
 WORD      sl_height;
 BYTE      x_id [4];         /* contains XIMG */
 WORD      color_model;      /* 0 = RGB,1 = CYM,2 = HLS, etc. */
 RGB_LIST  color_table [];   /* open array, length 2^planes */
} XIMG_HEADER;

/****** Variablen ************************************************************/

#if DR_C | LASER_C | MW_C
EXTERN WORD    gl_apid;          /* Identifikation fÅr Applikation */
#else
GLOBAL WORD    gl_apid;          /* Identifikation fÅr Applikation */
#endif

GLOBAL WORD    contrl [12];
GLOBAL WORD    intin [128];
GLOBAL WORD    ptsin [128];
GLOBAL WORD    intout [128];
GLOBAL WORD    ptsout [128];

LOCAL  WORD    work_in [103];
LOCAL  WORD    work_out [57];
LOCAL  WORD    vdi_handle;
LOCAL  BYTE    fs_iinpath [128];
LOCAL  BYTE    fs_iinsel [13];
LOCAL  WORD    fs_iexbutton;

/****** Prototypen ***********************************************************/

LOCAL VOID    open_work   _((VOID));
LOCAL VOID    close_work  _((VOID));
LOCAL VOID    flip_word   _((UBYTE *adr));
LOCAL BOOLEAN conv_img    _((BYTE *filename, BYTE *dst_name));
LOCAL VOID    file_split  _((BYTE *fullname, WORD *drive, BYTE *path, BYTE *filename, BYTE *ext));
LOCAL WORD    get_path    _((BYTE *path, WORD drive));
LOCAL BOOLEAN set_path    _((BYTE *path));
LOCAL BOOLEAN select_file _((BYTE *name, BYTE *suffix, BYTE *filename));

/*****************************************************************************/

LOCAL VOID open_work ()

{
  WORD i;

  i = appl_init ();                       /* Applikationsnummer besorgen */

#if (LATTICE_C | TURBO_C) | (GEM & (GEM2 | GEM3 | XGEM))
  gl_apid = i;                            /* gl_apid nicht extern */
#endif

  for (i = 0; i < 103; i++) work_in [i] = 1;

  work_in [0]  = SCREEN; /* device handle  */
  work_in [10] = 2;      /* RC Koordinaten */

  vdi_handle = graf_handle (&i, &i, &i, &i);
  v_opnvwk (work_in, &vdi_handle, work_out); /* virtuell îffnen */
} /* open_work */

/*****************************************************************************/

LOCAL VOID close_work ()

{
  v_clsvwk (vdi_handle);
  appl_exit ();
} /* close_work */

/*****************************************************************************/

LOCAL VOID flip_word (adr)
REG UBYTE *adr;

{
  REG UBYTE c;

  c       = adr [0];
  adr [0] = adr [1];
  adr [1] = c;
} /* flip_word */

/*****************************************************************************/

LOCAL BOOLEAN conv_img (filename, dst_name)
BYTE *filename;
BYTE *dst_name;

{
  WORD        i;
  WORD        f;
  WORD        rgb [3];
  WORD        size_header;
  WORD        color;
  LONG        img_len, colors;
  UBYTE       *img_buffer;
  BYTE        x_id [5];
  RGB_LIST    rgb_list [MAX_COLORS];
  IMG_HEADER  *img_header;
  XIMG_HEADER x_header, *px_header;

  f = Fopen (filename, 0);

#if MSDOS | FLEXOS
  if (DOS_ERR) f = -32 - f;
#endif

  if (f < -3)
  {
    form_alert (1, "[3][Datei nicht gefunden!][ ABBRUCH ]");
    return (FALSE);
  } /* if */
  else
  {
    size_header = (WORD)sizeof (IMG_HEADER);
    img_len     = Fseek (0L, f, 2);

#if MSDOS | FLEXOS
    if (img_len > 65535L)
    {
      form_alert (1, "[3][IMG-Datei zu gro·!][ ABBRUCH ]");
      return (FALSE);
    } /* if */
#endif

    img_buffer  = (UBYTE *)Malloc (img_len);
    if (img_buffer == NULL)
    {
      form_alert (1, "[3][Zu wenig Speicher|zum Konvertieren!][ ABBRUCH ]");
      return (FALSE);
    } /* if */

    Fseek (0L, f, 0);
    img_len    = Fread (f, img_len, img_buffer);
    img_header = (IMG_HEADER *)img_buffer;
    px_header  = (XIMG_HEADER *)img_buffer;
    Fclose (f);

    strncpy (x_id, px_header->x_id, 5);
    x_id [4] = EOS;

#if I8086
    {
      WORD headlen;

      headlen = img_header->headlen;
      flip_word ((UBYTE *)&headlen);
      for (i = 0; i < headlen; i++) flip_word (&img_buffer [i * 2]);
    } /* #if */
#endif


    if ((img_header->headlen > 8) && (strcmp (x_id, "XIMG") == 0))
    {
      form_alert (1, "[3][IMG-Datei liegt schon im|erweiterten Format vor!][ ABBRUCH ]");
      return (FALSE); /* schon konvertiert */
    } /* if */

    colors = 1 << img_header->planes;
    if (colors > MAX_COLORS) colors = MAX_COLORS;

    for (i = 0; i < colors; i++)
    {
#if GEMDOS
      color = Setcolor (i, -1); /* get ATARI ST colors */

      rgb [0] = (WORD)(((color & 0x0700) >> 8) * 1000L / 7); /* red */
      rgb [1] = (WORD)(((color & 0x0070) >> 4) * 1000L / 7); /* green */
      rgb [2] = (WORD)(((color & 0x0007)) * 1000L / 7);      /* blue */
#else
      vq_color (vdi_handle, i, FALSE, rgb);
#endif

      rgb_list [i].red   = rgb [0];
      rgb_list [i].green = rgb [1];
      rgb_list [i].blue  = rgb [2];
    } /* for */

    x_header.version     = img_header->version;
    x_header.headlen     = (WORD)(sizeof (XIMG_HEADER) + colors * sizeof (RGB_LIST)) / 2;
    x_header.planes      = img_header->planes;
    x_header.pat_run     = img_header->pat_run;
    x_header.pix_width   = img_header->pix_width;
    x_header.pix_height  = img_header->pix_height;
    x_header.sl_width    = img_header->sl_width;
    x_header.sl_height   = img_header->sl_height;
    strncpy (x_header.x_id, "XIMG", 4);
    x_header.color_model = RGB;

#if I8086
    flip_word ((UBYTE *)&x_header.version);
    flip_word ((UBYTE *)&x_header.headlen);
    flip_word ((UBYTE *)&x_header.planes);
    flip_word ((UBYTE *)&x_header.pat_run);
    flip_word ((UBYTE *)&x_header.pix_width);
    flip_word ((UBYTE *)&x_header.pix_height);
    flip_word ((UBYTE *)&x_header.sl_width);
    flip_word ((UBYTE *)&x_header.sl_height);
    flip_word ((UBYTE *)&x_header.color_model);

    for (i = 0; i < colors; i++)
    {
      flip_word ((UBYTE *)&rgb_list [i].red);
      flip_word ((UBYTE *)&rgb_list [i].green);
      flip_word ((UBYTE *)&rgb_list [i].blue);
    } /* for */
#endif

    f = Fcreate (dst_name, 0);

#if MSDOS | FLEXOS
    if (DOS_ERR) f = -32 - f;
#endif

    if (f < -3)
    {
      form_alert (1, "[3][Datei konnte nicht|erzeugt werden!][ ABBRUCH ]");
      return (FALSE);
    } /* if */
    else
    {
      Fwrite (f, (LONG)sizeof (XIMG_HEADER), &x_header);
      Fwrite (f, colors * sizeof (RGB_LIST), rgb_list);
      Fwrite (f, img_len - size_header, &img_buffer [size_header]);

      Mfree (img_buffer);
      Fclose (f);
    } /* else */

    return (TRUE);
  } /* else */
} /* conv_img */

/*****************************************************************************/

LOCAL VOID file_split (fullname, drive, path, filename, ext)
BYTE *fullname;
WORD *drive;
BYTE *path, *filename, *ext;

{
  BYTE s [128];
  BYTE name [12];
  BYTE *p, *f;

  strcpy (s, fullname);

  p = strchr (s, DRIVESEP);

  if (p == NULL)                                /* Kein Laufwerk */
  {
    if (drive != NULL) *drive = Dgetdrv ();
    p = s;
  } /* if */
  else
  {
    if (drive != NULL) *drive = p [-1] - 'A';
    p++;
  } /* else */

  f = strrchr (p, PATHSEP);

  if (f == NULL)                                /* Kein Pfad */
  {
    strcpy (name, p);                           /* Dateinamen retten */
    if (path != NULL) get_path (path, 0);
  } /* if */
  else
  {
    strcpy (name, f + 1);                       /* Dateinamen retten */
    f [1] = EOS;

    if (path != NULL)
    {
      if (*p != PATHSEP)                        /* Keine Root */
        get_path (path, 0);
      else
        *path = EOS;

      strcat (path, p);
    } /* if */
  } /* else */

  if (filename != NULL) strcpy (filename, name);

  if (ext != NULL)
  {
    p = strrchr ((filename != NULL) ? filename : name, SUFFSEP);

    if (p == NULL)
      *ext = EOS;
    else
    {
      strcpy (ext, p + 1);
      if (filename != NULL) *p = EOS;
    } /* else */
  } /* if */
} /* file_split */

/*****************************************************************************/

LOCAL WORD get_path (path, drive)
BYTE *path;
WORD drive;

{
  BYTE s [64], sep [2];
  WORD ret;

  path [0] = EOS;

  ret = Dgetpath (s, drive);

  if (*s)
  {

#if MSDOS | FLEXOS
    strcpy (path + 1, s);
    path [0] = PATHSEP;
#endif

#if GEMDOS
    strcpy (path, s);
#endif

  } /* if */

  sep [0] = PATHSEP;
  sep [1] = EOS;

  strcat (path, sep);
  return (ret);
} /* get_path */

/*****************************************************************************/

GLOBAL BOOLEAN set_path (path)
BYTE *path;

{
  BYTE s [64];
  BYTE *p;
  WORD l;

  strcpy (s, path);

  if (*s)
  {
    p = s;
    if (p [1] == DRIVESEP) p += 2;

    l = (WORD)strlen (p);
    if ((l > 1) && (p [l - 1] == PATHSEP)) p [l - 1] = EOS;
  } /* if */

#if GEMDOS
  return ((WORD)Dsetpath (s) == 0);
#else
  Dsetpath (s);
  return (! DOS_ERR);
#endif
} /* set_path */

/*****************************************************************************/

LOCAL BOOLEAN select_file (name, suffix, filename)
BYTE *name, *suffix, *filename;

{
  WORD i;
  BYTE s [80];

  if (*suffix)                          /* Suffix Ñndern */
  {
    i = (WORD)strlen (fs_iinpath);
    while (fs_iinpath [i] != PATHSEP) i--;
    fs_iinpath [i + 1] = EOS;
    strcat (fs_iinpath, suffix);
  } /* if */

  name [12] = EOS;
  if (*name) strcpy (fs_iinsel, name);  /* Default-Name */
  fsel_input (fs_iinpath, fs_iinsel, &fs_iexbutton);

  strcpy (s, fs_iinpath);               /* Path aufbereiten */
  i = (WORD)strlen (s);
  while (s [i] != PATHSEP) i--;
  s [i + 1] = EOS;

  if (*fs_iinsel)
  {
    strcpy (filename, s);
    strcat (filename, fs_iinsel);
  } /* if */
  else
  {
    filename [0] = EOS;                 /* Keinen Dateinamen gewÑhlt */
    fs_iexbutton = 0;                   /* Abbruch */
  } /* else */

  return (fs_iexbutton != 0);
} /* select_file */

/*****************************************************************************/

GLOBAL WORD main ()

{
  WORD act_drive, drive;
  BYTE act_path [80];
  BYTE img_name [80];
  BYTE dst_name [80];
  BYTE filename [80];
  BYTE path [80];
  BYTE fname [80];
  BYTE ext [4];
  BYTE s [80];

  open_work ();
  act_drive = Dgetdrv ();
  get_path (act_path, 0);

  sprintf (fs_iinpath, "A:%s*.GEM", act_path);
  fs_iinpath [0] += Dgetdrv ();           /* Standard-Laufwerk */
  fs_iinsel [0]   = EOS;                  /* Leerer Dateiname */
  strcpy (img_name, "");
  strcpy (filename, "");

  while (select_file (filename, "*.IMG", img_name) && *img_name)
  {
    file_split (img_name, &drive, path, fname, ext);
    sprintf (filename, "X%s", fname);
    filename [8] = EOS;
    sprintf (img_name, "%s.%s", fname, ext);
    sprintf (dst_name, "%s.%s", filename, ext);

    Dsetdrv (drive);
    set_path (path);

    if (conv_img (img_name, dst_name))
    {
      sprintf (s, "[1][%s->%s|ins erweiterte|IMG-Format konvertiert.][ OK ]", img_name, dst_name);
      form_alert (1, s);
    } /* if */

    strcpy (filename, "");
  } /* while */

  Dsetdrv (act_drive);
  set_path (act_path);
  close_work ();

  return (0);
} /* main */
