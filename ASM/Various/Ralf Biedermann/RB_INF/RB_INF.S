                OPT O+
                OUTPUT 'RBINF.PRG'
;dieses kleine progrÑmmchen sollte man als Anwendung fÅr .INF dateien
;anmelden. durch einen doppelklick auf eine DESKTOP.INF datei kann
;man sehr schnell das aussehen des desktops verÑndern.
;sehr praktisch wenn man des îfteren zwischen diversen compilern und
;anwendungsprogrammen hin- und herschaltet.
;version 1.1 vom 10.01.92 Ralf Biedermann
;ab TOS 1.04 scheint Desktop.INF bis 4K gehen zu kînnen

                TEXT
;nicht benutzten Speicherplatz zurÅckgeben
                movea.l SP,A5
                lea     stack+200(PC),SP
                movea.l 4(A5),A5
                movea.l 12(A5),A1
                adda.l  20(A5),A1
                adda.l  28(A5),A1
                lea     $0100(A1),A1
                move.l  A1,-(SP)
                move.l  A5,-(SP)
                clr.w   -(SP)
                move.w  #$004A,-(SP)    ;mshrink
                trap    #1
                lea     12(SP),SP
                tst.l   D0
                bne.s   error
;appl init
                moveq   #10,D0
                move.l  #$00010000,D1
                bsr.s   aes
                tst.w   intout
                bmi.s   error
                move.w  #2,-(SP)
;open
;parameter in basepage
                lea     128(A5),A5
                moveq   #0,D0
                move.b  (A5)+,D0        ;=0 keine parameter
                beq.s   exit
                movea.l A5,A0
                clr.b   0(A0,D0.w)      ;erste byte nach namen lîschen
                move.l  A5,-(SP)        ;datei îffnen
                move.w  #$003D,-(SP)
                trap    #1
                addq.l  #8,SP
                tst.w   D0
                bmi.s   error
;read
                pea     deskinf(PC)
                move.l  #4096,-(SP)
                move.w  D0,-(SP)
                move.w  #$003F,-(SP)
                trap    #1
;close
                move.w  #$003E,(SP)
                trap    #1
                lea     12(SP),SP
;shel put
                moveq   #123,D0
                move.l  #$01010100,D1
                move.w  #4096,intin
                move.l  #deskinf,addrin
                bsr.s   aes
;appl exit
exit:           moveq   #19,D0
                move.l  #$00010000,D1
                bsr.s   aes

error:          clr.w   -(SP)
                trap    #1

aes:            lea     contrl(PC),A0
                move.w  D0,(A0)
                movep.l D1,3(A0)
                move.l  #aesbp,D1
                move.w  #$00C8,D0
                trap    #2
                rts

                DATA

aesbp:          DC.L contrl,global,intin,intout,addrin,addrout

                BSS

contrl:         DS.W 11
global:         DS.W 15
intin:          DS.W 64
intout:         DS.W 64
addrin:         DS.W 64
addrout:        DS.W 64
deskinf:        DS.B 1024
stack:          DS.L 50
                END
