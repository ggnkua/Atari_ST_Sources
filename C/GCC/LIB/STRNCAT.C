
char	* strncat(s1, s2, n)
char	*s1;
char	*s2;
int	n;
{
  char	* saves1 = s1;

  while (*s1++)
	;
  s1--;
  while ((--n >= 0) && (*s2))
	*s1++ = *s2++;
  *s1 = '\0';
  return(saves1);
}
