/* GETBPB.C : Liest BIOS-Parameterblock ein & analysiert ihn
   (C) 1990 by Claus Brod
   TC 2.0
   Aus dem SCHEIBENKLEISTER, dem etwas anderen Floppybuch
*/
#include <tos.h>
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>

#define OUT(s)  Cconws(s)
#define OUTDINT(i)  OUT(itoa(i, buf, 10))
#define OUTHINT(i)  OUT(itoa(i, buf, 16))

/* leicht erweiterte Definition eines BPB */
typedef struct {
	int bps;
	int clsize;
	int clsizeb;
	int dirsize;
	int fatsize;
	int fatrec;
	int datrec;
	int numcl;
	int bflags;
	int tracks;		/* ab hier gilt das nur fÅr */
	int sides;		/* die Laufwerke A und B - eine */
	int spdt;		/* undokumentierte Eigenschaft des */
	int spt;			/* BIOS. */
	int hid;
	unsigned char no[3];
   } MYBPB;

int main(void);

main()
{
	MYBPB *pnt;
	int drive;
	char drvstr[] = "A:\\";
   char buf[10];;
   
   OUT("\n\rDiskinfo    by Claus Brod 1987");
	OUT("\n\rAus SCHEIBENKLEISTER, dem etwas anderen Floppybuch");
	OUT("\n\rLaufwerk (A, B...)? ");
	do
		drive = toupper((int)Cconin())-'A';
	while ( (drive<0) || (drive>15) );
	 
	drvstr[0]=drive+'A';		/* damit GEMDOS keinen Wechsel */
	Fsfirst(drvstr, 0);		/* verpaût */
		  
	if ( (pnt=(MYBPB *)Getbpb(drive)) >0 ) {
		OUT("\n\rBytes pro Sektor    :");
		OUTDINT(pnt->bps);
		
		OUT("\n\rClustergroesse      :");
		OUTDINT(pnt->clsize);
		OUT("\n\r      in Bytes      :");
		OUTDINT(pnt->clsizeb);
		OUT("\n\rDirectorylaenge     :");
		OUTDINT(pnt->dirsize);
		OUT("\n\rFAT-Groesse         :");
		OUTDINT(pnt->fatsize);
		OUT("\n\rAnfang der 2. FAT   :");
		OUTDINT(pnt->fatrec);
		OUT("\n\rErster Datensektor  :");
		OUTDINT(pnt->datrec);
		OUT("\n\rAnzahl der Cluster  :");
		OUTDINT(pnt->numcl);
		OUT("\n\rBFLAGS              :");
		OUTDINT(pnt->bflags);
		if (drive<2)
		{
			OUT("\n\rSpuren              :");
			OUTDINT(pnt->tracks);
			OUT("\n\rSeiten              :");
			OUTDINT(pnt->sides);
			OUT("\n\rSektoren/Spur       :");
			OUTDINT(pnt->spdt);
			OUT("\n\rSektoren/Spur/Seite :");
			OUTDINT(pnt->spt);
			OUT("\n\rVersteckte Sektoren :");
			OUTDINT(pnt->hid);
			OUT("\n\rSeriennummer        :");
			OUTHINT(pnt->no[0]); OUTHINT(pnt->no[1]); OUTHINT(pnt->no[3]);
		}
	}
	else OUT("\n\nFehler!");
   
	Cnecin();
	return 0;
}
