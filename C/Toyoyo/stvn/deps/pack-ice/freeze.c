#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

#include "ice.h"

char *me;

static void
freeze (char *file)
{
  long length;
  char *destination;
  char *ice_file;
  char *source;
  FILE *f, *f2;

  f = fopen (file, "rb");
  if (f == NULL)
    {
      fprintf (stderr, "%s: error opening file %s: %s\n",
	       me, file, strerror (errno));
      goto end;
    }

  fseek (f, 0L, SEEK_END);
  length = ftell (f);
  rewind (f);

  source = malloc (length);
  if (source == NULL)
    {
      fprintf (stderr, "%s: %s: out of memory\n", me, file);
      goto close_file;
    }

  if (fread (source, 1, length, f) != length)
    {
      fprintf (stderr, "%s: %s: read error: %s\n",
	       me, file, strerror (errno));
      goto free_source;
    }

  destination = ice_crunch (source, length, 1);
  if (destination == NULL)
    {
      fprintf (stderr, "%s: %s: crunch error\n", me, file);
      goto free_source;
    }

  ice_file = malloc (strlen (file) + 5);
  if (ice_file == NULL)
    {
      fprintf (stderr, "%s: %s: out of memory\n", me, file);
      goto free_destination;
    }

  strcpy (ice_file, file);
  strcat (ice_file, ".ice");

  f2 = fopen (ice_file, "wb");
  if (f2 == NULL)
    {
      fprintf (stderr, "%s: error opening file %s: %s\n",
	       me, ice_file, strerror (errno));
      goto free_file;
    }

  fclose (f);
  f = f2;
  
  {
    size_t n, N;
    N = ice_crunched_length (destination);
    n = fwrite (destination, 1, N, f);
    if (n != N)
    //if (fwrite (destination, ice_crunched_length (destination), 1, f) != 1)
      {
	fprintf (stderr, "%s: %s: write error: %s\n",
		 me, ice_file, strerror (errno));
	goto free_file;
      }
  }

  if (remove (file) == -1)
    {
      fprintf (stderr, "%s: error removing file %s: %s\n",
	       me, file, strerror (errno));
      goto free_file;
    }

 free_file:
  free (ice_file);
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
      freeze (argv[i]);
    }

  return 0;
}
