;MESSAGE1
	DC.B	$EF,$0B		;OK
	DC.B	$E1,$01		;OK
	DC.B	$F6,$00		;OK
	DC.B	$F5,$00		;OK
	DC.B	$F4,$00		;OK
	DC.B	$F3,$FF		;OK
	DC.B	$F2,$FF		;OK
	DC.B	$F1,$FF		;OK
	DC.B	$EA,$00		;OK
	DC.B	$EB,$00		;OK
	DC.B	$DD		;OK
	DC.B	$EE,$00,$00	;OK
	DC.B	$EE,$01,$01	;OK
	DC.B	$EE,$02,$02	;OK
	DC.B	$EE,$03,$03	;OK
	DC.B	$EE,$04,$04	;OK
	DC.B	$EE,$05,$05	;OK
	DC.B	$EC		;OK
	DC.B	$FA,$02		;OK

	DC.B	$F4,$02		;OK
	DC.B	$F5,$FF		;OK

;	DC.B	$FF,$0A		;VITESSE
;	DC.B	'let',$27,'s sta'
;	DC.B	'rt the s'
;	DC.B	'how   '
;	DC.B	$E9
;	DC.B	'stage: open'
;	DC.B	$E8		;OK

	DC.B	$E7		;OK
	DC.B	$FD		;OK

	DC.B	$F0,$05,$00	;OK

;	DC.B	'as main '
;	DC.B	'actor:   '
;	DC.B	$E9
;	DC.B	'the cube'
;	DC.B	$E8		;OK
;	DC.B	$FF

;	dc.b	'd  wooow!!  '
;	DC.B	' what a '
;	DC.B	'nice cub'
;	DC.B	'e :-)   '
;	DC.B	'      bu'
;	DC.B	't someho'
;	DC.B	'w boring'
	DC.B	$F3,'@',$F2,'`',$F1,$00
	dc.b	'   '
	dc.b	$E9
;	dc.b	'spreadpoint'
	dc.b	$E8,$FE,$FF
	DC.B	$0A,$E5,$05,$FF,$FF,'F',$F3,$00
	DC.B	$F2,'`',$F1,$00,'prou'
	DC.B	'dly pres'
	DC.B	'ents:   '
	DC.B	$E9,'cube-o-'
	DC.B	'matic',$E8,$FE,$FF
	DC.B	$0A,$E5,$00,$FF,$FF,'P',$F3,' '
	DC.B	$F2,$00,$F1,$00,'in c'
	DC.B	'ooperati'
	DC.B	'on with '
	DC.B	'  ',$E9,'amiga'
	DC.B	' indust.'
	DC.B	$E8,$FE,$FF,$0A,$E5,$04,$FF,$FF
	DC.B	'F',$F3,' ',$F2,'@',$F1,$00,'p'
	DC.B	'rogrammi'
	DC.B	'ng:   ',$E9,'b'
	DC.B	'uddha',$E8,$FE,$E5
	DC.B	$02,$FF,$FF,'<',$F3,' ',$F2,' '
	DC.B	$F1,$00,'music '
	DC.B	'called ',$27
	DC.B	'cubus',$27,': '
	DC.B	'  ',$E9,'mat o'
	DC.B	'f mda',$E8,$FE,$E5
	DC.B	$01,$FF,$FF,'<',$F3,' ',$F2,'`'
	DC.B	$F1,$00,'idea a'
	DC.B	'nd logo:'
	DC.B	'   ',$E9,'ucom'
	DC.B	$E8,$FE,$E5,$04,$0F,$EE,$0B,$04
	DC.B	$E5,$03,$FF,$FF,'<',$F3,' ',$F2
	DC.B	$00,$F1,$00,'font:'
	DC.B	'   ',$E9,'gram'
	DC.B	'pa',$E8,$FE,$E5,$04,$FF,$FF
	DC.B	'<',$F5,$FF,'    ',$E9
	DC.B	' ',$E8,$FF,'<',$F6,$02,$FF,'d'
	DC.B	$F3,$1B,$F2,'U',$F1,'0do'
	DC.B	' you mis'
	DC.B	's a seco'
	DC.B	'nd scrol'
	DC.B	'ltext?? '
	DC.B	'   ',$E9,' ',$E8,$FE,$E5
	DC.B	$05,$01,$FC,$EB,$01,$FA,$02,$E5
	DC.B	$05,$FF,$FC,'   ',$E9,'t'
	DC.B	'ry the m'
	DC.B	'ouse',$E8,$F7,$01,$FF
	DC.B	$C8,'    ',$E9,' ',$E8
	DC.B	'switchin'
	DC.B	'g the mo'
	DC.B	'use off',$F7
	DC.B	$00,$F0,$0A,$00,$F6,$02,$F5,$FE
;	DC.B	'    wher'
;	DC.B	'e other '
;	DC.B	'groups j'
;	DC.B	'ust show'
;	DC.B	' you pla'
;	DC.B	'stic (no'
;	DC.B	'rmally f'
;	DC.B	'illed) o'
;	DC.B	'r flat l'
;	DC.B	'ooking ('
;	DC.B	'stencil '
;	DC.B	'vector) '
;	DC.B	'cubes  s'
;	DC.B	'preadpoi'
;	DC.B	'nt bring'
	DC.B	's you:',$E6,' '
	DC.B	'  ',$E9,'stone'
	DC.B	'-cube',$E8,$FD,$EF
	DC.B	$00,$EA,$02,$EB,$00,$EE,$08,$00
	DC.B	$EE,$08,$01,$EE,$08,$02,$EE,$08
	DC.B	$03,$EE,$08,$04,$EE,$08,$05,$FA
	DC.B	$02,$E7,$FD,$F4,$02,$FF,$1E,$F6
	DC.B	$00,$FF,$1E,$F5,$00,$FF,$1E,$F6
	DC.B	$FD,$FF,$1E,$F4,$00,$FF,$1E,$F5
	DC.B	$02,$FF,'d',$E6,'   ',$E9
	DC.B	'plasma-c'
	DC.B	'ube',$E8,$FD,$EF,$00,$EA
	DC.B	$03,$EB,$00,$EE,$07,$00,$EE,$07
	DC.B	$01,$EE,$07,$02,$EE,$07,$03,$EE
	DC.B	$07,$04,$EE,$07,$05,$FA,$02,$E7
	DC.B	$FD,$F4,$02,$FF,$1E,$F6,$00,$FF
	DC.B	$1E,$F5,$00,$FF,$1E,$F6,$FD,$FF
	DC.B	$1E,$F4,$00,$FF,$1E,$F5,$02,$FF
	DC.B	'2my favo'
	DC.B	'rite:',$E6,'  '
	DC.B	' ',$E9,'wood-c'
	DC.B	'ube',$E8,$FD,$EF,$00,$EA
	DC.B	$01,$EB,$00,$EE,$06,$00,$EE,$06
	DC.B	$01,$EE,$06,$02,$EE,$06,$03,$EE
	DC.B	$06,$04,$EE,$06,$05,$FA,$02,$E7
	DC.B	$FD,$F4,$02,$FF,$1E,$F6,$00,$FF
	DC.B	$1E,$F5,$00,$FF,$1E,$F6,$FD,$FF
	DC.B	$1E,$F4,$00,$FF,$1E,$F5,$02,$FF
	DC.B	'x but it'
	DC.B	' gets ev'
	DC.B	'en bette'
	DC.B	'r: cube-'
	DC.B	'o-motion'
	DC.B	' and',$E6,'   '
	DC.B	$E9,'the jug'
	DC.B	'gler',$E8,$FD,$F7,$00
	DC.B	$F6,$03,$F5,$FE,$DE,$01,$ED,$01
	DC.B	$00,$ED,$01,$01,$ED,$01,$02,$ED
	DC.B	$01,$03,$ED,$01,$04,$ED,$01,$05
	DC.B	$FA,$04,$E7,$FD,$FF,$FA,'mo'
	DC.B	're textu'
	DC.B	'res comi'
	DC.B	'ng up:',$E6,' '
	DC.B	'  ',$E9,'cube-'
	DC.B	'o-matic',$E8
	DC.B	$FD,$EC,$DD,$EF,$00,$EA,$00,$EB
	DC.B	$00,$EE,$00,$00,$EE,$00,$01,$EE
	DC.B	$00,$02,$EE,$00,$03,$EE,$00,$04
	DC.B	$EE,$00,$05,$FA,$02,$E7,$FD,$F4
	DC.B	$02,$FF,$1E,$F6,$00,$FF,$1E,$F5
	DC.B	$00,$FF,$1E,$F6,$FD,$FF,$1E,$F4
	DC.B	$00,$FF,$1E,$F5,$02,$E6,'  '
	DC.B	' ',$E9,'cheese'
	DC.B	'-cube',$E8,$FD,$EA
	DC.B	$04,$EB,$00,$EE,$0D,$00,$EE,$0D
	DC.B	$01,$EE,$0D,$02,$EE,$0D,$03,$EE
	DC.B	$0D,$04,$EE,$0D,$05,$FA,$02,$E7
	DC.B	$FD,$F6,$02,$FF,$1E,$F5,$00,$FF
	DC.B	$1E,$F4,$FD,$FF,$1E,$F4,$00,$FF
	DC.B	$1E,$F5,$02,$FF,'dbut'
	DC.B	' now bac'
	DC.B	'k to rea'
	DC.B	'lity    '
	DC.B	$E9,' ',$E8,$EA,$00,$E3,$00,$FF
	DC.B	$E3,$01,$01,$E3,$02,$FF,$E3,$03
	DC.B	$01,$E3,$04,$FF,$E3,$05,$01,$FB
	DC.B	$EE,$00,$00,$EE,$01,$01,$EE,$02
	DC.B	$02,$EE,$03,$03,$EE,$04,$04,$EE
	DC.B	$05,$05,$FA,$04,$E3,$00,$01,$E3
	DC.B	$01,$FF,$E3,$02,$01,$E3,$03,$FF
	DC.B	$E3,$04,$01,$E3,$05,$FF,$FB,'m'
	DC.B	'y contri'
	DC.B	'bution t'
	DC.B	'o the ',$F3,'\'
	DC.B	$F2,'p',$F1,'0mand'
	DC.B	'elbrot f'
	DC.B	'ever:   '
	DC.B	$E9,'mouse o'
	DC.B	'n!',$E8,$FE,$F7,$01,$E0,$00
	DC.B	$F9,$FF,'<',$E0,$01,$F9,$FF,'<'
	DC.B	$E0,$02,$F9,$FF,'<',$E0,$03,$F9
	DC.B	'special '
	DC.B	'greeting'
	DC.B	's are in'
	DC.B	' the hid'
	DC.B	'den mode'
	DC.B	'! try to'
	DC.B	' get the'
	DC.B	're!! joi'
	DC.B	'n the po'
	DC.B	'wer!    '
	DC.B	'   ',$E6,'    '
	DC.B	$E9,' ',$E8,$FD,$EF,$0B,$E1,$01
	DC.B	$F6,$00,$F5,$00,$F4,$00,$F3,$FF
	DC.B	$F2,$FF,$F1,$FF,$EA,$00,$EB,$00
	DC.B	$DD,$EE,$00,$00,$EE,$01,$01,$EE
	DC.B	$02,$02,$EE,$03,$03,$EE,$04,$04
	DC.B	$EE,$05,$05,$EC,$FA,$02,$EE,$01
	DC.B	$00,$EE,$00,$02,$EE,$09,$03,$EE
	DC.B	$0A,$04,$FA,$04,$E5,$00,$FF,$E5
	DC.B	$01,$FF,$E5,$02,$FF,$E5,$03,$FF
	DC.B	$E5,$04,$FF,$E5,$05,$FF,$EB,$02
	DC.B	$DE,$01,$F7,$01,$F0,$0A,$00,$E7
	DC.B	$FD,'now pas'
	DC.B	'sing ove'
	DC.B	'r the co'
	DC.B	'ntrol to'
	DC.B	' the use'
	DC.B	'r.... mo'
	DC.B	'use on  '
	DC.B	' technic'
	DC.B	'al infor'
	DC.B	'mation: '
	DC.B	'   assem'
	DC.B	'bler use'
	DC.B	'd: (gues'
	DC.B	's what?)'
	DC.B	' masters'
	DC.B	'eka by b'
	DC.B	'uddha an'
	DC.B	'd george'
	DC.B	' ii   if'
	DC.B	' you wan'
	DC.B	't to con'
	DC.B	'tact me.'
	DC.B	'.... jus'
	DC.B	't do it '
	DC.B	':-)     '
	DC.B	'but reme'
	DC.B	'mber: i',$27
	DC.B	'm not in'
	DC.B	'terested'
	DC.B	' in any '
	DC.B	'swapping'
	DC.B	' or othe'
	DC.B	'r illega'
	DC.B	'l stuff.'
	DC.B	'... frie'
	DC.B	'ndship r'
	DC.B	'ules!   '
	DC.B	' every e'
	DC.B	'ffort wa'
	DC.B	's taken '
	DC.B	'to make '
	DC.B	'this dem'
	DC.B	'o both a'
	DC.B	's powerf'
	DC.B	'ul and a'
	DC.B	's flexib'
	DC.B	'le as po'
	DC.B	'ssible. '
	DC.B	'hence it'
	DC.B	' will ev'
	DC.B	'en work '
	DC.B	'on a sto'
	DC.B	'ck 512k '
	DC.B	'machine,'
	DC.B	' althoug'
	DC.B	'h full s'
	DC.B	'peed wil'
	DC.B	'l only b'
	DC.B	'e achiev'
	DC.B	'ed on a '
	DC.B	'68040...'
	DC.B	' oooops,'
	DC.B	' didn',$27,'t '
	DC.B	'want to '
	DC.B	'frustrat'
	DC.B	'e anyone'
	DC.B	'.. as a '
	DC.B	'matter o'
	DC.B	'f fact r'
	DC.B	'unning o'
	DC.B	'n a 6803'
	DC.B	'0, cube-'
	DC.B	'o-matic '
	DC.B	'reaches '
	DC.B	'the spee'
	DC.B	'd other '
	DC.B	'demos ju'
	DC.B	'st dream'
	DC.B	' of: up '
	DC.B	'to 60 fr'
	DC.B	'ames per'
	DC.B	' second.'
	DC.B	'.. thank'
	DC.B	's again '
	DC.B	'to mark '
	DC.B	'for the '
	DC.B	'mandelbr'
	DC.B	'ot calcu'
	DC.B	'lation r'
	DC.B	'outine ('
	DC.B	'although'
	DC.B	' i made '
	DC.B	'some sli'
	DC.B	'ght chan'
	DC.B	'ges ...)'
	DC.B	' which i'
	DC.B	's pretty'
	DC.B	' fast.. '
	DC.B	'remember'
	DC.B	': the ma'
	DC.B	'ndelbrot'
	DC.B	' routine'
	DC.B	' only ge'
	DC.B	'ts about'
	DC.B	' 10 perc'
	DC.B	'ent of t'
	DC.B	'he cpu t'
	DC.B	'ime.. al'
	DC.B	'so thank'
	DC.B	's to eri'
	DC.B	'c graham'
	DC.B	' for the'
	DC.B	' origina'
	DC.B	'l juggle'
	DC.B	'r animat'
	DC.B	'ion... e'
	DC.B	'nd of te'
	DC.B	'chnical '
	DC.B	'informat'
	DC.B	'ion...  '
	DC.B	'  genera'
	DC.B	'l note: '
	DC.B	'don',$27,'t us'
	DC.B	'e demo m'
	DC.B	'akers, t'
	DC.B	'hey prod'
	DC.B	'uce only'
	DC.B	' old cra'
	DC.B	'p (sorry'
	DC.B	' delta..'
	DC.B	'.)! try '
	DC.B	'doing in'
	DC.B	'novative'
	DC.B	' stuff..'
	DC.B	' this de'
	DC.B	'mo is ab'
	DC.B	'out to r'
	DC.B	'estart a'
	DC.B	'nd we ho'
	DC.B	'pe to se'
	DC.B	'e you ag'
	DC.B	'ain in a'
	DC.B	'nother b'
	DC.B	'uddha an'
	DC.B	'd spread'
	DC.B	'point pr'
	DC.B	'oduction'
	DC.B	'... than'
	DC.B	'k you fo'
	DC.B	'r flying'
	DC.B	' cube-o-'
	DC.B	'air.....'
	DC.B	' perhaps'
	DC.B	' we will'
	DC.B	' meet ag'
	DC.B	'ain in c'
	DC.B	'ube-o-ma'
	DC.B	'tic 2 or'
	DC.B	' sphere-'
	DC.B	'o-matic.'
	DC.B	'.. that',$27
	DC.B	's all fo'
	DC.B	'r now   '
	DC.B	'      ',$E9,'w'
	DC.B	'rap',$E8,$E5,$00,$01,$E5
	DC.B	$01,$01,$E5,$02,$01,$E5,$03,$01
	DC.B	$E5,$04,$01,$E5,$05,$01,$E6,$F0
	DC.B	$05,$0A,$F7,$00,$FD,$FC,'  '
	DC.B	'  ',$E9,' ',$E8,' ',$00,$00
