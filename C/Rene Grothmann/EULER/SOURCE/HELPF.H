void minmax (double *x, LONG n, double *min, double *max,
	int *imin, int *imax);
void transpose (header *hd);
void vectorize (header *init, header *step, header *end);
void mfft (header *hd);
void mifft (header *hd);
void mtridiag (header *hd);
void mcharpoly (header *hd);
void mscompare (header *hd);
void mfind (header *hd);
void mdiag2 (header *hd);
void mband (header *hd);
void mdup (header *hd);
void make_complex (header *hd);
void mvconcat (header *hd);
void mhconcat (header *hd);
void wmultiply (header *hd);
void smultiply (header *hd);
