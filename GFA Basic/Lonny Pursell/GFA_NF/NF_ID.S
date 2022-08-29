
		comment HEAD=-1		;tell gbe to strip prg header
		opt	p=68000		;processor type
		opt	c+		;case matters
		opt	o+		;optimize all
		opt	chkpc		;force position independent
		output	nf_id.inl

		text

start:		dc.w	$7300
		rts

		end
