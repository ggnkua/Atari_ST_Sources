;
; Calcul de convolution de filtre pour VISION
; Les images traitees sont soit True Color 16 bits,
; Soit en niveaux de gris 8 plans
;
; Equivalences standards
BCR      EQU    $FFFE
PBC      EQU    $FFE0
HCR      EQU    $FFE8
HSR      EQU    $FFE9
HTX      EQU    $FFEB
HRX      EQU    $FFEB
IPR      EQU    $FFFF

; Lignes en entree envoyees par le CPU
; pt_in 1 er pointeur sur les donnees en entree
; Stockage en buffer circulaire en memoire X a partir de indata
pt_in    EQU    $0
indata   EQU    $200


; Comme P:$200-$3FFF = Y:$200-$3FFF, startY doit commencer
; Apres l'adresse de la derniere instruction du programme
; Variables passees en parametre par le CPU
; Elles sont stockees dans la memoire Y
startY   EQU    $0
nplanes  EQU    startY+$00
fw       EQU    startY+$01
fh       EQU    startY+$02
fnbpts   EQU    startY+$03
shift    EQU    startY+$04
imgw     EQU    startY+$05
outw     EQU    startY+$06

red      EQU    startY+$07
green    EQU    startY+$08
blue     EQU    startY+$09
re       EQU    startY+$0A
gr       EQU    startY+$0B
bl       EQU    startY+$0C
ms       EQU    startY+$0D

gray     EQU    startY+$0E

filter   EQU    startY+$10

outdata  EQU    startY+$200


         ORG    P:$0
         JMP    start


         ORG    P:$40
start    MOVEP  #0,X:<<HCR
         MOVEP  #$C00,X:<<IPR
         MOVEP  #1,X:<<PBC
         ANDI   #$0B,MR             ; No scaling
         ORI    #$03,MR             ; Toutes IT

         MOVE   #0,OMR
         ORI    #4,OMR              ; ROM OK
         MOVEP  #0,X:<<BCR          ; Pas de Wait State

main     JCLR   #0,X:<<HSR,*        ; Attendre un ordre du CPU
         CLR    A
         MOVEP  X:<<HRX,A1
         MOVE   #>0,X1              ; 0 : Envoi des parametres par le CPU
         CMP    X1,A
         JEQ    getpar
         MOVE   #>1,X1              ; 1 : Demande de calcul
         CMP    X1,A
         JEQ    calc
         JMP    main                ; On retourne attendre

getpar
         MOVE   #nplanes,R1         ; Premier element : nplanes
         MOVE   #-1,M1
         DO     #7,endrec           ; 7 parametres d'abord
         JCLR   #0,X:<<HSR,*        ; On attend le prochain mot
         MOVEP  X:<<HRX,Y:(R1)+     ; On stocke ce mot
endrec
; On recoit maintenant le filtre lui meme
         MOVE   Y:fnbpts,N2
         MOVE   #-1,M0
         MOVE   #filter,R0
         DO     N2,end_filter
         JCLR   #0,X:<<HSR,*
         MOVEP  X:<<HRX,Y:(R0)+
end_filter

; On initialise R0, N0 et M0 afin de gerer un buffer circulaire
; De fh lignes de imgw points
         MOVE   #-1,M1
         MOVE   #-1,M2              ; Adressage lineaire des donnees out
         MOVE   #-1,M3
         MOVE   Y:fh,R2
         MOVE   Y:imgw,N3
         MOVE   #indata,R3
         MOVE   #pt_in,R1
         DO     R2,end_mkpt
         MOVE   R3,X:(R1)+
         CLR    A          (R3)+N3
end_mkpt
         CLR    A          (R2)-
         MOVE   #pt_in,R0          ; X:(R0) -> Prochaines donnees en entree
         MOVE   R2,M0              ; Buffer circulaire module Y:fh en entree


         JMP    main                ; Attendre l'ordre de calcul

calc
         MOVE   #-1,M1
         MOVE   X:(R0),R1
         DO     Y:imgw,end_pts      ; Reception de la nouvelle ligne
         JCLR   #0,X:<<HSR,*
         MOVEP  X:<<HRX,X:(R1)+
end_pts
         BSET   #3,X:<<HCR          ; Informe le Host (Hf2 = 1)
; Inits pour le calcul
         MOVE   X:(R0),R1           ; R1 pointe la derniere ligne
         CLR    A   Y:imgw,N1
         MOVE   #outdata,R2         ; R2 -> Data Out
         CLR    A   Y:imgw,N0
         MOVE   R1,R6
         MOVE   #-1,M3
         MOVE   #0,R4
         MOVE   #-1,M4
         MOVE   #$1F,A1
         MOVE   A1,X1               ; X1 = $1F pour toutes les boucles

         MOVE   Y:nplanes,A1
         MOVE   #>8,X0
         CMP    X0,A
         JNE    Tb16
         JSR    p8_convol
         JMP    do_send
Tb16     JSR    p16_convol

;Envoi des donnees au CPU
do_send
         BCLR   #3,X:<<HCR          ; Informe le Host (Hf2 = 0)
         MOVE   #outdata,R3
         MOVE   #-1,M3
         DO     Y:outw,end_send
         JCLR   #1,X:<<HSR,*
         MOVEP  Y:(R3)+,X:<<HTX
end_send

         CLR   A       (R0)+

         JMP    main


p8_convol
         MOVE   #$FFFFFF,Y1         ; Y1 = $FFFFFF pour toutes les boucles
         DO     N1,imgw_loop8       ; Boucle sur la largeur image
         CLR    A    R6,R1
         MOVE   A,Y:gray
         MOVE   #filter,R3          ; R3 -> element courant du filtre
         MOVE   #$FF,R5             ; R5 = $FE pour toutes les boucles

         DO     Y:fh,fh_loop8
         MOVE   R4,N1

         DO     Y:fw,fw_loop8
         CLR    A      Y:(R3)+,X0      ; X0 = ms
         CLR    B      Y:gray,A
         TST    A      X:(R1+N1),Y0
         TLT    Y1,B
         MOVE   N1,R7
         MPY    X0,Y0,A   Y:gray,B0
         ADDR   B,A       (R7)+
         MOVE   A0,Y:gray
         MOVE   R7,N1
fw_loop8
         CLR    A    (R0)+
         CLR    B    X:(R0)-,R1
fh_loop8
         MOVE   Y:shift,B
         TST    B    Y:gray,B
         JEQ    after_shift8
         MOVE   Y:gray,Y0
         MOVE   Y:shift,X0
         MPY    X0,Y0,B
after_shift8
         TST    B       R5,X0
         TLT    A,B
         CMP    X0,B    (R4)+
         TGT    X0,B
         MOVE   B1,Y:(R2)+
imgw_loop8
         RTS


p16_convol
         DO     N1,imgw_loop        ; Boucle sur la largeur image
         CLR    A    R6,R1
         MOVE   A,Y:red
         MOVE   A,Y:green
         MOVE   A,Y:blue
         MOVE   #filter,R3          ; R3 -> element courant du filtre
         MOVE   #$1F,R5             ; R5 = $1F pour toutes les boucles

         DO     Y:fh,fh_loop
         MOVE   R4,N1

         DO     Y:fw,fw_loop
         CLR    B        Y:(R3)+,X0         ; X0 = ms
         CLR    A        X:(R1+N1),B1
         TFR    B,A      B1,Y1
         AND    X1,B     #$20000,Y0
         MPY    Y0,Y1,B  B1,Y:bl
         AND    X1,B     #$1000,Y0
         MPY    Y0,Y1,B  B1,Y:gr
         AND    X1,B     #$FFFFFF,Y1

         CLR    B        B1,Y:re

         MOVE   Y:blue,A
         TST    A         Y:bl,Y0
         TLT    Y1,B
         MPY    X0,Y0,A   Y:blue,B0
         ADDR   B,A       Y:gr,Y0
         CLR    B         A0,Y:blue
         MOVE   Y:green,A
         TST    A
         TLT    Y1,B
         MPY    X0,Y0,A   Y:green,B0
         ADDR   B,A       Y:re,Y0
         CLR    B         A0,Y:green
         MOVE   Y:red,A
         TST    A
         TLT    Y1,B
         MPY    X0,Y0,A   Y:red,B0
         ADDR   B,A       N1,R7
         MOVE   A0,Y:red
         CLR    A        (R7)+
         MOVE   R7,N1
fw_loop
         CLR    A    (R0)+
         CLR    B    X:(R0)-,R1
fh_loop
         MOVE   Y:shift,A
         TST    A
         JEQ    after_shift16
         MOVE   Y:shift,X0
         MOVE   Y:red,Y0
         MPY    X0,Y0,A    Y:green,Y0
         MPY    X0,Y0,A    A1,Y:red
         MOVE   Y:blue,Y0
         MPY    X0,Y0,A   A1,Y:green
         MOVE   A1,Y:blue
after_shift16
         CLR    B       R5,X0
         CLR    A       Y:red,B
         TST    B
         TLT    A,B
         CMP    X0,B
         TGT    X0,B
         MOVE   B,Y:red
         MOVE   Y:blue,B
         TST    B
         TLT    A,B
         CMP    X0,B
         TGT    X0,B
         MOVE   B,Y:blue
         MOVE   Y:green,B
         TST    B
         TLT    A,B
         CMP    X0,B
         TGT    X0,B
make16bits
         REP    #5
         LSL    B
         LSL    B    Y:blue,A1
         MOVE   B1,X0
         OR     X0,A   Y:red,B1
         REP    #11
         LSL    B
         MOVE   B1,X0
         OR     X0,A   (R4)+
         MOVE   A1,Y:(R2)+
imgw_loop

         RTS


         END    start
