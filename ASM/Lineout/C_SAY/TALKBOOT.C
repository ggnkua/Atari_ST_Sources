#include <stdio.h>
#include <osbind.h>

extern char *strrchr();
extern char say_copyright[];
extern int cdecl say(int mode, ...);

main()
{
    FILE *talk;
    char *nl;
    char buf[256];

    Cconws(say_copyright);

    talk = fopen("BOOT.SAY", "r");
    if (!talk)
	return;
    while (fgets(buf, sizeof(buf), talk)) {
	if (nl=strrchr(buf, '\n'))
		*nl = 0;
	if (buf[0])
		say(0,buf);
    }
    say(1,0L);
}
