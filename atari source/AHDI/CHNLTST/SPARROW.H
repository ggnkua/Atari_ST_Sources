/* A set of useful defines for SPARROW */
/* Complied from everybody working on the machine */

#define		Config		((char *) 0xFFFF8006l)
#define		Clock_Sel	((char *) 0xFFFF8007l)
#define		VID_BH		((int *) 0xFFFF8200l)
#define		VID_BM		((int *) 0xFFFF8202l)
#define		VID_BL		((int *) 0xFFFF820Cl)
#define		HOFF		((int *) 0xFFFF820El)	
#define		VWRAP		((int *) 0xFFFF8210l)	
#define		ST_Palette	((int *) 0xFFFF8240l)
#define		ST_Shift	((int *) 0xFFFF8260l)
#define		SP_Shift	((int *) 0xFFFF8266l)
#define		HHT		((int *) 0xFFFF8282l)	/* Horiz Half Total */
#define		HBB		((int *) 0xFFFF8284l)
#define		HBE		((int *) 0xFFFF8286l)
#define		HDB		((int *) 0xFFFF8288l)
#define		HDE		((int *) 0xFFFF828Al)
#define		HSS		((int *) 0xFFFF828Cl)
#define		HFS		((int *) 0xFFFF828El)
#define		HEE		((int *) 0xFFFF8290l)
#define		VFT		((int *) 0xFFFF82A2l)
#define		VBB		((int *) 0xFFFF82A4l)
#define		VBE		((int *) 0xFFFF82A6l)
#define		VDB		((int *) 0xFFFF82A8l)
#define		VDE		((int *) 0xFFFF82AAl)
#define		VSS		((int *) 0xFFFF82ACl)
#define		VMC		((int *) 0xFFFF82C0l)
#define		VCO		((int *) 0xFFFF82C2l)
#define		SP_Palette	((int *) 0xFFFF9800l)

/* Equates file for Testing of SPARROW sound DMA channels */

#define		s_dma_ctl	((char *) 0xFFFF8901l)
#define		 REC_SET	0x80
#define		 PLAY_SET	0x00
#define		 REC_REP	0x20
#define		 REC_SINGLE	0x00
#define		 REC_ENABLE	0x10
#define		 PLAY_REP	0x02
#define		 PLAY_SINGLE	0x00
#define		 PLAY_ENABLE	0x01

#define		f_b_um		((char *) 0xFFFF8903l)
#define		f_b_lm		((char *) 0xFFFF8905l)
#define		f_b_ll		((char *) 0xFFFF8907l)

#define		f_a_um		((char *) 0xFFFF8909l)
#define		f_a_lm		((char *) 0xFFFF890Bl)
#define		f_a_ll		((char *) 0xFFFF890Dl)

#define		f_e_um		((char *) 0xFFFF890Fl)
#define		f_e_lm		((char *) 0xFFFF8911l)
#define		f_e_ll		((char *) 0xFFFF8913l)

/* Note this block of registers exist
   only in the Falcon version of this chip */
#define		f_b_uu		((char *) 0xFFFF8915l)
#define		f_a_uu		((char *) 0xFFFF8917l)
#define		f_e_uu		((char *) 0xFFFF8919l)

#define		s_mode_ctl	((short *) 0xFFFF8920l)
#define		 M_CHAN_0	0x0000
#define		 M_CHAN_1	0x1000
#define		 M_CHAN_2	0x2000
#define		 M_CHAN_3	0x3000
#define		 M_CHAN_4	0x4000
#define		 M_CHAN_OFF	0x7000
#define		 M_CHAN_MASK	0x7000

#define		 A_CHAN_1	0x0000
#define		 A_CHAN_2	0x0100
#define		 A_CHAN_3	0x0200
#define		 A_CHAN_4	0x0300
#define		 A_CHAN_5	0x0400
#define		 A_CHAN_MASK	0x0700

#define		 MONO_MODE	0x0080
#define		 WORD_MODE	0x0040

#define		 S_RT_160	0x0003
#define		 S_RT_320	0x0002
#define		 S_RT_640	0x0001
#define		 S_RT_1280	0x0000
#define		 S_RT_MASK	0x0003

#define		uwire_data	((short *) 0xFFFF8922l)
#define		uwire_mask	((short *) 0xFFFF8924l)

#define		MAX_CHANNELS	5

#define		SND		0x8000
#define		INPUT_SELECT	0x0000
#define		 PSG_OFF	0x0000
#define		 PSG_EN		0x0020
#define		 PSG_DIS	0x0040
#define		BASS		0x0800
#define		 FLAT		0x00C0
#define		TREBLE		0x1000
#define		VOLUME		0x1800
#define		 V_FULL		0x0500
#define		RIGHT_FADE	0x2000
#define		 FADE_OFF	0x0280
#define		LEFT_FADE	0x2800
#define		SCALE		0x3000
#define		CONTROL		0x3800
#define		 MHZ8		0x0200
#define		 MIX_AUX	0x0080
#define		 MUX_AUX	0x0060
#define		 MUX_ADC	0x0040
#define		 MUX_IN		0x0020
#define		MASK		0xFFE0

#define		NULL		0
