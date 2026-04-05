#include "ice_private.h"

static size_t
getinfo (char *data)
{
  size_t info = 0;
  int i;

  for (i = 0; i < 4; i++)
    info = (info << 8) | (unsigned char)*data++;

  return info;
}

int
is_ice_data (char *data)
{
  return getinfo (data) == ICE_MAGIC;
}

size_t
ice_crunched_length (char *data)
{
  if (!is_ice_data (data))
    return 0;

  return getinfo (data + 4);
}

size_t
ice_decrunched_length (char *data)
{
  if (!is_ice_data (data))
    return 0;

  return getinfo (data + 8);
}
