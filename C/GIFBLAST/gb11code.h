/* gb11code.h - Include file for special purpose GIF compressor routines
	(version 1.1). */

#ifndef P_DEFINED
#define P_DEFINED
#ifdef NOPROTOS
#define P(a,b) b
#else
#define P(a,b) a
#endif
#endif

typedef struct {
	ARCON_BIG_CONTEXT ac_order_0_con;
	ARCON_SMALL_CONTEXT ac_order_1_cons[ARCON_NCODES];
	ARCON_TYPE_CONTEXT ac_type_con;
	int prev;
	ARITH_CODER ac_struct;
} GB11_CODER;

extern int copy_if_larger;

extern int gb11_start_encoding P((GB11_CODER *gb11, FFILE *ff),());
extern int gb11_encode_c P((int c, GB11_CODER *gb11),());
extern int gb11_end_encoding P((GB11_CODER *gb11),());
extern int gb11_start_decoding P((GB11_CODER *gb11, FFILE *ff),());
extern int gb11_decode_c P((GB11_CODER *gb11),());
extern int gb11_end_decoding P((GB11_CODER *gb11),());
