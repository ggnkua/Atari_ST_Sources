/**
 * Virtual bindings for v_Opnvwk() and v_Opnwk()
**/
#include <vdi.h>
#include <osbind.h>

#include "HighWire.h"

short
V_Opnvwk(VDI_Workstation *dev)
{	
	short i, in[11];
	
	in[0] = Getrez() + 2;
	dev->dev_id = in[0];
	for(i=1;i<10;in[i++]=1);
	in[10]=2;
	i=graf_handle(&dev->wchar,&dev->hchar,&dev->wbox,&dev->hbox);
	v_opnvwk(in,&i,&dev->xres);
	dev->handle=i;
	
	if(i)
		vq_extnd(i,1,&dev->screentype);
	
	return(i);
}

short
V_Opnwk(short devno, VDI_Workstation *dev)
{
	short i, in[11];
	
	in[0] = dev->dev_id = devno;
	for(i=1;i<10;in[i++]=1);
	in[10]=2;
	i=devno;
	
	v_opnwk(in,&i,&dev->xres);
	dev->handle = i;
	
	if(i)
		vq_extnd(i,1,&dev->screentype);
	
	return(i);
}