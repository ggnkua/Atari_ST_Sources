
*************************************
*
*       EXTENSION FRACTALE STOS
*
*************************************
*
*       STOS BASIC INTERFACE
*
*************************************

even
        bra load                ; JUMP TO FIRST CALL AFTER LOAD

        dc.b $80                ;Important!
tokens: 
        dc.b "fracinit",$80,"fracalt",$81   
        dc.b "fracview",$82,"fraccolor",$83
        dc.b "fracnew",$84,"fracbase",$85
        dc.b "fracload",$86,"fracx",$87
        dc.b "fracsave",$88,"fracy",$89
        dc.b "fracmove",$8a,"fracz",$8b
        dc.b "fracup",$8c,"fracspeed",$8d
        dc.b "fracdown",$8e,"fracangle",$8f
        dc.b "fracleft",$90,"fracmode",$91
        dc.b "fracright",$92,"fracvdraw",$93
        dc.b "fracstop",$94
        dc.b "fracmore",$96
        dc.b "fracless",$98
        dc.b "fracchange",$9a
        dc.b "fracset",$9c
        dc.b "fracadd",$9e
*       dc.b "interdit",$a0
        dc.b "fracmountain",$a2
        dc.b "fracdome",$a4
        dc.b "fracwave",$a6
        dc.b "fracalea",$a8
        dc.b "fracclear",$aa
        dc.b "fracscope",$ac
        dc.b "fracwindow",$ae
        dc.b "fracpal",$b0
        dc.b "fracvinit",$b2
        dc.b "fricfrac",$b4
*       dc.b "interdit",$b8
        dc.b 0                  ;END of the table

; Table of jumps related to the tokens
even
jumps:  dc.w 54                  ;Number of jumps
        dc.l fracinit,fracalt
        dc.l fracview,fraccolor
        dc.l fracnew,fracbase
        dc.l fracload,fracx       
        dc.l fracsave,fracy
        dc.l fracmove,fracz               
        dc.l fracup,fracspeed
        dc.l fracdown,fracangle
        dc.l fracleft,fracmode
        dc.l fracright,fracvdraw
        dc.l fracstop,rien
        dc.l fracmore,rien
        dc.l fracless,rien
        dc.l fracchange,rien
        dc.l fracset,rien
        dc.l fracadd,rien
        dc.l rien,rien                  ; idem pour la ligne $b8
        dc.l fracmountain,rien
        dc.l fracdome,rien
        dc.l fracwave,rien
        dc.l fracalea,rien
        dc.l fracclear,rien      
        dc.l fracscope,rien
        dc.l fracwindow,rien
        dc.l fracpal,rien
        dc.l fracvinit,rien
        dc.l fricfrac,rien
even

; Welcome message, in two languages, 40 char max.

welcome:

dc.b 10,"Stos FRACTAL by P. Bodart",0
dc.b 10,"Stos FRACTAL par P. Bodart",0
even

table:  dc.l 0
return: dc.l 0


******************************************
;       INITIALISATION ROUTINES
******************************************

load:   lea finprg,a0           ;A0---> end of the extension
        lea cold,a1             ;A1---> adress of COLD START routine
        rts

cold:   move.l a0,table         ;INPUT: basic table adress
        lea welcome,a0          ;OUTPUT:        A0= welcome message
        lea warm,a1             ;               A1= warm start
        lea tokens,a2           ;               A2= token table
        lea jumps,a3            ;               A3= jump table
        rts   
rien:
warm:   rts


***********************************
;       INTERFACE ROUTINES
***********************************

; ADDRESS TABLE: here is a copy of the basic's address table.
;          dc.l buffer,fltoint,inttofl,dta               ;$00
;          dc.l fichiers,erreur,err2,demande             ;$10
;          dc.l start1,leng1,transmem,fe                 ;$20
;          dc.l jumps,opejumps,evajumps,extfonc          ;$30
;          dc.l dirjumps,extjumps,merreur,vecteurs       ;$40
;          dc.l mode,contrl,intin,ptsin                  ;$50
;          dc.l intout,ptsout,vdipb,chrget               ;$60
;          dc.l chaine,dechaine,active,savect            ;$70
;          dc.l loadvect,menage,adoubank,adecran         ;$80
;          dc.l abck,abis                                ;$90

; Offsets
graphics:       equ $50         ;graphic datas
ptsin:          equ $5c         ;GEM garbage
contrl:         equ $54
vdipb:          equ $68
autob1:         equ $90         ;autoback 1
autob2:         equ $94         ;autoback 2

; Offsets in graphic variables
xxmax:          equ $24         ;X Maximum
yxmax:          equ $28         ;Y
grh:            equ $44         ;GEM graphic handle


************************************
;       ROUTINES
************************************

;------> Pull an integer from the pile. 
; Handle error messages
; In:    D0= number of params left in the pile
; Out:   D3= integer number
integer:
        move.l (sp)+,a0         ;Return address
        tst.w d0                ;If no param---> syntax error
        beq syntax
        movem.l (sp)+,d2-d4     ;Get the param
        tst.b d2        
        bmi typemis             ;If string---> type mismatch
        beq.s endint            ;If integer--> OK
        movem.l d0/d1/d5/d6/d7/a0-a2,-(sp)  
        move.l table,a0         ;Address table
        move.l $04(a0),a0       ;Position 4 in table
        jsr (a0)                ;FL TO INT
        movem.l (sp)+,d0/d1/d5/d6/d7/a0-a2
endint: subq.w #1,d0
        jmp (a0) 

;------> Pull an string from the pile. 
; Handle error messages
; In:    D0.W= number of params left in the pile
; Out:   D2.W= length of the string
;        A2.L= adress of the string
string:
        move.l (sp)+,a0

        tst.w d0                ;If no param---> syntax error
        beq syntax
        movem.l (sp)+,d2-d4     ;Get the param
        tst.b d2        
        bpl typemis             ;If not string---> type mismatch
        move.l d3,a2            ;adress of the string
        move.w (a2)+,d2         ;get length and point string

        subq.w #1,d0 
        jmp (a0)


;-----> Is the parameter a BANK NUMBER or an absolute address?
;       Handle error messages
; In:   D3.L = parameter
; Out:  If absolute address: nothing changed
;       If bank number: check if the bank is reserved
;                       D3.L= start address
adorbank:
        movem.l a0-a2,-(sp)
        move.l table,a0
        move.l $88(a0),a0       ;Have a look at the address table!
        jsr (a0)
        movem.l (sp)+,a0-a2
        rts

;-----> Same as before, but also check if the adress or bank is a screen!
;       Handle error messages
adorscreen:
        movem.l a0-a2,-(sp)
        move.l table,a0
        move.l $8c(a0),a0
        jsr (a0)
        movem.l (sp)+,a0-a2
        rts

;-----> ERROR handling

; Syntax error
syntax: moveq #12,d0
        bra.s error
; Type mismatch
typemis:moveq #19,d0
        bra.s error
; Illegal function call
foncall:moveq #13,d0

; Appel des erreurs
error:  move.l table,a0
        move.l $14(a0),a0
        jmp (a0)   

; Erreur propre a l'extension
formale:
        move.l table,a1
        move.l $18(a1),a1
        moveq #0,d4
        jmp (a1)

; Trouve l'adresse du buffer
GetAd:  movem.l d0-d7/a0-a6,-(sp)
        moveq #14,d3
        move.l table,a0
        move.l $88(a0),a0
        jsr (a0)
        cmp.l #14,d3
        beq.s AdB1
        move.l (a0),d0
        and.l #$ffffff,d0
        cmp.l #13770*3+80000+4,d0
        bcs.s AdB2
        move.l d3,a0
        move.l d3,AdBuf
        move.l #$17121956,(a0)
        addq.l #4,d3
        move.l d3,Altitude
        add.l #80000,d3
        move.l d3,xe
        add.l #13770,d3
        move.l d3,ye
        add.l #13770,d3
        move.l d3,cl
        movem.l (sp)+,d0-d7/a0-a6
        rts
; Bk not reserved
AdB1:   lea Bknot,a2
        bra formale
; Bk too small
AdB2:   lea Bksml,a2
        bra formale

; Verifie que la banque est la...
ChkAd:  move.l a0,-(sp)
        move.l AdBuf,a0
        cmp.l #$17121956,(a0)
        bne.s AdB1
        move.l (sp)+,a0
        rts

***************************************
;       INSTRUCTION: FRACINIT
***************************************
FracInit:
      
        move.l (sp)+,Return
        tst.w d0
        bne Syntax
        bsr GetAd
        movem.l a3-a6,-(sp)

; initialisation des param‚tres fractaux

        move #319,xpmax
        move #199,ypmax
        move #0 ,xsmin
        move #0 ,ysmin
        move #319,xsmax
        move #199,ysmax

        move #200,taille

        move #2,-(sp)
        jsr xbios
        addq.l #2,sp
        move.l D0,video

        move #4,-(sp)
        jsr xbios
        addq.l #2,sp
        move D0,moniteur

        bra IF18
IF19:
        move #160,lgligne
        bra IF17
IF20:
IF21:
        lea erreur0,a2
        bra formale
IF22:
        move #80,lgligne
        bra IF17
IF18:
        tst D0
        beq IF19
        cmp #1,D0
        beq IF20
        cmp #2,D0
        beq IF22
        bra IF21
IF17:

*
* init de d‚part
*
        move.l #171256,fracflag
        clr.w   modeflag

        move ptmax,D0
        ext.l D0
        divs #2,D0
        move D0,portee
        move taille,D0
        asl #6,D0
        move D0,Ymax
        move D0,Xmax
        move Xmax,D0
        ext.l D0
        divs #2,D0
        move D0,Y0
        move D0,X0
        move #100,Z0
        move D0,X
        add  #480,D0
        move D0,Y
        move #100,Z

        clr D0
        move D0,Angle
        move D0,Orientat
        clr D0
        move D0,VZ
        move D0,Vitesse
        clr D0
        move D0,VY
        move D0,VX
        move #5,cran

        move xpmax,D0
        ext.l D0
        divs #2,D0
        add #1,D0
        move D0,ouvertur
        move ypmax,D0
        ext.l D0
        divs #2,D0
        add #1,D0
        move D0,balayage

        bsr calcule
        bsr initvisu

PreRet: movem.l (sp)+,a3-a6
Retour: move.l Return(pc),a0
        jmp (a0)


******************************************
;   INSTRUCTION: FRACVIEW [x,y,z,angle]
******************************************

FracView:
        move.l (sp)+,return             ;Return address
        tst.w d0                        ;Nombre de params
        beq PaParam

        bsr ChkAd

; Get the 4 parameters
        cmp.w #4,d0                     ;SYNTAX ERROR!
        bne syntax 

        bsr integer             ;Get angle
        divs #360,d3
        clr.w d3
        swap d3
        tst.w d3
        bpl PaNeg
        add.w #360,d3
PaNeg:  divu #5,d3
        move.w d3,angle
                
        bsr integer             ;Get Z
        cmp.l #-4096,d3
        blt foncall
        cmp.l #4096,d3
        bge foncall
        move.w d3,Z0

        bsr integer             ;Get Y
        move.w d3,Y0

        bsr integer             ;Get X
        move.w d3,X0

        movem.l a3-a6,-(sp)
        clr.w -(sp)
        jsr incangle
        addq.l #2,sp
        movem.l (sp)+,a3-a6

paparam:
        movem.l a3-a6,-(sp)

        cmp.l #171256,fracflag
        bne.s pap
  
        move.l  $44E,video      ; ecran logique

        jsr calcule
        jsr visualis

        bra preret



pap:    lea papmes,a2
        bra formale


******************************************
;   INSTRUCTION: FRACVINIT Adresse
******************************************

FracVinit:
        move.l (sp)+,return             ;Return address

        cmp.w #1,d0
        bne Syntax

        bsr integer

        movem.l a3-a6,-(sp)

        cmp.l #171256,fracflag
        bne.s pap

        move.l  D3,video      ; adresse ecran decors

        bsr calcule
        bsr initvisu

        bra preret


****************************************
;       FRACVDRAW()
****************************************

FracVdraw:
        move.l (sp)+,Return
        bsr ChkAd
       
        tst.w d0
        bne syntax 
 
        movem.l a3-a6,-(sp)

        bsr visu

*       retourne <0 en fin de trac‚
        ext.l   d0
        move.l d0,d3

        clr.b d2
        bra preret


****************************************
;       FRACBASE()
****************************************

FracBase:
        move.l (sp)+,Return
        bsr ChkAd
       
        tst.w d0
        bne syntax 
 
        movem.l a3-a6,-(sp)

* retourne l'adresse de base du tableau

        move.l altitude,d3

* pour debug
*       lea X1b,a0
*       move.l a0,D3

        clr.b d2
        bra preret


***********************************
;       FRACNEW
***********************************

FracNew:
        move.l (sp)+,Return
        tst.w d0
        bne Syntax
        bsr GetAd

        movem.l a3-a6,-(sp)        
*
* efface le tableau des altitudes
*
        move.l altitude(pc),A5
        move taille(pc),D0
        muls taille(pc),D0
        move.l D0,D6
        asr.l #$4,D6
        bra IF505
IF506:
        move #15,(A5)+
        move #14,(A5)+
        move #13,(A5)+
        move #12,(A5)+
        move #11,(A5)+
        move #10,(A5)+
        move #9,(A5)+
        move #8,(A5)+
        move #7,(A5)+
        move #6,(A5)+
        move #5,(A5)+
        move #4,(A5)+
        move #3,(A5)+
        move #2,(A5)+
        move #1,(A5)+
        clr (A5)+

        sub.l #$1,D6
IF505:
        tst.l D6
        bgt IF506

        bra PreRet


************************************
;       FRACLOAD "nomfichier
************************************

FracLoad:
        move.l (sp)+,Return
        bsr GetAd

        cmp.w #1,d0
        bne Syntax
        bsr String
        cmp.w #128,d2
        bcc foncall
        move.l Table(pc),a0
        move.l (a0),a0
        move.l a0,tpg
        subq.w #1,d2
        bmi foncall
Fcl:    move.b (a2)+,(a0)+
        dbra d2,Fcl
        clr.b (a0)
        movem.l a3-a6,-(sp)        

        bsr chargetpg

        bra preret
        

***************************************
;       FRACSAVE "nomfichier
***************************************

FracSave:
        move.l (sp)+,Return
        bsr GetAd

        cmp.w #1,d0
        bne Syntax
        bsr String
        cmp.l #128,d2
        bcc foncall
        move.l Table(pc),a0
        move.l (a0),a0
        move.l a0,tpg
        subq.w #1,d2
        bmi foncall
Fcs:    move.b (a2)+,(a0)+
        dbra d2,Fcs
        clr.b (a0)
        movem.l a3-a6,-(sp)        

        bsr sauvetpg

        bra preret


***********************************
;       FRACALT(X,Y)
***********************************

FracAlt:
        move.l (sp)+,Return
        bsr ChkAd
       
        cmp.w #2,d0
        bne syntax 

; demande l'altitude du point X,Y
        bsr integer
        move.w d3,X
        bsr integer
        move.w d3,Y

        movem.l a3-a6,-(sp)

* X=8
* Y=10
* pcol=12
        pea pile(pc)
        move    Y(pc),-(sp)
        move    X(pc),-(sp)
        bsr altimetr
        addq.l  #8,sp
        move.w D0,X1b   ; Z1 alt de X,Y

        add.w #64,X
        pea pile(pc)
        move    Y(pc),-(sp)
        move    X(pc),-(sp)
        bsr altimetr
        addq.l  #8,sp
        move.w D0,Y1b   ; Z2 alt de X+64,Y

        add.w #64,Y
        pea pile(pc)
        move    Y(pc),-(sp)
        move    X(pc),-(sp)
        bsr altimetr
        addq.l  #8,sp
        move.w D0,Y2b   ; Z4 alt de X+64,Y+64

        sub.w #64,X
        pea pile(pc)
        move    Y(pc),-(sp)
        move    X(pc),-(sp)
        bsr altimetr
        addq.l  #8,sp
        move.w D0,X2b   ; Z3 alt de X,Y+64

        sub.w #64,Y
test:
        move X(pc),D0
        move.w D0,D1
        asr.w #6,D1
        asl.w #6,D1
        sub.w D1,D0
        move.w Y1b(pc),D1
        sub.w  X1b(pc),D1
        muls D1,D0
        asr.w #6,D0
        add.w X1b(pc),D0
        move.w D0,D2    ; za

        move X(pc),D0
        move.w D0,D1
        asr.w #6,D1
        asl.w #6,D1
        sub.w D1,D0
        move.w Y2b(pc),D1
        sub.w  X2b(pc),D1
        muls D1,D0
        asr.w #6,D0
        add.w X2b(pc),D0
        move.w D0,D3    ; zb

        move Y(pc),D0
        move.w D0,D1
        asr.w #6,D1
        asl.w #6,D1
        sub.w D1,D0
        move.w D3,D1
        sub.w  D2,D1
        muls D1,D0
        asr.w #6,D0
        add.w D2,D0     ;z

fin:
        move.w d0,d3
        ext.l d3
        clr.l d2
        bra PreRet


*************************************
;       FRACCOLOR(X,Y)
*************************************

FracColor:
        move.l (sp)+,Return
        bsr ChkAd
       
        cmp.w #2,d0
        bne syntax 

        bsr integer
        move.w d3,X
        bsr integer
        move.w d3,Y

        movem.l a3-a6,-(sp)
; demande de la  couleur du point

        pea pile(pc)
        move    Y(pc),-(sp)
        move    X(pc),-(sp)
* X=8
* Y=10
* pcol=12
        bsr altimetr
        addq.l  #8,sp
        move.w pile(pc),d3
        ext.l d3
        clr.l d2
        bra PreRet


*******************************
;       FRACMOVE
*******************************

FracMove:
        move.l (sp)+,Return
        bsr ChkAd
       
        tst.w d0
        bne syntax 

        movem.l a3-a6,-(sp)

; d‚place le point a vitesse constante
        move VX(pc),D0
        add D0,X0
        tst X0
        bge FM130
        move Xmax(pc),D0
        sub #1,D0
        move D0,X0
FM130:
        move X0,D0
        cmp Xmax(pc),D0
        blt FM131
        clr X0

FM131:
        move VY(pc),D0
        add D0,Y0
        tst Y0
        bge FM132
        move Ymax(pc),D0
        sub #1,D0
        move D0,Y0
FM132:
        move Y0(pc),D0
        cmp Ymax(pc),D0
        blt FM133
        clr Y0
FM133:
        bra PreRet


***********************************
;       FRACSTOP
***********************************

FracStop:
        move.l (sp)+,Return
        bsr ChkAd
       
        tst.w d0
        bne syntax 

        movem.l a3-a6,-(sp)

; Arret du d‚placement

        clr Vitesse
        clr VX
        clr VY
        clr VZ

        bra preret


************************************
;       FRACLESS
************************************

FracLess:
        move.l (sp)+,Return
        bsr ChkAd
       
        tst.w d0
        bne syntax 

        movem.l a3-a6,-(sp)
; diminue la vitesse

        move cran(pc),D0
        sub D0,Vitesse
        cmp #-32000,Vitesse
        bge L149
        move #-32000,Vitesse
L149:
        move Angle(pc),A0
        add.l A0,A0
        add.l A0,A0
        move.l #projecti,A1
        move 2(A0,A1.l),D0
        muls Vitesse(pc),D0
        move.l #$a,D1
        asr.l D1,D0
        neg.l D0
        move D0,VX

        move Angle(pc),A0
        add.l A0,A0
        add.l A0,A0
        move.l #projecti,A1
        move 0(A0,A1.l),D0
        muls Vitesse(pc),D0
        move.l #$a,D1
        asr.l D1,D0
        move D0,VY

        bra preret


**********************************
;       FRACMORE
**********************************

FracMore:
        move.l (sp)+,Return
        bsr ChkAd
       
        tst.w d0
        bne syntax 

        movem.l a3-a6,-(sp)
; augmente la vitesse

        move cran(pc),D0
        add D0,Vitesse
        cmp #32000,Vitesse
        ble L151
        move #32000,Vitesse
L151:
        move Angle(pc),A0
        add.l A0,A0
        add.l A0,A0
        move.l #projecti,A1
        move 2(A0,A1.l),D0
        muls Vitesse(pc),D0
        move.l #$a,D1
        asr.l D1,D0
        neg.l D0
        move D0,VX

        move Angle(pc),A0
        add.l A0,A0
        add.l A0,A0
        move.l #projecti,A1
        move 0(A0,A1.l),D0
        muls Vitesse(pc),D0
        move.l #$a,D1
        asr.l D1,D0
        move D0,VY

        bra preret


***********************************
;       FRACLEFT
***********************************

FracLeft:
        move.l (sp)+,Return
        bsr ChkAd
       
        tst.w d0
        bne syntax 

        movem.l a3-a6,-(sp)
; tourne le champ de vision … gauche

        move #-1,(sp)
        bsr incangle
        bra preret


****************************************
;       FRACRIGHT
****************************************

FracRight:
        move.l (sp)+,Return
        bsr ChkAd
       
        tst.w d0
        bne syntax 

        movem.l a3-a6,-(sp)
; tourne le champ de vision … droite

        move #1,(sp)
        bsr incangle
        bra preret


******************************************
;       FRACUP
******************************************

FracUp:
        move.l (sp)+,Return
        bsr ChkAd
       
        tst.w d0
        bne syntax 

        movem.l a3-a6,-(sp)
; monte le point d'observation

        tst VZ
        bge L138
        clr VZ
L138:
        move cran(pc),D0
        add D0,VZ
        cmp #320,VZ
        ble L139
        move #320,VZ
L139:
        move VZ(pc),D0
        add D0,Z0
        cmp #320,Z0
        ble L140
        move #320,Z0
L140:
        bra preret


****************************************
;       FRACDOWN
****************************************

FracDown:
        move.l (sp)+,Return
        bsr ChkAd
       
        tst.w d0
        bne syntax 

        movem.l a3-a6,-(sp)
; descend le point d'observation

        tst VZ
        ble L142
        clr VZ
L142:
        move cran(pc),D0
        sub D0,VZ
        cmp #-320,VZ
        bge L143
        move #-320,VZ
L143:
        move VZ(pc),D0
        add D0,Z0
        cmp #-320,Z0
        bge L144
        move #-320,Z0
L144:
        bra preret


***************************************
;       FRACCHANGE X,Y,Couleur
***************************************

FracChange:
        move.l (sp)+,Return
        bsr ChkAd
       
        cmp.w #3,d0
        bne syntax 
        bsr integer
        cmp.l #16,d3
        bhi foncall
        move.w d3,couleur
        bsr integer
        move.w d3,Y
        bsr integer
        move.w d3,X

        movem.l a3-a6,-(sp)
; change la couleur du point X,Y par [couleur]

        link A6,#0
        movem.l D5-D7,-(sp)

* IX=D7
* IY=D6
* i=D5
*
        move   X(pc),D7
        tst    D7
        blt.s FC1
*
        asr    #6,D7
        cmp    taille(pc),D7
        blt.s FC10
        sub    taille(pc),D7
        bra.s FC10
*
FC1:
        neg    D7
        asr    #6,D7
        neg    D7
        add    taille(pc),D7
        subq   #1,D7
*
*
FC10:
        move   Y,D6
        tst    D6
        blt.s FC11
*
        asr    #6,D6
        cmp    taille(pc),D6
        blt.s FC20
        sub    taille(pc),D6
        bra.s FC20
*
FC11:
        neg    D6
        asr    #6,D6
        neg    D6
        add    taille(pc),D6
        subq   #1,D6
*
*
FC20:
*
* codage du tableau
* des altitudes :
* bit 0 a 3 = couleur
*   (de 0 a 15)
* bit 4 a 15= hauteur
* ( de -4096 a 4095 m) 
*
        muls   taille(pc),D6
        add.l  D6,D6
        asl    #1,D7
        move   D7,A0
        add.l  D6,A0
        add.l  altitude(pc),A0
        move (A0),D0
*
        and #$FFF0,D0
        add couleur(pc),d0
        move D0,(A0)
*
        movem.l (sp)+,D5-D7
        unlk A6
        bra preret


**************************************
;       FRACADD X,Y,Amplitude
**************************************

FracAdd:
        move.l (sp)+,Return
        bsr ChkAd
       
        cmp.w #3,d0
        bne syntax
 
        bsr integer
        cmp.l #-256,d3
        blt foncall
        cmp.l #256,d3 
        bge foncall
        move.w d3,constant

        bsr integer
        move.w d3,Y

        bsr integer
        move.w d3,X

        movem.l a3-a6,-(sp)

; augmente l'altitude de X,Y de constante

        link A6,#0
        movem.l D5-D7,-(sp)

* IX=D7
* IY=D6
* i=D5
*
        move   X,D7
        tst    D7
        blt.s FA1
*
        asr    #6,D7
        cmp    taille(pc),D7
        blt.s FA10
        sub    taille(pc),D7
        bra.s FA10
*
FA1:
        neg    D7
        asr    #6,D7
        neg    D7
        add    taille(pc),D7
        subq   #1,D7
*
*
FA10:
        move   Y,D6
        tst    D6
        blt.s FA11
*
        asr    #6,D6
        cmp    taille(pc),D6
        blt.s FA20
        sub    taille(pc),D6
        bra.s FA20
*
FA11:
        neg    D6
        asr    #6,D6
        neg    D6
        add    taille(pc),D6
        subq   #1,D6
*
*
FA20:
*
* codage du tableau
* des altitudes :
* bit 0 a 3 = couleur
*   (de 0 a 15)
* bit 4 a 15= hauteur
* ( de -4096 a 4095 m) 
*
        muls   taille(pc),D6
        add.l  D6,D6
        asl    #1,D7
        move   D7,A0
        add.l  D6,A0
        add.l  altitude(pc),A0
        move (A0),D0

        move constant(pc),d5
        asl #4,D5
        add D5,D0
        move D0,(A0)
*
        movem.l (sp)+,D5-D7
        unlk A6
        bra preret


******************************************
;       FRACSET X,Y,Altitude
******************************************

FracSet:
        move.l (sp)+,Return
        bsr ChkAd
       
        cmp.w #3,d0
        bne syntax 

        bsr integer
        cmp.l #-4096,d3
        blt foncall
        cmp.l #4096,d3 
        bge foncall
        move.w d3,constant

        bsr integer
        move.w d3,Y

        bsr integer
        move.w d3,X

        movem.l a3-a6,-(sp)

; fixe l'altitude de X,Y … constante

        link A6,#0
        movem.l D5-D7,-(sp)

* IX=D7
* IY=D6
* i=D5
*
        move   X(pc),D7
        tst    D7
        blt.s FS1
*
        asr    #6,D7
        cmp    taille(pc),D7
        blt.s FS10
        sub    taille(pc),D7
        bra.s FS10
*
FS1:
        neg    D7
        asr    #6,D7
        neg    D7
        add    taille(pc),D7
        subq   #1,D7
*
*
FS10:
        move   Y(pc),D6
        tst    D6 
        blt.s FS11
*
        asr    #6,D6
        cmp    taille(pc),D6
        blt.s FS20
        sub    taille(pc),D6
        bra.s FS20
*
FS11:
        neg    D6
        asr    #6,D6
        neg    D6
        add    taille(pc),D6
        subq   #1,D6
*
*
FS20:
*
* codage du tableau
* des altitudes :
* bit 0 a 3 = couleur
*   (de 0 a 15)
* bit 4 a 15= hauteur
* ( de -4096 a 4095 m) 
*
        muls   taille(pc),D6
        add.l  D6,D6
        asl    #1,D7
        move   D7,A0
        add.l  D6,A0
        add.l  altitude(pc),A0
        move (A0),D0

        and #$FFF0,D0
        move constant(pc),D5
        asl #4,D5
        add D5,D0
        move D0,(A0)
*
        movem.l (sp)+,D5-D7
        unlk A6
        bra preret


******************************************
;       FRAMOUNTAIN X,Y,Amplitude
******************************************

FracMountain:
        move.l (sp)+,Return
        bsr ChkAd
       
        cmp.w #3,d0
        bne syntax 

        bsr integer
        cmp.l #-256,d3
        blt foncall
        cmp.l #256,d3 
        bge foncall
        move.w d3,constant

        bsr integer
        move.w d3,Y

        bsr integer
        move.w d3,X

        movem.l a3-a6,-(sp)

; g‚n‚re un pic de valeur [constante] en X,Y

        link A6,#0
        movem.l D6-D7,-(sp)

* IX=D7
* IY=D6

        move   X(pc),D7
        tst    D7
        blt.s FM1
*
        asr    #6,D7
        cmp    taille(pc),D7
        blt.s FM10
        sub    taille(pc),D7
        bra.s FM10
*
FM1:
        neg    D7
        asr    #6,D7
        neg    D7
        add    taille(pc),D7
        subq   #1,D7
*
*
FM10:
        move   Y(pc),D6
        tst    D6
        blt.s FM11
*
        asr    #6,D6
        cmp    taille(pc),D6
        blt.s FM20
        sub    taille(pc),D6
        bra.s FM20
*
FM11:
        neg    D6
        asr    #6,D6
        neg    D6
        add    taille(pc),D6
        subq   #1,D6
*
*
FM20:
*
        move   D6,-(sp)
        move   D7,-(sp)
        bsr    montagne
        addq.l #4,sp

        movem.l (sp)+,D6-D7
        unlk A6
        bra preret


*****************************************
;       FRACDOME X,Y,Amplitude
*****************************************

FracDome:
        move.l (sp)+,Return
        bsr ChkAd
       
        cmp.w #3,d0
        bne syntax 

        bsr integer
        cmp.l #-256,d3
        blt foncall
        cmp.l #256,d3 
        bge foncall
        move.w d3,constant

        bsr integer
        move.w d3,Y

        bsr integer
        move.w d3,X

        movem.l a3-a6,-(sp)

; g‚n‚re un dome de valeur [constante] en X,Y

        link A6,#0
        movem.l D6-D7,-(sp)

* IX=D7
* IY=D6

        move   X(pc),D7
        tst    D7
        blt.s FO1
*
        asr    #6,D7
        cmp    taille(pc),D7
        blt.s FO10
        sub    taille(pc),D7
        bra.s FO10
*
FO1:
        neg    D7
        asr    #6,D7
        neg    D7
        add    taille(pc),D7
        subq   #1,D7
*
*
FO10:
        move   Y(pc),D6
        tst    D6
        blt.s FO11
*
        asr    #6,D6
        cmp    taille(pc),D6
        blt.s FO20
        sub    taille(pc),D6
        bra.s FO20
*
FO11:
        neg    D6
        asr    #6,D6
        neg    D6
        add    taille(pc),D6
        subq   #1,D6
*
*
FO20:
*
        move   D6,-(sp)
        move   D7,-(sp)
        bsr    dome
        addq.l #4,sp

        movem.l (sp)+,D6-D7
        unlk A6
        bra preret


*******************************************
;       FRACWAVE X1,Y1,X2,Y2,Amplitude
*******************************************

FracWave:
        move.l (sp)+,Return
        bsr ChkAd
       
        cmp.l #171256,fracflag
        bne pap

        move X1,X1b
        move X2,X2b
        move Y1,Y1b
        move Y2,Y2b

        cmp.w #5,d0
        bne syntax 

        bsr integer
        cmp.l #-256,d3
        blt foncall
        cmp.l #256,d3 
        bge foncall
        move.w d3,constant

        bsr integer
        move.w d3,Y2

        bsr integer
        move.w d3,X2

        bsr integer
        move.w d3,Y1

        bsr integer
        move.w d3,X1

        move.w taille(pc),d3
        lsl.w #6,d3
        move.w X1(pc),d0
        move.w X2(pc),d1
fw10:
        tst.w d0
        bge.s fw11
        clr d0
fw11:
        cmp.w d3,d1
        ble.s fw12
        move.w d3,d1
fw12:
        move.w d0,X1
        move.w d1,X2
        cmp.w d0,d1
        bge.s fw13
        move X2(pc),d0
        move X1(pc),d1
        bra.s fw10
fw13:
        move.w Y1(pc),d0
        move.w Y2(pc),d1
fw20:
        tst.w d0
        bge.s fw21
        clr d0
fw21:
        cmp.w d3,d1
        ble.s fw22
        move.w d3,d1
fw22:
        move.w d0,Y1
        move.w d1,Y2
        cmp.w d0,d1
        bge.s fw23
        move Y2(pc),d0
        move Y1(pc),d1
        bra.s fw20

fw23:
        movem.l a3-a6,-(sp)

; g‚n‚re des vagues sur le champ de vision
                    ; amplitude [constante]

        bsr onde
 
        move X1b,X1
        move X2b,X2
        move Y1b,Y1
        move Y2b,Y2

        bra preret


*******************************************
;       FRACALEA X1,Y1,X2,Y2,Amplitude
*******************************************

FracAlea:
        move.l (sp)+,Return
        bsr ChkAd
       
        cmp.l #171256,fracflag
        bne pap

        move X1,X1b
        move X2,X2b
        move Y1,Y1b
        move Y2,Y2b

        cmp.w #5,d0
        bne syntax 

        bsr integer
        cmp.l #-256,d3
        blt foncall
        cmp.l #256,d3 
        bge foncall
        move.w d3,constant

        bsr integer
        move.w d3,Y2

        bsr integer
        move.w d3,X2

        bsr integer
        move.w d3,Y1

        bsr integer
        move.w d3,X1

        move.w taille(pc),d3
        lsl.w #6,d3
        move.w X1(pc),d0
        move.w X2(pc),d1
fal10:
        tst.w d0
        bge.s fal11
        clr d0
fal11:
        cmp.w d3,d1
        ble.s fal12
        move.w d3,d1
fal12:
        move.w d0,X1
        move.w d1,X2
        cmp.w d0,d1
        bge.s fal13
        move X2(pc),d0
        move X1(pc),d1
        bra.s fal10
fal13:
        move.w Y1(pc),d0
        move.w Y2(pc),d1
fal20:
        tst.w d0
        bge.s fal21
        clr d0
fal21:
        cmp.w d3,d1
        ble.s fal22
        move.w d3,d1
fal22:
        move.w d0,Y1
        move.w d1,Y2
        cmp.w d0,d1
        bge.s fal23
        move Y2(pc),d0
        move Y1(pc),d1
        bra.s fal20

fal23:
        movem.l a3-a6,-(sp)

; g‚n‚re des brissures sur le champ de vision
                    ; amplitude [constante]

        bsr fractal

        move X1b,X1
        move X2b,X2
        move Y1b,Y1
        move Y2b,Y2

        bra preret


******************************************
;       FRACCLEAR X1,Y1,X2,Y2,Amplitude
******************************************

FracClear:
        move.l (sp)+,Return
        bsr ChkAd
       
        cmp.l #171256,fracflag
        bne pap

        move X1,X1b
        move X2,X2b
        move Y1,Y1b
        move Y2,Y2b

        cmp.w #5,d0
        bne syntax 

        bsr integer
        cmp.l #-256,d3
        blt foncall
        cmp.l #256,d3 
        bge foncall
        move.w d3,constant

        bsr integer
        move.w d3,Y2

        bsr integer
        move.w d3,X2

        bsr integer
        move.w d3,Y1

        bsr integer
        move.w d3,X1

        move.w taille(pc),d3
        lsl.w #6,d3
        move.w X1(pc),d0
        move.w X2(pc),d1
fcl10:
        tst.w d0
        bge.s fcl11
        clr d0
fcl11:
        cmp.w d3,d1
        ble.s fcl12
        move.w d3,d1
fcl12:
        move.w d0,X1
        move.w d1,X2
        cmp.w d0,d1
        bge.s fcl13
        move X2(pc),d0
        move X1(pc),d1
        bra.s fcl10
fcl13:
        move.w Y1(pc),d0
        move.w Y2(pc),d1
fcl20:
        tst.w d0
        bge.s fcl21
        clr d0
fcl21:
        cmp.w d3,d1
        ble.s fcl22
        move.w d3,d1
fcl22:
        move.w d0,Y1
        move.w d1,Y2
        cmp.w d0,d1
        bge.s fcl23
        move Y2(pc),d0
        move Y1(pc),d1
        bra.s fcl20

fcl23:

        movem.l a3-a6,-(sp)

; efface une partie du d‚cors
        bsr efface

        move X1b,X1
        move X2b,X2
        move Y1b,Y1
        move Y2b,Y2

        bra preret


**************************************
;       FRACSCOPE portee
**************************************

FracScope:
        move.l (sp)+,Return
        bsr ChkAd
       
        cmp.w #1,d0
        bne syntax 
        bsr integer

        move.w d3,d0
 
        movem.l a3-a6,-(sp)
; fixe le champ de vision
        move.w d0,portee
        cmp ptmax(pc),D0
        ble LS0
        move ptmax(pc),portee
LS0:
        move portee(pc),D0
        cmp ptmin(pc),D0
        bge LS1
        move ptmin(pc),portee
LS1:
        bra preret


*************************************
;       FRACX()
*************************************

FracX:
        bsr ChkAd
       
        tst.w d0
        bne syntax 
 
        move.w X0(pc),d3
        ext.l d3
        clr.b d2
        rts


*************************************
;       FRACY()
*************************************

FracY:
        bsr ChkAd
       
        tst.w d0
        bne syntax 
 
        move.w Y0(pc),d3
        ext.l d3
        clr.b d2
        rts


*************************************
;       FRACZ()
*************************************

FracZ:
        bsr ChkAd
       
        tst.w d0
        bne syntax 
 
        move.w Z0(pc),d3
        ext.l d3
        clr.b d2
        rts


**************************************
;       FRACANGLE()
**************************************

FracAngle:
        bsr ChkAd
       
        tst.w d0
        bne syntax 
 
        move.w angle(pc),d3
        muls #5,d3
        clr.b d2
        rts


***************************************
;       FRACSPEED()
***************************************

FracSpeed:
        bsr ChkAd
       
        tst.w d0
        bne syntax 
 
        move.w vitesse(pc),d3
        ext.l d3
        clr.b d2
        rts


***************************************
;       FRACMODE()
***************************************

FracMode:
        bsr ChkAd
       
        tst.w d0
        bne syntax 
 
        move.w  modeflag(pc),d3
        subq    #1,d3
        beq.s ffmm1
        moveq   #1,d3
ffmm1:
        move.w  d3,modeflag
        ext.l   d3
        clr.b   d2
        rts


****************************************
;       FRACPAL
****************************************

FracPal:
        bsr ChkAd
       
        tst.w d0
        bne syntax 

        beq Palette


*****************************************
;       FRACWINDOW x1,y1,x2,y2
*****************************************

FracWindow:
        move.l (sp)+,return
        bsr GetAd
       
        cmp.l #171256,fracflag
        bne pap

        cmp.w #4,d0
        bne syntax 

        bsr integer
        tst moniteur
        beq.s wd1
        asr #1,d3
wd1:    move.w d3,ysmax

        bsr integer
        tst moniteur
        beq.s wd2
        asr #1,d3
wd2:    move.w d3,xsmax

        bsr integer
        tst moniteur
        beq.s wd3
        asr #1,d3
wd3:    move.w d3,ysmin

        bsr integer
        tst moniteur
        beq.s wd4
        asr #1,d3
wd4:    move.w d3,xsmin

wd0:
        move.w xsmin(pc),d0
        move.w xsmax(pc),d1
wd10:
        tst.w d0
        bge.s wd11
        clr d0
wd11:
        cmp.w xpmax(pc),d1
        ble.s wd12
        move xpmax(pc),d1
wd12:
        move.w d0,xsmin
        move.w d1,xsmax
        cmp.w d0,d1
        bge.s wd13
        move xsmax(pc),d0
        move xsmin(pc),d1
        bra.s wd10
wd13:
        move.w ysmin(pc),d0
        move.w ysmax(pc),d1
wd20:
        tst.w d0
        bge.s wd21
        clr.w d0
wd21:
        cmp.w ypmax(pc),d1
        ble.s wd22
        move.w ypmax(pc),d1
wd22:
        move.w d0,ysmin
        move.w d1,ysmax
        cmp.w d0,d1
        bge.s wd23
        move.w ysmax(pc),d0
        move.w ysmin(pc),d1
        bra.s wd20

wd23:
         bra retour
         

**************************************
;       FRICFRAC
**************************************

FricFrac:
        lea kikimes,a2
        bra formale


* variables

pile:           dc.l 0
videobis:       dc.l 0

fvt:            dc.l 0
fvv:            dc.l 0
fvr:            dc.l 0
fvs:            dc.l 0
fvtc:           dc.l 0
fvtc0:          dc.l 0
fvx:            dc.w 0
fvy:            dc.w 0
fvn:            dc.w 0
fvk:            dc.w 0
fvxe1:          dc.w 0
fvxe2:          dc.w 0
fvxe3:          dc.w 0
fvxe4:          dc.w 0

ptmax:          dc.w 3200
ptmin:          dc.w 192
X:              dc.w 7420
Y:              dc.w 6450
Z:              dc.w 0
couleur:        dc.w 1
constant:       dc.w 25
fracflag:       dc.l 0
modeflag:       dc.w 0
tpg:            dc.l 0 

tablefractale:

video:          dc.l 0
xpmax:          dc.w 319
ypmax:          dc.w 199
xsmin:          dc.w 0
xsmax:          dc.w 319
ysmin:          dc.w 0
ysmax:          dc.w 199
moniteur:       dc.w 2
lgligne:        dc.w 80

ouvertur:       dc.w 0
portee:         dc.w 0
balayage:       dc.w 0
hauteur:        dc.w 0
largeur:        dc.w 0

Angle:          dc.w 0
Orientat:       dc.w 0
Xmax:           dc.w 0
Ymax:           dc.w 0
X0:             dc.w 0
Y0:             dc.w 0
Z0:             dc.w 0
X1:             dc.w 0
Y1:             dc.w 0
X2:             dc.w 0
Y2:             dc.w 0
X1b:            dc.w 30
Y1b:            dc.w 30
X2b:            dc.w 0
Y2b:            dc.w 0
X3b:            dc.w 30
Y3b:            dc.w 30
X4b:            dc.w 0
Y4b:            dc.w 0
Vitesse:        dc.w 0
VX:             dc.w 0
VY:             dc.w 0
VZ:             dc.w 0
cran:           dc.w 0

projecti:
dc.w $400
dc.w $0
dc.w $3FC
dc.w $59
dc.w $3F0
dc.w $B1
dc.w $3DD
dc.w $109
dc.w $3C2
dc.w $15E
dc.w $3A0
dc.w $1B0
dc.w $376
dc.w $200
dc.w $346
dc.w $24B
dc.w $310
dc.w $292
dc.w $2D4
dc.w $2D4
dc.w $292
dc.w $310
dc.w $24B
dc.w $346
dc.w $200
dc.w $376
dc.w $1B0
dc.w $3A0
dc.w $15E
dc.w $3C2
dc.w $109
dc.w $3DD
dc.w $B1
dc.w $3F0
dc.w $59
dc.w $3FC
dc.w $0
dc.w $400
dc.w $FFA7
dc.w $3FC
dc.w $FF4F
dc.w $3F0
dc.w $FEF7
dc.w $3DD
dc.w $FEA2
dc.w $3C2
dc.w $FE50
dc.w $3A0
dc.w $FE00
dc.w $376
dc.w $FDB5
dc.w $346
dc.w $FD6E
dc.w $310
dc.w $FD2C
dc.w $2D4
dc.w $FCF0
dc.w $292
dc.w $FCBA
dc.w $24B
dc.w $FC8A
dc.w $200
dc.w $FC60
dc.w $1B0
dc.w $FC3E
dc.w $15E
dc.w $FC23
dc.w $109
dc.w $FC10
dc.w $B1
dc.w $FC04
dc.w $59
dc.w $FC00
dc.w $0
dc.w $FC04
dc.w $FFA7
dc.w $FC10
dc.w $FF4F
dc.w $FC23
dc.w $FEF7
dc.w $FC3E
dc.w $FEA2
dc.w $FC60
dc.w $FE50
dc.w $FC8A
dc.w $FE00
dc.w $FCBA
dc.w $FDB5
dc.w $FCF0
dc.w $FD6E
dc.w $FD2C
dc.w $FD2C
dc.w $FD6E
dc.w $FCF0
dc.w $FDB5
dc.w $FCBA
dc.w $FE00
dc.w $FC8A
dc.w $FE50
dc.w $FC60
dc.w $FEA2
dc.w $FC3E
dc.w $FEF7
dc.w $FC23
dc.w $FF4F
dc.w $FC10
dc.w $FFA7
dc.w $FC04
dc.w $0
dc.w $FC00
dc.w $59
dc.w $FC04
dc.w $B1
dc.w $FC10
dc.w $109
dc.w $FC23
dc.w $15E
dc.w $FC3E
dc.w $1B0
dc.w $FC60
dc.w $200
dc.w $FC8A
dc.w $24B
dc.w $FCBA
dc.w $292
dc.w $FCF0
dc.w $2D4
dc.w $FD2C
dc.w $310
dc.w $FD6E
dc.w $346
dc.w $FDB5
dc.w $376
dc.w $FE00
dc.w $3A0
dc.w $FE50
dc.w $3C2
dc.w $FEA2
dc.w $3DD
dc.w $FEF7
dc.w $3F0
dc.w $FF4F
dc.w $3FC
dc.w $FFA7

taille:         dc.w  200
AdBuf:          dc.l 0
altitude:       dc.l 0
xe:             dc.l 0
ye:             dc.l 0
cl:             dc.l 0

* palette initiale
colpal:         dc.w $000
                dc.w $777
                dc.w $555
                dc.w $333
                dc.w $770
                dc.w $700
                dc.w $630
                dc.w $520
                dc.w $432
                dc.w $070
                dc.w $360
                dc.w $050
                dc.w $007
                dc.w $005
                dc.w $234
                dc.w $557

erreur0:
  dc.b "mode 320x200 or 640x400 only",0
  dc.b "mode 320x200 ou 640x400 seulement",0
erreur2:
  dc.b "Can't open fractal file",0
  dc.b "Ouverture impossible du fichier fractal",0
erreur3:
  dc.b "Loading error of fractal file",0
  dc.b "Erreur de chargement du fichier fractal",0
erreur4:
  dc.b "Writing error of fractal file",0
  dc.b "Erreur d'ecriture du fichier fractal",0
erreur9:
  dc.b "This file is not a TPG",0
  dc.b "Ce fichier n'est pas un format TPG",0
bknot:
  dc.b "Memory bank 14 not reserved",0
  dc.b "Banque memoire 14 non r‚serv‚e",0
bksml:
  dc.b "Bank 14: 121500 bytes mini",0
  dc.b "Banque 14: 121500 octets mini",0 
papmes:
  dc.b "Fractal not initialised",0
  dc.b "Fractal non initialis‚",0
kikimes:
  dc.b "This wonderfull extension was brought",13,10
  dc.b "to you by Pascal Bodart (BRAVOBRAVO)",13,10
  dc.b "and Francois Lionet (BOOBOOBOO) in a",13,10
  dc.b "exitation state close to hysteria!",13,10
  dc.b "Fractal Error ",0
  dc.b "Cette magnifique extension vous ‚tait",13,10
  dc.b "pr‚sent‚e par Pascal Bodart (BRAVOBRAVO)",13,10
  dc.b "et Francois Lionet (HOUHOUHOU) dans un",13,10
  dc.b "d'excitation proche de l'hyst‚rie!",13,10
  dc.b "Fractal Erreur ",0
even


***********************************
; interfaces avec la ROM
; -(sp) : num‚ro de fonction
;       + param‚tres
***********************************

gemdos:
        move.l  (sp)+, pile
        trap #1
        move.l  pile, -(sp)
        rts

xbios:
        move.l  (sp)+, pile
        trap #14
        move.l  pile, -(sp)
        rts

bios:
        move.l  (sp)+, pile
        trap #13
        move.l  pile, -(sp)
        rts


calcule:
        link A6,#-36
        movem.l D3-D7/A3-A5,-(sp)
*
* lg1=-4
* lg2=-8
* xe1=-10
* xe2=-12
* xe3=-14
* xe4=-16
* i=-18
* j=-20
* n=-22
* k=-24
* flag=-26
* cosinus=-28
* sinus=-30
* a=-32
* b=-34
* c=-36
* t=A5
* r=A4
* tc=A3
* x=D7
* y=D6
* X=D5
* Y=D4
*
* cos de Angle
move Angle,A0
add.l A0,A0
add.l A0,A0
add.l #projecti,A0
move (A0),-28(A6)
*
* sin de Angle
move 2(A0),-30(A6)
*
move ouvertur,-32(A6)
move portee,-34(A6)
move balayage,-36(A6)
*
move.l xe,A5
move.l ye,A4
move.l cl,A3
*
* D3 : SHIFT
moveq  #10,D3
*
move Orientat,D0
bra CA09
*
*
CA10:
* case 0:
*
* X1
move   -34(A6),D0
muls   -28(A6),D0
neg.l  D0
move   -34(A6),D1
muls   -30(A6),D1
sub.l  D1,D0
asr.l  D3,D0
add    X0,D0
move   D0,X1
*
* Y1
move   -34(A6),D0
muls   -30(A6),D0
neg.l  D0
move   -34(A6),D1
muls   -28(A6),D1
add.l  D1,D0
asr.l  D3,D0
add    Y0,D0
move   D0,Y1
*
* X2
move   -34(A6),D0
muls   -28(A6),D0
move   -34(A6),D1
muls   -30(A6),D1
sub.l  D1,D0
asr.l  D3,D0
add    X0,D0
move   D0,X2
*
* Y2
move   -34(A6),D0
muls   -30(A6),D0
move   -34(A6),D1
muls   -28(A6),D1
add.l  D1,D0
asr.l  D3,D0
add    Y0,D0
move   D0,Y2
*
*
move Y1,D0
cmp Y2,D0
ble.s CA11
*
move Y1,Y2
*
CA11:
move Y1,D0
cmp Y0,D0
ble.s CA12
*
move Y0,Y1
*
CA12:
add    #64,X2
*
and    #-64,X1
and    #-64,X2
and    #-64,Y1
and    #-64,Y2
*
* boucle sur Y
move   Y1,D4
clr    -22(A6)
bra CA15
*
CA16:
*
move   D4,D0
sub    Y0,D0
move   D0,D1
muls   -28(A6),D0
move.l D0,-4(A6)
*
muls   -30(A6),D1
move.l D1,-8(A6)
*
* boucle sur X
move   X1,D5
clr    -24(A6)
bra CA19
*
CA20:
*
* y = D6
move.l -4(A6),D6
move   D5,D1
sub    X0,D1
* D2 = X - X0
move   D1,D2
muls   -30(A6),D1
sub.l  D1,D6
asr.l  D3,D6
*
* if y > 0
tst D6
ble CA21
*
* condition remplie
* x = D7
move.l -8(A6),D7
muls   -28(A6),D2
add.l  D2,D7
asr.l  D3,D7
*
* xecran = 
* a - x*a/y
move   D7,D0
muls   -32(A6),D0
divs   D6,D0
bvs.s CA21
*
add    -32(A6),D0
bvs.s  CA21
move   D0,(A5)+
*
* yecran =
*
move.l A3,(sp)
move   D4,-(sp)
move   D5,-(sp)
bsr altimetr
addq.l #4,sp
*
sub    Z0,D0
muls   -32(A6),D0
divs   D6,D0
bvc.s CA17
*
CA21b:
subq.l #2,A5
*
* overflow du calcul
CA21:
move   #-32000,(A5)+
addq.l #2,A4
addq.l #2,A3
bra.s CA18
*
CA17:
move   -36(A6),D1
sub    D0,D1
bvs.s  CA21b
move   D1,(A4)+
addq.l #2,A3
*
CA18:
*
add #64,D5
add #1,-24(A6)
*
CA19:
cmp X2,D5
ble CA20
*
add #64,D4
add #1,-22(A6)
*
CA15:
cmp Y2,D4
ble CA16
*
bra CA08
*
*
CA23:
* case 1:
*
* X1
move -34(A6),D0
muls -28(A6),D0
neg.l D0
move -34(A6),D1
muls -30(A6),D1
sub.l D1,D0
asr.l D3,D0
add X0,D0
move D0,X1
*
* Y1
move -34(A6),D0
muls -30(A6),D0
neg.l D0
move -34(A6),D1
muls -28(A6),D1
add.l D1,D0
asr.l D3,D0
add Y0,D0
move D0,Y1
*
* X2
move -34(A6),D0
muls -28(A6),D0
move -34(A6),D1
muls -30(A6),D1
sub.l D1,D0
asr.l D3,D0
add X0,D0
move D0,X2
*
* Y2
move -34(A6),D0
muls -30(A6),D0
move -34(A6),D1
muls -28(A6),D1
add.l D1,D0
asr.l D3,D0
add Y0,D0
move D0,Y2
*
move X1,D0
cmp X2,D0
ble.s CA24
*
move X2,X1
*
CA24:
move X2,D0
cmp X0,D0
bge.s CA25
*
move X0,X2
*
CA25:
add #64,X2
add #64,Y2
*
and #-64,X1
and #-64,X2
and #-64,Y1
and #-64,Y2
*
* boucle sur X
move X2,D5
clr -22(A6)
bra CA28
*
CA29:
*
move   D5,D0
sub    X0,D0
move   D0,D1
muls   -28(A6),D0
move.l D0,-4(A6)
*
muls   -30(A6),D1
move.l D1,-8(A6)
*
* boucle sur Y
move Y1,D4
clr -24(A6)
bra CA32
*
CA33:
*
* y = D6
move   D4,D6
sub    Y0,D6
* D2 = Y - Y0
move   D6,D2
muls   -28(A6),D6
sub.l  -8(A6),D6
asr.l  D3,D6
*
* if y > 0
tst D6
ble CA35
*
* condition remplie
* x = D7
move   D2,D7
muls   -30(A6),D7
add.l  -4(A6),D7
asr.l  D3,D7
*
* xecran = 
* a - x*a/y
move   D7,D0
muls   -32(A6),D0
divs   D6,D0
bvs.s CA35
*
* le calcul est correct
add    -32(A6),D0
bvs.s  CA35
move   D0,(A5)+
*
* yecran =
*
move.l A3,(sp)
move   D4,-(sp)
move   D5,-(sp)
bsr altimetr
addq.l #4,sp
*
sub    Z0,D0
muls   -32(A6),D0
divs   D6,D0
bvc.s CA34
*
CA35b:
subq.l #2,A5
*
* overflow du calcul
CA35:
move   #-32000,(A5)+
addq.l #2,A4
addq.l #2,A3
bra.s CA31
*
CA34:
move   -36(A6),D1
sub    D0,D1
bvs.s  CA35b
move   D1,(A4)+
addq.l #2,A3
*
CA31:
add #64,D4
add #1,-24(A6)
*
CA32:
cmp Y2,D4
ble CA33
*
sub #64,D5
add #1,-22(A6)
*
CA28:
cmp X1,D5
bge CA29
*
*
bra CA08
*
*
CA36:
* case 2:
*
* X2
move   -34(A6),D0
muls   -28(A6),D0
neg.l  D0
move   -34(A6),D1
muls   -30(A6),D1
sub.l  D1,D0
asr.l  D3,D0
add    X0,D0
move   D0,X2
*
* Y2
move   -34(A6),D0
muls   -30(A6),D0
neg.l  D0
move   -34(A6),D1
muls   -28(A6),D1
add.l  D1,D0
asr.l  D3,D0
add    Y0,D0
move   D0,Y2
*
* X1
move   -34(A6),D0
muls   -28(A6),D0
move   -34(A6),D1
muls   -30(A6),D1
sub.l  D1,D0
asr.l  D3,D0
add    X0,D0
move   D0,X1
*
* Y1
move   -34(A6),D0
muls   -30(A6),D0
move   -34(A6),D1
muls   -28(A6),D1
add.l  D1,D0
asr.l  D3,D0
add    Y0,D0
move   D0,Y1
*
move   Y1,D0
cmp    Y2,D0
ble.s CA37
*
move Y2,Y1
*
CA37:
move   Y2,D0
cmp    Y0,D0
bge.s CA38
*
move   Y0,Y2
*
CA38:
add #64,X2
add #64,Y2
*
and #-64,X1
and #-64,X2
and #-64,Y1
and #-64,Y2
*
* boucle sur Y
move Y2,D4
clr -22(A6)
bra CA41
*
CA42:
*
move   D4,D0
sub    Y0,D0
move   D0,D1
muls -28(A6),D0
move.l D0,-4(A6)
*
muls   -30(A6),D1
move.l D1,-8(A6)
*
* boucle sur X
move X1,D5
clr -24(A6)
bra CA45
*
CA46:
*
* y = D6
move.l -4(A6),D6
move   D5,D1
sub    X0,D1
* D2 = X - X0
move   D1,D2
muls   -30(A6),D1
sub.l  D1,D6
asr.l  D3,D6
*
* if y > 0
tst D6
ble CA47
*
* condition remplie
* x = D7
move.l -8(A6),D7
muls   -28(A6),D2
add.l  D2,D7
asr.l  D3,D7
*
* xecran = 
* a - x*a/y
move   D7,D0
muls   -32(A6),D0
divs   D6,D0
bvs.s CA47
*
add    -32(A6),D0
bvs.s  CA47
move   D0,(A5)+
*
* yecran =
*
move.l A3,(sp)
move   D4,-(sp)
move   D5,-(sp)
bsr altimetr
addq.l #4,sp
*
sub    Z0,D0
muls   -32(A6),D0
divs   D6,D0
bvc.s CA43
*
CA47b:
subq.l #2,A5
*
* overflow du calcul
CA47:
move   #-32000,(A5)+
addq.l #2,A4
addq.l #2,A3
bra.s CA44
*
CA43:
move   -36(A6),D1
sub    D0,D1
bvs.s  CA47b
move   D1,(A4)+
addq.l #2,A3
*
CA44:
add #64,D5
add #1,-24(A6)
*
CA45:
cmp X2,D5
ble CA46
*
sub #64,D4
add #1,-22(A6)
*
CA41:
cmp Y1,D4
bge CA42
*
*
bra CA08
*
*
CA49:
* case 3:
*
* X2
move   -34(A6),D0
muls   -28(A6),D0
neg.l  D0
move   -34(A6),D1
muls   -30(A6),D1
sub.l  D1,D0
asr.l  D3,D0
add    X0,D0
move   D0,X2
*
* Y2
move   -34(A6),D0
muls   -30(A6),D0
neg.l  D0
move   -34(A6),D1
muls   -28(A6),D1
add.l  D1,D0
asr.l  D3,D0
add    Y0,D0
move   D0,Y2
*
* X1
move   -34(A6),D0
muls   -28(A6),D0
move   -34(A6),D1
muls   -30(A6),D1
sub.l  D1,D0
asr.l  D3,D0
add    X0,D0
move   D0,X1
*
* Y1
move   -34(A6),D0
muls   -30(A6),D0
move   -34(A6),D1
muls   -28(A6),D1
add.l  D1,D0
asr.l  D3,D0
add    Y0,D0
move   D0,Y1
*
*
move   X2,D0
cmp    X1,D0
bge.s CA50
*
move   X1,X2
*
CA50:
*
move   X1,D0
cmp    X0,D0
ble.s CA51
*
move   X0,X1
*
CA51:
add #64,Y2
*
and #-64,X1
and #-64,X2
and #-64,Y1
and #-64,Y2
*
* boucle sur X
move X1,D5
clr -22(A6)
bra CA54
*
CA55:
*
move   D5,D0
sub    X0,D0
move   D0,D1
muls   -28(A6),D0
move.l D0,-4(A6)
*
muls   -30(A6),D1
move.l D1,-8(A6)
*
* boucle sur Y
move   Y1,D4
clr    -24(A6)
bra CA58
*
CA59:
*
* y = D6
move   D4,D6
sub    Y0,D6
* D2 = Y - Y0
move   D6,D2
muls   -28(A6),D6
sub.l  -8(A6),D6
asr.l  D3,D6
*
* if y > 0
tst D6
ble CA60
*
* condition remplie
* x = D7
move   D2,D7
muls   -30(A6),D7
add.l  -4(A6),D7
asr.l  D3,D7
*
* xecran = 
* a - x*a/y
move   D7,D0
muls   -32(A6),D0
divs   D6,D0
bvs.s CA60
*
add    -32(A6),D0
bvs.s  CA60
move   D0,(A5)+
*
* yecran =
*
move.l A3,(sp)
move   D4,-(sp)
move   D5,-(sp)
bsr altimetr
addq.l #4,sp
*
sub    Z0,D0
muls   -32(A6),D0
divs   D6,D0
bvc.s CA56
*
CA60b:
subq.l #2,A5
*
* overflow du calcul
CA60:
move   #-32000,(A5)+
addq.l #2,A4
addq.l #2,A3
bra.s CA57
*
CA56:
move   -36(A6),D1
sub    D0,D1
bvs.s  CA60b
move   D1,(A4)+
addq.l #2,A3
*
CA57:
add    #64,D4
add    #1,-24(A6)
*
CA58:
cmp    Y2,D4
ble CA59
*
add    #64,D5
add    #1,-22(A6)
*
CA54:
cmp    X2,D5
ble CA55
*
*
bra CA08
*
*
CA09:
tst    D0
beq CA10
cmp    #1,D0
beq CA23
cmp    #2,D0
beq CA36
cmp    #3,D0
bra CA49
*
*
CA08:
* sauvegarde
* de la taille
* des tableaux
*
move -22(A6),hauteur
move -24(A6),largeur
*
movem.l (sp)+,D3-D7/A3-A5
unlk A6
rts

altimetr:
*
* retourne l'altitude du coin du damier
*
* position des paramŠtres dans la pile
* X=8
* Y=10
* pcol=12
*
        link A6,#0
        movem.l D5-D7,-(sp)

* IX=D7
* IY=D6
* i=D5
*
        move   8(A6),D7
        tst    D7
        blt.s AL1
*
        asr    #6,D7
        cmp    taille,D7
        blt.s AL10
        sub    taille,D7
        bra.s AL10
*
AL1:
        neg    D7
        asr    #6,D7
        neg    D7
        add    taille,D7
        subq   #1,D7
*
*
        AL10:
        move   10(A6),D6
        tst    D6
        blt.s AL11
*
        asr    #6,D6
cmp    taille,D6
blt.s AL20
sub    taille,D6
bra.s AL20
*
AL11:
neg    D6
asr    #6,D6
neg    D6
add    taille,D6
subq   #1,D6
*
*
AL20:
*
* codage du tableau
* des altitudes :
* bit 0 a 3 = couleur
*   (de 0 a 15)
* bit 4 a 15= hauteur
* ( de -4096 a 4095 m) 
*
muls   taille,D6
add.l  D6,D6
asl    #1,D7
move   D7,A0
add.l  D6,A0
add.l  altitude,A0
move (A0),D5
*
move D5,D0
and #15,D0
move.l 12(A6),A1
move D0,(A1)
*
move D5,D0
asr #4,D0
*
movem.l (sp)+,D5-D7
unlk A6
rts


incangle:
*
* cran=8
*
link A6,#-4

        move 8(A6),D0
        add D0,Angle
*
        cmp #72,Angle
        blt IC10
        clr Angle
IC10:
        tst Angle
        bge IC11
        move #71,Angle
IC11:
        move Angle,A0
        add.l A0,A0
        add.l A0,A0
        move.l #projecti,A1
        move 0(A0,A1.l),D0
        muls Vitesse,D0
        move.l #$a,D1
        asr.l D1,D0
        move D0,VY

        move Angle,A0
        add.l A0,A0
        add.l A0,A0
        move.l #projecti,A1
        move 2(A0,A1.l),D0
        muls Vitesse,D0
        move.l #$a,D1
        asr.l D1,D0
        neg.l D0
        move D0,VX

        clr Orientat
        cmp #27,Angle
        bge IC12
        cmp #9,Angle
        blt IC12

        move #1,Orientat
IC12:

        cmp #45,Angle
        bge IC13
        cmp #27,Angle
        blt IC13

        move #2,Orientat
IC13:

        cmp #63,Angle
        bge IC14
        cmp #45,Angle
        blt IC14

        move #3,Orientat
IC14:
IC09:
        unlk A6
        rts


visualis:
*
        link A6,#-48
        movem.l D3-D7,-(sp)
*
* position par rapport … la pile
*
* boutton=-2
* xs=-4
* ys=-6
* q=-10
* xe1=-12
* xe2=-14
* xe3=-16
* xe4=-18
* i=-20
* j=-22
* n=-24
* t=-28
* v=-32
* r=-36
* s=-40
* tc=-44
* tc0=-48
*
* x=D7
* y=D6
* c=D5
* k=D4
*
        move hauteur,-24(A6)
        move largeur,D4
        move.l xe,-32(A6)
        move.l ye,-40(A6)
        move.l cl,-48(A6)

        move D4,D6
        move D6,D0
        move -24(A6),D1
        sub #2,D1
        muls D1,D0
        move D0,D6
        bra L224
L225:
L234:
L226:
        move D6,D0
        add.w D0,D0
        ext.l D0
        add.l -32(A6),D0
        move.l D0,-28(A6)

        move D6,D0
        add.w D0,D0
        ext.l D0
        add.l -40(A6),D0
        move.l D0,-36(A6)

        move D6,D0
        add.w D0,D0
        ext.l D0
        add.l -48(A6),D0
        move.l D0,-44(A6)

        move D4,D7
        sub #2,D7


        move D4,A0
        add.l A0,A0
        move D7,A1
        add.l A1,A1
        add.l A1,A0
        add.l -28(A6),A0
        move 2(A0),-16(A6)

        move D7,A0
        add.l A0,A0
        add.l -28(A6),A0
        move 2(A0),-18(A6)

        bra L237
L238:
        move D7,A0
        add.l A0,A0
        add.l -28(A6),A0
        move (A0),-12(A6)
        move D4,A0
        add.l A0,A0
        move D7,A1
        add.l A1,A1
        add.l A1,A0
        add.l -28(A6),A0
        move (A0),-14(A6)

        move #-32000,D5
        cmp -12(A6),D5
        bge L240
        cmp -14(A6),D5
        bge L241
        cmp -18(A6),D5
        bge L242
        cmp -16(A6),D5
        bge L243

        move.l -44(A6),A0
        move D7,A1
        add.l A1,A1
        move 0(A0,A1.l),(sp)
        move.l -36(A6),A0
        move D7,A1
        add.l A1,A1
        move 2(A0,A1.l),-(sp)
        move -18(A6),-(sp)
        move.l -36(A6),A0
        move D4,A1
        add.l A1,A1
        move D7,A2
        add.l A2,A2
        add.l A2,A1
        move 2(A0,A1.l),-(sp)
        move -16(A6),-(sp)
        move.l -36(A6),A0
        move D4,A1
        add.l A1,A1
        move D7,A2
        add.l A2,A2
        add.l A2,A1
        move 0(A0,A1.l),-(sp)
        move -14(A6),-(sp)
        move.l -36(A6),A0
        move D7,A1
        add.l A1,A1
        move 0(A0,A1.l),-(sp)
        move -12(A6),-(sp)
        bsr FourSide
        adda.l #16,sp

L243:
L242:
L241:
L240:
L239:

move -12(A6),-18(A6)
move -14(A6),-16(A6)

L236:

sub #1,D7

L237:

tst D7
bge L238

L235:
L223:

sub D4,D6
L224:

tst D6
bge L225
L222:

*
L221:
        tst.l (sp)+
        movem.l (sp)+,D4-D7
        unlk A6
        rts



initvisu:

move hauteur,fvn
move largeur,fvk
move.l xe,fvv
move.l ye,fvs
move.l cl,fvtc0

move fvn,D0
sub #2,D0
muls fvk,D0
move D0,fvy

rts



visu:

movem.l D7-D7,-(sp)
*c=D7

tst fvy
blt FVL3

move fvy,D0
add.w D0,D0
ext.l D0
add.l fvv,D0
move.l D0,fvt

move fvy,D0
add.w D0,D0
ext.l D0
add.l fvs,D0
move.l D0,fvr

move fvy,D0
add.w D0,D0
ext.l D0
add.l fvtc0,D0
move.l D0,fvtc

move fvk,D0
sub #2,D0
move D0,fvx


move fvk,A0
add.l A0,A0
move fvx,A1
add.l A1,A1
add.l A1,A0
add.l fvt,A0
move 2(A0),fvxe3

move fvx,A0
add.l A0,A0
add.l fvt,A0
move 2(A0),fvxe4

bra FVL6
FVL7:



move fvx,A0
add.l A0,A0
add.l fvt,A0
move (A0),fvxe1

move fvk,A0
add.l A0,A0
move fvx,A1
add.l A1,A1
add.l A1,A0
add.l fvt,A0
move (A0),fvxe2


move #-32000,D7


cmp fvxe1,D7
bge FVL8


cmp fvxe2,D7
bge FVL9


cmp fvxe4,D7
bge FVL10


cmp fvxe3,D7
bge FVL11

move.l fvtc,A0
move fvx,A1
add.l A1,A1
move 0(A0,A1.l),(sp)
move.l fvr,A0
move fvx,A1
add.l A1,A1
move 2(A0,A1.l),-(sp)
move fvxe4,-(sp)
move.l fvr,A0
move fvk,A1
add.l A1,A1
move fvx,A2
add.l A2,A2
add.l A2,A1
move 2(A0,A1.l),-(sp)
move fvxe3,-(sp)
move.l fvr,A0
move fvk,A1
add.l A1,A1
move fvx,A2
add.l A2,A2
add.l A2,A1
move 0(A0,A1.l),-(sp)
move fvxe2,-(sp)
move.l fvr,A0
move fvx,A1
add.l A1,A1
move 0(A0,A1.l),-(sp)
move fvxe1,-(sp)
jsr FourSide
adda.l #16,sp

FVL11:

FVL10:

FVL9:


FVL8:

move fvxe1,fvxe4
move fvxe2,fvxe3

FVL5:
sub #1,fvx
FVL6:

tst fvx
bge FVL7

FVL4:
move fvk,D0
sub D0,fvy

FVL3:
move fvy,D0
movem.l (sp)+,D7-D7
rts



chargetpg:
        link A6,#-24
*l=-4
*lp=-8
*compteur=-12
*i=-14
*fhandle=-16
*ptr=-20

        move #2,(sp)
        move.l tpg,-(sp)     ; … modifier donner l'adresse de la chaine
        move #61,-(sp)
        bsr gemdos
        addq.l #6,sp
        move D0,-16(A6)

        bge CT249

        lea erreur2,a2
        jmp formale

CT249:

        move.l #$2,-12(A6)
        move.l #taille,-20(A6)

        move.l -20(A6),(sp)
        move.l -12(A6),-(sp)
        move -16(A6),-(sp)
        move #63,-(sp)
        bsr gemdos
        addq.l #8,sp
        cmp.l -12(A6),D0
        beq CT250

        move -16(A6),(sp)
        move #62,-(sp)
        bsr gemdos
        addq.l #2,sp
        move #200,taille
        lea erreur3,a2
        jmp formale
CT250:

        move.l #$2,-12(A6)
        lea -14(A6),A0
        move.l A0,-20(A6)
        move.l -20(A6),(sp)
        move.l -12(A6),-(sp)
        move -16(A6),-(sp)
        move #63,-(sp)
        bsr gemdos
        addq.l #8,sp
        cmp.l -12(A6),D0
        beq CT251

        move -16(A6),(sp)
        move #62,-(sp)
        bsr gemdos
        addq.l #2,sp
        move #200,taille
        lea erreur3,a2
        jmp formale

CT251:

        move taille,D0
        cmp #200,D0
        bne BCT252
        move -14(A6),D0
        cmp taille,D0
        beq CT252 

BCT252:
        move -16(A6),(sp)
        move #62,-(sp)
        bsr gemdos
        addq.l #2,sp
        move #200,taille
        lea erreur9,a2
        jmp formale

CT252:

        move.l #$20,-12(A6)
        move.l #colpal,-20(A6)

        move.l -20(A6),(sp)
        move.l -12(A6),-(sp)
        move -16(A6),-(sp)
        move #63,-(sp)
        bsr gemdos
        addq.l #8,sp
        cmp.l -12(A6),D0
        beq CT253

        move -16(A6),(sp)
        move #62,-(sp)
        bsr gemdos
        addq.l #2,sp
        move #200,taille
        lea erreur3,a2
        jmp formale
CT253:
        move taille,D0
        muls taille,D0
        asl.l #$1,D0
        move.l D0,-12(A6)
        move.l altitude,-20(A6)

        move.l -20(A6),(sp)
        move.l -12(A6),-(sp)
        move -16(A6),-(sp)
        move #63,-(sp)
        bsr gemdos
        addq.l #8,sp
        cmp.l -12(A6),D0
        beq CT254

        move -16(A6),(sp)
        move #62,-(sp)
        bsr gemdos
        addq.l #2,sp
        move #200,taille
        lea erreur3,a2
        jmp formale
CT254:
        move -16(A6),(sp)
        move #62,-(sp)
        bsr gemdos
        addq.l #2,sp

********        bsr Palette

CT248:
CT246:
        clr.l D0
        unlk A6
        rts

Color:
* actualise colpal[] avec la palette courante

        link A6,#-10
*i=-2
        clr -2(A6)
        bra C42
C43:
        move #-1,(sp)
        move -2(A6),-(sp)
        move #7, -(sp)
        bsr xbios
        addq.l #4,sp

        move -2(A6),A0
        add.l A0,A0
        add.l #colpal,A0
        move D0,(A0)

        add #1,-2(A6)
C42:
        cmp #16,-2(A6)
        blt C43

        unlk A6
        rts

Palette:
* reg‚n‚re la palette avec colpal[]
        move.l #colpal,-(sp)
        move #6,-(sp)
        bsr xbios
        addq.l #6,sp
        lea colpal,a0
        move.l $44e,a1
        lea 32000(a1),a1

        moveq #15,d0
Pal1:   move.w (a0)+,(a1)+
        dbra d0,Pal1
        rts


sauvetpg:
        link A6,#-22
*l=-4
*lp=-8
*compteur=-12
*fhandle=-14
*ptr=-18

        bsr color

        clr (sp)
        move.l tpg,-(sp)     ; … modifier donner l'adresse de la chaine
        move #60,-(sp)
        bsr gemdos
        addq.l #6,sp
        move D0,-14(A6)
        bge ST257

        lea erreur2,a2
        jmp formale
ST257:
        move.l #$2,-12(A6)
        move.l #taille,-18(A6)
        move.l -18(A6),(sp)
        move.l -12(A6),-(sp)
        move -14(A6),-(sp)
        move #64,-(sp)
        bsr gemdos
        addq.l #8,sp
        cmp.l -12(A6),D0
        beq ST258

        lea erreur4,a2
        jmp formale
ST258:
        move.l #$2,-12(A6)
        move.l #taille,-18(A6)
        move.l -18(A6),(sp)
        move.l -12(A6),-(sp)
        move -14(A6),-(sp)
        move #64,-(sp)
        bsr gemdos
        addq.l #8,sp
        cmp.l -12(A6),D0
        beq ST259

        lea erreur4,a2
        jmp formale
ST259:
        move.l #$20,-12(A6)
        move.l #colpal,-18(A6)
        move.l -18(A6),(sp)
        move.l -12(A6),-(sp)
        move -14(A6),-(sp)
        move #64,-(sp)
        bsr gemdos
        addq.l #8,sp
        cmp.l -12(A6),D0
        beq ST260

        lea erreur4,a2
        jmp formale
ST260:
        move taille,D0
        muls taille,D0
        asl.l #$1,D0
        move.l D0,-12(A6)
        move.l altitude,-18(A6)
        move.l -18(A6),(sp)
        move.l -12(A6),-(sp)
        move -14(A6),-(sp)
        move #64,-(sp)
        bsr gemdos
        addq.l #8,sp
        cmp.l -12(A6),D0
        beq ST261

        lea erreur4,a2
        jmp formale
ST261:

        move -14(A6),(sp)
        move #62,-(sp)
        bsr gemdos
        addq.l #2,sp

        bra ST254
ST256:
ST254:
        clr.l D0
        unlk A6
        rts

montagne:
*IX0=8
*IY0=10
link A6,#-16
movem.l D2-D7,-(sp)
*i=-2
*n=-4
*k=-6
*c=-8
*cote=-10
*iteratio=-12
*a=-14
*b=-16
*X=D7
*Y=D6
*IX=D5
*IY=D4
*cste=D3

move 10(A6),D4


tst D4
bge LM287

add taille,D4
LM287:


cmp taille,D4
blt LM288

sub taille,D4

LM288:

move 8(A6),D5


tst D5
bge LM289

add taille,D5
LM289:


cmp taille,D5
blt LM290

sub taille,D5

LM290:

move D4,D0
muls #400,D0
move D5,D1
asl #1,D1
ext.l D1
add.l D1,D0
move.l D0,A0
move.l altitude,A1
move 0(A0,A1.l),D0
move constant,D1
asl #4,D1
add D1,D0
move D4,D1
muls #400,D1
move D5,D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move D0,(A1)

move hauteur,-10(A6)


move -10(A6),D0
cmp largeur,D0
ble LM291

move largeur,-10(A6)

LM291:

move -10(A6),D0
ext.l D0
divs #2,D0
move D0,-12(A6)

move #1,-2(A6)
bra LM294
LM295:


move constant,D3
move -2(A6),-(sp)
add #1,(sp)
move D3,D0
ext.l D0
divs (sp)+,D0
move D0,D3
asl #4,D3


move 10(A6),D4
sub -2(A6),D4


tst D4
bge LM296

add taille,D4
LM296:


cmp taille,D4
blt LM297

sub taille,D4
LM297:

move D4,-14(A6)


move 10(A6),D4
add -2(A6),D4


tst D4
bge LM298

add taille,D4
LM298:


cmp taille,D4
blt LM299

sub taille,D4
LM299:

move D4,-16(A6)


move -2(A6),D0
neg D0
move D0,-6(A6)
bra LM302
LM303:


move 8(A6),D5
add -6(A6),D5


tst D5
bge LM304

add taille,D5
LM304:


cmp taille,D5
blt LM305

sub taille,D5

LM305:

move D3,D0
move -14(A6),D1
muls #400,D1
move D5,D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move (A1),D1
add D1,D0
move -14(A6),D1
muls #400,D1
move D5,D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move D0,(A1)

move D3,D0
move -16(A6),D1
muls #400,D1
move D5,D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move (A1),D1
add D1,D0
move -16(A6),D1
muls #400,D1
move D5,D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move D0,(A1)
LM301:

add #1,-6(A6)
LM302:

move -6(A6),D0
cmp -2(A6),D0
ble LM303
LM300:


move D5,-16(A6)


move 8(A6),D5
sub -2(A6),D5


tst D5
bge LM306

add taille,D5
LM306:


cmp taille,D5
blt LM307

sub taille,D5
LM307:

move D5,-14(A6)


move -2(A6),D0
sub #1,D0
neg D0
move D0,-6(A6)
bra LM310
LM311:


move 10(A6),D4
add -6(A6),D4


tst D4
bge LM312

add taille,D4
LM312:


cmp taille,D4
blt LM313

sub taille,D4

LM313:

move D3,D0
move D4,D1
muls #400,D1
move -14(A6),D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move (A1),D1
add D1,D0
move D4,D1
muls #400,D1
move -14(A6),D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move D0,(A1)

move D3,D0
move D4,D1
muls #400,D1
move -16(A6),D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move (A1),D1
add D1,D0
move D4,D1
muls #400,D1
move -16(A6),D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move D0,(A1)
LM309:

add #1,-6(A6)
LM310:

move -2(A6),D0
sub #1,D0
cmp -6(A6),D0
bge LM311
LM308:
LM293:
        add #1,-2(A6)
LM294:
        move -2(A6),D0
        cmp -12(A6),D0
        blt LM295
LM292:
LM286:
        tst.l (sp)+
        movem.l (sp)+,D3-D7
        unlk A6
        rts

dome:
*IX0=8
*IY0=10
link A6,#-16
movem.l D2-D7,-(sp)
*i=-2
*n=-4
*k=-6
*c=-8
*cote=-10
*iteratio=-12
*a=-14
*b=-16
*X=D7
*Y=D6
*IX=D5
*IY=D4
*cste=D3

move 10(A6),D4


tst D4
bge LD337

add taille,D4
LD337:


cmp taille,D4
blt LD338

sub taille,D4

LD338:

move 8(A6),D5


tst D5
bge LD339

add taille,D5
LD339:


cmp taille,D5
blt LD340

sub taille,D5

LD340:

move D4,D0
muls #400,D0
move D5,D1
asl #1,D1
ext.l D1
add.l D1,D0
move.l D0,A0
move.l altitude,A1
move 0(A0,A1.l),D0
move constant,D1
asl #4,D1
add D1,D0
move D4,D1
muls #400,D1
move D5,D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move D0,(A1)

move hauteur,-10(A6)


move -10(A6),D0
cmp largeur,D0
ble LD341

move largeur,-10(A6)

LD341:

move -10(A6),D0
ext.l D0
divs #2,D0
move D0,-12(A6)

move #1,-2(A6)
bra LD344
LD345:


move -2(A6),D0
asl #3,D0
move D0,A0
move.l #projecti,A1
move 0(A0,A1.l),D0
muls constant,D0
move.l #$a,D1
asr.l D1,D0
move D0,D3



tst constant
ble LD346


cmp #18,-2(A6)
bgt LD10004
tst D3
bge LD347
LD10004:
        clr D3
        bra LD348
LD347:
        asl #4,D3
LD348:
        bra LD349
LD346:
        cmp #18,-2(A6)
        bgt LD10005
        tst D3
        ble LD350
LD10005:
        clr D3
        bra LD351
LD350:
        asl #4,D3
LD351:
LD349:
        move 10(A6),D4
sub -2(A6),D4


tst D4
bge LD352

add taille,D4
LD352:


cmp taille,D4
blt LD353

sub taille,D4
LD353:

move D4,-14(A6)


move 10(A6),D4
add -2(A6),D4


tst D4
bge LD354

add taille,D4
LD354:


cmp taille,D4
blt LD355

sub taille,D4
LD355:

move D4,-16(A6)

move -2(A6),D0
neg D0
move D0,-6(A6)
bra LD358
LD359:


move 8(A6),D5
add -6(A6),D5


tst D5
bge LD360

add taille,D5
LD360:


cmp taille,D5
blt LD361

sub taille,D5

LD361:

move D3,D0
move -14(A6),D1
muls #400,D1
move D5,D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move (A1),D1
add D1,D0
move -14(A6),D1
muls #400,D1
move D5,D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move D0,(A1)

move D3,D0
move -16(A6),D1
muls #400,D1
move D5,D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move (A1),D1
add D1,D0
move -16(A6),D1
muls #400,D1
move D5,D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move D0,(A1)
LD357:
add #1,-6(A6)
LD358:
move -6(A6),D0
cmp -2(A6),D0
ble LD359
LD356:


move D5,-16(A6)


move 8(A6),D5
sub -2(A6),D5


tst D5
bge LD362

add taille,D5
LD362:


cmp taille,D5
blt LD363

sub taille,D5
LD363:

move D5,-14(A6)


move -2(A6),D0
sub #1,D0
neg D0
move D0,-6(A6)
bra LD366
LD367:


move 10(A6),D4
add -6(A6),D4


tst D4
bge LD368

add taille,D4
LD368:


cmp taille,D4
blt LD369

sub taille,D4

LD369:

move D3,D0
move D4,D1
muls #400,D1
move -14(A6),D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move (A1),D1
add D1,D0
move D4,D1
muls #400,D1
move -14(A6),D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move D0,(A1)

move D3,D0
move D4,D1
muls #400,D1
move -16(A6),D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move (A1),D1
add D1,D0
move D4,D1
muls #400,D1
move -16(A6),D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
move.l D1,A1
move D0,(A1)
LD365:

add #1,-6(A6)
LD366:

move -2(A6),D0
sub #1,D0
cmp -6(A6),D0
bge LD367
LD364:
LD343:
        add #1,-2(A6)
LD344:
        move -2(A6),D0
        cmp -12(A6),D0
        blt LD345
LD342:
LD336:
        tst.l (sp)+
        movem.l (sp)+,D3-D7
        unlk A6
        rts

onde:
link A6,#-10
movem.l D2-D7,-(sp)
*X=D7
*Y=D6
*IX=D5
*IY=D4
*h=D3
*i=-2
*n=-4
*a1=-6
*a2=-8
*k=-10

move #6,-2(A6)

clr -6(A6)

move Y1,D6
add #64,D6
bra LO317
LO318:



tst D6
blt LO319

move D6,D4
asr #6,D4


cmp taille,D4
blt LO320

sub taille,D4
LO320:


bra LO321
LO319:


move taille,D4
sub #1,D4
move D6,D0
neg D0
asr #6,D0
sub D0,D4
LO321:



move -6(A6),-8(A6)


move X1,D7
add #64,D7
bra LO324
LO325:



tst D7
blt LO326

move D7,D5
asr #6,D5


cmp taille,D5
blt LO327

sub taille,D5
LO327:


bra LO328
LO326:


move taille,D5
sub #1,D5
move D7,D0
neg D0
asr #6,D0
sub D0,D5
LO328:



move D4,D0
muls #400,D0
move D5,D1
asl #1,D1
ext.l D1
add.l D1,D0
add.l altitude,D0
move.l D0,A0
move (A0),D3

move D3,D0
asr #4,D0
ext.l D0
move -8(A6),A1
add.l A1,A1
add.l A1,A1
add.l #projecti,A1
move 2(A1),D1
muls constant,D1
move.l #$a,D2
asr.l D2,D1
add.l D1,D0
move D0,-10(A6)

move D3,D0
and #15,D0
move -10(A6),D1
asl #4,D1
add D1,D0
move D4,D1
muls #400,D1
move D5,D2
asl #1,D2
ext.l D2
add.l D2,D1
add.l altitude,D1
        move.l D1,A1
        move D0,(A1)
        move -2(A6),D0
        add D0,-8(A6)
        cmp #72,-8(A6)
        blt LO329
        clr -8(A6)
LO329:
LO323:
        add #64,D7
LO324:
        cmp X2,D7
        blt LO325
LO322:
        move -2(A6),D0
        add D0,-6(A6)
        cmp #72,-6(A6)
        blt LO330
        clr -6(A6)
LO330:
LO316:
        add #64,D6
LO317:
        cmp Y2,D6
        blt LO318
LO315:
LO314:
        tst.l (sp)+
        movem.l (sp)+,D3-D7
        unlk A6
        rts

fractal:
        link A6,#-12
        movem.l D3-D7,-(sp)
*i=D7
*n=D6
*X=D5
*Y=D4
*IX=-2
*IY=-4
*IX1=-6
*IY1=-8
*IX2=-10
*IY2=-12
        move #-1,(sp)
        bsr Aleatoir
        move Y1,D4
        add #64,D4
        bra LF373
LF374:
        tst D4
        blt LF375
        move D4,D0
        asr #6,D0
        move D0,-4(A6)
        move -4(A6),D0
        cmp taille,D0
        blt LF376
        move taille,D0
        sub D0,-4(A6)
LF376:
        bra LF377
LF375:
        move taille,D0
        sub #1,D0
        move D4,D1
        neg D1
        asr #6,D1
        sub D1,D0
        move D0,-4(A6)
LF377:
        move X1,D5
        add #64,D5
        bra LF380
LF381:
        tst D5
        blt LF382
        move D5,D0
        asr #6,D0
        move D0,-2(A6)
        move -2(A6),D0
        cmp taille,D0
        blt LF383
        move taille,D0
        sub D0,-2(A6)
LF383:
        bra LF384
LF382:
        move taille,D0
        sub #1,D0
        move D5,D1
        neg D1
        asr #6,D1
        sub D1,D0
        move D0,-2(A6)
LF384:
        move -4(A6),D0
        muls #400,D0
        move -2(A6),D1
        asl #1,D1
        ext.l D1
        add.l D1,D0
        add.l altitude,D0
        move.l D0,A0
        move (A0),D7
        tst constant
        blt LF385
        move constant,(sp)
        bsr Aleatoir
        move D0,D6
        move D7,D0
        asr #4,D0
        add D0,D6
        bra LF386
LF385:
        move D7,D6
        asr #4,D6
        move constant,D0
        neg D0
        move D0,(sp)
        bsr Aleatoir
        sub D0,D6
LF386:
        cmp #4000,D6
        ble LF387
        move #4000,D6
LF387:
        cmp #-4000,D6
        bge LF388
        move #-4000,D6
LF388:
        move D7,D0
        and #15,D0
        move D6,D1
        asl #4,D1
        add D1,D0
        move -4(A6),D1
        muls #400,D1
        move -2(A6),D2
        asl #1,D2
        ext.l D2
        add.l D2,D1
        add.l altitude,D1
        move.l D1,A1
        move D0,(A1)
LF379:
        add #64,D5
LF380:
        cmp X2,D5
        blt LF381
LF378:
LF372:
        add #64,D4
LF373:
        cmp Y2,D4
        blt LF374
LF371:
LF370:
        tst.l (sp)+
        movem.l (sp)+,D4-D7
        unlk A6
        rts

efface:
        link A6,#0
        movem.l D3-D7,-(sp)
*X=D7
*Y=D6
*IX=D5
*IY=D4
        move Y1,D6
        add #64,D6
        bra LE392
LE393:
        tst D6
        blt LE394
        move D6,D4
        asr #6,D4
        cmp taille,D4
blt LE395
        sub taille,D4
LE395:
        bra LE396
LE394:
        move taille,D4
        sub #1,D4
        move D6,D0
        neg D0
        asr #6,D0
        sub D0,D4
LE396:
        move X1,D7
        add #64,D7
        bra LE399
LE400:
        tst D7
        blt LE401
        move D7,D5
        asr #6,D5
        cmp taille,D5
        blt LE402
        sub taille,D5
LE402:
        bra LE403
LE401:
        move taille,D5
        sub #1,D5
        move D7,D0
        neg D0
        asr #6,D0
        sub D0,D5
LE403:
        move D4,D0
        muls #400,D0
        move D5,D1
        asl #1,D1
        ext.l D1
        add.l D1,D0
        add.l altitude,D0
        move.l D0,A0
        and #15,(A0)
LE398:
        add #64,D7
LE399:
        cmp X2,D7
        blt LE400
LE397:
LE391:
        add #64,D6
LE392:
        cmp Y2,D6
        blt LE393
LE390:
LE389:
        tst.l (sp)+
        movem.l (sp)+,D4-D7
        unlk A6
        rts



NALEAT:dc.w 2,1568

Aleatoir:
*n=8
        link A6,#-8
* l=-4
* Naleat=NALEAT
*
        tst    8(A6)
        bge AL7
*
        move   #17,(sp)
        bsr    xbios
        and.l  #$7fff,D0
        move   D0,NALEAT
        bra AL5
*
AL7:
        move   #17,(sp)
        bsr xbios
        move.l D0,-4(A6)
*
        move.l -4(A6),D0
        add.l  -4(A6),D0
        asr.l  #$8,D0
        add    NALEAT,D0
        and    #32767,D0
        muls   8(A6),D0
        divs   #32767,D0
*
AL8:
AL5:
        unlk A6
        rts


*****************************************



Draw:
**Draw:
*xp1=8
*yp1=10
*xp2=12
*yp2=14
*color=16

link A6,#-34
movem.l D3-D7/A4-A5,-(sp)


*decallag=D7
*
move.l #9,D7
*xg=D6
*yg=D5
*xd=D4
*col=D3
*
move 16(A6),D3

*pt=-4
*ix=-8
*iy=-12
*x1=-14
*y1=-16
*x2=-18
*y2=-20
*yd=-22
*x=-24
*y=-26
*a=-28
*yh=-30
*d12x=-32
*d12y=-34
*


move    10(A6),D0
sub     14(A6),D0
move    D0,-34(A6)
*
*
tst     -34(a6)
bgt.s DWL74
bne.s DWL75

move    d3,(sp)
move    10(a6),-(sp)
move    12(a6),-(sp)
move    8(a6),-(sp)
bsr Line
addq.l  #6,sp
bra DW366

DWL75:

neg     -34(a6)

DWL74:


move 8(A6),D0
sub 12(A6),D0
move D0,-32(A6)
*
*
tst -32(A6)
bge DW368
*
neg     -32(A6)
*
DW368:
*

* trac‚ par point

* positionne l'‚cran video
move.l  video,a1


move -32(A6),D0
cmp -34(A6),D0
ble DW369



move 8(A6),D0
cmp 12(A6),D0
ble DW370
*
move    8(A6),D6
move    12(A6),8(A6)
move    D6,12(A6)
move    10(A6),D5
move    14(A6),10(A6)
move    D5,14(A6)
*
*
DW370:
*
move    8(A6),D1
sub     12(A6),D1
move    10(A6),D0
sub     14(A6),D0
ext.l   D0
asl.l   D7,D0
divs    d1,d0
ext.l   d0
move.l  D0,-4(A6)
*
*
*
move 8(A6),D0
cmp xsmin,D0
bge DW371
*
move 8(A6),D0
sub xsmin,D0
move 10(A6),D1
sub 14(A6),D1
muls D1,D0

move 8(A6),D1
sub 12(A6),D1
divs    d1,d0

move 10(A6),D1
sub.l   d0,D1
move D1,10(A6)
*
move xsmin,8(A6)
*
*
DW371:
*
*
move 12(A6),D0
cmp xsmax,D0
ble DW372
*
move xsmax,12(A6)
*
*
*
*
DW372:
*
move 10(A6),D4
ext.l D4
asl.l D7,D4
*
*
move 8(A6),D6
bra DW375
DW376:
*
*
move.l D4,D5
add.l #$100,D5
asr.l D7,D5
*
*
cmp ysmin,D5
blt DW377
cmp ysmax,D5
bgt DW377
*
* move D3,(sp)
* move D5,-(sp)
* move D6,-(sp)
* bsr Dot
* addq.l #4,sp

bsr DOT

DW377:
*
add.l -4(A6),D4
DW374:
*
addq #1,D6

DW375:
*
cmp 12(A6),D6
ble DW376
DW373:
*
bra DW378



DW369:
*
*
move 10(A6),D0
cmp 14(A6),D0
blt DW380
*
move 8(A6),D6
move 12(A6),8(A6)
move D6,12(A6)
move 10(A6),D5
move 14(A6),10(A6)
move D5,14(A6)

DW380:
*
move    10(A6),D1
sub     14(A6),D1
move    8(A6),D0
sub     12(A6),D0
ext.l   D0
asl.l   D7,D0
divs    d1,d0
ext.l   d0
move.l  D0,-4(A6)


move    10(A6),D0
cmp     ysmin,D0
bge     DW383
*

move    8(a6),d0
move    10(a6),d1
sub     ysmin,d1
move    8(a6),d2
sub     12(a6),d2
muls    d2,d1

move    10(a6),d2
sub     14(a6),d2
divs    d2,d1
sub     d1,d0
move    d0,8(a6)
*
move    ysmin,10(A6)
*
*
DW383:
*
*
move 14(A6),D0
cmp ysmax,D0
ble DW384
*
move ysmax,14(A6)
*
*
*
*
DW384:
*
move    8(A6),D4
ext.l   D4
asl.l   D7,D4
*
*
move    10(A6),D5
bra DW387
DW388:
*
*
move.l  D4,D6
add.l   #$100,D6
asr.l   D7,D6
*
*
*
cmp     xsmin,D6
blt.s DW389
cmp     xsmax,D6
bgt.s DW389
*
* move D3,(sp)
* move D5,-(sp)
* move D6,-(sp)
* bsr Dot
* addq.l #4,sp

bsr DOT

DW389:
*
add.l   -4(A6),D4
DW386:
*
addq    #1,D5
DW387:
*
cmp     14(A6),D5
ble DW388
DW385:
*
DW379:
DW378:
*
DW366:

movem.l (sp)+,D3-D7/A4-A5
unlk A6
rts



* Triangle

Triangle:
**Triangle:

*xp1=8
*yp1=10
*xp2=12
*yp2=14
*xp3=16
*yp3=18
*color=20

link A6,#-32
movem.l D3-D7/A4-A5,-(sp)

* positionne l'‚cran video
move.l  video,A1


*decallag=D7
*xg=D6
*yg=D5
*xd=D4
*col=D3

move 20(A6),D3

*yd=-2
*yh=-4
*x1=-6
*y1=-8
*x2=-10
*y2=-12
*x3=-14
*y3=-16
*d31x=-18
*d23x=-20
*d12x=-22
*d31y=-24
*d23y=-26
*d12y=-28
*ruptgauc=-30
*ruptdroi=-32


move    10(a6),d0
cmp     14(a6),d0
bgt.s TG333

cmp 18(a6),d0
bgt.s TG334

move    8(A6),-6(A6)
move    10(A6),-8(A6)
move    12(A6),-10(A6)
move    14(A6),-12(A6)
move    16(A6),-14(A6)
move    18(A6),-16(A6)
*
bra.s TG336
TG334:
*
move    16(A6),-6(A6)
move    18(A6),-8(A6)
move    8(A6),-10(A6)
move    10(A6),-12(A6)
move    12(A6),-14(A6)
move    14(A6),-16(A6)
TG335:
bra.s TG336
TG333:

move    14(a6),d0
cmp     18(a6),d0
bgt.s TG337
*
move    12(A6),-6(A6)
move    14(A6),-8(A6)
move    8(A6),-10(A6)
move    10(A6),-12(A6)
move    16(A6),-14(A6)
move    18(A6),-16(A6)
*
bra.s TG338
TG337:
*
move    16(A6),-6(A6)
move    18(A6),-8(A6)
move    8(A6),-10(A6)
move    10(A6),-12(A6)
move    12(A6),-14(A6)
move    14(A6),-16(A6)
TG338:
*
TG336:
*
move    -14(A6),D0
sub     -6(A6),D0
move    D0,-18(A6)
*
move -10(A6),D0
sub -14(A6),D0
move D0,-20(A6)
*
move -6(A6),D0
sub -10(A6),D0
move D0,-22(A6)
*
move -16(A6),D0
sub -8(A6),D0
move D0,-24(A6)
*
move -12(A6),D0
sub -16(A6),D0
move D0,-26(A6)
*
move -8(A6),D0
sub -12(A6),D0
move D0,-28(A6)
*
*
tst -28(A6)
bne TG339
*
*
tst -22(A6)
bne TG340
*
move D3,(sp)
move -16(A6),-(sp)
move -14(A6),-(sp)
move -8(A6),-(sp)
move -6(A6),-(sp)
bsr Draw
addq.l #8,sp
bra TG341
*
*
*
TG340:
*
*
tst -24(A6)
bne TG342
*
move D3,(sp)
move -8(A6),-(sp)
move -10(A6),-(sp)
move -6(A6),-(sp)
bsr Line
addq.l #6,sp
bra TG341
*
*
TG342:
*
*
TG339:
*
*
tst -24(A6)
bne TG343
*
*
tst -18(A6)
bne TG344
*
move D3,(sp)
move -16(A6),-(sp)
move -14(A6),-(sp)
move -8(A6),-(sp)
move -6(A6),-(sp)
bsr Draw
addq.l #8,sp
bra TG341
*
*
TG344:
*
*
*
*
TG343:
*
*
tst -26(A6)
blt TG345
*
move -12(A6),-4(A6)
*
*
bra TG346
TG345:
*
*
move -16(A6),-4(A6)
TG346:
*
*
move -4(A6),D0
cmp ysmax,D0
ble TG347
*
move ysmax,-4(A6)
*
*
*
*
TG347:

* trac‚ par horizontale

* col=D3

and     #$f,D3
move    D3,A2

add.l   a2,a2
add.l   a2,a2

tst moniteur
beq.s TG001

add.l #HLMONO,a2
bra.s TG005

TG001:
add.l #HL16COL,a2

TG005:

* A2 routine de la couleur choisie
move.l  (a2),a2


move #-1,-30(A6)
move #-1,-32(A6)
move -8(A6),D5
move -6(A6),D6
move D6,D4


cmp     ysmin,d5
bge.s FSL59

move    ysmin,d5

cmp     -16(a6),d5
blt.s FSL60
clr     -30(a6)
FSL60:

cmp     -12(a6),d5
blt.s FSL61
clr     -32(a6)
FSL61:

FSL59:

*
bra TG357
TG356:
*
*
*
tst     -30(A6)
bge.s TG358
*
*
cmp     -16(A6),D5
blt.s TG359
*
move    -14(A6),D6
*
clr -30(A6)

bra.s TG361

TG359:
*
move D5,D6
sub -8(A6),D6
muls -18(A6),D6
divs -24(A6),D6
add -6(A6),D6

TG360:
bra.s TG361

TG358:
*
cmp -12(A6),D5
blt.s FSL176

move -10(A6),D6
bra.s TG361

FSL176:

move D5,D6
sub -16(A6),D6
muls -20(A6),D6
divs -26(A6),D6
add -14(A6),D6


TG361:



*
tst -32(A6)
bge.s TG362
*
*
cmp -12(A6),D5
blt.s TG363
*
move -10(A6),D4
*
clr -32(A6)

bra.s TG365

TG363:
*
move -6(A6),D4
move -8(A6),D0
sub D5,D0
muls -22(A6),D0
divs -28(A6),D0
sub D0,D4

TG364:
bra.s TG365

TG362:
*
cmp -16(A6),D5
blt.s FSL182

move -14(A6),D4
bra.s TG365

FSL182:
*
move    -10(A6),D4
move    -12(A6),D0
sub     D5,D0
muls    -20(A6),D0
divs    -26(A6),D0
sub     D0,D4

TG365:

*
* move D3,(sp)
* move D5,-(sp)
* move D4,-(sp)
* move D6,-(sp)
* bsr Line
* addq.l #6,sp

bsr HLINE

add #1,D5
TG357:
*
cmp -4(A6),D5
ble TG356

TG355:
TG341:

TG332:

movem.l (sp)+,D3-D7/A4-A5
unlk A6
rts



*****************************
* losange quelconque
*****************************

* FourSide

FourSide:
**FourSide:
*xp1=8
*yp1=10
*xp2=12
*yp2=14
*xp3=16
*yp3=18
*xp4=20
*yp4=22
*color=24

link A6,#-76
movem.l D3-D7/A4-A5,-(sp)


* move 22(A6),Y4b
* move 20(A6),X4b
* move 18(A6),Y3b
* move 16(A6),X3b
* move 14(A6),Y2b
* move 12(A6),X2b
* move 10(A6),Y1b
* move  8(A6),X1b

* positionne l'‚cran video
move.l  video,A1

*decallag=D7
*xg=D6
*yg=D5
*xd=D4
*col=D3
*
move 24(A6),D3

*a=-4
*b=-8
*d12yd34x=-12
*d34yd12x=-16
*yd=-18
*x=-20
*y=-22
*yh=-24
*y0=-26
*i=-28
*x1=-30
*y1=-32
*x2=-34
*y2=-36
*x3=-38
*y3=-40
*x4=-42
*y4=-44
*l=-48
*d14yd23x=-52
*d23yd14x=-56
*d41x=-58
*d34x=-60
*d23x=-62
*d12x=-64
*d41y=-66
*d34y=-68
*d23y=-70
*d12y=-72
*ruptgauc=-74
*ruptdroi=-76
*
*
move    8(A6),D0
cmp     xsmin,D0
blt.s FS195
cmp     xsmax,D0
bgt.s FS195

move    10(A6),D0
cmp     xsmin,D0
blt.s FS195
cmp     ypmax,D0
bgt.s FS195

bra FS196


FS195:

move    12(A6),D0
cmp     xsmin,D0
blt.s FS197
cmp     xsmax,D0
bgt.s FS197

move    14(A6),D0
cmp     xsmin,D0
blt.s FS197
cmp     ypmax,D0
bgt.s FS197

bra.s FS198


FS197:

move    16(A6),D0
cmp     xsmin,D0
blt.s FS199
cmp     xsmax,D0
bgt.s FS199

move    18(A6),D0
cmp     xsmin,D0
blt.s FS199
cmp     ypmax,D0
bgt.s FS199

bra.s FS200


FS199:

move    20(A6),D0
cmp     xsmin,D0
blt.s FS201
cmp     xsmax,D0
bgt.s FS201

move    22(A6),D0
cmp     xsmin,D0
blt.s FS201
cmp     ypmax,D0
bgt.s FS201

bra.s FS202

FS201:

bra FS203


FS202:
FS200:
FS198:
FS196:

tst modeflag
beq.s FSL1

* move D3,-(sp)
* move 14(A6),-(sp)
* move 12(A6),-(sp)
* move 10(A6),-(sp)
* move 8(A6),-(sp)
* bsr Draw
* add.l #10,sp

* move D3,-(sp)
* move 18(A6),-(sp)
* move 16(A6),-(sp)
* move 14(A6),-(sp)
* move 12(A6),-(sp)
* bsr Draw
* add.l #10,sp

move D3,-(sp)
move 22(A6),-(sp)
move 20(A6),-(sp)
move 18(A6),-(sp)
move 16(A6),-(sp)
bsr Draw
add.l #10,sp

move D3,-(sp)
move 10(A6),-(sp)
move 8(A6),-(sp)
move 22(A6),-(sp)
move 20(A6),-(sp)
bsr Draw
add.l #10,sp

bra FS203

FSL1:

*
move 10(A6),D0
cmp 14(A6),D0
bgt FS204
*
*
move 10(A6),D0
cmp 18(A6),D0
bgt FS205
*
*
move 10(A6),D0
cmp 22(A6),D0
bgt FS206
*
move 8(A6),-30(A6)
move 10(A6),-32(A6)
move 12(A6),-34(A6)
move 14(A6),-36(A6)
move 16(A6),-38(A6)
move 18(A6),-40(A6)
move 20(A6),-42(A6)
move 22(A6),-44(A6)
*
bra FSdist
FS206:
*
move 20(A6),-30(A6)
move 22(A6),-32(A6)
move 8(A6),-34(A6)
move 10(A6),-36(A6)
move 12(A6),-38(A6)
move 14(A6),-40(A6)
move 16(A6),-42(A6)
move 18(A6),-44(A6)

bra FSdist
FS207:
*
bra FS208
FS205:
*
move 18(A6),D0
cmp 22(A6),D0
bgt FS209
*
move 16(A6),-30(A6)
move 18(A6),-32(A6)
move 20(A6),-34(A6)
move 22(A6),-36(A6)
move 8(A6),-38(A6)
move 10(A6),-40(A6)
move 12(A6),-42(A6)
move 14(A6),-44(A6)
*
bra FSdist
FS209:
*
move 20(A6),-30(A6)
move 22(A6),-32(A6)
move 8(A6),-34(A6)
move 10(A6),-36(A6)
move 12(A6),-38(A6)
move 14(A6),-40(A6)
move 16(A6),-42(A6)
move 18(A6),-44(A6)

bra FSdist
FS210:

FS208:
*
bra FS211
FS204:
*
move 14(A6),D0
cmp 18(A6),D0
bgt FS212
*
move 14(A6),D0
cmp 22(A6),D0
bgt FS213
*
move 12(A6),-30(A6)
move 14(A6),-32(A6)
move 16(A6),-34(A6)
move 18(A6),-36(A6)
move 20(A6),-38(A6)
move 22(A6),-40(A6)
move 8(A6),-42(A6)
move 10(A6),-44(A6)
*
bra FSdist
FS213:
*
move 20(A6),-30(A6)
move 22(A6),-32(A6)
move 8(A6),-34(A6)
move 10(A6),-36(A6)
move 12(A6),-38(A6)
move 14(A6),-40(A6)
move 16(A6),-42(A6)
move 18(A6),-44(A6)

bra FSdist
FS214:
*
bra FS215
FS212:
*
move 18(A6),D0
cmp 22(A6),D0
bgt FS216
*
move 16(A6),-30(A6)
move 18(A6),-32(A6)
move 20(A6),-34(A6)
move 22(A6),-36(A6)
move 8(A6),-38(A6)
move 10(A6),-40(A6)
move 12(A6),-42(A6)
move 14(A6),-44(A6)
*
bra FSdist
FS216:
*
move 20(A6),-30(A6)
move 22(A6),-32(A6)
move 8(A6),-34(A6)
move 10(A6),-36(A6)
move 12(A6),-38(A6)
move 14(A6),-40(A6)
move 16(A6),-42(A6)
move 18(A6),-44(A6)

FS217:
FS215:
FS211:

FSdist:

*
move -42(A6),D0
sub -30(A6),D0
move D0,-58(A6)
*
move -38(A6),D0
sub -42(A6),D0
move D0,-60(A6)
*
move -34(A6),D0
sub -38(A6),D0
move D0,-62(A6)
*
move -30(A6),D0
sub -34(A6),D0
move D0,-64(A6)
*
move -44(A6),D0
sub -32(A6),D0
move D0,-66(A6)
*
move -40(A6),D0
sub -44(A6),D0
move D0,-68(A6)
*
move -36(A6),D0
sub -40(A6),D0
move D0,-70(A6)
*
move -32(A6),D0
sub -36(A6),D0
move D0,-72(A6)
*
*
tst -72(A6)
bne FS218
*
*
*
*
tst -66(A6)
bne FS219
move -32(A6),D0
cmp -40(A6),D0
bne FS219
*
*
*
*
tst -64(A6)
bge FS220
*
*
move -30(A6),D0
cmp -38(A6),D0
bge FS221
*
*
tst -58(A6)
ble FS222
*
move -30(A6),D6
*
*
bra FS223
FS222:
*
*
move -42(A6),D6
FS223:
*
*
*
bra FS224
FS221:
*
*
*
tst -60(A6)
bge FS225
*
move -38(A6),D6
*
*
bra FS226
FS225:
*
*
move -42(A6),D6
FS226:
*
FS224:
*
*
*
bra FS227
FS220:
*
*
*
tst -62(A6)
bge FS228
*
*
move -34(A6),D0
cmp -42(A6),D0
bge FS229
*
move -34(A6),D6
*
*
bra FS230
FS229:
*
*
move -42(A6),D6
FS230:
*
*
*
bra FS231
FS228:
*
*
*
tst -60(A6)
bge FS232
*
move -38(A6),D6
*
*
bra FS233
FS232:
*
*
move -42(A6),D6
FS233:
*
FS231:
*
FS227:
*
*
*
*
tst -64(A6)
ble FS234
*
*
move -30(A6),D0
cmp -38(A6),D0
ble FS235
*
*
tst -58(A6)
bge FS236
*
move -30(A6),D4
*
*
bra FS237
FS236:
*
*
move -42(A6),D4
FS237:
*
*
*
bra FS238
FS235:
*
*
*
tst -60(A6)
ble FS239
*
move -38(A6),D4
*
*
bra FS240
FS239:
*
*
move -42(A6),D4
FS240:
*
FS238:
*
*
*
bra FS241
FS234:
*
*
*
tst -62(A6)
ble FS242
*
*
move -34(A6),D0
cmp -42(A6),D0
ble FS243
*
move -34(A6),D4
*
*
bra FS244
FS243:
*
*
move -42(A6),D4
FS244:
*
*
*
bra FS245
FS242:
*
*
*
tst -60(A6)
ble FS246
*
move -38(A6),D4
*
*
bra FS247
FS246:
*
*
move -42(A6),D4
FS247:
*
FS245:
*
FS241:
*
*
*
*
*
move D3,(sp)
move -32(A6),-(sp)
move D4,-(sp)
move D6,-(sp)
bsr Line
addq.l #6,sp
bra FS203
*
*
*
FS219:
*
*
tst -64(A6)
bne FS248
*
move D3,(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
*
FS248:
*
*
tst -66(A6)
bne FS249
*
*
tst -64(A6)
bge FS250
*
*
move -34(A6),D0
cmp -42(A6),D0
bge FS251
*
move D3,(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
*
bra FS252
FS251:
*
*
*
tst -58(A6)
ble FS253
*
move D3,(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
*
bra FS254
FS253:
*
*
move D3,(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
FS254:
*
FS252:
*
*
*
bra FS255
FS250:
*
*
*
move -34(A6),D0
cmp -42(A6),D0
ble FS256
*
move D3,(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
*
bra FS257
FS256:
*
*
*
tst -58(A6)
bge FS258
*
move D3,(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
*
bra FS259
FS258:
*
*
move D3,(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
FS259:
*
FS257:
*
FS255:
*
*
*
FS249:
*
*
move -32(A6),D0
cmp -40(A6),D0
bne FS260
*
*
tst -64(A6)
bge FS261
*
*
tst -62(A6)
bge FS262
*
move D3,(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
*
bra FS263
FS262:
*
*
*
move -30(A6),D0
cmp -38(A6),D0
bge FS264
*
move D3,(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
*
bra FS265
FS264:
*
*
move D3,(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
FS265:
*
FS263:
*
*
*
bra FS266
FS261:
*
*
*
tst -62(A6)
ble FS267
*
move D3,(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
*
bra FS268
FS267:
*
*
*
move -30(A6),D0
cmp -38(A6),D0
ble FS269
*
move D3,(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
*
bra FS270
FS269:
*
*
move D3,(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
FS270:
*
FS268:
*
FS266:
*
*
FS260:
*
*
FS218:
*
*
move -32(A6),D0
cmp -40(A6),D0
bne FS271
*
*
move -30(A6),D0
cmp -38(A6),D0
bne FS272
*
move D3,(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
bsr Draw
addq.l #8,sp
*
move D3,(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
bsr Draw
addq.l #8,sp
bra FS203
*
*
FS272:
*
*
FS271:
*
*
tst -66(A6)
bne FS273
*
*
tst -58(A6)
bne FS274
*
move D3,(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
*
FS274:
*
*
move -32(A6),D0
cmp -40(A6),D0
bne FS275
*
*
tst -64(A6)
bge FS276
*
*
tst -62(A6)
bge FS277
*
move D3,(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
*
bra FS278
FS277:
*
*
*
move -30(A6),D0
cmp -38(A6),D0
bge FS279
*
move D3,(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
*
bra FS280
FS279:
*
*
move D3,(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
FS280:
*
FS278:
*
*
*
bra FS281
FS276:
*
*
*
tst -62(A6)
ble FS282
*
move D3,(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
*
bra FS283
FS282:
*
*
*
move -30(A6),D0
cmp -38(A6),D0
ble FS284
*
move D3,(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
*
bra FS285
FS284:
*
*
move D3,(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
FS285:
*
FS283:
*
FS281:
*
*
FS275:
*
*
*
*
FS273:
*
*
tst -70(A6)
blt FS286
tst -68(A6)
bgt FS286
*
move -72(A6),D0
muls -60(A6),D0
move.l D0,-12(A6)
*
move -68(A6),D0
muls -64(A6),D0
move.l D0,-16(A6)
*
move.l -12(A6),D0
sub.l -16(A6),D0
move.l D0,-4(A6)
*
*
*
tst.l -4(A6)
beq FS287
*

move.l  -16(A6),d1
move    -38(A6),d0
bsr     mul16x32
move.l  D0,-(sp)

move.l  -12(A6),d1
move    -30(A6),d0
bsr     mul16x32
move.l  D0,-(sp)

move    -40(A6),D1
sub     -32(A6),D1
muls    -64(A6),D1
move    -60(A6),D0
bsr     mul16x32

add.l   (sp)+,D0
sub.l   (sp)+,D0

move.l  -4(A6),d1
bsr     div32p32
move    D0,D6
addq    #1,d6

*
*
cmp -30(A6),D6
ble FS10009
cmp -34(A6),D6
blt FS10008
FS10009:
cmp -34(A6),D6
ble FS288
cmp -30(A6),D6
bge FS288

FS10008:
move    -32(A6),D5
move    -30(A6),D0
sub     D6,D0
muls    -72(A6),D0
divs    -64(A6),D0
sub     D0,D5
addq    #1,d5
*
*
*
*
move D3,(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move D5,-(sp)
move D6,-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
bsr Triangle
adda.l #12,sp
*
move D3,(sp)
move D5,-(sp)
move D6,-(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
*
FS288:
*
*
cmp -38(A6),D6
ble FS10011
cmp -42(A6),D6
blt FS10010
FS10011:cmp -42(A6),D6
ble FS289
cmp -38(A6),D6
bge FS289

FS10010:
move    -40(A6),D5
move    -38(A6),D0
sub     D6,D0
muls    -68(A6),D0
divs    -60(A6),D0
sub     D0,D5
addq    #1,d5
*
*
*
*
move D3,(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
move D5,-(sp)
move D6,-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
bsr Triangle
adda.l #12,sp
*
move D3,(sp)
move D5,-(sp)
move D6,-(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
FS289:
*
*
FS287:
*
move -66(A6),D0
neg D0
muls -62(A6),D0
move.l D0,-52(A6)
*
move -58(A6),D0
neg D0
muls -70(A6),D0
move.l D0,-56(A6)
*
move.l -52(A6),D0
sub.l -56(A6),D0
move.l D0,-4(A6)
*
*
*
tst.l -4(A6)
beq FS290
*

move.l  -56(A6),d1
move    -34(A6),d0
bsr     mul16x32
move.l  D0,-(sp)

move.l  -52(A6),d0
move    -30(A6),d1
bsr     mul16x32
move.l  d0,-(sp)

move    -72(A6),D1
muls    -58(A6),D1
move    -62(A6),D0
bsr     mul16x32

add.l   (sp)+,D0
sub.l   (sp)+,D0

move.l  -4(A6),d1
bsr     div32p32
move    D0,D6
addq    #1,d6

*
cmp -30(A6),D6
ble FS10013
cmp -42(A6),D6
blt FS10012
FS10013:
cmp -42(A6),D6
ble FS291
cmp -30(A6),D6
bge FS291

FS10012:
move    D6,D5
sub     -30(A6),D5
muls    -66(A6),D5
divs    -58(A6),D5
add     -32(A6),D5
addq    #1,d5
*
*
*
*
move D3,(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
move D5,-(sp)
move D6,-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
bsr Triangle
adda.l #12,sp
*
move D3,(sp)
move D5,-(sp)
move D6,-(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
*
FS291:
*
*
cmp -34(A6),D6
ble FS10015
cmp -38(A6),D6
blt FS10014
FS10015:
cmp -38(A6),D6
ble FS292
cmp -34(A6),D6
bge FS292

FS10014:
move    -36(A6),D5
move    -34(A6),D0
sub     D6,D0
muls    -70(A6),D0
divs    -62(A6),D0
sub     D0,D5
addq    #1,d5
*
*
*
*
move D3,(sp)
move -36(A6),-(sp)
move -34(A6),-(sp)
move D5,-(sp)
move D6,-(sp)
move -32(A6),-(sp)
move -30(A6),-(sp)
bsr Triangle
adda.l #12,sp
*
move D3,(sp)
move D5,-(sp)
move D6,-(sp)
move -40(A6),-(sp)
move -38(A6),-(sp)
move -44(A6),-(sp)
move -42(A6),-(sp)
bsr Triangle
adda.l #12,sp
bra FS203
*
*
FS292:
*
FS290:
*
*
*
*
FS286:
*
*
tst -70(A6)
ble FS293
*
*
move -36(A6),D0
cmp -44(A6),D0
ble FS294
*
move -36(A6),-24(A6)
*
*
bra FS295
FS294:
*
*
move -44(A6),-24(A6)
FS295:
*
*
*
bra FS296
FS293:
*
*
*
tst -68(A6)
ble FS297
*
move -40(A6),-24(A6)
*
*
bra FS298
FS297:
*
*
move -44(A6),-24(A6)
FS298:
*
FS296:
*
*
move -24(A6),D0
cmp ysmax,D0
ble FS299
*
move ysmax,-24(A6)
*
*
*
*
FS299:
*

* trac‚ par horizontale

* col=D3

and     #$f,D3
move    D3,A2

add.l   a2,a2
add.l   a2,a2

tst moniteur
beq.s FS001

add.l #HLMONO,a2
bra.s FS005

FS001:
add.l #HL16COL,a2

FS005:

* A2 routine de la couleur choisie
move.l  (a2),a2


move #-1,-74(A6)
move #-1,-76(A6)
move -32(A6),D5
move -30(A6),D6
move D6,D4


cmp ysmin,d5
bge.s FSL17

move ysmin,d5


cmp -44(a6),d5
blt.s FSL18

clr -74(a6)

FSL18:

tst -74(a6)
bne.s FSL19

cmp -40(a6),d5
blt.s FSL20

move #1,-74(a6)

FSL20:
FSL19:


cmp -36(a6),d5
blt.s FSL21

clr -76(a6)

FSL21:

tst -76(a6)
bne.s FSL22

cmp -40(a6),d5
blt.s FSL23

move #1,-76(a6)

FSL23:
FSL22:
FSL17:


bra FS315
FS314:
*
*
*
tst -74(A6)
bge.s FS316
*
*
cmp -44(A6),D5
blt.s FS317
*
move -42(A6),D6
clr -74(A6)
*
bra.s FS319

FS317:
*
move D5,D6
sub -32(A6),D6
muls -58(A6),D6
divs -66(A6),D6
add -30(A6),D6

FS318:
bra.s FS319

FS316:
*
tst -74(A6)
bne.s FS320
*
*
cmp -40(A6),D5
blt.s FS321
*
move -38(A6),D6
move #1,-74(A6)

bra.s FS319

FS321:
*
move D5,D6
sub -44(A6),D6
muls -60(A6),D6
divs -68(A6),D6
add -42(A6),D6

FS322:
bra.s FS323

FS320:
*
cmp -36(A6),D5
blt.s FSL137

move -34(A6),D6
bra.s FS319

FSL137:

move D5,D6
sub -40(A6),D6
muls -62(A6),D6
divs -70(A6),D6
add -38(A6),D6

FS323:
FS319:



tst -76(A6)
bge.s FS324
*
cmp -36(A6),D5
blt.s FS325
*
move -34(A6),D4
clr -76(A6)
*
bra.s FS327

FS325:
*
move -30(A6),D4
move -32(A6),D0
sub D5,D0
muls -64(A6),D0
divs -72(A6),D0
sub D0,D4

FS326:
bra FS327

FS324:

tst -76(A6)
bne.s FS328
*
cmp -40(A6),D5
blt.s FS329
*
move -38(A6),D4
move #1,-76(A6)
*
bra.s FS327

FS329:
*
move -34(A6),D4
move -36(A6),D0
sub D5,D0
muls -62(A6),D0
divs -70(A6),D0
sub D0,D4

FS330:
bra.s FS331

FS328:
*
cmp -44(A6),D5
blt.s FSL147

move -42(A6),D4
bra.s FS327

FSL147:

move -38(A6),D4
move -40(A6),D0
sub D5,D0
muls -60(A6),D0
divs -68(A6),D0
sub D0,D4

FS331:
FS327:


* move D3,(sp)
* move D5,-(sp)
* move D4,-(sp)
* move D6,-(sp)
* bsr Line
* addq.l #6,sp

bsr.s HLINE
addq #1,D5

FS315:

cmp -24(A6),D5
ble FS314

FS313:
FS203:
FS194:

movem.l (sp)+,D3-D7/A4-A5
unlk A6
rts



HLINE:
*
* registres 
* en entr‚e
*
* D6  = xg
* D5  = yg
* D4  = xd
* D3  = color
*
* en sortie
*
* A4, A5 = adresse dans video
*
* D4 et D6 modifi‚s
* D6 : pointeur de bit
* D4 = w  
*
*
cmp    D4,D6
ble.s HL9

exg    D6,D4

HL9:
cmp     xsmax,D6
bgt.s HL999

cmp     xsmin,D6
bge.s HL91
move    xsmin,D6

HL91:
cmp     xsmin,D4
blt.s HL999

cmp     xsmax,D4
ble.s HL92
move    xsmax,D4

HL92:
* D4 = w  
sub     D6,D4

jmp (A2)

HL999:
rts




* couleur 0

HL100:

move    lgligne,D0
muls    D5,D0
add.l   D0,D0
move.l  D0,A5
add.l   A1,A5

* D6 et D2 pointeur bit
add     D6,D6
move    D6,D0
and     #$F,D6
neg     D6
add     #$F,D6
move    D6,D2
subq    #1,D2

ext.l   D0
lsr.l   #4,D0
add.l   D0,D0
add.l   D0,A5
move    lgligne,A4
add.l   A5,A4

move   (A5),D0
move   (A4),D1

HL1009:

tst    D6
bge.s HL1000
*
HL1002:
move   D0,(A5)+
move   D1,(A4)+
cmp    #8,D4
bge.s HL1001
move   (A5),D0
move   (A4),D1
moveq  #15,D6
moveq  #14,D2
*
HL1000:
bclr   D6,D0
bclr   D2,D0
bclr   D6,D1
bclr   D2,D1
*
subq   #2,D6
subq   #2,D2
dbra D4, HL1009
*
move   D0,(A5)
move   D1,(A4)
rts
*
HL1001:
clr    D0
clr    D1
subq   #8,D4
bra.s HL1002



* couleur 1

HL101:

move    lgligne,D0
muls    D5,D0
add.l   D0,D0
move.l  D0,A5
add.l   A1,A5

* D6 et D2 pointeur bit
add     D6,D6
move    D6,D0
and     #$F,D6
neg     D6
add     #$F,D6
move    D6,D2
subq    #1,D2

ext.l   D0
lsr.l   #4,D0
add.l   D0,D0
add.l   D0,A5
move   lgligne,A4
add.l   A5,A4

move   (A5),D0
move   (A4),D1

HL1019:

tst    D6
bge.s HL1010
*
HL1012:
move   D0,(A5)+
move   D1,(A4)+
cmp    #8,D4
bge.s HL1011
move   (A5),D0
move   (A4),D1
moveq  #15,D6
moveq  #14,D2
*
HL1010:
bset   D6,D0
bclr   D2,D0
bclr   D6,D1
bclr   D2,D1
*
subq   #2,D6
subq   #2,D2
dbra D4, HL1019
*
move   D0,(A5)
move   D1,(A4)
rts
*
HL1011:
move   #$AAAA,D0
clr    D1
subq   #8,D4
bra.s HL1012




* couleur 2

HL102:

move    lgligne,D0
muls    D5,D0
add.l   D0,D0
move.l  D0,A5
add.l   A1,A5

* D6 et D2 pointeur bit
add     D6,D6
move    D6,D0
and     #$F,D6
neg     D6
add     #$F,D6
move    D6,D2
subq    #1,D2

ext.l   D0
lsr.l   #4,D0
add.l   D0,D0
add.l   D0,A5
move   lgligne,A4
add.l   A5,A4

move   (A5),D0
move   (A4),D1

HL1029:

tst    D6
bge.s HL1020
*
HL1022:
move   D0,(A5)+
move   D1,(A4)+
cmp    #8,D4
bge.s HL1021
move   (A5),D0
move   (A4),D1
moveq  #15,D6
moveq  #14,D2
*
HL1020:
bclr   D6,D0
bset   D2,D0
bclr   D6,D1
bclr   D2,D1
*
subq   #2,D6
subq   #2,D2
dbra D4, HL1029
*
move   D0,(A5)
move   D1,(A4)
rts
*
HL1021:
move   #$5555,D0
clr    D1
subq   #8,D4
bra.s HL1022




* couleur 3

HL103:

move    lgligne,D0
muls    D5,D0
add.l   D0,D0
move.l  D0,A5
add.l   A1,A5

* D6 et D2 pointeur bit
add     D6,D6
move    D6,D0
and     #$F,D6
neg     D6
add     #$F,D6
move    D6,D2
subq    #1,D2

ext.l   D0
lsr.l   #4,D0
add.l   D0,D0
add.l   D0,A5
move   lgligne,A4
add.l   A5,A4

move   (A5),D0
move   (A4),D1

HL1039:

tst    D6
bge.s HL1030
*
HL1032:
move   D0,(A5)+
move   D1,(A4)+
cmp    #8,D4
bge.s HL1031
move   (A5),D0
move   (A4),D1
moveq  #15,D6
moveq  #14,D2
*
HL1030:
bset   D6,D0
bset   D2,D0
bclr   D6,D1
bclr   D2,D1
*
subq   #2,D6
subq   #2,D2
dbra D4, HL1039
*
move   D0,(A5)
move   D1,(A4)
rts
*
HL1031:
move   #$FFFF,D0
clr    D1
subq   #8,D4
bra.s HL1032




* couleur 4

HL104:

move    lgligne,D0
muls    D5,D0
add.l   D0,D0
move.l  D0,A5
add.l   A1,A5

* D6 et D2 pointeur bit
add     D6,D6
move    D6,D0
and     #$F,D6
neg     D6
add     #$F,D6
move    D6,D2
subq    #1,D2

ext.l   D0
lsr.l   #4,D0
add.l   D0,D0
add.l   D0,A5
move   lgligne,A4
add.l   A5,A4

move   (A5),D0
move   (A4),D1

HL1049:

tst    D6
bge.s HL1040
*
HL1042:
move   D0,(A5)+
move   D1,(A4)+
cmp    #8,D4
bge.s HL1041
move   (A5),D0
move   (A4),D1
moveq  #15,D6
moveq  #14,D2
*
HL1040:
bclr   D6,D0
bclr   D2,D0
bset   D6,D1
bclr   D2,D1
*
subq   #2,D6
subq   #2,D2
dbra D4, HL1049
*
move   D0,(A5)
move   D1,(A4)
rts
*
HL1041:
clr    D0
move   #$AAAA,D1
subq   #8,D4
bra.s HL1042




* couleur 5

HL105:

move    lgligne,D0
muls    D5,D0
add.l   D0,D0
move.l  D0,A5
add.l   A1,A5

* D6 et D2 pointeur bit
add     D6,D6
move    D6,D0
and     #$F,D6
neg     D6
add     #$F,D6
move    D6,D2
subq    #1,D2

ext.l   D0
lsr.l   #4,D0
add.l   D0,D0
add.l   D0,A5
move   lgligne,A4
add.l   A5,A4

move   (A5),D0
move   (A4),D1

HL1059:

tst    D6
bge.s HL1050
*
HL1052:
move   D0,(A5)+
move   D1,(A4)+
cmp    #8,D4
bge.s HL1051
move   (A5),D0
move   (A4),D1
moveq  #15,D6
moveq  #14,D2
*
HL1050:
bset   D6,D0
bclr   D2,D0
bset   D6,D1
bclr   D2,D1
*
subq   #2,D6
subq   #2,D2
dbra D4, HL1059
*
move   D0,(A5)
move   D1,(A4)
rts
*
HL1051:
move   #$AAAA,D0
move   #$AAAA,D1
subq   #8,D4
bra.s HL1052




* couleur 6
*
HL106:

move    lgligne,D0
muls    D5,D0
add.l   D0,D0
move.l  D0,A5
add.l   A1,A5

* D6 et D2 pointeur bit
add     D6,D6
move    D6,D0
and     #$F,D6
neg     D6
add     #$F,D6
move    D6,D2
subq    #1,D2

ext.l   D0
lsr.l   #4,D0
add.l   D0,D0
add.l   D0,A5
move   lgligne,A4
add.l   A5,A4

move   (A5),D0
move   (A4),D1

HL1069:

tst    D6
bge.s HL1060
*
HL1062:
move   D0,(A5)+
move   D1,(A4)+
cmp    #8,D4
bge.s HL1061
move   (A5),D0
move   (A4),D1
moveq  #15,D6
moveq  #14,D2
*
HL1060:
bclr   D6,D0
bset   D2,D0
bset   D6,D1
bclr   D2,D1
*
subq   #2,D6
subq   #2,D2
dbra D4, HL1069
*
move   D0,(A5)
move   D1,(A4)
rts
*
HL1061:
move   #$5555,D0
move   #$AAAA,D1
subq   #8,D4
bra.s HL1062




* couleur 7

HL107:

move    lgligne,D0
muls    D5,D0
add.l   D0,D0
move.l  D0,A5
add.l   A1,A5

* D6 et D2 pointeur bit
add     D6,D6
move    D6,D0
and     #$F,D6
neg     D6
add     #$F,D6
move    D6,D2
subq    #1,D2

ext.l   D0
lsr.l   #4,D0
add.l   D0,D0
add.l   D0,A5
move   lgligne,A4
add.l   A5,A4

move   (A5),D0
move   (A4),D1

HL1079:

tst    D6
bge.s HL1070
*
HL1072:
move   D0,(A5)+
move   D1,(A4)+
cmp    #8,D4
bge.s HL1071
move   (A5),D0
move   (A4),D1
moveq  #15,D6
moveq  #14,D2
*
HL1070:
bset   D6,D0
bset   D2,D0
bset   D6,D1
bclr   D2,D1
*
subq   #2,D6
subq   #2,D2
dbra D4, HL1079
*
move   D0,(A5)
move   D1,(A4)
rts
*
HL1071:
move   #$FFFF,D0
move   #$AAAA,D1
subq   #8,D4
bra.s HL1072




* couleur 8

HL108:

move    lgligne,D0
muls    D5,D0
add.l   D0,D0
move.l  D0,A5
add.l   A1,A5

* D6 et D2 pointeur bit
add     D6,D6
move    D6,D0
and     #$F,D6
neg     D6
add     #$F,D6
move    D6,D2
subq    #1,D2

ext.l   D0
lsr.l   #4,D0
add.l   D0,D0
add.l   D0,A5
move   lgligne,A4
add.l   A5,A4

move   (A5),D0
move   (A4),D1

HL1089:

tst    D6
bge.s HL1080
*
HL1082:
move   D0,(A5)+
move   D1,(A4)+
cmp    #8,D4
bge.s HL1081
move   (A5),D0
move   (A4),D1
moveq  #15,D6
moveq  #14,D2
*
HL1080:
bclr   D6,D0
bclr   D2,D0
bclr   D6,D1
bset   D2,D1
*
subq   #2,D6
subq   #2,D2
dbra D4, HL1089
*
move   D0,(A5)
move   D1,(A4)
rts
*
HL1081:
clr    D0
move   #$5555,D1
subq   #8,D4
bra.s HL1082




* couleur 9

HL109:

move    lgligne,D0
muls    D5,D0
add.l   D0,D0
move.l  D0,A5
add.l   A1,A5

* D6 et D2 pointeur bit
add     D6,D6
move    D6,D0
and     #$F,D6
neg     D6
add     #$F,D6
move    D6,D2
subq    #1,D2

ext.l   D0
lsr.l   #4,D0
add.l   D0,D0
add.l   D0,A5
move   lgligne,A4
add.l   A5,A4

move   (A5),D0
move   (A4),D1

HL1099:

tst    D6
bge.s HL1090
*
HL1092:
move   D0,(A5)+
move   D1,(A4)+
cmp    #8,D4
bge.s HL1091
move   (A5),D0
move   (A4),D1
moveq  #15,D6
moveq  #14,D2
*
HL1090:
bset   D6,D0
bclr   D2,D0
bclr   D6,D1
bset   D2,D1
*
subq   #2,D6
subq   #2,D2
dbra D4, HL1099
*
move   D0,(A5)
move   D1,(A4)
rts
*
HL1091:
move   #$AAAA,D0
move   #$5555,D1
subq   #8,D4
bra.s HL1092




* couleur 10

HL110:

move    lgligne,D0
muls    D5,D0
add.l   D0,D0
move.l  D0,A5
add.l   A1,A5

* D6 et D2 pointeur bit
add     D6,D6
move    D6,D0
and     #$F,D6
neg     D6
add     #$F,D6
move    D6,D2
subq    #1,D2

ext.l   D0
lsr.l   #4,D0
add.l   D0,D0
add.l   D0,A5
move   lgligne,A4
add.l   A5,A4

move   (A5),D0
move   (A4),D1

HL1109:

tst    D6
bge.s HL1100
*
HL1102:
move   D0,(A5)+
move   D1,(A4)+
cmp    #8,D4
bge.s HL1101
move   (A5),D0
move   (A4),D1
moveq  #15,D6
moveq  #14,D2
*
HL1100:
bclr   D6,D0
bset   D2,D0
bclr   D6,D1
bset   D2,D1
*
subq   #2,D6
subq   #2,D2
dbra D4, HL1109
*
move   D0,(A5)
move   D1,(A4)
rts
*
HL1101:
move   #$5555,D0
move   #$5555,D1
subq   #8,D4
bra.s HL1102




* couleur 11

HL111:

move    lgligne,D0
muls    D5,D0
add.l   D0,D0
move.l  D0,A5
add.l   A1,A5

* D6 et D2 pointeur bit
add     D6,D6
move    D6,D0
and     #$F,D6
neg     D6
add     #$F,D6
move    D6,D2
subq    #1,D2

ext.l   D0
lsr.l   #4,D0
add.l   D0,D0
add.l   D0,A5
move   lgligne,A4
add.l   A5,A4

move   (A5),D0
move   (A4),D1

HL1119:

tst    D6
bge.s HL1110
*
HL1112:
move   D0,(A5)+
move   D1,(A4)+
cmp    #8,D4
bge.s HL1111
move   (A5),D0
move   (A4),D1
moveq  #15,D6
moveq  #14,D2
*
HL1110:
bset   D6,D0
bset   D2,D0
bclr   D6,D1
bset   D2,D1
*
subq   #2,D6
subq   #2,D2
dbra D4, HL1119
*
move   D0,(A5)
move   D1,(A4)
rts
*
HL1111:
move   #$FFFF,D0
move   #$5555,D1
subq   #8,D4
bra.s HL1112




* couleur 12

HL112:

move    lgligne,D0
muls    D5,D0
add.l   D0,D0
move.l  D0,A5
add.l   A1,A5

* D6 et D2 pointeur bit
add     D6,D6
move    D6,D0
and     #$F,D6
neg     D6
add     #$F,D6
move    D6,D2
subq    #1,D2

ext.l   D0
lsr.l   #4,D0
add.l   D0,D0
add.l   D0,A5
move   lgligne,A4
add.l   A5,A4

move   (A5),D0
move   (A4),D1

HL1129:

tst    D6
bge.s HL1120
*
HL1122:
move   D0,(A5)+
move   D1,(A4)+
cmp    #8,D4
bge.s  HL1121
move   (A5),D0
move   (A4),D1
moveq  #15,D6
moveq  #14,D2
*
HL1120:
bclr   D6,D0
bclr   D2,D0
bset   D6,D1
bset   D2,D1
*
subq   #2,D6
subq   #2,D2
dbra D4, HL1129
*
move   D0,(A5)
move   D1,(A4)
rts
*
HL1121:
clr    D0
move   #$FFFF,D1
subq   #8,D4
bra.s HL1122




* couleur 13

HL113:

move    lgligne,D0
muls    D5,D0
add.l   D0,D0
move.l  D0,A5
add.l   A1,A5

* D6 et D2 pointeur bit
add     D6,D6
move    D6,D0
and     #$F,D6
neg     D6
add     #$F,D6
move    D6,D2
subq    #1,D2

ext.l   D0
lsr.l   #4,D0
add.l   D0,D0
add.l   D0,A5
move   lgligne,A4
add.l   A5,A4

move   (A5),D0
move   (A4),D1

HL1139:

tst    D6
bge.s HL1130
*
HL1132:
move   D0,(A5)+
move   D1,(A4)+
cmp    #8,D4
bge.s HL1131
move   (A5),D0
move   (A4),D1
moveq  #15,D6
moveq  #14,D2
*
HL1130:
bset   D6,D0
bclr   D2,D0
bset   D6,D1
bset   D2,D1
*
subq   #2,D6
subq   #2,D2
dbra D4, HL1139
*
move   D0,(A5)
move   D1,(A4)
rts
*
HL1131:
move   #$AAAA,D0
move   #$FFFF,D1
subq   #8,D4
bra.s HL1132




* couleur 14

HL114:

move    lgligne,D0
muls    D5,D0
add.l   D0,D0
move.l  D0,A5
add.l   A1,A5

* D6 et D2 pointeur bit
add     D6,D6
move    D6,D0
and     #$F,D6
neg     D6
add     #$F,D6
move    D6,D2
subq    #1,D2

ext.l   D0
lsr.l   #4,D0
add.l   D0,D0
add.l   D0,A5
move   lgligne,A4
add.l   A5,A4

move   (A5),D0
move   (A4),D1

HL1149:

tst    D6
bge.s HL1140
*
HL1142:
move   D0,(A5)+
move   D1,(A4)+
cmp    #8,D4
bge.s  HL1141
move   (A5),D0
move   (A4),D1
moveq  #15,D6
moveq  #14,D2
*
HL1140:
bclr   D6,D0
bset   D2,D0
bset   D6,D1
bset   D2,D1
*
subq   #2,D6
subq   #2,D2
dbra D4, HL1149
*
move   D0,(A5)
move   D1,(A4)
rts
*
HL1141:
move   #$5555,D0
move   #$FFFF,D1
subq   #8,D4
bra.s HL1142




* couleur 15

HL115:

move    lgligne,D0
muls    D5,D0
add.l   D0,D0
move.l  D0,A5
add.l   A1,A5

* D6 et D2 pointeur bit
add     D6,D6
move    D6,D0
and     #$F,D6
neg     D6
add     #$F,D6
move    D6,D2
subq    #1,D2

ext.l   D0
lsr.l   #4,D0
add.l   D0,D0
add.l   D0,A5
move   lgligne,A4
add.l   A5,A4

move   (A5),D0
move   (A4),D1

HL1159:

tst    D6
bge.s HL1150
*
HL1152:
move   D0,(A5)+
move   D1,(A4)+
cmp    #8,D4
bge.s HL1151
move   (A5),D0
move   (A4),D1
moveq  #15,D6
moveq  #14,D2
*
HL1150:
bset   D6,D0
bset   D2,D0
bset   D6,D1
bset   D2,D1
*
subq   #2,D6
subq   #2,D2
dbra D4, HL1159
*
move   D0,(A5)
move   D1,(A4)
rts
*
HL1151:
move   #$FFFF,D0
move   #$FFFF,D1
subq   #8,D4
bra.s HL1152





* couleur 0

HL400:

move    lgligne,D0
muls    D5,D0
move    D0,A5
add.l   A1,A5

move    D6,D0
ext.L   D0
lsr.L   #4,D0
lsl.l   #3,D0
add.L   D0,A5

* D6 pointeur bit
and     #$F,D6
neg     D6
add     #$F,D6

move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7

HL4009:

tst    D6
bge.s HL4000
*
HL4002:
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)+
cmp    #16,D4
bge.s HL4001
move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7
moveq  #15,D6
*
HL4000:
bclr   D6,D0
bclr   D6,D1
bclr   D6,D2
bclr   D6,D7
*
subq   #1,D6
dbra D4, HL4009
*
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)
rts
*
HL4001:
clr    D0
clr    D1
clr    D2
clr    D7
sub    #16,D4
bra.s HL4002
*
*
* couleur 1
*
HL401:

move    lgligne,D0
muls    D5,D0
move    D0,A5
add.l   A1,A5

move    D6,D0
ext.L   D0
lsr.L   #4,D0
lsl.l   #3,D0
add.L   D0,A5

* D6 pointeur bit
and     #$F,D6
neg     D6
add     #$F,D6

move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7

HL4019:

tst    D6
bge.s HL4010
*
HL4012:
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)+
cmp    #16,D4
bge.s HL4011
move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7
moveq  #15,D6
*
HL4010:
bset   D6,D0
bclr   D6,D1
bclr   D6,D2
bclr   D6,D7
*
subq   #1,D6
*
dbra D4, HL4019
*
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)
rts
*
HL4011:
move   #$FFFF,D0
clr    D1
clr    D2
clr    D7
sub    #16,D4
bra.s HL4012




* couleur 2

HL402:

move    lgligne,D0
muls    D5,D0
move    D0,A5
add.l   A1,A5

move    D6,D0
ext.L   D0
lsr.L   #4,D0
lsl.l   #3,D0
add.L   D0,A5

* D6 pointeur bit
and     #$F,D6
neg     D6
add     #$F,D6

move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7

HL4029:

tst    D6
bge.s HL4020
*
HL4022:
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)+
cmp    #16,D4
bge.s HL4021
move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7
moveq  #15,D6
*
HL4020:
bclr   D6,D0
bset   D6,D1
bclr   D6,D2
bclr   D6,D7
*
subq   #1,D6
*
dbra D4, HL4029
*
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)
rts
*
HL4021:
clr    D0
move   #$FFFF,D1
clr    D2
clr    D7
sub    #16,D4
bra.s HL4022




* couleur 3

HL403:

move    lgligne,D0
muls    D5,D0
move    D0,A5
add.l   A1,A5

move    D6,D0
ext.L   D0
lsr.L   #4,D0
lsl.l   #3,D0
add.L   D0,A5

* D6 pointeur bit
and     #$F,D6
neg     D6
add     #$F,D6

move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7

HL4039:

tst    D6
bge.s HL4030
*
HL4032:
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)+
cmp    #16,D4
bge.s HL4031
move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7
moveq  #15,D6
*
HL4030:
bset   D6,D0
bset   D6,D1
bclr   D6,D2
bclr   D6,D7
*
subq   #1,D6
*
dbra D4, HL4039
*
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)
rts
*
HL4031:
move   #$FFFF,D0
move   #$FFFF,D1
clr    D2
clr    D7
sub    #16,D4
bra.s HL4032




* couleur 4

HL404:

move    lgligne,D0
muls    D5,D0
move    D0,A5
add.l   A1,A5

move    D6,D0
ext.L   D0
lsr.L   #4,D0
lsl.l   #3,D0
add.L   D0,A5

* D6 pointeur bit
and     #$F,D6
neg     D6
add     #$F,D6

move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7

HL4049:

tst    D6
bge.s HL4040
*
HL4042:
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)+
cmp    #16,D4
bge.s HL4041
move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7
moveq  #15,D6
*
HL4040:
bclr   D6,D0
bclr   D6,D1
bset   D6,D2
bclr   D6,D7
*
subq   #1,D6
*
dbra D4, HL4049
*
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)
rts
*
HL4041:
clr    D0
clr    D1
move   #$FFFF,D2
clr    D7
sub    #16,D4
bra.s HL4042
*
*
* couleur 5
*
HL405:

move    lgligne,D0
muls    D5,D0
move    D0,A5
add.l   A1,A5

move    D6,D0
ext.L   D0
lsr.L   #4,D0
lsl.l   #3,D0
add.L   D0,A5

* D6 pointeur bit
and     #$F,D6
neg     D6
add     #$F,D6

move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7

HL4059:

tst    D6
bge.s HL4050
*
HL4052:
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)+
cmp    #16,D4
bge.s HL4051
move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7
moveq  #15,D6
*
HL4050:
bset   D6,D0
bclr   D6,D1
bset   D6,D2
bclr   D6,D7
*
subq   #1,D6
*
dbra D4, HL4059
*
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)
rts
*
HL4051:
move   #$FFFF,D0
clr    D1
move   #$FFFF,D2
clr    D7
sub    #16,D4
bra.s HL4052




* couleur 6

HL406:

move    lgligne,D0
muls    D5,D0
move    D0,A5
add.l   A1,A5

move    D6,D0
ext.L   D0
lsr.L   #4,D0
lsl.l   #3,D0
add.L   D0,A5

* D6 pointeur bit
and     #$F,D6
neg     D6
add     #$F,D6

move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7

HL4069:

tst    D6
bge.s HL4060
*
HL4062:
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)+
cmp    #16,D4
bge.s HL4061
move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7
moveq  #15,D6
*
HL4060:
bclr   D6,D0
bset   D6,D1
bset   D6,D2
bclr   D6,D7
*
subq   #1,D6
*
dbra D4, HL4069
*
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)
rts
*
HL4061:
clr    D0
move   #$FFFF,D1
move   #$FFFF,D2
clr    D7
sub    #16,D4
bra.s HL4062




* couleur 7

HL407:

move    lgligne,D0
muls    D5,D0
move    D0,A5
add.l   A1,A5

move    D6,D0
ext.L   D0
lsr.L   #4,D0
lsl.l   #3,D0
add.L   D0,A5

* D6 pointeur bit
and     #$F,D6
neg     D6
add     #$F,D6

move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7

HL4079:

tst    D6
bge.s HL4070
*
HL4072:
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)+
cmp    #16,D4
bge.s HL4071
move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7
moveq  #15,D6
*
HL4070:
bset   D6,D0
bset   D6,D1
bset   D6,D2
bclr   D6,D7
*
subq   #1,D6
*
dbra D4, HL4079
*
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)
rts
*
HL4071:
move   #$FFFF,D0
move   #$FFFF,D1
move   #$FFFF,D2
clr    D7
sub    #16,D4
bra.s HL4072




* couleur 8

HL408:

move    lgligne,D0
muls    D5,D0
move    D0,A5
add.l   A1,A5

move    D6,D0
ext.L   D0
lsr.L   #4,D0
lsl.l   #3,D0
add.L   D0,A5

* D6 pointeur bit
and     #$F,D6
neg     D6
add     #$F,D6

move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7

HL4089:

tst    D6
bge.s HL4080
*
HL4082:
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)+
cmp    #16,D4
bge.s HL4081
move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7
moveq  #15,D6
*
HL4080:
bclr   D6,D0
bclr   D6,D1
bclr   D6,D2
bset   D6,D7
*
subq   #1,D6
*
dbra D4, HL4089
*
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)
rts
*
HL4081:
clr    D0
clr    D1
clr    D2
move   #$FFFF,D7
sub    #16,D4
bra.s HL4082




* couleur 9

HL409:

move    lgligne,D0
muls    D5,D0
move    D0,A5
add.l   A1,A5

move    D6,D0
ext.L   D0
lsr.L   #4,D0
lsl.l   #3,D0
add.L   D0,A5

* D6 pointeur bit
and     #$F,D6
neg     D6
add     #$F,D6

move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7

HL4099:

tst    D6
bge.s HL4090
*
HL4092:
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)+
cmp    #16,D4
bge.s HL4091
move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7
moveq  #15,D6
*
HL4090:
bset   D6,D0
bclr   D6,D1
bclr   D6,D2
bset   D6,D7
*
subq   #1,D6
*
dbra D4, HL4099
*
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)
rts
*
HL4091:
move   #$FFFF,D0
clr    D1
clr    D2
move   #$FFFF,D7
sub    #16,D4
bra.s HL4092




* couleur 10
*
HL410:

move    lgligne,D0
muls    D5,D0
move    D0,A5
add.l   A1,A5

move    D6,D0
ext.L   D0
lsr.L   #4,D0
lsl.l   #3,D0
add.L   D0,A5

* D6 pointeur bit
and     #$F,D6
neg     D6
add     #$F,D6

move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7

HL4109:

tst    D6
bge.s HL4100
*
HL4102:
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)+
cmp    #16,D4
bge.s HL4101
move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7
moveq  #15,D6
*
HL4100:
bclr   D6,D0
bset   D6,D1
bclr   D6,D2
bset   D6,D7
*
subq   #1,D6
*
dbra D4, HL4109
*
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)
rts
*
HL4101:
clr    D0
move   #$FFFF,D1
clr    D2
move   #$FFFF,D7
sub    #16,D4
bra.s HL4102




* couleur 11

HL411:

move    lgligne,D0
muls    D5,D0
move    D0,A5
add.l   A1,A5

move    D6,D0
ext.L   D0
lsr.L   #4,D0
lsl.l   #3,D0
add.L   D0,A5

* D6 pointeur bit
and     #$F,D6
neg     D6
add     #$F,D6

move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7

HL4119:

tst    D6
bge.s HL4110
*
HL4112:
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)+
cmp    #16,D4
bge.s HL4111
move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7
moveq  #15,D6
*
HL4110:
bset   D6,D0
bset   D6,D1
bclr   D6,D2
bset   D6,D7
*
subq   #1,D6
*
dbra D4, HL4119
*
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)
rts
*
HL4111:
move   #$FFFF,D0
move   #$FFFF,D1
clr    D2
move   #$FFFF,D7
sub    #16,D4
bra.s HL4112




* couleur 12

HL412:

move    lgligne,D0
muls    D5,D0
move    D0,A5
add.l   A1,A5

move    D6,D0
ext.L   D0
lsr.L   #4,D0
lsl.l   #3,D0
add.L   D0,A5

* D6 pointeur bit
and     #$F,D6
neg     D6
add     #$F,D6

move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7

HL4129:

tst    D6
bge.s HL4120
*
HL4122:
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)+
cmp    #16,D4
bge.s HL4121
move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7
moveq  #15,D6
*
HL4120:
bclr   D6,D0
bclr   D6,D1
bset   D6,D2
bset   D6,D7
*
subq   #1,D6
*
dbra D4, HL4129
*
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)
rts
*
HL4121:
clr    D0
clr    D1
move   #$FFFF,D2
move   #$FFFF,D7
sub    #16,D4
bra.s HL4122




* couleur 13

HL413:

move    lgligne,D0
muls    D5,D0
move    D0,A5
add.l   A1,A5

move    D6,D0
ext.L   D0
lsr.L   #4,D0
lsl.l   #3,D0
add.L   D0,A5

* D6 pointeur bit
and     #$F,D6
neg     D6
add     #$F,D6

move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7

HL4139:

tst    D6
bge.s HL4130
*
HL4132:
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)+
cmp    #16,D4
bge.s HL4131
move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7
moveq  #15,D6
*
HL4130:
bset   D6,D0
bclr   D6,D1
bset   D6,D2
bset   D6,D7
*
subq   #1,D6
*
dbra D4, HL4139
*
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)
rts
*
HL4131:
move   #$FFFF,D0
clr    D1
move   #$FFFF,D2
move   #$FFFF,D7
sub    #16,D4
bra.s HL4132




* couleur 14

HL414:

move    lgligne,D0
muls    D5,D0
move    D0,A5
add.l   A1,A5

move    D6,D0
ext.L   D0
lsr.L   #4,D0
lsl.l   #3,D0
add.L   D0,A5

* D6 pointeur bit
and     #$F,D6
neg     D6
add     #$F,D6

move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7

HL4149:

tst    D6
bge.s HL4140
*
HL4142:
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)+
cmp    #16,D4
bge.s HL4141
move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7
moveq  #15,D6
*
HL4140:
bclr   D6,D0
bset   D6,D1
bset   D6,D2
bset   D6,D7
*
subq   #1,D6
*
dbra D4, HL4149
*
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)
rts
*
HL4141:
clr    D0
move   #$FFFF,D1
move   #$FFFF,D2
move   #$FFFF,D7
sub    #16,D4
bra.s HL4142




* couleur 15

HL415:

move    lgligne,D0
muls    D5,D0
move    D0,A5
add.l   A1,A5

move    D6,D0
ext.L   D0
lsr.L   #4,D0
lsl.l   #3,D0
add.L   D0,A5

* D6 pointeur bit
and     #$F,D6
neg     D6
add     #$F,D6

move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7

HL4159:

tst    D6
bge.s HL4150
*
HL4152:
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)+
cmp    #16,D4
bge.s HL4151
move.l  A5,A4
move   (A4)+,D0
move   (A4)+,D1
move   (A4)+,D2
move   (A4),D7
moveq  #15,D6
*
HL4150:
bset   D6,D0
bset   D6,D1
bset   D6,D2
bset   D6,D7
*
subq   #1,D6
*
dbra D4, HL4159
*
move   D0,(A5)+
move   D1,(A5)+
move   D2,(A5)+
move   D7,(A5)
rts
*
HL4151:
move   #$FFFF,D0
move   #$FFFF,D1
move   #$FFFF,D2
move   #$FFFF,D7
sub    #16,D4
bra.s HL4152




*****************************
* affichage d'un point
*****************************

* BisDot

BisDot:
**BisDot:

*x=8
*y=10
*col=12

link A6,#0
movem.l D3-D6/A4-A5,-(sp)

* A1 adresse de la video
move.l  videobis,A1

*x=D6
*y=D5
*col=R3

bra.s DOT0



* Dot

point:

**Dot:

*x=8
*y=10
*col=12

link A6,#0
movem.l D3-D6/A4-A5,-(sp)

* A1 adresse de la video
move.l  video,A1


*x=D6
*y=D5
*col=R3


DOT0:

* x = D6
move    8(a6),D6
cmp     xsmin,D6
blt.s DOT9
cmp    xsmax,D6
bgt.s DOT9
 
* y = D5
move    10(a6),D5
cmp     ysmin,D5
blt.s DOT9
cmp     ysmax,D5
bgt.s DOT9

* col = D3
move    12(a6),D3


bsr.s DOT

DOT9:
movem.l (sp)+,D3-D6/A4-A5
unlk A6
rts



DOT:
*
* D6 = x
* D5 = y
* D3 = color
* A1 = rv
*

* A5 = adresse
move.l A1,A5
*
tst     moniteur
beq DOT4
*
DOT1:
*
move   lgligne,D0
muls   D5,D0
add.l  D0,D0
add.l  D0,A5
*
* x = x*2
move   D6,D0
add    D0,D0
move   D0,D1
*
* D1 = nbit
* D2 = nbit - 1
and    #$F,D1
neg    D1
add    #$F,D1
move   D1,D2
subq   #1,D2
*
ext.l  D0
lsr.l  #4,D0
add.l  D0,D0
add.l  D0,A5
move   lgligne,A4
add.l  A5,A4
*
*
move   (A5),D0
*
bclr   D1,D0
btst   #0,D3
beq.s DO11
bset   D1,D0
*
DO11:
bclr   D2,D0
btst   #1,D3
beq.s DO12
bset   D2,D0
*
DO12:
move   D0,(A5)
*
move   (A4),D0
*
bclr   D1,D0
btst   #2,D3
beq.s DO13
bset   D1,D0
*
DO13:
bclr   D2,D0
btst   #3,D3
beq.s DO14
bset   D2,D0
*
DO14:
move   D0,(A4)
*
rts


DOT2:
rts


DOT4:
*
move   lgligne,D0
muls   D5,D0
add.l  D0,A5
*
move   D6,D0
move   D6,D1
*
ext.l  D0
lsr.l  #4,D0
lsl.l  #3,D0
add.l  D0,A5
*
* D1 = nbit
and    #$F,D1
neg    D1
add    #$F,D1
*
move   (A5),D0
*
bclr   D1,D0
btst   #0,D3
beq DO41
bset   D1,D0
DO41:
move   D0,(A5)+
move   (A5),D0
*
bclr   D1,D0
btst   #1,D3
beq DO42
bset   D1,D0
DO42:
move   D0,(A5)+
move   (A5),D0
*
bclr   D1,D0
btst   #2,D3
beq DO43
bset   D1,D0
DO43:
move   D0,(A5)+
move   (A5),D0
*
bclr   D1,D0
btst   #3,D3
beq DO44
bset   D1,D0
DO44:
move   D0,(A5)
*
rts


*********************
*  tables d'acc‚s
*********************


* table des couleurs pour HLINE

HLMONO:

dc.l HL100
dc.l HL101
dc.l HL102
dc.l HL103
dc.l HL104
dc.l HL105
dc.l HL106
dc.l HL107
dc.l HL108
dc.l HL109
dc.l HL110
dc.l HL111
dc.l HL112
dc.l HL113
dc.l HL114
dc.l HL115

HL16COL:

dc.l HL400
dc.l HL401
dc.l HL402
dc.l HL403
dc.l HL404
dc.l HL405
dc.l HL406
dc.l HL407
dc.l HL408
dc.l HL409
dc.l HL410
dc.l HL411
dc.l HL412
dc.l HL413
dc.l HL414
dc.l HL415




* _H_Line

Line:

**H_Line:

*xp1    =8
*xp2    =10
*yp     =12
*color  =14

link A6,#0
movem.l D3-D7/A4-A5,-(sp)

* A1 adresse de l'‚cran video
move.l  video,A1


*xg=D6
move 8(A6),D6
*yg=D5
move 12(A6),D5
*xd=D4
move 10(A6),D4
*col=D3
move 14(A6),D3

*lp1=A5
*lp2=A4


cmp ysmin,D5
blt.s HL23

cmp ysmax,D5
bgt.s HL23

and #15,D3
asl #2,d3 
move D3,A2

tst moniteur
beq.s HL21

add.l #HLMONO,a2
bra.s HL15

HL21:
add.l #HL16COL,a2

HL15:

* A2 routine de la couleur choisie
move.l  (a2),a2

bsr HLINE

HL23:
movem.l (sp)+,D3-D7/A4-A5
unlk A6
rts



***************************
*   extension … anima.s
***************************


div32p32:

*        ; d0 dividante sur 32 bits
*        ; d1 diviseur sur 32 bits
*        ; calcul de D0/D1 sur 32 bits sign‚s
*        ; r‚sultat dans D0

        tst.l   d0
        blt cdiv

        tst.l   d1
        blt.s bdiv


adiv:
        cmp.l   d0,d1
        bgt.s anul
        bne.s adiv1

        moveq   #1,d0
        rts
anul:
        clr.l   d0
        rts
adiv1:
        cmp.l   #$10000,d0
        bge.s adiv2

        move.l  d0,d2
        divu    d1,d2
        move.w  d2,d0
        rts
adiv2:
        move.l  d3,-(sp)
        clr.l   d3
        moveq   #1,d2
adiv20:
        cmp.l d1,d0
        bcs.s adiv10
        add.l   d1,d1
        add.l   d2,d2
        bra.s adiv20
adiv10:
        tst.l   d2
        beq.s adiv30
        cmp.l   d1,d0
        bcs.s adiv40
        or.l    d2,d3
        sub.l   d1,d0
adiv40:
        lsr.l   #1,d2
        lsr.l   #1,d1
        bra.s adiv10
adiv30:
        move.l  d3,d0
        move.l  (sp)+,d3
        rts


bdiv:
        neg.l   d1
        cmp.l   d0,d1
        bgt.s bnul
        bne.s bdiv1

        move.l  #-1,d0
        rts 
bnul:
        clr.l   d0
        rts
bdiv1:
        cmp.l   #$10000,d0
        bge.s bdiv2

        move.l  d0,d2
        divu    d1,d2
        move.w  d2,d0
        neg.l   d0
        rts
bdiv2:
        move.l  d3,-(sp)
        clr.l   d3
        moveq   #1,d2
bdiv20:
        cmp.l d1,d0
        bcs.s bdiv10
        add.l   d1,d1
        add.l   d2,d2
        bra.s bdiv20
bdiv10:
        tst.l   d2
        beq.s bdiv30
        cmp.l   d1,d0
        bcs.s bdiv40
        or.l    d2,d3
        sub.l   d1,d0
bdiv40:
        lsr.l   #1,d2
        lsr.l   #1,d1
        bra.s bdiv10
bdiv30:
        move.l  d3,d0
        move.l  (sp)+,d3
        neg.l d0
        rts


cdiv:
        tst.l   D1
        blt.s ddiv

        neg.l   D0
        cmp.l   d0,d1
        bgt.s cnul
        bne.s cdiv1

        move.l  #-1,d0
        rts 
cnul:
        clr.l   d0
        rts
cdiv1:
        cmp.l   #$10000,d0
        bge.s cdiv2

        move.l  d0,d2
        divu    d1,d2
        move.w  d2,d0
        neg.l   d0
        rts
cdiv2:
        move.l  d3,-(sp)
        clr.l   d3
        moveq   #1,d2
cdiv20:
        cmp.l d1,d0
        bcs.s cdiv10
        add.l   d1,d1
        add.l   d2,d2
        bra.s cdiv20
cdiv10:
        tst.l   d2
        beq.s cdiv30
        cmp.l   d1,d0
        bcs.s cdiv40
        or.l    d2,d3
        sub.l   d1,d0
cdiv40:
        lsr.l   #1,d2
        lsr.l   #1,d1
        bra.s cdiv10
cdiv30:
        move.l  d3,d0
        move.l  (sp)+,d3
        neg.l D0
        rts


ddiv:
        neg.l   D0
        neg.l   D1
        cmp.l   d0,d1
        bgt.s dnul
        bne.s ddiv1

        moveq   #1,d0
        rts
dnul:
        clr.l   d0
        rts
ddiv1:
        cmp.l   #$10000,d0
        bge.s ddiv2

        move.l  d0,d2
        divu    d1,d2
        move.w  d2,d0
        rts
ddiv2:
        move.l  d3,-(sp)
        clr.l   d3
        moveq   #1,d2
ddiv20:
        cmp.l d1,d0
        bcs.s ddiv10
        add.l   d1,d1
        add.l   d2,d2
        bra.s ddiv20
ddiv10:
        tst.l   d2
        beq.s ddiv30
        cmp.l   d1,d0
        bcs.s ddiv40
        or.l    d2,d3
        sub.l   d1,d0
ddiv40:
        lsr.l   #1,d2
        lsr.l   #1,d1
        bra.s ddiv10
ddiv30:
        move.l  d3,d0
        move.l  (sp)+,d3
        rts



mul16x32:

*        ; d0 op‚rande 16 bits
*        ; d1 op‚rande sur 32 bits
*        ; multiplication sur 32 bits sign‚s
*        ; r‚sultat dans D0

        tst.w d0
        blt.s mul1

        tst.l d1
        blt.s mul2
mul0:
        move.w d0,d2
        mulu d1,d2
        swap d1
        mulu d1,d0
        swap d0
        add.l d2,d0
        rts
mul2:
        neg.l d1
        move.w d0,d2
        mulu d1,d2
        swap d1
        mulu d1,d0
        swap d0
        add.l d2,d0
        neg.l d0
        rts
mul1:
        tst.l D1
        blt.s mul3

        neg.w D0
        move.w d0,d2
        mulu d1,d2
        swap d1
        mulu d1,d0
        swap d0
        add.l d2,d0
        neg.l D0
        rts
mul3:
        neg.w D0
        neg.l D1
        move.w d0,d2
        mulu d1,d2
        swap d1
        mulu d1,d0
        swap d0
        add.l d2,d0
        rts

        dc.l 0
FinPrg: dc.l 0

