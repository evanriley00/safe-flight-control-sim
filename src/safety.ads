with Ada.Strings.Unbounded;
with Airspace;
with Flight_Types;

package Safety is
   use Ada.Strings.Unbounded;

   type Conflict_Report is record
      Has_Conflict        : Boolean := False;
      Left_Index          : Positive := 1;
      Right_Index         : Positive := 1;
      Horizontal_Distance : Flight_Types.Nautical_Miles := 0.0;
      Vertical_Distance   : Natural := 0;
      Severity            : Flight_Types.Separation_Status := Flight_Types.Safe;
      Left_Action         : Flight_Types.Advisory_Action := Flight_Types.Hold_Altitude;
      Right_Action        : Flight_Types.Advisory_Action := Flight_Types.Hold_Altitude;
      Message             : Unbounded_String := Null_Unbounded_String;
   end record;

   function Find_First_Conflict (Space : Airspace.Airspace_State) return Conflict_Report;
end Safety;
