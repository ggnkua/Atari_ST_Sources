#include <tos.h>
#include <aes.h>
#include <linea.h>

long
mson(void)
{
	while (mousehidden)
		graf_mouse(M_ON, NULL);
	return 0;
}


int
main(void)
{
	linea0();

	Supexec(mson);
	return 0;
}
