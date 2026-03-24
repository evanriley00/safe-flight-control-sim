with Airspace;

package Scenarios is
   Default_Scenario_Path : constant String := "scenarios/default.scn";

   procedure Load_Default (Space : out Airspace.Airspace_State);
   procedure Load_From_File (
      Space : out Airspace.Airspace_State;
      Path  : String
   );
end Scenarios;
