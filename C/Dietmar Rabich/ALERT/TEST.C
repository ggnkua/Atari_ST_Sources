/* Testprogramm */

#include <stddef.h>
#include "alert.h"

void main(void)
{
    if(appl_init() >= 0)
    {
        do_alert(NULL,
                 "Hello World!",
                 " OK ", 0);
        do_alert(NULL,
                 "Dieses ist ein besonders "
                 "langer Text, der den weichen "
                 "Zeilenumbruch demonstriert!",
                 " 1 | 2 | 3 | 4 ", 1);
        do_alert(NULL,
                 "Dieses ist ein|besonders "
                 "langer Text,|der den harten "
                 "Zeilenumbruch|demonstriert!",
                 " OK ", 0);
        do_alert(NULL,
                 "Dieses ist ein|besonders "
                 "langer Text, der den harten "
                 "und den weichen Zeilen"
                 "umbruch|demonstriert!",
                 " OK ", 0);
        do_alert(BitblkCalculator(),
                 "Dieses ist ein|besonders "
                 "langer Text, der den harten "
                 "und den weichen Zeilen"
                 "umbruch|demonstriert!|"
                 "Und aužerdem mit einem "
                 "kleinen Bitblock!",
                 " OK ", 0);
        appl_exit();
    }
}