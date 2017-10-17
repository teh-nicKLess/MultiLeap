cmake_minimum_required(VERSION 2.8)
project(exposeImages)

set(leapSDKdir ${CMAKE_CURRENT_SOURCE_DIR}/LeapSDK)
include_directories(${leapSDKdir}/include)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  link_directories(${leapSDKdir}/lib/x64)
else()
  link_directories(${leapSDKdir}/lib/x86)
endif()

add_executable(exposeImages main.cpp)
target_link_libraries(exposeImages Leap)
