/* The Voice II by Team From The East */
/* Turbo C Tutorial */

/* kilka operacji graficznych w Turbo C */
/* Program w Turbo C */

#include<graphics.h> 	/* dolacz bibloteke dla grafiki */

main()					/* program tu */
{
int drv,mod;			/* deklaruj zmienne drv i mod */
drv=DETECT;				/* DETECT to stala oznajmiajaca, ze */
						/* drv (czyli driver grafiki) bedzie automatycznie */
						/* dobrany */	
mod=STLOW;

initgraph(&drv,&mod,"");/* tu deklarujemy chec pracy w trybie graficznym */
					
line (0,0,100,100);		/* przykladowe instrukcje graficzne */
						/* kresl linie od punktu 0,0 do 100,100 */
circle (100,100,20);	/* kresl kolo w punkcjie 0,0 i promieniu 20 punktow */
putpixel (200,100,1);	/* punkt 200,100 o kolorze 1 */
bar (0,0,10,10);		/* wypelniony kwadrat */
 /* setgraphmode(nr_trybu) ustawianie rozdzielczosci
 0 - dla niskiej rozdzielczosci
 1 - sredniej
 2 - wysokiej */
 
closegraph();			/* zamknij operacje graficzne */ 
return(0);				/* oddaj zero */
}						/* koniec */

