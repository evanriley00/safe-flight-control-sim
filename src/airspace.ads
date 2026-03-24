with Aircraft;

package Airspace is
   Max_Aircraft : constant := 12;

   type Airspace_State is private;

   procedure Initialize (Space : out Airspace_State);
   procedure Add_Aircraft (
      Space : in out Airspace_State;
      Item  : Aircraft.Aircraft_State
   );
   procedure Step_All (
      Space   : in out Airspace_State;
      Minutes : Positive := 1
   );
   function Count (Space : Airspace_State) return Natural;
   function Get_Aircraft (
      Space : Airspace_State;
      Index : Positive
   ) return Aircraft.Aircraft_State;
   procedure Update_Aircraft (
      Space : in out Airspace_State;
      Index : Positive;
      Item  : Aircraft.Aircraft_State
   );

private
   subtype Slot_Range is Positive range 1 .. Max_Aircraft;
   type Aircraft_Array is array (Slot_Range) of Aircraft.Aircraft_State;

   type Airspace_State is record
      Items       : Aircraft_Array;
      Item_Count  : Natural := 0;
   end record;
end Airspace;
