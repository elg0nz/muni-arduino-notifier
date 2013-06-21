#include "Charliplexing.h"
#include "Myfont.h"

#include "Arduino.h"

const int BUFFER_SIZE = 140;
int leng=0;
int endChar = 0;
char serialBuffer[BUFFER_SIZE];
unsigned char* message;
unsigned char readyMsg[]="READY.";

void setup(){
  LedSign::Init();
  Serial.begin(9600);
  message = (unsigned char*)malloc(sizeof serialBuffer);
  leng = calculateLenght(readyMsg);
  Myfont::Banner(leng, readyMsg);
}

void clear_buffer(char *serialBuffer){
  for(int i=0; i < BUFFER_SIZE; i++){
    serialBuffer[i] = 0;
  }
}

int calculateLenght(unsigned char *message){
  int len = 0;
  for(int i=0; i < BUFFER_SIZE; i++){
      if(message[i]==endChar){
        len = i;
        break;
      }
   }
  return len;
}

void SerialPrint(int leng, unsigned char *message){
  for(int i=0; i < leng; i++){
     Serial.print((char) message[i]);
   }
}

void loop(){
  if (Serial.available()) {
    Serial.readBytesUntil(endChar, serialBuffer, BUFFER_SIZE);
    memcpy(message, serialBuffer, BUFFER_SIZE); // Copy serialBuffer to message.
    clear_buffer(serialBuffer);

    leng = calculateLenght(message);
    Myfont::Banner(leng, message);
    SerialPrint(leng, message);

    Serial.flush();
    free(message);
  }
}
