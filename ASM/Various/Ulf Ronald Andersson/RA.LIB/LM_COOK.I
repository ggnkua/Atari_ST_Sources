;----------------------------------------------------------------------------
;File name:	LM_COOK.I			Revision date:	1998.08.14
;Created by:	Ulf Ronald Andersson		Creation date:	1994.08.19
;----------------------------------------------------------------------------
;       DevPac source for the 'LMus' cookie structure
;       defined by the mouse accelerator Lace_Mus.Prg
;----------------------------------------------------------------------------
		rsreset
;
;symbol name    data size   Purpose                           Example
;-----------    ---------   -------                           -------
LM_version:     rs.w    1   ;current version		       $0302
LM_interface:   rs.w    1   ;version that defined structure    $0104
LM_block_f:     rs.b    1   ;blocks acceleration when nonzero      0
LM_future_1:    rs.b    1   ;reserved for the future               0
LM_ref_X:       rs.w    1   ;unaccelerated reference width       320
LM_ref_Y:       rs.w    1   ;unaccelerated reference height      200
LM_max_X:       rs.w    1   ;maximum acceleration width          960
LM_max_Y:       rs.w    1   ;maximum acceleration height         720
;
; The reference values are used to adjust acceleration such that a given
; mouse movement always moves the pointer by a specific percentage of the
; virtual resolution.
;
; The result:   A small mouse pad will serve every resolution.
;
; The maximum values exist to limit this effect, to avoid problems with
; precision mouseclicks in the huge virtual resolutions of Lace_Emu.
; (To suppress acceleration completely [momentarily] press left shift)
;
;
; Rough acceleration formulas:
;
; out_step_X = (in_step_X * min(rez_X,LM_max_X)) / LM_ref_X
; out_step_Y = (in_step_Y * min(rez_Y,LM_max_Y)) / LM_ref_Y
;
; where:  rez_X,rez_Y            = current virtual resolution
;         in_step_X,in_step_Y    = unaccelerated mouse movement
;         out_step_X,out_step_Y  = accelerated mouse movement
;
; The formulas above are simplified of course, since the real ones also
; preserve the values rounded off to produce integral steps.
; This means that roundoff errors do not accumulate.
;----------------------------------------------------------------------------
;End of file:	LM_COOK.I
;----------------------------------------------------------------------------
