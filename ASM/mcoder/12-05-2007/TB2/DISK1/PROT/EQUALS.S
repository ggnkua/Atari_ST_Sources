MAMY_CODER	equ	'TOKI'
LENGTH_XOR	equ	$fada

PRO	equ	0
BOOT	equ	1
RELOC	equ	1
BASEPAGE	equ	0
LINK	equ	1
ILLEGAL_TRK	equ	1
ZAR_TRK	equ	2
DUPLIC	equ	1	;Easy duplic flag
DRIVE	equ	0	;Formatting drive (0 or 1)

OCEAN	equ	0
ZARATHUSTRA	equ	1
ALTAIR	equ	0
ILLEGAL	equ	0

ALTAIR_TRK	equ	ZAR_TRK+1
PRG_TRK	equ	4

  IFNE BOOT
SIDE 	equ 	0	;$0101=2eme face
BUFF_TRK	equ	$800	;pour illegal buffer piste gap1
 			;donc retestable si en memoire BOOT
ADDRESS	equ	$16000	;adresse chg programme principal
BUFFER	equ	$16000
SECTOR	equ	1
NB_SEC	equ	40 ;72	;nbre de secteur du prg
SEC_PER_TRK	equ	9


side = SIDE
sct_pro_trk = SEC_PER_TRK
sector = SECTOR
adress = ADDRESS
nbs = NB_SEC
buffer = BUFFER
prg_trk = PRG_TRK
  ENDC

 IFNE BOOT
RELOC_BUFFER	equ	$7fd00	;A $100 bytes long buffer addr for relocator
RELOC_ADDR	equ	$400	;Destination PRG absolute start addr
PRG_ADDR	equ	$20000	;Protect absolute start addr
 ELSEIF
VERIFY	equ	$dec4	;Flopread verif
PRG_LENGTH	equ	76 (49232/512)	;Packed program length
 ENDC

SUPER	equ	1
HZ50	equ	1

	IFEQ DUPLIC
TRK_CHECK	equ	$4235e822
	ELSEIF
TRK_CHECK	equ	$e8748ade
	ENDC
  ;#[ OCEAN Checks:
 IFNE OCEAN
  IFEQ DRIVE
CHECK0	equ	$18ab284d
CHECK1	equ	$4a21298d
CHECK2	equ	$fadafada
CHECK3	equ	$fadafada
CHEKC4	equ	$fadafada
CHECK5	equ	$fadafada
CHECK6	equ	$fadafada
CHECK7	equ	$fadafada
CHECK8	equ	$fadafada
CHECK9	equ	$fadafada
  ELSEIF
CHECK0	equ	$fadafada
CHECK1	equ	$fadafada
CHECK2	equ	$fadafada
CHECK3	equ	$fadafada
CHECK4	equ	$fadafada
CHECK5	equ	$fadafada
CHECK6	equ	$fadafada
CHECK7	equ	$fadafada
CHECK8	equ	$fadafada
CHECK9	equ	$fadafada
  ENDC
 ENDC
  ;#] OCEAN Checks:
  ;#[ ALTAIR Checks:
 IFNE ALTAIR
  IFEQ DRIVE
CHECK0	equ	$1ae497ea
CHECK1	equ	$4523d46a
CHECK2	equ	$16b0ca06
CHECK3	equ	$fadafada
CHECK4	equ	$fadafada
CHECK5	equ	$fadafada
CHECK6	equ	$fadafada
CHECK7	equ	$fadafada
CHECK8	equ	$fadafada
CHECK9	equ	$fadafada
  ELSEIF
CHECK0	equ	$fadafada
CHECK1	equ	$fadafada
CHECK2	equ	$fadafada
CHECK3	equ	$fadafada
CHECK4	equ	$fadafada
CHECK5	equ	$fadafada
CHECK6	equ	$fadafada
CHECK7	equ	$fadafada
CHECK8	equ	$fadafada
CHECK9	equ	$fadafada
  ENDC
 ENDC
  ;#] ALTAIR Checks:
  ;#[ ZARATHUSTRA Checks:
 IFNE ZARATHUSTRA
  IFEQ DRIVE
CHECK0	equ	$6fa13c4c
CHECK1	equ	$a4c02a5c
CHECK2	equ	$0f094dee
CHECK3	equ	$7b078669
CHECK4	equ	$c63d2ce7
CHECK5	equ	$fadafada
CHECK6	equ	$fadafada
CHECK7	equ	$fadafada
CHECK8	equ	$6fa13c4c
CHECK9	equ	$1f4ed6a6
  ELSEIF
CHECK0	equ	$83f60e41
CHECK1	equ	$fadafada
CHECK2	equ	$fadafada
CHECK3	equ	$fadafada
CHECK4	equ	$fadafada
CHECK5	equ	$fadafada
CHECK6	equ	$fadafada
CHECK7	equ	$fadafada
CHECK8	equ	$fadafada
CHECK9	equ	$fadafada
  ENDC
 ENDC
  ;#] ZARATHUSTRA Checks:
  ;#[ ILLEGAL Checks:
 IFNE ILLEGAL
  IFEQ DRIVE
CHECK0	equ	$bc7677f1
CHECK1	equ	$4029280c
CHECK2	equ	$1732a40b
CHECK3	equ	$fadafada
CHECK4	equ	$fadafada
CHECK5	equ	$fadafada
CHECK6	equ	$fadafada
CHECK7	equ	$fadafada
CHECK8	equ	$fadafada
CHECK9	equ	$fadafada
  ELSEIF
CHECK0	equ	$fada
CHECK1	equ	$4029280c
CHECK2	equ	$1732a40b
CHECK3	equ	$fadafada
CHECK4	equ	$fadafada
CHECK5	equ	$fadafada
CHECK6	equ	$fadafada
CHECK7	equ	$fadafada
CHECK8	equ	$fadafada
CHECK9	equ	$fadafada
  ENDC
 ENDC
  ;#] ILLEGAL Checks:
; IFNE BOOT
;;A $100 bytes long buffer addr for relocator
;RELOC_ADDR	equ	$70000
;;Destination PRG absolute start addr
;PRG_ADDR	equ	$20000
; ELSEIF
;Packed program length
;PRG_LENGTH	equ	76	49232
; ENDC

 IFNE PRO
VERIFY	equ	$183f
 ELSEIF
VERIFY	equ	$6721
LINEA	equ	0
LINEF	equ	0
TRAP1	equ	0
TRAP2	equ	0
TRAP13	equ	0
TRAP14	equ	0
KEYBOARD	equ	0
VBLQUEUE	equ	0
VECTORS	equ	0
TIMERS	equ	0
 ENDC

