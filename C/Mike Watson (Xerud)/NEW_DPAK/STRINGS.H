/*****************************************************************************
** Possible file types
****************************************************************************
*/
char	exec_info[]="Executable";
char	data_info[]="Datafile";
char	pic_info[]="Picture";
char	arc_info[]="Archive";
/*
****************************************************************************
** Possible packers & info
****************************************************************************
*/
char	blank[]="";

char	atom_3_1[][39]={
		"Packed by ATOMIC v3.1.",
		"Coded by Altair."};

char	atom_3_3[][39]={
		"Packed by ATOMIC v3.3.",
		"Coded by Altair."};

char	bmt_3_3[][39]={
		"Packed by ATOMIC v3.3.",
		"Coded by Altair.",
		"The BMT fix!"};

char	atom_3_5[][40]={	
		"Packed by ATOMIC v3.5.",
		"Coded by Altair.",
		"Ace packer!"};

char	_4pak[][39]={
		"Packed by 4PACK.",
		"Coded by ???."};
	
char	arc[][39]={
		"This MIGHT be an ARCED file",
		"Try using ARC to decompress.",
		"it!!!"};

char	aut_2_3r[][39]={
		"Packed by AUTOMATION v2.3r.",
		"Coded by Ozz."};
	
char	aut_2_51[][39]={
		"Packed by AUTOMATION v2.51.",
		"Coded by Ozz."};
	
char	aut_2_3_5[][39]={
		"Packed by AUTOMATION v2.3r/51.",
		"Coded by Ozz."};
	
char	aut_chnk[][39]={
		"Packed by AUTOMATION v2.51",
		"Chunk packed file",
		"Coded by EGB"};

char	aut_chnk2[][39]={
		"Packed by AUTOMATION v5.01",
		"Chunk packed file",
		"Coded by EGB/AXE"};

char	aut_5_01[][39]={
		"Packed by AUTOMATION v5.01",
		"Coded by EGB/Axe"};
	
char	bapack[][39]={
		"Packed by BAPACK",
		"Coded by BRAS"};
	
char	bkill_2[][39]={
		"Packed by BYTEKILLER 2",
		"Coded by M.Coates"};
	
char	bkill_3[][39]={
		"Packed by BYTEKILLER 3",
		"Coded by M.Coates"};

char	bkill_jpm[][39]={
		"Packed by BYTEKILLER",
		"Coded by JPM"};
	
char	dat_np[][39]={
		"Probably unpacked.",
		"Unless it""s a new packer."};
	
char	dat_pp[][39]={
		"Possibly packed.",
		"File header is xxxx.",
		"Send it to me!."};
	
char	degas_p[][39]={
		"This file is unpacked and the",
		"length shows it to be a DEGAS",
		"picture file."};		

char	degas_e[][39]={
		"DEGAS ELITE file.",
		"by Tom Hudson."};
	
char	dcs_1_0[][39]={
		"Packed by DCSQUISH v1.0.",
		"Coded by by Double Click S/W."};
	
char	dcs_1_2[][39]={
		"Packed by DCSQUISH v1.2.",
		"Coded by by Double Click S/W."};
	
char	dcs_1_4[][39]={
		"Packed by DCSQUISH v1.4.",
		"Coded by by Double Click S/W."};
	
char	dcs_2_0[][39]={
		"Packed by DCSQUISH v2.0.",
		"Coded by by Double Click S/W."};
	
char	fire_1[][39]={
		"Packed by FIRE v1.",
		"Coded by AXE."};
	
char	fire_2[][39]={
		"Packed by FIRE v2.",
		"Coded by AXE."};
	
char	gollum[][39]={
		"Packed by GOLLUM."};
	
char	gollum_h[][39]={
		"Packed by GOLLUM.",
		"With Huffmans encoding"};

char	gremlin[][39]={
		"Packed by Gremlin Packer.",
		"By Fungus the bogeyman!"};
	
char	happy[][39]={
		"Packed by HAPPY packer.",
		"Coded by Ralph Hartmann."};
	
char	ice_1[][39]={
		"Packed by ICE v1.0",
		"Coded by AXE."};
	
char	ice_1_1[][39]={
		"Packed by ICE v1.1.",
		"Coded by AXE."};
	
char	ice_2_0[][39]={
		"Packed by ICE v2.0.",
		"Coded by AXE."};
	
char	ice_2_2[][39]={
		"Packed by ICE v2.2.",
		"Coded by AXE."};
	
char	ice_2_3[][39]={
		"Packed by ICE v2.3.",
		"Coded by AXE."};
	
char	ice_2_4[][39]={
		"Packed by ICE v2.4.",
		"Coded by AXE."};
	
char	ice_2_3_4[][39]={
		"Packed by ICE v2.3/2.4.",
		"Coded by AXE."};

char	imp[][39]={
		"Packed by IMP! packer."};
	
char	idrag[][39]={
		"Packed by IVORY DRAGON",
		"Coded by Vermillion Prawn!"};
	
char	iff[][39]={
		"IFF file. Use a good art prog",
		"Or Photochrome by Doug!"};
char	jpak[][39]={
		"Packed by Jpack.",
		"Might be by ACF?"};
	
char	jam_1[][39]={
		"Packed by JAM packer 1.",
		"Coded by Tim & Andrew Knipe."};
	
char	jam_3[][39]={
		"Packed by JAM packer 3.",
		"Coded by Tim & Andrew Knipe."};
	
char	jam_3_v2[][39]={
		"Packed by JAM packer 3.",
		"Using V2 compression", 
		"Coded by Tim & Andrew Knipe."};

char	jam_3_lzh[][39]={
		"Packed by JAM packer 3.",
		"Using LZH compression", 
		"Coded by Tim & Andrew Knipe."};

char	jam_4[][39]={
		"Packed by JAM packer 4.",
		"Coded by Tim & Andrew Knipe."};
	
char	jam_4_v2[][39]={
		"Packed by JAM packer 4.",
		"Using v2 compression", 
		"Coded by Tim & Andrew Knipe."};

char	jam_4_lzh[][39]={
		"Packed by JAM packer 4.",
		"Using LZH compression", 
		"Coded by Tim & Andrew Knipe."};

char	jam_4_lzw[][39]={
		"Packed by JAM packer 4.",
		"Using LZW compression", 
		"Coded by Tim & Andrew Knipe."};

char	jam_4_ice[][39]={
		"Packed by JAM packer 4.",
		"Using ICE compression", 
		"Coded by Tim & Andrew Knipe."};

char	jam_3_4_lzh[][39]={
		"Packed by JAM packer 3/4.",
		"Using LZH compression", 
		"Coded by Tim & Andrew Knipe."};

char	jek_jam[][39]={
		"Packed by JEK/JAM v1.",
		"Coded by Tim & Andrew Knipe."};
	
char	jek_1_2d[][39]={
		"Packed by JEK v1.2d.",
		"Coded by Tim & Andrew Knipe."};
	
char	jek_1_3d[][39]={
		"Packed by JEK v1.3d.",
		"Coded by Tim & Andrew Knipe."};

char	LeCr[][39]={
		"Atlantis S/W Le Crunch."};
	
char	lharc[][39]={
		"LHARC archive.",
		"Use Lharc to decompress it!"};

char	lsd_1_2_3[][39]={
		"Packed by LSD v1.2/1.3.",
		"Coded by Ozz."};
	
char	lsd_1_2[][39]={
		"Packed by LSD v1.2.",
		"Coded by Ozz."};
	
char	lsd_1_3[][39]={
		"Packed by LSD v1.3.",
		"Coded by Ozz."};
	
char	mpack[][39]={
		"Packed by Mpack ",
		"Coded by Mcoder - neat prog."};

char	neo[][39]={
		"This file is unpacked and the",
		"length shows it to be a NEO",
		"picture file."};		

char	neo_obj[][39]={
		"Animation object file.",
		"Created by Neochrome Master.",
		"THE art package! (hi Stefan!)."};

char	pa[][39]={
		"Packed by PA packer.",
		"Coded by Keith Baines."};
	
char	ppack2[][39]={
		"Packed by power packer2.",
		"Something from the AMIGA!!"};
	
char	pfx[][39]={		
		"Packed by PFX packer.",
		"Coded by M.Fritze & T.Questor."};
	
char	pompey[][39]={
		"Packed by POMPEY PIRATES packer",
		"Coded by JPM."};
	
char	pomp_1_5[][39]={
		"Packed by POMPEY PIRATES v1.5",
		"Coded by JPM."};
	
char	pomp_1_9[][39]={
		"Packed by POMPEY PIRATES v1.9",
		"Coded by JPM."};

char	pomp_2_3[][39]={
		"Packed by POMPEY PIRATES v2.3",
		"Coded by JPM."};
	
char	pomp_2_6[][39]={
		"Packed by POMPEY PIRATES v2.6",
		"Coded by JPM."};
	
char	pomp_3_0[][39]={
		"Packed by POMPEY PIRATES v3.0",
		"Coded by JPM."};
	
char	prog_np[][39]={
		"Probably unpacked.",
		"Unless it""s a new packer."};
	
char	prog_pp[][39]={
		"Possibly packed!",
		"Send it to me!"};
	
char	qpack_2[][39]={
		"Packed by QPACK v2.",
		"Coded by JMP."};
	
char	rnc1[][39]={
		"Packed by RNC packer1.",
		"Coded by R.Northern."};

char	rnc2[][39]={
		"Packed by RNC packer2.",
		"Coded by R.Northern."};

char	rncc[][39]={
		"Packed by Copylock packer.",
		"Coded by R.Northern."};
	
char	rpbkill[][39]={
		"Packed by BYTEKILLER.",
		"Coded by Russ Payne."};

char	scared[][39]={
		"No way, I\'m scared!!"};

char	sent_2_05[][39]={
		"Packed by SENTRY v2.05.",
		"Coded by Eagle."};

char	sent_2_11[][39]={
		"Packed by SENTRY v2.11.",
		"Coded by Eagle."};
	
char	spec_512[][39]={
		"SPECTRUM 512 file.",
		"Coded by Antic.",
		"Great ART package."}; 

char	speed_2[][39]={
		"Packed by SPEED packer v2.",
		"Coded by The Firehawks."};
	
char	speed_3[][39]={
		"Packed by SPEED packer v3.",
		"Coded by The Firehawks.",
		"GREAT packer guys!"};

char	stos[][39]={
		"Packed by STOS(tm) packer"};
	
char	sup[][39]={
		"Packed by Superior packer?", 
		"Coded by AXE?"};
	
char	sup3[][39]={
		"Packed by Super packer3", 
		"Coded by INGO RUDDAT."};

char	thun_1[][39]={
		"Packed by THUNDER v1.",
		"Coded by JPM."};

char	thun_1_1[][39]={
		"Packed by THUNDER v1.1",
		"Coded by JPM."};
	
char	thun_2[][39]={
		"Packed by THUNDER v2.",
		"Coded by JPM."};
	
char	un_pompey[][39]={
		"Unknown version of POMPEY PACKER",
		"Send it to me!"};
	
char	unknown_1[][39]={
		"Packed by an UNKNOWN packer.",
		"Any clues folks?"};
	
char	vic2[][39]={
		"Packed by VIC2 packer."};

char	zip[][39]={
		"ZIP archive.",
		"Use ZIP to decompress it."};
	 	
char	zoo[][39]={
		"ZOO archive.",
		"Use ZOO to decompress it."};
	 	
