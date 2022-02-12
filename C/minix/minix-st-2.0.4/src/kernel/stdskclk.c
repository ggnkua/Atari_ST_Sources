#include "kernel.h"
#if (HD_CLOCK == 1)
#if (NR_ACSI_DRIVES > 0)	/* assume: no hard disk; no controller */
#include <minix/com.h>
#include <sgtty.h>
#include <minix/callnr.h>
#include "proc.h"

#include "staddr.h"
#include "stmfp.h"
#include "sthdc.h"
#include "stdma.h"

#define TRACE(x)	/* x */
#define XTRACE(x)	x
#define DEBUG(x)	x

#define	WINCHESTER	CTRLR(0)

/*===========================================================================*
 *				do_xbms  				     *
 *===========================================================================*/

#define XFERSIZE 13
#define IENABLE()	MFP->mf_ierb |= IB_DINT
#define IDISABLE()	MFP->mf_ierb &= ~IB_DINT

/* defines for bms 100 */
#define CLK_100	0x7
#define CLK_ADR1	(CLK_100 * 32)
#define CLK_HOLD	0x1
#define CLK_WRITE	0x2
#define CLK_READ	0x4
#define CLK_WREN	0x8
/* defines for bms 200 */
#define SELECT	0x10
#define SCK_EN	0x08
#define SCK_WRITE	0x80
#define CLK_SCSI	0x6
#define CLK_ADR	(CLK_SCSI * 32)

PUBLIC int do_xbms(address, count, rw, minor)
phys_bytes 	address;
int		count;
int		rw;
int		minor; /* 0= bms100 1=bms200 */
{

  register int	r, s, wrbit;
  register int	index;
  register char	*cp;
  char	lbuf[XFERSIZE];
  long l;
  unsigned short date,time;


  /*
   * Carry out the transfer. All parameters have been checked and
   * are set up properly.
   *
   * Every single byte written to the hdc will cause an interrupt.
   * Thus disable interrupts while communicating with hdc. Ready test
   * will be done by busy waiting. Only for real hard disk operations
   * interrupts will be enabled.
   */
  TRACE(printf("hd address:0x%X count=%d minor=%d cmd:%s\n",
	address, count, minor, (rw==DEV_READ)?"READ":"WRITE")
  );
  IDISABLE();

  dmagrab(WINCHESTER, dmaint);
  if (rw == DEV_GATHER && minor == DC_RBMS100) {
	DMA->dma_mode = FDC | HDC;
	DMA->dma_data = CLK_ADR1+CLK_HOLD;
	for(r=100;r>0;r--) ; /* pause */
	DMA->dma_mode = FDC | HDC;
	DMA->dma_data = CLK_ADR1+CLK_READ+CLK_HOLD;
	for(index = 0; index<XFERSIZE; index++) {
		DMA->dma_mode = FDC | HDC | A0;
		DMA->dma_data = (index << 4);
		for(r=3;r>0;r--) ; /* pause */
		lbuf[index] =  DMA->dma_data & 0xf;
	}
	DMA->dma_mode = FDC | HDC;
	DMA->dma_data = CLK_ADR1+0;
	DMA->dma_mode = FDC ;

	for(index=0,cp=(char*)address; index<count; index++)
		*cp++ = lbuf[index];
	r = 0; /* good return */

  } else if (rw == DEV_GATHER && minor == DC_RBMS200) {
	DMA->dma_mode = FDC | HDC;
	DMA->dma_data = CLK_ADR+SELECT;
	wr1byte(0x20);

	for(index = 0; index<7; index++) {
		lbuf[index] =  rd1byte();
	}
	DMA->dma_data = CLK_ADR+0;
	DMA->dma_mode = FDC ;

	cp=(char*)address;
/* lbuf format: bcd H L */
	*cp++ = lbuf[0] & 0xf;
	*cp++ = (lbuf[0]  >> 4) & 0xf;
	*cp++ = lbuf[1] & 0xf;
	*cp++ = (lbuf[1]  >> 4) & 0xf;
	*cp++ = lbuf[2] & 0xf;
	*cp++ = (lbuf[2]  >> 4) & 0xf;
	*cp++ = lbuf[3] & 0xf;
	*cp++ = lbuf[4] & 0xf;
	*cp++ = (lbuf[4]  >> 4) & 0xf;
	*cp++ = lbuf[5] & 0xf;
	*cp++ = (lbuf[5]  >> 4) & 0xf;
	*cp++ = lbuf[6] & 0xf;
	*cp++ = (lbuf[6]  >> 4) & 0xf;
	r = 0; /* good return */

  } else if (rw == DEV_GATHER && (minor==DC_RSUPRA || minor==DC_RICD)) { /* supra or icd*/
	if(minor == DC_RSUPRA)
		l = getsupra();
	else
		l = geticd();
TRACE(
printf("Supra/ICD Clock returned\n\tdate(yyyyyyymmmmddddd)=%x time(hhhhhhmmmmmmsssss)=%x\n",
(int)(l>>16),(int)l)
);


	if(l == 0) {
		r = EIO; /* failed */
		goto bms_exit;
	}
/*
!date format:
! 0-4	(1f)	day	1-31
! 5-8	>>5 (f)	month	1-12
! 9-15	>>9 (7f) year	0-119  year 0 == 1980
*/
		date = l>>16;
		lbuf[0] = (date >> 9) & 0x7f;
		lbuf[1] = (date >> 5) & 0xf;
		lbuf[2] = (date ) & 0x1f;
		lbuf[3] = 0;
/*
!time format:
! 0-4	(1f)	2sec	0-29
! 5-10	>>5 (3f) min	0-59
! 11-15	>>11 (3f) hour	0-59
!
*/
		time = l;
		lbuf[4] = (time >> 11) & 0x3f;
		lbuf[5] = (time >> 5) & 0x3f;
		lbuf[6] = (time  & 0x1f) <<1; /* real seconds */
	
		cp=(char*)address;
/* lbuf format: bcd H L */
		*cp++ = lbuf[6] % 10;
		*cp++ = (lbuf[6]  / 10);
		*cp++ = lbuf[5] % 10;
		*cp++ = (lbuf[5]  / 10);
		*cp++ = lbuf[4] % 10;
		*cp++ = (lbuf[4]  / 10);

		*cp++ = 0;
	
		*cp++ = lbuf[2] % 10;
		*cp++ = (lbuf[2]  / 10);
		*cp++ = lbuf[1] % 10;
		*cp++ = (lbuf[1]  / 10);
		*cp++ = lbuf[0] % 10;
		*cp++ = (lbuf[0]  / 10);
		r = 0; /* good return */
	
  } else if (rw == DEV_SCATTER && minor == DC_WBMS100) {


	for(index=0,cp=(char*)address; index<count; index++)
		lbuf[index] = *cp++;
	
	DMA->dma_mode = FDC | HDC;
	DMA->dma_data = CLK_ADR1+CLK_WREN+CLK_HOLD;
	for(r=100;r>0;r--) ; /* pause */
	for(index = 0; index<13; index++) {
		DMA->dma_mode = FDC | HDC | A0;
		DMA->dma_data = (index << 4) | (lbuf[index] & 0xf);
		for(r=1;r>0;r--) ; /* pause */
		DMA->dma_mode = FDC | HDC;
		DMA->dma_data = CLK_ADR1+CLK_WREN+CLK_HOLD+CLK_WRITE;
		for(r=3;r>0;r--) ; /* pause */
		DMA->dma_mode = FDC | HDC;
		DMA->dma_data = CLK_ADR1+CLK_WREN+CLK_HOLD;
	}
	DMA->dma_mode = FDC | HDC;
	DMA->dma_data = CLK_ADR1+CLK_HOLD;
	for(r=100;r>0;r--) ; /* pause */
	DMA->dma_mode = FDC | HDC;
	DMA->dma_data = CLK_ADR1+CLK_READ+CLK_HOLD;

	for(index = 0; index<13; index++) {
		DMA->dma_mode = FDC | HDC | A0;
		DMA->dma_data = (index << 4);
		for(r=3;r>0;r--) ; /* pause */
		s =  (unsigned char)DMA->dma_data & 0xf;
		if(s != lbuf[index]) { /* fail */
			DMA->dma_mode = FDC | HDC;
			DMA->dma_data = CLK_ADR1+0;
			DMA->dma_mode = FDC ;
			r = EIO; /* bad return */
			goto bms_exit;
		}
	}
	DMA->dma_mode = FDC | HDC;
	DMA->dma_data = CLK_ADR1+0;
	DMA->dma_mode = FDC ;
	r = 0; /* good return */
  } else if (rw == DEV_SCATTER && minor == DC_WBMS200) {
	int l;

	cp=(char*)address;
	l = *cp++ & 0xf; /* sec-L */
	lbuf[0] = (*cp++ << 4) | l;
	l = *cp++ & 0xf; /* min-L */
	lbuf[1] = (*cp++ << 4) | l;
	l = *cp++ & 0xf; /* hr-L */
	lbuf[2] = (*cp++ << 4) | l;
	lbuf[2] &= 0x7f;	/* strip the 24 hour bit */
	lbuf[3] = *cp++ & 0xf;
	l = *cp++ & 0xf; /* day-L */
	lbuf[4] = (*cp++ << 4) | l;
	l = *cp++ & 0xf; /* mon-L */
	lbuf[5] = (*cp++ << 4) | l;
	l = *cp++ & 0xf; /* yr-L */
	lbuf[6] = (*cp++ << 4) | l;
	
	DMA->dma_mode = FDC | HDC;
	DMA->dma_data = CLK_ADR+SELECT;
	wr1byte(SCK_WRITE+0x31);
	wr1byte(0xb5);
	wr1byte(0);
	DMA->dma_data = CLK_ADR+0;

	DMA->dma_mode = FDC | HDC;
	DMA->dma_data = CLK_ADR+SELECT;
	wr1byte(SCK_WRITE+0x20);
	for(index = 0; index<7; index++) {
		wr1byte(lbuf[index]);
	}
	DMA->dma_data = CLK_ADR+0;

	DMA->dma_mode = FDC | HDC;
	DMA->dma_data = CLK_ADR+SELECT;
	wr1byte(0x20);

	for(index = 0; index<7; index++) {
int r = rd1byte();
if(lbuf[index] !=  r) { /* fail */
printf("disk clock fail; index: %d, lbuf: %x, r: %x\n", index, lbuf[index], r);
#if 0
		if(lbuf[index] !=  rd1byte()) { /* fail */
#endif
			DMA->dma_data = CLK_ADR+0;
			DMA->dma_mode = FDC ;
			r = EIO; /* bad return */
			goto bms_exit;
		}
	}
	DMA->dma_data = CLK_ADR+0;
	DMA->dma_mode = FDC ;
	r = 0; /* good return */
  } else if (rw == DEV_SCATTER && minor == DC_RSUPRA) {
	r = EINVAL;
  } else {
/* reserve for screen blanker */
	r = EINVAL;
	goto bms_exit;
  }
bms_exit:
  dmafree(WINCHESTER);
    IENABLE();
  
  return(r);
}
#endif
#endif
