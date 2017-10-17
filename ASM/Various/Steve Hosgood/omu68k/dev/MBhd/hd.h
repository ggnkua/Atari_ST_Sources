/*******************************************************************************
 *	Hd.h	Header info for hard disk
 *******************************************************************************
 */

# define	NHDDEVS		2	/* Number of hard disk drives */
# define	ERROR		-1	/* Error return */

# define	HDIOCTL		1	/* Special harddisk command */
# define	HDFORMAT	6
# define	HDCERTIFY	7
# define	HDNFORMAT	8

struct Drive_info {
	int     d_nopen;
};
