#include "core_i_framework"
#include "util_i_data"

void main()
{
    object oNPC = OBJECT_SELF;
    int nTimerID = CreateTimer(oNPC, "falhace_timer", 1440.0, 1);
    _SetLocalInt(oNPC, "DEATH_TIMER_ID", nTimerID);
    StartTimer(nTimerID, FALSE);
}
