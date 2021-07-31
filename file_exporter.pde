
//--------------------------------------------------------- output file generator

PrintWriter output;
String  file_path;
boolean output_selected = false;
String fileExtension = ".gcode";


void selectionFunction( File selected ) { // file selector 
  if (selected == null ) {
    print("nessun file selezionato");
    exit();
  } else {
    file_path = selected.getAbsolutePath() + fileExtension;
    println("file generato: " + file_path);
    output_selected = true;
  }
}


void start_select_output_file() {
  selectOutput("Save as ->", "selectionFunction"); //select output file path
}


void create_file_writer() {
  output = createWriter(file_path);
}

void close_file_writer() {
  output.flush();
  output.close();

  println("Gcode generato!");
}

void outputAppend(String txt) { // add code line ot output file
  output.println(txt);
}
