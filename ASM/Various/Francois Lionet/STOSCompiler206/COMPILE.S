
	OutPut	D:\Compiler\Comp_208.Prg

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   |COMPILATEUR STOS BASIC 29/12/1990|       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------

*************************************************************************
        bra SetPar              ;JUMP set params
        bra DStos               ;JUMP compile
	bra Grab		;GRABber de programmes
	bra Version		;Get version number
*************************************************************************

*************************************************************************

CDta:   ds 48
SauveP: dc.l 0

;-------------------------------------> Variables compilateur

DebWork:        dc.l 0          ;Zone de travail
TopWork:        dc.l 0
TBuffers:	dc.l 0

Source:         dc.l 0          ;Adresse du code source
LSource:        dc.l 0
LFile:          dc.l 0

StObjet:        dc.l 0          ;Adresse du debut objet
Objet:          dc.l 0          ;Adresse du debut du PROGRAMME

BReloc:         dc.l 0          ;Table de relocation
OldRel:         dc.l 0

HiVar:          dc.l 0          ;Table des variables
LoVar:          dc.l 0
BotVar:         dc.l 0
AdADefn:        dc.l 0
ADefn:          dc.l 0

RoutIn:         dc.l 0          ;Routines a charger
BufCalc:        dc.l 0          ;Pile des expressions

LongCode:       dc.l 0          ;Longueur du code
LongRel:        dc.l 0          ;Longueur table de relocation
LongChai:       dc.l 0          ;Longueur des chaines
LongProg:       dc.l 0          ;Longueur des trois
LongBank:       dc.l 0          ;Longueur des banques
LongOb:         dc.l 0          ;Longueur totale de l'objet
LongVar:        dc.l 0          ;Longueur des variables RUN-TIME

LiToAd:         dc.l 0          ;Table numeros de ligne ---> adresses pgm
ALiToAd:        dc.l 0
NbLines:        dc.w 0
AdLine:         dc.l 0  
CurLine:	dc.w 0
NewLine:        dc.l 0
Parenth:        dc.w 0
FlagStos:       dc.w 0
CptInst:	dc.w 0

AdChai:         dc.l 0
BAdChai:        dc.l 0  
BAdString:      dc.l 0
AdString:       dc.l 0
BufVar:         ds.b 64
Passe:          dc.w 0

; Tests cycliques
Tests:          dc.w 1

; Pointeurs boucles
coldf:          dc.l 0          ;Oldfind
cnboucle:       dc.w 0          
ctstnbcle:      dc.w 0
cposbcle:       dc.l 0
ccptnext:       dc.w 0

; Pile des boucles (28 octets / boucle)
cmaxbcle:       ds 28*10
cbufbcle:       equ *

; Pile des IF THEN ELSE
Pif:            dc.l 0
Tif:            dc.l 0

; Datas
FstData:        dc.l 0
OlData:         dc.l 0

; Flag GEM RUN
FlagGem:        dc.w 0          ;0= STOS-RUN / 1= GEM-RUN

; Flag MENUS
Menucall:       dc.l 0
Flagmenu:       dc.w 0

; Librairies
AdCata:         dc.l 0
OLibr:          dc.l 0

; Interface stos / Chargements / Extensions
nomin:          dc.l 0
nomout:         dc.l 0
prgnb:          dc.w 0
VTable:         dc.l 0
Advector:	dc.l 0
ADtprg:         dc.l 0
ADtbnk:         dc.l 0
AdExtAd:        dc.l 0
AdExtAp:        dc.l 0
AdExtPa:        dc.l 0
PAdExtAd:       dc.l 0
PAdExtAp:       dc.l 0
BufLoad:        dc.l 0
MaxLoad:        dc.l 0
ExtFlag:        dc.l 0
FloFlag:        dc.w 0
ValFlo:         dc.w 0
NomCr0:         dc.l 0
NomCr1:         dc.l 0
NomCr2:         dc.l 0
NomMou:         dc.l 0
TBufSp:         dc.l 2500
MaxCop:         dc.l 32000
BufOb:          dc.l 0
DebBob:         dc.l 0
FinBob:         dc.l 0
TopOb:          dc.l 0
MaxBob:         dc.l 0
BordBob:        dc.l 0
BufSou:         dc.l 0
TopSou:         dc.l 0
MaxBso:         dc.l 0
BordBso:        dc.l 0
DebBso:         dc.l 0
FinBso:         dc.l 0

; Affichage compilation
LigneA:		dc.l 0
resol:		dc.w 0
XLine:		dc.w 0
YLine:		dc.w 0
LBar:		dc.w 0
HBar:		dc.w 0
BasBar:		dc.w 0
Bar1:		dc.w 0
Bar2:		dc.w 0
Bar3:		dc.w 0
Bar4:		dc.w 0
Bar5:		dc.w 0
LongSou:	dc.l 0
CptRout:	dc.l 0
NbRout:		dc.l 0

; Filtres / Noms des fichiers
nomsrc:         dc.b "ESSAI.BAS",0
nomobj:         dc.b "ESSAIRUN.PRG",0
NomLib:         dc.b "COMPILER\BASIC???.LIB",0
NomSpr:         dc.b "COMPILER\SPRIT???.LIB",0
NomWin:         dc.b "COMPILER\WINDO???.LIB",0
NomMus:         dc.b "COMPILER\MUSIC???.LIB",0
NomFlo:         dc.b "COMPILER\FLOAT???.LIB",0
NCr0:           dc.b "COMPILER\8X8.CR0",0
NCr1:           dc.b "COMPILER\8X8.CR1",0
NCr2:           dc.b "COMPILER\8X16.CR2",0
NMou:           dc.b "COMPILER\MOUSE.SPR",0
NomExt:         dc.b "COMPILER\*.EC?",0
NomDisk:        dc.b "COMPILER\"
BufDisk:        ds.b 16

        even

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | TABLE DES JUMPS COMPILATION     |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
DebOp:          equ $EA
DebFonc:        equ $B8

jumps:  dc.l csynt,csynt,CNext,CWeND,CUnti,CDim,pok,dok
        dc.l lok,CRead,CRem,CRetu,CPop,CResn,CResu,Coner 	;$80-$8f
        dc.l CScc,CSwap,CPlot,CPie,CDro,CPoli,CPoma,csynt
        dc.l CGoto,CGosu,csynt,CElse,CRest,CFor,CWhil,CRepe ;$90-$9f
        dc.l CEten,CPrnt,Cif,CUpd,CSpr,CFrz,COff,Con
        dc.l CExti,CLoc,CPap,CPen,CHome,csynt,csynt,csynt ;$A0-$Af
        dc.l CCUp,CDwn,CLft,CRit,CCls,CInc,CDec,CScsw
; Fonctions/instructions
        dc.l csynt,CPsg,csynt,CDReg,CAReg,csynt,CDriD,CDyr
        dc.l csynt,csynt,CCol,csynt,csynt,csynt,CDri,CStmr
        dc.l CLog,csynt,csynt,csynt,csynt,csynt,csynt,csynt
        dc.l csynt,CImid,CIrgh,CIlft,csynt,csynt,csynt,csynt
        dc.l csynt,csynt,csynt,csynt,csynt,csynt,CXm,CYm  
        dc.l csynt,CPhy,CBak,csynt,CPof,Cmod,CSTim,CSDat
        dc.l CSc,CDefo,csynt,csynt,csynt,csynt,csynt,csynt
        dc.l csynt,csynt,csynt,csynt,csynt,csynt,csynt,csynt
        dc.l csynt,csynt,CLet,csynt,csynt,csynt,csynt,csynt

; ADRESSE DES FONCTIONS
fnjumps:dc.l FEten,CFpsg,CFTSc,CFDrg,CFArg,CPoin,CFDrD,CFDyr
        dc.l CExtf,CAbs,CFCol,CFKey,CSin,CCos,CFDr,CTimr
        dc.l CFLog,CFn,CNot,CRnd,CVal,CAsc,CChr,CInky
        dc.l CScan,CMid,CRigh,CLeft,CLeng,CStar,CLen,CPi
        dc.l pik,dik,lik,CZo,CXSp,CYSp,CFXm,CFYm
        dc.l CFKm,CFPhy,CFBak,CLog1,CFPof,CFmod,CTime,CDate
        dc.l CFSc,CFDfo
; ... operateurs
        dc.l csynt,csynt,csynt,csynt,csynt,csynt             ;$E0-$E9
        dc.l csynt,csynt,csynt,csynt,csynt,csynt,csynt,csynt
        dc.l csynt,csynt
; ... variable
        dc.l Var
; ... constantes
        dc.l CEnt,CChai,CEnt,CEnt,CFlo                    ;$F0-$Ff

; ADRESSE DES OPERATEURS
opjumps:dc.l csynt,CXor,COr,CAnd                          ;$EA-$Ef
        dc.l CDiff,CInfe,CSupe,CEgal,CInf,CSup
        dc.l CPlus,CMoin,CModu,CMult,CDivi,CPuis
        dc.l csynt,csynt,csynt,csynt,csynt                   ;$F0-$Ff

; ADRESSE DES INSTRUCTIONS ETENDUES
ExtJump:dc.l CDIrW,CFad,CBcop,CSqa
        dc.l CPrev,CTran,CShif,CWtky 
        dc.l CDir,CLDir,CBlo,CBsa,CQWdo,csynt,CChc,CUnd
        dc.l CMenu,CMeno,CTit,CBor,CHard,CWind,CRedr,CCen
        dc.l CTemp,CVol,CEnv,CExpl,CShoo,CPing,CNaut,CNoi
        dc.l CVoi,CMus,CBox,CRBox,CBar,CRBar,CApp,CBclr
        dc.l CBSet,CRol,CRor,CCur,CClw,CBchg,CCall,CTrap
        dc.l csynt,CRun,CClky,CLInp,CInpu,csynt,CData,CEnd 
        dc.l CEras,CRese,csynt,csynt,csynt,csynt,CCopy,CDef
        dc.l CHid,CSho,CChgm,CLimm,CMvx,CMvy,CFix,CBGra 
        dc.l csynt,CFill,csynt,CKys,CMve,CAni,CUfrz,CSZo
        dc.l CRZo,CLsp,Cpri,CRedu,CPSp,CGSp,CLoad,CSave
        dc.l CPal,CSync,CErr,CBrek,CLLet,CKey,COpin,COpou 
        dc.l COpen,CClo,CFiel,csynt,CPuky,CGPal,CKill,CRena
        dc.l CRmD,CMkD,CStop,CWVbl,CSort,CGet,CFlas,csynt 
        dc.l CLprt,CAuto,CSLi,CGrw,CSMa,CSpa,csynt
        dc.l CSPt
        dc.l CClip,CArc,CPogo,CCir,CEarc,CEpie,CEll,CWr
        dc.l CPain,CInk,CWait,CClic,CPut,CZoo,CSCur,CScd
        dc.l CScu,CScro,CInv,CSha,CWdop,CWdo,CWdm,CWdl

; ADRESSE DES FONCTIONS ETENDUES
ExtFonc:dc.l CSinh,CCosh,CTanh,CAsin,CAcos,CAtan,CUpp,CLow 
        dc.l CCurr,CMach,CErrn,CErrl,CVarp,CFinp,CFlip,CFree
        dc.l CStr,CHex,CBin,CStri,CSpc,CInst,CMax,CMin 
        dc.l CLof,CEof,CDirF,CDirN,CBtst,CColi,CAccn,CLang
        dc.l csynt,CHunt,CVrai,CFaux,CCx,CCy,CJup,CJLef
        dc.l CJRig,CJDow,CFire,CJoy,CMvo,CIc,CTab,CExp 
        dc.l CChl,CChoi,CItem,CWdn,CXt,CYt,CXg,CYg 
        dc.l csynt,CSqr,CDx,CDy,CLogn,CTan,CDMap,CFsel
        dc.l CDFri,CSgn,CPort,CPVoi,CInt,CDtct,CDeg,CRad 

;-----------------------------> Formats de parametres
ParEnt: dc.b en,1
        dc.b en,",",en,1
        dc.b en,",",en,",",en,1
        dc.b en,",",en,",",en,",",en,1
        dc.b en,",",en,",",en,",",en,",",en,1
        dc.b en,",",en,",",en,",",en,",",en,",",en,1
        dc.b en,",",en,",",en,",",en,",",en,",",en,",",en,1
        dc.b 1

;----------------------------> MESSAGES D'ERREUR 
MError: dc.b 13,10,"Erreur number ",0
merr:   dc.b "in line ",0

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | INSTRUCTIONS RECOPIEES          |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
        even
CJsr:           jsr $fffffe
CJmp:           jmp $fffffe
Cbra:           bra Cbra
CLeaa0:         lea $ffffff,a0
CLeaa2:         lea $ffffff,a2
CMvima6:        move.l #$ffffffff,-(a6)
Cmvqd0:         moveq #0,d0
Cmvqd1:         moveq #0,d1 
Cmvqd2:         moveq #0,d2
Cmvd1:          move.w #$ffff,d1
Crts:           rts
En:             equ $00
Ch:             equ $80
Fl:             equ $40
to:             equ $80

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | PROGRAMME                       |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
        even


*********************************************************************
*	Ramene la version
***************************
Version	move.w #$0208,d0
	rts

*********************************************************************
*	GRABBER DE PROGRAMME POUR LE STOS BASIC
*	AREG(0)= debut PRG
*	AREG(1)= fin PRG
*	AREG(2)= compad
*	AREG(3)= back
*	DREG(0)= programme ou grabber
**************************************

******* Poke et appelle le grabber
Grab:	lea Grabber(pc),a4
	lea GrabEnd(pc),a5
	move.l a3,-(sp)
Grb:	move.l (a4)+,(a3)+
	cmp.l a5,a4
	bcs.s Grb
	rts

Grabber:move.l a2,a6		;A6= compad
	move.l $4c(a6),a5	;A5= tables
	move.l a0,a2		;A2= adresse du .PRG
	move.l a1,d3
	sub.l a2,d3		;D3= longueur du .PRG
	move.w d0,d7		;# du programme ou grabber
	move.w d0,program(a5)
	clr.w AccFlg(a5)	;Plus d'accessoire!

	move.l adatabank(a5),a0
	move.l (a0)+,d0
	moveq #14,d1
Grb1:	clr.l (a0)+		;Efface les banques!
	dbra d1,Grb1
	move.l adataprg(a5),a0
	move.l (a0),a3		;Adresse de recopie
	move.l d0,4(a0)		;Longueur compil= longueur basic.
	add.l d0,a3		;Pointe la fin du compilateur
	move.l d3,-(sp)	
	move.l $28(a6),a0
	jsr (a0)		;Transmem
	lsl.w #3,d7
	lea dataprg(a5),a4
	add.w d7,a4
	move.l 8(a4),a2		;Debut du prg au dessus
	move.l (sp),d3
; Fait tourner les buffers
Tour0:	move.l #32000,d0
	cmp.l d3,d0
	bcs.s Tour1
	move.l d3,d0
Tour1:	sub.l d0,d3
	move.l adback(a5),a1	;Recopie dans le buffer
	add.l #32768,a1
	move.l a3,a0
	lsr.w #1,d0
	subq.w #1,d0
	move.w d0,d1
Tour2:	move.w -(a0),-(a1)
	dbra d0,Tour2 
	move.l a3,a1		;Monte le programme
Tour3:	move.w -(a0),-(a1)
	cmp.l a2,a0
	bhi.s Tour3 	
	move.l adback(a5),a0	;Remet le bout d'ecran
	add.l #32768,a0
Tour4:	move.w -(a0),-(a1)
	dbra d1,Tour4
	tst.l d3
	bne.s Tour0
; Remonte le gros bout de basic
	move.l (sp)+,d3
	move.l a2,-(sp)
	add.l d3,a2
	move.l a3,d3
	sub.l a2,d3
	move.l adataprg(a5),a0
	move.l 8(a0),a3
	sub.l d3,a3
	move.l $28(a6),a0
	jsr (a0)
; Change les adresses des programmes
	move.l adataprg(a5),a0
Tour5:	sub.l 4(a0),a3
	move.l a3,(a0)
	subq.l #8,a0
	cmp.l a4,a0
	bhi.s Tour5
; Descend le .PRG
	lsl.w #3,d7
	lea Databank(a5),a0
	add.w d7,a0
	move.l a0,adatabank(a5)
	move.l a4,adataprg(a5)
	move.l (a4),a3
	move.l (sp)+,a2
	lea 10(a2),a2			;Saute lionpoulos
	move.l (a2)+,d3
	move.l d3,4(a4)			;Longueur totale prg
	moveq #15,d0
Des1:	move.l (a2)+,(a0)+		;Copie databank
	dbra d0,Des1
	move.l $28(a6),a0		;Descend le programme
	jsr (a0)
	move.l $74(a6),a0		;Dechaine le programme
	jsr (a0)
	move.l $40(a6),a0		;Prend DIR JUMPS
	move.l 14*4(a0),a0		;WARM
	jmp (a0)
GrabEnd:

*************************************************************************
*       Depart SEKA
*********************** 
w:      clr.w FlagStos
	clr.l VTable
	dc.w $a000
	move.l a0,LigneA
        move.l #FinPrg,a0
        move.l #$F0000,a1
        move.l #$F0000,a2
        move.l #$F8000,a3
        move.l #nomsrc,nomin
        move.l #nomobj,nomout
        clr.l VTable
        clr.w prgnb
        move.l #NCr0,NomCr0
        move.l #NCr1,NomCr1
        move.l #NCr2,NomCr2
        move.l #NMou,NomMou
        move.w #1,FlagGem
	move.w #0,XLine
	move.w #0,YLine
	move.w #64,LBar
	move.w #100,HBar
        lea $f0000,sp
        bra.w Ds

*************************************************************************
*       FIXE LES PARAMETRES DE COMPILATION
*       A0= table vecteurs
*       A1= Sprites souris
*       A2= CR0
*       A3= CR1
*       A4= CR2
*	A5= parametres DEFAULT
*       D0= pgm#
*       D1= FlagGem
*	D2= XBarre
*	D3= YBarre
*	D4= Taille barre X
*	D5= Taille barre Y
*	D6= TMaxCopie
*	D7= BufSprites
***********************
SetPar: move.l a0,VTable
        move.l a1,NomMou
        move.l a2,NomCr0
        move.l a3,NomCr1
        move.l a4,NomCr2
        subq.w #1,d0
        move.w d0,PrgNb
        move.w d1,FlagGem
	move.w d2,XLine
	move.w d3,YLine
	move.w d4,LBar
	move.w d5,HBar
	move.l d6,MaxCop
	move.l d7,TBufSp
	moveq #44-1,d0
	lea OAmb(pc),a0
SetP:	move.b (a5)+,(a0)+
	dbra d0,SetP
; Adresses ligne A / control-c
	move.l VTable(pc),d0
	bmi.s Sp1
	move.l d0,a0
	move.l $4c(a0),a0
	bra.s Sp2
Sp1:	bclr #31,d0
	move.l d0,a0
Sp2:	move.l a0,AdVector
	move.l laad(a0),LigneA
	rts

*************************************************************************
*       COMPILATION STOS
*       a0= Debut du buffer WORK
*       a1= Fin du buffer WORK
*       a2= bas buffer BACK
*       a3= haut buffer BACK
*       a4= nom entree / 0 sinon
*       a5= nom sortie / 0 sinon
*	d0= compiler TEST 0 / 1 / 2
*	d1= zero float (1)
*	d2= zero float (2)
**********************************************
DStos:  move.w #1,FlagStos
	move.w d0,Tests
	move.l d1,OZero
	move.l d2,OZero+4
        move.l a4,NomIn
        move.l a5,NomOut
    
*************************************************************************
*       Fixe les buffers fixes
*************************************************************************
Ds:     move.l sp,SauveP

        move.l a0,DebWork
        move.l a1,TopWork

; RAZ buffer BACK
        move.l a2,a0
RazB:   clr.l (a0)+
        cmp.l a3,a0
        bcs.s RazB
; Table des variables / descendantes
        move.l a3,HiVar
; Buffer de chargement librairie
        move.l a2,BufLoad
        move.l #$2000,MaxLoad
        add.l MaxLoad(pc),a2
; Buffer de chargement SOURCE
        tst.l NomIn
        beq.s Rab1
        move.l a2,BufSou
        move.l #$1000,MaxBso
        add.l MaxBso(pc),a2
        move.l #256,BordBso
	move.l a2,ADtbnk
	lea 17*4(a2),a2
; Buffer de sauvegarde OBJET
Rab1:   tst.l NomOut
        beq.s Rab2
        move.l a2,BufOb
        move.l #$1000,MaxBob
        add.l MaxBob(pc),a2
        move.l #512,BordBob
Rab2:
; Table des gestions fichiers
        move.l a2,Datafyche
        lea Nfyche*TFyche(a2),a2
; Table des IFTHENELSE longueur FIXE
        move.l a2,Tif
        add.l #8*32,a2
; Buffer de calcul, longueur FIXE, descendant
        add.l #4*100,a2
        move.l a2,BufCalc
; Table des routines a copier: RoutIn, longueur FIXE
        move.l a2,RoutIn        
        add.l #(RoutMx+1)*4,a2    ;Nombre de routines
        move.l a2,a6

*************************************************************************
*       Charge le catalogue de la librairie
*************************************************************************
        bsr RazDisk
        moveq #0,d7                     ;Librairie = 0
        lea nomlib(pc),a0
        bsr SFirst
        bne DiskErr
        bsr Open
        moveq #$1c,d0                   ;Saute l'entete
        bsr LSeek
        move.l a6,a0
        moveq #4,d0
        bsr Load
        move.l (a6),d0
        move.l d0,OLibr
        subq.l #4,d0
        move.l a6,a0
        move.l a0,AdCata
        bsr Load
        move.l a0,a6
        
*************************************************************************
*       Charge le catalogue des extensions
*************************************************************************
        move.l a6,AdExtAd            ;Adresse table adresse CATALOGUE
        move.l a6,a5
        lea 26*4(a6),a6
        move.l a6,AdExtPa               ;Adresse table EXTENSIONS PARAMS
        move.l a6,a4
        lea 26*4(a6),a6
        move.l a6,AdExtAp            ;Adresse table EXTENSION APPELLEE
        move.l a6,a3
        lea 26*4(a6),a6
        
        lea NomExt(pc),a0
        bsr SFirst
        bne.s LdE3
LdE1:   lea NomDisk(pc),a0
LdE2:   cmp.b #".",(a0)+
        bne.s LdE2
        clr d6
        move.b 2(a0),d6
        sub.w #"A",d6
        move.w d6,d7
        addq.w #1,d7
        lsl.w #2,d6
        bsr Open
        moveq #$1c,d0                   ;Saute l'entete
        bsr LSeek 
        moveq #12,d0
        move.l a6,a0
        move.l a0,0(a5,d6.w)            ;Adresse du CATALOGUE
        bsr load
        move.l a6,a1
        add.l (a6),a1
        move.l a1,0(a4,d6.w)            ;Adresse PARAMS
        move.l 4(a6),d0                 ;Charge catalogue/params
        sub.l #12,d0
        bsr load
        move.l a0,a6
        move.l a6,0(a3,d6.w)            ;Adresse de la table appels
        move.w (a1),d5                  ;Nb de routines
        lsl.w #2,d5                     ;Reserve la JUSTE place pour 
        addq.w #8,d5                    ;les appels!
        add.w d5,a6
        bsr SNext
        beq.s LdE1
LdE3:   

*************************************************************************
*       Buffer des DEFFN / variable / montant
*************************************************************************
        move.l a6,AdADefn

*************************************************************************
*       SOURCE
*************************************************************************
        tst.l nomin
        bne.s LdSou
; Programme en memoire
        move.l VTable,a0
        move.l $4c(a0),a5
        move.w prgnb,d0
        lea dataprg(a5),a0
        lea databank(a5),a1
        lsl.w #3,d0
        lea 0(a0,d0.w),a0               ;Pointe DATAPRG
        lsl.w #3,d0
        lea 0(a1,d0.w),a1               ;Pointe DATABANK
        move.l a0,ADtprg
        move.l a1,ADtbnk
        move.l (a0),Source              ;Adresse du source!
	move.l (a1),LongSou 		;Longueur du source
        bra FLdSou

;-----> Ouvre le programme .BAS
LdSou:  moveq #30,d7
        move.l NomIn,a0
        bsr SFirst
        bne DiskErr
        move.l NomIn,a0
        bsr Open2
        move.l d0,TopSou
; Charge le debut
	clr.l Source
        clr.l DebBso
        move.l MaxBso(pc),FinBso
        bsr LoadBso
        move.l BufSou(pc),a0
        lea HeadStos(pc),a1
        moveq #10-1,d0
OpSo:   cmpm.b (a0)+,(a1)+
        bne DiskErr
        dbra d0,OpSo
; Copie ADATABANK
 	move.l BufSou(pc),a0
	lea 10+4(a0),a0
	move.l ADtbnk(pc),a1
	move.l (a0),d0
	add.l #17*4+10,d0
	move.l d0,LongSou
	moveq #15,d0
Opso1:	move.l (a0)+,(a1)+
	dbra d0,Opso1
FLdSou:

*************************************************************************
*       COMPILATION
*************************************************************************

;-----> Donnees affichage
	move.w XLine(pc),d0
	move.w d0,BasBar
	move.w LBar(pc),d1
	add.w d1,d0
	move.w d0,Bar1	
	add.w d1,d0
	move.w d0,Bar2
	add.w d1,d0
	move.w d0,Bar3
	add.w d1,d0
	move.w d0,Bar4
	add.w d1,d0
	move.w d0,Bar5
	move.w #4,-(sp)
	trap #14
	lea 2(sp),sp
	move.w d0,Resol

;-----> Passe 0: Test des erreurs / Calcul de la longueur
        clr.w Passe
        bsr Passe0
        bne COut
	move.w Bar1(pc),d0
	move.w d0,BasBar
	bsr AffBar 

;-----> Ouvre le fichier OBJET si sur disque
        tst.l NomOut
        beq.s PaDis
        moveq #31,d7
        move.l NomOut(pc),a0
        bsr Create2
        move.l StObjet(pc),TopOb
        clr.l DebBob
        move.l MaxBob(pc),FinBob
PaDis:

;-----> Passe 1: 
        move.w #1,Passe
        bsr Passe1
	move.w Bar4(pc),d0
	move.w d0,BasBar
	bsr AffBar

;-----> Passe 2
        move.w #2,Passe
        bsr Passe2
	move.w Bar5(pc),d0
	bsr AffBar

;-----> Rajoute les headers
        move.l StObjet(pc),a5
        tst.w FlagGem
        bne.s Head1
; Header STOS
        lea HeadStos(pc),a0
        lea 10(a0),a1
        bra.s Head2
; Header GEM
Head1:  lea HeadTos(pc),a0
        lea $1c+2(a0),a1
Head2:  bsr CodeF

;-----> Si disque, sauve le dernier buffer
        tst.w NomOut
        beq.s Head3
        bsr SaveBob
Head3:

;-----> Ferme tous les fichiers
        bsr Close

;-----> FINI: 
;	si memoire : A0= debut / A1= fin de l'objet 
;	si disque  : a0= longueur OBJET 
;	a2= longueur buffers
	tst.w NomOut
	beq.s Head4
; Sur disque : taille de l'objet
	moveq #31,d7
	bsr GetFich
	move.l Longfyche(a3),a0
	bra.s Head5
; En memoire---> ramene debut / fin
Head4:  moveq #0,d0
        move.l StObjet(pc),a0
        move.l Objet(pc),a1
        add.l LongOb(pc),a1
	tst.w FlagGem
	beq.s Head5
	addq.l #8,a1
; Taille des buffers
Head5:  move.l TBuffers(pc),a2		;Taille buffers utilises
	move.l SauveP,sp
; Nombre d'instructions en D2
	moveq #0,d2
	move.w CptInst(pc),d2
        tst.w FlagStos
        beq FinSeka
        rts
FinSeka:illegal

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | AFFICHAGE COMPILATION           |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------

;-----> Calcule et affiche un pourcentage: D0 / D1 
AffPour:cmp.w d1,d0
	bcc.s Afp1
	swap d0
	clr.w d0
	divu d1,d0
	mulu LBar(pc),d0
	swap d0
Afp0:	add.w BasBar(pc),d0
	bsr AffBar
	rts
Afp1:	move.w LBar(pc),d0
	bra.s Afp0
	
;-----> Affiche une ligne depuis la position courante---> D0
AffBar:	move.w d1,-(sp)
	move.w d0,d1
	move.w XLine,d0
	bra.s afb1
Afb0:	bsr AffLine
	addq.w #1,d0
Afb1:	cmp.w d1,d0
	bcs.s Afb0
	move.w d0,XLine
	move.w (sp)+,d1
	rts

;-----> Affiche une ligne VERTICALE en X=d0
AffLine:movem.l d0-d3/a0-a3,-(sp)
	move.l LigneA(pc),a0
	move.w YLine(pc),d1
	move.w d1,d2
	add.w HBar(pc),d2
	tst.w Resol			;Si HIRES: *2
	beq.s Ali1
	lsl.w #1,d0
	lsl.w #1,d1
	lsl.w #1,d2
Ali1:	move.w d0,38(a0)		;X
	move.w d0,42(a0)
	move.w d1,40(a0)		;Y
	move.w d2,44(a0)
	move.l #$FFFFFFFF,24(a0)	;Plans de couleur
	move.l #$FFFFFFFF,28(a0)
	clr.w 36(a0)			;Writing
	move.w #$FFFF,34(a0)		;Ligne parcourue
	move.w #-1,32(a0)
	dc.w $a003
	tst.l VTable
	beq.s Ali3
; Teste le CONTRL-C
	move.l AdVector(pc),a0
	move.b interflg(a0),d0
	bpl.s Ali3
	and.b #$7f,d0
	beq.s Ali2
	bclr #0,d0
	beq.s Ali2
	moveq #3,d0			;BREAK!
	bra CError 
Ali2:	move.b d0,(a0)
Ali3:	movem.l (sp)+,d0-d3/a0-a3
	rts



 
;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | ERREURS DU COMPILATEUR          |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
; Out of memory!
COut:   moveq #2,d0
        bra CError
; Rien a compiler!
CRien:	moveq #1,d0
	bra CError
; Message normaux
CSynt:  moveq #12,d0            ;Syntax error
        bra CError
CType:  moveq #19,d0            ;Type mismatch
        bra CError
DiskErr:moveq #-1,d0
        moveq #0,d1
        bra CError2

;-----> Entree ERREURS
CError: moveq #0,d1
	move.w Curline(pc),d1
CError2:and.w #$ffff,d0
        movem.l d0-d1,-(sp)
        bsr Close
        movem.l (sp)+,d0-d1
        tst.w FlagStos          ;Si STOS---> D0= # de l'erreur          
        beq.s CEro              ;D1= # de la ligne
        move.l SauveP,sp
        rts
CEro:   move.w d1,-(sp)
        move.w d0,-(sp)
        lea MError,a0
        bsr Print
        move.w (sp)+,d0
        bsr AffWord
        lea MErr,a0
        bsr print
        move.w (sp)+,d0
        bsr affword
        bsr AffRet
        illegal

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | ZEROIEME PASSE: FIXE LES BUFFERS|       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------

Passe0:

;-----> Met tout a zero
        clr.l LiToAd
        clr.l BReloc
        clr.l BAdString
        clr.l BAdChai
        clr.l Objet
        clr.w ValFlo
	clr.l NbRout
        bsr Passe1                      ;Fait la passe 1
        move.w FloFlag,ValFlo
        move.l Debwork,a6

;-----> Buffer LiToAd
        move.l a6,LiToAd
        move.l ALiToAd,d0
        addq.l #8,d0
        add.l d0,a6
        bsr Pair

;-----> Buffer relocation
        move.l a6,BReloc
        move.l LongRel,d0
        cmp.l #$1000,d0
        bcc.s BRel 
        move.l #$1000,d0
BRel:   add.l #$400,d0
        add.l d0,a6
        bsr Pair

;-----> Buffer AdString
        move.l a6,BAdString
        move.l AdString,d0
        addq.l #8,d0
        add.l d0,a6
        bsr Pair

;-----> Buffer adresses constantes alphanumeriques
        move.l a6,BAdChai
        move.l AdChai,d0
        addq.l #8,d0
        add.l d0,a6
        bsr Pair

;-----> Buffer objet 
        tst.l NomOut
        bne.s Bob1
; En Memoire
        move.l a6,StObjet
; Si debugg
        tst.w FlagStos
        bne.s Bob2
        move.l #$d0000-$1c-2,StObjet
        bra.s Bob2   
; Sur disque ---> adresse base=0
BOb1:   clr.l StObjet
; Rajoute le HEADER (Stos ou Gem)
Bob2:   move.l StObjet(pc),d0
        tst.w FlagGem
        bne.s Bob3
        add.l #10,d0
        bra.s Bob4
Bob3:   add.l #$1c+2,d0
Bob4:   move.l d0,Objet

;-----> Out of mem ???
        cmp.l TopWork(pc),a6
        bcc COut
	sub.l DebWork,a6
	move.l a6,TBuffers
        moveq #0,d0
        rts

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | PREMIERE PASSE                  |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------

Passe1:
;-----> Initialisations
        move.l Source,a6                ;A6= debut du source
        tst.l NomIn
        beq.s Pasa
        lea 17*4+10(a6),a6             
Pasa:   
        move.l Objet,a5                 ;A5= pointe l'objet
        move.l BReloc,a4                ;A4= table de relocation
        move.l BufCalc,a3               ;A3= buffer de calcul         

        move.l RoutIn,a0                
        move.w #RoutMx-1,d0             ;RAZ buffer RoutIn
Pas0:   clr.l (a0)+
        dbra d0,Pas0
        move.l #-1,(a0)                 ;Signale la fin

        clr.w FloFlag                   ;Pas de float!
        move.l Hivar,a0                 ;Pas de variable
        clr.w -(a0)                     
        move.l a0,LoVar
        move.l AdADefn,a0               ;Pas de DefFn
        move.l a0,ADefn
        clr.l (a0)+
        move.l a0,BotVar

        move.l a5,OldRel                ;Initialise la relocation

        move.l BAdString,AdString       ;Pas de chaine
        move.l BAdChai,a0
        move.l a0,AdChai
        tst.w Passe
        beq.s Pap
        clr.l (a0)
Pap:
        move.l #cbufbcle,cposbcle       ;Init des boucles
        clr.w cnboucle
        clr.w ctstnbcle

        move.l Tif,Pif                  ;Table des IF THEN ELSE

        move.l LiToAd,ALiToAd           ;Table des GOTO
        clr.w NbLines
        
        clr.l FstData                   ;Pas de datas
        clr.l OlData
        clr.w FlagMenu                  ;Pas de menu!
	clr.w CptInst			;Compteur instructions
	move.w #$ffff,CurLine

; Extensions
	clr.l extflag
        move.l AdExtAp(pc),a0
        move.l AdExtPa(pc),a1
        moveq #26-1,d0
InEx1:  tst.l (a0)
        beq.s InEx3
        move.l (a1),a2
        move.w (a2),d2
        move.l (a0),a2
        subq.w #1,d2
InEx2:  clr.l (a2)+
        dbra d2,InEx2
        move.l #-1,(a2)
InEx3:  lea 4(a0),a0
        lea 4(a1),a1
        dbra d0,InEx1

;-----> Saute les routines d'initialisation
        move.l #DebPrgF,d1
        sub.l #DebPrg,d1
        tst.w FlagGem
        bne.s p1in1
        add.l #InaF,d1           ;STOS-run
        sub.l #Ina,d1
        bra.s p1in2
p1in1:  add.l #InbF,d1           ;GEM-run
        sub.l #Inb,d1
p1in2:	add.l a5,d1
; Rempli de zero les routines INIT
p1in3:	clr.w d0
	bsr Outword
	cmp.l d1,a5
	bne.s p1in3
	tst.w FlagGem
	beq.s p1in4	
        move.w #Defo,d0          ;JSR redessin
        bsr Crefonc 
        move.w #206,d0           ;MOVE DATA
        bsr CreFonc
        move.w #210,d0           ;Calclong
        bsr CreFonc             
p1in4:  

;-----> Appel a RAZ PRG
        moveq #RazPrg,d0
        bsr CreFonc
	move.l a5,-(sp)		;Position au debut compilation
        bra.s DebChr

;-----> Exploration du source
FinLine:bsr RelBra              ;Reloge les BRA <LIGNE SUIVANTE>
        move.l NewLine,a6
DebChr: move.l a6,AdLine
        bsr GetWord
        beq FinPas1
        move.w d0,d1
        move.l ALiToAd,a0       ;Table #ligne / adresses
        bsr GetWord
        cmp.w #$ffff,d0         ;Pas de ligne 65535!
        beq CSynt
	move.w d0,Curline
        tst.w Passe             ;Si PASSE=0 ne poke pas!
        bne.s ChG1
        addq.l #6,a0
        bra.s ChG2  
ChG1:   move.w d0,(a0)+         ;Numero de la ligne
        move.l a5,(a0)+         ;Adresse de la ligne
ChG2:   move.l a0,ALiToAd
        lea -4(a6),a1
        add.w d1,a1
        move.l a1,NewLine
        add.w #1,NbLines        ;1 ligne de plus!
; Affiche la position
	move.l a6,d0
	sub.l Source,d0
	lsr.l #8,d0
	move.l LongSou,d1
	lsr.l #8,d1
	bsr AffPour
; Prend la prochaine instruction
ChrGet: bsr GetByte
        move.b d0,d1
        beq.s FinLine
        bmi.s Chr1
        cmp.b #":",d1
        beq ChrGet
        bra CSynt
; Appele l'instruction
Chr1:   and.w #$7f,d1
        lsl.w #2,d1
        lea Jumps,a1
        move.l (a1,d1.w),a1
        move.l #$49fafffe,d0
        bsr OutLong
	add.w #1,CptInst
        jsr (a1)
        bra.s ChrGet

;-----> Fin de la premiere passe: appel de la routine de fin
FinPas1:cmp.l (sp)+,a5			;Quelque chose de compile?
	beq CRien
	move.l #$49fafffe,d0
        bsr OutLong
        moveq #FiniStos,d0
        tst.w FlagGem
        beq.s FinP
        moveq #FiniGem,d0
FinP:   bsr CreFonc

;------------------------------------> APPEL DES TESTS DES MENUS
        tst.w Flagmenu
        beq.s pamen
        move.l a5,menucall
        move.w #572,d0
        bsr crejmp
pamen:
;------------------------------------> APPEL DE LA ROUTINE D'ERREUR
        move.l a5,d0
        sub.l Objet,d0                  ;Offset---> routine
        lea DebPrg,a0
        move.l d0,OError(a0)            ;Variable relogeable!
        moveq #Erreur,d0                
        bsr CreFonc                     ;Routine d'erreur
        moveq #Erreur+1,d0      
        tst.w FlagGem
        beq.s Ent1
        addq.w #1,d0
Ent1:   bsr CreFonc                     ;Retour STOS / GEM

;------------------------------------> COPIE LES INITS DES EXTENSIONS
        lea DebPrg(pc),a0
        lea OExt(a0),a0
        move.l a0,a2
        moveq #26-1,d0                  ;Nettoie la table
CIni1:  clr.l (a0)+
        dbra d0,CIni1
        moveq #1,d7                     ;Numero extension / fyche
        move.l ExtFlag,d6
; Recopie les initialisations
CIni2:  btst d7,d6
        beq.s CIni5
        move.l AdExtAd(pc),a1
        move.w d7,d1
        lsl.w #2,d1
        move.l -4(a1,d1.w),a1
        tst.w Passe
        bne.s CIni3
; Passe 0 : additionne la taille
        move.l 	8(a1),d0
        sub.l 	4(a1),d0
        add.l 	d0,a5
        bra.s 	CIni5
; Passe 1 : charge
CIni3:  move.l 	a5,d1
        sub.l 	Objet(pc),d1
        move.l 	d1,(a2)                  ;Adresse de l'extension
	move.l 	4(a1),d0                 ;Pointe l'init
        add.l 	#$1c,d0
        bsr 	LSeek
        move.l 	8(a1),d5                 ;Longueur a charger
        sub.l 	4(a1),d5
CIni3a	move.l	d5,d0             
        cmp.l 	MaxLoad(pc),d5
        bcs.s	CIni3b
	move.l	MaxLoad(pc),d0
CIni3b  sub.l	d0,d5
	move.l 	BufLoad(pc),a0
        bsr 	Load
        move.l 	BufLoad(pc),a1
        move.l 	d0,d1
        lsr.w 	#1,d1
	subq.w	#1,d1
CIni4:  move.w 	(a1)+,d0
        bsr 	OutWord
        dbra 	d1,CIni4
	tst.l	d5
	bne.s	CIni3a
CIni5:  lea 	4(a2),a2
        addq.w 	#1,d7
        cmp.w 	#27,d7
        bcs.s 	CIni2

;------------------------------------> COPIE LES ROUTINES LIBRAIRIE
                                        ;A6= debut des routines
                                        ;A5= position objet
                                        ;A4= position relocation
        move.l OldRel,d7                ;D7= derniere relocation
 
; Explore la table
CLib1:  move.l RoutIn,a6                ;A6= debut flags routines
        move.l AdExtAp,PAdExtAp         ;Debut flags extensions
        move.l AdExtAd,PAdExtAd         ;Debut des catalogues ext
        move.l AdCata,a3                ;A3= debut du catalogue
        moveq #0,d5                     ;D5= debut de la librairie
        moveq #0,d6                     ;Flag
	tst.w passe
	beq.s CLib2
	clr.l CptRout			;Initialise l'affichage
	move.w Bar2,BasBar

; Prend une routine
CLib2:  move.l (a6)+,d0                 ;Routine selectionnee?
        beq.s CLib3
        cmp.l #-1,d0                    ;Fin de la table?
        beq.s CLib4
        cmp.l #1,d0                     ;Deja copiee?
        beq.s CLib5
CLib3:  moveq #0,d0                     ;Pointe la routine suivante 
        move.w (a3)+,d0
        add.l d0,d5
        bra.s CLib2
; Passe a l'extension suivante...
CLib4:  swap d6
        move.l PAdExtAp,a0
        move.l PAdExtAd,a1
CLib4b: lea 4(a0),a0
        lea 4(a1),a1
        addq.w #1,d6
        tst.w -4(a0)
        bne.s CLib4c
        cmp.w #27,d6
        bne.s CLib4b
        swap d6
        tst.w d6                        ;A fait une tour: encore 1?
        bne.w CLib1
        bra CLibFin
CLib4c: move.l a0,PAdExtAp
        move.l a1,PAdExtAd
        move.l -4(a0),a6
        move.l -4(a1),a3
        moveq #0,d5
        lea 12(a3),a3
        swap d6
        bra.s CLib2
; Recopie une routine / marque les routines appelee
CLib5:  move.l a5,-4(a6)                ;Marque la RoutIn
        move.l d5,a2                    ;Debut de la routine a recopier
        tst.w Passe
        beq CLib10
; Charge le bout de routine dans BUFLOAD
	movem.l d0-d7/a0-a6,-(sp)
        move.w (a3),-(sp)               ;Longueur de la routine
        move.l d5,d0
        add.l #$1c,d0
        swap d6
        move.w d6,d7
        bne.s CLib5a
        add.l OLibr(pc),d0              ;Offset  DEBUT / CATA ---> LIB
        bra.s CLib5b
CLib5a: move.l PAdExtAd(pc),a0
        move.l -4(a0),a0
        add.l 8(a0),d0                  ;Offset DEBUT / CATA ----> EXT
CLib5b: bsr LSeek
        moveq #0,d0
        move.w (sp)+,d0    
        cmp.w MaxLoad+2(pc),d0		;Taille maxi des routines
        bcc CSynt
        move.l BufLoad(pc),a0
        bsr Load
	add.l #1,CptRout		;Affyche le nombre de routines
	move.l CptRout,d0
	move.l NbRout,d1
	bsr AffPour
        movem.l (sp)+,d0-d7/a0-a6
; Recopie la routine
        move.l BufLoad(pc),a1
        move.l a1,a2
CLib6:  tst.w (a2)+                     ;Cherche le debut du CODE
        bne.s CLib6
        moveq #0,d4                     ;Calcule l'ad de l'appel
        move.w (a1)+,d4
        add.l BufLoad(pc),d4
        moveq #0,d3
        move.w (a3),d3
        add.l BufLoad(pc),d3            ;Pointe la fin de la routine
; Boucle de recopie
CLib7:  cmp.l d3,a2                     ;Tout est recopie?
        bcc.w CLib3
        cmp.l d4,a2                     ;Appel a une autre routine
        beq.s CLib8
        move.w (a2)+,d0                 ;Envoie le mot
        bsr OutWord
        bra.s CLib7
; Un appel...
CLib8:  move.w (a2)+,d0                 ;Envoie le JSR / JMP
        bsr OutWord
; ...reloge...
        move.l a5,d0
        sub.l d7,d0                     ;... derniere relocation
ReR1:   cmp.w #126,d0
        bls.s ReR2
        bsr OutRel1                     ;>126: met 1 et boucle
        sub.w #126,d0
        bra.s ReR1
ReR2:   bclr #7,d0                      ;Flag #7=0 ---> JSR
        bsr OutRel                      ;<126: met le chiffre
        move.l a5,d7                    ;Derniere relocation...
        moveq #0,d4                     ;Pointe l'appel suivant, s'il existe
        move.w (a1)+,d4
        add.l BufLoad(pc),d4
; ...marque la table RoutIn
        move.l (a2)+,d0                 ;Envoie le # routine
        bclr #31,d0
        beq.s ReR3
; Appel interne a l'extension (BUG BUG BUG!)
	move.l	d0,d1
	and.w	#$00FF,d0
	swap	d6
	lsl.w	#8,d6
	or.w	d6,d0
	sub.w	#$0100,d0
	lsr.w	#8,d6
	swap	d6
        bset 	#28,d0
        bsr 	OutLong
        lsl.w 	#2,d1
        move.l 	PAdExtAp(pc),a0
        move.l 	-4(a0),a0
        add.w 	d1,a0
        tst.l 	(a0)
        bne.s 	CLib7
        move.l 	#1,(a0)
        addq.w 	#1,d6
        bra.s 	CLib7
; Appelle de la librairie normale
ReR3:   bsr OutLong
        lsl.w #2,d0
        move.l RoutIn,a0
        add.w d0,a0                     ;Pointe dans la table
        tst.l (a0)                      ;Deja appele?
        bne CLib7
        move.l #1,(a0)                  ;Marque
        addq.w #1,d6                    ;Flag: refaire un tour
        bra.w CLib7                     
;-----> C'est la passe 0!
CLib10: moveq #0,d3                     ;Longueur de la routine
        move.w (a3),d3          
        add.l d3,a5
        addq.l #2,a4
        lea 256(a5),a5                  ;Plus 256 octets/routine
        lea 12(a4),a4                   ;Plus 8 octets relocation
	add.l #1,NbRout
        bra CLib3
;-----> Fini de copier
CLibFin:moveq #0,d0                     ;Termine la table de relocation!
        bsr OutRel
        bsr OutRel
        move.l a4,LongRel

;-------------------------------> STOP si passe 0
	tst.w Passe			
	beq EndP1
; Initialise l'affichage  COPIE TRAPPES
	move.w Bar3(pc),d0
	move.w d0,BasBar
	bsr AffBar
	
;-------------------------------> Longueur du CODE
        move.l a5,d0
        sub.l Objet,d0
        move.l d0,LongCode

;-------------------------------> Recopie la table de relocation 
	move.l a5,d6
        sub.l Objet,d6          ;Pointeur ---> Table relocation
        move.l BReloc,a2
CRel:   move.b (a2)+,d0
        bsr OutByte
        tst.b d0
        beq.s CRel1
        btst #7,d0
        beq.s CRel
        move.b (a2)+,d0
        bsr OutByte
        bra.s CRel
CRel1:  move.w a5,d1            ;Rend pair
        btst #0,d1
        beq.s CRel2
        bsr OutByte
CRel2:  sub.l BReloc,a2         ;Longueur de la table de relocation
        move.l a2,LongRel
	moveq #1,d0
	moveq #28,d1
	bsr AffPour

;-------------------------------> Recopie la table LITOAD
	move.l a5,d5
        sub.l Objet,d5
        move.l LiToAd,a2        ;Debut de la table
CLi:    cmp.l ALiToAd,a2
        bcc.s CLi1
        move.w (a2)+,d0
        bsr OutWord
        move.l (a2),d0
        sub.l Objet,d0
        move.l d0,(a2)+
        bsr OutLong
        bra.s CLi
CLi1:   move.w #$ffff,d0
        bsr OutWord
        moveq #0,d0
        bsr OutLong
	moveq #2,d0
	moveq #28,d1
	bsr AffPour

;-------------------------------> Poke la chaine vide
	move.l a5,d7            ;D7= ad chaine vide
        clr.w d0
        bsr OutWord

;-------------------------------> Recopie les CONSTANTES ALPHANUMERIQUES
	move.l BAdChai,a1
        moveq #0,d2             ;longueur
P2c1:   tst.l (a1)              ;ZERO= termine
        beq.s P2c4
        move.l (a1),a6          ;Adresse dans le source
        move.l a5,(a1)+         ;Nouvelle adresse dans l'objet
        addq.w #2,a6
        bsr GetWord             ;Prend la longueur de la chaine
        tst.w d0
        bne.s P2c2
        move.l d7,-4(a1)        ;Si chaine vide---> pointe la bonne
        bra.s P2c1
P2c2:   bsr OutWord
        addq.l #2,d2
        move.w d0,d1
        addq.w #1,d1
        lsr.w #1,d1
        subq.w #1,d1            ;Travaille par mots
P2c3:   bsr GetWord             ;Recopie la chaine
        bsr OutWord
        addq.l #2,d2
        dbra d1,P2c3
        bra.s P2c1
P2c4:   move.l d2,LongChai      ;Longueur des chaines
        moveq #0,d0             ;Securite d'un mot long
        bsr OutLong
	moveq #3,d0
	moveq #28,d1
	bsr AffPour

;----------------------------> Laisse l'espace pour la table VarChaine
        move.l a5,d4            ;Offset OAdStr
        sub.l Objet,d4
        move.l AdString,d0
        sub.l BAdString,d0
        add.l d0,a5
        moveq #0,d0             ;Met au moins un zero!
        bsr OutLong

;----------------------------> Copie les TRAPPES si programme GEM-RUN
        movem.l d4-d7,-(sp)
        tst.w FlagGem
        beq.w PaTrap
; Copie WINDO101.LIB
CoTrap: lea NomWin(pc),a0
        move.l #OTrap3,a1
        bsr LoTrap
	moveq #4,d0
	moveq #28,d1
	bsr AffPour
        lea DebPrg(pc),a0       ;Jeux de caracteres par defaut
        move.l a5,d0
        sub.l Objet(pc),d0
        move.l d0,OCr0(a5)
        move.l d0,OCr1(a5)
        move.l d0,OCr2(a5)
        tst.l NomCr0
        beq.s Cot1
        move.l NomCr0(pc),a0
        move.l #OCr0,a1
        bsr LoTrap
Cot1:   moveq #5,d0
	moveq #28,d1
	bsr AffPour
	tst.l NomCr1
        beq.s Cot2
        move.l NomCr1(pc),a0
        move.l #OCr1,a1
        bsr LoTrap
Cot2:   moveq #6,d0
	moveq #28,d1
	bsr AffPour
	tst.l NomCr2
        beq.s Cot3
        move.l NomCr2(pc),a0
        move.l #OCr2,a1
        bsr LoTrap
; Copie SPRIT101.LIB
Cot3:   moveq #7,d0
	moveq #28,d1
	bsr AffPour
	lea NomSpr(pc),a0
        move.l #OTrap5,a1
        bsr LoTrap
	moveq #8,d0
	moveq #28,d1
	bsr AffPour
        move.l NomMou(pc),a0
        move.l #OMou,a1
        bsr LoTrap
	moveq #9,d0
	moveq #28,d1
	bsr AffPour
; Copie MUSIC101.LIB
        lea NomMus(pc),a0
        move.l #OTrap7,a1
        bsr LoTrap
	moveq #10,d0
	moveq #28,d1
	bsr AffPour
; Copie FLOAT101.LIB s'il faut
jlo:    lea DebPrg(pc),a0
        clr.l OTrap6(a0)
        tst.w FloFlag
        beq.s PaTrap
        moveq #31,d7
        lea NomFlo(pc),a0
        move.l #OTrap6,a1
        bsr LoTrap
	moveq #11,d0
	moveq #28,d1
	bsr AffPour
PaTrap:
        movem.l (sp)+,d4-d7

;----------------------------> Loke la longueur du PROGRAMME / BANQUE 0
        moveq #0,d0             ;Securite un mot long
        bsr OutLong
        move.l a5,d0            ;D0= Debut des variables
        sub.l Objet,d0
        move.l d0,LongProg
        sub.l #17*4,d0          ;Longueur de la banque 0
        move.l d0,BrDataB       ;---> dans le header

;----------------------------> Recopie les BANQUES (garder a4/d6/d7)
	move.l ADtbnk,a3
        move.l Source,a6        ;Debut du source
	tst.w NomIn
	beq.s CopB2a
	lea 17*4+10(a6),a6	;Saute les entetes
CopB2a:	lea BrDataB+4,a2
        add.l (a3)+,a6          ;Debut de la premiere banque
        moveq #0,d2
        moveq #0,d3
CopB3:  move.l (a3)+,d1
        move.l d1,(a2)+
        and.l #$ffffff,d1
        beq.s CopB5
; Copie la banque
	add.l d1,d3
        lsr.l #2,d1
CopB4:  bsr GetLong
        bsr OutLong
        subq.l #1,d1
        bne.s CopB4
CopB5:  moveq #12,d0
	add.w d2,d0
	moveq #28,d1
	bsr AffPour
	addq.w #1,d2
	cmp.w #15,d2
	bcs.s CopB3
FCopB:  move.l d3,LongBank

;----------------------------> Longueur totale du programme
        move.l a5,d1
        sub.l Objet(pc),d1
        move.l d1,LongOb
        move.l d1,d0
        sub.l #17*4,d0                  ;Longueur TOTALE ---> header
        move.l d0,BrLong
; Fausse table de relocation
        move.l #OVide-4,d0              ;Pour la table de relocation
        bsr Outlong
        moveq #0,d0
        bsr Outlong
        addq.l #2,d1
        move.l d1,HeadTos+2

;----------------------------> Loke les pointeurs dans l'initialisation
        lea DebPrg,a5
        move.l d4,OAdStr(a5)            ;Table adresse var alphanumeriques
        move.l d5,OLiAd(a5)             ;Table #LIGNE----> Adresse
        move.l d6,OReloc(a5)            ;Sauve la position relocation
        sub.l Objet,d7
        move.l d7,OChVide(a5)           ;Sauve la position chaine vide
        move.l FstData,OFData(a5)       ;Premiere ligne de datas
        move.l MenuCall,d0              ;Adresse de l'appel des menus
        sub.l Objet,d0
        move.l d0,OAdMenu(a5)
        move.l TBufSp(pc),OTBufSp(a5)
        move.l MaxCop(pc),OMaxCop(a5)
        move.w ValFlo(pc),OFloLa

;----------------------------> Fin de la passe1
EndP1:  rts

***********************************************************************

; Copie une trappe dans le programme
LoTrap: move.l a5,d1                    ;PAIR!
        btst #0,d1
        beq.s Lotp
        addq.l #1,d1
        addq.l #1,a5
Lotp:   sub.l Objet(pc),d1
        add.l #DebPrg,a1
        move.l d1,(a1)
        moveq #28,d7
        bsr SFirst
        bne Diskerr
        bsr Open
        move.l d0,d6
Lot0:   move.l BufLoad(pc),a0
        move.l MaxLoad(pc),d0
        cmp.l d0,d6
        bcc.s Lot1
        move.l d6,d0
Lot1:   bsr load
        move.l d0,d1
        sub.l d1,d6
        move.l BufLoad(pc),a0
Lot2:   move.l (a0)+,d0
        bsr outlong
        subq.l #4,d1
        bmi.s Lot3
        bne.s Lot2
Lot3:   tst.l d6
        bne.s Lot0
        bsr Clofyche
        rts

;-----> Entree des instructions etendues (en $A0)
CEten:  clr.w d0
        bsr GetByte
        cmp.b #32,d0
        bcs.s CEt1
; Appelle la routine
        sub.w #$70,d0
        bcs CSynt
        lsl.w #2,d0
        lea ExtJump,a0
        move.l 0(a0,d0.w),a0
        jmp (a0)
; Commande directe!
CEt1:   moveq #15,d0
        bra CError

;-----> Entree des fonctions etendues (en $B8)
FEten:  clr.w d0
        bsr GetByte
        sub.w #$80,d0
        bcs CSynt
; Appelle la routine
        lsl.w #2,d0
        lea ExtFonc,a0
        move.l 0(a0,d0.w),a0
        jmp (a0)

;-----> Entree des instructions EXTENSIONS
CExti:  bsr test0
        bsr extpar
        movem.w d2/d6/d7,-(sp)
        cmp.b #1,(a2)                   ;Si pas de params!
        beq.s Exti1
        bsr parinst
Exti1:  bra.s extcall

;-----> Entree des fonctions EXTENSIONS
Cextf:  bsr extpar
        movem.w d2/d6/d7,-(sp)
        cmp.b #1,(a2)
        beq.s Extf1
        bsr parfonc
Extf1:  
; Appelle la fonction / instruction
extcall:movem.w (sp)+,d2/d6/d7
        move.w cmvqd0,d1
        move.b d0,d1
        move.w d1,d0
        bsr outword
        move.w cmvd1,d0
        bsr outword
        move.w d6,d0
        lsl.b #2,d0
        add.w #OExt,d0
        bsr outword
        move.w CJsr,d0
        bsr OutWord
        bsr reljsr
        moveq #0,d0
        move.b d6,d0
        lsl.w #8,d0
        move.b d7,d0
        bset #28,d0
        bsr OutLong
        rts

; Pointe la definition des parametres   ---> A2
;                                       ---> D6= #extension
;                                       ---> D7= #instructio
extpar: moveq #0,d0
        bsr GetByte
        cmp.b #2,d0
        bne.s extp1
; Directive compilateur
	move.w d0,d1 
	bsr getbyte
	cmp.b #$88,d0
	beq.s cpt3
	cmp.b #$86,d0
	beq.s cpt2
	cmp.b #$84,d0
	beq.s cpt1
	cmp.b #$82,d0
	beq.s cpt0
	subq.l #1,a6
	move.w d1,d0
	bra.s extp1
; Comptest off
cpt0:	clr.w Tests
	bra.s cpt4
; Comptest on
cpt1:	move.w #1,Tests
	bra.s cpt4
; Comptest always
cpt2:	move.w #2,Tests
	bra.s cpt4
; Comptest
cpt3:	moveq #Tester,d0
	bsr CreFonc
; Fin: POP!
cpt4:	addq.l #4,sp
	rts
; Normale ---> extension presente?
extp1:  move.w d0,d6
        move.l extflag,d1               ;Marque l'extension appelee
        addq.w #1,d0
        bset d0,d1
        subq.w #1,d0
        move.l d1,extflag
        lsl.b #2,d0
        move.l AdExtAd(pc),a0
        tst.l 0(a0,d0.w)
        beq.s Expala
        move.l AdExtPa(pc),a0
        move.l 0(a0,d0.w),a2            ;Adresse des parametres
        move.l AdExtAp(pc),a0
        move.l 0(a0,d0.w),a0
        bsr GetByte
        and.w #$7f,d0
        cmp.w 2(a2),d0
        bhi CSynt
        move.w d0,d7
        lsl.b #1,d0
        add.w 4(a2,d0.w),a2             ;Pointe les params
        lsl.b #1,d0
        move.l #1,0(a0,d0.w)            ;Force l'appel de la routine
        clr.w d2
        move.b (a2)+,d2                 ;Ramene le type de retour
        rts
Expala: moveq #84,d0
        bra cerror

;-----> L'instruction est-elle finie
Finie:  bsr GetByte
        subq.l #1,a6
        tst.b d0                ;0 / : / ELSE
        beq.s Fi
        cmp.b #":",d0
        beq.s Fi
        cmp.b #$9b,d0
Fi:     rts

;-----> ON ou OFF ou FREEZE 
OnOff:  bsr GetByte
        cmp.b #$a6,d0
        beq.s onof1
        cmp.b #$a7,d0
        beq.s onof2
        cmp.b #$a5,d0
        beq.s onof3
        subq.l #1,a6
        moveq #-1,d0
        rts
onof1:  clr.w d0
        rts
onof2:  moveq #1,d0
        rts
onof3:  clr.w d0
        subq.w #1,d0
        rts

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | DEUXIEME PASSE                  |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
Passe2: 
            
;--------------------------------------> Reloge le programme
        move.l Objet,d7         ;Base de toute les adresses
        move.l d7,a5            ;Debut de l'exploration
        move.l RoutIn,a3        ;Catalogue de la librairie
        move.l BReloc,a6        ;Table de relocation
        move.l LongProg,a4      ;Debut des variables
        move.l a4,d4            ;---> addition
        move.l BAdString,a2     ;Table des variables chaines
P2a:    move.b (a6)+,d0
        beq.w P2f
        cmp.b #1,d0
        bne.s P2b
        add.w #126,a5
        bra.s P2a
; Affyche la position
P2b:    move.w d0,-(sp)
	move.l a6,d0
	sub.l BReloc,d0
	move.l LongRel,d1
	bsr AffPour
	move.w (sp)+,d0
	move.b d0,d1
        and.w #$7f,d1
        add.w d1,a5
        btst #7,d0
        bne.w P2c
; Routine librairie ou constante alphanumerique
        bsr GtoLong
        subq.l #4,a5
        btst #31,d0
        bne.s P2g
        btst #30,d0
        bne.s P2h
        btst #29,d0
        bne.s P2i
        btst #28,d0
        bne.w P2m
; Trouve l'adresse d'une routine librairie 
        lsl.w #2,d0
        move.l 0(a3,d0.w),d0    ;Adresse absolue de la routine
        sub.l d7,d0
        bsr OutLong
        subq.l #4,a5
        bra P2a
; Trouve l'adresse d'une constante alphanumerique
P2g:    and.l #$ffffff,d0
        move.l d0,a0
        move.l (a0),d0          ;Adresse absolue de la constante
        sub.l Objet,d0          ;---> relative
        bsr OutLong
        subq.l #4,a5
        bra.w P2a
; Simple adresse a l'interieur du programmme
P2h:    and.l #$ffffff,d0
        bsr OutLong
        subq.l #4,a5
        bra.w P2a
; Trouve l'adresse d'un GOTO / GOSUB
P2i:    move.l LiToAd,a0
        move.l ALiToAd,a1
P2j:    cmp.l a1,a0
        bcc.s P2l
        cmp.w (a0),d0
        beq.s P2k
        bcs.s P2l
        addq.l #6,a0
        bra.s P2j
P2k:    move.l 2(a0),d0
        bsr OutLong
        subq.l #4,a5
        bra.w P2a
P2l:    move.l LiToAd,a0
        move.l alitoad,a1
        sub.l objet,a5
p2l1:   lea 6(a0),a0
        cmp.l a1,a0
        bcc.s p2l2
        cmp.l 2(a0),a5
        bhi.s p2l1
p2l2:   moveq #0,d1
        move.w -6(a0),d1
        moveq #29,d0
        bra CError2
; Trouve l'adresse d'un appel a une extension
p2m:    move.l AdExtAp(pc),a0
        move.w d0,d1
        lsr.w #8,d1
        lsl.w #2,d1
        move.l 0(a0,d1.w),a0
        and.w #$ff,d0
        lsl.w #2,d0
        move.l 0(a0,d0.w),d0            ;Adresse absolue 
        sub.l d7,d0
        bsr OutLong
        subq.l #4,a5
        bra P2a
; Trouve l'adresse d'une variable / pointe la suivante
P2c:    bsr GtoLong
        subq.l #4,a5
        move.l d0,a0            ;Pointe la table des variables
        move.b (a0),d0
        bne.s P2d
; Deja passe: reprend l'adresse
        move.l (a0),d0
        bsr OutLong
        subq.l #4,a5
        addq.l #1,a6            ;Saute le flag
        bra P2a
; Premiere utilisation de cette variable
P2d:    move.l a4,d0            ;Position relative dans les variables
        move.l d0,(a0)          ;Repoke dans les variables
        bsr OutLong
        subq.l #4,a5
        move.b (a6)+,d0
        and.b #$e0,d0
        bpl.s P2e1
        move.l a4,(a2)+         ;Construit la tables des variables alpha
        btst #5,d0              ;$8000xxxx si tableau!
        beq.s P2e1
        bset #7,-4(a2)
P2e1:   btst #5,d0              ;Tableau: pointeur sur tableau          
        bne.s P2e
        tst.b d0
        beq.s P2e
        bmi.s P2e
        addq.l #4,a4
P2e:    addq.l #4,a4
        bra P2a
; Fin: loke l'offset de fin des variables / debut des trappes
P2f:    clr.l (a2)              ;Arret AdString
        addq.l #8,a4            ;Saute la derniere variable
        lea DebPrg,a5
        move.l a4,OTrappes(a5)
        sub.l d4,a4             ;Longueur des variables
        move.l a4,LongVar

;--------------------------------> Copie la table AdString
        move.l OAdStr(a5),a5
        add.l Objet,a5
        move.l BAdString,a0        
P2s:    move.l (a0),d0
        bsr OutLong
        tst.l (a0)+
        bne.s P2s

;--------------------------------> Copie le debut du programme
        move.l Objet,a5
        move.l #DebPrg,a0       ;Copie les variables
        move.l #DebPrgF,a1
        bsr CodeF       
        tst.w FlagGem
        bne.s P2t
        move.l #Ina,a0          ;Initialisation STOS-RESIDENT
        move.l #InaF,a1
        bsr CodeF
        rts
P2t:    move.l #Inb,a0          ;Initialisation GEM-run
        move.l #InbF,a1
        bsr CodeF
        rts


       
*************************************************************************
*       FABRICATION DU PROGRAMME BASIC RESIDENT
        even
; Header STOS
HeadStos:
	dc.b "Lionpoulos"

; Header TOS
HeadTos:
        dc.b $60,$1a
        dc.l OVide-4
        ds.b $1c-6
        bra.s ButDe

; Programme
DebPrg: 

;-----> Datas banques
BRLong: dc.l 0
BRDataB:ds.l 16
        dc.w $0008,$ffff
        dc.b $a8,$02,$80,$00
        dc.w 0000 
OLong:  equ 0
ODataB: equ 4
;-----> Programme
ButDe:  bra 	DPrg
        dc.b 	"Stos basic compiler V 1.0 by Francois Lionet"
glu:    equ 	*-DebPrg
        ds.b 	128-glu
        even

DebD:           equ 128                 ;DeD-DebPrg
**********************************
; Non relogeables
ATable:         equ DebD+$00            ;Adresse de la table
OTBufSp:        equ DebD+$04
OMaxCop:        equ DebD+$08
OVide:          equ DebD+$12
; Relogeables
DebRel:         equ DebD+$10
OChVide:        equ DebD+$10            ;Chaine vide
OReloc:         equ DebD+$14            ;Debut de la table de relocation
OTrappes:       equ DebD+$18            ;Debut des buffers trappes
OError:         equ DebD+$1c            ;Traitement des erreur
OLiAd:          equ DebD+$20            ;Table #LIGNE----> ADRESSE
OAdStr:         equ DebD+$24
OFData:         equ DebD+$28
OAdMenu:        equ DebD+$2C
OTrap3:         equ DebD+$30            ;Adresses des trappes
OTrap5:         equ DebD+$34
OTrap6:         equ DebD+$38
OTrap7:         equ DebD+$3C
OExt:           equ DebD+$40            ;Offset (debut/fin) des 26 extensions
OCr0:           equ 26*8+OExt
OCr1:           equ OCr0+4
OCr2:           equ OCr1+4
OMou:           equ OCr2+4
LDeb:           equ OMou+4

**********************************
        ds.b LDeb                       ;Reserve la place               
        dc.w $ff00                      ;Signal de fin des relogeables
**************************************************************************
*       Zone de donnees FIXES 

; Flag FLOAT present!
OFlola: dc.w 0
OOFloLa:equ OFloLa-debprg
OZero:	dc.l 0,$12345678
OOZero:	equ OZero-debprg

; TABLE DE DEFSCROLL
odfst:  ds.w 16*8
oodfst: equ odfst-debprg

; AMBIANCE PAR DEFAUT
oamb:   dc.w $000,$777,$070,$000,$770,$420,$430,$450
        dc.w $555,$333,$733,$373,$773,$337,$737,$337
ooamb:  equ oamb-debprg
; CURSEUR PAR DEFAUT
	dc.w 0
; TOUCHES DE FONCTION PAR DEFAUT
	dc.w 0
; MODE PAR DEFAUT	
	dc.w 0
; LANGUE PAR DEFAUT
	dc.w 1
; BLACK et WHITE env
	dc.w 1
; HIDE / SHOW
	dc.w 0
	
*************************************************************************
;-----> Debut du programme
DPrg:   lea DebPrg(pc),a6               ;Debut du programme

;-----> Reloge les adresses systeme
        move.l a6,d6
        lea DebRel(a6),a5
DPrg2:  cmp.w #$FF00,(a5)
        beq.s DPrg3
        add.l d6,(a5)+
        bra.s DPrg2
DPrg3:

;-----> Reloge la table des GOTO
        move.l OLiAd(a6),a5
DPrg4:  cmp.w #65535,(a5)+
        beq.s DPrg5
        add.l d6,(a5)+
        bra.s DPrg4
DPrg5:

;-----> Reloge la table des AdString
        move.l OAdStr(a6),a5
DPrg6:  tst.l (a5)
        beq.s DPrg7
        add.l d6,(a5)+
        bra.s DPrg6
DPrg7:

;-----> Efface la table des defscroll
        lea odfst(pc),a1
        move.w #16*8-1,d0
cd2:    clr.w (a1)+
        dbra d0,cd2

; Passe la main a la suite...
DebPrgF:

************************************************************************

************************************************************************
*       Initilisation BASIC RESIDENT
*       Relocation des variables 
                                                                                                                                                          
    
Ina:    move.l a0,ATable(a6)    ;Adresse de la table d'adresses
        move.l $4C(a0),a0       ;Pointe VECTEURS
        move.l topmem(a0),a5    ;Trouve la fin de la memoire!

        move.l OReloc(a6),a0    ;Pointe la table de relocation
        move.l a6,a2            ;Debut a reloger
        move.l OChVide(a6),a4   ;Chaine vide
        clr.w d7                ;Flag Out of mem
	move.l OoZero(a6),d3	;Prend le ZERO float!
	move.l OoZero+4(a6),d4

Ina1:   move.b (a0)+,d0
        beq.s Ina10
Ina2:   cmp.b #1,d0
        bne.s Ina3
        add.w #126,a2
        bra.s Ina1
Ina3:   move.b d0,d1
        and.w #$007F,d1
        add.w d1,a2
; Reloge...
        btst #7,d0
        bne.s Ina4
; Reloge un JSR / JMP ...
        add.l d6,(a2)           ;Additionne la base
        bra.s Ina1
; Reloge et CLEAR une variable
Ina4:   add.l d6,(a2)           ;Additionne la base
        move.l (a2),a3
        cmp.l a3,a5
        bcc.s Ina7              ;Out of mem!
        moveq #1,d7
Ina7:   move.b (a0)+,d0         ;Prend le flag de la variable
        btst #4,d0              ;Pas d'init
        beq.s Ina1
        tst.w d7                ;Out of mem
        bne.s Ina1
        btst #5,d0              ;Tableau: RAZ du pointeur!
        bne.s Ina5
        and.b #$C0,d0
        bmi.s Ina6
	bne.s Ina8
Ina5:	clr.l (a3)              ;Clear une entiere
        bra.s Ina1
Ina6:   move.l a4,(a3)          ;Adresse de la chaine vide
        bra.s Ina1
Ina8:	move.l d3,(a3)+		;Clear une float
	move.l d4,(a3)
	bra.s Ina1
; Sauve les adresses importantes
Ina10:  
	move.l ATable(a6),a0
        move.l $4c(a0),a5               ;Pointe les vecteurs
        move.l a6,Debut(a5)             ;Debut du programme
        move.l OError(a6),Error(a5)     ;Traitement des erreurs
        move.l OTrappes(a6),d0
        move.l d0,LoChaine(a5)          ;Nouveau, pour pas deranger
        move.l d0,HiChaine(a5)          ;FSource!
        move.l a4,ChVide(a5)            ;Chaine vide
        move.l sp,SPile(a5)             ;Sauve la pile
        move.l sp,LowPile(a5)           ;Niveau zero de la pile!
        add.l #4,LowPile(a5)
        move.l OLiAd(a6),LiAd(a5)       ;Adresse des LiToAd
        move.l OAdStr(a6),AdStr(a5)     ;Adresse Ad-Strings
        move.l OFData(a6),datastart(a5) ;Datas
        move.l OAdMenu(a6),AdMenu(a5)   ;Menus
        move.l a0,Table(a5)             ;Adresse de la table d'adresses

; Donnees pour le programme
        move.l $0c(a0),dta(a5)
        move.l $10(a0),fichiers(a5)
        move.l $54(a0),contrl(a5)
        move.l $58(a0),intin(a5)
        move.l $5c(a0),ptsin(a5)
        move.l $68(a0),vdipb(a5)
	move.l $98(a0),buffonc(a5)	;NOUVEAU 2.04: adresses touches!
	move.l $a0(a0),foncnom(a5)	
        lea oodfst(a6),a1
        move.l a1,dfst(a5)
        move.w OOFloLa(a6),FloLa(a5)    ;Float present?
	move.l OoZero(a6),ZeroFl(a5)	;RAZ zero float
	move.l OoZero+4(a6),ZeroFl+4(a5)
        clr.w FlgRun(a5)
; Buffers
        move.l (a0),d0
        move.l d0,Buffer(a5)            ;Adresse du buffer (monte)
        move.l d0,name1(a5)
        move.l d0,name2(a5)
        add.l #64,name2(a5)
        move.l d0,d1
        add.l #256,d1
        move.l d1,fsname(a5)
        add.l #32,d1
        move.l d1,fsbuff(a5)
        move.l d0,a0                    ;Adresse pour calculs...
        move.l d0,a6
        move.l a6,BufPar(a5)            ;Buffer des parametres (desc)
        sub.w #512,d0
        move.l d0,DeFloat(a5)           ;Buffer ecriture float
        sub.w #$180,d0
        move.l d0,Work(a5)              ;Definition workstation

; Sauve les vecteurs erreurs systeme
        lea SVect(a5),a0
        move.l $8,(a0)+
        move.l $c,(a0)+
        move.l $404,(a0)+
        move.l $10,(a0)+
        move.l $14,(a0)+
        lea CErrbus(pc),a0
        move.l a0,$8
        lea CErradr(pc),a0
        move.l a0,$c
        lea CCritic(pc),a0
        move.l a0,$404
        lea CIllins(pc),a0		
        move.l a0,$10
        lea CDbyzer(pc),a0
        move.l a0,$14

	tst.w d7			;Si Out of MEM
	bne InaErr

; Initialise les extensions
        clr.w FlaGem(a5)
        move.l Debut(a5),a3
        lea OExt(a3),a2
        moveq #26-1,d2
        move.l LoChaine(a5),a0
        move.l LowVar(a5),a1
Ina20:  cmp.l (a2),a3
        beq.s Ina21
        movem.l d2/a2/a3/a4/a5/a6,-(sp)
        move.l (a2),a2
        clr.w d0
        jsr (a2)
	move.l a2,d1
        movem.l (sp)+,d2/a2/a3/a4/a5/a6
        tst.w d0
        bne.s InaErr
	move.l d1,26*4(a2)			;Adresse de fin
Ina21:  lea 4(a2),a2
        dbra d2,Ina20
        move.l a0,LoChaine(a5)
        move.l a0,HiChaine(a5)
        bra.s InaF

;-----> Erreurs systeme
InaErr: moveq #8,d0
        bra errgo
CErrbus:moveq #31,d0
        bra errgo
CErradr:moveq #32,d0
        bra errgo
CCritic:rts
CIllins:moveq #82,d0
        bra errgo
CDbyzer:moveq #46,d0
ErrGo:  move.l error(a5),a0
        jmp (a0)

; Fin de la sequence de code
InaF:

*************************************************************************
*       DEBUT POUR GEM
*************************************************************************
Inb:

;-----> Efface / Recopie les touches de fonctions ---> buffer
        lea df(pc),a1
        lea bf(pc),a2
        move #19,d0
cd0:    move.l a2,a3
cd1:    move.b (a1)+,(a3)+
        bne.s cd1
        add #40,a2
        dbra d0,cd0

*********************** GLOADER.PRG
;-----> Efface SOURIS / CURSEUR
        dc.w $a00a                    ;enleve la souris
        pea cursec(pc)
        move #9,-(sp)
        trap #1
        addq.l #6,sp

;-----> Passe en mode SUPERVISEUR -si pas deja-
;	move.w sr,d0		ILLEGAL trouver un autre moyen
;	btst #13,d0
;	bne.s DejaSup
        clr.l -(sp)         ;passage en mode SUPERVISEUR
        move.w #$20,-(sp)
        trap #1
        addq.l #6,sp
DejaSup:
;-----> Sauve les donnees ecran
        lea dataec(pc),a5
        move.w #3,-(sp)       ;cherche l'adresse LOGIQUE
        trap #14
        addq.l #2,sp
        move.l d0,imagec(a5)
;-----> SAUVE LA PALETTE et ADAPTE A L'ORDINATEUR
;       installe aussi la fausse trappe FLOAT!
        lea $ff8240,a0
        lea dataec(pc),a1
        moveq #15,d0
bgp1:   move.w (a0)+,(a1)+
        dbra d0,bgp1
; Adapte aux ROMS en respectant le systeme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Adapt+2(pc),a4
	dc.w	$A000
	lea	-602(a0),a1	; Position souris
	move.l	a1,(a4)
	lea	-692(a0),a1	; Table VDI 1
	move.l	a1,12(a4)
	lea	-498(a0),a1	; Table VDI 2
	move.l	a1,16(a4)

	move.w	#1,-(sp)	; Adresse du buffer clavier
	move.w	#14,-(sp)
	trap 	#14
	addq.l	#4,sp
	move.l	d0,8(a4)

	move.w	#34,-(sp)	; Adresse des interruptions souris
	trap 	#14
	addq.l	#2,sp
	move.l	d0,a0
	lea	16(a0),a1		; Adresse souris
	move.l	a0,20(a4)
	lea	24(a0),a0
	lea	Joy_In(pc),a1
	move.l	a0,Joy_Ad-Joy_In(a1)
	move.l	(a0),Joy_Sav-Joy_In(a1)
	move.l	a1,(a0)			; Branche la routine joystick
	move.l	a1,4(a4)		; Adresse du resultat

; Fausse trappe FLOAT en trappe 6
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        lea FauxFloat(pc),a0
	move.l a0,$98

;-----> Suite sauvegarde
        lea dataec+32(pc),a4
        move.w #4,-(sp)
        trap #14              ; get res
        addq.l #2,sp
        move d0,modec(a5)
        lea adapt+2(pc),a3
        move.l 12(a3),a0              ;table VDI 1
        moveq #$5a/2-1,d0
sv1:    move.w (a0)+,(a4)+            ;recopie...
        dbra d0,sv1
        move.l 16(a3),a0              ;table VDI 2
        moveq #$18/2-1,d0
sv2:    move.w (a0)+,(a4)+            ;recopie...
        dbra d0,sv2
        move.l 0(a3),a0               ;coordonnees de la souris
        move.l (a0),(a4)+

*********************** CREE LA FAUSSE TABLE DE DONNEES
        move.l $42e,a5
        sub.l #$10000,a5
        sub.l #Libre+256,a5             ;Debut VAR / Fin Pile!
        move.l a5,a0
        lea -256*4(a0),a4               ;Taille pile: 256 mots longs
        move.l #Libre+256/4-1,d0
Inbt1:  clr.l (a0)+
        dbra d0,InbT1

        move.l 4(sp),a0
        lea 128(a0),a0
        move.l #$01234568,callreg(a5)   ;Command line!
        move.l a0,callreg+4(a5)
        move.l sp,SPile(a5)             ;Sauve la pile
        move.l a5,sp                    ;Nouvelle pile
        lea adapt+2(pc),a3
        move.l a3,ada(a5)               ;adresse adaptation
        move.l (a3),adm(a5)             ;adresse souris
        move.l 8(a3),adk(a5)            ;adresse clavier
        move.l 24(a3),ads(a5)           ;adresse sons

        clr.l -(a4)                     ;Initialise DATAPRG
        lea dataprg(a5),a0
        move.l a0,adataprg(a5)
        lea 8(a0),a0
        moveq #14,d0
Inbb1:  move.l a4,(a0)+
        move.l #2,(a0)+
        dbra d0,Inbb1
        move.l a4,d4                    ;TOPMEM multiple de 256
        clr.b d4
        move.l d4,a4
        move.l a4,TopMem(a5)
        lea 17*4(a6),a0
        move.l a0,DSource(a5)
        move.l a0,DataPrg(a5)
        lea databank(a5),a0           ;DATABANK
        move.l a0,adatabank(a5)
        lea 16*4(a0),a0
        moveq #14,d0
ig3:    move.l #2,(a0)+               ;Premiere banque: source de deux octets
        moveq #14,d1
ig4:    clr.l (a0)+                   ;Autre banques: longueur nulle
        dbra d1,ig4
        dbra d0,ig3

        move.l $42e,d0                  ;fin de la memoire physique
        sub.l #$8000,d0                 ;moins 32 k
        move.l d0,deflog(a5)            ;= ecran logique & physique
        sub.l #$8000,d0                 ;moins 32 k
        move.l d0,defback(a5)           ;= decor des sprites

*********************** BOUGE LES BANQUES AU BOUT DE LA MEMOIRE
        move.l OLong(a6),d0             ;Longueur TOTALE
        move.l d0,DataPrg+4(a5)
        sub.l ODataB(a6),d0             ;- banque 0 = long banques
        move.l DSource(a5),a0
        add.l ODataB(a6),a0             ;Pointe la premiere banque
        move.l a0,a2
        add.l d0,a0                     ;Pointe la FIN
        move.l Topmem(a5),a1            ;Haut de la memoire
        bra.s InbC1
; Copie
InbC0:  move.l -(a0),-(a1)
        move.l -(a0),-(a1)
        move.l -(a0),-(a1)
        move.l -(a0),-(a1)
InbC1:  cmp.l a2,a0
        bhi.s InbC0
        move.l a1,Himem(a5)
        move.l a1,LowVar(a5)

        lea ODataB(a6),a0               ;Copie DATABANK
        lea databank(a5),a1
        moveq #15,d0
InbC2:  move.l (a0)+,(a1)+
        dbra d0,InbC2

*********************** RELOGE LE PROGRAMME
        move.l a6,d6            ;Addition a reloger
        move.l OReloc(a6),a0    ;Pointe la table de relocation
        move.l a6,a2            ;Debut a reloger
        move.l OChVide(a6),a4   ;Chaine vide
        move.l Himem(a5),d5     ;Fin de la memoire
        clr.w d7                ;Flag Out of mem
	move.l OoZero(a6),d3	;Zero float
	move.l OoZero+4(a6),d4

inb1:   move.b (a0)+,d0
        beq.s inb10
inb2:   cmp.b #1,d0
        bne.s inb3
        add.w #126,a2
        bra.s inb1
inb3:   move.b d0,d1
        and.w #$007F,d1
        add.w d1,a2
; Reloge...
        btst #7,d0
        bne.s inb4
; Reloge un JSR / JMP ...
        add.l d6,(a2)           ;Additionne la base
        bra.s inb1
; Reloge et CLEAR une variable
inb4:   add.l d6,(a2)           ;Additionne la base
        move.l (a2),a3
        cmp.l a3,d5
        bcc.s inb7              ;Out of mem!
        moveq #1,d7
inb7:   move.b (a0)+,d0         ;Prend le flag de la variable
        btst #4,d0              ;Pas d'init
        beq.s inb1
        tst.w d7                ;Out of mem
        bne.s inb1
        btst #5,d0              ;Tableau: RAZ du pointeur!
        bne.s inb5
        and.b #$C0,d0
        bmi.s inb6
	bne.s inb8
inb5:   clr.l (a3)              ;Clear une entiere
        bra.s inb1
inb6:   move.l a4,(a3)          ;Adresse de la chaine vide
        bra.s inb1
inb8:	move.l d3,(a3)+		;RAZ float
	move.l d4,(a3)
	bra.s inb1

; Sauve les adresses importantes
inb10:  tst.w d7
	bne ErrM1
	move.l a6,Debut(a5)             ;Debut du programme
        move.l OError(a6),Error(a5)     ;Traitement des erreurs
        move.l a4,ChVide(a5)            ;Chaine vide
        move.l sp,LowPile(a5)           ;Niveau zero de la pile!
        add.l #4,LowPile(a5)
        move.l OLiAd(a6),LiAd(a5)       ;Adresse des LiToAd
        move.l OAdStr(a6),AdStr(a5)     ;Adresse Ad-Strings
        move.l OFData(a6),datastart(a5) ;Datas
        move.l OAdMenu(a6),AdMenu(a5)   ;Menus

; Tables VDI...
        lea cvdipb(pc),a2
        move.l a2,vdipb(a5)
        move.l OTrappes(a6),a4
        move.l a4,FSource(a5)
        move.l a4,a3 
        move.l a4,dta(a5)
        lea 48(a4),a4
        move.l a4,fichiers(a5)
        lea 106*10(a4),a4
        move.l a4,contrl(a5)
        move.l a4,(a2)
        lea 12*2(a4),a4
        move.l a4,Intin(a5)
        move.l a4,4(a2)
        lea 128*2(a4),a4
        move.l a4,ptsin(a5)
        move.l a4,8(a2)
        lea 128*2(a4),a4
        move.l a4,12(a2)
        lea 128*2(a4),a4
        move.l a4,16(a2)
        lea 128*2(a4),a4
; Buffers
        move.l a4,Work(a5)              ;Definition workstation
        lea $180(a4),a4
        move.l a4,defloat(a5)
        lea 512(a4),a4
        move.l a4,BufPar(a5)            ;Parametres, descendant
        move.l a4,Buffer(a5)            ;Adresse du buffer (monte)
        move.l a4,a0
        move.l a0,name1(a5)
        move.l a0,name2(a5)
        add.l #64,name2(a5)
        lea 256(a0),a0
        move.l a0,fsname(a5)
        lea 32(a0),a0
        move.l a0,fsbuff(a5)
        lea 512+512+32(a4),a4
; Donnees editeur
        lea bf(pc),a1
        move.l a1,buffonc(a5)
        lea fn(pc),a1
        move.l a1,foncnom(a5)
        lea oodfst(a6),a1
        move.l a1,dfst(a5)
        lea ooamb(a6),a1
        move.l a1,amb(a5)
	move.w 36(a1),defmod(a5)
	move.w 38(a1),langue(a5)
        clr.w FlgRun(a5)
	move.l OoZero(a6),ZeroFl(a5)
	move.l OoZero+4(a6),ZeroFl+4(a5)
; Out of mem?
        cmp.l LowVar(a5),a4
        bcc ErrM1
; Nettoie tous les buffers
inbcl:  clr.l (a3)+
        cmp.l a4,a3
        bcs.s inbcl

; Premier appel des trappes
        move.l a4,a0
        move.l LowVar(a5),a1
; Fenetres
        move.l OTrap3(a6),a2
        bsr reloge
        move.l OCr0(a6),a2
        move.l OCr1(a6),a3
        move.l OCr2(a6),a4
        move.l OMaxCop(a6),d0
        move.l a6,-(sp)
        move.l OTrap3(a6),a6
        jsr (a6)
        move.l (sp)+,a6
        tst.w d0
        bne ErrM1
; Sprites
        move.l OTrap5(a6),a2
        bsr Reloge
        move.l OMou(a6),a2
        lea adapt+2(pc),a3
        move.l OTBufsp(a6),d0
        move.l OTrap5(a6),a4
        jsr (a4)
        tst.w d0
        bne ErrM1
; Float?
        move.w OOFloLa(a6),FloLa(a5)
        beq.s InbPaf
        move.l OTrap6(a6),a2
        bsr Reloge
        movem.l a0-a6,-(sp)
        jsr (a2)
        movem.l (sp)+,a0-a6
; Music
InbPaf: move.l OTrap7(a6),a2
        bsr Reloge
        jsr (a2)
        tst.w d0
        bne ErrM1
        move.l a0,LoChaine(a5)

; Sauve les vecteurs erreurs systeme
        lea SVect(a5),a0
        move.l $8,(a0)+
        move.l $c,(a0)+
        move.l $404,(a0)+
        move.l $10,(a0)+
        move.l $14,(a0)+
        lea BErrbus(pc),a0
        move.l a0,$8
        lea BErradr(pc),a0
        move.l a0,$c
        lea BCritic(pc),a0
        move.l a0,$404
        lea BIllins(pc),a0
        move.l a0,$10
        lea BDbyzer(pc),a0
        move.l a0,$14
; Init inter trappes
        moveq #30,d0
        lea interflg(a5),a0
        trap #5
        moveq #15,d7
        trap #3
        moveq #7,d0
        trap #7
        move.l adk(a5),a0
        move.w 8(a0),ancdb8(a5)
        move.l $400,anc400(a5)
        lea inter50(pc),a0
        move.l a5,2(a0)                 ;LOKE l'adresse de la table
        move.l a0,$400

; Initialise les extensions
	move.l BufPar(a5),a6
        lea FinGem(pc),a0
        move.l a0,OEnd(a5)

        move.w #1,FlaGem(a5)
        move.l Debut(a5),a3
        lea OExt(a3),a2
        moveq #26-1,d2
        move.l LoChaine(a5),a0
        move.l LowVar(a5),a1
inb20:  cmp.l (a2),a3
        beq.s inb21
        movem.l d2/a2/a3/a4/a5/a6,-(sp)
        move.l (a2),a2
        clr.w d0
        jsr (a2)
	move.l a2,d1
        movem.l (sp)+,d2/a2/a3/a4/a5/a6
        tst.w d0
        bne BOutMem
	move.l d1,26*4(a2)
inb21:  lea 4(a2),a2
        dbra d2,inb20
        move.l a0,LoChaine(a5)
        move.l a0,HiChaine(a5)

; Fin du programme sous GEM
	move.w #37,-(sp)
	trap #14
	lea 2(sp),sp
	move.l Amb(a5),-(sp)		;Envoie la palette
	move.w #6,-(sp)
	trap #14
	lea 6(sp),sp
	move.l DefLog(a5),a0		;Efface l'ecran
	move.w #32768/8-1,d0
InEc:	clr.l (a0)+
	clr.l (a0)+
	dbra d0,InEc
        bra.w InbF
**********************************************
;-----> Erreurs systeme
BOutMem:move.w #8,d0
	bra.s Berrgo
; Erreur programme
BErrbus:moveq #31,d0
        bra.s Berrgo
BErradr:moveq #32,d0
        bra.s Berrgo
BCritic:rts
BIllins:moveq #82,d0
        bra.s Berrgo
BDbyzer:moveq #46,d0
BErrGo: move.l error(a5),a0
        jmp (a0)
**********************************************
;-----> FAUSSE TRAPPE FLOAT!
FauxFloat:
        cmp.b #$0c,d0         ;Ramene toujours 0
        beq.s FxFl1
        moveq #0,d0
        moveq #0,d1
        rte
FxFl1:  move.b #"0",(a0)      ;Ramene toujours la chaine nulle
        move.b #".",1(a0)
        move.b #"0",2(a0)
        clr.b 3(a0)
	moveq #3,d0
        rte
**********************************************
; ENTREE DES INTERRUPTIONS 50 HERZ
inter50:lea $ffffff,a2
        add.l #1,timer(a2)                ;timer!
        tst.l waitcpt(a2)
        beq.s i5
        subq.l #1,waitcpt(a2)             ;compteur WAIT
; A-T-ON APPUYE SUR UNE TOUCHE?
i5:     move.l adk(a2),a1
        move 8(a1),d1
        cmp.w ancdb8(a2),d1
        beq fi5
; BUFFER PLEIN ???
        addq #4,d1
        cmp 6(a1),d1                  ;buffer PLEIN!
        bne.s i5e
        subq #4,d1
        move.l (a1),a0                ;prend le dernier code
        move.l 0(a0,d1.w),d0
        move.w ancdb8(a2),d1          ;et le met a l'avant dernier
        move.w d1,8(a1)
        move.l d0,0(a0,d1.w)          ;pointe l'avant dernier
        bra.s i5f
; test du CONTRL/C, BIP DES TOUCHES
i5e:    subq #4,d1
        move d1,ancdb8(a2)
        move.l (a1),a0                ;buffer clavier
        move.w 2(a0,d1.w),d0          ;code ASCII de la derniere touche
i5f:    cmp.w #3,d0                   ;CONTRL-C (i5ab)
        bne.s i5a
        bset #7,interflg(a2)              ;provoque un test immediat
        bset #0,interflg(a2)              ;OUI: met le flag
i5a:    tst.b bip(a2)                     ;flag: bruit des touches
        bne.s fi5
        cmp #3,d0
        bne.s i5b
        lea b1(pc),a0
        bra.s i5z
i5b:    cmp #13,d0
        bne.s i5c
        lea b2(pc),a0
        bra.s i5z
i5c:    cmp #32,d0
        bcc.s i5d
        lea b3(pc),a0
        bra.s i5z
i5d:    lea b4(pc),a0
i5z:	sub.l	#23*2,$4a2		; Safe BIOS interrupt call
	move.l	a0,-(sp)
	move.w	#32,-(sp)
	trap 	#14
	addq.l	#6,sp
	add.l	#23*2,$4a2
; fin des interruptions: se rebranche a la routine normale
fi5:    move.l anc400(a2),a0
        jmp (a0)
; BRUIT DES TOUCHES
b1:     dc.b 8,$10,9,$10,10,$10,11,0,12,$10,13,9
        dc.b 0,239,1,0,2,190,3,0,4,159,5,0,6,0,7,$f8,$ff,0
b2:     dc.b 8,$10,9,0,10,0,11,0,12,5,13,9
        dc.b 0,219,1,1,2,0,3,0,4,0,5,0,6,0,7,$fe,$ff,0
b3:     dc.b 8,$10,9,0,10,0,11,0,12,2,13,3
        dc.b 0,119,1,0,2,0,3,0,4,0,5,0,6,0,7,$fe,$ff,0
b4:     dc.b 8,$10,9,0,10,0,13,3,11,$80,12,1
        dc.b 0,80,1,0,2,0,3,0,4,0,5,0,6,0,7,$fe,$ff,0
        even
**********************************************
; RELOGE LES TRAPPES
Reloge: movem.l d0-d3/a0-a3,-(sp)
        move.l a2,a1
        move.l 2(a1),d0     ;distance a la table
        add.l 6(a1),d0
        and.l #$ffffff,d0
        add #$1c,a1         ;pointe le debut du programme
        move.l a1,a2
        move.l a2,d2        ;d2=debut du programme
        add.l d0,a1
        clr.l d0
        tst.l (a1)
        beq.s exec3
        add.l (a1)+,a2      ;pointe la premiere adresse a reloger !!!
        bra.s exec1
exec0:  move.b (a1)+,d0
        beq.s exec3
        cmp.b #1,d0
        beq.s exec2
        add d0,a2           ;pointe dans le prg
exec1:  add.l d2,(a2)       ;change dans le programme
        bra.s exec0
exec2:  add.w #254,a2       ;si 1 saute 254 octets
        bra.s exec0
exec3:  movem.l (sp)+,d0-d3/a0-a3
        rts
**********************************************
*	ROUTINE GESTION DU JOYSTICK
**********************************************
Joy_In	move.l	a1,-(sp)
	lea	Joy_Pos(pc),a1
	move.b	2(a0),(a1)
	move.l	(sp)+,a1
	rts

**********************************************
;       FIN BASIC SOUS GEM
**********************************************
FinGem: move.l Anc400(a5),$400
        moveq #8,d0
        trap #7
        moveq #7,d7
        trap #3
        moveq #31,d0
        trap #5
; Enleve la workstation
        lea OTrp1(pc),a0
        move.l $84,(a0) 
	lea trp1(pc),a0
	move.l a0,$84
        lea trp2(pc),a0
        move.l Work(a5),2(a0)
	move.l contrl(a5),a0
        move.w #101,(a0)
        clr 2(a0)
        clr 6(a0)
        move.w grh(a5),12(a0)
        moveq #$73,d0
        move.l vdipb(a5),d1
        trap #2
        move.l OTrp1(pc),$84
; Remet le click des touches
        move.b #7,$484 
; Restore la routine d'entree du joystick
	move.l	Joy_Ad(pc),d0
	beq.s	.Skip
	move.l	d0,a0
	move.l	Joy_Sav(pc),(a0)
; RETOUR au gem
.Skip   lea dataec+32(pc),a4
        lea adapt+2(pc),a3
        move.l 12(a3),a0      ;table VDI 1
        moveq #$5a/2-1,d0
lv1:    move.w (a4)+,(a0)+
        dbra d0,lv1
        move.l 16(a3),a0      ;table VDI 2
        moveq #$18/2-1,d0
lv2:    move.w (a4)+,(a0)+
        dbra d0,lv2
        move.l 0(a3),a0       ;adresse souris
        move.l (a4)+,(a0)     ;coords de la souris
; Palette / images 
        lea dataec(pc),a4
        move.w modec(a4),-(sp)
        move.l imagec(a4),-(sp)
        move.l imagec(a4),-(sp)
        move.w #5,-(sp)
        trap #14
        add #12,sp
        pea dataec(pc)
        move #6,-(sp)
        trap #14
        addq.l #6,sp
; RETOUR!
        tst.w FlgRun(a5)                ;Est-ce un RUN?
        bne.s PaRt
ErrM1:  move.l SPile(a5),sp
        clr.w -(sp)
        trap #1 
PaRt:   rts
; Fausse trappe 1
trp1:   cmp.b #$48,6(sp)
        beq.s trp2
        cmp.b #$49,6(sp)
        beq.s trp3
        move.l Otrp1(pc),-(sp)
        rts
trp2:   move.l #$ffffffff,d0
        rte
trp3:   clr.l d0
        rte
OTrp1:  dc.l 0
**********************************************
cvdipb: dc.l 0,0,0,0,0
**********************************************
;-----------------------------> Adaptation aux differentes ROMS
adapt   dc.w 	0
	dc.l 	0,0,0,0,0,0,0
Joy_Sav	dc.l	0		; Adresses de gestion du joystick
Joy_Pos	dc.l	0
Joy_Ad	dc.l	0

dataec 	ds.b 	152+4+4
modec	equ 	152
imagec	equ 	156
cursec	dc.b 	27,"f",0
        even
; BUFFER DES TOUCHES DE FONCTIONS
bf:     ds.b 40*20
        ds.b 64                      ;buffer pour PUT KEY
;TOUCHES DE FONCTION PAR DEFAUT
df:     dc.b " ",0             ;0
        dc.b "list ",0         ;1
        dc.b "listbank`",0     ;2
        dc.b "fload",34,"*.bas",34,"`",0   ;3
        dc.b "fsave",34,"*.bas",34,"`",0   ;4
        dc.b "run`",0          ;5
        dc.b "dir`",0      ;6
        dc.b "dir$= dir$ + ",34,"\`",0      ;7
        dc.b "previous`",0                 ;8
        dc.b "off`",0      ;9
        dc.b "full`",0        ;10
        dc.b "multi 2`",0      ;11
        dc.b "multi 3`",0      ;12
        dc.b "multi 4`",0      ;13
        dc.b "mode 0`",0       ;14
        dc.b "mode 1`",0       ;15
        dc.b "accnew:accload",34,"*",34,"`",0 ;16
        dc.b "default`",0      ;17
        dc.b "env`",0          ;18
        dc.b "key list`",0     ;19
; AFFICHAGE DES TOUCHES DE FONCTION: NOMS
fn:     dc.b "f1: ",0,"f2: ",0,"f3: ",0,"f4: ",0,"f5: ",0
        dc.b "f6: ",0,"f7: ",0,"f8: ",0,"f9: ",0,"f10:",0
        dc.b "f11:",0,"f12:",0,"f13:",0,"f14:",0,"f15:",0
        dc.b "f16:",0,"f17:",0,"f18:",0,"f19:",0,"f20:",0
        even
**********************************************
; Fin de la sequence de code
inbF:




*************************************************************************
*       ROUTINES COMPILATEUR

Hande:  dc.w 0

;-----> Converti et imprime un mot hexa D0
AffWord:movem.l d0-d7/a0-a6,-(sp)
        swap d0
        move.l d0,d7
        moveq #3,d6
        bra.s Al0
;-----> Converti et imprime un mot long hexa D0
AffLong:movem.l d0-d7/a0-a6,-(sp)
        move.l d0,d7
        moveq #7,d6
Al0:    
Al1:    rol.l #4,d7
        move.b d7,d0
        and.w #$f,d0
        cmp.b #10,d0
        bcs.s Al2
        add.b #7,d0
Al2:    add.b #48,d0
        move.w d0,-(sp)
        move.w #2,-(sp)
        move.w #3,-(sp)
        trap #13
        addq.l #6,sp
        dbra d6,Al1
        move.w #32,-(sp)
        move.w #2,-(sp)
        move.w #3,-(sp)
        trap #13
        addq.l #6,sp
        movem.l (sp)+,d0-d7/a0-a6
        rts

AffRet: movem.l d0-d7/a0-a6,-(sp)
        move.w #13,-(sp)
        move.w #2,-(sp)
        move.w #3,-(sp)
        trap #13
        addq.l #6,sp
        move.w #10,-(sp)
        move.w #2,-(sp)
        move.w #3,-(sp)
        trap #13
        addq.l #6,sp
        movem.l (sp)+,d0-d7/a0-a6
        rts

WaitKey:movem.l d1-d7/a0-a6,-(sp)
        move.w #2,-(sp)
        move.w #2,-(sp)
        trap #13
        addq.l #4,sp
        cmp.b #27,d0
        beq CSynt
        movem.l (sp)+,d1-d7/a0-a6
        rts

; Print
Print:  move.l a0,-(sp)
        move.w #$09,-(sp)
        trap #1
        addq.l #6,sp
        rts

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | GESTION DU DISQUE               |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------

;-------------------------> Gestion des 30 fichiers ouverts!
Poignee:        equ 0
Longfyche:      equ 2
Posfyche:       equ 6
TFyche:         equ 10
Nfyche:         equ 32
Datafyche:      dc.l 0

;-----> Set Dta
SetDta: pea Cdta
        move.w #$1a,-(sp)
        trap #1     
        addq.l #6,sp
        rts

;-----> Initialisation disque
RazDisk:bsr SetDta
        move.l Datafyche(pc),a0
        moveq #Nfyche-1,d0
Rzd0:   moveq #TFyche-1,d1
Rzd1:   clr.b (a0)+
        dbra d1,Rzd1
        dbra d0,Rzd0
        rts

;-----> Ramene la fyche en fonction de D7
GetFich:move.w d7,-(sp)
        mulu #TFyche,d7
        move.l Datafyche(pc),a3
        add.w d7,a3
        move.w (sp)+,d7
        rts

;-----> SFirst / Copie le nom 
;       D7= # de la fyche
SFirst: move.w #$00,-(sp)
        move.l a0,-(sp)
        move.w #$4e,-(sp)
        trap #1
        addq.l #8,sp
SF:     tst.w d0
        bne.s PaLa
        lea CDta(pc),a1
        move.l 26(a1),d0
        lea 30(a1),a1
        lea BufDisk(pc),a0
SF1:    move.b (a1)+,(a0)+
        bne.s SF1
        clr.w d1
Pala:   rts

; SNext
SNext:  move.w #$4f,-(sp)
        trap #1
        addq.l #2,sp
        bra.s SF

;-----> Open /  FAIRE UN SFIRST AVANT!
Open:   lea nomdisk(pc),a0
Open2:  clr.w -(sp)
        move.l a0,-(sp)
        move.w #$3d,-(sp)
        trap #1                         ;OPEN
        addq.l #8,sp
        tst.w d0
        bmi DErr
        move.l a3,-(sp)
        bsr GetFich
        move.w d0,Poignee(a3)           ;Ouvre la fyche
        move.l CDta+26(pc),d0
        move.l d0,Longfyche(a3)
        clr.l Posfyche(a3)
        move.l (sp)+,a3
        rts

;-----> Create 
Create: lea nomdisk(pc),a0
Create2:clr.w -(sp)
        move.l a0,-(sp)
        move.w #$3c,-(sp)
        trap #1                    ;OPEN
        addq.l #8,sp
        tst.w d0
        bmi DErr
        move.l a3,-(sp)
        bsr GetFich
        move.w d0,Poignee(a3)
        clr.l Longfyche(a3)
        clr.l Posfyche(a3)
        move.l (sp)+,a3
        rts

;-----> LSeek
LSeek:  move.l a3,-(sp)
        bsr GetFich
        sub.l Longfyche(a3),d0
        move.w #2,-(sp)
        move.w (a3),-(sp)
        beq DErr
        move.l d0,-(sp)
        move.w #$42,-(sp)
        trap #1
        lea 10(sp),sp
        tst.l d0
        bmi DErr
        move.l d0,Posfyche(a3)
        move.l (sp)+,a3
        rts
       
;-----> Load
Load:   move.l a3,-(sp)
        bsr GetFich
        move.l a0,-(sp)                 ;adresse de chargement
        move.l d0,-(sp)                 ;taille du fichier!
        move.w (a3),-(sp)
        beq DErr
        move.w #$3f,-(sp)
        trap #1
        lea 4(sp),sp
        cmp.l (sp)+,d0
        bne DErr
        add.l d0,Posfyche(a3)           ;Change la position du pointeur
        move.l (sp)+,a0
        add.l d0,a0
        move.l (sp)+,a3
        rts

;-----> Write
Write:  move.l a3,-(sp)
        bsr GetFich
        move.l a0,-(sp)                 ;adresse de sauvegarde
        move.l d0,-(sp)                 ;taille du fichier!
        move.w (a3),-(sp)
        beq DErr
        move.w #$40,-(sp)
        trap #1
        lea 4(sp),sp
        cmp.l (sp)+,d0
        bne DErr
        add.l d0,Posfyche(a3)           ;Position du pointeur
        move.l Posfyche(a3),d0
        cmp.l Longfyche(a3),d0          ;Augmente la taille de la fyche 
        bcs.s Writ1
        move.l d0,Longfyche(a3)
Writ1:  addq.l #4,sp
        move.l (sp)+,a3
        rts

;-----> Ferme un seul fichier
Clofyche:
        bsr GetFich
        tst.w (a3)
        beq.s Clf
        move.w (a3),-(sp)
        move.w #$3e,-(sp)
        trap #1
        addq.l #4,sp
Clf:    rts

;-----> Close: ferme TOUS les fichiers
Close:  moveq #0,d7
Clo1:   bsr GetFich
        tst.w (a3)
        beq.s Clo2
        move.w (a3),-(sp)
        move.w #$3e,-(sp)
        trap #1 
        addq.l #4,sp
Clo2:   addq.w #1,d7
        cmp.w #Nfyche,d7
        bcs.s Clo1
        rts

DErr:   bra DiskErr

****************************************************************************
*
*       INSTRUCTIONS / FONCTIONS
*
****************************************************************************

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | VARIABLES / EXPRESSIONS         |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------

;-----> Instruction LET
CLLet:  bsr GetByte
        cmp.b #$fa,d0           ;Veut une variable
        bne CSynt

;-----> Entree directe
CLet:   bsr Test0		;Teste les interruptions!
	bsr Vari                ;Cree la variable
        move.w d2,-(sp)
        move.l a1,-(sp)
        move.l a0,-(sp) 
        bsr GetByte
        cmp.b #$f1,d0
        bne CSynt
        bsr Evalue              ;Va evaluer
        tst.w Parenth
        bne CSynt
        and.w #$c0,d2
        move.w 8(sp),d1
        bsr EqType
        bne CType
; Egalise la variable
Let3:   move.l (sp)+,a0
        move.l (sp)+,a1
        move.w (sp)+,d2
        move.l a0,-(sp)
        bsr VarAd               ;Cree le LEA VarAd,a0
        and.b #$c0,d2
        beq.s Let4
        bmi.s Let4
        move.w #1,floflag
        lea Let6,a0
        bsr Code0
        move.l (sp)+,a0
        rts
Let4:   lea Let5,a0
        bsr Code0
        move.l (sp)+,a0
        rts
; Chargement variable ENTIERE / ALPHANUMERIQUE
Let5:   move.l (a6)+,(a0)
        dc.w 0
; Chargement variable FLOAT
Let6:   move.l (a6)+,4(a0)
        move.l (a6)+,(a0)
        dc.w 0

;-----> Prend le contenu d'une variable
Var:    bsr Vari                ;Va chercher l'adresse
        bsr VarAd               ;Poke dans le code
        and.b #$c0,d2           ;Enleve les autres flags
        beq.s VarCE
        bmi.s VarCE
; Variable FLOAT
        move.w #1,FloFlag
        lea VarCF,a0
        bra Code0
VarCF:  move.l (a0)+,-(a6)
        move.l (a0),-(a6)
        dc.w 0
; Variable CHAINE / ENTIERE
VarCE:  lea VarCC,a0
        bra Code0
VarCC:  move.l (a0),-(a6)
        dc.w 0

;-----> DIM
CDim:   bsr GetByte
        cmp.b #$fa,d0           ;Veut une variable
        bne CSynt
        bsr Vari                ;Va chercher la variable
; Si revient: elle etait deja dimensionnee
RetDim: moveq #28,d0             ;Erreur: deja dimensionne!
        bra CError

;-----> Veritable entree de DIM
EntDim: cmp.l #RetDim,(sp)      ;Vient de DIM???
        addq.l #4,sp
        beq.s CDi1              ;OUI! continue!
; Variable non dimensionnee
        moveq #18,d0
        bra CError
; Va chercher le nombre de dimension
CDi1:   bset #4,d1              ;Flag nettoyage!
        move.l a0,-(sp)
        move.w d1,-(sp)
        lea ParEnt,a2           ;Va chercher les parametres     
        bsr ParFonc
; Poke le nombre de dimensions dans la table et dans le source
        move.w (sp)+,d2
        move.l (sp),a0
        move.b d0,1(a0)
        lea cddim,a0
        subq.w #1,d0            ;Nb de dimensions -1!
        move.b d0,1(a0)
        moveq #2,d1
        move.b d2,d0
        and.b #$c0,d0
        move.b d0,5(a0)         ;Flag de la variable
        beq.s Vt8
        bmi.s Vt8
        moveq #3,d1 
Vt8:    move.b d1,3(a0)         ;Nombre de shifts
        bsr Code0
; Poke le LEA
        move.l (sp)+,a0
        bsr ReV0
; Installe la routine
        move.w #SetDim,d0
        bsr CreFonc
;---> Encore une variable?
        bsr GetByte
        cmp.b #",",d0
        beq CDim
        subq.l #1,a6
        rts
CdDim:  moveq #0,d0             ;Nb Dim-1
        moveq #0,d1             ;Nb shifts
        moveq #0,d2             ;Flag
        dc.w $0

;-----> Gestion des adresses des variables
PreVari:bsr GetByte
        cmp.b #$fa,d0
        bne CSynt
Vari:   bsr Pair
        bsr GetByte             ;Prend le flag
        move.b d0,d1    
        addq.l #3,a6            ;Pointe le nom
; Copie la variable dans un buffer et saute le nom
        lea BufVar,a0 
        move.b d1,d2
        and.w #$1f,d2
        subq.w #1,d2
Va0:    bsr GetByte
        move.b d0,(a0)+
        dbra d2,Va0
        move.l LoVar,a0         ;Adresse des variables
; Explore la table des variables
Va1:    move.l a0,a1
        move.b (a1)+,d2         ;Fin de la table = zero
        beq.s Va5
        cmp.b d1,d2             ;Pas le meme flag?
        bne.s Va3
        addq.l #3,a1            ;Saute le flag
        lea BufVar,a2
        and.w #$1f,d2
        subq.w #1,d2
Va2:    cmpm.b (a1)+,(a2)+
        bne.s Va3
        dbra d2,Va2
        bra.w VaT
Va3:    add.w 2(a0),a0          ;Pointe la variable suivante
        bra.s Va1
; Stocke la variable, en DESCENDANT vers l'objet
Va5:    move.l LoVar,a1
        lea -4(a1),a0
        move.b d1,d2
        and.w #$1f,d2
        sub.w d2,a0
        move.w a0,d0
        btst #0,d0
        beq.s Va6
        subq.l #1,a0
Va6:    cmp.l BotVar,a0         ;Ne descend pas trop bas?
        bcs COut
        move.l a0,LoVar
        move.b d1,(a0)          ;Flag
        clr.b 1(a0)
        sub.l a0,a1
        move.w a1,2(a0)         ;Distance a la suivante
        addq.l #4,a0
        subq.w #1,d2
        lea BufVar,a2
Va7:    move.b (a2)+,(a0)+      ;Recopie le nom
        dbra d2,Va7
        move.l LoVar,a0         ;Adresse de la variable
        bset #4,d1              ;Flag CLEAR
        move.b d1,d0
        and.b #$c0,d0
        bpl.s Va7a
        add.l #4,AdString       ;Taille de la table Ad variables alpha
Va7a:   btst #6,d1              ;Variable FLOAT?
        beq.s Va7b
        move.w #1,FloFlag       ;Met le FLOAT!
Va7b:   btst #5,d1
        bne EntDim
;---> Variable trouvee!
VaT:    move.b d1,d2            ;Ramene le flag en D2 / A0=adresse
        and.b #$F0,d2           ;Garde le flag tableau / flag clear
        btst #5,d2
        bne.s VaT0
        rts
;---> Variable tableau: saute la parenthese
VaT0:   move.l a6,a1            ;CHRGET au debut de la ( )
        movem.l a0/a1/d2,-(sp)
        movem.l a4/a5,-(sp)
        move.l OldRel,-(sp)
        lea ParEnt,a2
        bsr ParFonc
        move.l (sp)+,OldRel
        movem.l (sp)+,a4/a5
        movem.l (sp)+,a0/a1/d2
        cmp.b 1(a0),d0          ;Est-ce le bon nombre de dimensions?
        bne CSynt
        rts

;-----> Code prend adresse variable: LEA VARAD,A0
VarAd:  btst #5,d2
        bne.s ReT
; Variable simple ...
ReV0:   move.w CLeaA0,d0        ;Code: LEA adresse variable,a0
        bsr OutWord
; Change la table de relocation 
        move.l a5,d0
        sub.l OldRel,d0
ReV1:   cmp.w #126,d0
        bls.s ReV2
        bsr OutRel1             ;>126: met 1 et boucle
        sub.w #126,d0
        bra.s ReV1
ReV2:   bset #7,d0              ;Flag #7=1 ---> VARIABLE
        bsr OutRel
        move.b d2,d0
        bsr OutRel              ;Poke le flag
        move.l a5,OldRel
        move.l a0,d0
        bsr OutLong
        rts
; Variable TABLEAU
ReT:    move.l a6,-(sp)
        move.l a1,a6            ;Adresse du debut ( , , )
        movem.l a0/d2,-(sp)
        lea ParEnt,a2
        bsr ParFonc
        movem.l (sp)+,a0/d2
        cmp.b 1(a0),d0          ;Meme nombre de dimensions?
        bne CSynt
        move.l (sp)+,a6         ;Repointe au bon endroit
        bsr ReV0                ;Poke le LEA
        move.w #GetDim,d0       ;Trouve l'adresse
        bra CreFonc

;----------------------------------> EXPRESSIONS

;-----> Empile les parametres d'une instruction
;       A2 pointe sur la table de d‚finition des parametres
ParInst:
        move.l a2,-(sp)         ;Definitions des formats
        movem.l a4-a6,-(a3)     ;Stocke les parametres
        move.l OldRel,-(a3)
        lea -32(a3),a3          ;Stocke la definition dans la pile
        move.l a3,a2            ;Debut du format
; Recupere les parametres / stocke le format
Ins1:   move.l a2,-(sp)
        bsr Evalue
        move.l (sp)+,a2
        and.b #$c0,d2
        move.b d2,(a2)+         ;Stocke le type
        tst.w Parenth
        bne CSynt
        bsr GetByte          
        tst.b d0
        beq.s Ins2
        cmp.b #":",d0
        beq.s Ins2
        cmp.b #$9b,d0           ;Else
        beq.s Ins2
        move.b d0,(a2)+         ;Stocke le separateur
        bra.s Ins1
Ins2:   move.b #1,(a2)+
        subq.l #1,a6            ;Reste sur le separateur
; Trouve la bonne chaine
        lea 32(a3),a3           ;Remet la pile
        move.l (sp)+,a2         ;Debut de la definition
        moveq #0,d4             ;Numero du format
Ins3:   lea -32(a3),a1          ;Debut du format trouve
        move.l a2,a0            ;Debut du format definition
        clr.w d0                ;Flag "PRESQUE CA"
        addq.w #1,d4
Ins4:   move.b (a0)+,d1         ;Prend le parametre DEFINITION
        move.b (a1)+,d2         ;Prend le parametre TROUVE
        cmp.b d1,d2
        bne.s Ins5
Ins0:   move.b (a0)+,d1         ;Compare les separateurs
        move.b (a1)+,d2
        cmp.b d1,d2             ;Les separateurs doivent etre le mm
        bne.s Ins6
        cmp.b #1,d1             ;Trouve?
        bne.s Ins4
        beq.s Ins7
Ins5:   cmp.b #1,d1             ;Un des 2 est a la fin
        beq.s Ins6
        cmp.b #1,d2
        beq.s Ins6
        tst.b d1                ;Type mismatch?
        bmi.s Ins6
        tst.b d2
        bmi.s Ins6
        addq.l #1,d0            ;Flag "PRESQUE CA"
        bra.s Ins0
Ins6:   cmp.b #1,(a2)+          ;Definition suivante: cherche la fin
        bne.s Ins6
        cmp.b #1,(a2)           ;C'est le dernier!
        bne.s Ins3
; Rate! aucun ne va
        bra CSynt
; On a trouve une chaine
Ins7:   tst.w d0                ;Des conversion FL/INT a faire?
        bne.s InsR              ;Non---> c'est fini!
        lea 16(a3),a3           ;Restore la pile
        move.w d4,d0            ;Met les flags
        rts
; Il faut recommencer l'evaluation en adaptant les formats
InsR:   move.w d4,-(sp)
        move.l (a3)+,OldRel     ;Restore tous les registres
        movem.l (a3)+,a4-a6
Ins8:   move.l a2,-(sp)
        bsr Evalue
        move.l (sp)+,a2
        move.b (a2)+,d1
        bsr EqType
        addq.l #1,a6
        cmp.b #1,(a2)+
        bne.s Ins8
        subq.l #1,a6            ;Reste sur le separateur
        move.w (sp)+,d0
        rts

;-----> Empile les parametres d'une fonction
;       A2 pointe sur la table de d‚finition des parametres
ParFonc:
        move.w Parenth,-(sp)
        bsr GetByte
        cmp.b #"(",d0
        bne CSynt
        move.l a2,-(sp)         ;Definitions des formats
        movem.l a4-a6,-(a3)     ;Stocke les parametres
        move.l OldRel,-(a3)
        lea -32(a3),a3          ;Stocke la definition dans la pile
        move.l a3,a2            ;Debut du format
; Recupere les parametres / stocke le format
Fnc1:   move.l a2,-(sp)
        bsr Evalue
        move.l (sp)+,a2
        and.b #$c0,d2
        move.b d2,(a2)+         ;Stocke le type
        cmp.w #-1,Parenth
        beq.s Fnc2
        tst.w Parenth
        bne CSynt
        bsr GetByte
        move.b d0,(a2)+         ;Stocke le separateur
        bra.s Fnc1
Fnc2:   move.b #1,(a2)+
; Trouve la bonne chaine
        lea 32(a3),a3           ;Remet la pile
        move.l (sp)+,a2         ;Debut de la definition
        moveq #0,d4             ;Numero du format
Fnc3:   lea -32(a3),a1          ;Debut du format trouve
        move.l a2,a0            ;Debut du format definition
        clr.w d0                ;Flag "PRESQUE CA"
        addq.w #1,d4
Fnc4:   move.b (a0)+,d1         ;Prend le parametre DEFINITION
        move.b (a1)+,d2         ;Prend le parametre TROUVE
        cmp.b d1,d2
        bne.s Fnc5
Fnc0:   move.b (a0)+,d1         ;Compare les separateurs
        move.b (a1)+,d2
        cmp.b d1,d2
        bne.s Fnc6
        cmp.b #1,d1             ;Trouve?
        bne.s Fnc4
        beq.s Fnc7
Fnc5:   cmp.b #1,d1             ;Un des 2 est a la fin
        beq.s Fnc6
        cmp.b #1,d2
        beq.s Fnc6
        tst.b d1                ;Type mismatch?
        bmi.s Fnc6
        tst.b d2
        bmi.s Fnc6
        addq.l #1,d0            ;Flag "PRESQUE CA"
        bra.s Fnc0
Fnc6:   cmp.b #1,(a2)+          ;Definition suivante: cherche la fin
        bne.s Fnc6
        cmp.b #1,(a2)           ;C'est le dernier!
        bne.s Fnc3
; Rate! aucun ne va
        bra CSynt
; On a trouve une chaine
Fnc7:   tst.w d0                ;Des conversion FL/INT a faire?
        bne.s FncR              ;Non---> c'est fini!
        lea 16(a3),a3           ;Restore la pile
        move.w (sp)+,Parenth    ;Niveau de parentheses
        move.w d4,d0            ;Met les flags
        rts
; Il faut recommencer l'evaluation en adaptant les formats
FncR:   move.w d4,-(sp)
        move.l (a3)+,OldRel     ;Restore tous les registres
        movem.l (a3)+,a4-a6
Fnc8:   move.l a2,-(sp)
        bsr Evalue
        move.l (sp)+,a2
        move.b (a2)+,d1
        bsr EqType
        cmp.b #1,(a2)+
        beq.s Fnc9
        addq.l #1,a6
        bra.s Fnc8
Fnc9:   move.w (sp)+,d0
        move.w (sp)+,Parenth
        rts

;-----> Evaluation d'une expression
Evalue: clr Parenth
; Entree recursive
EvalBis:move.w #Debop,d0        ;Signal de fin
        bra.s Ev1
Ev0:    move.w d2,-(a3)
Ev1:    move.w d0,-(a3)
        bsr Operand
Ev2:    bsr GetByte             ;Prend l'operateur
        and.w #$ff,d0
        cmp.w (a3),d0
        bhi.s Ev0

        subq.l #1,a6            ;Reste sur le meme pointeur
        move.w (a3)+,d1         ;Depile l'operateur
        sub.w #Debop,d1
        beq.s EvFin
        lsl.w #2,d1
        lea OpJumps,a0
        move.l 0(a0,d1.w),a0
        move.w (a3)+,d5         ;Depile le 1er operande
        jsr (a0)                ;Effectue l'operateur
        bra.s Ev2

EvFin:  cmp.b #")",d0           ;Fermeture d'une parenthese?
        bne.s Ev3
        sub.w #1,Parenth
        bsr GetByte
Ev3:    rts

;-----> Prend un operande
Operand:clr.w -(sp)             ;Pas de signe moins devant
Op0:    bsr GetByte
        beq CSynt
        bpl.s Op3
        cmp.b #$F5,d0           ;Signe moins?
        beq.s Op2
        and.w #$ff,d0
        sub.w #DebFonc,d0
        bcs CSynt
	add.w #1,CptInst
        lsl.w #2,d0             ;Appelle la routine
        lea FnJumps,a0
        move.l 0(a0,d0.w),a0
        jsr (a0)
; Changement de signe?
Op1:    move.w (sp)+,d0         ;Ressort le signe
        bne.s Cs5
        rts
Cs5:    tst.b d2
        beq.s Cs3
        bmi CSynt
; Changement de signe float
        lea Cs2,a0         
        bra Code0
Cs2:    move.l (a6)+,d4
	move.l (a6)+,d3
	move.w #$ff00,d0
	trap #6
	move.l d3,-(a6)
	move.l d4,-(a6)
        dc.w 0
; Changement de signe entier
Cs3:    lea Cs4,a0
        bra Code0
Cs4:    neg.l (a6)
        dc.w 0
; Signe moins
Op2:    tst.w (sp)
        bne CSynt
        move.w #1,(sp)
        bra.s Op0
; Parenthese?
Op3:    cmp.b #"(",d0
        bne CSynt
        add.w #1,Parenth
        bsr EvalBis
        bra Op1

;-----> Egalise le type du resultat (D2/(A6))
;       au type demande D1      
EqType: movem.w d1-d2,-(sp)
        and.b #$c0,d1
        and.b #$c0,d2
        cmp.b d1,d2             ;Compare les flags
        beq.s Eqt3
        tst.b d1                ;Une des deux alphanumerique?
        bmi.s Eqt4
        tst.b d2
        bmi.s Eqt4
        tst.b d1                ;Fait la conversion
        beq.s Eqt1
        move.w #1,FloFlag
        moveq #IntToFl,d0       ;JSR IntToFl
        move.b #$40,d2
        bra.s Eqt2
Eqt1:   move.w #1,FloFlag
        moveq #FlToInt,d0       ;JSR FlToInt
        clr.b d2
Eqt2:   bsr CreFonc
Eqt3:   movem.w (sp)+,d1-d2     ;Retour: 0= OK
        moveq #0,d0
        rts
Eqt4:   movem.w (sp)+,d1-d2     ;1= Type mismatch
        moveq #1,d0
        rts

;-----> Prend une constante ENTIERE
CEnt:   move.w CMvima6,d0
        bsr OutWord
        bsr Pair
        bsr GetLong
        bsr OutLong
        clr.b d2
        rts

;-----> Prend une constante FLOAT
CFlo:   move.w #1,FloFlag
        bsr Pair
        move.w Cmvima6,d0
        bsr OutWord
        bsr GetLong
        bsr OutLong
        move.w Cmvima6,d0
        bsr OutWord
        bsr GetLong
        bsr OutLong
        move.b #$40,d2
        rts

;-----> Prend une constante CHAINE
CChai:  bsr Pair
        move.w Cmvima6,d0       ;Adresse de la constante ---> -(A6)
        bsr OutWord
        bsr RelJsr              ;Poke la table de relocation
        move.l AdChai,a0
        move.l a0,d0            ;Adresse dans la table AdChaines
        or.l #$80000000,d0      ;Marque qu'il s'agit d'une constante!
        bsr OutLong
        tst.w Passe
        beq.s CCh1
        move.l a6,(a0)+         ;NON: loke l'adresse dans le source
        clr.l (a0)              ;Fin des constantes
        move.l a0,AdChai
        addq.l #2,a6
        bsr GetWord
        add.w d0,a6             ;Saute la constante
        move.b #$80,d2          ;Chaine
        rts
CCh1:   addq.l #4,a0            ;Ne poke pas si passe 0
        move.l a0,AdChai
        moveq #0,d0
        addq.l #2,a6
        bsr GetWord             ;Compte la longueur des constantes
        add.w d0,a6
        add.l d0,LongChai
        add.l #2,LongChai
        move.b #$80,d2
        rts

;-----> Meme type d'operande (FLOAT si <>)
Compat: cmp.b d2,d5
        bne.s QueFloat
        tst.b d2
        rts

;-----> Que des floats
Quefloat:
        move.w #1,FloFlag
        tst.b d2                ;Change le 2eme en FLOAT
        bmi CType
        bne.s Qf1
        moveq #IntToFl,d0
        bsr CreFonc
        move.w #$40,d2
Qf1:    tst.b d5                ;Change le 1er en FLOAT
        bmi CType
        bne.s Qf2
        lea Qf3,a0              ;depile le 2eme
        bsr Code0
        moveq #IntToFl,d0       ;Change
        bsr CreFonc
        lea Qf4,a0              ;rempile
        bsr Code0
        move.b #$40,d5
Qf2:    rts
Qf3:    move.l (a6)+,d5
        move.l (a6)+,d4
        dc.w 0
Qf4:    move.l d4,-(a6)
        move.l d5,-(a6)
        dc.w 0

;-----> Que des entiers
Quentier:
        tst.b d2
        beq.s Qe1
        bmi CType
        move.w #1,FloFlag
        moveq #FlToInt,d0
        bsr CreFonc
        clr.b d2
Qe1:    tst.b d5
        beq.s Qe2
        bmi CType
        lea Qe3,a0
        bsr Code0
        move.w #1,FloFlag
        moveq #FlToInt,d0
        bsr CreFonc
        clr.b d5
        lea Qe4,a0
        bsr Code0
Qe2:    rts
Qe3:    move.l (a6)+,d4
        dc.w 0
Qe4:    move.l d4,-(a6)
        dc.w 0

;-----> Expression ALPHANUMERIQUE seulement
ExpAlpha:
        bsr Evalue
        tst.w Parenth
        bne CSynt
        tst.b d2
        bpl CType
        rts

;-----> Expression ENTIERE seulement
ExpEntier:
        bsr Evalue
        tst.w Parenth
        bne CSynt
        tst.b d2
        bmi CType
        beq.s Exe
        clr.b d2
        move.w #1,FloFlag
        moveq #FlToInt,d0
        bsr CreFonc
Exe:    rts

;-----> CONSTANTE? D1=1 oui (D0=const) (pour GOTO / GOSUB ...)
Constant:
        bsr GetByte
        subq.l #1,a6
        cmp.b #$fe,d0
        bne.s Cst2
; Ca commence bien!
        movem.l a4-a6,-(sp)
        move.l OldRel,-(sp)
        move.l a6,d2
        addq.l #1,a6
        bsr Pair                        ;Saute la constante
        addq.l #4,a6
        move.l a6,-(sp)
        move.l d2,a6                    ;Repointe la constante
        bsr ExpEntier                   ;Va evaluer
        cmp.l (sp)+,a6                  ;Pointe au meme endroit
        bne.s Cst1
; C'est une constante!
        move.l (sp)+,OldRel             ;Repointe au debut
        movem.l (sp)+,a4-a6
        addq.l #1,a6
        bsr Pair
        bsr GetLong
        move.l d0,d1                    ;Ramene la constante
        moveq #1,d0
        rts
; C'est pas une constante!
Cst1:   move.l (sp)+,OldRel
        movem.l (sp)+,a4-a6
; Evalue l'expression
Cst2:   bsr ExpEntier
        moveq #0,d0
        rts

;-----> Fonction UN param FLOAT seulement
Flop:   dc.b fl,1,1,0
FFlo:   lea Flop,a2
        bra ParFonc

;-----> Fonction UN param ENTIER seulement
Flep:   dc.b en,1,1,0
FEnt:   lea Flep,a2
        bra ParFonc

;-----> Fonction UN param CHAINE seulement
Flap:   dc.b ch,1,1,0
FChai:  lea FLap,a2
        bra ParFonc

;-----> Fonction UN param CHIFFRE seulement BEQ-> entier / BNE-> FLOAT
FArg:   bsr GetByte
        cmp.b #"(",d0
        bne CSynt
        move.w Parenth,-(sp)
        bsr Evalue
        cmp.w #-1,Parenth
        bne CSynt
        move.w (sp)+,Parenth
        tst.b d2
        bmi CType
        rts


;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | CALCULS / FONCTION MATHEMATIQUE |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------

;-----> TRUE
CVrai:  lea ctru(pc),a0
        bsr Code0
        clr.b d2
        rts
;-----> FALSE
CFaux:  lea cfal(pc),a0
        bsr code0
        clr.b d2
        rts
ctru:   move.l #$ffffffff,-(a6)
        dc.w 0
cfal:   clr.l -(a6)
        dc.w 0

;-----> DEF FN
CDef:   bsr GetByte
        cmp.b #$c9,d0
        beq.s df0
        cmp.b #$a0,d0                 ;Cherche un defscroll
        bne CSynt
        bsr GetByte
        cmp.b #$f9,d0
        beq CDSc
        bne csynt
df0:    move.w cbra,d0
        bsr OutWord
        move.l a5,-(sp)
        clr.w d0
        bsr OutWord
        bsr GetByte
        cmp.b #$fa,d0
        bne CSynt
        bsr Vari
        and.b #$c0,d2
        bne CSynt
; Recupere les adresses des variables
        move.l ADefn,a2                 ;Table des Deffn
        move.l a0,(a2)+                 ;Adresse de la variable
        move.l a5,(a2)+                 ;Adresse dans l'objet
        clr.w (a2)+
        bsr GetByte
        subq.l #1,a6
        cmp.b #"(",d0
        bne.s Df2
        addq.l #1,a6
Df1:    bsr GetByte
        cmp.b #$fa,d0                   ;Veut une variable
        bne CSynt
        move.l a2,-(sp)
        bsr Vari
        bsr VarAd
        lea CdDf,a0
        bsr Code0
        and.w #$c0,d2
        bset #15,d2
        move.l (sp)+,a2                 ;Stocke le flag
        move.w d2,(a2)+
        bsr GetByte
        cmp.b #",",d0
        beq.s Df1
        cmp.b #")",d0
        bne CSynt
Df2:    bsr GetByte
        cmp.b #$f1,d0                   ;EGAL?
        bne CSynt
        clr.w (a2)+
        clr.l (a2)                      ;Signale la fin!
        cmp.l LoVar,a2
        bcc COut
        move.l a2,-(sp)
; Evalue l'expression
        bsr evalue
        tst.w parenth
        bne CSynt
        move.w CRts,d0
        bsr OutWord
; Poke le type de l'expression / remonte BotVar
        move.l ADefn,a2
        move.w d2,8(a2)
        move.l (sp)+,d0
        move.l d0,ADefn
        addq.l #4,d0
        move.l d0,BotVar
; Reloge le BRA
        move.l (sp)+,d0
        move.l a5,-(sp)
        sub.l d0,a5
        exg d0,a5
        bsr OutWord
        move.l (sp)+,a5
        rts
Cddf:   lea cddf1(pc),a2
        rts
Cddf1:  dc.w 0

;-----> FNxxxc (skjk,qslmdjqs)
CFn:    move.w Parenth,-(sp)
        bsr GetByte
        cmp.b #$fa,d0
        bne CSynt
        bsr Vari
        move.l AdADefn,a2
CFn1:   tst.l (a2)              ;Cherche dans la table
        beq CFn9
        cmp.l (a2)+,a0
        beq.s CFn3      
        addq.l #6,a2            ;Adresse / flag
CFn2:   tst.w (a2)+
        bne.s CFn2
        bra.s CFn1
CFn3:   move.w cleaa2,d0        ;LEA adresse,a2
        bsr outWord             ;MOVE.L A2,-(SP)
        bsr reljsr
        move.l (a2)+,d0
        sub.l Objet,d0
        bset #30,d0
        bsr outlong
        lea cdfn1,a0
        bsr Code0
        move.w (a2)+,-(sp)      ;Pousse le flag de l'expression
; Prend les expressions/egalise
        bsr GetByte
        subq.l #1,a6
        cmp.b #"(",d0
        bne.s CFn5
        addq.l #1,a6
CFn4:   move.l a2,-(sp)
        bsr Evalue
        and.w #$c0,d2
        move.l (sp)+,a2
        move.w (a2)+,d1
        beq.s CFn8
        and.w #$c0,d1
        bsr eqtype      
        bne CType
        lea cdfn2,a0
        bsr Code0
        lea Let5,a0
        tst.b d1
        beq.s Cfn4a
        bmi.s CFn4a
        lea Let6,a0
CFn4a:  bsr Code0
        cmp.w #-1,parenth
        beq.s CFn5
        tst.w Parenth
        bne CSynt
        bsr GetByte
        cmp.b #",",d0
        beq.s CFn4
        bra CSynt
; Fini
CFn5:   tst.w (a2)
        bne.s CFn8
        lea cdfn3,a0                    ;Appelle l'expression
        bsr Code0
        move.w (sp)+,d2                 ;Flag de l'expression
        move.w (sp)+,Parenth
        rts
cdfn1:  move.l a2,-(sp)
        dc.w 0
cdfn2:  move.l (sp)+,a2
        jsr (a2)
        move.l a2,-(sp)
        dc.w 0
cdfn3:  move.l (sp)+,a2
        jsr (a2)
        dc.w 0
CFn8:   moveq #40,d0                    ;Illegal user
        bra CError
CFn9:   moveq #39,d0                    ;User not def
        bra CError

;-----> SWAP
CSwap:  bsr test0
        bsr GetByte
        cmp.b #$fa,d0
        bne CSynt
        bsr Vari
        bsr VarAd
        move.w d2,-(sp)
        lea CSw,a0
        bsr Code0
        bsr GetByte
        cmp.b #",",d0
        bne CSynt
        bsr GetByte
        cmp.b #$fa,d0
        bne CSynt
        bsr Vari
        bsr VarAd
        move.w (sp)+,d1
        and.w #$c0,d1
        and.w #$c0,d2
        cmp.w d1,d2
        bne CType
        tst.b d1
        beq.s CSw1
        bmi.s CSw1
        move.w #1,FLoFlag
        move.w #swap+1,d0
        bra CreFonc
CSw1:   move.w #swap,d0
        bra CreFonc
CSw:    move.l a0,-(a6)
        dc.w 0

;-----> INC 
CInc:   bsr Test0
        bsr GetByte
        cmp.b #$fa,d0
        bne CSynt
        bsr Vari
        bsr VarAd
        and.b #$c0,d2
        bne CType
        lea CdIn,a0
        bra Code1
CdIn:   add.l #1,(a0)
        dc.w $1111

;-----> DEC
CDec:   bsr Test0
        bsr GetByte
        cmp.b #$fa,d0
        bne CSynt
        bsr Vari
        bsr VarAd
        and.b #$c0,d2
        bne CType
        lea CdDe,a0
        bra Code1
CdDe:   sub.l #1,(a0)
        dc.w $1111

;-----> SORT
CSort:  bsr Test0
        bsr GetByte
        cmp.b #$fa,d0
        bne CSynt
        bsr Vari
        bclr #5,d2              ;Veut un tableau
        beq CType
        bsr VarAd               ;Ne met QUE LE POINTEUR!
        and.b #$c0,d2
        move.w cmvqd0,d0
        move.b d2,d0
        bsr outWord
        move.w #sort,d0
        bra CreFonc

;-----> MATCH(a(0),b)
CMach:  bsr GetByte
        cmp.b #"(",d0
        bne CSynt
        bsr GetByte
        cmp.b #$fa,d0
        bne CSynt
        bsr Vari
        bclr #5,d2
        beq CType
        move.l a0,-(sp)
        move.w d2,-(sp)
        bsr GetByte
        cmp.b #",",d0
        bne CSynt
        move.w Parenth,-(sp)
        bsr Evalue
        cmp.w #-1,Parenth
        bne CSynt
        move.w (sp)+,Parenth
        move.w (sp),d1                 ;Egalise les types
        bsr EqType
        bne CType
        move.w (sp)+,d2
        move.l (sp)+,a0
        bsr VarAd
        move.w cmvqd0,d0                ;Moveq #type,d0
        and.b #$c0,d2
        move.b d2,d0
        bsr OutWord
        move.w #match,d0
        bra CreEnt

;-----> Operateur PLUS
CPlus:  bsr Compat
        beq.s CPl2
        bmi.s CPl1
; Addition FLOAT
        move.w #1,FloFlag
        moveq #PlusFl,d0
        bra CreFonc
; Addition de CHAINES
CPl1:   moveq #PlusCh,d0
        bra CreFonc
; Addition entiere DIRECTE
CPl2:   lea CPl3,a0
        bra Code0
CPl3:   move.l (a6)+,d0
        add.l d0,(a6)
        dc.w 0

;-----> Operateur MOINS
CMoin:  bsr Compat
        beq.s CMo2
        bmi.s CMo1
; Soustraction FLOAT
        move.w #1,FloFlag
        moveq #MoinFl,d0
        bra CreFonc
; Soustraction de CHAINES
CMo1:   moveq #MoinCh,d0
        bra CreFonc
; Soustraction entiere DIRECTE
CMo2:   lea CMo3,a0
        bra Code0
CMo3:   move.l (a6)+,d0
        sub.l d0,(a6)
        dc.w 0

;-----> Operateur *
CMult:  bsr Compat
        beq.s CMu
        bmi CType
; Mult FLOAT
        move.w #1,FloFlag
        moveq #MultFl,d0
        bra CreFonc
; Mult Entiere
CMu:    moveq #MultEn,d0
        bra CreFonc

;-----> Operateur /
CDivi:  bsr Compat
        beq.s CDi
        bmi CType
; Divi FLOAT
        move.w #1,FloFlag
        moveq #DiviFl,d0
        bra CreFonc
; Divi Entiere
CDi:    moveq #DiviEn,d0
        bra CreFonc

;-----> Operateur MODULO
CModu:  bsr Quentier
        moveq #Modulo,d0
        bra CreFonc
        
;-----> Operateur PUISSANCE
CPuis:  bsr QueFloat
        moveq #Puiss,d0
        bra CreFonc

;-----> Operateur =
CEgal:  moveq #Egal,d0
        bra.s CompAll
;-----> Operateur <>
CDiff:  moveq #Diff,d0
        bra.s CompAll
;-----> Operateur <
CInf:   moveq #Inf,d0
        bra.s CompAll
;-----> Operateur >
CSup:   moveq #Sup,d0
        bra.s CompAll
;-----> Operateur <=
CInfe:  moveq #Infe,d0
        bra.s CompAll
;-----> Operateur >=
CSupe:  moveq #Supe,d0
  
; Comparateurs sur les trois types
CompAll:move.w d0,-(sp)
        bsr compat
        move.w (sp)+,d0
        tst.b d2
        beq.s Opa3
        bmi.s Opa1
        move.w #1,FloFlag
        bne.s Opa2
Opa1:   addq.w #1,d0
Opa2:   addq.w #1,d0
Opa3:   bsr CreFonc
        clr.b d2                ;Resultat ENTIER
        rts

;-----> Operateur OR
COr:    bsr Quentier
        lea COr2,a0
COr1:   bsr Code0
        clr.b d2
        rts
COr2:   move.l (a6)+,d0
        or.l d0,(a6)
        dc.w 0

;-----> Operateur AND
CAnd:   bsr Quentier
        lea CAnd1,a0
        bra.s COr1
CAnd1:  move.l (a6)+,d0
        and.l d0,(a6)
        dc.w 0

;-----> Operateur XOR
CXor:   bsr Quentier
        lea CXor1,a0
        bra.s COr1
CXor1:  move.l (a6)+,d0
        eor.l d0,(a6)
        dc.w 0

;-----> Fonction NOT
CNot:   bsr FEnt
        lea CNt,a0
        bra.s COr1
CNt:    not.l (a6)
        dc.w 0

;-----> RAD
CRad:   bsr FFlo
        moveq #50,d0
        bra creflo
;-----> DEG
CDeg:   bsr FFlo
        moveq #48,d0
        bra creflo      
;-----> PI
CPi:    moveq #46,d0
        bra creflo

;-----> SINUS
CSin:   moveq #51,d0
CS1:    move.w d0,-(sp)
        bsr FFLo                ;1 param FLOAT
        move.w (sp)+,d0
        bra CreFlo              ;Cree le JSR / ramene un FLOAT
;-----> COSINUS
CCos:   moveq #52,d0
        bra.s CS1
;-----> TANGENTE
CTan:   moveq #53,d0
        bra.s CS1
;-----> EXPONANTIELLE
CExp:   moveq #54,d0
        bra.s CS1
;-----> LOGN
CLogn:  moveq #55,d0
        bra.s CS1
;-----> LOG10
CLog1:  moveq #56,d0
        bra.s CS1
;-----> SQR
CSqr:   moveq #57,d0
        bra.s CS1
;-----> SINH
CSinh:  moveq #58,d0
        bra.s CS1
;-----> CCOSH
CCosh:  moveq #59,d0
        bra.s CS1
;-----> CTANH
CTanh:  moveq #60,d0
        bra.s CS1
;-----> ASIN
CAsin:  moveq #61,d0
        bra.s CS1
;-----> ACOS
CAcos:  moveq #62,d0
        bra.s CS1
;-----> ATAN
CAtan:  moveq #63,d0
        bra.s CS1

;-----> ABS
CAbs:   bsr FArg
        bne.s Ca1
        moveq #64,d0
CreEnt: clr.b d2
        bra CreFonc
Ca1:    moveq #65,d0
CreFlo: move.w #1,FloFlag
        move.b #$40,d2
        bra CreFonc

;-----> INT
CInt:   bsr FArg                
        beq.s Ci1               ;INT(entier)= IDIOT!
        moveq #66,d0
        bra CreFlo
Ci1:    rts

;-----> SGN
CSgn:   bsr FArg
        bne.s Ci2
        moveq #67,d0
        bra CreEnt
Ci2:    move.w #1,floflag
        moveq #68,d0
        bra CreEnt

;-----> RND
CRnd:   bsr FEnt
        moveq #69,d0
        bra CreEnt

;-----> Sous prg MAX / MIN
MaxMin: bsr GetByte
        cmp.b #"(",d0
        bne CSynt
        move.w Parenth,-(sp)
        bsr Evalue
        tst.w Parenth
        bne CSynt
        move.w d2,-(sp)
        bsr GetByte
        cmp.b #",",d0
        bne CSynt
        bsr Evalue
        cmp.w #-1,Parenth
        bne CSynt
        move.w (sp)+,d5
        move.w (sp)+,Parenth
        bsr Compat
        rts

;-----> MAX
CMax:   bsr MaxMin
        move.w #Max,d0
Cm0:    tst.b d2
        beq CreEnt
        addq.l #1,d0
        tst.b d2
        bpl CreFlo
        addq.l #1,d0 
        bra CreCh

;-----> MIN
CMin:   bsr MaxMin
        move.w #Min,d0
        bra.s Cm0

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | BOUCLES / BRANCHEMENTS          |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------

;------------------------------> TESTS DU COMPILATEUR

;-----> Instruction de NIVEAU 0 : RAPIDE!
Test0:  cmp.w #2,Tests
        bne.s Ptt1
Ptt0:   movem.l d0-d7/a0-a2,-(sp)
        moveq #Tester,d0
        bsr CreFonc
        movem.l (sp)+,d0-d7/a0-a2
Ptt1:   rts

;-----> Instruction de NIVEAU 1 : BRANCHEMENT!
Test1:  tst.w Tests
        beq.s Ptt1
        bne.s Ptt0

;------------------------------> REM!
CRem:   addq.l #4,sp            ;Va a la ligne suivante
        subq.l #4,a5            ;Enleve le LEA
        bra FinLine

;------------------------------> END
CEnd:   moveq #FiniStos,d0
        tst.w FlagGem
        beq CreFonc
        moveq #FiniGem,d0
        bra CreFonc

;------------------------------> STOP
CStop:  lea cdstp,a0
        bra code0
cdstp:  moveq #17,d0
        move.l error(a5),a0
        jmp (a0)

;------------------------------> GOTO
CGoto:  bsr Test1
        bsr Pair
        addq.l #4,a6
        bsr Constant
        beq.s Gt1
; GOTO #LIGNE
Gto:    move.w cjmp,d0
        bsr OutWord
        bsr Reljsr
        move.l d1,d0            ;Loke le # de ligne
        cmp.l #65535,d0
        bcc CSynt
        bset #29,d0             ;Reloger ---> # de ligne
        bra OutLong     
; GOTO expression
Gt1:    moveq #Goto,d0
        bra CreFonc

; GOSUB
CGosu:  bsr Test1
        bsr Pair
        addq.l #4,a6  
        bsr Constant
        beq.s Gs1
; GOSUB #LIGNE
        lea Cdgs,a0             ;MOVE.L SP,LOWPILE(A5)
        bsr Code0
        move.w cjsr,d0
        bsr OutWord
        bsr Reljsr
        bsr Pair
        move.l d1,d0            ;Loke le # de ligne
        cmp.l #65535,d0
        bcc CSynt
        bset #29,d0             ;Reloger ---> # de ligne
        bra OutLong     
; GOSUB expression
Gs1:    lea Cdgs,a0             ;MOVE.L SP,LOWPILE(A5)
        bsr Code0
        moveq #Gosub,d0
        bra CreFonc
CdGs:   move.l sp,LowPile(a5)
        dc.w 0

; RETURN
CRetu:  bsr Test0
        moveq #Return,d0
        bra CreFonc
; POP
CPop:   bsr Test0
        moveq #Pop,d0
        bra CreFonc     

; ON xx GOTO / GOSUB
COn:    bsr Test1
        bsr GetByte
        cmp.b #$a0,d0
        bne.s Ona1
        bsr GetByte
        cmp.b #$81,d0
        beq OnMenu
Ona:    subq.l #1,a6
Ona1:   subq.l #1,a6
        bsr ExpEntier           ;Prend la variable
        move.l a5,-(sp)         ;Place pour le MOVEQ
        addq.l #2,a5
        bsr GetByte             ;GOTO ou GOSUB
        bsr Pair
        addq.l #4,a6
        cmp.b #$98,d0           ;GOTO?
        bne.s On0
        moveq #OnGto,d0
        bra.s On1
On0:    cmp.b #$99,d0
        bne CSynt
*        lea Cdgs,a0             ;MOVE.L SP,LOWPILE(A5)
*        bsr Code0
        moveq #OnGsb,d0
On1:    bsr CreFonc
        move.w Cbra,d0
        bsr OutWord
        move.l a5,-(sp)         ;Adresse du BRA
        bsr OutWord
; Compte et poke les numeros de ligne
        clr.w -(sp)
On2:    move.w Cjmp,d0
        bsr Outword
        bsr Reljsr
        bsr Constant
        beq CSynt
        cmp.l #65535,d1
        bcc CSynt
        move.l d1,d0
        bset #29,d0
        bsr OutLong
        add.w #1,(sp)
        bsr GetByte
        cmp.b #",",d0
        beq.s On2
        subq.l #1,a6
        move.w (sp)+,d1
        move.w d1,d0
        mulu #6,d0                      ;Doke le BRA
        addq.w #2,d0
        move.l a5,d7
        move.l (sp)+,a5
        bsr OutWord
        move.w cmvqd0,d0                ;Doke le MOVEQ
        move.b d1,d0
        move.l (sp)+,a5
        bsr OutWord
        move.l d7,a5
        rts
        

;------------------------------> IF THEN ELSE
CIf:    bsr Test0
        bsr ExpEntier           ;ramene VRAI ou FAUX
; Cherche le THEN
        bsr GetByte
        cmp.b #$9a,d0
        bne CSynt
        bsr Pair                ;Saute le flag du THEN
        addq.l #4,a6
        lea cthen,a0            ;Poke TST.L (A6)+ / BEQ XXXXX
        bsr Code1 
; Cherche le ELSE
        move.l a6,a0
        move.w #1,ccptnext
If1:    move.b #$9a,d0
        move.b #$9b,d1
        bsr ftoken
        beq.s If3
        bmi.s If2
; A trouve un THEN
        add.w #1,ccptnext
        bra.s If1
; A trouve un ELSE
If2:    sub.w #1,ccptnext
        bne.s If1 
; A trouve le bon ELSE
        bra.s If4
; Pas de ELSE
If3:    move.l #$1,a1
; Stocke dans la table d'adressage
If4:    move.l Pif,a0
        move.l a1,(a0)+
        move.l a5,(a0)+
        move.l a0,Pif
; Numero de ligne apres le THEN?
        bsr GetByte
        subq.l #1,a6
        cmp.b #$fe,d0
        beq.s If5
        rts
If5:    bsr Constant
        beq CSynt
        bsr Test1
        bra Gto
cthen:  tst.l (a6)+
        beq celse
        dc.w $1111

;-----> ELSE
CElse:  
; Fait un GOTO ligne suivante
        move.w cbra,d0                  ;Poke le BRA
        bsr OutWord
        clr.w d0
        bsr OutWord
        move.l Pif,a0                   ;Force le relogeage
        move.l #$1,(a0)+
        move.l a5,(a0)+
        move.l a0,Pif
; Reloge le IF
        move.l Tif,a0                   ;Origine table des IF
        subq.l #1,a6
Ce1:    cmp.l Pif,a0                    ;ELSE non reference?
        beq CSynt
        cmp.l (a0),a6                   ;trouve le bon IF
        beq.s Ce2
        lea 8(a0),a0
        bra.s Ce1
Ce2:    clr.l (a0)                      ;ELSE deja reloge!
        move.l a5,d0
        move.l a5,-(sp)
        move.l 4(a0),a5
        sub.l a5,d0                     ;Distance THEN / ELSE   
        addq.w #2,d0
        subq.l #2,a5    
        bsr OutWord
        move.l (sp)+,a5
; Un numero de ligne apres le ELSE?
        addq.l #1,a6
        bsr Pair                        ;Saute le flag du ELSE
        addq.l #4,a6
        bsr GetByte
        subq.l #1,a6
        cmp.b #$fe,d0
        beq If5
        rts     

;-----> Reloge les BRA a la fin d'une ligne
RelBra: move.l Tif,a2
Rb1:    cmp.l Pif,a2
        beq.s Rb3
        cmp.l #1,(a2)
        bne.s Rb2
; Reloge!
        clr.l (a2)
        move.l a5,d0
        move.l a5,-(sp)
        move.l 4(a2),a5
        sub.l a5,d0                     ;Distance au THEN
        addq.w #2,d0
        subq.l #2,a5    
        bsr OutWord
        move.l (sp)+,a5
Rb2:    lea 8(a2),a2
        bra.s Rb1
; Fini: RAZ de la table
Rb3:    move.l Tif,Pif
        rts

;------------------------------> FOR TO STEP
CFor:   bsr Test0
        bsr Pair
        addq.l #4,a6            ;Saute le flag

; Prend et egalise la variable
        bsr CLLet
        tst.b d2
        bmi CType
        move.w d2,-(sp)         ;Sauve le type
        move.l a6,-(sp)         ;Sauve le CHRGET
        move.l a0,-(sp)
        lea forcd1,a0           ;MOVE.L A0,-(A6)
        bsr Code0

;-----> Trouve le bon NEXT
        move.l a6,a0
        move #1,ccptnext
        move.l AdLine,coldf
for2:   move.b #$9d,d0
        move.b #$82,d1
        bsr supfind
	beq CFonx               ;For without next error
        bmi.s for4
; a trouve un FOR
	bsr GetByt0
	subq.l #1,a0
        cmp.b #$fa,d2           ;si SYNTAX ERR: n'en tient pas compte
        bne.s for2
        lea 1(a0),a6
        bsr vari
        cmp.l (sp),a0
        move.l a6,a0            ;La meme variable?
        bne.s for2
        add #1,ccptnext
        bra.s for2
; a trouve un NEXT
for4:   move.l a1,a2            ;a1 pointe le NEXT
	bsr GetByt0		;Si NEXT seul
	subq.l #1,a0 
        cmp.b #$fa,d2           ;ou erreur, decremente le compteur
        bne.s for5
        lea 1(a0),a6
        move.l a2,-(sp)
        bsr vari                ;va chercher la variable
        move.l (sp)+,a2
        cmp.l (sp),a0           ;compare la variable
        move.l a6,a0
        bne for2
for5:   sub #1,ccptnext
        bne for2
        move.l a2,(sp)          ;pointe le NEXT
        move.l 4(sp),a6         ;a6 repointe le TO
        
;-----> LE NEXT EST TROUVE
 
; Compile le TO
        bsr GetByte
        cmp.b #$80,d0           ;cherche le TO
        bne CSynt
        bsr evalue
        move.w 8(sp),d1         ;Type de la boucle
        bsr EqType              ;egalise les types
        bne CType
; Compile le STEP
        bsr GetByte
        subq.l #1,a6
        cmp.b #$81,d0           ;cherche un STEP
        bne.s for11
        addq.l #1,a6
        bsr evalue              ;va chercher le STEP
        bra.s for12
for11:  lea forcd2,a0           ;MOVE.L #$1,-(A6)
        bsr Code1
        clr.b d2                ;entier!
for12:  move.w 8(sp),d1
        bsr EqType              ;Egalise les type TO / STEP
        bne CType

;-----> Poke les tables du compilateur
        move.l cposbcle,a0
        lea -16(a0),a0
        move.l a0,cposbcle
        add.w #1,cnboucle
        move.l a6,(a0)          ;Debut de la boucle
        move.l (sp)+,4(a0)      ;Fin de la boucle
        move.l a5,8(a0)         ;Adresse du chargement de adresses
        addq.l #4,sp
        move.w (sp)+,d7
        move.w d7,12(a0)        ;Type de la boucle: INT ou FLOAT

;-----> Poke dans le source
        move.w cleaa2,d0        ;Adresse ou poker
        bsr OutWord
        bsr RelJsr
        addq.l #4,a5
        moveq #for,d0           ;Fonction qui poke
        tst.b d7
        beq.s For13
        addq.w #1,d0
For13:  bra CreFonc

CFonx:  moveq #22,d0
        bra CError

;-----> Code pour FOR
forcd1: move.l a0,-(a6)
        dc.w 0
forcd2: move.l #$1,-(a6)
        dc.w $1111

;-----------------------------------> NEXT
CNext:  bsr Test1
        move.w ctstnbcle,d0     ;un boucle depuis le dernier gosub?
        cmp.w cnboucle,d0
        beq CnxFo
; Saute la variable (si elle existe)
        pea -1(a6)              ;adresse du NEXT
        bsr GetByte
        subq.l #1,a6
        cmp.b #$fa,d0
        bne.s CNx0
        addq.l #1,a6
        bsr vari
CNx0:   move.l (sp)+,d0
; Verifie qu'il s'agit du bon next
        move.l cposbcle,a0
        cmp.l 4(a0),d0          ;Bonne boucle?
        bne CnxFo
        add.l #16,cposbcle      ;depile
        sub.w #1,cnboucle
        move.w 12(a0),d2        ;Type de la boucle
; Loke l'adresse du NEXT dans le LEA du FOR -completement genial merde-
        move.l a5,-(sp)
        move.l a5,d0            ;Pointe l'adresse du RTS apres l'appel
        sub.l Objet,d0          ;en relatif
        bset #30,d0             ;Signale une adresse INTERNE au prg
        move.l 8(a0),a5         ;Adresse du LEA
        lea 2(a5),a5            ;-2
        bsr OutLong
        move.l (sp)+,a5
; Poke le code de chargement des parametres
        tst.b d2
        bne.s CNx1
        lea cdnx1,a0
        bsr Code0
        moveq #next,d0
        bra CreFonc
CNx1:   lea cdnx2,a0
        bsr Code0
        moveq #next+1,d0
        bra CreFonc
; Code chargement parametres ENTIERS
cdnx1:  lea $ffffff,a2          ;adresse de bouclage
        lea $ffffff,a3          ;adresse de le variable
        move.l #$ffffffff,d1    ;limite
        move.l #$ffffffff,d2    ;step
        dc.w 0  
; Code chargement parametres FLOAT
cdnx2:  lea $ffffff,a2
        lea $ffffff,a3
        move.l #$ffffffff,d5
        move.l #$ffffffff,d6
        move.l #$ffffffff,d3        
        move.l #$ffffffff,d4
        dc.w 0
; For without next
Cnxfo:  moveq #23,d0
        bra CError

;-----> WHILE
CWhil:  bsr Pair
        addq.l #4,a6
        move.l a6,a0
        move.l AdLine,coldf
        move.w #1,ccptnext
wh2:    move.b #$9e,d0
        move.b #$83,d1
        bsr supfind
        beq.s cwhw
        bmi.s wh3
; a trouve un while
        add.w #1,ccptnext
        bra.s wh2
; a trouve un wend
wh3:    sub.w #1,ccptnext
        bne.s wh2
; a trouve le bon wend
        move.l a5,-(sp)         ;Adresse du debut de la boucle (objet)
        move.l a1,-(sp)         ;Adresse du wend (source)
        bsr ExpEntier
; poke la boucle
        move.l cposbcle,a0
        lea -16(a0),a0
        move.l a0,cposbcle
        add.w #1,cnboucle
        move.l a6,(a0)          ;Debut de la boucle (source)
        move.l (sp)+,4(a0)      ;Fin de la boucle (source)
        move.l a5,8(a0)         ;Adresse de l'adresse NEXT (objet)
        move.l (sp)+,12(a0)     ;Adresse de la boucle (objet)
; Termine...
        move.w CLeaa2,d0        ;Adresse du WEND
        bsr OutWord
        bsr Reljsr
        addq.l #4,a5
        moveq #While,d0
        bra CreFonc
        
cwhw:   moveq #24,d0
        bra CError
cwwh:   moveq #25,d0
        bra CError

;-----> WEND
CWend:  move.w ctstnbcle,d0
        cmp.w cnboucle,d0
        beq.s cwwh
        move.l cposbcle,a2
        subq.l #1,a6
        cmp.l 4(a2),a6
        bne.s cwwh
        addq.l #1,a6
; Une boucle de moins
        add.l #16,cposbcle
        sub.w #1,cnboucle
; Loke l'adresse du WEND dans le LEA du WHILE
        bsr Test1
        move.l a5,-(sp)
        move.l a5,d0            ;Pointe l'adresse du RTS apres l'appel
        addq.l #6,d0            ;de WEND
        sub.l Objet,d0          ;en relatif
        bset #30,d0             ;Signale une adresse INTERNE au prg
        move.l 8(a2),a5         ;Adresse du LEA
        lea 2(a5),a5            ;-2
        bsr OutLong
        move.l (sp)+,a5
; JMP boucle
        move.w cjmp,d0
        bsr OutWord
        bsr Reljsr
        move.l 12(a2),d0
        sub.l objet,d0
        bset #30,d0
        bra OutLong

;-----> REPEAT
CRepe:  bsr Pair
        addq.l #4,a6
        move.l AdLine,coldf
        move.l a6,a0
        move.w #1,ccptnext
rp2:    move.b #$9f,d0
        move.b #$84,d1
        bsr supfind
        beq.w crpu
        bmi.s rp3
; a trouve un repeat
        add.w #1,ccptnext
        bra.s rp2
; a trouve un until
rp3:    sub.w #1,ccptnext
        bne.s rp2
; a trouve le bon until
        move.l cposbcle,a0
        lea -16(a0),a0
        move.l a0,cposbcle
        add.w #1,cnboucle
        move.l a6,(a0)          ;Debut de la boucle (source)
        move.l a1,4(a0)         ;Fin de la boucle (source)
        move.l a5,8(a0)         ;Adresse de la boucle (objet)
        rts

;-----> UNTIL
CUnti:  move.w ctstnbcle,d0
        cmp.w cnboucle,d0
        beq.s curp
        move.l cposbcle,a2
        subq.l #1,a6
        cmp.l 4(a2),a6
        bne.s curp
        addq.l #1,a6
; Une boucle de moins
        add.l #16,cposbcle
        sub.w #1,cnboucle
; Evalue l'expression
        bsr Test1
        move.l a2,-(sp)
        bsr ExpEntier
        move.l (sp)+,a2
; Charge l'adresse de la boucle
        move.w cleaa2,d0
        bsr OutWord
        bsr Reljsr
        move.l 8(a2),d0
        sub.l objet,d0
        bset #30,d0
        bsr OutLong
; Appelle la librairie
        moveq #until,d0
        bra CreFonc
crpu:   moveq #26,d0
        bra CError
curp:   moveq #27,d0
        bra CError

;-----> ON ERROR GOTO
COnEr:  bsr Test0
        bsr GetByte
        cmp.b #$98,d0
        bne CSynt
        bsr Pair
        addq.l #4,a6
        bsr ExpEntier
        move.w #onerr,d0
        bra CreFonc

;-----> ERROR xx
CErr:   bsr Test0
        bsr ExpEntier
        move.w #err,d0
        bra CreFonc

;-----> RESUME [xxxx]
CResu:  bsr Test1
        bsr Finie
        beq.s Resu1
; RESUME #ligne
        bsr expentier
        move.w #resline,d0
        bra CreFonc
; RESUME seul#
Resu1:  move.w #reseul,d0
        bra CreFonc

;-----> RESUME NEXT
CResN:  bsr Test1
        move.w #resnex,d0
        bra CreFonc

;-----> ERRL
CErrl:  move.w #errl,d0
        bra CreEnt

;-----> ERRN
CErrn:  move.w #errn,d0
        bra CreEnt

;-----> BREAK ON/OFF
CBrek:  bsr Test0
        bsr OnOff
        bmi CSynt
        bne.s brk
        move.w #brek,d0
        bra CreFonc
brk:    move.w #brek+1,d0
        bra CreFonc

; SUPER FIND: CHERCHE UN TOKEN DANS LA SUITE DU PROGRAMME a partir de a0!
supfind:bsr ftoken
        bne.s sf5
        move.l coldf,a0
        bsr GetWor0
        subq.l #2,a0
        add.w d2,a0
        bsr GetWor0
        subq.l #2,a0
        tst.w d2
        beq.s sf5
        move.l a0,coldf
        addq.l #4,a0
        bra supfind
sf5:    rts

; FIND TOKEN: CHERCHE UN TOKEN DANS LA LIGNE ACTUELLE
ftoken: move.l a0,a1        ;ramene l'adresse juste en a1
        bsr GetByt0         ;ramene l'adresse juste apres en a0!
        beq.s ft8           ;fin de la ligne
        bpl.s ft5
        cmp.b #$a0,d2       ;instruction etendue
        beq.s ft1a
        cmp.b #$b8,d2       ;fonction etendue
        beq.s ft1a
        cmp.b #$a8,d2       ;.EXT instruction
        beq.s ft1
        cmp.b #$c0,d2       ;.EXT fonction
        bne.s ft2
ft1:    addq.l #1,a0          
ft1a:   addq.l #1,a0
        bra.s ft5
ft2:    cmp.b #$fa,d2       ;variable ou constante?
        bcc.s ft3
        cmp.b #$98,d2
        bcs.s ft5
        cmp.b #$a0,d2
        bcc.s ft5
ft3:    move a0,d3          ;rend pair
        btst #0,d3
        beq.s ft4
        addq.l #1,a0
ft4:    cmp.b #$ff,d2
        bne.s ft4a
        addq.l #4,a0        ;constantes float sur huit octets!
ft4a:   cmp.b #$fc,d2
        bne.s ft0
        move.w d2,-(sp)
        addq.l #2,a0
        bsr GetWor0
        subq.l #4,a0
        add.w d2,a0         ;chaines alphanumerique! saute la chaine
        move.w (sp)+,d2
ft0:    addq.l #4,a0        ;saute le flag
ft5:    cmp.b d2,d1
        beq.s ft7
        cmp.b d2,d0
        bne.s ftoken
ft6:    move #1,d2          ;trouve le premier
        rts
ft7:    move #-1,d2         ;trouve le second
        rts
ft8:    subq.l #1,a0        ;reste sur le zero!!!
        rts                 ;pas trouve!

;-----> Prend un octet du programme (A0)---> D2
GetByt0:tst.w NomIn
        bne.s gdb0
        move.b (a0)+,d2
        rts
gdb0:   movem.l a0/a6,-(sp)
        move.l a0,a6
        bsr SoDisk
        move.b (a0),d2
        movem.l (sp)+,a0/a6
        addq.l #1,a0
        tst.b d2
        rts
;-----> Prend un MOT du programme (A0)---> D2
GetWor0:tst.w NomIn
        bne.s gdw0
        move.w (a0)+,d2
        rts
gdw0:   movem.l a0/a6,-(sp)
        move.l a0,a6
        bsr SoDisk
        move.w (a0),d2
        movem.l (sp)+,a0/a6
        addq.l #2,a0
        tst.w d2
        rts



;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | ACCES MEMOIRE                   |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------

;-----> TIMER=
CStmr:  bsr GetByte
        cmp.b #$f1,d0
        bne CSynt
        bsr Test0
        bsr ExpEntier
        moveq #timr,d0
        bra CreFonc
;-----> =TIMER
CTimr:  moveq #timr+1,d0
        bra CreEnt

;-----> POKE DOKE LOKE: rapide, pas de JSR
Pok:    lea Po,a0               ;Poke
        bra.s Lok1
Po:     move.b d0,(a0)
        dc.w 0
Dok:    lea Do,a0               ;Doke
        bra.s Lok1
Do:     move.w d0,(a0)
        dc.w 0
Lok:    lea Lo,a0               ;Loke
Lok1:   bsr Test0
        move.l a0,-(sp)
        lea ParEnt,a2           ;2 params entiers
        bsr ParInst
        cmp.w #2,d0
        bne CSynt
        lea Lok2,a0
        bsr Code0
        move.l (sp)+,a0
        bsr Code0
        rts
Lo:     move.l d0,(a0)
        dc.w 0
Lok2:   move.l (a6)+,d0
        move.l (a6)+,a0
        dc.w 0

;-----> PEEK DEEK LEEK rapide: pas de JSR
Pik:    bsr FArg
        lea Cpik,a0
        bra.s FPik
Dik:    bsr FArg
        lea CDik,a0
        bra.s FPik
Lik:    bsr FArg
        lea CLik,a0
FPik:   bsr Code0
        clr.b d2
        rts
CPik:   move.l (a6)+,a0
        moveq #0,d0
        move.b (a0),d0
        move.l d0,-(a6)
        dc.w 0
CDik:   move.l (a6)+,a0
        moveq #0,d0
        move.w (a0),d0
        move.l d0,-(a6)
        dc.w 0
CLik:   move.l (a6),a0
        move.l (a0),(a6)
        dc.w 0
        
;-----> FREE
CFree:  move.w #free,d0
        bra CreEnt

;-----> VARPTR
CVarp:  bsr GetByte
        cmp.b #"(",d0
        bne CSynt
        bsr GetByte
        cmp.b #$fa,d0
        bne CSynt
        bsr Vari
        bsr VarAd
        bsr GetByte
        cmp.b #")",d0
        bne CSynt
        tst.b d2
        bmi.s CV1
        lea Cdv1,a0
        bra.s Cv2
Cv1:    lea Cdv2,a0    
Cv2:    bsr Code0
        clr.b d2
        rts
Cdv1:   move.l a0,-(a6)
        dc.w 0
Cdv2:   move.l (a0),d0
        addq.l #2,d0
        move.l d0,-(a6)
        dc.w 0

;-----> BSET/CLR/CHG
CBset:  move.w #bst,-(sp)
        bra.s CBit
CBclr:  move.w #bst+1,-(sp)
        bra.s CBit
CBchg:  move.w #bst+2,-(sp)
CBit:   bsr Test0
        bsr ExpEntier
        bsr GetByte
        cmp.b #",",d0
        bne CSynt
        bsr PreVari
        bsr VarAd
        and.b #$c0,d2
        bne CType
        move.w (sp)+,d0        
        bra CreFonc

;-----> BTST
CBtst:  lea ParEnt,a2
	bsr ParFonc
	cmp.w #2,d0
	bne CSynt
        move.w #bst+3,d0
        bra CreEnt

;-----> ROL .b / .w / .l 
CRol:   move.w #raul,-(sp)
        bra.s rr1
;-----> ROR
CRor:   move.w #raur,-(sp)
rr1:    moveq #1,d1
        bsr GetByte
        subq.l #1,a6
        cmp.b #$ad,d0           ;Octet?
        beq.s rr2
        cmp.b #$ae,d0           ;Mot?
        beq.s rr3
        cmp.b #$af,d0           ;Mot long?
        bne.s rr4
        moveq #2,d1             ;Mot long
        bra.s rr3
rr2:    moveq #0,d1             ;Octet
rr3:    addq.l #1,a6
rr4:    move.w d1,-(sp)
        bsr ExpEntier
        bsr GetByte
        cmp.b #",",d0
        bne CSynt
        bsr PreVari
        bsr VarAd
        and.b #$c0,d2
        bne CType
        move.w (sp)+,d0
        add.w (sp)+,d0
        bra CreFonc

;-----> D/A REG(0-7)=
CDReg:  move.w #regs,-(sp)
        bra.s Dr1
CAReg:  move.w #regs+1,-(sp)
Dr1:    bsr Test0
        bsr FEnt
        bsr GetByte
        cmp.b #$f1,d0
        bne CSynt
        bsr Expentier
        move.w (sp)+,d0
        bra CreFonc

;-----> = A/D REG(0-7)
CFDrg:  move.w #regs+2,-(sp)
        bra.s Dr2
CFArg:  move.w #regs+3,-(sp)
Dr2:    bsr FEnt
        move.w (sp)+,d0
        bra CreEnt

;-----> CALL
CCall:  move.w #trp+1,-(sp)
        bra.s CTr0
;-----> TRAP
CTrap:  move.w #trp,-(sp)
CTr0:   bsr Test0
        bsr Expentier
        lea Cdtr1,a0
        bsr Code0
Ctr1:   bsr GetByte
        subq.l #1,a6
        beq.s Ctr6
        cmp.b #":",d0
        beq.s Ctr6
        cmp.b #$9b,d0
        beq.s Ctr6
        cmp.b #",",d0
        bne CSynt
        addq.l #1,a6
        clr.w -(sp)
        bsr GetByte
        subq.l #1,a6
        cmp.b #$ae,d0
        beq.s Ctr2
        cmp.b #$af,d0
        bne.s Ctr3
        move.w #1,(sp)
Ctr2:   addq.l #1,a6
Ctr3:   bsr evalue
        tst.w parenth
        bne CSynt
        tst.b d2
        beq.s Ctr5
        bmi.s Ctr4
        moveq #inttofl,d0
        bsr crefonc
        bra.s Ctr5
Ctr4:   move.w #3,(sp)          ;LONG et CHAINE!
Ctr5:   lea cdtr2,a0            ;MOVE.W TYPE,-(a6)
        move.w (sp)+,2(a0)
        bsr Code1
        bra.s Ctr1
CTr6:   move.w (sp)+,d0
        bra CreFonc
cdtr1:  move.w #-1,-(a6)
        dc.w 0
cdtr2:  move.w #$2222,-(a6)
        dc.w $1111

;-----> FILL
ParFil: dc.b en,to,en,",",en,1
        dc.b 1,0
CFill:  move.w #fill,-(sp)
        lea ParFil,a2
        bra.s CCo
;-----> COPY
ParCop: dc.b en,",",en,to,en,1
        dc.b 1,0
CCopy:  move.w #Copy,-(sp)
        lea ParCop,a2
CCo:    bsr Test0
        bsr ParInst
        move.w (sp)+,d0
        bra CreFonc

;-----> HUNT
ParUnt: dc.b en,to,en,",",ch,1
        dc.b 1,0
CHunt:  lea ParUnt,a2
        bsr ParFonc
        move.w #Hunt,d0
        bra CreEnt

;-----> RESERVE
CRese:  bsr Test0
        bsr GetByte
        cmp.b #$a0,d0
        bne CSynt
        bsr GetByte
        cmp.b #$aa,d0
        beq.s res2
        cmp.b #$ab,d0
        beq.s res3
        cmp.b #$ac,d0
        beq.s res1
        cmp.b #$7d,d0
        beq.s res2a
        move #$81,d1                    ;data!
        bra.s res4
res1:   move #$2,d1                     ;screen!
        bra.s res4
res2:   move #$82,d1                    ;datascreen!
        bra.s res4
res2a:  move #$84,d1
        bra.s res4
res3:   move #$1,d1
res4:   move.w d1,-(sp)
        bsr Expentier                   ;# de la banque
        move.w (sp),d0
        and.w #$0f,d0
        cmp.b #2,d0
        beq.s Res5
        bsr GetByte
        cmp.b #",",d0
        bne CSynt
        bsr Expentier                   ;Taille
res5:   move.w cmvqd0,d0
        move.w (sp)+,d1
        move.b d1,d0
        bsr OutWord
        move.w #rese,d0
        bra CreFonc

;-----> ERASE
CEras:  bsr Test0
        lea ParEnt,a2
        bsr ParInst
        cmp.w #2,d0
        beq.s Cer1
        cmp.w #1,d0
        bne CSynt
        move.w #eras,d0
        bra CreFonc
Cer1:   moveq #15,d0
        bra CError

;-----> BCOPY
Parbc:  dc.b en,to,en,1
        dc.b 1,0
CBCop:  bsr Test0
        lea Parbc,a2
        bsr ParInst
        move.w #bcop,d0
        bra CreFonc

;-----> BGRAB
CBgra:  bsr Test0
        lea ParEnt,a2
        bsr ParInst
        cmp.w #2,d0
        beq.s CBg
        cmp.w #1,d0
        bne CSynt
        move.w #bgrab,d0
        bra CreFonc
CBg:    move.w #bgrab+1,d0
        bra CreFonc

;-----> =LENGTH
CLeng:  move.w #length,-(sp)
        bra.s CSr
;-----> =START
CStar:  move.w #start,-(sp)
CSr:    lea ParEnt,a2
        bsr ParFonc
        cmp.w #2,d0
        beq.s CSr1
        cmp.w #1,d0
        bne CSynt
        move.w (sp)+,d0
        bra CreEnt
CSr1:   move.w (sp)+,d0
        addq.w #1,d0
        bra CreEnt

;-----> CURRENT
CCurr:  move.w #curr,d0
        bra CreEnt

;-----> ACCNB
CAccn:  move.w #accnb,d0
        bra CreEnt

;-----> LANGAGE
CLang:  move.w #lang,d0
        bra CreEnt

;-----> OFF
COff:   bsr Test0
        move.w #off,d0
        bra CreFonc

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | TEXTE / ALPHANUMERIQUE          |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
; Formats des MIDS
PMid:   dc.b ch,",",en,1
        dc.b ch,",",en,",",en,1
        dc.b 1

        even
;-----> =LEFT$(a$,xx)
CLeft:  lea PMid,a2
        bsr ParFonc
        cmp.w #1,d0
        bne CSynt
        moveq #Left,d0
CreCh:  bsr CreFonc
        move.b #$80,d2
        rts

;-----> =RIGHT$(a$,xx)   
CRigh:  lea PMid,a2
        bsr ParFonc
        cmp.w #1,d0
        bne CSynt
        moveq #Right,d0
        bra.s CreCh

;-----> =MID$(a$,xx) / =MID$(a$,xx,yy)
CMid:   lea PMid,a2
        bsr ParFonc
        cmp.w #1,d0
        bne.s CMd
        moveq #Mid1,d0
        bra.s CreCh
CMd:    moveq #Mid2,d0
        bra.s CreCh

;-----> LEFT$(a$,xx)=
CIlft:  bsr Cim
        cmp.w #1,d7
        bne CSynt
        moveq #ILeft,d0
        bra CreFonc

;-----> RIGHT$(a$,xx)=
CIrgh:  bsr Cim
        cmp.w #1,d7
        bne CSynt
        moveq #IRigh,d0
        bra CreFonc

;-----> MID$(a$,xx)= / MID$(a$,xx,yy)=
CImid:  bsr Cim
        cmp.w #2,d7
        beq Cimd
        moveq #IMid1,d0
        bra CreFonc
cimd:   moveq #IMid2,d0
        bra CreFonc

; Routine commune LEFT/RIGHT/MID en INSTRUCTIONS
Cim:    bsr Test0
        bsr GetByte                 ;Parenthese
        cmp.b #"(",d0
        bne CSynt
        bsr GetByte                 ;Variable
        cmp.b #$fa,d0
        bne CSynt
        bsr Vari
        tst.b d2
        bpl CType
        move.w d2,-(sp)         ;Sauve pour apres
        movem.l a0/a1,-(sp)
; Prend les parametres
        bsr GetByte
        cmp.b #",",d0
        bne CSynt
        bsr Evalue
        clr.b d1                ;Veut un entier
        bsr EqType
        bne CType
        moveq #1,d7
        cmp.w #-1,Parenth
        beq.s Cim2
        tst.w Parenth
        bne CSynt

        bsr GetByte
        cmp.b #",",d0
        bne CSynt
        bsr Evalue
        clr.b d1
        bsr EqType
        bne CType
        moveq #2,d7
        cmp.w #-1,Parenth
        bne CSynt
Cim2:   bsr GetByte             ;Veut un EGAL
        cmp.b #$f1,d0
        bne CSynt
        move.w d7,-(sp)
        bsr ExpAlpha            ;Va evaluer la CHAINE
        move.w (sp)+,d7         ;Nombre de params
        movem.l (sp)+,a0/a1     ;Recupere la variable
        move.w (sp)+,d2
        bsr VarAd
        rts

;-----> =INSTR(a$,xx)
PIst:   dc.b ch,",",ch,1
        dc.b ch,",",ch,",",en,1
        dc.b 1,0
CInst:  lea PIst,a2
        bsr ParFonc
        cmp.w #1,d0
        bne.s CIn
        moveq #Inst,d0
        bra CreEnt
CIn:    moveq #Inst+1,d0
        bra CreEnt

;-----> =LEN(a$)
CLen:   bsr FChai
        moveq #len,d0
        bra CreEnt

;-----> =FLIP$(a$)
CFlip:  bsr FChai
        moveq #flip,d0
        bra CreCh

;-----> =SPACE$(xx)
CSpc:   bsr FEnt
        moveq #spc,d0
        bra CreCh

;-----> =STRING$(a$,xx)
CStri:  lea PMid,a2
        bsr ParFonc
        cmp.w #1,d0
        bne CSynt
        moveq #string,d0
        bra CreCh

;-----> =CHR$(xx)
CChr:   bsr FEnt
        moveq #chr,d0
        bra CreCH

;-----> =ASC(a$)
CAsc:   bsr FChai
        moveq #asc,d0
        bra CreEnt

;-----> =BIN$(xx) / BIN$(xx,yy)
CBin:   lea ParEnt,a2
        bsr ParFonc
        cmp.w #2,d0
        beq.s CB1
        cmp.w #1,d0
        bne CSynt
        moveq #Bin,d0
        bra CreCh
Cb1:    moveq #Bin+1,d0
        bra CreCh

;-----> =HEX$(xx) / HEX$(xx,yy)
CHex:   lea ParEnt,a2
        bsr ParFonc
        cmp.w #2,d0
        beq.s Ch1
        cmp.w #1,d0
        bne CSynt
        moveq #Hex,d0
        bra CreCh
Ch1:    moveq #Hex+1,d0
        bra CreCh

;-----> =STR$(xx)
CStr:   bsr FArg
        bne.s Cst
        moveq #Str,d0
        bra CreCh
Cst:    moveq #Str+1,d0
        bra CreCh

;-----> =VAL(a$)
CVal:   bsr FChai
        moveq #Val,d0
        tst.w ValFlo
        beq CreEnt
        bra CreFlo

;-----> UPPER$ (inverse)
CLow:   bsr FChai
        move.w #Upp,d0
        bra CreCh

;-----> LOWER$ (inverse)
CUpp:   bsr FChai
        move.w #Low,d0
        bra CreCh

;-----> TIME$ en fonction
CTime:  move.w #Time,d0
        bra CreCh

;-----> DATE$ en fonction
CDate:  move.w #Date,d0
        bra CreCh

;-----> SETTIME
CSTim:  bsr Test0
        bsr GetByte
        cmp.b #$f1,d0
        bne CSynt
        bsr ExpAlpha
        move.w #STime,d0
        bra CreFonc

;-----> SETDATE
CSDat:  bsr Test0
        bsr GetByte
        cmp.b #$f1,d0
        bne CSynt
        bsr ExpAlpha
        move.w #SDate,d0
        bra CreFonc 

;-----> CLICK ON/OFF
CClic:  bsr Test0
        bsr OnOff
        bmi CSynt
        bne.s CCl
        move.w #clic,d0
        bra crefonc
CCl:    move.w #clic+1,d0
        bra crefonc

;-----> KEY
CKey:   bsr Test0
        bsr OnOff
        bmi.s Cki2
        bne.s Cki1
; KEY OFF
        move.w #Ky,d0
        bra CreFonc
; KEY ON
Cki1:   move.w #Ky+1,d0
        bra CreFonc
; KEY(XX)="kkkkkkkkkkkkkkkk"
Cki2:   bsr FEnt
        bsr GetByte
        cmp.b #$f1,d0
        bne CSynt
        bsr ExpAlpha
        move.w #Ky+2,d0
        bra CreFonc

; =FKEY
CFKey:  move.w #Ky+3,d0
        bra CreEnt

; =INKEY$
CInky:  move.w #Inky,d0
        bra CreCh

; =SCANCODE
CScan:  move.w #Inky+1,d0
        bra Creent

; CLEARKEY
CClKy:  bsr Test0
        move.w #Inky+2,d0
        bra CreFonc

; WAIT KEY
CWtKy:  move.w #Inky+4,d0
        bra CreFonc
 
; PUTKEY
CPuKy:  bsr Test0
        bsr ExpAlpha
        move.w #Inky+3,d0
        bra CreFonc


;----------------------------------> DATA / READ / RESTORE
;-----> DATA
CData:  
; Premiere ligne de datas?
        tst.l FstData
        bne.s Cda1
        move.l a5,d0
        sub.l Objet,d0
        move.l d0,FstData 
        bra.s Cda2
; Reloge la ligne precedente
Cda1:   move.l a5,-(sp)
        move.l a5,d0                    ;Saute le BRA
        sub.l Objet,d0
        bset #30,d0
        move.l OlData,a5
        bsr OutLong
        move.l (sp)+,a5
; Fait un BRA a la ligne suivante
Cda2:   subq.l #4,a5                    ;Pas de LEA
        move.w cbra,d0
        bsr OutWord
        clr.w d0
        bsr OutWord
        move.l Pif,a0
        move.l #$1,(a0)+
        move.l a5,(a0)+
        move.l a0,Pif
; Evalue tous les datas
Cda3:   bsr GetByte
        subq.l #1,a6
        cmp.b #",",d0
        bne.s Cda4
; Une virgule!
        move.b #1,d2                    ;Vide!
        bra.s Cda5
; Une expression
Cda4:   bsr Evalue                      ;Evalue l'expression
        and.b #$c0,d2
Cda5:   move.w cmvqd0,d0
        move.b d2,d0                    ;Type de l'expression
        bsr OutWord
        move.l #$45fa0004,d0            ;LEA expression suivante,a2
        bsr OutLong
        move.w crts,d0                  ;Met un RTS
        bsr OutWord
        bsr GetByte
        cmp.b #",",d0
        beq.s Cda3
        subq.l #1,a6
; Pointe la ligne suivante de datas
        move.w cleaa2,d0                ;Retour: D0= 2
        bsr OutWord                     ;A2= adresse prochaine ligne
        bsr RelJsr
        move.l a5,OlData
        moveq #0,d0
        bset #30,d0
        bsr OutLong
        move.w cmvqd0,d0
        move.b #2,d0
        bsr OutWord
        move.w crts,d0
        bsr OutWord
; Fini!
        rts

;-----> RESTORE
CRest:  bsr Test0
        bsr Pair
        addq.l #4,a6
        bsr Finie
        bne.s CRe1
; Restore seul
        move.w #rest,d0
        bra CreFonc
; Restore EXPRESSION
CRe1:   bsr Constant
        beq.s CRe2
; Restore CONSTANTE
        move.w cleaa2,d0
        bsr OutWord
        bsr Reljsr
        move.l d1,d0            ;Loke le # de ligne
        cmp.l #65535,d0
        bcc CSynt
        bset #29,d0             ;Reloger ---> # de ligne
        bsr OutLong
        move.w #Rest+1,d0
        bra CreFonc     
; Restore EXPRESSION
CRe2:   move.w #Rest+2,d0
        bra CreFonc

;-----> READ
CRead:  bsr Test0
CRi1:   bsr GetByte
        cmp.b #$fa,d0
        bne CSynt
        bsr Vari
        bsr VarAd
        and.b #$c0,d2
        move.w cmvqd0,d0
        move.b d2,d0
        bsr OutWord
        move.w #Read,d0
        bsr CreFonc
        bsr GetByte
        cmp.b #",",d0
        beq.s CRi1
        subq.l #1,a6
        rts

;----------------------------------> LINE INPUT
CLinp:  lea cdin1,a0
        bra.s CIn1
;----------------------------------> INPUT
CInpu:  lea cdin2,a0
CIn1:   bsr Code0
        clr.w -(sp)
; Est-ce INPUT#
        bsr GetByte
        subq.l #1,a6
        cmp.b #"#",d0
        bne.s CIn5
;-->    Input en provenance de fichier
        addq.l #1,a6
        bsr expentier
        bsr GetByte
        cmp.b #",",d0
        bne csynt
        clr.w -(sp)
        bsr GetByte
        subq.l #1,a6
        cmp.b #$fa,d0
        beq.s CIn2
        bsr expentier
        move.w #1,(sp)
        bsr GetByte
        cmp.b #",",d0
        bne csynt
CIn2:   move.w cmvqd0,d0
        move.w (sp)+,d1
        move.b d1,d0
        bsr outword
        move.w #552,d0
        bsr crefonc 
        move.w #1,(sp)
        bsr GetByte
        subq.l #1,a6
        cmp.b #$fa,d0
        beq.s CIn7
        bra Csynt
;-->    Continue...
CIn5:   cmp.b #$fa,d0                   ;Variable?
        beq.s CIn6
        cmp.b #$fc,d0                   ;Chaine alphanumerique?
        bne CSynt
; Impression de la chaine
        bsr ExpAlpha
        move.w #input,d0
        bsr CreFonc
        bsr GetByte
        cmp.b #";",d0
        bne CSynt
        bsr GetByte
        subq.l #1,a6
        cmp.b #$fa,d0
        bne CSynt
        bra.s CIn7
; Met le point d'interrogation
CIn6:   move.w #input+1,d0
        bsr CreFonc
; Stocke la liste des variable ---> -(A6) / moveq #NB,d0
CIn7:   addq.l #1,a6
        clr.w -(sp)                     ;Nbre de variables
CIn8:   bsr vari                        ;cherche la variable
        bsr varad                       ;LEA varad,a0
        and.w #$c0,d2
        move.w d2,Cdin3+2               ;FLAG de la variable
        lea CdIn3,a0
        bsr Code1                       ;move.w flg,-(a6)/move.l a0,-(a6)
        addq.w #1,(sp)
        bsr GetByte
        cmp.b #",",d0                   ;encore une?
        bne.s CIn9
        bsr GetByte
        cmp.b #$fa,d0
        beq.s CIn8
        bra CSynt
CIn9:   subq.l #1,a6
        move.w cmvqd0,d0                ;Doke le MOVEQ
        move.w (sp)+,d1
        move.b d1,d0
        bsr Outword
; Appele la fonction
        move.w #Input+2,d0
        tst.w (sp)+
        beq Crefonc
        move.w #156,d0
        bra CreFonc

cdin1:  clr.w inputype(a5)
        dc.w 0
cdin2:  move.w #",",inputype(a5)
        dc.w 0
cdin3:  move.w #$ffff,-(a6)
        move.l a0,-(a6)
        dc.w $1111

;-----> INPUT$
CFInp:  bsr GetByte
        cmp.b #"(",d0
        bne csynt
        bsr GetByte
        subq.l #1,a6
        cmp.b #"#",d0
        beq.s cfi1
        subq.l #1,a6
        bsr fent
        move.w #553,d0
        bra crech
cfi1:   addq.l #1,a6
        move.w parenth(pc),-(sp)
        bsr evalue
        tst.w parenth
        bne csynt
        and.b #$c0,d2
        beq.s cfi2
        bmi ctype
        move.w #fltoint,d0
        bsr crefonc
cfi2:   bsr GetByte
        cmp.b #",",d0
        bne csynt
        bsr evalue
        cmp.w #-1,parenth
        bne csynt
        and.b #$c0,d2
        beq.s cfi3
        bmi ctype
        move.w #fltoint,d0
        bsr crefonc
cfi3:   move.w (sp)+,parenth
        move.w #554,d0
        bra crech

;-----> LPRINT
CLPrt:  bsr Test1
        lea Lp1,a0
        bra.s Cp0

Lp0:    clr.l PrintFlg(a5)      ;USING=0 / PRT=0 / TYPE=0
        move.l a4,PrintPos(a5)
        dc.w 0
Lp1:    clr.l PrintFlg(a5)      ;USING=0 / PRT=1 / TYPE=0
        move.b #1,ImpFlg(a5)
        move.l a4,PrintPos(a5)
        dc.w 0
Lp2:    clr.l PrintPos(a5)      ;Arret print
        dc.w 0
StUs:   move.b #1,UsingFlg(a5)  ;Demarrage du USING
        dc.w 0

;-----> PRINT
CPrnt:  bsr Test1
        lea Lp0,a0
Cp0:    bsr code0
        clr.w -(sp)             ;CODE fichier/normal
        bsr GetByte
        subq.l #1,a6
        cmp.b #"#",d0
        bne.s Cp2
; Impression dans un fichier
        addq.l #1,a6
        bsr ExpEntier           ;Prend le numero du fichier
        move.w #36,d0
        bsr crefonc
        bsr GetByte
        cmp.b #",",d0
        bne CSynt
        move.w #1,(sp)
; Prend les expressions
Cp2:    bsr GetByte
        tst.b d0
        beq.w Cp9
        cmp.b #":",d0
        beq.w Cp9
        cmp.b #$9b,d0
        beq.w Cp9
        cmp.b #$a0,d0           ;Code etendu de USING?
        bne.s Cp4
        bsr GetByte
        subq.l #1,a6
        cmp.b #$df,d0
        bne.s Cp4
; USING: prend la chaine et marque le using
        move.l #$49fa0002,d0    ;LEA adexp,A4
        bsr OutLong
        addq.l #1,a6
        bsr ExpAlpha            ;Stocke la chaine
        lea StUs,a0             ;USING en route!
        bsr Code0
        bsr GetByte
        cmp.b #";",d0
        bne CSynt
        bra.s Cp4a
; Prend la chaine et pousse
Cp4:    move.l #$49fa0002,d0    ;LEA adexp,A4
        bsr OutLong
        subq.l #1,a6
Cp4a:   bsr Evalue
        tst Parenth
        bne CSynt
        tst.b d2
        beq.s Cp5
        bmi.s Cp6
        moveq #PrtFl,d0         ;Chiffre FLOAT
        tst.w (sp)
        beq.s cp7
        move.w #547,d0          ;FLOAT---> FICHIER
        bra.s Cp7
Cp5:    moveq #PrtEn,d0         ;Chiffre ENTIER
        tst.w (sp)
        beq.s cp7
        move.w #546,d0          ;ENTIER---> FICHIER
        bra.s Cp7
Cp6:    moveq #PrtCh,d0         ;Chaine
        tst.w (sp)
        beq.s cp7
        move.w #548,d0
Cp7:    bsr CreFonc

; Prend le separateur
Cp8:    bsr GetByte
Cp9:    cmp.b #";",d0
        beq.s Cp13
        cmp.b #",",d0
        beq.s Cp11
        subq.l #1,a6
        tst.b d0
        beq.s Cp10
        cmp.b #":",d0
        beq.s Cp10
        cmp.b #$9b,d0
        beq.s Cp10
        bra CSynt
Cp10:   moveq #PrtRet,d0
        tst.w (sp)
        beq.s cp12
        move.w #550,d0          ;RETOUR---> fichier
        bra.s Cp12
Cp11:   moveq #PrtVir,d0
        tst.w (sp)
        beq.s cp12
        move.w #551,d0          ;VIRGULE---> Fichier
Cp12:   bsr CreFonc

; Encore quelque chose a imprimer?
Cp13:   bsr Finie
        bne Cp2
        addq.l #2,sp
        lea Lp2,a0              ;Sortie NORMALE du print
        bsr Code0
        rts


;-----> KEY SPEED
Ckys:   bsr test0
        lea parent2(pc),a2
        bsr parinst
        move.w #421,d0
        bra crefonc

;-----> FIX
CFix:   bsr test0
        bsr expentier
        move.w #422,d0
        bra crefonc

;-----> ICON$
CIc:    bsr fent
        move.w #423,d0
        bra crech

;-----> TAB
CTab:   bsr fent
        move.w #424,d0
        bra crech
 
;-----> CHARLEN
CChl:   bsr fent
        move.w #425,d0
        bra creent

;-----> CHARCOPY
parchc: dc.b en,to,en,1,1,0
CChc:   bsr test0
        lea parchc(pc),a2
        bsr parinst
        move.w #426,d0
        bra crefonc

;-----> WINDOPEN
CWdop:  bsr test0
        lea parent(pc),a2
        bsr parinst
        sub.w #5,d0
        bcs csynt
        cmp.w #3,d0
        bcc csynt
        add.w #427,d0
        bra crefonc

;-----> WINDOW
CWdo:   bsr test0
        lea parent(pc),a2 
        bsr parinst
        move.w cmvqd0,d1
        move.b d0,d1
        move.w d1,d0
        bsr outword
        move.w #432,d0
        bra crefonc

;-----> QWINDOW
CQwdo:  bsr test0
        bsr expentier
        move.w #433,d0
        bra crefonc

;-----> WINDON
CWdn:   move.w #434,d0
        bra creent

;-----> WINDMOVE
CWdm:   bsr test0
        lea parent2(pc),a2
        bsr parinst
        move.w #435,d0
        bra crefonc

;-----> WINDEL
CWdl:   bsr test0
        bsr expentier
        move.w #436,d0
        bra crefonc

;-----> LOCATE
CLoc:   bsr test0
        lea parent2(pc),a2
        bsr parinst
        move.w #437,d0
        bra crefonc

;-----> CURS X
CCx:    move.w #438,d0
        bra creent

;-----> CURS Y
CCy:    move.w #439,d0
        bra creent

;-----> XTEXT
CXt:    bsr fent
        move.w #440,d0
        bra creent

;-----> YTEXT
CYt:    bsr fent
        move.w #441,d0
        bra creent

;-----> XGRAPHIC
CXg:    bsr fent
        move.w #442,d0
        bra creent

;-----> YGRAPHIC
CYg:    bsr fent
        move.w #443,d0
        bra creent

;-----> DIVX
CDx:    move.w #444,d0
        bra creent

;-----> DIVY
CDy:    move.w #445,d0
        bra creent

;-----> SCREEN
CFTSc:  lea parent2(pc),a2
        bsr parfonc
        move.w #446,d0
        bra creent

;-----> PAPER
CPap:   bsr test0
        bsr expentier
        move.w #447,d0
        bra crefonc

;-----> PEN
CPen:   bsr test0
        bsr expentier
        move.w #448,d0
        bra crefonc

;-----> CUP
CCup:   bsr test0
        move.w #449,d0
        bra crefonc

;-----> CDOWN
CDwn:   bsr test0
        move.w #450,d0
        bra crefonc

;-----> CLEFT
CLft:   bsr test0
        move.w #451,d0
        bra crefonc

;-----> CRIGHT
CRit:   bsr test0
        move.w #452,d0
        bra crefonc

;-----> SCROLL
CScro:  bsr test0
        bsr onoff
        bmi gscro               ; SCROLLING GRAPHIQUE         
        bne.s sco
        move.w #453,d0
        bra crefonc
sco:    move.w #454,d0
        bra crefonc

;-----> SCROLL DOWN
CScd:   bsr test0
        move.w #455,d0
        bra crefonc

;-----> SCROLL UP
CScu:   bsr test0
        move.w #456,d0
        bra crefonc

;-----> HOME
CHome:  bsr test0
        move.w #457,d0
        bra crefonc

;-----> CLW
CClw:   bsr test0
        move.w #458,d0
        bra crefonc

;-----> SQUARE
CSqa:   bsr test0
        lea parent,a2
        bsr parinst
        cmp.w #3,d0
        bne csynt
        move.w #459,d0
        bra crefonc

;-----> CLS
parcls: dc.b en,1
        dc.b en,",",en,1
        dc.b en,",",en,",",en,",",en,to,en,",",en,1
        dc.b 1,0
CCls:   bsr test0
        bsr finie
        bne.s cls1
        move.w #460,d0
        bra crefonc 
cls1:   lea parcls,a2
        bsr parinst
        add.w #460,d0
        bra crefonc

;-----> INVERSE
CInv:   move.w #464,-(sp)
        bra.s Cun
;-----> SHADE
CSha:   move.w #466,-(sp)
        bra.s cun
;-----> UNDER
CUnd:   move.w #468,-(sp)
  
cun:    bsr test0
        bsr onoff
        bmi csynt
        bne.s cun1
        move.w (sp)+,d0
        bra crefonc
cun1:   move.w (sp)+,d0
        addq.w #1,d0
        bra crefonc

;-----> WRITING
CWr:    bsr test0
        bsr expentier
        move.w #470,d0
        bra crefonc

;-----> CENTER a$
CCen:   bsr test0
        bsr expalpha
        move.w #471,d0
        bra crefonc

;-----> TITLE a$
CTit:   bsr test0
        bsr expalpha
        move.w #472,d0
        bra crefonc

;-----> BORDER
CBor:   bsr test0
        bsr finie
        bne.s bor1
        move.w #473,d0
        bra crefonc
bor1:   bsr expentier
        move.w #474,d0
        bra crefonc

;-----> HARDCOY
CHard:  bsr test0
        move.w #475,d0
        bra crefonc

;-----> WINDCOPY
CWind:  bsr test0
        move.w #476,d0
        bra crefonc

;-----> MENU$(xx) MENU$(xx,yy)=
parmen: dc.b ch,1
        dc.b ch,1
        dc.b ch,",",en,",",en,1
        dc.b 1,0
CMenu:  move.w #1,Flagmenu
        bsr test0
        lea parent(pc),a2
        bsr parfonc
        cmp.w #2,d0
        beq.s cmn1
        cmp.b #1,d0
        bne csynt
; MENU$(XX)=
        move.w #564,-(sp)
        bra.s cmn4
; MENU$(xx,yy)
cmn1:   move.w #566,-(sp)
cmn2:   bsr onoff
        bmi.s cmn4
        bne.s cmn3
; MENU$(xx,yy) OFF
        clr.w d0
        move.w #567,(sp)
        bra.s cmn5
; MENU$(xx,yy) ON
cmn3:   move.w #568,(sp)
        clr.w d0
        bra.s cmn5
; MENU$(xx,yy)=
cmn4:   bsr GetByte
        cmp.b #$f1,d0
        bne csynt
        lea parmen(pc),a2
        bsr parinst
cmn5:   move.w cmvqd0,d1
        move.b d0,d1
        move.w d1,d0
        bsr outword
        move.w (sp)+,d0
        bra crefonc

;-----> MENU$ OFF / FREEZE / ON
Cmeno:  move.w #1,Flagmenu
        bsr test0
        bsr onoff
        bcs.s cmnf
        bmi csynt
        bne cmno
; Off
        move.w #569,d0
        bra crefonc
; Frezze
cmnf:   move.w #570,d0
        bra crefonc
; On / paper / pen
cmno:   clr.w -(sp)
        bsr finie
        beq.s cmno1
        lea parent(pc),a2
        bsr parinst
        cmp.w #2,d0
        bhi csynt
        move.w d0,(sp)
cmno1:  move.w (sp)+,d1
        move.w cmvqd0,d0
        move.b d1,d0
        bsr outword
        move.w #571,d0
        bra crefonc

;-----> CHOICE
CChoi:  move.w #573,d0
        bra creent
;-----> ITEM
CItem:  move.w #574,d0
        bra creent

;-----> ON MENU ON / OFF / GOTO ...
onmenu: bsr test0
        bsr onoff
        bmi.s onmn2
        bne.s onmn1
        move.w #575,d0          ;ON MENU OFF
        bra crefonc
onmn1:  move.w #576,d0          ;ON MENU ON
        bra crefonc
onmn2:  bcs csynt
        bsr GetByte
        cmp.b #$98,d0           ;veut un GOTO
        bne csynt
        bsr pair
        addq.l #4,a6
; Prend et compte les numeros de ligne
        clr.w -(sp)
onmn3:  bsr Constant
        beq CSynt
        cmp.l #65535,d1
        bcc CSynt
        move.w cmvima6,d0
        bsr outword
        move.l d1,d0
        bsr outlong
        add.w #1,(sp)
        bsr GetByte
        cmp.b #",",d0
        beq.s onmn3
        subq.l #1,a6
        move.w cmvqd0,d0
        move.w (sp)+,d1
        move.b d1,d0
        bsr outword
        move.w #577,d0
        bra crefonc

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | GRAPHIQUES                      |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------

;-----> =LOGIC
CFlog:  move.w #log,d0
        bra CreEnt
;-----> LOGIC=
CLog:   move.w #Log+1,-(sp)
        bra.s Cbk
;-----> =PHYSIC
CFPhy:  move.w #Phy,d0
        bra CreEnt
;-----> PHYSIC=
CPhy:   move.w #phy+1,-(sp)
        bra.s Cbk
;-----> =BACK
CFBak:  move.w #bak,d0
        bra CreEnt
;-----> BACK=
CBak:   move.w #Bak+1,-(sp)
Cbk:    bsr test0
        bsr GetByte
        cmp.b #$f1,d0
        bne CSynt
        bsr Expentier
        move.w (sp)+,d0
        bra CreFonc

;-----> = DEFAULT
CFDfo:  bsr GetByte
        move.b d0,d1
        move.w #DBak,d0
        cmp.b #$e2,d1
        beq CreEnt
        move.w #DLog,d0
        cmp.b #$c8,d1
        beq CreEnt 
        cmp.b #$e1,d1
        beq CreEnt
        bra CSynt

;-----> SCREEN SWAP
CScsw:  bsr Test0
        move.w #sswap,d0
        bra CreFonc

;-----> WAITVBL
CWvbl:  move.w #waitvbl,d0
        bsr crefonc
        bra Test1

;-----> WAIT xx
CWait:  bsr test0
        bsr expentier
        move.w #wait,d0
        bra crefonc

;-----> =XMOUSE
CFXm:   move.w #xmou,d0
        bra creent
;-----> XMOUSE=
CXm:    bsr test0
        bsr GetByte
        cmp.b #$f1,d0
        bne csynt
        bsr expentier
        move.w #Xmou+1,d0
        bra crefonc

;-----> =YMOUSE
CFYm:   move.w #YMou,d0
        bra creent
;-----> YMOUSE=
CYm:    bsr test0
        bsr GetByte
        cmp.b #$f1,d0
        bne csynt
        bsr expentier
        move.w #ymou+1,d0
        bra crefonc

;-----> =MOUSEKEY
CFKm:   move.w #KMou,d0
        bra CreEnt

;-----> =JOY
CJoy:   move.w #joy,d0
        bra Creent
;-----> =FIRE
CFire:  move.w #fire,d0
        bra creent
;-----> =JRIGHT
CJRig:  move.w #fire+1,d0
        bra creent
;-----> =JLEFT
CJLef:  move.w #fire+2,d0
        bra creent
;-----> =JDOWN
CJdow:  move.w #fire+3,d0
        bra creent
;-----> =JUP
CJUp:   move.w #fire+4,d0
        bra creent

;-----> =MODE
CFmod:  move.w #fmode,d0
        bra creent
;-----> MODE=
Cmod:   bsr test0
        bsr expentier
        move.w #smode,d0
        bra crefonc

;-----> INK
Cink:   bsr test0
        bsr expentier
        move.w #inkk,d0
        bra crefonc

;-----> GRWRITING
Cgrw:   bsr test0
        bsr expentier
        move.w #grw,d0
        bra crefonc

;-----> SET LINE
CSli:   bsr test0
        lea parent,a2
        bsr parinst
        cmp.w #4,d0
        bne CSynt
        move.w #sline,d0
        bra crefonc

;-----> SET MARK
CSma:   bsr test0
        lea parent2,a2
        bsr parinst
        move.w #smark,d0
        bra crefonc

;-----> SET PAINT
CSpa:   bsr test0
        lea parent,a2 
        bsr parinst
        cmp.w #3,d0
        bne csynt
        move.w #spaint,d0
        bra crefonc

;-----> SET PATTERN
CSpt:   bsr test0
        bsr evalue
        tst.b d2
        bmi.s Cpat2
        beq.s Cpat1
        move.w #fltoint,d0
        bsr crefonc
Cpat1:  move.w #spat,d0
        bra crefonc
Cpat2:  move.w #spat+1,d0
        bra crefonc

;-----> CLIP OFF
parcli: dc.b en,",",en,to,en,",",en,1
        dc.b 1,0
CClip:  bsr test0
        bsr onoff
        bmi.s clp
        bne CSynt
        move.w #clip,d0
        bra crefonc
clp:    lea parcli,a2
        bsr parinst
        move.w #clip+1,d0
        bra crefonc

;-----> AUTOBACK
CAuto:  bsr test0
        bsr onoff
        bmi csynt
        bne.s cao
        move.w #abak,d0
        bra crefonc
cao:    move.w #abak+1,d0
        bra crefonc

;-----> PLOT 
CPlot:  bsr test0
        lea parent,a2
        bsr parinst
        cmp.w #3,d0
        beq.s cpl
        cmp.w #2,d0
        bne csynt
        move.w #plot,d0
        bra crefonc
cpl:    move.w #plot+1,d0
        bra crefonc

;-----> POINT
CPoin:  lea parent2,a2
        bsr parfonc
        move.w #point,d0
        bra creent

;-----> PAINT
CPain:  bsr test0
        lea parent2,a2
        bsr parinst
        move.w #paint,d0
        bra crefonc

;-----> POLYPARS ---> empile les parametres D0= nb coords / D1= pas debut?
polyp:  bsr test0
        clr.w -(sp)
        clr.w -(sp)
        bsr GetByte
        subq.l #1,a6
        cmp.b #$80,d0
        bne.s cpp1
        addq.l #1,a6
        add.w #1,(sp)
        move.w #1,2(sp)
cpp1:   bsr expentier
        bsr GetByte
        cmp.b #",",d0
        bne csynt
        bsr expentier
        add.w #1,(sp)
        bsr GetByte
        cmp.b #$80,d0
        beq.s cpp1
        subq.l #1,a6
        move.w cmvqd0,d0
        move.w (sp),d1
        move.b d1,d0
        bsr outword
        move.w cmvqd1,d0
        move.w 2(sp),d1
        move.b d1,d0
        bsr outword
        move.w (sp)+,d0
        move.w (sp)+,d1
        rts

;-----> DRAW
cdro:   bsr polyp
        cmp.w #2,d0
        bne csynt
        tst.w d1
        bne.s cdr
        move.w #draw,d0
        bra crefonc
cdr:    move.w #draw+1,d0
        bra crefonc

;-----> POLYLINE
Cpoli:  bsr polyp
        move.w #poli,d0
        bra crefonc

;-----> POLYGONE
Cpogo:  bsr polyp
        move.w #pogo,d0
        bra crefonc

;-----> POLYMARK
Cpoma:  bsr test0
        clr.w -(sp)
pm1:    bsr expentier
        bsr GetByte
        cmp.b #",",d0
        bne csynt
        bsr expentier
        add.w #1,(sp)
        bsr GetByte
        cmp.b #";",d0
        beq.s pm1
        subq.l #1,a6
        move.w cmvqd0,d0
        move.w (sp)+,d1
        move.b d1,d0
        bsr outword
        move.w #poma,d0
        bra crefonc

;-----> BAR
CBar:   bsr polyp
        cmp.w #2,d0
        bne csynt
        move.w #bar,d0
        bra crefonc

;-----> RBOX
CRBox:  bsr polyp
        cmp.w #2,d0
        bne csynt
        move.w #rbox,d0
        bra crefonc

;-----> RBAR
CRBar:  bsr polyp
        cmp.w #2,d0
        bne csynt
        move.w #rbar,d0
        bra crefonc

;-----> BOX
CBox:   bsr polyp
        cmp.w #2,d0
        bne csynt
        move.w #box,d0
        bra crefonc

;-----> ARC
CArc:   move.w #arc,-(sp)
        bra.s Caa
;-----> PIE
CPie:   move.w #Pie,-(sp)
caa:    bsr test0
        lea parent,a2
        bsr parinst
        cmp.w #5,d0
        bne csynt
        move.w (sp)+,d0
        bra crefonc

;-----> EARC
CEarc:  move.w #earc,-(sp)
        bra.s cab
;-----> EPPIE
CEpie:  move.w #epie,-(sp)
cab:    bsr test0
        lea parent,a2
        bsr parinst
        cmp.w #6,d0
        bne csynt
        move.w (sp)+,d0
        bra crefonc

;-----> CIRCLE
ccir:   bsr test0
        lea parent,a2
        bsr parinst
        cmp.w #3,d0
        bne csynt
        move.w #circ,d0
        bra crefonc

;-----> ELLIPSE
cell:   bsr test0
        lea parent,a2
        bsr parinst
        cmp.w #4,d0
        bne csynt
        move.w #ell,d0
        bra crefonc

;-----> CURS ON / OFF
CCur:   bsr test0
        bsr onoff
        bmi csynt
        bne.s ccu
        move.w #curs,d0
        bra crefonc
ccu:    move.w #curs+1,d0
        bra crefonc

;-----> SET CURS
CScur:  bsr test0
        lea parent2,a2
        bsr parinst
        move.w #curs+2,d0
        bra crefonc

;-----> PREND LES PARAMETRES PALETTE
GetPal: clr.w d1
        moveq #0,d2
        clr.w d3
gp1:    bsr finie
        beq.s gp3
        bsr GetByte
        subq.l #1,a6
        cmp.b #",",d0
        beq.s gp2
        movem.w d1-d3,-(sp)
        bsr expentier
        movem.w (sp)+,d1-d3
        bset d1,d2
        addq.w #1,d3
gp2:    addq.w #1,d1
        cmp.w #16,d1
        beq.s gp3
        bsr finie
        beq.s gp3
        bsr GetByte
        cmp.b #",",d0
        beq.s gp1
        bne csynt
gp3:    move.w cmvqd0,d0
        move.b d1,d0
        bsr outword
        move.l cmvd1,d0
        move.w d2,d0
        bsr outlong
        move.w cmvqd2,d0
        move.b d3,d0
        bsr outword
        rts

;-----> PALETTE 
CPal:   bsr test0
        bsr GetPal
        move.w #Pal,d0
        bra crefonc

;-----> GET PALETTE (ecran)
CGPal:  bsr test0
        bsr FEnt
        move.w #pal+3,d0
        bra crefonc

;-----> COLOUR xx,nn
parent2:dc.b en,",",en,1,1,0
CCol:   bsr test0
        lea parent2,a2
        bsr parinst
        move.w #col,d0
        bra crefonc

;-----> = COLOUR(xx)
CFCol:  bsr fent
        move.w #col+1,d0
        bra creent

;-----> SHOW / SHOW ON
CSho:   move.w #show,-(sp)
        bra.s cho
;-----> HIDE / HIDE ON
CHid:   move.w #show+2,-(sp)
Cho:    bsr test0
        bsr finie
        beq.s cho1
        bsr onoff
        bmi csynt
        beq csynt
        add.w #1,(sp)
Cho1:   move.w (sp)+,d0
        bra crefonc

;-----> CHANGE MOUSE
CChgm:  bsr test0
        bsr expentier
        move.w #show+4,d0
        bra crefonc

;-----> LIMIT MOUSE
CLimm:  bsr finie
        beq.s Clm
        lea parcli,a2
        bsr parinst
        move.w #show+6,d0
        bra crefonc
clm:    move.w #show+5,d0
        bra crefonc

;-----> SYNCHRO / On / Off
CSync:  move.w #Sync,-(sp)
        bra.s CSy
;-----> UPDATE / On / Off
CUpd:   move.w #Upd,-(sp)
CSy:    bsr test0
        bsr onoff
        bmi.s csy2
        beq.s csy1
        add.w #1,(sp)
csy1:   add.w #1,(sp)
csy2:   bcs csynt
        move.w (sp)+,d0
        bra crefonc
        
;-----> REDRAW
Credr:  bsr test0
        move.w #redr,d0
        bra crefonc

;-----> SPRITE
CSpr:   bsr test0
        bsr onoff
        bmi.s csp5
        bne.s csp0
        clr.w -(sp)
        bra.w csp1
csp0:   move.w #1,-(sp)
csp1:   bsr finie
        bne.s csp2
        move.w #spr,d0          ;SPRITE ON/OFF
        add.w (sp)+,d0
        bra crefonc
csp2:   bsr expentier           ;SPRITE ON/OFF xx
        move.w #spr+2,d0
        add.w (sp)+,d0
        bra crefonc
csp5:   bcs csynt               ;SPRITE X,Y,Z,[N]
        lea parent,a2
        bsr parinst
        cmp.w #4,d0
        beq.s csp6
        cmp.w #3,d0
        bne csynt
        move.w #spr+4,d0
        bra crefonc
csp6:   move.w #spr+5,d0
        bra crefonc

;-----> MOVE ON/OFF/FREEZE [xx]
CMve:   move.w #mve,-(sp)
        bra.s mv0
;-----> ANIM ON/OFF/FREEZE [xx]
parani: dc.b en,",",ch,1,1,0
CAni:   move.w #ani,-(sp)
mv0:    bsr test0
        bsr onoff
        bcs.s mv1
        bmi.s mv5
        beq.s mv2               ;Off
        add.w #1,(sp)           ;On
        bra.s mv2
mv1:    add.w #2,(sp)           ;Freeze
mv2:    bsr finie
        bne.s mv3
        move.w (sp)+,d0          ;Pas de param
        bra crefonc
mv3:    bsr expentier           ;Param!    
        move.w (sp)+,d0
        addq.w #3,d0
        bra crefonc
mv5:    cmp.w #ani,(sp)+        ;ANIM seul avec params!
        bne csynt
        lea parani,a2
        bsr parinst
        move.w #ani+6,d0
        bra crefonc

;-----> MOVEX
Cmvx:   move.w #mvx,-(sp)
        bra.s mvx1
;-----> MOVEY
Cmvy:   move.w #mvx+1,-(sp)
mvx1:   bsr test0
        lea parani,a2
        bsr parinst
        move.w (sp)+,d0
        bra crefonc

;-----> MOVON
Cmvo:   bsr fent
        move.w #mvx+2,d0
        bra creent

;-----> COLLIDE
CColi:  lea parent,a2
        bsr parfonc
        cmp.w #3,d0
        bne csynt
        move.w #coli,d0
        bra creent

;-----> DETECT(cc)
CDtct:  bsr fent
        move.w #dtct,d0
        bra creent

;-----> FREEZE
Cfrz:   bsr test0
        move.w #frz,d0
        bra crefonc

;-----> UNFREEZE
CUfrz:  bsr test0
        move.w #frz+1,d0
        bra crefonc

;-----> XPSPRITE
CXsp:   bsr fent
        move.w #xsp,d0
        bra creent

;-----> YSPRITE
CYSp:   bsr fent
        move.w #xsp+1,d0  
        bra creent

;-----> LIMIT SPRITE
CLsp:   bsr test0
        bsr finie
        beq.s clsp1
        lea parcli,a2
        bsr parinst
        move.w #lsp+1,d0
        bra crefonc
clsp1:  move.w #lsp,d0
        bra crefonc

;-----> PUT SPRITE xx
CPsp:   bsr test0
        bsr expentier
        move.w #psp,d0
        bra crefonc

;-----> GET SPRITE
CGsp:   bsr test0
        lea parent,a2
        bsr parinst
        cmp.w #4,d0
        beq.s gsp1
        cmp.w #3,d0
        bne csynt
        move.w #gsp,d0
        bra crefonc
gsp1:   move.w #gsp+1,d0
        bra crefonc

;-----> PRIORITY ON/OFF
Cpri:   bsr test0
        bsr onoff
        bmi csynt
        bne.s cpn
        move.w #pri,d0
        bra crefonc
cpn:    move.w #pri+1,d0
        bra crefonc

;-----> SCREEN COPY
parscc: dc.b en,to,en,1
        dc.b en,",",en,",",en,",",en,",",en,to,en,",",en,",",en,1
        dc.b 1,0
CScc:   bsr Test0
        lea parscc(pc),a2
        bsr parinst
        cmp.w #1,d0
        beq.s Csc1
        cmp.w #2,d0
        bne csynt
        move.w #scc+1,d0
        bra crefonc
csc1:   move.w #scc,d0
        bra crefonc

;-----> =SCREEN$
parsc:  dc.b en,",",en,",",en,to,en,",",en,1,1,0
CFSc:   lea parsc(pc),a2
        bsr parfonc
        move.w #scr,d0
        bra crech
;-----> SCREEN$=
CSc:    bsr test0
        lea parent(pc),a2
        bsr parfonc
        cmp.w #3,d0
        bne csynt
        bsr GetByte
        cmp.b #$f1,d0
        bne csynt
        bsr expalpha
        move.w #scr+1,d0
        bra crefonc

;-----> DEFSCROLL
pardsc: dc.b en,",",en,",",en,to,en,",",en,",",en,",",en,1,1,0
CDSc:   bsr test0
        lea pardsc(pc),a2
        bsr parinst
        move.w #dsc,d0
        bra crefonc
;-----> SCROLL
GScro:  bsr expentier
        move.w #dsc+1,d0
        bra crefonc

;-----> RESET ZONE
CRzo:   bsr test0
        bsr finie
        beq.s rez1
        bsr expentier
        move.w #zone+1,d0
        bra crefonc
rez1:   move.w #zone,d0
        bra crefonc
;-----> SET ZONE
parzo:  dc.b en,",",en,",",en,to,en,",",en,1,1,0
CSzo:   bsr test0
        lea parzo(pc),a2
        bsr parinst
        move.w #zone+2,d0
        bra crefonc
;-----> = ZONE
CZo:    bsr fent
        move.w #zone+3,d0
        bra creent

;-----> REDUCE
CRedu:  bsr test0
        bsr GetByte
        subq.l #1,a6
        cmp.b #$80,d0
        bne.s cru2
; To
        addq.l #1,a6
        lea parent,a2
        bsr parinst
        cmp.w #5,d0
        beq.s cru1
        cmp.w #4,d0
        bne csynt
        move.w #rd,d0
        bra crefonc
cru1:   move.w #rd+2,d0
        bra crefonc
; ecran To
cru2:   bsr expentier
        bsr GetByte
        cmp.b #$80,d0
        bne csynt
        lea parent,a2
        bsr parinst
        cmp.w #5,d0
        beq.s cru6
        cmp.w #4,d0
        bne csynt
        move.w #rd+1,d0
        bra crefonc
cru6:   move.w #rd+3,d0
        bra crefonc

;-----> ZOOM
parzoo: dc.b en,",",en,",",en,",",en,to,en,",",en,",",en,",",en,1
        dc.b en,",",en,",",en,",",en,",",en,to,en,",",en,",",en,",",en,1
        dc.b en,",",en,",",en,",",en,to,en,",",en,",",en,",",en,",",en,1
        dc.b en,",",en,",",en,",",en,",",en
        dc.b to,en,",",en,",",en,",",en,",",en,1
        dc.b 1,0
CZoo:   bsr test0
        lea parzoo(pc),a2
        bsr parinst
        add.w #zm-1,d0
        bra crefonc

;-----> APPEAR
CApp:   bsr test0
        lea parent(pc),a2
        bsr parinst
        cmp.w #2,d0
        beq.s cap1
        move.w #app,d0
        bra crefonc
cap1:   move.w #app+1,d0
        bra crefonc

;-----> FADE
CFad:   bsr test0
        bsr expentier
        bsr GetByte
        cmp.b #",",d0
        beq.s CFa2
        cmp.b #$80,d0
        beq.s CFa1
        subq.l #1,a6
        move.w #fad,d0
        bra crefonc
CFa1:   bsr expentier
        move.w #fad+1,d0
        bra crefonc
CFa2:   bsr getpal
        move.w #fad+2,d0
        bra crefonc

;-----> FLASH
CFlas:  bsr test0
        bsr onoff
        bmi.s CFl1
        bne csynt
        move.w #flas,d0
        bra crefonc
CFl1:   bcs csynt
        lea parani(pc),a2
        bsr parinst
        move.w #flas+1,d0
        bra crefonc

;-----> SHIFT OFF / xx
CShif:  bsr test0
        bsr onoff
        bmi.s csh1
        bne csynt
        move.w #shif,d0
        bra crefonc
csh1:   bcs csynt
        lea parent(pc),a2
        bsr parinst
        cmp.w #2,d0
        bhi csynt
        add.w #shif,d0
        bra crefonc

;-----> DEFAULT
CDefo:  bsr test0
        tst.w FlagGem
        beq.s CDefo1
; Si GEM
        move.w #defo,d0
        bra crefonc
; Si STOS
CDefo1: move.w #580,d0
        bra crefonc


;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | MUSIQUE ET SONS                 |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------

;-----> MUSIC
CMus:   bsr test0
        bsr onoff
        bmi.s mu2
        bne.s mu1
        move.w #mus,d0          ;OFF
        bra crefonc
mu1:    move.w #mus+2,d0        ;ON
        bra crefonc
mu2:    bcc.s mu3
        move.w #mus+1,d0        ;FREEZE
        bra crefonc
mu3:    bsr expentier
        move.w #mus+3,d0
        bra crefonc

;-----> PVOICE
CPvoi:  bsr fent
        move.w #pvoi,d0
        bra creent

;-----> VOICE
CVoi:   bsr test0
        bsr onoff
        bmi csynt
        bne.s vo2
; OFF
        bsr finie
        bne.s vo0
        move.w #voi,d0
        bra crefonc
vo0:    lea parent(pc),a2
        bsr parinst
        cmp.w #2,d0
        beq.s vo1
        cmp.w #1,d0
        bne csynt
        move.w #voi+2,d0
        bra crefonc
vo1:    move.w #voi+4,d0
        bra crefonc
; ON
vo2:    bsr finie
        bne.s vo3
        move.w #voi+1,d0
        bra crefonc
vo3:    bsr expentier
        move.w #voi+3,d0
        bra crefonc
    
;-----> TEMPO
CTemp:  bsr test0
        bsr expentier
        move.w #temp,d0
        bra crefonc

;-----> TRANSPOSE
CTran:  bsr test0
        bsr expentier
        move.w #tran,d0
        bra crefonc

;-----> SHOOT
CShoo:  bsr test0
        move.w #shoo,d0
        bra crefonc

;-----> EXPLODE
CExpl:  bsr test0
        move.w #expl,d0
        bra crefonc

;-----> PING
CPing:  bsr test0
        move.w #ping,d0
        bra crefonc

;-----> ENVEL
CEnv:   bsr test0
        lea parent2(pc),a2
        bsr parinst
        move.w #env,d0
        bra crefonc

;-----> VOLUME
CVol:   bsr test0
        lea parent,a2
        bsr parinst
        cmp.w #2,d0
        beq.s cvo1
        cmp.w #1,d0
        bne csynt
        move.w #vol,d0
        bra crefonc
cvo1:   move.w #vol+1,d0
        bra crefonc

;-----> NOISE
CNoi:   bsr test0
        lea parent,a2
        bsr parinst
        cmp.w #2,d0
        beq.s cn1
        cmp.w #1,d0
        bne csynt
        move.w #noi,d0
        bra crefonc
cn1:    move.w #noi+1,d0
        bra crefonc

;-----> NOTE
CNaut:  bsr test0
        lea parent,a2
        bsr parinst
        cmp.w #3,d0
        beq.s cn2
        cmp.w #2,d0
        bne csynt
cn2:    move.w d0,d1
        move.w cmvqd0,d0
        move.b d1,d0
        bsr outword
        move.w #naut,d0
        bra crefonc

;-----> =PSG
CFpsg:  bsr fent
        move.w #psg,d0
        bra creent

;-----> PSG=
Cpsg:   bsr test0
        bsr fent
        bsr GetByte
        cmp.b #$f1,d0
        bne csynt
        bsr expentier
        move.w #psg+1,d0
        bra crefonc

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | FICHIERS                        |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------

;-----> RUN
CRun:   bsr Finie
        bne.s CRun1
; Run seul
        move.w #581,d0
        bra crefonc
; Run NOM$
CRun1:  bsr expalpha
        move.w #582,d0
        bra crefonc

;-----> LOAD / SAVE
ParLd:  dc.b ch,1
        dc.b ch,",",en,1
        dc.b ch,",",en,",",en,1
        dc.b 1,0
CLoad:  move.w #488,-(sp)
        bra.s Clo
CSave:  move.w #496,-(sp)

Clo:    bsr test0
        lea parld(pc),a2
        bsr parinst
        move.w cmvqd0(pc),d1
        move.b d0,d1
        move.w d1,d0
        bsr outword
        move.w (sp)+,d0
        bra crefonc

;-----> BLOAD
Parblo: dc.b ch,",",en,1,1,0
CBlo:   bsr test0
        lea parblo(pc),a2
        bsr parinst
        move.w #494,d0
        bra crefonc

;-----> BSAVE
parbsa: dc.b ch,",",en,to,en,1,1,0
CBsa:   bsr test0
        lea parbsa(pc),a2
        bsr parinst
        move.w #495,d0
        bra crefonc

;-----> Getfile number
getf:   bsr GetByte
        cmp.b #"#",d0
        beq.s gf1
        subq.l #1,a6
gf1:    bsr expentier
        rts
;-----> idem
fgetf:  move.w parenth,-(sp)
        bsr GetByte
        cmp.b #"(",d0
        bne csynt
        bsr GetByte
        cmp.b #"#",d0
        beq.s gf2
        subq.l #1,a6
gf2:    bsr evalue
        cmp.w #-1,parenth
        bne csynt
        tst.b d2
        bmi CType
        beq.s gf3
        move.w #inttofl,d0
        bsr crefonc
gf3:    move.w (sp)+,parenth
        rts

;-----> OPENIN
COpin:  bsr test0
        bsr getf
        bsr GetByte
        cmp.b #",",d0
        bne csynt
        bsr expalpha
        move.w #503,d0
        bra crefonc  
;-----> OPENOUT
COpou:  bsr test0
        bsr getf
        bsr GetByte
        cmp.b #",",d0
        bne csynt
        bsr expalpha
        clr.w -(sp)
        bsr finie
        beq.s Cop1
        bsr GetByte
        cmp.b #",",d0
        bne csynt
        bsr expentier
        move.w #1,(sp)
Cop1:   move.w cmvqd0,d0
        move.w (sp)+,d1
        move.b d1,d0
        bsr outword
        move.w #504,d0
        bra crefonc

;-----> OPEN #xx,"llk"[,a$]
COpen:  bsr test0
        bsr getf
        bsr GetByte
        cmp.b #",",d0
        bne csynt
        bsr expalpha
        clr.w -(sp)
        bsr finie
        beq.s Cop2
        bsr GetByte
        cmp.b #",",d0
        bne csynt
        bsr expalpha
        move.w #1,(sp)
Cop2:   move.w cmvqd0,d0
        move.w (sp)+,d1
        move.b d1,d0
        bsr outword
        move.w #505,d0
        bra crefonc

;-----> PORT(xx)
CPort:  bsr fgetf
        move.w #507,d0
        bra creent

;-----> CLOSE
CClo:   bsr test0
        bsr finie
        bne.s CClo1
        move.w #508,d0
        bra crefonc
CClo1:  bsr getf
        move.w #509,d0
        bra crefonc

;-----> LOF
CLof:   bsr fgetf
        move.w #513,d0
        bra creent

;-----> EOF
CEof:   bsr fgetf
        move.w #514,d0
        bra creent

;-----> =POF
CFPof:  bsr fgetf
        move.w #515,d0
        bra creent
;-----> POF=
CPof:   bsr test0
        bsr fgetf
        bsr GetByte
        cmp.b #$f1,d0
        bne csynt
        bsr expentier
        move.w #516,d0
        bra crefonc

;-----> FIELD
CFiel:  bsr test0
        bsr getf
        bsr GetByte
        cmp.b #",",d0
        bne csynt
        clr.w -(sp)
CFld:   bsr expentier
        bsr GetByte
        cmp.b #$a0,d0
        bne csynt
        bsr GetByte
        cmp.b #$d3,d0
        bne csynt
        bsr GetByte
        cmp.b #$fa,d0 
        bne csynt
        bsr vari
        tst.b d2
        bpl CType
        btst #5,d2
        bne CSynt
        bsr varad
        lea cfield(pc),a0
        bsr code0
        add.w #1,(sp)
        bsr GetByte
        cmp.b #",",d0
        beq.s CFld
        subq.l #1,a6 
        move.w cmvqd0,d0
        move.w (sp)+,d1
        move.b d1,d0
        bsr outword
        move.w #517,d0
        bra crefonc
CField: move.l a0,-(a6)
        dc.w 0

;-----> GET #xx,nn
CGet:   bsr test0
        bsr getf
        bsr GetByte
        cmp.b #",",d0
        bne csynt
        bsr expentier
        move.w #520,d0
        bra crefonc
;-----> PUT #xx,nn
CPut:   bsr test0
        bsr getf
        bsr GetByte
        cmp.b #",",d0
        bne csynt
        bsr expentier
        move.w #521,d0
        bra crefonc

;-----> DFREE
CDfri:  move.w #522,d0
        bra creent
       
;-----> MKDIR
CMkd:   bsr test0
        bsr expalpha
        move.w #523,d0
        bra crefonc
;-----> RMDIR
CRmd:   bsr test0
        bsr expalpha
        move.w #524,d0
        bra crefonc

;-----> DIR$="
CDyr:   bsr test0
        bsr GetByte
        cmp.b #$f1,d0
        bne csynt
        bsr expalpha
        move.w #525,d0
        bra crefonc
;-----> =DIR$
CFDyr:  move.w #526,d0
        bra crech

;-----> PREVIOUS
CPrev:  bsr test0
        move.w #527,d0
        bra crefonc

;-----> =DRIVE$
CFDrD:  move.w #528,d0
        bra crech
;-----> =DRIVE
CFDr:   move.w #529,d0
        bra creent
;-----> DRIVE=
CDri:   bsr GetByte
        cmp.b #$f1,d0
        bne csynt
        bsr expentier
        move.w #530,d0
        bra crefonc
;-----> DRIVE$=        
CDriD:  bsr GetByte
        cmp.b #$f1,d0
        bne csynt
        bsr expalpha
        move.w #531,d0
        bra crefonc

;-----> DRVMAP
CDMap:  move.w #533,d0
        bra creent

;-----> DIRFIRST$
pardir: dc.b ch,",",en,1,1,0
CDirF:  lea pardir(pc),a2
        bsr parfonc
        move.w #534,d0
        bra crech
;-----> DIRNEXT$
CDirN:  move.w #535,d0
        bra crech

;-----> KILL
CKill:  bsr test0
        bsr expalpha
        move.w #537,d0
        bra crefonc
;-----> RENAME 
Paren:  dc.b ch,to,ch,1,1,0
CRena:  bsr test0
        lea paren(pc),a2
        bsr parinst
        move.w #538,d0
        bra crefonc

;-----> DIRW
CDirW:  move.w #541,-(sp)
        bra.s Dir
;-----> LDIR
CLDir:  move.w #542,-(sp)
        bra.s dir
;-----> DIR
CDir:   move.w #543,-(sp)
Dir:    clr.w -(sp)
        bsr finie
        beq.s Dir1
        bsr expalpha
        move.w #1,(sp)
Dir1:   move.w cmvqd0,d0
        move.w (sp)+,d1
        move.b d1,d0
        bsr outword
        move.w (sp)+,d0
        bra crefonc

;-----> FILE SELECT$
parfsl: dc.b ch,1
        dc.b ch,",",ch,1
        dc.b ch,",",ch,",",en,1
        dc.b 1,0
CFsel:  lea parfsl(pc),a2
        bsr parfonc
        add.w #555-1,d0
        bra crech

;----------------------------------> Routines annexes
;-----> Rend l'adresse paire
Pair:   move.w d0,-(sp)
        move.w a6,d0
        btst #0,d0
        beq.s Per
        addq.l #1,a6
Per:    move.w (sp)+,d0
        rts

;-----> Prend un octet du programme (A6)
GetByte:tst.w NomIn
        bne.s gdb
        move.b (a6)+,d0
        rts
gdb:    move.l a0,-(sp)
        bsr SoDisk
        move.b (a0),d0
        addq.l #1,a6
        move.l (sp)+,a0
        rts

;-----> Prend un MOT du programme (A6)
GetWord:tst.w NomIn
        bne.s gdw
        move.w (a6)+,d0
        rts
gdw:    move.l a0,-(sp)
        bsr SoDisk
        move.w (a0),d0
        addq.l #2,a6
        move.l (sp)+,a0
        rts

;-----> Prend un MOTLONG du programme (A6)
GetLong:tst.w NomIn
        bne.s gdl
        move.l (a6)+,d0
        rts
gdl:    move.l a0,-(sp)
        bsr SoDisk
        move.l (a0),d0
        addq.l #4,a6
        move.l (sp)+,a0
        rts

;-----> Gestion du buffer entree SOURCE
SoDisk: cmp.l DebBso(pc),a6
        bcs.s SoDi1
        lea 4(a6),a0
        cmp.l FinBso(pc),a0
        bcc.s SoDi1
; Adresse RELATIVE dans le buffer
        move.l a6,a0
        sub.l DebBso(pc),a0
        add.l BufSou(pc),a0
        rts
; Change la position du buffer
SoDi1:  movem.l d0-d7/a0-a6,-(sp)
; Bouge le bout
        move.l DebBso(pc),d0
        move.l FinBso(pc),d1
        move.l MaxBso(pc),d2
        sub.l BordBso(pc),d2
        lea 4(a6),a0
SoDi3:  cmp.l d0,a6
        bcs.s SoDi4
        cmp.l d1,a0
        bcs.s SoDi5
; Monte le buffer
        add.l d2,d0
        add.l d2,d1
        bra.s SoDi3
; Descend le buffer
SoDi4:  sub.l d2,d0
        sub.l d2,d1
        bra.s SoDi3
SoDi5:  move.l d0,DebBso
        move.l d1,FinBso
        bsr LoadBso
; Trouve l'adresse relative
        movem.l (sp)+,d0-d7/a0-a6
        move.l a6,a0
        sub.l DebBso(pc),a0
        add.l BufSou,a0
        rts

;-----> Charge le buffer SOURCE
LoadBso:moveq #30,d7
        move.l DebBso(pc),d0
        bsr LSeek
; Sauve l'ancien
        move.l BufSou(pc),a0
        move.l TopSou(pc),d0
        sub.l DebBso(pc),d0
        cmp.l MaxBso(pc),d0
        bcs.s SoDi2
        move.l FinBso(pc),d0
        sub.l DebBso(pc),d0
SoDi2:  bsr Load
        rts

;-----> Cree un appel a la routine #D0
CreJmp: sub.l a0,a0
        move.w d0,a0
        move.w CJmp,d0
        bra.s CreF
;-----> Cree un appel a un sous programme #D0
CreFonc:sub.l a0,a0
        move.w d0,a0
        move.w CJsr,d0          ;Dans le source: JSR
CreF:   bsr OutWord  
        bsr RelJsr              ;Pointe la table de relocation ici 
        move.l a0,d0
        bsr OutLong             ;#ROUTINE.L 
; Met le flag dans RoutIn
        move.w a0,d0
        lsl.w #2,d0
        move.l RoutIn,a0
        move.l #1,0(a0,d0.w)     ;Force la recopie de la routine
        lsr.w #2,d0
        rts

;-----> Reloge un JSR ou une CONSTANTE ALPHANUMERIQUE
RelJsr: move.l d0,-(sp)
        move.l a5,d0
        sub.l OldRel,d0
ReJ1:   cmp.w #126,d0
        bls.s ReJ2
        bsr OutRel1             ;>126: met 1 et boucle
        sub.w #126,d0
        bra.s ReJ1
ReJ2:   bclr #7,d0              ;Flag #7=0 ---> JSR ou CHAINE
        bsr OutRel              ;<126: met le chiffre
        move.l a5,OldRel
        move.l (sp)+,d0
        rts
; Poke un octet dans la table de relocation
OutRel: tst.w Passe
        beq.s OutR
        move.b d0,(a4)+
        rts
OutRel1:tst.w Passe
        beq.s OutR
        move.b #1,(a4)+
        rts
OutR:   addq.l #1,a4
        rts

;-----> Copie la portion de code A0 dans le source (RELOGEABLE)
Code1:  movem.l a0/d0/d1,-(sp)
        move.w #$1111,d1        ;Termine par 1
        bra.s Cod
Code0:  movem.l a0/d0/d1,-(sp)
        move.w #$0000,d1        ;Termine par 0
Cod:    move.w (a0)+,d0
        cmp.w d0,d1
        beq.s CodFin
        bsr OutWord
        bra.s Cod
CodFin: movem.l (sp)+,a0/d0/d1
        rts

;-----> Copie la portion de code A0-->A1 dans le source (RELOGEABLE)
CodeF:  move.w (a0)+,d0
        bsr OutWord
        cmp.l a1,a0
        bcs.s CodeF
        rts
        
;-----> Poke un OCTET dans l'objet
OutByte:tst.w Passe
        beq.s PaOB
        tst.w NomOut
        beq.s PaDB
; Sur disque
        move.l a0,-(sp)
        bsr ObDisk
        move.b d0,(a0)+
        addq.l #1,a5
        move.l (sp)+,a0
        cmp.l TopOb(pc),a5
        bcs.s PamB
        move.l a5,TopOb
PamB:   rts
; En memoire
PaDB:   move.b d0,(a5)+         ;Poke
	cmp.l TopWork(pc),a5
	bcc Cout
        rts
; Passe 0
PaOB:   addq.l #1,a5
        rts 
       
;-----> Poke un MOT dans l'objet
OutWord:tst.w Passe
        beq.s PaOW
        tst.w NomOut
        beq.s PaDW
; Sur disque
        move.l a0,-(sp)
        bsr ObDisk
        move.w d0,(a0)+
        addq.l #2,a5
        move.l (sp)+,a0
        cmp.l TopOb(pc),a5
        bcs.s PamW
        move.l a5,TopOb
PamW:   rts
; En memoire
PaDW:   move.w d0,(a5)+
	cmp.l TopWork(pc),a5
	bcc COut
        rts
; Passe 0
PaOW:   addq.l #2,a5
        rts

;-----> Poke un MOT LONG dans l'objet
OutLong:tst.w Passe
        beq.s PaOL
        tst.w NomOut
        beq.s PaDL
; Sur disque
        move.l a0,-(sp)
        bsr ObDisk
        move.l d0,(a0)+
        addq.l #4,a5
        move.l (sp)+,a0
        cmp.l TopOb(pc),a5
        bcs.s PamL
        move.l a5,TopOb
PamL:   rts
; En memoire
PaDL:   move.l d0,(a5)+         ;Poke
	cmp.l TopWork(pc),a5
	bcc Cout
        rts
; Passe 0
PaOL:   addq.l #4,a5
        rts

;-----> Prend un mot long dans l'objet
GtoLong:tst.w NomOut
        beq.s PaGL
; Sur disque
        move.l a0,-(sp)
        bsr ObDisk
        move.l (a0)+,d0
        addq.l #4,a5
        move.l (sp)+,a0
        rts
; En memoire
PaGL:   move.l (a5)+,d0
        rts

;-----> BUFFER OBJET DISQUE
ObDisk: cmp.l DebBob(pc),a5
        bcs.s ObDi1
        lea 4(a5),a0
        cmp.l FinBob(pc),a0
        bcc.s ObDi1
; Adresse RELATIVE dans le buffer
        move.l a5,a0
        sub.l DebBob(pc),a0
        add.l BufOb(pc),a0
        rts
; Change la position du buffer
ObDi1:  movem.l d0-d7/a0-a6,-(sp)
; Sauve le buffer
        bsr SaveBob
; Bouge le bout
        move.l DebBob(pc),d0
        move.l FinBob(pc),d1
        move.l MaxBob(pc),d2
        sub.l BordBob(pc),d2
        lea 4(a5),a0
ObDi3:  cmp.l d0,a5
        bcs.s ObDi4
        cmp.l d1,a0
        bcs.s ObDi5
; Monte le buffer
        add.l d2,d0
        add.l d2,d1
        bra.s ObDi3
; Descend le buffer
ObDi4:  sub.l d2,d0
        sub.l d2,d1
        bra.s ObDi3
ObDi5:  move.l d0,DebBob
        move.l d1,FinBob
        bsr LSeek
; Charge le nouveau bout
        move.l DebBob(pc),a0
        move.l FinBob(pc),d0
        cmp.l TopOb(pc),d0
        bcs.s ObDi6
        move.l TopOb(pc),d0
ObDi6:  sub.l a0,d0
        beq.s ObDi7
        move.l BufOb(pc),a0
        bsr Load
; Trouve l'adresse relative
ObDi7:  movem.l (sp)+,d0-d7/a0-a6
        move.l a5,a0
        sub.l DebBob(pc),a0
        add.l BufOb,a0
        rts
;-----> Sauve le buffer OBJET
SaveBob:moveq #31,d7
        move.l DebBob(pc),d0
        bsr LSeek
; Sauve l'ancien
        move.l BufOb(pc),a0
        move.l TopOb(pc),d0
        sub.l DebBob(pc),d0
        cmp.l MaxBob(pc),d0
        bcs.s ObDi2
	move.l FinBob(pc),d0
        sub.l DebBob(pc),d0
ObDi2:  bsr Write
        rts

*************************************************************************
*       LIBRAIRIE
*************************************************************************
RoutMx:         equ 600

;-----> Numero des fonctions de la librairie
InitStos:       equ 0           ;Initialisation STOS resident
Deloge:         equ 1           ;Deloge le programme
PlusFl:         equ 2           ;Plus
PlusCh:         equ 3
MoinFl:         equ 4           ;Moins
MoinCh:         equ 5
IntToFl:        equ 6
FlToInt:        equ 7
MultEn:         equ 8
MultFl:         equ 9
DiviEn:         equ 10
DiviFl:         equ 11
Modulo:         equ 12
Puiss:          equ 13
Egal:           equ 14
Diff:           equ 17
Inf:            equ 20
Sup:            equ 23
Infe:           equ 26
Supe:           equ 29
CompCh:         equ 32

; Print
PrtEn:          equ 33
PrtFl:          equ 34
PrtCh:          equ 35
GetFile:        equ 36
ImpFin:         equ 37
WaitVbl:        equ 38
LongDec:        equ 39
StrFlAsc:       equ 40
UsingCf:        equ 41
UsingCh:        equ 42
PrtRet:         equ 43
PrtVir:         equ 44

; Fonctions mathematiques: 45 ---> 69

Demande:        equ 70
instrfind:      equ 71
Left:           equ 72
Right:          equ 73
Mid1:           equ 74
Mid2:           equ 75
FinMid:         equ 76
CIMid1:         equ 77
ILeft:          equ 78
IRigh:          equ 79
IMid1:          equ 80
IMid2:          equ 81
CIMid2:         equ 82
Inst:           equ 83
flip:           equ 85
len:            equ 86
spc:            equ 87
string:         equ 88
fstring:        equ 89
chr:            equ 90
asc:            equ 91
bin:            equ 92
hex:            equ 94
binhex:         equ 96
longascii:      equ 97
longbin:        equ 98
Finbin:         equ 99
str:            equ 100
chverbuf:       equ 102
val:            equ 103
declong:        equ 104
hexalong:       equ 105
binlong:        equ 106
minichr:        equ 107

; Boucles
For:            equ 108
Next:           equ 110
RazPrg:         equ 112
While:          equ 113
Until:          equ 114
Goto:           equ 115
Gosub:          equ 116
Return:         equ 117
Pop:            equ 118
OnGto:          equ 119
OnGsb:          equ 120

; Systeme / erreurs
timr:           equ 121
Tester:         equ 123
FiniStos:       equ 124
FiniGem:        equ 125
Erreur:         equ 126
closys:         equ 129
Onerr:          equ 130
Err:            equ 131
ResLine:        equ 132
ReSeul:         equ 133
ResNex:         equ 134
ErrL:           equ 135
ErrN:           equ 136
Brek:           equ 137

Max:            equ 139
Min:            equ 142

upp:            equ 145
low:            equ 146

timebis:        equ 147
datebis:        equ 148
time:           equ 149
date:           equ 150
stime:          equ 151
sdate:          equ 152

Input:          equ 153
FInput:         equ 157
valprg:         equ 158
traduit:        equ 159
key:            equ 160
incle:          equ 161
affonc:         equ 162

SetDim:         equ 163
GetDim:         equ 164

Menage:         equ 165
Free:           equ 166

Rest:           equ 167
Read:           equ 170

clic:           equ 171
ky:             equ 173
inky:           equ 177
swap:           equ 182
getablo:        equ 184
supbis:         equ 185
egbis:          equ 186
sort:           equ 187
match:          equ 188
bst:            equ 189
raul:           equ 193
raur:           equ 196
regs:           equ 199
trp:            equ 203

stopall:        equ 205
movedata:       equ 206
putchar:        equ 207
relprg:         equ 208
transmem:       equ 209
calclong:       equ 210
cleanbank:      equ 211
adbank:         equ 212
adprg:          equ 213
adoubank:       equ 214
fill:           equ 215
copy:           equ 216
hunt:           equ 217
rese:           equ 218
reservin:       equ 219
resbis:         equ 220
eras:           equ 221
effbank:        equ 222
bcop:           equ 223
bgrab:          equ 224
start:          equ 226
adbis:          equ 228
length:         equ 229
curr:           equ 231
accnb:          equ 232
lang:           equ 233
adecran:        equ 234
log:            equ 235
phy:            equ 237
bak:            equ 239
DBak:           equ 241
dlog:           equ 242
sswap:          equ 243
wait:           equ 244
xmou:           equ 245
ymou:           equ 247
kmou:           equ 249
joy:            equ 250
fire:           equ 251

maude:          equ 256
modebis:        equ 257
inkk:           equ 258
grw:            equ 259
clip:           equ 260
sline:          equ 262
smark:          equ 263
spaint:         equ 264
spat:           equ 265
vdi:            equ 267
vdint:          equ 268
avdi:           equ 269
abak:           equ 270
plot:           equ 272
point:          equ 275
draw:           equ 276
paint:          equ 278
bar:            equ 279
rbox:           equ 280
rbar:           equ 281
box:            equ 282
pogo:           equ 283
poma:           equ 284
poli:           equ 285
arc:            equ 286
pie:            equ 287
circ:           equ 289
earc:           equ 290
epie:           equ 291
ell:            equ 293
polypar:        equ 294
curseur:        equ 295
curs:           equ 296
defaut:         equ 299
off:            equ 300
fmode:          equ 301
smode:          equ 302
pal:            equ 303
col:            equ 307

show:           equ 309
sync:           equ 316
upd:            equ 319
redr:           equ 322
spr:            equ 323
mve:            equ 329
ani:            equ 335
mvx:            equ 342
coli:           equ 345
dtct:           equ 346
frz:            equ 347
xsp:            equ 349
lsp:            equ 351
psp:            equ 353
gsp:            equ 354
pri:            equ 356
scalc:          equ 358
scc:            equ 359
scr:            equ 361
dsc:            equ 363
zone:           equ 365
rd:             equ 369
zm:             equ 374
app:            equ 379
fad:            equ 381
flas:           equ 385
shif:           equ 387                  
defo:           equ 392

mus:            equ 393
pvoi:           equ 397
voi:            equ 398
temp:           equ 403
tran:           equ 404
vo:             equ 405
stmus:          equ 406
stenv:          equ 407
getgia:         equ 408
putgia:         equ 409
shoo:           equ 410
expl:           equ 411
ping:           equ 412
env:            equ 413
vol:            equ 414
noi:            equ 416
naut:           equ 418
psg:            equ 419

winderr:        equ 431

	INCLUDE "EQUATES.S"

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | DEPART DES BUFFERS              |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
        dc.l 0
FinPrg: dc.l 0












