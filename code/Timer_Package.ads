------------------------------------------------------
--
-- processo timer
--
--
--
------------------------------------------------------
with Player_Package;		use Player_Package;
with Manager_Package;		use Manager_Package;
with Ball_Package;			use Ball_Package;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Elementary_Functions;
use  Ada.Numerics.Elementary_Functions;

package Timer_Package is 

	protected type TimeCount is
				
		entry Increment;
				
		-- ritorna il valore del tempo di gioco
		function GetTime return Integer;
		
		-- ritorna il tempo toale per la partita
		function GetTotalTime return Integer;

		private
		
			TotalTime : Integer := 45000;
			Timing : Integer := 0;
			
	end TimeCount;
	
	-- tipo access al tipo timecount	
	type TimeCount_Access is access TimeCount;

	task type Timer (T : TimeCount_Access; T1, T2 : Team_Access; M1, M2 : Manager_Access; B : TaskBall_Access) is	

		pragma Priority(5);
					
		entry Start;
			
	end Timer;

	-- tipo access al tipo timer
	type Timer_Access is access Timer;

end Timer_Package;