main:
  move.l	#$0,-(sp)
  move.w	#$20,-(sp)
  trap	#$1
  addq.l	#$6,sp

prepare_image:
  move.l	#image,a0
  move.l	#gland,a1
  move.w	#164,d0	; 165 mots pour l' image 1 bitplan.
.copy:
  move.w	(a0),(a1)+
  addq.l	#$8,a0
  dbra	d0,.copy

print_message:
  pea	text
  move.w	#$9,-(sp)
  trap	#$1
  addq.l	#$6,sp

wait_a_key:
  move.w	#$7,-(sp)	; Attend une touche.
  trap	#$1
  addq.l	#$2,sp

  cmp.w	#" ",d0	; Space appuye?
  beq.s	load_old_boot

exit_program:
  clr.w	-(sp)
  trap	#$1

load_old_boot:
  move.w	#1,-(sp)	; Lire un secteur.
  move.w	#0,-(sp)	; Face 0.
  move.w	#0,-(sp)	; Piste 0.
  move.w	#1,-(sp)	; Secteur 1.
  move.w	#0,-(sp)	; Disquette A.
  clr.l	-(sp)
  move.l	#old_boot,-(sp)	; Buffer.
  move.w	#$8,-(sp)
  trap	#$e	; Floppy read.
  add.l	#20,sp

copy_boot_code_and_image:
  move.l	#bootsector,a0
  move.l	#old_boot+$3a,a1
  move.w	#511,d0	; On va copier un peu trop.
.copy:
  move.b	(a0)+,(a1)+
  dbra	d0,.copy

  move.w	#$6038,old_boot	; Instruction de branch.

checksum:		; Faut que le total fasse $1234.
  move.l	#old_boot,a0
  moveq.l	#$0,d0
  move.l	#254,d1	; On additione 255 mots.
.add_one_word:
  add.w	(a0)+,d0
  dbra	d1,.add_one_word

  move.w	#$1234,d1	; On calcule ce que le 256eme mot doit
  sub.w	d0,d1	; valoir pour que le checsum=$1234.
  move.w	d1,(a0)	; Puis on le met dans le boot.

save_new_boot:
  move.w	#1,-(sp)	; Ecrire un secteur.
  move.w	#0,-(sp)	; Face 0.
  move.w	#0,-(sp)	; Piste 0.
  move.w	#1,-(sp)	; Secteur 1.
  move.w	#0,-(sp)	; Disquette A.
  clr.l	-(sp)
  move.l	#old_boot,-(sp)	; Buffer.
  move.w	#$9,-(sp)
  trap	#$e	; Floppy read.
  add.l	#20,sp

  bra	wait_a_key	; Another boot to install?

text:
  dc.b	'Bootsector by Dracula of Positivity.',$d,$a
  dc.b	'',$d,$a
  dc.b	'Press <space> to install bootsector.',$d,$a
  dc.b	'',$d,$a
  dc.b	'',$d,$a
  dc.b	'           ',$d,$a,$0

 even

image:
  incbin	'a:\48x55.xxx'

; *********** Le code et l' image pour le futur bootsecteur. ************

bootsector:
  pea	.text(pc)	; Affiche le texte.
  move.w	#$9,-(sp)
  trap	#$1
  addq.l	#$6,sp
  move.w	#$075,$ffff8242.w ; Logo en vert "gland".
  lea	gland(pc),a0	; Adresse de l' image.
  move.l	$44e.w,a1  	; Adresse de la ramvideo.
  moveq.l	#54,d0	; 55 lignes.
.one_line:
  move.w	(a0)+,(a1)	; 3 mots pour 48 pixels.
  move.w	(a0)+,$8(a1)
  move.w	(a0)+,$10(a1)
  add.w	#$a0,a1
  dbra	d0,.one_line
.test_resvector:
  cmp.l	#$31415926,$426.w ; Reset vector validated?
  beq.s	.virus
  bclr.b	#$0,$484.w	; Fuck the key click.
  rts

.virus:
  move.w	#$500,$ffff8240.w
.stop_all:
  nop
  bra.s	.stop_all

.text:
  dc.b	'        Boot by Dracula.',$d,$a,$0

 even

gland:		; L' image fait 48*55 en un bitplan.
  ds.w	165	; Soit 330 octets.

  ds.w	200

;*************************************************************************

  Section BSS

old_boot:		; Un bootsecteur=512 octets.
  ds.w	256

  ds.w	256	; Un petit extra.
