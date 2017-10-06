#include <vdi.h>

#include "imgcodec.h"

/* Local extension of public image buffer struct for MFDB output. */

typedef struct ibuf
{
  IBUFPUB pub;
  char *line_adr;
  long length;
  long src_bwidth;
  long des_bwidth;
  long plane_size;
  void *raster_ptr;
  void (*user_exit)(void);
  short src_planes, des_planes;
  short width, height;
  char data[];
}
IBUF;

/* Forward declaration of local function. */

static void mfdb_putline(IBUF *ip);

/* Initialization function to be used for decoding input into
 * a standard MFDB (without dithering, but in arbitrary color
 * index plane mode).
 * Returns a zero pointer if user_malloc failes.
 * Otherwise the returned pointer has to be freed after
 * processing by the 'complement' of user_malloc.
 *
 * NOTE: The MFDB-struct must be prefilled with valid entries.
 * The image memory referenced by fd_addr is assumed to be
 * prefilled with zero.
 * The fd_w, fd_h, and fd_wdwidth entries are assumed to be equal
 * to or higher than the input_header values.
 * The fd_nplanes, however, does NOT need to match the input planes,
 * it may rather match the screen mode (color index mode assumed).
 *
 * The code provided here is thought as a base for applications
 * that need screen representation of image data. Advanced
 * applications must extend the code (dithering, direct color
 * mode support).
 */

IBUFPUB *mfdb_output_init(IMG_HEADER *input_header, MFDB *mfdb,
			  void *(*user_malloc)(long size),
			  void (*user_exit)(void))
{
  long src_bwidth, des_bwidth, line_len, plane_size;
  IBUF *image;

  src_bwidth = (input_header->sl_width + 7) >> 3;
  des_bwidth = mfdb->fd_wdwidth << 1;
  line_len = src_bwidth * input_header->planes;
  plane_size = des_bwidth * mfdb->fd_h;
  image =
    (*user_malloc)(sizeof(IBUF) + line_len + input_header->pat_run);
  if (image)
  {
    image->line_adr = image->pub.pbuf = image->data;
    image->pub.pat_buf = image->data + line_len;
    image->pub.bytes_left = line_len;
    image->length = line_len;
    image->src_bwidth = src_bwidth;
    image->des_bwidth = des_bwidth;
    image->plane_size = plane_size;
    image->pub.pat_run = input_header->pat_run;
    image->src_planes = input_header->planes;
    image->des_planes = mfdb->fd_nplanes;
    image->width = input_header->sl_width;
    image->height = input_header->sl_height;
    image->raster_ptr = mfdb->fd_addr;
    image->user_exit = user_exit;
    image->pub.vrc = 1;
    image->pub.put_line = (void (*)(IBUFPUB *))mfdb_putline;
  }
  return &image->pub;
}

static void mfdb_putline(IBUF *ip)
{
  short mask, plane, src_planes, des_planes;
  char *raster_ptr, *line_ptr, *line_buf;
  long i, plane_size;

  raster_ptr = ip->raster_ptr; plane_size = ip->plane_size;
  src_planes = ip->src_planes; des_planes = ip->des_planes;
  do
  { i = ip->src_bwidth; line_buf = ip->line_adr;
    loop: line_ptr = raster_ptr; plane = des_planes;
    for (;;)
    {
      if (i & 1L)
	do *line_ptr++ |= *line_buf++; while (--i);
      else
	do *((short *)line_ptr)++ |= *((short *)line_buf)++;
	while (i -= 2);
      if (line_buf >= ip->pub.pbuf) break;
      i = ip->src_bwidth;
      if (--plane <= 0) goto loop;
      line_ptr -= i; line_ptr += plane_size;
    }
    if (src_planes >= des_planes) raster_ptr += ip->des_bwidth;
    else
    {
      i = ip->des_bwidth;
      do
      { plane = 1;
	line_ptr = raster_ptr; mask = *((short *)raster_ptr)++;
	do
	{ line_ptr += plane_size;
	  if (plane < src_planes) mask &= *(short *)line_ptr;
	  else *(short *)line_ptr = mask;
	}
	while (++plane < des_planes);
      }
      while (i -= 2);
    }
    if (--ip->height <= 0) (*ip->user_exit)();
  }
  while (--ip->pub.vrc);
  ip->pub.vrc++;
  ip->raster_ptr = raster_ptr;
  ip->pub.pbuf = ip->line_adr; ip->pub.bytes_left = ip->length;
}
