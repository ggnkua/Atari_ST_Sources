/* Common definitions
 */

# include <gemma/gemma.h>

extern GEM_ARRAY *gem;
extern short call_aes(GEM_ARRAY *gem, short fn);

# ifdef GEMMA_MULTIPROC
extern GEM_ARRAY *gem_control(void);
extern SLB gemma[];
extern short _pid;
# else
extern SLB gemma;
# endif

/* EOF */
