// -----------------------------------------------------------------------------
//    File: util_i_debug.nss
//  System: Utilities (include script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This file holds utility functions for generating debug messages.
// -----------------------------------------------------------------------------

#include "util_i_color"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// VarNames
const string REPORT_COLOR = "DEBUG_COLOR";
const string REPORT_LEVEL = "DEBUG_LEVEL";
const string REPORT_LOG   = "DEBUG_LOG";

// Debug levels
const int DEBUG_LEVEL_CRITICAL = 0;
const int DEBUG_LEVEL_ERROR    = 1;
const int DEBUG_LEVEL_WARNING  = 2;
const int DEBUG_LEVEL_NOTICE   = 3;

// Debug logging
const int DEBUG_LOG_NONE = 0x0;
const int DEBUG_LOG_FILE = 0x1;
const int DEBUG_LOG_DM   = 0x2;
const int DEBUG_LOG_PC   = 0x4;
const int DEBUG_LOG_ALL  = 0xf;

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< GetDebugLevel >---
// ---< util_i_debug >---
// Returns the minimum level of debug messages that will be logged for oTarget.
// If the module is set to have more verbosity than oTarget, will return the
// module's verbosity instead.
int GetDebugLevel(object oTarget = OBJECT_SELF);

// ---< SetDebugLevel >---
// ---< util_i_debug >---
// Sets the minimum level of debug messages that will be logged for oTarget.
void SetDebugLevel(int nLevel, object oTarget = OBJECT_SELF);

// ---< GetDebugColor >---
// ---< util_i_debug >---
// Returns the string color code (in <cRGB> form) for debug messages of nLevel.
string GetDebugColor(int nLevel);

// ---< SetDebugColor >---
// ---< util_i_debug >---
// Sets the string color code (in <cRGB> form) for debug messages of nLevel. If
// sColor is blank, will use the default color codes.
void SetDebugColor(int nLevel, string sColor = "");

// ---< GetDebugLogging >---
// ---< util_i_debug >---
// Returns the enabled debug logging destinations. This is a bitmasked field
// that may contain the following:
// - DEBUG_LOG_NONE: do not log debug messages
// - DEBUG_LOG_FILE: log debug messages to the log file
// - DEBUG_LOG_DM: send debug messages to online DMs
// - DEBUG_LOG_PC: send debug messages to the first PC
// - DEBUG_LOG_ALL: sends messages to the log file, online DMs, and the first PC
// Note: only messages with a priority of GetDebugLevel() or higher will be
// logged.
int GetDebugLogging();

// ---< SetDebugLogging >---
// ---< util_i_debug >---
// Enables debug logging to nEnabled. This is a bitmasked field that may contain
// the following:
// - DEBUG_LOG_NONE: do not log debug messages
// - DEBUG_LOG_FILE: log debug messages to the log file
// - DEBUG_LOG_DM: send debug messages to online DMs
// - DEBUG_LOG_PC: send debug messages to the first PC
// - DEBUG_LOG_ALL: sends messages to the log file, online DMs, and the first PC
// Note: only messages with a priority of GetDebugLevel() or higher will be
// logged.
void SetDebugLogging(int nEnabled);

// ---< IsDebugging >---
// ---< util_i_debug >---
// Returns whether debug messages of nLevel will be logged on oTarget. Useful
// for avoiding spending cycles compiling extra debug information if it will not
// be shown.
// Parameters:
// - nLevel: The error level of the message.
//   Possible values:
//   - DEBUG_LEVEL_CRITICAL: errors severe enough to stop the script
//   - DEBUG_LEVEL_ERROR: indicates the script malfunctioned in some way
//   - DEBUG_LEVEL_WARNING: indicates that unexpected behavior may occur
//   - DEBUG_LEVEL_NOTICE: information to track the flow of the function
// - oTarget: The object to debug. If invalid, defaults to GetModule().
int IsDebugging(int nLevel, object oTarget = OBJECT_SELF);

// ---< Debug >---
// ---< util_i_debug >---
// If oTarget has a debug level of nLevel or higher, logs sMessages to all
// destinations set with SetDebugLogging(). If the module is set to log with
// more verbosity than oTarget, will log using the module's verbosity instead.
void Debug(string sMessage, int nLevel = DEBUG_LEVEL_NOTICE, object oTarget = OBJECT_SELF);

// ---< Warning >---
// ---< util_i_debug >---
// Alias for Debug() that issues a warning.
void Warning(string sMessage, object oTarget = OBJECT_SELF);

// ---< Error >---
// ---< util_i_debug >---
// Alias for Debug() that issues an error.
void Error(string sMessage, object oTarget = OBJECT_SELF);

// ---< CriticalError >---
// ---< util_i_debug >---
// Alias for Debug() tat issues a critical error.
void CriticalError(string sMessage, object oTarget = OBJECT_SELF);

void CriticalError(string sMessage, object oTarget = OBJECT_SELF);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

string GetDebugColor(int nLevel)
{
    string sColor = _GetLocalString(GetModule(), DEBUG_COLOR + IntToString(nLevel));

    if (sColor == "")
    {
        int nColor;
        switch (nLevel)
        {
            case DEBUG_LEVEL_CRITICAL: nColor = COLOR_RED;          break;
            case DEBUG_LEVEL_ERROR:    nColor = COLOR_ORANGE_DARK;  break;
            case DEBUG_LEVEL_WARNING:  nColor = COLOR_ORANGE_LIGHT; break;
            default:                   nColor = COLOR_GRAY_LIGHT;   break;
        }

        sColor = HexToColor(nColor);
        SetDebugColor(nLevel, sColor);
    }

    return sColor;
}

void SetDebugColor(int nLevel, string sColor = "")
{
    _SetLocalString(GetModule(), DEBUG_COLOR + IntToString(nLevel), sColor);
}

int GetDebugLogging()
{
    return _GetLocalInt(GetModule(), DEBUG_LOG);
}

void SetDebugLogging(int nEnabled)
{
    _SetLocalInt(GetModule(), DEBUG_LOG, nEnabled);
}

int IsDebugging(int nLevel, object oTarget = OBJECT_SELF)
{
    return (nLevel <= GetDebugLevel(oTarget));
}

void Debug(string sMessage, int nLevel = DEBUG_LEVEL_NOTICE, object oTarget = OBJECT_SELF)
{
    if (IsDebugging(nLevel, oTarget))
    {
        string sColor = GetDebugColor(nLevel);
        string sPrefix;

        switch (nLevel)
        {
            case DEBUG_LEVEL_CRITICAL: sPrefix = "[Critical Error] "; break;
            case DEBUG_LEVEL_ERROR:    sPrefix = "[Error] ";          break;
            case DEBUG_LEVEL_WARNING:  sPrefix = "[Warning] ";        break;
        }

        sMessage = sPrefix + sMessage;

        int nLogging = _GetLocalInt(GetModule(), DEBUG_LOG);

        if (nLogging & DEBUG_LOG_FILE)
            WriteTimestampedLogEntry(sMessage);

        sMessage = ColorString(sMessage, sColor);

        if (nLogging & DEBUG_LOG_DM)
            SendMessageToAllDMs(sMessage);

        if (nLogging & DEBUG_LOG_PC)
            SendMessageToPC(GetFirstPC(), sMessage);
    }
}

void Warning(string sMessage, object oTarget = OBJECT_SELF)
{
    Debug(sMessage, DEBUG_LEVEL_WARNING, oTarget);
}

void Error(string sMessage, object oTarget = OBJECT_SELF)
{
    Debug(sMessage, DEBUG_LEVEL_ERROR, oTarget);
}

void CriticalError(string sMessage, object oTarget = OBJECT_SELF)
{
    Debug(sMessage, DEBUG_LEVEL_CRITICAL, oTarget);
}

void Report(string sMessage, object oTarget = OBJECT_SELF)
{

}

void ReportToPC(string sMessage, object oTarget = OBJECT_SELF)
{

}

void ReportToDM(string sMessage, object oTarget = OBJECT_SELF)
{

}


