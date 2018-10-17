/*********************************************************************/
/* Sample Program to Read Tracks with Duplicate Sectors		     */
/*								     */
/*  The main program will read the third sector with a sector number */
/*  of '3' after the sector with sector number '1' and display the   */
/*  first 8 bytes of data. This will be done on drive B, track 77,   */
/*  and side 0.							     */
/*								     */
/*  The subroutine rd_dup can be used to read any type of duplicate  */
/*  sectors as long as the track number in the address field is the  */
/*  actual track the data is recorded on. See the calling parameters */
/*  in the subroutine definition. **NOTE: If the duplicate sectors   */
/*  occur on the track one after another (without any others between */
/*  them) then this subroutine is accurate only about 66% of the     */
/*  time. This is due to time stolen by the different interrupt      */
/*  (especially the vertical blank interrupt). This can be circum-   */
/*  vented by rewriting the assembler subroutines to not release the */
/*  vertical blank lock.					     */
/*								     */
/*	Guy L. Albertelli   4/3/89   Alpha Systems		     */
/*								     */
/*********************************************************************/

/*********************************************************************/
/* INCLUDE FILES						     */
/*********************************************************************/

#include "osbind.h"
#include "define.h"

/*********************************************************************/
/* DEFINES						   	     */
/*********************************************************************/


/*********************************************************************/
/* EXTERNALS						   	     */
/*********************************************************************/

extern int	gl_apid;

/*********************************************************************/
/* GLOBAL VARIABLES					   	     */
/*********************************************************************/

int	contrl[12];
int	intin[128];
int	ptsin[128];
int	intout[128];
int	ptsout[128];	/* storage wasted for idiotic bindings */

int work_in[11];	/* Input to GSX parameter array */
int work_out[57];	/* Output from GSX parameter array */
int pxyarray[10];	/* input point array */

char errstr[200];
int buffer1[4000];
int stat1;
int bytes;		/* required by the routines in FLOP.O and will
				contain the number of bytes read after
				a read_sector.			*/


/****************************************************************/
/*	Routine to Read Track with Duplicate Sectors		*/
/****************************************************************/
rd_dup(dr,side,r_tr,f_sec,d_sec,n,rest,buf)
int	dr,	/* drive number 1 = A, 2 = B */
	side,	/* side number 0 or 1 */
	r_tr,	/* real track number, 0 to 79 (81) */
	f_sec,	/* sector number of sector before dups */
	d_sec,	/* sector number of dup sectors */
	n,	/* number of dup to return 1 gives first original
					   2 gives first duplicate
					   3 gives second duplicate */
	rest,	/* TRUE to sync drive to this subroutine, use FALSE
			on second and other calls */
	*buf;	/* pointer to buffer */
{
	long save_ssp;
	int stat, drive, track, sector;
 
/* drive = {1|2} * 2 + {0|1}   drive 1 or 2 and side 0 or 1 */
	drive = 2 * dr + side;
	track = r_tr;
	sector = d_sec;

	save_ssp = Super(0L);
	set_drive(drive);
	if(rest) restore();
	seek(track);
	stat = read_sector(f_sec,512,buf);
	while (n--) {
		stat = read_sector(sector,512,buf);
	}
	set_drive(0);
	Super(save_ssp);
	return stat;
}

/****************************************************************/
/*	Sample Main Program					*/
/****************************************************************/
main()
{
	int i;

	appl_init();
	i = 1;

	stat1 = rd_dup(2,0,77,1,2,1,TRUE,buffer1);
	while(i==1){
		stat1 = rd_dup(2,0,77,1,3,3,FALSE,buffer1);
	
sprintf(errstr,"[1][status: bytes = %d stat = %x|%x %x %x %x][ok|term]",
			bytes,stat1,buffer1[0],buffer1[1],
			buffer1[2],buffer1[3]);
		i = form_alert(1,errstr);
	}

	appl_exit();    /* quit  */


}
