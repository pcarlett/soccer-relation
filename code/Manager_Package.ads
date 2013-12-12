------------------------------------------------------
--
-- processo manager 
--
--
--
------------------------------------------------------
with Field_Package;			use Field_Package;
with Player_Package;		use Player_Package;

package Manager_Package is
	
	type Strategy is (Attack, Middle, Defense);
	
	type Module is (Mod442, Mod352, Mod343, Mod451);
		
	procedure ChangeModule(Md : in Module; Pr : PropsArray_Access);
	
	-- procedure ChangePlayers(A : in Player; B : in Player);
	
	-- procedure ChangeStrategy(A : in Strategy);

	task type Manager (F : Field_Access; T : Team_Access; Pr : PropsArray_Access; Dir : Integer; S : Integer) is

		entry Start;
		
		entry Stop;

		pragma Priority(2);

	end Manager;
	
	type Manager_Access is access Manager;
	
end Manager_Package;