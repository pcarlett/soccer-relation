------------------------------------------------------
--
-- classe principale del gioco
--
--
--
------------------------------------------------------
with Timer_Package;		use Timer_Package;
with Field_package;		use Field_package;
with Ball_Package;		use Ball_Package;
with Player_Package;	use Player_Package;
with Manager_Package;	use Manager_Package;
with Referee_Package;	use Referee_Package;
with Display_Package;	use Display_Package;
with Gtk.Main;			use Gtk.Main;

procedure Game is
	
	F : Field_Access := new Field(22);
	B : Ball_Access := new Ball(F);
	Tm : TimeCount_Access := new TimeCount;
	
	-- inizializzazione del moviment della palla
	T : TaskBall_Access := new TaskBall(F, B, 40);
		
	-- inizializzazione delle caratteristiche dei giocatori
	TP1 : PropsArray_Access := new PropsArray;
	TP2 : PropsArray_Access := new PropsArray;
		
	-- inizializzazione dell'array di giocatori
	Players : array (1..22) of Player_Access;
		
	-- inizializzazione delle squadre
	T1 : Team_Access := new Team;
	T2 : Team_Access := new Team;
			
	-- manager
	M1 : Manager_Access := new Manager(F, T1, TP1,  1, 80);
	M2 : Manager_Access := new Manager(F, T2, TP2, -1, 80);
	
	-- referee
	R : Referee_Access := new Referee (F, B);
	
	-- timer
	Tmr : Timer_Access;
	
begin
	-- inizializzazione delle posizioni
	F.InitField;

	-- creazione delle caratteristiche dei giocatori
	for i in 1..11 loop
		TP1(i) := new Props;
		TP2(i) := new Props;
	end loop;
	TP1( 1).SetRole(GKP);	TP2( 1).SetRole(GKP);
	TP1( 2).SetRole(LDF);	TP2( 2).SetRole(LDF);
	TP1( 3).SetRole(CDF);	TP2( 3).SetRole(CDF);
	TP1( 4).SetRole(CDF);	TP2( 4).SetRole(CDF);
	TP1( 5).SetRole(RDF);	TP2( 5).SetRole(RDF);
	TP1( 6).SetRole(LMF);	TP2( 6).SetRole(LMF);
	TP1( 7).SetRole(CMF);	TP2( 7).SetRole(CMF);
	TP1( 8).SetRole(CMF);	TP2( 8).SetRole(CMF);
	TP1( 9).SetRole(RMF);	TP2( 9).SetRole(RMF);
	TP1(10).SetRole(LFW);	TP2(10).SetRole(LFW);
	TP1(11).SetRole(RFW);	TP2(11).SetRole(RFW);
	
	-- inizializzazione dei giocatori
	-- ID, Props, Team, Direction, Field, Ball, Visibility, Speed, Power, Precision
	Players( 1) := new Player ( 1, 	TP1( 1), 	T1, 	1,		F, B, 60, 60, 60, 70);
	Players( 2) := new Player ( 2, 	TP1( 2), 	T1, 	1,		F, B, 60, 50, 50, 70);
	Players( 3) := new Player ( 3, 	TP1( 3), 	T1, 	1,		F, B, 60, 60, 60, 70);
	Players( 4) := new Player ( 4, 	TP1( 4), 	T1, 	1,		F, B, 60, 70, 70, 70);
	Players( 5) := new Player ( 5, 	TP1( 5), 	T1, 	1,		F, B, 60, 60, 60, 70);
	Players( 6) := new Player ( 6, 	TP1( 6), 	T1, 	1,		F, B, 60, 70, 70, 70);
	Players( 7) := new Player ( 7, 	TP1( 7), 	T1, 	1,		F, B, 60, 40, 90, 70);
	Players( 8) := new Player ( 8, 	TP1( 8), 	T1, 	1,		F, B, 60, 60, 70, 70);
	Players( 9) := new Player ( 9, 	TP1( 9), 	T1, 	1,		F, B, 60, 50, 60, 70);
	Players(10) := new Player (10, 	TP1(10), 	T1, 	1,		F, B, 60, 40, 80, 70);
	Players(11) := new Player (11, 	TP1(11), 	T1, 	1,		F, B, 60, 70, 60, 70);
	Players(12) := new Player (12, 	TP2( 1), 	T2, 	-1, 	F, B, 60, 70, 70, 70);
	Players(13) := new Player (13, 	TP2( 2),	T2, 	-1, 	F, B, 60, 80, 80, 70);
	Players(14) := new Player (14, 	TP2( 3),	T2, 	-1, 	F, B, 60, 70, 70, 70);
	Players(15) := new Player (15, 	TP2( 4),	T2, 	-1, 	F, B, 60, 60, 60, 70);
	Players(16) := new Player (16, 	TP2( 5),	T2, 	-1, 	F, B, 60, 50, 50, 70);
	Players(17) := new Player (17, 	TP2( 6), 	T2, 	-1, 	F, B, 60, 60, 60, 70);
	Players(18) := new Player (18, 	TP2( 7), 	T2, 	-1, 	F, B, 60, 50, 50, 70);
	Players(19) := new Player (19, 	TP2( 8), 	T2, 	-1, 	F, B, 60, 40, 80, 70);
	Players(20) := new Player (20, 	TP2( 9), 	T2, 	-1, 	F, B, 60, 50, 50, 70);
	Players(21) := new Player (21, 	TP2(10), 	T2, 	-1, 	F, B, 60, 40, 70, 70);
	Players(22) := new Player (22, 	TP2(11), 	T2, 	-1, 	F, B, 60, 60, 60, 70);

	-- inizializza le squadre in campo
	for i in 1..11 loop
		T1(i) := Players(i);
		T2(i) := Players(i + 11);
	end loop;
			
	-- timer
	--Tm := new TimeCount;
	Tmr := new Timer(Tm, T1, T2, M1, M2, T);
	
	-- lancio dell'interfaccia grafica
	Gtk.Main.Set_Locale;
	Gtk.Main.Init;
	Display_Package.References(F, B, Tm, Tmr);
	Display_Package.Init;
	Gtk.Main.Main;
	
end Game;	