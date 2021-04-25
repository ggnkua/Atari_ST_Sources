/*
 * Archive header format
 *
 * Archives must start with a word containing the magic number
 * 0xff65 or 0xff66, with 0xff66 being reserved for a random-
 * access object module library.
 */

#define	ARMAG1	0xff65
#define	ARMAG2	0xff66

struct	ar_hdr {
	char	ar_name[14];
	long	ar_date;
	char	ar_uid;
	char	ar_gid;
	int	ar_mode;
	long	ar_size;
	int	ar_fill;
};

#define	ARHSZ	(sizeof (struct ar_hdr))
