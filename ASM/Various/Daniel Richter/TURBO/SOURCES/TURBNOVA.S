;TURBO-NOVA v1.0
;
;Daniel Richter
;Bergische Str.54
;D-42549 Velbert
;11.07.1996
;
;Dieses Programm schaltet den Bild-
;schirm am normalen Videoausgang
;des Falcon aus. Dadurch sinkt die
;Busbelastung, der Rechner wird-
;schneller! Nur sinnvoll auf Falcon
;030/ 040 mit NOVA-Grafikkarte!


                TEXT


;Hardwareregister dÅrfen nur im Super-
;visormode angesprochen werden:


                pea     go_for_it(pc)
                move.w  #$26,-(sp)
                trap    #14
                addq.l  #6,sp


                lea     starttext(pc),a0
                bsr.s   print
;und wech:
                clr.w   -(sp)
                trap    #1
;**********************************
go_for_it:
;Erstmal testen, ob eine NOVA drinne ist:


                bsr.s   test_ob_nova_da
                tst.w   d0
                beq.s   keine_nova_da


nova_da:
;Die Nova-Karte scheint da zu sein:
;Damit nur schwarze RÑnder dar-
;gestellt werden: Vertikalen Rand-
;anfang und -ende gleichsetzen.


;$FF82A2: Vertikaler Frequenz Timer
;$FF82A4: Vertikaler Randanfang
;$FF82A6: Vertikales Randende
;$FF82A8: Vertikaler Bildschirmanfang


                move.w  $FFFF82A2.w,d0
                move.w  d0,$FFFF82A4.w
                move.w  d0,$FFFF82A6.w


;Damit die Busbelastung auch weg ist,
;fÑngt der Bildschirm halt "nirgendwo" an:


                move.w  #-1,$FFFF82A8.w
                rts
;**********************************
test_ob_nova_da:
;Anhand des Cookies "NOVA" kann fest-
;gestellt werden, ob eine NOVA-Karte
;angeschlossen ist:


;$5A0: Zeiger auf Cookiejar
                move.l  $05A0.w,d0
                beq.s   keine_nova
                movea.l d0,a0
get_next_cookie:
                move.l  (a0)+,d0
;d0.l: Kennung des Cookies
                beq.s   keine_nova
                move.l  (a0)+,d1
;d1.l: Wert des Cookies
                cmp.l   #"NOVA",d0
                bne.s   get_next_cookie
                moveq   #-1,d0
;d0=-1: Nova installiert
                rts
keine_nova:
                moveq   #0,d0
;d0=0: Keine Nova-Karte installiert
                rts
;**********************************

keine_nova_da:
;Wenn keine NOVA da ist, wird das Pro-
;gramm bei Leertastendruck verlassen,
;oder per "I"-Taste ignoriert, da· keine
;NOVA da ist:


                lea     no_nova_text(pc),a0
                bsr.s   print


;Zeichen eingeben lassen:
key_again:
                move.w  #8,-(sp)
                trap    #1
                addq.l  #2,sp
;Wenn "I" oder "i" gedrÅckt wird,
;werden die Sicherheitsvorkehrungen
;umgangen...
                cmp.b   #"I",d0
                beq.s   nova_da
                cmp.b   #"i",d0
                beq.s   nova_da
                cmp.b   #" ",d0
                bne.s   key_again
                rts
;**********************************
print:
;Gibt einen Text auf dem Bildschirm aus:
                pea     (a0)
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp
                rts
;**********************************

                DATA
starttext:
                DC.B 13,10
                DC.B 27,"p TURBO-NOVA"
                DC.B " v1.0 - D. Richter"
                DC.B " 1996",27,"q"
                DC.B 13,10,"       Video"
                DC.B "busbelastung"
                DC.B "= 0%       ",13,10
                DC.B 13,10,0
no_nova_text:
                DC.B "Es ist keine Nova-"
                DC.B "Karte "
                DC.B "installiert!!",13,10
                DC.B "Dieses Programm ist"
                DC.B " ohne sie nutzlos!"
                DC.B 13,10
                DC.B "<LEERTASTE>"
                DC.B " oder"
                DC.B " <I>gnorieren?"
                DC.B 13,10,0
                EVEN
                BSS
                END
