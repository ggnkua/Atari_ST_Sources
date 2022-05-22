;
; 3 separate pack routines, making it a LOAD faster!
;

	pea	source(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
	
	
	lea	source(pc),a0
	lea	dest(pc),a1
	lea	four(pc),a2
	
nextel4:move.b	(a2)+,d0
	beq.s	endlist4
	move.b	(a2)+,d1
	move.b	(a2)+,d2
	move.b	(a2)+,d3
	move.b	(a2)+,d4

contpack4:
	cmp.b	(a0),d0
	bne.s	copy14
	cmp.b	1(a0),d1
	bne.s	copy24
	cmp.b	2(a0),d2
	bne.s	copy34
	cmp.b	3(a0),d3
	bne.s	copy44
	lea	4(a0),a0
	move.b	d4,(a1)+
	bra.s	contpack4
	
copy14:	move.b	(a0)+,(a1)+
	beq.s	endpack4
	bra.s	contpack4
	
copy24:	move.b	(a0)+,(a1)+
	beq.s	endpack4
	move.b	(a0)+,(a1)+
	beq.s	endpack4
	bra.s	contpack4
	
copy34:	move.b	(a0)+,(a1)+
	beq.s	endpack4
	move.b	(a0)+,(a1)+
	beq.s	endpack4
	move.b	(a0)+,(a1)+
	beq.s	endpack4
	bra.s	contpack4

copy44:	move.b	(a0)+,(a1)+
	beq.s	endpack4
	move.b	(a0)+,(a1)+
	beq.s	endpack4
	move.b	(a0)+,(a1)+
	beq.s	endpack4
	move.b	(a0)+,(a1)+
	beq.s	endpack4
	bra.s	contpack4
	
endpack4:
	lea	dest(pc),a0
	move.l	a0,a1
	bra.s	nextel4
endlist4:


	lea	three(pc),a2
	
nextel3:move.b	(a2)+,d0
	beq.s	endlist3
	move.b	(a2)+,d1
	move.b	(a2)+,d2
	move.b	(a2)+,d3

contpack3:
	cmp.b	(a0),d0
	bne.s	copy13
	cmp.b	1(a0),d1
	bne.s	copy23
	cmp.b	2(a0),d2
	bne.s	copy33
	lea	3(a0),a0
	move.b	d3,(a1)+
	bra.s	contpack3
	
copy13:	move.b	(a0)+,(a1)+
	beq.s	endpack3
	bra.s	contpack3
	
copy23:	move.b	(a0)+,(a1)+
	beq.s	endpack3
	move.b	(a0)+,(a1)+
	beq.s	endpack3
	bra.s	contpack3
	
copy33:	move.b	(a0)+,(a1)+
	beq.s	endpack3
	move.b	(a0)+,(a1)+
	beq.s	endpack3
	move.b	(a0)+,(a1)+
	beq.s	endpack3
	bra.s	contpack3

endpack3:
	lea	dest(pc),a0
	move.l	a0,a1
	bra.s	nextel3
endlist3:


	lea	two(pc),a2
	
nextel2:move.b	(a2)+,d0
	beq.s	endlist2
	move.b	(a2)+,d1
	move.b	(a2)+,d2

contpack2:
	cmp.b	(a0),d0
	bne.s	copy12
	cmp.b	1(a0),d1
	bne.s	copy22
	lea	2(a0),a0
	move.b	d2,(a1)+
	bra.s	contpack2
	
copy12:	move.b	(a0)+,(a1)+
	beq.s	endpack2
	bra.s	contpack2
	
copy22:	move.b	(a0)+,(a1)+
	beq.s	endpack2
	move.b	(a0)+,(a1)+
	beq.s	endpack2
	bra.s	contpack2
	
endpack2:
	lea	dest(pc),a0
	move.l	a0,a1
	bra.s	nextel2
endlist2:

	pea	dest(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
	
	
	lea	dest(pc),a0
	lea	dest2(pc),a1
	
recheck:move.b	(a0)+,d0
	beq.s	fncheck
	cmpi.b	#127,d0
	bge.s	tnormal
	lea	four(pc),a2
fcheck4:tst.b	(a2)
	beq.s	endfr4
	cmp.b	4(a2),d0
	bne.s	nxtfr4
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	bra.s	recheck
nxtfr4:	lea	5(a2),a2
	bra.s	fcheck4
endfr4:

	lea	three(pc),a2
fcheck3:tst.b	(a2)
	beq.s	endfr3
	cmp.b	3(a2),d0
	bne.s	nxtfr3
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	bra.s	recheck
nxtfr3:	lea	4(a2),a2
	bra.s	fcheck3
endfr3:

	lea	two(pc),a2
fcheck2:tst.b	(a2)
	beq.s	endfr2
	cmp.b	2(a2),d0
	bne.s	nxtfr2
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	bra.s	recheck
nxtfr2:	lea	3(a2),a2
	bra.s	fcheck2
endfr2:
	
tnormal:
	move.b	d0,(a1)+
	bra.s	recheck
fncheck:	

	
	pea	dest2(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
	
	
	move.w	#1,-(sp)
	trap	#1
	addq.w	#2,sp
	
	clr.w	-(sp)
	trap	#1


source:	dc.b	$d,'help and me you bastard...  Caan! ',$a,$a,$d,0

dest:	ds.b	2048

dest2:	ds.b	2048

four:	dc.b	'help',128
	dc.b	'look',129
	dc.b	'give',130
	dc.b	'take',131
	dc.b	'pick',132
	dc.b	'you ',133
	dc.b	'thin',134
	dc.b	'with',135
	dc.b	'each',136
	dc.b	'hell',137
	dc.b	'scum',138
	dc.b	'work',139
	dc.b	'miss',140
	dc.b	'shit',141
	dc.b	'him ',142
	dc.b	'righ',143
	dc.b	'left',144
	dc.b	'well',145
	dc.b	'and ',146
	dc.b	0
	
three:	
	dc.b	'yes',147
	dc.b	'no ',148
	dc.b	'can',149
	dc.b	'loo',150
	dc.b	'how',151
	dc.b	'hen',152
	dc.b	'gri',153
	dc.b	'gir',154
	dc.b	'cho',155
	dc.b	'thr',156
	dc.b	'tho',157
	dc.b	'tha',158
	dc.b	'rec',159
	dc.b	'has',160
	dc.b	'com',161
	dc.b	'ent',162
	dc.b	'are',163
	dc.b	'amp',164
	dc.b	'the',165
	dc.b	'omm',166
	dc.b	'ner',167
	dc.b	'nal',168
	dc.b	0
	
two:	
	dc.b	'me',169
	dc.b	'. ',170
	dc.b	', ',171
	dc.b	'! ',172
	dc.b	'? ',173
	dc.b	'an',174
	dc.b	'ar',175
	dc.b	'is',176
	dc.b	'it',177
	dc.b	'mo',178
	dc.b	'ca',179
	dc.b	'ed',180
	dc.b	'il',181
	dc.b	'el',182
	dc.b	'vi',183
	dc.b	'ab',184
	dc.b	'st',185
	dc.b	'th',186
	dc.b	'pl',187
	dc.b	'so',188
	dc.b	'us',189
	dc.b	're',190
	dc.b	'ea',191
	dc.b	'on',192
	dc.b	'no',193
	dc.b	'ta',194
	dc.b	'at',195
	dc.b	'hi',196
	dc.b	'in',197
	dc.b	'am',198
	dc.b	'co',199
	dc.b	'lo',200
	dc.b	'mo',201
	dc.b	0