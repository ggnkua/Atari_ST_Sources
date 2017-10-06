#include "vdidef.h"
#include "vdi++.h"

class VDI& DefaultVDI()
{
	static VDI* vdi=0;
	if (!vdi) vdi=new VDI;
	return *vdi;
}
