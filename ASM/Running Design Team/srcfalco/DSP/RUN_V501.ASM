
;**********************************************************
;*
;* projekt: running
;*   coder: tarzan boy
;*
;**********************************************************

int_genau	equ	5
int_genau3	equ	0
int_genau4	equ	0
int_genau5	equ	1

stack_lines_max	equ	32

points_max	equ	192
lines_max	equ	192
monsters_max	equ	32
doors_max	equ	32
things_max	equ	48
schalt_max	equ	24

masked_max	equ	64

b_text_max	equ	$1870
b_boden_max	equ	$1200
b_mask_max	equ	$800

monst_pts_offi	equ	(points_max+monsters_max)*2
doors_pts_offi	equ	monst_pts_offi+monsters_max*4
things_pts_offi	equ	doors_pts_offi+doors_max*16+things_max*2
schalt_pts_offi	equ	things_pts_offi+things_max*4

PBC		equ	$ffe0
HCR		equ	$ffe8
HSR		equ	$ffe9
HRX		equ	$ffeb
HTX		equ	$ffeb
BCR		equ	$fffe
IPR		equ	$ffff


;**********************************************************
;***
;***		Programm-Speicher
;***
;**********************************************************

 		org	p:$200
start		
		jsr	init_system
main_loop
		jsr	reset_dsp_datas
		jsr	cpu_read_normal
		jsr	shift_playfield
		jsr	rotate_playfield
		jsr	place_monsters
		jsr	place_things
		jsr	kill_lines_behind
		jsr	sort_masked_lines
		jsr	control_mon_entf
		jsr	kollision
		jsr	cpu_send_bild
		jsr	cpu_send_info
		jsr	cpu_send_new_info
		
		jmp	main_loop

;**********************************************************

; sortierung aller linien, die maskiert werden muessen ...

; naives sortieren
; version 1.0  vom 12.4.96, 22.00 uhr
; version 1.2  vom 26.3.97, 14.30 uhr (completly rewritten)
; version 1.21 vom 28.3.97
; version 2.0  vom 30.3.97, 2.00 uhr (completly rewritten)
 
sort_masked_lines

		move	#>calc_lines_i,b
		move	x:calc_l_i_anz,a

		jsr	sort_ml_now

		move	#>calc_lines_ii,b
		move	x:calc_l_ii_anz,a

		jsr	sort_ml_now

		rts

;---------------

; b = calc_lines
; a = anzahl lines

sort_ml_now

		tst	a  a,x0			; keine linien vorhanden ?
		jeq	smln_out

	; zuerst die adressen der zu maskierenden
	; linien bestimmen und in x:strahl_buffer eintragen ...

		move	#>strahl_buffer,r3	; speicher linienadressen

		move	#>3,y0			; maskflag liegt im 4. byte
		add	y0,b  #>5,y1		; adresse korrigieren
						; 5 dsp-words pro linien
		clr	a  #>1,x1		; a = anzahl zu mask. linien

		do	x0,smln_find_loop

		add	y1,b  b,r2		; ins adressregister
		nop				; pointer auf naechste linie

		jclr	#14,x:(r2),smln_no_mask	; maskflag vorhanden ?

	; die linie muss maskiert werden, adresse zuruecksetzen und eintragen ...
	; anzahl zu maskierender linien um eins erhoehen ...

		add	x1,a  b,x0
		move	r2,b
		sub	y0,b			; pointer auf linienanfang
		move	b,x:(r3)+		; und eintragen
		move	x0,b

smln_no_mask
		nop
smln_find_loop

		move	#>2,x0			; wenn anzahl niedriger als
		cmp	x0,a  a,x:masked_anz	; zwei, dann keine
		jle	smln_out		; sortierung

		move	#>calc_points,r0

		clr	b
		move	b,x:sort_i

		move	#>1,x0
		sub	x0,a
		move	a,x0

		do	x0,smln_loop_i

		move	#>strahl_buffer,r3
		move	x:sort_i,n3
		nop
		move	x:(r3+n3),r4
		move	r4,r6
		move	x:(r4),n0
		nop
		move	x:(r0+n0),a
		move	a,x:sort_wert

		move	x:sort_i,a		; for j = i+1 ...
		move	#>1,x0
		add	x0,a
		move	a,x:sort_j

smln_j_begin
		move	x:masked_anz,a
		move	x:sort_j,b
		cmp	a,b
		jeq	smln_j_end

		move	#>strahl_buffer,r3
		move	x:sort_j,n3
		nop
		move	x:(r3+n3),r5
		nop
		move	x:(r5),n0
		nop
		move	x:(r0+n0),a

		move	x:sort_wert,b
		cmp	a,b
		jge	smln_no_inner_j

		move	a,x:sort_wert
		move	r5,r6

smln_no_inner_j


		move	x:sort_j,a
		move	#>1,x0
		add	x0,a
		move	a,x:sort_j
		jmp	smln_j_begin

smln_j_end

	; vertauschung

		do	#5,smln_change_loop
		move	x:(r4),a0
		move	x:(r6),a1
		move	a1,x:(r4)+
		move	a0,x:(r6)+
smln_change_loop		

		move	x:sort_i,a
		move	#>1,x0
		add	x0,a
		move	a,x:sort_i
smln_loop_i

		nop

smln_out

		rts


;**********************************************************

; kontrolliert die getroffenen monster mit der
; maximalen schussentfernung ...

control_mon_entf

		move	x:monsters_anz,a
		tst	a  a,x0
		jeq	cme_out	

		move	x:shoot,a		; nicht noetig, wenn
		tst	a			; kein schuss gefallen ist
		jeq	cme_out

		move	#>monsters_flags,r3
		move	#>-1,n3

	; die maximale schussentfernung berechnet sich
	; aus min_entf (naechstgelegene wand) und shoot
	; (reichweite der waffe) - je nachdem ...

		move	x:min_entf,b
		cmp	a,b
		jlt	cme_ok
		move	a,b
cme_ok	
		do	x0,cme_out

		move	x:(r3)+,a
		jclr	#23,a1,cme_loop

		bclr	#23,a1
		move	a1,a
		cmp	a,b
		jgt	cme_loop

		clr	a
		move	a,x:(r3+n3)

cme_loop
		nop
cme_out		
		nop
		rts

;**********************************************************

; bei sicht von bestimmten seiten muessen bei den
; monstern die texturen horizontal gespiegelt werden.
; flag ist bit 22 von x:monsters_breite.
; ist dieses gesetzt, so anfangs und endpunkt
; vertauschen (durch vertauschen der pointer) und
; den Normalenvektor der monster-textur auf $80 setzen.

pm_turn_monsters

		move	x:monsters_anz,a
		tst	a  a,x1
		jeq	pmtm_out

		move	#>monsters_breite,r4
		move	#>5,y0

		clr	b  #>monsters_lines,r2

		do	x1,pmtm_out

		clr	a  x:(r4)+,b1
		jclr	#22,b1,pmtm_no_change

		move	#>1,n2
		move	x:(r2),a0
		move	x:(r2+n2),a1
		move	a0,x:(r2+n2)
		move	#>3,n2
		move	a1,x:(r2)

		move	x:(r2+n2),a1	; winkel auf $80 setzen
		bset	#23,a1
		move	a1,x:(r2+n2)

pmtm_no_change
		move	r2,a
		add	y0,a
		move	a,r2
pmtm_out
		nop

		rts

;----

; Die Standpunkte der Monster sind rotiert worden.
; Jetzt wird aus jedem dieser Stadtpunkte zwei
; Punkte erzeugt, die dann miteinander verbunden
; die Linie fuer das Monster darstellen.
; Dabei entsteht (als Abfallprodukt) die Information,
; ob die Monster-Linie die X-Achse schneidet.
; Ist ein Schuss gefallen, so ist das Monster getroffen.

place_monsters

		jsr	pm_turn_monsters

		clr	b  x:monsters_anz,a
		move	b,x:one_mon_hit
		tst	a  a,x1
		jeq	nothing_to_place
		
		move	#>monsters_flags,r3
		move	#>monsters_breite,r4

		move	#>calc_points_m,r0
		move	#>calc_points_mm,r1

		do	x1,nothing_to_place

	; nutze x:p_x1 als flag fuer monster getroffen ...
	; also anfangs loeschen ...

		clr	a
		move	a,x:p_x1

		move	x:(r0)+,x0	; x-wert
		move	x:(r0)+,a	; y-wert

		clr	b  #>$0000ff,x1
		move	b,x:(r3)	; monsters_flags loeschen
		move	x:(r4),b1	; breite und killed_flag
		and	x1,b  b1,y1 
		rep	#3+int_genau
		lsl	b

		move	x0,x:(r1)+	; x-wert bleibt gleich
		add	b,a  a,x1
		move	a,x:(r1)+	; neuer y1-wert
		move	#>16*8*8*2*2,y0	; -> int_genau 5 = *2*2
		cmpm	y0,a
		jge	pm_nocase_1
		bset	#0,x:p_x1
pm_nocase_1

		move	y1,b1
		move	#>$ff00,y1
		and	y1,b  a,y0
		move	x1,a		; -> int_genau = 5 -> kein lsr b
		move	x0,x:(r1)+	; / x-wert bleibt gleich
		sub	b,a  x0,y1	; x-wert zwischenspeichern
		move	#>16*8*8*2*2,x1
		cmpm	x1,a
		jge	pm_nocase_2
		bset	#0,x:p_x1
pm_nocase_2

	; wenn monster bereits tot, dann kein_treffer

		move	x:(r4)+,b	; killed_flag (bit #23)
		tst	b  a,x:(r1)+	; / neuer y2-wert
		jmi	kein_treffer

	; x-wert testen - wenn negativ, dann kein_treffer

		move	x0,b		
		tst	b  a,x0		
		jmi	kein_treffer

	; multiplikation der beiden y-werte,
	; wenn negativ (y1>0, y2<0 o.u.), dann treffer

		mpy	x0,y0,a		
		jpl	kein_treffer	
treffer
		move	x:shoot,a
		tst	a  #>1,x0
		jeq	kein_treffer_out

		bset	#23,b1		; bit #23 setzen
		move	b1,x:(r3)+	
		move	x0,x:one_mon_hit
		jmp	testing_go_on

kein_treffer
		jset	#0,x:p_x1,treffer

kein_treffer_out
		move	y1,b
		bclr	#23,b1
		move	b1,x:(r3)+

testing_go_on
		nop

nothing_to_place

		nop

		rts		
 

;**********************************************************

place_things
		move	x:things_anz,a
		tst	a  a,x0
		jeq	noth_to_place
		
		move	#>calc_points_g,r0
		move	#>calc_points_gg,r1
		move	#>things_lines+4,r2
		move	#>5,x1

		do	x0,noth_to_place

		move	x:(r0)+,x0		; x-wert
		move	x:(r0)+,a		; y-wert

		clr	b  #>$ff,y1
		move	x:(r2),b0
		rep	#8
		asl	b
		and	y1,b  #>1,y0
		add	y0,b  x0,x:(r1)+	; / x-wert bleibt gleich
		rep	#4+int_genau
		lsl	b
		move	b1,y1

		add	y1,a  a,b
		move	a,x:(r1)+		; neuer y1-wert

		sub	y1,b  x0,x:(r1)+	; / x-wert bleibt gleich

		move	r2,a
		add	x1,a  b,x:(r1)+		; / neuer y2-wert
		move	a,r2

noth_to_place

		nop

		rts

;**********************************************************

shift_playfield
		move	x:sx,x0
		move	x:sy,y0

		move	x:points_anz,x1

		move	#>points,r0
		move	#>calc_points,r1
		
		jsr	shift_now

		move	x:doors_anz,a
		tst	a
		jeq	no_doors_shift

		rep	#3
		lsl	a
		move	a,x1			; 1 door = 8 punkte

		move	#>points_doors,r0
		move	#>calc_points_d,r1

		jsr	shift_now

no_doors_shift
		move	x:monsters_anz,a
		tst	a  a,x1
		jeq	no_monsters_shift

		move	#>points_monsters,r0
		move	#>calc_points_m,r1

		jsr	shift_now

no_monsters_shift
		move	x:things_anz,a
		tst	a  a,x1
		jeq	no_things_shift

		move	#>points_things,r0
		move	#>calc_points_g,r1

		jsr	shift_now

no_things_shift
		move	x:schalt_anz,a
		tst	a
		jeq	no_schalt_shift

		lsl	a  #>points_schalt,r0
		move	a,x1
		move	#>calc_points_s,r1

		jsr	shift_now

no_schalt_shift
		nop

		rts

;------

; x1 = anzahl an punkten (x/y)
; x0 = sx
; y0 = sy
; r0 = von hier
; r1 = nach hier

shift_now
		do	x1,shift_loop

		move	x:(r0)+,a
		sub	x0,a  x:(r0)+,b
		sub	y0,b  a,x:(r1)+
		move	b,x:(r1)+
shift_loop
		nop

		rts

;**********************************************************

rotate_playfield
		move	#>$1,n1
		move	#>$100,r2

		move	x:alpha,x0
		move	#>$100,a
		sub	x0,a  #>$ff,x1
		and	x1,a  #>$40,x0
		move	a,n2
		add	x0,a
		and	x1,a  y:(r2+n2),y0	;wsi
		move	a,n2
		move	x:points_anz,x0
		move	y:(r2+n2),y1		;wco

		move	#>calc_points,r1

		jsr	rotate_now

		move	x:doors_anz,a
		tst	a
		jeq	no_doors_rot

		rep	#3
		lsl	a
		move	a,x0			; 1 door = 8 punkte

		move	#>calc_points_d,r1

		jsr	rotate_now

no_doors_rot
		move	x:monsters_anz,a
		tst	a  a,x0
		jeq	no_monsters_rot

		move	#>calc_points_m,r1

		jsr	rotate_now

no_monsters_rot
		move	x:things_anz,a
		tst	a  a,x0
		jeq	no_things_rot

		move	#>calc_points_g,r1

		jsr	rotate_now

no_things_rot
		move	x:schalt_anz,a
		tst	a
		jeq	no_schalt_rot

		lsl	a  #>calc_points_s,r1
		move	a,x0

		jsr	rotate_now

no_schalt_rot
		nop

		rts

;------

; x0 = anzahl an punkten (x/y)
; y0 = sinus
; y1 = cosinus
; r1 = calc_points

rotate_now
		do	x0,rotate_loop

		move	x:(r1),x0		;x
		mpy	x0,y1,a  x:(r1+n1),x1	;y
		macr	-x1,y0,a
		mpy	x0,y0,b
		macr	x1,y1,b  a,x:(r1)+
		move	b,x:(r1)+

rotate_loop	
		nop
		
		rts

;**********************************************************

kill_lines_behind
		move	#>calc_lines_i,r4
		move	#>calc_lines_ii,r5
		move	#>reg_retten,r6
		move	#>$7fffff,a
		move	a,x:min_entf

		move	x:alpha,a
		move	#>$100,b
		sub	a,b
		rep	#16
		lsl	b
		move	b1,y1

		move	#>$0,x0
		move	x0,x1
		move	x0,x:mon_line_flag

		move	#>calc_points,r0
		move	#>calc_points+1,r1
		move	#>lines,r2
		move	x:lines_anz,y0

		jsr	kill_now

		move	x:doors_anz,a
		tst	a
		jeq	no_doors

		lsl	a
		lsl	a
		move	a,y0

		move	#>doors_lines,r2

		jsr	kill_now
no_doors
		move	x:monsters_anz,a
		tst	a  a,y0
		jeq	no_monsters

		move	#>monsters_lines,r2

		move	#>1,a
		move	a,x:mon_line_flag
		jsr 	kill_now
no_monsters
		move	x:things_anz,a
		tst	a  a,y0
		jeq	no_things

		clr	a
		move	a,x:mon_line_flag
		move	#>things_lines,r2

		jsr	kill_now
no_things
		move	x:schalt_anz,a
		tst	a  a,y0
		jeq	no_schalt

		move	#>schalt_lines,r2

		jsr	kill_now
no_schalt
		move	x0,x:calc_l_i_anz
		move	x1,x:calc_l_ii_anz

		rts

;---------------

;* r0: calc_points
;* r1: calc_points+1
;* r2: xxx_lines

;* r4: calc_lines_i
;* r5: calc_lines_ii

;* x0: anzahl calc_lines_i
;* x1: anzahl calc_lines_ii
;* y0: anzahl xxx_lines
;* y1: alpha_offset

kill_now	
		do	y0,kill_loop

		move	x:(r2)+,y0
		move	y0,x:koll_counter
		move	y0,n0
		move	n0,n1
		move	x:(r0+n0),b	;x1
		tst	b  n0,n2
		jmi	anf_behind
		
anf_in_front	move	x:(r1+n1),b	;y1
		tst	b
		jmi	anf_sector_2

anf_sector_1	move	x:(r2)+,y0
		move	y0,x:make_counter
		move	y0,n1
		nop
		move	x:(r1+n1),b
		tst	b
		jmi	its_sector_3

its_sector_1	
		move	x:koll_counter,y0
		move	y0,x:(r4)+
		move	x:make_counter,y0
		move	y0,x:(r4)+
		move	x0,a
		move	#>$1,b
		add	b,a  		;n1,x:(r4)+
		move	a,x0
		move	x:(r2)+,a
		move	a,x:(r4)+
		move	x:(r2)+,a
		add	y1,a
		move	a1,x:(r4)+
		move	x:(r2)+,a
		move	a,x:(r4)+
		jmp	next_line

anf_sector_2	move	x:(r2)+,y0
		move	y0,x:make_counter
		move	y0,n1
		nop
		move	x:(r1+n1),b	;y2
		tst	b
		jpl	its_sector_3

its_sector_2
		move	x:koll_counter,y0
		move	y0,x:(r5)+
		move	x:make_counter,y0
		move	y0,x:(r5)+

		move	x1,a
		move	#>$1,b
		add	b,a  
		move	a,x1
		move	x:(r2)+,a
		move	a,x:(r5)+
		move	x:(r2)+,a
		add	y1,a
		move	a1,x:(r5)+
		move	x:(r2)+,a
		move	a,x:(r5)+
		jmp	next_line

its_sector_3
		move	x0,x:(r6)+
		move	x1,x:(r6)+
		move	y1,x:(r6)+
		move	#>1,n2		

		move	x:koll_counter,y0
		move	y0,n0
		move	y0,n1
		move	y0,x:(r4)+
		move	y0,x:(r5)+		
		move	x:(r0+n0),x0		; x1
		move	x:(r1+n1),x1		; y1

		move	x:make_counter,y0
		move	y0,n0
		move	y0,n1
		move	y0,x:(r4)+
		move	y0,x:(r5)+

		clr	b  x:sh,a
		lsr	a  x:(r2),b1
		lsr	a  #>$ff,y0
		and	y0,b 
		cmp	a,b
		jgt	klb_no_min_fnd

		move	x:(r2+n2),b1
		jset	#14,b1,klb_no_min_fnd
		and	y0,b
		cmp	a,b
		jlt	klb_no_min_fnd

		move	x:(r0+n0),a		; x2
		move	x:(r1+n1),b		; y2

		sub	x0,a			; dx
		sub	x1,b  a,y0		; dy
		neg	b  b,y1
		
		mpy	x1,y0,a  
		mac	-x0,y1,a
		asr	a  b,x0

		tst	b
		jpl	klb_div_go_on
		neg	a
klb_div_go_on
		andi	#$fe,ccr
		asl	a
		rep	#24
		div	x0,a

		move	a0,b
		tst	b
		jmi	klb_no_min_fnd
		move	x:mon_line_flag,a
		tst	a
		jne	klb_no_min_fnd
		move	x:min_entf,a
		cmp	b,a
		jle	klb_no_min_fnd
		move	b,x:min_entf
klb_no_min_fnd

		move	x:-(r6),y1
		move	x:-(r6),x1
		move	x:-(r6),x0

		move	#>1,b
		add	x0,b  b,a
		add	x1,a  b,x0  	
		move	a,x1
		move	x:(r2)+,a
		move	a,x:(r4)+
		move	a,x:(r5)+
		move	x:(r2)+,a
		add	y1,a
		move	a1,x:(r4)+
		move	a1,x:(r5)+
		move	x:(r2)+,a
		move	a,x:(r4)+
		move	a,x:(r5)+
		jmp	next_line

anf_behind	move	x:(r2),n0
		nop
		move	x:(r0+n0),b	;x2
		tst	b  n2,n0
		jpl	anf_in_front

		move	x:(r2)+,n0
		move	x:(r2)+,n0
		move	x:(r2)+,n0
		move	x:(r2)+,n0

next_line
		nop
kill_loop
		nop
		
		rts

;**********************************************************

;* r0: bild (RESERVIERT!) 
;* r1: strahl_buffer (RESERVIERT!)

kollision
		move	#>bild,r0
		move	#>bild_boden,a
		move	a,x:bild_boden_pos
		move	#>bild_mask,a
		move	a,x:bild_mask_pos

		move	#>calc_points,r2
		move	#>calc_points+1,r3

		clr	b  #>tangens_tab,r5
		move	b,x:koll_counter
strahl_loop
		clr	a  #>strahl_buffer,r1
		move	a,x:strahl_buffer_anz
		move	r1,x:strahl_buffer_free

		move	x:width,a
		lsr	a
		cmp	b,a  b,n5
		jlt	winkel_positiv

winkel_negativ	move	x:calc_l_ii_anz,a
		tst	a  a,x0
		jeq	part_ende

		move	#>calc_lines_ii,r4
		jsr	part_kollision

		jmp	part_ende

winkel_positiv	move	x:calc_l_i_anz,a
		tst	a  a,x0
		jeq	part_ende

		move	#>calc_lines_i,r4
		jsr	part_kollision

part_ende
		jsr	make_bild_entry

		move	#>1,x0
		move	x:koll_counter,b
		add	x0,b  x:width,x0
		cmp	x0,b  b,x:koll_counter
		jlt	strahl_loop

		rts

;**********************************************************

;* r0: bild (RESERVIERT!)
;* r1: strahl_buffer (RESERVIERT!)
;* r2: calc_points (anfang)
;* r3: calc_points+1 (anfang)
;* r4: calc_lines (je nach sektor)
;* r5: tangens_tab
;* r6: winkel_320_tab
;* r7: used for make_entry

part_kollision	
		move	#>$7fffff,y0
		move	y0,x:entfernung_max

		move	#>winkel_320_tab,r6
		move	n5,n6

		do	x0,kollision_loop


	; zuallererst feststellen, welche seite der textur ueberhaupt
	; getroffen wird bzw. ob diese seite dann ueberhaupt sichtbar ist.
	; dazu wird lediglich line_flag_2 benoetigt ...

		clr	a  #>$ffff00,x1
		move	#>3,n4
		move	a,x:flag
		move	x:(r4+n4),a0		; line_flag_2
		move	a0,x:line_flag_2

		rep	#8
		asl	a			; a[7..0] = normw
		jclr	#7,a1,bit_null
		add	x1,a
bit_null	move	x:(r6+n6),x0			;winkel fÅr strahl
		sub	x0,a  #>$40,x1			;a = normw - sw
		cmpm	x1,a
		jle	vorderseite

		bset	#3,x:flag
		jset	#9,x:line_flag_2,text_sichtbar
		jmp	pk_pre_out

vorderseite
		jset	#8,x:line_flag_2,text_sichtbar

pk_pre_out
		move	r4,a
		move	#>5,x0
		add	x0,a
		move	a,r4
		jmp	strahl_vorbei


text_sichtbar

	; die seite die der strahl eventuell trifft, ist
	; also auf jeden fall sichtbar ...

		move	x:(r4)+,x0		; bodenfarben enthalten ...
		move	x0,x:point1		; deshalb in 24bit register !!!
		move	x0,n2
		move	n2,n3
		move	x:(r2+n2),y0		;x1
		move	x:(r3+n3),y1		;y1

		move	x:(r4)+,x0
		move	x0,x:point2
		move	x0,n2
		move	n2,n3
		move	x:(r2+n2),a		;x2
		
		cmp	y0,a  x:(r3+n3),b	;y2
		jge	no_change_points

		move	y0,x1			;exg y0,a
		move	a,y0
		move	x1,a
		move	y1,x1			;exg y1,b
		move	b,y1
		move	x1,b
		bset	#1,x:flag

no_change_points
		sub	y0,a  a,x:p_x2		;dx // end_x
		sub	y1,b  b,x:p_y2		;dy // end_y

		cmpm	a,b  x:(r5+n5),x0	;tan
		jsgt	set_steile_flag

	; -----------------------------
	; calc_entf
	; -----------------------------

	;	       y1 * dx - x1 * dy
	;	 xs = -------------------
	;	         tan * dx - dy

		move	a,x1			;dx

		mpyr	x0,x1,a			;tan * dx // texture
		sub	b,a  b,x0		;a = tan * dx - dy

		mpy	x1,y1,b  x1,x:p_dx	;y1 * dx
		mac	-x0,y0,b  x0,x1		;b - x1 * dy // dy
		asr	b  a,x0			;ZÑhler jetzt in b0 (!)

		tst	a  x1,x:p_dy
		jpl	ce_div_go_on

		neg	b

ce_div_go_on
		andi	#$fe,ccr
		asl	b  x:(r4)+,x1		; need perh. carry bit (!)
		rep	#24
		div	x0,b

		move	x1,x:line_flag_1
		move	x:(r4)+,x0
		move	x0,x:line_flag_2
		move	x:(r4)+,x1
		
		move	b0,a			; entf
		tst	a  a,x:entf
		jmi	strahl_vorbei
		jeq	strahl_vorbei

		move	x:entfernung_max,x0
		cmp	x0,a  x1,x:line_flag_3
		jgt	strahl_vorbei

		jset	#0,x:flag,steile_linie
		jmp	flache_linie


entry_vorbereiten

	; -----------------------------
	; calc_height
	; -----------------------------

		clr	a  #>$ffff,x1		; / fuer calc_zoom_and_xyoffi
		move	a,x:yind		; gleichzeitig yind loeschen
		move	x:per,a0
		asl	a  x:entf,x0
		asl	a  #>2,b		; / fuer calc_zoom_and_xyoffi
		rep	#24
		div	x0,a		
		move	a0,x:c_heigth

	; -----------------------------
	; calc_zoom_and_xyoffi
	; -----------------------------

		clr	a  x:c_heigth,x0
		andi	#$fe,ccr
		rep	#24
		div	x0,b

		move	x:line_flag_3,a1	; a ist komplett null
		and	x1,a  b0,x:zoom
		move	a1,x:xyoffi

	; -----------------------------
	; calc_h1_h2
	; -----------------------------

	; immernoch:  x0 = c_heigth

		move	x:sh,x1
		mpy	x0,x1,a  x:heigth_d2,b
		rep	#10
		asr	a
		move	a0,x1
		sub	x1,b  x:line_flag_1,a1

		move	#>$ff,x1
		and	x1,a1
		move	a1,y0
		mpy	x0,y0,a
		rep	#8
		asr	a
		move	a0,a
		add	b,a  x:heigth,y0
		jpl	h1_ok

		neg	a  x:zoom,y0
		clr	a  a,x:yind

h1_ok		
		cmp	y0,a  a,x:h1
		jge	strahl_vorbei		

		move	a,x:prev_h1

		move	x:line_flag_2,a1
		and	x1,a1  #>1,y0
		add	y0,a
		move	a1,y0
		mpy	x0,y0,a
		rep	#8
		asr	a
		move	a0,a
		add	b,a  #>1,x0
		sub	x0,a

		tst	a  x:heigth,x0
		jmi	strahl_vorbei

		cmp	x0,a
		jlt	h2_ok

		move	x:heigth_m1,a

h2_ok		
		move	a,x:h2
		move	a,x:prev_h2


	; -----------------------------
	; calc_text
	; -----------------------------

		clr	a  #>$00000f,x0
		move	x:line_flag_1,a0

		jclr	#3,x:flag,front_texture

	; rueckseite ist getroffen worden ...
	; line_flag_1: [23..20]

		rep	#4
		asl	a
		move	a1,x:text

		jclr	#13,x:line_flag_2,calc_text_out

	; rueckseite ist texturiert wie vorderseite ...

		bclr	#3,x:flag

		jmp	calc_text_out

front_texture

	; texturnummer vorderseite holen ...
	; line_flag_1: [19..16]

		rep	#8
		asl	a
		and	x0,a
		move	a1,x:text

calc_text_out

	; -----------------------------

		jset	#3,x:flag,text_backside

	; es ist eine textur ganz normal von vorne getroffen worden ...

	; muss die textur maskiert werden, so das entsprechende flag setzen ...
	; ebenso mit lightshading ...

		jclr	#14,x:line_flag_2,no_mask	; maskierung notwendig ?
		bset	#22,x:xyoffi
no_mask
		jclr	#15,x:line_flag_2,no_lights	; lightshading notwendig ?
		bset	#21,x:xyoffi
no_lights

	; dann die normale textur in den strahl buffer eintragen ...

		jsr	make_entry		

	; -----------------------------
	; ist unterhalb der textur auch boden, dann diesen
	; ebenfalls eintragen ...

		jclr	#10,x:line_flag_2,no_unten	; boden vorhanden ?

		move	x:prev_h1,a		
		clr	b  #>1,x0			
		sub	x0,a  b,x:h1
		jmi	no_unten

	; boden ist also nicht zu tief, um sichtbar zu sein ...

		clr	a  a,x:h2		; / neues h2 fuer boden
		move	x:point1,a0		; bodenfarbe holen ...
		rep	#8
		asl	a
		move	a1,x:text
		move	b,x:xyoffi

		bset	#23,x:xyoffi		; flag fuer boden

		jsr	make_entry

no_unten

	; -----------------------------
	; ist oberhalb der textur auch decke, dann diese
	; auch eintragen ...

		jclr	#11,x:line_flag_2,strahl_vorbei		; decke vorhanden ?

		jclr	#10,x:line_flag_2,oben_nicht_unten	; war vorher auch 
								; schon boden vorhanden ?

	; da zu dieser textur gleichzeitig boden und decke vorhanden
	; ist, kann die maximale sichtweite auf die
	; entfernung der aktuellen linie gesetzt werden kann ...

		move	x:entf,a
		move	a,x:entfernung_max


oben_nicht_unten

		move	x:prev_h2,a
		move	#>1,y0
		add	y0,a  x:heigth,x0
		cmp	x0,a  a,x:h1
		jge	strahl_vorbei

	; die decke ist nicht zu hoch, um sichtbar zu sein ...

		jclr	#12,x:line_flag_2,no_clouds

	; -----------------------------
	; es ist himmel vorhanden ...

		move	x:sky_text,b
		move	b,x:text
		move	x:heigth_m1,b
		move	b,x:h2
		lsr	b  x:sky_zoom,x0
		sub	b,a  x0,x:zoom
		move	a,x:yind

		move	x:double_x,b
		tst	b  x:koll_counter,a
		jeq	no_double_x
		lsl	a
no_double_x
		move	x:alpha,x0
		add	x0,a  x:time,b 
		add	b,a  x:sky_and_maske,y0
		and	y0,a  x:sky_xyoffi,b
		move	a,x:xind
		move	b,x:xyoffi

		jsr	make_entry

		jmp	strahl_vorbei



	; -----------------------------
	; es ist normale decke einzutragen ...

no_clouds
		clr	a
		move	x:point2,a0
		rep	#8
		asl	a
		move	a1,x:text

		clr	b  x:heigth_m1,a
		move	b,x:xyoffi
		move	a,x:h2
		
		bset	#23,x:xyoffi
		
		jsr	make_entry

strahl_vorbei
		nop
kollision_loop
		nop

		rts

; -------------------------------------

text_backside

		jclr	#10,x:line_flag_2,text_backside2

	; -----------------------------
	; die rueckseite wird zu boden ...

		move	#>$800000,x0		; bit 23 ist gesetzt
		clr	a  x0,x:xyoffi
		move	a,x:h1

		jsr	make_entry

		jmp	strahl_vorbei


text_backside2

		jclr	#11,x:line_flag_2,strahl_vorbei

	; -----------------------------
	; die rueckseite wird zu decke

		move	x:heigth_m1,x0
		clr	a  x0,x:h2
		move	a,x:xyoffi
		bset	#23,x:xyoffi	

		jsr	make_entry

		jmp	strahl_vorbei


; -------------------------------------

steile_linie
		move	x:(r5+n5),x0		;tan
		move	a,x1			;xs
		mpy	x0,x1,a  x:p_y2,b	;ys = tan(a) * xs / y2

		cmp	y1,b
		jlt	change_y_koord
		
		cmp	y1,a
		jlt	strahl_vorbei
		cmp	b,a
		jgt	strahl_vorbei

steile_normal
		btst	#1,x:flag
		jcs	steile_vertauscht_go
steile_normal_go
		move	a,b
		sub	y1,b
 
		jmp	steile_weiter

change_y_koord
		cmp	b,a
		jlt	strahl_vorbei
		cmp	y1,a  y1,y0
		jgt	strahl_vorbei
	
		move	b,y1
		move	y0,b

		btst	#1,x:flag
		jcs	steile_normal_go
steile_vertauscht_go
		sub	a,b

steile_weiter
		move	b,y0

		clr	a  #>$1,y1
		move	x:line_flag_3,a0
		rep	#8
		asl	a
		move	a1,x1
		add	y1,a
		lsl	a
		lsl	a
		sub	y1,a
		move	a1,y1
		
		mpy	y0,y1,b  x:p_dy,x0
		asr	b
		andi	#$fe,ccr
		asl	b
		rep	#24
		div	x0,b

		move	b0,a

		move	x:line_flag_1,b
		move	#>$ff00,x0
		and	x0,b
		rep	#8
		lsr	b
		move	b1,x1
		and	x1,a

		move	a,x:xind
		
		jmp	entry_vorbereiten

set_steile_flag
		bset	#0,x:flag
		rts

negiere_dy
		neg	a
		rts


; -------------------------------------

flache_linie
		cmp	y0,a  x:p_x2,x0			; x1 < xs (!) / x2
		jlt	strahl_vorbei
		cmp	x0,a				; xs < x2 (!)
		jgt	strahl_vorbei

		jclr	#1,x:flag,flache_normal		; x_punkte vertauscht ?

flache_vertauscht

		move	x:p_x2,b
		sub	a,b

		jmp	flache_weiter

flache_normal
		move	a,b
		sub	y0,b

flache_weiter
		move	b,y0
		clr	a  #>1,y1
		move	x:line_flag_3,a0
		rep	#8
		asl	a
		move	a1,x1
		add	y1,a
		lsl	a
		lsl	a
		sub	y1,a
		move	a1,y1
		
		mpy	y0,y1,b
		asr	b
		andi	#$fe,ccr
		asl	b  x:p_dx,x0
		rep	#24
		div	x0,b

		move	b0,a

		move	x:line_flag_1,b
		move	#>$ff00,x0
		and	x0,b
		rep	#8
		lsr	b
		move	b1,x1
		and	x1,a
		
		move	a,x:xind

		jmp	entry_vorbereiten


; -------------------------------------

make_entry
		clr	a
		move	a,x:stack_anz

		jsr	make_entry_now

clear_stack_loop
		move	x:stack_anz,a
		tst	a  #>1,x0
		jne	clear_stack_now

		rts

clear_stack_now
		sub	x0,a
		lsl	a  a,x:stack_anz
		lsl	a
		lsl	a  #>stack,b
		add	a,b
		move	b,r1

		nop

		move	x:(r1)+,x0
		move	x0,x:h1
		move	x:(r1)+,x0
		move	x0,x:h2
		move	x:(r1)+,x0
		move	x0,x:xind
		move	x:(r1)+,x0
		move	x0,x:yind
		move	x:(r1)+,x0
		move	x0,x:zoom
		move	x:(r1)+,x0
		move	x0,x:text
		move	x:(r1)+,x0
		move	x0,x:entf
		move	x:(r1)+,x0
		move	x0,x:xyoffi

		jsr	make_entry_now

		jmp	clear_stack_loop

;---------------		

make_entry_now
		move	#>strahl_buffer,r1
		move	x:strahl_buffer_anz,a
		move	x:strahl_buffer_free,r7

;* r1: strahl_buffer
;* r7: strahl_buffer (erster freier platz)

		tst	a  a,x:make_counter
		jeq	entry_loop

entry_loop_anf
		move	#>6,n1
		move	r1,n2
		move	x:(r1+n1),x0	;entf

		move	x:entf,a
		cmpm	x0,a  #>1,n1
		jgt	dahinter
		jlt	davor
gleich
		jset	#23,x:xyoffi,dahinter

davor
		move	x:(r1),a	;h1
		tst	a  a,x0
		jmi	entry_ready
		move	x:(r1+n1),x1	;h2
		move	x:h2,b
		cmp	x0,b  x:h1,a
		jlt	entry_ready	;keine Åberschneidung
		cmp	x1,a  #>7,n1
		jgt	entry_ready	;keine Åberschneidung

		jset 	#22,x:xyoffi,entry_ready		;maske vor etwas
		jset	#23,x:(r1+n1),text_boden_vor_boden	;etwas vor boden

		cmp	x0,a  #>1,n1
		jeq	davor_case_137
		cmp	x1,b
		jeq	davor_case_238

davor_case_4569
		cmp	x0,a
		jgt	davor_case_45
davor_case_69
		cmp	x1,b
		jgt	davor_case_3789
davor_case_16
		move	x:h2,a
		move	x:(r1),x0
		sub	x0,a  #>$3,n1
		move	#>1,x1
		move	x:(r1+n1),y0
		add	y0,a  x1,b
		add	x1,a  x:h2,x0
		add	x0,b  a,x:(r1+n1)	; new yind
		move	b,x:(r1)

		jmp	entry_ready
davor_case_45
		cmp	x1,b
		jgt	davor_case_25
davor_case_4
		move	#>$1,y0
		move	x:h2,a
		add	y0,a  x:(r1)+,x1
		move	a,x:(r7)+

		move	x:h1,a
		sub	y0,a  x:(r1),x0
		move	a,x:(r1)+

		move	x0,x:(r7)+
		move	x:(r1)+,x0
		move	x0,x:(r7)+

		move	x:h2,a
		sub	x1,a  x:(r1)+,x0
		add	x0,a  #>$1,x1
		add	x1,a  x:(r1)+,x0
		move	a,x:(r7)+	;new yind

		move	x0,x:(r7)+
		move	x:(r1)+,x0
		move	x0,x:(r7)+
		move	x:(r1)+,x0
		move	x0,x:(r7)+
		move	x:(r1)+,x0
		move	x0,x:(r7)+

		move	x:strahl_buffer_anz,a
		add	y0,a
		move	a,x:strahl_buffer_anz

		jmp	entry_ready
davor_case_137
		cmp	x1,b
		jlt	davor_case_16
davor_case_3789
		move	#>-1,x0
		move	x0,x:(r1)

		jmp	entry_ready
davor_case_238
		cmp	x0,a
		jle	davor_case_3789
davor_case_25
		move	x:h1,a
		move	#>1,x0
		sub	x0,a
		move	a,x:(r1+n1)
		
		jmp	entry_ready

;***************

text_boden_vor_boden
		
		cmp	x0,a  #>1,n1
		jeq	tbvb_case_137
		cmp	x1,b
		jeq	tbvb_case_238

tbvb_case_4569
		cmp	x0,a
		jgt	tbvb_case_45
tbvb_case_69
		cmp	x1,b
		jgt	tbvb_case_3789
tbvb_case_16
		move	x:h2,x0
		move	#>1,a
		add	x0,a
		move	a,x:(r1)

		jmp	entry_ready
tbvb_case_45
		cmp	x1,b
		jgt	tbvb_case_25
tbvb_case_4
		move	#>1,y0
		move	x:h2,a
		add	y0,a  x:(r1)+,x1
		move	a,x:(r7)+

		move	x:h1,a
		sub	y0,a  x:(r1),x0
		move	a,x:(r1)+
		move	x0,x:(r7)+
		move	x:(r1)+,x0
		move	x0,x:(r7)+
		move	x:(r1)+,x0
		move	x0,x:(r7)+
		move	x:(r1)+,x0
		move	x0,x:(r7)+
		move	x:(r1)+,x0
		move	x0,x:(r7)+
		move	x:(r1)+,x0
		move	x0,x:(r7)+
		move	x:(r1)+,x0
		move	x0,x:(r7)+

		move	x:strahl_buffer_anz,a
		add	y0,a
		move	a,x:strahl_buffer_anz

		jmp	entry_ready
tbvb_case_137
		cmp	x1,b
		jlt	tbvb_case_16
tbvb_case_3789
		move	#>-1,x0
		move	x0,x:(r1)

		jmp	entry_ready
tbvb_case_238
		cmp	x0,a
		jle	tbvb_case_3789
tbvb_case_25
		move	x:h1,a
		move	#>1,x0
		sub	x0,a
		move	a,x:(r1+n1)
		
		jmp	entry_ready

;***************

dahinter
		move	x:(r1),a	;h1
		tst	a  a,x0
		jmi	entry_ready
		move	x:(r1+n1),x1	;h2
		move	x:h2,b
		cmp	x0,b  x:h1,a
		jlt	entry_ready	;keine Åberschneidung
		cmp	x1,a  #>7,n1
		jgt	entry_ready	;keine Åberschneidung

		jset	#22,x:(r1+n1),entry_ready	;etwas hinter maske -> Åberspr.
		jset	#23,x:xyoffi,boden_hinter_textur_boden

		cmp	x0,a  #>$1,n1
		jeq	dahint_case_137
		cmp	x1,b
		jeq	dahint_case_238

dahint_case_4569
		cmp	x0,a
		jlt	dahint_case_45
dahint_case_69
		cmp	x1,b
		jle	dahint_case_3789
dahint_case_16
		move	x:(r1+n1),a
		move	x:h1,x0
		sub	x0,a  #>1,x1
		move	x:yind,y0
		add	y0,a  x1,b
		add	x1,a  x:(r1+n1),x0
		add	x0,b  a,x:yind
		move	b,x:h1

		jmp	entry_ready
dahint_case_45
		cmp	x1,b
		jle	dahint_case_25
dahint_case_4
		move	x:(r1+n1),y1	; h2 retten

		move	x:stack_anz,a	; stack erhoehen
		move	#>stack_lines_max,b
		cmp	b,a  #>1,x0
		jeq	dahintc4_out
		add	x0,a  a,b
		lsl	b  a,x:stack_anz
		lsl	b
		lsl	b  #>stack,a
		add	b,a  x:h2,y0
		tfr	y1,a  a,r1	; old h2
		add	x0,a  y1,b
		move	a,x:(r1)+	; new h1
		move	y0,x:(r1)+	; new h2
		move	x:xind,y0
		move	y0,x:(r1)+	; new xind
		add	x0,b  x:h1,y0	; +1 korrekturaddition
		sub	y0,b
		move	b,x:(r1)+	; new yind
		move	x:zoom,y0
		move	y0,x:(r1)+		
		move	x:text,y0
		move	y0,x:(r1)+		
		move	x:entf,y0
		move	y0,x:(r1)+		
		move	x:xyoffi,y0
		move	y0,x:(r1)

		; aktuell einzutragende
		; textur anpassen, dabei
		; register r1 zurueckholen ...

		move	n2,r1
dahintc4_out	move	#>1,x0
		move	x:(r1),a
		sub	x0,a
		move	a,x:h2
		
		jmp	entry_ready
dahint_case_137
		cmp	x1,b
		jgt	dahint_case_16
dahint_case_3789
		move	r7,x:strahl_buffer_free

		rts
dahint_case_238
		cmp	x0,a
		jge	dahint_case_3789
dahint_case_25
		move	x:(r1),a
		move	#>1,x0
		sub	x0,a
		move	a,x:h2

		jmp	entry_ready

;***************

boden_hinter_textur_boden

		cmp	x0,a  #>$1,n1
		jeq	bhtb_case_137
		cmp	x1,b
		jeq	bhtb_case_238

bhtb_case_4569
		cmp	x0,a
		jlt	bhtb_case_45
bhtb_case_69
		cmp	x1,b
		jle	bhtb_case_3789
bhtb_case_16
		move	x:(r1+n1),x0
		move	#>1,a
		add	x0,a
		move	a,x:h1

		jmp	entry_ready
bhtb_case_45
		cmp	x1,b
		jle	bhtb_case_25
bhtb_case_4
		move	x:(r1+n1),y1	; h2 retten

		move	x:stack_anz,a	; stack erhoehen
		move	#>stack_lines_max,b
		cmp	b,a  #>1,x0
		jeq	bhtbc4_out
		add	x0,a  a,b
		lsl	b  a,x:stack_anz
		lsl	b
		lsl	b  #>stack,a
		add	b,a  x:h2,y0
		move	a,r1
		move	y1,a		; h2
		add	x0,a
		move	a,x:(r1)+	; new h1
		move	y0,x:(r1)+	; new h2
		move	y0,x:(r1)+	; dummy (xind)
		move	y0,x:(r1)+	; dummy (yind)
		move	y0,x:(r1)+	; dummy (zoom)
		move	x:text,y0
		move	y0,x:(r1)+		
		move	x:entf,y0
		move	y0,x:(r1)+		
		move	x:xyoffi,y0
		move	y0,x:(r1)

		; aktuell einzutragende
		; textur anpassen, dabei
		; register r1 zurueckholen ...

		move	n2,r1
bhtbc4_out	move	#>1,x0
		move	x:(r1),a
		sub	x0,a
		move	a,x:h2
		
		jmp	entry_ready
bhtb_case_137
		cmp	x1,b
		jgt	bhtb_case_16
bhtb_case_3789
		move	r7,x:strahl_buffer_free

		rts
bhtb_case_238
		cmp	x0,a
		jge	bhtb_case_3789
bhtb_case_25
		move	x:(r1),a
		move	#>1,x0
		sub	x0,a
		move	a,x:h2

;***************
		
entry_ready
		move	n2,a
		move	#>8,x0
		add	x0,a  #>1,y0
		move	x:make_counter,b
		sub	y0,b  a,r1
		move	b,x:make_counter
		jne	entry_loop_anf

entry_loop
		move	x:h1,x0		;texture_endgÅltig_eintragen
		move	x0,x:(r7)+
		move	x:h2,x0
		move	x0,x:(r7)+
		move	x:xind,x0
		move	x0,x:(r7)+
		move	x:yind,x0
		move	x0,x:(r7)+
		move	x:zoom,x0
		move	x0,x:(r7)+
		move	x:text,x0
		move	x0,x:(r7)+
		move	x:entf,x0
		move	x0,x:(r7)+
		move	x:xyoffi,x0
		move	x0,x:(r7)+

		move	x:strahl_buffer_anz,a
		move	#>1,x0
		add	x0,a  r7,x:strahl_buffer_free
		move	a,x:strahl_buffer_anz


		rts

;**********************************************************

make_bild_entry
		move	x:bild_boden_pos,r7
		move	x:bild_mask_pos,r4

		move	x:strahl_buffer_anz,a
		tst	a  a,x0
		jeq	no_text_in_strahl

		move	x:heigth_m1,y1
		move	y1,x:p_x1		; Zwischenspeicher
	
		move	#>strahl_buffer,r1

		do	x0,no_text_in_strahl

		move	#>6,n1
		move	x:(r1)+,a	; h1	
		move	x:(r1+n1),x0
		move	x0,x:xyoffi

		tst	a  a,x0
		jmi	next_text

		jset	#23,x:xyoffi,make_bild_boden
		jset	#22,x:xyoffi,make_bild_mask
		
		move	x:(r1)+,a	; h2
		sub	x0,a
		jpl	mbe_t_ok
		clr	a
mbe_t_ok
		move	a,y:(r0)+	; dbra

		move	y1,a		; y1 = heigth - 1
		sub	x0,a  x:true,y0
		move	a,x1
		mpy	x1,y0,a
		asr	a
		move	a0,y:(r0)+	; yoffset

		move	x:xyoffi,a
		move	#>$00ff00,x0
		and	x0,a
		rep	#8
		lsr	a
		move	x:(r1)+,x1	; xind
		add	x1,a  #>512,x0
		move	a,x1
		mpy	x0,x1,a
		asr	a
		clr	b  x:(r1)+,x0	; yind
		nop
		move	x:(r1)+,x1	; zoom
		mpy	x0,x1,b
		rep	#7
		asl	b
		lsl	b  a0,y0
		add	y0,b  x:xyoffi,a
		move	#>$ff,y0
		and	y0,a
		lsl	a
		add	a,b

		move	x:(r1)+,y0	; text_nr
		move	#>$10000,y1
		mpy	y0,y1,a
		move	a0,a
		add	b,a
		move	a,y:(r0)+	;text_offset

		move	x:p_x1,y1
		
		move	x1,y:(r0)+	;zoom

		mpy	x0,x1,a
		asr	a  #>$ffff,x0
		move	a0,b
		and	x0,b  #>$7,x1
		move	b1,y:(r0)+	;zoom_offset

		jclr	#21,x:xyoffi,no_lightshade
		move	x:(r1)+,a	;entf

		move	#>$ffc000,x1
		and	x1,a  #>$20000,x0
		cmp	x0,a
		jlt	visible
		move	#>$1c000,a
visible		rep	#2
		lsl	a
		move	a,y:(r0)+
		jmp	ls_ok

no_lightshade	clr	a  x:(r1)+,x1
		move	a,y:(r0)+

ls_ok	
		move	x:(r1)+,x1	;dummy (xyoffi)

next_text_go_on
		nop

no_text_in_strahl
		move	#>-$1,x0
		move	x0,y:(r0)+
		move	x0,y:(r4)+
		move	x0,y:(r7)+

		move	r7,x:bild_boden_pos
		move	r4,x:bild_mask_pos

		rts

next_text
		move	r1,a1
		move	#>$7,x0
 		add	x0,a
		move	a1,r1

		jmp	next_text_go_on

;---------------

make_bild_boden
		move	x:(r1)+,a	;h2
		sub	x0,a
		jpl	mbe_b_ok
		clr	a
mbe_b_ok
		move	a,y:(r7)+	;dbra

		move	y1,a		;y1 = heigth - 1
		sub	x0,a  x:true,y0
		move	a,x1
		mpy	x1,y0,a
		asr	a
		move	a0,y:(r7)+	;yoffset

		move	#>3,x0
		move	r1,a
		add	x0,a
		move	a,r1

		nop

		move	x:(r1)+,x0	;text
		move	x0,y:(r7)+

		move	#>2,x0
		move	r1,a
		add	x0,a
		move	a,r1

		nop

		jmp	next_text_go_on

;---------------

make_bild_mask
		move	x:(r1)+,a	;h2
		sub	x0,a
		jpl	mbe_m_ok
		clr	a
mbe_m_ok
		move	a,y:(r4)+	;dbra

		move	y1,a		;y1 = heigth - 1
		sub	x0,a  x:true,y0
		move	a,x1
		mpy	x1,y0,a
		asr	a
		move	a0,y:(r4)+	;yoffset

		move	x:xyoffi,a
		move	#>$00ff00,x0
		and	x0,a  
		rep	#8
		lsr	a
		move	x:(r1)+,x1	;xind
		add	x1,a  #>512,x0
		move	a,x1
		mpy	x0,x1,a
		asr	a
		clr	b  x:(r1)+,x0	;yind
		nop
		move	x:(r1)+,x1	;zoom
		mpy	x0,x1,b
		rep	#7
		asl	b
		lsl	b  a0,y0
		add	y0,b  x:xyoffi,a
		move	#>$ff,y0
		and	y0,a
		lsl	a
		add	a,b

		move	x:(r1)+,y0
		move	#>$10000,y1
		mpy	y0,y1,a
		move	a0,a
		add	b,a
		move	a,y:(r4)+	;text_offset

		move	x:p_x1,y1

		move	x1,y:(r4)+	;zoom

		mpy	x0,x1,a
		asr	a  #>$ffff,x0
		move	a0,b
		and	x0,b  #>$7,x1
		move	b1,y:(r4)+	;zoom_offset

		jclr	#21,x:xyoffi,no_lightshade_m
		move	x:(r1)+,a	;entf
		move	#>$ffc000,x1
		and	x1,a  #>$20000,x0
		cmp	x0,a
		jlt	visible_m
		move	#>$1c000,a
visible_m	rep	#2
		lsl	a
		move	a,y:(r4)+
		jmp	ls_ok_m

no_lightshade_m	clr	a  x:(r1)+,x1
		move	a,y:(r4)+

ls_ok_m	
		move	x:(r1)+,x1	;dummy (xyoffi)

		jmp	next_text_go_on

;**********************************************************

init_system
		movep	#>$1,x:<<PBC
		bset	#2,OMR			;Data ROM Enable

		rts

;**********************************************************

cpu_read	jclr	#0,x:<<HSR,cpu_read
		movep	x:<<HRX,x1
		rts

;**********************************************************

cpu_send	jclr	#1,x:<<HSR,cpu_send
		movep	y0,x:<<HRX
		rts

;**********************************************************

reset_dsp_datas

		move	#>monst_pts_offi,x0
		clr	a  x0,x:monsters_offi
		move	a,x:monsters_anz
		move	#>points_monsters,x0
		move	x0,x:mon_pts_ptr
		move	#>monsters_lines,x0
		move	x0,x:mon_line_ptr
		move	#>monsters_breite,x0
		move	x0,x:mon_breite_ptr

		move	#>things_pts_offi,x0
		clr	a  x0,x:things_offi
		move	a,x:things_anz
		move	#>points_things,x0
		move	x0,x:things_pts_ptr
		move	#>things_lines,x0
		move	x0,x:things_line_ptr

		move	#>schalt_pts_offi,x0
		clr	a  x0,x:schalt_offi
		move	a,x:schalt_anz
		move	#>points_schalt,x0
		move	x0,x:schalt_pts_ptr
		move	#>schalt_lines,x0
		move	x0,x:schalt_line_ptr

		move	#>doors_pts_offi,x0
		clr	a  x0,x:doors_offi
		move	a,x:doors_anz
		move	#>points_doors,x0
		move	x0,x:doors_pts_ptr
		move	#>doors_lines,x0
		move	x0,x:doors_line_ptr

		rts

;**********************************************************

cpu_read_normal
		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,a
		tst	a  a,x1
		jne	extended_read

normal_read
		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,a
		rep	#int_genau
		lsl	a
		move	a,x:sx

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,a
		rep	#int_genau
		lsl	a
		move	a,x:sy

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:sh

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:alpha

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:width

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:heigth

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:double_x

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:true

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,b		; shoot

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:time

	; schussentfernung anpassen

		rep	#int_genau
		lsl	b
		move	b,x:shoot

	; heigth-werte berechnen

		move	x:heigth,a
		tfr	a,b
		lsr	a  #>1,x0
		sub	x0,b  a,x:heigth_d2
		move	b,x:heigth_m1

		
		rts

;---------------

extended_read	btst	#0,x1
		jcs	read_points_and_lines
		btst	#1,x1
		jcs	read_init_data
		btst	#2,x1
		jcs	read_tables
		btst	#3,x1
		jcs	read_one_monster
		btst	#4,x1
		jcs	read_one_schalt
		btst	#5,x1
		jcs	read_one_door

		btst	#7,x1
		jcs	read_extended_lines
		btst	#8,x1
		jcs	read_extended_points
		btst	#9,x1
		jcs	read_one_thing

		jmp	cpu_read_normal

;---------------

read_one_thing

		move	x:things_pts_ptr,r0
		move	x:things_line_ptr,r1
		move	x:things_offi,a

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,b
		rep	#int_genau
		lsl	b
		move	b,x:(r0)+
		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,b
		rep	#int_genau
		lsl	b
		move	b,x:(r0)+

		move	#>2,y0
		move	a,x:(r1)+
		add	y0,a
		move	a,x:(r1)+
		add	y0,a
		move	a,x:things_offi

		do	#3,read_t_l_loop

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:(r1)+
read_t_l_loop
				
		move	x:things_anz,a
		move	#>1,x0
		add	x0,a
		move	a,x:things_anz

		move	r0,x:things_pts_ptr
		move	r1,x:things_line_ptr

		jmp	cpu_read_normal			
				
;---------------

read_one_schalt

		move	x:schalt_pts_ptr,r0
		move	x:schalt_line_ptr,r1
		move	x:schalt_offi,a

		do	#4,ros_loop
		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,b
		rep	#int_genau
		lsl	b
		move	b,x:(r0)+
ros_loop

		move	#>2,y0
		move	a,x:(r1)+
		add	y0,a
		move	a,x:(r1)+
		add	y0,a
		move	a,x:schalt_offi

		do	#3,ros_line_loop

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:(r1)+
ros_line_loop
				
		move	x:schalt_anz,a
		move	#>1,x0
		add	x0,a  r0,x:schalt_pts_ptr
		move	a,x:schalt_anz
		move	r1,x:schalt_line_ptr

		jmp	cpu_read_normal			
				
;---------------

read_one_door

		move	x:doors_pts_ptr,r0
		move	x:doors_line_ptr,r1
		move	x:doors_offi,y0

		do	#8,door_read_pts

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,a
		rep	#int_genau
		lsl	a
		move	a,x:(r0)+
door_read_pts

		do	#4,door_lpts_loop

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,a
		add	y0,a
		move	a,x:(r1)+
		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,a
		add	y0,a
		move	a,x:(r1)+

		do	#3,door_read_line

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:(r1)+
door_read_line
		nop
door_lpts_loop

		move	#>8,a
		add	y0,a
		move	a,x:doors_offi

		move	x:doors_anz,a
		move	#>1,x0
		add	x0,a
		move	a,x:doors_anz

		move	r0,x:doors_pts_ptr
		move	r1,x:doors_line_ptr

		jmp	cpu_read_normal			
				
;---------------

read_init_data

		jsr	cpu_read
		move	x1,x:sky_zoom
		jsr	cpu_read
		move	x1,x:sky_xyoffi
		jsr	cpu_read
		move	x1,x:sky_text
		jsr	cpu_read
		move	x1,x:sky_and_maske

		jsr	cpu_read
		move	x1,x:sht_line_1
		jsr	cpu_read
		move	x1,x:sht_line_3
		jsr	cpu_read
		move	x1,x:sht_line_3+1
		jsr	cpu_read
		move	x1,x:sht_line_3+2
		jsr	cpu_read
		move	x1,x:sht_line_3+3
		
		jmp	cpu_read_normal

;---------------

read_one_monster

		move	x:mon_pts_ptr,r0
		move	x:mon_line_ptr,r1
		move	x:mon_breite_ptr,r2
		move	x:monsters_offi,a

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,b
		rep	#int_genau
		lsl	b
		move	b,x:(r0)+
		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,b
		rep	#int_genau
		lsl	b
		move	b,x:(r0)+

		move	#>2,y0
		move	a,x:(r1)+
		add	y0,a
		move	a,x:(r1)+
		add	y0,a
		move	a,x:monsters_offi

		do	#3,read_m_l_loop
		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:(r1)+
read_m_l_loop

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:(r2)+		; monsters_breite
				
		move	x:monsters_anz,a
		move	#>1,x0
		add	x0,a
		move	a,x:monsters_anz

		move	r0,x:mon_pts_ptr
		move	r1,x:mon_line_ptr
		move	r2,x:mon_breite_ptr

		jmp	cpu_read_normal			
				
;---------------

read_tables
		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,a
		rep	#int_genau
		lsl	a
		move	a,x:per

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	#>winkel_320_tab,r0

		move	x1,y0

		do	y0,read_winkel_320_tab

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:(r0)+

read_winkel_320_tab

		move	#>tangens_tab,r0

		do	y0,read_tangens_tab

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:(r0)+

read_tangens_tab

		nop

		jmp	cpu_read_normal

;---------------

read_points_and_lines

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:points_anz

		move	x1,a
		lsl	a
		move	a,x1

		move	#>points,r0

		do	x1,read_points_loop

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,a
		rep	#int_genau
		lsl	a
		move	a,x:(r0)+
read_points_loop

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:lines_anz

		move	x1,a
		lsl	a
		lsl	a
		add	x1,a
		move	a,x1

		move	#>lines,r0

		do	x1,read_lines_loop

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:(r0)+
read_lines_loop

		jmp	cpu_read_normal

;---------------

read_extended_lines

		move	x:lines_anz,a
		
		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		add	x1,a  a,b
		move	a,x:lines_anz

		move	x1,a
		lsl	a
		lsl	a
		add	x1,a
		move	a,x1

		move	#>lines,r0
		lsl	b  b,x0
		lsl	b
		add	x0,b
		move	r0,a
		add	b,a
		move	a,r0

		do	x1,read_exlin_loop

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x1,x:(r0)+
read_exlin_loop

		jmp	cpu_read_normal

;---------------

read_extended_points

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x1
		move	x:points_anz,a
		add	x1,a  a,b
		move	a,x:points_anz

		move	x1,a
		lsl	a
		move	a,x1

		move	#>points,a
		lsl	b
		add	b,a
		move	a,r0

		do	x1,read_ext_points_l

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,a
		rep	#int_genau
		lsl	a
		move	a,x:(r0)+
read_ext_points_l
		
		jmp	cpu_read_normal


;**********************************************************

cpu_send_info
		move	x:min_entf,a
		rep	#int_genau
		lsr	a
		move	a,y0
		jsr	cpu_send

		move	x:masked_anz,y0
		jsr	cpu_send
		rts

;---------------

cpu_send_new_info
		move	x:monsters_anz,y0
		jsr	cpu_send
		
		move	y0,a
		tst	a
		jeq	no_sending

		move 	#>monsters_flags,r7
		
		do 	y0,no_sending

		move	x:(r7)+,y0
		jsr	cpu_send

		nop

no_sending
		nop

		rts

;**********************************************************

cpu_send_bild
		move	r0,a
		move	#>bild,x0
		sub	x0,a  #>b_text_max,x1
		cmp	x1,a  a,y0
		jgt	bild_error		

		jsr	cpu_send
		
		move	#>bild,r0

		do	y0,send_bytes
		move	y:(r0)+,y0
send_wait	jclr	#1,x:<<HSR,send_wait
		movep	y0,x:<<HRX
send_bytes
		
		move	#>bild_boden,x0
		move	x:bild_boden_pos,a
		sub	x0,a  x0,r0
		move	#>b_boden_max,x1
		cmp	x1,a  a,y0
		jgt	bild_error		

		jsr	cpu_send

		do	y0,send_bytes_b
		move	y:(r0)+,y0
send_wait_b	jclr	#1,x:<<HSR,send_wait_b
		movep	y0,x:<<HRX
send_bytes_b

		move	#>bild_mask,x0
		move	x:bild_mask_pos,a
		sub	x0,a  x0,r0
		move	#>b_mask_max,x1
		cmp	x1,a  a,y0
		jgt	bild_error

		jsr	cpu_send

		do	y0,send_bytes_m
		move	y:(r0)+,y0
send_wait_m	jclr	#1,x:<<HSR,send_wait_m
		movep	y0,x:<<HRX
send_bytes_m

		nop

		rts

;--------

bild_error
		move	#>-$1,y0
		jsr	cpu_send

		nop

		rts

programm_end_adress

;**********************************************************


;**********************************************************
;***
;***		X-Speicher
;***
;**********************************************************

;*** $100 - $1ff ist fÅr Tangens-Tabelle reserviert ...

		org	x:$0

width		dc	16
heigth		dc	10
heigth_d2	dc	0
heigth_m1	dc	0

sx		dc	$543	;Standort (x,y,Hîhe,Sichtwinkel)
sy		dc	$23d
sh		dc	$130
alpha		dc	$be

per		dc	44234	;Skalierungsfaktor Y-Richtung
double_x	dc	0	;Flag fÅr Double-Pix
true		dc	0
shoot		dc	0

one_mon_hit	dc	0
mon_line_flag	dc	0

koll_counter	dc	0
make_counter	dc	0

p_x1		dc	0	;Zwischenspeicher
p_x2		dc	0
p_y1		dc	0
p_y2		dc	0
p_dx		dc	0
p_dy		dc	0

c_heigth	dc	0

prev_h1		dc	0
prev_h2		dc	0

h1		dc	0	;fuer make_entry
h2		dc	0
xind		dc	0
yind		dc	0
zoom		dc	0
text		dc	0
entf		dc	0
xyoffi		dc	0

flag		dc	0

points_anz	dc	4
lines_anz	dc	4
calc_l_i_anz	dc	0
calc_l_ii_anz	dc	0

point1		dc	0		;fuer part_kollision
point2		dc	0		;(Zwischenspeicher)
line_flag_1	dc	0
line_flag_2	dc	0
line_flag_3	dc	0

strahl_buffer_free	dc	0	;fuer make_entry
strahl_buffer_anz	dc	0	

bild_boden_pos	dc	0		;wie zwei zusaetzliche
bild_mask_pos	dc	0		;Adreûregister ...

monsters_anz	dc	0
monsters_offi	dc	0
mon_pts_ptr	dc	0
mon_line_ptr	dc	0
mon_breite_ptr	dc	0

min_entf	dc	0

doors_anz	dc	0
doors_offi	dc	0
doors_pts_ptr 	dc	0
doors_line_ptr	dc	0

schalt_anz	dc	0
schalt_offi	dc	0
schalt_pts_ptr 	dc	0
schalt_line_ptr	dc	0

things_anz	dc	0
things_offi	dc	0
things_pts_ptr	dc	0
things_line_ptr	dc	0

masked_anz	dc	0
sort_i		dc	0
sort_j		dc	0
sort_wert	dc	0

sky_zoom	dc	0
sky_xyoffi	dc	0
sky_text	dc	0
sky_and_maske	dc	0

sht_line_1	dc	0
sht_line_3	dc	0,0,0,0
sht_anim_pos	dc	0

time		dc	0

entfernung_max	dc	0


		org	x:$200

points		ds	points_max*2
points_monsters	ds	monsters_max*2
points_doors	ds	doors_max*16
points_things	ds	things_max*2
points_schalt	ds	schalt_max*4

;	line_flag_1:  23..16 15..8 7..0

;		 7...0:	h1 (0..255)
;		15...8:	text_and_maske (0..255)
;		19..16:	texture_nr_front (0..15) (texturnummer vorderseite)
;		23..29: texture_nr_back (0..15) (texturnummer rueckseite)			

;	line_flag_2:  23..16 15..8 7..0

;		 7...0: h2 (0..255)
;		     8: visi_front (1 = vorderseite sichtbar)
;		     9: visi_back (1 = rueckseite sichtbar)
;		    10: oben_decke (1 = true)
;		    11: unten_decke (1 = true)
;		    12: decke_ist_himmel (1 = true)
;		    13: backside ist normale textur (1 = true)
;		    14:	masked_texture (1 = textur muû maskiert werden)
;			(z.b. monster, gegner, gitterstÑbe ...)
;		    15: lightshading on/off
;		23..16: normw (0..255)

;	line_flag_3:  23..16 15..8 7..0

;		 7...0: x_offset (0..255) 
;		15...8: y_offset (0..255) 
;		23..16: text_width (0..255) Faktor 4 (d.h. $01 = 4)

lines		ds	lines_max*5
monsters_lines	ds	monsters_max*5
doors_lines	ds	doors_max*20
things_lines	ds	things_max*5
schalt_lines	ds	schalt_max*5

calc_points	ds	points_max*2
calc_points_m	ds	monsters_max*2
calc_points_mm	ds	monsters_max*4
calc_points_d	ds	doors_max*16
calc_points_g	ds	things_max*2
calc_points_gg	ds	things_max*4
calc_points_s	ds	schalt_max*4

calc_lines_i	ds	lines_max*5
		ds	monsters_max*5
		ds	doors_max*20
		ds	things_max*5
		ds	schalt_max*5
calc_lines_ii	ds	lines_max*5
		ds	monsters_max*5
		ds	doors_max*20
		ds	things_max*5
		ds	schalt_max*5

winkel_320_tab	ds	320
tangens_tab	ds	320

monsters_breite ds	monsters_max
monsters_flags	ds	monsters_max

stack_anz	dc	0
stack_max	dc	stack_lines_max
stack		ds	stack_lines_max*8

reg_retten
strahl_buffer	ds	60*8


;**********************************************************
;***
;***		Y-Speicher
;***
;**********************************************************

;*** Take care: der Y-Speicher muû um die Groesse des
;*** Programmspeichers erhoeht werden ...
;*** $100 - $1ff ist fuer Sinus-Tabelle reserviert ...

		org	y:$c90

bild		ds	b_text_max
bild_boden	ds	b_boden_max
bild_mask	ds	b_mask_max



		end
