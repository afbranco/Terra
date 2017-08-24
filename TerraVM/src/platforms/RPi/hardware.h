/*
  	Terra IoT System - A small Virtual Machine and Reactive Language for IoT applications.
  	Copyright (C) 2014-2017  Adriano Branco
	
	This file is part of Terra IoT.
	
	Terra IoT is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Terra IoT is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Terra IoT.  If not, see <http://www.gnu.org/licenses/>.  
*/  
#ifndef HARDWARE_H
#define HARDWARE_H
inline void __nesc_enable_interrupt() { }
inline void __nesc_disable_interrupt() { }

typedef uint8_t __nesc_atomic_t;
typedef uint8_t mcu_power_t;

inline __nesc_atomic_t __nesc_atomic_start(void) @spontaneous() {
  return 0;
}

inline void __nesc_atomic_end(__nesc_atomic_t x) @spontaneous() { }
inline void __nesc_atomic_sleep() { }

/* Floating-point network-type support */
typedef float nx_float __attribute__((nx_base_be(afloat)));

inline float __nesc_ntoh_afloat(const void *COUNT(sizeof(float)) source) @safe() {
  float f;
  memcpy(&f, source, sizeof(float));
  return f;
}

inline float __nesc_hton_afloat(void *COUNT(sizeof(float)) target, float value) @safe() {
  memcpy(target, &value, sizeof(float));
  return value;
}

// enum so components can override power saving,
// as per TEP 112.
// As this is not a real platform, just set it to 0.
enum {
  TOS_SLEEP_NONE = 0,
};


#endif
