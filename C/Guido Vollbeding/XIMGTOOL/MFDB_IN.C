#include <vdi.h>

#include "imgcodec.h"

/* Standard MFDB input processing.
 * This can be used for screen snapshots.
 * The image object is provided by calling an encode_init
 * function. The input_header must thereby match the mfdb,
 * i.e. the sl_width, sl_height, and planes entries must be
 * set to fd_w, fd_h, and fd_nplanes. The input pat_run
 * entry should be set to zero, remaining entries don't care.
 */

void mfdb_in_proc(MFDB *mfdb, IBUFPUB *image)
{
  long byte_width, line_offs, plane_size, count;
  char *raster_ptr, *line_ptr, *buf_ptr;
  short num_planes, plane;

  raster_ptr = mfdb->fd_addr;
  num_planes = mfdb->fd_nplanes;
  byte_width = (mfdb->fd_w + 7) >> 3;
  line_offs = mfdb->fd_wdwidth << 1;
  plane_size = mfdb->fd_h;
  plane_size *= line_offs;
  for (;;) /* Assume image object handles breakdown. */
  {
    line_ptr = raster_ptr;
    buf_ptr = image->pbuf;
    plane = num_planes;
    do
    { count = byte_width;
      if (byte_width & 1L)
	do *buf_ptr++ = *line_ptr++;
	while (--count);
      else
	do *((short *)buf_ptr)++ =
	   *((short *)line_ptr)++;
	while (count -= 2);
      line_ptr -= byte_width;
      line_ptr += plane_size;
    }
    while (--plane > 0);
    image->pbuf = buf_ptr;
    image->bytes_left = 0;
    (*image->put_line)(image);
    raster_ptr += line_offs;
} }
