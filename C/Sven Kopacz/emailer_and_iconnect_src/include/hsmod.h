#define FIONREAD  (('F'<< 8) | 1) 
#define FIONWRITE (('F'<< 8) | 2) 
#define TIOCCBRK (('T'<< 8) | 20) 
#define TIOCSBRK (('T'<< 8) | 21) 
#define TIOCIBAUD (('T'<< 8) | 18) 
#define TIOCOBAUD (('T'<< 8) | 19)
#define TIOCGFLAGS (('T'<< 8) | 22) 
/* Anzahl der Stoppbits */ 
#define TF_STOPBITS 0x0003 
/* 0x0000  nicht erlaubt 
ERWEITERUNGSVORSCHLAG: So wird der Synchronmode aktiviert. Die restlichen  
Parameter erhalten im Synchronmode andere Bedeutungen. Diese sind sp„ter  
noch festzulegen. */ 
#define TF_1STOP   0x0001 /* 1 Stoppbit */ 
#define TF_15STOP  0x0002 /* 1.5 Stoppbit */ 
#define TF_2STOP   0x0003 /* 2 Stoppbit */ 
 
/* Anzahl der Bits pro Zeichen */ 
#define TF_CHARBITS 0x000C 
#define TF_8BIT 0x0 /* 8 Bit */ 
#define TF_7BIT 0x4 
#define TF_6BIT 0x8 
#define TF_5BIT 0xC /* 5 Bit */ 
 
/* Handshakemodi und Parit„t */ 
#define TF_FLAG  0xF000 
#define T_TANDEM 0x1000 /* XON/XOFF (=^Q/^S) Flužkontrolle aktiv */ 
#define T_RTSCTS 0x2000 /* RTS/CTS Flužkontrolle aktiv */ 
#define T_EVENP  0x4000 /* even (gerade) Parit„t aktiv */ 
#define T_ODDP   0x8000 /* odd (ungerade) Parit„t aktiv */ 
/* even und odd schliežen sich gegenseitig aus */ 


#define TIOCSFLAGS (('T'<< 8) | 23) 




#define TIOCFLUSH (('T'<< 8) | 8) 
#define TIOCSTOP (('T'<< 8) | 9) 
#define TIOCSTART (('T'<< 8) | 10) 
#define TIOCBUFFER (('T'<<8) | 128) 
#define TIOCCTLMAP (('T'<<8) | 129) 

#define TIOCM_LE   0x0001 /* line enable output, Ausgang */ 
#define TIOCM_DTR  0x0002 /* data terminal ready, Ausgang */ 
#define TIOCM_RTS  0x0004 /* ready to send, hat heute andere Bedeutung, 
Ausgang */ 
#define TIOCM_CTS  0x0008 /* clear to send, hat heute andere Bedeutung, 
Eingang */ 
#define TIOCM_CAR  0x0010 /* data carrier detect, Eingang */ 
#define TIOCM_CD   TIOCM_CAR /* alternativer Name */ 
#define TIOCM_RNG  0x0020 /* ring indicator, Eingang */ 
#define TIOCM_RI   TIOCM_RNG /* alternativer Name */ 
#define TIOCM_DSR  0x0040 /* data set ready, Eingang */ 
#define TIOCM_LEI  0x0080 /* line enable input, Eingang */ 
#define TIOCM_TXD  0x0100 /* Sendedatenleitung, Ausgang */ 
#define TIOCM_RXD  0x0200 /* Empfangsdatenleitung, Eingang */ 
#define TIOCM_BRK  0x0400 /* Break erkannt, Pseudo-Eingang */ 
#define TIOCM_TER  0x0800 /* Sendefehler, Pseudo-Eingang */ 
#define TIOCM_RER  0x1000 /* Empfangsfehler, Pseudo-Eingang */ 
#define TIOCM_TBE  0x2000 /* Hardware-Sendepuffer leer, Pseudo-Eingang */ 
#define TIOCM_RBF  0x4000 /* Hardware-Empfangspuffer voll, Pseudo-Eingang */ 

#define TIOCCTLGET (('T'<<8) | 130) 
#define TIOCCTLSET (('T'<<8) | 131) 
#define TIOCCTLSFAST (('T'<<8) | 132) 
#define TIOCCTLSSLOW (('T'<<8) | 133) 
#define TIONOTSEND (('T'<<8) | 134) 
#define TIOCERROR (('T'<<8) | 135) 
