with Ada.Real_Time;		use	Ada.Real_Time;

package body Ball_Package is

	task body TaskBall is
		-- B: palla
		Current_Period : Time_Span := Milliseconds(S);
		Next_Cycle : Time := Clock + Current_Period;
	begin
		-- inizializza il movimento della palla
		accept Start;

		loop
			----------------------
			-- muove il pallone --
			----------------------
			B.Movement;
			
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
	end TaskBall;

	-- corpo dell'oggetto protetto
	protected body Ball is

		-- F: field access
		
		entry StopMoving
			when Owner = 0 and Moving is
		begin
				Moving := False;
	
		end StopMoving;
		
		-- imposta il proprietario del pallone 
		entry Control (ID : in Integer)
			when Owner = 0 is
		begin
			Owner := ID;
		end Control;
		
		-- gestisce il movimento della palla
		entry Movement
			when Moving and Owner = 0 is
		begin
			F.SetBallPosition(Step, Dir);
			Power := Power - 1;
			if (Power = 0) then
				Moving := False;
			end if;
		end Movement;
			
		entry Kick (D : in Integer; S : in Move; Pw : in Integer)
			when Owner /= 0 is
		begin
			Owner := 0;
			Dir := D;
			Step := S;
			Power := Pw;
			Moving := True;
		end Kick;
		
		-- ritorna il possessore della palla
		function GetOwner return Integer is
		begin
			return Owner;
		end GetOwner;
				
	end Ball;

end Ball_Package;
