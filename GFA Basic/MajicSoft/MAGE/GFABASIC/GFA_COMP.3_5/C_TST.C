/* Turbo-C Functions to be linked with GFA-BASIC	*/
/* testp fills 32000 bytes (screen) with counter	*/
/* testf is just a dummy function 					*/

void cdecl testp(x)
char *x;
{
	int i;
	for (i=0;i<32000;i++)
		*(char *)(x+i) = (char) i;
}

long cdecl testf(x)
long x;
{
	return(x+123);
}
