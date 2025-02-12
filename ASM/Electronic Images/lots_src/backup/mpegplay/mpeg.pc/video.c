/* This file contains C code that implements
 * the video decoder model.
 */

#include <stdio.h>
#include <stdlib.h>
#include <setjmp.h>
#include <string.h>
#include <time.h>
#include "decoders.h"
#include "video.h"
#include "util.h"
#include "proto.h"

extern long ditherType;
char *ditherFlags;
extern int loopFlag;

/* Macro for returning 1 if num is positive, -1 if negative, 0 if 0. */

#define Sign(num) ((num > 0) ? 1 : ((num == 0) ? 0 : -1))

/* Declare global pointer to vid stream used for current decoding. */

VidStream *curVidStream = NULL;

/* Set up array for fast conversion from zig zag order to row/column
   coordinates.
*/

int zigzag[64][2] = {
  0, 0, 1, 0, 0, 1, 0, 2, 1, 1, 2, 0, 3, 0, 2, 1, 1, 2, 0, 3, 0, 4, 1, 3,
  2, 2, 3, 1, 4, 0, 5, 0, 4, 1, 3, 2, 2, 3, 1, 4, 0, 5, 0, 6, 1, 5, 2, 4,
  3, 3, 4, 2, 5, 1, 6, 0, 7, 0, 6, 1, 5, 2, 4, 3, 3, 4, 2, 5, 1, 6, 0, 7,
  1, 7, 2, 6, 3, 5, 4, 4, 5, 3, 6, 2, 7, 1, 7, 2, 6, 3, 5, 4, 4, 5, 3, 6,
  2, 7, 3, 7, 4, 6, 5, 5, 6, 4, 7, 3, 7, 4, 6, 5, 5, 6, 4, 7, 5, 7, 6, 6,
7, 5, 7, 6, 6, 7, 7, 7};
/* Array mapping zigzag to array pointer offset. */

int zigzag_direct[64] = {
  0, 1, 8, 16, 9, 2, 3, 10, 17, 24, 32, 25, 18, 11, 4, 5, 12,
  19, 26, 33, 40, 48, 41, 34, 27, 20, 13, 6, 7, 14, 21, 28, 35,
  42, 49, 56, 57, 50, 43, 36, 29, 22, 15, 23, 30, 37, 44, 51,
58, 59, 52, 45, 38, 31, 39, 46, 53, 60, 61, 54, 47, 55, 62, 63};
/* Set up array for fast conversion from row/column coordinates to
   zig zag order.
*/

int scan[8][8] = {
  {0, 1, 5, 6, 14, 15, 27, 28},
  {2, 4, 7, 13, 16, 26, 29, 42},
  {3, 8, 12, 17, 25, 30, 41, 43},
  {9, 11, 18, 24, 31, 40, 44, 53},
  {10, 19, 23, 32, 39, 45, 52, 54},
  {20, 22, 33, 38, 46, 51, 55, 60},
  {21, 34, 37, 47, 50, 56, 59, 61},
{35, 36, 48, 49, 57, 58, 62, 63}};
/* Initialize P and B skip flags. */

/* Max lum, chrom indices for illegal block checking. */

static long lmaxx;
static long lmaxy;
static long cmaxx;
static long cmaxy;

/*
 *--------------------------------------------------------------
 *
 * NewVidStream --
 *
 *      Allocates and initializes a VidStream structure. Takes
 *      as parameter requested size for buffer length.
 *
 * Results:
 *      A pointer to the new VidStream structure.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */

VidStream *
NewVidStream(bufLength)
  long bufLength;
{
  int i, j;
  VidStream *new;
  static unsigned char default_intra_matrix[64] = {
    8, 16, 19, 22, 26, 27, 29, 34,
    16, 16, 22, 24, 27, 29, 34, 37,
    19, 22, 26, 27, 29, 34, 34, 38,
    22, 22, 26, 27, 29, 34, 37, 40,
    22, 26, 27, 29, 32, 35, 40, 48,
    26, 27, 29, 32, 35, 40, 48, 58,
    26, 27, 29, 34, 38, 46, 56, 69,
  27, 29, 35, 38, 46, 56, 69, 83};

  /* Check for legal buffer length. */

  if (bufLength < 4)
    return NULL;

  /* Make buffer length multiple of 4. */

  bufLength = (bufLength + 3) >> 2;

  /* Allocate memory for new structure. */

  new = (VidStream *) malloc(sizeof(VidStream));

  /* Initialize pointers to extension and user data. */

  new->group.ext_data = new->group.user_data =
    new->picture.extra_info = new->picture.user_data =
    new->picture.ext_data = new->slice.extra_info =
    new->ext_data = new->user_data = NULL;

  /* Copy default intra matrix. */

  for (i = 0; i < 8; i++) {
    for (j = 0; j < 8; j++) {
      new->intra_quant_matrix[j][i] = default_intra_matrix[i * 8 + j];
    }
  }

  /* Initialize non intra quantization matrix. */

  for (i = 0; i < 8; i++) {
    for (j = 0; j < 8; j++) {
      new->non_intra_quant_matrix[j][i] = 16;
    }
  }

  /* Initialize pointers to image spaces. */

  new->current = new->past = new->future = NULL;
  for (i = 0; i < RING_BUF_SIZE; i++) {
    new->ring[i] = NULL;
  }

  /* Create buffer. */

  new->buf_start = (unsigned long *) malloc(bufLength * 4);

  /*
   * Set max_buf_length to one less than actual length to deal with messy
   * data without proper seq. end codes.
   */

  new->max_buf_length = bufLength - 1;

  /* Initialize bitstream i/o fields. */

  new->bit_offset = 0;
  new->buf_length = 0;
  new->buffer = new->buf_start;


  /* Return structure. */

  return new;
}



/*
 *--------------------------------------------------------------
 *
 * DestroyVidStream --
 *
 *      Deallocates a VidStream structure.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */
void
DestroyVidStream(astream)
  VidStream *astream;
{
  int i;

  if (astream->ext_data != NULL)
    free(astream->ext_data);

  if (astream->user_data != NULL)
    free(astream->user_data);

  if (astream->group.ext_data != NULL)
    free(astream->group.ext_data);

  if (astream->group.user_data != NULL)
    free(astream->group.user_data);

  if (astream->picture.extra_info != NULL)
    free(astream->picture.extra_info);

  if (astream->picture.ext_data != NULL)
    free(astream->picture.ext_data);

  if (astream->picture.user_data != NULL)
    free(astream->picture.user_data);

  if (astream->slice.extra_info != NULL)
    free(astream->slice.extra_info);

  if (astream->buf_start != NULL)
    free(astream->buf_start);

  for (i = 0; i < RING_BUF_SIZE; i++) {
    if (astream->ring[i] != NULL) {
      DestroyPictImage(astream->ring[i]);
      astream->ring[i] = NULL;
    }
  }

  free((char *) astream);
}




/*
 *--------------------------------------------------------------
 *
 * NewPictImage --
 *
 *      Allocates and initializes a PictImage structure.
 *      The width and height of the image space are passed in
 *      as parameters.
 *
 * Results:
 *      A pointer to the new PictImage structure.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */

PictImage *
NewPictImage(width, height)
  unsigned long width, height;
{
  PictImage *new;

  /* Allocate memory space for new structure. */

  new = (PictImage *) malloc(sizeof(PictImage));


  /* Allocate memory for image spaces. */
  {
      new->display = (unsigned char *) malloc(width * height * 2);
  }

  new->luminance = (unsigned char *) malloc(width * height);
  new->Cr = (unsigned char *) malloc(width * height / 4);
  new->Cb = (unsigned char *) malloc(width * height / 4);

  /* Reset locked flag. */

  new->locked = 0;

  /* Return pointer to new structure. */

  return new;
}



/*
 *--------------------------------------------------------------
 *
 * DestroyPictImage --
 *
 *      Deallocates a PictImage structure.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */
void
DestroyPictImage(apictimage)
  PictImage *apictimage;
{
  if (apictimage->luminance != NULL) {
    free(apictimage->luminance);
  }
  if (apictimage->Cr != NULL) {
    free(apictimage->Cr);
  }
  if (apictimage->Cb != NULL) {
    free(apictimage->Cb);
  }

  if (apictimage->display != NULL) {
    free(apictimage->display);
  }
  free(apictimage);
}



/*
 *--------------------------------------------------------------
 *
 * mpegVidRsrc --
 *
 *      Parses bit stream until MB_QUANTUM number of
 *      macroblocks have been decoded or current slice or
 *      picture ends, whichever comes first. If the start
 *      of a frame is encountered, the frame is time stamped
 *      with the value passed in time_stamp. If the value
 *      passed in buffer is not null, the video stream buffer
 *      is set to buffer and the length of the buffer is
 *      expected in value passed in through length. The current
 *      video stream is set to vid_stream. If vid_stream
 *      is passed as NULL, a new VidStream structure is created
 *      and initialized and used as the current video stream.
 *
 * Results:
 *      A pointer to the video stream structure used.
 *
 * Side effects:
 *      Bit stream is irreversibly parsed. If a picture is completed,
 *      a function is called to display the frame at the correct time.
 *
 *--------------------------------------------------------------
 */

VidStream *
mpegVidRsrc(time_stamp, vid_stream)
  TimeStamp time_stamp;
  VidStream *vid_stream;
{
  static long first = 1;
  unsigned long data;
  long i, status;

  /* If vid_stream is null, create new VidStream structure. */

  if (vid_stream == NULL) {
    return NULL;
  }

  /*
   * Set global curVidStream to vid_stream. Necessary because bit i/o use
   * curVidStream and are not passed vid_stream. Also set global bitstream
   * parameters.
   */

  curVidStream = vid_stream;
  bitOffset = curVidStream->bit_offset;
#ifdef UTIL2
  curBits = *curVidStream->buffer << bitOffset;
#else
  curBits = *curVidStream->buffer;
#endif
  bufLength = curVidStream->buf_length;
  bitBuffer = curVidStream->buffer;

  /*
   * If called for the first time, find start code, make sure it is a
   * sequence start code.
   */

  if (first) {
    next_start_code();
    show_bits32(data);
    if (data != SEQ_START_CODE) {
      CloseColorDisplay();
      DestroyVidStream(curVidStream);
      fprintf(stderr, "This is not an MPEG stream.");

      exit(1);
    }
    first = 0;
  }
  /* Get next 32 bits (size of start codes). */

  show_bits32(data);

  /*
   * Process according to start code (or parse macroblock if not a start code
   * at all.
   */

  switch (data) {

  case SEQ_END_CODE:

    
    /* Display last frame. */

    if (vid_stream->future != NULL) {
      vid_stream->current = vid_stream->future;
      ExecuteDisplay(vid_stream);
    }
    
    /* Sequence done. Do the right thing. For right now, exit. */

    if (loopFlag)
      longjmp(env, 1);

    CloseColorDisplay();
    DestroyVidStream(curVidStream);
    exit(0);
    break;

  case SEQ_START_CODE:

    /* Sequence start code. Parse sequence header. */

    if (ParseSeqHead(vid_stream) != PARSE_OK)
      goto error;

    /*
     * Return after sequence start code so that application above can use
     * info in header.
     */

    goto done;

  case GOP_START_CODE:

    /* Group of Pictures start code. Parse gop header. */

    if (ParseGOP(vid_stream) != PARSE_OK)
      goto error;


  case PICTURE_START_CODE:

    /* Picture start code. Parse picture header and first slice header. */

    status = ParsePicture(vid_stream, time_stamp);

    if (status == SKIP_PICTURE) {
      next_start_code();
      while (!next_bits(32, PICTURE_START_CODE)) {
		if (next_bits(32, GOP_START_CODE))
	  		break;
		else if (next_bits(32, SEQ_END_CODE))
	  		break;
		flush_bits(24);
		next_start_code();
      }
      goto done;
    } else if (status != PARSE_OK)
      goto error;


    if (ParseSlice(vid_stream) != PARSE_OK)
      goto error;
    break;

  default:

    /* Check for slice start code. */

    if ((data >= SLICE_MIN_START_CODE) && (data <= SLICE_MAX_START_CODE)) {

      /* Slice start code. Parse slice header. */

      if (ParseSlice(vid_stream) != PARSE_OK)
	goto error;
    }
    break;
  }

  /* Parse next MB_QUANTUM macroblocks. */

  for (i = 0; i < MB_QUANTUM; i++) {

    /* Check to see if actually a startcode and not a macroblock. */

    if (!next_bits(23, 0x00000000)) {

      /* Not start code. Parse Macroblock. */

      if (ParseMacroBlock(vid_stream) != PARSE_OK)
	goto error;

    } else {

      /* Not macroblock, actually start code. Get start code. */

      next_start_code();
      show_bits32(data);

      /*
       * If start code is outside range of slice start codes, frame is
       * complete, display frame.
       */

      if ((data < SLICE_MIN_START_CODE) || (data > SLICE_MAX_START_CODE)) {
			DoPictureDisplay(vid_stream);
      }
      break;
    }
  }

  /* Return pointer to video stream structure. */

  goto done;

error:
  next_start_code();
  goto done;

done:

  /* Copy global bit i/o variables back into vid_stream. */

  vid_stream->buffer = bitBuffer;
  vid_stream->buf_length = bufLength;
  vid_stream->bit_offset = bitOffset;

  return vid_stream;

}



/*
 *--------------------------------------------------------------
 *
 * ParseSeqHead --
 *
 *      Assumes bit stream is at the begining of the sequence
 *      header start code. Parses off the sequence header.
 *
 * Results:
 *      Fills the vid_stream structure with values derived and
 *      decoded from the sequence header. Allocates the pict image
 *      structures based on the dimensions of the image space
 *      found in the sequence header.
 *
 * Side effects:
 *      Bit stream irreversibly parsed off.
 *
 *--------------------------------------------------------------
 */

 long
ParseSeqHead(vid_stream)
  VidStream *vid_stream;
{

  unsigned long data;
  long i;

  /* Flush off sequence start code. */

  flush_bits32;

  /* Get horizontal size of image space. */

  get_bits12(data);
  vid_stream->h_size = data;

  /* Get vertical size of image space. */

  get_bits12(data);
  vid_stream->v_size = data;

  /* Calculate macroblock width and height of image space. */

  vid_stream->mb_width = (vid_stream->h_size + 15) / 16;
  vid_stream->mb_height = (vid_stream->v_size + 15) / 16;

  /* If dither type is MBORDERED allocate ditherFlags. */

  /* Initialize lmaxx, lmaxy, cmaxx, cmaxy. */

  lmaxx = vid_stream->mb_width*16-1;
  lmaxy = vid_stream->mb_height*16-1;
  cmaxx = vid_stream->mb_width*8-1;
  cmaxy = vid_stream->mb_height*8-1;

  /*
   * Initialize ring buffer of pict images now that dimensions of image space
   * are known.
   */

  if (vid_stream->ring[0] == NULL) {
    for (i = 0; i < RING_BUF_SIZE; i++) {
      vid_stream->ring[i] = NewPictImage(vid_stream->mb_width * 16,
					 vid_stream->mb_height * 16);
    }
  }

  /* Parse of aspect ratio code. */

  get_bits4(data);
  vid_stream->aspect_ratio = (unsigned char) data;

  /* Parse off picture rate code. */

  get_bits4(data);
  vid_stream->picture_rate = (unsigned char) data;

  /* Parse off bit rate. */

  get_bits18(data);
  vid_stream->bit_rate = data;

  /* Flush marker bit. */

  flush_bits(1);

  /* Parse off vbv buffer size. */

  get_bits10(data);
  vid_stream->vbv_buffer_size = data;

  /* Parse off contrained parameter flag. */

  get_bits1(data);
  if (data) {
    vid_stream->const_param_flag = TRUE;
  } else
    vid_stream->const_param_flag = FALSE;

  /*
   * If intra_quant_matrix_flag set, parse off intra quant matrix values.
   */

  get_bits1(data);
  if (data) {
    for (i = 0; i < 64; i++) {
      get_bits8(data);

      vid_stream->intra_quant_matrix[zigzag[i][1]][zigzag[i][0]] =
	(unsigned char) data;
    }
  }
  /*
   * If non intra quant matrix flag set, parse off non intra quant matrix
   * values.
   */

  get_bits1(data);
  if (data) {
    for (i = 0; i < 64; i++) {
      get_bits8(data);

      vid_stream->non_intra_quant_matrix[zigzag[i][1]][zigzag[i][0]] =
	(unsigned char) data;
    }
  }
  /* Go to next start code. */

  next_start_code();

  /*
   * If next start code is extension start code, parse off extension data.
   */

  if (next_bits(32, EXT_START_CODE)) {
    flush_bits32;
    if (vid_stream->ext_data != NULL) {
      free(vid_stream->ext_data);
      vid_stream->ext_data = NULL;
    }
    vid_stream->ext_data = get_ext_data();
  }
  /* If next start code is user start code, parse off user data. */

  if (next_bits(32, USER_START_CODE)) {
    flush_bits32;
    if (vid_stream->user_data != NULL) {
      free(vid_stream->user_data);
      vid_stream->user_data = NULL;
    }
    vid_stream->user_data = get_ext_data();
  }
  return PARSE_OK;
}



/*
 *--------------------------------------------------------------
 *
 * ParseGOP --
 *
 *      Parses of group of pictures header from bit stream
 *      associated with vid_stream.
 *
 * Results:
 *      Values in gop header placed into video stream structure.
 *
 * Side effects:
 *      Bit stream irreversibly parsed.
 *
 *--------------------------------------------------------------
 */

 long
ParseGOP(vid_stream)
  VidStream *vid_stream;
{
  unsigned long data;

  /* Flush group of pictures start code. WWWWWWOOOOOOOSSSSSSHHHHH!!! */

  flush_bits32;

  /* Parse off drop frame flag. */

  get_bits1(data);
  if (data) {
    vid_stream->group.drop_flag = TRUE;
  } else
    vid_stream->group.drop_flag = FALSE;

  /* Parse off hour component of time code. */

  get_bits5(data);
  vid_stream->group.tc_hours = data;

  /* Parse off minute component of time code. */

  get_bits6(data);
  vid_stream->group.tc_minutes = data;

  /* Flush marker bit. */

  flush_bits(1);

  /* Parse off second component of time code. */

  get_bits6(data);
  vid_stream->group.tc_seconds = data;

  /* Parse off picture count component of time code. */

  get_bits6(data);
  vid_stream->group.tc_pictures = data;

  /* Parse off closed gop and broken link flags. */

  get_bits2(data);
  if (data > 1) {
    vid_stream->group.closed_gop = TRUE;
    if (data > 2) {
      vid_stream->group.broken_link = TRUE;
    } else
      vid_stream->group.broken_link = FALSE;
  } else {
    vid_stream->group.closed_gop = FALSE;
    if (data) {
      vid_stream->group.broken_link = TRUE;
    } else
      vid_stream->group.broken_link = FALSE;
  }

  /* Goto next start code. */

  next_start_code();

  /* If next start code is extension data, parse off extension data. */

  if (next_bits(32, EXT_START_CODE)) {
    flush_bits32;
    if (vid_stream->group.ext_data != NULL) {
      free(vid_stream->group.ext_data);
      vid_stream->group.ext_data = NULL;
    }
    vid_stream->group.ext_data = get_ext_data();
  }
  /* If next start code is user data, parse off user data. */

  if (next_bits(32, USER_START_CODE)) {
    flush_bits32;
    if (vid_stream->group.user_data != NULL) {
      free(vid_stream->group.user_data);
      vid_stream->group.user_data = NULL;
    }
    vid_stream->group.user_data = get_ext_data();
  }
  return PARSE_OK;
}



/*
 *--------------------------------------------------------------
 *
 * ParsePicture --
 *
 *      Parses picture header. Marks picture to be presented
 *      at particular time given a time stamp.
 *
 * Results:
 *      Values from picture header put into video stream structure.
 *
 * Side effects:
 *      Bit stream irreversibly parsed.
 *
 *--------------------------------------------------------------
 */

 long
ParsePicture(vid_stream, time_stamp)
  VidStream *vid_stream;
  TimeStamp time_stamp;
{
  unsigned long data;
  long i;

  /* Flush header start code. */
  flush_bits32;

  /* Parse off temporal reference. */
  get_bits10(data);
  vid_stream->picture.temp_ref = data;

  /* Parse of picture type. */
  get_bits3(data);
  vid_stream->picture.code_type = data;

  if ((vid_stream->picture.code_type == B_TYPE) &&
      (
	   (vid_stream->past == NULL) ||
	   (vid_stream->future == NULL)))
    return SKIP_PICTURE;

  if ((vid_stream->picture.code_type == P_TYPE) &&
      ((vid_stream->future == NULL)))
    return SKIP_PICTURE;

  /* Parse off vbv buffer delay value. */
  get_bits16(data);
  vid_stream->picture.vbv_delay = data;

  /* If P or B type frame... */

  if ((vid_stream->picture.code_type == 2) || (vid_stream->picture.code_type == 3)) {

    /* Parse off forward vector full pixel flag. */
    get_bits1(data);
    if (data)
      vid_stream->picture.full_pel_forw_vector = TRUE;
    else
      vid_stream->picture.full_pel_forw_vector = FALSE;

    /* Parse of forw_r_code. */
    get_bits3(data);

    /* Decode forw_r_code into forw_r_size and forw_f. */

    vid_stream->picture.forw_r_size = data - 1;
    vid_stream->picture.forw_f = (1 << vid_stream->picture.forw_r_size);
  }
  /* If B type frame... */

  if (vid_stream->picture.code_type == 3) {

    /* Parse off back vector full pixel flag. */
    get_bits1(data);
    if (data)
      vid_stream->picture.full_pel_back_vector = TRUE;
    else
      vid_stream->picture.full_pel_back_vector = FALSE;

    /* Parse off back_r_code. */
    get_bits3(data);

    /* Decode back_r_code into back_r_size and back_f. */

    vid_stream->picture.back_r_size = data - 1;
    vid_stream->picture.back_f = (1 << vid_stream->picture.back_r_size);
  }
  /* Get extra bit picture info. */

  if (vid_stream->picture.extra_info != NULL) {
    free(vid_stream->picture.extra_info);
    vid_stream->picture.extra_info = NULL;
  }
  vid_stream->picture.extra_info = get_extra_bit_info();

  /* Goto next start code. */
  next_start_code();

  /* If start code is extension start code, parse off extension data. */

  if (next_bits(32, EXT_START_CODE)) {
    flush_bits32;

    if (vid_stream->picture.ext_data != NULL) {
      free(vid_stream->picture.ext_data);
      vid_stream->picture.ext_data = NULL;
    }
    vid_stream->picture.ext_data = get_ext_data();
  }
  /* If start code is user start code, parse off user data. */

  if (next_bits(32, USER_START_CODE)) {
    flush_bits32;

    if (vid_stream->picture.user_data != NULL) {
      free(vid_stream->picture.user_data);
      vid_stream->picture.user_data = NULL;
    }
    vid_stream->picture.user_data = get_ext_data();
  }
  /* Find a pict image structure in ring buffer not currently locked. */

  i = 0;

  while (vid_stream->ring[i]->locked != 0) {
    if (++i >= RING_BUF_SIZE) {
      CloseColorDisplay();
      perror("Fatal error. Ring buffer full.");
      exit(1);
    }
  }

  /* Set current pict image structure to the one just found in ring. */

  vid_stream->current = vid_stream->ring[i];

  /* Set time stamp. */

  vid_stream->current->show_time = time_stamp;

  /* Reset past macroblock address field. */

  vid_stream->mblock.past_mb_addr = -1;

  return PARSE_OK;
}



/*
 *--------------------------------------------------------------
 *
 * ParseSlice --
 *
 *      Parses off slice header.
 *
 * Results:
 *      Values found in slice header put into video stream structure.
 *
 * Side effects:
 *      Bit stream irreversibly parsed.
 *
 *--------------------------------------------------------------
 */

 long
ParseSlice(vid_stream)
  VidStream *vid_stream;
{
  unsigned long data;

  /* Flush slice start code. */

  flush_bits(24);

  /* Parse off slice vertical position. */

  get_bits8(data);
  vid_stream->slice.vert_pos = data;

  /* Parse off quantization scale. */

  get_bits5(data);
  vid_stream->slice.quant_scale = data;

  /* Parse off extra bit slice info. */

  if (vid_stream->slice.extra_info != NULL) {
    free(vid_stream->slice.extra_info);
    vid_stream->slice.extra_info = NULL;
  }
  vid_stream->slice.extra_info = get_extra_bit_info();

  /* Reset past intrablock address. */

  vid_stream->mblock.past_intra_addr = -2;

  /* Reset previous recon motion vectors. */

  vid_stream->mblock.recon_right_for_prev = 0;
  vid_stream->mblock.recon_down_for_prev = 0;
  vid_stream->mblock.recon_right_back_prev = 0;
  vid_stream->mblock.recon_down_back_prev = 0;

  /* Reset macroblock address. */

  vid_stream->mblock.mb_address = ((vid_stream->slice.vert_pos - 1) *
				   vid_stream->mb_width) - 1;

  /* Reset past dct dc y, cr, and cb values. */

  vid_stream->block.dct_dc_y_past = 1024;
  vid_stream->block.dct_dc_cr_past = 1024;
  vid_stream->block.dct_dc_cb_past = 1024;

  return PARSE_OK;
}



/*
 *--------------------------------------------------------------
 *
 * ParseMacroBlock --
 *
 *      Parseoff macroblock. Reconstructs DCT values. Applies
 *      inverse DCT, reconstructs motion vectors, calculates and
 *      set pixel values for macroblock in current pict image
 *      structure.
 *
 * Results:
 *      Here's where everything really happens. Welcome to the
 *      heart of darkness.
 *
 * Side effects:
 *      Bit stream irreversibly parsed off.
 *
 *--------------------------------------------------------------
 */

 long
ParseMacroBlock(vid_stream)
  VidStream *vid_stream;
{
  long addr_incr;
  unsigned long data;
  long mask, i, recon_right_for, recon_down_for, recon_right_back,
      recon_down_back;
#define MB_STUFFING 34
#define MB_ESCAPE 35  long zero_block_flag;
  BOOLEAN mb_quant, mb_motion_forw, mb_motion_back, mb_pattern;
  long no_dith_flag = 
  
  0;

  /*
   * Parse off macroblock address increment and add to macroblock address.
   */
  do {
    DecodeMBAddrInc(addr_incr);
    if (addr_incr == MB_ESCAPE) {
      vid_stream->mblock.mb_address += 33;
      addr_incr = MB_STUFFING;
    }
  } while (addr_incr == MB_STUFFING);
  vid_stream->mblock.mb_address += addr_incr;

  if (vid_stream->mblock.mb_address > (vid_stream->mb_height *
				       vid_stream->mb_width - 1))
    return SKIP_TO_START_CODE;

  /*
   * If macroblocks have been skipped, process skipped macroblocks.
   */

  if (vid_stream->mblock.mb_address - vid_stream->mblock.past_mb_addr > 1) {
    if (vid_stream->picture.code_type == P_TYPE)
      ProcessSkippedPFrameMBlocks(vid_stream);
    else if (vid_stream->picture.code_type == B_TYPE)
      ProcessSkippedBFrameMBlocks(vid_stream);
  }
  /* Set past macroblock address to current macroblock address. */
  vid_stream->mblock.past_mb_addr = vid_stream->mblock.mb_address;

  /* Based on picture type decode macroblock type. */
  switch (vid_stream->picture.code_type) {
  case I_TYPE:
    		DecodeMBTypeI(mb_quant,mb_motion_forw, mb_motion_back, mb_pattern,
		  vid_stream->mblock.mb_intra);
    break;

  case P_TYPE:
    		DecodeMBTypeP(mb_quant,mb_motion_forw, mb_motion_back, mb_pattern,
		  vid_stream->mblock.mb_intra);
    break;

  case B_TYPE:
    		DecodeMBTypeB(mb_quant,mb_motion_forw, mb_motion_back, mb_pattern,
		  vid_stream->mblock.mb_intra);
    break;
  }

  /* If quantization flag set, parse off new quantization scale. */

  if (mb_quant == TRUE) {
    get_bits5(data);
    vid_stream->slice.quant_scale = data;
  }
  /* If forward motion vectors exist... */
  if (mb_motion_forw == TRUE) {

    /* Parse off and decode horizontal forward motion vector. */
    DecodeMotionVectors(vid_stream->mblock.motion_h_forw_code);

    /* If horiz. forward r data exists, parse off. */

    if ((vid_stream->picture.forw_f != 1) &&
	(vid_stream->mblock.motion_h_forw_code != 0)) {
      get_bitsn(vid_stream->picture.forw_r_size, data);
      vid_stream->mblock.motion_h_forw_r = data;
    }
    /* Parse off and decode vertical forward motion vector. */
    DecodeMotionVectors(vid_stream->mblock.motion_v_forw_code);

    /* If vert. forw. r data exists, parse off. */

    if ((vid_stream->picture.forw_f != 1) &&
	(vid_stream->mblock.motion_v_forw_code != 0)) {
      get_bitsn(vid_stream->picture.forw_r_size, data);
      vid_stream->mblock.motion_v_forw_r = data;
    }
  }
  /* If back motion vectors exist... */
  if (mb_motion_back == TRUE) {

    /* Parse off and decode horiz. back motion vector. */
    DecodeMotionVectors(vid_stream->mblock.motion_h_back_code);

    /* If horiz. back r data exists, parse off. */

    if ((vid_stream->picture.back_f != 1) &&
	(vid_stream->mblock.motion_h_back_code != 0)) {
      get_bitsn(vid_stream->picture.back_r_size, data);
      vid_stream->mblock.motion_h_back_r = data;
    }
    /* Parse off and decode vert. back motion vector. */
    DecodeMotionVectors(vid_stream->mblock.motion_v_back_code);

    /* If vert. back r data exists, parse off. */

    if ((vid_stream->picture.back_f != 1) &&
	(vid_stream->mblock.motion_v_back_code != 0)) {
      get_bitsn(vid_stream->picture.back_r_size, data);
      vid_stream->mblock.motion_v_back_r = data;
    }
  }

  /* If mblock pattern flag set, parse and decode CBP (code block pattern). */
  if (mb_pattern == TRUE) {
    DecodeCBP(vid_stream->mblock.cbp);
  }
  /* Otherwise, set CBP to zero. */
  else
    vid_stream->mblock.cbp = 0;


  /* Reconstruct motion vectors depending on picture type. */
  if (vid_stream->picture.code_type == P_TYPE) {

    /*
     * If no forw motion vectors, reset previous and current vectors to 0.
     */

    if (!mb_motion_forw) {
      recon_right_for = 0;
      recon_down_for = 0;
      vid_stream->mblock.recon_right_for_prev = 0;
      vid_stream->mblock.recon_down_for_prev = 0;
    }
    /*
     * Otherwise, compute new forw motion vectors. Reset previous vectors to
     * current vectors.
     */

    else {
      ComputeForwVector(&recon_right_for, &recon_down_for);
    }
  }
  if (vid_stream->picture.code_type == B_TYPE) {

    /* Reset prev. and current vectors to zero if mblock is intracoded. */

    if (vid_stream->mblock.mb_intra) {
      vid_stream->mblock.recon_right_for_prev = 0;
      vid_stream->mblock.recon_down_for_prev = 0;
      vid_stream->mblock.recon_right_back_prev = 0;
      vid_stream->mblock.recon_down_back_prev = 0;
    } else {

      /* If no forw vectors, current vectors equal prev. vectors. */

      if (!mb_motion_forw) {
	recon_right_for = vid_stream->mblock.recon_right_for_prev;
	recon_down_for = vid_stream->mblock.recon_down_for_prev;
      }
      /*
       * Otherwise compute forw. vectors. Reset prev vectors to new values.
       */

      else {
	ComputeForwVector(&recon_right_for, &recon_down_for);
      }

      /* If no back vectors, set back vectors to prev back vectors. */

      if (!mb_motion_back) {
	recon_right_back = vid_stream->mblock.recon_right_back_prev;
	recon_down_back = vid_stream->mblock.recon_down_back_prev;
      }
      /* Otherwise compute new vectors and reset prev. back vectors. */

      else {
	ComputeBackVector(&recon_right_back, &recon_down_back);
      }

      /*
       * Store vector existance flags in structure for possible skipped
       * macroblocks to follow.
       */

      vid_stream->mblock.bpict_past_forw = mb_motion_forw;
      vid_stream->mblock.bpict_past_back = mb_motion_back;
    }
  }

  /* For each possible block in macroblock. */
	
      for (mask = 32, i = 0; i < 6; mask >>= 1, i++) {
	
	/* If block exists... */
	if ((vid_stream->mblock.mb_intra) || (vid_stream->mblock.cbp & mask)) {
	  zero_block_flag = 0;
	  ParseReconBlock(i);
	} else {
	  zero_block_flag = 1;
	}
	
	/* If macroblock is intra coded... */
	if (vid_stream->mblock.mb_intra) {
	  ReconIMBlock(vid_stream, i);
	} else if (mb_motion_forw && mb_motion_back) {
	  ReconBiMBlock(vid_stream, i, recon_right_for, recon_down_for,
			recon_right_back, recon_down_back, zero_block_flag);
	} else if (mb_motion_forw || (vid_stream->picture.code_type == P_TYPE)) {
	  ReconPMBlock(vid_stream, i, recon_right_for, recon_down_for,
		       zero_block_flag);
	} else if (mb_motion_back) {
	  ReconBMBlock(vid_stream, i, recon_right_back, recon_down_back,
		       zero_block_flag);
	}
      }

  /* If D Type picture, flush marker bit. */
  if (vid_stream->picture.code_type == 4)
    flush_bits(1);

  /* If macroblock was intracoded, set macroblock past intra address. */
  if (vid_stream->mblock.mb_intra)
    vid_stream->mblock.past_intra_addr =
      vid_stream->mblock.mb_address;

  return PARSE_OK;
}

/*
 *--------------------------------------------------------------
 *
 * ReconIMBlock --
 *
 *      Reconstructs intra coded macroblock.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */


void
ReconIMBlock2(vid_stream, bnum)
  VidStream *vid_stream;
  long bnum;
{
  int mb_row, mb_col, row, col, row_size, rr;
  unsigned char *dest;

  /* Calculate macroblock row and column from address. */

  mb_row = vid_stream->mblock.mb_address / vid_stream->mb_width;
  mb_col = vid_stream->mblock.mb_address % vid_stream->mb_width;

  switch (bnum)
  {	
	case 0:
	case 1:
	case 2:
	case 3:		/* Calculate row and col values for upper left pixel of block. */

			row = mb_row * 16;
   			col = mb_col * 16;
    			if (bnum > 1)
      				row += 8;
    			if (bnum % 2)
      				col += 8;

    			/* Set dest to luminance plane of current pict image. */

			dest = vid_stream->current->luminance;

    			/* Establish row size. */

    			row_size = vid_stream->mb_width * 16;
  			break;

	case 4:		/* Otherwise if block is Cr block... */
		    	/* Set dest to Cr plane of current pict image. */

    			dest = vid_stream->current->Cr;

			    /* Establish row size. */

    			row_size = vid_stream->mb_width * 8;

    			/* Calculate row,col for upper left pixel of block. */

    			row = mb_row * 8;
    			col = mb_col * 8;
  			break;
  
  	case 5:		/* Otherwise block is Cb block, and ... */
    			/* Set dest to Cb plane of current pict image. */

    			dest = vid_stream->current->Cb;

			/* Establish row size. */

			row_size = vid_stream->mb_width * 8;

    			/* Calculate row,col for upper left pixel value of block. */

    			row = mb_row * 8;
    			col = mb_col * 8;
			break;
  }
  dest += row * row_size + col; 
  memcpy(dest,&vid_stream->block.dct_recon[0][0],64);
}


void
ReconIMBlock(vid_stream, bnum)
  VidStream *vid_stream;
  long bnum;
{
  int mb_row, mb_col, row, col, row_size, rr;
  unsigned char *dest;

  /* Calculate macroblock row and column from address. */

  mb_row = vid_stream->mblock.mb_address / vid_stream->mb_width;
  mb_col = vid_stream->mblock.mb_address % vid_stream->mb_width;


  /* If block is luminance block... */

  if (bnum < 4) {

    /* Calculate row and col values for upper left pixel of block. */

    row = mb_row * 16;
    col = mb_col * 16;
    if (bnum > 1)
      row += 8;
    if (bnum % 2)
      col += 8;

    /* Set dest to luminance plane of current pict image. */

    dest = vid_stream->current->luminance;

    /* Establish row size. */

    row_size = vid_stream->mb_width * 16;
  }
  /* Otherwise if block is Cr block... */

  else if (bnum == 4) {

    /* Set dest to Cr plane of current pict image. */

    dest = vid_stream->current->Cr;

    /* Establish row size. */

    row_size = vid_stream->mb_width * 8;

    /* Calculate row,col for upper left pixel of block. */

    row = mb_row * 8;
    col = mb_col * 8;
  }
  /* Otherwise block is Cb block, and ... */

  else {

    /* Set dest to Cb plane of current pict image. */

    dest = vid_stream->current->Cb;

    /* Establish row size. */

    row_size = vid_stream->mb_width * 8;

    /* Calculate row,col for upper left pixel value of block. */

    row = mb_row * 8;
    col = mb_col * 8;
  }

  {
    int *sp = &vid_stream->block.dct_recon[0][0];
    dest += row * row_size + col;
    for (rr = 0; rr < 4; rr++, sp += 16, dest += row_size) {
      dest[0] = sp[0];
      dest[1] = sp[1];
      dest[2] = sp[2];
      dest[3] = sp[3];
      dest[4] = sp[4];
      dest[5] = sp[5];
      dest[6] = sp[6];
      dest[7] = sp[7];

      dest += row_size;
      dest[0] = sp[8];
      dest[1] = sp[9];
      dest[2] = sp[10];
      dest[3] = sp[11];
      dest[4] = sp[12];
      dest[5] = sp[13];
      dest[6] = sp[14];
      dest[7] = sp[15];
    }
  }
}


/*
 *--------------------------------------------------------------
 *
 * ReconPMBlock --
 *
 *      Reconstructs forward predicted macroblocks.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */

 void
ReconPMBlock(vid_stream, bnum, recon_right_for, recon_down_for, zflag)
  VidStream *vid_stream;
  long bnum, recon_right_for, recon_down_for, zflag;
{
  long mb_row, mb_col, row, col, row_size, rr;
  unsigned char *dest, *past;
  static long right_for, down_for, right_half_for, down_half_for;
  unsigned char *rindex1, *rindex2;
  unsigned char *index;
  int *blockvals;

  /* Calculate macroblock row and column from address. */

  mb_row = vid_stream->mblock.mb_address / vid_stream->mb_width;
  mb_col = vid_stream->mblock.mb_address % vid_stream->mb_width;

  if (bnum < 4) {

    /* Calculate right_for, down_for motion vectors. */

    right_for = recon_right_for >> 1;
    down_for = recon_down_for >> 1;
    right_half_for = recon_right_for & 0x1;
    down_half_for = recon_down_for & 0x1;

    /* Set dest to luminance plane of current pict image. */

    dest = vid_stream->current->luminance;

    if (vid_stream->picture.code_type == B_TYPE) {
      if (vid_stream->past != NULL)
	past = vid_stream->past->luminance;
    } else {

      /* Set predicitive frame to current future frame. */

      if (vid_stream->future != NULL)
	past = vid_stream->future->luminance;
    }

    /* Establish row size. */

    row_size = vid_stream->mb_width << 4;

    /* Calculate row,col of upper left pixel in block. */

    row = mb_row << 4;
    col = mb_col << 4;
    if (bnum > 1)
      row += 8;
    if (bnum % 2)
      col += 8;

  }
  /* Otherwise, block is NOT luminance block, ... */

  else {

    /* Construct motion vectors. */

    recon_right_for /= 2;
    recon_down_for /= 2;
    right_for = recon_right_for >> 1;
    down_for = recon_down_for >> 1;
    right_half_for = recon_right_for & 0x1;
    down_half_for = recon_down_for & 0x1;

    /* Establish row size. */

    row_size = vid_stream->mb_width << 3;

    /* Calculate row,col of upper left pixel in block. */

    row = mb_row << 3;
    col = mb_col << 3;

    /* If block is Cr block... */

    if (bnum == 4) {

      /* Set dest to Cr plane of current pict image. */

      dest = vid_stream->current->Cr;

      if (vid_stream->picture.code_type == B_TYPE) {

	if (vid_stream->past != NULL)
	  past = vid_stream->past->Cr;
      } else {
	if (vid_stream->future != NULL)
	  past = vid_stream->future->Cr;
      }
    }
    /* Otherwise, block is Cb block... */

    else {

      /* Set dest to Cb plane of current pict image. */

      dest = vid_stream->current->Cb;

      if (vid_stream->picture.code_type == B_TYPE) {
	if (vid_stream->past != NULL)
	  past = vid_stream->past->Cb;
      } else {
	if (vid_stream->future != NULL)
	  past = vid_stream->future->Cb;
      }
    }
  }

  /* For each pixel in block... */

    index = dest + (row * row_size) + col;
    rindex1 = past + (row + down_for) * row_size + col + right_for;
    
    blockvals = &(vid_stream->block.dct_recon[0][0]);
    
    /*
     * Calculate predictive pixel value based on motion vectors and copy to
     * dest plane.
     */
    
    if ((!down_half_for) && (!right_half_for)) {
      if (!zflag)
	for (rr = 0; rr < 4; rr++) {
	  index[0] = (long) rindex1[0] + (long) blockvals[0];
	  index[1] = (long) rindex1[1] + (long) blockvals[1];
	  index[2] = (long) rindex1[2] + (long) blockvals[2];
	  index[3] = (long) rindex1[3] + (long) blockvals[3];
	  index[4] = (long) rindex1[4] + (long) blockvals[4];
	  index[5] = (long) rindex1[5] + (long) blockvals[5];
	  index[6] = (long) rindex1[6] + (long) blockvals[6];
	  index[7] = (long) rindex1[7] + (long) blockvals[7];
	  index += row_size;
	  rindex1 += row_size;
	  
	  index[0] = (long) rindex1[0] + (long) blockvals[8];
	  index[1] = (long) rindex1[1] + (long) blockvals[9];
	  index[2] = (long) rindex1[2] + (long) blockvals[10];
	  index[3] = (long) rindex1[3] + (long) blockvals[11];
	  index[4] = (long) rindex1[4] + (long) blockvals[12];
	  index[5] = (long) rindex1[5] + (long) blockvals[13];
	  index[6] = (long) rindex1[6] + (long) blockvals[14];
	  index[7] = (long) rindex1[7] + (long) blockvals[15];
	  blockvals += 16;
	  index += row_size;
	  rindex1 += row_size;
	}
      else {
	if (right_for & 0x1) {
	  /* No alignment, use bye copy */
	  for (rr = 0; rr < 4; rr++) {
	    index[0] = rindex1[0];
	    index[1] = rindex1[1];
	    index[2] = rindex1[2];
	    index[3] = rindex1[3];
	    index[4] = rindex1[4];
	    index[5] = rindex1[5];
	    index[6] = rindex1[6];
	    index[7] = rindex1[7];
	    index += row_size;
	    rindex1 += row_size;
	    
	    index[0] = rindex1[0];
	    index[1] = rindex1[1];
	    index[2] = rindex1[2];
	    index[3] = rindex1[3];
	    index[4] = rindex1[4];
	    index[5] = rindex1[5];
	    index[6] = rindex1[6];
	    index[7] = rindex1[7];
	    index += row_size;
	    rindex1 += row_size;
	  }
	} else if (right_for & 0x2) {
	  /* Half-word bit aligned, use 16 bit copy */
	  int *src = (int *)rindex1;
	  int *dest = (int *)index;
	  row_size >>= 1;
	  for (rr = 0; rr < 4; rr++) {
	    dest[0] = src[0];
	    dest[1] = src[1];
	    dest[2] = src[2];
	    dest[3] = src[3];
	    dest += row_size;
	    src += row_size;
	    
	    dest[0] = src[0];
	    dest[1] = src[1];
	    dest[2] = src[2];
	    dest[3] = src[3];
	    dest += row_size;
	    src += row_size;
	  }
	} else {
	  /* Word aligned, use 32 bit copy */
	  long *src = (long *)rindex1;
	  long *dest = (long *)index;
	  row_size >>= 2;
	  for (rr = 0; rr < 4; rr++) {
	    dest[0] = src[0];
	    dest[1] = src[1];
	    dest += row_size;
	    src += row_size;
	    
	    dest[0] = src[0];
	    dest[1] = src[1];
	    dest += row_size;
	    src += row_size;
	  }
	}
      }
    } else {
      rindex2 = rindex1 + right_half_for + (down_half_for * row_size);
      if (!zflag)
	for (rr = 0; rr < 4; rr++) {
	  index[0] = ((long) (rindex1[0] + rindex2[0]) >> 1) + blockvals[0];
	  index[1] = ((long) (rindex1[1] + rindex2[1]) >> 1) + blockvals[1];
	  index[2] = ((long) (rindex1[2] + rindex2[2]) >> 1) + blockvals[2];
	  index[3] = ((long) (rindex1[3] + rindex2[3]) >> 1) + blockvals[3];
	  index[4] = ((long) (rindex1[4] + rindex2[4]) >> 1) + blockvals[4];
	  index[5] = ((long) (rindex1[5] + rindex2[5]) >> 1) + blockvals[5];
	  index[6] = ((long) (rindex1[6] + rindex2[6]) >> 1) + blockvals[6];
	  index[7] = ((long) (rindex1[7] + rindex2[7]) >> 1) + blockvals[7];
	  index += row_size;
	  rindex1 += row_size;
	  rindex2 += row_size;
	  
	  index[0] = ((long) (rindex1[0] + rindex2[0]) >> 1) + blockvals[8];
	  index[1] = ((long) (rindex1[1] + rindex2[1]) >> 1) + blockvals[9];
	  index[2] = ((long) (rindex1[2] + rindex2[2]) >> 1) + blockvals[10];
	  index[3] = ((long) (rindex1[3] + rindex2[3]) >> 1) + blockvals[11];
	  index[4] = ((long) (rindex1[4] + rindex2[4]) >> 1) + blockvals[12];
	  index[5] = ((long) (rindex1[5] + rindex2[5]) >> 1) + blockvals[13];
	  index[6] = ((long) (rindex1[6] + rindex2[6]) >> 1) + blockvals[14];
	  index[7] = ((long) (rindex1[7] + rindex2[7]) >> 1) + blockvals[15];
	  blockvals += 16;
	  index += row_size;
	  rindex1 += row_size;
	  rindex2 += row_size;
	}
      else
	for (rr = 0; rr < 4; rr++) {
	  index[0] = (long) (rindex1[0] + rindex2[0]) >> 1;
	  index[1] = (long) (rindex1[1] + rindex2[1]) >> 1;
	  index[2] = (long) (rindex1[2] + rindex2[2]) >> 1;
	  index[3] = (long) (rindex1[3] + rindex2[3]) >> 1;
	  index[4] = (long) (rindex1[4] + rindex2[4]) >> 1;
	  index[5] = (long) (rindex1[5] + rindex2[5]) >> 1;
	  index[6] = (long) (rindex1[6] + rindex2[6]) >> 1;
	  index[7] = (long) (rindex1[7] + rindex2[7]) >> 1;
	  index += row_size;
	  rindex1 += row_size;
	  rindex2 += row_size;
	  
	  index[0] = (long) (rindex1[0] + rindex2[0]) >> 1;
	  index[1] = (long) (rindex1[1] + rindex2[1]) >> 1;
	  index[2] = (long) (rindex1[2] + rindex2[2]) >> 1;
	  index[3] = (long) (rindex1[3] + rindex2[3]) >> 1;
	  index[4] = (long) (rindex1[4] + rindex2[4]) >> 1;
	  index[5] = (long) (rindex1[5] + rindex2[5]) >> 1;
	  index[6] = (long) (rindex1[6] + rindex2[6]) >> 1;
	  index[7] = (long) (rindex1[7] + rindex2[7]) >> 1;
	  index += row_size;
	  rindex1 += row_size;
	  rindex2 += row_size;
	}
    }

}


/*
 *--------------------------------------------------------------
 *
 * ReconBMBlock --
 *
 *      Reconstructs back predicted macroblocks.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */

 void
ReconBMBlock(vid_stream, bnum, recon_right_back, recon_down_back, zflag)
  VidStream *vid_stream;
  long bnum, recon_right_back, recon_down_back, zflag;
{
  long mb_row, mb_col, row, col, row_size, rr;
  unsigned char *dest, *future;
  long right_back, down_back, right_half_back, down_half_back;
  unsigned char *rindex1, *rindex2;
  unsigned char *index;
  int *blockvals;

  /* Calculate macroblock row and column from address. */

  mb_row = vid_stream->mblock.mb_address / vid_stream->mb_width;
  mb_col = vid_stream->mblock.mb_address % vid_stream->mb_width;

  /* If block is luminance block... */

  if (bnum < 4) {

    /* Calculate right_back, down_bakc motion vectors. */

    right_back = recon_right_back >> 1;
    down_back = recon_down_back >> 1;
    right_half_back = recon_right_back & 0x1;
    down_half_back = recon_down_back & 0x1;

    /* Set dest to luminance plane of current pict image. */

    dest = vid_stream->current->luminance;

    /*
     * If future frame exists, set future to luminance plane of future frame.
     */

    if (vid_stream->future != NULL)
      future = vid_stream->future->luminance;

    /* Establish row size. */

    row_size = vid_stream->mb_width << 4;

    /* Calculate row,col of upper left pixel in block. */

    row = mb_row << 4;
    col = mb_col << 4;
    if (bnum > 1)
      row += 8;
    if (bnum % 2)
      col += 8;

  }
  /* Otherwise, block is NOT luminance block, ... */

  else {

    /* Construct motion vectors. */

    recon_right_back /= 2;
    recon_down_back /= 2;
    right_back = recon_right_back >> 1;
    down_back = recon_down_back >> 1;
    right_half_back = recon_right_back & 0x1;
    down_half_back = recon_down_back & 0x1;

    /* Establish row size. */

    row_size = vid_stream->mb_width << 3;

    /* Calculate row,col of upper left pixel in block. */

    row = mb_row << 3;
    col = mb_col << 3;

    /* If block is Cr block... */

    if (bnum == 4) {

      /* Set dest to Cr plane of current pict image. */

      dest = vid_stream->current->Cr;

      /*
       * If future frame exists, set future to Cr plane of future image.
       */

      if (vid_stream->future != NULL)
	future = vid_stream->future->Cr;
    }
    /* Otherwise, block is Cb block... */

    else {

      /* Set dest to Cb plane of current pict image. */

      dest = vid_stream->current->Cb;

      /*
       * If future frame exists, set future to Cb plane of future frame.
       */

      if (vid_stream->future != NULL)
	future = vid_stream->future->Cb;
    }
  }

  /* For each pixel in block do... */

    index = dest + (row * row_size) + col;
    rindex1 = future + (row + down_back) * row_size + col + right_back;

    blockvals = &(vid_stream->block.dct_recon[0][0]);

    if ((!right_half_back) && (!down_half_back)) {
      if (!zflag)
	for (rr = 0; rr < 4; rr++) {
	  index[0] = (long) rindex1[0] + (long) blockvals[0];
	  index[1] = (long) rindex1[1] + (long) blockvals[1];
	  index[2] = (long) rindex1[2] + (long) blockvals[2];
	  index[3] = (long) rindex1[3] + (long) blockvals[3];
	  index[4] = (long) rindex1[4] + (long) blockvals[4];
	  index[5] = (long) rindex1[5] + (long) blockvals[5];
	  index[6] = (long) rindex1[6] + (long) blockvals[6];
	  index[7] = (long) rindex1[7] + (long) blockvals[7];
	  index += row_size;
	  rindex1 += row_size;
	  
	  index[0] = (long) rindex1[0] + (long) blockvals[8];
	  index[1] = (long) rindex1[1] + (long) blockvals[9];
	  index[2] = (long) rindex1[2] + (long) blockvals[10];
	  index[3] = (long) rindex1[3] + (long) blockvals[11];
	  index[4] = (long) rindex1[4] + (long) blockvals[12];
	  index[5] = (long) rindex1[5] + (long) blockvals[13];
	  index[6] = (long) rindex1[6] + (long) blockvals[14];
	  index[7] = (long) rindex1[7] + (long) blockvals[15];
	  blockvals += 16;
	  index += row_size;
	  rindex1 += row_size;
	}
      else {
	if (right_back & 0x1) {
	  /* No alignment, use bye copy */
	  for (rr = 0; rr < 4; rr++) {
	    index[0] = rindex1[0];
	    index[1] = rindex1[1];
	    index[2] = rindex1[2];
	    index[3] = rindex1[3];
	    index[4] = rindex1[4];
	    index[5] = rindex1[5];
	    index[6] = rindex1[6];
	    index[7] = rindex1[7];
	    index += row_size;
	    rindex1 += row_size;
	    
	    index[0] = rindex1[0];
	    index[1] = rindex1[1];
	    index[2] = rindex1[2];
	    index[3] = rindex1[3];
	    index[4] = rindex1[4];
	    index[5] = rindex1[5];
	    index[6] = rindex1[6];
	    index[7] = rindex1[7];
	    index += row_size;
	    rindex1 += row_size;
	  }
	} else if (right_back & 0x2) {
	  /* Half-word bit aligned, use 16 bit copy */
	  int *src = (int *)rindex1;
	  int *dest = (int *)index;
	  row_size >>= 1;
	  for (rr = 0; rr < 4; rr++) {
	    dest[0] = src[0];
	    dest[1] = src[1];
	    dest[2] = src[2];
	    dest[3] = src[3];
	    dest += row_size;
	    src += row_size;
	    
	    dest[0] = src[0];
	    dest[1] = src[1];
	    dest[2] = src[2];
	    dest[3] = src[3];
	    dest += row_size;
	    src += row_size;
	  }
	} else {
	  /* Word aligned, use 32 bit copy */
	  long *src = (long *)rindex1;
	  long *dest = (long *)index;
	  row_size >>= 2;
	  for (rr = 0; rr < 4; rr++) {
	    dest[0] = src[0];
	    dest[1] = src[1];
	    dest += row_size;
	    src += row_size;
	    
	    dest[0] = src[0];
	    dest[1] = src[1];
	    dest += row_size;
	    src += row_size;
	  }
	}
      }
    } else {
      rindex2 = rindex1 + right_half_back + (down_half_back * row_size);
      if (!zflag)
	for (rr = 0; rr < 4; rr++) {
	  index[0] = ((long) (rindex1[0] + rindex2[0]) >> 1) + blockvals[0];
	  index[1] = ((long) (rindex1[1] + rindex2[1]) >> 1) + blockvals[1];
	  index[2] = ((long) (rindex1[2] + rindex2[2]) >> 1) + blockvals[2];
	  index[3] = ((long) (rindex1[3] + rindex2[3]) >> 1) + blockvals[3];
	  index[4] = ((long) (rindex1[4] + rindex2[4]) >> 1) + blockvals[4];
	  index[5] = ((long) (rindex1[5] + rindex2[5]) >> 1) + blockvals[5];
	  index[6] = ((long) (rindex1[6] + rindex2[6]) >> 1) + blockvals[6];
	  index[7] = ((long) (rindex1[7] + rindex2[7]) >> 1) + blockvals[7];
	  index += row_size;
	  rindex1 += row_size;
	  rindex2 += row_size;
	  
	  index[0] = ((long) (rindex1[0] + rindex2[0]) >> 1) + blockvals[8];
	  index[1] = ((long) (rindex1[1] + rindex2[1]) >> 1) + blockvals[9];
	  index[2] = ((long) (rindex1[2] + rindex2[2]) >> 1) + blockvals[10];
	  index[3] = ((long) (rindex1[3] + rindex2[3]) >> 1) + blockvals[11];
	  index[4] = ((long) (rindex1[4] + rindex2[4]) >> 1) + blockvals[12];
	  index[5] = ((long) (rindex1[5] + rindex2[5]) >> 1) + blockvals[13];
	  index[6] = ((long) (rindex1[6] + rindex2[6]) >> 1) + blockvals[14];
	  index[7] = ((long) (rindex1[7] + rindex2[7]) >> 1) + blockvals[15];
	  blockvals += 16;
	  index += row_size;
	  rindex1 += row_size;
	  rindex2 += row_size;
	}
      else
	for (rr = 0; rr < 4; rr++) {
	  index[0] = (long) (rindex1[0] + rindex2[0]) >> 1;
	  index[1] = (long) (rindex1[1] + rindex2[1]) >> 1;
	  index[2] = (long) (rindex1[2] + rindex2[2]) >> 1;
	  index[3] = (long) (rindex1[3] + rindex2[3]) >> 1;
	  index[4] = (long) (rindex1[4] + rindex2[4]) >> 1;
	  index[5] = (long) (rindex1[5] + rindex2[5]) >> 1;
	  index[6] = (long) (rindex1[6] + rindex2[6]) >> 1;
	  index[7] = (long) (rindex1[7] + rindex2[7]) >> 1;
	  index += row_size;
	  rindex1 += row_size;
	  rindex2 += row_size;
	  
	  index[0] = (long) (rindex1[0] + rindex2[0]) >> 1;
	  index[1] = (long) (rindex1[1] + rindex2[1]) >> 1;
	  index[2] = (long) (rindex1[2] + rindex2[2]) >> 1;
	  index[3] = (long) (rindex1[3] + rindex2[3]) >> 1;
	  index[4] = (long) (rindex1[4] + rindex2[4]) >> 1;
	  index[5] = (long) (rindex1[5] + rindex2[5]) >> 1;
	  index[6] = (long) (rindex1[6] + rindex2[6]) >> 1;
	  index[7] = (long) (rindex1[7] + rindex2[7]) >> 1;
	  index += row_size;
	  rindex1 += row_size;
	  rindex2 += row_size;
	}
    }

}


/*
 *--------------------------------------------------------------
 *
 * ReconBiMBlock --
 *
 *      Reconstructs bidirectionally predicted macroblocks.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */

 void
ReconBiMBlock(vid_stream, bnum, recon_right_for, recon_down_for,
	      recon_right_back, recon_down_back, zflag)
  VidStream *vid_stream;
  long bnum, recon_right_for, recon_down_for, recon_right_back, recon_down_back;
  long zflag;
{
  long mb_row, mb_col, row, col, row_size, rr;
  unsigned char *dest, *past, *future;
  long right_for, down_for, right_half_for, down_half_for;
  long right_back, down_back, right_half_back, down_half_back;
  unsigned char *index, *rindex1, *bindex1;
  int *blockvals;
  long forw_row_start, back_row_start, forw_col_start, back_col_start;

  /* Calculate macroblock row and column from address. */

  mb_row = vid_stream->mblock.mb_address / vid_stream->mb_width;
  mb_col = vid_stream->mblock.mb_address % vid_stream->mb_width;

  /* If block is luminance block... */

  if (bnum < 4) {

    /*
     * Calculate right_for, down_for, right_half_for, down_half_for,
     * right_back, down_bakc, right_half_back, and down_half_back, motion
     * vectors.
     */

    right_for = recon_right_for >> 1;
    down_for = recon_down_for >> 1;
    right_half_for = recon_right_for & 0x1;
    down_half_for = recon_down_for & 0x1;

    right_back = recon_right_back >> 1;
    down_back = recon_down_back >> 1;
    right_half_back = recon_right_back & 0x1;
    down_half_back = recon_down_back & 0x1;

    /* Set dest to luminance plane of current pict image. */

    dest = vid_stream->current->luminance;

    /* If past frame exists, set past to luminance plane of past frame. */

    if (vid_stream->past != NULL)
      past = vid_stream->past->luminance;

    /*
     * If future frame exists, set future to luminance plane of future frame.
     */

    if (vid_stream->future != NULL)
      future = vid_stream->future->luminance;

    /* Establish row size. */

    row_size = (vid_stream->mb_width << 4);

    /* Calculate row,col of upper left pixel in block. */

    row = (mb_row << 4);
    col = (mb_col << 4);
    if (bnum > 1)
      row += 8;
    if (bnum & 0x01)
      col += 8;

    forw_col_start = col + right_for;
    forw_row_start = row + down_for;

    back_col_start = col + right_back;
    back_row_start = row + down_back;

  }
  /* Otherwise, block is NOT luminance block, ... */

  else {

    /* Construct motion vectors. */

    recon_right_for /= 2;
    recon_down_for /= 2;
    right_for = recon_right_for >> 1;
    down_for = recon_down_for >> 1;
    right_half_for = recon_right_for & 0x1;
    down_half_for = recon_down_for & 0x1;

    recon_right_back /= 2;
    recon_down_back /= 2;
    right_back = recon_right_back >> 1;
    down_back = recon_down_back >> 1;
    right_half_back = recon_right_back & 0x1;
    down_half_back = recon_down_back & 0x1;

    /* Establish row size. */

    row_size = (vid_stream->mb_width << 3);

    /* Calculate row,col of upper left pixel in block. */

    row = (mb_row << 3);
    col = (mb_col << 3);

    forw_col_start = col + right_for;
    forw_row_start = row + down_for;

    back_col_start = col + right_back;
    back_row_start = row + down_back;

    /* If block is Cr block... */

    if (bnum == 4) {

      /* Set dest to Cr plane of current pict image. */

      dest = vid_stream->current->Cr;

      /* If past frame exists, set past to Cr plane of past image. */

      if (vid_stream->past != NULL)
	past = vid_stream->past->Cr;

      /*
       * If future frame exists, set future to Cr plane of future image.
       */

      if (vid_stream->future != NULL)
	future = vid_stream->future->Cr;
    }
    /* Otherwise, block is Cb block... */

    else {

      /* Set dest to Cb plane of current pict image. */

      dest = vid_stream->current->Cb;

      /* If past frame exists, set past to Cb plane of past frame. */

      if (vid_stream->past != NULL)
	past = vid_stream->past->Cb;

      /*
       * If future frame exists, set future to Cb plane of future frame.
       */

      if (vid_stream->future != NULL)
	future = vid_stream->future->Cb;
    }
  }

  /* For each pixel in block... */

  index = dest + (row * row_size) + col;

    rindex1 = past + forw_row_start  * row_size + forw_col_start;

    bindex1 = future + back_row_start * row_size + back_col_start;

  blockvals = (int *) &(vid_stream->block.dct_recon[0][0]);

  {
  if (!zflag)
    for (rr = 0; rr < 4; rr++) {
      index[0] = ((long) (rindex1[0] + bindex1[0]) >> 1) + blockvals[0];
      index[1] = ((long) (rindex1[1] + bindex1[1]) >> 1) + blockvals[1];
      index[2] = ((long) (rindex1[2] + bindex1[2]) >> 1) + blockvals[2];
      index[3] = ((long) (rindex1[3] + bindex1[3]) >> 1) + blockvals[3];
      index[4] = ((long) (rindex1[4] + bindex1[4]) >> 1) + blockvals[4];
      index[5] = ((long) (rindex1[5] + bindex1[5]) >> 1) + blockvals[5];
      index[6] = ((long) (rindex1[6] + bindex1[6]) >> 1) + blockvals[6];
      index[7] = ((long) (rindex1[7] + bindex1[7]) >> 1) + blockvals[7];
      index += row_size;
      rindex1 += row_size;
      bindex1 += row_size;

      index[0] = ((long) (rindex1[0] + bindex1[0]) >> 1) + blockvals[8];
      index[1] = ((long) (rindex1[1] + bindex1[1]) >> 1) + blockvals[9];
      index[2] = ((long) (rindex1[2] + bindex1[2]) >> 1) + blockvals[10];
      index[3] = ((long) (rindex1[3] + bindex1[3]) >> 1) + blockvals[11];
      index[4] = ((long) (rindex1[4] + bindex1[4]) >> 1) + blockvals[12];
      index[5] = ((long) (rindex1[5] + bindex1[5]) >> 1) + blockvals[13];
      index[6] = ((long) (rindex1[6] + bindex1[6]) >> 1) + blockvals[14];
      index[7] = ((long) (rindex1[7] + bindex1[7]) >> 1) + blockvals[15];
      blockvals += 16;
      index += row_size;
      rindex1 += row_size;
      bindex1 += row_size;
    }

  else
    for (rr = 0; rr < 4; rr++) {
      index[0] = (long) (rindex1[0] + bindex1[0]) >> 1;
      index[1] = (long) (rindex1[1] + bindex1[1]) >> 1;
      index[2] = (long) (rindex1[2] + bindex1[2]) >> 1;
      index[3] = (long) (rindex1[3] + bindex1[3]) >> 1;
      index[4] = (long) (rindex1[4] + bindex1[4]) >> 1;
      index[5] = (long) (rindex1[5] + bindex1[5]) >> 1;
      index[6] = (long) (rindex1[6] + bindex1[6]) >> 1;
      index[7] = (long) (rindex1[7] + bindex1[7]) >> 1;
      index += row_size;
      rindex1 += row_size;
      bindex1 += row_size;

      index[0] = (long) (rindex1[0] + bindex1[0]) >> 1;
      index[1] = (long) (rindex1[1] + bindex1[1]) >> 1;
      index[2] = (long) (rindex1[2] + bindex1[2]) >> 1;
      index[3] = (long) (rindex1[3] + bindex1[3]) >> 1;
      index[4] = (long) (rindex1[4] + bindex1[4]) >> 1;
      index[5] = (long) (rindex1[5] + bindex1[5]) >> 1;
      index[6] = (long) (rindex1[6] + bindex1[6]) >> 1;
      index[7] = (long) (rindex1[7] + bindex1[7]) >> 1;
      index += row_size;
      rindex1 += row_size;
      bindex1 += row_size;
    }
  }
}

/*
 *--------------------------------------------------------------
 *
 * ProcessSkippedPFrameMBlocks --
 *
 *      Processes skipped macroblocks in P frames.
 *
 * Results:
 *      Calculates pixel values for luminance, Cr, and Cb planes
 *      in current pict image for skipped macroblocks.
 *
 * Side effects:
 *      Pixel values in pict image changed.
 *
 *--------------------------------------------------------------
 */

 void
ProcessSkippedPFrameMBlocks(vid_stream)
  VidStream *vid_stream;
{
  long row_size, half_row, mb_row, mb_col, row, col, rr;
  long addr, row_incr, half_row_incr, crow, ccol;
  long *dest, *src, *dest1, *src1;

  /* Calculate row sizes for luminance and Cr/Cb macroblock areas. */

  row_size = vid_stream->mb_width << 4;
  half_row = (row_size >> 1);
  row_incr = row_size >> 2;
  half_row_incr = half_row >> 2;

  /* For each skipped macroblock, do... */

  for (addr = vid_stream->mblock.past_mb_addr + 1;
       addr < vid_stream->mblock.mb_address; addr++) {

    /* Calculate macroblock row and col. */

    mb_row = addr / vid_stream->mb_width;
    mb_col = addr % vid_stream->mb_width;

    /* Calculate upper left pixel row,col for luminance plane. */

    row = mb_row << 4;
    col = mb_col << 4;


    /* For each row in macroblock luminance plane... */

    dest = (long *)(vid_stream->current->luminance + (row * row_size) + col);
    src = (long *)(vid_stream->future->luminance + (row * row_size) + col);

    for (rr = 0; rr < 8; rr++) {

      /* Copy pixel values from last I or P picture. */

      dest[0] = src[0];
      dest[1] = src[1];
      dest[2] = src[2];
      dest[3] = src[3];
      dest += row_incr;
      src += row_incr;

      dest[0] = src[0];
      dest[1] = src[1];
      dest[2] = src[2];
      dest[3] = src[3];
      dest += row_incr;
      src += row_incr;
    }

    /*
     * Divide row,col to get upper left pixel of macroblock in Cr and Cb
     * planes.
     */

    crow = row >> 1;
    ccol = col >> 1;

    /* For each row in Cr, and Cb planes... */

    dest = (long *)(vid_stream->current->Cr + (crow * half_row) + ccol);
    src = (long *)(vid_stream->future->Cr + (crow * half_row) + ccol);
    dest1 = (long *)(vid_stream->current->Cb + (crow * half_row) + ccol);
    src1 = (long *)(vid_stream->future->Cb + (crow * half_row) + ccol);

    for (rr = 0; rr < 4; rr++) {

      /* Copy pixel values from last I or P picture. */

      dest[0] = src[0];
      dest[1] = src[1];

      dest1[0] = src1[0];
      dest1[1] = src1[1];

      dest += half_row_incr;
      src += half_row_incr;
      dest1 += half_row_incr;
      src1 += half_row_incr;

      dest[0] = src[0];
      dest[1] = src[1];

      dest1[0] = src1[0];
      dest1[1] = src1[1];

      dest += half_row_incr;
      src += half_row_incr;
      dest1 += half_row_incr;
      src1 += half_row_incr;
    }

  }

  vid_stream->mblock.recon_right_for_prev = 0;
  vid_stream->mblock.recon_down_for_prev = 0;
}




/*
 *--------------------------------------------------------------
 *
 * ProcessSkippedBFrameMBlocks --
 *
 *      Processes skipped macroblocks in B frames.
 *
 * Results:
 *      Calculates pixel values for luminance, Cr, and Cb planes
 *      in current pict image for skipped macroblocks.
 *
 * Side effects:
 *      Pixel values in pict image changed.
 *
 *--------------------------------------------------------------
 */

 void
ProcessSkippedBFrameMBlocks(vid_stream)
  VidStream *vid_stream;
{
  long row_size, half_row, mb_row, mb_col, row, col, rr;
  long right_half_for, down_half_for, c_right_half_for, c_down_half_for;
  long right_half_back, down_half_back, c_right_half_back, c_down_half_back;
  long addr, right_for, down_for;
  long recon_right_for, recon_down_for;
  long recon_right_back, recon_down_back;
  long right_back, down_back;
  long c_right_for, c_down_for;
  long c_right_back, c_down_back;
  unsigned char forw_lum[256];
  unsigned char forw_cr[64], forw_cb[64];
  unsigned char back_lum[256], back_cr[64], back_cb[64];
  long row_incr, half_row_incr;
  long ccol, crow;

  /* Calculate row sizes for luminance and Cr/Cb macroblock areas. */

  row_size = vid_stream->mb_width << 4;
  half_row = (row_size >> 1);
  row_incr = row_size >> 2;
  half_row_incr =  half_row >> 2;

  /* Establish motion vector codes based on full pixel flag. */

  if (vid_stream->picture.full_pel_forw_vector) {
    recon_right_for = vid_stream->mblock.recon_right_for_prev << 1;
    recon_down_for = vid_stream->mblock.recon_down_for_prev << 1;
  } else {
    recon_right_for = vid_stream->mblock.recon_right_for_prev;
    recon_down_for = vid_stream->mblock.recon_down_for_prev;
  }

  if (vid_stream->picture.full_pel_back_vector) {
    recon_right_back = vid_stream->mblock.recon_right_back_prev << 1;
    recon_down_back = vid_stream->mblock.recon_down_back_prev << 1;
  } else {
    recon_right_back = vid_stream->mblock.recon_right_back_prev;
    recon_down_back = vid_stream->mblock.recon_down_back_prev;
  }


  /* If only one motion vector, do display copy, else do full
     calculation. 
  */

  if (0) {
    if (vid_stream->mblock.bpict_past_forw &&
	!vid_stream->mblock.bpict_past_back) {
      for (addr = vid_stream->mblock.past_mb_addr+1;
	   addr < vid_stream->mblock.mb_address; addr++) {
	
	ditherFlags[addr] = 0;
      }
      return;
    }
    if (vid_stream->mblock.bpict_past_back && 
	!vid_stream->mblock.bpict_past_forw) {
      for (addr = vid_stream->mblock.past_mb_addr+1;
	   addr < vid_stream->mblock.mb_address; addr++) {
	
	ditherFlags[addr] = 0;
      }
      return;
    }
  }

  /* Calculate motion vectors. */
  
  if (vid_stream->mblock.bpict_past_forw) {
    right_for = recon_right_for >> 1;
    down_for = recon_down_for >> 1;
    right_half_for = recon_right_for & 0x1;
    down_half_for = recon_down_for & 0x1;
    
    recon_right_for /= 2;
    recon_down_for /= 2;
    c_right_for = recon_right_for >> 1;
    c_down_for = recon_down_for >> 1;
    c_right_half_for = recon_right_for & 0x1;
    c_down_half_for = recon_down_for & 0x1;
    
  }
  if (vid_stream->mblock.bpict_past_back) {
    right_back = recon_right_back >> 1;
    down_back = recon_down_back >> 1;
    right_half_back = recon_right_back & 0x1;
    down_half_back = recon_down_back & 0x1;
    
    recon_right_back /= 2;
    recon_down_back /= 2;
    c_right_back = recon_right_back >> 1;
    c_down_back = recon_down_back >> 1;
    c_right_half_back = recon_right_back & 0x1;
    c_down_half_back = recon_down_back & 0x1;
    
  }
  /* For each skipped macroblock, do... */
  
  for (addr = vid_stream->mblock.past_mb_addr + 1;
       addr < vid_stream->mblock.mb_address; addr++) {
    
    /* Calculate macroblock row and col. */
    
    mb_row = addr / vid_stream->mb_width;
    mb_col = addr % vid_stream->mb_width;
    
    /* Calculate upper left pixel row,col for luminance plane. */
    
    row = mb_row << 4;
    col = mb_col << 4;
    crow = row / 2;
    ccol = col / 2;
    
    /* If forward predicted, calculate prediction values. */
    
    if (vid_stream->mblock.bpict_past_forw) {
      
      ReconSkippedBlock(vid_stream->past->luminance, forw_lum,
			row, col, row_size, right_for, down_for,
			right_half_for, down_half_for, 16);
      ReconSkippedBlock(vid_stream->past->Cr, forw_cr, crow,
			ccol, half_row,
			c_right_for, c_down_for, c_right_half_for, c_down_half_for, 8);
      ReconSkippedBlock(vid_stream->past->Cb, forw_cb, crow,
			ccol, half_row,
			c_right_for, c_down_for, c_right_half_for, c_down_half_for, 8);
    }
    /* If back predicted, calculate prediction values. */
    
    if (vid_stream->mblock.bpict_past_back) {
      ReconSkippedBlock(vid_stream->future->luminance, back_lum,
			row, col, row_size, right_back, down_back,
			right_half_back, down_half_back, 16);
      ReconSkippedBlock(vid_stream->future->Cr, back_cr, crow,
			ccol, half_row,
			c_right_back, c_down_back,
			c_right_half_back, c_down_half_back, 8);
      ReconSkippedBlock(vid_stream->future->Cb, back_cb, crow,
			ccol, half_row,
			c_right_back, c_down_back,
			c_right_half_back, c_down_half_back, 8);
    }
    if (vid_stream->mblock.bpict_past_forw &&
	!vid_stream->mblock.bpict_past_back) {
      
      long *dest, *dest1;
      long *src, *src1;
      dest = (long *)(vid_stream->current->luminance + (row * row_size) + col);
      src = (long *)forw_lum;
      
      for (rr = 0; rr < 16; rr++) {
	
	/* memcpy(dest, forw_lum+(rr<<4), 16);  */
	dest[0] = src[0];
	dest[1] = src[1];
	dest[2] = src[2];
	dest[3] = src[3];
	dest += row_incr;
	src += 4;
      }
      
      dest = (long *)(vid_stream->current->Cr + (crow * half_row) + ccol);
      dest1 = (long *)(vid_stream->current->Cb + (crow * half_row) + ccol);
      src = (long *)forw_cr;
      src1 = (long *)forw_cb;
      
      for (rr = 0; rr < 8; rr++) {
	/*
	 * memcpy(dest, forw_cr+(rr<<3), 8); memcpy(dest1, forw_cb+(rr<<3),
	 * 8);
	 */
	
	dest[0] = src[0];
	dest[1] = src[1];
	
	dest1[0] = src1[0];
	dest1[1] = src1[1];
	
	dest += half_row_incr;
	dest1 += half_row_incr;
	src += 2;
	src1 += 2;
      }
    } else if (vid_stream->mblock.bpict_past_back &&
	       !vid_stream->mblock.bpict_past_forw) {
      
      long *src, *src1;
      long *dest, *dest1;
      dest = (long *)(vid_stream->current->luminance + (row * row_size) + col);
      src = (long *)back_lum;
      
      for (rr = 0; rr < 16; rr++) {
	dest[0] = src[0];
	dest[1] = src[1];
	dest[2] = src[2];
	dest[3] = src[3];
	dest += row_incr;
	src += 4;
      }
      
      
      dest = (long *)(vid_stream->current->Cr + (crow * half_row) + ccol);
      dest1 = (long *)(vid_stream->current->Cb + (crow * half_row) + ccol);
      src = (long *)back_cr;
      src1 = (long *)back_cb;
      
      for (rr = 0; rr < 8; rr++) {
	/*
	 * memcpy(dest, back_cr+(rr<<3), 8); memcpy(dest1, back_cb+(rr<<3),
	 * 8);
	 */
	
	dest[0] = src[0];
	dest[1] = src[1];
	
	dest1[0] = src1[0];
	dest1[1] = src1[1];
	
	dest += half_row_incr;
	dest1 += half_row_incr;
	src += 2;
	src1 += 2;
      }
    } else {
      
      unsigned char *src1, *src2, *src1a, *src2a;
      unsigned char *dest, *dest1;
      dest = vid_stream->current->luminance + (row * row_size) + col;
      src1 = forw_lum;
      src2 = back_lum;
      
      for (rr = 0; rr < 16; rr++) {
	dest[0] = (long) (src1[0] + src2[0]) >> 1;
	dest[1] = (long) (src1[1] + src2[1]) >> 1;
	dest[2] = (long) (src1[2] + src2[2]) >> 1;
	dest[3] = (long) (src1[3] + src2[3]) >> 1;
	dest[4] = (long) (src1[4] + src2[4]) >> 1;
	dest[5] = (long) (src1[5] + src2[5]) >> 1;
	dest[6] = (long) (src1[6] + src2[6]) >> 1;
	dest[7] = (long) (src1[7] + src2[7]) >> 1;
	dest[8] = (long) (src1[8] + src2[8]) >> 1;
	dest[9] = (long) (src1[9] + src2[9]) >> 1;
	dest[10] = (long) (src1[10] + src2[10]) >> 1;
	dest[11] = (long) (src1[11] + src2[11]) >> 1;
	dest[12] = (long) (src1[12] + src2[12]) >> 1;
	dest[13] = (long) (src1[13] + src2[13]) >> 1;
	dest[14] = (long) (src1[14] + src2[14]) >> 1;
	dest[15] = (long) (src1[15] + src2[15]) >> 1;
	dest += row_size;
	src1 += 16;
	src2 += 16;
      }
      
      
      dest = vid_stream->current->Cr + (crow * half_row) + ccol;
      dest1 = vid_stream->current->Cb + (crow * half_row) + ccol;
      src1 = forw_cr;
      src2 = back_cr;
      src1a = forw_cb;
      src2a = back_cb;
      
      for (rr = 0; rr < 8; rr++) {
	dest[0] = (long) (src1[0] + src2[0]) >> 1;
	dest[1] = (long) (src1[1] + src2[1]) >> 1;
	dest[2] = (long) (src1[2] + src2[2]) >> 1;
	dest[3] = (long) (src1[3] + src2[3]) >> 1;
	dest[4] = (long) (src1[4] + src2[4]) >> 1;
	dest[5] = (long) (src1[5] + src2[5]) >> 1;
	dest[6] = (long) (src1[6] + src2[6]) >> 1;
	dest[7] = (long) (src1[7] + src2[7]) >> 1;
	dest += half_row;
	src1 += 8;
	src2 += 8;
	
	dest1[0] = (long) (src1a[0] + src2a[0]) >> 1;
	dest1[1] = (long) (src1a[1] + src2a[1]) >> 1;
	dest1[2] = (long) (src1a[2] + src2a[2]) >> 1;
	dest1[3] = (long) (src1a[3] + src2a[3]) >> 1;
	dest1[4] = (long) (src1a[4] + src2a[4]) >> 1;
	dest1[5] = (long) (src1a[5] + src2a[5]) >> 1;
	dest1[6] = (long) (src1a[6] + src2a[6]) >> 1;
	dest1[7] = (long) (src1a[7] + src2a[7]) >> 1;
	dest1 += half_row;
	src1a += 8;
	src2a += 8;
      }
    }
    
  }
}




/*
 *--------------------------------------------------------------
 *
 * ReconSkippedBlock --
 *
 *      Reconstructs predictive block for skipped macroblocks
 *      in B Frames.
 *
 * Results:
 *      No return values.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */

 void
ReconSkippedBlock(source, dest, row, col, row_size,
		  right, down, right_half, down_half, width)
  unsigned char *source;
  unsigned char *dest;
  long row, col, row_size, right, down, right_half, down_half, width;
{
  long rr;
  unsigned char *source2;

  source += ((row + down) * row_size) + col + right;

  if (width == 16) {
    if ((!right_half) && (!down_half)) {
	if (right & 0x1) {
	  /* No alignment, use bye copy */
	  for (rr = 0; rr < 16; rr++) {
	    dest[0] = source[0];
	    dest[1] = source[1];
	    dest[2] = source[2];
	    dest[3] = source[3];
	    dest[4] = source[4];
	    dest[5] = source[5];
	    dest[6] = source[6];
	    dest[7] = source[7];
	    dest[8] = source[8];
	    dest[9] = source[9];
	    dest[10] = source[10];
	    dest[11] = source[11];
	    dest[12] = source[12];
	    dest[13] = source[13];
	    dest[14] = source[14];
	    dest[15] = source[15];
	    dest += 16;
	    source += row_size;
	  }
	} else if (right & 0x2) {
	  /* Half-word bit aligned, use 16 bit copy */
	  int *src = (int *)source;
	  int *d = (int *)dest;
	  row_size >>= 1;
	  for (rr = 0; rr < 16; rr++) {
	    d[0] = src[0];
	    d[1] = src[1];
	    d[2] = src[2];
	    d[3] = src[3];
	    d[4] = src[4];
	    d[5] = src[5];
	    d[6] = src[6];
	    d[7] = src[7];
	    d += 8;
	    src += row_size;
	  }
	} else {
	  /* Word aligned, use 32 bit copy */
	  long *src = (long *)source;
	  long *d = (long *)dest;
	  row_size >>= 2;
	  for (rr = 0; rr < 16; rr++) {
	    d[0] = src[0];
	    d[1] = src[1];
	    d[2] = src[2];
	    d[3] = src[3];
	    d += 4;
	    src += row_size;
	  }
	}
    } else {
      source2 = source + right_half + (row_size * down_half);
      for (rr = 0; rr < width; rr++) {
	dest[0] = (long) (source[0] + source2[0]) >> 1;
	dest[1] = (long) (source[1] + source2[1]) >> 1;
	dest[2] = (long) (source[2] + source2[2]) >> 1;
	dest[3] = (long) (source[3] + source2[3]) >> 1;
	dest[4] = (long) (source[4] + source2[4]) >> 1;
	dest[5] = (long) (source[5] + source2[5]) >> 1;
	dest[6] = (long) (source[6] + source2[6]) >> 1;
	dest[7] = (long) (source[7] + source2[7]) >> 1;
	dest[8] = (long) (source[8] + source2[8]) >> 1;
	dest[9] = (long) (source[9] + source2[9]) >> 1;
	dest[10] = (long) (source[10] + source2[10]) >> 1;
	dest[11] = (long) (source[11] + source2[11]) >> 1;
	dest[12] = (long) (source[12] + source2[12]) >> 1;
	dest[13] = (long) (source[13] + source2[13]) >> 1;
	dest[14] = (long) (source[14] + source2[14]) >> 1;
	dest[15] = (long) (source[15] + source2[15]) >> 1;
	dest += width;
	source += row_size;
	source2 += row_size;
      }
    }
  } else {                      /* (width == 8) */
    if ((!right_half) && (!down_half)) {
      if (right & 0x1) {
	for (rr = 0; rr < width; rr++) {
	  dest[0] = source[0];
	  dest[1] = source[1];
	  dest[2] = source[2];
	  dest[3] = source[3];
	  dest[4] = source[4];
	  dest[5] = source[5];
	  dest[6] = source[6];
	  dest[7] = source[7];
	  dest += 8;
	  source += row_size;
	}
      } else if (right & 0x02) {
	int *d = (int *)dest;
	int *src = (int *)source;
	row_size >>= 1;
	for (rr = 0; rr < width; rr++) {
	  d[0] = src[0];
	  d[1] = src[1];
	  d[2] = src[2];
	  d[3] = src[3];
	  d += 4;
	  src += row_size;
	}
      } else {
	long *d = (long *)dest;
	long *src = (long *)source;
	row_size >>= 2;
	for (rr = 0; rr < width; rr++) {
	  d[0] = src[0];
	  d[1] = src[1];
	  d += 2;
	  src += row_size;
	}
      }
    } else {
      source2 = source + right_half + (row_size * down_half);
      for (rr = 0; rr < width; rr++) {
	dest[0] = (long) (source[0] + source2[0]) >> 1;
	dest[1] = (long) (source[1] + source2[1]) >> 1;
	dest[2] = (long) (source[2] + source2[2]) >> 1;
	dest[3] = (long) (source[3] + source2[3]) >> 1;
	dest[4] = (long) (source[4] + source2[4]) >> 1;
	dest[5] = (long) (source[5] + source2[5]) >> 1;
	dest[6] = (long) (source[6] + source2[6]) >> 1;
	dest[7] = (long) (source[7] + source2[7]) >> 1;
	dest += width;
	source += row_size;
	source2 += row_size;
      }
    }
  }
}



/*
 *--------------------------------------------------------------
 *
 * DoPictureDisplay --
 *
 *      Converts image from Lum, Cr, Cb to colormap space. Puts
 *      image in lum plane. Updates past and future frame
 *      pointers. Dithers image. Sends to display mechanism.
 *
 * Results:
 *      Pict image structure locked if displaying or if frame
 *      is needed as past or future reference.
 *
 * Side effects:
 *      Lum plane pummelled.
 *
 *--------------------------------------------------------------
 */

void
DoPictureDisplay(vid_stream)
  VidStream *vid_stream;
{

  /* Convert to colormap space and dither. */

  DoDitherImage(vid_stream->current->luminance, vid_stream->current->Cr,
		vid_stream->current->Cb, vid_stream->current->display,
		vid_stream->mb_height * 16, vid_stream->mb_width * 16);

  /* Update past and future references if needed. */
  if ((vid_stream->picture.code_type == I_TYPE) || (vid_stream->picture.code_type == P_TYPE)) {
    if (vid_stream->future == NULL) {
      vid_stream->future = vid_stream->current;
      vid_stream->future->locked |= FUTURE_LOCK;
    } else {
      if (vid_stream->past != NULL) {
	vid_stream->past->locked &= ~PAST_LOCK;
      }
      vid_stream->past = vid_stream->future;
      vid_stream->past->locked &= ~FUTURE_LOCK;
      vid_stream->past->locked |= PAST_LOCK;
      vid_stream->future = vid_stream->current;
      vid_stream->future->locked |= FUTURE_LOCK;
      vid_stream->current = vid_stream->past;
      ExecuteDisplay(vid_stream);
    }
  } else
    ExecuteDisplay(vid_stream);

}
