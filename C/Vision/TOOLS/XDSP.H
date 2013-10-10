/***********************/
/*------- XDSP.H ------*/
/* Header de XDSPLIB.C */
/***********************/
#if !defined(__XDSP)
#define __XDSP

#if !defined(__TOS)
#include <tos.h>
#endif

/********************************************************/
/* Conversion d'un double compris entre -1.0 et 1.0     */
/* En une fraction 24 bits au format du DSP             */
/* NB : Le double Doit absolument ˆtre compris entre    */
/*      -1.0 et 1.0 sinon le r‚sultat est impr‚visible. */
/********************************************************/
long ftob24(double x) ;

/*******************************************/
/* Conversion d'une fraction DSP en double */
/*******************************************/
double b24tof(long x) ;

#endif