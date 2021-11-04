local e = {}

e.PermissionLevel = {
	Custom = -1;
	Visitor = 100;
	Support = 125;
	Observer = 150;
	TrialMod = 175;
	Aux = 200;
	JrMod = 225;
	SrMod = 300;
	Admin = 400;
}

e.Arguments = {
	UsernameInGame = 0;
	DisplayNameInGame = 1;
	Username = 2;
	UserId = 3;
	Number = 4;
	Text = 5;
	Boolean = 6;
	Any = 7;
}

e.Necessity = {
	Required = 0;
	Optional = 1;
}

e.FailureType = {
    InvalidArgs = "One or more arguments provided were not of the correct type!";
    MissingArgs = "You were missing one or more required arguments!";
    InvalidPerms = "You don't have permission to run this command!";
}

return e