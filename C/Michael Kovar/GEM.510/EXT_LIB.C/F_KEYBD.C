
extern int	int_in[], int_out[];
extern long	addr_in[];


int form_keybd(a, b, c, d, e, f)
long	a; /* Baumadresse */
int	b; /* Objekt-Index */
int	c; /* ASCII-Zeichen */
int	d; 
int	*e;
int	*f;
{
	addr_in[0]=a; /* Baum-Adresse */
	int_in[0]=b; /* Objekt-Index des Textfeldes */
	int_in[1]=d; /* Tastaturcode */
	int_in[2]=c; /* reserviert */

	crys_if(55); /* AES-Aufruf fr form_keybd */

	*e = int_out[1]; /* n„chstes Objekt */
	*f = int_out[2]; /* Flag */
	return(int_out[0]); /* EXIT-Status */
}
