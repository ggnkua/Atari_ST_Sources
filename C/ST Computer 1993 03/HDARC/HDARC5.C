#include <types.h>
#include <osbind.h>
#include <stat.h>
#include <stdio.h>
#include <string.h>
#include <aes.h>
#include <dos.h>

#define PATHSEP	'\\'

char *buffer;
char ofeld[50][20];
int i = 0;
int k = 0;
long count;
int ar1 = 0;
int ar2 = 0;


																									/* Pfadstruktur erweitern */

void struerw(char *pfad,
			 char datei[14])
{
	char *cp;
	char mdir[200];
	long error;
	char file[30] = "                             ";
	strcpy (mdir,pfad);
	strcpy (file,datei);			

																									/* Wenn ein neuer Ordner gefunden wird */	
																									/* dann wird er in ofeld abgelegt      */

	strcpy (ofeld[++i],datei);		
	cp = strrchr(mdir, (int)(PATHSEP));
	strcpy (++cp,strcat (file,"\\*.*"));
	suchen(mdir);																		/* Rekursion: In diesem Pfad weitersuchen */
	if(k == i)
	{
																									/* Nach RÅckkehr eine Ordnerebene zurÅck  */
		error = Dsetdrv(0);
		error = Dsetpath("..\0");	
		k--;	
	}
	i--;
	if(i<k)
		k=i;
}


																									/* Untersucht auf Notwendigkeit zu sichern  */

void bitcheck(int attr,
			  char *dir,
			  char *name,
			  long size)
{
	int z;
																									/* Wenn Bit 5 gesetzt ist, ist das Archivbit gesetzt;*/
																									/* d.h. die Datei ist nicht archiviert				 */
	
	if(((attr & 32) == 32) || (ar1 == 1))		/* Bit 5 ? */
	{
		for(z=(k+1);z<=i;z++)
		{
			Dsetdrv(0);
			if(Dsetpath(ofeld[z]) != 0)
			{
				printf("\nPfad %s wird angelegt\n",ofeld[z]);
				Dcreate(ofeld[z]);
				Dsetpath(ofeld[z]);
			}
		}
		k = i;
		arbeiten(dir,name,attr,size);
	}
}



																									/* Hier wird der mit dir Åbergebene Pfad nach Dateien */
																									/* und weiteren Ordnern durchsucht				   */

void suchen(char *dir)
{
	DMABUFFER dumb;
	Fsetdta(&dumb);
	
																									/* Normale Dateien suchen */
	
	if(Fsfirst(dir, 0) == 0)
	{
		bitcheck((int)dumb.d_fattr, dir,
				 dumb.d_fname, dumb.d_fsize);
		while(Fsnext() == 0)
			bitcheck((int)dumb.d_fattr, dir,
					 dumb.d_fname, dumb.d_fsize);
	}
	
																									/* Keine weiteren Dateien in diesem Pfad. Deshalb Ordner suchen */
																									/* Dabei ist Bit 4 = 16 Ordnerattribut und '.' RÅckkehrordner	*/
	
	if(Fsfirst(dir,16) == 0)
		if((dumb.d_fattr == 16) && (dumb.d_fname[0] != '.')) 
			struerw(dir,dumb.d_fname);
		while(Fsnext() == 0)
			if((dumb.d_fattr == 16) && (dumb.d_fname[0] != '.')) 
					struerw(dir,dumb.d_fname);
}



																									/* Bei voller Diskette wird das unvollstÑndige File gelîscht */
																									/* und nach Diskettenwechsel ein neuer Pfad aufgebaut 	 */

void diskchange(long inhand,
				long outhand,
				char *neuname,
				char *cp2,
				char *pfad,
				char *cp,
				char *name,
				int type,
				long status)
{
	Fclose((short)inhand);
	Fclose((short)outhand);
	printf("\033EDatei %s lîschen\n",neuname);
	Fdelete(neuname);
	printf("\nDiskette wechseln\n");
	Cconin();
	Dsetdrv(0);
	strcpy (cp2,&pfad[3]);
	while (cp = strchr(cp2,(int)(PATHSEP)))
	{
		*cp++ = '\0';
		Dcreate(cp2);
		Dsetpath(cp2);
		cp2 = cp;
	}
	inhand = Fopen(name,0);
	printf("\033E\n%s\n",name);
	outhand = Fcreate(neuname,type);
	status = 0L;
}


																									/* Zeigt Fehlermeldung und terminiert Programm */

void fehler (short inhand,
			 short outhand)
{
	printf("\nFehler bei Lesen oder Schreiben\n");
	Cconin();
	Fclose((short)inhand);
	Fclose((short)outhand);
	Mfree(buffer);
	appl_exit();
	Pterm(1);
}


																									/* Sichern einer Datei auf Diskette im vorher angelegten Ordner */

void arbeiten (char *pfad,
			   char *datei,
			   int type,
			   long menge)
{
	long inhand, outhand;
	long status;
	int res = 1;
	char *cp;
	char name[200], neuname[200];
	char neupfad[200];
	char *cp2 = neupfad;
	strcpy(name,pfad);
	cp = strrchr(name, (int)(PATHSEP));
	strcpy(++cp,datei);
	printf("\nKopiere  %s\n",name);
	strcpy (neuname, name);
	neuname[0] = 'A';
	if((outhand = Fopen(neuname,(short)(0))) > 0L)
	{
		res = form_alert(1,"[1][File existiert auf Disk| |    öberschreiben ?][ja|nein]");
		Fclose((short)outhand);
	}
	if(res == 1)																		/* res ist mit 1 initialisiert */
	{	
		inhand = Fopen(name,(short)(0));
		outhand = Fcreate(neuname,type);							/* Datei erzeugen */
		while(menge > count)
		{
																									/* Datei lesen */
			if(Fread((short)inhand,count,buffer) < 0)	
				fehler((short)inhand, (short)outhand);
																									/* Datei schreiben */
			if((status = Fwrite((short)outhand,count,buffer)) < 0)	
				fehler((short)inhand, (short)outhand);
			if(status != count)
				diskchange(inhand, outhand, neuname, cp2,
						   pfad, cp, name, type, status); 
			menge -= status;														/* ... notfalls auch mehrmals */
		}
		while(menge > 0)															/* Noch Reste ? */
		{
																									/* Rest lesen */
			if(Fread((short)inhand,menge,buffer) < 0)
				fehler((short)inhand, (short)outhand);
																									/* Rest schreiben */
			if((status = Fwrite((short)outhand,menge,buffer)) < 0)	
				fehler((short)inhand, (short)outhand);
			if(status != menge)
				diskchange(inhand, outhand, neuname, cp2, pfad,
						   cp, name, type, status);
			menge -= status;
		}
		Fclose((short)inhand);												/* Handles freigeben */
		Fclose((short)outhand);
		if (ar2 == 0)																	/* Bit 5 (Archiv) lîschen */
			Fattrib(name,(short)1,(short)(type & 31));
	}	
}


void zerlege(char *pfbez)												/* Das ofeld muû befÅllt werden, */
{																								/* dazu muû der Pfad zerlegt werden */
	char *cp1, *cp2;																
	char alerttxt[200] = "[2][Diskette fÅr die Sicherung |    des nÑchsten Pfades |          eingelegt ? ][OK]";																										

																								/* Ersten Pfadsep. suchen */
	printf("\033E\n\n\nDer nÑchste Pfad ist \n%s\n",pfbez);																							
	cp1 = strchr(pfbez,(int)(PATHSEP));
	do
	{
																								/* Zweiter Pfadsep. */
		cp2 = strchr(++cp1,(int)(PATHSEP));
		if (cp2)																		/* Falls Suche erfolglos -> cp2 == 0 */
		{
			*cp2 = '\0';															/* KÅnstliches Stringende */
			strcpy(ofeld[++i],cp1);
			*cp2 = PATHSEP;														/* Wieder Normalzustand */
																								/* Altes Ende ist neuer Anfang fÅr Suche */
			cp1 = cp2;			
		}
	} while(cp2);
	form_alert(1,alerttxt);
	Dsetdrv(0);
	Dsetpath("\\");																/* GEMDOS ins Wurzelverzeichnis von A setzen */
	suchen(pfbez);
}


void anfrage(void)															/* Handling des Archivbits abfragen */
{
	int res;
	res = form_alert(1,"[2][Soll das Archivbit|     beachtet|     werden ?][ja|nein]");
	if (res == 2)
		ar1 = 1; 
	res = form_alert(1,"[2][Soll das Archivbit|    verÑndert|    werden ?][ja|nein]");
	if (res == 2)
		ar2 = 1;
} 

void zende(char info[])
{
	char *cp1, *cp2;
	char pfbez[FMSIZE] = "";												/* In dos.h FMSIZE = 128 */
	cp1 = info;
	do
	{
		cp2 = strchr(cp1,0x0D);												/* Zeilenende suchen */
		*cp2 = '\0';
		strcpy(pfbez,cp1);
		++cp2;
		cp1 = ++cp2;
		zerlege(pfbez);
	} while (strchr(cp1,'\\'));
}
																									

void auswahl(void)																/* Der Nutzer kann hier den Start-Pfad eingeben */
{
	long fhandle;
	char *cp1;
	char info[1000] = "";														/* Nimmt das Hdarc.inf auf */
	char pfbez[FMSIZE] = "C:\\*.*";									/* In dos.h FMSIZE = 128 */
	char file[FNSIZE] = "";													/* und FNSIZE = 13       */
	char label[20]="Bitte Pfad wÑhlen";
	short button;
	int res;

	anfrage(); 

	if((fhandle = Fopen("HDARCA.INF",(short)(0))) > 0)
	{
																									/* Autostart-Automatik-File vorhanden */		
		Fread((short)(fhandle),1000L,info);
		Fclose((short)(fhandle));
		zende (info);
	}
	else
	{		
		res = fsel_exinput(pfbez, file, &button, label);
		if(button)																		/* Benutzer wÑhlte einen Pfad */
		{
			if(!strcmp(file,"HDARC.INF"))	 							/* Automatik-File gewÑhlt */ 
			{ 
				cp1 = strrchr(pfbez,(int)(PATHSEP));
				strcpy(++cp1,file);
				if((fhandle = Fopen(pfbez,(short)(0))) <= 0)
				{
					printf("\nFehler beim ôffnen von HDARC.INF\n");
					Cconin();
					Mfree(buffer);
					appl_exit();
					Pterm(1);
				}
				Fread((short)(fhandle),1000L,info);
				Fclose((short)(fhandle));
				zende (info);			
			}
			else
				zerlege (pfbez);
		}
	}
}



void diskwechs(void)
{
	DMABUFFER dumb;																	/* Die nÑchsten Zeilen zwingen zum Erkennen eines Medienwechsels */
	Fsetdta(&dumb);
	Fsfirst("A:\\*.*", 16);
}



void main(void)
{
	appl_init();
	buffer = (char *)Malloc(count=((long)Malloc(-1L)-8000L));
	diskwechs();
	auswahl();
	Mfree(buffer);
	appl_exit();
}

