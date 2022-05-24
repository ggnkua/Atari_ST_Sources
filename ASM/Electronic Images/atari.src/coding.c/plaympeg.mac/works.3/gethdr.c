/*
 *	PLAYMPEG
 *	Martin Griffiths 1995.
 */

#include <stdio.h>
#include <stdlib.h>
#include "plaympeg.h"
#include "proto.h"

static void getseqhdr _ANSI_ARGS_((void));
static void getgophdr _ANSI_ARGS_((void));
static void getpicturehdr _ANSI_ARGS_((void));
static void ext_user_data _ANSI_ARGS_((void));
static void ext_bit_info _ANSI_ARGS_((void));


/*
 * decode headers from one input stream
 * until an End of Sequence or picture start code
 * is found
 */

INT32 getheader()
{
  UINT32 code;

  for (;;)
  {
    /* look for startcode */
    startcode();
    code = getbits(32);
    switch (code)
    {
    case SEQ_START_CODE:
      getseqhdr();
      break;
    case GOP_START_CODE:
      getgophdr();
      break;
    case PICTURE_START_CODE:
      getpicturehdr();
      return 1;
      break;
    case SEQ_END_CODE:
      return 0;
      break;
    default:
      if (!quiet)
        fprintf(stderr,"Unexpected startcode %08x (ignored)\n",code);
      break;
    }
  }
}


/* align to start of next startcode */

void startcode()
{
  /* byte align */
  flushbits(ld_incnt&7);
  while (showbits(24)!=1l)
    flushbits(8);
}


/* decode sequence header */

static void getseqhdr()
{
  INT32 i;
  INT32 aspect_ratio, picture_rate, vbv_buffer_size;
  INT32 constrained_parameters_flag;
  INT32 load_intra_quantizer_matrix, load_non_intra_quantizer_matrix;
  INT32 bit_rate;
  horizontal_size = getbits(12);
  vertical_size = getbits(12);
  aspect_ratio = getbits(4);
  picture_rate = getbits(4);
  bit_rate = getbits(18);
  flushbits(1); /* marker bit (=1) */
  vbv_buffer_size = getbits(10);
  constrained_parameters_flag = getbits(1);

  if (load_intra_quantizer_matrix = getbits(1))
  {
    for (i=0; i<64; i++)
      ld_intra_quantizer_matrix[zig_zag_scan[i]] = getbits(8);
  }
  else
  {
    for (i=0; i<64; i++)
      ld_intra_quantizer_matrix[i] = default_intra_quantizer_matrix[i];
  }

  if (load_non_intra_quantizer_matrix = getbits(1))
  {
    for (i=0; i<64; i++)
      ld_non_intra_quantizer_matrix[zig_zag_scan[i]] = getbits(8);
  }
  else
  {
    for (i=0; i<64; i++)
      ld_non_intra_quantizer_matrix[i] = 16;
  }

  /* copy luminance to chrominance matrices */
  for (i=0; i<64; i++)
  {
    ld_chroma_intra_quantizer_matrix[i] =
      ld_intra_quantizer_matrix[i];

    ld_chroma_non_intra_quantizer_matrix[i] =
      ld_non_intra_quantizer_matrix[i];
  }

  ext_user_data();
}


/* decode group of pictures header */

static void getgophdr()
{
  INT32 drop_flag, hour, minute, sec, frame, closed_gop, broken_link;
  drop_flag = getbits(1);
  hour = getbits(5);
  minute = getbits(6);
  flushbits(1);
  sec = getbits(6);
  frame = getbits(6);
  closed_gop = getbits(1);
  broken_link = getbits(1);
  ext_user_data();
}


/* decode picture header */

static void getpicturehdr()
{
  INT32 temp_ref, vbv_delay;

  temp_ref = getbits(10);
  pict_type = getbits(3);
  vbv_delay = getbits(16);
  if (pict_type==P_TYPE || pict_type==B_TYPE)
  {
    full_forw = getbits(1);
    forw_r_size = getbits(3) - 1;
  }
  if (pict_type==B_TYPE)
  {
    full_back = getbits(1);
    back_r_size = getbits(3) - 1;
  }

  ext_bit_info();
  ext_user_data();
}

/* decode slice header */

void getslicehdr()
{
  INT32 intra_slice;

  ld_quant_scale =	getbits(5);

  if (getbits(1))
  {
    intra_slice = getbits(1);
    flushbits(7);
    ext_bit_info();
  }
  else
    intra_slice = 0;

}


/* decode extension and user data */

static void ext_user_data()
{
  INT32 code,ext_ID;

  startcode();

  while ((code = showbits(32))==EXT_START_CODE || code==USER_START_CODE)
  {
    if (code==EXT_START_CODE)
    {
      flushbits(32);
      ext_ID = getbits(4);
      startcode();
    }
    else
    {
      flushbits(32);
      startcode();
    }
  }
}

/* decode extra bit information */

static void ext_bit_info()
{
  while (getbits1())
    flushbits(8);
}
