;
;
;
;	"Tattlets"
;
;	An object-style system for demo effects
;	Uses linked lists for easy object insertion/removal
;
;
;
;
;

;--------------------------------------------------------------------

max_objects		equ	100
max_object_size		equ	128

;--------------------------------------------------------------------
			rsreset
object_next		rs.l	1		;addr of next object
						;<=0  ==  empty
object_last		rs.l	1		;addr of last object
object_routine		rs.l	1		;addr of obj routine
object_data_base	rs.b	1		;start of obj data


;--------------------------------------------------------------------
define_object		macro
			rsset	object_data_base
			endm


;--------------------------------------------------------------------
			define_object bubble
bubble_x		rs.l	1
bubble_y		rs.l	1
bubble_z		rs.l	1


;--------------------------------------------------------------------
			section	data
;--------------------------------------------------------------------
object_last		dc.l	0
			dc.l	0
			dc.l	object_end


;--------------------------------------------------------------------
			section bss
;--------------------------------------------------------------------

object_first		dc.l	object_last

object_list		equ	max_objects*max_object_size

