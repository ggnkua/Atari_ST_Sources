#include 	<tos.h>

main()
{
	char load[4] = {0x20,0x01,0x20,8};
	char message[8] = " FALCON ";
	char spaces[8]  = "        ";

	Ikbdws(3,load);
	Ikbdws(7,message);
	Cconin();
	Ikbdws(3,load);
	Ikbdws(7,spaces);
	return(0);
}