#ifndef LATTICE
#include <gemfast.h>
#include <aesbind.h>
#include <vdibind.h>
#define GEM_SIZE int
#else
#include <aes.h>
#include <vdi.h>
#define GEM_SIZE short
#endif
#include "cbzone.h"