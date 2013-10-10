/* arith.h - Include file for arithmetic coding routines. */

#ifndef P_DEFINED
#define P_DEFINED
#ifdef NOPROTOS
#define P(a,b) b
#else
#define P(a,b) a
#endif
#endif

typedef struct {
	FFILE *ff;
	long low,high;
	union {
		struct {
			long bits_to_follow;
		} e;
		struct {
			long value;
		} d;
	} u;
} ARITH_CODER;

extern int arith_start_encoding P((ARITH_CODER *ac, FFILE *ff),());
/* Prepares to do arithmetic encoding to ff. Returns 0 on success,
	or -1 on failure. */
extern int arith_encode P((ARITH_CODER *ac, int rstart, int rend, int rtot),());
/* Encodes a fraction rstart..rend of the interval 0..rtot-1. Returns 0
	on success, or -1 on failure. */
extern int arith_end_encoding P((ARITH_CODER *ac),());
/* Ends encoding. Returns 0 on success, or -1 on failure. */
extern int arith_start_decoding P((ARITH_CODER *ac, FFILE *ff),());
/* Prepares to do arithmetic decoding from ff. Returns 0 on success,
	or -1 on failure. */
extern int arith_decode_getrpos P((ARITH_CODER *ac, int rtot),());
/* Gets the decoder's current position within 0..rtot-1. */
extern int arith_decode_advance P((ARITH_CODER *ac,
	int rstart, int rend, int rtot),());
/* Advances the decoder to account for a fraction rstart..rend of the
	interval 0..rtot-1. If rpos was the position returned by
	arith_decode_advance, then rstart..rend should be the interval
	within the appropriate context such that rstart<=rpos<rend.
	Returns 0 on success, or -1 on failure. */
extern int arith_end_decoding P((ARITH_CODER *ac),());
/* Ends decoding. Returns 0 on success, or -1 on failure. */
