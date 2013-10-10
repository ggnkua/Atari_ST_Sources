#include "HighWire.h"

void
debug(char *output)
{
	vst_charmap(vdi_handle,1);
	vswr_mode(vdi_handle,1);
	v_ftext(vdi_handle,30,50,output);
	vswr_mode(vdi_handle,2);
	vst_charmap(vdi_handle,0);
}

void debug(short output)
{
	char outs[7];
	
	stci_d(out,output);
	debug(out);
}