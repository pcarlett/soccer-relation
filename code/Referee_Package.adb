with Ada.Text_IO;					use Ada.Text_IO;

package body Referee_Package is
	
	procedure OutOfBorder(F : Field_Access; B : Ball_Access) is
		Goal : Boolean := False;
	begin
		if (F.OverHorizzontalLimit) then
			F.GoalReached (Goal);
			if (Goal) then
				B.StopMoving;
				F.InitField;
				Put_Line("*** Referee: Goal Reached!");
			else
				B.StopMoving;
				F.BallToKeeper;
				Put_Line("*** Referee: Ball Out of Horizzontal Border!");
			end if;
		elsif (F.OverVerticalLimit) then
			B.StopMoving;
			F.LateralReposition;
			Put_Line("*** Referee: Ball Out of Vertical Border!");
		end if;
	end OutOfBorder;
	
	task body Referee is
		
	begin
		
		loop
			OutOfBorder (F, B);
				
		
		end loop;
		
		select
			accept Goal do
				-- ***********
				-- notifica il gol e aggiorna il risultato
				null;
			end Goal;
		or
			accept Fault do
				-- ***********
				-- notifica il fallo, riposiziona i giocatori e riprende il gioco
				null;
			end Fault;
		end select;
	end Referee;

end Referee_Package;