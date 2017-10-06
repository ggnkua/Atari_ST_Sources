#include "gemap.h"
#include "gemfn.h"
#include "gemfl.h"
#include "vdi.h"

main()
{
	GEMapplication example;

	VDI vdi;

	vdi.st_load_fonts();

	GEMfontlist fontlist(vdi);

	int n=fontlist.NumberOfFonts();
	printf("%d fonts\n\n",n);

	for (int i=0; i<n; i++) {
		printf("Font %d:\n",i);
		printf("  name = %s\n",fontlist.FontName(i));
		printf("  code = %d\n",fontlist.FontCode(i));
		printf("  arbs = %d\n\n",fontlist.ArbitrarilySizable(i));
	}
}
