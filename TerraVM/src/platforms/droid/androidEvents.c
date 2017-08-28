/*
  	Terra IoT System - A small Virtual Machine and Reactive Language for IoT applications.
  	Copyright (C) 2014-2017  Mauricio Pedro Vieira
	
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

#include <android_native_app_glue.h>
#include "androidEvents.h"

#include <EGL/egl.h>
#include <GLES/gl.h>
#include "androidGraphics.h"

#include <android/sensor.h>
#include <android/log.h>

#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, "terra", __VA_ARGS__))

void  androidTouchEvent(uint16_t posX, uint16_t posY);

struct engine engine;

static void engine_handle_cmd(struct android_app* app, int32_t cmd) {
    struct engine* userData = (struct engine*)app->userData;
    switch (cmd) {
        case APP_CMD_INIT_WINDOW:
			LOGI("**** Janela Comecou, inicializando Display ****");
			androidEngineInitDisplay(userData);
			androidEngineDrawFrame(userData, 1.0f, 0.54901f, 0.0f);
            break;
    }
}

static int32_t engine_handle_input(struct android_app* app, AInputEvent* event) {
	uint16_t posX, posY;
	float originalX, originalY;
	LOGI("******* Processando INPUT ********");
	if (AInputEvent_getType(event) == AINPUT_EVENT_TYPE_MOTION) {
		originalX = AMotionEvent_getX(event,0);
		originalY = AMotionEvent_getY(event,0);
		posX = (uint16_t) 1000*originalX;
		posY = (uint16_t) 1000*originalY;
		androidTouchEvent(posX, posY);
	}
	return 0;
}

void androidInitEvent(struct android_app* state) {
	memset(&engine, 0, sizeof(engine));
	state->userData = &engine;
	state->onAppCmd = engine_handle_cmd;
    state->onInputEvent = engine_handle_input;
	engine.app = state;
	LOGI("Inicializando a engine para eventos");
}


void androidCheckEvent() {
	int events;	
    struct android_poll_source* source;

	LOGI("Android esta checando eventos");
	
	ALooper_pollAll(0.5, NULL, &events, (void**)&source);

	if (source != NULL) { source->process(engine.app, source); }
}
