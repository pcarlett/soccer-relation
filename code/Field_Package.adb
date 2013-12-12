with Ada.Text_IO;					use Ada.Text_IO;
with Ada.Numerics.Elementary_Functions;

package body Field_Package is

	function "-" (A, B : Position) return Integer is
		X, Y, Z : Integer;
	begin
		X := abs (A.Row - B.Row);
		Y := abs (A.Col - B.Col);
		Z := Integer( Ada.Numerics.Elementary_Functions.Sqrt (Float(X**2) + Float(Y**2)) );
		return Z;
	end "-";
	
	function "=" (A, B : Position) return Boolean is
		X : Boolean := False;
	begin
		if (A.Row = B.Row) then
			if (A.Col = B.Col) then
				X := True;
			end if;
		end if;
		return X;
	end "=";

	function Near(A, B : Position) return Boolean is
		X : Boolean := False;
	begin
		if ((A.Row = B.Row - 1) or (A.Row = B.Row + 1) or (A.Row = B.Row - 2) or (A.Row = B.Row + 2)) then
			if ((A.Col = B.Col - 1) or (A.Col = B.Col + 1) or (A.Col = B.Col - 2) or (A.Col = B.Col + 2)) then
				X := True;
			end if;
		end if;
		return X;
	end Near;
		
	-- funzione per la definizione dei limiti di movimento dei ruoli
	procedure RoleLimit(Dir : in Integer; R : in Role; A,B,C,D : out Integer) is
	begin
		if (Dir = 1) then
			case R is
				when STK => A := 38; 	B := 248; 	C := 166; 	D := 315;
				when LFW => A := 0; 	B := 210; 	C := 104; 	D := 315;
				when CFW => A := 53; 	B := 210; 	C := 151; 	D := 315;
				when RFW => A := 103; 	B := 210; 	C := 204; 	D := 315;
				when LMF => A := 0; 	B := 68; 	C := 90; 	D := 248;
				when CMF => A := 45; 	B := 105; 	C := 159; 	D := 210;
				when RMF => A := 114; 	B := 68; 	C := 204; 	D := 248;
				when LDF => A := 0; 	B := 0; 	C := 100; 	D := 135;
				when CDF => A := 30; 	B := 0; 	C := 174; 	D := 113;
				when RDF => A := 104; 	B := 0; 	C := 204; 	D := 135;
				when GKP => A := 53; 	B := 0; 	C := 151; 	D := 50;
			end case;
		else
			case R is
				when STK => A := 38;   B := 315 - 248;  C := 166; 	D := 315 - 315;
				when LFW => A := 100;  B := 315 - 210;  C := 204; 	D := 315 - 315;
				when CFW => A := 53;   B := 315 - 210;  C := 151; 	D := 315 - 315;
				when RFW => A := 0;    B := 315 - 210;  C := 100; 	D := 315 - 315;
				when LMF => A := 114;  B := 315 - 68; 	C := 204; 	D := 315 - 248;
				when CMF => A := 45;   B := 315 - 105;  C := 159; 	D := 315 - 210;
				when RMF => A := 0;    B := 315 - 68; 	C := 90;  	D := 315 - 248;
				when LDF => A := 104;  B := 315 - 0; 	C := 204; 	D := 315 - 135;
				when CDF => A := 30;   B := 315 - 0; 	C := 174; 	D := 315 - 113;
				when RDF => A := 0;    B := 315 - 0; 	C := 100;  	D := 315 - 135;
				when GKP => A := 53;   B := 315 - 0; 	C := 151; 	D := 315 - 50;
			end case;
		end if;
	end RoleLimit;	
		
	protected body Field is 
	
		-- funzione per inizializzare le posizioni
		procedure InitField is
			P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11,
			P12, P13, P14, P15, P16, P17, P18, P19, P20, P21, P22 : Position;
		begin
			-- crea le posizioni
			P1 := (1, 102, 10); P2 := (2, 41, 50); P3 := (3, 71, 50); P4 := (4, 133, 50);
			P5 := (5, 163, 50); P6 := (6, 41, 110); P7 := (7, 71, 110); P8 := (8, 133, 110);
			P9 := (9, 163, 150); P10 := (10, 68, 150); P11 := (11, 136, 150);
			P12 := (12, 102, 305); P13 := (13, 41, 265); P14 := (14, 71, 265);
			P15 := (15, 133, 265); P16 := (16, 163, 265);
			P17 := (17, 41, 205); P18 := (18, 71, 205); P19 := (19, 133, 205);
			P20 := (20, 163, 205); P21 := (21, 68, 165); P22 := (22, 136, 165);
						
			-- inizializza gli ID, la riga e la colonna
			PList(1) := P1; PList(2) := P2; PList(3) := P3; PList(4) := P4; PList(5) := P5; PList(6) := P6;
			PList(7) := P7; PList(8) := P8; PList(9) := P9; PList(10) := P10; PList(11) := P11;
			PList(12) := P12; PList(13) := P13; PList(14) := P14; PList(15) := P15; PList(16) := P16; PList(17) := P17;
			PList(18) := P18; PList(19) := P19; PList(20) := P20; PList(21) := P21; PList(22) := P22;
			
			-- inizializza la posizione della palla
			Ball := (0, 102, 157);
		end InitField;
			
		-- funzione per leggere lo stato del campo
		function GetPositions return PositionList is
		begin
			return PList;
		end GetPositions;
			
		-- funzione per la posizione di un giocatore specifico
		function GetPlayerPosition (ID : in Integer) return Position is
			P : Position;
		begin
			for i in 1..22 loop
				if (PList(i).ID = ID) then
					P := PList(i);
				end if;
			end loop;
			return P;
		end GetPlayerPosition;
			
		-- procedura per il controllo della possibilita' di movimento se intersezione libera
		function CheckCell(Pos : in Position) return Boolean is
			Flag : Boolean := True;
		begin
			for i in PList'Range loop 
				if (Pos = PList(i)) then
					Flag := False;
					exit;
				end if;
			end loop;
			return Flag;
		end CheckCell;		
			
		-- procedura per la modifica dello stato del campo su un oggetto protetto
		procedure SetPosition (ID : in Integer; M : in Move; Dir : in Integer) is
		begin
			for i in 1..22 loop -- 
				if (PList(i).ID = ID) then

					case M is
						when Up =>
							PList(i).Row := PList(i).Row - 1;
						when Down =>
							PList(i).Row := PList(i).Row + 1;
						when Forwd =>
							if (Dir = 1) then
								PList(i).Col := PList(i).Col + 1;
							else
								PList(i).Col := PList(i).Col - 1;
							end if;
						when Backwd =>
							if (Dir = 1) then
								PList(i).Col := PList(i).Col - 1;
							else
								PList(i).Col := PList(i).Col + 1;
							end if;
						when others =>
							null;
					end case;
				end if;
			end loop;
		end SetPosition;
		
		-- procedura per la modifica dello stato del campo su un oggetto protetto
		procedure SetPosition (ID : in Integer; P : in Position) is
		begin
			for i in 1..22 loop
				if (PList(i).ID = ID) then
					PList(i).Row := P.Row;
					PList(i).Col := P.Col;
				end if;
			end loop;
		end SetPosition;
		
		-- procedura per la modifica dello stato della palla in campo
		procedure SetBallPosition (M : in Move; Dir : in Integer) is
		begin
			case M is
				when Up =>
					Ball.Row := Ball.Row - 1;
				when Down =>
					Ball.Row := Ball.Row + 1;
				when Forwd =>
					if (Dir = 1) then
						Ball.Col := Ball.Col + 1;
					else
						Ball.Col := Ball.Col - 1;
					end if;
				when Backwd =>
					if (Dir = 1) then
						Ball.Col := Ball.Col - 1;
					else
						Ball.Col := Ball.Col + 1;
					end if;
				when others =>
					null;
			end case;
		end SetBallPosition;
		
		-- procedura per la modifica dello stato della palla in campo
		procedure SetBallPosition (P : in Position) is
		begin
			Ball.Row := P.Row;
			Ball.Col := P.Col;
		end SetBallPosition;
		
		-- funzione per il test del movimento
		function CheckMovement(Dir : in Integer; M : in Move; PRole : in Role; Pos : in Position) return Boolean is
			A, B, C, D : Integer;
			Flag : Boolean := False; -- con True allora movimento completo: problema di integrita'
			TempPos : Position;
		begin
			RoleLimit (Dir, PRole, A, B, C, D);
			case M is
				when Up =>
					TempPos := Pos;
					TempPos.Row := TempPos.Row - 1;
					if (TempPos.Row < A and CheckCell(TempPos)) then
						Flag := True;
					end if;
				when Down =>
					TempPos := Pos;
					TempPos.Row := TempPos.Row + 1;
					if (TempPos.Row < C and CheckCell(TempPos)) then
						Flag := True;
					end if;
				when Forwd =>
					if (Dir = 1) then
						TempPos := Pos;
						TempPos.Col := TempPos.Col + 1;
						if (TempPos.Col < D and CheckCell(TempPos)) then
							Flag := True;
						end if;
					else
						TempPos := Pos;
						TempPos.Col := TempPos.Col - 1;
						if (TempPos.Col > D and CheckCell(TempPos)) then
							Flag := True;
						end if;
					end if;
				when Backwd =>
					if (Dir = 1) then
						TempPos := Pos;
						TempPos.Col := TempPos.Col - 1;
						if(TempPos.Col > B and CheckCell(TempPos)) then
							Flag := True;
						end if;
					else
						TempPos := Pos;
						TempPos.Col := TempPos.Col + 1;
						if(TempPos.Col < B and CheckCell(TempPos)) then
							Flag := True;
						end if;
					end if;
				when others =>
					null;
			end case;
			return Flag;
		end CheckMovement;

		-- funzione per testare se il compagno e' avanzato
		function Forward(To, From : Position; Dir : Integer) return Boolean is
			Flag : Boolean := False;
			Var : Integer := 0;
		begin
			if (Dir = 1) then
				if (To.Col >= (From.Col - Var)) then
					Flag := True;
				end if;
			else
				if (To.Col <= (From.Col + Var)) then
					Flag := True;
				end if;
			end if;
			return Flag;
		end Forward;

		-- funzione per la restituzione della posizione del pallone
		function GetBallPosition return Position is
		begin
			return Ball;
		end GetBallPosition;
		
		-- funzione per la restituzione della posizione della porta
		procedure GetGoalPosition (D : in Integer; A : out Position; B : out Position) is
		begin
			if (D = 1) then
				A := G1_P1;
				B := G1_P2;
			else
				A := G2_P1;
				B := G2_P2;
			end if;
		end GetGoalPosition;
		
		procedure ResetPosition (ID : in Integer; P : Position) is
		begin
			for i in 1..22 loop
				if (PList(i).ID = ID) then
					PList(i).Row := P.Row;
					PList(i).Col := P.Col;
				end if;
			end loop;
		end ResetPosition;

		-- funzione per testare se la palla e' in campo
		function IsBallPlayable return Boolean is
			Test1 : Boolean := False;
			Test2 : Boolean := False;
			Test3 : Boolean := False;
		begin
			if (Ball.Row >= 0 and Ball.Row <= 204) then
				Test1 := True;
			end if;
			if (Ball.Col >= 0 and Ball.Col <= 315) then
				Test2 := True;
			end if;
			if (Test1 and Test2) then
				Test3 := True;
			end if;
			return Test3;
		end IsBallPlayable;
		
		-- funzione per testare se la palla e' uscita lateralemente
		function OverVerticalLimit return Boolean is
			Test : Boolean := False;
		begin
			if (Ball.Row < 0 or Ball.Row > 204) then
				Test := True;
			end if;
			return Test;
		end OverVerticalLimit;
		
		-- funzione per testare se la palla e' uscita dal fondo
		function OverHorizzontalLimit return Boolean is
			Test : Boolean := False;
		begin
			if (Ball.Col < 0 or Ball.Col > 315) then
				Test := True;
			end if;
			return Test;
		end OverHorizzontalLimit;
		
		-- procedura per restituire la palla al portiere
		procedure BallToKeeper is
		begin
			if (Ball.Col < 0) then
				Ball := GetPlayerPosition(1);
			else
				Ball := GetPlayerPosition(12);
			end if;
		end BallToKeeper;
		
		-- funzione per testare se la palla e' in rete
		procedure GoalReached(B : in out Boolean) is
			Goal : Boolean := False;
		begin
			if (Ball.Row > 92 and Ball.Row < 112) then
				if (Ball.Col <= 0) then
					Result2 := Result2 + 1;
				else
					Result1 := Result1 + 1;
				end if;				
				Goal := True;
			end if;
			B := Goal;
		end GoalReached;
		
		-- funzione per riposizionare la palla
		procedure LateralReposition is
		begin
			if (Ball.Row <= 0) then
				Ball.Row := 1;
			elsif (Ball.Row >= 204) then
				Ball.Row := 203;
			end if;
		end LateralReposition;
		
		-- procedura per impostare il risultato
		procedure SetScore (I : in Integer) is
		begin
			if (I = 1) then
				Result1 := Result1 + 1;
			else
				Result2 := Result2 + 1;
			end if;
		end SetScore;
		
		-- procedura per ottenere il risultato parziale del match
		function GetScore(I : Integer) return Integer is
		begin
			if (I = 1) then
				return Result1;
			else
				return Result2;
			end if;
		end GetScore;
		
	end Field;
	
end Field_Package;
