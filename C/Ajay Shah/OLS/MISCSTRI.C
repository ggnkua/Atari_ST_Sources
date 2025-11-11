/* Miscellanous string routines */

char *
strdup (char *s)
{
  char *tmp;

  tmp = (char *) malloc ((1 + strlen (s)) * sizeof (char));
  strcpy (tmp, s);
  return tmp;
}
