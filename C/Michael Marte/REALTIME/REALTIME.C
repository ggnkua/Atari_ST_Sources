/*
REALTIME
Utility fÅr Bandaufnahmen
v1.00 vom 03.10.1990
v2.00 vom 05.10.1990
v2.01 vom 20.10.1990
v2.02 vom 12.12.1991
von Michael Marte
(c) 1992 MAXON Computer
*/


#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <ext.h>


/* Typendefinitionen */

typedef struct Machine MACHINE;
typedef struct Tape TAPE;


/* Strukturdefinitionen */

struct Machine{
   char *name;

   float twd;
   /* Wickelkerndurchmesser in cm */

   float tv;
   /* Bandgeschwindigkeit in cm/s */

   float nrpcu;
   /* Laufwerk-ZÑhler-öbersetzungsverhÑltnis */

};


struct Tape{
   char *name;

   float td;
   /* BandstÑrke in cm */

};


/* Variablen- und Konstantendefinitionen */

MACHINE machine[]={
   {"Technics RS-B505",2.2,4.8,2}
};


TAPE tape[]={
   {"BASF LH-EI 90",1.2981E-3},
   {"BASF CR-E II 90",1.2361E-3},
   {"FUJI JP-II 60",1.6564E-3},
   {"FUJI DR 90",1.2570E-3},
   {"MAXELL XL II-S 60",1.7359E-3},
   {"SONY HF 90",1.2372E-3},
   {"SONY UX-S 90a",1.2809E-3},
   {"SONY UX-S 90c",1.2700E-3},
   {"SONY UX-S 60c",1.7800E-3},
   {"TDK SA 90",1.1818E-3},
   {"TDK SA 90N",1.2302E-3},
   {"TDK SA 100",1.1391E-3},
   {"TDK SA-X 90",1.2404E-3},
   {"TDK D 90",1.2404E-3},
   {"THAT'S VX 90",1.1785E-3}
};


const float pi=3.141592654;

const int nm=(int)(sizeof(machine)/sizeof(MACHINE));
/* Anzahl d. def. GerÑte */

const int nt=(int)(sizeof(tape)/sizeof(TAPE));
/* Anzahl d. def. BÑnder */

int miu=0;
/* aktuelles GerÑt */

int tiu=0;
/* aktuelles Band */


/* Prototypen */

void convert_counter(void);
void compute_interval(void);
void select_tape(void);
void select_machine(void);


float realtime(float c){
   float nr=c*machine[miu].nrpcu;
   return (pi*nr*(tape[tiu].td*(nr-1)
           +machine[miu].twd))/machine[miu].tv;
}


main(){
   int choice;
   
   do{
      do{
         printf("\x1b\x45"
                "REALTIME\n"
                "Utility fÅr Bandaufnahmen\n"
                "v2.02 vom 12.12.1991\n"
                "(c)1990 by Michael Marte\n\n"
                "1. ZÑhlerstand umrechnen\n"
                "2. Intervall berechnen\n"
                "3. Band wÑhlen (%s)\n"
                "4. GerÑt wÑhlen (%s)\n"
                "5. Ende\n\n"
                "Bitte wÑhlen Sie : ",
                tape[tiu].name,machine[miu].name);
         scanf("%d",&choice);
      }while(choice<1 || choice>5); 
      printf("\x1b\x45");

      switch(choice){
         case 1:convert_counter();break;
         case 2:compute_interval();break;
         case 3:select_tape();break;
         case 4:select_machine();break;
      }
   }while(choice!=5);

   return 0;
}


void convert_counter(){
   int t;
   float c;

   printf("ZÑhlerstand relativ zum Bandbeginn : ");
   scanf("%f",&c);
   t=(int)realtime(c);
   printf("entspricht %d min %d sec\n",t/60,t%60);

   printf("\n<Taste>\n");(void)getch();
}


void compute_interval(){
   int t1,t2,t;
   float c;

   printf("ZÑhlerstand am Intervallanfang : ");
   scanf("%f",&c);
   t1=(int)realtime(c);
   printf("entspricht %d min %d sec\n",t1/60,t1%60);

   printf("ZÑhlerstand am Intervallende : ");
   scanf("%f",&c);
   t2=(int)realtime(c);
   printf("entspricht %d min %d sec\n",t2/60,t2%60);

   t=t2-t1;
   printf("Das Intervall hat eine LÑnge von "
          "%d min %d sec.\n",t/60,t%60);

   printf("\n<Taste>\n");(void)getch();
}


void select_tape(){
   int cnt;

   /* Definierte BÑnder ausgeben */
   for(cnt=0;cnt<nt;cnt++)
      printf("%d. %s  td=%f mm\n",
             cnt,tape[cnt].name,tape[cnt].td*10);

   /* Band wÑhlen */
   do{
      printf("\nVerwendetes Band : ");
      scanf("%d",&tiu);
   }while(tiu<0 || tiu>nt-1);

}


void select_machine(){
   int cnt;

   /* Definierte GerÑte ausgeben */
   for(cnt=0;cnt<nm;cnt++)
      printf("%d. %s  twd=%.2f cm  tv=%.2f cm/s  "
             "nrpcu=%.2f r/Einheit\n",
             cnt,machine[cnt].name,machine[cnt].twd,
             machine[cnt].tv,machine[cnt].nrpcu);

   /* GerÑt wÑhlen */
   do{
      printf("\nVerwendetes GerÑt : ");
      scanf("%d",&miu);
   }while(miu<0 || miu>nm-1);

}
