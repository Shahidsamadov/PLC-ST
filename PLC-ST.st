(*
    SetLedStatus Legend

    Syntax
    result := SetLedStatus(index, status);

    Parameter      Type           Description

    Result         DINT           0: operation successfully completed  1: operation failed
    index          DINT           LED number(12: Alarm Led, 7: Prg Led)
    status         DINT           Status of the Led(0: off, 1: on, 2: blinking)
*)


// ------------------------------------------------------------- //
/////////////////////--------IMPORTANT--------\\\\\\\\\\\\\\\\\\\\\

//When simulating the project, in "Mask simulator" window press "Watch Variables" and
//set "-1" value to "ID_Lang" variable in order to skip the initial mask

//To collapse all the Functions press CTRL+M+L


// ------------------------------------------------------------- //
// ---                 Variables declaration                 --- //
// ------------------------------------------------------------- // 

VAR_GLOBAL
    
    // ------------------------------------------------------------- //

    //MENU VARIABLES
    //Modify these variables to customize the menu 
    MAIN_MENU_ITEMS_NO       : INT:=7; //Set here the number of voices for "Main menu", 
                                       //Classes to modify for mask text = MainTxtTOP, MainTxtMIDDLE and MainTxtBOTTOM,
                                       //Class to modify for mask icon = IdxImgMain
                                       //Function to modify = "SelMainMenu"
  
    SETTINGS_MENU_ITEMS_NO   : INT:=6; //Set here the number of voices for "Settings Menu", 
                                       //classes to modify for mask text SettingsTxtTOP, SettingsTxtMIDDLE and SettingsTxtBOTTOM,
                                       //class to modify for mask icon  IdxImgSettings
                                       //Function to modify = "SelSettingsMenu"

    QUICK_MENU_ITEMS_NO      : INT:=3; //Set here the number of voices for "Quick Menu"
                                       //class to modify for mask icon IdxImgQM
                                       //Function to modify = "QuickMenuENT"

    // ------------------------------------------------------------- //
    
    //Variables decalration
    //Menu variables
    BarPos            : INT;      //Manages the position of the black bar
    IdxMenuMsk        : INT;      //Manages the position of the items of Main_Menu
    CurrItemNo        : INT:=1;   //Manages the number of the item pointed by the black bar
    IdxImg1           : INT:=1;   //Icon position management of Menu
    IdxImg2           : INT:=2;   //Icon position management of Menu
    IdxImg3           : INT:=4;   //Icon position management of Menu
    IdxMenuMskTmp, BarPosTmp, CurrItemNoTmp : INT; //Temporary variables for Settings menu(save the last position of the main menu)
    IdxImg1Tmp, IdxImg2Tmp, IdxImg3Tmp      : INT; //Temporary variables for Settings menu(save the last position of the main menu)
    MenuItemsNo                             : INT; //Total items number of current menu
    
    //Delay variables
    DTRetMain         : INT;   //Support variable for Main Mask return 
    DTQM              : INT;   //Support variable for quick menu icon blink

    //Password variables
    IncrTmp           : INT ;  //Support variable for password management
    PwdIn             : UINT;  //Input password
    PwdRes            : INT ;  //Password result
    EnLogOut          : BOOL;  //Enable for Logout mask
    EnPwdChgU         : BOOL;  //Enable for User password change
    EnPwdChgS         : BOOL;  //Enable for Service password change
    EnPwdChgM         : BOOL;  //Enable for Manufacturer password change
    PwdTyp            : INT ;  //Password type in login menu(1: User; 2: Service; 3: Manufacturer)
    PwdTypMenu        : INT ;  //Copy of PwdType that shows in the menu the user access
    CntDwnPwdTypMenu  : INT ; //Countdown in second to show the user access in the menu (-1 to always on)

    //Quick menu variables
    IdxImgQM          : INT:=1;//Icon position management of Quick Menu
    IdxQM             : INT:=1;//Index of quick menu

    //Other variables
    MaskPos             : INT ; //Position of the current Mask
    ImpExpSel           : BOOL; //Import/Export selection
    EnImpExpTmp         : INT ; //Temporary enable of Import/Export parameters functions
    LangTime            : INT ; //Language mask time
    EnLangChg           : BOOL; //Language countdown enable
    Date1, Date2, Date3 : UINT; //Mask date management    
    EnStartup           : BOOL; //Enable application startup 
    EnEndDef            : BOOL; //Enable EndDefault mask
    EnCarelLogo         : BOOL; //Enable CarelLogo mask   
    BoardTempMsk        : REAL; //Internal board temperature 
    EnAlrmExpTmp        : INT;  //Temporary enable of Export alarms functions
    En_WipeRetain       : BOOL; //Enable wipe retain memory
    En_WipeNVRAM        : BOOL; //Enable wipe NVRAM memory
    En_WipeAll          : BOOL; //Enable wipe retain+NVRAM memory
    TimeZoneTmp         : UINT; //Temp variable for time zone mng
    SetTimeZoneTmp      : INT;  //Temp variable for time zone mng
    FirstCycleDone      : BOOL; //UoM initialization
    //End declaration

    //Alarm variables
    LastValidRecord                                 : DINT;  //Index of the last valid record
    LastActAlrm                                     : DINT;  //Index of the last active alarm
    infoLogOk, AlrmLogInfoErr                       : DINT;  //result of function GetAlarmLogInfo
	AlrmIdx, AlrmCode                               : DINT;  //Used on GetAlarmInfo
    AlrmLogsIdx, AlrmLogCode, AlrmLogsTot           : DINT;  //Used on GetAlarmLogInfo
    AlrmLogEventType                                : USINT; //Type of alarm event
    AlrmStoredVarReal1, AlrmStoredVarReal2          : REAL;  //Alarm variable stored  
    EnStoredVar1_REAL, EnStoredVar2_REAL            : BOOL;  //Stored alarm variable enable
    N_Alrms,N_Alrms_Prev                            : DINT;  //Current and previous alarm number
    KeyAlarmAutorepeatActive                        : BOOL;  //Single alarm reset management
    ClrAutoResCounters                              : BOOL;  //Enable for ClrAutoResCounters statement
    AlrmLogsIdxTemp,AlrmLogCodeTemp,AlrmLogTimeTemp : DINT;  //Temporary variables for alarm information
    AlrmLogEventTypeTemp                            : USINT; //Temporary variables for "AlrmLogInfoErr" statement
    AlrmLogDelete                                   : BOOL;  //Alarm log delete enable 
    EnCheckAlarm                                    : BOOL;  //Enable check alarm function 
    En_CheckAlrm_Reset                              : BOOL;  //Enable the alarm check after a Global alarm Reset
    ShowTemp                                        : BOOL;  //Show Board temperature if the function is implemented on the target (only c.pCO)
    //End variables declaration

END_VAR

// ------------------------------------------------------------- //
// ---                      Timed Loop                       --- //
// ------------------------------------------------------------- //

FUNCTION TIMED_LOOP 

    // ---Timed Loop Functions--- //
    InstDef();
    
    IF GeneralMng.VerMismatch = FALSE AND StartupJmp = FALSE THEN
        CheckAlarm();
        CarelLogo();
        ShowLangMskTime();
        BlinkQuickMenu();
        RetMainMsk();
        MskDateFormat();
        DTQM := DTQM + 1;
        UsrAccessMenu();
        CheckAlrm_Reset();
    END_IF;

    // --- Leds and Delays management--- //
    SetExternalDisplayMode(1,300); //Set the backlight timer after 5 minutes of inactivity for external display
    DTRetMain := DTRetMain +1;     //Delay for main mask return
    BoardTempMsk:=GeneralMng.BoardTemp_Msk; //Board Temperature in °C
    IF GeneralMng.BoardTyp[1] = 12 THEN
        ShowTemp:= TRUE;
    ELSIF GeneralMng.BoardTyp[1] <> 12 THEN
        ShowTemp:= FALSE;
    END_IF;
    // UoM management - startup initialization
    IF FirstCycleDone = FALSE THEN
        FirstCycleDone := TRUE;
        SetUoMZone (STD_UOM_ZONE_UI);
    END_IF;

END_FUNCTION

// ------------------------------------------------------------- //
// ---                 Timed Loop Functions                  --- //
// ------------------------------------------------------------- //

{#region  Timed Loop Functions}

FUNCTION InstDef

    //EndDefault mask display
    IF GeneralMng.DefDone = FALSE AND EnEndDef = FALSE THEN 
        EnEndDef := TRUE;        
        SetLedStatus(7,2);
        Gotomask(EndDefault);
    END_IF;

    //Automatic application startup after default installation
    IF GeneralMng.EndDefMsk = TRUE AND EnCarelLogo = FALSE AND EnEndDef = TRUE THEN 
        EnCarelLogo := TRUE;
        SetLedStatus(7,0);
        Gotomask(CarelLogo);
    END_IF;

END_FUNCTION

FUNCTION CheckAlarm                     //Check active alarms
    
    N_Alrms := GetAlarmsCount();        //Number of active alarms
    IF N_Alrms > N_Alrms_Prev THEN      //Activate the buzzer and alarm led if any alarm is present
        IF GeneralMng.RESERVED3 THEN                             
        __SYSVA_MANUAL_BUZZER_ON:= TRUE;
        __SYSVA_MANUAL_BUZZER_OFF:= FALSE;
        END_IF;
        SetLedStatus(12,2);
        EnCheckAlarm := TRUE;                                               
    ELSIF N_Alrms = 0 AND N_Alrms < N_Alrms_Prev THEN //Turn off the buzzer and alarm led if there aren't active alarms
        __SYSVA_MANUAL_BUZZER_OFF:= TRUE;    
        __SYSVA_MANUAL_BUZZER_ON:= FALSE;    
        SetLedStatus(12,0);
    END_IF;
  
    N_Alrms_Prev := N_Alrms;             //Save the previous number of alarm to the actual
END_FUNCTION

FUNCTION ShowLangMskTime
    //Language countdown of 30 seconds         
    LangTime := LangTime - 1;    
    IF LangTime = 0 AND GeneralMng.VerMismatch = FALSE AND EnLangChg = TRUE THEN
        EnLangChg := FALSE;
        GotoMain();
    END_IF;
END_FUNCTION

FUNCTION BlinkQuickMenu
    //Blinking of quick menu icons
    IF DTQM = 1 AND IdxImgQM <(QUICK_MENU_ITEMS_NO + 1 )  THEN        
        DTQM := 0;                            
        IdxImgQM := IdxImgQM + QUICK_MENU_ITEMS_NO;
    ELSIF DTQM = 1 AND IdxImgQM > QUICK_MENU_ITEMS_NO THEN
        DTQM := 0;
        IdxImgQM := IdxImgQM - QUICK_MENU_ITEMS_NO;
    END_IF;
END_FUNCTION

FUNCTION CarelLogo                              
        IF GeneralMng.ID_Lang = -1 THEN         //If ID_Language = -1, it means that a Wipe Retain has just be done     
            GeneralMng.ID_Lang := 0;
            LangTime := 30;
            EnLangChg := TRUE;
            GotoMask(Language);
            EnStartup := TRUE;
        END_IF;
        IF  EnStartup = FALSE THEN
            ChangeLanguage(GeneralMng.ID_Lang); //Configuration of language mask time after startup jump           
            EnStartup := TRUE;
            Gotomask(Main);
        END_IF;                                              
END_FUNCTION

FUNCTION RetMainMsk
    //Automatic return to Main Mask after 5 minutes of inactivity and automatic Logout
    IF __SYSVA_KEY_PRESSED = 1 THEN    
        DTRetMain := 0;               
        LangTime := 30; 
       __SYSVA_KEY_PRESSED := 0;
    ELSIF DTRetMain = 300 THEN
        MenuItemsNo := MAIN_MENU_ITEMS_NO;
        PwdIn := 0;
        EnLogOut := FALSE;
        GotoMain();
    END_IF;
END_FUNCTION    

FUNCTION MskDateFormat
    CASE GeneralMng.DateFormat OF

        0:// DD/MM/YY
          Date1 := GeneralMng.Day;
          Date2 := GeneralMng.Month;
          Date3 := GeneralMng.Year;

        1:// MM/DD/YY
          Date1 := GeneralMng.Month; 
          Date2 := GeneralMng.Day;
          Date3 := GeneralMng.Year;

        2:// YY/MM/DD
          Date1 := GeneralMng.Year;
          Date2 := GeneralMng.Month;
          Date3 := GeneralMng.Day;

    END_CASE;
END_FUNCTION

FUNCTION UsrAccessMenu
    IF CntDwnPwdTypMenu > 0 THEN
        CntDwnPwdTypMenu := CntDwnPwdTypMenu - 1;
    ELSIF CntDwnPwdTypMenu = 0 THEN
        PwdTypMenu := 0;
    END_IF;
END_FUNCTION

FUNCTION CheckAlrm_Reset
    //Check the active alarms after a Global/Single alarm reset
    IF En_CheckAlrm_Reset THEN
        IF N_Alrms = 0 THEN
            GotoMask(Alrms_NoAlrms);      
        ELSE          
            CheckActiveAlarm();
        END_IF;
        En_CheckAlrm_Reset := FALSE;
    END_IF;
END_FUNCTION

{#endregion}

// ------------------------------------------------------------- //
// ---                  Language Management                  --- //
// ------------------------------------------------------------- //

FUNCTION Lang_UP                    //UP key function for Language selection    
    IF GeneralMng.ID_Lang >= (GetLanguagesCount() - 1) THEN
        GeneralMng.ID_Lang := 0;
    ELSE            
        GeneralMng.ID_Lang := GeneralMng.ID_Lang + 1;
    END_IF;
    
    ChangeLanguage(GeneralMng.ID_Lang);
END_FUNCTION

// ------------------------------------------------------------- //
// ---                   Alarm Management                    --- //
// ------------------------------------------------------------- //


// ---Active Alarms Management--- //

{#region Active Alarms}

FUNCTION CheckActiveAlarm  
              
    VAR
        infoOk:DINT;
    END_VAR
    
    MaskPos := 1;
    SetLedStatus(7,0);
    EnCheckAlarm := FALSE;

    N_Alrms := GetAlarmsCount();            //Get active alarms number
    __SYSVA_MANUAL_BUZZER_OFF:= TRUE;       //Every time i enter alarm mask, turn off the buzzer
    __SYSVA_MANUAL_BUZZER_ON:= FALSE;

    IF N_Alrms > 0 THEN                     //If there's a new alarm and alarm key is pressed,                                 
        SetLedStatus(12, 1);                //then fix the alarm led
        AlrmIdx := 1;
        infoOk:= GetAlarmInfo(AlrmIdx, AlrmCode , AlarmMng.AlrmTime); //Call GetAlarmInfo to show first alarm active
        CheckStoredVar_Alrm();
        GotoLoop(ACTIVEALARMS);
    ELSE
        AlrmIdx := 0;
        SetLedStatus(12, 0);                
        IF __SYSVA_KEY_COUNTER <= 1 THEN
            GotoMask(Alrms_NoAlrms);        //If there are no active alarms, goto no_alarms loop
        ELSIF __SYSVA_KEY_COUNTER >= 3 THEN //Try to reset alarms also if no alarms(due to remote devices)
            ResetAlarms();
            AlarmMng.AlrmResByPGD1:=TRUE;
            AlrmIdx:= 0;
        END_IF;
    END_IF;
END_FUNCTION

FUNCTION ScrollAlarm_DOWN                              //Navigation trought active alarm mask

    N_Alrms := GetAlarmsCount();                       //Get active alarms count
    IF AlrmIdx = 0 AND N_Alrms <> 0 THEN               //If i'm in the "Alarm_Reset" mask, go to Alarm_Active mask
        GotoNextMask();
    END_IF; 
                                            
    IF N_Alrms >= 0 AND N_Alrms <> 0 THEN              //If there are active alarms,
        IF AlrmIdx >= 0 AND AlrmIdx < N_Alrms THEN     //and i'm not in the last alarm, then show me the next alarm
            AlrmIdx:= AlrmIdx+1;
        ELSIF AlrmIdx >= N_Alrms THEN                  //If i'm in the last alarm, show next mask(Alarm_Reset)
            AlrmIdx:= 0;
            GotoNextMask();
        END_IF;
        GetAlarmInfo(AlrmIdx, AlrmCode, AlarmMng.AlrmTime);     //Get alarm info by index
        CheckStoredVar_Alrm(); 
    ELSIF N_Alrms = 0 THEN                             //If there are no alarms, show No_alarms mask 
        GotoMask(Alrms_NoAlrms);
    END_IF;

END_FUNCTION

FUNCTION ScrollAlarm_UP                                //Navigation trought active alarm mask
                                        
    N_Alrms := GetAlarmsCount();                       //Get active alarms count
    IF N_Alrms > 0 THEN                                //If there are active alarms,
        IF AlrmIdx > 1 AND AlrmIdx <= N_Alrms THEN     //and i'm not in the last alarm, then show me the previous alarm
            AlrmIdx:= AlrmIdx-1;
        ELSIF AlrmIdx = 1 THEN                         //If i'm in the last alarm, show next mask(Alarm_Reset)
            AlrmIdx:= 0;
            GotoPreviousMask();
        ELSIF AlrmIdx = 0 AND N_Alrms <> 0 THEN        //If i'm in the "Alarm_Reset" mask, go to Alarm_Active mask
            AlrmIdx := N_Alrms;
            GotoPreviousMask(); 
        END_IF;
        GetAlarmInfo(AlrmIdx, AlrmCode, AlarmMng.AlrmTime);     //Get alarm info by index
        CheckStoredVar_Alrm(); 
    ELSIF N_Alrms = 0 THEN                             //If there are no alarms, show No_alarms mask
        GotoMask(Alrms_NoAlrms);
    END_IF;

END_FUNCTION

FUNCTION ResetSingleAlarm
    IF N_Alrms = 0 OR EnCheckAlarm = TRUE THEN                                  
        CheckActiveAlarm();
        EnCheckAlarm := FALSE;
    END_IF;

    IF __SYSVA_KEY_COUNTER = 1 THEN         //Reset only the alarm that I'm displaying
        KeyAlarmAutorepeatActive := FALSE;
    ELSIF(__SYSVA_KEY_COUNTER >= 3) AND 
         (KeyAlarmAutorepeatActive=FALSE) THEN
        KeyAlarmAutorepeatActive := TRUE;
        ResetAlarm(AlrmIdx);
        En_CheckAlrm_Reset := TRUE;         //Enable the CheckAlrm_Reset function
    END_IF;
END_FUNCTION

FUNCTION ResetGlobalAlarm
    IF __SYSVA_KEY_COUNTER >= 3 THEN     //If I hold down the alarm button for more 
        ResetAlarms();                   //than 3 seconds then resets all alarms
        AlarmMng.AlrmResByPGD1 := TRUE;           
        AlrmIdx:= 1;
        En_CheckAlrm_Reset := TRUE;      //Enable the CheckAlrm_Reset function
    END_IF;
END_FUNCTION

FUNCTION CheckStoredVar_Alrm                                                  //This function let you sample the sampled variables on Alarm table
    
    //--- Active alarms ---//
    IF GetAlarmStoredVar(AlrmIdx, 1, AlrmStoredVarReal1) <> 0 THEN            //Control if there's any variable to be sampled
        EnStoredVar1_REAL := FALSE;                                           //If is present, enable the fields
    ELSE
        EnStoredVar1_REAL := TRUE;                                            //else, don't enable the fields
    END_IF;

    IF GetAlarmStoredVar(AlrmIdx, 2, AlrmStoredVarReal2) <> 0 THEN
        EnStoredVar2_REAL := FALSE;     
    ELSE
        EnStoredVar2_REAL := TRUE; 
    END_IF;
    
END_FUNCTION

{#endregion}

//--- Alarms logs Management ---//

{#region Alarms logs}

FUNCTION gotoAlarmLog        
                                
    AlrmLogsTot:= GetAlarmLogsCount();
    //Show last alarm log                            
    IF AlrmLogsTot > 0 THEN                                       
        AlrmLogsIdx:=1;
        infoLogOk:=GetAlarmLogInfo(AlrmLogsIdx, AlrmLogCode, 
                                   AlrmLogEventType, AlarmMng.AlrmLogTime);
        CheckStoredVar_Log(); 
    ELSE
        AlrmLogsIdx:=0;
        infoLogOk:=-1;
    END_IF;

    IF infoLogOk = 0 THEN                                         
        LastValidRecord:= AlrmLogsIdx;
        GotoLoop(ALRMLOGS);
    ELSE
        GotoMask(Alrms_NoLog);                                   
    END_IF;

END_FUNCTION

FUNCTION ScrollAlarmLog_UP 
     
    IF AlrmLogsIdx = 1 THEN                                         //If I'm displaying the first log alarm, then beep              
        Beep();
    ELSE
        AlrmLogsIdx:= AlrmLogsIdx-1;                                //else, decrease the alarm log index
        AlrmLogsIdxTemp:= AlrmLogsIdxTemp - 1;                      
        AlrmLogInfoErr:=GetAlarmLogInfo(AlrmLogsIdx, AlrmLogCode,   //Get information about alarm logs
                                    AlrmLogEventType, AlarmMng.AlrmLogTime);
        CheckStoredVar_Log();                                           //Show me sampled values if there are
    END_IF;
                                                     
END_FUNCTION

FUNCTION ScrollAlarmLog_DOWN  
  
    AlrmLogsIdxTemp := AlrmLogsIdx;
    AlrmLogsIdxTemp:= AlrmLogsIdxTemp + 1;
    AlrmLogInfoErr:=GetAlarmLogInfo(AlrmLogsIdxTemp, AlrmLogCodeTemp,       //Get information about alarm logs
                                    AlrmLogEventTypeTemp, AlrmLogTimeTemp);
    IF AlrmLogInfoErr = 1 THEN                                              //If I'm displaying the last log alarm, then beep
        Beep();
    ELSE
        IF AlrmLogsIdx < 64 THEN
            AlrmLogsIdx:= AlrmLogsIdx + 1;                                   //else, increase the alarm log index 
            AlrmLogInfoErr:=GetAlarmLogInfo(AlrmLogsIdx, AlrmLogCode,        //Get information about alarm logs
                                        AlrmLogEventType, AlarmMng.AlrmLogTime);
            CheckStoredVar_Log();                                                //Show me sampled values if there are
        ELSE
            AlrmLogsIdx := 64;
            Beep();
        END_IF;    
    END_IF;
   
END_FUNCTION

FUNCTION CheckStoredVar_Log                                                   //This function let you sample the sampled variables on Alarm table
    
    //--- Logged alarms ---//
    IF GetAlarmLogStoredVar(AlrmLogsIdx, 1, AlrmStoredVarReal1) <> 0 THEN 
        EnStoredVar1_REAL := FALSE;                                           //If is present, enable the fields
    ELSE
        EnStoredVar1_REAL := TRUE;                                            //else, don't enable the fields
    END_IF;
    
    IF GetAlarmLogStoredVar(AlrmLogsIdx, 2, AlrmStoredVarReal2) <> 0 THEN
        EnStoredVar2_REAL := FALSE;     
    ELSE
        EnStoredVar2_REAL := TRUE; 
    END_IF;
    
END_FUNCTION

FUNCTION DeleteAlarmLog
    //Alarm logs clear
    IF AlrmLogDelete = TRUE THEN           
        ClearAlarmLogs();
        AlrmLogDelete := FALSE;
    END_IF;
    Gotonextfield();
END_FUNCTION

FUNCTION ClearAutoResetCounter

    //Alarm counters clear
    IF ClrAutoResCounters = TRUE THEN  
        ClearAutoResetCounters();
        ClrAutoResCounters := FALSE;
        GlobalEsc();
    ELSE
        Gotonextfield();
    END_IF;

END_FUNCTION

{#endregion}


// ------------------------------------------------------------- //
// ---                   Menu navigation                     --- //
// ------------------------------------------------------------- //


// ---Quick Menu management--- //

{#region Quick menu}

//Function for UP key of main mask
FUNCTION QuickMenuUP              
    IdxQM := IdxQM + 1;
    IF IdxQM > QUICK_MENU_ITEMS_NO THEN
        IdxImgQM := 1;
        IdxQM := 1;
    ELSE
        IdxImgQM := IdxImgQM + 1;    
    END_IF;      
END_FUNCTION

//Function for DOWN key of main mask    
FUNCTION QuickMenuDOWN           
    IdxQM := IdxQM - 1;
    IF IdxQM < 1 THEN
        IdxImgQM := QUICK_MENU_ITEMS_NO;
        IdxQM := QUICK_MENU_ITEMS_NO;
    ELSE
        IdxImgQM := IdxImgQM - 1;    
    END_IF; 
END_FUNCTION

//Selection of quick menu
FUNCTION QuickMenuENT           
    MaskPos := 1;

    CASE IdxQM OF

        1: GotoLoop(ONOFF);
        
        2: GotoLoop(SET);

        3: GotoLoop(INFO);

    END_CASE; 
END_FUNCTION

{#endregion}

// ---Main Menu management--- //

{#region Main menu}

//Function associated to key PRG
FUNCTION GotoMainMenu                           
    SetLedStatus(7,1);             //Turn on Led 7(prg)

    IF EnLogOut = FALSE THEN
        PwdIn := 0;                 //Reset password
        IncrTmp := 0;  
        PwdRes := 0;
        GotoMask(Pwd_LogIn);
    ELSE
        GotoMask(Menu_Main);
    END_IF;

    MaskPos := 1;                    
    MenuItemsNo := MAIN_MENU_ITEMS_NO;   //Main menu initialization
    IdxMenuMsk := 0;                   
    BarPos := 0;              
    CurrItemNo := 1;
    IdxImg1 := 1;                 
    IdxImg2 := 2;
    IdxImg3 := 4;

    PwdTypMenu := PwdTyp;
    CntDwnPwdTypMenu := 5;
END_FUNCTION
    
FUNCTION SelMainMenu                //CASE that manages the Main Menu selection
    CASE CurrItemNo OF              //Depending on which item the black bar is pointing, select the menu
       
        1: GotoLoop(DEVICE1);
           MaskPos := 2;

        2: GotoLoop(DEVICE2);
           MaskPos := 2;

        3: GotoLoop(DEVICEn);  
           MaskPos := 2;

        4: GotoLoop(UNITCFG);                         
           MaskPos := 2;

        5: gotoAlarmLog();
           MaskPos := 2;

        6: MaskPos := 3;

           //Save Main Menu position and go to Settings menu
           IdxMenuMskTmp := IdxMenuMsk;                  
           BarPosTmp     := BarPos;                         
           CurrItemNoTmp := CurrItemNo;   
           IdxImg1Tmp    := IdxImg1 ;                      
           IdxImg2Tmp    := IdxImg2;
           IdxImg3Tmp    := IdxImg3;
           
           //Settings menu initialization
           MenuItemsNo := SETTINGS_MENU_ITEMS_NO; 
           CurrItemNo  := 1;                     
           IdxMenuMsk  := 0;                              
           BarPos      := 0;
           IdxImg1     := 1;                     
           IdxImg2     := 2;
           IdxImg3     := 4;

           Gotomask(SETTINGS);
        
        7: GotoMask(Pwd_LogOut);
           MaskPos := 2;
        
    END_CASE;
END_FUNCTION

FUNCTION RetMainLoop                //Function that restore the Main Menu position
    IdxMenuMsk  := IdxMenuMskTmp;                         
    BarPos      := BarPosTmp;
    MenuItemsNo := MAIN_MENU_ITEMS_NO;                          
    CurrItemNo  := CurrItemNoTmp;
    IdxImg1     := IdxImg1Tmp;                      
    IdxImg2     := IdxImg2Tmp;
    IdxImg3     := IdxImg3Tmp;
    GotoMask(Menu_Main);      
END_FUNCTION

{#endregion}

// ---Settings Menu management--- //

{#region Settings menu}

FUNCTION GotoMain                   
    MaskPos := 0;
    SetLedStatus(7,0);           
    EnLangChg := FALSE;
    GotoMask(Main);
END_FUNCTION

FUNCTION SelSettingsMenu            //CASE that manages the Settings Menu selection                              
    CASE CurrItemNo OF              //Depending on where the black bar is pointing, select the menu
       
        1: Gotoloop(DATETIME);
            
           GeneralMng.SecondIn   := GeneralMng.Second;    //Copy the current values of date and time that will be modified
           GeneralMng.MinuteIn   := GeneralMng.Minute;
           GeneralMng.HourIn  := GeneralMng.Hour;
           GeneralMng.DayIn   := GeneralMng.Day;
           GeneralMng.MonthIn := GeneralMng.Month;
           GeneralMng.YearIn  := GeneralMng.Year;
           
           TimeZoneTmp := GeneralMng.Zone_Read; //aligns "new time zone" to "current"

        2: Gotomask(Language);
           EnLangChg := TRUE;
        
        3: Gotoloop(SERIALPORTS) ;

        4: GotoMask(PWDCHG); 
           IncrTmp := 0;  
    
        5: Gotoloop(INITIALIZATION); 
           En_WipeRetain := FALSE;
           En_WipeNVRAM := FALSE;
           En_WipeAll := FALSE;

        6: GotoLoop(UoM);
         
    END_CASE;
    MaskPos := 4;
END_FUNCTION

FUNCTION RetSettingsLoop        //Function that restore the Settings Menu position     
    Gotomask(SETTINGS);
END_FUNCTION

{#endregion}

//--- Global ESC ---//
FUNCTION GlobalEsc              //Global ESC, according to the mask where you are, do a ESC Function 
    CASE MaskPos OF             //The MaskPos variable, keeps track of the current position
        0: GotoMain();
           MaskPos := 0;

        1: GotoMain();
           MaskPos := 0;
        
        2: Gotomask(Menu_Main);
           SetLedStatus(7,1);
           MaskPos := 1; 

        3: RetMainLoop();
           MaskPos := 1;

        4: RetSettingsLoop();
           MaskPos := 3;
    END_CASE;
END_FUNCTION


//---Function for DOWN key of Menu---//
FUNCTION ScrollMenuDown
    CurrItemNo := CurrItemNo + 1;          //Increase the number of the page
    IF MenuItemsNo > 2 THEN
        IF BarPos = 0 THEN                     //If the bar is in HIGH position, then move the bar in HALF position
            BarPos := 1;
            IdxImg1 := IdxImg1 - 1;            //Icon management
            IdxImg2 := IdxImg2 + 1;     
        ELSIF BarPos = 1 THEN                  //If the bar is in HALF position, then move the bar in DOWN posiotion
            BarPos := 2;
            IdxImg2 := IdxImg2 - 1;            //Icon management
            IdxImg3 := IdxImg3 + 1;
        ELSIF BarPos = 2 THEN                  //If the bar is in the LOW position and the index Idx is less than(Num_Menu - 3), or else
            IF IdxMenuMsk <(MenuItemsNo - 3) THEN  //if you are not at the lower end of the menu, then increase the index of the written
                IdxMenuMsk := IdxMenuMsk + 1;  //(so slide the writing)
                IdxImg1 := IdxImg1 + 2;        //Icon management
                IdxImg2 := IdxImg2 + 2;
                IdxImg3 := IdxImg3 + 2;
            ELSE
                IdxMenuMsk := 0;               //If the bar is at the lower end of the menu, then reset the values and returns the menu 
                BarPos := 0;                   //to the top
                CurrItemNo := 1;
                IdxImg1 := 1;                  //Icon management
                IdxImg2 := 2;
                IdxImg3 := 4;
            END_IF;
        END_IF;
    ELSE
        IF BarPos = 0 THEN          //Menu management for 2 items
            BarPos := 1;
            IdxImg1 := IdxImg1 - 1;        
            IdxImg2 := IdxImg2 + 1;     
        ELSIF BarPos = 1 THEN             
            BarPos := 0;
            IdxMenuMsk := 0;              
            CurrItemNo := 1;
            IdxImg1 := 1;                  
            IdxImg2 := 2;
        END_IF;
    END_IF;       
END_FUNCTION

//---Function for UP key of Menu---//
FUNCTION ScrollMenuUp   
    CurrItemNo:= CurrItemNo - 1;                //Decrease the number of page
    IF MenuItemsNo > 2 THEN
        IF BarPos = 0 THEN                          //If the bar is in HIGH position then, if the index Idx number is greater than zero,
            IF IdxMenuMsk > 0 THEN                  //then decreases Idx(slide the written keeping the bar high)
                IdxMenuMsk := IdxMenuMsk - 1;                     
                IdxImg1 := IdxImg1 - 2;             //Icon management
                IdxImg2 := IdxImg2 - 2;
                IdxImg3 := IdxImg3 - 2;
            ELSE                                    //otherwise, in the case in which they are at the upper limit of the menu,
                IdxMenuMsk :=(MenuItemsNo  -3);    //sets the values ??pointing to the lower limit of the menu
                BarPos := 2;               
                CurrItemNo := MenuItemsNo;
                IdxImg1 :=(MenuItemsNo * 2) - 6;   //Icon management
                IdxImg2 :=(MenuItemsNo * 2) - 4;
                IdxImg3 :=(MenuItemsNo * 2) - 1;
            END_IF;
        ELSIF BarPos = 1 THEN              //otherwise,  if the bar is in HALF position, then move the bar in HIGH position               
            BarPos := 0;
            IdxImg1 := IdxImg1 + 1;        //Icon management
            IdxImg2 := IdxImg2 - 1;
        ELSIF BarPos = 2 THEN              //otherwise, if the bar is in LOW position, then move the bar in HALF position
            BarPos := 1;
            IdxImg2 := IdxImg2 + 1;        //Icon management
            IdxImg3 := IdxImg3 - 1;
        END_IF;
    ELSE
        IF BarPos = 0 THEN             //Menu management for 2 items
            BarPos := 1;               
            CurrItemNo := MenuItemsNo;
            IdxImg1 := 0;                  
            IdxImg2 := 3; 
        ELSIF BarPos = 1 THEN                             
            BarPos := 0;
            IdxImg1 := IdxImg1 + 1;        
            IdxImg2 := IdxImg2 - 1;
        END_IF;
    END_IF;
END_FUNCTION


// ------------------------------------------------------------- //
// ---            Password Management Functions              --- //
// ------------------------------------------------------------- //

{#region Password functions}

FUNCTION PwdLogIn
    Compare();     
    IncrTmp := IncrTmp + 1;                         //Increment the cursor position                                             
    GotoRightDigit();

    IF PwdIn <> GeneralMng.PwdUser AND PwdIn <> GeneralMng.PwdService     //If password is wrong THEN reset password and say that is wrong
    AND PwdIn <> GeneralMng.RESERVED1 AND PwdIn <> GeneralMng.RESERVED2 AND IncrTmp = 4 THEN
        __SYSVA_TMP_VALUE := 0;
        PwdRes := 1;
        IncrTmp := 0;
        EnLogOut := FALSE;     
    
    ELSIF PwdIn = GeneralMng.RESERVED2 AND IncrTmp = 4 THEN //If password is a PASSE PAR TOUT password THEN login as MANUFACTURER and enable 
        PwdTyp := 3;                                   //Manufacturer Service and User passwords change
        EnLogOut := TRUE;
        EnPwdChgU := TRUE;
        EnPwdChgS := TRUE;
        EnPwdChgM := TRUE;
        MaskPos := 1;
        GotoMask(Menu_Main);   

    ELSIF PwdIn = GeneralMng.RESERVED1 AND IncrTmp = 4 THEN     //If password is a MANUFACTURER password THEN login as MANUFACTURER and enable 
        PwdTyp := 3;                                //Manufacturer Service and User passwords change
        EnLogOut := TRUE;
        EnPwdChgU := TRUE;
        EnPwdChgS := TRUE;
        EnPwdChgM := TRUE;
        MaskPos := 1;
        GotoMask(Menu_Main);
           
    ELSIF PwdIn = GeneralMng.PwdService AND IncrTmp = 4 THEN   //If password is a SERVICE password THEN login as SERVICE and enable 
        PwdTyp := 2;                                //Service and User passwords change
        EnLogOut := TRUE;
        EnPwdChgU := TRUE;
        EnPwdChgS := TRUE;
        EnPwdChgM := FALSE;
        MaskPos := 1;
        GotoMask(Menu_Main);

    ELSIF PwdIn = GeneralMng.PwdUser AND IncrTmp = 4 THEN      //If password is a USER password THEN login as USER and enable 
        PwdTyp := 1;                                //User password change
        EnLogOut := TRUE;
        EnPwdChgU := TRUE;
        EnPwdChgS := FALSE; 
        EnPwdChgM := FALSE;
        MaskPos := 1;       
        GotoMask(Menu_Main);
    END_IF;

    PwdTypMenu := PwdTyp;
    CntDwnPwdTypMenu := 5;
END_FUNCTION

FUNCTION PwdLogOut        //Function for Logout  
    MaskPos := 0;                   
    EnLogOut := FALSE;
    PwdTyp := 0;
    PwdIn := 0;
    PwdRes := 0;
    PwdTypMenu := PwdTyp;    

    SetLedStatus(7,0);
    IdxMenuMsk := 0;                   
    BarPos := 0;              
    CurrItemNo := 1;
    IdxImg1 := 1;         //Icon management
    IdxImg2 := 2;
    IdxImg3 := 4;

    GotoMask(Main);
END_FUNCTION

FUNCTION ChgPwd           //Function for password change
    Compare();
    IncrTmp := IncrTmp + 1;
    
    IF IncrTmp >= 4 THEN
        GotoNextField();
        IncrTmp := 0;
        GeneralMng.WritePwd := 1;
    ELSE 
        GotoRightDigit();
    END_IF;
END_FUNCTION

FUNCTION EscLogIn                     
    SetLedStatus(7,0);
    GotoMask(Main);
END_FUNCTION

FUNCTION DummyService                   //Function for Service masks, allow you to enter 
    IF PwdTyp = 2 OR PwdTyp = 3 THEN    //only if logged as service or manufacturer
        GotoNextField();
    ELSE
        StoreMask();
        SetLedStatus(7,2);
        Gotomask(InsertService);
    END_IF;
END_FUNCTION

FUNCTION DummyManuf                     //Function for Manufacturer masks, allow you to enter
    IF PwdTyp = 3 THEN                  //only if logged as manufacturer
        GotoNextField();
    ELSE
        StoreMask();
        SetLedStatus(7,2);
        Gotomask(InsertManuf);
    END_IF;
END_FUNCTION

FUNCTION DummyManufOnOff                     //Function for Manufacturer masks, allow you to enter
    IF PwdTyp = 3 AND NOT(UnitOn) THEN                  //only if logged as manufacturer and unit is OFF
        GotoNextField ();
    ELSIF PwdTyp = 3 AND UnitOn THEN
        StoreMask ();
        SetLedStatus (7,2);
        Gotomask (TurnOffUnit);
    ELSE
        StoreMask ();
        SetLedStatus (7,2);
        Gotomask (InsertManuf);
    END_IF;
END_FUNCTION

FUNCTION EscDummyService
    RestoreMask();
    SetLedStatus(7,0);
END_FUNCTION

FUNCTION EscDummyManuf
    RestoreMask();
    SetLedStatus(7,0);
END_FUNCTION

FUNCTION IncrDig
    IncrementDigit();
END_FUNCTION

FUNCTION DecrDig
    DecrementDigit();
END_FUNCTION

{#endregion}

// ------------------------------------------------------------- //
// ---               Import/Export parameters                --- //
// ------------------------------------------------------------- // 

FUNCTION ParamImpExp   //Selection of import/export paramenters function
    Compare();
    IF UnitOn AND EnImpExpTmp = 1 THEN
        SetLedStatus(7,2);
        Gotomask(ParamsImpExpErr);
        MaskPos := 2;
        EnImpExpTmp := 0;
    ELSIF EnImpExpTmp = 1 AND ImpExpSel = 0 THEN
        ImpExpMng.En_ParamsImp := 1;
        Gotomask(ParamsImpExpRes);
        EnImpExpTmp := 0;
    ELSIF EnImpExpTmp = 1 AND ImpExpSel = 1 THEN
        ImpExpMng.En_ParamsExp := 1;
        Gotomask(ParamsImpExpRes);
        EnImpExpTmp := 0;
    ELSE
        GotoNextField();
    END_IF;   
END_FUNCTION

// ------------------------------------------------------------- //
// ---                     Alarm Export                      --- //
// ------------------------------------------------------------- // 

FUNCTION AlrmExp   
    Compare();
    IF EnAlrmExpTmp = 1 THEN
        GeneralMng.En_AlrmExp := TRUE;
        Gotomask(AlrmExpRes);
        EnAlrmExpTmp := 0;
    ELSE
        GotoNextField();
    END_IF;
END_FUNCTION

// ------------------------------------------------------------- //
// ---                   Date/Hour change                    --- //
// ------------------------------------------------------------- // 

FUNCTION EnDateChg   //Enable for date/hour change
    GeneralMng.En_Date := 1;            
    Compare();
    GotoNextField();
END_FUNCTION

FUNCTION TZUp
    Increment_WORD();
    Compare();
END_FUNCTION

FUNCTION TZDwn
    Decrement_WORD();
    Compare();
END_FUNCTION

// ------------------------------------------------------------- //
// ---                 Unit OnOff Management                 --- //
// ------------------------------------------------------------- //

FUNCTION OnOffSwitch   //Unit onoff
    OnOffUnitMng.KeybOnOff := NOT(OnOffUnitMng.KeybOnOff);  
END_FUNCTION

// ------------------------------------------------------------- //
// ---                    Other functions                    --- //
// ------------------------------------------------------------- //

FUNCTION DoNothing
END_FUNCTION

FUNCTION WipeMem
    //Enable wipe retain memory
    IF En_WipeRetain THEN
        GeneralMng.WipeMem[1] := 1;
        En_WipeMem := TRUE;
    END_IF;
    //Enable wipe NVRAM memory
    IF En_WipeNVRAM THEN
        GeneralMng.WipeMem[1] := 2;
        En_WipeMem := TRUE;
    END_IF;    
    //Enable wipe retain+NVRAM memory
    IF En_WipeAll THEN
        GeneralMng.WipeMem[1] := 3;
        En_WipeMem := TRUE;
    END_IF;
    GotoNextField();
END_FUNCTION

FUNCTION SetTimeZone
    Compare();
    IF SetTimezoneTmp = 1 THEN
        GeneralMng.Zone_Write := TimeZoneTmp;
        GeneralMng.SetTimezone := TRUE;
        GeneralMng.ReadTimezone := TRUE;
        SetTimezoneTmp := 0;
    END_IF;
    GotoNextField();
END_FUNCTION

FUNCTION SetUoMZone_UI
    Compare();
    SetUoMZone (STD_UOM_ZONE_UI);
    GotoNextField ();
END_FUNCTION
