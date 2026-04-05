/*
 * acctest.c
 *
 *  Created on: 20.03.2016
 *      Author: mfro
 */

#include <stdio.h>
#include <stdlib.h>
#include <gem.h>

#include "ACCTEST.H"
#include "ACCTEST.RSH"

static char acc_name[] = "  libcmini Accessory ";
extern short _app;

static short app_id;
static short menu_id;

int main(int argc, char *argv[], char *envp[])
{
    short msgbuff[8];

    if ((app_id = appl_init()) >= 0)
    {
        if (_app == 0)
        {
            form_alert(1, "[1][ I am an accessory ][ OK ]");
        }

        if ((menu_id = menu_register(app_id, acc_name)) >= 0)
        {
            for (;;)
            {
                evnt_mesag(msgbuff);

                switch (msgbuff[0])
                {
                    case AC_OPEN:
                        if (msgbuff[4] == menu_id)
                        {
                            form_alert(1, "[1][Accessory opened][ OK ]");
                        }
                        break;

                    case AC_CLOSE:
                        if (msgbuff[3] == menu_id)
                        {
                            form_alert(1, "[1][Accessory closed][ OK ]");
                        }
                        break;
                }
            }
        }
    }
    for (;;) evnt_mesag(msgbuff);
}


