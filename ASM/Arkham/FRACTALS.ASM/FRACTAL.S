*******************************************
* affiche FRACTALE JULIA by TCHOOM/ANONYM *
*******************************************

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp

 clr.l -(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,oldpile
 
 movem.l palette,d0-d7
 movem.l d0-d7,$ffff8240.w

* initialise variables pour affichage

 move.w #160,_a1	* point d'origine
 move.w #100,_a2	* de la fractale

 move.w #50,_Xn		* point de depart
 move.w #50,_Yn		* de la suite (n=0)

* commence le trace de la fractale
 
loop

 clr.l d6
 clr.l d7

 cmpi.b #$b9,$fffffc02.w
 beq end
 
* calcul de X(n+1) et Y(n+1)

; X(n+1)

 move.w _Xn,d0
 muls.w d0,d0		; Xn^2
 move.w _Yn,d1
 muls.w d1,d1		; Yn^2
 sub.w d1,d0		; Xn^2-Yn^2
 add.w _a1,d0		; Xn^2-Yn^2+a1
 move.w d0,d6		; Xn+1=Xe

; Y(n+1)

 move.w #2,d0
 muls.w _Xn,d0
 muls.w _Yn,d0
 add.w _a2,d0
 move.w d0,d7		; Yn+1=Ye

* augmente n  -> actualise Xn et Yn

 move.w d6,_Xn
 move.w d7,_Yn

; et on trace le point

 lea.l $1f8000,a0
 mulu.w #$a0,d7
 adda.w d7,a0
 move.w #2,(a0)                                                           

 bra loop

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
 move.l oldpile,-(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr -(sp)
 trap #1

* section data 

oldpile even
 dc.l 0

palette even
 dc.w $000,$222,$333,$444
 dc.w $555,$666,$777,$767
 dc.w $757,$747,$737,$727
 dc.w $717,$707,$606,$505

_a1 even
 dc.w 0
_a2 even
 dc.w 0
_Xn even
 dc.w 0
_Yn even
 dc.w 0


 

 


