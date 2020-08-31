// -----------------------------------------------------------------------------
//    File: fugue_i_events.nss
//  System: Fugue Death and Resurrection (events)
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

 #include "fugue_i_main"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< fugue_OnClientEnter >---
// If the player is dead, but is not in the fugue or at his deity's ressurection 
//  location, send them to the fugue.
void fugue_OnClientEnter();

// ---< fugue_OnPlayerDeath >---
// Upon death, drop all henchmen and send PC to the fugue plane.
void fugue_OnPlayerDeath();

// ---< fugue_OnPlayerDying >---
// When a PC is dying, and already in the fugue plane, resurrect.
void fugue_OnPlayerDying();

// ---< fugue_OnPlayerExit >---
// No matter how a player exits the fugue plane, mark PC as alive.
void fugue_OnPlayerExit();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void fugue_OnClientEnter()
{
    object oPC = GetEnteringObject();
    int playerstate = _GetLocalInt(oPC, H2_PLAYER_STATE);
    string uniquePCID = _GetLocalString(oPC, H2_UNIQUE_PC_ID);
    location ressLoc = GetDatabaseLocation(uniquePCID + H2_RESS_LOCATION);
    if (GetTag(GetArea(oPC)) != H2_FUGUE_PLANE && playerstate == H2_PLAYER_STATE_DEAD && !h2_GetIsLocationValid(ressLoc))
        DelayCommand(H2_CLIENT_ENTER_JUMP_DELAY, h2_SendPlayerToFugue(oPC));
}

void fugue_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();

    if (_GetLocalInt(oPC, H2_PLAYER_STATE) != H2_PLAYER_STATE_DEAD)
        return;  //<-- Use core-framework cancellation function?

    if (GetTag(GetArea(oPC)) == H2_FUGUE_PLANE)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oPC);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oPC)), oPC);
        return;
    }
    else
    {
        h2_DropAllHenchmen(oPC);
        h2_SendPlayerToFugue(oPC);
    }
}

void fugue_OnPlayerDying()
{
    object oPC = GetLastPlayerDying();
    if (GetTag(GetArea(oPC)) == H2_FUGUE_PLANE)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oPC);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oPC)), oPC);
        return;
    }
}

void fugue_OnPlayerExit()  // TODO is this for the area exit?
{
    object oPC = GetExitingObject();
    _DeleteLocalInt(oPC, H2_LOGIN_DEATH);
    _SetLocalInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_ALIVE);
    //DelayCommand(0.0, DelayEvent(H2_EVENT_ON_PLAYER_LIVES, oPC, oPC));
    RunEvent(H2_EVENT_ON_PLAYER_LIVES, OBJECT_INVALID, oPC);
}
