extern	int	int_in[], int_out[];
extern	long	addr_in[];


int form_button(a, b, c, d)
long	a; /* Baumadresse */
int	b; /* Objektindex */
int	c; /* Anzahl Mausclicks */
int	*d; /* n„chstes Objekt */ 
{
	addr_in[0]=a; /* Baumadresse */
	int_in[0]=b; /* Objekt */
	int_in[1]=c; /* Anzahl Mausclicks */

	crys_if(56); /* AES-Aufruf fr form_button */

	*d=int_out[1]; /* n„chste vom Anwender ausgew„hlte Objekt */
	return(int_out[0]); /* EXIT-Status */
}
