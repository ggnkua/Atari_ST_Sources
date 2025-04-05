#include "imgcodec.h"

/* Here is the one and only Level-3 decoder...
 * It is designed to be efficient as well as flexible in usage,
 * and it is capable of decoding all Level 1, 2, and 3 image files
 * without explicitly checking for level number of input stream.
 * So this one decoder is really sufficient, there is no need for
 * lower level decoders. In fact, a lower level decoder could be
 * programmed somewhat more straightforward by assuming, that the
 * line limit is not reached during inner decoding loops, but this
 * approach would have the disadvantage to loose reliability on
 * messy input data. The Level-3 decoder, however, automatically
 * checks for buffer overflows at any time, so it is the most
 * reliable and should work without any problems on arbitrary
 * messy data input.
 *
 * Aside from getting away with any line limit coding (but going
 * on to require only a single line buffer by the given decoding
 * scheme!), Level-3 provides an 'extended vertical run mode',
 * which is introduced with Level-2. This is quite easy to
 * implement in the decoder, and is also easy to exploit in
 * encoding. It may save a lot of bytes on certain images,
 * especially desktop snapshots or line drawings.
 * This mode places a run code in the stream for a series of bytes
 * in the line that equals the above line. This may be considered
 * as a generalization of the known 'vertical run code', which is
 * used for (multiple) full line repeats. This vrc has a 'stuffed
 * prefix byte' (0xFF), and the new generalized vertical run is
 * introduced as an extension of this stuffing byte by allowing it
 * to be an arbitrary value to be 0xFF for known full vrc and the
 * extended vertical run count minus one else. The 'minus one'
 * allows the real run count to be from 1 to 255 (0 is not needed,
 * and so is reserved for full vrc), which is also straightforward
 * to implement.
 * Implementation of extended vrc is very easy and efficient by
 * simply skipping the line output buffer bytewise runcount times.
 * This, however, assumes, that the line buffer always contains
 * the last decoded bytes. But this is easy to guarantee by only
 * forbid the put_line function to change the buffer contents.
 *
 * Furthermore, the Level-3 as well as Level-2 extends the meaning
 * of byte string and full vrc counts. We consider a zero value to
 * be a count of 256. This is straightforward to implement in the
 * decoder by using a do-while-decrement loop, without additional
 * code. The encoders can also take care of this easily.
 *
 * The decoder is implemented as endless loop for processing data.
 * Conditions for breakdown are assumed to be checked within the
 * callback functions (data_func and put_line) and to be handled
 * via a standard setjmp/longjmp scheme. This approach avoids
 * additional checking code in the decoder loop. If it should be
 * unlikely, it is possible to define the callback functions as
 * returning a boolean continue/abort value and adapt the decoder.
 * But, again, the actual approach is more compact and efficient.
 */

void level_3_decode(FBUFPUB *input, IBUFPUB *image)
{
  char cdata, c_val, *pat_ptr;
  short i;

  for (;;)
  {
    FGETC(input, cdata);
    if ((c_val = cdata) != 0)
    {
      if (cdata <<= 1)				  /* solid run */
      {
	c_val >>= 7;
	do IPUTC(image, c_val); while (cdata -= 2);
      }
      else					/* byte string */
      {
	FGETC(input, cdata);
	do FICOPYC(input, image); while (--cdata);
    } }
    else
    {
      FGETC(input, cdata);
      if (cdata)				/* pattern run */
      {
	pat_ptr = image->pat_buf;
	for (i = image->pat_run; --i >= 0;)
	  FGETC(input, *pat_ptr++);
	do
	{ pat_ptr = image->pat_buf;
	  for (i = image->pat_run; --i >= 0;)
	    IPUTC(image, *pat_ptr++);
	}
	while (--cdata);
      }
      else			       /* vertical replication */
      {
	FGETC(input, cdata);
	if (++cdata) do ISKIPC(image); while (--cdata);
	else FGETC(input, image->vrc);
} } } }
