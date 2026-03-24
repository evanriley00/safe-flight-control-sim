with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Aircraft;
with Airspace;
with Controller;
with Flight_Types;
with Logger;
with Scenarios;
with Safety;

procedure Main is
   use Ada.Strings.Unbounded;

   Space         : Airspace.Airspace_State;
   Steps         : Positive := 8;
   Scenario_Path : Unbounded_String :=
     To_Unbounded_String (Scenarios.Default_Scenario_Path);

   function Trimmed (Value : String) return String is
   begin
      return Ada.Strings.Fixed.Trim (Value, Ada.Strings.Both);
   end Trimmed;

   function Is_Positive_Value (Value : String) return Boolean is
   begin
      declare
         Parsed : constant Positive := Positive'Value (Value);
      begin
         return Parsed >= Positive'First;
      end;
   exception
      when others =>
         return False;
   end Is_Positive_Value;

   procedure Print_Usage is
   begin
      Ada.Text_IO.Put_Line ("Usage: main.exe [steps] [scenario_path]");
      Ada.Text_IO.Put_Line ("   or: main.exe [scenario_path]");
      Ada.Text_IO.Put_Line ("Example: main.exe 8 scenarios/default.scn");
   end Print_Usage;

   procedure Load_Airspace is
   begin
      Scenarios.Load_From_File (Space, To_String (Scenario_Path));
   end Load_Airspace;

   procedure Print_State (Current_Step : Positive) is
   begin
      Logger.Section ("Simulation Step" & Trimmed (Positive'Image (Current_Step)));
      for Index in 1 .. Airspace.Count (Space) loop
         Logger.Log (Aircraft.Summary (Airspace.Get_Aircraft (Space, Index)));
      end loop;
   end Print_State;

begin
   if Ada.Command_Line.Argument_Count >= 1 then
      if Is_Positive_Value (Ada.Command_Line.Argument (1)) then
         Steps := Positive'Value (Ada.Command_Line.Argument (1));

         if Ada.Command_Line.Argument_Count >= 2 then
            Scenario_Path := To_Unbounded_String (Ada.Command_Line.Argument (2));
         end if;
      else
         Scenario_Path := To_Unbounded_String (Ada.Command_Line.Argument (1));
      end if;
   end if;

   Load_Airspace;
   Logger.Reset;
   Logger.Set_Minute (0);
   Logger.Section ("Safe Flight Control Simulation");
   Logger.Log (
     "Starting deterministic scenario with "
     & Trimmed (Positive'Image (Steps))
     & " steps from "
     & To_String (Scenario_Path)
     & "."
   );

   for Step_Index in 1 .. Steps loop
      declare
         Report : Safety.Conflict_Report;
      begin
         Logger.Set_Minute (Step_Index - 1);
         Print_State (Step_Index);
         Report := Safety.Find_First_Conflict (Space);
         if Report.Has_Conflict then
            Controller.Resolve_Conflict (Space, Report);
         else
            Logger.Log ("No conflicts detected.");
         end if;

         Airspace.Step_All (Space, Minutes => 1);
      end;
   end loop;

   Logger.Set_Minute (Steps);
   Logger.Section ("Simulation Complete");
   for Index in 1 .. Airspace.Count (Space) loop
      Logger.Log (Aircraft.Summary (Airspace.Get_Aircraft (Space, Index)));
   end loop;
exception
   when Constraint_Error =>
      Print_Usage;
      Ada.Text_IO.Put_Line ("Error: invalid arguments or scenario data.");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   when Error : others =>
      Print_Usage;
      Ada.Text_IO.Put_Line ("Error: " & Ada.Exceptions.Exception_Message (Error));
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Main;
