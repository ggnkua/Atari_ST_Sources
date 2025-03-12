/*
 * gemstuff.h:
 *
 * Portable Header-Datei fuer GEM-Funktionen
 */
#ifndef GEMSTUFF_H
#define GEMSTUFF_H

#ifndef STDSTUFF_H
#include "stdstuff.h"
#endif

#ifdef __TURBOC__
#include <aes.h>
#include <vdi.h>
#else
#ifdef SOZOBON
#include <gemfast.h>
#else
#include <gemdefs.h>    /* oder was weiss ich */
#endif
#endif

#endif GEMSTUFF_H

