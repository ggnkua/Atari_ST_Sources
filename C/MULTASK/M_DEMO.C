
#define true 1
#define false 0

#define word short
#define byte char

long *screenbase(); /* Adresse des Bildschirmspeichers */

/*-------- Magisches Quadrat --------*/

#define groesse 7 /* muû ungerade Zahl sein ! */

struct magicstructur
        {
        byte feld[groesse][groesse];
        byte fertig_berechnet;
        } magic;

berechne_magic()
{
        word x,y,i,j,zahl;
        
        x=groesse>>1; y=groesse>>1; zahl=1;
        for (i=0; i<groesse; ++i)
                {
                for (j=0; j<groesse; ++j)
                        {
                        magic.feld[x][y]=zahl;
                        ++zahl;
                        ++x; --y;
                        if (x==groesse) x=0;
                        if (y<0) y=groesse-1;
                        }
                y+=2; if (y>=groesse) y-=groesse;
                --x; if (x<0) x=groesse-1;
                waittask();
                }
        magic.fertig_berechnet=true;
}

zeige_magisches_quadrat()
{
        word x,y,i,summe;
        
        printf("Magisches Quadrat : ");
        for (i=0; i<(groesse*3+2); ++i) printf("-");
        for (y=0; y<groesse; ++y)
                {
                printf("/n                    |");
                summe=0;
                for (x=0; x<groesse; ++x)
                        {
                        if (magic.feld[x][y]>9) printf(" %d",magic.feld[x][y]);
                        else printf("  %d",magic.feld[x][y]);
                        summe+=magic.feld[x][y];
                        }
                printf("| = %d",summe);
                }
        printf("/n                    ");
        for (i=0; i<(groesse*3+2); ++i) printf("-");
}

/*------ input - Stringeingabe Åber Tastatur ------*/

input(str)
byte *str;
{
        byte textbuffer[100];
        word i;
        
        textbuffer[0]=98;
        Cconrs(textbuffer);
        for (i=2; i<2+textbuffer[1]; ++i) *(str++)=textbuffer[i];
        *str=0;
}

/*--------- Bildschirm invertieren ----------*/

invert(base)   /* Bildschirm zeilenweise invertieren */
long *base;
{
        word vorn,hinten;

        for (hinten=vorn=0; vorn<16; ++vorn) 
                {
                invertiere_zeile(base,vorn); /* Anfang */
                waittask();
                }
        for (;;) /* Endlosschleife */
                {
                invertiere_zeile(base,hinten++);
                invertiere_zeile(base,vorn++);
                if (hinten==200) hinten=0;
                if (vorn==200) vorn=0;
                waittask(); /* waittask wirkt hier wie VSYNC ! */
                }
}               

invertiere_zeile(base,zeile)
long *base;
word zeile;
{
        word i;
        
        for (i=0; i<40; ++i) base[zeile*40+i]=-base[zeile*40+i]-1;
}

/*------------ Wurzel ---------------*/

wurzel(z,done,erg)
word z,*done,*erg;
{
        *erg=1;
        while (((*erg+1)*(*erg+1))<=z)
               {
               ++*erg;
               waittask();
               }
        *done=true;
}

/*----------- FakultÑt -------------*/

word fakultaet(i)
word i;
{
        waittask();
        return (i>1)? (word) (fakultaet(i-1)*i) : (word) 1;
}

fak(z,done,erg)
word z,*done,*erg;
{
        *erg=fakultaet(z); /* Beispiel fÅr rekursiven Aufruf */
        *done=true;
}

/*----------- Hauptprogramm ------------*/

main()
{
        word t1done,t2done,t3done;
        word e1,e2,e3;
        word dummy,cd;
        byte name[100];
        
        printf("* * *  Multitasking-Manager-Demo  * * *");
        printf("/nBerechnung von Wurzel 1024, Wurzel 100, 6!/n");
        printf("und Magischem Quadrat gleichzeitig,");
        printf("/nwÑhrend der Bildschirm zeilenweise invertiert wird./n/n");
        taskinit();  /* Init */
     
        /* normaler Aufruf einer Hintergrundroutine */
        fak(5,&dummy,&e1); printf("5! = %d - 'normal' berechnet./n",e1);

        t1done=t2done=t3done=magic.fertig_berechnet=false; 
        do_task(invert,1,screenbase());     /* Tasks */
        do_task(wurzel,3,1024,&t1done,&e1); /* werden */
        do_task(wurzel,3,100,&t2done,&e2);  /* gestartet */
        do_task(fak,3,6,&t3done,&e3);
        do_task(berechne_magic,0);
      
        printf("/nDie Zeit, die sie zur Eingabe Ihres Namens benîtigen (Åber GEMDOS #10)/n");
        printf("kann ebenfalls zur Berechnung verwendet werden!/n");
        printf("Wie heiûen sie ? "); input(name);
        printf("/nHallo %s/n/n",name);
        cd=0;
        while (cd!=4)
                {
                /* Hauptprogramm wartet nur das Ende der Berechnungen ab,
                   falls noch nicht abgeschlossen und gibt die Ergebnisse
                   aus */
                if (t1done) { ++cd; t1done=false; printf("Wurzel 1024 = %d/n",e1); }
                if (t2done) { ++cd; t2done=false; printf("Wurzel 100 = %d/n",e2); }
                if (t3done) { ++cd; t3done=false; printf("6! = %d/n",e3); }
                if (magic.fertig_berechnet)
                        {
                        ++cd;
                        magic.fertig_berechnet=false; /* damit nicht 2 mal */
                        zeige_magisches_quadrat();   /* gezeigt wird      */
                        }
                }
        printf("/ndrÅcke Taste");
        bconin(); 
        stoptask(); /* hier stoppt auch invert(); */
        bconin();
        taskexit(); /* Taskmanager ausschalten */
}

/*-----------------------------------*/

