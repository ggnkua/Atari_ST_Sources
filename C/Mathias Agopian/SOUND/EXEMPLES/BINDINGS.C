#include <vdi.h>

void SetVDIPB(VDIPB *vdipb);


void SetVDIPB(VDIPB *vdipb)
{
	vdipb->contrl	=_VDIParBlk.contrl;
	vdipb->intin	=_VDIParBlk.intin;
	vdipb->intout	=_VDIParBlk.intout;
	vdipb->ptsin	=_VDIParBlk.ptsin;
	vdipb->ptsout	=_VDIParBlk.ptsout;
}


void vsspl_monitor_on(int handle)
{
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=0;	
	(vdipb.contrl)[5]=3030;
	(vdipb.contrl)[6]=handle;
	vdi(&vdipb);
}

void vsspl_monitor_off(int handle)
{
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=0;	
	(vdipb.contrl)[5]=3031;
	(vdipb.contrl)[6]=handle;
	vdi(&vdipb);
}

void vspl_play(int handle,char *fname,unsigned long position)
{
	int i;
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[5]=3000;
	(vdipb.contrl)[6]=handle;
	((unsigned long *)(vdipb.intin))[0]=position;
	i=0;
	while(fname[i])
	{
		(vdipb.intin)[i+2]=(int)fname[i];
		i++;
	}	
	(vdipb.contrl)[3]=i+2;
	vdi(&vdipb);
}

int vspl_load_sample(int handle,char *fname,unsigned long position)
{
	int i;
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[5]=3001;
	(vdipb.contrl)[6]=handle;
	((unsigned long *)(vdipb.intin))[0]=position;
	i=0;
	while(fname[i])
	{
		(vdipb.intin)[i+2]=(int)fname[i];
		i++;
	}	
	(vdipb.contrl)[3]=i+2;
	vdi(&vdipb);
	return (vdipb.intout)[0];
}

void vspl_unload_sample(int handle,int id)
{
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[5]=3002;
	(vdipb.contrl)[6]=handle;
	(vdipb.intin)[0]=id;
	(vdipb.contrl)[3]=1;	
	vdi(&vdipb);
}

void vspl_play_dma(int handle,int id)
{
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[5]=3003;
	(vdipb.contrl)[6]=handle;
	(vdipb.intin)[0]=id;
	(vdipb.contrl)[3]=1;	
	vdi(&vdipb);
}

void vspl_pause_dma(int handle,int id)
{
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[5]=3007;
	(vdipb.contrl)[6]=handle;
	(vdipb.intin)[0]=id;
	(vdipb.contrl)[3]=1;	
	vdi(&vdipb);
}

void vspl_stop_dma(int handle,int id)
{
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[5]=3004;
	(vdipb.contrl)[6]=handle;
	(vdipb.intin)[0]=id;
	(vdipb.contrl)[3]=1;	
	vdi(&vdipb);
}

int vqspl_status_dma(int handle,int id)
{
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[5]=3005;
	(vdipb.contrl)[6]=handle;
	(vdipb.intin)[0]=id;
	(vdipb.contrl)[3]=1;	
	vdi(&vdipb);
	return (vdipb.intout)[0];
}

unsigned long vqspl_position_dma(int handle,int id)
{
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[5]=3006;
	(vdipb.contrl)[6]=handle;
	(vdipb.intin)[0]=id;
	(vdipb.contrl)[3]=1;	
	vdi(&vdipb);
	return ((long *)(vdipb.intout))[0];
}




int vspl_load_d2d(int handle,char *fname,unsigned long position)
{
	int i;
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[5]=3011;
	(vdipb.contrl)[6]=handle;
	((unsigned long *)(vdipb.intin))[0]=position;
	i=0;
	while(fname[i])
	{
		(vdipb.intin)[i+2]=(int)fname[i];
		i++;
	}	
	(vdipb.contrl)[3]=i+2;	
	vdi(&vdipb);
	return (vdipb.intout)[0];
}

void vspl_unload_d2d(int handle)
{
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=0;	
	(vdipb.contrl)[5]=3012;
	(vdipb.contrl)[6]=handle;
	vdi(&vdipb);
}

void vspl_play_d2d(int handle)
{
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=0;
	(vdipb.contrl)[5]=3013;
	(vdipb.contrl)[6]=handle;
	vdi(&vdipb);
}

void vspl_pause_d2d(int handle)
{
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=0;
	(vdipb.contrl)[5]=3014;
	(vdipb.contrl)[6]=handle;
	vdi(&vdipb);
}

void vspl_stop_d2d(int handle)
{
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=0;	
	(vdipb.contrl)[5]=3015;
	(vdipb.contrl)[6]=handle;
	vdi(&vdipb);
}

int vqspl_status_d2d(int handle)
{
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=0;
	(vdipb.contrl)[5]=3016;
	(vdipb.contrl)[6]=handle;
	vdi(&vdipb);
	return (vdipb.intout)[0];
}

unsigned long vqspl_position_d2d(int handle)
{
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=0;
	(vdipb.contrl)[5]=3017;
	(vdipb.contrl)[6]=handle;
	vdi(&vdipb);
	return ((long *)(vdipb.intout))[0];
}

int vqspl_time_left_d2d(int handle)
{
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=0;
	(vdipb.contrl)[5]=3018;
	(vdipb.contrl)[6]=handle;
	vdi(&vdipb);
	return (vdipb.intout)[0];
}

void vspl_make_d2d(int handle)
{
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=0;
	(vdipb.contrl)[5]=3020;
	(vdipb.contrl)[6]=handle;
	vdi(&vdipb);
}

/********************************************************************************/
/*	binding PURE C																*/
/*																				*/
/*	int vq_driver_info(int handle,int *res0, int *drv, int *res1, *int res2, char name[27]) */
/*																				*/
/*	Retour: 0 si l'appel est inhexistant										*/
/*		drv contient le no du driver						 					*/
/*		res0,res1,res2: reserv‚s												*/
/*																				*/
/********************************************************************************/

int vq_driver_info(int handle,int *res0,int *drv,int *res1,int *res2, char name[27])
{
	int i;
	VDIPB vdipb;
	SetVDIPB(&vdipb);
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;    
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=0;
	(vdipb.contrl)[5]=2101;
	(vdipb.contrl)[6]=handle;	
	vdi(&vdipb);
	*res0=(vdipb.intout)[1];
	*drv=(vdipb.intout)[2];
	*res1=(vdipb.intout)[3];
	*res2=(vdipb.intout)[4];	
	for(i=0;i<26;i++)
		*name++=(vdipb.intout)[i+5];
	*name=0;
	return ((vdipb.intout)[0]);
}
