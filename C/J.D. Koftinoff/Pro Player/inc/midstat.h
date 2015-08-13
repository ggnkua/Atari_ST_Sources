

#ifndef __MIDI_STATUS_H
#define __MIDI_STATUS_H

#define M_NOTE_OFF	0x80
#define M_NOTE_ON	0x90
#define M_P_AFTER	0xa0
#define M_CONTROL	0xb0
#define M_PG		0xc0
#define M_C_AFTER	0xd0
#define M_BENDER	0xe0

#define M_EXCL		0xf0
#define M_EOX		0xf7

#define M_TUNE		0xf6
#define M_SPP		0xf2
#define M_SONG		0xf3
#define M_CLOCK		0xf8
#define M_START		0xfa
#define M_CONTINUE	0xfb
#define M_STOP		0xfc

#define M_SENSE		0xfe
#define M_RESET		0xff


// controller numbers:

#define MC_GSS			0x00
#define MC_MOD			0x01

#define MC_HOLD			0x40

#define MC_RESET		0x79
#define MC_LOCAL		0x7a
#define MC_ALL_NOTES_OFF	0x7b
#define MC_OMNI_OFF		0x7c			// controller # byte
#define MC_OMNI_ON		0x7d
#define MC_MONO			0x7e
#define MC_POLY			0x7f

#endif
