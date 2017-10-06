************************************************
* D‚sassemblage de BASIC206.PRG                *
*      Par Pink Elephant Software Inc .        *
*                 Juin 1992                    *
************************************************
        opt     d+
        output  Basic208.prg

Debut:  BRA     START
                
; Tables d'adaptation   
; Dans l'ordre :
; Mot : Version du Tos
; .l  : Adr souris
; .l  : Adr joystick
; .l  : Buffer Clavier
; .l  : Table Vdi 1
; .l  : Table Vdi 2
; .l  : Vecteur d'interruption souris
; .l  : D‚part d'un son
Adapt   DC.W    0
        DC.L    0,0,0,0,0,0,0

extend  DS.L     26             ;26 adresses d'extensions 

dta     DS.W    13              ;Buffer DTA
size    DC.L    0               ;Taille du fichier
NAME    DC.W    0               ;Son nom
        DS.W    9               ;Buffer Dta (Suite)

Joy_Sav	dc.l	0		; Gestion du joystick
Joy_Pos	dc.l	0
Joy_Ad	dc.l	0

CMDLINE DC.L    0       
end_adr DC.L    0               ;Adresse fin de fichier
logic   DC.L    0               ;Adresse de l'‚cran logique
res     DC.W    0               ;R‚solution au boot
handle  DC.W    0               ;Handle de fichier
Cmd_Tail:DC.L    0              ;Command Tail 
sav_col DS.W    16              ;Buffer pour 16 couleurs
vdi_1   DS.W    $2C             ;Table VDI 1
        DS.W    $11             ;Table VDI 2
        DS.L    1               ;M‚moire libre


curs_off
        DC.B    27,"f",0        ;Curs Off
folder  DC.B    "\STOS",0       ;Folder \Stos 
        
path    DS.b    64              ;Buffer
newpath DS.b    64              ;Autre buffer
piclow  DC.B    "PIC.PI1",0     ;Image basse r‚olution
pichi   DC.B    "PIC.PI3",0     ;Image haute r‚solution
sprit   DC.B    "SPRIT???.BIN",0 ; Sprite trap
windo   DC.B    "WINDO???.BIN",0 ; Window Trap
float   DC.B    "FLOAT???.BIN",0 ; Float Trap
music   DC.B    "MUSIC???.BIN",0 ; Music Trap
basic   DC.B    "BASIC???.BIN",0 ; Basic lui meme
namext  dc.b "*.EX"
numbext dc.b 0,0
        even
BUFFER3 DS.B    13
        EVEN
;D‚but du programme
LOADER: Dc.b    "BASLOAD.PRG",0
        EVEN

start   CLR.L   logic           
        MOVEA.L 4(A7),A0        ;Adresse Basepage
        LEA     $80(A0),A0      ;Nb de caractŠres ds ligne de commande
        TST.B   (A0)            ;=0 ?
        BEQ.S   .Skip0          ;cherche Adr logique
        ADDQ.L  #1,A0           ;Ligne de commande
        MOVE.L  A0,Cmdline      ;Stocke son adresse     
.Skip0
; Trouve les adresses en respectant le systeme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Adapt+2(pc),a6
	dc.w	$A000
	lea	-602(a0),a1	; Position souris
	move.l	a1,(a6)
	lea	-692(a0),a1	; Table VDI 1
	move.l	a1,12(a6)
	lea	-498(a0),a1	; Table VDI 2
	move.l	a1,16(a6)

	move.w	#1,-(sp)	; Adresse du buffer clavier
	move.w	#14,-(sp)
	trap 	#14
	addq.l	#4,sp
	move.l	d0,8(a6)

	move.w	#34,-(sp)	; Adresse des interruptions souris
	trap 	#14
	addq.l	#2,sp
	move.l	d0,a0
	lea	16(a0),a1		; Adresse souris
	move.l	a0,20(a6)
	lea	24(a0),a0
	move.l	a0,Joy_Ad
	move.l	(a0),Joy_Sav
	move.l	#Joy_In,(a0)		; Branche la routine joystick
	move.l	#Joy_Pos,4(a6)		; Adresse du resultat

; Trouve l'adresse de l'‚cran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
        MOVE.W  #3,-(A7)        ;LogBase
        TRAP    #$E     
        ADDQ.L  #2,A7
        MOVE.L  D0,logic        ;Range adresse logic
        PEA     sav_vect(PC)    ;Sauvegarde la configuration
        MOVE.W  #$26,-(A7)      ;SupExec
        TRAP    #$E
        ADDQ.L  #6,A7
        LEA     vdi_1(PC),A6    ;
        MOVE.W  #4,-(A7)
        TRAP    #$E
        ADDQ.L  #2,A7
        MOVE.W  D0,res          ;Range r‚solution
        LEA     Adapt+2(PC),A5  ;Adresse vecteurs
        MOVEA.L $C(A5),A0       ;Adr Table VDI 1
        MOVEQ   #$2C,D0         ;Copie 44+1 mots
bcl1:
        MOVE.W  (A0)+,(A6)+     ;(Soit 90 octets)
        DBF     D0,bcl1         ;
        MOVEA.L $10(A5),A0      ;Adresse Table VDI 2
        MOVEQ   #$B,D0          ;Copier 11+1 mots
bcl2:
        MOVE.W  (A0)+,(A6)+     ;(Soit 24 octets)
        DBF     D0,bcl2
        add.l   exit,a5         ;
        MOVEA.L (A5),A0
        MOVE.L  (A0),(A6)+      ;Adresse m‚moire libre
        MOVE.L  #EXIT,end_adr   ;Adresse de fin de BASIC206.PRG
        BSR     set_dta         ;Fixe tampon I/O
        CLR.W   -(A7)           ;Unit‚ actuelle
        PEA     path(PC)        ;Buffer de 64 octets : chemin d'accŠs
        MOVE.W  #$47,-(A7)      
        TRAP    #1
        ADDQ.L  #8,A7
        TST.W   D0              
        BNE     set_scr         ;ProblŠme...
        LEA     path(PC),A0     ;Chemin actuel
        LEA     newpath(PC),A1  ;Recopie ds un buffer
Copy_path:
        MOVE.B  (A0)+,(A1)+
        BNE.S   Copy_Path
        LEA     path(PC),A0
        TST.B   (A0)            ;Fin du chemin ?
        BNE.S   lbl1            ;Non , d‚cr‚mente
        MOVE.B  #'\',(A0)+      ;Antislash
        CLR.B   (A0)            ;Fin de chemin
lbl1:
        SUBQ.L  #1,A1
        LEA     folder(PC),A0   ;Recopie \STOS
Copy_Folder:
        MOVE.B  (A0)+,(A1)+
        BNE.S   Copy_Folder
        LEA     newpath(PC),A0  ;Fixe chemin \STOS
        BSR     set_path
        BNE     Error           ;Pas trouv‚
        CMPI.W  #2,res          ;Haute r‚solution ?
        BEQ.S   hi_res          ;vouiiiiii!
        LEA     piclow(PC),A0   ;'PIC.PI1' : zouli image
        BRA.S   affiche         ;Va la chercher
hi_res:
        LEA     pichi(PC),A0    ;'PIC.PI3'
affiche:
        BSR     fs_first        ;Existe-t-elle ?
        BNE     No_Image        ;Non...
        BSR     fopen           ;
        MOVEA.L logic(PC),A0    ;Logic-32768 : Back
        SUBA.L  #32768,A0       ;...
        MOVE.L  #32034,D0       ;Lire 32034 octets (Degas)
        BSR     fread           ;Lit
        BSR     fclose          ;Ferme
        
        DC.W    $A00A           ;cache souris
        TST.W   res             ;Low Res ?
        BEQ     fix_scr         ;Oui
        CMPI.W  #2,res          ;Hi Res ?
        BEQ     fix_scr         ;Oui
        MOVE.W  #0,-(A7)        ;Mid Res: passe en basse
        MOVE.L  #$FFFFFFFF,-(A7)
        MOVE.L  #$FFFFFFFF,-(A7)
        MOVE.W  #5,-(A7)
        TRAP    #$E
        ADDA.L  #$C,A7
fix_scr:
        LEA     curs_off(PC),A0 ;EnlŠve curseur
        BSR     print           ;Emulation VT52
        MOVE.L  logic(PC),-(A7) ;
        SUBI.L  #32766,(A7)     ;Adresse palette
        MOVE.W  #6,-(A7)        ;SetPalette
        TRAP    #$E
        ADDQ.L  #6,A7
        MOVEQ   #1,D6
        
; Recopie l'image avec un effet...

copy_scr:
        MOVEA.L logic(PC),A2
        MOVEA.L A2,A3
        ADDA.L  #99*160,A2      ;Ligne 99
        ADDA.L  #100*160,A3     ;Ligne 100
        MOVEA.L A2,A0
        MOVEA.L A3,A1
        SUBA.L  #32734,A0
        SUBA.L  #32734,A1
        MOVEQ   #99,D7
        ADDQ.W  #1,D6
        CMP.W   #100,D6         ;Ligne 100 atteinte ?
        BHI     load            ;Oui...
        MOVEQ   #50,D5          
Effect:
        ADD.W   D6,D5
        CMP.W   #100,D5
        BCS.S   cpy_scr
        SUBI.W  #100,D5
        MOVEM.L A0-A3,-(A7)
        MOVEQ   #9,D0
BitMap_Copy:
        MOVE.L  (A0)+,(A2)+
        MOVE.L  (A0)+,(A2)+
        MOVE.L  (A0)+,(A2)+
        MOVE.L  (A0)+,(A2)+
        MOVE.L  (A1)+,(A3)+
        MOVE.L  (A1)+,(A3)+
        MOVE.L  (A1)+,(A3)+
        MOVE.L  (A1)+,(A3)+
        DBF     D0,BitMap_Copy
        MOVEM.L (A7)+,A0-A3
        SUBA.L  #160,A2
        ADDA.L  #160,A3
cpy_scr:
        SUBA.L  #160,A0
        ADDA.L  #160,A1
        DBF     D7,Effect
        BRA     copy_scr
No_Image:
        DC.W    $A00A           ;Cache la souris
        LEA     curs_off(PC),A0 ;EnlŠve le curseur
        BSR     print
load:
        LEA     sprit(PC),A0    ;Filtre 'SPRIT???.BIN'
        BSR     get_im          ;Charge fichier
        LEA     Adapt+2(PC),A3  ;Adresses
        JSR     (A0)            ;Installe trappe
        MOVE.L  A0,end_adr
        
        LEA     windo(PC),A0    ;Filtre 'WINDO???.BIN'
        BSR     get_im          ;Charge fichier
        LEA     Adapt+2(PC),A3  ;Adresses
        JSR     (A0)            ;Installe trappe
        MOVE.L  A0,end_adr

        LEA     float(PC),A0    ;Filtre 'FLOAT???.BIN'
        BSR     get_bin         ;Charge fichier
        BNE     load_zik        ;Si pas l… , tant pis!
        LEA     Adapt+2(PC),A3  ;Adresses
        JSR     (A0)            ;Installe trappe
        
load_zik:
        LEA     music(PC),A0    ;Filtre 'MUSIC???.BIN'
        BSR     get_im          ;Charge fichier
        LEA     Adapt+2(PC),A3  ;Adresses
        JSR     (A0)            ;Installe trappe
        MOVE.L  A0,end_adr

; charge et appelle les extensions, poke les adresses
        clr     d7
        lea     extend(pc),a6
load5:  move.b  d7,numbext
        add.b   #65,numbext
        lea     namext(pc),a0
        bsr     fs_first
        bne.s   load6
        lea     namext(pc),a0
        bsr     get_im
        movem.l a6/d6/d7,-(sp)
        lea     adapt+2,a3
        jsr     (a0)
        move.l  a0,end_adr
        movem.l (sp)+,a6/d6/d7
        move    d7,d6
        lsl     #2,d6
        move.l  a1,0(a6,d6.w)          ;poke l'adresse de debut
load6:  addq    #1,d7
        cmp     #26,d7
        bcs.s   load5
        
        LEA     basic(PC),A0    ;Filtre 'BASIC???.BIN'
        BSR     get_im          ;Charger
        MOVE.L  A0,-(A7)        ;Sauve l'adresse sur la pile
        LEA     path(PC),A0     ;Chemin de boot
        BSR     set_path        ;Le remettre
        MOVEA.L (A7)+,A6        ;Adresse BASIC.BIN
        MOVE.W  #$25,-(A7)      ;Vsync
        TRAP    #$E
        ADDQ.L  #2,A7
        MOVEA.L logic(PC),A0    ;effacer logic
        MOVE.W  #7999,D0        ;8000-1 (dbf)
cls:
        CLR.L   (A0)+
        DBF     D0,cls
        CMPI.W  #2,res          ;Haute r‚solution ?
        BEQ.S   hi              ;oui
        MOVE.W  #1,-(A7)        ;MidRes
        MOVE.L  #$FFFFFFFF,-(A7)
        MOVE.L  #$FFFFFFFF,-(A7)
        MOVE.W  #5,-(A7)
        TRAP    #$E
        ADDA.W  #$C,A7
hi:
        LEA     Extend(PC),A0   ;Adresse des extensions
        LEA     Adapt+2(PC),A3  ;Adresse adaptations
        MOVEA.L Cmd_Tail(PC),A4 ;Command Tail
        CLR.L   D0              ;d0=0
        JSR     (A6)            ;Saute au basic
        BRA     set_scr         ;fin du basic

; Erreur de chargement >>> sortie
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Error:
        BSR     fclose
        LEA     path(PC),A0
        BSR     set_path
; Restoration du systeme
; ~~~~~~~~~~~~~~~~~~~~~~
set_scr:
; Restore la routine d'entree du joystick
	move.l	Joy_Ad(pc),d0
	beq.s	.Skip
	move.l	d0,a0
	move.l	Joy_Sav(pc),(a0)
.Skip
; Les ecrans
        MOVE.W  res(PC),-(A7)   ;restore r‚solution
        MOVE.L  logic(PC),-(A7) ;adresses ‚crans
        MOVE.L  logic(PC),-(A7)
        MOVE.W  #5,-(A7)
        TRAP    #$E
        ADDA.W  #$C,A7
        
        LEA     vdi_1(PC),A6    ;Remet vecteurs
        LEA     Adapt+2(PC),A5
        MOVEA.L 12(A5),A0
        MOVEQ   #44,D0
bcl7:
        MOVE.W  (A6)+,(A0)+
        DBF     D0,bcl7
        MOVEA.L 16(A5),A0
        MOVEQ   #$B,D0
bcl8:
        MOVE.W  (A6)+,(A0)+
        DBF     D0,bcl8
        add.l   exit,a5
        MOVEA.L (A5),A0
        MOVE.L  (A6)+,(A5)
        PEA     sav_col(PC)     ;Remet couleurs
        MOVE.W  #6,-(A7)
        TRAP    #$E
        ADDQ.L  #6,A7
        MOVE.W  #$25,-(A7)      ;Vsync
        TRAP    #$E
        ADDQ.L  #2,A7
        CLR.W   -(A7)           ;Pterm
        TRAP    #1

; Routine d'entree du joystick
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Joy_In	move.b	2(a0),Joy_Pos
	rts

; En superviseur
; ~~~~~~~~~~~~~~~
sav_vect:
; Copie de la palette
        LEA     $ffff8240,A0
        LEA     sav_col(PC),A1
        MOVEQ   #$F,D0
bcl8A:
        MOVE.W  (A0)+,(A1)+
        DBF     D0,bcl8A
; Fausse trappe float
        MOVE.L  #fake_fl,D0
        MOVE.L  D0,$98
        RTS

; Fausse trap float
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fake_fl CMP.B   #$C,D0
        BEQ.S   fltoa
        MOVEQ   #0,D0
        MOVEQ   #0,D1
        RTE
; Fonction $c 'FLTOA'
; ~~~~~~~~~~~~~~~~~~~
fltoa:  MOVE.B  #$30,(A0)
        MOVE.B  #$2E,1(A0)
        MOVE.B  #$30,2(A0)
        CLR.B   3(A0)
        RTE

; Routines d'interfa‡age disque
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fsnext:
        Move.w  #$4f,-(Sp)
        Trap    #1
        Addq.l  #2,Sp
        Rts     
set_dta:
        MOVE.L  A0,-(A7)
        PEA     dta(PC)
        MOVE.W  #$1A,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7
        MOVEA.L (A7)+,A0
        RTS
        
set_path:
        MOVE.L  A0,-(A7)
        MOVE.W  #$3B,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7
        TST.W   D0
        RTS
        
fs_first:
        CLR.W   -(A7)
        MOVE.L  A0,-(A7)
        MOVE.W  #$4E,-(A7)
        TRAP    #1
        ADDQ.L  #8,A7
        LEA     name(PC),A0
        TST.W   D0
        RTS
        
fopen:
        CLR.W   -(A7)
        MOVE.L  A0,-(A7)
        MOVE.W  #$3D,-(A7)
        TRAP    #1
        ADDQ.L  #8,A7
        TST.W   D0
        BMI     Error
        MOVE.W  D0,handle
        RTS
        
charge:
        MOVE.L   size,D0
fread:
        MOVE.L  A0,-(A7)
        MOVE.L  D0,-(A7)
        MOVE.W  handle(PC),-(A7)
        MOVE.W  #$3F,-(A7)
        TRAP    #1
        ADDA.L  #$C,A7
        TST.L   D0
        BMI     Error
        RTS
fclose:
        MOVE.W  handle(PC),-(A7)
        MOVE.W  #$3E,-(A7)
        TRAP    #1
        ADDQ.L  #4,A7
        RTS
print:
        MOVE.L  A0,-(A7)
        MOVE.W  #9,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7
        RTS
get_im:
        BSR     get_bin
        BNE     Error
        RTS
get_bin:
        MOVEM.L D0-D7/A1-A6,-(A7)
        BSR     set_dta
        BSR     fs_first
        BNE     failed
        MOVE.L  end_adr(PC),D3
        ADD.L    size(PC),D3
        ADDI.L  #60000,D3
        CMP.L   logic(PC),D3
        BCC     Error
        BSR     fopen
        MOVEA.L end_adr(PC),A0
        BSR     charge
        BSR     fclose
        MOVEA.L end_adr(PC),A1
        MOVE.L  $2(A1),D0
        ADD.L   6(A1),D0
        ANDI.L  #$FFFFFF,D0
        ADDA.W  #$1C,A1
        MOVEA.L A1,A2
        MOVE.L  A2,D2
        ADDA.L  D0,A1
        CLR.L   D0
        TST.L   (A1)
        BEQ.S   Reloge
        ADDA.L  (A1)+,A2
        BRA.S   noerr
err:
        MOVE.B  (A1)+,D0
        BEQ.S   Reloge
        CMP.B   #1,D0
        BEQ.S   do_asc
        ADDA.W  D0,A2
noerr:
        ADD.L   D2,(A2)
        BRA.S   err
do_asc:
        ADDA.W  #$FE,A2
        BRA.S   err
Reloge:
        MOVEA.L end_adr(PC),A0
        MOVE.L  A0,D0
        ADD.L   size(PC),D0
        BTST    #0,D0
        BEQ.S   pair
        ADDQ.L  #1,D0
pair:
        MOVE.L  D0,end_adr
        MOVEM.L (A7)+,D0-D7/A1-A6
        MOVEQ   #0,D0
        RTS
failed:
        MOVEM.L (A7)+,D0-D7/A1-A6
        MOVEQ   #1,D0
        RTS
        
EXIT    DC.L    0
