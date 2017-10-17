/******************************************************************************
 *	Machine.c		Machine specific bits
 ******************************************************************************
 */

char	m_fdonflag;	/* Indicates floppy motor is on */

/*
 *	Mach_init()	Initialises machine
 */
mach_init(){
	s_init();		/* Initialise CPU status and LEDS */
	mach_fdon();		/* Don't turn of floppy disk for a bit */
}

/*
 *	Mach_shut()	Closes down the machine
 */
mach_shut(){
	motoroff();
}

/*
 *	Mach_tick()	Called every MTICK (approx 30 secs)
 *			Does things like floppy disk motor off
 */
mach_tick(){
	/* Checks if motor has been switched on resently, if so don't
	 * switch off until next mach_tick.
	 */
	if(m_fdonflag) m_fdonflag = 0;
	else motoroff();
}

/*
 *	Mach_fdon()	Called from the floppy disk handler to indicate
 *			that the floppy disk motor has been switched on
 */
mach_fdon(){
	m_fdonflag = 1;
}
