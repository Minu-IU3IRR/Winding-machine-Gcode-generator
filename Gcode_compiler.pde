 //<>//

//--------------------------------------------------------- Gcode_compiler
//comment
String comment( String txt ) {
  return "   (" + txt + ")";
}

//movement compile macros
String linear_rel_move( float x, float y ) {
  return "G01 X" + str(x) + " Y" + str(y) + " F" + str(speed);
}

String linear_abs_move( float x, float y) {
  return "G01 X" + str( mode_rel_posX + x) + " Y" + str(mode_rel_posY + y) + " F" + str(speed);
}

void G_command(String command, String comment) {
  if (comment != "")outputAppend(command + comment(comment));
  else outputAppend(command);
}

void G_move(float X_move, float Y_move, float layer, String comment) {
  if ( layer % 2 != 0) X_move = -X_move; //if odd layer invert guide direction
  
  if(invert_guide_direction) X_move = -X_move;
  if(invert_spindle_direction) Y_move = -Y_move;
  
  if (comment != "")outputAppend(linear_rel_move(X_move, Y_move) + comment(comment));
  else outputAppend(linear_rel_move(X_move, Y_move));
}

void G_blankLine() {
  outputAppend("");
}

void G_comment(String txt) {
  outputAppend(comment(txt));
}

//error during compile macro
void throwError( String comment ) {
  println("ERRORE: " + comment );
  exit();
}

//machine config compiler
void machine_configs() { 
  G_command(COMMAND_ENABLE_STEPPERS, "motori sempre attivi");
  G_command(COMMAND_X_STEP_MM, "step/mm guida");
  G_command(COMMAND_Y_STEP_MM, "step/rev mandrino");
  G_command(COMMAND_X_MAX_FEED, "max x feed rate");
  G_command(COMMAND_Y_MAX_FEED, "max y feed rate");
  G_command(COMMAND_X_MAX_ACCEL, "accelerazione max guida");
  G_command(COMMAND_MAX_Y_ACCEL, "accelerazione max mandrino ");
  G_command(COMMAND_SOFT_LIMIT_STATE, "disabilita finecorsa software");
  G_blankLine();
  G_command(COMMAND_POS_MODE, "abs(G90)-rel(G91) modalità");
  G_blankLine();
}


//--------------------------------------------------------- work parameters calc and enviroment variables
//-> calculate work parameters

float turns_perLayer = bobin_length / wire_diameter;
float layers_total = turns / turns_perLayer;
float speed_rpm = speed * 60;

// enviroment variables
int current_pause = 0;//turn pause counter
boolean turn_pause_done = false; //becomes true if there are no more turn pauses to schedule

//--------------------------------------------------------- functions

void user_input_check() {

  if ( enable_turn_pause && pause_at_turn.length == 0) throwError("turn pause enabled but no pauses are listed!");

  if ( !enable_turn_pause && pause_at_turn.length != 0) throwError("turn pause disabled but pauses are listed!");

  int precedent_pause_check = 0;
  for ( int i = 0; i < pause_at_turn.length; i++) { // check every listed pause

    // input check: are listed turn pauses in the work limits?
    if ( pause_at_turn[i] <= 0 ) {
      throwError("pausa a spira " + pause_at_turn[i] + " < 0" );                                      // check for turn pause below zero
      break;
    } else if (pause_at_turn[i] >= turns ) {
      throwError("pausa a spira " + pause_at_turn[i] + " above total turns");                // check for turn pause above total turns
      break;
    } else if (precedent_pause_check > pause_at_turn[i]) {
      throwError("le pause a spira non sono ordinate in modo crescente, spira " + pause_at_turn[i] + " dovrebbe essere inserita prima della spira " + pause_at_turn[i-1] ); // check if pauses are sequential  
      break;
    } else if ( precedent_pause_check == pause_at_turn[i]) {
      throwError("piu pause specificate per la spira " + pause_at_turn[i] +" , indicare solo una volta per paisa");
      break;
    } else precedent_pause_check = pause_at_turn[i];
  }
}


void compile() { // main function

  //start cycle
  //---------------------------- comment work params
  G_blankLine();
  //comment work parameters
  G_comment("        turns: " + turns);
  G_comment(" bobin length: " + bobin_length + " mm");
  G_comment("wire diameter: " + wire_diameter + " mm");
  G_comment("winding speed: " + speed + " turns/s");
  G_comment("---------------------------");

  //comment if pause @ turn is enabled
  if (enable_turn_pause) {
    G_comment("turn pause enabled @");                                                                         

    for ( int i  =0; i < pause_at_turn.length; i++) { // list all pauses
      G_comment("-" + pause_at_turn[i]);
    }
  }
  G_comment("---------------------------");

  //comment if pause between layers is enabled
  if (pause_between_layers) G_comment("pause between layers enabled");
  else G_comment("pause between layers disabled");

  G_comment("---------------------------");
  G_blankLine();
  G_blankLine();


  //---------------------------- apply machine configs
  machine_configs();


  //---------------------------- winding process

  for ( int layer = 0; layer <= layers_total; layer++) {

    //calculate layer properties
    float start_layer_turns = layer * turns_perLayer;
    float end_layer_turns = start_layer_turns + turns_perLayer;

    // is a turn pause in this layer?
    if ( enable_turn_pause && !turn_pause_done && isBetween(pause_at_turn[constrain(current_pause, 0, pause_at_turn.length -1)], start_layer_turns, end_layer_turns)) { //if turn pause is enabled and  there are still pauses to be done check

      //partial layer routine
      boolean layer_schedule_complete = false;
      while (!layer_schedule_complete) {

        float turns_to_do = pause_at_turn[current_pause] - start_layer_turns;
        float guide_movement = turns_to_do * wire_diameter; //<>//

        G_move(guide_movement, turns_to_do, layer, "" );
        G_command(COMMAND_PROGRAM_PAUSE, "pause at turn " + pause_at_turn[current_pause] );

        if (current_pause == (pause_at_turn.length-1)) { //check if this is the last pause listed
          turn_pause_done = true;
          break;
        }

        if (isBetween( pause_at_turn[current_pause +1], start_layer_turns, end_layer_turns)) { //check if next pause is  within this layer
          layer_schedule_complete = false;
        } else {
          layer_schedule_complete = true;
        }

        current_pause++;
      }

      //complete the layer
      float remaning_turns = end_layer_turns - pause_at_turn[current_pause -1]; // last pause to end of layer
      float remaning_guide_movement = remaning_turns * wire_diameter;
 //<>//
      G_move(remaning_guide_movement, remaning_turns, layer, "complete layer " + layer);
    } else { //full layer

      //calculate parameters
      float guide_movement = turns_perLayer * wire_diameter;

      if ( layer != floor(layers_total) ) G_move(guide_movement, turns_perLayer, layer, "layer " + (layer +1)); 
      else {
        //last layer
        float remaning_turns = turns - turns_perLayer * layer;
        float remaning_guide_movement = remaning_turns * wire_diameter;

        G_move(remaning_guide_movement, remaning_turns, layer, "layer " + (layer -1));
      }
    }


    //---------------------------- layer pause
    if (pause_between_layers) G_command(COMMAND_PROGRAM_PAUSE, "layer pause");
    
  }

  //---------------------------- end of cycle
  G_blankLine();
  G_command(COMMAND_PROGRAM_END_NO_RESET, "reset" );
}




//-------------------------------------------------------------------------- other comands

boolean isBetween( float i, float a, float b) { //returns trie if i is in the range of a and b
  if ( a <= b ) {
    if ( i >= a && i <= b ) return true;
    else return false;
  } else {
    if ( i >= b && i <= a ) return true;
    else return false;
  }
}
