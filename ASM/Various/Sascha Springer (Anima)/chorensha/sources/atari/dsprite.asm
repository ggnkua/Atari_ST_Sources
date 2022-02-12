; Some figures for Cho Ren Sha 68k:
; 1885 sprite masks.
; Up to about 4000 RLE values.

	opt mu,nohdr

	include	'ioequ.inc'

TOTAL_NUMBER_OF_PACKED_SPRITES equ 1900
NUMBER_OF_PACKED_SPRITES1 equ 1100 ; Keep some space within the X memory for DSP boot code.

push	macro	register
        move    register,y:-(r7)
        endm

pop		macro	register
        move    y:(r7)+,register
        endm

peek	macro	register
        move    y:(r7),register
        endm

; -----------------------------------------------------------------------------
	org	p:$0
; -----------------------------------------------------------------------------

	jmp		main

; -----------------------------------------------------------------------------
	org	p:$40
; -----------------------------------------------------------------------------

main:
	movep	#1,x:m_pbc
	bclr	#m_hf2,x:m_hcr
	move	#<stack,r7

	move	#0,x0
	jsr		<fill_screen_buffer

	jclr	#1,x:m_hsr,*
	movep	x0,x:m_htx ; DSP <-> CPU synchronization.

	jsr		<receive_sprite_masks

_loop:
	jsr		<receive_sprite_infos
	jsr		<draw_inverted_masks
	jsr		<create_rle_data
	jsr		<send_rle_data
	jsr		<swap_sprite_infos
	jsr		<draw_masks

;	jsr		<send_screen_buffer

	jmp		<_loop

; -----------------------------------------------------------------------------

receive_sprite_masks:
	move	#packed_sprite_masks1,r0

	move	#packed_sprite_masks2,r4

	move	#>NUMBER_OF_PACKED_SPRITES1,x0

	jclr	#0,x:m_hsr,*
	movep	x:m_hrx,x1

	tfr		x1,a
	sub		x0,a
	jcc		_extended_receive

	do		x1,_loop

	do		#11,_loop2

	jclr	#0,x:m_hsr,*
	movep	x:m_hrx,x:(r0)+
_loop2:

	nop
_loop:
	
	rts

_extended_receive:
	do		#NUMBER_OF_PACKED_SPRITES1,_loop3

	do		#11,_loop4

	jclr	#0,x:m_hsr,*
	movep	x:m_hrx,x:(r0)+
_loop4:

	nop
_loop3:

	do		a1,_loop5

	do		#11,_loop6

	jclr	#0,x:m_hsr,*
	movep	x:m_hrx,y:(r4)+
_loop6:

	nop
_loop5:

	rts	

; -----------------------------------------------------------------------------

receive_sprite_infos:
	move	x:<work_sprite_infos,r0

	move	#>$ffff,x1

	bset	#m_hf2,x:m_hcr ; DSP <-> CPU synchronization.
	jclr	#m_hf0,x:m_hsr,*

	jclr	#0,x:m_hsr,*
	movep	x:m_hrx,x0

	do		x0,_loop

	jclr	#0,x:m_hsr,*
	movep	x:m_hrx,a
	and		x1,a
	move	a1,x:(r0)+ ; Flip info + ID.

	jclr	#0,x:m_hsr,*
	movep	x:m_hrx,a
	and		x1,a
	move	a1,x:(r0)+ ; X position.

	jclr	#0,x:m_hsr,*
	movep	x:m_hrx,a
	and		x1,a
	move	a1,x:(r0)+ ; Y position.
_loop:

	move	x0,x:<number_of_work_sprite_infos

	rts

; -----------------------------------------------------------------------------
;
; r0 = packed sprite mask address (X memory).
;
convert_packed_sprite_mask1:
	move	#<sprite_convert_masks,r1

	move	#<sprite_mask,r4
	move	#<sprite_convert_shifts,r5

	move	x:(r0)+,x1

	do		#10/2,_loop

	tfr		x1,a x:(r1)+,x0 y:(r5)+,y0
	and		x0,a x:(r0)+,y1
	mpy		x1,y0,a a1,y:(r4)+
	mpy		y1,y0,b x:(r1)-,x0 y:(r5)-,y0
	and		x0,b a0,x1
	or		x1,b x:(r0)+,x1
	mpy		y1,y0,a b1,y:(r4)+
	move	a0,y:(r4)+
_loop:

	tfr		x1,a x:(r1)+,x0
	and		x0,a
	move	a,y:(r4)+
	
	rts

; -----------------------------------------------------------------------------
;
; r6 = packed sprite mask address (Y memory).
;
convert_packed_sprite_mask2:
	move	#<sprite_convert_masks,r1

	move	#<sprite_mask,r4
	move	#<sprite_convert_shifts,r5

	move	y:(r6)+,x1

	do		#10/2,_loop

	tfr		x1,a x:(r1)+,x0 y:(r5)+,y0
	and		x0,a y:(r6)+,y1
	mpy		x1,y0,a a1,y:(r4)+
	mpy		y1,y0,b x:(r1)-,x0 y:(r5)-,y0
	and		x0,b a0,x1
	or		x1,b y:(r6)+,x1
	mpy		y1,y0,a b1,y:(r4)+
	move	a0,y:(r4)+
_loop:

	tfr		x1,a x:(r1)+,x0
	and		x0,a
	move	a,y:(r4)+
	
	rts

; -----------------------------------------------------------------------------

vertical_flip_sprite_mask:
	move	#<sprite_mask,r4
	move	#<sprite_mask+16,r5

	do		#16/2,_loop

	move	y:(r4),x0
	move	y:-(r5),x1
	move	x1,y:(r4)+
	move	x0,y:(r5)
_loop:

	rts

; -----------------------------------------------------------------------------

horizontal_flip_sprite_mask:
	move	#bit_reverse_table,r0

	move	#<sprite_mask,r4
	move	#<sprite_convert_shifts,r5

	move	#>$ff,y1

	move	y:(r5)+,y0

	do		#16,_loop

	move	y:(r4),x0
	mpy		x0,y0,a x0,x1
	and		y1,a y:(r5)-,y0
	mpy		x1,y0,b a1,n0
	and		y1,b y:(r5)+,y0
	move	x:(r0+n0),x0
	mpy		x0,y0,a b1,n0
	move	y:(r5)-,y0
	move	x:(r0+n0),x0
	mac		x0,y0,a y:(r5)+,y0
	move	a0,y:(r4)+
_loop:

	rts

; -----------------------------------------------------------------------------

draw_inverted_masks:
	move	x:<work_sprite_infos,r0
	move	x:<number_of_work_sprite_infos,a

	tst		a a,x0
	jne		_start

	rts

_start:
	move	x:(r0)+,a

	do		x0,_loop

	; Prepare mask.

	move	#>NUMBER_OF_PACKED_SPRITES1,x0
	move	#>11,x1
	move	#>$3fff,y0

	push	r0
	push	a1

	and		y0,a
	sub		x0,a a1,x0

	jcc		<_masks2

	mpy		x0,x1,a
	asr		a #packed_sprite_masks1,r0
	move	a0,n0
	nop
	move	(r0)+n0

	jsr		<convert_packed_sprite_mask1

	jmp		<_skip

_masks2:
	move	a1,x0
	mpy		x0,x1,a
	asr		a #packed_sprite_masks2,r6
	move	a0,n6
	nop
	move	(r6)+n6

	jsr		<convert_packed_sprite_mask2

_skip:
	jsset	#15,y:(r7),vertical_flip_sprite_mask
	jsset	#14,y:(r7)+,horizontal_flip_sprite_mask

	pop		r0

	; Calculate screen offset and shift value.

	move	#$055556,x1 ; 1.0/24.0
	move	x:(r0)+,x0
	mpy		x0,x1,a #>24/2,y0
	move	a1,x1
	mpy		x1,y0,b x0,a
	move	b0,b
	sub		b,a x:(r0)+,b

	move	y:<scrolling_offset,y1
	add		y1,b #>16+256,y1
	jmi		<_skip_drawing
	
	cmp		y1,b b1,y0
	jcc		<_skip_drawing
	
	move	x1,b0
	move	#>(16+256+16)/8/3/2,y1
	mac		y0,y1,b a1,n1
	move	#<sprite_mask,r4
	move	#screen_buffer,r5
	move	b0,n5
	move	#<shift_values,r1
	move	n1,n2
	move	#<shift_masks,r2
	move	(r5)+n5
	move	(r1)+n1
	move	(r2)+n2
	move	#(16+256+16)/8/3-1,n5

	; Draw inverted mask.

	move	x:(r1),x0 y:(r4)+,y0

	do		#16,_loop2

	mpy		-x0,y0,a x:(r2),x0 y:(r5)+,y1
	and		x0,a a0,b
	not		a
	and		y1,a y:(r5)-,y1
	not		b a1,y:(r5)+
	and		y1,b x:(r1),x0 y:(r4)+,y0
	move	b1,y:(r5)+n5
_loop2:

_skip_drawing:
	move	x:(r0)+,a
_loop:

	rts

; -----------------------------------------------------------------------------

create_rle_data:
	move	#screen_buffer+(16+256+16)/8/3*16,r4
	move	#rle_buffer,r5

	clr		b
	move	b1,x0
	move	#>1*2,x1
	move	#>24*2,y0
	move	#>(512-(16+256+16))*2,y1

	do		#240,_loop

	move	y:(r4),a

	do		#(16+256+16)/8/3,_loop2

	tst		a a0,y:(r4)+
	jeq		<_skip_empty_data

	do		#24,_loop3

	rol		a
	jcc		<_transparent_pixel

	bset	#0,x0
	jcs		<_next_pixel

	clr		b b1,y:(r5)+

	jmp		<_next_pixel

_transparent_pixel:
	bclr	#0,x0
	jcc		<_next_pixel

	clr		b b1,y:(r5)+

_next_pixel:
	add		x1,b
_loop3:
	
	jmp		<_skip_non_empty_data

_skip_empty_data:
	bclr	#0,x0
	jcc		<_next_word

	clr		b b1,y:(r5)+

_next_word:
	add		y0,b

_skip_non_empty_data:
	move	y:(r4),a
_loop2:

	bclr	#0,x0
	jcc		<_next_line

	clr		b b1,y:(r5)+

_next_line:
	add		y1,b
_loop:

	clr		b
	move	b1,y:(r5)+ ; Offset.
	move	#>-12,b
	move	b1,y:(r5)+ ; Number of pixels.

	move	#rle_buffer,x0
	move	r5,a
	sub		x0,a
	move	a1,y:rle_length

	rts

; -----------------------------------------------------------------------------

send_rle_data:
	move	#rle_buffer,r4

	move	y:rle_length,a
	bclr	#0,sr
	ror		a #<0,y0

	bclr	#m_hf2,x:m_hcr ; DSP <-> CPU synchronization.
	jset	#m_hf0,x:m_hsr,*

	jclr	#1,x:m_hsr,*
	movep	a1,x:m_htx

	do		a1,_loop

	jclr	#1,x:m_hsr,*
	movep	y:(r4),x:m_htx

	move	y0,y:(r4)+

	move	y:(r4),a
	neg		a y0,y:(r4)+

	jclr	#1,x:m_hsr,*
	movep	a1,x:m_htx
_loop:

	rts

; -----------------------------------------------------------------------------

fill_screen_buffer:
	move	#screen_buffer+(16+256+16)/8/3*16,r4

	rep		#(16+256+16)/8/3*256
	move	x0,y:(r4)+

	rts

; -----------------------------------------------------------------------------

swap_sprite_infos:
	move	x:<work_sprite_infos,x0
	move	x:<display_sprite_infos,x1
	move	x0,x:<display_sprite_infos
	move	x1,x:<work_sprite_infos

	move	x:<number_of_work_sprite_infos,x0
	move	x:<number_of_display_sprite_infos,x1
	move	x0,x:<number_of_display_sprite_infos
	move	x1,x:<number_of_work_sprite_infos

	rts

; -----------------------------------------------------------------------------

draw_masks:
	move	x:<work_sprite_infos,r0
	move	x:<number_of_work_sprite_infos,a

	tst		a a,x0
	jne		_start

	rts

_start:
	move	x:(r0)+,a

	do		x0,_loop

	; Prepare mask.

	move	#>NUMBER_OF_PACKED_SPRITES1,x0
	move	#>11,x1
	move	#>$3fff,y0

	push	r0
	push	a1

	and		y0,a
	sub		x0,a a1,x0

	jcc		<_masks2

	mpy		x0,x1,a
	asr		a #packed_sprite_masks1,r0
	move	a0,n0
	nop
	move	(r0)+n0

	jsr		<convert_packed_sprite_mask1

	jmp		<_skip

_masks2:
	move	a1,x0
	mpy		x0,x1,a
	asr		a #packed_sprite_masks2,r6
	move	a0,n6
	nop
	move	(r6)+n6

	jsr		<convert_packed_sprite_mask2

_skip:
	jsset	#15,y:(r7),vertical_flip_sprite_mask
	jsset	#14,y:(r7)+,horizontal_flip_sprite_mask

	pop		r0

	; Calculate screen offset and shift value.

	move	#$055556,x1 ; 1.0/24.0
	move	x:(r0)+,x0
	mpy		x0,x1,a #>24/2,y0
	move	a1,x1
	mpy		x1,y0,b x0,a
	move	b0,b
	sub		b,a x:(r0)+,y0
	move	x1,b0
	move	#>(16+256+16)/8/3/2,y1
	mac		y0,y1,b a1,n1
	move	#<sprite_mask,r4
	move	#screen_buffer,r5
	move	b0,n5
	move	#<shift_values,r1
	move	n1,n2
	move	#<shift_masks,r2
	move	(r5)+n5
	move	(r1)+n1
	move	(r2)+n2
	move	#(16+256+16)/8/3-1,n5

	; Draw mask.

	move	x:(r1),x0 y:(r4)+,y0

	do		#16,_loop2

	mpy		-x0,y0,a x:(r2),x0 y:(r5)+,y1
	and		x0,a a0,b
	or		y1,a y:(r5)-,y1
	move	a1,y:(r5)+
	or		y1,b x:(r1),x0 y:(r4)+,y0
	move	b1,y:(r5)+n5
_loop2:

	move	x:(r0)+,a
_loop:

	rts

; -----------------------------------------------------------------------------
	org	x:$0 ; Internal X RAM.
; -----------------------------------------------------------------------------

shift_values:
	dc		-1.0/@POW(2.0,0.0)
	dc		-1.0/@POW(2.0,1.0)
	dc		-1.0/@POW(2.0,2.0)
	dc		-1.0/@POW(2.0,3.0)
	dc		-1.0/@POW(2.0,4.0)
	dc		-1.0/@POW(2.0,5.0)
	dc		-1.0/@POW(2.0,6.0)
	dc		-1.0/@POW(2.0,7.0)
	dc		-1.0/@POW(2.0,8.0)
	dc		-1.0/@POW(2.0,9.0)
	dc		-1.0/@POW(2.0,10.0)
	dc		-1.0/@POW(2.0,11.0)
	dc		-1.0/@POW(2.0,12.0)
	dc		-1.0/@POW(2.0,13.0)
	dc		-1.0/@POW(2.0,14.0)
	dc		-1.0/@POW(2.0,15.0)
	dc		-1.0/@POW(2.0,16.0)
	dc		-1.0/@POW(2.0,17.0)
	dc		-1.0/@POW(2.0,18.0)
	dc		-1.0/@POW(2.0,19.0)
	dc		-1.0/@POW(2.0,20.0)
	dc		-1.0/@POW(2.0,21.0)
	dc		-1.0/@POW(2.0,22.0)
	dc		-1.0/@POW(2.0,23.0)

shift_masks:
	dc		$ffffff
	dc		$7fffff
	dc		$3fffff
	dc		$1fffff
	dc		$0fffff
	dc		$07ffff
	dc		$03ffff
	dc		$01ffff
	dc		$00ffff
	dc		$007fff
	dc		$003fff
	dc		$001fff
	dc		$000fff
	dc		$0007ff
	dc		$0003ff
	dc		$0001ff
	dc		$0000ff
	dc		$00007f
	dc		$00003f
	dc		$00001f
	dc		$00000f
	dc		$000007
	dc		$000003
	dc		$000001

sprite_convert_masks:
	dc		$ffff00
	dc		$00ff00

work_sprite_infos:
	dc		sprite_infos1

display_sprite_infos:
	dc		sprite_infos2

number_of_work_sprite_infos:
	dc		0

number_of_display_sprite_infos:
	dc		0

; -----------------------------------------------------------------------------
	org	x:$4000 ; External X RAM.
; -----------------------------------------------------------------------------

bit_reverse_table:
	dc		$00,$80,$40,$C0,$20,$A0,$60,$E0,$10,$90,$50,$D0,$30,$B0,$70,$F0
	dc		$08,$88,$48,$C8,$28,$A8,$68,$E8,$18,$98,$58,$D8,$38,$B8,$78,$F8 
	dc		$04,$84,$44,$C4,$24,$A4,$64,$E4,$14,$94,$54,$D4,$34,$B4,$74,$F4 
	dc		$0C,$8C,$4C,$CC,$2C,$AC,$6C,$EC,$1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC 
	dc		$02,$82,$42,$C2,$22,$A2,$62,$E2,$12,$92,$52,$D2,$32,$B2,$72,$F2 
	dc		$0A,$8A,$4A,$CA,$2A,$AA,$6A,$EA,$1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA
	dc		$06,$86,$46,$C6,$26,$A6,$66,$E6,$16,$96,$56,$D6,$36,$B6,$76,$F6 
	dc		$0E,$8E,$4E,$CE,$2E,$AE,$6E,$EE,$1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE
	dc		$01,$81,$41,$C1,$21,$A1,$61,$E1,$11,$91,$51,$D1,$31,$B1,$71,$F1
	dc		$09,$89,$49,$C9,$29,$A9,$69,$E9,$19,$99,$59,$D9,$39,$B9,$79,$F9 
	dc		$05,$85,$45,$C5,$25,$A5,$65,$E5,$15,$95,$55,$D5,$35,$B5,$75,$F5
	dc		$0D,$8D,$4D,$CD,$2D,$AD,$6D,$ED,$1D,$9D,$5D,$DD,$3D,$BD,$7D,$FD
	dc		$03,$83,$43,$C3,$23,$A3,$63,$E3,$13,$93,$53,$D3,$33,$B3,$73,$F3 
	dc		$0B,$8B,$4B,$CB,$2B,$AB,$6B,$EB,$1B,$9B,$5B,$DB,$3B,$BB,$7B,$FB
	dc		$07,$87,$47,$C7,$27,$A7,$67,$E7,$17,$97,$57,$D7,$37,$B7,$77,$F7 
	dc		$0F,$8F,$4F,$CF,$2F,$AF,$6F,$EF,$1F,$9F,$5F,$DF,$3F,$BF,$7F,$FF

packed_sprite_masks1:
	ds 		NUMBER_OF_PACKED_SPRITES1*11

sprite_infos1:
	ds		512*3

sprite_infos2:
	ds		512*3

; -----------------------------------------------------------------------------
	org	y:$0 ; Internal Y RAM.
; -----------------------------------------------------------------------------

sprite_mask:
	ds		16

sprite_convert_shifts:
	dc		$008000
	dc		$000080

rle_length:
	ds		1

scrolling_offset:
	dc		0

	ds		10
stack:

; -----------------------------------------------------------------------------
	org	y:$4000 ; External Y RAM.
; -----------------------------------------------------------------------------

packed_sprite_masks2:
	ds 		(TOTAL_NUMBER_OF_PACKED_SPRITES-NUMBER_OF_PACKED_SPRITES1)*11

rle_buffer: ; Needs to be in front of the screen buffer!
	ds		4000
screen_buffer:
	ds		(16+256+16)*(16+256+16)/8/3

; -----------------------------------------------------------------------------
	end
; -----------------------------------------------------------------------------

send_screen_buffer:
	move	#screen_buffer1+(16+256+16)/8/3*(16+20),r4
	move	#<sprite_convert_shifts,r5

	move	#>$ff,x1
	move	y:(r4)+,y0
	move	y:(r5)+,y1

	do		#(16+256+16)/8/3/2*200,_loop

	mpy		y0,y1,a
	move	a0,x0
	mpy		x0,y1,b y:(r4)+,x0

	jclr	#1,x:m_hsr,*
	movep	a1,x:m_htx
	
	move	y:(r5)-,y1
	mpy		x0,y1,b b1,x0
	and		x1,b
	or		x0,b

	jclr	#1,x:m_hsr,*
	movep	b1,x:m_htx
	
	move	b0,x0
	move	y:(r5)+,y1
	mpy		x0,y1,a y:(r4)+,y0

	jclr	#1,x:m_hsr,*
	movep	a1,x:m_htx
_loop:
	
	rts


