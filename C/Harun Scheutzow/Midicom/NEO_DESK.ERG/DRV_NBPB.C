#include <stddef.h>
#include <tos.h>
#include <string.h>

#define BP _BasPag

long premiere(void)
{
	install();
	return(0);
}

void main(void)
{
	Cconws("NEODESK-Anpassung\r\n");
	(void)Supexec(premiere);
	Ptermres(256L + BP->p_tlen + BP->p_dlen + BP->p_blen, 0);
}