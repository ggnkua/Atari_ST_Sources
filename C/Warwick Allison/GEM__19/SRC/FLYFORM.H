void *flysave(int vdihandle,int x,int y,int w,int h);
void flyrestore(void *buffer);
void flyfly(int vdihandle, void **buffer, int* dx, int* dy, int opaque);
