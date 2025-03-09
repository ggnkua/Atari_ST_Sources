/* strcat wie es normal gebraucht wird. */

char	*strcat(char *dest, const char *src);

char
*strcat(char *dest, const char *src)
{
	char	*tmp;

	tmp = dest;
	while(*tmp != '\0')
		++tmp;

	while(*tmp++ = *src++)
		;

	return(dest);
}

+++++++++++++++++++++++++++++++++++++++++++++++

/* strcat mit Doppelpointern. */

char	**strcat(char **dest, const char **src);

char
**strcat(char **dest, const char **src)
{
	char	**tmp;
	int	pos1 = 0;
	int	pos2 = 0;

	tmp = dest;
	while(tmp[0][pos1] != '\0')
		pos1++;

	while(tmp[0][pos1] = src[0][pos2])
	{
		pos1++;
		pos2++;
	}
	return(dest);
}
