package Logger is
   procedure Reset;
   procedure Set_Enabled (Enabled : Boolean);
   procedure Set_Minute (Minute : Natural);
   procedure Log (Message : String);
   procedure Section (Title : String);
end Logger;
