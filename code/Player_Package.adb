-- identifica il task dei giocatori in campo
with Ada.Real_Time;					use	Ada.Real_Time;
with Ada.Text_IO;					use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Elementary_Functions;
use  Ada.Numerics.Elementary_Functions;

package body Player_Package is 

	protected body Props is
	
		-- entry che modifica il ruolo del giocatore
		procedure SetRole (R : in Role) is
		begin
			PRole := R;
		end SetRole;
	
		-- funzione che ritorna il ruolo del giocatore
		function GetRole return Role is
		begin
			return PRole;
		end GetRole;
			
	end Props;

	-----------------------------------------------------------------------
	-- funzione per le testare il possesso palla dell'eventuale compagno --
	-----------------------------------------------------------------------
	function CheckMates(ID : Integer; T : Team_Access) return Boolean is
		Flag : Boolean;
	begin
		Flag := False;
		for i in 1..11 loop
			if(ID = T(i).ID) then
				Flag := True;
			end if;
		end loop;
		return Flag;
	end CheckMates;
	
	-- funzione per ottenere la distanza da una posizione
	procedure Distance (To, From : in Position; Dist : out Integer) is
		R , C : Integer;
	begin
		-- To: Palla (dove andare)  -*-  From: Player (da dove andare)
		R := abs(To.Row - From.Row);
		C := abs(To.Col - From.Col);
		if (R < C) then
			Dist := R;
		elsif (C < R) then
			Dist := C;
		else
			Dist := R;
		end if;
	end Distance;
	
	---------------------------------------------------------------
	-- funzione per le testare l'eventuale passaggio al compagno --
	---------------------------------------------------------------
	function CheckPass(Pos : in Position; Dir : in Integer; Positions : in PositionList; T : in Team_Access; F : in Field_Access) return Integer is
		ID, ID2, TempID, Min, Dist : Integer;
		Pos2, TempPos : Position;
	begin
		ID := Pos.ID;
		ID2 := Pos.ID;
		Min := 315;
		for x in 2..11 loop
			TempID := T(x).ID;
			TempPos := F.GetPlayerPosition(TempID);
			if (ID /= TempID and CheckPassable(10, Pos, Positions, T) and F.Forward(TempPos, Pos, Dir)) then
				Distance (TempPos, Pos, Dist);
				if (Dist < Min) then
					Min := Dist;
					ID2 := TempID;
				end if;
			end if;
		end loop;
		return ID2;
					
		-- return -1; -- nessun compagno per il passaggio
	end CheckPass;

	--------------------------------------------------------
	-- funzione per testare la fattibilita' del passaggio --
	--------------------------------------------------------
	function CheckPassable(Rng : in Integer; Pos : in Position; Positions : in PositionList; T : in Team_Access) return Boolean is
		Flag : Boolean := True;
		ID : Integer;
	begin
		-- se non ci sono avversari nel range allora torna true
		for x in Positions'Range loop -- per tutti le posizioni
			if(Visibility(Positions(x), Pos, Rng) and Flag) then -- se visibile rispetto alla posizione del compagno controlla se compagno
				ID := Positions(x).ID;
				if(not CheckMates(ID, T) and Flag) then -- se non compagno allora falso
					Flag := False; 
				end if;
			end if;
		end loop;
		return Flag;
	end CheckPassable;
	
	------------------------------------------
	-- funzione per effettuare il movimento --
	------------------------------------------
	procedure Movement(ID : in Integer; Dir : in Integer; M : in Move; F : in Field_Access; B : in Ball_Access) is
	begin
		F.SetPosition(ID, M, Dir);
		if(B.GetOwner = ID) then
			F.SetBallPosition(M, Dir);
		end if;
	end Movement;
	
	----------------------------------------------
	-- funzione per effettuare il tiro in porta --
	----------------------------------------------
	procedure Kick (B : in Ball_Access; Dir : in Integer; Step : in Move; Power : in Integer) is
	begin
		B.Kick (Dir, Step, Power);
		-- Put_Line("Control: " & Integer'Image(B.GetOwner));
	end Kick;
	
	----------------------------------------------
	-- funzione per effettuare il tiro in porta --
	----------------------------------------------
	procedure Contrast (ID1, ID2 : in Integer; F : in Field_Access; B : in Ball_Access; Ptz : in Integer) is
		X, Y : Position;
		M : Move;
		Probability : Integer;
		
		subtype Contrastable is Integer range 1..2;
		package Random_Move is new Ada.Numerics.Discrete_Random (Move);
		package Random_Probability is new Ada.Numerics.Discrete_Random (Contrastable);
		use Random_Move;
		use Random_Probability;
		G : Random_Move.Generator;
		K : Random_Probability.Generator;
		
	begin
		Put_Line("Contrast: " & Integer'Image(ID1) & " - " & Integer'Image(ID2) & " tried");
		Random_Move.Reset (G); -- Start the generator in a unique state in each run
		Random_Probability.Reset (K); -- Start the generator in a unique state in each run
		M := Random (G); -- Generate a move
		Probability := Random (K);
		Put_Line("Probability: " & Integer'Image(Probability));

		-- ******************************
		-- eventuale fattore casuale per l'errore di contrasto (vedi soglie)
		if (Probability = 1) then
			X := F.GetPlayerPosition(ID1);
			Y := F.GetPlayerPosition(ID2);
			if (Near(X, Y)) then
				Kick (B, 1, M, Ptz);
				Put_Line(" ---> Contrast: " & Integer'Image(ID1) & " - " & Integer'Image(ID2));
				Put_Line(" ---> Contrast Owner: " & Integer'Image(B.GetOwner));
			end if;
		else 
			Put_Line(" ---> Contrast not Reached");
		end if;
	end Contrast;
	
	---------------------------------------------
	-- funzione per ottenere il possesso palla --
	---------------------------------------------
	function GetBall (ID : in Integer; F : in Field_Access) return Boolean is
		X, Y : Position;
		Flag : Boolean := False;
	begin
		X := F.GetPlayerPosition(ID);
		Y := F.GetBallPosition;
		if (X = Y) then
			Flag := True;
		end if;
		return Flag;
	end GetBall;	
	
	-- funzione per il calcolo della diagonale
	function Diagonal (C1, C2 : Integer) return Integer is
		Fl : Float;
		Int : Integer;
		D : Integer;
	begin
		Int := ((C1*C1) + (C2 * C2));
		Fl := Sqrt(Float(Int));
		D := Integer(Fl);
		return D;
	end Diagonal;
	
	----------------------------------------------------
	-- funzione per ottenere la direzione della palla --
	----------------------------------------------------
	function GetDirection(To, From : in Position; Dir : in Integer) return Move is
		R, C, D: Integer;
		M : Move;
	begin
		-- To: Palla (dove andare)  -*-  From: Player (da dove andare)
		R := abs(To.Row - From.Row);
		C := abs(To.Col - From.Col);
		if (R = 0 or C = 0) then
			if (R = 0) then
				if (Dir = 1) then
					if (To.Col < From.Col) then
						M := Backwd;
					else
						M := Forwd;
					end if;
				else
					if (To.Col < From.Col) then
						M := Forwd;
					else
						M := Backwd;
					end if;
				end if;
			else
				if (To.Row < From.Row) then
					M := Up;
				else
					M := Down;
				end if;
			end if;
		else
			D := Diagonal (R, C);
			if ((D - R) < (D - C)) then -- passaggio verticale
				if (To.Row < From.Row) then
					M := Up;
				else
					M := Down;
				end if;
			else -- passaggio orizzontale
				if (Dir = 1) then
					if (To.Col < From.Col) then
						M := Backwd;
					else
						M := Forwd;
					end if;
				else
					if (To.Col < From.Col) then
						M := Forwd;
					else
						M := Backwd;
					end if;
				end if;
			end if;
		end if;
		return M;
	end GetDirection;
	
	---------------------------------
	-- funzione per la visibilita' --
	---------------------------------
	function Visibility(P1, P2 : in Position; Vis : in Integer) return Boolean is
	begin
		if ((P1 - P2) < Vis) then
			return True;
		else
			return False;
		end if;
	end Visibility;	
	
	----- ***** ----- ***** -----
	procedure PrintM(ID1, ID2 : in Integer; M : in Move) is
	begin
		case M is
			when Up =>
				Put_line("* ID: " & Integer'Image(ID1) & " * TeamMate: " & Integer'Image(ID2) & " UP");
			when Down =>
				Put_line("* ID: " & Integer'Image(ID1) & " * TeamMate: " & Integer'Image(ID2) & " DOWN");
			when Forwd =>
				Put_line("* ID: " & Integer'Image(ID1) & " * TeamMate: " & Integer'Image(ID2) & " FORWD");
			when Backwd =>
				Put_line("* ID: " & Integer'Image(ID1) & " * TeamMate: " & Integer'Image(ID2) & " BACKWD");
			when others =>
				null;
		end case;
	end PrintM;
 
	-----------------------------------------------------------
	-- procedura per gestire il possesso palla del giocatore --
	-----------------------------------------------------------
	procedure PlayerBall(ID : in Integer; Vis : in Integer; Pos : in Position; PList : in PositionList;
						PRole : in Role; Dir : in Integer; T : in Team_Access; F : in Field_Access; 
						B : in Ball_Access; Pw : in Integer) is
		Post1 : Position;
		Post2 : Position;
		TeamMate : Integer;
		M : Move;
		Completed : Boolean := False;
	begin
		F.GetGoalPosition(Dir, Post1, Post2); -- controlla la posizione della porta
		TeamMate := CheckPass(Pos, Dir, PList, T, F); -- controlla eventuali passaggi possibili

		if (not Completed) then
			if (Visibility(Post1, Pos, Vis)) then
				-- possibilita' di tiro
				M := GetDirection(Post1, Pos, Dir);
				Kick (B, Dir, Forwd, Pw);
				Completed := True; -- azione completata
				-- Put_line("Kick to Goal");
			elsif (Visibility(Post2, Pos, Vis) and not Completed) then
			-- 	possibilita' di tiro
				M := GetDirection(Post2, Pos, Dir);
				Kick (B, Dir, Forwd, Pw);
				Completed := True; -- azione completata
				-- Put_line("Kick to Goal");
			end if;
		end if;
		if (Visibility(F.GetPlayerPosition(TeamMate), Pos, Vis) and not Completed) then			
			-- possibilita' di passaggio
			Put_Line("TeamMate: " & Integer'Image(TeamMate));
			if (CheckPassable(15, F.GetPlayerPosition(TeamMate), PList, T)) then
				M := GetDirection(F.GetPlayerPosition(TeamMate), Pos, Dir);
				PrintM(ID, TeamMate, M);
				Kick (B, Dir, M, Pw);
				Completed := True; -- azione completata						
				Put_line("Kick to Pass the Ball");
			end if;
		end if;
		if (not Completed) then
			M := GetDirection(Post1, Pos, Dir);
			if (F.CheckMovement(Dir, M, PRole, Pos) and not Completed) then -- avanza verso la porta
				PrintM(ID, ID, M);
				Movement (ID, Dir, M, F, B);
				Completed := True; -- azione completata						
			else
				Kick (B, Dir, Forwd, Pw);
				Put_line("Kick to Forward the Ball");
			end if;
		end if;
	end PlayerBall;

	-----------------------------------------------------------
	-- procedura per gestire il possesso palla della squadra --
	-----------------------------------------------------------
	procedure TeamBall(ID : in Integer; Vis : in Integer; Pos : in Position;
						PRole : in Role; Dir : in Integer; F : in Field_Access; B : in Ball_Access) is
		M : Move;
		Completed : Boolean := False;
	begin
		if (Visibility(F.GetBallPosition, Pos, Vis) and not Completed) then -- se palla visibile avvicinati (sali/scendi)
			M := GetDirection(F.GetBallPosition, Pos, Dir);
			if(F.CheckMovement(Dir, M, PRole, Pos)) then
				Movement(ID, Dir, M, F, B);
				Completed := True; -- azione completata						
			end if;
		end if;
		if(F.CheckMovement(Dir, Forwd, PRole, Pos) and not Completed) then -- controlla se possibile l'avanzamento
			Movement(ID, Dir, Forwd, F, B); -- avanza
			Completed := True; -- azione completata						
		end if;
	end TeamBall;

	-------------------------------------------------------
	-- procedura per gestire l'assenza di possesso palla --
	-------------------------------------------------------
	procedure NoneBall(ID : in Integer; Pos : in Position; PRole : in Role; Dir : in Integer; F : in Field_Access; B : in Ball_Access) is
		M : Move;
	begin
		M := GetDirection(F.GetBallPosition, Pos, Dir);
		if (F.CheckMovement(Dir, M, PRole, Pos)) then
			Movement(ID, Dir, M, F, B);
			if(GetBall(ID, F)) then -- prende la palla
				B.Control(ID);
				F.SetBallPosition(F.GetPlayerPosition(ID));
				Put_Line("Control: " & Integer'Image(B.GetOwner));
			end if;
		end if;
	end NoneBall;

	--------------------------------------------------------
	-- procedura per gestire il possesso palla avversario --
	--------------------------------------------------------
	procedure OtherBall(ID : in Integer; Vis : in Integer; Pos : in Position; PRole : in Role;
						Dir : in Integer; F : in Field_Access; B : in Ball_Access) is
		M : Move;
		Completed : Boolean := False;
	begin
		if (Visibility(F.GetBallPosition, Pos, Vis) and not Completed) then -- se palla visibile avvicinati (sali/scendi)
			M := GetDirection(F.GetBallPosition, Pos, Dir);
			if(F.CheckMovement(Dir, M, PRole, Pos)) then
				Movement(ID, Dir, M, F, B);
				
				if (Visibility(F.GetBallPosition, Pos, 1)) then
					-- ******************************
					-- ******************************

					Contrast(B.GetOwner, ID, F, B, 30);
					Completed := True;
				end if;
			end if;
		elsif(F.CheckMovement(Dir, Backwd, PRole, Pos) and not Completed) then
			F.SetPosition(ID, Backwd, Dir);
			Completed := True; -- azione completata						
		end if;
	end OtherBall;	

	task body Player is
				
		Team_Possess : Boolean; -- determina il possesso della palla della squadra
		P1 : PositionList; -- vettore posizione
		P2 : Position; -- posizione della palla
		P3 : Integer; -- possessore della palla
		P4 : Position; -- posizione del giocatore
		Current_Period : Time_Span := Milliseconds(S);
		Next_Cycle : Time := Clock + Current_Period;
		
		R : Role;
		
	begin
		
		--------------------------------------
		-- permette ai giocatori di partire --
		--------------------------------------
		accept Start;
		
		loop
			-------------------------------------------------------
			-- estrae i dati necessari per eventuali valutazioni --
			-------------------------------------------------------
			P1 := F.GetPositions;
			P2 := F.GetBallPosition;
			P3 := B.GetOwner;
			P4 := F.GetPlayerPosition(ID);
			R := Prop.GetRole;
			-----------------------------------------
			-- determina se la squadra ha la palla --
			-----------------------------------------
			Team_Possess := CheckMates(P3, T);
			
			--------------------------------------------------
			-- lancia il processo decisionale del giocatore --
			--------------------------------------------------
			if (P3 = ID) then
				------------------------------
				-- Player possiede la palla --
				------------------------------
				
				PlayerBall(ID, Vis, P4, P1, R, Dir, T, F, B, Pw);
				
			elsif (Team_Possess) then
				---------------------------------------
				-- un TeamPlayer possiede il pallone --
				---------------------------------------
				TeamBall(ID, Vis, P4, R, Dir, F, B);
				
			elsif (P3 = 0) then
				--------------------------------------
				-- nessun Player controlla la palla --
				--------------------------------------
				NoneBall(ID, P4, R, Dir, F, B);
				
			else
				------------------------------------------------
				-- la squadra avversaria controlla il pallone --
				------------------------------------------------
				OtherBall(ID, Vis, P4, R, Dir, F, B);

			end if;
			
			---------------------------------------------
			-- termina il ciclo di gioco del giocatore --
			---------------------------------------------
			select
				accept Stop;
				exit;
	         else
				null;
			end select;
	        
			---------------------------------
			-- definisce il prossimo ciclo --
			---------------------------------
			Next_Cycle := Next_Cycle + Current_Period;
			delay until Next_Cycle;

		end loop;
			
	end Player;
		
end Player_Package;