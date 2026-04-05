#include "ice_private.h"

#ifdef ICE_DEBUG
#include <stdio.h>
#endif

#include<string.h>
#include <stdlib.h>
#include<stdio.h>

typedef struct ice_decrunch_state
{
  char *unpacked_stop;
  char *unpacked;
  char *packed;
  int bits;
} state_t;

static char *packed_start;

static size_t
init_state (state_t *state, char *data, char *destination)
{
  size_t unpacked_length;


  state->unpacked_stop = destination;
  state->packed = data + ice_crunched_length (data);
  packed_start = state->packed;
  state->bits = (unsigned char)*--state->packed;
  unpacked_length = ice_decrunched_length (data);
  state->unpacked = destination + unpacked_length;

  return unpacked_length;
}

static void
memcpybwd (char *to, char *from, size_t n)
{
  to += n;
  from += n;
  while (n-- > 0)
    *--to = *--from;
}

static int
get_bit (state_t *state)
{
  int bit;

  bit = (state->bits & 0x80) != 0;
  state->bits = (state->bits << 1) & 0xff;
  if (state->bits == 0)
    {
      state->bits = *--state->packed;
      bit = (state->bits & 0x80) != 0;
      state->bits = ((state->bits << 1) & 0xff) + 1;
    }

  return bit;
}

static int
get_bits (state_t *state, int n)
{
  int bits = 0;

  while (n--)
    bits = bits << 1 | get_bit (state);

  return bits;
}

static int
get_depack_length (state_t *state)
{
  static int bits_to_get[]   = { 0, 0, 1, 2, 10 };
  static int number_to_add[] = { 2, 3, 4, 6, 10 };
  int i, length;
  int bits;

  for (i = 0; i < 4; i++)
    {
      if (get_bit (state) == 0)
	break;
    }

  bits = bits_to_get[i];
  if (bits > 0)
    length = get_bits (state, bits);
  else
    length = 0;
  length += number_to_add[i];

  return length;
}

static int
get_depack_offset (state_t *state, int length)
{
  int i, offset;
  int bits, add;

  if (length == 2)
    {
      if (get_bit (state))
	{
	  bits = 9;
	  add = 0x3f;
	}
      else
	{
	  bits = 6;
	  add = -1;
	}

      offset = get_bits (state, bits) + add;
    }
  else
    {
      static int bits_to_get[] =   {  8,  5,  12 };
      static int number_to_add[] = { 31, -1, 287 };

      for (i = 0; i < 2; i++)
	{
	  if (get_bit (state) == 0)
	    break;
	}

      bits = bits_to_get[i];
      add = number_to_add[i];
      offset = get_bits (state, bits) + add;
      if (offset < 0)
	offset -= length - 2;
    }

  return offset;
}

static int
get_direct_length (state_t *state)
{
  int bits_to_get[] =   { 1, 2, 2, 3,    8,     15 };
  int all_ones[] =      { 1, 3, 3, 7, 0xff, 0x7fff };
  int number_to_add[] = { 1, 2, 5, 8,   15,    270, 270 };
  int i, n;

  for (i = 0; i < 6; i++)
    {
      n = get_bits (state, bits_to_get[i]);
      if (n != all_ones[i])
	break;
    }
  n += number_to_add[i];

  return n;
}

static void
normal_bytes (state_t *state)
{
  int length, offset;

  for (;;)
    {
      if (get_bit (state))
	{
	  length = get_direct_length (state);
#ifdef ICE_DEBUG
	  fprintf (stderr, "copy: length = %d\n", length);
#endif
	  state->packed -= length;
	  state->unpacked -= length;

	  if (state->unpacked < state->unpacked_stop)
	    exit (1);
	  memcpy (state->unpacked, state->packed, length);
	}

      if (state->unpacked > state->unpacked_stop)
	{
	  length = get_depack_length (state);
	  offset = get_depack_offset (state, length);

#ifdef ICE_DEBUG
	  fprintf (stderr,
		   "pack: length = %d, offset = %d\n",
		   length,
		   offset >= 0 ? offset + length : offset + length - 2);
#endif

	  state->unpacked -= length;

	  if (state->unpacked < state->unpacked_stop)
	    exit (1);
	  memcpybwd (state->unpacked,
		     state->unpacked + length + offset,
		     length);
	}
      else
	return;
    }
}

size_t
ice_decrunch (char *data, char *destination)
{
  size_t unpacked_length;
  state_t state;

  if (!is_ice_data (data))
    return 0;

  unpacked_length = init_state (&state, data, destination);
  normal_bytes (&state);

#if 0
  if (is_picture_data)
    something();
#endif

  return unpacked_length;
}

size_t
ice_decrunch_2 (char *data)
{
  char save[ICE_DECRUNCH2_EXTRA_SIZE];
  size_t unpacked_length;
  state_t state;

  if (!is_ice_data (data))
    return 0;

  unpacked_length = init_state (&state, data, data + ICE_DECRUNCH2_EXTRA_SIZE);
  memcpy (save, data + unpacked_length, ICE_DECRUNCH2_EXTRA_SIZE);
  normal_bytes (&state);

#if 0
  if (is_picture_data)
    something();
#endif

  memcpy (data + unpacked_length, save, ICE_DECRUNCH2_EXTRA_SIZE);
  return unpacked_length;
}
