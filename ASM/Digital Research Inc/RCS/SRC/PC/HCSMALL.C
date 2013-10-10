/*
** hcsmall.c
**	- Fool Metaware's High C need for library
**	- High C outputs an external reference to the symbol 'SMALL?'
**	  in order to guarantee that the user is linking with the correct model
**	  of the run time library
**	- Compile and link this module in for stand alone applications
*/

void small()
{
}
pragma alias(small,"SMALL?");
