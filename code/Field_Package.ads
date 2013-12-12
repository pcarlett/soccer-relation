------------------------------------------------------
--
-- campo di gioco
--
--
--
------------------------------------------------------

package Field_Package is

	-- dichiarazione di oggetto remoto
	-- pragma Remote_Types;

	type Move is (Up, Down, Forwd, Backwd);

	-- dichiarazione dei ruoli dei giocatori
	type Role is (STK, LFW, CFW, RFW, LMF, CMF, RMF, LDF, CDF, RDF, GKP);
		
	-- funzione per la definizione dei limiti di movimento dei ruoli
	procedure RoleLimit(Dir : in Integer; R : in Role; A,B,C,D : out Integer);

	type Position is record
		ID : Integer;
		Row : Integer;
		Col : Integer;
	end record;

	type Score is record
		T1 : Integer;
		T2 : Integer;
	end record;
	
	function "-" (A, B : Position) return Integer;
	
	function "=" (A, B : Position) return Boolean;

	function Near(A, B : Position) return Boolean;

	-- gestione della lista di posizioni come array
	type PositionList is array (1..22) of Position;
	
	protected type Field (N : Integer) is -- N: numero giocatori per determinare la dimensione
		
		-- funzione per inizializzare le posizioni
		procedure InitField;

		-- funzione per leggere lo stato del campo
		function GetPositions return PositionList;
	
		-- funzione per la posizione di un giocatore specifico
		function GetPlayerPosition (ID : in Integer) return Position;
		
		-- procedura per il controllo della possibilita' di movimento se intersezione libera
		function CheckCell(Pos : in Position) return Boolean;

		-- procedura per la modifica dello stato del campo su un oggetto protetto
		procedure SetPosition (ID : in Integer; M : in Move; Dir : in Integer);	

		-- procedura alternativa per la modifica della posizione
		procedure SetPosition (ID : in Integer; P : in Position);
		
		-- procedura per la modifica dello stato della palla in campo
		procedure SetBallPosition (M : in Move; Dir : in Integer);	

		-- procedura per la modifica dello stato della palla in campo
		procedure SetBallPosition (P : in Position);	

		-- funzione per testare se il compagno e' avanzato
		function Forward(To, From : Position; Dir : Integer) return Boolean;

		-- funzione per il test del movimento
		function CheckMovement (Dir : in Integer; M : in Move; PRole : in Role; Pos : in Position) return Boolean;
			
		-- funzione per ottenere la posizione della palla
		function GetBallPosition return Position;
		
		-- funzione per ottenere la posizione della porta avversaria
		procedure GetGoalPosition (D : in Integer; A : out Position; B : out Position);
		
		-- funzione esclusiva dell'arbitro
		procedure ResetPosition (ID : in Integer; P : in Position);

		-- funzione per testare se la palla e' in campo
		function IsBallPlayable return Boolean;
			
		-- funzione per testare se la palla e' uscita lateralemente
		function OverVerticalLimit return Boolean;

		-- funzione per testare se la palla e' uscita dal fondo
		function OverHorizzontalLimit return Boolean;

		-- procedura per restituire la palla al portiere
		procedure BallToKeeper;
			
		-- funzione per riposizionare la palla
		procedure LateralReposition;

		-- funzione per testare se la palla e' in rete
		procedure GoalReached (B : in out Boolean);
		
		-- procedura per impostare il risultato
		procedure SetScore (I : in Integer);

		-- procedura per ottenere il risultato parziale del match
		function GetScore(I : Integer) return Integer;

		private

			-- dimensioni del campo standard (variabili in base all'inizializzatore)
			NumRows : Integer := 204;
			NumCols : Integer := 315;

			-- variabile contenente il risultato del match
			Result1 : Integer := 0;
			Result2 : Integer := 0;

			-- posizionamento iniziale del pallone
			Ball : Position := (0, 103, 157);
			
			-- posizione delle porte
			G1_P1 : Position := (30, 92, 315);
			G1_P2 : Position := (31, 112, 315);

			G2_P1 : Position := (32, 92, 0);
			G2_P2 : Position := (33, 112, 0);
			
			-- array di posizionamento dei giocatori
			PList : PositionList;

	end Field;

	type Field_Access is access Field;
			
end Field_Package;
