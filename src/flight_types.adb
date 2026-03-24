with Ada.Numerics.Elementary_Functions;

package body Flight_Types is
   function Distance_Between (Left, Right : Coordinate) return Nautical_Miles is
      DX : constant Float := Float (Left.X) - Float (Right.X);
      DY : constant Float := Float (Left.Y) - Float (Right.Y);
   begin
      return Nautical_Miles (Ada.Numerics.Elementary_Functions.Sqrt ((DX * DX) + (DY * DY)));
   end Distance_Between;

   function Apply_Altitude_Change (
      Current : Altitude_Feet;
      Action  : Advisory_Action
   ) return Altitude_Feet is
   begin
      case Action is
         when Climb_1000 =>
            return Altitude_Feet'Min (Altitude_Feet'Last, Current + 1_000);
         when Descend_1000 =>
            return Altitude_Feet'Max (Altitude_Feet'First, Current - 1_000);
         when others =>
            return Current;
      end case;
   end Apply_Altitude_Change;

   function Apply_Heading_Change (
      Current : Heading_Degrees;
      Action  : Advisory_Action
   ) return Heading_Degrees is
   begin
      case Action is
         when Turn_Left_15 =>
            return Current - 15;
         when Turn_Right_15 =>
            return Current + 15;
         when others =>
            return Current;
      end case;
   end Apply_Heading_Change;
end Flight_Types;
