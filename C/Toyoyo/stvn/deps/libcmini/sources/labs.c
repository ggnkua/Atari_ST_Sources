/*
 * labs.c
 *
 *  Created on: 12.07.2017
 *      Author: og
 */


#include <stdlib.h>


long
labs(long n)
{
    return (n < 0) ? -n : n;
}
