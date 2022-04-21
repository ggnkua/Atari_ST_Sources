HSR       equ     $ffe9                             ;Ho
HRX       equ     $ffeb                             ;Ho
HTX       equ     $ffeb                             ;Ho
PBC       equ     $ffe0                             ;Po
rec	MACRO   dest
	jclr    #0,x:<<HSR,*
	movep   x:<<HRX,dest
	ENDM
env	MACRO   source
        jclr    #1,x:<<HSR,*
        movep   source,x:<<HTX
        ENDM
        org     p:$0
        jmp     start
        org     p:$40
start
        movep             #1,x:<<PBC
        move              #IMG,r0
        move              #-1,m0
        move              #128*64,n0
        do      n0,_loop12
        rec     x:(r0)+
_loop12
        nop
again
        move              #I_X,r0
        move              #>4096*256/2,x1
        do      #4,_l_rec
        rec     x0
        mpy     x0,x1,a
        move	a,y:(r0)+
_l_rec
        rec     y:BASE_X
        rec     y:BASE_Y
        clr     a
        move                          a,y:COUNT
        move              #-1,m0
        move              #IMG,r0
        move              #SOIXANTE4,r1
        move              #MASK,r2
        move              #P_Y,r4
        move              #DEUX_M,r5
        DO      #160,BOU_Y
        move                          y:I_XP,x0
        move                          y:COUNT,x1
        move                          y:BASE_Y,a
        move                          y:BASE_X,b
        mac     x0,x1,b               y:I_YP,x0
        mac     x0,x1,a               b,y:P_X
        move              #>2048,b
        add     x1,b                  a,y:P_Y
        move                          b,y:COUNT
        move                          y:I_X,x0
        move                          y:I_Y,y0
        move              #>0,x1
        move                          y:P_X,a
        DO      #160,BOU_X
	mac     x0,x1,a               y:(r4)-,b
        mac     y0,x1,b   a,a0
        tfr     x1,b      b,y1        x:(r1),x1
        mac     x1,y1,a   x:(r2),x1   y:(r5),y1
        add     y1,b      a0,a
        and     x1,a      b,x1        y:(r4)+,y1
        tfr     y1,a      a1,n0
        env     x:(r0+n0)
BOU_X:
        nop
BOU_Y:
        move              #IMG,r0
        move              #>$1fff,x1
        do      #512,_chg
        rec     a
        and     x1,a
       	move              a,n0
        rec     x:(r0+n0)
_chg
        MOVE              #>64,x0
        move              x0,X:SOIXANTE4
        MOVE              x1,X:MASK
        jmp     again

          org     y:$0
I_X       dc      4096*1
I_Y       dc      0
I_XP      dc      $0
I_YP      dc      4096*1
COUNT     dc      0
DEUX_M    dc      2048
V_X       dc      0
V_Y       dc      0
P_X       dc      0
P_Y       dc      0
BASE_X    dc      64
BASE_Y    dc      32
          org     x:$0
SOIXANTE4 dc      64
MASK      dc      $1fff
IMG       ds      128*64
