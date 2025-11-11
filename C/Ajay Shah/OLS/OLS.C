/* This file contains the main program, and the code which parses
 * the commandline.
 */

#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "utils.h"
#include "patchlevel.h"

/* Local prototypes. */
int ols (char **labels, float **data, int K, int ObsNum,
	 int purebeta, int pscript, int epp,
	 int *maptable, int labelcount);
int CommandLine (int argc, char **argv,
		 int *found_labels, char **labelstring,
		 int *found_model, char **modelstring,
		 char **dfname,
		 int *purebeta, int *pscript, int *epp);
void GiveUsage (char *execname);
char *cleanup_mstring (char *s);
/* End of local prototypes. */

#define MAXLABELS 1024

int 
main (int argc, char **argv)
{
  char *dfname;			/* name of input data file */
  int cols;			/* Number of columns found in file */
  float **data;			/* main data matrix */
  int ObsNum;			/* How many observations? */
  char **labels;		/* labels for variables. */
  char *labelstring;		/* comes out of commandline parsing. */
  int found_labels;
  int purebeta, pscript, epp;
  int found_model;		/* is he specifying a model? */
  char *modelstring;
  int *maptable, labelcount;

  if (1 == CommandLine (argc, argv,
			&found_labels, &labelstring,
			&found_model, &modelstring,
			&dfname, &purebeta, &pscript, &epp))
    return 1;

  if (found_model && (!found_labels))
    {
      fprintf (stderr, "If you specify a model on the commandline,\n");
      fprintf (stderr, "you should also specify data labels.\n");
      return 1;
    }

  if (found_labels && (!found_model))
    {
      modelstring = strdup (labelstring);
      found_model = TRUE;
    }				/* not writing a modelstring is just saying "use
		everything in the labels */

  if (NULL ==
      (data = LoadFile (dfname, &cols, &ObsNum,
			found_model, labelstring, modelstring,
			&labels, &maptable, &labelcount)))
    {
      fprintf (stderr, "Errors in reading data.\n");
      fprintf (stderr, "Say 'ols -h' for help.\n");
      return 1;
    }
  /* at return,
		cols is #columns in what is used.
		ObsNum is #rows loaded from disk.
		cols may have nothing to do with NF of labelstring.
		Labels come back whether or not found_model.
		maptable always comes back. */

  free (labelstring);
  free (modelstring);

  /* Worry about weirdo datasets.*/
  if ((ObsNum == 0) || (cols <= 1))
    {
      fprintf (stderr, "Nonsense dataset.\n");
      return 1;
    }
  if (ObsNum <= (cols - 1))
    {
      fprintf (stderr, "Too few observations for fitting a line.\n");
      return 1;
    }
  /* End of checks for weirdo datasets. */

  if (1 == ols (labels, data, cols - 1, ObsNum,
		purebeta, pscript, epp, maptable, labelcount))
    {
      fprintf (stderr, "Fatal errors, aborting.\n");
      return 1;
    }

  return 0;
}

void 
GiveUsage (char *execname)
{
  fprintf (stderr, "\nThis is a tool to estimate linear regressions (OLS).\nUsage:\n");
  fprintf (stderr, "\n\t%s [datafile] [-l labels_string] [-m model_spec] [-p] [-raw]\n", execname);
  fprintf (stderr, "\nFinished example of usage:\n\n");
  fprintf (stderr, "\t%s abc.dat -l 'x y z' -m 'z = x'", execname);
  fprintf (stderr, "\n\nThis is just a quick summary; lookup man pages for more.\n");
  fprintf (stderr, "\nThis is version %s.\n", PATCHLEVEL);
}

int 
CommandLine (int argc, char **argv,
	     int *found_labels, char **labelstring,
	     int *found_model, char **modelstring,
	     char **dfname,
	     int *purebeta, int *pscript, int *epp)
{
  int i, found_df, parsed;

  found_df = *found_labels = *found_model =
    *purebeta = *pscript = *epp = FALSE;
  *modelstring = *labelstring = NULL;
  for (i = 1; i < argc; i++)
    {
      if (0 == strncmp (argv[i], "-", 1))
	{
	  parsed = FALSE;

	  /* -h or -H */
	  if (
	       (0 == strncmp (argv[i], "-h", 2))
	       ||
	       (0 == strncmp (argv[i], "-H", 2))
	    )
	    {
	      GiveUsage (argv[0]);
	      return 1;
	    }

	  /* -l */
	  if (0 == strncmp (argv[i], "-l", 2))
	    {
	      *labelstring = strdup (argv[++i]);
	      parsed = TRUE;
	      *found_labels = TRUE;
	    }

	  /* -m */
	  if (0 == strncmp (argv[i], "-m", 2))
	    {
	      if (NULL ==
		  (*modelstring = cleanup_mstring (strdup (argv[++i]))))
		{
		  fprintf (stderr, "Error in model description.\n");
		  return 1;
		};
	      parsed = TRUE;
	      *found_model = TRUE;
	    }

	  /* -raw */
	  if (0 == strncmp (argv[i], "-raw", 4))
	    {
	      parsed = TRUE;
	      *purebeta = TRUE;
	    }

	  /* -p */
	  if (0 == strncmp (argv[i], "-p", 2))
	    {
	      parsed = TRUE;
	      *pscript = TRUE;
	    }

	  /* -epp */
	  if (0 == strncmp (argv[i], "-epp", 4))
	    {
	      parsed = TRUE;
	      *epp = TRUE;
	    }

	  if (!parsed)
	    {
	      fprintf (stderr,
		       "Unrecognised switch: %s\n", argv[i]);
	      return 1;
	    }
	}
      else
	/* if it's not "-" something then it's the dfname. */
	{
	  if (found_df)
	    {
	      fprintf (stderr,
		       "You can't have two filenames on the commandline.\n");
	      fprintf (stderr,
		       "%s was supposed to be the datafile but you claim %s is a datafile too.\n", *dfname, argv[i]);
	      fprintf (stderr, "Say 'ols -h' for help.\n");
	      return 1;
	    }
	  *dfname = (char *) strdup (argv[i]);
	  found_df = TRUE;
	}
    }

  /* Now we need to make sure the various flags are not incompatible.
	The full list of flags is h l m beta p epp
	Incompatibilities:
		Errors of mixing h with others are ignored.
		Only one of beta, p and epp are ok.
	We'll do a cheap implementation:
	*/
  if (((*epp) + (*pscript) + (*purebeta)) > 1)
    {
      fprintf (stderr,
	       "Atmost one of these three flags '-p', '-beta' and '-epp'\n");
      fprintf (stderr, "can be present at a time.\n");
      return 1;
    }

  /* if you still don't have a dfname, it's coming from StdIn. */
  if (!found_df)
    *dfname = (char *) strdup ("-");
  return 0;
}

char *
cleanup_mstring (char *s)
     /* given a string "y = x z" produce "x z y".
Modifies the data which the pointer s points to.*/
{
  char *words[2];

  if (2 != split (s, words, 2, "="))
    {
      fprintf (stderr, "Model definition must look like 'y = x z'.\n");
      return NULL;
    }
  words[0] = strdup (words[0]);
  words[1] = strdup (words[1]);
  /* So words are no longer pointers into contents of s */

  /* Now we go around setting up s correctly. */
  s = strcpy (s, words[1]);
  s = strcat (s, " ");
  s = strcat (s, words[0]);
  free (words[0]);
  free (words[1]);

  return s;
}
