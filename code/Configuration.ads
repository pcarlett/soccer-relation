with Field_Package; with Ball_Package; with Referee_Package; with Player_Package; with Team_Package; with Manager_Package;

configuration Config is 

	-- definizione di Manager e uso dei package
	fragment Manager1 is
		use Manager_Package;
	end Manager1;

	fragment Manager2 is
		use Manager_Package;
	end Manager2;

	-- definizione di Player e uso dei package
	fragment Player1 is
		use Player_Package;
	end Player1;
	
	fragment Player2 is
		use Player_Package;
	end Player2;

	-- definizione di Team e uso dei package
	fragment Team1 is
		use Team_Package;
	end Team1;
	
	fragment Team2 is
		use Team_Package;
	end Team2;

	-- definizione del campo
	fragment Field0 is
		use Field_Package;
	end Field0;
	
	-- definizione del pallone
	fragment Ball0 is
		use Ball_Package;
	end Ball0;

	-- definizione dell'arbitro
	fragment Referee0 is
		use Referee_Package;
	end Referee0;
	
end Config;	