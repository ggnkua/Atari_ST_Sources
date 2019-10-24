/************************************************/
/*												*/
/* Transform‚e de Fourier directe et inverse	*/
/* FFT - Calcul‚e par le DSP56001				*/
/*												*/
/************************************************/


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>

#include "FFT_DSP.H"

int init_dsp(void);
void calculations(void);
int open_screen(void);
void close_screen(void);
void draw_signal(int nb_graph,int window,int *signal,int couleur);
void draw_spectre(int nb_graph,int window,int *spectre,int couleur);
void draw_dsp(int nb_graph,int window,int *spectre,int couleur);


int ap_id,handle,XRES,YRES;
int ability;

int signal[1024];
int spectre[1024*2];

int main(void)
{
	ap_id = appl_init();
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);

	ability = init_dsp();
	if (ability)
	{
		handle=open_screen();
		calculations();
		close_screen();
		Dsp_Reserve(0L,0L);
		Dsp_Unlock();
	}
	else
	{
		printf("\nerreur");
	}

	printf("\nAppuyez sur une touche");
	Bconin(2);

	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
	appl_exit();
	return 0;
}


void calculations(void)
{
	int i;
	double alpha;
	double f,fe;

	fe=49170.0;				/* Fr‚quence d'‚chantillonnage */
	f=5000.0;				/* Fr‚quence du signal */

	/* Calcul du sugnal … analyser */

	printf("\nCalcul du signal");
	for (i=0;i<1024;i++)
	{
		alpha = 2.0 * M_PI * ( f / fe ) * (double)i;
		signal[i] = 32767.0 * cos(alpha) * (1.0-0.5*cos(0.025*alpha)) * 0.5;
	}
	
	/*
	 * Calcul de la S‚rie de Fourier du signal
	 * en utilisant un algorithme de FFT
	 */

	printf("\nCalcul de la DFS");
	fft(signal,spectre,ability);

	draw_signal(5,1,signal,BLUE);
	draw_spectre(5,2,spectre,BLACK);
	draw_spectre(5,3,spectre+1,BLACK);
	draw_dsp(5,4,spectre,BLACK);

	/*
	 * Reconstruction du signal
	 * … partir de sa transform‚e de Fourier
	 */

	ffti(spectre,signal,ability);
	draw_signal(5,5,signal,RED);
}



void draw_signal(int nb_graph,int window,int *signal,int couleur)
{
	int pxy[4];
	int i;
	int y,h;
	double xfact,yfact;

	h = YRES / nb_graph;
	y = h * (window - 1) + h / 2;
	
	xfact = XRES / 1024.0;
	yfact = (h>>1) / 32767.0;
	
	vswr_mode(handle,MD_REPLACE);
	vsl_color(handle,couleur);
	
	for (i=0;i<1024;i++)
	{
		pxy[0] = pxy[2] = i * xfact;
		pxy[1] = y;
		pxy[3] = y - (signal[i] * yfact);
		v_pline(handle,2,pxy);
	}
}

void draw_spectre(int nb_graph,int window,int *spectre,int couleur)
{
	int pxy[4];
	int i;
	int y,h;
	double xfact,yfact;

	h = YRES / nb_graph;
	y = h * (window - 1) + h / 2;
	
	xfact = XRES / 1024.0;
	yfact = (h>>1) / 32768.0;
	
	vswr_mode(handle,MD_REPLACE);
	vsl_color(handle,couleur);
	
	for (i=0;i<1024;i++)
	{
		pxy[0] = pxy[2] = i * xfact;
		pxy[1] = y;
		pxy[3] = y - (spectre[i<<1] * yfact);
		v_pline(handle,2,pxy);
	}
}

void draw_dsp(int nb_graph,int window,int *spectre,int couleur)
{
	int pxy[4];
	int i;
	int y,h;
	double xfact;
	double a,b;

	h = YRES / nb_graph;
	y = h * (window - 1) + h;
	
	xfact = XRES / 1024.0;
	
	vswr_mode(handle,MD_REPLACE);
	vsl_color(handle,couleur);
	
	for (i=0;i<1024;i++)
	{
		a =	spectre[i<<1] / 32768.0;
		b =	spectre[(i<<1)+1] / 32768.0;
		pxy[0] = pxy[2] = i * xfact;
		pxy[1] = y;
		pxy[3] = y - ((a*a + b*b) * (h>>1));
		v_pline(handle,2,pxy);
	}
}


int init_dsp(void)
{
	int ability;
	long xmem,ymem;

	/*
	 * Demander le DSP et r‚server sa m‚moire
	 */
	 
	if (!Dsp_Lock())
	{
		ability = Dsp_RequestUniqueAbility();
		Dsp_Available(&xmem,&ymem);
		Dsp_Reserve(xmem,ymem);
	}
	else
	{
		ability = 0;
		printf("\nLe DSP est d‚ja en service");
	}
	return ability;
}


int open_screen(void)
{
	int pxy[4];
	int i,handle;
	for (i=0;i<10;i++)
		_VDIParBlk.intin[i]=1;
	_VDIParBlk.intin[0]=Getrez()+2;
	_VDIParBlk.intin[10]=2;
	v_opnvwk(_VDIParBlk.intin,&handle,_VDIParBlk.intout);
	XRES=(_VDIParBlk.intout[0]);
	YRES=(_VDIParBlk.intout[1]);

	pxy[0] = pxy[1] = 0;
	pxy[2] = XRES-1;
	pxy[3] = YRES-1;
	vsf_style(handle,FIS_SOLID);
	vsf_color(handle,WHITE);
	v_bar(handle,pxy);

	return handle;
}

void close_screen(void)
{
	v_clsvwk(handle);
}
