//ICC-AVR application builder : 18.6.2005 20:00:44
// Target : M64
// Crystal: 16.000Mhz

#include <iom64v.h>
#include <macros.h>

void port_init(void);

//UART1 initialize
// desired baud rate:19200
// actual baud rate:19231 (0.2%)
void uart1_init(void);

//call this routine to initialize all peripherals
void init_devices(void);
