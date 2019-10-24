/*
 * Terminal_Public.h
 *
 * ---------------- METHODES --------------
 */

void	init_MinitelPort(
				int	n_port );			/* In: Port concern‚ */
void	MinitelPort_ChgeSpeed(
				int	n_port,			/* In: Port concern‚ */
				long	l_newspeed );	/* In: Code nouvelle vitesse */

void	sconout ( int device, long length, char *seq );

void	pos( 
							int device,	/* In: No périf concerné */
							int x, 		/* In: Position horizontale (colomne) */
							int y );		/* In: Position verticale (ligne) */
void	str_conout( 
							int device, 
					const		char *string );
void	str_nconout( 
			int 		device, 
			const char	*	string,
			int		n_maxlen );	/* In: Longueur maximum */
void	start_l0(  
			int device );	/* In: No p‚rif concern‚ */
void	end_l0(  
							int device );	/* In: No p‚rif concern‚ */

void	csr_on( int device );
void	csr_off( int device );
void	full_cls( int device );

void	allume_minitel( 
			int device );	/* In: No périf concerné */
void	eteind_minitel( 
			int device );	/* In: No p‚rif concern‚ */

void	param_local( int device );
void	envoi_porteuse( int device );
void	deconnecte_modem( int device );
void	param_normal( int device );
void	param_minitel( 
				int 	device,
				BOOL	b_Connecte );	/* In: TRUE si connect‚ */

void	pos( int device, int x, int y );
void	set_tcolor( int device, int color );
void	term_setReverse( int device );
void	cconout ( int device, int code );
void	mconout ( int device, int code, int nb );
