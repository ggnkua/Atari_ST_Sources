
		comment HEAD=-1		;tell gbe to strip prg header
		opt	p=68000		;processor type
		opt	c+		;case matters
		opt	o+		;optimize all
		opt	chkpc		;force position independent
		output	nf_call.inl

		text

start:		dc.w	$7301
		rts

		end
