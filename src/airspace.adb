with Ada.Text_IO;

package body Airspace is
   procedure Initialize (Space : out Airspace_State) is
   begin
      Space.Item_Count := 0;
   end Initialize;

   procedure Add_Aircraft (
      Space : in out Airspace_State;
      Item  : Aircraft.Aircraft_State
   ) is
   begin
      if Space.Item_Count >= Max_Aircraft then
         raise Constraint_Error with "Airspace capacity exceeded";
      end if;

      Space.Item_Count := Space.Item_Count + 1;
      Space.Items (Space.Item_Count) := Item;
   end Add_Aircraft;

   procedure Step_All (
      Space   : in out Airspace_State;
      Minutes : Positive := 1
   ) is
   begin
      for Index in 1 .. Space.Item_Count loop
         Aircraft.Step (Space.Items (Index), Minutes);
      end loop;
   end Step_All;

   function Count (Space : Airspace_State) return Natural is
   begin
      return Space.Item_Count;
   end Count;

   function Get_Aircraft (
      Space : Airspace_State;
      Index : Positive
   ) return Aircraft.Aircraft_State is
   begin
      if Index > Space.Item_Count then
         raise Constraint_Error with "Aircraft index out of range";
      end if;
      return Space.Items (Index);
   end Get_Aircraft;

   procedure Update_Aircraft (
      Space : in out Airspace_State;
      Index : Positive;
      Item  : Aircraft.Aircraft_State
   ) is
   begin
      if Index > Space.Item_Count then
         raise Constraint_Error with "Aircraft index out of range";
      end if;
      Space.Items (Index) := Item;
   end Update_Aircraft;
end Airspace;
