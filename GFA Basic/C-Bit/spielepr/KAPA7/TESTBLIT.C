/*
   Demoprogramm fÅr bitblit()

   geschrieben von Simon Gleissner 1993

   ACHTUNG: Dieses Programm lÑuft NUR unter der niedrigen ST-Auflîsung
   mit 320x200 Punken und 16 Farben
*/

#include <tos.h>
#include <ext.h>

/* alle Bitblit Modes */
typedef enum {BBM_SOLID,BBM_NAND,BBM_EOR} BitBlitMode;

/* Beschreibung von Start- und Zielbildschirm */
typedef struct
{
	void *source_ad;
	int source_off;
	void *dest_ad;
	int dest_off;
} Screens;

/* Beschreibung der Koordinaten */
typedef struct
{
	int source_x,source_y;
	int dest_x,dest_y;
	int width,height;
} Koord;



/* folgende Funktion ist in BITBLIT.S zu finden */
extern void bitblit(Screens *,Koord *,BitBlitMode);


int main()
{
	int i,roll,len,rez;
	char farbbalken[]="\xa\xd\x1b\x63\x00\x1bl";
	Screens sc;
	Koord ko;

	rez=Getrez();

	Setscreen((void*)-1L,(void*)-1L,0);

	/* Bildschirm vollmalen */

	Cconws("\x1b\x63\x0dGuten \x1b\x63\x02Tag, dies\x1b\x63\x01 ist\x1b\x63\x8 ein \x1b\x63\x04Testtext!");
	for(i=0;i<25;i++)
	{
		farbbalken[4]=(char)i;
		Cconws(farbbalken);
	}


	sc.source_ad=Physbase();
	sc.source_off=160;			/* NUR fÅr 320x200x16 */
	sc.dest_ad=Physbase();
	sc.dest_off=160;			/* NUR fÅr 320x200x16 */

	for(len=0;len<32;len++)
	{
		for(roll=0;roll<20;roll++)
		{
			for(i=0;i<=20;i++)
			{
				ko.source_x=roll;		/* RIESEN BLOCK */
				ko.source_y=1;
				ko.dest_x=8+i;
				ko.dest_y=10+9*i;
				ko.width=150+len;
				ko.height=8;
				bitblit(&sc,&ko,BBM_SOLID);

				ko.source_x=roll;		/* Mittlerer Block */
				ko.source_y=1;
				ko.dest_x=200+i;
				ko.dest_y=10+9*i;
				ko.width=16+len;
				ko.height=8;
				bitblit(&sc,&ko,BBM_SOLID);

				ko.source_x=roll;		/* kleiner block */
				ko.source_y=1;
				ko.dest_x=260+i;
				ko.dest_y=10+9*i;
				ko.width=len;
				ko.height=8;
				bitblit(&sc,&ko,BBM_SOLID);
			}
		}
	}

	getch();

	Setscreen((void*)-1L,(void*)-1L,rez);

	return(0);
}
