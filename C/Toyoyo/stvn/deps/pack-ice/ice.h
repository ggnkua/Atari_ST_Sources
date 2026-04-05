#ifndef ICE_H
#define ICE_H

#include <sys/types.h>
#include <stddef.h>

#define ICE_HEADER_SIZE 12
#define ICE_DECRUNCH2_EXTRA_SIZE 120

extern int	is_ice_data (char *data);
extern size_t	ice_crunched_length (char *data);
extern size_t	ice_decrunched_length (char *data);

extern char *	ice_crunch (char *data, size_t length, int level);
extern size_t	ice_decrunch (char *data, char *destination);
extern size_t	ice_decrunch_2 (char *data);

#endif /* ICE_H */
