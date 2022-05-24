void main(int argc, char *argv[])
{
    printf("/* */\n");
    printf("rc = call RxFuncAdd('mciRxInit','MCIAPI',,\n'mciRxInit')\n");
    printf("rc = call mciRxInit()\n");
    printf("rc = mciRxSendString('open waveaudio',\n'alias wave shareable wait',,\n'RetStr','0','0')\n");
    printf("rc = mciRxSendString('load wave %s wait',,\n'RetStr','0','0')\n", argv[1]);
    printf("rc = mciRxSendString('play wave wait',,\n'RetStr','0','0')\n" );
    printf("rc = mciRxSendString('close wave wait',,\n'RetStr','0','0')\n" );
    printf("call mciRxExit\n" );
    printf("exit\n\x1A\0" );
}
