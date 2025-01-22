/******************************************************************************
 * @file    main.hpp
 * @project Arduino EEPROM Programmer
 * @brief   Programs an AT28 EEPROM through an Arduino Mega 2560
 * @author  ImpendingMoon
 * @date    2024-04-27
 ******************************************************************************/

#ifndef ARDUINO_EEPROM_PROGRAMMER_MAIN_HPP
#define ARDUINO_EEPROM_PROGRAMMER_MAIN_HPP

#include <Arduino.h>

/**
 * @brief Initializes the pins and requests bus access from the CPU
 */
void initializePins();

/**
 * @brief Places an address on the system address bus
 * @param address
 */
void setAddressBus(uint16_t address);

/**
 * @brief Reads a byte from the EEPROM at a given address
 * @param address
 * @return uint8_t
 */
uint8_t readByte(uint16_t address);

/**
 * @brief Writes a byte to the EEPROM at a given address
 * @param address
 * @param value
 */
void writeByte(uint16_t address, uint8_t value);

/**
 * @brief Writes the full DATA array to the EEPROM, starting at address $0000
 */
void writeBinary();

/**
 * @brief Reads and compares the EEPROM's data with the DATA array.
 * @return True if successfully verified, false if failed
 */
bool verifyBinary();

/**
 * @brief Disables the EEPROM's software write lock, if enabled
 */
void disableSoftwareLock();

#endif //ARDUINO_EEPROM_PROGRAMMER_MAIN_HPP
