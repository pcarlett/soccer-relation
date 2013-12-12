with Ada.Real_Time;					use	Ada.Real_Time;
with Ada.Text_IO;					use Ada.Text_IO;

package body Manager_Package is

	procedure ChangeModule (Md : in Module; Pr : PropsArray_Access) is
	begin
		Put_Line("### Cambio Modulo ###");
		case Md is
			when Mod442 =>
				-- cambia il ruolo dei 10 giocatori
				Pr( 2).SetRole(LDF);
				Pr( 3).SetRole(CDF);
				Pr( 4).SetRole(CDF);
				Pr( 5).SetRole(RDF);
				Pr( 6).SetRole(LMF);
				Pr( 7).SetRole(CMF);
				Pr( 8).SetRole(CMF);
				Pr( 9).SetRole(RMF);
				Pr(10).SetRole(LFW);
				Pr(11).SetRole(RFW);				                    
			when Mod352 =>
				-- cambia il ruolo dei 10 giocatori
				Pr( 2).SetRole(LDF);
				Pr( 3).SetRole(CDF);
				Pr( 4).SetRole(RDF);
				Pr( 5).SetRole(LMF);
				Pr( 6).SetRole(CMF);
				Pr( 7).SetRole(CMF);
				Pr( 8).SetRole(CMF);
				Pr( 9).SetRole(RMF);
				Pr(10).SetRole(LFW);
				Pr(11).SetRole(RFW);				                    
			when Mod343 =>
				-- cambia il ruolo dei 10 giocatori
				Pr( 2).SetRole(LDF);
				Pr( 3).SetRole(CDF);
				Pr( 4).SetRole(RDF);
				Pr( 5).SetRole(LMF);
				Pr( 6).SetRole(CMF);
				Pr( 7).SetRole(CMF);
				Pr( 8).SetRole(RMF);
				Pr( 9).SetRole(LFW);
				Pr(10).SetRole(CFW);
				Pr(11).SetRole(RFW);				                    
			when Mod451 =>
				-- cambia il ruolo dei 10 giocatori
				Pr( 2).SetRole(LDF);
				Pr( 3).SetRole(CDF);
				Pr( 4).SetRole(CDF);
				Pr( 5).SetRole(RDF);
				Pr( 6).SetRole(LMF);
				Pr( 7).SetRole(CMF);
				Pr( 8).SetRole(CMF);
				Pr( 9).SetRole(CMF);
				Pr(10).SetRole(RMF);
				Pr(11).SetRole(STK);				                    
			when others =>
				null;
		end case;
	end ChangeModule;
	
	-- function GetFieldState() return PlayerList;
	
	-- procedure ChangePlayers(A : in Player; B : in Player);
	
	-- procedure ChangeStrategy(A : in Strategy);

	task body Manager is
	
		-- T: team
		Current_Period : Time_Span := Milliseconds(S);
		Next_Cycle : Time := Clock + Current_Period;
	
		InitR1, InitR2, R1, R2 : Integer;
	begin
		------------------------------------
		-- permette al manager di partire --
		------------------------------------
		accept Start;

		InitR1 := 0;
		InitR2 := 0;

		loop
			
			R1 := F.GetScore(1);
			R2 := F.GetScore(2);
			-----------------------------------------------------------------
			-- controlla il risultato della partita e cambia la formazione --
			-----------------------------------------------------------------
			if (R1 /= InitR1 or R2 /= InitR2) then
				if (Dir = 1) then
					if (R1 < R2) then
						-- modulo d'attacco
						ChangeModule (Mod343, Pr);
					elsif  (R1 > R2) then
						-- modulo di difesa
						ChangeModule (Mod451, Pr);
					else
						-- modulo equilibrato
						ChangeModule (Mod442, Pr);
					end if;
				else
					if (R2 < R1) then
						-- modulo d'attacco
						ChangeModule (Mod343, Pr);
					elsif  (R2 > R1) then
						-- modulo di difesa
						ChangeModule (Mod451, Pr);
					else
						-- modulo equilibrato
						ChangeModule (Mod442, Pr);
					end if;
					-- cambia il modulo sulla base del risultato (result2)			
				end if;
				InitR1 := R1;
				InitR2 := R2;
			end if;
			
			-------------------------------------------
			-- termina il ciclo di gioco del manager --
			-------------------------------------------
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

	end Manager;
	
end Manager_Package;