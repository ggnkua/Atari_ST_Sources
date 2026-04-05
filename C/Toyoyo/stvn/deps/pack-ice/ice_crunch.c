#include <stdlib.h>
#include <string.h>
#include "ice_private.h"

#undef NEW_ALGORITHM

#ifdef ICE_DEBUG
#include <stdio.h>
#endif

#define COPY (-2)

typedef struct
{
  int last_copy_direct;
  size_t unpacked_length;
  char *unpacked_start;
  char *unpacked_stop;
  char *unpacked;
  char *packed_start;
  char *packed;
  char *write_bits_here;
  int bits;
  int bits_written;
  int bits_copied;
} state_t;

static void
init_state (state_t *state, char *data, size_t length, void *packed_start)
{
  state->unpacked_length = length;
  state->unpacked_start = data + length;
  state->unpacked_stop = data;
  state->unpacked = data + length;
  state->packed_start = packed_start;
  state->packed = state->packed_start;
  state->last_copy_direct = 0;
  state->write_bits_here = NULL;
  state->bits = 1;
  state->bits_written = 0;
  state->bits_copied = 0;
}

static void
putinfo (char *data, size_t info)
{
  int i;

  for (i = 0; i < 4; i++)
    {
      *data++ = (info >> 24) & 0xff;
      info <<= 8;
    }
}

static int
pack_length_bits (int length)
{
  if (length == 0)
    return 0;
  if (length < 2)
    return 1000000;
  else if (length < 3)
    return 1;
  else if (length < 4)
    return 2;
  else if (length < 6)
    return 4;
  else if (length < 10)
    return 6;
  else if (length < 1034)
    return 14;
  else
    return 1000000;
}

static int
pack_offset_bits (int length, int offset)
{
  offset -= length;

  if (length == 0)
    return 0;
  if (length == 2)
    {
      if (offset < 63)
	return 7;
      else if (offset < 575)
	return 10;
      else
	return 1000000;
    }
  else /* length > 2 */
    {
      if (offset < 31)
	return 7;
      else if (offset < 287)
	return 9;
      else if (offset < 4383)
	return 14;
      else
	return 1000000;
    }
}

static int
pack_bits (int length, int offset)
{
  return pack_length_bits (length) + pack_offset_bits (length, offset);
}

static int
copy_length_bits (int length)
{
  if (length < 1)
    return 1;
  if (length < 2)
    return 2;
  else if (length < 5)
    return 4;
  else if (length < 8)
    return 6;
  else if (length < 15)
    return 9;
  else if (length < 270)
    return 17;
  else if (length < 33038)
    return 32;
  else
    return 1000000;
}

static int
copy_bits (int length)
{
  return copy_length_bits (length) + 8 * length;
}

void
write_bit (state_t *state, int bit)
{
  state->bits = (state->bits << 1) | bit;
  if (state->bits & 0x100)
    {
      if (state->write_bits_here == NULL)
	{
	  *--state->packed = state->bits & 0xff;
	}
      else
	{
	  *state->write_bits_here = state->bits & 0xff;
	  state->write_bits_here = NULL;
	}
      state->bits = 1;
    }

  state->bits_written++;
  if (state->bits_written == 7)
    write_bit (state, 1);
}

static void
write_bits (state_t *state, int length, int bits)
{
  int i;

  for (i = length - 1; i >= 0; i--)
    write_bit (state, (bits >> i) & 1);
}

static void
write_next_bits_here (state_t *state)
{
  if (state->bits != 1 &&
      state->write_bits_here == NULL)
    state->write_bits_here = --state->packed;
}

static void
flush_bits (state_t *state)
{
  write_bits (state, 7, 0);
}

static void
pack_string (state_t *state, int length, int offset)
{
  if (length == 0)
    {
      return;
    }
  if (length < 2)
    {
      exit (1);
    }
  else if (length < 3)
    {
      write_bit (state, 0);
    }
  else if (length < 4)
    {
      write_bit (state, 1);
      write_bit (state, 0);
    }
  else if (length < 6)
    {
      write_bit (state, 1);
      write_bit (state, 1);
      write_bit (state, 0);
      write_bits (state, 1, length - 4);
    }
  else if (length < 10)
    {
      write_bit (state, 1);
      write_bit (state, 1);
      write_bit (state, 1);
      write_bit (state, 0);
      write_bits (state, 2, length - 6);
    }
  else if (length < 1034)
    {
      write_bit (state, 1);
      write_bit (state, 1);
      write_bit (state, 1);
      write_bit (state, 1);
      write_bits (state, 10, length - 10);
    }
  else
    {
      exit (1);
    }

  if (offset > 0)
    offset -= length;

  if (length == 2)
    {
      if (offset < 63)
	{
	  write_bit (state, 0);
	  write_bits (state, 6, offset + 1);
	}
      else if (offset < 575)
	{
	  write_bit (state, 1);
	  write_bits (state, 9, offset - 63);
	}
      else
	{
	  exit (1);
	}
    }
  else /* length > 2 */
    {
      if (offset < 31)
	{
	  write_bit (state, 1);
	  write_bit (state, 0);
	  write_bits (state, 5, offset + 1);
	}
      else if (offset < 287)
	{
	  write_bit (state, 0);
	  write_bits (state, 8, offset - 31);
	}
      else if (offset < 4383)
	{
	  write_bit (state, 1);
	  write_bit (state, 1);
	  write_bits (state, 12, offset - 287);
	}
      else
	{
	  exit (1);
	}
    }

  state->unpacked -= length;
}

static void
copy_direct (state_t *state, int length)
{
  state->bits_copied += 8 * length;

  if (length == 0)
    {
      write_bit (state, 0);
      return;
    }

  write_bit (state, 1);

  if (length > 33037)
    {
      exit (1);
    }

  if (length < 2)
    {
      write_bits (state, 1, 0);
    }
  else if (length < 5)
    {
      write_bits (state, 1, 1);
      write_bits (state, 2, length - 2);
    }
  else if (length < 8)
    {
      write_bits (state, 1, 1);
      write_bits (state, 2, 3);
      write_bits (state, 2, length - 5);
    }
  else if (length < 15)
    {
      write_bits (state, 1, 1);
      write_bits (state, 2, 3);
      write_bits (state, 2, 3);
      write_bits (state, 3, length - 8);
    }
  else if (length < 270)
    {
      write_bits (state, 1, 1);
      write_bits (state, 2, 3);
      write_bits (state, 2, 3);
      write_bits (state, 3, 7);
      write_bits (state, 8, length - 15);
    }
  else /* length < 33038 */
    {
      write_bits (state, 1, 0x01);
      write_bits (state, 2, 0x03);
      write_bits (state, 2, 0x03);
      write_bits (state, 3, 0x07);
      write_bits (state, 8, 0xff);
      write_bits (state, 15, length - 270);
    }
  
  write_next_bits_here (state);
  state->packed -= length;
  state->unpacked -= length;
  memcpy (state->packed, state->unpacked, length);
}

static void
debug_print_info (state_t *state, const char *name, int length, int offset)
{
#ifdef ICE_DEBUG
  int bits;
  int i;

  if (length == 0 && offset != COPY)
    return;

  if (offset == COPY)
    bits = copy_bits (length);
  else
    bits = pack_bits (length, offset);

  fprintf (stderr, "%s: %3d", name, length);
  if (offset < -1)
    fprintf (stderr, "      ");
  else
    fprintf (stderr, ", %3d ", offset);
  fprintf (stderr, "%3d->%2d \"", 8 * length, bits);
  for (i = 0; i < length; i++)
    {
      unsigned char c = state->unpacked[i];
      switch (c)
	{
	case '\n':
	  fprintf (stderr, "\\n");
	  break;
	case '\t':
	  fprintf (stderr, "\\t");
	  break;
	default:
	  if (c < 32 || c >= 127)
	    fprintf (stderr, "\\x%02x", c);
	  else
	    fputc (c, stderr);
	}
    }
  fprintf (stderr, "\"\n");
#endif
}

#ifndef NEW_ALGORITHM

static void analyze (state_t *state, int level, int *copy_length,
		     int *pack_length, int *pack_offset);

static int
search_string (state_t *state, int *ret_length, int level)
{
  int offset, length, max_offset, max_length;
  double compression, max_compression;

#if 1
  max_length = 1;
  max_offset = 0;
  max_compression = 0.0;

  for (offset = -1; offset < 4383; offset++)
    {
      int uncompressed_bits;
      int compressed_bits;
      int X = offset == -1 ? 0 : -1;

      if (offset == -1 && state->unpacked == state->unpacked_start)
	break;
      if (state->unpacked + offset > state->unpacked_start)
	break;

      for (length = 0;
	   state->unpacked[offset - length + X] ==
	     state->unpacked[-length + X];
	   length++)
	{
	  if (state->unpacked - length + X < state->unpacked_stop)
	    break;
	  if (length == offset)
	    break;
	  if (length == 1033)
	    break;
	}

      if (length < 2)
	continue;
      if (length == 2 && offset >= 574)
	continue;

      uncompressed_bits = 8 * length;
      compressed_bits = pack_bits (length, offset);
      compression = (double)uncompressed_bits / (double)compressed_bits;

      if (compression > max_compression)
	{
	  max_compression = compression;
	  max_length = length;
	  max_offset = offset;
	}
    }
#else
  {
    int i;

    for (i = 0; i < 1034; i++)
      {
	if (state->unpacked[-i - 1] != state->unpacked[-i])
	  break;
      }

    if (i > 1 && state->unpacked < state->unpacked_start)
      {
	max_length = i;
	max_offset = -1;
	max_compression = 
	  (double)(8 * i) / (double)pack_bits (i, -1);
      }
    else
      {
	max_length = 1;
	max_offset = 0;
	max_compression = 0.0;
      }
  }

  for (offset = 1; offset < 4383; offset++)
    {
      int uncompressed_bits;
      int compressed_bits;

      if (state->unpacked + offset > state->unpacked_start)
	break;

      for (length = 1;
	   state->unpacked[offset - length] ==
	     state->unpacked[-length];
	   length++)
	{
	  if (length == offset)
	    break;
	  if (length == 1033)
	    break;
	  if (length < 2)
	    continue;
	  if (length == 2 && offset >= 574)
	    continue;

	  uncompressed_bits = 8 * length;
	  compressed_bits = pack_bits (length, offset);

	  if ((double)uncompressed_bits /
	      (double)compressed_bits > max_compression &&
	      level > 1 && state->unpacked - length > state->unpacked_stop)
	    {
	      state_t new_state = *state;
	      int clen, plen, poff;

	      new_state.unpacked -= length;
	      analyze (&new_state, level - 1, &clen, &plen, &poff);
	      if (clen == 0 && poff == offset)
		continue;
	      if (clen > 0 || plen > 0)
		{
		  uncompressed_bits += 8 * (clen + plen);
		  compressed_bits += copy_bits (clen) + pack_bits (plen, poff);
		}
	    }

	  compression = (double)uncompressed_bits / (double)compressed_bits;

	  if (compression > max_compression)
	    {
	      max_compression = compression;
	      max_length = length;
	      max_offset = offset;
	    }
	}
    }
#endif

  *ret_length = max_length;
  return max_offset;
}

static void
analyze (state_t *state, int level, int *copy_length, int *pack_length,
	 int *pack_offset)
{
  int max_copy_length;
  int max_pack_length;
  int max_pack_offset;
  double max_compression;
  int i, N;

  if (level == 0)
    return;

  max_copy_length = state->unpacked - state->unpacked_stop;
  max_pack_length = 0;
  max_pack_offset = 0;

  max_compression = 0;
  N = 33038;
  for (i = 0; i < N; i++)
    {
      int compressed_bits, uncompressed_bits;
      int length, offset;
      state_t new_state = *state;
      double compression;

      if (new_state.unpacked - i < new_state.unpacked_stop)
	break;

      new_state.unpacked -= i;

      offset = search_string (&new_state, &length, level);
      if (length < 2)
	continue;

      new_state.unpacked -= length;
      uncompressed_bits = 8 * (i + length);
      compressed_bits = copy_bits (i) + pack_bits (length, offset);

      if (level > 1)
      {
	int clen, plen, poff;
	analyze (&new_state, level - 1, &clen, &plen, &poff);
	if (clen > 0 || plen > 0)
	  {
	    uncompressed_bits += 8 * (clen + plen);
	    compressed_bits += copy_bits (clen) + pack_bits (plen, poff);
	  }
      }

      compression = (double)uncompressed_bits /
	            (double)compressed_bits;

      if (compression > max_compression)
	{
	  max_compression = compression;
	  max_copy_length = i;
	  max_pack_length = length;
	  max_pack_offset = offset;
	  N = i + 2;
	}
    }

  *copy_length = max_copy_length;
  *pack_length = max_pack_length;
  *pack_offset = max_pack_offset;
}

static void
crunch (state_t *state, int level)
{
  do
    {
      int copy_length, pack_length, pack_offset;

level = 2;
      analyze (state, level, &copy_length, &pack_length, &pack_offset);

      copy_direct (state, copy_length);
      debug_print_info (state, "copy", copy_length, COPY);
      pack_string (state, pack_length, pack_offset);
      debug_print_info (state, "pack", pack_length, pack_offset);
    }
  while (state->unpacked > state->unpacked_stop);

#ifdef ICE_DEBUG
  fprintf (stderr,
	   "summary: %d bits encoded in %d bits, compression factor %.2f\n",
	   8 * state->unpacked_length,
	   state->bits_written - 1 + state->bits_copied,
	   (double)(8 * state->unpacked_length) /
	   (double)(state->bits_written + state->bits_copied));
#endif

  flush_bits (state);

  state->packed -= 4;
  putinfo (state->packed, state->unpacked_length);
  state->packed -= 4;
  putinfo (state->packed, state->packed_start - state->packed + 4);
  state->packed -= 4;
  putinfo (state->packed, ICE_MAGIC);
}

#else /* NEW_ALGORITHM */

typedef struct
{
  int length;
  int offset;
  int bits;
} info_t;

static void
compress (state_t *state, info_t *info)
{
  int last_was_pack = 0;
  int i;

  for (i = state->unpacked_length - 1; i >= 0; i -= info[i].length)
    {
      if (info[i].offset == COPY)
	{
	  copy_direct (state, info[i].length);
	  debug_print_info (state, "copy", info[i].length, COPY);
	  last_was_pack = 0;
	}
      else
	{
	  if (last_was_pack)
	    {
	      copy_direct (state, 0);
	      debug_print_info (state, "copy", 0, COPY);
	    }
	  pack_string (state, info[i].length, info[i].offset);
	  debug_print_info (state, "pack", info[i].length, info[i].offset);
	  last_was_pack = 1;
	}
    }
}

static void
analyze_this (state_t *state, info_t *info, int i)
{
  int length, offset;
  int best_length;
  int best_offset;
  int best_bits;
  int bits;
  int j;

  best_bits = 1000000000;
  for (j = 0; j <= 2; j++)
    {
      if (info[i - 1].offset == COPY)
	length = info[i - 1].length + j;
      else
	length = j;

      if (length < 1)
	continue;
      if (i - length < -1)
	break;

      if (info[i - length].offset == COPY)
	length += info[i - length].length;

      bits = info[i - length].bits + copy_bits (length);

      if (bits < best_bits)
	{
	  best_bits = bits;
	  best_length = length;
	  best_offset = offset;
	}
    }
  best_offset = COPY;

  if (i < state->unpacked_length - 1)
    {
      offset = -1;

      if (info[i - 1].offset == -1 &&
	  state->unpacked_stop[i] == state->unpacked_stop[i - 1] &&
	  state->unpacked_stop[i] == state->unpacked_stop[i + 1])
	{
	  length = info[i - 1].length + 1;
	}
      else
	{
	  for (length = 0;
	       state->unpacked_stop[i - length] ==
		 state->unpacked_stop[i + 1 - length];
	       length++)
	    {
	      if (i - length < 0)
		break;
	      if (length == 1033)
		break;
	    }
	}

      if (length >= 2)
	{
	  bits = info[i - length].bits + pack_bits (length, offset);
	  if (info[i - length].offset != COPY && i - length > -1)
	    bits += copy_bits (0);

	  if (bits < best_bits)
	    {
	      best_bits = bits;
	      best_length = length;
	      best_offset = offset;
	    }
	}
    }

  for (offset = 1; offset < 4383; offset++)
    {
      if (offset == -1 && i == state->unpacked_length - 1)
	continue;
      if (i + offset > state->unpacked_length)
	break;
      if (offset == 0)
	continue;

      for (length = 1;
	   state->unpacked_stop[i + offset + 1 - length] ==
	     state->unpacked_stop[i + 1 - length];
	   length++)
	{
	  if (offset == -1 && i - length < -1)
	    break;
	  if (length > offset && offset != -1)
	    break;
	  if (length == 1034)
	    break;
	  if (length < 2)
	    continue;
	  if (length == 2 && offset >= 574)
	    continue;
	  if (i + 1 - length < 0)
	    break;

	  bits = info[i - length].bits + pack_bits (length, offset);
	  if (info[i - length].offset != COPY && i - length > -1)
	    bits += copy_bits (0);

	  if (bits < best_bits)
	    {
	      best_bits = bits;
	      best_length = length;
	      best_offset = offset;
	    }
	}
    }

  info[i].length = best_length;
  info[i].offset = best_offset;
  info[i].bits = best_bits;
}

static void
analyze (state_t *state, info_t *info)
{
  int i;

  info[-1].length = 0;
  info[-1].offset = 0;
  info[-1].bits = 0;

  info[0].length = 1;
  info[0].offset = COPY;
  info[0].bits = copy_bits (1);

  for (i = 1; i < state->unpacked_length; i++)
    {
      analyze_this (state, info, i);
    }
}

static void
crunch (state_t *state, int level)
{
  info_t *info;

  info = malloc ((state->unpacked_length + 1) * sizeof (info_t));
  if (info == NULL)
    exit (1);

  analyze (state, info + 1);
  compress (state, info + 1);
  free (info);

#ifdef ICE_DEBUG
  fprintf (stderr,
	   "summary: %d bits encoded in %d bits, compression factor %.2f\n",
	   8 * state->unpacked_length,
	   state->bits_written - 1 + state->bits_copied,
	   (double)(8 * state->unpacked_length) /
	   (double)(state->bits_written + state->bits_copied));
#endif

  flush_bits (state);

  state->packed -= 4;
  putinfo (state->packed, state->unpacked_length);
  state->packed -= 4;
  putinfo (state->packed, state->packed_start - state->packed + 4);
  state->packed -= 4;
  putinfo (state->packed, ICE_MAGIC);
}

#endif /* NEW_ALGORITHM */

char *
ice_crunch (char *data, size_t length, int level)
{
  state_t state;
  size_t packed_buffer_length;
  size_t packed_length;
  char *packed, *packed_new;

  packed_buffer_length = 2 * length;
  if (packed_buffer_length < 100)
    packed_buffer_length = 100;

  packed = malloc (packed_buffer_length);
  if (packed == NULL)
    return NULL;

  init_state (&state, data, length, packed + packed_buffer_length);
  crunch (&state, level);

  packed_length = ice_crunched_length (state.packed);
  if (packed_length == 0)
    {
      free (packed);
      packed = NULL;
    }
  else
    {
      memmove (packed,
	       packed + packed_buffer_length - packed_length,
	       packed_length);
      packed_new = realloc (packed, packed_length);
      if (packed_new != NULL)
	packed = packed_new;
    }

  return packed;
}
