
/*********************************************************************
**
** MAKE_XHD.C
**
** by Darek Mihocka
**
** Last update: 05/15/89  12:30
**
********************************************************************/

#include <osbind.h>

rgchFoo[102400];

main()
    {
    register int ch;
    register int cmeg;
    register int h, err;

    Cconws("\033EMAKE XHD (C) 1989 by Darek Mihocka\r\n\n");
    Cconws("This program generates the file HARDDISK.XHD for use with ST Xformer 2.5\r\n");
    Cconws("Size of file is 1 meg to 9 meg in 1 meg increments.\r\n\n");
    Cconws("Press a key to indicate size of file (0 = exit, 1-9 = 1-9 meg)\r\n");

    ch = (int)Bconin(2);

    if (ch == '0')
        return;    

    if (ch < '1')
        return;

    if (ch > '9')
        return;

    cmeg = (ch - '0') * 10;

    Cconws("Creating file!\r\n");

    h = Fcreate("HARDDISK.XHD", 0);
    if (h < 0)
        {
        Cconws("Creation error (write protected?)\r\n");
        return;
        }

    while (cmeg--)
        {
        if (Fwrite(h, 102400L, rgchFoo) != 102400L)
            {
            Cconws("Write error (disk full?)\r\n");
            goto close;
            }
        }

    Cconws("File created!\r\n");

close:
    Fclose (h);
    Bconin(2);
    }

