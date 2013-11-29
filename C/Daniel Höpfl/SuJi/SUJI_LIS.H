#ifndef __DH_SUJI_LIS_H_
#define __DH_SUJI_LIS_H_

FILE_INFO *add_to_list(DTA *dta,char *pfad,long *sort_nr);void free_whole_list(void);FILE_INFO *get_from_list(long nr);#define get_next_in_list(this)	this->nextvoid free_from_list(FILE_INFO *this);
#endif
