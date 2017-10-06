/*
	Beispiel fÅr die Benutzung der Funktionen 'AvailableDrivers'
	und 'DriverInfo' unter MAGIC.
	
	Das Programm klappert alle GDOS-Devices ab und gibt bei den
	existierenden den Namen aus.

	Orginalversion in Pure Pascal von Peter Hellinger.
	Portierung nach C von Dirk Stadler.
*/	
	
#include <magic.h>
#include <stdio.h>

char DevName[][10] =
               { "Screen  ",  /* Device-Nummer  1..10 */
                 "Plotter ",  /*               11..20 */
                 "Printer ",  /*               21..30 */
                 "Metafile",  /*               31..40 */
                 "Camera  ",  /*               41..50 */
                 "Tablett ",  /*               51..60 */
                 "Memory  ",  /*               61..70 */
                 "dev71_80",  /*               71..80 */
                 "dev81_90",  /*               81..90 */
                 "dev91_99"}; /*               91..99 */

void main()
{
	int i, j;
    WORKSTATION ws;
    Device dev;
    
	ApplInit();
	
	/* MAGIC-Meldung bei Programmende aus */
	Appl->MAGICParaBlk->IntIn[0] = 1;
	CallMagic(98);
	
	/* Devices abklappern */
	for (dev = Plotter; dev <= dev91_99; dev++) {
  		i = AvailableDrivers(dev);
  		if (i > 0) {
   			for (j = 1; j <= i; j++) {
    			DriverInfo(dev, j, &ws);
    			printf("Driver for %s -> %s Id: %d\n\r", DevName[dev], ws.Name, ws.Handle);
   			}
   		}
  		else
   			printf ("No Driver for %s\n\r", DevName[dev]);
 	}
 	
 	/* und tschuess... */
 	ApplTerm(0);
} /* main */