/* pc.c : module de base pour PC (Windows 3.1 et MultiMedia)
Description des instructions de ce module dans doc.txt.
Guillaume LAMONOCA
Supelec (94)

Utiliser Turbo C++ ou Borland C++ et compiler en modele LARGE
(Ou mieux, en modele HUGE si la perte de vitesse importe peu)

Si vous obtenez de nombreux Warnings, plutot que de
corriger vos sources, n'hesitez pas a desactiver ces
warnings! (Dans Options -> Compiler -> Messages)

Attention dans Compiler -> Optimizations, vous pouvez
choisir "Fastest" mais je vous conseille alors de
desactiver "Copy propagation","Invariant code motion"
et "Induction variables"!!!
(En optimisant trop on perd le sens de certaines
 lignes de programme!)

Dans Compiler -> Code generation, selectionnez
"Duplicate strings merged" pour gagner de la place sur
les chaines de characteres.

La fenetre produite n'a pas de bouton de fermeture.
Neanmoins vous pouvez forcer la fermeture par Alt+F4.
Mais il faut absolument eviter de sortir brusquement de
votre programme car sous windows les zones memoires allouees
dynamiquement doivent etre liberees a la fin de votre
programme! Une interruption brusque laissera ces zones
memoires inutilisables pour le systeme! Donc prevoyez
toujours un moyen de sortir de maniere normale de votre
programme (liberation des objets, des zones memoires et
appel a la fonction killsystem()).

Pour les samples, vous devez avoir installe un driver
correct avec le panneau de configuration de windows.
De plus il ne faut pas jouer un sample a une frequence
trop haute ou trop basse (ideal:11025 Hz).

Attention! Sur PC, un pointeur ne peut se "deplacer"
sur une zone plus vaste que 64Ko, a moins qu'il ne
soit declare comme suit (toujours le cas en modele HUGE):

char huge *p;

Pour garantir la portabilite sur les autres machines
il suffit alors d'ecrire:

#define huge <commentaire> dans header.h par exemple.
(exemple ci-dessous)


*/

#define prout /**/

#include <windows.h>
#include <mmsystem.h>
#include "header.h"

extern void main(void);











/********************************************************************/
/* variables globales */

/* facteur de grossissement maximum autorise */
static int RATIO=2;

static int emulmono=0;

static unsigned int oldpal[16]=
{
	0x0000,0x1008,0x3080,0x5088,
	0x2800,0x3808,0x4880,0x5ccc,
	0x3888,0x400f,0x50f0,0x60ff,
	0x4f00,0x5f0f,0x7ff0,0x8fff
};


static int silence=0;
static int ecran_travail=0;
static int ecran_actif=1;
static UINT nosound=1;
static HWAVEOUT hwo;
static PCMWAVEFORMAT pcmwf;
static WAVEHDR whdr;
static HANDLE hInst;
static HWND window;
static HDC hdcm,hdcm2,hdc;
static HBITMAP holdbitmap,holdbitmap2,hcharbm;
static HBITMAP hecran[2];
static HPEN hpen,holdpen;
static HBRUSH hbrush,holdbrush;
static PAINTSTRUCT ps;
static int nbscreen=2;
static COLORREF color=RGB(255,255,255);
static nocolor=15;

static int xcur=0;
static int ycur=0;

int mousex,mousey,mousek,vblclock;
int msex,msey,msek,mclk;

static int nbrbuffer=0;
static int lstbufptr=0;
static int msebufptr=0;
static int msebuffer[128];

char keymap[256]={
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};


static int keybuffer[256];
static int keybufptr=0;
static int keybufend=0;
static int keybufnbr=0;


/********************************************************************/
/* fontes */

static unsigned int sysfonte[64*16]={
0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0xc3,0xc3,0xc3,0xc3,0xc7,0xe7,0xc7,0xe7,0x1c,0x1c,0x1c,0x18,0x18,0x00,0x18,0x00,
0x81,0x81,0x81,0xdb,0xff,0xff,0xff,0xff,0x36,0x36,0x24,0x00,0x00,0x00,0x00,0x00,
0xc8,0x88,0x00,0x81,0x80,0x00,0x81,0xdb,0x13,0x33,0x7e,0x36,0x37,0x7e,0x24,0x00,
0x83,0x01,0x01,0x81,0xc0,0x00,0x80,0xc1,0x3c,0x6e,0x68,0x3e,0x0b,0x6b,0x3e,0x00,
0x9f,0x09,0x81,0xc3,0xc1,0x80,0xd8,0xfd,0x20,0x52,0x24,0x08,0x12,0x25,0x02,0x00,
0xc7,0x83,0x83,0x83,0x00,0x00,0x80,0xc6,0x18,0x24,0x34,0x38,0x4d,0x46,0x39,0x00,
0x8f,0x8f,0xcf,0x8f,0xdf,0xff,0xff,0xff,0x30,0x30,0x10,0x20,0x00,0x00,0x00,0x00,
0xf3,0xe3,0xc7,0xc7,0xc7,0xe7,0xf3,0xfb,0x04,0x08,0x18,0x10,0x18,0x08,0x04,0x00,
0xcf,0xe7,0xe3,0xf3,0xe3,0xe3,0xc7,0xef,0x10,0x08,0x0c,0x04,0x0c,0x08,0x10,0x00,
0xff,0xc9,0xe1,0x80,0xc0,0xc1,0xed,0xff,0x00,0x12,0x0c,0x3f,0x0c,0x12,0x00,0x00,
0xff,0xe3,0xe3,0x80,0xc0,0xe3,0xf3,0xff,0x00,0x0c,0x0c,0x3f,0x0c,0x0c,0x00,0x00,
0xff,0xff,0xff,0xff,0xc7,0xc7,0x87,0xcf,0x00,0x00,0x00,0x00,0x18,0x18,0x30,0x00,
0xff,0xff,0xff,0x81,0xc1,0xff,0xff,0xff,0x00,0x00,0x00,0x3e,0x00,0x00,0x00,0x00,
0xff,0xff,0xff,0xff,0xff,0x8f,0x8f,0xcf,0x00,0x00,0x00,0x00,0x00,0x30,0x30,0x00,
0xff,0xf9,0xf1,0xe3,0xc7,0x8f,0xdf,0xff,0x00,0x02,0x04,0x08,0x10,0x20,0x00,0x00,
0xc3,0x81,0x00,0x00,0x00,0x80,0xc1,0xe3,0x1c,0x26,0x63,0x63,0x63,0x32,0x1c,0x00,
0xe3,0xc3,0xe3,0xe3,0xe3,0xe3,0x80,0xc0,0x0c,0x1c,0x0c,0x0c,0x0c,0x0c,0x3f,0x00,
0x81,0x00,0x80,0xc0,0x81,0x03,0x00,0x80,0x3e,0x63,0x07,0x1e,0x3c,0x70,0x7f,0x00,
0x00,0x80,0xe1,0xc1,0xe0,0x00,0x80,0xc1,0x7f,0x06,0x0c,0x1e,0x03,0x63,0x3e,0x00,
0xe1,0xc1,0x81,0x01,0x00,0x80,0xf1,0xf9,0x0e,0x1e,0x36,0x66,0x7f,0x06,0x06,0x00,
0x01,0x01,0x01,0x80,0xf8,0x18,0x80,0xc1,0x7e,0x60,0x7e,0x03,0x03,0x63,0x3e,0x00,
0xc1,0x81,0x0f,0x01,0x00,0x00,0x80,0xc1,0x1e,0x30,0x60,0x7e,0x63,0x63,0x3e,0x00,
0x00,0x80,0xf0,0xe1,0xc3,0xc7,0xc7,0xe7,0x7f,0x03,0x06,0x0c,0x18,0x18,0x18,0x00,
0x83,0x01,0x01,0x81,0x00,0x00,0x80,0xc1,0x3c,0x62,0x72,0x3c,0x4f,0x43,0x3e,0x00,
0x81,0x00,0x00,0x80,0xc0,0xf0,0x81,0xc3,0x3e,0x63,0x63,0x3f,0x03,0x06,0x3c,0x00,
0xff,0xc7,0xc7,0xe7,0xc7,0xc7,0xe7,0xff,0x00,0x18,0x18,0x00,0x18,0x18,0x00,0x00,
0xff,0xc7,0xc7,0xe7,0xc7,0xc7,0x87,0xcf,0x00,0x18,0x18,0x00,0x18,0x18,0x30,0x00,
0xf1,0xe1,0xc3,0x87,0xc7,0xe3,0xf1,0xf9,0x06,0x0c,0x18,0x30,0x18,0x0c,0x06,0x00,
0xff,0xff,0x81,0xc1,0x81,0xc1,0xff,0xff,0x00,0x00,0x3e,0x00,0x3e,0x00,0x00,0x00,
0x8f,0xc7,0xe3,0xf1,0xe1,0xc3,0x87,0xcf,0x30,0x18,0x0c,0x06,0x0c,0x18,0x30,0x00,
0x81,0x00,0x00,0x80,0xe1,0xf3,0xe3,0xf3,0x3e,0x7f,0x63,0x06,0x0c,0x00,0x0c,0x00,
0x83,0x01,0x00,0x00,0x00,0x00,0x00,0x81,0x3c,0x42,0x99,0xa1,0xa1,0x99,0x42,0x3c,
0xc3,0x81,0x00,0x00,0x00,0x00,0x18,0x9c,0x1c,0x36,0x63,0x63,0x7f,0x63,0x63,0x00,
0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x81,0x7e,0x63,0x63,0x7e,0x63,0x63,0x7e,0x00,
0xc1,0x80,0x0c,0x1f,0x1f,0x88,0xc0,0xe1,0x1e,0x33,0x60,0x60,0x60,0x33,0x1e,0x00,
0x03,0x01,0x00,0x00,0x00,0x00,0x01,0x83,0x7c,0x66,0x63,0x63,0x63,0x66,0x7c,0x00,
0x00,0x00,0x1f,0x01,0x01,0x1f,0x00,0x80,0x7f,0x60,0x60,0x7e,0x60,0x60,0x7f,0x00,
0x00,0x00,0x1f,0x01,0x01,0x1f,0x1f,0x9f,0x7f,0x60,0x60,0x7e,0x60,0x60,0x60,0x00,
0xc0,0x80,0x0f,0x00,0x00,0x80,0xc0,0xe0,0x1f,0x30,0x60,0x6f,0x63,0x33,0x1f,0x00,
0x18,0x18,0x18,0x00,0x00,0x18,0x18,0x9c,0x63,0x63,0x63,0x7f,0x63,0x63,0x63,0x00,
0x80,0xc0,0xe3,0xe3,0xe3,0xe3,0x80,0xc0,0x3f,0x0c,0x0c,0x0c,0x0c,0x0c,0x3f,0x00,
0xf8,0xf8,0xf8,0xf8,0xf8,0x18,0x80,0xc1,0x03,0x03,0x03,0x03,0x03,0x63,0x3e,0x00,
0x18,0x10,0x01,0x03,0x03,0x01,0x10,0x98,0x63,0x66,0x6c,0x78,0x7c,0x6e,0x67,0x00,
0x8f,0x8f,0x8f,0x8f,0x8f,0x8f,0x80,0xc0,0x30,0x30,0x30,0x30,0x30,0x30,0x3f,0x00,
0x18,0x00,0x00,0x00,0x10,0x18,0x18,0x9c,0x63,0x77,0x7f,0x6b,0x63,0x63,0x63,0x00,
0x18,0x08,0x00,0x00,0x00,0x10,0x18,0x9c,0x63,0x73,0x7b,0x7f,0x6f,0x67,0x63,0x00,
0x81,0x00,0x00,0x00,0x00,0x00,0x80,0xc1,0x3e,0x63,0x63,0x63,0x63,0x63,0x3e,0x00,
0x01,0x00,0x00,0x00,0x00,0x01,0x1f,0x9f,0x7e,0x63,0x63,0x63,0x7e,0x60,0x60,0x00,
0x81,0x00,0x00,0x00,0x00,0x00,0x80,0xc2,0x3e,0x63,0x63,0x63,0x6f,0x66,0x3d,0x00,
0x01,0x00,0x00,0x00,0x00,0x01,0x10,0x98,0x7e,0x63,0x63,0x67,0x7c,0x6e,0x67,0x00,
0x83,0x01,0x01,0x81,0xc0,0x00,0x80,0xc1,0x3c,0x66,0x60,0x3e,0x03,0x63,0x3e,0x00,
0x80,0xc0,0xe3,0xe3,0xe3,0xe3,0xe3,0xf3,0x3f,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x00,
0x18,0x18,0x18,0x18,0x18,0x18,0x80,0xc1,0x63,0x63,0x63,0x63,0x63,0x63,0x3e,0x00,
0x18,0x18,0x18,0x00,0x80,0xc1,0xe3,0xf7,0x63,0x63,0x63,0x77,0x3e,0x1c,0x08,0x00,
0x18,0x18,0x18,0x00,0x00,0x00,0x08,0x9c,0x63,0x63,0x63,0x6b,0x7f,0x77,0x63,0x00,
0x18,0x00,0x80,0xc1,0x81,0x00,0x08,0x9c,0x63,0x77,0x3e,0x1c,0x3e,0x77,0x63,0x00,
0x11,0x11,0x11,0x81,0xc3,0xc7,0xc7,0xe7,0x66,0x66,0x66,0x3c,0x18,0x18,0x18,0x00,
0x00,0x80,0xe0,0xc1,0x83,0x07,0x00,0x80,0x7f,0x07,0x0e,0x1c,0x38,0x70,0x7f,0x00,
0xc3,0xc3,0xc7,0xc7,0xc7,0xc7,0xc3,0xe3,0x1c,0x18,0x18,0x18,0x18,0x18,0x1c,0x00,
0xff,0x9f,0xcf,0xe7,0xf3,0xf9,0xfd,0xff,0x00,0x20,0x10,0x08,0x04,0x02,0x00,0x00,
0xc3,0xe3,0xe3,0xe3,0xe3,0xe3,0xc3,0xe3,0x1c,0x0c,0x0c,0x0c,0x0c,0x0c,0x1c,0x00,
0xe7,0xc3,0x81,0x08,0x9c,0xff,0xff,0xff,0x08,0x1c,0x36,0x63,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x00
};


/**********************************************************************/
/* tables trigonometriques 14 bits */

static int tsn[320]={
	0,402,804,1205,1606,2006,2404,2801,
	3196,3590,3981,4370,4756,5139,5520,5897,
	6270,6639,7005,7366,7723,8076,8423,8765,
	9102,9434,9760,10080,10394,10702,11003,11297,
	11585,11866,12140,12406,12665,12916,13160,13395,
	13623,13842,14053,14256,14449,14635,14811,14978,
	15137,15286,15426,15557,15679,15791,15893,15986,
	16069,16143,16207,16261,16305,16340,16364,16379,
	16384,16379,16364,16340,16305,16261,16207,16143,
	16069,15986,15893,15791,15679,15557,15426,15286,
	15137,14978,14811,14635,14449,14256,14053,13842,
	13623,13395,13160,12916,12665,12406,12140,11866,
	11585,11297,11003,10702,10394,10080,9760,9434,
	9102,8765,8423,8076,7723,7366,7005,6639,
	6270,5897,5520,5139,4756,4370,3981,3590,
	3196,2801,2404,2006,1606,1205,804,402,
	0,-402,-804,-1205,-1606,-2006,-2404,-2801,
	-3196,-3590,-3981,-4370,-4756,-5139,-5520,-5897,
	-6270,-6639,-7005,-7366,-7723,-8076,-8423,-8765,
	-9102,-9434,-9760,-10080,-10394,-10702,-11003,-11297,
	-11585,-11866,-12140,-12406,-12665,-12916,-13160,-13395,
	-13623,-13842,-14053,-14256,-14449,-14635,-14811,-14978,
	-15137,-15286,-15426,-15557,-15679,-15791,-15893,-15986,
	-16069,-16143,-16207,-16261,-16305,-16340,-16364,-16379,
	-16384,-16379,-16364,-16340,-16305,-16261,-16207,-16143,
	-16069,-15986,-15893,-15791,-15679,-15557,-15426,-15286,
	-15137,-14978,-14811,-14635,-14449,-14256,-14053,-13842,
	-13623,-13395,-13160,-12916,-12665,-12406,-12140,-11866,
	-11585,-11297,-11003,-10702,-10394,-10080,-9760,-9434,
	-9102,-8765,-8423,-8076,-7723,-7366,-7005,-6639,
	-6270,-5897,-5520,-5139,-4756,-4370,-3981,-3590,
	-3196,-2801,-2404,-2006,-1606,-1205,-804,-402,
	0,402,804,1205,1606,2006,2404,2801,
	3196,3590,3981,4370,4756,5139,5520,5897,
	6270,6639,7005,7366,7723,8076,8423,8765,
	9102,9434,9760,10080,10394,10702,11003,11297,
	11585,11866,12140,12406,12665,12916,13160,13395,
	13623,13842,14053,14256,14449,14635,14811,14978,
	15137,15286,15426,15557,15679,15791,15893,15986,
	16069,16143,16207,16261,16305,16340,16364,16379
};
static int ttg[65]={
	-16384,-15599,-14850,-14133,-13446,-12786,-12151,-11539,
	-10947,-10375,-9820,-9281,-8757,-8247,-7749,-7263,
	-6786,-6320,-5862,-5413,-4970,-4534,-4104,-3679,
	-3259,-2843,-2430,-2021,-1614,-1209,-805,-402,
	0,402,805,1209,1614,2021,2430,2843,
	3259,3679,4104,4534,4970,5413,5862,6320,
	6786,7263,7749,8247,8757,9281,9820,10375,
	10947,11539,12151,12786,13446,14133,14850,15599,
	16384
};
int *sn=tsn;
int *cs=tsn+64;
int *tg=ttg+32;











/*******************************************************************************/
/* initialisation du systeme */




static void initwindow(void)
{
	hdc=GetDC(window);
	hdcm=CreateCompatibleDC(hdc);
	hdcm2=CreateCompatibleDC(hdc);
	hcharbm=CreateBitmap(8,8,1,1,&sysfonte[0]);
	hecran[0]=CreateCompatibleBitmap(hdc,320*RATIO,200*RATIO);
	hecran[1]=CreateCompatibleBitmap(hdc,320*RATIO,200*RATIO);
	ReleaseDC(window,hdc);
	holdbitmap=SelectObject(hdcm,hecran[ecran_actif]);
	holdbitmap2=SelectObject(hdcm2,hcharbm);

	hpen=CreatePen(PS_NULL,1,NULL);
	hbrush=CreateSolidBrush(RGB(0,0,0));
	holdbrush=SelectObject(hdcm,hbrush);
	holdpen=SelectObject(hdcm,hpen);
	Rectangle(hdcm,0,0,320*RATIO+1,200*RATIO+1);
	SelectObject(hdcm,hecran[ecran_travail]);
	Rectangle(hdcm,0,0,320*RATIO+1,200*RATIO+1);
	SelectObject(hdcm,holdbrush);
	SelectObject(hdcm,holdbrush);
	SelectObject(hdcm,holdpen);
	DeleteObject(hbrush);
	DeleteObject(hpen);

	hpen=CreatePen(PS_NULL,1,NULL);
	holdpen=SelectObject(hdcm,hpen);
	hbrush=CreateSolidBrush(color);
	holdbrush=SelectObject(hdcm,hbrush);

	SetTextColor(hdcm,RGB(0,0,0));



	pcmwf.wf.wFormatTag=WAVE_FORMAT_PCM;
	pcmwf.wf.nChannels=1;
	pcmwf.wf.nSamplesPerSec=11025L;
	pcmwf.wf.nAvgBytesPerSec=11025L;
	pcmwf.wf.nBlockAlign=1;
	pcmwf.wBitsPerSample=8;    
	nosound=waveOutOpen(&hwo,WAVE_MAPPER,&pcmwf,NULL,NULL,NULL);
	if (!nosound)
	{
    	waveOutGetID(hwo,&nosound);
		waveOutSetVolume(nosound,0xffff);
		waveOutReset(hwo);
		waveOutClose(hwo);
    	nosound=1;
    }

}



int initsystem(void)
{
	return 1;
}


void killsystem(void)
{
	MSG msg;

	stopsample();

	pcmwf.wf.wFormatTag=WAVE_FORMAT_PCM;
	pcmwf.wf.nChannels=1;
	pcmwf.wf.nSamplesPerSec=11025L;
	pcmwf.wf.nAvgBytesPerSec=11025L;
	pcmwf.wf.nBlockAlign=1;
	pcmwf.wBitsPerSample=8;
	nosound=waveOutOpen(&hwo,WAVE_MAPPER,&pcmwf,NULL,NULL,NULL);
	if (!nosound)
	{
		waveOutGetID(hwo,&nosound);
		waveOutSetVolume(nosound,0);
		waveOutReset(hwo);
		waveOutClose(hwo);
    	nosound=1;
    }

	playsample(&silence,1L,11025L);
	stopsample();

	SelectObject(hdcm,holdbrush);
	SelectObject(hdcm,holdpen);
	DeleteObject(hbrush);
	DeleteObject(hpen);

	SelectObject(hdcm,holdbitmap);
	SelectObject(hdcm2,holdbitmap2);
	DeleteObject(hcharbm);
	DeleteObject(hecran[0]);
	DeleteObject(hecran[1]);
	DeleteDC(hdcm);
	DeleteDC(hdcm2);
	PostQuitMessage(0);

	while(GetMessage(&msg, NULL, 0, 0))
	{
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

    exit(0);
}




long FAR PASCAL WndProc (HWND hWnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
	window=hWnd;

	switch (Message)
	{
		case WM_CREATE:
			break;

		case WM_PAINT:
			hdc=BeginPaint(window,&ps);
			SelectObject(hdcm,hecran[ecran_actif]);
			BitBlt(hdc,0,0,320*RATIO,200*RATIO,hdcm,0,0,SRCCOPY);
			SelectObject(hdcm,hecran[ecran_travail]);
			EndPaint(window,&ps);
			break;

		case WM_DESTROY:
			killsystem();
			break;

		default:
			return (DefWindowProc(hWnd, Message, wParam, lParam));
	}
	return (NULL);
}




static int InitApplication(HANDLE hInstance)
{
	WNDCLASS  wc;

	wc.style = CS_BYTEALIGNCLIENT;
	wc.lpfnWndProc = WndProc;
	wc.cbClsExtra = 0;
	wc.cbWndExtra = 0;
	wc.hInstance = hInstance;
	wc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
	wc.hCursor = LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground = GetStockObject(BLACK_BRUSH);
	wc.lpszMenuName = NULL;
	wc.lpszClassName = "OutputWClass";

	return (RegisterClass(&wc));
}



static int InitInstance(HANDLE hInstance, int nCmdShow)
{
	HWND	hWnd;
	int		rx,ry,screenH,screenW,windowW,windowH;

	screenH=GetSystemMetrics(SM_CYSCREEN);
	screenW=GetSystemMetrics(SM_CXSCREEN);

	rx=screenW/320;
	ry=screenH/200;
	if (ry<rx) rx=ry;
	if (rx<RATIO) RATIO=rx;

	windowW=320*RATIO+2*GetSystemMetrics(SM_CXBORDER);
	windowH=200*RATIO+GetSystemMetrics(SM_CYCAPTION)+GetSystemMetrics(SM_CYBORDER);
	if (!RATIO) return 0;

	hInst = hInstance;

	hWnd = CreateWindow(
		"OutputWClass",
		"",
		NULL,
		(screenW-windowW)/2,
		(screenH-windowH)/2,
		windowW,
		windowH,
		NULL,
		NULL,
		hInstance,
		NULL
	);

	if (!hWnd)
		return (FALSE);

	window=hWnd;

	ShowWindow(hWnd, nCmdShow);
	UpdateWindow(hWnd);
	return (TRUE);

}






#pragma argsused
int PASCAL WinMain(HANDLE hInstance, HANDLE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{

	if (!hPrevInstance)
	if (!InitApplication(hInstance))
		return (FALSE);

	if (!InitInstance(hInstance, nCmdShow))
		return (FALSE);

	initwindow();

	main();

	return 0;
}



























/***************************************************************/
/* gestion des couleurs */


static COLORREF couleur(int n)
{
	unsigned int r,v,b;

	if (n==FOND) return RGB(0,0,0);
	if (n==MASK) return RGB(255,255,255);

	if (!emulmono)
    {
		r=16*((oldpal[n]>>8)&15);
		v=16*((oldpal[n]>>4)&15);
		b=16*(oldpal[n]&15);

		if (r>=240) r=255;
		if (v>=240) v=255;
		if (b>=240) b=255;
	}
	else
	{
		switch((oldpal[n]>>12)&15)
		{
			case 0: r=0; break;
			case 1: r=1; break;
			case 2: r=1; break;
			case 3: r=2; break;
			case 4: r=4; break;
			case 5: r=6; break;
			case 6: r=7; break;
			case 7: r=7; break;
			case 8: r=8; break;
		}
		r*=16;
		return RGB(r,r,r);
	}

	return RGB(r,v,b);
}

void setcolor(int c)
{
	if (nocolor!=c)
    {
		color=couleur(c);
		nocolor=c;

		SelectObject(hdcm,holdbrush);
		DeleteObject(hbrush);
		hbrush=CreateSolidBrush(color);
		SelectObject(hdcm,hbrush);
	}
}


void getpalette(unsigned int *pal)
{
	int i;

	for(i=0;i<16;i++) pal[i]=oldpal[i];
}



void setpalette(unsigned int *pal)
{
	int i;

	for(i=0;i<16;i++) oldpal[i]=pal[i];
}

















/************************************************************/
/* instructions de gestion des ecrans graphiques */



void simplescreen(void)
{
	if (nbscreen==2)
	{
		ecran_travail=ecran_actif;
		nbscreen=1;
		SelectObject(hdcm,hecran[ecran_travail]);
	}
}


void doublescreen(void)
{
	if (nbscreen==1)
	{
		ecran_travail=1-ecran_actif;
		nbscreen=2;
		SelectObject(hdcm,hecran[ecran_travail]);
	}
}


void cls(void)
{
	int t;

	xcur=ycur=0;
	t=nocolor;
	pbox(0,0,320,200,0);
	setcolor(t);
}


void copyscreen(void)
{
	if (nbscreen==2)
	{
		SelectObject(hdcm2,hecran[ecran_actif]);
		BitBlt(hdcm,0,0,320*RATIO,200*RATIO,hdcm2,0,0,SRCCOPY);
		SelectObject(hdcm2,hcharbm);
	}
}


void refresh(void)
{
	vblclock++;
	RedrawWindow(window,NULL,NULL,RDW_INVALIDATE);
    buthit();
}



void swap(void)
{
	vblclock++;
	if (nbscreen==2)
	{
		ecran_travail=1-ecran_travail;
		ecran_actif=1-ecran_actif;
	}
	RedrawWindow(window,NULL,NULL,RDW_INVALIDATE);
	SelectObject(hdcm,hecran[ecran_travail]);
	buthit();

}













/******************************************************************/
/* instructions graphiques de base */

#define SGN(x) ((x==0)?(0):((x<0)?(-1):(1)))
#define ABS(x) ((x<0)?(-(x)):(x))

void pellipse(int x,int y,int lx,int ly,int c)
{
	if (c>=0) setcolor(c);

	Ellipse(hdcm,x*RATIO,y*RATIO,(x+lx)*RATIO+1,(y+ly)*RATIO+1);
}


void pbox(int x,int y,int lx,int ly,int c)
{
	if (c>=0) setcolor(c);

	Rectangle(hdcm,x*RATIO,y*RATIO,(x+lx)*RATIO+1,(y+ly)*RATIO+1);
}


void plot(int x,int y,int c)
{
	if (c>=0) setcolor(c);

	Rectangle(hdcm,x*RATIO,y*RATIO,(x+1)*RATIO+1,(y+1)*RATIO+1);
}


void vline(int x,int y,int y2,int c)
{
	if (y2>y) pbox(x,y,1,y2-y+1,c); else pbox(x,y2,1,y-y2+1,c);
}


void hline(int x,int y,int x2,int c)
{
	if (x2>x) pbox(x,y,x2-x+1,1,c); else pbox(x2,y,x-x2+1,1,c);
}


void rline(int x,int y,int x2,int y2,int c)
{
	HPEN hp;
	if (c>=0) setcolor(c);

	hp=CreatePen(PS_SOLID,1,color);
	SelectObject(hdcm,hp);
	MoveTo(hdcm,x*RATIO,y*RATIO);
	LineTo(hdcm,x2*RATIO,y2*RATIO);
	SelectObject(hdcm,hpen);
	DeleteObject(hp);
}



void dline(int x1,int y1,int x2,int y2,int c)
{
	int dx=x2-x1;
	int dy=y2-y1;
	int d;
	int i;
	double a,x,y;

	if (c>=0) setcolor(c);

	if (!dx) vline(x1,y1,y2,-1);
	else
		if (!dy) hline(x1,y1,x2,-1);
		else
		{

			if (ABS(dx)>ABS(dy))
			{
				d=SGN(dx);
				a=(double)dy/ABS(dx);
				for(i=x1,y=0.5+(double)y1;i!=x2;i+=d,y+=a)
					plot(i,(int)y,-1);
			}
			else
			{
				d=SGN(dy);
				a=(double)dx/ABS(dy);
				for(i=y1,x=0.5+(double)x1;i!=y2;i+=d,x+=a)
					plot((int)x,i,-1);
			}

			plot(x2,y2,-1);
		}

}




void dbox(int x,int y,int lx,int ly,int c)
{
	if (c>=0) setcolor(c);
	pbox(x,y,lx,1,-1);
	pbox(x,y+ly-1,lx,1,-1);
	pbox(x,y,1,ly,-1);
	pbox(x+lx-1,y,1,ly,-1);
}


void polyline(int n,int *tp,int c)
{
	int i;

	if (c>=0) setcolor(c);
	for(i=0;i<n-1;i++)
		rline(tp[i*2],tp[i*2+1],tp[i*2+2],tp[i*2+3],-1);

}



void polyfill(int n,int *tp,int c)
{
	POINT points[256];
	int i;

	if (c>=0) setcolor(c);
	for(i=0;i<n;i++)
	{
		points[i].x=RATIO*tp[i*2];
		points[i].y=RATIO*tp[i*2+1];
	}
	Polygon(hdcm,points,n);
}










/*****************************************************************/
/* instructions d'allocation memoire                             */

long ramfree(void)
{
	return GetFreeSpace(NULL);
}


void *memalloc(long size)
{
	char huge *r=0L;
    HGLOBAL hg;

	hg=GlobalAlloc(GMEM_MOVEABLE|GMEM_SHARE,size+(long)sizeof(HGLOBAL));

	if (hg)
	{
		r=GlobalLock(hg);
		if (r)
        {
			*(HGLOBAL *)r=hg;
			r+=sizeof(HGLOBAL);
		}
		else
			GlobalFree(hg);
	}

	return (void *)r;
}


void memfree(void **ptr)
{
	HGLOBAL hg;
    char huge *r;

	if (*ptr)
	{
		r=(char huge *)*ptr;
		r-=sizeof(HGLOBAL);
		hg=*(HGLOBAL *)r;
		GlobalUnlock(hg);
		GlobalFree(hg);
		*ptr=(void *)0L;
	}
}










/**************************************************************/
/* transferts de blocs memoire */

void bmove(void *src,void *dst,long len)
{
	char huge *hs;
	char huge *hd;
	char *s;
	char *d;
	long hi;
	int i,l;

	if (len>65535L)
	{
		hs=(char huge *)src;
		hd=(char huge *)dst;
		if (hs>hd)
			for(hi=0L;hi<len;hi++) *(hd++)= *(hs++);
		else
			for(hd+=len,hs+=len,hi=0L;hi<len;hi++) *(--hd)= *(--hs);
	}
	else
	{
		l=(int)len;
		s=(char *)src;
		d=(char *)dst;
		if (s>d)
			for(i=0;i<l;i++) *(d++)= *(s++);
		else
			for(d+=l,s+=l,i=0;i<l;i++) *(--d)= *(--s);
	}
}










/*****************************************************************/
/* instructions de gestion d'horloge                             */


unsigned long systime(void)
{
	return GetTickCount();
}


void waitdelay(unsigned int n)
{
	unsigned long start;
	start=systime();
	do {} while((unsigned long)(systime()-start)<((unsigned long)n));
}


















/******************************************************************/
/* fonctions aleatoires                                           */


int randint(void)
{
	return(rand()&0x7fff);
}

int randval(int n)
{
	return(randint()%n);
}















/**************************************************************/
/* gestion des fichiers */

#define MAXFILE 16
HMMIO ftab[MAXFILE];
char fused[MAXFILE]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

static int nextfile(void)
{
	int r=0;
	int i;

	for(i=0;i<MAXFILE;i++) if (!fused[i]) r=i+1;
	return(r);
}



static void verifnom(char *s,char *s2)
{
	while(*s)
	{
		*s2= *s;
		if (*s=='/') *s2='\\';
		s++;
		s2++;
	}
	*s2=0;
}


int bexist(char *nom)
{
	HMMIO fp;
	char nom2[200];
	verifnom(nom,nom2);

	fp = mmioOpen(nom2,NULL,MMIO_READ);
	if (fp)
	{
		mmioClose(fp,NULL);
		return(1);
	}
	else
		return(0);
}


long bsize(char *nom)
{
	HMMIO fp;
	char nom2[200];
	long size=0L;

	verifnom(nom,nom2);

	fp = mmioOpen(nom2,NULL,MMIO_READ);
	if (fp)
	{
		size=mmioSeek(fp, 0L, SEEK_END);
		mmioClose(fp,NULL);
	}

	return(size);
}



int bsave(char *nom,void *adr,long offset,long len)
{
	void *buffer;
	long filesize;
	HMMIO fp;
	int r= -1;
	char *d;
	char *s;
	long i;

	char nom2[200];
	verifnom(nom,nom2);
	fp = mmioOpen(nom2,NULL,MMIO_READ);
	if (fp)
	{
    	r=0;
		filesize = mmioSeek(fp, 0L, SEEK_END);
		mmioClose(fp,NULL);

		if (!r)
		{
			r= -1;
			if (buffer=memalloc(filesize))
			{
				if (!bload(nom,buffer,0L,filesize))
				{
					s=(char *)adr;
					d=(char *)(buffer)+offset;
					for(i=0L;i<len;i++) *(d++)= *(s++);
					r=bmake(nom,buffer,filesize);
				}
				memfree((void **)&buffer);
			}
		}
	}

	return(r);
}




int bload(char *nom,void *adr,long offset,long len)
{
	HMMIO fp;
	int r= -1;
	char nom2[200];

	verifnom(nom,nom2);

	fp = mmioOpen(nom2,NULL,MMIO_READ);
	if (fp)
	{
		mmioSeek(fp, offset, SEEK_SET);
		if (len==mmioRead(fp,adr,len))
			r=0;
		else
			r= -1;
		mmioClose(fp,NULL);
	}

	return(r);
}




int bmake(char *nom,void *adr,long len)
{
	HMMIO fp;
	int r= -1;
	char nom2[200];

	verifnom(nom,nom2);

	fp = mmioOpen(nom2,NULL,MMIO_WRITE|MMIO_CREATE);
	if (fp)
	{
		if (len==mmioWrite(fp,adr,len))
			r=0;
		else
			r= -1;
		mmioClose(fp,NULL);
	}
	return(r);
}



int bcreate(char *nom)
{
	HMMIO fp;
	int r=0;
	char nom2[200];

	r=nextfile();
	if (r)
	{
		verifnom(nom,nom2);
		fp = mmioOpen(nom2,NULL,MMIO_WRITE|MMIO_CREATE);
		if (fp) { ftab[r-1]=fp; fused[r-1]=1; }
		else r=0;
	}
	return(r);
}



int bopen(char *nom)
{
	HMMIO fp;
	int r=0;
	char nom2[200];

	r=nextfile();
	if (r)
	{
		verifnom(nom,nom2);
		fp = mmioOpen(nom2,NULL,MMIO_READ);
		if (fp) { ftab[r-1]=fp; fused[r-1]=1; }
		else r=0;
	}
	return(r);
}



int bclose(int n)
{
	HMMIO fp;
	int r=0;

	if (n)
	{
		fp=ftab[n-1];
		mmioClose(fp,NULL);
		fused[n-1]=0;
	}
	return(r);
}




int bwrite(int n,void *adr,long len)
{
	HMMIO fp;
	int r= -1;

	if (n)
	{
		fp=ftab[n-1];
		if (fp)
		{
			if (len==mmioWrite(fp,adr,len))
				r=0;
			else
				r= -1;
		}
	}
	return(r);
}




int bread(int n,void *adr,long len)
{
	HMMIO fp;
	int r= -1;

	if (n)
	{
		fp=ftab[n-1];
		if (fp)
		{
			if (len==mmioRead(fp,adr,len))
				r=0;
			else
				r= -1;
		}
	}
	return(r);
}


















/**************************************************************/
/* gestion de la souris et du clavier */

void hide(void)
{
}

void show(void)
{
}




static void addchar(int c)
{
	if (keybufnbr<256)
	{
		keybuffer[keybufptr++]=c;
		keybufnbr++;
		keybufptr&=255;
	}
}



static void addbut(int k,int x,int y,int c)
{
	int ptr;

	if (nbrbuffer<32)
	{
		ptr=(msebufptr>>1);
		msebuffer[ptr]=k;
		msebuffer[ptr+1]=x;
		msebuffer[ptr+2]=y;
		msebuffer[ptr+3]=c;
		msebufptr+=8;
		msebufptr&=255;
		nbrbuffer++;
	}
}


static void msemoved(int x,int y,unsigned int k)
{
	mousex=x;
	mousey=y;
	if (mousex<0) mousex=0;
	if (mousey<0) mousey=0;
	if (mousex>319) mousex=319;
	if (mousey>199) mousey=199;
	mousek=0;
	if (k&MK_LBUTTON) mousek|=1;
	if (k&MK_RBUTTON) mousek|=2;
}


static unsigned int scancode(unsigned int k)
{
	switch(k)
	{
		case 0xDB: k=')'; break;
		case 0xBB: k='='; break;
		case 0xDD: k='^'; break;
		case 0xBA: k='$'; break;
		case 0xC0: k='%'; break;
		case 0xDC: k='*'; break;
		case 0xBC: k=','; break;
		case 0xBE: k=';'; break;
		case 0xBF: k=':'; break;
		case 0xDF: k='!'; break;
		case 111: k='/'; break;
		case 106: k='*'; break;
		case 109: k='-'; break;
		case 107: k='+'; break;
		case 110: k='.'; break;
		case 96: k='0'; break;
		case 97: k='1'; break;
		case 98: k='2'; break;
		case 99: k='3'; break;
		case 100: k='4'; break;
		case 101: k='5'; break;
		case 102: k='6'; break;
		case 103: k='7'; break;
		case 104: k='8'; break;
		case 105: k='9'; break;
		case 0x26: k='^'; break;
		case 0x28: k='v'; break;
		case 0x25: k='<'; break;
		case 0x27: k='>'; break;
		case 226: k='<'; break;
    }

	if ((k>='A')&&(k<='Z')) k+=32;

	if (k>127) k=0;
	if ((k<32)&&(k!=27)&&(k!=13)&&(k!=8)) k=0;

	return k;
}


static int lookevent(MSG *msg)
{
	int x,y,k,r;

	k=(unsigned int)msg->wParam;
	x=((int)LOWORD(msg->lParam))/RATIO;
	y=((int)HIWORD(msg->lParam))/RATIO;
    r=1;

	switch (msg->message)
	{
	case WM_MOUSEMOVE:
		msemoved(x,y,k);
		break;

	case WM_LBUTTONDOWN:
		msemoved(x,y,k);

		if ((x<320)&&(y<200)&&(x>=0)&&(y>=0))
			addbut(1,x,y,(int)(msg->time&65535L));

		break;

	case WM_LBUTTONUP:
		msemoved(x,y,k);

		if ((x<320)&&(y<200)&&(x>=0)&&(y>=0))
			addbut(5,x,y,(int)(msg->time&65535L));

		break;

	case WM_RBUTTONDOWN:
		msemoved(x,y,k);

		if ((x<320)&&(y<200)&&(x>=0)&&(y>=0))
			addbut(2,x,y,(int)(msg->time&65535L));

		break;

	case WM_RBUTTONUP:
		msemoved(x,y,k);

		if ((x<320)&&(y<200)&&(x>=0)&&(y>=0))
			addbut(6,x,y,(int)(msg->time&65535L));

		break;


	case WM_KEYUP:
		k&=255;
        k=scancode(k);
		if (k) keymap[k]=0;
		break;

	case WM_KEYDOWN:
		k&=255;
		k=scancode(k);
		if ((k)&&(!(msg->lParam>>30)))
		{
			addchar(k);
			keymap[k]=1;
        }
		break;

	default:
		r=0;
        break;
	}

    return r;
}





int getmouse(void)
{
	int ptr;

	buthit();

	if (nbrbuffer)
	{
		ptr=(lstbufptr>>1);
		msek=msebuffer[ptr];
		msex=msebuffer[ptr+1];
		msey=msebuffer[ptr+2];
		mclk=msebuffer[ptr+3];
		lstbufptr+=8;
		lstbufptr&=255;
		nbrbuffer-=1;

		/* msek: bit 0:bouton gauche  bit 1:bouton droit  bit 2:0:presse 1:relache */

		return msek;
	}

	return 0;
}







int buthit(void)
{
	MSG msg;

	while(PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
		if (!lookevent(&msg))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}

	return(nbrbuffer);
}





void empty(void)
{
	kbhit();
	buthit();

	keybufnbr=keybufptr=keybufend=0;
	nbrbuffer=lstbufptr=msebufptr=0;
}


char getch(void)
{
	char c=0;
    MSG msg;

	while(!kbhit())
	{
		if (GetMessage(&msg, NULL, 0, 0))
            if (!lookevent(&msg))
			{
				TranslateMessage(&msg);
				DispatchMessage(&msg);
			}
	}

	if (keybufnbr)
	{
		c=keybuffer[keybufend++];
		keybufend&=255;
		keybufnbr--;
	}

	return(c);
}


int kbhit(void)
{
	MSG msg;

	while(PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
		if (!lookevent(&msg))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}

	return(keybufnbr);
}


int keyhit(void)
{
	int r;

	r=buthit();
	if (!r) r=kbhit();
	return(r);
}



void confirm(void)
{
	MSG msg;

	empty();
	while(!buthit())
	{
		if (GetMessage(&msg, NULL, 0, 0))
            if (!lookevent(&msg))
			{
				TranslateMessage(&msg);
				DispatchMessage(&msg);
			}
	}
}













/***************************************************************/
/* gestion de blocs graphiques */


typedef struct
{
	int lx;
	int ly;
	int id;
	HBITMAP bloc;
	HBITMAP mask;
}
pixbloc;



void initbloc(void **blocptr)
{
	pixbloc *bloc;
	*blocptr=memalloc((long)sizeof(pixbloc));
	bloc=(pixbloc *)*blocptr;
	if (*blocptr) bloc->id=0;
}


void freebloc(void **blocptr)
{
	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;
		if (bloc->id) DeleteObject(bloc->bloc);
		if (bloc->id==2) DeleteObject(bloc->mask);
		bloc->id=0;
		memfree(blocptr);
	}
}



void getbloc(void **blocptr,int x,int y,int lx,int ly)
{
	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;
		if ((!bloc->id)||(bloc->lx!=lx)||(bloc->ly!=ly))
		{
			if (bloc->id) DeleteObject(bloc->bloc);
			if (bloc->id==2) DeleteObject(bloc->mask);
			bloc->id=0;
	    	hdc=GetDC(window);
			bloc->bloc=CreateCompatibleBitmap(hdc,lx*RATIO,ly*RATIO);
			ReleaseDC(window,hdc);
			if (bloc->bloc)
			{
				bloc->id=1;
				bloc->lx=lx;
				bloc->ly=ly;
			}
		}

		if (bloc->id)
		{
			SelectObject(hdcm2,bloc->bloc);
			BitBlt(hdcm2,0,0,lx*RATIO,ly*RATIO,hdcm,x*RATIO,y*RATIO,SRCCOPY);
			SelectObject(hdcm2,hcharbm);
        }

	}
}


void copybloc(void **blocptrs,int xs,int ys,int lxs,int lys,void **blocptrd,int xd,int yd)
{
	pixbloc *blocs;
	pixbloc *blocd;
	if ((*blocptrs)&&(*blocptrd))
	{
		blocs=(pixbloc *)*blocptrs;
		blocd=(pixbloc *)*blocptrd;
		if ((blocs->id)&&(blocd->id))
		if ((xd>=0)&&(yd>=0)&&(xs>=0)&&(ys>=0))
		if ((xs+lxs<=blocs->lx)&&(ys+lys<=blocs->ly))
		if ((xd+lxs<=blocd->lx)&&(yd+lys<=blocd->ly))
		if (blocd!=blocs)
		{

			SelectObject(hdcm,blocs->bloc);
            SelectObject(hdcm2,blocd->bloc);
            BitBlt(hdcm2,xd*RATIO,yd*RATIO,lxs*RATIO,lys*RATIO,hdcm,xs*RATIO,ys*RATIO,SRCCOPY);

			if ((blocs->id==2)&&(blocd->id==2))
			{
				SelectObject(hdcm,blocs->mask);
				SelectObject(hdcm2,blocd->mask);
            	BitBlt(hdcm2,xd*RATIO,yd*RATIO,lxs*RATIO,lys*RATIO,hdcm,xs*RATIO,ys*RATIO,SRCCOPY);
			}

			SelectObject(hdcm2,hcharbm);
			SelectObject(hdcm,hecran[ecran_travail]);

		}
		else
		{

            SelectObject(hdcm2,blocd->bloc);
			BitBlt(hdcm2,xd*RATIO,yd*RATIO,lxs*RATIO,lys*RATIO,hdcm2,xs*RATIO,ys*RATIO,SRCCOPY);

			if (blocd->id==2)
			{
				SelectObject(hdcm2,blocd->mask);
            	BitBlt(hdcm2,xd*RATIO,yd*RATIO,lxs*RATIO,lys*RATIO,hdcm2,xs*RATIO,ys*RATIO,SRCCOPY);
			}

			SelectObject(hdcm2,hcharbm);
		}
	}
}



void putpbloc(void **blocptr,int x,int y,int xs,int ys,int lxs,int lys)
{
	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;

		if ((y>=0)||(y+lys<=200))
		{
			if (y<0)
			{
				ys+=(-y);
				lys-=(-y);
				y=0;
			}
			else
			if (y+lys>200)
			{
				lys=200-y;
			}
		}
		if (lys>0)
		if ((x>=0)&&(y>=0)&&(xs>=0)&&(ys>=0))
		if ((x<320)&&(y<200))
		if ((x+lxs<=320)&&(y+lys<=200))
		if (bloc->id==1)
		{
			SelectObject(hdcm2,bloc->bloc);
            BitBlt(hdcm,x*RATIO,y*RATIO,lxs*RATIO,lys*RATIO,hdcm2,xs*RATIO,ys*RATIO,SRCCOPY);
			SelectObject(hdcm2,hcharbm);
		}
		else
		if (bloc->id==2)
		{
			SelectObject(hdcm2,bloc->mask);
			BitBlt(hdcm,x*RATIO,y*RATIO,lxs*RATIO,lys*RATIO,hdcm2,xs*RATIO,ys*RATIO,SRCAND);
			SelectObject(hdcm2,bloc->bloc);
			BitBlt(hdcm,x*RATIO,y*RATIO,lxs*RATIO,lys*RATIO,hdcm2,xs*RATIO,ys*RATIO,SRCPAINT);
			SelectObject(hdcm2,hcharbm);
		}
	}
}


void putbloc(void **blocptr,int x,int y)
{
	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;
		putpbloc(blocptr,x,y,0,0,bloc->lx,bloc->ly);
	}
}



void getmask(void **blocptr,int x,int y)
{
	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;
		if (bloc->id)
		{
			if (bloc->id==2)
			{
				DeleteObject(bloc->mask);
				bloc->id=1;
			}
			if (bloc->id==1)
			{
		    	hdc=GetDC(window);
				bloc->mask=CreateCompatibleBitmap(hdc,bloc->lx*RATIO,bloc->ly*RATIO);
				ReleaseDC(window,hdc);
				if (bloc->mask) bloc->id=2;
			}

			if (bloc->id==2)
	        {
				SelectObject(hdcm2,bloc->mask);
				BitBlt(hdcm2,0,0,bloc->lx*RATIO,bloc->ly*RATIO,hdcm,x*RATIO,y*RATIO,NOTSRCCOPY);
				SelectObject(hdcm2,hcharbm);
			}
		}
	}
}












/*****************************************************************/
/* instructions de gestion de fonte */



void affchar(int x,int y,char c)
{
	unsigned int n;

	if ((c>31)&&(c<127))
	{
		if (c>95) c-=32;

		n=c-32;

		SetBkColor(hdcm,couleur(MASK));
		SetBitmapBits(hcharbm,16,&sysfonte[n*16]);
		StretchBlt(hdcm,x*RATIO,y*RATIO,8*RATIO,8*RATIO,hdcm2,0,0,8,8,SRCAND);

		SetBkColor(hdcm,color);
		SetBitmapBits(hcharbm,16,&sysfonte[n*16+8]);
		StretchBlt(hdcm,x*RATIO,y*RATIO,8*RATIO,8*RATIO,hdcm2,0,0,8,8,SRCPAINT);
	}

}



void afftext(int x,int y,char *s)
{
	while(*s)
	{
		affchar(x,y,*s++);
		x+=8;
		if (x>312) { x=0; y+=8; if (y>192) y=0; }
	}
}


void printchar(char c)
{
	void *ecr;
    int t;

	while(ycur>192)
	{
		ycur-=8;
		initbloc(&ecr);
		getbloc(&ecr,0,8,320,192);
		putbloc(&ecr,0,0);
		freebloc(&ecr);
		t=nocolor;
		pbox(0,192,320,8,0);
		setcolor(t);
	}


	if (c==10) xcur= -8;
	else
	if (c==13) { ycur+=8; xcur= -8; }
	else
	affchar(xcur,ycur,c);

	xcur+=8;
	if (xcur>312) { xcur=0; ycur+=8; }


}


void print(char *s)
{
	while(*s) printchar(*s++);

	xcur=0;
	ycur+=8;
}















/*******************************************************************/
/* gestion des samples */



void playsample(void *adr,long len,long freq)
{
    stopsample();

	pcmwf.wf.wFormatTag=WAVE_FORMAT_PCM;
	pcmwf.wf.nChannels=1;
	pcmwf.wf.nSamplesPerSec=freq;
	pcmwf.wf.nAvgBytesPerSec=freq;
	pcmwf.wf.nBlockAlign=1;
	pcmwf.wBitsPerSample=8;

	whdr.lpData=adr;
	whdr.dwBufferLength=len;
	whdr.dwBytesRecorded=NULL;
	whdr.dwUser=NULL;
	whdr.dwFlags=WHDR_PREPARED;
	whdr.dwLoops=1;
	whdr.lpNext=NULL;
	whdr.reserved=NULL;

	nosound=waveOutOpen(&hwo,WAVE_MAPPER,&pcmwf,NULL,NULL,NULL);

	if (!nosound)
		waveOutWrite(hwo,&whdr,sizeof(WAVEHDR));
}



void stopsample()
{
	if (!nosound)
	{
		waveOutReset(hwo);
		waveOutClose(hwo);
		nosound=1;
	}
}


void fixsample(void *adr,long len)
{
	long i;
	char huge *ptr;
	WAVEHDR wh;

	ptr=(char huge *)adr;
	for(i=0L;i<len;i++) *(ptr++)-=128;

	wh.lpData=adr;
	wh.dwBufferLength=len;
	wh.dwBytesRecorded=NULL;
	wh.dwUser=NULL;
	wh.dwFlags=NULL;
	wh.dwLoops=1;
	wh.lpNext=NULL;
	wh.reserved=NULL;

	if (nosound)
	{
		pcmwf.wf.wFormatTag=WAVE_FORMAT_PCM;
		pcmwf.wf.nChannels=1;
		pcmwf.wf.nSamplesPerSec=11025L;
		pcmwf.wf.nAvgBytesPerSec=11025L;
		pcmwf.wf.nBlockAlign=1;
		pcmwf.wBitsPerSample=8;
		nosound=waveOutOpen(&hwo,WAVE_MAPPER,&pcmwf,NULL,NULL,NULL);
		if (!nosound)
			waveOutPrepareHeader(hwo,&wh,sizeof(WAVEHDR));
		waveOutReset(hwo);
		waveOutClose(hwo);
		nosound=1;
	}
	else
		waveOutPrepareHeader(hwo,&wh,sizeof(WAVEHDR));
}







