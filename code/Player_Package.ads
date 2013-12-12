------------------------------------------------------
--
-- processo giocatore
--
--
--
------------------------------------------------------
with Field_Package;		use Field_Package;
with Ball_Package;		use Ball_Package;

package Player_Package is 
	
	-- predichiarazione del tipo Team
	type Team;
		
	-- tipo access al tipo Team
	type Team_Access is access Team;
		
	protected type Props is
		
		-- entry che modifica il ruolo del giocatore
		procedure SetRole (R : in Role);
		
		-- funzione che ritorna il ruolo del giocatore
		function GetRole return Role;
		
		private
			
			PRole : Role;
			-- Dir : Integer;
			-- Speed : Integer;
			-- Power : Integer;
			-- Precision : Integer;
		
	end Props;
	
	type Props_Access is access Props;
		
	type PropsArray is array (1..11) of Props_Access;
		
	type PropsArray_Access is access PropsArray;
		
	-- ID, Role, Team, Direction, Field, Ball, Visibility, Speed, Power, Precision
	task type Player (ID : Integer; Prop : Props_Access; T : Team_Access; Dir : Integer; F : Field_Access; B : Ball_Access; 
							Vis : Integer; S : Integer; Pw : Integer; Pr : Integer) is	
		
		pragma Priority(1);
		
		entry Start;
		
		entry Stop;
				
	end Player;
	
	-- tipo access al tipo player
	type Player_Access is access Player;
		
	-- definizione della classe team
	type Team is array (1..11) of Player_Access;
	
	-- funzione per testare i compagni di squadra
	function CheckMates (ID : Integer; T : Team_Access) return Boolean;

	-- funzione per ottenere la distanza da una posizione
	procedure Distance (To, From : in Position; Dist : out Integer);

	-- funzione per testare il passaggio ai compagni
	function CheckPass (Pos : in Position; Dir : in Integer; Positions : in PositionList;	T : in Team_Access; F : in Field_Access) return Integer;
		
	-- funzione per testare la fattibilita' del passaggio
	function CheckPassable(Rng : in Integer; Pos : in Position; Positions : in PositionList; T : in Team_Access) return Boolean;

	-- funzione per effettuare il movimento
	procedure Movement (ID : in Integer; Dir : in Integer; M : in Move; F : in Field_Access; B : in Ball_Access);

	-- funzione per effettuare il tiro
	procedure Kick (B : in Ball_Access; Dir : in Integer; Step : in Move; Power : in Integer);

	-- funzione per il contrasto di gioco
	procedure Contrast (ID1, ID2 : in Integer; F : in Field_Access; B : in Ball_Access; Ptz : in Integer);

	-- funzione per prendere possesso della palla
	function GetBall (ID : in Integer; F : in Field_Access) return Boolean;

	-- funzione per il calcolo della diagonale
	function Diagonal (C1, C2 : Integer) return Integer;

	-- funzione per ottenere la direzione di movimento piu' corretta
	function GetDirection(To, From : in Position; Dir : in Integer) return Move;

	-- funzione per testare la visibilita'
	function Visibility(P1, P2 : in Position; Vis : in Integer) return Boolean;

	procedure PrintM(ID1, ID2 : in Integer; M : in Move);

	-- procedura per gestire l'assenza di possesso palla
	procedure NoneBall(ID : in Integer; Pos : in Position; PRole : in Role; Dir : in Integer; F : in Field_Access; B : in Ball_Access);

	-- procedura per gestire il possesso palla della squadra
	procedure TeamBall(ID : in Integer; Vis : in Integer; Pos : in Position; PRole : in Role; Dir : in Integer; F : in Field_Access; B : in Ball_Access);

	-- procedura per gestire il possesso palla del giocatore
	procedure PlayerBall(ID : in Integer; Vis : in Integer; Pos : in Position; PList : in PositionList;
						PRole : in Role; Dir : in Integer; T : in Team_Access; F : in Field_Access; 
						B : in Ball_Access; Pw : in Integer);

	-- procedura per gestire l'assenza di possesso palla
	procedure OtherBall(ID : in Integer; Vis : in Integer; Pos : in Position; PRole : in Role;
						Dir : in Integer; F : in Field_Access; B : in Ball_Access);
			
end Player_Package;
