
/*
 * Get file statistics - sort of like stat(2)
 */

int st_fstat(fname, buf)
char *fname;
struct stat *buf;
{
    register struct stat *save_dta;
    register int status;

    /* Save old DTA */
/*    save_dta = (struct stat *)Fgetdta();	*/
    save_dta = trap_1_wlww(0x2F);

    /* set the new DTA */
/*    Fsetdta(buf);				*/
    trap_1_wlww(0x1A, buf);

    /* Find file stat */
/*    status = Fsfirst(fname, 0);		*/
    status = trap_1_wlww(0x4E, fname, 0);

    /* reset dta */
/*    Fsetdta(save_dta);			*/
    trap_1_wlww(0x1A, save_dta);

    /* return status */
    return (status == 0) ? 0 : -1;

}
