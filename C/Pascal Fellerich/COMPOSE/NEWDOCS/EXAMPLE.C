
#include "CKBD.H"

interface	*ckbd;


/*
 * get_cookie(): searches the cookie jar for a given magic. 
 *  If the cookie exists it returns TRUE and copies the cookies contents
 *  to the variable ckbd (which is the pointer to the function dispatcher)
 *
 *  If the cookie was not found it returns FALSE
 *
 *  The internally used function (xpcb->getcookie)() is available
 *  in Atari's Xcontrol.
 */
int get_cookie(void)
{
	if ((xpcb->getcookie)( CKBD, (long *)&ckbd ) != 0)
		return(TRUE);
	else
		return(FALSE);
}



/*
 * tablereset(): 'deletes' a loaded table from CKBD's memory.
 *  This is also an example of how to read the current tables!
 */
void tablereset(void)
{
	XKEYTAB *keytab;

	/* Use standard system tables */
	Cbioskeys(0);

	/* Get Pointers to keyboard mapping & compose tables
	 * and set the loaded filename to '---system---'
	 */
	keytab=(XKEYTAB*)Ckeytbl(-1L, -1L, -1L, -1L, "---system---");
	
	/* Set the loaded table identical to the standard table */
	Ckeytbl(keytab->unshift, keytab->shift, keytab->caps,
									keytab->compose, keytab->name);
}



/*
 * load_ckb_file(): loads a CKB table.
 */
void load_ckb_file(void)
{
	if (fileselect( save_vars.loadfile, "*.CKB", say(LOADNEWCOMPOSETABLE)))
	{
		tablereset();					/* safety */
		read_ckb();						/* read & set the file */
	};
}



/*
 * open, read, install, close a ckb file.
 */
void read_ckb(void)
{
	int 	hn;
	long	fs;
	CKB_FILE_HEADER *cfh;
	char	*tab;
	void	*unshift, *shift, *caps, *compose;

	unshift=shift=caps=compose=(void *)-1L;
	hn=Fopen( save_vars.loadfile, FO_READ);
	if (hn>0) {
		if ((tab=Malloc(fs=Fseek( 0L, hn, 2 ))) != NULL ) {
			cfh=(CKB_FILE_HEADER*)tab;
			Fseek( 0L, hn, 0 ); Fread(hn, fs, cfh);
			if ( cfh->magic==CKBD ) {
				if (cfh->unshift_offset)	unshift=tab+cfh->unshift_offset;
				if (cfh->shift_offset)		shift=tab+cfh->shift_offset;
				if (cfh->caps_offset)		caps=tab+cfh->caps_offset;
				if (cfh->compose_offset)	compose=tab+cfh->compose_offset;
				Ckeytbl( unshift, shift, caps, compose, cfh->name );
				/* now the new tables are loaded & activated */
			} else
				form_alert(1, say(WRONGFILEFORMAT));
			Mfree(cfh);
		};
		Fclose(hn);
	};
}



/*
 * Switch Compose AND Keyboard mapping tables on:
 */
void newtables_on(void)
{
	Cbioskeys(KBD_MAP | COMPOSE_MAP);
}



/*
 * Switch Compose AND Keyboard mapping tables off:
 */
void newtables_off(void)
{
	Cbioskeys(OFF);
}



/*--------------------------------------------------------------------------*/
