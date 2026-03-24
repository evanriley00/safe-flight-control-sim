with Ada.Strings.Unbounded;
with Aircraft;

package body Safety is
   use type Flight_Types.Altitude_Feet;
   use type Flight_Types.Nautical_Miles;
   use type Flight_Types.Separation_Status;

   function Vertical_Delta (
      Left  : Flight_Types.Altitude_Feet;
      Right : Flight_Types.Altitude_Feet
   ) return Natural is
   begin
      if Left >= Right then
         return Natural (Left - Right);
      else
         return Natural (Right - Left);
      end if;
   end Vertical_Delta;

   function Recommend_For_Left (
      Left  : Aircraft.Aircraft_State;
      Right : Aircraft.Aircraft_State
   ) return Flight_Types.Advisory_Action is
   begin
      if Left.Altitude <= Right.Altitude then
         return Flight_Types.Descend_1000;
      else
         return Flight_Types.Climb_1000;
      end if;
   end Recommend_For_Left;

   function Recommend_For_Right (
      Left  : Aircraft.Aircraft_State;
      Right : Aircraft.Aircraft_State
   ) return Flight_Types.Advisory_Action is
   begin
      if Left.Altitude <= Right.Altitude then
         return Flight_Types.Climb_1000;
      else
         return Flight_Types.Descend_1000;
      end if;
   end Recommend_For_Right;

   function Find_First_Conflict (Space : Airspace.Airspace_State) return Conflict_Report is
   begin
      for Left_Index in 1 .. Airspace.Count (Space) loop
         for Right_Index in Left_Index + 1 .. Airspace.Count (Space) loop
            declare
               Left_Aircraft : constant Aircraft.Aircraft_State :=
                 Airspace.Get_Aircraft (Space, Left_Index);
               Right_Aircraft : constant Aircraft.Aircraft_State :=
                 Airspace.Get_Aircraft (Space, Right_Index);
               Horizontal : constant Flight_Types.Nautical_Miles :=
                 Flight_Types.Distance_Between (Left_Aircraft.Position, Right_Aircraft.Position);
               Vertical : constant Natural :=
                 Vertical_Delta (Left_Aircraft.Altitude, Right_Aircraft.Altitude);
               Severity : Flight_Types.Separation_Status := Flight_Types.Safe;
            begin
               if Horizontal < 3.0 and then Vertical < 500 then
                  Severity := Flight_Types.Emergency;
               elsif Horizontal < 5.0 and then Vertical < 1_000 then
                  Severity := Flight_Types.Advisory_Required;
               end if;

               if Severity /= Flight_Types.Safe then
                  return (
                     Has_Conflict        => True,
                     Left_Index          => Left_Index,
                     Right_Index         => Right_Index,
                     Horizontal_Distance => Horizontal,
                     Vertical_Distance   => Vertical,
                     Severity            => Severity,
                     Left_Action         => Recommend_For_Left (Left_Aircraft, Right_Aircraft),
                     Right_Action        => Recommend_For_Right (Left_Aircraft, Right_Aircraft),
                     Message             => Ada.Strings.Unbounded.To_Unbounded_String (
                       "Loss of separation between "
                       & Ada.Strings.Unbounded.To_String (Left_Aircraft.Call_Sign)
                       & " and "
                       & Ada.Strings.Unbounded.To_String (Right_Aircraft.Call_Sign)
                     )
                  );
               end if;
            end;
         end loop;
      end loop;

      return (others => <>);
   end Find_First_Conflict;
end Safety;
