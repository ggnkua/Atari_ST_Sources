
mirqs_blength	equ	1024
mirqs_bmask	equ	1023

; datenstruktur mirqs_data
mirqs_posread	equ	0
mirqs_possave	equ	2
mirqs_dlength	equ	4

; datenstruktur midi_dat
midi_pos	equ	0	; position des falcon im token-ring (master = 0)
midi_anz	equ	2	; anzahl an falcons im token-ring
midi_anzm1	equ	4	; anzahl an falcons im token-ring (-1)
midi_mode	equ	6	; -1 = slave, 1 = master
midi_connected	equ	8	; verbindungsflag
midi_level_flag	equ	10	; flag, ob gueltiger level vorliegt

; erweiterte datenstruktur mon_dat
mon_midi_x	equ	96
mon_midi_y	equ	100
mon_midi_sector	equ	104
mon_midi_sh	equ	106
mon_midi_alpha	equ	107
mon_midi_walk	equ	108
mon_midi_shoot	equ	109
mon_midi_hit	equ	110
mon_midi_die	equ	111
mon_midi_name	equ	112	; namenslaenge: 11 bytes + nullzeichen
mon_midi_length	equ	124-96

m0_counter	equ	3

m1_anz		equ	3

m3_falcon	equ	3
m3_name		equ	4	; adresse muss gerade sein!

m10_spieler	equ	3
m10_sector	equ	4
m10_sx		equ	5
m10_sy		equ	8
m10_sh		equ	11
m10_salpha	equ	12
m10_walk_flag	equ	13

m11_wer		equ	3
m11_wen		equ	4
m11_energy_loss	equ	5

m12_wer		equ	3

m13_wer		equ	3

m20_sector	equ	3
m20_door	equ	4

m21_sector	equ	3
m21_door	equ	4

m22_sector	equ	3

m23_sector	equ	3

m24_sector	equ	3
m24_item	equ	4

m25_sector	equ	3
m25_item	equ	4
