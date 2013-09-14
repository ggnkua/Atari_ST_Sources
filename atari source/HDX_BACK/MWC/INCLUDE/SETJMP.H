/*
 * setjmp.h -- structure for setjmp environment.
 *
 * Copyright (c) 1986-1987, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */

/*
 * Structure for a setjmp environment.
 * The pc, d3-d7, and a3-a7 are saved.
 */
typedef	long	jmp_buf[11];

/* End of setjmp.h */
