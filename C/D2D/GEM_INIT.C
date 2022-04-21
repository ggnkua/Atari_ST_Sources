#include <aes.h>
#include <vdi.h>

int contrl[12],intin[132],ptsin[140],intout[145],ptsout[145];
		/* tableaux utilis‚s par les fonctions VDI */

int ap_id,handle,resol_x,resol_y;
		/* 	ap_id			= id du prg 
			handle			= id graphique de la VDI
			resol_x,resol_y	= abscisse & ordonn‚e maxi */

void gem_init(void)
{
 int work_in[11],work_out[57],i;	/* tableaux pour v_opnvwk */
 
 ap_id=appl_init();					/* initialise l'AES */
 
 for(i=0;i<10;work_in[i++]=1);		/* tous … 1 sauf le drapeau */
 work_in[10]=2;						/* des coordonn‚es			*/

 v_opnvwk(work_in,&handle,work_out);	/* initialise la VDI */ 
 
 resol_x=work_out[0];					/* stocke la r‚solution */
 resol_y=work_out[1];
}
 
void gem_exit(void)
{
 v_clsvwk(handle);
 appl_exit();
}