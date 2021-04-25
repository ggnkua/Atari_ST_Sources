/*******************************************************************
 * Dieses Programm dient als Debug-Hilfe zum Debugger TEMPLEMON
 * von Thomas Tempelmann, E.-L.-Kirchner Str. 25, 2900 Oldenburg.
 * Es wurde mit dem MEGAMAX C Entwicklungssystem erstellt.
 * Das Programm (ohne die besonders markierten spezifischen Programm-
 * abschnitte fuer das Beispielprogramm TRACE.TOS) kann als Rumpf
 * fuer alle weiteren User-Trace Routinen dienen.
 ******************************************************************/

/* Allg. includes */

#include <osbind.h>

/* spezifische Konstante fuer Zugriffe auf die Prozessorregister */

#define  RegD0  04(A0)
#define  RegD1  08(A0)
#define  RegD2  12(A0)
#define  RegD3  16(A0)
#define  RegD4  20(A0)
#define  RegD5  24(A0)
#define  RegD6  28(A0)
#define  RegD7  32(A0)
#define  RegA0  36(A0)
#define  RegA1  40(A0)
#define  RegA2  44(A0)
#define  RegA3  48(A0)
#define  RegA4  52(A0)
#define  RegA5  56(A0)
#define  RegA6  60(A0)
#define  RegA7  64(A0)
#define  RegSR  02(A0)
#define  RegPC  68(A0)
#define  RegUSP 80(A0)
#define  RegSSP 84(A0)

#define  StopTrace D0

/* Allg. Definitionen */

#define  TRUE   1
#define  FALSE  0


/******************** User - Trace Routine ***************************/

static _usrTrc();

asm {
_usrTrc:    ;Hier ist der Einsprungspunkt fuer die User-Trace Routine.
            ;Hier koennen Abfragen in Assembler programmiert werden.
            ;Die augenblicklichen Register A0 und D7 duerfen nicht
            ;veraendert werden; in D0.W wird Nicht-Null oder Null zu-
            ;rueckgegeben, je nachdem, ob das Tracing abgebrochen wer-
            ;densoll oder ob weitergetraced werden soll.
            ;Auf die im Debugger zwischengespeicherten Register der
            ;CPU fuer die naechste auszufuehrende Instruktion kann
            ;mit den obigen Definitionen (Reg..) zugegriffen werden.
            ;Die Register (Reg..) koennen auch veraendert werden.
            ;Dieses Programm wird immer im Supervisormodus aufgerufen.
            ;
            ;Z.B. kann eine Ueberpruefung, ob als naechste Instruktion
            ;ein Line-A Aufruf stattfindet, folgendermassen program-
            ;miert werden :
            ;
            ; CLR.W   StopTrace  ;D0.W erstmal ruecksetzen...
            ; MOVE.L  RegPC,A1   ;PC laden
            ; MOVE.W  (A1),D1    ;Instruktion laden
            ; ANDI.W  #0xF000,D1 ;oberstes Nibble der Instr. maskieren
            ; CMPI.W  #0xA000,D1 ;Line-A Instruktion ?
            ; SEQ     StopTrace  ;je nachdem D0.B auf 0 oder -1 setzen
            ; RTS                ;zurueck zum Monitor
            ;
            
            /**** Beispiel-Text f. TRACE.TOS ******/
            
             CLR.W   StopTrace
             MOVE.L  0x44E,A1     ;Adr. des Bildschirmbereichs
             TST.W   640(A1)      ;Sind die Bits der ersten 8 Spalten
                                  ;in der zweiten Zeile geloescht ?
             SNE     StopTrace    ;Wenn nicht, dann Stop
             RTS

}


install_trace()
{
    asm{
        LEA     _usrTrc(PC),A0     ; Adr. der Traceroutine
        MOVE.L  A0,0x3F0           ; in User-Trace Vektor ablegen
    }
    
    /**********************************************************
     * Hier folgt evtl. Anwenderspezifischer Code f. weitere  *
     * Initialisierungen :                                    *
     **********************************************************/
    
}


long keep, prgtop;
extern char *_base;

main()
{
    
    Supexec(install_trace);   /* Trace-Routine installieren */
    
    /******* Text f. Beispielprogramm TRACE.TOS : *******/
      
      /* ACHTUNG: dieser Text ist ausgeklammert !
        printf("\nDr…ken Sie gleich ALT/HELP, wenn Sie im Desktop sind.\n");
        printf("Dadurch gelangen Sie in den Monitor, vorausgesetzt, er wurde vorher\n");
        printf("durch einen Aufruf (z.B. im Auto-Ordner) initialisiert.\n");
        printf("Mit den Tasten F1 und F2 k馬nen Sie dann zwischen dem Monitor- und dem\n");
        printf("normalen Bildschirm hin- und herschalten.\n");
        printf("Geben Sie dann 'T+' ein. Damit wird der Tracemodus eingeschaltet.\n");
        printf("Danach geben Sie 'G' ein, um das unterbrochene Programm (das Desktop-Programm)\n");
        printf("weiterlaufen zu lassen.\n");
        printf("Dann wird nochmal auf einen Tastendruck gewartet, worauf Sie dann\n");
        printf("die Taste 'A' dr…ken sollen.\n");
        printf("Nun lеft wieder das Desktop-Programm, allerdings nicht mehr ganz so\n");
        printf("schnell, wie man das eigentlich von einer 68000 erwartet...\n");
        printf("Nun sollten Sie die Zeit nutzen, um ein bischen herumzuspielen.\n");
        printf("Wenn Sie genug haben, gehen Sie mit dem Mauscursor nach links oben. Das erkennt\n");
        printf("dann dieses User-Trace Programm und der Monitor meldet sich zur…k.\n");
        printf("Mit '?' bekommen Sie im Monitor eine kurze Anleitung !\n");
        printf("Mit 'T-' und 'G' k馬nen Sie den Monitor wieder normal verlassen"); 
        printf("\nBitte nun erstmal die SPACE-Taste dr…ken...\n");
        Cconin();
      */
    
    
    /**********************************************************
     * Programm beenden, aber Speicher dieses Programms nicht *
     * freigeben :                                            *
     **********************************************************/
    asm {
        MOVE.L  A7,prgtop(A4)
    }
    keep = ( prgtop + 0x100 ) - (long) _base;
    Ptermres( keep, 0 );
}

/* Ende des Programms */

