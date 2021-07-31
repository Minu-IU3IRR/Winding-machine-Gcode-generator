


//NOTA : LEGGERE LE ISTRUZIONI ALLA PAGINA ISTRUZIONI
//tutto il necessario per utilizzare il softwtware è descritto, non è necessario modificare altre schede



//-----------------------------------------------------------------------------
//work setup parameters
int   turns         = 1000; //totale spire      
float bobin_length  = 30;   //lunghezza della bobina in mm
float wire_diameter = 0.33; //diametro del cavo in mm
float speed         = 30;   //velocità in spire/minuto


boolean enable_turn_pause = false;        //abilita pause a spire
int pause_at_turn[] = {};                 //lista pause scheulate

boolean pause_between_layers = true;      // pausa a ogni strato ( per applicare isolamento )

boolean invert_guide_direction = true;    // inverti direzione guida ( nel caso di bobine con refori contraspposti )
boolean invert_spindle_direction = false; // inverti direzione di bobinatura

//------------------------------------------------------------------------------


void setup() {
  user_input_check(); // check user input 

  start_select_output_file();//initiate output file exporter
}

void draw() {
  if ( file_path != null) { //wait for file to be selected

    create_file_writer(); // start the file generator
    compile();            // start compiler

    close_file_writer();//finish

    exit(); // exit the program
  }
}
