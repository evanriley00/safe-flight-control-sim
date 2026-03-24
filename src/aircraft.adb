with Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;

package body Aircraft is
   function Trimmed (Value : String) return String is
   begin
      return Ada.Strings.Fixed.Trim (Value, Ada.Strings.Both);
   end Trimmed;

   function Create (
      Identifier : Flight_Types.Aircraft_Id;
      Call_Sign  : String;
      Position   : Flight_Types.Coordinate;
      Altitude   : Flight_Types.Altitude_Feet;
      Speed      : Flight_Types.Speed_Knots;
      Heading    : Flight_Types.Heading_Degrees
   ) return Aircraft_State is
   begin
      return (
         Identifier => Identifier,
         Call_Sign  => Ada.Strings.Unbounded.To_Unbounded_String (Call_Sign),
         Position   => Position,
         Altitude   => Altitude,
         Speed      => Speed,
         Heading    => Heading
      );
   end Create;

   procedure Step (
      Item    : in out Aircraft_State;
      Minutes : Positive := 1
   ) is
      use type Flight_Types.Nautical_Miles;

      Distance_Traveled : constant Float :=
        Float (Integer (Item.Speed)) * Float (Minutes) / 60.0;
      Heading_Radians : constant Float :=
        Float (Integer (Item.Heading)) * Ada.Numerics.Pi / 180.0;
      Delta_X : constant Float :=
        Ada.Numerics.Elementary_Functions.Sin (Heading_Radians) * Distance_Traveled;
      Delta_Y : constant Float :=
        Ada.Numerics.Elementary_Functions.Cos (Heading_Radians) * Distance_Traveled;
      New_X : Float := Float (Item.Position.X) + Delta_X;
      New_Y : Float := Float (Item.Position.Y) + Delta_Y;
   begin
      if New_X < 0.0 then
         New_X := 0.0;
      end if;
      if New_Y < 0.0 then
         New_Y := 0.0;
      end if;

      Item.Position := (
         X => Flight_Types.Nautical_Miles (New_X),
         Y => Flight_Types.Nautical_Miles (New_Y)
      );
   end Step;

   procedure Apply_Advisory (
      Item   : in out Aircraft_State;
      Action : Flight_Types.Advisory_Action
   ) is
   begin
      Item.Altitude := Flight_Types.Apply_Altitude_Change (Item.Altitude, Action);
      Item.Heading := Flight_Types.Apply_Heading_Change (Item.Heading, Action);
   end Apply_Advisory;

   function Summary (Item : Aircraft_State) return String is
   begin
      return
        Trimmed (Ada.Strings.Unbounded.To_String (Item.Call_Sign))
        & " | Alt:"
        & Trimmed (Flight_Types.Altitude_Feet'Image (Item.Altitude))
        & " ft | Spd:"
        & Trimmed (Flight_Types.Speed_Knots'Image (Item.Speed))
        & " kt | Hdg:"
        & Trimmed (Flight_Types.Heading_Degrees'Image (Item.Heading))
        & " | Pos:"
        & Trimmed (Flight_Types.Nautical_Miles'Image (Item.Position.X))
        & ","
        & Trimmed (Flight_Types.Nautical_Miles'Image (Item.Position.Y));
   end Summary;
end Aircraft;
