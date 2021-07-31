

//----------------------------------------------------------------- mechanical configs
//machine parameters

float motor_step_rev = 200; //step/rev motori

//mechanicl advantages
float spindle_MA = float(45)/float(15); //vantaggio meccanico trasmissione mandrino = denti seconda ruota / denti prima ruota
float spindle_uStep = 16;               //microstepping impostato con i jumper sui driver

float guide_MA = float(1)/8;  //vantaggio meccanico guida = 1 rotazione / 8mm di spostamento
float guide_uStep = 16;       //microstepping impostato con i jumper sui driver

float max_x_feed = 10000;     // massima feed rate guida (mm/s)
float max_y_feed = 100;       // massima feed rate mandrino (rotazione/s)
float max_x_accel = 100;      // massima accelerazione guida (mm/s^2)
float max_y_accel = 2;        // massima accelerazione mandrino (rotazione/s^2)
int enable_soft_limits = 0;   // disabilita limiti software
int stepper_idle_delay = 255; // 255 significa motori sempre attivi (per nn perdere la posizione)



//---------------------------------------------------------------- firmware configuration

//calculate work parameters
float x_step_mm = motor_step_rev * guide_uStep * guide_MA;                       
String COMMAND_X_STEP_MM  = "$100=" + str(int(x_step_mm));


float y_step_rev = motor_step_rev * spindle_uStep * spindle_MA;    //step_revolution allow to compute in turns
float y_step_mm = y_step_rev;
String COMMAND_Y_STEP_MM  ="$101=" + str(int(y_step_mm));

//------ positioning commands and macros

String COMMAND_ABS_POS = "G90";
String COMMAND_REL_POS = "G91";
float mode_rel_posX = 0, mode_rel_posY = 0; //machine position store for realtiva mode

String COMMAND_POS_MODE = COMMAND_REL_POS;

//------ systemaconfig  
String COMMAND_X_MAX_FEED = "$110=" + str( int(max_x_feed));

String COMMAND_Y_MAX_FEED = "$111=" + str( int(max_y_feed));

String COMMAND_X_MAX_ACCEL = "$120=" + str( int(max_x_accel));

String COMMAND_MAX_Y_ACCEL = "$121=" + str( int(max_y_accel));

String COMMAND_SOFT_LIMIT_STATE = "$20=" + enable_soft_limits; //must be disabled

String COMMAND_ENABLE_STEPPERS = "$1=" + stepper_idle_delay;


//------ misc commands

String COMMAND_PROGRAM_END_NO_RESET = "M02";

String COMMAND_PROGRAM_PAUSE = "M0";
