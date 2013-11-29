/* Specjalne komendy AV/VA	*/
#define MYTASK_START							0x5010			/* MyTask dziala									*/
#define MYTASK_NEW_COLOR					0x5011			/* Nowy kolor przycisku		*/
#define MYTASK_NEW_ICON						0x5012			/* Wyslanie nowej ikonki
																								msg[2] - nr ikonki
																								msg[3], msg[4] - dane wygladu ikonki
																								msg[5], msg[6] - maska ikonki
																								Ikona jest tworzona przy uzyciu Interface	*/
#define MYTASK_DELETE_ICON				0x5013					/* Kasuje ikonki w Trayu
																								msg[2] - nr ikonki					*/
#define MYTASK_ICON_CLICK					0x5014						/* Klikniecie na ikonke w Trayu	*/
																							/*	msg[0] = MYTASK_ICON_CLICK
																								msg[1] = MyTask.id
																								msg[2] = 0 - lewy przycisk, 1 - prawy przycisk, 3 - podwojne tupniecie
																								msg[2] - ktory klawisz (1-lewy, 2-prawy)
																								msg[3] - ilosc przycisniec (1 lub 2)
																								msg[4], msg[5] - pozycja myszki
																								msg[6] - ktora ikonka danej aplikacji zostala nacisnieta	*/
#define MYTASK_BUTTON							0x5015			/* Jezeli aplikacja wysle taki komunikat oznacza to, ze:
																								msg[2] = 0 - przycisk tej aplikacji nie powinien byc pokazany na listwie
																								msg[3] = 1 - przycisk ma byc pokazany na listwie (standardowo)					*/
#define MYTASK_NEW_WINDOW					0x5016			/* Nowy przycisk od znanej juz aplikacji.																	*/
#define MYTASK_NAME								0x5017			/* Wyslanie tego komunikatu oznacza zmiane tekstu na przycisku aplikacji
																									msg[3], msg[4] zawieraja nowa nazwe aplikacji	(max. 24 znaki)						*/
#define MYTASK_GET_SIZE						0x5018
#define MYTASK_BUBBLE_CHANGE			0x5019			/* Wyslanie nowego tekstu dla BubbleGEM:
																								msg[2] - dlugosc tekstu, msg[3,4] - tekst																*/
#define MYTASK_ICON_ERROR					0x501A			/* Wyslanie komunikatu o blednym numerze ikonki lub o
																									o innym bledzie zwiazanym z ikonami	*/
#define MYTASK_CHANGED_OPTIONS		0x501B			/* Wyslanie komunikatu o fakcie zmiany opcji programu (MYCONF.APP)	*/
#define MYTASK_SEND_OPTIONS				0x501C			/* Opcje zostaly zmienione!																					*/
