------------------------------------------------------
--
-- processo arbitro
--
--
--
------------------------------------------------------
with Field_Package;		use Field_Package;
with Ball_Package;		use Ball_Package;
with Player_Package;	use Player_Package;

package Referee_Package is
	
	-- controlla se la palla e' uscita dai bordi
	procedure OutOfBorder(F : Field_Access; B : Ball_Access);
	
	task type Referee (F : Field_Access; B : Ball_Access) is

		pragma Priority(3);
		
		entry Goal;
		
		entry Fault;
		
	end Referee;

	-- tipo access al tipo player
	type Referee_Access is access Referee;

end Referee_Package;
