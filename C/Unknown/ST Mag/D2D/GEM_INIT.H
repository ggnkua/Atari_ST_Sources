extern int contrl[12],intin[132],ptsin[140],intout[145],ptsout[145];
		/* tableaux utilis‚s par les fonctions VDI */

extern int ap_id,handle,resol_x,resol_y;
		/* 	ap_id			= id du prg 
			handle			= id graphique de la VDI
			resol_x,resol_y	= abscisse & ordonn‚e maxi */

void gem_init(void);
void gem_exit(void);
