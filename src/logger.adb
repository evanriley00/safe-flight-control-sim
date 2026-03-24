with Ada.Strings.Fixed;
with Ada.Text_IO;

package body Logger is
   Current_Minute : Natural := 0;
   Is_Enabled     : Boolean := True;

   function Trimmed (Value : String) return String is
   begin
      return Ada.Strings.Fixed.Trim (Value, Ada.Strings.Both);
   end Trimmed;

   procedure Reset is
   begin
      Current_Minute := 0;
      Is_Enabled := True;
   end Reset;

   procedure Set_Enabled (Enabled : Boolean) is
   begin
      Is_Enabled := Enabled;
   end Set_Enabled;

   procedure Set_Minute (Minute : Natural) is
   begin
      Current_Minute := Minute;
   end Set_Minute;

   procedure Log (Message : String) is
   begin
      if Is_Enabled then
         Ada.Text_IO.Put_Line (
           "[T+"
           & Trimmed (Natural'Image (Current_Minute))
           & "m] "
           & Message
         );
      end if;
   end Log;

   procedure Section (Title : String) is
   begin
      if Is_Enabled then
         Ada.Text_IO.New_Line;
         Ada.Text_IO.Put_Line ("=== " & Title & " ===");
      end if;
   end Section;
end Logger;
