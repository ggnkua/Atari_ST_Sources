DEFINITION MODULE KbdEvents;
(*------------------------------------------------------------------------------
 * Version 2.6  (fr MEGAMAX MOS 2.2)
 *------------------------------------------------------------------------------
 * Copyright (c) 1989, 90, 91 by Michael Seyfried
 *------------------------------------------------------------------------------
 *                            Modulbeschreibung
 *
 * Bei Tastaturereignissen in GEM-Programmen kann man den Status der Sonder-
 * tasten (Shift, Alternate, Control) beim Bearbeiten des Ereignisses in der
 * Tastaturbehandlungsroutine des Anwenderprogramms berprfen. Die Routinen
 * des AES liefern dabei aber immer den aktuellen Status der Sondertasten zu-
 * rck. Richtig w„re es, wenn jedem Tastendruck schon beim Auftritt des
 * Ereignisses die Sondertastenbelegung zugeordnet wrde. Der Tastendruck wird
 * von der Tastaturbehandlungsroutine oft falsch analysiert, weil sich zwischen
 * Auftritt und Behandlung des Tastaturereignisses der Sondertastenstatus
 * „ndern kann.
 *
 * Wird dieses Modul importiert und die Prozedur 'InstallKbdEvents' aufgerufen,
 * so erh„lt man bei 'MultiEvent' und 'HandleEvents' den Status der Sondertasten
 * richtig, d.h. zum Zeitpunkt des Tastendrucks, zurck.
 * Dazu wird das Bit 3 in 'conterm' gesetzt und beim Auftritt eines Tastatur-
 * ereignisses die Bits 24..31 aus dem Tastaturpuffer (entspricht dem Wert von
 * 'Kbshift()' beim Tastendruck) nach 'int_out[4]' bertragen (Man erh„lt also
 * auch den Status der CapsLock-Taste und der Maustasten).
 * Wird 'KeyboardEvents' verwendet, um auf ein Tastaturereignis zu warten, mu
 * man sich den Sondertastenstatus anschlieend direkt aus int_out[4] besorgen.
 *
 * Hinweis: Dieses Modul h„ngt sich in folgende Vektoren:
 *
 *          $088            TRAP#2
 *          $118            IKBD/MIDI
 *          $400            etv_timer
 *
 *          Dabei wird die XBRA-Kennung 'KbEv' verwendet.
 *------------------------------------------------------------------------------
 *                            Bekannte Probleme:
 *
 * Wenn man durch wilde Hackerei den Tastaturpuffer zum šberlaufen bringt, darf
 * man nicht erwarten, da auch noch der Sondertastenstatus dazu geliefert wird.
 * Es wird dann einfach der AES-Wert zurckgegeben.
 * Da sich die Routinen mit dem Puffer atomatisch syncronisieren, werden weitere
 * Tastendrcke wieder richtig geliefert. Man kann also mit diesem "Problem"
 * leben.
 *------------------------------------------------------------------------------
 *)


PROCEDURE KbdEventsInstalled(): BOOLEAN;
(*
 * Wert: genau dann TRUE, wenn DIESES Modul sich auf die o. a. Vektoren
 *       installiert hat.
 *)

PROCEDURE InstallKbdEvents;
(*
 * Diese Routine mu man aufrufen, wenn man dieses Modul aktiv setzen will.
 * Dann liefern, wie oben beschrieben, die AES-Routinen den Sondertastenstatus
 * richtig zurck.
 *)

PROCEDURE DeInstallKbdEvents;
(*
 * Nach dem Aufruf dieser Routine sind die Funktionen dieses Moduls inaktiv.
 * Die o.a. Vektoren werden dabei restauriert.
 * Diese Prozedur wird bei Terminierung dieses Moduls automatisch aufgerufen.
 *)

END KbdEvents.
