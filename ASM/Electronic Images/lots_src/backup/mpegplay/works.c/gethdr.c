/* gethdr.c, header decoding                                                */

#include <stdio.h>
#include <stdlib.h>
#include "global.h"

static unsigned int zig_zag_scan[64]=
{
  0,1,8,16,9,2,3,10,17,24,32,25,18,11,4,5,
  12,19,26,33,40,48,41,34,27,20,13,6,7,14,21,28,
  35,42,49,56,57,50,43,36,29,22,15,23,30,37,44,51,
  58,59,52,45,38,31,39,46,53,60,61,54,47,55,62,63
};
int getheader()
{
  unsigned long code;
  for (;;)
  {
    startcode();	    /* look for startcode */
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
    case SEQ_END_CODE:
      return 0;
    default:
      break;
    }
  }
}


/* align to start of next startcode */

void startcode()
{
  /* byte align */
  flushbits(ld_incnt & 7);
  while (showbits(24)!=1l)
    flushbits(8);
}


/* decode sequence header */

void getseqhdr()
{
  static unsigned char default_intra_matrix[64] = {
    8, 16, 19, 22, 26, 27, 29, 34,
    16, 16, 22, 24, 27, 29, 34, 37,
    19, 22, 26, 27, 29, 34, 34, 38,
    22, 22, 26, 27, 29, 34, 37, 40,
    22, 26, 27, 29, 32, 35, 40, 48,
    26, 27, 29, 32, 35, 40, 48, 58,
    26, 27, 29, 34, 38, 46, 56, 69,
  27, 29, 35, 38, 46, 56, 69, 83};

  int i;
  horizontal_size = getbits(12);
  vertical_size = getbits(12);
  flushbits(27);  /*aspect ratio(4)/picture rate(4)/bitrate(18)/marker bit(1))
  flushbits(11); /*vbf buffer size(10)/constrain params flag(1) */

  if (getbits(1))
  {	for (i=0; i<64; i++) ld_intra_quantizer_matrix[zig_zag_scan[i]] = getbits(8);
  }
  else
  {	for (i=0; i<64; i++) ld_intra_quantizer_matrix[i] = default_intra_matrix[i];
  }

  if (getbits(1))
  {	for (i=0; i<64; i++)  flushbits(8);		/* skip non-intra quantab */
  }

  ext_user_data();
}


/* decode group of pictures header */

void getgophdr()
{
  flushbits(27); /* dropflag(1)/hour(5)/minute(6)/(1)/seconds(6)/frame(24)/closed_gop(1)/broken_link(1) */
  ext_user_data();
}


/* decode picture header */

void getpicturehdr()
{
  flushbits(10);	/*temp ref */
  pict_type = getbits(3);
  flushbits(16);	/* vbv_delay */
  ext_bit_info();
  ext_user_data();
}

/* decode slice header */

int getslicehdr()
{
  ld_quant_scale = getbits(5);
  if (getbits(1))
  { flushbits(8);
    ext_bit_info();
  }
  return 0;
}


/* decode extension and user data */

void ext_user_data()
{
  unsigned long code,ext_ID;

  startcode();

  while ((code = showbits(32))==EXT_START_CODE || (code==USER_START_CODE))
  { 
      flushbits(32);
      startcode();
  }
}



/* decode extra bit information */

void ext_bit_info()
{
  while (getbits(1))
    flushbits(8);
}
