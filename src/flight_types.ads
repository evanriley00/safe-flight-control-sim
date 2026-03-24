package Flight_Types is
   type Aircraft_Id is new Positive;
   type Altitude_Feet is range 0 .. 60_000;
   type Speed_Knots is range 0 .. 700;
   type Heading_Degrees is mod 360;
   type Nautical_Miles is digits 6 range 0.0 .. 5_000.0;

   type Coordinate is record
      X : Nautical_Miles := 0.0;
      Y : Nautical_Miles := 0.0;
   end record;

   type Advisory_Action is (
      Hold_Altitude,
      Climb_1000,
      Descend_1000,
      Turn_Left_15,
      Turn_Right_15
   );

   type Separation_Status is (
      Safe,
      Advisory_Required,
      Emergency
   );

   function Distance_Between (Left, Right : Coordinate) return Nautical_Miles;
   function Apply_Altitude_Change (
      Current : Altitude_Feet;
      Action  : Advisory_Action
   ) return Altitude_Feet;
   function Apply_Heading_Change (
      Current : Heading_Degrees;
      Action  : Advisory_Action
   ) return Heading_Degrees;
end Flight_Types;
