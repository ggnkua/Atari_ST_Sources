#include <stdio.h>
#include "gui.h"

void main()
{
    int i,j;
    int TopLine = 0;

    SetGuiMode(0x12);
    InitMouse();
    ShowMouse();
    Box(0, 0, 639, 799, 1);
    i = 1;
    while(i) {
        switch(getch()) {
            case 0x1b:
            i = 0;
            break;

            case 'q':
            if(TopLine > 0) TopLine--;
            break;

            case 'a':
            if(TopLine < (800-480)) TopLine++;
            break;
        }
        SetTopLine(TopLine);
    }
    DeInitMouse();
    SetTxtMode(0x3);
}
