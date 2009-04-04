int bin[] = {0, 1, 10, 11, 100, 101, 110, 111};
int r0 = 0;  int r1 = 0;  int r2 = 0;
int t0 = 0;  int t1 = 0;  int t2 = 0;

int power_indicator = 13;
int row = 0;
int bpm = 120;
int row_1 = 0;
int row_2 = 1;
int row_3 = 3;
int tempo_pot = 2;
int tempo = 100;
int measure_count = 0;
int serial_midi = 31250;

void setup(){
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(7, OUTPUT);
  digitalWrite(power_indicator, HIGH);
  beginSerial(serial_midi);
  // turn off any existing notes
  //writeMidi(0x80, 0x00);
}

void loop () {
  
  // Read transposition
  if (measure_count == 8) measure_count = 0;
  row = bin[measure_count];
  t0 = row & 0x01;        t1 = (row>>1) & 0x01;    t2 = (row>>2) & 0x01;
  digitalWrite(5, t0);    digitalWrite(6, t1);     digitalWrite(7, t2);
  measure_count += 1;
  // Retrieve transposition pot value from multiplexer 4
  int transposition = 6 - (analogRead(row_3)/85);
  
  
  for (int count=0; count<8; count++) {
    tempo = analogRead(tempo_pot)/4;
    // bpm is milliseconds * measures * seconds
    // bpm = (tempo*2) * 4 * 60
    
    // Write data to multiplexers
    row = bin[count];
    r0 = row & 0x01;        r1 = (row>>1) & 0x01;    r2 = (row>>2) & 0x01;
    digitalWrite(2, r0);    digitalWrite(3, r1);     digitalWrite(4, r2);
    
    
    // Retrieve note pot value from multiplexer 1
    int note_to_be_played = (analogRead(row_2)/85)+45;
    if (note_to_be_played > 127) note_to_be_played = 127;
    note_to_be_played += transposition;
    
    // Retreive volume pot value from multiplexer 3 and adjust
    int volume_to_be_set = (analogRead(row_1)/12)+40;
    if (volume_to_be_set > 127) volume_to_be_set = 127;
    
    // Write information to MIDI
    writeVolume(volume_to_be_set);
    writeNote(note_to_be_played);
    delay(tempo);
    
    // Turn off note
    writeVolume(0);
    writeMidi(0x90, note_to_be_played, 0x00);
    delay(tempo/2);
  }
}

// Physically write data to MIDI out
void writeMidi(char cmd, char data1, char data2) {
  Serial.print(cmd, BYTE);
  Serial.print(data1, BYTE);
  Serial.print(data2, BYTE);
}

// Write a note value to output
void writeNote(int note) {
  writeMidi(0x90, note, 0x45);
}

// Adjust volume before playing note (velocity)
void writeVolume(int value) {
  writeMidi(0xB0, 0x07, value);
}

