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


               .EXPORT wake_me

               .EVEN
               .CODE

wake_me:
               pea     ringeling(pc)
               bra     s_mode

ringeling:
               move.w   #$DF,-(sp)     * STROBE LOW
               move.w   #29,-(sp)
               trap     #14
               addq.l   #4,sp
one_more_time:
               move.w   #$DF,-(sp)     * STROBE LOW
               move.w   #29,-(sp)
               trap     #14
               addq.l   #4,sp

               move.w   #$20,-(sp)     * STROBE HIGH
               move.w   #30,-(sp)
               trap      #14
               addq.l   #4,sp
s_mode:
               move.w  #38,-(A7)
               trap    #14
               addq.l  #6,A7
               rts

               .END
