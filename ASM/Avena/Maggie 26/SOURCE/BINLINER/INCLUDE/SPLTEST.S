; SPLTEST.S
; little test code for doc on splines 
; assemble and run under MonST and check the 2 values
; stored in my_test_value
; it should give the values of 50 and 100
; (or just less than this)


; -----------------------------------------------------------------
value_of_t		equ	$7fff		; t = "1"


my_test_code:
                        lea my_test_matrix(pc),a0   ;input
                        lea my_basis_matrix(pc),a1  ;output
                        move.w #2,d0                ;matrix has 2
                                                    ;columns
                        bsr spl_init_matrix_hermite ;go!

calc_my_test_point:
                        lea my_basis_matrix(pc),a0  ;input
                        lea my_test_value(pc),a1    ;
                        move.w #2,d1                ;matrix has 2
                                                    ;columns
                        move.w #value_of_t,d0       ;t = ?
                        bsr spl_calc_spline_value   ;go!

			illegal

; -----------------------------------------------------------------
my_test_matrix:         dc.w 0,50,10,25
                        dc.w 0,100,20,15

my_basis_matrix:
                        ds.w 4*2

my_test_value:          ds.w    2                   ; has 2 dimensions

			include	splines.s

