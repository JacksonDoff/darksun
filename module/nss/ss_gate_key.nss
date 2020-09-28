/*
 *  Script generated by LS Script Generator, v.TK.0
 *
 *  For download info, please visit:
 *  http://nwvault.ign.com/View.php?view=Other.Detail&id=1502
 */
// Put this under "Actions Taken" in the conversation editor.


void main()
{
    // Get the PC who is in this conversation.
    object oPC = GetPCSpeaker();

    // If the PC does not have the item "SilverSpringKey".
    if ( GetItemPossessedBy(oPC, "SilverSpringKey") == OBJECT_INVALID )
    {
        // If the PC has at least 1 gold.
        if ( GetGold(oPC) >= 1 )
        {
            // Take 1 gold from the PC.
            TakeGoldFromCreature(1, oPC, TRUE);

            // Give "silverspringkey" to the PC.
            CreateItemOnObject("silverspringkey", oPC);
        }
    }
}