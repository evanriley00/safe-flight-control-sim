with Ada.Exceptions;
with Ada.Strings.Fixed;
with Ada.Text_IO;
with Aircraft;
with Airspace;
with Flight_Types;

package body Scenarios is
   use type Flight_Types.Nautical_Miles;

   function Trimmed (Value : String) return String is
   begin
      return Ada.Strings.Fixed.Trim (Value, Ada.Strings.Both);
   end Trimmed;

   function Field (
      Line        : String;
      Index       : Positive;
      Line_Number : Positive
   ) return String is
      Field_Start   : Positive := Line'First;
      Current_Field : Positive := 1;
   begin
      if Line'Length = 0 then
         raise Constraint_Error with
           "Scenario line" & Trimmed (Positive'Image (Line_Number)) & " is empty";
      end if;

      for Position in Line'Range loop
         if Line (Position) = ',' then
            if Current_Field = Index then
               return Trimmed (Line (Field_Start .. Position - 1));
            end if;

            Current_Field := Current_Field + 1;
            if Position = Line'Last then
               Field_Start := Line'Last + 1;
            else
               Field_Start := Position + 1;
            end if;
         end if;
      end loop;

      if Current_Field = Index and then Field_Start <= Line'Last then
         return Trimmed (Line (Field_Start .. Line'Last));
      end if;

      raise Constraint_Error with
        "Scenario line"
        & Trimmed (Positive'Image (Line_Number))
        & " is missing field"
        & Trimmed (Positive'Image (Index));
   end Field;

   procedure Add_Line_As_Aircraft (
      Space       : in out Airspace.Airspace_State;
      Line        : String;
      Line_Number : Positive
   ) is
      Identifier : constant Flight_Types.Aircraft_Id :=
        Flight_Types.Aircraft_Id'Value (Field (Line, 1, Line_Number));
      Call_Sign : constant String := Field (Line, 2, Line_Number);
      Position_X : constant Flight_Types.Nautical_Miles :=
        Flight_Types.Nautical_Miles'Value (Field (Line, 3, Line_Number));
      Position_Y : constant Flight_Types.Nautical_Miles :=
        Flight_Types.Nautical_Miles'Value (Field (Line, 4, Line_Number));
      Altitude : constant Flight_Types.Altitude_Feet :=
        Flight_Types.Altitude_Feet'Value (Field (Line, 5, Line_Number));
      Speed : constant Flight_Types.Speed_Knots :=
        Flight_Types.Speed_Knots'Value (Field (Line, 6, Line_Number));
      Heading : constant Flight_Types.Heading_Degrees :=
        Flight_Types.Heading_Degrees'Value (Field (Line, 7, Line_Number));
   begin
      if Call_Sign'Length = 0 then
         raise Constraint_Error with
           "Scenario line"
           & Trimmed (Positive'Image (Line_Number))
           & " has an empty call sign";
      end if;

      Airspace.Add_Aircraft (
         Space,
         Aircraft.Create (
            Identifier => Identifier,
            Call_Sign  => Call_Sign,
            Position   => (X => Position_X, Y => Position_Y),
            Altitude   => Altitude,
            Speed      => Speed,
            Heading    => Heading
         )
      );
   exception
      when Error : others =>
         raise Constraint_Error with
           "Invalid scenario line"
           & Trimmed (Positive'Image (Line_Number))
           & ": "
           & Ada.Exceptions.Exception_Message (Error);
   end Add_Line_As_Aircraft;

   procedure Load_From_File (
      Space : out Airspace.Airspace_State;
      Path  : String
   ) is
      Scenario_File : Ada.Text_IO.File_Type;
      Buffer        : String (1 .. 256);
      Last          : Natural;
      Line_Number   : Natural := 0;
   begin
      Airspace.Initialize (Space);

      Ada.Text_IO.Open (Scenario_File, Ada.Text_IO.In_File, Path);
      while not Ada.Text_IO.End_Of_File (Scenario_File) loop
         Ada.Text_IO.Get_Line (Scenario_File, Buffer, Last);
         Line_Number := Line_Number + 1;

         declare
            Line : constant String := Trimmed (Buffer (1 .. Last));
         begin
            if Line'Length = 0 or else Line (Line'First) = '#' then
               null;
            else
               Add_Line_As_Aircraft (Space, Line, Positive (Line_Number));
            end if;
         end;
      end loop;
      Ada.Text_IO.Close (Scenario_File);

      if Airspace.Count (Space) = 0 then
         raise Constraint_Error with "Scenario file contains no aircraft entries";
      end if;
   exception
      when Ada.Text_IO.Name_Error =>
         raise Constraint_Error with "Scenario file not found: " & Path;
      when Ada.Text_IO.End_Error =>
         raise Constraint_Error with "Scenario line exceeds 256 characters in " & Path;
      when Error : others =>
         if Ada.Text_IO.Is_Open (Scenario_File) then
            Ada.Text_IO.Close (Scenario_File);
         end if;
         raise Constraint_Error with Ada.Exceptions.Exception_Message (Error);
   end Load_From_File;

   procedure Load_Default (Space : out Airspace.Airspace_State) is
   begin
      Load_From_File (Space, Default_Scenario_Path);
   end Load_Default;
end Scenarios;
