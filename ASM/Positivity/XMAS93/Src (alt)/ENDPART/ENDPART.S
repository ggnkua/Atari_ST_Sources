;**************************************************************************
;**	           Le programme principal!	         **
;**************************************************************************

supervisor_mode:	; INDISPENSABLE.
  move.l	#$0,-(sp)
  move.w	#$20,-(sp)
  trap	#$1
  addq.l	#$6,sp

  dc.w	$a00a	; Bye bye la souris.
  move.b	#$12,$fffffc02.w
  bclr.b	#$0,$484.w
  
save_old_features:	
  move.w	$ffff8260.w,old_res
  move.b	$ffff820a.w,old_sync
  moveq.l	#$0,d0
  move.b	$ffff8201.w,d0	; Base haute.
  swap.w	d0
  move.b	$ffff8203.w,d0	; Moyenne.
  lsl.w	#$8,d0
  move.b	$ffff820d.w,d0	; Basse.( N' existe pas sur ST-STf)
  move.l	d0,old_screen
  move.l	#$7,d0	; Sauver les couleurs qu'on va modifier.
  move.l	#old_colors,a0
  move.w	#$8240,a1
.save_cols:
  move.l 	(a1)+,(a0)+
  dbra	d0,.save_cols

  move.l	#screen,screen_ad ; Adresse de base.
  
screen_features:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp
  move.b	#$1,$ffff8260.w	; Moyenne resolution.
  move.b	#$2,$ffff820a.w	; Sync=50Hz.
  move.l	screen_ad,d0	; Mettre l' adresse de l' ecran.
  move.b	d0,$ffff8209.w	; Base basse de la ramvideo.
  lsr.w	#$8,d0
  move.b	d0,$ffff8207.w	; Base moyenne de la ramvideo.
  swap.w	d0
  move.b	d0,$ffff8205.w	; Base haute de la ramvideo.

  moveq.l	#$7,d0	
  move.w	#$8240,a0	; Mettre les couleurs a $334.
  move.l	#colors,a1
.put_cols:
  move.l 	(a1)+,(a0)+
  dbra	d0,.put_cols

  jsr	muson
  
;**************************************************************************

vbl1:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test
  add.w	#$111,$ffff8240.w
.no_test:

  move.l	screen_ad,d0	; Ecran a afficher.
  move.b	d0,$ffff8209.w	; Base basse de la ramvideo.
  lsr.w	#$8,d0
  move.b	d0,$ffff8207.w	; Base moyenne de la ramvideo.
  swap.w	d0
  move.b	d0,$ffff8205.w	; Base haute de la ramvideo.

;**********

  move.w	nb_vbls,d0
  addq.w	#$1,d0
  cmp.w	#216,d0	; 204 lignes de scrollees deja.
  bne.s	.scroll_one
.up_again:		; Sinon on retourne en haut.
  move.l	#screen,screen_ad
  moveq.l	#$0,d0
  bra.s	.ok_ok_compris
  
.scroll_one:
  add.l	#$a0,screen_ad
.ok_ok_compris:
  move.w	d0,nb_vbls

.print_text:		; Afficher du texte si besoin est.
  move.w	nb_vbls_mod12,d0
  subq.w	#$1,d0
  bne.s	.no_print_text
  
  move.l	screen_ad,a0	; Si on ici il faut afficher du texte.
  move.l	text_pos,a1	; Position dans le texte.
  sub.w	#1920,a0	; Au dessus de l' ecran.
  jsr	print_one_line
  
  adda.l	#34560,a0	; Et au dessous.
  jsr	print_one_line

  add.l	#40,a1	; Prochaine ligne.
  move.l	text_end,d1
  cmp.l	d1,a1	; C' est la fin?    
  bne	.not_text_end
  
  move.l	#text,a1	; On recommence.
  
.not_text_end:  
  move.l	a1,text_pos	; Sinon on sauve.
  move.w	#12,d0
  
.no_print_text:
  move.w	d0,nb_vbls_mod12 ; Et on continue.

;**********
  
  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test2
  sub.w	#$111,$ffff8240.w
.no_test2:

;***************************
;***************************
;***************************
vbl2:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp

  move.l	screen_ad,d0	; Ecran a afficher.
  move.b	d0,$ffff8209.w	; Base basse de la ramvideo.
  lsr.w	#$8,d0
  move.b	d0,$ffff8207.w	; Base moyenne de la ramvideo.
  swap.w	d0
  move.b	d0,$ffff8205.w	; Base haute de la ramvideo.

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test
  add.w	#$111,$ffff8240.w
.no_test:

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test2
  sub.w	#$111,$ffff8240.w
.no_test2:

  cmpi.b	#$39,$fffffc02.w
  bne	vbl1
  
  
;**************************************************************************
sortie:

  jsr	musoff

  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp
  move.w	old_res,$ffff8260.w
  move.b	old_sync,$ffff820a.w
  move.l	old_screen,d0
  swap.w	d0
  move.b	d0,$ffff8201.w	; Le pire c' est qu'il faut mettre
  swap.w	d0	; $ff820d en dernier.
  rol.w	#$8,d0	
  move.b	d0,$ffff8203.w
  rol.w	#$8,d0	
  move.b	d0,$ffff820d.w
  move.l	#$7,d0	
  move.w	#$8240,a0	; Mettre les couleurs a $334.
  move.l	#old_colors,a1
.restore_cols:
  move.l 	(a1)+,(a0)+
  dbra	d0,.restore_cols

  bset.b	#$0,$484.w
  move.b	#$8,$fffffc02.w
  dc.w	$a009	; Le tank est de retour!
  
  clr.w	-(sp)
  trap	#$1

;**************************************************************************
print_one_line:

  movem.l	d0-d2/a0-a4,-(sp)
  
  move.l	#fonts,a2	; Adresse des motifs.
  move.l	#conv_table,a3	; Pour conversion.
  move.w	#39,d0	; 40 chars par ligne.
.one_char:
  moveq.l	#$0,d1
  move.b	(a1)+,d1	; Char a afficher.
  move.b	(a3,d1.w),d1	; Position dans les motifs.  
  move.w	d1,d2	; Multiplication par 24.
  add.w	d1,d1
  add.w	d2,d1
  lsl.w	#$3,d1
  move.l	a2,a4
  add.w	d1,a4	; a4 pointe sur le char.
  move.w	(a4),(a0)
  move.w	(a4)+,$a2(a0)
  move.w	(a4),$a0(a0)
  move.w	(a4)+,$142(a0)
  move.w	(a4),$140(a0)
  move.w	(a4)+,$1e2(a0)
  move.w	(a4),$1e0(a0)
  move.w	(a4)+,$282(a0)
  move.w	(a4),$280(a0)
  move.w	(a4)+,$322(a0)
  move.w	(a4),$320(a0)
  move.w	(a4)+,$3c2(a0)
  move.w	(a4),$3c0(a0)
  move.w	(a4)+,$462(a0)
  move.w	(a4),$460(a0)
  move.w	(a4)+,$502(a0)
  move.w	(a4),$500(a0)
  move.w	(a4)+,$5a2(a0)
  move.w	(a4),$5a0(a0)
  move.w	(a4)+,$642(a0)
  move.w	(a4),$640(a0)
  move.w	(a4)+,$6e2(a0)
  move.w	(a4),$6e0(a0)
  move.w	(a4)+,$782(a0)
  addq.w	#$4,a0	; Prochain char.
  dbra	d0,.one_char
  
  movem.l	(sp)+,d0-d2/a0-a4
  rts  
  
;**************************************************************************
  Section DATA
  
colors:
  dc.w	$0aa,$466,$099,$466
  dc.w	$000,$000,$000,$000
  dc.w	$000,$000,$000,$000
  dc.w	$000,$000,$000,$000

fonts:
  incbin	'a:\endpart\fonts.xxx'
  
conv_table:
  dc.b	75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75
  dc.b	75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75
  dc.b	75,54,61,52,75,75,75,60,55,56,63,75,59,58,53,52
  dc.b	73,64,65,66,67,68,69,70,71,72,74,75,75,75,75,57
  dc.b	75,00,01,02,03,04,05,06,07,08,09,10,11,12,13,14
  dc.b	15,16,17,18,19,20,21,22,23,24,25,75,75,75,75,75
  dc.b	60,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40
  dc.b	41,42,43,44,45,46,47,48,49,50,51,75,75,75,62,75
  
text:
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'            * PoSiTiViTy *              '
  dc.b	'            ~~~~~~~~~~~~~~              '
  dc.b	'                                        '
  dc.b	'   * Whishes you a merry X-mas 1993 *   '
  dc.b	'       And also a Happy New-Year.       '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'    I (Dracula) am not familiar with    '
  dc.b	'  scrolltexts, so it''ll be boring, but  '
  dc.b	'    the Wonderfull music by ST_MIXES    '
  dc.b	'       will help you reading this!      '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'  First let''s go on with the ego trip!  '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	' The Credits:                           '
  dc.b	' ~~~~~~~~~~~~                           '
  dc.b	'     Soundtrack music########ST-Mixes   '
  dc.b	'     First Picture#############STelex   '
  dc.b	'     Second Piccy##############Exocet   '
  dc.b	'     Chip music##############Big Alec   '
  dc.b	'     Soundtrack rout##########Wizzcat   '
  dc.b	'     Ugly logos###############Dracula   '
  dc.b	'     Crappy code##############Dracula   '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'   I know you don''t mind the bollocks,  '
  dc.b	'           but here''s the##.            '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	' Positivity Memberlist:                 '
  dc.b	' ~~~~~~~~~~~~~~~~~~~~~~                 '
  dc.b	'         Anneli############Swapper      '
  dc.b	'         Dracula############Bugger      '
  dc.b	'         Dump#############Musician      '
  dc.b	'         Exocet###########Graphist      '
  dc.b	'         Kasar###############Coder      '
  dc.b	'         Kelvin############Tourist      '
  dc.b	'         Nikom############Musician      '
  dc.b	'         Silver Eagle######Swapper      '
  dc.b	'         Spearhead###########Coder      '
  dc.b	'         STelex###########Graphist      '
  dc.b	'         ST-Mixes#########Musician      '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  dc.b	'                                        '
  dc.b	'   As X-mas is a major event,I would    '
  dc.b	'    like to send my best regards to:    '
  dc.b	'                                        '
  dc.b	'   Chris-Creeks-Survivor of Mafiamiga   '
  dc.b	'                Daubeman                '
  dc.b	'                 Daniel                 '
  dc.b	'             Elf of Intense             '
  dc.b	'            Flips of Dnt Crew           '
  dc.b	'      Fred (STe is goood for you!)      '
  dc.b	'                  Jazz                  '
  dc.b	'                  Kaya                  '
  dc.b	'                  Onyx                  '
  dc.b	'        Philippe and his brother        '
  dc.b	'             STC-Sam of Hmd             '
  dc.b	'   Tomcat-Lector-Skillion of Steelers   '
  dc.b	'      Wann ze flying koter of Hmd       '
  dc.b	'        Zorgan of les Heretiques        '
  dc.b	'                                        '
  dc.b	' The anonymous who send the nice letter!'  
  dc.b	'                                        '
  dc.b	'       All members of Positivity#       '
  dc.b	'                                        '
  dc.b	'       All the cool guys I forgot!      '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'           Merry X-mas guys!            '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	' Kasar send his greetings to:           '
  dc.b	'                                        '
  dc.b	'  ABSTRACT,ST CONNEXION,HMD,THE MISFITS '
  dc.b	' FMCC,OVR,DNT CREW,LEGACY,FUZION,FANTASY'
  dc.b	'ADRENALINE,SUPREMACY,MJJ PROD,SECTOR ONE'
  dc.b	'EQUINOX,DUNE,NEXT,OXYGENE,HOLOCAUST,ASOA'
  dc.b	' THE CYBERNETICS,THE AUTHENTIK,AURA,ICS '
  dc.b	' BINARIS,THE REPLICANTS,KGB,VMAX,SYSTEM '
  dc.b	'THE RESPECTABLES,LUNO,ODISSEY,ALEX,SMALT'
  dc.b	' NEIMAD,HALTERO,CREATEUR,NRTH,DANEE-TFH '
  dc.b	'  PHILST,NICKY-ACS,ARX-TDS,SAD-ETERNITY '
  dc.b	'          ZER,THE UNION,FALCON          '
  dc.b	'        ALL THE GREAT DEMOMAKERS        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'  It''s X-mas, so I included *surprises* '
  dc.b	'              on the disk:              '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'   You can found all my (lame) sources! '
  dc.b	'                                        '
  dc.b	'     There is also the reset I coded    '
  dc.b	'     for the marvellous DNT Paper 6!    '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~'
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'   Ok, now I''ll bore you with my life:  '
  dc.b	'                                        '
  dc.b	'       I''m born on 27 of april 1973     '
  dc.b	'      and I was drunk the day after,    '
  dc.b	'cos my birth is a major event in my life'
  dc.b	'                   and#######           '
  dc.b	'                                        '
  dc.b	'  Stoooooooooooooooooooooooooooooooop!  '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'   I didn''t thought it was so hard to   '
  dc.b	'      write a scrolltext! Tough shit!   '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'  Ok, a few words about the members of  '
  dc.b	' the megagroup (Arf,arf##) *PoSiTiViTy* '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'     The amazing thing is that the      '
  dc.b	'musicians are really good and efficient!'
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'   The music you are listening at now   '
  dc.b	'    is a wonderfull piece of talent,    '
  dc.b	' and you should know that''s it''s not the'
  dc.b	'       best one our musicians made!     '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'  Of course, all members  of Positivity '
  dc.b	'    are pure gods, except I(lamer no1)  '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'      Oh yeah, you may be interested    '
  dc.b	'     in knowing I''m currently trying    '
  dc.b	'            to code a game##            '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'   Don''t wet your pants, it''ll not be   '
  dc.b	'        as big as "Monkey Island",      '
  dc.b	'          as funny as "Utopos",         '
  dc.b	'   as mindblowing as "Dungeon Master"## '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	' In fact, I would like to code a remake '
  dc.b	'  of centipede for up to three player.  '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'  Of course, if I succeed in making it, '
  dc.b	'    it will be released as a freeware.  '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'    The matter is that my exams are     '
  dc.b	'      approching fastly, and that       '
  dc.b	'   I have loads of projects in mind!    '
  dc.b	'  (Enhanced polygone and sphere rout#)  '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'   So, don''t wait for this game to be   '
  dc.b	'    coming soon, and well, when I see   '
  dc.b	'    how lame I am, I feel like giving   '
  dc.b	'    all my projects up and do nothing   '
  dc.b	'      but sleeeeeeeeeeeeeeeeeeeeeep!    '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'  While we are at it, it''s late in the  '
  dc.b	'night (early in the morning?) rigth now,'
  dc.b	'   so don''t bother me if there are no   '
  dc.b	' hundreds of kilobytes left in the text!'                                     '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*'
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'    A funny thing happening is that     '
  dc.b	'       loads of people are saying:      '
  dc.b	'                                        '
  dc.b	'         "The Atari ST is dead!"        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'  Yep, it''s funny, cos I can''t believe  '
  dc.b	'   people who really like the ST will   '
  dc.b	'    forget such a fantastic machine,    '
  dc.b	'   and for my point of view it''s the    '
  dc.b	'          very best computer.           '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'     I coded on PC for some weeks.      '
  dc.b	'  My washing machine is more exciting!  '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'     My brothers owns an Amiga 1200.    '
  dc.b	'        The hardware is fantastic!      '
  dc.b	'          The demos are amazing.        '
  dc.b	'          The workbench is crap.        '
  dc.b	'   Amiga freaks are loving "Fucktros"!  '
  dc.b	'    ( Demos only to piss on someone!)   '
  dc.b	'                                        '
  dc.b	' Definetily, atmosphere is better on ST!'
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'  So, do not be surprised if there are  '
  dc.b	'     "Fanatics" who will stay on ST!    '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'And well,do you remind the Commodore 64?'                                       '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*'
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'   Huum, would like to say that I am    '
  dc.b	'  looking out for all 3.5 Kbytes demos, '
  dc.b	'        and for all "big" demos#        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'So, if you want to get in touch with me,'
  dc.b	'  for coding, or sending me 3.5K demos, '
  dc.b	'            here''s my adress:           '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'        (Dracula of PoSiTiViTy)         '
  dc.b	'                                        '
  dc.b	'            BROBECKER Alain             '
  dc.b	'            rte de Dardagny             '
  dc.b	'             01630 CHALLEX              '
  dc.b	'                 FRANCE                 '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'  If you want to write to PoSiTiVity:   '                                      '
  dc.b	'                                        '
  dc.b	'              POSITIVITY                '
  dc.b	'            122 rue Bossuet             '
  dc.b	'              69006 LYON                '
  dc.b	'                 FRANCE                 '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*'
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'   Last thing: If you use my routines   '
  dc.b	'     in a freeware/shareware proggy,    '
  dc.b	' (Commercial use not allowed of course!)'
  dc.b	'it would be nice to send me your product'
  dc.b	'            and to credit me!           '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'     Dracula, on 10 december 1993.      '
  dc.b	'                                        '
  dc.b	'       ***************************      '
  dc.b	'       *                         *      '
  dc.b	'       *     MERRY CHRISTMAS     *      '
  dc.b	'       *     HAPPY NEW YEAR!     *      '
  dc.b	'       *                         *      '
  dc.b	'       ***************************      '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '
  dc.b	'                                        '

text_end:
  dc.l	*    
nb_vbls:
  dc.w	$0
nb_vbls_mod12:
  dc.w	1
text_pos:
  dc.l	text  

module:
data:	INCBIN 	a:\endpart\stm12.MOD
rien:
	Ds.B	32000  ; Workspace
workspc	DS.W	1


;**************************************************************************
  Section BSS

buffer:
  ds.w	16
old_res:
  ds.w	1
old_sync:
  ds.w	1
old_screen:
  ds.l	1
old_colors:
  ds.l	8
  
screen_ad:
  ds.l	1
marge:		; Sert a preserver l' integrite du bidule.
  ds.l	800
screen:
  ds.l	20000


;**************************************************************************
  Section TEXT
  
;-----------------------------------------------------------------------;
; 	Replay STe							;
; 	by WizzCat the 21st of May 1991					;
;-----------------------------------------------------------------------;
; Uses no registers							;
;									;
; Replay is started by calling MUSON in supervisor mode. Returns with	;
; timer A running. Calling MUSOFF will stop music.			;
;									;
; This routine needs some workspace after the module to work properly.	;
; We've set it to 16k, some modules needs more, some need less. If the	;
; workspace is too small, initialization will hang on an ILLEGAL	;
; instruction. Adjust workspace size to fit the specific module.	;
;									;
; MVOL = Main volume	  (Unnecessary to adjust. $80 default)		;
; FREQ = replay frequency (See below)					;
;-----------------------------------------------------------------------;

MVOL	EQU $80
FREQ	EQU 2				; 0=6.259, 1=12.517, 2=25.036
					; 3=50.072 (MegaSTe/TT)

	IFEQ FREQ
PARTS	EQU 5-1				; 6.259
LEN	EQU 25
INC	EQU $023BF313			; 3579546/6125*65536
	ELSEIF
	IFEQ FREQ-1
PARTS	EQU 5-1				; 12.517
LEN	EQU 50
INC	EQU $011DF989			; 3579546/12517*65536
	ELSEIF
	IFEQ FREQ-2
PARTS	EQU 5-1				; 25.035
LEN	EQU 100
INC	EQU $008EFB4E			; 3579546/25035*65536
	ELSEIF
	IFEQ FREQ-3
PARTS	EQU 5-1				; 50.072
LEN	EQU 200
INC	EQU $00477CEC			; 3579546/50072*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC


;---------------------------------------------------- Interrupts on/off --
muson	bsr	vol			; Calculate volume tables
	bsr	incrcal			; Calculate tonetables

	jsr	init			; Initialize music
	jsr	prepare			; Prepare samples

	move	#$2700,sr

	bset	#5,$FFFFFA07.w
	bset	#5,$FFFFFA13.w

	clr.b	$FFFFFA19.w
	move.b	#1,$FFFFFA1F.w
	move.b	#8,$FFFFFA19.w

	move.l	$0134.w,oldtima
	move.l	#stereo,$0134.w

	move.b	#FREQ,$FFFF8921.w		; Frequency

	lea	$FFFF8907.w,a0

	move.l	#sample1,d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)

	move.l	#sample1+LEN*2,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)

	move.b	#3,$FFFF8901.w		; Start DMA

	move	#$2300,sr
	rts

musoff	move	#$2700,sr

	clr.b	$FFFFFA19.w		; Stop timers

	move.l	oldtima(pc),$0134.w	; Restore everything

	bclr	#5,$FFFFFA07.w
	bclr	#5,$FFFFFA13.w

	clr.b	$FFFF8901.w		; Stop DMA

	move	#$2300,sr
	rts

oldtima	DC.L 0

;--------------------------------------------------------- Volume table --
vol	moveq	#64,d0
	lea	vtabend(pc),a0

.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL,d2		; <---- Master volume
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop

	rts

vtab	DS.B 65*256
vtabend

;------------------------------------------------------ Increment-table --
incrcal	lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC,d2

recalc	swap	d2
	moveq	#0,d3
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	swap	d4

	swap	d2
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+

	addq.w	#1,d1
	dbra	d0,recalc
	rts

itab	DS.L $30
stab	DS.L $03A0-$30

;-------------------------------------------------------- DMA interrupt --
stereo
sasa	
	move	#$2500,sr
	bclr	#5,$FFFFFA0F.w
	movem.l	d0-a6,-(sp)

	move.l	samp1(pc),d0
	move.l	samp2(pc),samp1
	move.l	d0,samp2

	lea	$FFFF8907.w,a0

	move.l	samp1(pc),d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)

	move.l	samp1(pc),d0
	add.l	#LEN*2,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)

	subq.w	#1,count
	bpl.s	.nomus

	move.w	#PARTS,count
	bsr	music

.nomus	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4

v1	movea.l	wiz2lc(pc),a0

	move.w	wiz2pos(pc),d0
	move.w	wiz2frc(pc),d1

	move.w	aud2per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2

	movea.w	2(a5,d7.w),a4

	move.w	aud2vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2


	movea.l	wiz3lc(pc),a1

	move.w	wiz3pos(pc),d4
	move.w	wiz3frc(pc),d5

	move.w	aud3per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud3vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	movea.l	samp1(pc),a6
	moveq	#0,d3

	REPT LEN
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	ENDR

	cmp.l	wiz2len(pc),d0
	blt.s	.ok2
	sub.w	wiz2rpt(pc),d0

.ok2	move.w	d0,wiz2pos
	move.w	d1,wiz2frc

	cmp.l	wiz3len(pc),d4
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d4

.ok3	move.w	d4,wiz3pos
	move.w	d5,wiz3frc



	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4

v2	movea.l	wiz1lc(pc),a0

	move.w	wiz1pos(pc),d0
	move.w	wiz1frc(pc),d1

	move.w	aud1per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2
	movea.w	2(a5,d7.w),a4

	move.w	aud1vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2


	movea.l	wiz4lc(pc),a1

	move.w	wiz4pos(pc),d4
	move.w	wiz4frc(pc),d5

	move.w	aud4per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud4vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	movea.l	samp1(pc),a6
	moveq	#0,d3

	REPT LEN
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	addq.w	#2,a6
	ENDR

	cmp.l	wiz1len(pc),d0
	blt.s	.ok1
	sub.w	wiz1rpt(pc),d0

.ok1	move.w	d0,wiz1pos
	move.w	d1,wiz1frc

	cmp.l	wiz4len(pc),d4
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d4

.ok4	move.w	d4,wiz4pos
	move.w	d5,wiz4frc

	movem.l	(sp)+,d0-a6
soso
	rte

;-------------------------------------------- Hardware-registers & data --
count	DC.W PARTS

wiz1lc	DC.L sample1
wiz1len	DC.L 0
wiz1rpt	DC.W 0
wiz1pos	DC.W 0
wiz1frc	DC.W 0

wiz2lc	DC.L sample1
wiz2len	DC.L 0
wiz2rpt	DC.W 0
wiz2pos	DC.W 0
wiz2frc	DC.W 0

wiz3lc	DC.L sample1
wiz3len	DC.L 0
wiz3rpt	DC.W 0
wiz3pos	DC.W 0
wiz3frc	DC.W 0

wiz4lc	DC.L sample1
wiz4len	DC.L 0
wiz4rpt	DC.W 0
wiz4pos	DC.W 0
wiz4frc	DC.W 0

aud1lc	DC.L dummy
aud1len	DC.W 0
aud1per	DC.W 0
aud1vol	DC.W 0
	DS.W 3

aud2lc	DC.L dummy
aud2len	DC.W 0
aud2per	DC.W 0
aud2vol	DC.W 0
	DS.W 3

aud3lc	DC.L dummy
aud3len	DC.W 0
aud3per	DC.W 0
aud3vol	DC.W 0
	DS.W 3

aud4lc	DC.L dummy
aud4len	DC.W 0
aud4per	DC.W 0
aud4vol	DC.W 0

dmactrl	DC.W 0

dummy	DC.L 0

samp1	DC.L sample1
samp2	DC.L sample2

sample1	DS.W LEN
sample2	DS.W LEN

;========================================================= EMULATOR END ==

prepare	lea	workspc,a6
	movea.l	samplestarts(pc),a0
	movea.l	end_of_samples(pc),a1

tostack	move.w	-(a1),-(a6)
	cmpa.l	a0,a1			; Move all samples to stack
	bgt.s	tostack

	lea	samplestarts(pc),a2
	lea	data(pc),a1		; Module
	movea.l	(a2),a0			; Start of samples
	movea.l	a0,a5			; Save samplestart in a5

	moveq	#30,d7

roop	move.l	a0,(a2)+		; Sampleposition

	tst.w	$2A(a1)
	beq.s	samplok			; Len=0 -> no sample

	tst.w	$2E(a1)			; Test repstrt
	bne.s	repne			; Jump if not zero


repeq	move.w	$2A(a1),d0		; Length of sample
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a0,a4
fromstk	move.w	(a6)+,(a0)+		; Move all samples back from stack
	dbra	d0,fromstk

	bra.s	rep



repne	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a6,a4
get1st	move.w	(a4)+,(a0)+		; Fetch first part
	dbra	d0,get1st

	adda.w	$2A(a1),a6		; Move a6 to next sample
	adda.w	$2A(a1),a6



rep	movea.l	a0,a5
	moveq	#0,d1
toosmal	movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
moverep	move.w	(a3)+,(a0)+		; Repeatsample
	addq.w	#2,d1
	dbra	d0,moverep
	cmp.w	#320,d1			; Must be > 320
	blt.s	toosmal

	move.w	#320/2-1,d2
last320	move.w	(a5)+,(a0)+		; Safety 320 bytes
	dbra	d2,last320

done	add.w	d4,d4

	move.w	d4,$2A(a1)		; length
	move.w	d1,$30(a1)		; Replen
	clr.w	$2E(a1)

samplok	lea	$1E(a1),a1
	dbra	d7,roop

	cmp.l	#workspc,a0
	bgt.s	.nospac

	rts

.nospac	illegal

end_of_samples	DC.L 0

;------------------------------------------------------ Main replayrout --
init	lea	data(pc),a0
	lea	$03B8(a0),a1

	moveq	#$7F,d0
	moveq	#0,d1
loop	move.l	d1,d2
	subq.w	#1,d0
lop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	loop
	dbra	d0,lop2
	addq.b	#1,d2

	lea	samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$043C,d2
	add.l	a0,d2
	movea.l	d2,a2

	moveq	#$1E,d0
lop3	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	adda.l	d1,a2
	adda.l	#$1E,a0
	dbra	d0,lop3

	move.l	a2,end_of_samples	;
	rts

music	lea	data(pc),a0
	addq.w	#$01,counter
	move.w	counter(pc),d0
	cmp.w	speed(pc),d0
	blt.s	nonew
	clr.w	counter
	bra	getnew

nonew	lea	voice1(pc),a4
	lea	aud1lc(pc),a3
	bsr	checkcom
	lea	voice2(pc),a4
	lea	aud2lc(pc),a3
	bsr	checkcom
	lea	voice3(pc),a4
	lea	aud3lc(pc),a3
	bsr	checkcom
	lea	voice4(pc),a4
	lea	aud4lc(pc),a3
	bsr	checkcom
	bra	endr

arpeggio
	moveq	#0,d0
	move.w	counter(pc),d0
	divs	#$03,d0
	swap	d0
	tst.w	d0
	beq.s	arp2
	cmp.w	#$02,d0
	beq.s	arp1

	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	bra.s	arp3

arp1	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	bra.s	arp3

arp2	move.w	$10(a4),d2
	bra.s	arp4

arp3	add.w	d0,d0
	moveq	#0,d1
	move.w	$10(a4),d1
	lea	periods(pc),a0
	moveq	#$24,d4
arploop	move.w	0(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	arp4
	addq.l	#2,a0
	dbra	d4,arploop
	rts

arp4	move.w	d2,$06(a3)
	rts

getnew	lea	data+$043C(pc),a0
	lea	-$043C+$0C(a0),a2
	lea	-$043C+$03B8(a0),a1

	moveq	#0,d0
	move.l	d0,d1
	move.b	songpos(pc),d0
	move.b	0(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1
	clr.w	dmacon

	lea	aud1lc(pc),a3
	lea	voice1(pc),a4
	bsr.s	playvoice
	lea	aud2lc(pc),a3
	lea	voice2(pc),a4
	bsr.s	playvoice
	lea	aud3lc(pc),a3
	lea	voice3(pc),a4
	bsr.s	playvoice
	lea	aud4lc(pc),a3
	lea	voice4(pc),a4
	bsr.s	playvoice
	bra	setdma

playvoice
	move.l	0(a0,d1.l),(a4)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$02(a4),d2
	and.b	#$F0,d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	setregs
	moveq	#0,d3
	lea	samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$01,d2
	asl.l	#2,d2
	mulu	#$1E,d4
	move.l	0(a1,d2.l),$04(a4)
	move.w	0(a2,d4.l),$08(a4)
	move.w	$02(a2,d4.l),$12(a4)
	move.w	$04(a2,d4.l),d3
	tst.w	d3
	beq.s	noloop
	move.l	$04(a4),d2
	add.w	d3,d3
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$04(a2,d4.l),d0
	add.w	$06(a2,d4.l),d0
	move.w	d0,8(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
	bra.s	setregs

noloop	move.l	$04(a4),d2
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
setregs	move.w	(a4),d0
	and.w	#$0FFF,d0
	beq	checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$03,d0
	bne.s	setperiod
	bsr	setmyport
	bra	checkcom2

setperiod
	move.w	(a4),$10(a4)
	andi.w	#$0FFF,$10(a4)
	move.w	$14(a4),d0
	move.w	d0,dmactrl
	clr.b	$1B(a4)

	move.l	$04(a4),(a3)
	move.w	$08(a4),$04(a3)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	move.w	$14(a4),d0
	or.w	d0,dmacon
	bra	checkcom2

setdma	move.w	dmacon(pc),d0

	btst	#0,d0			;-------------------
	beq.s	wz_nch1			;
	move.l	aud1lc(pc),wiz1lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.w	voice1+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len		;
	move.w	d2,wiz1rpt		;
	clr.w	wiz1pos			;

wz_nch1	btst	#1,d0			;
	beq.s	wz_nch2			;
	move.l	aud2lc(pc),wiz2lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.w	voice2+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz2len		;
	move.w	d2,wiz2rpt		;
	clr.w	wiz2pos			;

wz_nch2	btst	#2,d0			;
	beq.s	wz_nch3			;
	move.l	aud3lc(pc),wiz3lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.w	voice3+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz3len		;
	move.w	d2,wiz3rpt		;
	clr.w	wiz3pos			;

wz_nch3	btst	#3,d0			;
	beq.s	wz_nch4			;
	move.l	aud4lc(pc),wiz4lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.w	voice4+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz4len		;
	move.w	d2,wiz4rpt		;
	clr.w	wiz4pos			;-------------------

wz_nch4	addi.w	#$10,pattpos
	cmpi.w	#$0400,pattpos
	bne.s	endr
nex	clr.w	pattpos
	clr.b	break
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1
	cmp.b	data+$03B6(pc),d1
	bne.s	endr
	move.b	data+$03B7(pc),songpos
endr:	tst.b	break
	bne.s	nex
	rts

setmyport
	move.w	(a4),d2
	and.w	#$0FFF,d2
	move.w	d2,$18(a4)
	move.w	$10(a4),d0
	clr.b	$16(a4)
	cmp.w	d0,d2
	beq.s	clrport
	bge.s	rt
	move.b	#$01,$16(a4)
	rts

clrport	clr.w	$18(a4)
rt	rts

myport	move.b	$03(a4),d0
	beq.s	myslide
	move.b	d0,$17(a4)
	clr.b	$03(a4)
myslide	tst.w	$18(a4)
	beq.s	rt
	moveq	#0,d0
	move.b	$17(a4),d0
	tst.b	$16(a4)
	bne.s	mysub
	add.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)

myok	move.w	$10(a4),$06(a3)
	rts

mysub	sub.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	blt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
	move.w	$10(a4),$06(a3)
	rts

vib	move.b	$03(a4),d0
	beq.s	vi
	move.b	d0,$1A(a4)

vi	move.b	$1B(a4),d0
	lea	sin(pc),a1
	lsr.w	#$02,d0
	and.w	#$1F,d0
	moveq	#0,d2
	move.b	0(a1,d0.w),d2
	move.b	$1A(a4),d0
	and.w	#$0F,d0
	mulu	d0,d2
	lsr.w	#$06,d2
	move.w	$10(a4),d0
	tst.b	$1B(a4)
	bmi.s	vibmin
	add.w	d2,d0
	bra.s	vib2

vibmin	sub.w	d2,d0
vib2	move.w	d0,$06(a3)
	move.b	$1A(a4),d0
	lsr.w	#$02,d0
	and.w	#$3C,d0
	add.b	d0,$1B(a4)
	rts

nop:	move.w	$10(a4),$06(a3)
	rts

checkcom
	move.w	$02(a4),d0
	and.w	#$0FFF,d0
	beq.s	nop
	move.b	$02(a4),d0
	and.b	#$0F,d0
	tst.b	d0
	beq	arpeggio
	cmp.b	#$01,d0
	beq.s	portup
	cmp.b	#$02,d0
	beq	portdown
	cmp.b	#$03,d0
	beq	myport
	cmp.b	#$04,d0
	beq	vib
	cmp.b	#$05,d0
	beq	port_toneslide
	cmp.b	#$06,d0
	beq	vib_toneslide
	move.w	$10(a4),$06(a3)
	cmp.b	#$0A,d0
	beq.s	volslide
	rts

volslide
	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	voldown
	add.w	d0,$12(a4)
	cmpi.w	#$40,$12(a4)
	bmi.s	vol2
	move.w	#$40,$12(a4)
vol2	move.w	$12(a4),$08(a3)
	rts

voldown	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	sub.w	d0,$12(a4)
	bpl.s	vol3
	clr.w	$12(a4)
vol3	move.w	$12(a4),$08(a3)
	rts

portup	moveq	#0,d0
	move.b	$03(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$71,d0
	bpl.s	por2
	andi.w	#$F000,$10(a4)
	ori.w	#$71,$10(a4)
por2	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

port_toneslide
	bsr	myslide
	bra.s	volslide

vib_toneslide
	bsr	vi
	bra.s	volslide

portdown
	clr.w	d0
	move.b	$03(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$0358,d0
	bmi.s	por3
	andi.w	#$F000,$10(a4)
	ori.w	#$0358,$10(a4)
por3	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$0D,d0
	beq.s	pattbreak
	cmp.b	#$0B,d0
	beq.s	posjmp
	cmp.b	#$0C,d0
	beq.s	setvol
	cmp.b	#$0F,d0
	beq.s	setspeed
	rts

pattbreak
	st	break
	rts

posjmp	move.b	$03(a4),d0
	subq.b	#$01,d0
	move.b	d0,songpos
	st	break
	rts

setvol	moveq	#0,d0
	move.b	$03(a4),d0
	cmp.w	#$40,d0
	ble.s	vol4
	move.b	#$40,$03(a4)
vol4	move.b	$03(a4),$09(a3)
	move.b	$03(a4),$13(a4)
	rts

setspeed
	cmpi.b	#$1F,$03(a4)
	ble.s	sets
	move.b	#$1F,$03(a4)
sets	move.b	$03(a4),d0
	beq.s	rts2
	move.w	d0,speed
	clr.w	counter
rts2	rts

sin	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18

periods	DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
	DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
	DC.W $F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
	DC.W $7F,$78,$71,$00,$00

speed	DC.W $06
counter	DC.W $00
songpos	DC.B $00
break	DC.B $00
pattpos	DC.W $00

dmacon		DC.W $00
samplestarts	DS.L $1F

voice1	DS.W 10
	DC.W $01
	DS.W 3
voice2	DS.W 10
	DC.W $02
	DS.W 3
voice3	DS.W 10
	DC.W $04
	DS.W 3
voice4	DS.W 10
	DC.W $08
	DS.W 3

