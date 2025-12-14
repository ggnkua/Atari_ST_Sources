/*
 *	Definitions to handle io vectors.
 *
 *	11/13/93, kay roemer.
 */

#ifndef _IOV_H
#define _IOV_H

/* Maximum number of elements in an io vector */
#define IOV_MAX		16

struct iovec {
	void	*iov_base;
	long	iov_len;
};

static inline long
iov_size (iov, n)
	struct iovec *iov;
	short n;
{
	register long size;

	if (n <= 0 || n > IOV_MAX) return -1;
	for (size = 0; n; ++iov, --n) {
		if (iov->iov_len < 0) return -1;
		size += iov->iov_len;
	}
	return size;
}

#endif /* _IOV_H */
