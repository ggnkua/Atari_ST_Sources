main:
;desactive l'interuption 200hz
        move.w          #5,-(sp)
        move.w          #26,-(sp)
        trap            #14
        addq.l          #4,sp

;placer les nouveaux vecteurs
        move.l          #vbl_ir,d0
        move.w          #28,d1
        bsr             setexec
        move.l          d0,-(sp)
        move.l          #hbl_ir,d0
        move.w          #26,d1
        bsr             setexec
        move.l          d0,-(sp)

;super(mode superviseur)
        clr.l           -(sp)
        move.w          #$20,-(sp)
        trap            #1
        addq.l          #6,sp
        move.l          d0,-(sp)
        lea             $ff8240,a4

;toutes interruptions permises
        and.w           #$f8ff,sr

;pression d'une touche
arf:
        bra arf
        move.w          #1,-(sp)
        trap            #1
        addq.l          #2,sp

;desactivation interruption
        or.w            #$0300,sr

;mode user(mode user)
        move.w          #$20,-(sp)
        trap            #1
        addq.l          #6,sp

;remise en place des anciens vecteurs
        move.l          (sp)+,d0
        move.w          #28,d1
        bsr             setexec
        move.l          (sp)+,d0
        move.w          #26,d1
        bsr             setexec

;autoriser l'interruption 200hz
        move.w          #5,-(sp)
        move.w          #27,-(sp)
        trap            #14
        addq.l          #4,sp
        clr.w -(sp)
        trap #1

;placer vecteurs d'exceptions
setexec:
        move.l          d0,-(sp)
        move.w          d1,-(sp)
        move.w          #5,-(sp)
        trap            #13
        addq.l          #8,sp
        rts

;routine hbl
hbl_ir:
        lea prrg,a3
        lea dxrg,a4
        move.l (a3),a3
        move.l (a4),a4
        move.w (a3)+,(a4)        
        cmpi.w #$fff,(a3)
        bne.s hbl_end
        lea palette,a3
        
        
        
hbl_end:
        move.l a3,prrg
        move.l a4,dxrg
        rte
        
;routine vbl
vbl_ir:
        move.l #palette,prrg
        
        
        
        
        
vbl_end:
        rte




palette:
        dc.w $000
        dc.w $001
        dc.w $002
        dc.w $003
        dc.w $004
        dc.w $005
        dc.w $006
        dc.w $007
        dc.w $006
        dc.w $005
        dc.w $004
        dc.w $003
        dc.w $002
        dc.w $001
        dc.w $fff
prrg:
        dc.l 0
dxrg:
        dc.l 0




