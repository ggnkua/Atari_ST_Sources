/***                                                          ***/
/*      CZ SPLIT                                                */
/*      aus ANTIC Publishing, June 1988                         */
/*      von Jim Pierson-Perry                                   */
/*      in 'C' umgesetzt, eingedeutscht und erweitert  von      */                                   
/*      Wolfgang Schmidt, ST VISION                     6/88    */
/*                                                              */
/*      ST VISION                                               */
/*      Postfach 1651                                           */
/*      6070 Langen                                             */
/*                                                              */
/***                                                          ***/
/*      CZ SPLIT teilt das Keyboard in bis zu vier Bereiche     */
/*      auf, die mit verschiedenen Kl„ngen belegt werden k”nnen.*/
/*      Dazu werden die Modi Local off und Mono benutzt.        */
/***                                                          ***/
 

#include <stdio.h>
#include <osbind.h>

#include "midi_def.c"

int vprg[3], sp[3];
int mc, czt, i, nsplit, b, t, sp1, sp2, sp3;
int s;
char a;


main()
{
int ia, ie;
  do {
        /* Init der split-points und patch-nummer felder */
        for (i=0; i<=3; i++)
          {
          sp[i] = 36;
          vprg[i] = 0;
          }
                  
        cl_s();
        
        /* Abfrage des zu benutzenden MIDI-Kanals */
        do {
           printf("Gib den MIDI-Basis Kanal ein (1..13): ");
           scanf("%d", &mc);
           }
        while( !check_range(1,13,mc));
        
        mc--;
        midi_chan = mc;
        
        /* Markenbezeichnung anfragen */         
        puts("");
        puts("Welche Bezeichnung hat dein CZ Synthi ?  ");
        puts("  1 - CZ-101/1000");
        puts("  2 - CZ-3000/5000");
        puts("  3 - andere (CZ-230S/CZ-1");
        do {
           printf("Welche Bezeichnung (1, 2 oder 3): ");
           scanf("%d", &czt);
           }
        while (!check_range(1,3,czt));
        
        cl_s();
        
        /* Einteilung der Keyboard-Bereiche in verschiedene Klangfarben */
        /* Klang 1: vom linken Ende zum ersten Split-Point, */
        /* Klang 2: vom ersten Split-Point zum zweiten, usw.*/
        do {
           printf("Wieviele Split-Points m”chtest du (1..3)?  ");
           scanf("%d", &nsplit);
           }
        while (!check_range(1,3,nsplit));
        
        for (i=1; i <= nsplit; i++)
           {
           do {
              printf("   \nGib den MIDI-Wert der Taste ein, auf der der\n");
              printf("   %d. Split-Point liegen soll (36..96): ", i);
              scanf("%d", &sp[i-1]);
              }
           while (!check_range(36,96,sp[i-1]));
           }
        sort();    /* Reihenfolge der Split-Points absteigend sortieren */ 
                              
        cl_s();
        
        /* Auswahl der Kl„nge fr die Keyboard-Bereiche */
        /* Falls die Cartridge angew„hlt wird und sie ist nicht vorhanden */
        /* wird der korrespondierende Klang in der Default-Bank genommen */
        for (i=0; i<=nsplit; i++)
           {
           ia = (i!=nsplit) ? sp[i] : 36;
           ie = (i!=0) ? sp[i-1]-1 : 95;
           printf("W„hle nun den Klang fr den Bereich %d (%d..%d) aus:\n",
                  i+1, ia, ie);
           if (czt == 1)
             {
             do {
                printf("   Bank (Preset = 1, Internal = 2, Catridge = 3): ");
                scanf("%d", &b);
                }
             while (!check_range(1,3,b));
             
             do {
                printf("   Programm Nummer (1..16): ");
                scanf("%d", &t);
                }
             while (!check_range(1,16,t));
             }  
            else if (czt == 2)
             {
             do {
                printf("   Source (Preset = 1, Memory = 2): ");
                scanf("%d", &b);
                }
             while (!check_range(1,2,b));
               
             do {
                printf("   Bank (A..D):");
                scanf("%c", &s);
                s = s - 'A' + 1;
                }
             while (!check_range(1,4,s));
                
             do {
                printf("   Programm Nummer (1..8): ");
                scanf("%d", &t);
                }
             while (!check_range(1,8,t)); 
             t = 8 * (s-1) + t;
             }
            else
             {
             b = 1;
             printf("  Programm-Nummer: ");
             scanf("%d", &t);
             }
            
            puts("");
            vprg[i] = 32*(b-1)+t-1;
        }
        
        sp1 = sp[0];
        sp2 = sp[1];
        sp3 = sp[2];
        
        mono_set();      /* setze mono-mode */      
        cl_s();
        
        /* Daten zum Prfen nochmals ausgeben */
        puts("Split-Points bei:");
        for (i=0; i<nsplit; i++)
          printf("%d.  %d\n", i+1, sp[i]);        

        puts("");
        puts("Keyboard-Bereiche:");
        for (i = 0; i <= nsplit; i++)
           {
           ia = (i!=nsplit) ? sp[i] : 36;
           ie = (i!=0) ? sp[i-1]-1 : 95;
           printf("%d.  Tasten %d..%d belegen Programm #%d\n", i+1, 
                  ia, ie, vprg[i]);
           probe(i,ia,ie);      /* H”rprobe */
           }
        puts("");

        
        puts("");
        puts("CZ Aufbau abgeschlossen - fertig zum Spielen.");
        puts("Drcke PORTAMENTO ON/OFF um das Programm abzubrechen.");
        puts("");        

        /* Real-Time MIDI Daten-Verarbeitung */
        A:
        b = midi_in();
        
        B:
        /* falls es der Portamento-Knopf ist, verzweige zum Ende */
        if (b == CONTROL_CHANGE+mc)
            goto X;
         
        /* Test auf NOTE_ON Kommando */
        if (b != NOTE_ON)
          {      
          /* kein NOTE_ON */
          midi_out(b);    /* direkt weiterleiten an den Synthi */
          goto A;
          }          
         else
          {
          /* NOTE_ON Verarbeitung */
          /* lies das n„chstfolgende MIDI Daten-Byte */
          /* (gibt an, welcher Ton gedrckt wurde)   */
          t = midi_in();
          }         

          C:
          /* ermittle in welchem Keyboard-Bereich der Ton liegt und */
          /* steuere den korrespondierenden Klang an.               */
          if (t >= sp1)
             midi_out(NOTE_ON+mc);
          else if (t >= sp2)
             midi_out(NOTE_ON+mc+1);
          else if (t >= sp3)
             midi_out(NOTE_ON+mc+2);
          else
             midi_out(NOTE_ON+mc+3);

          D:
          /* sende das NOTE_ON Daten-Byte zum CZ */
          midi_out(t);
          /* lies das Lautst„rke-Daten-Byte (Velocity)  */
          /* und schicke es wieder hinaus               */                
          midi_out(midi_in());
          
          /* Teste, ob das n„chste MIDI-Byte ein Kommando-Byte ist oder */
          /* eins anderes NOTE_ON Datenpaar                             */
          t = midi_in();
          if (t < NOTE_OFF)
            goto C;   /* eine andere Note */
           else {
            b = t;   /* ein neues Kommando-Byte */
            goto B;
            }
          
        X:
        /* Sauberes Beenden des Programms */
        midi_clear();   /* den MIDI-Kanal leeren */
        local_on();     /* Kontrolle an das Keyboard zurck geben */
        midi_out(CONTROL_CHANGE+mc);
        midi_out(65);   /* Portamento Reset */
        midi_out(0);
        
        poly_on();      /* Rckkehr zum Poly-Modus */
        
        /* Abfrage, ob das Programm nochmals gestartet werden soll */
        printf("Soll ich das Programm nochmal starten (J/N) ?");
        do {        
           scanf("%c", &a); 
           a &= ~32;
           }
        while (a != 'J' && a != 'N');
        }
  while (a == 'J');

}  



/* Unterroutinen */

/* aufteilen des CZ in n+1 monophone Stimmen (max. 4) */
mono_set()
{
        /* Zuerst lokale Keyboard-Kontrolle ausschalten, d.h. die    */
        /* Steuerung wird allein ber MIDI vom Computer bernommen   */
        local_off();
        
        /* Mono-Modus einschalten */
        mono_on(); 
        
        /* Setzen der n+1 Klangformen fr die MIDI Kan„le mc bis mc+n */
        for (i=0; i<=nsplit; i++)
          {         
          midi_out(PROGRAM_CHANGE+mc+i);
          midi_out(vprg[i]);
          }
        
        /* Vor dem Start Kanal leeren */
        midi_clear();
}


/* H”rprobe des Keyboard-Bereiches */
probe(chan, anf, end)
int chan, anf, end;
{
int h;
        midi_out(NOTE_ON+nsplit-chan);
        for (h=anf; h<=end; h++)
           {
           midi_out(h);
           midi_out(64); /* medium velocity */
           for (s=0; s<30000; s++);
           midi_out(h);
           midi_out(0);   /* quasi NOTE_OFF */ 
           }
}           

/* Bildschirm s„ubern und Programm-Name ausgeben */
cl_s()
{
        cls();
        puts("****                    CZ-SPLIT                   ***");
        puts("");
        puts("by ANTIC Publishing,");
        puts("C-erwandelt, erweitert u. eingedeutscht by ST VISION");
        puts("");  puts("");
}

check_range(lo, hi, number)
int lo, hi, number;
{
        if (number >= lo && number <= hi)
          return(TRUE);
         else
          {
          printf("Bitte eine Zahl im Bereich %d..%d ausw„hlen !\n", lo, hi);
          return(FALSE);
          }
}

sort()
{
int j,h;
      for (j=0; j <=nsplit; j++)
        for (i=1; i < nsplit; i++)
           {
           if (sp[i-1] < sp[i])
             {             
             h = sp[i];
             sp[i] = sp[i-1];
             sp[i-1] = h;
             h = 1;
             }
           }

}
