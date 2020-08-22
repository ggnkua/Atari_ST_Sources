/*
	STGA_DEM.C    							(c) 1992 by Till Harbaum
*/

#define  FALSE  0
#define  TRUE	!FALSE

#include <vdi.h>
#include <aes.h>
#include <ext.h>
#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int 	work_in[12],work_out[57];
int 	handle,phys_handle;
int 	gl_hchar,gl_wchar,gl_hbox,gl_wbox;
int 	gl_apid;

int main( void )
{
	register int 	i,j;
	int		x,y,col,pxy[10],dummy;

	if (( gl_apid = appl_init() ) != -1 )
	{
		for ( i = 1; i < 10; work_in[i++] = 1 );
		work_in[10] = 2;
		phys_handle = graf_handle( &gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox );
		work_in[0]  = handle = phys_handle;

		v_opnvwk( work_in, &handle, work_out );

		graf_mouse(M_OFF,NULL);

		v_clrwk(handle);

		x=work_out[0];
		y=work_out[1];
		col=work_out[13];

		vswr_mode(handle,MD_REPLACE);
		vsl_color(handle,1);
		vsf_perimeter(handle,0);
		vsf_interior(handle,FIS_SOLID);

		pxy[1]=0; pxy[3]=y;
		for(i=(x%17)/2;i<x;i+=(x/17))
		{
			pxy[0]=pxy[2]=i;
			v_pline(handle,2,pxy);
		}

		pxy[0]=0; pxy[2]=x;
		for(i=(y%(x/17))/2;i<y;i+=(x/17))
		{
			pxy[1]=pxy[3]=i;
			v_pline(handle,2,pxy);
		}

		for(i=-8;i<=7;i++)
		{
			for(j=-8;j<=7;j++)
			{
				pxy[0]=(x/2)+(i*x/32);
				pxy[1]=(y/2)+(j*x/32);
				pxy[2]=(x/2)+((i+1)*x/32);
				pxy[3]=(y/2)+((j+1)*x/32);
				
				vsf_color(handle,(8+i+16*(j+8))%col);
				v_bar(handle,pxy);
				
				pxy[0]=pxy[6]=pxy[8]=(x/2)+(i*x/32);
				pxy[1]=pxy[3]=pxy[9]=(y/2)+(j*x/32);
				pxy[2]=pxy[4]=(x/2)+((i+1)*x/32);
				pxy[5]=pxy[7]=(y/2)+((j+1)*x/32);
				v_pline(handle,5,pxy);
			}
		}

		v_arc(handle,x/2+1,y/2+1,(y/2)-16,0,3600);

		vst_color(handle,1);
		vst_point(handle,8,&dummy,&dummy,&dummy,&dummy);
		v_gtext(handle,5,y-5,"STGA-Testbild (c)1992 Till Harbaum");

		vst_height(handle,13,&dummy,&dummy,&dummy,&dummy);
		v_justified(handle,10,20,"Hallo Welt",100,1,0);

		getch();
		graf_mouse(M_ON,NULL);

		v_clsvwk( handle );
		appl_exit( );
   	}
	return(0);
}
