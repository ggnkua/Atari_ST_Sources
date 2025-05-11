
#ifdef DEBUG
extern int stderr;	/* debug */
#endif

bcopy(from, to, nbytes)
register char * from, * to;
register int nbytes;
{
#ifdef DEBUG
  fprintf(stderr, "bcopy(%lx, %lx, %d)\n", from, to, nbytes);
#endif
  for( ; nbytes > 0 ; nbytes--)
	*to++ = *from++;
}

bcmp(b1, b2, nbytes)
register char * b1, * b2;
register int nbytes;
{
  register int i;
#ifdef DEBUG
  fprintf(stderr, "bcmp(%lx, %lx, %d)\n", b1, b2, nbytes);
#endif
  for(i = 1 ; nbytes > 0 ; nbytes--, i++)
	if (*b1++ != *b2++)
		return(i);
  return(0);		
}

bzero(bytes, nbytes)
register char *bytes;
register int nbytes;
{
#ifdef DEBUG
  fprintf(stderr, "bzero(%lx, %d)\n", bytes, nbytes);
#endif
  for( ; nbytes > 0 ; nbytes--)
	*bytes++ = 0;
}
