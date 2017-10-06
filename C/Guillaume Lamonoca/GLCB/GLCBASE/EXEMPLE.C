/* exemple.c :programme de test des modules de base
Guillaume LAMONOCA
supelec (94)

Compiler puis faites une edition de lien avec le module de base
correspondant a votre machine (instructions dans le source du module de base)
x11.c		Xwindows pour station VMS,Unix,OpenVMS,OSF1,SunOS,etc...
x11local.c	Idem mais strategie d'affichage differente.Voir entete.
mac.c		macintosh
atari.c		st,ste,falcon,tt (laser C)
ataripur.c	st,ste,falcon,tt (Pure C)
+ataripu2.s
falcon.c	falcon (Pure C)
+falcon2.s
falcontc.c	falcon (Pure C)
+falcont2.s
amiga500.c	amiga 500/2000 (aztec C)
amiga.c		amiga (tous modeles) (lattice C)
amiga.lha	amiga (tous modeles) (Version amelioree "portable")
pc.c		pc (Windows 3.1 et MultiMedia) (BC++ ou TC++)
pcvga.c		pc (MsDos et carte VGA 256ko) (TC ou TC++)
+pcvga2.asm
*/


#include "header.h"  /* header unique pour tous les modules de base */

/* dans header.h, definissez EXTENSION pour x11,pcvga et falcon */

/* a definir pour tester falcontc.c */
/*
#define TRUECOLOR
*/

#ifdef TRUECOLOR
void testtruecolors()
{
	int i,j;

	doublescreen();


	cls();
	swap();
	cls();

	setcolor(15);
	print("test true color.(clicker)");

	for(i=0;i<32;i++)
		for(j=0;j<64;j++)
		{
			settruecolor((i<<11)+(j<<5)+(31-i));
			pbox(32+j*4,20+i*5,4,5,-1);
		}
		
	swap();
	confirm();
	empty();

}
#endif


#ifdef EXTENSION

unsigned int superpalette[3*256];

void test256colors()
{
	int i,j;

	doublescreen();


	cls();
	swap();
	cls();

	setcolor(15);
	print("test palette etendue.(patience)");
	swap();

	for(i=0;i<16;i++)
		for(j=0;j<16;j++)
		{
			superpalette[3*(i*16+j)]=i*4369;
			superpalette[3*(i*16+j)+1]=j*4369;
			superpalette[3*(i*16+j)+2]=(15-i)*4369;
		}

	setbigpalette(0,256,superpalette);

	cls();
	swap();
	cls();

	setcolor(255);
	print("test palette etendue.(clicker)");

	for(i=0;i<16;i++)
		for(j=0;j<16;j++)
			pbox(32+j*16,20+i*10,16,10,i*16+j);
	
	swap();
	confirm();
	empty();

}

#endif



void testgraphisme()
{
	int i;

	doublescreen();

	cls();
	swap();
	cls();

	setcolor(15);
	print("test graphisme.(clicker)");

	pbox(160,80,50,30,5);
	pbox(170,90,10,10,FOND);
	pbox(190,90,10,10,MASK);
	for(i=0;i<16;i++) pbox(i*16,150,16,16,i);
	for(i=0;i<16;i++) dbox(i*16,166,16,16,i);
	for(i=0;i<16;i++) vline(i,32,48,i);
	for(i=0;i<16;i++) hline(0,48+i,16,i);
	for(i=0;i<16;i++) dline(i,64,i+15,79,i);
	for(i=0;i<16;i++) dline(15-i,95,30-i,80,i);
	pellipse(80,50,40,30,15);
	pellipse(140,40,25,25,2);

	setcolor(2);
	afftext(250,20,"texte");
	setcolor(4);
	afftext(253,23,"texte");
	
	swap();
	confirm();
	empty();

}




double dpoly[10]={-50.0,-50.0,50.0,-50.0,50.0,50.0,-50.0,50.0,-50.0,-50.0};

void testanimation()
{
	int i;
	int an=1;
	int poly[10];
	double x,y,xx,yy;
	double ca,sa;

	setcolor(15);
	ca=cs[an]/16384.0;
	sa=sn[an]/16384.0;

	doublescreen();

	do
	{

		cls();


		for(i=0;i<5;i++)
		{
			x=dpoly[i*2];
			y=dpoly[i*2+1];
			xx=x*ca-y*sa;
			yy=x*sa+y*ca;
			dpoly[i*2]=xx;
			dpoly[i*2+1]=yy;
		}


		for(i=0;i<5;i++)
		{
			poly[i*2]=160+(int)dpoly[i*2];
			poly[i*2+1]=100+(int)dpoly[i*2+1];
		}

		polyfill(5,poly,-1);

		swap();

	} 
	while(getmouse()!=1);
}








void testsouris()
{
	char s[50];

	hide();
	simplescreen();

	cls();
	setcolor(15);
	print("test getmouse()");
	refresh();
	show();
	
	do
	{

		if (getmouse())
		{
			sprintf(s,"%d %d %d %x",msek,msex,msey,mclk);
			hide();
			print(s);
			show();
			refresh();
		}
		refresh();
	}
	while(!kbhit());
	empty();

}









void testsuivi()
{
	int x,y;

	doublescreen();

	cls();
	swap();
	cls();

	setcolor(15);
	print("suivi du deplacement souris");
	swap();
	copyscreen();

	do
	{
		x=mousex;
		y=mousey;
		plot(x,y,2);
		swap();
		plot(x,y,2);
	}
	while(getmouse()!=1); 

}









void testclavier()
{
	int c;
	char s[50];

	hide();
	simplescreen();

	cls();
	setcolor(15);
	print("test clavier");
	refresh();
	show();

	do
	{
		if (kbhit())
		{
			c=getch();
			sprintf(s,"%d %c %lu",c,c,systime());
			hide();
			print(s);
			show();
			refresh();
		}
		refresh();
	}
	while(getmouse()!=1);

}









void testkeymap()
{
	int i;

	doublescreen();

	cls();
	swap();
	cls();

	setcolor(15);
	print("test de keymap[]");
	print("(appuis simultanes)");
	swap();
	copyscreen();

	do
	{
		kbhit();
		for(i=0;i<128;i++)
        	if (keymap[i])
				plot(50+i,50,15);
			else
				plot(50+i,50,0);
            	
		swap();
	}
	while(getmouse()!=1);

}







void testblocs()
{
	int i,lx;
	void *sprite;
	void *fond;
	int x=0;
	int y=0;
	int ox=0;
	int oy=0;

	hide();
	doublescreen();


	initbloc(&fond);
	initbloc(&sprite);

	pbox(0,0,32,32,FOND);
	pbox(0,11,32,10,2);
	pbox(11,0,10,32,4);
	getbloc(&sprite,0,0,32,32);

	pbox(0,11,32,10,MASK);
	pbox(11,0,10,32,MASK);
	getmask(&sprite,0,0);
	
	cls();
	for(i=0;i<200;i++) hline(0,i,319,i&15);
	setcolor(15);
	print("test des blocs graphiques");
	getbloc(&fond,0,0,320,200);
	swap();
	copyscreen();

	do
	{
		x=mousex-16;
		y=mousey-16;
		putbloc(&sprite,x,y);
		swap();

		if (ox&15) lx=48; else lx=32;
		ox=ox&0xfff0;
		putpbloc(&fond,ox,oy,ox,oy,lx,32);

		if (mousek==2)
		copybloc(&sprite,0,1,32,31,&sprite,0,0);

		ox=x;
		oy=y;
	}
	while(getmouse()!=1);

	freebloc(&fond);
	freebloc(&sprite);

	show();

}







void testfonte()
{
	int i;

	hide();
	simplescreen();

	cls();
	for(i=0;i<60;i++) hline(0,i,319,i&15);
	setcolor(15);

	print("test de la fonte");
	for(i=32;i<128;i++) printchar(i);
	refresh();

	show();

	confirm();
	empty();

}







void testsample()
{
	char *adr;
	int i;

	hide();
	simplescreen();

	cls();
	setcolor(15);
	print("test des samples");
	refresh();
	empty();
	
	show();

	if (adr=(char *)memalloc(10000L))
	{
		for(i=0;i<10000;i++) adr[i]=128+sn[(i*16)&255]/256;
		fixsample(adr,10000L);
		playsample(adr,10000L,10000L); /* joue un son sinusoidal */

		confirm();

		stopsample();
		memfree((void **)&adr);
	}
}









int main()
{

	if (initsystem())
	{

		testgraphisme();
		testanimation();
		testsouris();
		testsuivi();
		testclavier();
		testkeymap();
		testblocs();
		testfonte();
		testsample();

#ifdef TRUECOLOR
		testtruecolors();
#endif

#ifdef EXTENSION
		test256colors();
#endif

		killsystem();
	}

	return 0;
}

 
