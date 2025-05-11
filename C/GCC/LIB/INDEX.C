
char * index(str, c)
char *str, c;
{
  for( ; *str ; str++)
  	{
	if(*str == c) return(str);
	}
  return((char * )0);
}
