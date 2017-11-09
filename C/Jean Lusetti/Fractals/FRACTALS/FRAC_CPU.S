***********************************************************
* Calcul des ensembles fractals de Mandelbrot et de Julia.*
* Pour un temps de calcul minimal, les r‚els manipul‚s    *
* Sont cod‚s sur des entiers 32 bits.                     *
* Pour passer du nombre r‚el … sa repr‚sentation entiŠre, *
* On le multiplie par 2 … la puissance 28, ce qui donne   *
* Une pr‚cision d'environ 3.7 E-09.                       *
* Ainsi le r‚el 1.0 est repr‚sent‚ par $10000000.         *
* Le microprocesseur doit ˆtre au moins un 68030.         *
* R“le du CPU 68030 :                                     *
* - Participer au calcul de l'image avec le DSP 56001     *
* - Recevoir et stocker les orbites calcul‚es par le DSP  *
* - G‚rer les variables communes                          *
* - Afficher l'image dŠs que le calcul est termin‚.       *
* NB : Si le calcul doit se faire sur des r‚els, le r“le  *
*      du CPU se limite au stockage des donn‚es.          *
***********************************************************
N1          EQU       $10000000
N2          EQU       $20000000
NM2         EQU       $e0000000
N4          EQU       $40000000
BIOS        EQU       13
CTRL_C      EQU       $002E0003
Bconstat    EQU       1
Bconin      EQU       2
STOPCPU     EQU       3*10


            .IMPORT   Multitos, udt_scr
			.IMPORT   adr_data, pre_ligne, preabscpu
			.IMPORT   affiche_progression_calcul
            .IMPORT   dsp_go, receiver, with_dsp
			.IMPORT   nbl_cpu, nbl_fpu, nbl_dsp
			.IMPORT   stat_calc, max_iter, type
			.IMPORT   nbpt_x, nbpt_y, curr_ligne, curr_x, curr_y
			.IMPORT   xc, yc, cos_a, sin_a, angle

			.EXPORT   init_x, init_y, stat_calc, max_iter, type
			.EXPORT   xmin, ymax, ech_x, ech_y, ech2_x, ech2_y
			.EXPORT   nbl_cpu, nbl_fpu, nbl_dsp, ccy
			.EXPORT   asm_fractal
			.EXPORT   tst_kbd, stocke_orbite


asm_fractal:
			MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte
			CLR.W     nbl_cpu
			CLR.W     nbl_fpu
			CLR.W     nbl_dsp
			CLR.W     stat_calc
			MOVE.W    type,D0
			LEA.L     adr_calc,A3
			MOVE.L    (A3,D0.W*4),A3
            BSR       compute_set
retour:     MOVEM.L   (SP)+,D0-D7/A0-A6 ; Restauration du contexte
			RTS                         ; Retour au programme C

***********************************************
* Renvoie dans D0 le code de la touche appuy‚ *
* Ou 0 si on n'a pas appuy‚ sur une touche.   *
***********************************************
tst_kbd:    MOVE.W    #2,-(SP)          ; Interroger le clavier
			MOVE.W    #Bconstat,-(SP)
			TRAP      #BIOS
			ADDQ.L    #4,SP
			TST.W     D0                ; A-t-on appuy‚ sur une touche ?
			BEQ       ret_tst           ; Non : le calcul se poursuit
			MOVE.W    #2,-(SP)
			MOVE.W    #Bconin,-(SP)     ; Oui : on va chercher le caractŠre
			TRAP      #BIOS
			ADDQ.L    #4,SP
			ANDI.L    #$00FF00FF,D0
ret_tst:    RTS


****************************************************************************************
* Rotation de centre (xc,yc) du point (A0,A1) d'angle angle (d‚fini par cos_a et sin_a)
* R‚sultat dans (A0,A1)
* Registres modifi‚s : D0-D7, A0,A1
****************************************************************************************
rotate:
            MOVE.L    A0,D0
            SUB.L     xc,D0             ; D0 = x-xc
            MOVE.L    A1,D1
            SUB.L     yc,D1             ; D1 = y-yc
            MOVE.L    cos_a,D2
            MOVE.L    sin_a,D3
			MOVEQ     #$0f,D4           ; Pr‚pare le masque
			MOVEQ     #4,D5             ; Pr‚pare les d‚calages

            MOVE.L    D0,D6
            MULS.L    D2,D7:D6
			ASL.L     D5,D7
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D7             ; D7 = (x-xc)*cos_a
			MOVE.L    D7,A0             ; A0 = (x-xc)*cos_a

            MOVE.L    D1,D6
            MULS.L    D3,D7:D6
			ASL.L     D5,D7
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D7             ; D7 = (y-yc)*sin_a
			ADD.L     D7,A0             ; A0 = (x-xc)*cos_a+(y-yc)*sin_a

            MOVE.L    D1,D6
            MULS.L    D2,D7:D6
			ASL.L     D5,D7
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D7             ; D7 = (y-yc)*cos_a
			MOVE.L    D7,A1             ; A1 = (y-yc)*cos_a

            MOVE.L    D0,D6
            MULS.L    D3,D7:D6
			ASL.L     D5,D7
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D7             ; D7 = (x-xc)*sin_a
			SUB.L     D7,A1             ; A1 = -(x-xc)*sin_a+(y-yc)*cos_a

            ADD.L     xc,A0
            ADD.L     yc,A1

            RTS


***************************************************************************************
* Routine de calcul g‚n‚rale
* (A0,A1) est le point courant du plan complexe (fourni par l'algorithme des 3 lignes)
* A3 pointe sur la routine sp‚cifique de calcul
* Au cours de cette routine, tous les registres peuvent ˆtre modifi‚s
* … l'exception de A3 (routine sp‚cifique de calcul) et A4 (pr‚calcul de ligne)
* Une ‚ventuelle rotation est prise en compte
***************************************************************************************
calculate:
            TST.W     angle
            BEQ       after_rotation
            BSR       rotate

after_rotation:
            JMP       (A3)              ; Appel du calcul sp‚cifique

in_set:     MOVEQ     #$01,D7           ; 1 signifie que le critŠre de
                                        ; Divergence n'a pas ‚t‚ confirm‚
			RTS                         ; D7 contient l'orbite du point
out_calculate:
            NEG.W     D7
			ADD.W     max_iter,D7
            ADDQ.W    #$01,D7           ; Sinon on renvoit 1+iter

			RTS                         ; D7 contient l'orbite du point


********************************************
* Calcul de l'orbite d'un point.           *
* Ensembles de Mandelbrot                  *
********************************************
mandelbrot_calc:
			MOVEQ     #4,D5             ; Pr‚pare les d‚calages
			MOVEQ     #$0f,D4           ; Pr‚pare le masque
			MOVEA.L   #N4,A2            ; Pr‚pare la comparaison …  4.0
			MOVEA.L   #NM2,A5           ; Pr‚pare la comparaison … -2.0
			MOVEA.L   #N2,A6            ; Pr‚pare la comparaison …  2.0
			MOVEQ     #0,D7
			MOVE.W    max_iter,D7
			MOVE.L    init_x,D0             ; x = D0 = ix
			MOVE.L    init_y,D1             ; y = D1 = iy
mandelbrot_loop:
            SUBQ.W    #1,D7
			BEQ       in_set

			CMP.L     A6,D0
			BGE       out_calculate     ; Arrˆt si x > 2.0
			CMP.L     A5,D0
			BLE       out_calculate     ; Ou si x < -2.0
			MOVE.L    D0,D6
			MULS.L    D0,D2:D6
			ASL.L     D5,D2
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D2             ; x1 = D2 = x*x

			CMP.L     A6,D1
			BGE       out_calculate     ; Arrˆt si y > 2.0
			CMP.L     A5,D1
			BLE       out_calculate     ; Ou si y < -2.0
			MOVE.L    D1,D6
			MULS.L    D1,D3:D6
			ASL.L     D5,D3
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D3             ; y1 = D3 = y*y
			MOVE.L    D2,D6
			ADD.L     D3,D6             ; D6 = x1 + y1
			CMP.L     D6,A2             ; x1 + y1 > 4 ?
			BMI       out_calculate

			MOVE.L    D1,D6
			MULS.L    D0,D1:D6
			ASL.L     D5,D1
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D1             ; y = D1 = x*y
			ADD.L     D1,D1             ; y = 2*x*y
			ADD.L     A1,D1             ; y = 2*x*y+cy
			BVS       out_calculate

			MOVE.L    D2,D0             ; x = x1
			SUB.L     D3,D0             ; x = x1-y1
			ADD.L     A0,D0             ; x = x1-y1+cx
			BRA       mandelbrot_loop



********************************************
* Calcul de l'orbite d'un point.           *
* Ensembles de Julia                       *
********************************************
julia_calc:
			MOVEQ     #4,D5             ; Pr‚pare les d‚calages
			MOVEQ     #$0f,D4           ; Pr‚pare le masque
			MOVEA.L   #N4,A2            ; Pr‚pare la comparaison …  4.0
			MOVEA.L   #NM2,A5           ; Pr‚pare la comparaison … -2.0
			MOVEA.L   #N2,A6            ; Pr‚pare la comparaison …  2.0
			MOVEQ     #0,D7
			MOVE.W    max_iter,D7
			MOVE.L    A0,D0             ; x = D0 = ix
			MOVE.L    A1,D1             ; y = D1 = iy
			MOVE.L    init_x,A0
			MOVE.L    init_y,A1
julia_loop:
            SUBQ.W    #1,D7
			BEQ       in_set

			CMP.L     A6,D0
			BGE       out_calculate     ; Arrˆt si x > 2.0
			CMP.L     A5,D0
			BLE       out_calculate     ; Ou si x < -2.0
			MOVE.L    D0,D6
			MULS.L    D0,D2:D6
			ASL.L     D5,D2
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D2             ; x1 = D2 = x*x

			CMP.L     A6,D1
			BGE       out_calculate     ; Arrˆt si y > 2.0
			CMP.L     A5,D1
			BLE       out_calculate     ; Ou si y < -2.0
			MOVE.L    D1,D6
			MULS.L    D1,D3:D6
			ASL.L     D5,D3
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D3             ; y1 = D3 = y*y
			MOVE.L    D2,D6
			ADD.L     D3,D6             ; D6 = x1 + y1
			CMP.L     D6,A2             ; x1 + y1 > 4 ?
			BMI       out_calculate

			MOVE.L    D1,D6
			MULS.L    D0,D1:D6
			ASL.L     D5,D1
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D1             ; y = D1 = x*y
			ADD.L     D1,D1             ; y = 2*x*y
			ADD.L     A1,D1             ; y = 2*x*y+cy
			BVS       out_calculate

			MOVE.L    D2,D0             ; x = x1
			SUB.L     D3,D0             ; x = x1-y1
			ADD.L     A0,D0             ; x = x1-y1+cx
			BRA       julia_loop


*********************************
* Calcul de l'orbite d'un point *
* Ensembles ManowarM            *
*********************************
manowarm_calc:
			MOVEA.L   #N4,A2            ; Pr‚pare la comparaison …  4.0
			MOVEA.L   #NM2,A5           ; Pr‚pare la comparaison … -2.0
			MOVEA.L   #N2,A6            ; Pr‚pare la comparaison …  2.0
			MOVEQ     #0,D7
			MOVE.W    max_iter,D7
			MOVE.L    init_x,D0         ; x = D0 = ix
			MOVE.L    init_y,D1         ; y = D1 = iy
			MOVE.L    D0,D4
			MOVE.L    D1,D5
manowarm_loop:
            SUBQ.W    #1,D7
			BEQ       in_set

			CMP.L     A6,D0
			BGE       out_calculate     ; Arrˆt si x > 2.0
			CMP.L     A5,D0
			BLE       out_calculate     ; Ou si x < -2.0
			MOVE.L    D0,D6
			MULS.L    D0,D2:D6
			ASL.L     #4,D2
			ROR.L     #4,D6
			AND.L     #$0F,D6
			OR.L      D6,D2             ; x1 = D2 = x*x

			CMP.L     A6,D1
			BGE       out_calculate     ; Arrˆt si y > 2.0
			CMP.L     A5,D1
			BLE       out_calculate     ; Ou si y < -2.0
			MOVE.L    D1,D6
			MULS.L    D1,D3:D6
			ASL.L     #4,D3
			ROR.L     #4,D6
			AND.L     #$0F,D6
			OR.L      D6,D3             ; y1 = D3 = y*y
			MOVE.L    D2,D6
			ADD.L     D3,D6             ; D6 = x1 + y1
			CMP.L     D6,A2             ; x1 + y1 > 4 ?
			BMI       out_calculate

            MOVE.L    D0,-(SP)
            MOVE.L    D1,-(SP)          ; Sauve valeurs x et y
			MOVE.L    D1,D6
			MULS.L    D0,D1:D6
			ASL.L     #4,D1
			ROR.L     #4,D6
			AND.L     #$0F,D6
			OR.L      D6,D1             ; y = D1 = x*y
			ADD.L     D1,D1             ; y = 2*x*y
			ADD.L     A1,D1
			ADD.L     D5,D1             ; D1 = y = 2*x*y+y'+cy
			BVS       out_calculate

            MOVE.L    D2,D6
            SUB.L     D3,D6
            MOVE.L    D6,D0
            ADD.L     D4,D0
            ADD.L     A0,D0             ; D0 = x = x*x-y*y-x'+cx

            MOVE.L    (SP)+,D5          ; y' = last y
            MOVE.L    (SP)+,D4          ; x' = last x
			BRA       manowarm_loop


*********************************
* Calcul de l'orbite d'un point *
* Ensembles ManoWarJ            *
*********************************
manowarj_calc:
			MOVEA.L   #N4,A2            ; Pr‚pare la comparaison …  4.0
			MOVEA.L   #NM2,A5           ; Pr‚pare la comparaison … -2.0
			MOVEA.L   #N2,A6            ; Pr‚pare la comparaison …  2.0
			MOVEQ     #0,D7
			MOVE.W    max_iter,D7
			MOVE.L    A0,D0             ; x = D0 = ix
			MOVE.L    A1,D1             ; y = D1 = iy
			MOVE.L    D0,D4
			MOVE.L    D1,D5
			MOVE.L    init_x,A0
			MOVE.L    init_y,A1
manowarj_loop:
            SUBQ.W    #1,D7
			BEQ       in_set

			CMP.L     A6,D0
			BGE       out_calculate     ; Arrˆt si x > 2.0
			CMP.L     A5,D0
			BLE       out_calculate     ; Ou si x < -2.0
			MOVE.L    D0,D6
			MULS.L    D0,D2:D6
			ASL.L     #4,D2
			ROR.L     #4,D6
			AND.L     #$0F,D6
			OR.L      D6,D2             ; x1 = D2 = x*x

			CMP.L     A6,D1
			BGE       out_calculate     ; Arrˆt si y > 2.0
			CMP.L     A5,D1
			BLE       out_calculate     ; Ou si y < -2.0
			MOVE.L    D1,D6
			MULS.L    D1,D3:D6
			ASL.L     #4,D3
			ROR.L     #4,D6
			AND.L     #$0F,D6
			OR.L      D6,D3             ; y1 = D3 = y*y
			MOVE.L    D2,D6
			ADD.L     D3,D6             ; D6 = x1 + y1
			CMP.L     D6,A2             ; x1 + y1 > 4 ?
			BMI       out_calculate

            MOVE.L    D0,-(SP)
            MOVE.L    D1,-(SP)          ; Sauve valeurs x et y
			MOVE.L    D1,D6
			MULS.L    D0,D1:D6
			ASL.L     #4,D1
			ROR.L     #4,D6
			AND.L     #$0F,D6
			OR.L      D6,D1             ; y = D1 = x*y
			ADD.L     D1,D1             ; y = 2*x*y
			ADD.L     A1,D1
			ADD.L     D5,D1             ; D1 = y = 2*x*y+y'+cy
			BVS       out_calculate

            MOVE.L    D2,D6
            SUB.L     D3,D6
            MOVE.L    D6,D0
            ADD.L     D4,D0
            ADD.L     A0,D0             ; D0 = x = x*x-y*y-x'+cx

            MOVE.L    (SP)+,D5          ; y' = last y
            MOVE.L    (SP)+,D4          ; x' = last x
			BRA       manowarj_loop



*********************************
* Calcul de l'orbite d'un point *
* Ensembles Unity               *
*********************************
unity_calc :
			MOVEQ     #4,D5             ; Pr‚pare les d‚calages
			MOVEQ     #$0f,D4           ; Pr‚pare le masque
			MOVEA.L   #N4,A2            ; Pr‚pare la comparaison …  4.0
			MOVEA.L   #NM2,A5           ; Pr‚pare la comparaison … -2.0
			MOVEA.L   #N2,A6            ; Pr‚pare la comparaison …  2.0
			MOVEQ     #0,D7
			MOVE.W    max_iter,D7
			MOVE.L    A0,D0             ; x = D0
			MOVE.L    A1,D1             ; y = D1
			MOVE.L    init_x,A0
			MOVE.L    init_y,A1
unity_loop: SUBQ.W    #1,D7
			BEQ       in_set

			CMP.L     A6,D0
			BGE       out_calculate     ; Arrˆt si x > 2.0
			CMP.L     A5,D0
			BLE       out_calculate     ; Ou si x < -2.0
			MOVE.L    D0,D6
			MULS.L    D0,D2:D6
			ASL.L     D5,D2
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D2             ; x1 = D2 = x*x

			CMP.L     A6,D1
			BGE       out_calculate     ; Arrˆt si y > 2.0
			CMP.L     A5,D1
			BLE       out_calculate     ; Ou si y < -2.0
			MOVE.L    D1,D6
			MULS.L    D1,D3:D6
			ASL.L     D5,D3
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D3             ; y1 = D3 = y*y
			MOVE.L    D2,D6
			ADD.L     D3,D6             ; D6 = x1 + y1
			CMP.L     D6,A2             ; x1 + y1 > 4 ?
			BMI       out_calculate

            NEG.L     D6
            MOVE.L    D6,D2
            ADD.L     A1,D6

            MOVE.L    D1,D3             ; Sauve y
			MULS.L    D0,D1:D6
			ASL.L     D5,D1
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D1             ; y = D1 = (2-(x*x+y*y))*x

            MOVE.L    D2,D6
            ADD.L     A0,D6
			MULS.L    D1,D0:D6
			ASL.L     D5,D0
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D0             ; x = D0 = (2-(x*x+y*y))*y

			BRA       unity_loop


********************************************
* Calcul de l'orbite d'un point.           *
* Ensembles de BarnsleyM                   *
********************************************
barnsleym_calc:
			MOVEQ     #4,D5             ; Pr‚pare les d‚calages
			MOVEQ     #$0f,D4           ; Pr‚pare le masque
			MOVEA.L   #N4,A2            ; Pr‚pare la comparaison …  4.0
			MOVEA.L   #NM2,A5           ; Pr‚pare la comparaison … -2.0
			MOVEA.L   #N2,A6            ; Pr‚pare la comparaison …  2.0
			MOVEQ     #0,D7
			MOVE.W    max_iter,D7
			MOVE.L    init_x,D0             ; x = D0 = ix
			MOVE.L    init_y,D1             ; y = D1 = iy
barnsleym_loop:
            SUBQ.W    #1,D7
			BEQ       in_set

			CMP.L     A6,D0
			BGE       out_calculate     ; Arrˆt si x > 2.0
			CMP.L     A5,D0
			BLE       out_calculate     ; Ou si x < -2.0

			CMP.L     A6,D1
			BGE       out_calculate     ; Arrˆt si x > 2.0
			CMP.L     A5,D1
			BLE       out_calculate     ; Ou si x < -2.0

            MOVE.L    D0,D6
            MULS.L    D6,D2:D6
			ASL.L     D5,D2
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D2             ; D2 = x*x

            MOVE.L    D1,D6
            MULS.L    D6,D3:D6
			ASL.L     D5,D3
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D3             ; D3 = y*y

            ADD.L     D3,D2             ; D2 = x*x+y*y
            CMP.L     A2,D2
            BGT       out_calculate

			MOVE.L    A1,D6
			MULS.L    D0,D2:D6
			ASL.L     D5,D2
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D2             ; t1 = D2 = x*cy

			MOVE.L    A0,D6
			MULS.L    D1,D3:D6
			ASL.L     D5,D3
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D3             ; t2 = D3 = y*cx
			ADD.L     D3,D2             ; D2 = t = t1+t2 = x*cy+y*cx
            MOVE.L    D2,t              ; Sauve D2 = t

            BGT       t_is_positifm
            MOVE.L    D0,D6
            ADDI.L    #N1,D6            ; D6 = 1.0+x
            MOVE.L    A0,D2
            MULS.L    D2,D2:D6
			ASL.L     D5,D2
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D2             ; D2 = (1+x)*cx
            MOVE.L    A1,D6
            MULS.L    D1,D3:D6
			ASL.L     D5,D3
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D3             ; D3 = y*cy
            SUB.L     D3,D2             ; D2 = (1+x)*cx-y*cy
            MOVE.L    D2,D0             ; D0 = x = (1+x)*cx-y*cy

            MOVE.L    A1,D1
            ADD.L     t,D1              ; D1 = y = t+cy
			BRA       barnsleym_loop
t_is_positifm:
            MOVE.L    D0,D6
            SUBI.L    #N1,D6            ; D6 = x-1.0
            MOVE.L    A0,D2
            MULS.L    D2,D2:D6
			ASL.L     D5,D2
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D2             ; D2 = (x-1)*cx
            MOVE.L    A1,D6
            MULS.L    D1,D3:D6
			ASL.L     D5,D3
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D3             ; D3 = y*cy
            SUB.L     D3,D2             ; D2 = (x-1)*cx-y*cy
            MOVE.L    D2,D0             ; D0 = x = (x-1)*cx-y*cy

            MOVE.L    t,D1
            SUB.L     A1,D1             ; D1 = y = t-cy
			BRA       barnsleym_loop


********************************************
* Calcul de l'orbite d'un point.           *
* Ensembles de BarnsleyJ                   *
********************************************
barnsleyj_calc:
			MOVEQ     #4,D5             ; Pr‚pare les d‚calages
			MOVEQ     #$0f,D4           ; Pr‚pare le masque
			MOVEA.L   #N4,A2            ; Pr‚pare la comparaison …  4.0
			MOVEA.L   #NM2,A5           ; Pr‚pare la comparaison … -2.0
			MOVEA.L   #N2,A6            ; Pr‚pare la comparaison …  2.0
			MOVEQ     #0,D7
			MOVE.W    max_iter,D7
			MOVE.L    A0,D0             ; x = D0 = ix
			MOVE.L    A1,D1             ; y = D1 = iy
			MOVE.L    init_x,A0
			MOVE.L    init_y,A1
barnsleyj_loop:
            SUBQ.W    #1,D7
			BEQ       in_set

			CMP.L     A6,D0
			BGE       out_calculate     ; Arrˆt si x > 2.0
			CMP.L     A5,D0
			BLE       out_calculate     ; Ou si x < -2.0

			CMP.L     A6,D1
			BGE       out_calculate     ; Arrˆt si x > 2.0
			CMP.L     A5,D1
			BLE       out_calculate     ; Ou si x < -2.0

            MOVE.L    D0,D6
            MULS.L    D6,D2:D6
			ASL.L     D5,D2
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D2             ; D2 = x*x

            MOVE.L    D1,D6
            MULS.L    D6,D3:D6
			ASL.L     D5,D3
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D3             ; D3 = y*y

            ADD.L     D3,D2             ; D2 = x*x+y*y
            CMP.L     A2,D2
            BGT       out_calculate

			MOVE.L    A1,D6
			MULS.L    D0,D2:D6
			ASL.L     D5,D2
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D2             ; t1 = D2 = x*cy

			MOVE.L    A0,D6
			MULS.L    D1,D3:D6
			ASL.L     D5,D3
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D3             ; t2 = D3 = y*cx
			ADD.L     D3,D2             ; D2 = t = t1+t2 = x*cy+y*cx
            MOVE.L    D2,t              ; Sauve D2 = t

            BGT       t_is_positifj
            MOVE.L    D0,D6
            ADDI.L    #N1,D6            ; D6 = 1.0+x
            MOVE.L    A0,D2
            MULS.L    D2,D2:D6
			ASL.L     D5,D2
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D2             ; D2 = (1+x)*cx
            MOVE.L    A1,D6
            MULS.L    D1,D3:D6
			ASL.L     D5,D3
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D3             ; D3 = y*cy
            SUB.L     D3,D2             ; D2 = (1+x)*cx-y*cy
            MOVE.L    D2,D0             ; D0 = x = (1+x)*cx-y*cy

            MOVE.L    A1,D1
            ADD.L     t,D1              ; D1 = y = t+cy
			BRA       barnsleyj_loop
t_is_positifj:
            MOVE.L    D0,D6
            SUBI.L    #N1,D6            ; D6 = x-1.0
            MOVE.L    A0,D2
            MULS.L    D2,D2:D6
			ASL.L     D5,D2
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D2             ; D2 = (x-1)*cx
            MOVE.L    A1,D6
            MULS.L    D1,D3:D6
			ASL.L     D5,D3
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D3             ; D3 = y*cy
            SUB.L     D3,D2             ; D2 = (x-1)*cx-y*cy
            MOVE.L    D2,D0             ; D0 = x = (x-1)*cx-y*cy

            MOVE.L    t,D1
            SUB.L     A1,D1             ; D1 = y = t-cy
			BRA       barnsleyj_loop

********************************************
* Calcul de l'orbite d'un point.           *
* Ensembles de HyperBasin                  *
********************************************
hyperbasin_calc:
			MOVEQ     #4,D5             ; Pr‚pare les d‚calages
			MOVEQ     #$0f,D4           ; Pr‚pare le masque
			MOVEA.L   #N4,A2            ; Pr‚pare la comparaison …  4.0
			MOVEA.L   #NM2,A5           ; Pr‚pare la comparaison … -2.0
			MOVEA.L   #N2,A6            ; Pr‚pare la comparaison …  2.0
			MOVEQ     #0,D7
			MOVE.W    max_iter,D7
			MOVE.L    A0,D0             ; x = D0 = ix
			MOVE.L    A1,D1             ; y = D1 = iy
			MOVE.L    init_x,A0
			MOVE.L    init_y,A1
hyperbasin_loop:
            SUBQ.W    #1,D7
			BEQ       in_set

			CMP.L     A6,D0
			BGE       out_calculate     ; Arrˆt si x > 2.0
			CMP.L     A5,D0
			BLE       out_calculate     ; Ou si x < -2.0
			MOVE.L    D0,D6
			MULS.L    D0,D2:D6
			ASL.L     D5,D2
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D2             ; x1 = D2 = x*x

			CMP.L     A6,D1
			BGE       out_calculate     ; Arrˆt si y > 2.0
			CMP.L     A5,D1
			BLE       out_calculate     ; Ou si y < -2.0
			MOVE.L    D1,D6
			MULS.L    D1,D3:D6
			ASL.L     D5,D3
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D3             ; y1 = D3 = y*y
			MOVE.L    D2,D6
			ADD.L     D3,D6             ; D6 = x1 + y1
			CMP.L     D6,A2             ; x1 + y1 > 4 ?
			BMI       out_calculate

            SUB.L     D3,D2             ; D2 = x*x-y*y
			MOVE.L    A0,D6
			MULS.L    D0,D3:D6
			ASL.L     D5,D3
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D3             ; D3 = x*ix
			SUB.L     D3,D2             ; D2 = x*x-y*y-x*ix
            
			MOVE.L    A1,D6
			MULS.L    D1,D3:D6
			ASL.L     D5,D3
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D3             ; D3 = y*iy
			SUB.L     D3,D2             ; D2 = x*x-y*y-x*ix-y*iy

			MOVE.L    A1,D6
			MULS.L    D0,D3:D6
			ASL.L     D5,D3
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D3             ; D3 = x*iy

			ADD.L     D0,D0             ; D0 = 2*x
			ADD.L     A0,D0             ; D0 = 2*x+ix
			MOVE.L    D1,D6
			MULS.L    D0,D1:D6
			ASL.L     D5,D1
			ROR.L     D5,D6
			AND.L     D4,D6
			OR.L      D6,D1             ; D1 = (2*x+ix)*y

			SUB.L     D3,D1             ; y = D1 = (2*x+ix)*y-x*iy
			MOVE.L    D2,D0             ; x = D0 = x*x-y*y-x*ix-y*iy
			BRA       hyperbasin_loop

*********************************
* Calcul de l'orbite d'un point *
* Ensembles Spider              *
*********************************
spider_calc:
			MOVEA.L   #N4,A2            ; Pr‚pare la comparaison …  4.0
			MOVEA.L   #NM2,A5           ; Pr‚pare la comparaison … -2.0
			MOVEA.L   #N2,A6            ; Pr‚pare la comparaison …  2.0
			MOVEQ     #0,D7
			MOVE.W    max_iter,D7
			MOVE.L    A0,D0             ; x = D0 = ix
			MOVE.L    A1,D1             ; y = D1 = iy
			MOVE.L    D0,D4
			MOVE.L    D1,D5
			MOVE.L    init_x,A0
			MOVE.L    init_y,A1
spider_loop:
            SUBQ.W    #1,D7
			BEQ       in_set

			CMP.L     A6,D0
			BGE       out_calculate     ; Arrˆt si x > 2.0
			CMP.L     A5,D0
			BLE       out_calculate     ; Ou si x < -2.0
			MOVE.L    D0,D6
			MULS.L    D0,D2:D6
			ASL.L     #4,D2
			ROR.L     #4,D6
			AND.L     #$0F,D6
			OR.L      D6,D2             ; x1 = D2 = x*x

			CMP.L     A6,D1
			BGE       out_calculate     ; Arrˆt si y > 2.0
			CMP.L     A5,D1
			BLE       out_calculate     ; Ou si y < -2.0
			MOVE.L    D1,D6
			MULS.L    D1,D3:D6
			ASL.L     #4,D3
			ROR.L     #4,D6
			AND.L     #$0F,D6
			OR.L      D6,D3             ; y1 = D3 = y*y
			MOVE.L    D2,D6
			ADD.L     D3,D6             ; D6 = x1 + y1
			CMP.L     D6,A2             ; x1 + y1 > 4 ?
			BMI       out_calculate

			MOVE.L    D1,D6
			MULS.L    D0,D1:D6
			ASL.L     #4,D1
			ROR.L     #4,D6
			AND.L     #$0F,D6
			OR.L      D6,D1             ; y = D1 = x*y
			ADD.L     D1,D1             ; y = 2*x*y
			ADD.L     D5,D1             ; D1 = y = 2*x*y+y'
			ADD.L     A1,D1
			BVS       out_calculate

            MOVE.L    D2,D6
            SUB.L     D3,D6
            MOVE.L    D6,D0             ; D0 = x = x*x-y*y
            ADD.L     D4,D0             ; D0 = x = x*x-y*y+x'
            ADD.L     A0,D0

            ASR.L     #1,D4
            ADD.L     D0,D4             ; D4 = x' = x+x'/2
            ASR.L     #1,D5
            ADD.L     D1,D5             ; D5 = y' = y+y'/2
			BRA       spider_loop

********************************************
* Calcul de l'orbite d'un point.           *
* Ensembles de Sierpinski                  *
********************************************
sierpinski_calc:
			MOVEA.L   #NM2,A5           ; Pr‚pare la comparaison … -2.0
			MOVEA.L   #N2,A6            ; Pr‚pare la comparaison …  2.0
			MOVEQ     #0,D7
			MOVE.W    max_iter,D7
			MOVE.L    A0,D0
			MOVE.L    A1,D1
			MOVE.L    init_x,A0             ; x = D0 = ix
			SUB.L     #N1,A0
			MOVE.L    init_y,A1             ; y = D1 = iy
			SUB.L     #N1,A1
sierpinski_loop:
            SUBQ.W    #1,D7
			BEQ       in_set

			CMP.L     A6,D0
			BGE       out_calculate     ; Arrˆt si x > 2.0
			CMP.L     A5,D0
			BLE       out_calculate     ; Ou si x < -2.0

			CMP.L     A6,D1
			BGE       out_calculate     ; Arrˆt si y > 2.0
			CMP.L     A5,D1
			BLE       out_calculate     ; Ou si y < -2.0

            ADD.L     D0,D0             ; x = 2*x
            ADD.L     D1,D1             ; y = 2*y

            CMP.L     #N1,D1             ; 2*y > 1 ?
            BGE       s_yg05
            CMP.L     #N1,D0             ; 2*x > 1 ?
            BGE       s_xg05
			BRA       sierpinski_loop

s_yg05:     ADD.L     A1,D1          
			BRA       sierpinski_loop
s_xg05:     ADD.L     A0,D0          
			BRA       sierpinski_loop


***********************************************
* Routine de calcul de l'ensemble en totalit‚ *
***********************************************
compute_set:
			CLR.W     curr_y
			CLR.W     curr_ligne
			MOVE.L    ymax,cy
			MOVE.L    ymax,ccy
            JSR       dsp_go            ; Initialise les donn‚es DSP,
                                        ; Lance le calcul de la ligne 3
			LEA.L     pre_ligne,A4      ; Pr‚calcul pour stocke_orbite
yloop:
			BSR       compute_3lignes
			ADDQ.W    #3,nbl_cpu        ; 3 lignes viennent d'ˆtre calcul‚es
			BSR       tst_kbd
			CMPI.L    #CTRL_C,D0        ; CTRL-C ?
			BNE       next_calc         ; Non : le calcul se poursuit
			MOVE.W    #1,stat_calc      ; Oui : le calcul s'arrˆte
			BRA       fin
next_calc:  MOVE.L    ccy,save_ccy
            MOVE.L    ech2_y,D0
			SUB.L     D0,ccy
			MOVE.L    ech_y,D0
			SUB.L     D0,ccy            ; ccy = ccy-3*ey
			MOVE.L    ccy,cy
			MOVE.W    curr_ligne,save_currl
			ADDQ.W    #3,curr_ligne

			CMPI.W    #$1,Multitos
			BNE       no_Mint
* Si on est sous Multitos, effectue les ‚ventuels Redraws
			JSR       udt_scr
no_Mint :
			JSR       affiche_progression_calcul
			MOVE.W    curr_ligne, curr_y
			MOVE.W    curr_y,A5
			CMP.B     #1,with_dsp
			BNE       no_dsp
			ADD.W     #STOPCPU,A5
no_dsp:     CMPA.W    nbpt_y,A5
			BMI       yloop             ; Fin de la boucle sur les ordonn‚es

            MOVE.L    save_ccy,ccy
            MOVE.W    save_currl,curr_ligne
			CLR.W     stat_calc         ; Le calcul n'a pas ‚t‚ interrompu
fin:        RTS



******************************************
* M‚morise l'orbite D7 du point (A5,A6)  *
* Si le point a r‚pondu au critŠre de    *
* Divergence, on place $01 comme valeur. *
* Si orbite % 256 = $01, on place $02.   *
* Registres modifi‚s : D0, A2            *
******************************************
stocke_orbite:
			MOVE.L    (A4,A6.W*4),A2
			ADD.L     adr_data,A2
            CMPI.B    #$01,D7
			BNE       no_change
			MOVE.W    D7,D6
			ANDI.W    #$FF00,D6
			BEQ       no_change
			MOVE.B    #$02,(A2,A5.W)
			RTS
no_change:  MOVE.B    D7,(A2,A5.W)
			RTS



*********************************************
* Routine g‚n‚rale de calcul de 3 lignes
* D‚duction des points centraux si possible
*********************************************
compute_3lignes:
            MOVE.L    xmin,cx
			CLR.W     curr_x
			MOVE.L    cx,A0
			MOVE.L    cy,A1
			BSR calculate
			MOVE.W    D7,orbite00       ; orbite00 = calcul(cx,cy)
			MOVE.W    curr_x,A5
			MOVE.W    curr_y,A6
			BSR       stocke_orbite
			MOVE.L    cx,A0
			MOVE.L    cy,A1
			SUB.L     ech_y,A1
			BSR calculate
			MOVE.W    D7,orbite3        ; orbite3 = calcul(cx,cy-ey)
			MOVE.W    curr_x,A5
			MOVE.W    curr_y,A6
			ADDQ.W    #1,A6
			BSR       stocke_orbite
			MOVE.L    cx,A0
			MOVE.L    cy,A1
			SUB.L     ech2_y,A1
			BSR calculate
			MOVE.W    D7,orbite10       ; orbite10 = calcul(cx,cy-2ey)
			MOVE.W    curr_x,A5
			MOVE.W    curr_y,A6
			ADDQ.W    #2,A6
			BSR       stocke_orbite

xloop:      MOVE.L    cx,A0
			ADD.L     ech2_x,A0
			MOVE.L    cy,A1
			BSR calculate
			MOVE.W    D7,orbite01       ; orbite01 = calcul(cx+2*ex,cy)
			MOVE.W    curr_x,A5
			ADDQ.W    #2,A5
			MOVE.W    curr_y,A6
			BSR       stocke_orbite
            MOVE.L    cx,A0
			ADD.L     ech2_x,A0
			MOVE.L    cy,A1
			SUB.L     ech2_y,A1
			BSR calculate
			MOVE.W    D7,orbite11       ; orbite11 = calcul(cx+2*ex,cy-2*ey)
			MOVE.W    curr_x,A5
			ADDQ.W    #2,A5
			MOVE.W    curr_y,A6
			ADDQ.W    #2,A6
			BSR       stocke_orbite

			MOVE.W    orbite01,D7       ; Si on le d‚duit
			MOVE.W    orbite01,A5
			CMPA.W    orbite00,A5
			BEQ       aop1              ; on le d‚duit
			MOVE.L    cx,A0             ; on est oblig‚ de le calculer
			ADD.L     ech_x,A0
			MOVE.L    cy,A1
			BSR calculate
aop1 :      MOVE.W    curr_x,A5         ; on le recopie
			ADDQ.W    #1,A5
			MOVE.W    curr_y,A6
			BSR       stocke_orbite

			MOVE.W    orbite11,D7       ; Si on le d‚duit
			MOVE.W    orbite11,A5
			CMPA.W    orbite10,A5
			BEQ       aop2              ; on le d‚duit
			MOVE.L    cx,A0             ; on est oblig‚ de le calculer
			ADD.L     ech_x,A0
			MOVE.L    cy,A1
			SUB.L     ech2_y,A1
			BSR calculate
aop2:       MOVE.W    curr_x,A5
			ADDQ.W    #1,A5
			MOVE.W    curr_y,A6
			ADDQ.W    #2,A6
			BSR       stocke_orbite

			MOVE.W    orbite11,orbite4  ; Si on le d‚duit
			MOVE.W    orbite11,D7
			MOVE.W    orbite11,A5
			CMPA.W    orbite01,A5
			BEQ       aop4              ; on le d‚duit
			MOVE.L    cx,A0             ; on est oblig‚ de le calculer
			ADD.L     ech2_x,A0
			MOVE.L    cy,A1
			SUB.L     ech_y,A1
			BSR calculate
			MOVE.W    D7,orbite4        ; orbite4 = calcul(cx+2ex,cy-ey)
aop4 :      MOVE.W    curr_x,A5
			ADDQ.W    #2,A5
			MOVE.W    curr_y,A6
			ADDQ.W    #1,A6
			BSR       stocke_orbite

			MOVE.W    orbite4,D7        ; Si on le d‚duit
			MOVE.W    orbite4,A5
			CMPA.W    orbite3,A5
			BEQ       aop5              ; on le d‚duit
			MOVE.L    cx,A0             ; on est oblig‚ de le calculer
			ADD.L     ech_x,A0
			MOVE.L    cy,A1
			SUB.L     ech_y,A1
			BSR calculate
aop5 :      MOVE.W    curr_x,A5
			ADDQ.W    #1,A5
			MOVE.W    curr_y,A6
			ADDQ.W    #1,A6
			BSR       stocke_orbite

			MOVE.W    orbite01,orbite00
			MOVE.W    orbite4,orbite3
			MOVE.W    orbite11,orbite10

* R‚cupŠre ‚ventuellement le calcul du DSP
			JSR       receiver

			ADDQ.W    #2,curr_x
			MOVE.W    curr_x,A5
			LEA.L     preabscpu,A6
			MOVE.L    (A6,A5.W*4),A6
			MOVE.L    A6,cx
			MOVE.W    curr_x,A5         ; Le dernier point calcul‚ … partir de
			ADDQ.W    #2,A5             ; curr_x sera curr_x+2
			CMPA.W    nbpt_x,A5
			BMI       xloop             ; Fin de la boucle sur les abscisses
			MOVE.W    curr_x,A5         ; Il reste encore 1 colonne de 3
			ADDQ.W    #1,A5             ; Points … ‚valuer. Pour simplifier,
			MOVE.W    curr_y,A6         ; On r‚pŠte la derniŠre colonne
			MOVE.W    orbite01,D7
			BSR       stocke_orbite
			ADD.W     #1,A6
			MOVE.W    orbite4,D7
			BSR       stocke_orbite
			ADD.W     #1,A6
			MOVE.W    orbite11,D7
			BSR       stocke_orbite

			RTS



***********************
* Variables utilis‚es *
***********************
			.EVEN
init_x:	    .DS.L      1    ; Partie r‚elle de l'initialisateur
init_y:	    .DS.L      1    ; Partie imaginaire de l'initialisateur
xmin:       .DS.L      1    ; Minimum r‚el sur (Ox)
ymax:       .DS.L      1    ; Maximum r‚el sur (Oy)
ech_x:      .DS.L      1    ; R‚el suivant sur (Ox)
ech_y:      .DS.L      1    ; R‚el suivant sur (Oy)
ech2_x:     .DS.L      1    ; ech2_x = 2 * ech_x
ech2_y:     .DS.L      1    ; ech2_y = 2 * ech_y
orbite00:   .DS.W      1    ;  00                          01
orbite01:   .DS.W      1    ; *             *             *
orbite10:   .DS.W      1
orbite11:   .DS.W      1    ;  orbite3                     orbite4
orbite3:    .DS.W      1    ; *             *             *
orbite4:    .DS.W      1
                            ;  10                          11
                            ; *             *             *
cx:         .DS.L      1    ; Variable temporaire
cy:         .DS.L      1    ; Variable temporaire
ccy:        .DS.L      1    ; Variable temporaire commune
t:          .DS.L      1    ; Pour Barnsley
save_ccy:   .DS.L      1
save_currl: .DS.W      1
spec_calc:  .DS.L      1    ; Adresse de la routine de calcul sp‚cifique
adr_calc:
            .DC.L      mandelbrot_calc
            .DC.L      julia_calc
            .DC.L      manowarm_calc
            .DC.L      manowarj_calc
            .DC.L      unity_calc
            .DC.L      barnsleym_calc
            .DC.L      barnsleyj_calc
            .DC.L      hyperbasin_calc
            .DC.L      spider_calc
            .DC.L      sierpinski_calc
