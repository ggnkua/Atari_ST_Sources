#include <stdio.h>
#include <ext.h>
#include <process.h>

void main(void)
{
	char linker[] = "plink.ttp";
	char cmd_ed[] = {
						"-o=ifs_col.prg "
						"pcstart ifs_col intro1 "
						"pcstdlib.lib "
						"pcfltlib.lib "
					};
	int ret_code;
	int err;
	
	err = exec( linker, cmd_ed, "\0", &ret_code );
}