; [15:20] <XiA> So every other word is sine(x), every other is cox(x)?
; [15:21] <ggn> cos/sin rather
; [15:21] <ggn> cos(0)/sin(0)/cos(2*pi/512)/sin(2*pi/512)/etc

; sine/cosine generator by mcoder and ziggy stardust

nbsinus         EQU 512
cos1            EQU 32766       s;cos(2*pi/512)
sin1            EQU 402         s;sin(2*pi/512)

genere_sinus:
                lea     tabsinus,A0
                moveq   #nbsinus/4-1,D7
                move.w  #$7FFF,D0       s;cos(0)=1
                clr.w   D1              s;sin(0)=0
.loop:
                move.w  D0,(A0)+
                move.w  D1,(A0)+

                move.w  D0,D3
                muls    #cos1,D3
                move.w  D1,D4
                muls    #sin1,D4

                muls    #cos1,D1
                muls    #sin1,D0

                sub.l   D4,D3
                add.l   D0,D1

                move.l  D3,D0

                add.l   D0,D0
                swap    D0
                add.l   D1,D1
                swap    D1
                dbra    D7,.loop

                lea     tabsinus,A0
                moveq   #nbsinus/4-1,D2
.loop2:
                move.w  (A0)+,D0
                move.w  (A0)+,D1
                move.w  D0,nbsinus*1/4*4-4+2(A0)
                neg.w   D0
                move.w  D0,nbsinus*2/4*4-4+0(A0)
                move.w  D0,nbsinus*3/4*4-4+2(A0)
                move.w  D1,nbsinus*3/4*4-4+0(A0)
                neg.w   D1
                move.w  D1,nbsinus*1/4*4-4+0(A0)
                move.w  D1,nbsinus*2/4*4-4+2(A0)

                dbra    D2,.loop2
	rts