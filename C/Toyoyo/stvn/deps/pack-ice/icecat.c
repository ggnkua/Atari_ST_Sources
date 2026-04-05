#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

#include "ice.h"

char *me;

static void
icecat (char *file)
{
  char header[ICE_HEADER_SIZE];
  char *destination;
  char *source;
  FILE *f;

  f = fopen (file, "rb");
  if (f == NULL)
    {
      fprintf (stderr, "%s: error opening file %s: %s\n",
	       me, file, strerror (errno));
      goto end;
    }

  if (fread (header, ICE_HEADER_SIZE, 1, f) != 1)
    {
      fprintf (stderr, "%s: %s: error reading header: %s\n",
	       me, file, strerror (errno));
      goto close_file;
    }

  if (!is_ice_data (header))
    {
      fprintf (stderr, "%s: %s: not in ICE format\n", me, file);
      goto close_file;
    }

  source = malloc (ice_crunched_length (header));
  if (source == NULL)
    {
      fprintf (stderr, "%s: %s: out of memory\n", me, file);
      goto close_file;
    }

  rewind (f);
  if (fread (source, ice_crunched_length (header), 1, f) != 1)
    {
      fprintf (stderr, "%s: %s: read error: %s\n",
	       me, file, strerror (errno));
      goto free_source;
    }

  destination = malloc (ice_decrunched_length (header));
  if (destination == NULL)
    {
      fprintf (stderr, "%s: %s: out of memory\n", me, file);
      goto free_source;
    }

  if (ice_decrunch (source, destination) == 0)
    {
      fprintf (stderr, "%s: %s: decrunch error\n", me, file);
      goto free_destination;
    }

  if (fwrite (destination, ice_decrunched_length (header), 1, stdout) != 1)
    {
      fprintf (stderr, "%s: %s: write error: %s\n",
	       me, file, strerror (errno));
      goto free_destination;
    }

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
      icecat (argv[i]);
    }

  return 0;
}
