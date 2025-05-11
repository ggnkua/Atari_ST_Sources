#include <stddef.h>
#include <aesbind.h>

void* rsc_gobj(RSHDR *rsc, long offset, int re_gtype, int re_gindex)
{
	switch (re_gtype) {
	 case R_TREE:
		if (re_gindex >= 0 && re_gindex < rsc->rsh_ntree)
			return ((OBJECT**)(rsc->rsh_trindex + offset))[re_gindex];
	break; case R_OBJECT:
		if (re_gindex >= 0 && re_gindex < rsc->rsh_nobs)
			return (OBJECT*)(rsc->rsh_object + offset + sizeof(OBJECT)*re_gindex);
	break; case R_TEDINFO:
		if (re_gindex >= 0 && re_gindex < rsc->rsh_nted)
			return (TEDINFO*)(rsc->rsh_tedinfo + offset + sizeof(TEDINFO)*re_gindex);
	break; case R_ICONBLK:
		if (re_gindex >= 0 && re_gindex < rsc->rsh_nib)
			return (ICONBLK*)(rsc->rsh_iconblk + offset + 34UL*re_gindex); /* 34 = (sizeof(ICONBLK)-2) (no rsrvd field!) */
	break; case R_BITBLK:
		if (re_gindex >= 0 && re_gindex < rsc->rsh_nbb)
			return (BITBLK*)(rsc->rsh_bitblk + offset + sizeof(BITBLK)*re_gindex);
	break; case R_IMAGEDATA:
		if (re_gindex >= 0 && re_gindex < rsc->rsh_nimages)
			return (char*)(rsc->rsh_imdata + offset + sizeof(void*)*re_gindex);
	break; case R_OBSPEC:
		if (re_gindex >= 0 && re_gindex < rsc->rsh_nobs)
			return (void*)((OBJECT*)(rsc->rsh_object + offset + sizeof(OBJECT)*re_gindex))->ob_spec;
	break; case R_TEPTEXT:
		if (re_gindex >= 0 && re_gindex < rsc->rsh_nted)
			return ((TEDINFO*)(rsc->rsh_tedinfo + offset + sizeof(TEDINFO)*re_gindex))->te_ptext;
	break; case R_TEPTMPLT:
		if (re_gindex >= 0 && re_gindex < rsc->rsh_nted)
			return ((TEDINFO*)(rsc->rsh_tedinfo + offset + sizeof(TEDINFO)*re_gindex))->te_ptmplt;
	break; case R_TEPVALID:
		if (re_gindex >= 0 && re_gindex < rsc->rsh_nted)
			return ((TEDINFO*)(rsc->rsh_tedinfo + offset + sizeof(TEDINFO)*re_gindex))->te_pvalid;
	break; case R_IBPMASK:
		if (re_gindex >= 0 && re_gindex < rsc->rsh_nib)
			return ((ICONBLK*)(rsc->rsh_iconblk + offset + 34UL*re_gindex))->ib_pmask; /* 34 = (sizeof(ICONBLK)-2) */
	break; case R_IBPDATA:
		if (re_gindex >= 0 && re_gindex < rsc->rsh_nib)
			return ((ICONBLK*)(rsc->rsh_iconblk + offset + 34UL*re_gindex))->ib_pdata; /* 34 = (sizeof(ICONBLK)-2) */
	break; case R_IBPTEXT:
		if (re_gindex >= 0 && re_gindex < rsc->rsh_nib)
			return ((ICONBLK*)(rsc->rsh_iconblk + offset + 34UL*re_gindex))->ib_ptext; /* 34 = (sizeof(ICONBLK)-2) */
	break; case R_BIPDATA:
		if (re_gindex >= 0 && re_gindex < rsc->rsh_nbb)
			return ((BITBLK*)(rsc->rsh_bitblk + offset + sizeof(BITBLK)*re_gindex))->bi_pdata;

	// *I* think GEM stuffs these two up.  So I will too.
	break; case R_FRSTR: // SHOULD be R_STRING, but GEM wrong, so me wrong.
		// This is bogus.  Need to know semantics of R_FRSTR.
		if (re_gindex >= 0 && re_gindex < rsc->rsh_nstring)
			return (char*)(rsc->rsh_string + offset + sizeof(void*)*re_gindex);
	break; case R_STRING: // SHOULD be R_FRSTR, but GEM wrong, so me wrong.
		if (re_gindex >= 0 && re_gindex < rsc->rsh_nstring)
			return ((char**)(rsc->rsh_frstr + offset))[re_gindex];
	break; case R_FRIMG:
		if (re_gindex >= 0 && re_gindex < rsc->rsh_nimages)
			return ((char**)(rsc->rsh_frimg + offset))[re_gindex];
	}

	return 0;
}
