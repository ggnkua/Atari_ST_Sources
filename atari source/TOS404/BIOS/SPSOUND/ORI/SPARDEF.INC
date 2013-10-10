; *********************************************************************
;
; SPARDEF.INC	Sparrow sound definition file.
;
;
;	Started:	02/04/92
;	Last Update:	
;
;	Copyright Atari Corporation 1992
;
;  Equates file for FX-1
;
;
; *********************************************************************
;
;
;

FALCON = 1	; Set to one for FALCON


; Sound REGISTER one the..."Sound DMA control".
; NOTES:
;	The computer reads this register when sound is turned "ON". Some
;	teck kind of guy told me this I wondered if it is shadowed tooooo.
;
;
; *********************************************************************
; snd_modectl	Selects the types of operation modes See below...
;		
;
;-------------------------------------------------------------------------


snd_modectl	=	$00ff8920	; Sound tracks/perscaler/playmode

	.text
;-------------------------------------------------------------------------
;
; snd_modectl	16-BIT Register layout:
;
;		D15    8 7     D0
;               0---0---|--0000--
;		 PMS PTS MD    PC 
;
;		PMS	Playback "monitor speaker" choice.
;		PTS	Playback number of tracks choice.
;		 MD	Play Modes 8-bit_stereo...
;		 PC	prescaller for sample rate.
;		  0	Zero and should remain that way.
;
;
;
; What follows are the options that can be or's together to set the mode
; control register.
;
;
; Theses are the "monitor" speaker channel listening choices. You 
; get to listen to ONE of theses.

MON0_CHAN	=	$0	; Channel the monitors monitors.
MON1_CHAN	=	$1
MON2_CHAN	=	$2
MON3_CHAN	=	$3
MON4_CHAN	=	$4
MON_OFF		=	$7

; Theses are the "How many channel at once did you say... setting.
; I winder what NONE (7) done No tracks. You can choise up to 5 tracks.
; See documentation for data format. Yuk!

SAM_1280_RATE	=	$0		; Prescaler rates for clock input
SAM_640_RATE	=	$1
SAM_320_RATE	=	$2
SAM_160_RATE	=	$3

;
; Type of play/record mode we are performing
;
BIT8_STEREO	=	$0		; 8-bit stereo mode
BIT16_STEREO	=	$1		; 16-bit stereo mode.
BIT8_MONO	=	$2		; 8-bit mono mode


;
; How many active channels we are dealing with.
;
NUM01_CHAN	=	$0		; Active number of channels the
NUM02_CHAN	=	$1		;The system is trying to handle.
NUM03_CHAN	=	$2
NUM04_CHAN	=	$3
NUM05_CHAN	=	$4
NO_CHAN		=	$7		; I DO NOT KNOW THAT THIS MEANS YET.



;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;<<<<<<<<<<<  NEXT HARDWARE LOCATION AND IT'S OPTIONS.      >>>>>>>>>>>>>>>>>>>>>
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


; *********************************************************************
; snd_dmactl	Sound DMA controler.  There are a number of these options
;		Controls dma off sound in, out, and through (yes throuh)
;		
;		16-BIT Register layout:
;
;		D15    8 7     D0
;               0000----|-0--00--
;		    SISC|| ||  ||_> Playback DMA enable. (1 enabled)
;		         | ||  |__> Playback frame repeat. (0 single frame)
;		         | ||_____> Record enable.
;		         | |______> Record frame repeat.
; 			 |________> Register set selection bit (VERY IMPORTANT)
;					This is how we create "sound through".
;					If(0) playback locations addressse.
;					If (1) record location addresses.
;					Must deal with 16byte FIFO.
;
;	SI	SINT Source select(??????????????)
;	SC	SCNT SCNT source select. (>??????????????????) KLUDGE
;
;
;	QUESTION WHEN IS THIS LOCATION READ?????? KLUDGE
;
;
;-------------------------------------------------------------------------



snd_dmsctl	=	$00ff8900	;Sound DMA control register.


; *********************************************************************
; SND_DMSCTL 	control options.
; *********************************************************************
PE	=	$0
PF	=	$1
RE	=	$4
RF	=	$5
RS	=	$7

; *********************************************************************
; SND_DMSCTL 	Interrupt source selection
; *********************************************************************
INTOFF		=	0
INTPLAY		=	1
INTRECORD	=	2
INTPLAYREC	=	3


; *********************************************************************
; Sound buffer Play and Record locations.
; *********************************************************************

ST_SNDL		=	$FF8906		; Starting location of sound buffer.
ST_SNDM		=	$FF8904
ST_SNDH		=	$FF8902
;
CUR_SNDL	=	$FF890C		; Current buffer location.
CUR_SNDM	=	$FF890A
CUR_SNDH	=	$FF8908
;
END_SNDL	=	$FF8912		; Ending location of sound buffer.
END_SNDM	=	$FF8910
END_SNDH	=	$FF890e

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;<<<<<<<<<<<  NEXT HARDWARE LOCATION AND IT'S OPTIONS.      >>>>>>>>>>>>>>>>>>>>>
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; *********************************************************************
; src_pathclk	Source data and clock matrix (RW)
;		Register layout:
;
;		d15        d8 d7              d0
;		 |00b0|  0abh|   tabh  |   sabh|
;                | ADC|EXTINP| DSPXMIT |DMAPLAY|
;	OR
;	       headphones,external connector,DSP receive,DMA record
;
;
;	ab - Clock selector.
;	     00 - Internal 25.175MHz (codec)
;	     01 - External           (codec)
;	     10 - Internal 32MHz (DSP dependent)
;	     11 - Reserved
;
;	t - Tristate DSP output bus
;	h - (1) disables handshake,
;	s - Handshake source (0) - DSPRECV, (1) - EXTOUT
;
;
; *********************************************************************
src_pathclk	=	$FF8930

; *********************************************************************
; recv_pathclk	Receive data and clock matrix (RW)
;		Register layout:
;
;		d15        d8 d7              d0
;		 |0ab0|  0abh|   tabh  |   sabh|
;                | DAC|EXTOUT| DSPRECV |DMAREC |
;	OR
;	       headphones,external connector,DSP receive,DMA record
;
;
;	ab - Source Device data and clock.
;	     00 - DMAPLAY (DMA out)
;	     01 - DSPXMIT (DSP transmit)
;	     10 - EXTINP   (External port input)
;	     11 - MICPSG  (ADC)
;
;	t - Tristate DSP input bus
;	h - (1) disables handshake,
;	s - Handshake source (0) - DSPXMIT, (1) - EXTINP
;
; *********************************************************************
recv_pathclk	=	$FF8932

; *********************************************************************
; prescale	Prescaler for internal and external clocks. (RW)
;		Register layout:
;
;		d15      d8 d7      d0
;		 |0000|iiii|0000|eeee|
;
;		i - Internal clock prescaler.
;		e - External clock prescaler.
;
; *********************************************************************
prescale	=	$FF8934

; *********************************************************************
; dacrec_ctl	DAC (headphones) control word. Also ocontrols
;		PSG input, Record track number, global reset, and
;		Output to headphones (internal speaker).
;		Register layout:
;
;		d15      d8 d7      d0
;		 |0000|00rr|0000|RPSE|
;
;		r - Record tracks 0 - 3
;		R - (1) Reset sound subsection FF8900 -FF8934 (clears)
;		P - (1) PSG source	0 Selects serial data from PSG
;					1 Selects serial data from codec
;		S - (1) Sound enable to headphones and internal speaker.
;		E - (1) Enable PSG sound to DAC (headphones,internal speaker).
;
; *********************************************************************
dacrec_ctl	=	$FF8936

; *********************************************************************
; auxa_ctl	Aux port A conntrol field. Register layout is:
;
;		d15      d8 d7        d0
;		 |llll|EMmm|Lgain|Rgain|
;
;		l - Left sample bits 16 - 19
;		E - Expantion bit (No expantion on this rev (0)
;		M - Mute control 1 = Mute output.
;		m - Mux control (00) Mic input (11) PSG input.
;		Lgain - Gain increments in 1.5 db 0xF = +22.5 dB
;		Rgain - Gain increments in 1.5 db 0xF = +22.5 dB
;
; *********************************************************************
auxa_ctl	=	$FF8938

; *********************************************************************
; auxb_ctl	Port on the ASCO 2300. Used to control volume of
;		the codec. Register layout is:
;		d15           d8 d7            d0
;		 |     |  Left  | Right |	|
;
;		Attenuation (volume) is in 1.5 dB increments
;		0x0 = 0.0, 0xF = -22.5dB
;
;	Also see ASCO 2300 Spec.
; *********************************************************************
auxb_ctl	=	$FF893A

; *********************************************************************
; auxa_inp	Port on the ASCO 2300. Used to report the status 
;		condition on the codec. Register layout is:
;		d15      d8 d7      d0
;		 |llll|EVOO|SSSS|RRRR|
;
;		l - Left sample bits 16 - 19
;		E - Expantion bit (No expantion on this rev (0)
;		V - Valid data from ADC after powerup or mute.
;		O - Overflow Indicates clipping has occured.
;		S - Status	00 = No error.
;				01 = control word invalid data still valid.
;				10 = Data format error. Results in mute.
;				11 = Serial clock out of range Results in mute.
;
;	Also see ASCO 2300 Spec.
; *********************************************************************
auxa_inp	=	$FF893C

; *********************************************************************
; auxb_inp	Not Used.
; *********************************************************************
auxb_inp	=	$FF893C


; *********************************************************************
; gpio_ctl	General purpose I/O registor on the DSP port
;		Only bits d0-d2 are used. Setting them to a 1
;		indicates data bit is an output.
; *********************************************************************
gpio_ctl	=	$FF8940

; *********************************************************************
; gpio_data	General purpose I/O registor on the DSP port
;		This port is controled by the gpio_ctl register.
;		Only bits d0-d2 are used. Once written they remain until
;		written to again.
; *********************************************************************
gpio_data	=	$FF8942




