------------------------------------------------------
--
-- gestione della palla
--
--
--
------------------------------------------------------
with Field_Package;
use Field_Package;

package Ball_Package is

	-- dichiarazione di oggetto remoto
	-- pragma Remote_Types;

	protected type Ball (F : Field_Access) is
		
		entry StopMoving;
		
		-- imposta il proprietario del pallone
		entry Control (ID : in Integer);
		
		entry Movement;
		
		entry Kick (D : in Integer; S : in Move; Pw : in Integer);
		
		-- ritorna il possessore della palla
		function GetOwner return Integer;

		private
		
			Owner : Integer := 0; -- ID del proprietario della palla
			Moving : Boolean := False; -- Palla in movimento?
			Dir : Integer; -- +1 o -1 per la direzione del movimento verso la porta
			Power : Integer; -- potenza applicata al tiro
			Step : Move; -- direzione effettiva del lancio (avanti, indietro, su, giu)
	
	end Ball;
	
	type Ball_Access is access Ball;

	task type TaskBall (F : Field_Access; B : Ball_Access; S : Integer) is

		pragma Priority(1);	
		
		entry Start;
		
		entry Stop;
		
	end TaskBall;

	type TaskBall_Access is access TaskBall;

end Ball_Package;