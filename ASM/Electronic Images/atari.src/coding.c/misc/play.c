
    offset = offset + sprintf(mesg+offset, "/* */\r\n");
    offset = offset + sprintf(mesg+offset, "rc = call RxFuncAdd('mciRxInit','MCIAPI',,\r\n'mciRxInit')\r\n");
    offset = offset + sprintf(mesg+offset, "rc = call mciRxInit()\r\n");
    offset = offset + sprintf(mesg+offset, "rc = mciRxSendString('open waveaudio',\r\n'alias wave shareable wait',,\r\n'RetStr','0','0')\r\n");
    offset = offset + sprintf(mesg+offset, "rc = mciRxSendString('load wave %s wait',,\r\n'RetStr','0','0')\r\n", soundFile );
    offset = offset + sprintf(mesg+offset, "rc = mciRxSendString('play wave wait',,\r\n'RetStr','0','0')\r\n" );
    offset = offset + sprintf(mesg+offset, "rc = mciRxSendString('close wave wait',,\r\n'RetStr','0','0')\r\n" );
    offset = offset + sprintf(mesg+offset, "call mciRxExit\r\n" );
    sprintf(mesg+offset, "exit\r\n\x1A\0" );
