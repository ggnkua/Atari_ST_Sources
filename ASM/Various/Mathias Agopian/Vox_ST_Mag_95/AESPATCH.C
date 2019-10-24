#include <tos.h>
#include "AESPATCH.H"

extern void (*oldaes)();
extern void (newaes)();

void PatchAes(void)
{
	oldaes=Setexc(0x22,newaes);
}

void UnpatchAes(void)
{
	Setexc(0x22,oldaes);
}