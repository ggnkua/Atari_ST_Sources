DEFINITION MODULE ModUtil2;

FROM SYSTEM IMPORT ADDRESS;

FROM ModBase IMPORT ModRef;

TYPE ModInfo = PROCEDURE (ModRef);

VAR CallBody, LeaveBody, DeInit: ModInfo;

END ModUtil2.
