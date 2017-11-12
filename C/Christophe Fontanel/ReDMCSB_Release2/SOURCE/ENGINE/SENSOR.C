#include "DEFS.H"

/*_Global variables_*/
int G403_i_SensorRotationEffect = CM1_EFFECT_NONE;
int G404_i_SensorRotationEffectMapX;
int G405_i_SensorRotationEffectMapY;
int G406_i_SensorRotationEffectCell;


overlay "timeline"

VOID F268_fzzz_SENSOR_AddEvent(P562_c_Type, P563_c_MapX, P564_c_MapY, P565_c_Cell, P566_c_Effect, P567_l_Time)
char P562_c_Type;
char P563_c_MapX;
char P564_c_MapY;
char P565_c_Cell;
char P566_c_Effect;
long P567_l_Time;
{
        EVENT L0729_s_Event;


        M33_SET_MAP_AND_TIME(L0729_s_Event.Map_Time, G272_i_CurrentMapIndex, P567_l_Time);
        L0729_s_Event.A.A.Type = P562_c_Type;
        L0729_s_Event.A.A.Priority = 0;
        L0729_s_Event.B.Location.MapX = P563_c_MapX;
        L0729_s_Event.B.Location.MapY = P564_c_MapY;
        L0729_s_Event.C.A.Cell = P565_c_Cell;
        L0729_s_Event.C.A.Effect = P566_c_Effect;
        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L0729_s_Event);
}

VOID F269_xxxx_SENSOR_AddSkillExperience(P568_i_SkillIndex, P569_i_Experience, P570_B_LeaderOnly)
int P568_i_SkillIndex;
int P569_i_Experience;
BOOLEAN P570_B_LeaderOnly;
{
        register int L0730_i_ChampionIndex;
        register CHAMPION* L0731_ps_Champion;


        if (P570_B_LeaderOnly) {
                if (G411_i_LeaderIndex != CM1_CHAMPION_NONE) {
                        F304_apzz_CHAMPION_AddSkillExperience(G411_i_LeaderIndex, P568_i_SkillIndex, P569_i_Experience);
                }
                return;
        }
        P569_i_Experience /= G305_ui_PartyChampionCount;
        for(L0730_i_ChampionIndex = C00_CHAMPION_FIRST, L0731_ps_Champion = G407_s_Party.Champions; L0730_i_ChampionIndex < G305_ui_PartyChampionCount; L0730_i_ChampionIndex++, L0731_ps_Champion++) {
                if (L0731_ps_Champion->CurrentHealth) {
                        F304_apzz_CHAMPION_AddSkillExperience(L0730_i_ChampionIndex, P568_i_SkillIndex, P569_i_Experience);
                }
        }
}

/* While processing a list of sensors, this function may be called several times. The rotation effect of the last processed sensor is stored in global variables. When processing of the list of sensors is complete, a call to F271_xxxx_SENSOR_ProcessRotationEffect is made to perform the actual effect (either nothing or a rotation of the list of sensors). This ensures that only one rotation can occur when processing sensors on a given square */
VOID F270_xxxx_SENSOR_TriggerLocalEffect(P571_i_SensorLocalEffect, P572_i_SensorLocalEffectX, P573_i_SensorLocalEffectY, P574_i_SensorLocalEffectCell)
int P571_i_SensorLocalEffect;
int P572_i_SensorLocalEffectX;
int P573_i_SensorLocalEffectY;
int P574_i_SensorLocalEffectCell;
{
        if (P571_i_SensorLocalEffect == C10_EFFECT_ADD_EXPERIENCE) {
                F269_xxxx_SENSOR_AddSkillExperience(C08_SKILL_STEAL, 300, P574_i_SensorLocalEffectCell != CM1_CELL_ANY);
        } else {
                G403_i_SensorRotationEffect = P571_i_SensorLocalEffect;
                G404_i_SensorRotationEffectMapX = P572_i_SensorLocalEffectX;
                G405_i_SensorRotationEffectMapY = P573_i_SensorLocalEffectY;
                G406_i_SensorRotationEffectCell = P574_i_SensorLocalEffectCell;
        }
}

VOID F271_xxxx_SENSOR_ProcessRotationEffect()
{
        register THING L0732_T_FirstSensorThing;
        register THING L0733_T_LastSensorThing;
        register SENSOR* L0734_ps_FirstSensor;
        register SENSOR* L0735_ps_LastSensor;


        if (G403_i_SensorRotationEffect == CM1_EFFECT_NONE) {
                return;
        }
        switch (G403_i_SensorRotationEffect) {
                case C01_EFFECT_CLEAR:
                case C02_EFFECT_TOGGLE:
                        for(L0732_T_FirstSensorThing = F161_szzz_DUNGEON_GetSquareFirstThing(G404_i_SensorRotationEffectMapX, G405_i_SensorRotationEffectMapY); (M12_TYPE(L0732_T_FirstSensorThing) != C03_THING_TYPE_SENSOR) || ((G406_i_SensorRotationEffectCell != CM1_CELL_ANY) && (M11_CELL(L0732_T_FirstSensorThing) != G406_i_SensorRotationEffectCell)); L0732_T_FirstSensorThing = F159_rzzz_DUNGEON_GetNextThing(L0732_T_FirstSensorThing));
                        L0734_ps_FirstSensor = (SENSOR*)F156_afzz_DUNGEON_GetThingData(L0732_T_FirstSensorThing);
                        for(L0733_T_LastSensorThing = L0734_ps_FirstSensor->Next; (L0733_T_LastSensorThing != C0xFFFE_THING_ENDOFLIST) && ((M12_TYPE(L0733_T_LastSensorThing) != C03_THING_TYPE_SENSOR) || ((G406_i_SensorRotationEffectCell != CM1_CELL_ANY) && (M11_CELL(L0733_T_LastSensorThing) != G406_i_SensorRotationEffectCell))) ; L0733_T_LastSensorThing = F159_rzzz_DUNGEON_GetNextThing(L0733_T_LastSensorThing));
                        if (L0733_T_LastSensorThing == C0xFFFE_THING_ENDOFLIST) {
                                break;
                        }
                        F164_dzzz_DUNGEON_UnlinkThingFromList(L0732_T_FirstSensorThing, 0, G404_i_SensorRotationEffectMapX, G405_i_SensorRotationEffectMapY);
                        L0735_ps_LastSensor = (SENSOR*)F156_afzz_DUNGEON_GetThingData(L0733_T_LastSensorThing);
                        for(L0733_T_LastSensorThing = F159_rzzz_DUNGEON_GetNextThing(L0733_T_LastSensorThing); ((L0733_T_LastSensorThing != C0xFFFE_THING_ENDOFLIST) && (M12_TYPE(L0733_T_LastSensorThing) == C03_THING_TYPE_SENSOR)); L0733_T_LastSensorThing = F159_rzzz_DUNGEON_GetNextThing(L0733_T_LastSensorThing)) {
                                if ((G406_i_SensorRotationEffectCell == CM1_CELL_ANY) || (M11_CELL(L0733_T_LastSensorThing) == G406_i_SensorRotationEffectCell)) {
                                        L0735_ps_LastSensor = (SENSOR*)F156_afzz_DUNGEON_GetThingData(L0733_T_LastSensorThing);
                                }
                        }
                        L0734_ps_FirstSensor->Next = L0735_ps_LastSensor->Next;
                        L0735_ps_LastSensor->Next = L0732_T_FirstSensorThing;
        }
        G403_i_SensorRotationEffect = CM1_EFFECT_NONE;
}

VOID F272_xxxx_SENSOR_TriggerEffect(P575_ps_Sensor, P576_i_Effect, P577_i_MapX, P578_i_MapY, P579_ui_Cell)
register SENSOR* P575_ps_Sensor;
int P576_i_Effect;
int P577_i_MapX;
int P578_i_MapY;
unsigned int P579_ui_Cell;
{
        register int L0736_i_TargetMapX;
        register int L0737_i_TargetMapY;
        register long L0738_l_Time;
        register unsigned int L0739_ui_SquareType;
        unsigned int L0740_ui_TargetCell;


        if (P575_ps_Sensor->A.OnceOnly) {
                M44_SET_TYPE_DISABLED(P575_ps_Sensor);
        }
        L0738_l_Time = G313_ul_GameTime + P575_ps_Sensor->A.Value;
        if (P575_ps_Sensor->A.LocalEffect) {
                F270_xxxx_SENSOR_TriggerLocalEffect(M49_LOCAL_EFFECT(P575_ps_Sensor), P577_i_MapX, P578_i_MapY, P579_ui_Cell);
        } else {
                L0736_i_TargetMapX = P575_ps_Sensor->B.A.TargetMapX;
                L0737_i_TargetMapY = P575_ps_Sensor->B.A.TargetMapY;
                L0739_ui_SquareType = M34_SQUARE_TYPE(G271_ppuc_CurrentMapData[L0736_i_TargetMapX][L0737_i_TargetMapY]);
                if (L0739_ui_SquareType == C00_ELEMENT_WALL) {
                        L0740_ui_TargetCell = P575_ps_Sensor->B.A.TargetCell;
                } else {
                        L0740_ui_TargetCell = C00_CELL_NORTHWEST;
                }
                F268_fzzz_SENSOR_AddEvent(G059_auc_Graphic562_SquareTypeToEventType[L0739_ui_SquareType], L0736_i_TargetMapX, L0737_i_TargetMapY, L0740_ui_TargetCell, P576_i_Effect, L0738_l_Time);
        }
}

THING F273_xxxx_SENSOR_GetObjectOfTypeInCell(P580_i_MapX, P581_i_MapY, P582_i_Cell, P583_i_ObjectType)
int P580_i_MapX;
int P581_i_MapY;
register int P582_i_Cell;
register int P583_i_ObjectType;
{
        register THING L0741_T_Thing;


        for(L0741_T_Thing = F162_afzz_DUNGEON_GetSquareFirstObject(P580_i_MapX, P581_i_MapY); L0741_T_Thing != C0xFFFE_THING_ENDOFLIST; L0741_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0741_T_Thing)) {
                if (F032_aaaY_OBJECT_GetType(L0741_T_Thing) == P583_i_ObjectType) {
                        if ((P582_i_Cell == CM1_CELL_ANY) || (M11_CELL(L0741_T_Thing) == P582_i_Cell)) {
                                return L0741_T_Thing;
                        }
                }
        }
        return C0xFFFF_THING_NONE;
}

BOOLEAN F274_xxxx_SENSOR_IsObjectInPartyPossession(P584_i_ObjectType)
register int P584_i_ObjectType;
{
        register int L0742_i_ChampionIndex;
        register unsigned int L0743_ui_SlotIndex;
        register THING L0744_T_Thing;
        register CHAMPION* L0745_ps_Champion;
        register THING* L0746_pT_Thing;
        int L0747_i_ObjectType;
        BOOLEAN L0748_B_LeaderHandObjectProcessed;
        CONTAINER* L0749_ps_Container;


        L0748_B_LeaderHandObjectProcessed = FALSE;
        for(L0742_i_ChampionIndex = C00_CHAMPION_FIRST, L0745_ps_Champion = G407_s_Party.Champions; L0742_i_ChampionIndex < G305_ui_PartyChampionCount; L0742_i_ChampionIndex++, L0745_ps_Champion++) {
                if (L0745_ps_Champion->CurrentHealth) {
                        L0746_pT_Thing = L0745_ps_Champion->Slots;
                        for(L0743_ui_SlotIndex = C00_SLOT_READY_HAND; (L0743_ui_SlotIndex < C30_SLOT_CHEST_1) && !L0748_B_LeaderHandObjectProcessed; L0743_ui_SlotIndex++) {
                                L0744_T_Thing = *L0746_pT_Thing++;
                                T274_003:
                                if ((L0747_i_ObjectType = F032_aaaY_OBJECT_GetType(L0744_T_Thing)) == P584_i_ObjectType) {
                                        return TRUE;
                                }
                                if (L0747_i_ObjectType == C144_ICON_CONTAINER_CHEST_CLOSED) {
                                        L0749_ps_Container = (CONTAINER*)F156_afzz_DUNGEON_GetThingData(L0744_T_Thing);
                                        for(L0744_T_Thing = L0749_ps_Container->Slot; L0744_T_Thing != C0xFFFE_THING_ENDOFLIST; L0744_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0744_T_Thing)) {
                                                if (F032_aaaY_OBJECT_GetType(L0744_T_Thing) == P584_i_ObjectType) {
                                                        return TRUE;
                                                }
                                        }
                                }
                        }
                }
        }
        if (!L0748_B_LeaderHandObjectProcessed) {
                L0748_B_LeaderHandObjectProcessed = TRUE;
                L0744_T_Thing = G414_T_LeaderHandObject;
                goto T274_003;
        }
        return FALSE;
}

BOOLEAN F275_aszz_SENSOR_IsTriggeredByClickOnWall(P585_i_MapX, P586_i_MapY, P587_ui_Cell)
int P585_i_MapX;
int P586_i_MapY;
unsigned int P587_ui_Cell;
{
        register THING L0750_T_ThingBeingProcessed;
        register unsigned int L0751_ui_ThingType;
        register unsigned int L0752_ui_Cell;
        register BOOLEAN L0753_B_DoNotTriggerSensor;
        register GENERIC* L0754_ps_Generic;
        register SENSOR* L0755_ps_Sensor;
        int L0756_i_SensorEffect;
        int L0757_i_SensorType;
        int L0758_i_SensorData;
        BOOLEAN L0759_B_AtLeastOneSensorWasTriggered;
        int L0760_ai_SensorCountToProcessPerCell[4];
        THING L0761_T_LeaderHandObject;
        THING L0762_T_ThingOnSquare;
        THING L0763_T_LastProcessedThing;
        THING L0764_T_SquareFirstThing;
        SENSOR* L0765_ps_Sensor;


        L0759_B_AtLeastOneSensorWasTriggered = FALSE;
        L0761_T_LeaderHandObject = G414_T_LeaderHandObject;
        for(L0752_ui_Cell = C00_CELL_NORTHWEST; L0752_ui_Cell < C03_CELL_SOUTHWEST + 1; L0752_ui_Cell++) {
                L0760_ai_SensorCountToProcessPerCell[L0752_ui_Cell] = 0;
        }
        for(L0764_T_SquareFirstThing = L0750_T_ThingBeingProcessed = F161_szzz_DUNGEON_GetSquareFirstThing(P585_i_MapX, P586_i_MapY); L0750_T_ThingBeingProcessed != C0xFFFE_THING_ENDOFLIST; L0750_T_ThingBeingProcessed = F159_rzzz_DUNGEON_GetNextThing(L0750_T_ThingBeingProcessed)) {
                if ((L0751_ui_ThingType = M12_TYPE(L0750_T_ThingBeingProcessed)) == C03_THING_TYPE_SENSOR) {
                        L0760_ai_SensorCountToProcessPerCell[M11_CELL(L0750_T_ThingBeingProcessed)]++;
                } else {
                        if (L0751_ui_ThingType >= C04_THING_TYPE_GROUP) {
                                break;
                        }
                }
        }
        L0763_T_LastProcessedThing = L0750_T_ThingBeingProcessed = L0764_T_SquareFirstThing;
        while (L0750_T_ThingBeingProcessed != C0xFFFE_THING_ENDOFLIST) {
                if ((L0751_ui_ThingType = M12_TYPE(L0750_T_ThingBeingProcessed)) == C03_THING_TYPE_SENSOR) {
                        L0760_ai_SensorCountToProcessPerCell[L0752_ui_Cell = M11_CELL(L0750_T_ThingBeingProcessed)]--;
                        L0755_ps_Sensor = (SENSOR*)F156_afzz_DUNGEON_GetThingData(L0750_T_ThingBeingProcessed);
                        if ((L0757_i_SensorType = M39_TYPE(L0755_ps_Sensor)) == C000_SENSOR_DISABLED) {
                                goto T275_058_ProceedToNextThing;
                        }
                        if ((G411_i_LeaderIndex == CM1_CHAMPION_NONE) && (L0757_i_SensorType != C127_SENSOR_WALL_CHAMPION_PORTRAIT)) {
                                goto T275_058_ProceedToNextThing;
                        }
                        if (L0752_ui_Cell != P587_ui_Cell) {
                                goto T275_058_ProceedToNextThing;
                        }
                        L0758_i_SensorData = M40_DATA(L0755_ps_Sensor);
                        L0756_i_SensorEffect = L0755_ps_Sensor->A.Effect;
                        switch (L0757_i_SensorType) {
                                case C001_SENSOR_WALL_ORNAMENT_CLICK:
                                        L0753_B_DoNotTriggerSensor = FALSE;
                                        if (L0755_ps_Sensor->A.Effect == C03_EFFECT_HOLD) {
                                                goto T275_058_ProceedToNextThing;
                                        }
                                        break;
                                case C002_SENSOR_WALL_ORNAMENT_CLICK_WITH_ANY_OBJECT:
                                        L0753_B_DoNotTriggerSensor = (G415_B_LeaderEmptyHanded != L0755_ps_Sensor->A.RevertEffect);
                                        break;
                                case C017_SENSOR_WALL_ORNAMENT_CLICK_WITH_SPECIFIC_OBJECT_REMOVED_REMOVE_SENSOR:
                                case C011_SENSOR_WALL_ORNAMENT_CLICK_WITH_SPECIFIC_OBJECT_REMOVED_ROTATE_SENSORS:
                                        if (L0760_ai_SensorCountToProcessPerCell[L0752_ui_Cell]) { /* If the sensor is not the last one of its type on the cell */
                                                goto T275_058_ProceedToNextThing;
                                        }
                                case C003_SENSOR_WALL_ORNAMENT_CLICK_WITH_SPECIFIC_OBJECT:
                                case C004_SENSOR_WALL_ORNAMENT_CLICK_WITH_SPECIFIC_OBJECT_REMOVED:
                                        L0753_B_DoNotTriggerSensor = ((L0758_i_SensorData == F032_aaaY_OBJECT_GetType(L0761_T_LeaderHandObject)) == L0755_ps_Sensor->A.RevertEffect);
                                        if (!L0753_B_DoNotTriggerSensor && (L0757_i_SensorType == C017_SENSOR_WALL_ORNAMENT_CLICK_WITH_SPECIFIC_OBJECT_REMOVED_REMOVE_SENSOR)) {
                                                if (L0763_T_LastProcessedThing == L0750_T_ThingBeingProcessed) { /* If the sensor is the only one of its type on the cell */
                                                        break;
                                                }
                                                L0765_ps_Sensor = (SENSOR*)F156_afzz_DUNGEON_GetThingData(L0763_T_LastProcessedThing);
                                                L0765_ps_Sensor->Next = L0755_ps_Sensor->Next;
                                                L0755_ps_Sensor->Next = C0xFFFF_THING_NONE;
                                                L0750_T_ThingBeingProcessed = L0763_T_LastProcessedThing;
                                        }
                                        if (!L0753_B_DoNotTriggerSensor && (L0757_i_SensorType == C011_SENSOR_WALL_ORNAMENT_CLICK_WITH_SPECIFIC_OBJECT_REMOVED_ROTATE_SENSORS)) {
                                                F270_xxxx_SENSOR_TriggerLocalEffect(C02_EFFECT_TOGGLE, P585_i_MapX, P586_i_MapY, L0752_ui_Cell); /* This will cause a rotation of the sensors at the specified cell on the specified square after all sensors have been processed */
                                        }
                                        break;
                                case C012_SENSOR_WALL_OBJECT_GENERATOR_ROTATE_SENSORS:
                                        if (L0760_ai_SensorCountToProcessPerCell[L0752_ui_Cell]) { /* If the sensor is not the last one of its type on the cell */
                                                goto T275_058_ProceedToNextThing;
                                        }
                                        L0753_B_DoNotTriggerSensor = !G415_B_LeaderEmptyHanded;
                                        if (!L0753_B_DoNotTriggerSensor) {
                                                F270_xxxx_SENSOR_TriggerLocalEffect(C02_EFFECT_TOGGLE, P585_i_MapX, P586_i_MapY, L0752_ui_Cell); /* This will cause a rotation of the sensors at the specified cell on the specified square after all sensors have been processed */
                                        }
                                        break;
                                case C013_SENSOR_WALL_SINGLE_OBJECT_STORAGE_ROTATE_SENSORS:
                                        if (G415_B_LeaderEmptyHanded) {
                                                if ((L0761_T_LeaderHandObject = F273_xxxx_SENSOR_GetObjectOfTypeInCell(P585_i_MapX, P586_i_MapY, L0752_ui_Cell, L0758_i_SensorData)) == C0xFFFF_THING_NONE) {
                                                        goto T275_058_ProceedToNextThing;
                                                }
                                                F164_dzzz_DUNGEON_UnlinkThingFromList(L0761_T_LeaderHandObject, 0, P585_i_MapX, P586_i_MapY);
                                                F297_atzz_CHAMPION_PutObjectInLeaderHand(L0761_T_LeaderHandObject, TRUE);
                                        } else {
                                                if ((F032_aaaY_OBJECT_GetType(L0761_T_LeaderHandObject) != L0758_i_SensorData) || (F273_xxxx_SENSOR_GetObjectOfTypeInCell(P585_i_MapX, P586_i_MapY, L0752_ui_Cell, L0758_i_SensorData) != C0xFFFF_THING_NONE)) {
                                                        goto T275_058_ProceedToNextThing;
                                                }
                                                F298_aqzz_CHAMPION_GetObjectRemovedFromLeaderHand();
                                                F163_amzz_DUNGEON_LinkThingToList(M15_THING_WITH_NEW_CELL(L0761_T_LeaderHandObject, L0752_ui_Cell), 0, P585_i_MapX, P586_i_MapY);
                                                L0761_T_LeaderHandObject = C0xFFFF_THING_NONE;
                                        }
                                        F270_xxxx_SENSOR_TriggerLocalEffect(C02_EFFECT_TOGGLE, P585_i_MapX, P586_i_MapY, L0752_ui_Cell); /* This will cause a rotation of the sensors at the specified cell on the specified square after all sensors have been processed */
                                        if ((L0756_i_SensorEffect == C03_EFFECT_HOLD) && !G415_B_LeaderEmptyHanded) {
                                                L0753_B_DoNotTriggerSensor = TRUE;
                                        } else {
                                                L0753_B_DoNotTriggerSensor = FALSE;
                                        }
                                        break;
                                case C016_SENSOR_WALL_OBJECT_EXCHANGER:
                                        if (L0760_ai_SensorCountToProcessPerCell[L0752_ui_Cell]) { /* If the sensor is not the last one of its type on the cell */
                                                goto T275_058_ProceedToNextThing;
                                        }
                                        L0762_T_ThingOnSquare = F162_afzz_DUNGEON_GetSquareFirstObject(P585_i_MapX, P586_i_MapY);
                                        if ((F032_aaaY_OBJECT_GetType(L0761_T_LeaderHandObject) != L0758_i_SensorData) || (L0762_T_ThingOnSquare == C0xFFFF_THING_NONE)) {
                                                goto T275_058_ProceedToNextThing;
                                        }
                                        F164_dzzz_DUNGEON_UnlinkThingFromList(L0762_T_ThingOnSquare, 0, P585_i_MapX, P586_i_MapY);
                                        F298_aqzz_CHAMPION_GetObjectRemovedFromLeaderHand();
                                        F163_amzz_DUNGEON_LinkThingToList(M15_THING_WITH_NEW_CELL(L0761_T_LeaderHandObject, L0752_ui_Cell), 0, P585_i_MapX, P586_i_MapY);
                                        F297_atzz_CHAMPION_PutObjectInLeaderHand(L0762_T_ThingOnSquare, TRUE);
                                        L0753_B_DoNotTriggerSensor = FALSE;
                                        break;
                                case C127_SENSOR_WALL_CHAMPION_PORTRAIT:
                                        F280_agzz_CHAMPION_AddCandidateChampionToParty(L0758_i_SensorData);
                                        goto T275_058_ProceedToNextThing;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_14_FIX Useless code removed */
                                case C005_SENSOR_WALL_AND_OR_GATE: /* BUG0_00 Useless code */
                                case C006_SENSOR_WALL_COUNTDOWN:
                                case C007_SENSOR_WALL_SINGLE_PROJECTILE_LAUNCHER_NEW_OBJECT:
                                case C008_SENSOR_WALL_SINGLE_PROJECTILE_LAUNCHER_EXPLOSION:
                                case C009_SENSOR_WALL_DOUBLE_PROJECTILE_LAUNCHER_NEW_OBJECT:
                                case C010_SENSOR_WALL_DOUBLE_PROJECTILE_LAUNCHER_EXPLOSION:
                                case C014_SENSOR_WALL_SINGLE_PROJECTILE_LAUNCHER_SQUARE_OBJECT:
                                case C015_SENSOR_WALL_DOUBLE_PROJECTILE_LAUNCHER_SQUARE_OBJECT:
                                        goto T275_058_ProceedToNextThing;
#endif
                                default:
                                        goto T275_058_ProceedToNextThing;
                        }
                        if (L0756_i_SensorEffect == C03_EFFECT_HOLD) {
                                L0756_i_SensorEffect = L0753_B_DoNotTriggerSensor ? C01_EFFECT_CLEAR : C00_EFFECT_SET;
                                L0753_B_DoNotTriggerSensor = FALSE;
                        }
                        if (!L0753_B_DoNotTriggerSensor) {
                                L0759_B_AtLeastOneSensorWasTriggered = TRUE;
                                if (L0755_ps_Sensor->A.Audible) {
                                        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C01_SOUND_SWITCH, G306_i_PartyMapX, G307_i_PartyMapY, C01_MODE_PLAY_IF_PRIORITIZED);
                                }
                                if (!G415_B_LeaderEmptyHanded && ((L0757_i_SensorType == C004_SENSOR_WALL_ORNAMENT_CLICK_WITH_SPECIFIC_OBJECT_REMOVED) || (L0757_i_SensorType == C011_SENSOR_WALL_ORNAMENT_CLICK_WITH_SPECIFIC_OBJECT_REMOVED_ROTATE_SENSORS) || (L0757_i_SensorType == C017_SENSOR_WALL_ORNAMENT_CLICK_WITH_SPECIFIC_OBJECT_REMOVED_REMOVE_SENSOR))) {
                                        L0754_ps_Generic = (GENERIC*)F156_afzz_DUNGEON_GetThingData(L0761_T_LeaderHandObject);
                                        L0754_ps_Generic->Next = C0xFFFF_THING_NONE;
                                        F298_aqzz_CHAMPION_GetObjectRemovedFromLeaderHand();
                                        L0761_T_LeaderHandObject = C0xFFFF_THING_NONE;
                                } else {
                                        if (G415_B_LeaderEmptyHanded &&
                                           (L0757_i_SensorType == C012_SENSOR_WALL_OBJECT_GENERATOR_ROTATE_SENSORS) &&
                                           ((L0761_T_LeaderHandObject = F167_aozz_DUNGEON_GetObjectForProjectileLauncherOrObjectGenerator(L0758_i_SensorData)) != C0xFFFF_THING_NONE)) {
                                                F297_atzz_CHAMPION_PutObjectInLeaderHand(L0761_T_LeaderHandObject, TRUE);
                                        }
                                }
                                F272_xxxx_SENSOR_TriggerEffect(L0755_ps_Sensor, L0756_i_SensorEffect, P585_i_MapX, P586_i_MapY, L0752_ui_Cell);
                        }
                        goto T275_058_ProceedToNextThing;
                }
                if (L0751_ui_ThingType >= C04_THING_TYPE_GROUP) {
                        break;
                }
                T275_058_ProceedToNextThing:
                L0763_T_LastProcessedThing = L0750_T_ThingBeingProcessed;
                L0750_T_ThingBeingProcessed = F159_rzzz_DUNGEON_GetNextThing(L0750_T_ThingBeingProcessed);
        }
        F271_xxxx_SENSOR_ProcessRotationEffect();
        return L0759_B_AtLeastOneSensorWasTriggered;
}

VOID F276_qzzz_SENSOR_ProcessThingAdditionOrRemoval(P588_ui_MapX, P589_ui_MapY, P590_T_Thing, P591_B_PartySquare, P592_B_AddThing)
unsigned int P588_ui_MapX;
unsigned int P589_ui_MapY;
THING P590_T_Thing;
register BOOLEAN P591_B_PartySquare;
BOOLEAN P592_B_AddThing;
{
        register THING L0766_T_Thing;
        register int L0767_i_ThingType;
        register BOOLEAN L0768_B_TriggerSensor;
        register SENSOR* L0769_ps_Sensor;
        unsigned int L0770_ui_SensorTriggeredCell;
        unsigned int L0771_ui_ThingType;
        BOOLEAN L0772_B_SquareContainsObject;
        BOOLEAN L0773_B_SquareContainsGroup;
        int L0774_i_ObjectType;
        BOOLEAN L0775_B_SquareContainsThingOfSameType;
        BOOLEAN L0776_B_SquareContainsThingOfDifferentType;
        unsigned int L0777_ui_Square;
        int L0778_i_Effect;
        int L0779_i_SensorData;


        if (P590_T_Thing != C0xFFFF_THING_PARTY) {
                L0767_i_ThingType = M12_TYPE(P590_T_Thing);
                L0774_i_ObjectType = F032_aaaY_OBJECT_GetType(P590_T_Thing);
        } else {
                L0767_i_ThingType = CM1_THING_TYPE_PARTY;
                L0774_i_ObjectType = CM1_ICON_NONE;
        }
        if ((!P592_B_AddThing) && (L0767_i_ThingType != CM1_THING_TYPE_PARTY)) {
                F164_dzzz_DUNGEON_UnlinkThingFromList(P590_T_Thing, 0, P588_ui_MapX, P589_ui_MapY);
        }
        if (M34_SQUARE_TYPE(L0777_ui_Square = G271_ppuc_CurrentMapData[P588_ui_MapX][P589_ui_MapY]) == C00_ELEMENT_WALL) {
                L0770_ui_SensorTriggeredCell = M11_CELL(P590_T_Thing);
        } else {
                L0770_ui_SensorTriggeredCell = CM1_CELL_ANY;
        }
        L0772_B_SquareContainsObject = L0773_B_SquareContainsGroup = L0775_B_SquareContainsThingOfSameType = L0776_B_SquareContainsThingOfDifferentType = FALSE;
        L0766_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(P588_ui_MapX, P589_ui_MapY);
        if (L0770_ui_SensorTriggeredCell == CM1_CELL_ANY) {
                while (L0766_T_Thing != C0xFFFE_THING_ENDOFLIST) {
                        if ((L0771_ui_ThingType = M12_TYPE(L0766_T_Thing)) == C04_THING_TYPE_GROUP) {
                                L0773_B_SquareContainsGroup = TRUE;
                        } else {
                                if ((L0771_ui_ThingType == C02_THING_TYPE_TEXT) && (L0767_i_ThingType == CM1_THING_TYPE_PARTY) && P592_B_AddThing && !P591_B_PartySquare) {
                                        F168_ajzz_DUNGEON_DecodeText(G353_ac_StringBuildBuffer, L0766_T_Thing, C1_TEXT_TYPE_MESSAGE);
                                        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(C15_COLOR_WHITE, G353_ac_StringBuildBuffer);
                                } else {
                                        if ((L0771_ui_ThingType > C04_THING_TYPE_GROUP) && (L0771_ui_ThingType < C14_THING_TYPE_PROJECTILE)) {
                                                L0772_B_SquareContainsObject = TRUE;
                                                L0775_B_SquareContainsThingOfSameType |= (F032_aaaY_OBJECT_GetType(L0766_T_Thing) == L0774_i_ObjectType);
                                                L0776_B_SquareContainsThingOfDifferentType |= (F032_aaaY_OBJECT_GetType(L0766_T_Thing) != L0774_i_ObjectType);
                                        }
                                }
                        }
                        L0766_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0766_T_Thing);
                }
        } else {
                while (L0766_T_Thing != C0xFFFE_THING_ENDOFLIST) {
                        if ((L0770_ui_SensorTriggeredCell == M11_CELL(L0766_T_Thing)) && (M12_TYPE(L0766_T_Thing) > C04_THING_TYPE_GROUP)) {
                                L0772_B_SquareContainsObject = TRUE;
                                L0775_B_SquareContainsThingOfSameType |= (F032_aaaY_OBJECT_GetType(L0766_T_Thing) == L0774_i_ObjectType);
                                L0776_B_SquareContainsThingOfDifferentType |= (F032_aaaY_OBJECT_GetType(L0766_T_Thing) != L0774_i_ObjectType);
                        }
                        L0766_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0766_T_Thing);
                }
        }
        if (P592_B_AddThing && (L0767_i_ThingType != CM1_THING_TYPE_PARTY)) {
                F163_amzz_DUNGEON_LinkThingToList(P590_T_Thing, 0, P588_ui_MapX, P589_ui_MapY);
        }
        for(L0766_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(P588_ui_MapX, P589_ui_MapY); L0766_T_Thing != C0xFFFE_THING_ENDOFLIST; L0766_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0766_T_Thing)) {
                if ((L0771_ui_ThingType = M12_TYPE(L0766_T_Thing)) == C03_THING_TYPE_SENSOR) {
                        L0769_ps_Sensor = (SENSOR*)F156_afzz_DUNGEON_GetThingData(L0766_T_Thing);
                        if (M39_TYPE(L0769_ps_Sensor) == C000_SENSOR_DISABLED) {
                                continue;
                        }
                        L0779_i_SensorData = M40_DATA(L0769_ps_Sensor);
                        L0768_B_TriggerSensor = P592_B_AddThing;
                        if (L0770_ui_SensorTriggeredCell == CM1_CELL_ANY) {
                                switch (M39_TYPE(L0769_ps_Sensor)) {
                                        case C001_SENSOR_FLOOR_THERON_PARTY_CREATURE_OBJECT:
                                                if (P591_B_PartySquare || L0772_B_SquareContainsObject || L0773_B_SquareContainsGroup) { /* BUG0_30 A floor sensor is not triggered when you put an object on the floor if a levitating creature is present on the same square. The condition to determine if the sensor should be triggered checks if there is a creature on the square but does not check whether the creature is levitating. While it is normal not to trigger the sensor if there is a non levitating creature on the square (because it was already triggered by the creature itself), a levitating creature should not prevent triggering the sensor with an object. */
                                                        continue;
                                                }
                                                break;
                                        case C002_SENSOR_FLOOR_THERON_PARTY_CREATURE:
                                                if ((L0767_i_ThingType > C04_THING_TYPE_GROUP) || P591_B_PartySquare || L0773_B_SquareContainsGroup) {
                                                        continue;
                                                }
                                                break;
                                        case C003_SENSOR_FLOOR_PARTY:
                                                if ((L0767_i_ThingType != CM1_THING_TYPE_PARTY) || (G305_ui_PartyChampionCount == 0)) {
                                                        continue;
                                                }
                                                if (L0779_i_SensorData == 0) {
                                                        if (P591_B_PartySquare) {
                                                                continue;
                                                        }
                                                } else {
                                                        if (!P592_B_AddThing) {
                                                                L0768_B_TriggerSensor = FALSE;
                                                        } else {
                                                                L0768_B_TriggerSensor = (L0779_i_SensorData == M00_INDEX_TO_ORDINAL(G308_i_PartyDirection));
                                                        }
                                                }
                                                break;
                                        case C004_SENSOR_FLOOR_OBJECT:
                                                if ((L0779_i_SensorData != F032_aaaY_OBJECT_GetType(P590_T_Thing)) || L0775_B_SquareContainsThingOfSameType) {
                                                        continue;
                                                }
                                                break;
                                        case C005_SENSOR_FLOOR_PARTY_ON_STAIRS:
#ifdef C07_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN /* CHANGE8_05_FIX */
                                                if ((L0771_ui_ThingType != CM1_THING_TYPE_PARTY) || (M34_SQUARE_TYPE(L0777_ui_Square) != C03_ELEMENT_STAIRS)) { /* BUG0_31 Floor sensors to detect the party on a stairs square are never triggered. A wrong variable is used in a condition in the source code. This has no consequence in the games as this sensor type is not used in the original dungeons. The wrong variable is used in the condition (L0771_ui_ThingType != CM1_THING_TYPE_PARTY) which is always TRUE */
#endif
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_05_FIX The wrong variable is replaced by the correct variable in the condition. The test should not be on L0771_ui_ThingType but on L0767_i_ThingType */
                                                if ((L0767_i_ThingType != CM1_THING_TYPE_PARTY) || (M34_SQUARE_TYPE(L0777_ui_Square) != C03_ELEMENT_STAIRS)) {
#endif
                                                        continue;
                                                }
                                                break;
                                        case C006_SENSOR_FLOOR_GROUP_GENERATOR:
                                                continue;
                                        case C007_SENSOR_FLOOR_CREATURE:
                                                if ((L0767_i_ThingType > C04_THING_TYPE_GROUP) || (L0767_i_ThingType == CM1_THING_TYPE_PARTY) || L0773_B_SquareContainsGroup) {
                                                        continue;
                                                }
                                                break;
                                        case C008_SENSOR_FLOOR_PARTY_POSSESSION:
                                                if (L0767_i_ThingType != CM1_THING_TYPE_PARTY) {
                                                        continue;
                                                }
                                                L0768_B_TriggerSensor = F274_xxxx_SENSOR_IsObjectInPartyPossession(L0779_i_SensorData);
                                                break;
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_23_IMPROVEMENT New floor sensor type: version checker. This sensor is triggered only if its data value is smaller than or equal to the game engine version (hard coded as 20 for version 2.0). This sensor type is not used in the original dungeon */
                                        case C009_SENSOR_FLOOR_VERSION_CHECKER:
                                                if ((L0767_i_ThingType != CM1_THING_TYPE_PARTY) || !P592_B_AddThing || P591_B_PartySquare) {
                                                        continue;
                                                }
#ifdef C26_COMPILE_CSB20EN /* CHANGE8_06_IMPROVEMENT */
                                                L0768_B_TriggerSensor = (L0779_i_SensorData <= 20);
#endif
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_06_IMPROVEMENT The hard coded game engine version for the version checker sensor is now 21 for version 2.1 */
                                                L0768_B_TriggerSensor = (L0779_i_SensorData <= 21);
#endif
                                                break;
#endif
                                        default:
                                                continue;
                                }
                        } else {
                                if (L0770_ui_SensorTriggeredCell != M11_CELL(L0766_T_Thing)) {
                                        continue;
                                }
                                switch (M39_TYPE(L0769_ps_Sensor)) {
                                        case C001_SENSOR_WALL_ORNAMENT_CLICK:
                                                if (L0772_B_SquareContainsObject) {
                                                        continue;
                                                }
                                                break;
                                        case C002_SENSOR_WALL_ORNAMENT_CLICK_WITH_ANY_OBJECT:
                                                if (L0775_B_SquareContainsThingOfSameType || (M40_DATA(L0769_ps_Sensor) != F032_aaaY_OBJECT_GetType(P590_T_Thing))) {
                                                        continue;
                                                }
                                                break;
                                        case C003_SENSOR_WALL_ORNAMENT_CLICK_WITH_SPECIFIC_OBJECT:
                                                if (L0776_B_SquareContainsThingOfDifferentType || (M40_DATA(L0769_ps_Sensor) == F032_aaaY_OBJECT_GetType(P590_T_Thing))) {
                                                        continue;
                                                }
                                                break;
                                        default:
                                                continue;
                                }
                        }
                        L0768_B_TriggerSensor ^= L0769_ps_Sensor->A.RevertEffect;
                        if ((L0778_i_Effect = L0769_ps_Sensor->A.Effect) == C03_EFFECT_HOLD) {
                                L0778_i_Effect = L0768_B_TriggerSensor ? C00_EFFECT_SET : C01_EFFECT_CLEAR;
                        } else {
                                if (!L0768_B_TriggerSensor) {
                                        continue;
                                }
                        }
                        if (L0769_ps_Sensor->A.Audible) {
                                F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C01_SOUND_SWITCH, P588_ui_MapX, P589_ui_MapY, C01_MODE_PLAY_IF_PRIORITIZED);
                        }
                        F272_xxxx_SENSOR_TriggerEffect(L0769_ps_Sensor, L0778_i_Effect, P588_ui_MapX, P589_ui_MapY, CM1_CELL_ANY);
                        continue;
                }
                if (L0771_ui_ThingType >= C04_THING_TYPE_GROUP) {
                        break;
                }
        }
        F271_xxxx_SENSOR_ProcessRotationEffect();
}
