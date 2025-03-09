/* M_EXT.H ---  extern Deklarationen der BITSET-Funktionen 
 *              und einige Makros
 */

BitSetDefType *bs_newsettype(int min, int max);
BitSetType *bs_createset(BitSetDefType *bsd);
int 	bs_2setop(BitSetType *bs1,BitSetType *bs2,BitSetType *erg,
								BS_OpId opid);
int	  bs_1setop(BitSetType *bsp,BS_OpId opid);
int 	bs_elemop(int e,BitSetType *bsp,BS_OpId opid);
int	  bs_cmpset(BitSetType *bs1,BitSetType *bs2,BS_OpId opid);
unsigned bs_maxcard(BitSetType *bs);

/*
 * Folgende define's dienen der besseren Handhabung
 * der BITSET-Funktionen :
 */
#define bs_union(s1,s2,u)  bs_2setop(s1,s2,u,BS_UNION)
#define bs_inters(s1,s2,i) bs_2setop(s1,s2,i,BS_INTERSECT)
#define bs_diff(s1,s2,d)   bs_2setop(s1,s2,d,BS_DIFFERENCE)
#define bs_card(s)         bs_1setop(s,BS_CARDINAL)
#define bs_complement(s)   bs_1setop(s,BS_COMPLEMENT)
#define bs_isequal(s1,s2)  bs_cmpset(s1,s2,BS_ISEQUAL)
#define bs_issubset(s1,s2) bs_cmpset(s1,s2,BS_ISSUBSET)
#define bs_incl(e,s)       bs_elemop(e,s,BS_INCLUDE)
#define bs_excl(e,s)       bs_elemop(e,s,BS_EXCLUDE)
#define bs_iselem(e,s)     bs_elemop(e,s,BS_ISELEMENT)


