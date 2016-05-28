;/*-------------------------------------------------------------------------*/
;/* InqMagX()                                                               */
;/*                                                                         */
;/* Liefert                                                                 */
;/*  -1:   Kein Mag!X vorhanden                                             */
;/*  -2:   Mag!X installiert, aber Mag!X-AES inaktiv; d.h. Mag!X wird nur   */
;/*        als schnelles Filesystem benutzt!                                */
;/*  >0:   Mag!X vorhanden und Mag!X-AES aktiv. Der RÅckgabewert enthÑlt    */
;/*        die BCD-codierte Versionsnummer (z.B: 0x0200)                    */
;/*-------------------------------------------------------------------------*/

              export    InqMagX
              import    get_cookie

InqMagX:      move.l    #'MagX',d0
              lea       xadr,a0
              jsr       get_cookie
              tst.w     d0
              beq.s     no_magx
              move.l    xadr,a0
              move.l    8(a0),a0
              move.l    a0,d0
              beq.s     not_running
              move.w    48(a0),d0
              bra.s     bye
no_magx:      moveq     #-1,d0
              bra.s     bye
not_running:  moveq     #-2,d0
bye:          rts

              bss
xadr:         ds.l      1
              end
