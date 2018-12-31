/* (X)IMG snapshot utility (c) 1994 by Eero Tamminen
 * (puujalka@modeemi.cs.tut.fi)
 *
 * (X)IMG line packing function (c) 1994 by Thomas Binder
 * (binder@rbg.informatik.th-darmstadt.de)
 */

/* ++tb on 05/15/95:
 * - some small patches to make Pure C and other more-ANSI-like
 *   compilers happy
 * - added MagiC-workaround
 * - fixed wrong error-handling in Fwrite-calls
 * - fixed small bug: Mouse was missing when the alert after saving
 *   the snapshot appeared
 * - fixed getaccenv
 * - removed menu_id from main because it was never used
 */

#include <osbind.h>	/* pterm() */
#include <string.h>	/* memcpy(), strcpy() etc. */
#include <stdlib.h>	/* getenv() */

/* system includes */
#ifdef __GNUC__
#include <aesbind.h>
#include <vdibind.h>
typedef signed short   WORD;
typedef unsigned short UWORD;
#endif
#ifdef __PUREC__
#include <aes.h>
#include <vdi.h>
#include <portab.h>
#define short	int
short	gl_apid;
#endif
#ifdef __SOZOBONX__
#include <xgemfast.h>    /* AES / VDI      */
#endif

extern short _app;

#ifndef FALSE
#define FALSE 0
#define TRUE  !FALSE
#endif

/* define some texts */
#define ACC_NAME  "  (X)IMG Snapshot "
#define ALERT_AREA  "[2][ (X)IMG-SNAPSHOT v1.1 |1995 (C) Eero Tamminen | | Area to be saved... |][Freehand|Window|Screen]"
#define ALERT_COLOR  "[1][|Only 2-256 color modes... |][  OK  ]"
#define ALERT_DONE  "[1][|Image saved. |][  OK  ]"
#define ALERT_SAVE  "[3][|Save failed! |][ Hmm... ]"

struct BLOCK
{
  short x1;    /* 1st corner    */
  short y1;
  short x2;    /* size / 2nd corner  */
  short y2;
};

/* define GEM image */
typedef struct IMG_HEADER
{                 /* Header of GEM Image Files   */
  short version;  /* Img file format version (1) */
  short length;   /* Header length in words  (8) */
  short planes;   /* Number of bit-planes    (1) */
  short pat_len;  /* length of Patterns      (2) */
  short pix_w;    /* Pixel width in 1/1000 mmm  (372)    */
  short pix_h;    /* Pixel height in 1/1000 mmm (372)    */
  short img_w;    /* Pixels per line (=(x+7)/8 Bytes)    */
  short img_h;    /* Total number of lines               */
  long  magic;    /* Contains "XIMG" if standard color   */
  short paltype;  /* palette type (0 = RGB (short each)) */
} IMG_header;
#define XIMG      0x58494D47L

/* ------------------------------------
 * global variables
 */
/* some vdi arrays and global variables etc. */
static short vdi_handle, work_in[11], work_out[57],
      screen_planes, screen_colors,
      screen_w, screen_h;

static char *save_path;

/* VDI <-> Device palette order conversion matrixes:
 */
/* Four-plane device-vdi */
static short dev2vdi4[] = {0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,1};
/* Two-plane device-vdi */
static short dev2vdi2[] = {0,2,3,1};

static char tmp_buf[2048];	/* temp for a line from screen */
static char dst_buf[2048];	/* buf_1 converted into planar */
static char pack_buf[258];	/* for 1 line/bitplane packing */

/* ------------------------------------
 * Function prototypes.
 */
int  do_it(void);
int  select_area(short *x, short *y, short *w, short *h);
int  save_file(struct BLOCK *blk, char *filename);
int  save_header(short header, struct BLOCK *blk);
int  save_bitmaps(short header, struct BLOCK *blk);
WORD pack_img_line(char *source, char *dest, WORD byte_width);

/* GEM handling functions. */
void prg_init(void);
char *getaccenv(const char *var);
void get_savepath(char *(*get_env)(const char *var));

/* ------------------------------------
 * (main loop).
 */
void main()
{
  short  mbuf[8];

  prg_init();
  /* not acc -> snap and quit */
  if(_app)
  {
    get_savepath(getenv);
    do_it();
    appl_exit();
    Pterm(0);
  }

  get_savepath(getaccenv);
  menu_register(gl_apid, ACC_NAME);  /* register acc */

  /* Endless loop. */
  while (TRUE)
  {
    evnt_mesag(mbuf);
    if(mbuf[0] == AC_OPEN)
      do_it();
  }
}

/* ------------------------------------
 * Standard GEM startup.
 */
void prg_init()
{
  int i;

  gl_apid = appl_init();

  /* open virtual screen workstation (screen) */
  for(i = 0; i < 10; work_in[i ++] = 1);
  work_in[10] = 2;
  vdi_handle = graf_handle( &i, &i, &i, &i );
  v_opnvwk( work_in, &vdi_handle, work_out );
  screen_colors = work_out[13];
  screen_w = work_out[0];
  screen_h = work_out[1];

  /* get the number of bitplanes on screen */
  vq_extnd( vdi_handle, 1, work_out );
  screen_planes = work_out[4];
  v_clsvwk(vdi_handle);
}

/* Special getenv for accessories.
 * Get variables from system enviroment
 * instead of the process one.
 */
char *getaccenv(const char *var)
{
  char *string;

  shel_envrn(&string, (char *)var);
  if(string)
  {
    if(*string == '=')
      return(++string);
    else
      return("");
  }
  else
    return NULL;
}

/* Get the file save path (=CLIPBOARD)
 * As you can see, I'm in a need of some
 * documentation...
 */
void get_savepath(char *(*get_env)(const char *var))
{
  char *path;

  /* where's the clipboard directory and does it's drive exist */
  if((((path = (*get_env)("CLIPBRD")) != NULL)   ||
      ((path = (*get_env)("SCRAPDIR")) != NULL)) &&
     (Drvmap() & (1 << ((path[0] & 0xDF) - 'A')))
    )
    save_path = path;
  else
    if(Drvmap() & 4)			/* does C: exist? */
      save_path = "C:\\CLIPBRD";
    else
      save_path = "A:\\";
}


/* ---------------------
 * pack and save XIMG
 */
int do_it()
{
  struct BLOCK blk;
  short select, top_win, i, real_top;
  int save_ok;
  static int mode = 2, snap = 0;
  static char filename[] = "SNAP_000.IMG";

  /* Can't handle more than 8 bitplanes */
  if(screen_planes > 8)
  {
    form_alert(1, ALERT_COLOR);
    return(FALSE);
  }

  select = TRUE;
  /* select area to be saved */
  switch((mode = form_alert(mode, ALERT_AREA)))
  {
    /* draggable rubber band */
    case 1:
      wind_update(BEG_MCTRL);
      graf_mouse(THIN_CROSS, 0);
      wind_update(BEG_UPDATE);
      select = select_area(&blk.x1, &blk.y1, &blk.x2, &blk.y2);
      wind_update(END_UPDATE);
      wind_update(END_MCTRL);
      graf_mouse(ARROW, 0);
      if(!select)
        return(FALSE);
      break;
    /* get top window and it's work area (contents) */
    case 2:
      wind_get(0, WF_TOP, &top_win, &i, &i, &real_top);
      /* ++tb: Workaround for MagiC 2, which returns -2 as top-window
       * if it doesn't belong to your application (a trick to make
       * some old programs run). Does not work with Pure C because of
       * its `optimized' wind_get-call which ignores real_top.
       */
      if (top_win == -2)
      	top_win = real_top;
      wind_get(top_win, WF_WORKXYWH, &blk.x1, &blk.y1, &blk.x2, &blk.y2);
      break;
    /* whole screen */
    case 3:
      blk.x1 = blk.y1 = 0;
      blk.x2 = screen_w + 1;
      blk.y2 = screen_h + 1;
      break;
  }

  /* filename (into current directory) */
  filename[5] = snap / 100 + '0';
  filename[6] = snap % 100 / 10 + '0';
  filename[7] = snap % 10 + '0';
  snap = ++ snap % 1000;

  graf_mouse(M_OFF, 0);
  wind_update(BEG_UPDATE);
  save_ok = save_file(&blk, filename);
  graf_mouse(M_ON, 0);
  if(save_ok)
    form_alert(1, ALERT_DONE);
  else
    form_alert(1, ALERT_SAVE);
  wind_update(END_UPDATE);

  return(TRUE);
}

/* select area for saving */
int select_area(short *mx, short *my, short *w, short *h)
{
  short button = TRUE, i;

  /* mouse off */
  evnt_button(1, 1, 0, mx, my, &button, &i);
  /* mouse on, co-ordinates */
  evnt_button(257, 3, 0, mx, my, &button, &i);
  /* right button -> cancel */
  if(button == 2)
    return(FALSE);

  /* get area co-ordinates */
  graf_rubberbox(*mx, *my, 1, 1, w, h);
  return(TRUE);
}

/* save selected area into a file as an IMG */
int save_file(struct BLOCK *blk, char *filename)
{
  short handle;
  int error = FALSE;

  /* max. block width */
  if(blk->x2 > 2000)
    blk->x2 = 2000;

  /* CD where file is to be saved */
  Dsetdrv((save_path[0] & 0xDF) - 'A');
  Dsetpath(save_path);

  /* open IMG file: Use OS routines
   * instead of stdio functions.
   */
  if((handle = (short)Fcreate(filename, (short)0)) >= 0)
  {
    /* open workstation */
    v_opnvwk(work_in, &vdi_handle, work_out);
    /* save IMG header */
    if(save_header(handle, blk))
    {
      /* convert and save selected block line at the time */
      if(!save_bitmaps(handle, blk))
        error = TRUE;
    }
    else
      error = TRUE;
    /* close workstation */
    v_clsvwk(vdi_handle);
  }
  else
    error = TRUE;

  Fclose(handle);

  if(error)
    return(FALSE);
  else
    return(TRUE);
}

/* save IMG header and XIMG palette */
int save_header(short handle, struct BLOCK *blk)
{
  IMG_header image;
  short rgb[3], i, idx, error;

  /* only resolutions with a palette (<= 256 colors) */
  if((screen_planes > 8) && (screen_colors != (1 << screen_planes)))
    return(FALSE);

  /* setup GEM image header */
  image.version = 1;              /* Img file format version (1) */
  if(screen_planes == 1)
    image.length  = 8;            /* Header length in words  (8) */
  else
    image.length  = 11 + screen_colors * 3;
  image.planes  = screen_planes;  /* Number of bit-planes    (1) */
  image.pat_len = 2;              /* length of Patterns      (2) */
  image.pix_w   = 372;            /* Pixel width in 1/1000 mmm  (372)    */
  image.pix_h   = 372;            /* Pixel height in 1/1000 mmm (372)    */
  image.img_w   = blk->x2;        /* Pixels per line (=(x+7)/8 Bytes)    */
  image.img_h   = blk->y2;        /* Total number of lines in picture    */
  image.magic   = XIMG;           /* Contains "XIMG" if standard color   */
  image.paltype = 0;              /* palette type (0 = RGB (short each)) */

  /* write IMG header info */
  error = -(Fwrite(handle, 16L, (char *)&(image.version)) != 16L);

  /* if colors, add XIMG header info */
  if((screen_planes > 1) && (error >= 0))
  {
    error = -(Fwrite(handle, 6L, (char *)&(image.magic)) != 6L);

    /* save VDI palette */
    for(i = 0; i < screen_colors; i ++)
    {
      switch(screen_planes)
      {
        case 2:
          idx = dev2vdi2[i];
          break;
        case 4:
          idx = dev2vdi4[i];
          break;
        default:
          idx = i;
      }
      vq_color(vdi_handle, idx, 0, rgb);
      if(error < 0)
        return(FALSE);
      else
      {
        if (Fwrite(handle, 6L, (char *)(rgb)) != 6L)
          return(FALSE);
      }
    }
  }
  return(TRUE);
}

/* convert and save the selected area into IMG */
int save_bitmaps(short handle, struct BLOCK *blk)
{
  static char opcode[] = {0, 0, 0xff, 0};
  short bytes, packed, width, i, pxy[8], error;
  int aligning = FALSE, scan_repeat = 1, compare;
  MFDB screen, temp, dest;
  char *buf;

  /* setup memory description blocks */
  width = (blk->x2 + 15) & 0xFFF0;  /* word aligned */
  screen.fd_addr  = (char *)0;
  temp.fd_addr    = tmp_buf;        /* address      */
  temp.fd_w       = blk->x2;        /* width        */
  temp.fd_wdwidth = width >> 4;     /* width / 16   */
  temp.fd_h       = 1;              /* height       */
  temp.fd_stand   = 0;              /* formt=device */
  temp.fd_nplanes = screen_planes;  /* bitplanes    */
  dest.fd_addr    = dst_buf;
  dest.fd_w       = blk->x2;
  dest.fd_wdwidth = width >> 4;
  dest.fd_h       = 1;
  dest.fd_stand   = 1;              /* formt=planar */
  dest.fd_nplanes = screen_planes;

  /* scan_repeat search length */
  compare = (width >> 3) * screen_planes;
  /* byte / word alignment */
  bytes = (blk->x2 + 7) >> 3;
  if(width != (bytes << 3))
    aligning = TRUE;
  width --;

  /* setup raster copy co-ordinates */
  blk->y2 += blk->y1;
  pxy[0] = blk->x1;
  pxy[2] = blk->x1 + blk->x2 - 1;
  pxy[4] = 0;
  pxy[5] = 0;
  pxy[6] = blk->x2 - 1;
  pxy[7] = 0;
  do
  {
    /* copy current line into buffer */
    pxy[1] = pxy[3] = blk->y1;
    vro_cpyfm(vdi_handle, S_ONLY, pxy, &screen, &temp);

    /* check scan_line repeat */
    scan_repeat = 1;
    while (pxy[1] < (blk->y2 - 1))
    {
      pxy[1] = ++pxy[3];
      vro_cpyfm(vdi_handle, S_ONLY, pxy, &screen, &dest);
      if (memcmp(dst_buf, tmp_buf, compare))
        break;
      scan_repeat++;
    }

    if(scan_repeat > 1)
    {
      /* save opcodes and a line repeat count */
      opcode[3] = scan_repeat;
      error = -(Fwrite(handle, 4L, opcode) != 4L);
    }

    /* transfrom line from device into standard (planar) format */
    vr_trnfm(vdi_handle, &temp, &dest);

    /* pack and save line, plane by plane */
    buf = dst_buf;
    for(i = 0; i < screen_planes; i ++)
    {
      /* pack and save one line/plane */
      packed = pack_img_line(buf, pack_buf, bytes);
      error = -(Fwrite(handle, (long)packed, pack_buf) != packed);

      /* check for write errors */
      if(error < 0)
        return(FALSE);
      else
        buf += bytes;
      if(aligning)      /* byte <-> word alignment  */
        buf ++;
    }
    blk->y1 += scan_repeat;
  } while (blk->y1 <= blk->y2);

  return(TRUE);
}

/* --------------------------------------------------------------------
 * packimg.c as of 11/02/94
 *
 * (c) 1994 by Thomas Binder (binder@rbg.informatik.th-darmstadt.de),
 * Johann-Valentin-May-Straže 7, 64665 Alsbach-H„hnlein, Germany
 *
 * Contains a routine that packs a scanline for an (X)IMG-file.
 *
 * Permission is granted to spread this routine, but only the .c- and
 * the .h-file together, *unchanged*. Permission is also granted to
 * use this routine in own productions, as long as it's mentioned that
 * the routine was used and that it was written by me.
 *
 * I can't be held responsible for the correct function of this routine,
 * nor for any damage that occurs after the correct or incorrect use of
 * this routine. USE IT AT YOUR OWN RISK!
 *
 * If you find any bugs or have suggestions, please contact me!
 *
 * History:
 * 10/28 -
 * 10/29/94: Creation
 * 10/30/94: pack_img_line now also detects 2-byte-solid runs
 * 10/31/94: Fixed wrong comment. pack_img_line's return value will be
 *           <= byte_width + 2, not <= byte_width (because in the worst
 *           case, all data of the line must be stored uncompressed as
 *           a bitstring, and this needs two extra-bytes for identifying
 *           the bitstring)
 * 11/02/94: Fixed routine. It could happen that the saved line was even
 *           longer than byte_width + 2. This should be fixed now, as
 *           pack_img_line now only packs if this will *really* save
 *           bytes. Thanks to Eero Tamminen for reporting that bug.
 *           Another bug was in the adjustment of the new position after
 *           a run was packed (this didn't cause any harm, but wasted
 *           some bytes sometimes).
 * 11/03/94: Solid runs can now have odd lenghts. - Eero -
 *
 * pack_img_line
 *
 * Pack one scanline for an (X)IMG-file, using 2-byte-pattern runs
 * and solid runs. It's an easy task to write a second function that
 * checks the packed lines for scanline runs.
 *
 * Input:
 * source: Pointer to img-data that should be packed (one scanline
 *         of one plane)
 * dest: Pointer to where the packed information should be written
 *       (this area will contain data that can directly be written
 *       to a file after the function returns)
 * byte_width: Width of the scanline in bytes
 *
 * Output:
 * Number of bytes in dest (<= byte_width + 2)
 */

WORD pack_img_line(char *source, char *dest, WORD byte_width)
{
  WORD  i, j, pos, last, cnt;
  UWORD  test;

  byte_width --;
  /* repeat until there's no more to compress (at least two bytes!). */
  for(i = pos = last = 0; i < byte_width; i++)
  {
    /* We only check for 2-byte-patterns. If we find a run, we then
     * check if the pattern is 0xffff or 0x0000. In that case, it's
     * treated as a solid run, as a pattern run otherwise.
     */
    test = ((UWORD)source[i] << 8) | (source[i + 1] & 0xff);
    cnt = 1, j = i;
    while((j += 2) < byte_width &&
         (((UWORD)source[j] << 8) | (source[j + 1] & 0xff)) == test)
         cnt++;

    /* cnt now contains how often we could find the two-byte-pattern
     * located at position i (the length of the run).
     * We only use the run, if it's longer than two or can be transformed
     * into a solid run (plain "black" or plain "white").
     */
    if(((test == 0xffff) || !test) || (cnt > 2))
    {
      /* The bytes between the beginning of the current and the end of the
       * last run are saved as a bitstring.
       */
      if(last < i)
      {
        /* Saving as a bitstring needs two extra bytes, so we now have to
         * check if we still save bytes by packing the run we've found.
         */
        if((test == 0xffff) || !test)
        {
          if(cnt < 2)
            continue;
        }
        else
        {
          if(cnt < 4)
            continue;
        }
        dest[pos++] = 0x80;
        dest[pos++] = i - last;
        for(j = last; j < i; dest[pos++] = source[j++]);
      }
      /* Adjust the current position and the end of the "last" run. */
      last = i += cnt * 2;
      i--; /* - 1 because of i++ in the loop. */
      if((test == 0xffff) || !test)
      {
        /* Place a solid run */
        cnt *= 2;
        /* Check for odd (cnt + 1) lenght of solid run. */
        if(source[last] == (test & 0xff) && i < byte_width)
          last++, cnt ++, i++;
        do
        {
          dest[pos++] = (cnt > 127) ? 127 : cnt;
          if(test)
            dest[pos - 1] |= 128;
          cnt -= 127;
        } while(cnt > 0);
      }
      else
      {
        /* Place a pattern run. */
        do
        {
          dest[pos++] = 0;
          dest[pos++] = (cnt > 127) ? 127 : cnt;
          dest[pos++] = test >> 8;
          dest[pos++] = test & 0xff;
          cnt -= 127;
        } while(cnt > 0);
      }
    }
  }
  /* If there are bytes left, put them into the destination area as a
   * bitstring.
   */
  if(last <= byte_width)
  {
    dest[pos++] = 0x80;
    dest[pos++] = byte_width - last + 1;
    for(j = last; j <= byte_width; dest[pos++] = source[j++]);
  }
  /* Return the number of bytes we used in dest. */
  return(pos);
}

/* EOF */
