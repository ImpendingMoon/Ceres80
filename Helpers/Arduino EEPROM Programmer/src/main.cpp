/******************************************************************************
 * @file    main.cpp
 * @project Arduino EEPROM Programmer
 * @brief   Programs an AT28 EEPROM through an Arduino Mega 2560
 * @author  ImpendingMoon
 * @date    2024-04-27
 ******************************************************************************/

#include <Arduino.h>
#include "main.hpp"
#include "pindefs.hpp"
#include "data.hpp"

#define ROM_SIZE 0x2000

#ifdef __AVR_ATmega2560__
  const byte CLOCKOUT = 11;  // Mega 2560
#else
  const byte CLOCKOUT = 9;   // Uno, Duemilanove, etc.
#endif

void setup()
{
    // Clock output for rapid switching between programmer and system
    pinMode (CLOCKOUT, OUTPUT); 
    TCCR1A = bit (COM1A0);
    TCCR1B = bit (WGM12) | bit (CS10);
    OCR1A = 1;



    Serial.begin(9600);
    Serial.print("Initializing Pins.\n");
    initializePins();

    // AT28C models are locked for 5ms after power on
    delay(10);

    disableSoftwareLock();

    Serial.print("Writing EEPROM.\n");
    writeBinary();

    Serial.print("\nWrite successful. Verifying.\n");
    bool isVerified = true;
    
    for(int i = 0; i < 3; i++)
    {
        isVerified = verifyBinary();
        if(!isVerified) { break; }
        Serial.print("\n\n");
    }
    

    if(isVerified)
    {
        Serial.print("\nROM verified.");
    } else
    {
        Serial.print("\nVerification failed!");
    }
}

void loop()
{}



/**
 * @brief Initializes the pins and requests bus access from the CPU
 */
void initializePins()
{

    pinMode(ROM_CEB, OUTPUT);
    pinMode(ROM_WEB, OUTPUT);
    pinMode(ROM_OEB, OUTPUT);

    digitalWrite(ROM_CEB, HIGH);
    digitalWrite(ROM_WEB, HIGH);
    digitalWrite(ROM_OEB, HIGH);

    for(int pin = 22; pin <=53; pin++)
    {
        pinMode(pin, OUTPUT);
    }
}



/**
 * @brief Places an address on the system address bus
 * @param address
 */
void setAddressBus(uint16_t address)
{
    uint8_t i = 0;
    // Address pins are physically interlaced
    for(uint8_t pin = AD0; pin <= AD14; pin += 2)
    {
        digitalWrite(pin, (address >> i) & 1);
        i++;
    }
}



/**
 * @brief Reads a byte from the EEPROM at a given address
 * @param address
 * @return uint8_t
 */
uint8_t readByte(uint16_t address)
{
    uint8_t value = 0, i = 0;
    setAddressBus(address);

    // Set data bus state
    for(uint8_t pin = D0; pin <= D7; pin += 2)
    {
        pinMode(pin, INPUT);
    }

    // Enable ROM Output
    digitalWrite(ROM_WEB, HIGH);
    digitalWrite(ROM_OEB, LOW);
    digitalWrite(ROM_CEB, LOW);

    // Wait for ROM to respond
    delayMicroseconds(1);

    // Read data bus
    for(uint8_t pin = D0; pin <= D7; pin += 2)
    {
        value |= (digitalRead(pin) << i);
        i++;
    }

    // Disable ROM
    digitalWrite(ROM_CEB, HIGH);
    digitalWrite(ROM_OEB, HIGH);

    return value;
}



/**
 * @brief Writes a byte to the EEPROM at a given address
 * @param address
 * @param value
 */
void writeByte(uint16_t address, uint8_t value)
{
    uint8_t i = 0;
    setAddressBus(address);

    // Set data bus state
    for(uint8_t pin = D0; pin <= D7; pin += 2)
    {
        pinMode(pin, OUTPUT);
    }

    // Load value into data bus
    for(uint8_t pin = D0; pin <= D7; pin += 2)
    {
        digitalWrite(pin, (value >> i) & 1);
        i++;
    }

    // Enable ROM
    digitalWrite(ROM_OEB, HIGH);
    digitalWrite(ROM_WEB, LOW);
    digitalWrite(ROM_CEB, LOW);

    
    // Wait for write to finish
    asm volatile("nop\nnop\nnop"); // ~180ns delay


    // Disable ROM
    digitalWrite(ROM_CEB, HIGH);
    digitalWrite(ROM_WEB, HIGH);

    // Set pins back to high-impedance input
    for(uint8_t pin = D0; pin <= D7; pin += 2)
    {
        pinMode(pin, INPUT);
    }

    // Wait for ROM to refresh
    delay(10);
}



/**
 * @brief Writes the full DATA array to the EEPROM, starting at address $0000
 */
void writeBinary()
{
    static_assert(DATA_SIZE <= ROM_SIZE, "Binary image too large!");

    for(uint16_t i = 0; i < DATA_SIZE; i++)
    {
        writeByte(i, pgm_read_byte_near(DATA + i));

        // Progress dots
        if(i != 0)
        {
            if(i % 32 == 0) { Serial.print('.'); }
            if(i % (32 * 32) == 0) { Serial.print('\n'); }
        }
    }
}



/**
 * @brief Reads and compares the EEPROM's data with the DATA array.
 * @return True if successfully verified, false if failed
 */
bool verifyBinary()
{
    bool isVerified = true;

    for(uint16_t i = 0; i < DATA_SIZE; i++)
    {
        uint8_t rom_value = readByte(i);
        if(rom_value != pgm_read_byte_near(DATA + i))
        {
            isVerified = false;

            Serial.print("\nData mismatch at $");
            Serial.print(i, HEX);
            Serial.print("! Expected: 0x");
            Serial.print(pgm_read_byte_near(DATA + i), HEX);
            Serial.print(" Received: 0x");
            Serial.print(rom_value, HEX);
            Serial.print(".\n");

            break;
        }

        // Progress dots
        if(i != 0)
        {
            if(i % 32 == 0) { Serial.print('.'); }
            if(i % (32 * 32) == 0) { Serial.print('\n'); }
        }
    }

    return isVerified;
}



/**
 * @brief Disables the EEPROM's software write lock, if enabled
 */
void disableSoftwareLock()
{
    // From AT28C64B datasheet
    writeByte(0x1555, 0xAA);
    writeByte(0x0AAA, 0x55);
    writeByte(0x1555, 0x80);
    writeByte(0x1555, 0xAA);
    writeByte(0x0AAA, 0x55);
    writeByte(0x1555, 0x20);

    // Wait for page write cycle to end
    delay(10);
}
