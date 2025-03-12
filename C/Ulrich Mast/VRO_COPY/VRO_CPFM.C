/********************************************/
/*											*/
/*	vro_cpfm.c								*/
/*	vro_cpyfm()	Speed Demo					*/
/*											*/
/*	Programmiert mit LASER C V2.1 von		*/
/*											*/
/*	Ulrich Mast								*/
/*	Wilhelm-Maybach-Str. 9					*/
/*	7303 Neuhausen							*/
/*											*/
/********************************************/
#include	<osbind.h>
#include	<gemdefs.h>

#define		HZ_200		0x4BA

int		contrl[12],
		intin[128],intout[128],
		ptsin[128],ptsout[128];

int		vdi_handle,
		vdi_planes,
		vdi_w,
		vdi_h;
int		work_out[57],
		work_in[]={1,1,1,1,1,1,1,1,1,1,2};
MFDB	screen,mem;


long
get_timer()
{
	long	stack;
	long	timer;
	
	stack=Super(0L);
	timer=*(long*)HZ_200;
	Super(stack);
	return(timer);
}

copy(x,y,w,h,diff)
int		x,y,w,h,diff;
{
	int		xy[8];

	xy[0]=x;			/* Quelle	*/
	xy[1]=y;
	xy[2]=x+w-1;
	xy[3]=y+h-1;
	xy[4]=diff;			/* Ziel		*/
	xy[5]=0;
	xy[6]=w-1+diff;
	xy[7]=h-1;
	
	vro_cpyfm(vdi_handle,3,xy,&screen,&mem);
}

do_test(x,y,w,h,diff)
int	x,y,w,h,diff;
{
	long	timer;
	int		i;
	
	timer=get_timer();
	for(i=0;i<10;i++)
		copy(x,y,w,h,diff);
	printf("%3d %4d   %ld\n",
			x,diff,(get_timer()-timer)*5L);
}

test()
{
	int		x,y,w,h;
	long	len;
	int		i;
	
	wind_get(0,WF_WORKXYWH,&x,&y,&w,&h);
	w-=16;
	
	screen.fd_addr=0L;
	
	mem.fd_nplanes=vdi_planes;
	mem.fd_wdwidth=(w+31)/16;
	mem.fd_w=mem.fd_wdwidth*16;
	mem.fd_h=h;
	mem.fd_stand=0;

	len=2L;
	len*=(long)mem.fd_wdwidth;
	len*=(long)mem.fd_h;
	len*=(long)mem.fd_nplanes;
	
	mem.fd_addr=Malloc(len);
	if(!mem.fd_addr)
	{
		form_alert(1,
		"[3][ Nicht genug Speicher ! ][Oha]");
		return;
	}

	graf_mouse(M_OFF,0L);
	
	printf("\nvro_cpyfm() Speed Demo\n\n");
	printf("Aufl”sung:  %d x %d\n",vdi_w,vdi_h);
	printf("Farbebenen: %d\n",vdi_planes);
	printf("Rechteck:   [%d,%d] [%d,%d]\n",
						x,y,x+w-1,y+h-1);
	printf("Speicher:   %ld\n\n",len);
	
	printf("Test 1:\n\n");
	printf("von nach   Zeit (ms)\n");
	for(i=0;i<16;i++)
		do_test(x+i,y,w,h,0);
	printf("Taste...\n\n");
	Cconin();

	printf("Test 2:\n\n");
	printf("von nach   Zeit (ms)\n");
	for(i=0;i<16;i++)
		do_test(x+i,y,w,h,(x+i)%16);
	
	printf("Taste...\n\n");
	Cconin();

	graf_mouse(M_ON,0L);
	
	Mfree(mem.fd_addr);
}

main(argc,argv)
int		argc;
char	*argv[];
{
	int		d;
	
	appl_init();
	graf_mouse(ARROW,0L);

	vdi_handle=graf_handle(&d,&d,&d,&d);
	v_opnvwk(work_in,&vdi_handle,work_out);
	if(vdi_handle)
	{
		vdi_w=work_out[0];
		vdi_h=work_out[1];
		
		vq_extnd(vdi_handle,1,work_out);
		vdi_planes=work_out[4];
		
		test();
		
		v_clsvwk(vdi_handle);
	}
	else
		form_alert(3,
		"[1][ Kann vWK nich ”ffnen ! ][Hmnm]");
	
	appl_exit();
}

