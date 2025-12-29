/*
*** FFR by DG1BBQ@DB0CL.DEU.EU
***
*** util.c
***
 */

#include "ffr.h"
/*
*** find last dot in filename, if present;
*** not-UNIX:
***   limit filenames to 8 chars;
*** add dot (when dot == TRUE);
*** convert filename to lower case.
 */
void make_name (char *name, int dot)
{
    char *x;

    if ((x = strrchr (name, EXTCHAR)) != NULL)
      *x = EOS;

#if (__MSDOS__) || (__TOS__)
    name[8] = EOS;
#endif

    if (dot)
       strcat (name, EXTSEP);
    strlwr (name);
}

/*
*** write a line to file and count the chars written.
 */
void count_n_write (long *counter, char *string, FILE *file)
{
  if ((*counter += fprintf (file, "%s", string)) == EOF)
  {
    perror ("\007FFR: Write error.\n");
    exit (1);
  }
}

/*
*** test, if all searchstrings are present in header.
 */
int search_strings (int lines)
{
  int found = 0;
  int i     = 0;
  char *s;

  s = my_malloc (lines * MAXGET +1);

  /* concatenate strings to make search global */
  strcpy (s, win[0]);
  for (i=1; i<lines; i++)
    strcat (s, win[i]);
  strupr (s);

  i = 0;
  while (search[i])
  {
    if (strstr(s, search[i++]))
      found++;
  }
  free (s);
  return (found == i); /* When found == i, all strings are present */
}

/*
***
*** compare for qsort ()
***
 */
int comp_int (int *e1, int *e2)
{
  if (*e1 < *e2)
    return (-1);
  if (*e1 > *e2)
    return (1);
  return (0);
}

/*
***
*** init file read window
***
 */
void set_win (void)
{
  register i;

  for (i=0; i<WINSIZE; i++)
    if ((win[i] = my_malloc (MAXGET+1)) == NULL)
      exit (9);
}

/*
***
*** read line into file window, scroll window
***
 */
char *read_wline (FILE *file)
{
  register i;
  static flag = FALSE;
  static char *p;

  if (!file) /* clear window, if file == NULL. same as fflush() */
  {
    flag = FALSE;
    i = 0;
    return (NULL);
  }

  /* fill window on first call. read WINSIZE lines */
  if (!flag)
  {
    flag = TRUE;
    for (i=1; i<WINSIZE; i++)
      if ((p = fgets (win[i], MAXGET, file)) == NULL)
        *win[i] = EOS;
  }

  /* scroll file window up one line by scrolling pointers */
  p = win[0];
  for (i=1; i<WINSIZE; i++)
    win[i-1] = win[i];
  win[WINSIZE-1] = p;

  /* at end of file, continue reading, until window is fully scrolled
     through */
  if ((p = fgets(win[WINSIZE-1], MAXGET, file)) == NULL)
    *win[WINSIZE-1] = EOS;

  /* window is fully scrolled through, file ends. */
  if (!*win[0])
    return (NULL);

  return (win[0]);
}

/*
***
*** allocate mem. exit programm when not enough mem.
***
 */
void *my_malloc (size_t size)
{
  void *pointer = NULL;

  if ((pointer = malloc (size)) == NULL)
  {
    printf ("\n\007Insufficient memory!\n\n");
    exit (10);
  }
  return (pointer);
}

/*
***
*** output searchstrings
***
 */
void suchbegriffe (void)
{
  int i = 0;

  if (search[0]) /* are there any? */
  {              /* yes, output to screen */
    printf ("Searchstring%s: ", search[1]?"s":"");
    while (search[i])
      printf ("%s ", search[i++]);
    printf ("\n");
  }
}

/*
*** close file, but only if FILE-struct-pointer not NULL
***
***
 */
FILE *my_fclose (FILE *file)
{
  if (file)
  {
    if(fclose (file) == EOF)
    {
      printf ("\007Error while closing file.\n");
      exit (0);
    }
  }
  return (NULL);
}


#ifdef _FNSPLIT
/*
***       filenamesplit
***       (by DL1MEN, taken from SP-ST, modified for portability)
***
***       split filename up into drive, path, name and extension.
***
 */

void fnsplit(char *pth, char *dr, char *pa, char *fn, char *ft)
{
   char drv[MAXDRIVE], pat[MAXDIR], fna[MAXFILE], fty[MAXEXT], tmp[MAXPATH];
   char *p;

   strcpy(tmp,pth);
  
   if ((p = strchr(tmp,':')) != NULL)
   {
     *p++ = EOS;
     strcpy(drv,tmp);
   }
   else
   {
     p = tmp;
     drv[0] = EOS;
   }
   if ((pth = strrchr(p, PATHCHAR)) != NULL)
   {
     *pth++ = EOS;
     strcpy(pat,p);
   }
   else
   {
     pth = p;
     pat[0] = EOS;
   }
   if ((p = strchr(pth, EXTCHAR)) != NULL)
   {
     strcpy(fty,p);
     fty[MAXEXT-1] = EOS;
     *p = EOS;
   }
   else
     fty[0] = EOS;

   strcpy(fna,pth);
   fna[MAXFILE-1] = EOS;

   if (dr)
   {
     strcpy(dr,drv);
     if (drv[0])
       strcat(dr,":");
   }
   if (pa)
   {
     strcpy(pa,pat);
     if (pat[0])
       strcat(pa, PATHSEP);
   }
   if (fn)
     strcpy(fn,fna);
   if (ft)
     strcpy(ft,fty);
}
#endif /** _FNSPLIT **/

#ifdef _ICMP
/* The following functions are unfortunately not avialable on all compilers.
   You may have to include these functions.*/

/*
*** strupr - convert string to upper case.
***
***
 */
char *strupr (char *string)
{
  char *strcnvt (char *string, int flag);

  return (strcnvt (string, 1));
}

/*
*** strlwr - convert string to lower case.
***
***
 */
char *strlwr (char *string)
{
  char *strcnvt (char *string, int flag);

  return (strcnvt (string, 0));
}

/*
*** strcnvt - convert string to upper (flag == 1) or lower (flag == 0) case.
***
***
 */
char *strcnvt (char *string, int flag)
{
  register i = 0;

  while (string[i])
  {  
    string[i] = (flag)?toupper (string[i]):tolower (string[i]);
    i++;
  }

  return (string);
}

/*
*** stricmp - same as strcmp(), but ignores case.
*** s1 and s2 are not modified.
***
 */
int stricmp (char *s1, char *s2)
{
  return (strnicmp (s1, s2, (size_t) 80));
}

/*
*** strnicmp - same as strncmp(), but ignores case.
*** s1 and s2 are not modified.
***
 */
int strnicmp (char *s1, char *s2, int n)
{
  char _s1[MAXGET+1], _s2[MAXGET+1];

  strncpy (_s1, s1, 80);
  strncpy (_s2, s2, 80);
  strupr (_s1);
  strupr (_s2);

  return (strncmp (_s1, _s2, n));
}
#endif /** _ICMP **/
