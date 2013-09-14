; Sound DMA registers

SNDCTRL	    equ	    $ffff8901		; control register
REC_SET	    equ	    $80
PLAY_SET    equ	    0
REC_REP	    equ	    $20
REC_SINGLE  equ	    $00
REC_ENABLE  equ	    $10
PLAY_REP    equ	    $02
PLAY_SINGLE equ	    $00
PLAY_ENABLE equ	    $01

SFBHI	    equ	    $ffff8903		; Sound frame base addr high byte
SFBMID	    equ	    SFBHI+2		; Sound frame base addr middle byte
SFBLOW	    equ	    SFBMID+2		; Sound frame base addr low byte

SFAHI	    equ	    $ffff8909		; Sound frame addr high byte
SFAMID	    equ	    SFAHI+2		; Sound frame addr middle byte
SFALOW	    equ	    SFAMID+2		; Sound frame addr low byte

SFTHI	    equ	    $ffff890f		; Sound frame top addr high byte
SFTMID	    equ	    SFTHI+2		; Sound frame top addr middle byte
SFTLOW	    equ	    SFTMID+2		; Sound frame top addr low byte

CLKSRC	    equ	    $ffff8930		; clock source
DATAMTRX    equ	    $ffff8932		; data matrix - receive

SNDMODE	    equ	    $ffff8920		; mode register
M_CHAN_0    equ	    $0000
M_CHAN_1    equ	    $1000
M_CHAN_2    equ	    $2000
M_CHAN_3    equ	    $3000
M_CHAN_4    equ	    $4000
M_CHAN_OFF  equ	    $7000
M_CHAN_MASK equ	    $7000

A_CHAN_1    equ	    $0000
A_CHAN_2    equ	    $0100
A_CHAN_3    equ	    $0200
A_CHAN_4    equ	    $0300
A_CHAN_5    equ	    $0400
A_CHAN_MASK equ	    $0700

MONO_MODE   equ	    $0080
WORD_MODE   equ	    $0040

S_RT_160    equ	    $0003
S_RT_320    equ	    $0002
S_RT_640    equ	    $0001
S_RT_1280   equ	    $0000
S_RT_MASK   equ	    $0003

UWDATA	    equ	    $ffff8922		; MicroWire data register
UWMASK	    equ	    $ffff8924		; MicroWire mask register

VID_BH	    equ	    $ffff8201
VID_BM	    equ	    $ffff8203
VID_BL	    equ	    $ffff820d


