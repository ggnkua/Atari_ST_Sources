/* Skalierungen */
void	scale_one(unsigned char *src, unsigned char *dst, int sw, int sh, int dw, int dh, long ad_dw, int mode);
void	scale_three(unsigned char *s1, unsigned char *s2, unsigned char *s3, unsigned char *d1, unsigned char *d2, unsigned char *d3, unsigned char *mask, int sw, int sh, int dw, int dh, long ad_dw, int mode);
void	simple_scale_one(unsigned char *src, unsigned char *dst, int sw, int sh, int dw, int dh, long ad_dw, long sw_wid, int sx, int sy);

