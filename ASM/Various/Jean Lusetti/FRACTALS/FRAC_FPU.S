************************************
* Routine de calcul des ensembles  *
* Fractals de Mandelbrot et Julia  *
* En nombres flottants FPU 68881/2 *
************************************
CTRL_C      EQU       $002E0003

         .IMPORT   Multitos, udt_scr
         .IMPORT   adr_data, pre_ligne, xyorbit
         .IMPORT   affiche_progression_calcul, tst_kbd, stocke_orbite

         .IMPORT   nbl_cpu, nbl_fpu, nbl_dsp
         .IMPORT   stat_calc, max_iter, type, algo
         .IMPORT   nbpt_x, nbpt_y, curr_ligne, curr_x, curr_y
         .IMPORT   angle

         .EXPORT   finit_x, finit_y
         .EXPORT   fxmin, fymax, fech_x, fech_y, fech2_x, fech2_y
         .EXPORT   delta, big, over
         .EXPORT   fxc, fyc, fcos_a, fsin_a
         .EXPORT   fasm_fractal


fasm_fractal:
         MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte
         CLR.W     nbl_cpu
         CLR.W     nbl_fpu
         CLR.W     nbl_dsp
         CLR.W     stat_calc
         MOVE.W    type,D0
         LEA.L     adr_calc,A3
         MOVE.L    (A3,D0.W*4),A3
         BSR       fcompute_set
fretour: MOVEM.L   (SP)+,D0-D7/A0-A6 ; Restauration du contexte
         RTS                         ; Retour au programme C



********************************************************************************************
* Rotation de centre (xc,yc) du point (FP4,FP5) d'angle angle (d‚fini par fcos_a et fsin_a)
* R‚sultat dans (FP4,FP5)
* Registres modifi‚s : FP0-FP7
********************************************************************************************
frotate:
            FMOVE.X   FP4,FP6
            FMOVE.X   fxc,FP0
            FSUB.X    FP0,FP6           ; FP6 = x-xc
            FMOVE.X   FP5,FP7
            FMOVE.X   fyc,FP0
            FSUB.X    FP0,FP7           ; FP7 = y-yc
            FMOVE.X   fcos_a,FP0        ; FP0 = cos_a
            FMOVE.X   fsin_a,FP1        ; FP1 = sin_a

            FMOVE.X   FP6,FP4
            FMUL.X    FP0,FP4           ; FP4 = (x-xc)*cos_a
            FMOVE.X   FP7,FP2
            FMUL.X    FP1,FP2           ; FP2 = (y-yc)*sin_a
            FADD.X    FP2,FP4           ; FP4 = (x-xc)*cos_a+(y-yc)*sin_a
         
            FMOVE.X   FP7,FP5
            FMUL.X    FP0,FP5           ; FP5 = (y-yc)*cos_a
            FMOVE.X   FP6,FP2
            FMUL.X    FP1,FP2           ; FP2 = (x-xc)*sin_a
            FSUB.X    FP2,FP5           ; FP5 = -(x-xc)*sin_a+(y-yc)*cos_a

            FMOVE.X   fxc,FP0
            FADD.X    FP0,FP4           ; FP4 = xc + (x-xc)*cos_a + (y-yc)*sin_a

            FMOVE.X   fyc,FP0
            FADD.X    FP0,FP5           ; FP5 = yc - (x-xc)*sin_a + (y-yc)*cos_a

            RTS


***************************************************************************************
* Routine de calcul g‚n‚rale
* (FP4,FP5) est le point courant du plan complexe (fourni par l'algorithme des 3 lignes)
* A2 pointe sur la routine sp‚cifique de calcul
* Au cours de cette routine, tous les registres peuvent ˆtre modifi‚s
* … l'exception de A3 (routine sp‚cifique de calcul) et A4 (pr‚calcul de ligne)
* Une ‚ventuelle rotation est prise en compte
***************************************************************************************
fcalculate:
            TST.W     angle
            BEQ       after_rotation
            BSR       frotate

after_rotation:
            JMP       (A3)              ; Appel du calcul sp‚cifique

fin_set:    MOVEQ     #$01,D7           ; 1 signifie que le critŠre de
                                        ; Divergence n'a pas ‚t‚ confirm‚
			RTS                         ; D7 contient l'orbite du point
fout_calculate:
            NEG.W     D7
			ADD.W     max_iter,D7
            ADDQ.W    #$01,D7           ; Sinon on renvoit 1+iter

			RTS                         ; D7 contient l'orbite du point

*******************************************
* Retours pour les estimations de distance
*******************************************
out_fmed:
         FADD.X    FP2,FP3
         FMOVE.X   FP3,last_mod
         FMOVE.X   #0.0,FP0          ; FP0 = xder = 0 si Mandelbrot
         FMOVE.X   #0.0,FP1          ; FP1 = yder = 0
         FMOVE.X   #1.0,FP7          ; z(k+1) = z(k)*z'(k)+1 si Mandelbrot
         MOVE.W    type,D0
         BTST      #0,D0
         BEQ       not_julia
         FMOVE.X   #1.0,FP0          ; FP0 = xder = 1.0 si Julia
         FMOVE.X   #0.0,FP7          ; z(k+1) = z(k)*z'(k) si Julia
not_julia:
         FMOVE.X   over,FP6          ; FP6 = over
         MOVEQ.L   #0,D6             ; D6 = i = 0
         MOVE.L    xyorbit,A0
est_dist:
         FMOVE.X   (A0)+,FP2         ; FP2 = xorbit[i]
         FMOVE.X   (A0)+,FP3         ; FP3 = yorbit[i]
         FMOVE.X   FP2,FP4
         FMUL.X    FP0,FP4           ; FP4 = xorbit[i]*xder
         FMOVE.X   FP3,FP5
         FMUL.X    FP1,FP5           ; FP5 = yorbit[i]*yder
         FSUB.X    FP5,FP4
         FMUL.X    #2.0,FP4
         FADD.X    FP7,FP4           ; FP4 = dj+2*(xorbit[i]*xder-yorbit[i]*yder)

         FMUL.X    FP2,FP1           ; FP1 = xorbit[i]*yder
         FMOVE.X   FP0,FP5
         FMUL.X    FP3,FP5           ; FP5 = xder*yorbit[i]
         FADD.X    FP5,FP1
         FMUL.X    #2.0,FP1          ; yder = 2*(yorbit[i]*xder+xorbit[i]*yder)
         FMOVE.X   FP4,FP0           ; xder = 1+2*(xorbit[i]*xder-yorbit[i]*yder)

         FMOVE.X   FP0,FP4
         FADD.X    FP1,FP4
         FCMP.X    FP6,FP4
         FBGT      fin_set

         ADDQ.W    #1,D6
         CMP.W     D7,D6
         BMI       est_dist

         FMOVE.X   last_mod,FP2
         FMOVE.X   FP2,FP3
         FLOGN.X   FP2               ; FP2 = ln(last_mod)
         FSQRT.X   FP3               ; FP3 = sqrt(last_mod)
         FMUL.X    FP3,FP2           ; FP2 = ln(last_mod)*sqrt(last_mod)
         FMUL.X    FP0,FP0
         FMUL.X    FP1,FP1
         FADD.X    FP1,FP0
         FSQRT.X   FP0               ; FP0 = sqrt(xder*xder+yder*yder)
         FDIV.X    FP0,FP2           ; FP2 = dist

         FMOVE.X   delta,FP0
         FCMP.X    FP0,FP2
         FBLT      fin_set
         CMP.W     #1,D7
         BNE       no_ch
         ADDQ.W    #1,D7
no_ch:   RTS



**********************************************
* Calcul de l'orbite d'un point.             *
* Ensembles de Mandelbrot                    *
* c = FP4+FP5*i varie dans le plan complexe. *
* fix+fiy*i sert d'initialisateur.           *
* Registres modifi‚s :  FP0...FP7            *
**********************************************
fmandelbrot_calc:
         TST.W     algo               ; Estimation de distance ?
         BNE       mandelbrot_med
         MOVEQ     #0,D7
         MOVE.W    max_iter,D7
         FMOVE.X   #4.0,FP7           ; FP7 = 4.0
         FMOVE.X   fix,FP0            ; x = FP0 = fix
         FMOVE.X   fiy,FP1            ; y = FP1 = fiy
mandelbrot_loop:
         SUBQ.W    #1,D7
         BEQ       fin_set

         FMOVE.X   FP0,FP2
         FMUL.X    FP0,FP2           ; x1 = FP2 = x*x
         FMOVE.X   FP1,FP3
         FMUL.X    FP1,FP3           ; y1 = FP3 = y*y
         FMOVE.X   FP3,FP6
         FADD.X    FP2,FP6           ; FP6 = x*x+y*y
         FCMP.X    FP7,FP6           ; x*x + y*y > 4 ?
         FBGT      fout_calculate

         FMUL.X    FP0,FP1           ; y = x*y
         FMUL.X    #2.0,FP1          ; y = 2*x*y
         FADD.X    FP5,FP1           ; y = 2*x*y+fcy

         FMOVE.X   FP2,FP0           ; x = x1
         FSUB.X    FP3,FP0           ; x = x1-y1
         FADD.X    FP4,FP0           ; x = x1-y1+fcx
         BRA       mandelbrot_loop


**********************************************
*------- Estimation de la distance ----------*
* Ensembles de Mandelbrot :                  *
* c = FP4+FP5*i varie dans le plan complexe. *
* fix+fiy*i sert d'initialisateur.           *
* Registres modifi‚s :  FP0...FP7            *
**********************************************
mandelbrot_med:
         MOVEQ     #0,D7
         MOVE.W    max_iter,D6
         FMOVE.X   big,FP7            ; FP7 = big
         FMOVE.X   fix,FP0            ; x = FP0 = fix
         FMOVE.X   fiy,FP1            ; y = FP1 = fiy
         MOVE.L    xyorbit,A0
mandelbrot_medloop:
         FMOVE.X   FP0,(A0)+
         FMOVE.X   FP1,(A0)+
         FMOVE.X   FP0,FP2
         FMUL.X    FP0,FP2           ; x1 = FP2 = x*x
         FMOVE.X   FP1,FP3
         FMUL.X    FP1,FP3           ; y1 = FP3 = y*y
         FMOVE.X   FP3,FP6
         FADD.X    FP2,FP6           ; FP6 = x*x+y*y
         FCMP.X    FP7,FP6           ; x*x + y*y > big ?
         FBGT      out_fmed

         FMUL.X    FP0,FP1           ; y = x*y
         FMUL.X    #2.0,FP1          ; y = 2*x*y
         FADD.X    FP5,FP1           ; y = 2*x*y+fcy

         FMOVE.X   FP2,FP0           ; x = x1
         FSUB.X    FP3,FP0           ; x = x1-y1
         FADD.X    FP4,FP0           ; x = x1-y1+fcx

         ADDQ.W    #1,D7
         CMP.W     D6,D7
         BMI       mandelbrot_medloop
         BRA       fin_set


**********************************************
* Calcul de l'orbite d'un point.             *
* Ensembles de Julia                         *
* c = FP4+FP5*i varie dans le plan complexe. *
* fix+fiy*i sert d'initialisateur.           *
* Registres modifi‚s :  FP0...FP7            *
**********************************************
fjulia_calc:
         TST.W     algo               ; Estimation de distance ?
         BNE       julia_med
         MOVEQ     #0,D7
         MOVE.W    max_iter,D7
         FMOVE.X   #4.0,FP7           ; FP7 = 4.0
         FMOVE.X   FP4,FP0            ; x = FP0 = fix
         FMOVE.X   FP5,FP1            ; y = FP1 = fiy
         FMOVE.X   fix,FP4
         FMOVE.X   fiy,FP5
julia_loop:
         SUBQ.W    #1,D7
         BEQ       fin_set

         FMOVE.X   FP0,FP2
         FMUL.X    FP0,FP2           ; x1 = FP2 = x*x
         FMOVE.X   FP1,FP3
         FMUL.X    FP1,FP3           ; y1 = FP3 = y*y
         FMOVE.X   FP3,FP6
         FADD.X    FP2,FP6           ; FP6 = x*x+y*y
         FCMP.X    FP7,FP6           ; x*x + y*y > 4 ?
         FBGT      fout_calculate

         FMUL.X    FP0,FP1           ; y = x*y
         FMUL.X    #2.0,FP1          ; y = 2*x*y
         FADD.X    FP5,FP1           ; y = 2*x*y+fcy

         FMOVE.X   FP2,FP0           ; x = x1
         FSUB.X    FP3,FP0           ; x = x1-y1
         FADD.X    FP4,FP0           ; x = x1-y1+fcx
         BRA       julia_loop


**********************************************
*------- Estimation de la distance ----------*
* Ensembles de Julia      :                  *
* c = FP4+FP5*i varie dans le plan complexe. *
* Registres modifi‚s :  FP0...FP7            *
**********************************************
julia_med:
         MOVEQ     #0,D7
         MOVE.W    max_iter,D6
         FMOVE.X   big,FP7            ; FP7 = big
         FMOVE.X   FP4,FP0            ; x = FP0 = fix
         FMOVE.X   FP5,FP1            ; y = FP1 = fiy
         FMOVE.X   fix,FP4
         FMOVE.X   fiy,FP5
         MOVE.L    xyorbit,A0
julia_medloop:
         FMOVE.X   FP0,(A0)+
         FMOVE.X   FP1,(A0)+
         FMOVE.X   FP0,FP2
         FMUL.X    FP0,FP2           ; x1 = FP2 = x*x
         FMOVE.X   FP1,FP3
         FMUL.X    FP1,FP3           ; y1 = FP3 = y*y
         FMOVE.X   FP3,FP6
         FADD.X    FP2,FP6           ; FP6 = x*x+y*y
         FCMP.X    FP7,FP6           ; x*x + y*y > big ?
         FBGT      out_fmed

         FMUL.X    FP0,FP1           ; y = x*y
         FMUL.X    #2.0,FP1          ; y = 2*x*y
         FADD.X    FP5,FP1           ; y = 2*x*y+fcy

         FMOVE.X   FP2,FP0           ; x = x1
         FSUB.X    FP3,FP0           ; x = x1-y1
         FADD.X    FP4,FP0           ; x = x1-y1+fcx

         ADDQ.W    #1,D7
         CMP.W     D6,D7
         BMI       julia_medloop
         BRA       fin_set


**********************************************
* Calcul de l'orbite d'un point              *
* Ensembles ManowarM:                        *
* c = FP4+FP5*i varie dans le plan complexe. *
* fix+fiy*i sert d'initialisateur.           *
* Registres modifi‚s :  FP0...FP7            *
**********************************************
fmanowarm_calc :
         MOVEQ     #0,D7
         MOVE.W    max_iter,D7
         FMOVE.X   #4.0,FP7           ; FP7 = 4.0
         FMOVE.X   fix,FP0            ; x = FP0 = fix
         FMOVE.X   fiy,FP1            ; y = FP1 = fiy
         FMOVE.X   FP0,xp
         FMOVE.X   FP1,yp
manowarm_loop:
         SUBQ.W    #1,D7
         BEQ       fin_set

         FMOVE.X   FP0,FP2
         FMUL.X    FP0,FP2           ; x1 = FP2 = x*x
         FMOVE.X   FP1,FP3
         FMUL.X    FP1,FP3           ; y1 = FP3 = y*y
         FMOVE.X   FP3,FP6
         FADD.X    FP2,FP6           ; FP6 = x*x+y*y
         FCMP.X    FP7,FP6           ; x*x + y*y > 4 ?
         FBGT      fout_calculate

         FMOVE.X   FP0,-(SP)
         FMOVE.X   FP1,-(SP)         ; sauve x et y
         FMUL.X    FP0,FP1           ; y = x*y
         FMUL.X    #2.0,FP1          ; y = 2*x*y
         FADD.X    FP5,FP1           ; y = 2*x*y+fcy
         FMOVE.X   yp,FP6
         FADD.X    FP6,FP1           ; y = 2*x*y+fcy+yp

         FMOVE.X   FP2,FP0           ; x = x1
         FSUB.X    FP3,FP0           ; x = x1-y1
         FADD.X    FP4,FP0           ; x = x1-y1+fcx
         FMOVE.X   xp,FP6
         FADD.X    FP6,FP0           ; x = x1-y1+fcx+xp

         FMOVE.X   (SP)+,FP6
         FMOVE.X   FP6,yp
         FMOVE.X   (SP)+,FP6
         FMOVE.X   FP6,xp
         BRA       manowarm_loop


**********************************************
* Calcul de l'orbite d'un point              *
* Ensembles ManowarJ:                        *
* Registres modifi‚s :  FP0...FP7            *
**********************************************
fmanowarj_calc :
         MOVEQ     #0,D7
         MOVE.W    max_iter,D7
         FMOVE.X   #4.0,FP7           ; FP7 = 4.0
         FMOVE.X   FP4,FP0            ; x = FP0 = fix
         FMOVE.X   FP5,FP1            ; y = FP1 = fiy
         FMOVE.X   FP0,xp
         FMOVE.X   FP1,yp
         FMOVE.X   fix,FP4
         FMOVE.X   fiy,FP5
manowarj_loop:
         SUBQ.W    #1,D7
         BEQ       fin_set

         FMOVE.X   FP0,FP2
         FMUL.X    FP0,FP2           ; x1 = FP2 = x*x
         FMOVE.X   FP1,FP3
         FMUL.X    FP1,FP3           ; y1 = FP3 = y*y
         FMOVE.X   FP3,FP6
         FADD.X    FP2,FP6           ; FP6 = x*x+y*y
         FCMP.X    FP7,FP6           ; x*x + y*y > 4 ?
         FBGT      fout_calculate

         FMOVE.X   FP0,-(SP)
         FMOVE.X   FP1,-(SP)         ; sauve x et y
         FMUL.X    FP0,FP1           ; y = x*y
         FMUL.X    #2.0,FP1          ; y = 2*x*y
         FADD.X    FP5,FP1           ; y = 2*x*y+fcy
         FMOVE.X   yp,FP6
         FADD.X    FP6,FP1           ; y = 2*x*y+fcy+yp

         FMOVE.X   FP2,FP0           ; x = x1
         FSUB.X    FP3,FP0           ; x = x1-y1
         FADD.X    FP4,FP0           ; x = x1-y1+fcx
         FMOVE.X   xp,FP6
         FADD.X    FP6,FP0           ; x = x1-y1+fcx+xp

         FMOVE.X   (SP)+,FP6
         FMOVE.X   FP6,yp
         FMOVE.X   (SP)+,FP6
         FMOVE.X   FP6,xp
         BRA       manowarj_loop




************************************
* Calcul de l'orbite d'un point    *
* Ensembles Unity                  *
* (FP0,FP1) = (cx, cy)             *
* (FP4,FP5) = (ix, iy) (fix‚)      *
* Registres modifi‚s :  FP0...FP7  *
************************************
funity_calc:
         MOVEQ     #0,D7
         MOVE.W    max_iter,D7
         FMOVE.X   #4.0,FP7           ; FP7 = 4.0
         FMOVE.X   FP4,FP0
         FMOVE.X   FP5,FP1
         FMOVE.X   fix,FP4
         FMOVE.X   fiy,FP5
unity_loop:
         SUBQ.W    #1,D7
         BEQ       fin_set

         FMOVE.X   FP0,FP2
         FMUL.X    FP0,FP2           ; x1 = FP2 = x*x
         FMOVE.X   FP1,FP3
         FMUL.X    FP1,FP3           ; y1 = FP3 = y*y
         FMOVE.X   FP3,FP6
         FADD.X    FP2,FP6           ; FP6 = x*x+y*y
         FCMP.X    FP7,FP6           ; x*x + y*y > 4 ?
         FBGT      fout_calculate

         FNEG.X    FP6
         FMOVE.X   FP6,FP2           ; FP6 = FP2 = One

         FADD.X    FP5,FP2           ; FP2 = iy-One
         FMUL.X    FP2,FP0
         FMOVE.X   FP0,FP1           ; y = (ix-One)*x

         FADD.X    FP4,FP6
         FMOVE.X   FP1,FP0
         FMUL.X    FP6,FP0           ; x = (iy-One)*y

         BRA       unity_loop


**********************************************
* Calcul de l'orbite d'un point.             *
* Ensembles de BarnsleyM                     *
* c = FP4+FP5*i varie dans le plan complexe. *
* fix+fiy*i sert d'initialisateur.           *
* Registres modifi‚s :  FP0...FP7            *
**********************************************
fbarnsleym_calc:
         MOVEQ     #0,D7
         MOVE.W    max_iter,D7
         FMOVE.X   #4.0,FP7           ; FP7 = 4.0
         FMOVE.X   #1.0,FP6           ; FP6 = 1.0
         FMOVE.X   fix,FP0            ; x = FP0 = fix
         FMOVE.X   fiy,FP1            ; y = FP1 = fiy
barnsleym_loop:
         SUBQ.W    #1,D7
         BEQ       fin_set

         FMOVE.X   FP0,FP2
         FMUL.X    FP0,FP2           ; x1 = FP2 = x*x
         FMOVE.X   FP1,FP3
         FMUL.X    FP1,FP3           ; y1 = FP3 = y*y
         FADD.X    FP2,FP3           ; FP3 = x*x+y*y
         FCMP.X    FP7,FP3           ; x*x + y*y > 4 ?
         FBGT      fout_calculate

         FMOVE.X   FP0,FP2
         FMUL.X    FP5,FP2           ; FP2 = x*cy
         FMOVE.X   FP1,FP3
         FMUL.X    FP4,FP3           ; FP3 = y*cx
         FADD.X    FP3,FP2           ; FP2 = t = x*cy+y*cx

         FBGT      t_is_positifm
         FADD.X    FP6,FP0           ; x = x+1.0
         FMUL.X    FP4,FP0           ; x = (1+x)*cx
         FMUL.X    FP5,FP1           ; y = y*cy
         FSUB.X    FP1,FP0           ; x = (1+x)*cx-y*cy

         FMOVE.X   FP2,FP1           ; y = t
         FADD.X    FP5,FP1           ; y = t+cy
         BRA       barnsleym_loop
t_is_positifm:
         FSUB.X    FP6,FP0           ; x = x-1.0
         FMUL.X    FP4,FP0           ; x = (x-1)*cx
         FMUL.X    FP5,FP1           ; y = y*cy
         FSUB.X    FP1,FP0           ; x = (x-1)*cx-y*cy

         FMOVE.X   FP2,FP1           ; y = t
         FSUB.X    FP5,FP1           ; y = t-cy
         BRA       barnsleym_loop

**********************************************
* Calcul de l'orbite d'un point.             *
* Ensembles de BarnsleyJ                     *
* c = FP4+FP5*i varie dans le plan complexe. *
* fix+fiy*i sert d'initialisateur.           *
* Registres modifi‚s :  FP0...FP7            *
**********************************************
fbarnsleyj_calc:
         MOVEQ     #0,D7
         MOVE.W    max_iter,D7
         FMOVE.X   #4.0,FP7           ; FP7 = 4.0
         FMOVE.X   #1.0,FP6           ; FP6 = 1.0
         FMOVE.X   FP4,FP0            ; x = FP0 = fix
         FMOVE.X   FP5,FP1            ; y = FP1 = fiy
         FMOVE.X   fix,FP4
         FMOVE.X   fiy,FP5
barnsleyj_loop:
         SUBQ.W    #1,D7
         BEQ       fin_set

         FMOVE.X   FP0,FP2
         FMUL.X    FP0,FP2           ; x1 = FP2 = x*x
         FMOVE.X   FP1,FP3
         FMUL.X    FP1,FP3           ; y1 = FP3 = y*y
         FADD.X    FP2,FP3           ; FP3 = x*x+y*y
         FCMP.X    FP7,FP3           ; x*x + y*y > 4 ?
         FBGT      fout_calculate

         FMOVE.X   FP0,FP2
         FMUL.X    FP5,FP2           ; FP2 = x*cy
         FMOVE.X   FP1,FP3
         FMUL.X    FP4,FP3           ; FP3 = y*cx
         FADD.X    FP3,FP2           ; FP2 = t = x*cy+y*cx

         FBGT      t_is_positifj
         FADD.X    FP6,FP0           ; x = x+1.0
         FMUL.X    FP4,FP0           ; x = (1+x)*cx
         FMUL.X    FP5,FP1           ; y = y*cy
         FSUB.X    FP1,FP0           ; x = (1+x)*cx-y*cy

         FMOVE.X   FP2,FP1           ; y = t
         FADD.X    FP5,FP1           ; y = t+cy
         BRA       barnsleyj_loop
t_is_positifj:
         FSUB.X    FP6,FP0           ; x = x-1.0
         FMUL.X    FP4,FP0           ; x = (x-1)*cx
         FMUL.X    FP5,FP1           ; y = y*cy
         FSUB.X    FP1,FP0           ; x = (x-1)*cx-y*cy

         FMOVE.X   FP2,FP1           ; y = t
         FSUB.X    FP5,FP1           ; y = t-cy
         BRA       barnsleyj_loop


**********************************************
* Calcul de l'orbite d'un point.             *
* Ensembles de HyperBasin                    *
* c = FP4+FP5*i varie dans le plan complexe. *
* fix+fiy*i sert d'initialisateur.           *
* Registres modifi‚s :  FP0...FP7            *
**********************************************
fhyperbasin_calc:
         MOVEQ     #0,D7
         MOVE.W    max_iter,D7
         FMOVE.X   #4.0,FP7           ; FP7 = 4.0
         FMOVE.X   FP4,FP0            ; x = FP0 = fix
         FMOVE.X   FP5,FP1            ; y = FP1 = fiy
         FMOVE.X   fix,FP4
         FMOVE.X   fiy,FP5
hyperbasin_loop:
         SUBQ.W    #1,D7
         BEQ       fin_set

         FMOVE.X   FP0,FP2
         FMUL.X    FP0,FP2           ; x1 = FP2 = x*x
         FMOVE.X   FP1,FP3
         FMUL.X    FP1,FP3           ; y1 = FP3 = y*y
         FMOVE.X   FP3,FP6
         FADD.X    FP2,FP6           ; FP6 = x*x+y*y
         FCMP.X    FP7,FP6           ; x*x + y*y > 4 ?
         FBGT      fout_calculate

         FSUB.X    FP3,FP2           ; FP2 = x*x-y*y
         FMOVE.X   FP0,FP3
         FMUL.X    FP4,FP3
         FSUB.X    FP3,FP2           ; FP2 = x*x-y*y-x*ix
         FMOVE.X   FP1,FP3
         FMUL.X    FP5,FP3
         FSUB.X    FP3,FP2           ; FP2 = x*x-y*y-x*ix-y*iy

         FMOVE.X   FP0,FP3
         FMUL.X    #2.0,FP3
         FADD.X    FP4,FP3           ; FP3 = 2*x+ix
         FMUL.X    FP1,FP3           ; FP3 = (2*x+ix)*y
         FMUL.X    FP5,FP0           ; FP0 = x*iy
         FSUB.X    FP0,FP3           ; FP3 = (2*x+ix)*y-x*iy

         FMOVE.X   FP2,FP0
         FMOVE.X   FP3,FP1

         BRA       hyperbasin_loop


**********************************************
* Calcul de l'orbite d'un point              *
* Ensembles Spider                           *
* Registres modifi‚s :  FP0...FP7            *
**********************************************
fspider_calc :
         MOVEQ     #0,D7
         MOVE.W    max_iter,D7
         FMOVE.X   #4.0,FP7           ; FP7 = 4.0
         FMOVE.X   FP4,FP0            ; x = FP0 = fix
         FMOVE.X   FP5,FP1            ; y = FP1 = fiy
         FMOVE.X   FP0,xp
         FMOVE.X   FP1,yp
         FMOVE.X   fix,FP4
         FMOVE.X   fiy,FP5
spider_loop:
         SUBQ.W    #1,D7
         BEQ       fin_set

         FMOVE.X   FP0,FP2
         FMUL.X    FP0,FP2           ; x1 = FP2 = x*x
         FMOVE.X   FP1,FP3
         FMUL.X    FP1,FP3           ; y1 = FP3 = y*y
         FMOVE.X   FP3,FP6
         FADD.X    FP2,FP6           ; FP6 = x*x+y*y
         FCMP.X    FP7,FP6           ; x*x + y*y > 4 ?
         FBGT      fout_calculate

         FMUL.X    FP0,FP1           ; y = x*y
         FMUL.X    #2.0,FP1          ; y = 2*x*y
         FADD.X    FP5,FP1           ; y = 2*x*y+fcy
         FMOVE.X   yp,FP6
         FADD.X    FP6,FP1           ; y = 2*x*y+fcy+yp

         FMOVE.X   FP2,FP0           ; x = x1
         FSUB.X    FP3,FP0           ; x = x1-y1
         FADD.X    FP4,FP0           ; x = x1-y1+fcx
         FMOVE.X   xp,FP6
         FADD.X    FP6,FP0           ; x = x1-y1+fcx+xp

         FMUL.X    #0.5,FP6
         FADD.X    FP0,FP6
         FMOVE.X   FP6,xp
         FMOVE.X   yp,FP6
         FMUL.X    #0.5,FP6
         FADD.X    FP1,FP6
         FMOVE.X   FP6,yp
         BRA       spider_loop



***********************************************
* Routine de calcul de l'ensemble en totalit‚ *
***********************************************
fcompute_set:
         CLR.W     curr_y
         CLR.W     curr_ligne
         FMOVE.X   fymax,FP0
         FMOVE.X   FP0,fcy
         FMOVE.X   finit_x,FP0
         FMOVE.X   FP0,fix
         FMOVE.X   finit_y,FP0
         FMOVE.X   FP0,fiy
         LEA.L     pre_ligne,A4      ; Pr‚calcul pour stocke_orbite
yloop:
         BSR       fcompute_3lignes
         ADDQ.W    #3,nbl_fpu        ; 3 lignes viennent d'ˆtre calcul‚es
         BSR       tst_kbd
         CMPI.L    #CTRL_C,D0        ; CTRL-C ?
         BNE       next_calc         ; Non : le calcul se poursuit
         MOVE.W    #1,stat_calc      ; Oui : le calcul s'arrˆte
         BRA       fin
next_calc:
         FMOVE.X   fech_y,FP0
         FMUL.X    #3.0,FP0
         FMOVE.X   fcy,FP1
         FSUB.X    FP0,FP1
         FMOVE.X   FP1,fcy            ; fcy = fcy-3*ey
         ADDQ.W    #3,curr_ligne

         CMPI.W    #$1,Multitos
         BNE       no_Mint
* Si on est sous Multitos, effectue les ‚ventuels Redraws
         JSR       udt_scr
no_Mint:
         JSR       affiche_progression_calcul

         MOVE.W    curr_ligne, curr_y
         MOVE.W    curr_y,A5
         CMPA.W    nbpt_y,A5
         BMI       yloop             ; Fin de la boucle sur les ordonn‚es

         CLR.W     stat_calc         ; Le calcul n'a pas ‚t‚ interrompu
fin:     RTS




*********************************************
* Routine g‚n‚rale de calcul de 3 lignes
* D‚duction des points centraux si possible
*********************************************
fcompute_3lignes:
         FMOVE.X   fxmin,FP0
         FMOVE.X   FP0,fcx
         CLR.W     curr_x
         FMOVE.X   fcx,FP4
         FMOVE.X   fcy,FP5
         BSR fcalculate
         MOVE.W    D7,forbite00       ; orbite00 = calcul(ffcx,fcy)
         MOVE.W    curr_x,A5
         MOVE.W    curr_y,A6
         BSR       stocke_orbite
         FMOVE.X   fcx,FP4
         FMOVE.X   fcy,FP5
         FMOVE.X   fech_y,FP0
         FSUB.X    FP0,FP5
         BSR fcalculate
         MOVE.W    D7,forbite3        ; orbite3 = calcul(ffcx,fcy-ey)
         ADDQ.W    #1,A6
         BSR       stocke_orbite
         FMOVE.X   fcx,FP4
         FMOVE.X   fcy,FP5
         FMOVE.X   fech2_y,FP0
         FSUB.X    FP0,FP5
         BSR fcalculate
         MOVE.W    D7,forbite10       ; orbite10 = calcul(ffcx,fcy-2ey)
         ADDQ.W    #1,A6
         BSR       stocke_orbite

xloop:   FMOVE.X   fcx,FP4
         FMOVE.X   fech2_x,FP0
         FADD.X    FP0,FP4
         FMOVE.X   fcy,FP5
         BSR fcalculate
         MOVE.W    D7,forbite01       ; orbite01 = calcul(fcx+2*ex,fcy)
         MOVE.W    curr_x,A5
         ADDQ.W    #2,A5
         MOVE.W    curr_y,A6
         BSR       stocke_orbite
         FMOVE.X   fcx,FP4
         FMOVE.X   fech2_x,FP0
         FADD.X    FP0,FP4
         FMOVE.X   fcy,FP5
         FMOVE.X   fech2_y,FP0
         FSUB.X    FP0,FP5
         BSR fcalculate
         MOVE.W    D7,forbite11       ; orbite11 = calcul(fcx+2*ex,fcy-2*ey)
         ADD.W     #2,A6
         BSR       stocke_orbite

         MOVE.W    forbite01,D7       ; Si on le d‚duit
         MOVE.W    forbite01,A5
         CMPA.W    forbite00,A5
         BEQ       faop1              ; on le d‚duit
         FMOVE.X   fcx,FP4            ; on est oblig‚ de le calculer
         FMOVE.X   fech_x,FP0
         FADD.X    FP0,FP4
         FMOVE.X   fcy,FP5
         BSR fcalculate
faop1 :  MOVE.W    curr_x,A5          ; on le recopie
         ADDQ.W    #1,A5
         MOVE.W    curr_y,A6
         BSR       stocke_orbite

         MOVE.W    forbite11,D7       ; Si on le d‚duit
         MOVE.W    forbite11,A5
         CMPA.W    forbite10,A5
         BEQ       faop2              ; on le d‚duit
         FMOVE.X   fcx,FP4            ; on est oblig‚ de le calculer
         FMOVE.X   fech_x,FP0
         FADD.X    FP0,FP4
         FMOVE.X   fcy,FP5
         FMOVE.X   fech2_y,FP0
         FSUB.X    FP0,FP5
         BSR fcalculate
faop2:   MOVE.W    curr_x,A5
         ADDQ.W    #1,A5
         MOVE.W    curr_y,A6
         ADDQ.W    #2,A6
         BSR       stocke_orbite

         MOVE.W    forbite11,forbite4  ; Si on le d‚duit
         MOVE.W    forbite11,D7
         MOVE.W    forbite11,A5
         CMPA.W    forbite01,A5
         BEQ       faop4               ; on le d‚duit
         FMOVE.X   fcx,FP4             ; on est oblig‚ de le calculer
         FMOVE.X   fech2_x,FP0
         FADD.X    FP0,FP4
         FMOVE.X   fcy,FP5
         FMOVE.X   fech_y,FP0
         FSUB.X    FP0,FP5
         BSR fcalculate
         MOVE.W    D7,forbite4        ; orbite4 = calcul(fcx+2ex,fcy-ey)
faop4:   MOVE.W    curr_x,A5
         ADDQ.W    #2,A5
         MOVE.W    curr_y,A6
         ADDQ.W    #1,A6
         BSR       stocke_orbite

         MOVE.W    forbite4,D7        ; Si on le d‚duit
         MOVE.W    forbite4,A5
         CMPA.W    forbite3,A5
         BEQ       faop5              ; on le d‚duit
         FMOVE.X   fcx,FP4            ; on est oblig‚ de le calculer
         FMOVE.X   fech_x,FP0
         FADD.X    FP0,FP4
         FMOVE.X   fcy,FP5
         FMOVE.X   fech_y,FP0
         FSUB.X    FP0,FP5
         BSR fcalculate
faop5 :  MOVE.W    curr_x,A5
         ADDQ.W    #1,A5
         MOVE.W    curr_y,A6
         ADDQ.W    #1,A6
         BSR       stocke_orbite

         MOVE.W    forbite01,forbite00
         MOVE.W    forbite4,forbite3
         MOVE.W    forbite11,forbite10
         ADDQ.W    #2,curr_x
         FMOVE.X   fech2_x,FP0
         FMOVE.X   fcx,FP1
         FADD.X    FP0,FP1
         FMOVE.X   FP1,fcx
         MOVE.W    curr_x,A5         ; Le dernier point calcul‚ … partir de
         ADDQ.W    #2,A5             ; curr_x sera curr_x+2
         CMPA.W    nbpt_x,A5
         BMI       xloop             ; Fin de la boucle sur les abscisses
         MOVE.W    curr_x,A5         ; Il reste encore 1 colonne de 3
         ADDQ.W    #1,A5             ; Lignes … ‚valuer. Pour simplifier,
         MOVE.W    curr_y,A6         ; On r‚pŠte la derniŠre colonne
         MOVE.W    forbite01,D7
         BSR       stocke_orbite
         ADD.W     #1,A6
         MOVE.W    forbite4,D7
         BSR       stocke_orbite
         ADD.W     #1,A6
         MOVE.W    forbite11,D7
         BSR       stocke_orbite
         RTS




***********************
* Variables utilis‚es *
***********************
            .EVEN
finit_x:    .DS.L      3    ; Partie r‚elle de l'initialisateur
finit_y:    .DS.L      3    ; Partie imaginaire de l'initialisateur
fxmin:      .DS.L      3    ; Minimum r‚el sur (Ox)
fymax:      .DS.L      3    ; Maximum r‚el sur (Oy)
fech_x:     .DS.L      3    ; R‚el suivant sur (Ox)
fech_y:     .DS.L      3    ; R‚el suivant sur (Oy)
fech2_x:    .DS.L      3    ; ech2_x = 2 * ech_x
fech2_y:    .DS.L      3    ; ech2_y = 2 * ech_y
forbite00:  .DS.W      1    ;  00                          01
forbite01:  .DS.W      1    ; *             *             *
forbite10:  .DS.W      1
forbite11:  .DS.W      1    ;  forbite3                     forbite4
forbite3:   .DS.W      1    ; *             *             *
forbite4:   .DS.W      1
                            ;  10                          11
                            ; *             *             *
fcx:        .DS.L      3    ; Variable temporaire
fcy:        .DS.L      3    ; Variable temporaire
fix:        .DS.L      3    ; Variable temporaire
fiy:        .DS.L      3    ; Variable temporaire
big:        .DS.L      3    ; CritŠre de divergence pour MED
delta:      .DS.L      3    ; Distance limite pour appartenance
over:       .DS.L      3    ; Maximum pour les d‚riv‚es
last_mod:   .DS.L      3    ; Module du dernier ‚l‚ment avant sortie
xp:         .DS.L      3    ; x' pour ManoWar
yp:         .DS.L      3    ; y' pour ManoWar
fxc:        .DS.L      3    ; Abscisse du centre de la rotation
fyc:        .DS.L      3    ; Ordonn‚e du centre de la rotation
fcos_a:     .DS.L      3    ; Cosinus angle de rotation
fsin_a:     .DS.L      3    ; Sinus angle de rotation
adr_calc:
            .DC.L      fmandelbrot_calc
            .DC.L      fjulia_calc
            .DC.L      fmanowarm_calc
            .DC.L      fmanowarj_calc
            .DC.L      funity_calc
            .DC.L      fbarnsleym_calc
            .DC.L      fbarnsleyj_calc
            .DC.L      fhyperbasin_calc
            .DC.L      fspider_calc
