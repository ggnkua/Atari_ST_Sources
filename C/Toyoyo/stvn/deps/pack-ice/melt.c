#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

#include "ice.h"

char *me;

static void
melt (char *ice_file)
{
  size_t crunched_length;
  char header[ICE_HEADER_SIZE];
  char *destination;
  char *source;
  char *file;
  FILE *f, *f2;
  int len;

  f = fopen (ice_file, "rb");
  if (f == NULL)
    {
      fprintf (stderr, "%s: error opening file %s: %s\n",
	       me, ice_file, strerror (errno));
      goto end;
    }

  if (fread (header, ICE_HEADER_SIZE, 1, f) != 1)
    {
      fprintf (stderr, "%s: %s: error reading header: %s\n",
	       me, ice_file, strerror (errno));
      goto close_file;
    }

  if (!is_ice_data (header))
    {
      fprintf (stderr, "%s: %s: not in ICE format\n", me, ice_file);
      goto close_file;
    }

  source = malloc (ice_crunched_length (header));
  if (source == NULL)
    {
      fprintf (stderr, "%s: %s: out of memory\n", me, ice_file);
      goto close_file;
    }

  rewind (f);
  if (fread (source, ice_crunched_length (header), 1, f) != 1)
    {
      fprintf (stderr, "%s: %s: read error: %s\n",
	       me, ice_file, strerror (errno));
      goto free_source;
    }

  destination = malloc (ice_decrunched_length (header));
  if (destination == NULL)
    {
      fprintf (stderr, "%s: %s: out of memory\n", me, ice_file);
      goto free_source;
    }

  crunched_length = ice_decrunch (source, destination);

  file = strdup (ice_file);
  if (file == NULL)
    {
      fprintf (stderr, "%s: %s: out of memory\n", me, ice_file);
      goto free_destination;
    }

  len = strlen (file);
  if (len > 4 && strcmp (file + len - 4, ".ice") == 0)
    file[len - 4] = 0;

  f2 = fopen (file, "wb");
  if (f2 == NULL)
    {
      fprintf (stderr, "%s: error opening file %s: %s\n",
	       me, file, strerror (errno));
      goto free_file;
    }

  fclose (f);
  f = f2;

  if (fwrite (destination, 1, crunched_length, f) != crunched_length)
    {
      fprintf (stderr, "%s: %s: write error: %s\n",
	       me, file, strerror (errno));
      goto free_file;
    }

  if (strcmp (ice_file, file) != 0 && remove (ice_file) == -1)
    {
      fprintf (stderr, "%s: error removing file %s: %s\n",
	       me, ice_file, strerror (errno));
      goto free_file;
    }

 free_file:
  free (file);
 free_destination:
  free (destination);
 free_source:
  free (source);
 close_file:
  fclose (f);
 end:
  return;
}

static void
usage (FILE *file, int status)
{
  fprintf (file, "Usage: %s file ...\n", me);
  exit (status);
}

int
main (int argc, char **argv)
{
  int i;

  me = argv[0];

  if (argc <= 1)
    usage (stderr, 1);

  for (i = 1; i < argc; i++)
    {
      melt (argv[i]);
    }

  return 0;
}
