
	opt	l+,c+
	include library.h

	library CDLIB	* if this fails to assemble (to CDLIB.BIN)

	xref	get_string
	xref	get_array
	xref	make_string
	xref.l	gl_scratch
									* then maybe load library.h and search and replace all
	xdef	WORDCH
	subdef	lng,lng
								* ",\A,\B,\C" with "" then maybe save library.h and re-assemble?

	inl_sub	CDINIT,14,48,lng
	inl_lng	CDOPEN,14,49,int,lng
	inl_lng	CDCLOSE,14,50,int
	inl_lng	CDREAD,14,51,int,lng,lng,int
	inl_lng	CDWRITE,14,52,int,lng,lng,int * CDSEEK=53 unknown parameters?
	inl_lng	CDSTATUS,14,54,int,lng
	inl_lng	CDIOCTL,14,55,int,lng,int,lng * CDreadaudio=58 unknown parameters?
	inl_lng	CDSTARTAUDIO,14,59,int,int,lng
	inl_lng	CDSTOPAUDIO,14,60,int
	inl_lng	CDSETSONGTIME,14,61,int,int,lng,lng
	inl_lng	CDGETTOC,14,62,int,int,lng
	inl_lng	CDDISCINFO,14,63,int,lng
	inl_int	WAVEPLAY,14,165,int,lng,lng,lng


	option	'uv'
	libstart

WORDCH	move.l	4(sp),a1	the first address not to be word swapped
	move.l	8(sp),a0	first address to be word swapped

loop	cmpa.l	a0,a1		if finished...
	ble	done		...then exit.

	move.b	(a0),d0		swap upper-lower bytes in a word
	move.b	1(a0),d1	I'm not sure if this is the most
	move.b	d0,1(a0)	efficient way of doing this but
	move.b	d1,(a0)		hopefully would be faster than BASIC!

	adda.l	#2,a0		next word in the memory we are processing
	bra	loop		repeat it
done	rts			if done then exit back to HBASIC


