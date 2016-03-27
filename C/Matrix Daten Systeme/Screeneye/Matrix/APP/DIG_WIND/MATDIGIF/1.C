	locksnd();

 	soundcmd(LTATTEN,0);			/* Set Left Attenuation to zero */
	soundcmd(RTATTEN,0);			/* Set Right Attenuation to zero */
	soundcmd(LTGAIN,0x80);		/* Set Left Gain to 8 */
	soundcmd(RTGAIN,0x80);		/* Set Right Gain to 8 */

	soundcmd(ADDERIN,2);			/* Adder input from Matrix only */
	soundcmd(ADCINPUT,0);			/* ADC inputs from microphone */

	setmode(STEREO16);

	buffoper(0) ;

	devconnect (ADC,cod,CLK_25M,CLK50K,NO_SHAKE);

	soundcmd(ADDERIN,2);

	buffoper(0);
	dsptristate(TRISTATE,TRISTATE);	/* Disconnect DSP from matrix */

	unlocksnd();
