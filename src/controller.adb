with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with Aircraft;
with Flight_Types;
with Logger;

package body Controller is
   function Trimmed (Value : String) return String is
   begin
      return Ada.Strings.Fixed.Trim (Value, Ada.Strings.Both);
   end Trimmed;

   procedure Resolve_Conflict (
      Space  : in out Airspace.Airspace_State;
      Report : Safety.Conflict_Report
   ) is
      Left_Aircraft  : Aircraft.Aircraft_State := Airspace.Get_Aircraft (Space, Report.Left_Index);
      Right_Aircraft : Aircraft.Aircraft_State := Airspace.Get_Aircraft (Space, Report.Right_Index);
   begin
      if not Report.Has_Conflict then
         return;
      end if;

      Logger.Log (
        "Conflict detected: "
        & Ada.Strings.Unbounded.To_String (Report.Message)
        & " | horizontal="
        & Trimmed (Flight_Types.Nautical_Miles'Image (Report.Horizontal_Distance))
        & " nm | vertical="
        & Trimmed (Natural'Image (Report.Vertical_Distance))
        & " ft"
      );

      Aircraft.Apply_Advisory (Left_Aircraft, Report.Left_Action);
      Aircraft.Apply_Advisory (Right_Aircraft, Report.Right_Action);

      Logger.Log (
        "Resolution issued: "
        & Ada.Strings.Unbounded.To_String (Left_Aircraft.Call_Sign)
        & " -> "
        & Trimmed (Flight_Types.Advisory_Action'Image (Report.Left_Action))
        & ", "
        & Ada.Strings.Unbounded.To_String (Right_Aircraft.Call_Sign)
        & " -> "
        & Trimmed (Flight_Types.Advisory_Action'Image (Report.Right_Action))
      );

      Airspace.Update_Aircraft (Space, Report.Left_Index, Left_Aircraft);
      Airspace.Update_Aircraft (Space, Report.Right_Index, Right_Aircraft);
   end Resolve_Conflict;
end Controller;
