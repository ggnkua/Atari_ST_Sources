
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "utils.h"

#ifdef TESTING
int 
main ()
{
  int i, j, t, k, K, T;
  float **data;
  char *cstring, *ustring;
  char **labels;
  int *table, tablesize;

#ifdef FROMSTDIN
  data = LoadFile ("-", &K, &T, FALSE, cstring, ustring,
		   &labels, &table, &tablesize);
  if (data == NULL)
    return 1;
  printf ("K=%d, T=%d\n", K, T);
  for (t = 0; t < T; t++)
    {
      for (k = 0; k < K; k++)
	printf (" %f ", data[t][k]);
      printf ("\n");
    }
  return 0;
#endif /* STDIN */

  /*--------------------------------------------------*/
  printf ("Input data file:\n");
  system ("cat demo.dat");
  printf ("\n");

  cstring = ustring = (char *) NULL;
  printf ("No picking of fields:\nExpect x y z\n");
  data = LoadFile ("demo.dat", &K, &T,
		   FALSE, cstring, ustring, &labels, &table, &tablesize);
  if (NULL == data)
    {
      printf ("LoadFile failed.\n");
      return 1;
    }

  for (k = 0; k < K; k++)
    printf (" %s ", labels[k]);
  printf ("\n");
  for (t = 0; t < T; t++)
    {
      for (k = 0; k < K; k++)
	printf (" %f ", data[t][k]);
      printf ("\n");
    }
  printf ("\nMapping table:\n");
  for (i = 0; i < tablesize; i++)
    printf ("Table[%d] = %d\n", i, table[i]);
  printf ("\n");


  /*--------------------------------------------------*/
  cstring = strdup ("x y z");
  ustring = strdup ("z x");
  printf ("With picking of fields:\nExpect z x\n");
  data = LoadFile ("demo.dat", &K, &T,
		   TRUE, cstring, ustring, &labels, &table, &tablesize);
  if (NULL == data)
    {
      printf ("LoadFile failed.\n");
      return 1;
    }
  for (k = 0; k < K; k++)
    printf (" %s ", labels[k]);
  printf ("\n");
  for (t = 0; t < T; t++)
    {
      for (k = 0; k < K; k++)
	printf (" %f ", data[t][k]);
      printf ("\n");
    }
  printf ("\nMapping table:\n");
  for (i = 0; i < tablesize; i++)
    printf ("Table[%d] = %d\n", i, table[i]);
  printf ("\n");

  return 0;
}

#endif /* TESTING */

/* Look for a given words in a table of words */
int 
findword (char *word, char **manywords, int maxwords)
{
  int i;

  for (i = 0; i < maxwords; i++)
    if (0 == strcmp (word, manywords[i]))
      return i;
  return -1;
}

#define MAXFIELDS 1024
/* When you change this, be sure to make implied changes in
	messages in err_mktable below. */

/* Error codes */
#define TOOMANYFIELDS_C -1	/* more than MAXFIELDS fields in cstring */
#define TOOMANYFIELDS_U -2	/* more than MAXFIELDS fields in ustring */
#define OUT_OF_MEMORY -3	/* ran out of RAM someplace. */
#define USING_BUTNOT_CONTAINS	-4	/* a variable in ustring but not in cstring */

int 
mktable (char *safe_cstring, char *safe_ustring, int *cNF,
	 int **table, int *tablesize, int *NumColumns,
	 char ***labels)
{
  char *cstring, *ustring;
  int uNF;
  static char *cwords[MAXFIELDS], *uwords[MAXFIELDS];
  int i, j;

  cstring = strdup (safe_cstring);
  ustring = strdup (safe_ustring);
  /* screw around with copies. */

  if (MAXFIELDS <= (*cNF = split (cstring, cwords, MAXFIELDS, "")))
    return TOOMANYFIELDS_C;

  if (MAXFIELDS <= (uNF = split (ustring, uwords, MAXFIELDS, "")))
    return TOOMANYFIELDS_U;

  *NumColumns = *tablesize = uNF;
  if (NULL == (*labels = (char **) malloc (uNF * sizeof (char *))))
      return OUT_OF_MEMORY;
  if (NULL == (*table = (int *) malloc (uNF * sizeof (int))))
      return OUT_OF_MEMORY;

  for (i = 0; i < uNF; i++)
    {				/* processing for uwords[i] */
      (*labels)[i] = strdup (uwords[i]);
      j = findword (uwords[i], cwords, *cNF);
      if (j == -1)
	return USING_BUTNOT_CONTAINS;
      (*table)[i] = j;
    }

  free (cstring);
  free (ustring);
  return 0;
}

/* Converting error codes of mktable into strings; after K&R, page 113 */
char *
err_mktable (int n)
{
  static char *messages[] =
  {
    /*0*/ "Error in call to err_mktable.",
    /*1*/ "'Contains' string contains too many variables; atmost 1024 allowed.",
    /*2*/ "'Using' string contains too many variables; atmost 1024 allowed.",
    /*3*/ "Out of Memory inside MkTable.",
    /*4*/ "There is a variable in 'Using' which is not in 'Contains'."
  };

  return (n < -4 || n > -1) ? messages[0] : messages[-n];
}


/* Function which takes
	string containing one line
	mapping table
and returns
	pointer to float * which contains required numbers.
*/

float *
mkrowptr (char *line, int expectNF, int *table, int tablesize)
{
  float *tmp;			/* this is the array which will be built up. */
  char *words[MAXFIELDS];
  int i, NF;

  if (expectNF != (NF = split (line, words, MAXFIELDS, "")))
    return NULL;

  tmp = (float *) malloc (tablesize * sizeof (float));
  for (i = 0; i < tablesize; i++)
    tmp[i] = (float) atof (words[table[i]]);	/* atof is slow! */

  return tmp;
}

#define INITIALSIZE 100
#define GROWTHFACTOR 1.5
/* the float** starts off as INITIALSIZE row pointers.
	Each time the data gets bigger than it's current size,
	the size is increased by a factor of GROWTHFACTOR. */

#define MAXCHARSINLINE 16384
/* Largest line we can read from input file. */

float **
LoadFile (char *dfname,
	  int *NumColumns, int *ObsNum,
	  int pickfields, char *cstring, char *ustring,
	  char ***labels, int **table, int *tablesize)
{
  int errorcode;
  float **data;
  int capacity, rows;
  char *linebuffer;		/* one line from data file starts off here.  */
  FILE *filehandle;
  char *words[MAXFIELDS];
  int i, NF, cNF;
  char *hiteof, *linecopy;
  float *p;
  if (0 == (strncmp (dfname, "-", 1)))
    filehandle = stdin;
  else
    {
      if (NULL == (filehandle = fopen (dfname, "r")))
	{
	  fprintf (stderr, "Failed to open file %s.\n", dfname);
	  return NULL;
	}
    }
  if (pickfields == TRUE)
    {

      errorcode = mktable (cstring, ustring, &cNF, table,
			   tablesize, NumColumns, labels);

      if (errorcode < 0)
	{
	  fprintf (stderr, "%s", err_mktable (errorcode));
	  return NULL;
	}
    }

  data = (float **) malloc (INITIALSIZE * sizeof (float *));
  capacity = INITIALSIZE;
  rows = 0;
  linebuffer = (char *) malloc (MAXCHARSINLINE * sizeof (char));

  if (NULL == fgets (linebuffer, MAXCHARSINLINE, filehandle))
    {
      fprintf (stderr, "Premature EOF on Input.\n");
      return NULL;
    }
  linebuffer[strlen (linebuffer) - 1] = 0;
  /* the last char of linebuffer given us by fgets is
		"\n".  The confuses Henry Spencer's split function
		who has been asked to use whitespace delimiters;
		split claims the "\n" is a field.  This hack
		eliminates that problem */

  if (pickfields == FALSE)
    {				/* learn layout from 1st row */
      linecopy = strdup (linebuffer);	/* protecting linebuffer */
      cNF = NF = split (linecopy, words, MAXFIELDS, "");
      if (NF <= 0)
	{
	  fprintf (stderr, "No data found on 1st line!\n");
	  return NULL;
	}
      *tablesize = *NumColumns = NF;
      *table = (int *) malloc (NF * sizeof (int));
      *labels = (char **) malloc (NF * sizeof (char *));

      for (i = 0; i < NF; i++)
	{
	  (*table)[i] = i;
	  (*labels)[i] = (char *) malloc (5 * sizeof (char));
	  sprintf ((*labels)[i], "$%d", (i + 1));
	}
      free (linecopy);
    }

  /* The main loop.  Notice lines are read at bottom. */
  do
    {
      if (NULL ==
	  (p = mkrowptr (linebuffer, cNF, *table, *tablesize)))
	{
	  fprintf (stderr, "On row %d, expect %d fields.\n", 1 + rows, cNF);
	  return NULL;
	}
      rows++;
      if (rows > capacity)
	{
	  capacity = (int) ((float) GROWTHFACTOR * capacity);
	  data = (float **) realloc (data, capacity * sizeof (float *));
	}
      data[rows - 1] = p;
      hiteof = fgets (linebuffer, MAXCHARSINLINE, filehandle);
      linebuffer[strlen (linebuffer) - 1] = 0;
      /* Same problem -- remove \n for splitting */
    }
  while (hiteof != NULL);	/* End of main loop. */

  *ObsNum = rows;
  data = (float **) realloc (data, rows * sizeof (float *));
  free (linebuffer);
  return data;
}
