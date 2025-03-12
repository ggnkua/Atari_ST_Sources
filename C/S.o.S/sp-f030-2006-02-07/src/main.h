
#ifndef _MAIN_H_
#define _MAIN_H_

/* Function prototypes */

void system_load_sram(void);
void load_sram(void);
void save_sram(void);
void run_emulation(void);

/* */
extern int state_slot;


extern int frameskip;

#endif /* _MAIN_H_ */
