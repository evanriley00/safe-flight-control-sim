with Ada.Exceptions;
with Ada.Strings.Fixed;
with Ada.Text_IO;
with Aircraft;
with Airspace;
with Controller;
with Flight_Types;
with Logger;
with Scenarios;
with Safety;

procedure Test_Runner is
   use type Flight_Types.Altitude_Feet;
   use type Flight_Types.Advisory_Action;
   use type Flight_Types.Nautical_Miles;
   use type Flight_Types.Separation_Status;

   Passed : Natural := 0;
   Failed : Natural := 0;

   function Trimmed (Value : String) return String is
   begin
      return Ada.Strings.Fixed.Trim (Value, Ada.Strings.Both);
   end Trimmed;

   procedure Check (Condition : Boolean; Message : String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Check;

   procedure Run_Test (
      Name : String;
      Test : not null access procedure
   ) is
   begin
      Test.all;
      Passed := Passed + 1;
      Ada.Text_IO.Put_Line ("PASS " & Name);
   exception
      when Error : others =>
         Failed := Failed + 1;
         Ada.Text_IO.Put_Line (
           "FAIL "
           & Name
           & " - "
           & Ada.Exceptions.Exception_Message (Error)
         );
   end Run_Test;

   procedure Test_Aircraft_Step is
      Item : Aircraft.Aircraft_State :=
        Aircraft.Create (
           Identifier => 10,
           Call_Sign  => "STEP01",
           Position   => (X => 10.0, Y => 10.0),
           Altitude   => 30_000,
           Speed      => 420,
           Heading    => 90
        );
   begin
      Aircraft.Step (Item, Minutes => 1);

      Check (abs (Float (Item.Position.X) - 17.0) < 0.05, "Expected X position near 17.0 nm");
      Check (abs (Float (Item.Position.Y) - 10.0) < 0.05, "Expected Y position near 10.0 nm");
   end Test_Aircraft_Step;

   procedure Test_Advisory_Conflict_Detection is
      Space  : Airspace.Airspace_State;
      Report : Safety.Conflict_Report;
   begin
      Airspace.Initialize (Space);

      Airspace.Add_Aircraft (
         Space,
         Aircraft.Create (
            Identifier => 1,
            Call_Sign  => "LEFT01",
            Position   => (X => 10.0, Y => 10.0),
            Altitude   => 31_000,
            Speed      => 450,
            Heading    => 0
         )
      );

      Airspace.Add_Aircraft (
         Space,
         Aircraft.Create (
            Identifier => 2,
            Call_Sign  => "RGHT01",
            Position   => (X => 14.0, Y => 10.0),
            Altitude   => 31_000,
            Speed      => 450,
            Heading    => 180
         )
      );

      Report := Safety.Find_First_Conflict (Space);

      Check (Report.Has_Conflict, "Expected advisory conflict to be detected");
      Check (Report.Severity = Flight_Types.Advisory_Required, "Expected advisory severity");
      Check (Report.Left_Action = Flight_Types.Descend_1000, "Expected left aircraft to descend");
      Check (Report.Right_Action = Flight_Types.Climb_1000, "Expected right aircraft to climb");
   end Test_Advisory_Conflict_Detection;

   procedure Test_Emergency_Conflict_Detection is
      Space  : Airspace.Airspace_State;
      Report : Safety.Conflict_Report;
   begin
      Airspace.Initialize (Space);

      Airspace.Add_Aircraft (
         Space,
         Aircraft.Create (
            Identifier => 1,
            Call_Sign  => "EMR001",
            Position   => (X => 20.0, Y => 20.0),
            Altitude   => 30_000,
            Speed      => 430,
            Heading    => 45
         )
      );

      Airspace.Add_Aircraft (
         Space,
         Aircraft.Create (
            Identifier => 2,
            Call_Sign  => "EMR002",
            Position   => (X => 22.0, Y => 20.0),
            Altitude   => 30_400,
            Speed      => 430,
            Heading    => 225
         )
      );

      Report := Safety.Find_First_Conflict (Space);

      Check (Report.Has_Conflict, "Expected emergency conflict to be detected");
      Check (Report.Severity = Flight_Types.Emergency, "Expected emergency severity");
      Check (Report.Vertical_Distance = 400, "Expected 400 ft vertical separation");
   end Test_Emergency_Conflict_Detection;

   procedure Test_Controller_Resolution is
      Space         : Airspace.Airspace_State;
      Report        : Safety.Conflict_Report;
      Left_After    : Aircraft.Aircraft_State;
      Right_After   : Aircraft.Aircraft_State;
   begin
      Logger.Set_Enabled (False);
      Airspace.Initialize (Space);

      Airspace.Add_Aircraft (
         Space,
         Aircraft.Create (
            Identifier => 1,
            Call_Sign  => "CTRL01",
            Position   => (X => 5.0, Y => 5.0),
            Altitude   => 31_000,
            Speed      => 440,
            Heading    => 0
         )
      );

      Airspace.Add_Aircraft (
         Space,
         Aircraft.Create (
            Identifier => 2,
            Call_Sign  => "CTRL02",
            Position   => (X => 8.5, Y => 5.0),
            Altitude   => 31_000,
            Speed      => 440,
            Heading    => 180
         )
      );

      Report := Safety.Find_First_Conflict (Space);
      Controller.Resolve_Conflict (Space, Report);

      Left_After := Airspace.Get_Aircraft (Space, 1);
      Right_After := Airspace.Get_Aircraft (Space, 2);

      Check (Left_After.Altitude = 30_000, "Expected left aircraft altitude to decrease by 1000 ft");
      Check (Right_After.Altitude = 32_000, "Expected right aircraft altitude to increase by 1000 ft");
      Logger.Set_Enabled (True);
   exception
      when others =>
         Logger.Set_Enabled (True);
         raise;
   end Test_Controller_Resolution;

   procedure Test_Scenario_Loading is
      Space : Airspace.Airspace_State;
      First : Aircraft.Aircraft_State;
   begin
      Scenarios.Load_From_File (Space, "scenarios/default.scn");
      Check (Airspace.Count (Space) = 3, "Expected default scenario to load three aircraft");
      First := Airspace.Get_Aircraft (Space, 1);
      Check (First.Altitude = 31_000, "Expected first scenario aircraft altitude to be 31,000 ft");
      Check (Float (First.Position.X) = 10.0, "Expected first scenario aircraft X position to be 10.0 nm");
   end Test_Scenario_Loading;

begin
   Ada.Text_IO.Put_Line ("Running Safe Flight Control Simulation tests");

   Run_Test ("Aircraft movement", Test_Aircraft_Step'Access);
   Run_Test ("Scenario loading", Test_Scenario_Loading'Access);
   Run_Test ("Advisory conflict detection", Test_Advisory_Conflict_Detection'Access);
   Run_Test ("Emergency conflict detection", Test_Emergency_Conflict_Detection'Access);
   Run_Test ("Controller resolution", Test_Controller_Resolution'Access);

   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line (
     "Result: "
     & Trimmed (Natural'Image (Passed))
     & " passed, "
     & Trimmed (Natural'Image (Failed))
     & " failed"
   );

   if Failed > 0 then
      raise Program_Error with "One or more tests failed";
   end if;
end Test_Runner;
