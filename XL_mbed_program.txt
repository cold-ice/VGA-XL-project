#include "mbed.h"

#include "RawSerial.h"
#include <I2C.h>

#define LSM6DS0_WRITE_ADD 0b11010110  // SCRIVO sull' LSM6DS0
#define LSM6DS0_READ_ADD 0b11010111   // LEGGO dall' LSM6DS0
#define CTRL_REG_1_G 0x10
#define CTRL_REG7_XL 0x21
#define OUT_Z_G_M 0x1d
#define OUT_Z_G_L 0x1c
#define OUT_Y_G_M 0x1b
#define OUT_Y_G_L 0x1a
#define OUT_X_G_M 0x19
#define OUT_X_G_L 0x18
#define OUT_Z_A_M 0x2d
#define OUT_Z_A_L 0x2c
#define OUT_Y_A_M 0x2b
#define OUT_Y_A_L 0x2a
#define OUT_X_A_M 0x29
#define OUT_X_A_L 0x28
#define N 9
#define M 3
#define L 2
#define h (double)0.0125  // h = 1/(40*2)


I2C i2c1(PB_9,PB_8);  //da datasheet nucleo F401RE -> setto il mio micro come master

//COMUNICAZIONE ESTERNA
Serial Serial2(PB_6,PA_10,9600);


void setup_accelerometro(char add,char val);
int16_t mult_read (char add1,char add2);
void trapezi_pos(void);
void shift_pos(void);
void SerialSend(void);

int16_t acc_compensata[N]; // [x1,y1,z1,x2,y2,z2,x3,y3,z3]
int16_t pos[M]; // pos[0]=x  pos[1]=y  pos[2]=z


int main() {
    
    int16_t out_acc_z =0;
    int16_t out_acc_y=0;
    int16_t out_acc_x=0;
    double out_giro_z=0;
    double out_giro_y=0;
    double out_giro_x=0;
    int count=0;
    char dato = 0x68;  // valore che scrivo nel registro CTRL_REG_1_G
    char filtro=0x85;  // valore che scrivo nel registro CTRL_REG7_XL 
    int prima_volta=0;
    
    
    // inizializzo il sensore
    setup_accelerometro( CTRL_REG_1_G ,dato);  
    setup_accelerometro( CTRL_REG7_XL ,filtro);
    
    
    while(1) 
    {
       
       if(prima_volta == 0)   //attendiamo un tempo pari a 1/fcutoff per essere sicuri che il filtro sia attivo appena preleviamo il primo campione
        {
            wait(0.42);
            prima_volta++;
        }
        else
        {
           
            wait(0.025);      // leggo un nuovo campione ogni 25ms (f=40Hz) in modo da avere un incremento, seppur minimo, di accelerazione
       
        // leggo valori dal sensore    
        out_acc_z =  mult_read (OUT_Z_A_M,OUT_Z_A_L);
        out_acc_y =  mult_read (OUT_Y_A_M,OUT_Y_A_L); 
        out_acc_x =  mult_read (OUT_X_A_M,OUT_X_A_L);
        out_giro_z =  mult_read (OUT_Z_G_M,OUT_Z_G_L);
        out_giro_y =  mult_read (OUT_Y_G_M,OUT_Y_G_L); 
        out_giro_x =  mult_read (OUT_X_G_M,OUT_X_G_L);
        
     
        
        // shifto i valori del vettore delle accelerazioni
        shift_pos ();
        
        
        
       
        // acquisisco i nuovi valori di accelerazioni, che sono automaticamente compensati dal filtro
        acc_compensata[6]= out_acc_x; // x   
        acc_compensata[7]= out_acc_y; // y
        acc_compensata[8]= out_acc_z; // z
        
       
        
        // calcolo per la prima volta la posizione solo dopo aver letto almeno tre campioni di accelerazioni
        if(count < 3)
        {
            count++;
        }
        else 
        {
         
          trapezi_pos();  // calcolo la nuova posizione (relativa alla precedente)
          
        }
        
        SerialSend();  // invio il frame tramite seriale
         
        
      }
        
    }
    
    
}

// il parametro add è l'indirizzo del registro da settare; il parametro val è il valore da scrivere nel registro
void setup_accelerometro(char add,char val)
{
    char address[L]= {add,0};
    char dato[L]={val,0};
    i2c1.write(LSM6DS0_WRITE_ADD, &address[0], 1,true);   
    i2c1.write(LSM6DS0_WRITE_ADD, &dato[0], 1,false);     
}


// i parametri add1 e add2 sono gli indirizzi dei registri di output (su 8 bit) relativi alla singola componente di accelerazione e velocità
int16_t mult_read (char add1,char add2)
{
    char address[L]= {add1,add2}; // add1->parte alta(MSB) dell'indirizzo e add2-> parte bassa(LSB)
    char buffer[L]={0,0};
    int16_t out;
    
    i2c1.write(LSM6DS0_WRITE_ADD, &address[0], 1,true); 
    i2c1.read(LSM6DS0_READ_ADD, &buffer[0], 1, false);
    i2c1.write(LSM6DS0_WRITE_ADD, &address[1], 1,true);
    i2c1.read(LSM6DS0_READ_ADD, &buffer[1], 1, false);
    out=(((int16_t)buffer[0]<<8)|(buffer[1]));
    return out;
}   







void trapezi_pos(void)
{
   
    for(int j=0;j<M;j++)
    {
      //v[0]=(acc_compensata[j]+acc_compensata[j+3])*h;
      //v[1]=(acc_compensata[j+3]+acc_compensata[j+6])*h;
      pos[j]=((acc_compensata[j+3]+acc_compensata[j+6])*h+(acc_compensata[j]+acc_compensata[j+3])*h)*h; // (v0 +v1)*h
     
    }
    
    
}

void shift_pos (void)  
 {
    
    for (int i=0; i<6; i++)
    {
        acc_compensata[i]= acc_compensata[i+3];
    }
    
 }
 
    
void SerialSend (void)
{
    
  uint8_t acc_out_8[6];
  uint8_t start = 0xff;
  uint8_t stop = 0x00;
  
  // divido la variabile su 16 bit in due da 8 poichè la seriale invia pacchetti da 8 bit di dato
  acc_out_8[0]=pos[0]>>8;   //MSB x
  acc_out_8[1]=pos[0];      //LSB x
  acc_out_8[2]=pos[1]>>8;   //MSB y
  acc_out_8[3]=pos[1];      //LSB y
  acc_out_8[4]=pos[2]>>8;   //MSB z
  acc_out_8[5]=pos[2];      //LSB z
  
  Serial2.printf("%c",start);
  Serial2.printf("%c",start);
  for(int i=0;i<6;i++)
    {
        Serial2.printf("%c",acc_out_8[i]);
    }
  Serial2.printf("%c",stop);
  Serial2.printf("%c",stop);
  
}  