;
; Programme de calcul des ensembles fractals de Mandelbrot
; Et de Julia par le DSP 56001.
; Protocole de communication :
; * CPU -> DSP
; mot 1 : ordre a effectuer :
;         $1 : Envoi des parametres de calcul
;         $2 : Calcul de 3 lignes
;         $3 : Fin  des calculs
; mot 2 : Nombre n de mots a recevoir par la suite (en tout 2+n mots)
; * DSP -> CPU
; Envoi des 3 lignes calculees.
; Attente du numero de la prochaine ligne ou de l'ordre d'arret
;
; Equivalences standards
BCR      EQU    $FFFE
PBC      EQU    $FFE0
HCR      EQU    $FFE8
HSR      EQU    $FFE9
HTX      EQU    $FFEB
HRX      EQU    $FFEB
IPR      EQU    $FFFF
;
; Variables passees en parametre par le CPU
; Elles sont stockees dans la memoire X
maxiter  EQU    $00
type     EQU    maxiter+$01
pix      EQU    maxiter+$02
piy      EQU    maxiter+$03
xmin     EQU    maxiter+$04
ydsp     EQU    maxiter+$05
echx     EQU    maxiter+$06
echy     EQU    maxiter+$07
ech2x    EQU    maxiter+$08
ech2y    EQU    maxiter+$09
nbptx    EQU    maxiter+$0A
nr1      EQU    maxiter+$0B
angle    EQU    maxiter+$0C
cos_a    EQU    maxiter+$0D
sin_a    EQU    maxiter+$0E
xc       EQU    maxiter+$0F
yc       EQU    maxiter+$10

ix       EQU    maxiter+$15
iy       EQU    maxiter+$16
cx       EQU    maxiter+$17
cy       EQU    maxiter+$18
cxc      EQU    maxiter+$19
cyc      EQU    maxiter+$1A
orb00    EQU    maxiter+$1B
orb01    EQU    maxiter+$1C
orb10    EQU    maxiter+$1D
orb11    EQU    maxiter+$1E
orb3     EQU    maxiter+$1F
orb4     EQU    maxiter+$20
xp       EQU    maxiter+$21
yp       EQU    maxiter+$22
t        EQU    maxiter+$23

preabs   EQU    maxiter+$26

; Debut de la table contenant les orbites a calculmer pour le CPU
; Les orbites sont stockees en memoire Y
; Comme P:$200-$3FFF = Y:$200-$3FFF, startorb doit commencer
; Apres l'adresse de la derniere instruction du programme
startorb EQU    $300

         OPT    CC

         ORG    P:$0
         JMP    start


         ORG    P:$40
start    MOVEP  #0,X:<<HCR
         MOVEP  #$C00,X:<<IPR
         MOVEP  #1,X:<<PBC
         MOVEP  #0,X:<<BCR
         ANDI   #$0B,MR             ; No scaling
         ORI    #$03,MR             ; Toutes IT

         MOVE   #0,OMR
         MOVEP  #0,X:<<BCR          ; Pas de Wait State

main     JCLR   #0,X:<<HSR,*        ; Attendre un ordre du CPU
         CLR    A
         MOVEP  X:<<HRX,A1
         MOVE   #>1,X1              ; 1 : Envoi des parametres par le CPU
         CMP    X1,A
         JEQ    getpar
         MOVE   #>2,X1              ; 2 : Demande de calcul
         CMP    X1,A
         JEQ    calc
         MOVE   #>3,X1              ; 3 : Fin du calcul
         CMP    X1,A
         JEQ    end_calc
         JMP    main                ; On retourne attendre
;                                   ; Non reconnu : on attend le prochain
getpar
         JCLR   #0,X:<<HSR,*        ; Nombre de mots
         MOVEP  X:<<HRX,R0
         MOVE   #<maxiter,R1        ; Premier element : maxiter
         MOVE   #$FF,M1             ; Limite a 256 mots DSP
         DO     R0,endrec           ; Pour R0 mots
         JCLR   #0,X:<<HSR,*        ; On attend le prochain mot
         MOVEP  X:<<HRX,X:(R1)+     ; On stocke ce mot
endrec
         MOVE   #<maxiter,R1
         DO     R0,e_send
         JCLR   #1,X:<<HSR,*
         MOVEP  X:(R1)+,X:<<HRX
e_send
; On recoit maintenant les precalculs sur les abscisses
         MOVE   #-1,M0
         MOVE   #preabs,R0
         DO     X:<nbptx,end_pabs
         JCLR   #0,X:<<HSR,*
         MOVEP  X:<<HRX,X:(R0)+
end_pabs

         MOVE   X:<pix,X1
         MOVE   X1,X:<ix
         MOVE   X:<piy,X1
         MOVE   X1,X:<iy
         JMP    main                ; Attendre l'ordre de calcul

calc
         JCLR   #0,X:<<HSR,*        ; Nombre de mots
         MOVEP  X:<<HRX,R0
         JCLR   #0,X:<<HSR,*
         MOVEP  X:<<HRX,X:ydsp      ; Premiere ligne a calculer
         CLR    A          X:<type,N0
         MOVE   #adr_calc,R0
         BSET   #3,X:<<HCR          ; Informe le Host (Hf2 = 1)
         MOVE   P:(R0+N0),R7
         JSR    compute_3lignes

do_send  JSR    sendata
         JMP    main

end_calc
         JCLR   #0,X:<<HSR,*        ; Nombre de mots
         MOVEP  X:<<HRX,R0
         JMP    main

; Calcul de l'orbite a renvoyer au cas ou le
; Critere de divergence a echoue
out_set
         CLR     B          X:<maxiter,X0
         SUB     X0,A       #$2,B1
         NEG     A
         ADD     B,A
         MOVE    #$FFFF00,B0
         MOVE    B0,X1
         MOVE    A1,B1
         AND     X1,B
         JNE     change
         RTS
change   CLR     B
         MOVE    #$01,B1
         MOVE    B1,X1
         CMP     X1,A
         JEQ     do_ch
         RTS
do_ch    MOVE    #$000002,A1
         RTS



;
; Routine g‚n‚rale de calcul
; Initialisateurs  c : X:cx et X:cy
;                 z0 : X:ix et X:iy
; Registres modifies :
;                      A, B, X, Y
;                      R1, R2
; Resultat dans A1
calculate
; Effectue l'eventuelle rotation
         MOVE    X:<angle,A
         TST     A
         JEQ     call_calc
; Effectue la rotation de centre (xc,yc), d'angle angle sur (cx,cy)
         MOVE    X:<cx,A
         MOVE    X:<xc,X0
         SUB     X0,A       X:<cy,B
         MOVE    X:<yc,Y0
         MOVE    A,X0                    ; X0 = cx-xc
         SUB     Y0,B       X:<cos_a,X1  ; B = cy-yc, X1 = cos_a
         MOVE    X:<sin_a,Y1             ;            Y1 = sin_a
         MPY     X1,X0,A    B,Y0         ; Y0 = cy-yc
         MAC     Y1,Y0,A
         ASL     A
         ASL     A
         MPY     -X0,Y1,B
         MAC     X1,Y0,B    X:<xc,X0
         ASL     B
         ASL     B          X:<yc,Y0
         ADD     X0,A
         ADD     Y0,B       A,X:<cx
         MOVE    B,X:<cy


; Appelle la routine sp‚cifique
call_calc
         JSR     (R7)

         RTS


;
; Calcul de l'orbite d'un point
; Ensembles de Mandelbrot
;
mandelbrot_calc
         MOVE    #mandelbrot_again,R1
         ANDI    #$0F,CCR
         MOVE    X:<ix,X0
         MOVE    X:<iy,Y0

         DO      X:<maxiter,mandelbrot_loop
         MPY     X0,X0,A
         MAC     Y0,Y0,A    X:<nr1,B
         CMP     B,A
         JMI     (R1)
         CLR     A
         MOVEC   LC,A1
         ENDDO
         JSR     out_set
         RTS

mandelbrot_again
         MPY     -Y0,Y0,A
         MAC     X0,X0,A    X:<cx,B
         ASL     A
         ADDL    B,A

         MPY     X0,Y0,B
         ASL     B          A,X0
         ASL     B          X:<cy,A
         ADDL    A,B

         MOVE    B,Y0
mandelbrot_loop
         MOVE    #$01,A1
         RTS


;
; Calcul de l'orbite d'un point
; Ensembles de Julia
;
julia_calc
         MOVE    #julia_again,R1
         ANDI    #$0F,CCR
         MOVE    X:<cx,X0
         MOVE    X:<cy,Y0

         DO      X:<maxiter,julia_loop
         MPY     X0,X0,A
         MAC     Y0,Y0,A    X:<nr1,B
         CMP     B,A
         JMI     (R1)
         CLR     A
         MOVEC   LC,A1
         ENDDO
         JSR     out_set
         RTS

julia_again
         MPY     -Y0,Y0,A
         MAC     X0,X0,A    X:<ix,B
         ASL     A
         ADDL    B,A

         MPY     X0,Y0,B
         ASL     B          A,X0
         ASL     B          X:<iy,A
         ADDL    A,B

         MOVE    B,Y0
julia_loop
         MOVE    #$01,A1
         RTS

;
; Calcul de l'orbite d'un point
; Ensembles Unity
unity_calc
         MOVE    #unity_again,R1
         ANDI    #$0F,CCR
         MOVE    X:<cx,X0
         MOVE    X:<cy,Y0

         DO      X:<maxiter,unity_loop
         MPY     X0,X0,A
         MAC     Y0,Y0,A    X:<nr1,B
         CMP     B,A
         JMI     (R1)
         CLR     A
         MOVEC   LC,A1
         ENDDO
         JSR     out_set
         RTS

unity_again
         ASL     A
         ASL     A
         NEG     A          X:<iy,X1 ; X1 = cy
         MOVE    A,Y1
         ADD     X1,A
         MOVE    A,X1
         MPY     X0,X1,B
         ASL     B          X:<ix,X0
         ASL     B          Y1,A
         ADD     X0,A       B,Y0
         MOVE    A,X1
         MPY     Y0,X1,A
         ASL     A
         ASL     A
         MOVE    A,X0

unity_loop
         MOVE    #$01,A1
         RTS


;
; Calcul de l'orbite d'un point
; Ensembles ManowarM
manowarm_calc
         MOVE    #manowarm_again,R1
         ANDI    #$0F,CCR
         MOVE    X:<ix,X0
         MOVE    X:<iy,Y0
         MOVE    X0,X:<xp
         MOVE    Y0,X:<yp

         DO      X:<maxiter,manowarm_loop
         MPY     X0,X0,A
         MAC     Y0,Y0,A    X:<nr1,B
         CMP     B,A
         JMI     (R1)
         CLR     A
         MOVEC   LC,A1
         ENDDO
         JSR     out_set
         RTS

manowarm_again
         MPY     X0,Y0,B
         ASL     B
         ASL     B          X:<cy,A
         ADDL    A,B        X:<yp,A
         ADD     A,B

         MPY     -Y0,Y0,A   Y0,X:<yp
         MAC     X0,X0,A    B,Y0
         ASL     A          X:<cx,B
         ADDL    B,A        X:<xp,B
         ADD     B,A        X0,X:<xp

         MOVE    A,X0
manowarm_loop
         MOVE    #$01,A1
         RTS

;
; Calcul de l'orbite d'un point
; Ensembles ManowarJ
manowarj_calc
         MOVE    #manowarj_again,R1
         ANDI    #$0F,CCR
         MOVE    X:<cx,X0
         MOVE    X:<cy,Y0
         MOVE    X0,X:<xp
         MOVE    Y0,X:<yp

         DO      X:<maxiter,manowarj_loop
         MPY     X0,X0,A
         MAC     Y0,Y0,A    X:<nr1,B
         CMP     B,A
         JMI     (R1)
         CLR     A
         MOVEC   LC,A1
         ENDDO
         JSR     out_set
         RTS

manowarj_again
         MPY     X0,Y0,B
         ASL     B
         ASL     B          X:<iy,A
         ADDL    A,B        X:<yp,A
         ADD     A,B

         MPY     -Y0,Y0,A   Y0,X:<yp
         MAC     X0,X0,A    B,Y0
         ASL     A          X:<ix,B
         ADDL    B,A        X:<xp,B
         ADD     B,A        X0,X:<xp

         MOVE    A,X0
manowarj_loop
         MOVE    #$01,A1
         RTS


;
; Calcul de l'orbite d'un point
; Ensembles de BarnsleyM
;
barnsleym_calc
         MOVE    #barnsleym_again,R1
         ANDI    #$0F,CCR
         MOVE    X:<ix,X0
         MOVE    X:<iy,Y0
         MOVE    #t_is_positifm,R2

         DO      X:<maxiter,barnsleym_loop
         MPY     X0,X0,A
         MAC     Y0,Y0,A    X:<nr1,B
         CMP     B,A
         JMI     (R1)
         CLR     A
         MOVEC   LC,A1
         ENDDO
         JSR     out_set
         RTS

barnsleym_again
         MOVE    X:<cy,Y1
         MPY     X0,Y1,A    X:<cx,X1
         MAC     X1,Y0,A    X0,B
         ASL     A          X:<nr1,X0
         ASL     A
         JGT     (R2)
         ADD     X0,B       A,X:<t
         MPY     -Y0,Y1,A   B,X0
         MAC     X0,X1,A    X:<t,B
         ASL     A
         ASL     A
         ADD     Y1,B       A,X0
         JMP     last_updatem
t_is_positifm
         SUB     X0,B       A,X:<t
         MPY     -Y0,Y1,A   B,X0
         MAC     X0,X1,A    X:<t,B
         ASL     A
         ASL     A
         SUB     Y1,B       A,X0
last_updatem
         MOVE    B,Y0
barnsleym_loop
         MOVE    #$01,A1
         RTS

;
; Calcul de l'orbite d'un point
; Ensembles de BarnsleyJ
;
barnsleyj_calc
         MOVE    #barnsleyj_again,R1
         ANDI    #$0F,CCR
         MOVE    X:<cx,X0
         MOVE    X:<cy,Y0
         MOVE    #t_is_positifj,R2

         DO      X:<maxiter,barnsleyj_loop
         MPY     X0,X0,A
         MAC     Y0,Y0,A    X:<nr1,B
         CMP     B,A
         JMI     (R1)
         CLR     A
         MOVEC   LC,A1
         ENDDO
         JSR     out_set
         RTS

barnsleyj_again
         MOVE    X:<iy,Y1
         MPY     X0,Y1,A    X:<ix,X1
         MAC     X1,Y0,A    X0,B
         ASL     A          X:<nr1,X0
         ASL     A
         JGT     (R2)
         ADD     X0,B       A,X:<t
         MPY     -Y0,Y1,A   B,X0
         MAC     X0,X1,A    X:<t,B
         ASL     A
         ASL     A
         ADD     Y1,B       A,X0
         JMP     last_updatej
t_is_positifj
         SUB     X0,B       A,X:<t
         MPY     -Y0,Y1,A   B,X0
         MAC     X0,X1,A    X:<t,B
         ASL     A
         ASL     A
         SUB     Y1,B       A,X0
last_updatej
         MOVE    B,Y0
barnsleyj_loop
         MOVE    #$01,A1
         RTS

;
; Calcul de l'orbite d'un point
; Ensembles de Hyperbasin
;
hyperbasin_calc
         MOVE    #hyperbasin_again,R1
         ANDI    #$0F,CCR
         MOVE    X:<cx,X0
         MOVE    X:<cy,Y0

         DO      X:<maxiter,hyperbasin_loop
         MPY     X0,X0,A
         MAC     Y0,Y0,A    X:<nr1,B
         CMP     B,A
         JMI     (R1)
         CLR     A
         MOVEC   LC,A1
         ENDDO
         JSR     out_set
         RTS

hyperbasin_again
         MPY     -Y0,Y0,A   X:<ix,X1
         MAC     X0,X0,A    X:<iy,Y1
         MAC     -X0,X1,A
         MAC     -Y0,Y1,A
         ASL     A
         ASL     A
         MPY     X0,Y0,B    A,X:<t
         MPY     Y0,X1,A
         ADDL    A,B
         MAC     -X0,Y1,B   X:<t,X0
         ASL     B
         ASL     B
         MOVE    B,Y0
hyperbasin_loop
         MOVE    #$01,A1
         RTS

;
; Calcul de l'orbite d'un point
; Ensembles Spider
spider_calc
         MOVE    #spider_again,R1
         ANDI    #$0F,CCR
         MOVE    X:<cx,X0
         MOVE    X:<cy,Y0
         MOVE    X0,X:<xp
         MOVE    Y0,X:<yp

         DO      X:<maxiter,spider_loop
         MPY     X0,X0,A
         MAC     Y0,Y0,A    X:<nr1,B
         CMP     B,A
         JMI     (R1)
         CLR     A
         MOVEC   LC,A1
         ENDDO
         JSR     out_set
         RTS

spider_again
         MPY     X0,Y0,B
         ASL     B
         ASL     B          X:<iy,A
         ADDL    A,B        X:<yp,A
         ADD     A,B

         MPY     -Y0,Y0,A
         MAC     X0,X0,A    B,Y0
         ASL     A          X:<ix,B
         ADDL    B,A        X:<xp,B
         ADD     B,A
         ADDR    A,B        A,X0
         TFR     Y0,A       B,X:<xp
         MOVE    X:<yp,B
         ADDR    A,B
         MOVE    B,X:<yp
spider_loop
         MOVE    #$01,A1
         RTS


;
; Calcul de 3 lignes de l'ensemble
;
compute_3lignes
         MOVE    X:<xmin,X1
         MOVE    X1,X:<cxc
         MOVE    X:<ydsp,X1
         MOVE    X1,X:<cyc
         MOVE    #-1,M0
         MOVE    #startorb,R4        ; R4 pointe la premiere ligne
         MOVE    X:<nbptx,N5
         MOVE    #startorb,R5
         MOVE    #startorb,R6
         MOVE    X:<nbptx,N6
         RND     B          (R5)+N5  ; R5 pointe la seconde ligne
         RND     B          (R6)+N6
         RND     B          (R6)+N6  ; R6 pointe la troisieme ligne
         MOVE    #preabs,R3
         MOVE    #2,N3
         MOVE    #2,N4
         MOVE    #2,N5
         MOVE    #2,N6
         MOVE    #-1,M3
         MOVE    #-1,M4
         MOVE    #-1,M5
         MOVE    #-1,M6

         MOVE    X:<cxc,X1
         MOVE    X1,X:<cx
         MOVE    X:<cyc,X1
         MOVE    X1,X:<cy
         JSR     calculate
         MOVE    A1,X:<orb00      ; orbite00 = calcul(cx,cy)
         MOVE    A1,Y:(R4)
         CLR     A     X:ech2y,X0
         MOVE    X:<cyc,A
         SUB     X0,A  X:<cxc,Y0
         MOVE    Y0,X:<cx
         MOVE    A1,X:<cy
         JSR     calculate
         MOVE    A1,X:<orb10      ; orbite10 = calcul(cx,cy-2*ey)
         MOVE    A1,Y:(R6)
         CLR     A     X:<echy,X0
         MOVE    X:<cyc,A
         SUB     X0,A  X:<cxc,Y0
         MOVE    Y0,X:<cx
         MOVE    A1,X:<cy
         JSR     calculate
         MOVE    A1,X:<orb3        ; orbite3 = calcul(cx,cy-2*ey)
         MOVE    A1,Y:(R5)

         CLR     A
         MOVE    X:<nbptx,A1
         LSR     A
         MOVE    A,R1
         NOP
         RND     B   (R1)-
         NOP
         DO      R1,end_x1
         MOVE    X:(R3+N3),X1
         MOVE    X1,X:<cx
         MOVE    X:<cyc,X1
         MOVE    X1,X:<cy
         JSR     calculate
         MOVE    A1,X:<orb01      ; orbite01 = calcul(cx+2*ex,cy)
         MOVE    A1,Y:(R4+N4)

         MOVE    X:<cyc,A
         MOVE    X:<ech2y,B
         SUB     B,A     X:(R3+N3),X1
         MOVE    X1,X:<cx
         MOVE    A1,X:<cy
         JSR     calculate
         MOVE    A1,X:<orb11      ; orbite11 = calcul(cx+2*ex,cy-2*ey)
         MOVE    A1,Y:(R6+N6)

         MOVE    X:<orb01,A       ; Si on le deduit
         CLR     B  X:<orb00,X0
         MOVE    X:<orb01,B1
         CMP     X0,B  (R4)+
         JEQ     aop1
         RND     B     (R3)+
         MOVE    X:<cyc,X1
         MOVE    X1,X:<cy
         MOVE    X:(R3)-,X1
         MOVE    X1,X:<cx
         JSR     calculate
aop1     MOVE    A1,Y:(R4)-
         MOVE    X:<orb11,A1      ; Prepare la possible deduction
         CLR     B  X:<orb10,X0
         MOVE    X:orb11,B1
         CMP     X0,B  (R6)+
         JEQ     aop2
         RND     B     (R3)+
         MOVE    X:<cyc,A
         MOVE    X:<ech2y,B
         SUB     B,A
         MOVE    A1,X:<cy
         MOVE    X:(R3)-,X1
         MOVE    X1,X:<cx
         JSR     calculate
aop2     MOVE    A1,Y:(R6)-
         MOVE    X:<orb11,X1
         MOVE    X1,X:<orb4
         MOVE    X:<orb11,A1
         CLR     B  X:<orb11,X0
         MOVE    X:<orb01,B1
         CMP     X0,B
         JEQ     aop4
         MOVE    X:<cyc,A
         MOVE    X:<echy,B
         SUB     B,A
         MOVE    A1,X:<cy
         MOVE    X:(R3+N3),X1
         MOVE    X1,X:<cx
         JSR     calculate
         MOVE    A1,X:<orb4          ; orbite4 = calcul(cx+2*ex,cy-ey)
aop4     MOVE    A1,Y:(R5+N5)
         MOVE    X:<orb4,A1
         CLR     B  X:<orb3,X0
         MOVE    X:<orb4,B1
         CMP     X0,B  (R5)+
         JEQ     aop5
         RND     B     (R3)+
         MOVE    X:<cyc,A
         MOVE    X:<echy,B
         SUB     B,A
         MOVE    A1,X:<cy
         MOVE    X:(R3)-,X1
         MOVE    X1,X:<cx
         JSR     calculate
aop5     MOVE    A1,Y:(R5)-

         MOVE    X:<orb01,X1
         MOVE    X1,X:<orb00
         MOVE    X:<orb11,X1
         MOVE    X1,X:<orb10
         MOVE    X:<orb4,X1
         MOVE    X1,X:<orb3
         RND     B  (R3)+N3
         RND     B  (R4)+N4
         RND     B  (R5)+N5
         RND     B  (R6)+N6
end_x1
         RND     B  (R4)+
         RND     B  (R5)+
         RND     B  (R6)+
         MOVE    X:<orb01,A1
         MOVE    A1,Y:(R4)
         MOVE    X:<orb4,A1
         MOVE    A1,Y:(R5)
         MOVE    X:<orb11,A1
         MOVE    A1,Y:(R6)

         RTS

;Envoi des donnees au CPU
sendata
         BCLR   #3,X:<<HCR          ; Informe le Host (Hf2 = 0)
         MOVE   #startorb,R0
         MOVE   #-1,M0
         DO     X:<nbptx,end_send
         JCLR   #1,X:<<HSR,*
         MOVEP  Y:(R0)+,X:<<HTX
         JCLR   #1,X:<<HSR,*
         MOVEP  Y:(R0)+,X:<<HTX
         JCLR   #1,X:<<HSR,*
         MOVEP  Y:(R0)+,X:<<HTX
end_send
         RTS

adr_calc
         DC     mandelbrot_calc
         DC     julia_calc
         DC     manowarm_calc
         DC     manowarj_calc
         DC     unity_calc
         DC     barnsleym_calc
         DC     barnsleyj_calc
         DC     hyperbasin_calc
         DC     spider_calc

         END    start
