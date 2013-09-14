/* ipart.h */

/* 
 *
 *
 *  IBM Comparetable Hard Disk Driver
 *
 *  Boot sector and partitioning structures.
 *
 *
 */


#define ONEPART struct _onepart

ONEPART  {

	BYTE b_boot;			/* The boot indicator */
	BYTE b_bhead;   		/* The begining head */
	BYTE b_bsector; 		/* The begining sector */
	BYTE b_bcyl;			/* The begining cylinder */
	BYTE b_syst;			/* The system indicator */
	BYTE b_ehead;   		/* The ending head */
	BYTE b_esector; 		/* The ending sector */
	BYTE b_ecyl;			/* The ending cylinder */
	LONG b_relsect; 		/* The relative sector */
	LONG b_numsect; 		/* The number of sector */

};

#define IBMROOT struct _ibmroot

IBMROOT  {

	ONEPART ibm_p[4];		/* the four ibm partitions */
	WORD b_sign;			/* The signature */

};

/* Directory entry structure for IBM */

typedef struct
	{
		char f_name[11];		/* file name with extension */
		char f_attrib;			/* file attribute */
		char f_fill[10];		/* reserved */
		int f_time[2];			/* file modification time */
		int f_date[2];			/* file modification date */
		int f_clust[2];			/* file starting cluster number */
		long f_fileln;			/* file size in bytes */

	}	FCBIBM;

