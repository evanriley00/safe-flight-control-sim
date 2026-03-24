with Airspace;
with Safety;

package Controller is
   procedure Resolve_Conflict (
      Space  : in out Airspace.Airspace_State;
      Report : Safety.Conflict_Report
   );
end Controller;
