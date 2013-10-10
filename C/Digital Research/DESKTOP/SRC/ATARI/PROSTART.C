/*	PROSTART.C	05/03/84 -  01/05/85	Michael Bernstein	*/
/*	start GEMMAIN for Atari ST	*/

#include <portab.h>
#include <machine.h>
#include "deskapp.h"
#include "deskfpd.h"
#include "deskmain.h"

WORD	DOS_AX;
WORD	DOS_ERR;

int main(int argc, char *argv[])
{
	gemain();
	return(0);
}
