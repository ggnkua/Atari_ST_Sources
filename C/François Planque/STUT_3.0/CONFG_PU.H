/*
 * Config_Public.h
 */
 
	extern	int	G_cnf_gest_form_std;		/* Gestion de formulaires Standard */
	extern 	int	G_cnf_cope_with_ltf;		/* Contourner les bugs de Let'em Fly */


	/* 
	 * Configuration: 
	 */
	extern	void	init_config( void );
	extern	void	autoload_inf( void );
	extern	void	sauver_param_inf( void );
	extern	void	charger_param_inf ( void );
	extern	void	autoload_ini( void );
	extern	void	sauver_config_ini( void );
