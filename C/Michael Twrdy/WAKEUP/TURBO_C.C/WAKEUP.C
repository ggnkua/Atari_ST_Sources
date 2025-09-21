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
/*                       Telefon: 0222/7527212                            */
/*                                                                        */
/**************************************************************************/

#include <tos.h>

int strobe_low  = 0xDF;   /*   Bitmuster: 11011111 */
int strobe_high = 0x20;   /*   Bitmuster: 00100000 */

void main(void)
{
Offgibit(strobe_low);   /* Die Bitmuster werden an die XBIOS-Routinen Ongibit */
Offgibit(strobe_low);   /* und Offgibit Åbergeben und damit die Bits des Port */
Ongibit(strobe_high);   /* A des Soundchip manipuliert. */
}
