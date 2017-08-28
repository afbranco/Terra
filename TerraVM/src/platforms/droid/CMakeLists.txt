cmake_minimum_required(VERSION 3.3)
project(NativeActivity)

# -> dirs
set(ANDROID_HOME "/home/mauricio/Android/Sdk")
set(BUILD_TOOLS "/home/mauricio/Android/Sdk/build-tools/26.0.1")
set(ANDROID_NDK "/home/mauricio/Android/Sdk/ndk-bundle")
set(TOOLCHAIN "/home/mauricio/Android/Sdk/ndk-bundle/standalone-toolchain-ARM")
set(JAVA_HOME "/home/mauricio/android-studio/jre")
# <-

# -> compiler depends on architecture, in this case we are building for ARM architecture
set(CC ${TOOLCHAIN}/bin/arm-linux-androideabi-gcc)
set(CXX ${TOOLCHAIN}/bin/arm-linux-androideabi-c++)
set(AR ${TOOLCHAIN}/bin/arm-linux-androideabi-ar)
set(CXX_FLAGS "")
set(CC_INCLUDES "${ANDROID_NDK}/sources/android/native_app_glue")
set(LOG_INCLUDES "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-24/arch-arm/usr/include/")
# <-

# -> architecture

# <-
set(BUILD_DIR "../../build/droid")
set(HOME_DIR ${CMAKE_CURRENT_SOURCE_DIR})

set(SOURCE_FILES_CPP
        )

set(SOURCE_FILES_H
        )


set(CMAKE_VERBOSE_MAKEFILE 0)

add_custom_target(createToolchain
	COMMAND ${ANDROID_NDK}/build/tools/make_standalone_toolchain.py --arch arm --api 24 --install-dir ${ANDROID_NDK}/standalone-toolchain-ARM
	COMMENT "Creating standalone toolchain for ARM architecture.")

add_custom_target(uninstall
    COMMAND ${ANDROID_HOME}/platform-tools/adb uninstall com.example.native_activity
    WORKING_DIRECTORY ${HOME_DIR}
    COMMENT "Unninstalling apk.")

add_custom_target(deploy
    COMMAND ${ANDROID_HOME}/platform-tools/adb install -r ${BUILD_DIR}/bin/NativeActivity.apk
    COMMAND ${ANDROID_HOME}/platform-tools/adb logcat -c
    COMMAND ${ANDROID_HOME}/platform-tools/adb logcat -s "terra"
    WORKING_DIRECTORY ${HOME_DIR}
    COMMENT "Deploying apk.")

add_custom_target(build
    DEPENDS bin/NativeActivity.apk
    WORKING_DIRECTORY ${HOME_DIR}
    COMMENT "Building apk.")

add_custom_target(dummy
    DEPENDS ${BUILD_DIR}/lib/armeabi-v7a/libnative-activity.so
    WORKING_DIRECTORY ${HOME_DIR}
    COMMENT "Doing dummy stuff.")


add_custom_command(OUTPUT bin/NativeActivity.apk
    COMMAND ${BUILD_TOOLS}/zipalign -f 4 bin/NativeActivity.signed.apk bin/NativeActivity.apk
    DEPENDS bin/NativeActivity.signed.apk
    WORKING_DIRECTORY ${BUILD_DIR}
    COMMENT "Creating bin/NativeActivity.apk.")

add_custom_command(OUTPUT bin/NativeActivity.signed.apk
    COMMAND ${JAVA_HOME}/bin/jarsigner -keystore ToyKey.keystore -storepass armena -keypass armena
    -signedjar ${BUILD_DIR}/bin/NativeActivity.signed.apk bin/NativeActivity.unsigned.apk NativeActivityKey
    DEPENDS bin/NativeActivity.unsigned.apk ToyKey.keystore
    WORKING_DIRECTORY ${BUILD_DIR}
    COMMENT "Creating bin/NativeActivity.signed.apk.")

add_custom_command(OUTPUT bin/NativeActivity.unsigned.apk
    COMMAND ${BUILD_TOOLS}/aapt package -f -M ${HOME_DIR}/AndroidManifest.xml -S ${HOME_DIR}/res
    -I ${ANDROID_HOME}/platforms/android-24/android.jar -F bin/NativeActivity.unsigned.apk bin
    COMMAND ${BUILD_TOOLS}/aapt add bin/NativeActivity.unsigned.apk lib/armeabi-v7a/libnative-activity.so
    DEPENDS bin/classes.dex lib/armeabi-v7a/libnative-activity.so
    WORKING_DIRECTORY ${BUILD_DIR}
    COMMENT "Creating bin/NativeActivity.unsigned.apk.")

add_custom_command(OUTPUT ${BUILD_DIR}/bin/classes.dex
	COMMAND mkdir -p bin
	COMMAND mkdir -p bin/classes
    COMMAND ${BUILD_TOOLS}/dx --dex --output=bin/classes.dex obj
    DEPENDS obj/com/example/native_activity/R.class
    WORKING_DIRECTORY ${BUILD_DIR}
    COMMENT "Creating bin/classes/dex.")

add_custom_command(OUTPUT ${BUILD_DIR}/obj/com/example/native_activity/R.class
	COMMAND mkdir -p obj
	COMMAND mkdir -p obj/com
	COMMAND mkdir -p obj/com/example
	COMMAND mkdir -p obj/com/example/native_activity
    COMMAND ${JAVA_HOME}/bin/javac -source 1.7 -target 1.7 -d obj -classpath ${ANDROID_HOME}/platforms/android-24/android.jar -sourcepath src src/com/example/native_activity/R.java
    DEPENDS src/com/example/native_activity/R.java
    WORKING_DIRECTORY ${BUILD_DIR}
    COMMENT "Creating obj/com/example/native_activity/R.class.")

add_custom_command(OUTPUT ${BUILD_DIR}/src/com/example/native_activity/R.java
	COMMAND mkdir -p ${BUILD_DIR}/src
	COMMAND mkdir -p ${BUILD_DIR}/src/com
	COMMAND mkdir -p ${BUILD_DIR}/src/com/example
	COMMAND mkdir -p ${BUILD_DIR}/src/com/example/native_activity
    COMMAND ${BUILD_TOOLS}/aapt package -f -m  -S res -J ${BUILD_DIR}/src -M AndroidManifest.xml -I ${ANDROID_HOME}/platforms/android-24/android.jar
    DEPENDS res/values/strings.xml
    WORKING_DIRECTORY ${HOME_DIR}
    COMMENT "Creating src/com/example/native_activity/R.java.")

add_custom_command(OUTPUT ToyKey.keystore
    COMMAND ${JAVA_HOME}/bin/keytool -genkeypair -validity 1000 -dname "CN=some company,O=Android,C=JPN" -keystore ToyKey.keystore
    -storepass armena -keypass armena -alias NativeActivityKey -keyalg RSA
    WORKING_DIRECTORY ${BUILD_DIR}
    COMMENT "Creating ToyKey.keystore.")

add_custom_command(OUTPUT jni/libnative_app_glue.a
	COMMAND mkdir -p jni
    COMMAND ${CC} -Wall -march=armv7-a -c ${ANDROID_NDK}/sources/android/native_app_glue/android_native_app_glue.c -o jni/native_app_glue.o
    COMMAND ${AR} rcs jni/libnative_app_glue.a jni/native_app_glue.o
    BYPRODUCTS jni/native_app_glue.o
    DEPENDS ${ANDROID_NDK}/sources/android/native_app_glue/android_native_app_glue.c
    WORKING_DIRECTORY ${BUILD_DIR}
    COMMENT "Creating native_app_glue static library.")

add_custom_command(OUTPUT lib/armeabi-v7a/libnative-activity.so 
	COMMAND ${CC} -Wall -I ${CC_INCLUDES} -march=armv7-a --sysroot=${TOOLCHAIN}/sysroot -fPIC -c app.c -o jni/main.o
	COMMAND ${CC} -Wall -I ${CC_INCLUDES} -I ${LOG_INCLUDES} -march=armv7-a -fPIC -c ${HOME_DIR}/dbg.c -o ${BUILD_DIR}/jni/dbg.o
	COMMAND ${CC} -Wall -I ${CC_INCLUDES} -march=armv7-a -fPIC -c ${HOME_DIR}/setTimer.c -o ${BUILD_DIR}/jni/setTimer.o
	COMMAND ${CC} -Wall -I ${CC_INCLUDES} -march=armv7-a -fPIC -c ${HOME_DIR}/ifaddrs.c -o ${BUILD_DIR}/jni/ifaddrs.o
	COMMAND ${CC} -Wall -I ${CC_INCLUDES} -march=armv7-a -fPIC -c ${HOME_DIR}/androidEvents.c -o ${BUILD_DIR}/jni/androidEvents.o
	COMMAND ${CXX} -Wall -I ${CC_INCLUDES} -march=armv7-a --sysroot=${TOOLCHAIN}/sysroot -std=gnu++11 -fPIC -c ${HOME_DIR}/androidGraphics.c -o jni/androidGraphics.o
	COMMAND mkdir -p lib
	COMMAND mkdir -p lib/armeabi-v7a
    COMMAND ${CXX} -I ${CC_INCLUDES} -L jni -shared  -Wl,--no-undefined -o lib/armeabi-v7a/libnative-activity.so jni/androidGraphics.o jni/androidEvents.o jni/ifaddrs.o jni/dbg.o jni/setTimer.o jni/main.o -llog -landroid -lnative_app_glue -lGLESv2 -lEGL -u ANativeActivity_onCreate
    BYPRODUCTS jni/main.o jni/dbg.o jni/setTimer.o
    DEPENDS ${BUILD_DIR}/app.c jni/libnative_app_glue.a
    WORKING_DIRECTORY ${BUILD_DIR}
    COMMENT "Creating c++ shared libraries.")
