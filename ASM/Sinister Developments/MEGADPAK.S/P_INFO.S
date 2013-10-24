;
;;;;;;;;;;;;;;;;;;
; File type info ;
;;;;;;;;;;;;;;;;;;
;
exec	dc.b	'Executable',0
datafil	dc.b	'Datafile  ',0
pic	dc.b	'Picture   ',0
archive	dc.b	'Archive   ',0
;
;;;;;;;;;;;;;;;
; Packer info ;
;;;;;;;;;;;;;;;
;
;                    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
null	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
_4pak	dc.b	'Packed by 4PACK.',0
	dc.b	'Coded by ???.',0
	dc.b	0,0
arc	dc.b	'This MIGHT be an ARCED file',0
	dc.b	'Try using ARC to decompress.',0
	dc.b	'it!!!',0
atom_3_1	dc.b	'Packed by ATOMIC v3.1.',0
	dc.b	'Coded by Altair.',0
	dc.b	0,0
atom_3_3	dc.b	'Packed by ATOMIC v3.3.',0
	dc.b	'Coded by Altair.',0
	dc.b	0,0
atom_3_5	dc.b	'Packed by ATOMIC v3.5.',0
	dc.b	'Coded by Altair.',0
	dc.b	'THE packer on the ST!',0
aut_2_3r	dc.b	'Packed by AUTOMATION v2.3r.',0
	dc.b	'Coded by Ozz.',0
	dc.b	0,0
aut_2_51	dc.b	'Packed by AUTOMATION v2.51.',0
	dc.b	'Coded by Ozz.',0
	dc.b	0,0
aut_2_3_5	dc.b	'Packed by AUTOMATION v2.3r/51.',0
	dc.b	'Coded by Ozz.',0
	dc.b	0,0
aut_chnk	dc.b	'Packed by AUTOMATION v2.51',0
	dc.b	'Chunk packed file',0
	dc.b	'Coded by EGB',0
aut_5_01	dc.b	'Packed by AUTOMATION v5.01',0
	dc.b	'Coded by EGB/Axe',0
	dc.b	0,0
bapack	dc.b	'Packed by BAPACK',0
	dc.b	'Coded by BRAS',0
	dc.b	0,0
bkill_2	dc.b	'Packed by BYTEKILLER 2',0
	dc.b	'Coded by M.Coates',0
	dc.b	0,0
bkill_3	dc.b	'Packed by BYTEKILLER 3',0
	dc.b	'Coded by M.Coates',0
	dc.b	0,0
dat_np	dc.b	'Probably unpacked.',0
	dc.b	'Unless it''s a new packer.',0
	dc.b	0,0
dat_mp	dc.b	'Possibly packed.',0
	dc.b	'File header is '
fhdr	equ	*+1
	dc.b	'"xxxx".',0
	dc.b	'Send it to me!',0
degas_p	dc.b	'This file is unpacked and the',0
	dc.b	'length shows it to be a DEGAS',0
	dc.b	'picture file.',0		
degas_e	dc.b	'DEGAS ELITE file.',0
	dc.b	'by Tom Hudson.',0
	dc.b	0,0
dcs_1_0	dc.b	'Packed by DCSQUISH v1.0.',0
	dc.b	'Coded by by Double Click S/W.',0
	dc.b	0,0
dcs_1_2	dc.b	'Packed by DCSQUISH v1.2.',0
	dc.b	'Coded by by Double Click S/W.',0
	dc.b	0,0
dcs_1_4	dc.b	'Packed by DCSQUISH v1.4.',0
	dc.b	'Coded by by Double Click S/W.',0
	dc.b	0,0
fire_1	dc.b	'Packed by FIRE v1.',0
	dc.b	'Coded by AXE.',0
	dc.b	0,0
fire_2	dc.b	'Packed by FIRE v2.',0
	dc.b	'Coded by AXE.',0
	dc.b	0,0
gollum	dc.b	'Packed by GOLLUM.',0
	dc.b	0,0
	dc.b	0,0
gollum_h	dc.b	'Packed by GOLLUM.',0
	dc.b	'With Huffmans encoding',0
	dc.b	0,0
happy	dc.b	'Packed by HAPPY packer.',0
	dc.b	'Coded by Ralph Hartmann.',0
	dc.b	0,0
ice_1	dc.b	'Packed by ICE v1.0',0
	dc.b	'Coded by AXE.',0
	dc.b	0,0
ice_1_1	dc.b	'Packed by ICE v1.1.',0
	dc.b	'Coded by AXE.',0
	dc.b	0,0
ice_2_0	dc.b	'Packed by ICE v2.0.',0
	dc.b	'Coded by AXE.',0
	dc.b	0,0
ice_2_2	dc.b	'Packed by ICE v2.2.',0
	dc.b	'Coded by AXE.',0
	dc.b	0,0
ice_2_3	dc.b	'Packed by ICE v2.3.',0
	dc.b	'Coded by AXE.',0
	dc.b	0,0
ice_2_4	dc.b	'Packed by ICE v2.4.',0
	dc.b	'Coded by AXE.',0
	dc.b	0,0
ice_2_3_4	dc.b	'Packed by ICE v2.3/2.4.',0
	dc.b	'Coded by AXE.',0
	dc.b	0,0
idrag	dc.b	'Packed by IVORY DRAGON',0
	dc.b	'Coded by Vermillion Prawn!',0
	dc.b	0,0
iff	dc.b	'IFF file. Use a good art prog',0
	dc.b	'Or Photochrome by Doug!',0
	dc.b	0,0
jam_1	dc.b	'Packed by JAM packer 1.',0
	dc.b	'Coded by Tim & Andrew Knipe.',0
	dc.b	0,0
jam_3	dc.b	'Packed by JAM packer 3.',0
	dc.b	'Coded by Tim & Andrew Knipe.',0
	dc.b	0,0
jam_3_v2	dc.b	'Packed by JAM packer 3.',0
	dc.b	'Using V2 compression',0 
	dc.b	'Coded by Tim & Andrew Knipe.',0
jam_3_lzh	dc.b	'Packed by JAM packer 3.',0
	dc.b	'Using LZH compression',0 
	dc.b	'Coded by Tim & Andrew Knipe.',0
jam_4	dc.b	'Packed by JAM packer 4.',0
	dc.b	'Coded by Tim & Andrew Knipe.',0
	dc.b	0,0
jam_4_v2	dc.b	'Packed by JAM packer 4.',0
	dc.b	'Using v2 compression',0 
	dc.b	'Coded by Tim & Andrew Knipe.',0
jam_4_lzh	dc.b	'Packed by JAM packer 4.',0
	dc.b	'Using LZH compression',0 
	dc.b	'Coded by Tim & Andrew Knipe.',0
jam_4_lzw	dc.b	'Packed by JAM packer 4.',0
	dc.b	'Using LZW compression',0 
	dc.b	'Coded by Tim & Andrew Knipe.',0
jam_4_ice	dc.b	'Packed by JAM packer 4.',0
	dc.b	'Using ICE compression',0 
	dc.b	'Coded by Tim & Andrew Knipe.',0
jam_3_4_lzh
	dc.b	'Packed by JAM packer 3/4.',0
	dc.b	'Using LZH compression',0 
	dc.b	'Coded by Tim & Andrew Knipe.',0
jek_jam	dc.b	'Packed by JEK/JAM v1.',0
	dc.b	'Coded by Tim & Andrew Knipe.',0
	dc.b	0,0
jek_1_2d	dc.b	'Packed by JEK v1.2d.',0
	dc.b	'Coded by Tim & Andrew Knipe.',0
	dc.b	0,0
jek_1_3d	dc.b	'Packed by JEK v1.3d.',0
	dc.b	'Coded by Tim & Andrew Knipe.',0
	dc.b	0,0
lharc1	dc.b	'LHARC -lh1- archive.',0
	dc.b	'Use Thomas Questor''s Lharc to',0
	dc.b	'decompress it!',0
lharc5	dc.b	'LHARC -lh5- archive.',0
	dc.b	'Use Thomas Questor''s Lharc to',0
	dc.b	'decompress it!',0
lsd_1_2_3	dc.b	'Packed by LSD v1.2/1.3.',0
	dc.b	'Coded by Ozz.',0
	dc.b	0,0
lsd_1_2	dc.b	'Packed by LSD v1.2.',0
	dc.b	'Coded by Ozz.',0
	dc.b	0,0
lsd_1_3	dc.b	'Packed by LSD v1.3.',0
	dc.b	'Coded by Ozz.',0
	dc.b	0,0
neo	dc.b	'This file is unpacked and the',0
	dc.b	'length shows it to be a NEO',0
	dc.b	'picture file.',0		
neo_obj	dc.b	'Animation object file.',0
	dc.b	'Created by Neochrome Master.',0
	dc.b	'THE art package! (hi Stefan!).',0
pfx	dc.b	'Packed by PFX packer.',0
	dc.b	'Coded by M.Fritze & T.Questor.',0
	dc.b	0,0
pompey	dc.b	'Packed by POMPEY PIRATES packer',0
	dc.b	'Coded by JPM.',0
	dc.b	0,0
pomp_1_5	dc.b	'Packed by POMPEY PIRATES v1.5',0
	dc.b	'Coded by JPM.',0
	dc.b	0,0
pomp_1_9	dc.b	'Packed by POMPEY PIRATES v1.9',0
	dc.b	'Coded by JPM.',0
	dc.b	0,0
pomp_2_6	dc.b	'Packed by POMPEY PIRATES v2.6',0
	dc.b	'Coded by JPM.',0
	dc.b	0,0
prog_np	dc.b	'Probably unpacked.',0
	dc.b	'Unless it''s a new packer.',0
	dc.b	0,0
prog_pp	dc.b	'Possibly packed!',0
	dc.b	'Send it to me!',0
	dc.b	0,0
qpack_2	dc.b	'Packed by QPACK v2.',0
	dc.b	'Coded by JMP.',0
	dc.b	0,0
rpbkill	dc.b	'Packed by BYTEKILLER.',0
	dc.b	'Coded by Russ Payne.',0
	dc.b	0,0
sent_2_05	dc.b	'Packed by SENTRY v2.05.',0
	dc.b	'Coded by Eagle.',0
	dc.b	0,0
spec_512	dc.b	'SPECTRUM 512 file.',0
	dc.b	'Coded by Antic.',0
	dc.b	'Great ART package.',0 
speed_2	dc.b	'Packed by SPEED packer v2.',0
	dc.b	'Coded by The Firehawks.',0
	dc.b	0,0
speed_3	dc.b	'Packed by SPEED packer v3.',0
	dc.b	'Coded by The Firehawks.',0
	dc.b	'GREAT packer guys!',0

stos	dc.b	'Packed by STOS(tm) packer',0
	dc.b	0,0
	dc.b	0,0
sup	dc.b	'Packed by Superior packer?',0 
	dc.b	'Possibly by AXE.',0
	dc.b	0,0
thun_1	dc.b	'Packed by THUNDER v1.',0
	dc.b	'Coded by JPM.',0
	dc.b	0,0
thun_2	dc.b	'Packed by THUNDER v2.',0
	dc.b	'Coded by JPM.',0
	dc.b	0,0
un_pompey	dc.b	'Unknown version of POMPEY PACKER',0
	dc.b	'Send it to me!',0
	dc.b	0,0
unknown_1	dc.b	'Packed by an UNKNOWN packer.',0
	dc.b	'Any clues folks?',0
	dc.b	0,0
v2_cal2	dc.b	'Packed by vic2 packer.As seen ',0
	dc.b	'on california games2.',0
	dc.b	0,0

zip	dc.b	'PK Zip archive.',0
	dc.b	'Use PK Zip to decompress it.',0
	dc.b	0,0 	
zoo	dc.b	'Zoo archive.',0
	dc.b	'Use Zoo to decompress it.',0
	dc.b	0,0 	
