; Modded Example from Evl - Play multisong SNDH with embedded TPN
;
; Builds with Devpac 3 and probably vasm.
;


tpn_init_idx equ  0  ; Init with subsong # in d0
tpn_init_ptrs    equ  4  ; Init with TPIS in a0, TPSN in a1
tpn_exit         equ  8  ; Exit
tpn_play         equ 12  ; Play on timer


        section	text
_start:
        pea     instructions_text
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp

        pea	main
        move.w	#$26,-(sp)
        trap	#14
        addq.l	#6,sp

        clr.w	-(sp)
        trap	#1

main:
        moveq.l #0,d0           ; First subsong
        bsr     get_pointers
        bne.s   .subsong_failed
        bsr     tpn_replay_bin+tpn_init_ptrs

        move.l	$114.w,savetc
        move.l	#tc,$114.w

.main_loop:
        moveq.l #0,d0
        move.b  $fffffc02.w,d0
        ; Check keys and change songs here
        cmp.b   #$2,d0      ; 1-key scan code
        blt.s   .no_change
        cmp.s   #$3,d0      ; 9-key scan code
        bgt.s   .no_change
        subq.l  #2,d0       ; Make d0 subsong index
        ; Pause timers and request new subsong
        move.w  sr,d7
        move.w  #$2700,sr
        bsr     get_pointers
        bne.s   .subsong_failed
        bsr     tpn_replay_bin+tpn_init_ptrs
        move.w  d7,sr
        tst.w   d0
        bne.s   .subsong_failed
.no_change:
        cmp.b	#$39,d0
        bne.s	.main_loop

.subsong_failed:
        move.l	savetc,$114.w
        bsr		tpn_replay_bin+tpn_exit

        rts

tc:     move.w  $ffff8240.w,-(sp)
        move.w  #$700,$ffff8240.w
        bsr	tpn_replay_bin+tpn_play
        move.w  (sp)+,$ffff8240.w
        
        move.l	savetc,-(sp)
        rts

;-----------------------------
; Get pointers to instrument and song data
; Input:
;   d0 = song index (0-based)
; Output:
;   d0.l = 0 on success, -1 on failure
;   a0 = Instrument data
;   a1 = Song data
; Preserves: d1-d7/a0-a6
;-----------------------------
get_pointers:
        movem.l d1-d7/a2-a6,-(sp)
        move.l  d0,d7

        ; Validate FORM chunk at start of embedded TPN
        lea     tpn_file(pc),a0
        move.l  #'FORM',d0
        bsr     iff_check_chunk
        bne.w   .init_fail        ; Not a valid IFF file

        ; Enter FORM # TPN1 group
        move.l  #'TPN1',d0
        bsr     iff_enter_group
        bne.w   .init_fail        ; Not a TPN1 file

        ; Save TPN1 scope (start and end) before searching
        movea.l	a0,a6            ; a6 = TPN1 body start (saved)
        movea.l	a1,a5            ; a5 = TPN1 body end (saved)

        ; Find TPIS chunk (first occurrence)
        move.l  #'TPIS',d0
        moveq   #0,d1            ; Skip count = 0 (first)
        bsr     iff_find_chunk
        bne.w   .init_fail        ; No TPIS found
        ; Now a0 = TPIS header (ID already validated by iff_find_chunk)
        bsr     iff_enter_chunk        ; Enter TPIS to get body
        bne.w   .init_fail        ; Invalid TPIS chunk size/bounds
        movea.l a0,a4            ; a4 = TPIS body (saved)

        ; Restore TPN1 scope for searching LIST
        movea.l a6,a0            ; a0 = TPN1 body start (restored)
        movea.l a5,a1            ; a1 = TPN1 body end (restored)

        ; Find LIST chunk
        move.l  #'LIST',d0
        moveq   #0,d1
        bsr    	iff_find_chunk
        bne.w   .init_fail        ; No LIST found
        ; Now a0 = LIST header, a1 = scope end

        ; Enter LIST # TPSN group
        move.l  #'TPSN',d0
        bsr     iff_enter_group        ; Enter LIST with TPSN type
        bne.w   .init_fail        ; Not a TPSN list

        ; Find Nth TPSN chunk (song index)
        move.l  #'TPSN',d0
        moveq.l #0,d1
        move.b  d7,d1            ; Zero-extend d7.b to d1.l
        bsr     iff_find_chunk
        bne.w   .init_fail        ; Song not found
        ; Now a0 = TPSN header (ID already validated by iff_find_chunk)

        ; Enter TPSN to get body
        bsr     iff_enter_chunk        ; Enter TPSN to get body
        bne.w   .init_fail        ; Invalid TPSN chunk size/bounds

        ; Success - setup pointers
        ; a0 already = TPSN body
        move.l  a0,a1            ; a1 = TPSN body
        movea.l a4,a0            ; a0 = TPIS body (from a4)

        moveq.l #0,d0
        bra.s   .done

.init_fail:
        moveq.l #-1,d0
.done
        movem.l (sp)+,d1-d7/a2-a6
        rts

        include 'iff.s'

tpn_replay_bin:
        incbin	'player.bin'
instructions_text:
        dc.b    27,'E',"TPN Multi Module Example",13,10
        dc.b    "  Press 1 or 2 to switch songs",13,10
		dc.b	"  Press space to quit.",0
        even
tpn_file:
        incbin	'multi1.tpn'
        even
        dc.b    "END "

        section bss
        
savetc:	ds.l	1
