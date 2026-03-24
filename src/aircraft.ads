with Ada.Strings.Unbounded;
with Flight_Types;

package Aircraft is
   use Ada.Strings.Unbounded;

   type Aircraft_State is record
      Identifier : Flight_Types.Aircraft_Id := 1;
      Call_Sign  : Unbounded_String := Null_Unbounded_String;
      Position   : Flight_Types.Coordinate := (X => 0.0, Y => 0.0);
      Altitude   : Flight_Types.Altitude_Feet := 30_000;
      Speed      : Flight_Types.Speed_Knots := 450;
      Heading    : Flight_Types.Heading_Degrees := 0;
   end record;

   function Create (
      Identifier : Flight_Types.Aircraft_Id;
      Call_Sign  : String;
      Position   : Flight_Types.Coordinate;
      Altitude   : Flight_Types.Altitude_Feet;
      Speed      : Flight_Types.Speed_Knots;
      Heading    : Flight_Types.Heading_Degrees
   ) return Aircraft_State;

   procedure Step (
      Item    : in out Aircraft_State;
      Minutes : Positive := 1
   );

   procedure Apply_Advisory (
      Item   : in out Aircraft_State;
      Action : Flight_Types.Advisory_Action
   );

   function Summary (Item : Aircraft_State) return String;
end Aircraft;
