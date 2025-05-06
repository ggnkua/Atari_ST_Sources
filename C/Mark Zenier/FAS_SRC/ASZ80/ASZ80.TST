	cpu "64180"
disp	equ 43
immed	equ 77
immed16 equ 987
	adc a, (hl)
	adc a, (ix+disp)
	adc a, (iy+disp)
	adc a, a
	adc a, b
	adc a, c
	adc a, d
	adc a, e
	adc a, h
	adc a, immed
	adc a, l
	adc hl, bc
	adc hl, de
	adc hl, hl
	adc hl, sp
	add a, (hl)
	add a, (ix+disp)
	add a, (iy+disp)
	add a, a
	add a, b
	add a, c
	add a, d
	add a, e
	add a, h
	add a, immed
	add a, l
	add hl, bc
	add hl, de
	add hl, hl
	add hl, sp
	add ix, bc
	add ix, de
	add ix, ix
	add ix, sp
	add iy, bc
	add iy, de
	add iy, iy
	add iy, sp
	and (hl)
	and (ix+disp)
	and (iy+disp)
	and a
	and b
	and c
	and d
	and e
	and h
	and immed
	and l
	bit 0, (hl)
	bit 0, (ix+disp)
	bit 0, (iy+disp)
	bit 0, a
	bit 0, b
	bit 0, c
	bit 0, d
	bit 0, e
	bit 0, h
	bit 0, l
	bit 1, (hl)
	bit 1, (ix+disp)
	bit 1, (iy+disp)
	bit 1, a
	bit 1, b
	bit 1, c
	bit 1, d
	bit 1, e
	bit 1, h
	bit 1, l
	bit 2, (hl)
	bit 2, (ix+disp)
	bit 2, (iy+disp)
	bit 2, a
	bit 2, b
	bit 2, c
	bit 2, d
	bit 2, e
	bit 2, h
	bit 2, l
	bit 3, (hl)
	bit 3, (ix+disp)
	bit 3, (iy+disp)
	bit 3, a
	bit 3, b
	bit 3, c
	bit 3, d
	bit 3, e
	bit 3, h
	bit 3, l
	bit 4, (hl)
	bit 4, (ix+disp)
	bit 4, (iy+disp)
	bit 4, a
	bit 4, b
	bit 4, c
	bit 4, d
	bit 4, e
	bit 4, h
	bit 4, l
	bit 5, (hl)
	bit 5, (ix+disp)
	bit 5, (iy+disp)
	bit 5, a
	bit 5, b
	bit 5, c
	bit 5, d
	bit 5, e
	bit 5, h
	bit 5, l
	bit 6, (hl)
	bit 6, (ix+disp)
	bit 6, (iy+disp)
	bit 6, a
	bit 6, b
	bit 6, c
	bit 6, d
	bit 6, e
	bit 6, h
	bit 6, l
	bit 7, (hl)
	bit 7, (ix+disp)
	bit 7, (iy+disp)
	bit 7, a
	bit 7, b
	bit 7, c
	bit 7, d
	bit 7, e
	bit 7, h
	bit 7, l
	call addr
	call c, addr
	call m, addr
	call nc, addr
addr	 call nz, addr
	call p, addr
	call pe, addr
	call po, addr
	call z, addr
	ccf
	cp (hl)
	cp (ix+disp)
	cp (iy+disp)
	cp a
	cp b
	cp c
	cp d
	cp e
	cp h
	cp immed
	cp l
	cpd
	cpdr
	cpi
	cpir
	cpl
	daa
	dec (hl)
	dec (ix+disp)
	dec (iy+disp)
	dec a
	dec b
	dec bc
	dec c
	dec d
	dec de
	dec e
	dec h
	dec hl
	dec ix
addrd	 dec iy
	dec l
	dec sp
	di
	djnz addrd
	ei
	ex ( sp ) , hl
	ex ( sp ) , ix
	ex ( sp ) , iy
	ex af, af
	ex de, hl
	exx
	halt
	im 0
	im 1
	im 2
	in a, ( c )
	in a, ( immed )
	in b, ( c )
	in c, ( c )
	in d, ( c )
	in e, ( c )
	in h, ( c )
	in l, ( c )
	in0 a, ( immed )
	in0 b, ( immed )
	in0 c, ( immed )
	in0 d, ( immed )
	in0 e, ( immed )
	in0 h, ( immed )
	in0 l, ( immed )
	inc (hl)
	inc (ix+disp)
	inc (iy+disp)
	inc a
	inc b
	inc bc
	inc c
	inc d
	inc de
	inc e
	inc h
	inc hl
	inc ix
	inc iy
	inc l
	inc sp
	ind
	indr
	ini
	inir
	jp ( hl )
	jp ( ix )
	jp ( iy )
	jp addrj
	jp c, addrj
	jp m, addrj
	jp nc, addrj
	jp nz, addrj
	jp p, addrj
addrj	 jp pe, addrj
	jp po, addrj
	jp z, addrj
	jr addrj
	jr c, addrj
	jr nc, addrj
	jr nz, addrj
	jr z, addrj
	ld ( addr ) , a
	ld ( addr ) , bc
	ld ( addr ) , de
	ld ( addr ) , hl
	ld ( addr ) , hl
	ld ( addr ) , ix
	ld ( addr ) , iy
	ld ( addr ) , sp
	ld ( bc ) , a
	ld ( de ) , a
	ld (hl), a
	ld (hl), b
	ld (hl), c
	ld (hl), d
	ld (hl), e
	ld (hl), h
	ld (hl), immed
	ld (hl), l
	ld (ix+disp), a
	ld (ix+disp), b
	ld (ix+disp), c
	ld (ix+disp), d
	ld (ix+disp), e
	ld (ix+disp), h
	ld (ix+disp), immed
	ld (ix+disp), l
	ld (iy+disp), a
	ld (iy+disp), b
	ld (iy+disp), c
	ld (iy+disp), d
	ld (iy+disp), e
	ld (iy+disp), h
	ld (iy+disp), immed
	ld (iy+disp), l
	ld a, ( addr )
	ld a, ( bc )
	ld a, ( de )
	ld a, (hl)
	ld a, (ix+disp)
	ld a, (iy+disp)
	ld a, a
	ld a, b
	ld a, c
	ld a, d
	ld a, e
	ld a, h
	ld a, i
	ld a, immed
	ld a, l
	ld a, r
	ld b, (hl)
	ld b, (ix+disp)
	ld b, (iy+disp)
	ld b, a
	ld b, b
	ld b, c
	ld b, d
	ld b, e
	ld b, h
	ld b, immed
	ld b, l
	ld bc, ( addr )
	ld bc, immed16
	ld c, (hl)
	ld c, (ix+disp)
	ld c, (iy+disp)
	ld c, a
	ld c, b
	ld c, c
	ld c, d
	ld c, e
	ld c, h
	ld c, immed
	ld c, l
	ld d, (hl)
	ld d, (ix+disp)
	ld d, (iy+disp)
	ld d, a
	ld d, b
	ld d, c
	ld d, d
	ld d, e
	ld d, h
	ld d, immed
	ld d, l
	ld de, ( addr )
	ld de, immed16
	ld e, (hl)
	ld e, (ix+disp)
	ld e, (iy+disp)
	ld e, a
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, h
	ld e, immed
	ld e, l
	ld h, (hl)
	ld h, (ix+disp)
	ld h, (iy+disp)
	ld h, a
	ld h, b
	ld h, c
	ld h, d
	ld h, e
	ld h, h
	ld h, immed
	ld h, l
	ld hl, ( addr )
	ld hl, ( addr )
	ld hl, immed16
	ld hl, immed16
	ld i, a
	ld ix, ( addr )
	ld ix, immed16
	ld iy, ( addr )
	ld iy, immed16
	ld l, (hl)
	ld l, (ix+disp)
	ld l, (iy+disp)
	ld l, a
	ld l, b
	ld l, c
	ld l, d
	ld l, e
	ld l, h
	ld l, immed
	ld l, l
	ld r, a
	ld sp, ( addr )
	ld sp, hl
	ld sp, immed16
	ld sp, ix
	ld sp, iy
	ldd
	lddr
	ldi
	ldir
	mult bc
	mult de
	mult hl
	mult sp
	neg
	nop
	or (hl)
	or (ix+disp)
	or (iy+disp)
	or a
	or b
	or c
	or d
	or e
	or h
	or immed
	or l
	otdm
	otdmr
	otdr
	otim
	otimr
	otir
	out ( c ) , a
	out ( c ) , b
	out ( c ) , c
	out ( c ) , d
	out ( c ) , e
	out ( c ) , h
	out ( c ) , l
	out ( immed ) , a
	out0 ( immed ) , a
	out0 ( immed ) , b
	out0 ( immed ) , c
	out0 ( immed ) , d
	out0 ( immed ) , e
	out0 ( immed ) , h
	out0 ( immed ) , l
	outd
	outi
	pop af
	pop bc
	pop de
	pop hl
	pop ix
	pop iy
	push af
	push bc
	push de
	push hl
	push ix
	push iy
	res 0, (hl)
	res 0, (ix+disp)
	res 0, (iy+disp)
	res 0, a
	res 0, b
	res 0, c
	res 0, d
	res 0, e
	res 0, h
	res 0, l
	res 1, (hl)
	res 1, (ix+disp)
	res 1, (iy+disp)
	res 1, a
	res 1, b
	res 1, c
	res 1, d
	res 1, e
	res 1, h
	res 1, l
	res 2, (hl)
	res 2, (ix+disp)
	res 2, (iy+disp)
	res 2, a
	res 2, b
	res 2, c
	res 2, d
	res 2, e
	res 2, h
	res 2, l
	res 3, (hl)
	res 3, (ix+disp)
	res 3, (iy+disp)
	res 3, a
	res 3, b
	res 3, c
	res 3, d
	res 3, e
	res 3, h
	res 3, l
	res 4, (hl)
	res 4, (ix+disp)
	res 4, (iy+disp)
	res 4, a
	res 4, b
	res 4, c
	res 4, d
	res 4, e
	res 4, h
	res 4, l
	res 5, (hl)
	res 5, (ix+disp)
	res 5, (iy+disp)
	res 5, a
	res 5, b
	res 5, c
	res 5, d
	res 5, e
	res 5, h
	res 5, l
	res 6, (hl)
	res 6, (ix+disp)
	res 6, (iy+disp)
	res 6, a
	res 6, b
	res 6, c
	res 6, d
	res 6, e
	res 6, h
	res 6, l
	res 7, (hl)
	res 7, (ix+disp)
	res 7, (iy+disp)
	res 7, a
	res 7, b
	res 7, c
	res 7, d
	res 7, e
	res 7, h
	res 7, l
	ret
	ret c
	ret m
	ret nc
	ret nz
	ret p
	ret pe
	ret po
	ret z
	reti
	retn
	rl (hl)
	rl (ix+disp)
	rl (iy+disp)
	rl a
	rl b
	rl c
	rl d
	rl e
	rl h
	rl l
	rla
	rlc (hl)
	rlc (ix+disp)
	rlc (iy+disp)
	rlc a
	rlc b
	rlc c
	rlc d
	rlc e
	rlc h
	rlc l
	rlca
	rld
	rr (hl)
	rr (ix+disp)
	rr (iy+disp)
	rr a
	rr b
	rr c
	rr d
	rr e
	rr h
	rr l
	rra
	rrc (hl)
	rrc (ix+disp)
	rrc (iy+disp)
	rrc a
	rrc b
	rrc c
	rrc d
	rrc e
	rrc h
	rrc l
	rrca
	rrd
	rst 0
	rst 16
	rst 24
	rst 32
	rst 40
	rst 48
	rst 56
	rst 8
	sbc a, (hl)
	sbc a, (ix+disp)
	sbc a, (iy+disp)
	sbc a, a
	sbc a, b
	sbc a, c
	sbc a, d
	sbc a, e
	sbc a, h
	sbc a, immed
	sbc a, l
	sbc hl, bc
	sbc hl, de
	sbc hl, hl
	sbc hl, sp
	scf
	set 0, (hl)
	set 0, (ix+disp)
	set 0, (iy+disp)
	set 0, a
	set 0, b
	set 0, c
	set 0, d
	set 0, e
	set 0, h
	set 0, l
	set 1, (hl)
	set 1, (ix+disp)
	set 1, (iy+disp)
	set 1, a
	set 1, b
	set 1, c
	set 1, d
	set 1, e
	set 1, h
	set 1, l
	set 2, (hl)
	set 2, (ix+disp)
	set 2, (iy+disp)
	set 2, a
	set 2, b
	set 2, c
	set 2, d
	set 2, e
	set 2, h
	set 2, l
	set 3, (hl)
	set 3, (ix+disp)
	set 3, (iy+disp)
	set 3, a
	set 3, b
	set 3, c
	set 3, d
	set 3, e
	set 3, h
	set 3, l
	set 4, (hl)
	set 4, (ix+disp)
	set 4, (iy+disp)
	set 4, a
	set 4, b
	set 4, c
	set 4, d
	set 4, e
	set 4, h
	set 4, l
	set 5, (hl)
	set 5, (ix+disp)
	set 5, (iy+disp)
	set 5, a
	set 5, b
	set 5, c
	set 5, d
	set 5, e
	set 5, h
	set 5, l
	set 6, (hl)
	set 6, (ix+disp)
	set 6, (iy+disp)
	set 6, a
	set 6, b
	set 6, c
	set 6, d
	set 6, e
	set 6, h
	set 6, l
	set 7, (hl)
	set 7, (ix+disp)
	set 7, (iy+disp)
	set 7, a
	set 7, b
	set 7, c
	set 7, d
	set 7, e
	set 7, h
	set 7, l
	sla (hl)
	sla (ix+disp)
	sla (iy+disp)
	sla a
	sla b
	sla c
	sla d
	sla e
	sla h
	sla l
	slp
	sra (hl)
	sra (ix+disp)
	sra (iy+disp)
	sra a
	sra b
	sra c
	sra d
	sra e
	sra h
	sra l
	srl (hl)
	srl (ix+disp)
	srl (iy+disp)
	srl a
	srl b
	srl c
	srl d
	srl e
	srl h
	srl l
	sub (hl)
	sub (ix+disp)
	sub (iy+disp)
	sub a
	sub b
	sub c
	sub d
	sub e
	sub h
	sub immed
	sub l
	tst ( hl )
	tst a
	tst b
	tst c
	tst d
	tst e
	tst h
	tst immed
	tst l
	tstio immed
	xor (hl)
	xor (ix+disp)
	xor (iy+disp)
	xor a
	xor b
	xor c
	xor d
	xor e
	xor h
	xor immed
	xor l
