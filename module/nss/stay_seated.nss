void main()
{
     object oChair = GetNearestObjectByTag("SS_Chair1");
     ClearAllActions(); //This is so he don't spin in his chair, following you.
     ActionSit(oChair);
}
