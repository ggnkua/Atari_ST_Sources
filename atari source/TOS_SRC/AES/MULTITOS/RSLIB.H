/*	RSLIB.H			9/21/92			D.Mui		*/

#ifndef _RSLIB_H_
#define _RSLIB_H_

#define R_TREE 		0	/* These defines are used by rs_gaddr */
#define R_OBJECT 	1
#define R_TEDINFO 	2
#define R_ICONBLK 	3
#define R_BITBLK 	4
#define R_STRING 	5	/* gets pointer to free strings	*/
#define R_IMAGEDATA 	6	/* gets pointer to free images	*/
#define R_OBSPEC 	7
#define R_TEPTEXT 	8	/* sub ptrs in TEDINFO	*/
#define R_TEPTMPLT 	9
#define R_TEPVALID 	10
#define R_IBPMASK 	11	/* sub ptrs in ICONBLK	*/
#define R_IBPDATA 	12
#define R_IBPTEXT 	13
#define R_BIPDATA 	14	/* sub ptrs in BITBLK	*/
#define R_FRSTR 	15	/* gets addr of ptr to free strings	*/
#define R_FRIMG 	16	/* gets addr of ptr to free images	*/

#define RT_VRSN 	0	/* these must coincide w/ rshdr */
#define RT_OB 		1
#define RT_TEDINFO 	2
#define RT_ICONBLK 	3
#define RT_BITBLK 	4
#define RT_FREESTR 	5
#define RT_STRING 	6
#define RT_IMAGEDATA 	7
#define	RT_FREEIMG 	8
#define RT_TRINDEX 	9

#define R_NOBS 		10
#define R_NTREE 	11
#define R_NTED 		12
#define R_NICON 	13
#define R_NBITBLK 	14
#define R_NSTRING 	15
#define R_IMAGES 	16

#define NUM_RTYPES 	10

#define NUM_RN 		7

#define RS_SIZE 	NUM_RN + NUM_RTYPES	/* NUM_RTYPES + NUM_RN	*/

#define HDR_LENGTH 	(RS_SIZE + 1) * 2	/* in bytes	*/

#define NUM_OBS 	LWGET(rs_hdr + 2*R_NOBS)
#define NUM_TREE 	LWGET(rs_hdr + 2*R_NTREE)
#define NUM_TI 		LWGET(rs_hdr + 2*R_NTED)
#define NUM_IB 		LWGET(rs_hdr + 2*R_NICON)
#define NUM_BB 		LWGET(rs_hdr + 2*R_NBITBLK)
#define NUM_FRSTR 	LWGET(rs_hdr + 2*R_NSTRING)
#define NUM_FRIMG 	LWGET(rs_hdr + 2*R_IMAGES)

#define ROB_TYPE 	(psubstruct + 6)	/* Long pointer in OBJECT	*/
#define ROB_SPEC 	(psubstruct + 12)	/* Long pointer in OBJECT	*/

#define RTE_PTEXT 	(psubstruct + 0)	/* Long pointers in TEDINFO	*/
#define RTE_PTMPLT 	(psubstruct + 4)
#define RTE_PVALID 	(psubstruct + 8)
#define RTE_TXTLEN 	(psubstruct + 24)
#define RTE_TMPLEN 	(psubstruct + 26)

#define RIB_PMASK 	(psubstruct + 0)	/* Long pointers in ICONBLK	*/
#define RIB_PDATA 	(psubstruct + 4)
#define RIB_PTEXT 	(psubstruct + 8)

#define RBI_PDATA 	(psubstruct + 0)	/* Long pointer in BITBLK	*/
#define RBI_WB 		(psubstruct + 4)
#define RBI_HL 		(psubstruct + 6)
						/* in global array		*/

#define APP_LOPNAME 	(rs_global + 10)	/* tree index address		*/
#define APP_RSCADDR 	(rs_global + 14)	/* resource address		*/
#define APP_RSCSIZE 	(rs_global + 18)	/* resource size		*/

#endif

