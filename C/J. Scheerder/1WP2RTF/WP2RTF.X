# First: the 'special' stuff

init0	{\rtf1\mac\deff2\ {\fonttbl
init1	{\f0\fswiss Chicago;}{\f3\fswiss Geneva;}{\f4\fmodern Monaco;}{\f13\fnil Zapf Dingbats;}
init2	{\f16\fnil Palatino;}{\f20\froman Times;}{\f21\fswiss Helvetica;}{\f23\ftech Symbol;}
init3	{\f33\fnil Avant Garde;}{\f34\fnil New Century Schlbk;}}
init4	{\stylesheet{ \s243\qj\tqc\tx4320\tqr\tx8640 \f34\sbasedon0\snext243 footer;}
init5	{\s245\qj \f34\fs18\up6 \sbasedon0\snext0 footnote reference;}
init6	{\s246\qj \f34\fs20 \sbasedon0\snext246 footnote text;}
init7	{\s254\qj\sb120 \b\f34 \sbasedon0\snext0 heading 2;}
init8	{\s255\qj\sb240 \b\f34\ul \sbasedon0\snext0 heading 1;}
init9	{\qj \f34 \sbasedon222\snext0 Normal;}}\pard\plain \qj \f34 
exit	}
paragraph	\par
bold	{\b 
underlined	{\ul 
italic	{\i 
light	{\outl 
super	{\up6 
sub	{\dn6 
off	}
footnote	{\fs18\up6\chftn {\footnote \pard\plain \s246\qj \f34\fs20 {\fs18\up6\chftn }
endnote	}}

# Character table starts here

# 00-1D do not occur in the document, with a few exceptions

$00
$01
$02
$03
$04
$05
$06
$07
$08	\'c3
$09
$0a
$0b
$0c
$0d
$0e
$0f
$10
$11
$12
$13
$14
$15
$16
$17
$18
$19	\-
$1a
$1b
$1c
$1d

# 1e is WordPlus's SPACE

$1e	 

$1f

# Space is Fixed Space

$20	\~

# 21-2f go untranslated
# 30-39 is '0'..'9'
# 3a-40 go untranslated
# 41-5A is 'A'..'Z'
# 5b is OK

# escape the '\'
$5c	\\

# No need for 5d-60
# 61-7A is 'a'..'z'

# escape the '{'
$7b	\{

#escape the '}'
$7d	\}

# ~ is fine

# now map the available extended characters
$7f	\'c6
$80	\'82
$81	\'9f
$82	\'8e
$83	\'89
$84	\'8a
$85	\'88
$86	\'8c
$87	\'8d
$88	\'90
$89	\'91
$8a	\'8f
$8b	\'95
$8c	\'94
$8d	\'93
$8e	\'80
$8f	\'81
$90	\'83
$91	\'be
$92	\'ae
$93	\'99
$94	\'9a
$95	\'98
$96	\'9e
$97	\'9d
$98	\'d8
$99	\'85
$9a	\'86
$9b	\'a2
$9c	\'a3
$9d	\'b4
$9e	\'a7
$9f	\'c4
$a0	\'87
$a1	\'92
$a2	\'97
$a3	\'9c
$a4	\'96
$a5	\'84

# a-under N/A
$a6

$a7	\'bc
$a8	\'c0

# topleft N/A
$a9

$aa	\'c2
$ab	\|F(1,2)
$ac	\|F(1,4)
$ad	\'c1
$ae	\'c7
$af	\'c8
$b0	\'8b
$b1	\'9b
$b2	\'af
$b3	\'bf
$b4	\'cf
$b5	\'ce
$b6	\'cb
$b7	\'cc
$b8	\'cd
$b9	\'ac
$ba	`
$bb	\'a0
$bc	\'a6
$bd	\'a9
$be	\'a8
$bf	\'aa
$c0	ij
$c1	IJ

# Hebrew characters N/A
$c2
$c3
$c4
$c5
$c6
$c7
$c8
$c9
$ca
$cb
$cc
$cd
$ce
$cf
$d0
$d1
$d2
$d3
$d4
$d5
$d6
$d7
$d8
$d9
$da
$db
$dc

$dd	\'a4
# Low ^: down 6, ^
$de	{\dn6 ^}
$df	\'b0

# alpha N/A
$e0

$e1	\'a7

# Gamma N/A
$e2

$e3	\'b9
$e4	\'b7

# sigma N/A
$e5

$e6	\'b5

# tau, Psi, Theta N/A
$e7
$e8
$e9

$ea	\'bd
$eb	\'b6

# phi, psi, Epsilon, Big Union, Equivalence N/A
$ec
$ed
$ee
$ef
$f0

$f1	\'b1
$f2	\'b3
$f3	\'b2

# Upper/lower integral, division N/A
$f4
$f5
$f6

$f7	\'c5
$f8	\'a1
$f9	\'a5
$fa	\'a5
$fb	\'c3

# Superscript n, 2, 3 and overstrike N/A
$fc
$fd
$fe
$ff

# That's all folks
