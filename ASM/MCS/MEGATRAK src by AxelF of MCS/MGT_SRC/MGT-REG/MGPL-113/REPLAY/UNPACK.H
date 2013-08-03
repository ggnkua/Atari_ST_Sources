/**************************************************/
/*										*/
/*		Prototypes of functions for			*/
/*		automatic unpacking of data packed		*/
/*		with the following packers :			*/
/*										*/
/*		Atomik 3.5 - Speed 3 - Ice 2.4		*/
/*		    Sentry 2.0 or Power 2.0			*/
/*										*/
/*		   By Simplet / FATAL DESIGN			*/
/*										*/
/**************************************************/

#define	TOOFEWMEMORY	-2
#define	UNAVAILABLE	-1
#define	UNPACKED		0
#define	ATOMIK35		1
#define	SPEED3		2
#define	ICE24		3
#define	POWER2		4
#define	SENTRY20		5

/* Detect if a memory block is packed 	*/

/* Return the number of the packer or	*/
/* an error code as defined on top 	*/

extern	int	Unpack_Detect_Memory
		(void *Packed_Data,long Packed_Length,long Available_Memory);

/* Detect if a file is packed 		*/

extern	int	Unpack_Detect_Disk(int handle,long Available_Memory);

/* Unpack the Data								*/
/* Returns the length of unpacked data				*/

extern	long	Unpack_All(void *Packed_Data,long Packed_Length);
