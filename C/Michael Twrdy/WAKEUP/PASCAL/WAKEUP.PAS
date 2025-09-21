
PROGRAM WAKEUP;

{
/**************************************************************************/
/* Das Programm WAKEUP dient dazu, einen angeschlossenen Laserdrucker,    */
/* der erst nach dem Rechner eingeschaltet wurde, mit einem kurzem STROBE */
/* Impuls zum Leben zu erwecken. Erst jetzt nimmt der Drucker Daten an !  */
/* Es werden die XBIOS-Routinen OFFGIBIT und ONGIBIT verwendet und dabei  */
/* die korrekten Parameterwerte fÅr das Ein- und Ausschalten des Strobe-  */
/* signales Åbergeben. Es muû unbedingt das gesamte Bitmuster angegeben   */
/* werden und nicht nur die Bitnummer !!!                                 */
/*                                                                        */
/*                         (c) 1991 by PDST                               */
/*                  Public Domain & Shareware Twrdy                       */
/*                           Michael Twrdy                                */
/*                            Postfach 24                                 */
/*                      Telefon: 0222/7527212                             */
/*                                                                        */
/**************************************************************************/
}

  CONST

  STROBE_LOW  = $DF;
  STROBE_HIGH = $20;


PROCEDURE OFFGIBIT(BIT_NUMMER:INTEGER);
XBIOS(29);

PROCEDURE ONGIBIT(BIT_NUMMER:INTEGER);
XBIOS(30);

  BEGIN
   OFFGIBIT(STROBE_LOW);
   OFFGIBIT(STROBE_LOW);
   ONGIBIT(STROBE_HIGH);
  END.





