/******************************************************************************
 * @file    pindefs.hpp
 * @project Arduino EEPROM Programmer
 * @brief   Defines pinout names
 * @author  ImpendingMoon
 * @date    2024-04-27
 ******************************************************************************/

#ifndef ARDUINO_COMPONENT_MOCKER_PINDEFS_HPP
#define ARDUINO_COMPONENT_MOCKER_PINDEFS_HPP

#define ROM_CEB     53
#define ROM_OEB     51
#define ROM_WEB     49

enum DATA_BUS_PINS
{
    D0 = 23,
    D1 = 25,
    D2 = 27,
    D3 = 29,
    D4 = 31,
    D5 = 33,
    D6 = 35,
    D7 = 37
};

enum ADDRESS_BUS_PINS
{
    AD0 = 22,
    AD1 = 24,
    AD2 = 26,
    AD3 = 28,
    AD4 = 30,
    AD5 = 32,
    AD6 = 34,
    AD7 = 36,
    AD8 = 38,
    AD9 = 40,
    AD10 = 42,
    AD11 = 44,
    AD12 = 46,
    AD13 = 48,
    AD14 = 50,
};

#endif //ARDUINO_COMPONENT_MOCKER_PINDEFS_HPP
