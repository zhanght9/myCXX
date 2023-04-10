cmake_minimum_required(VERSION 3.5)

project(mymathlib VERSION 1.0
                  DESCRIPTION "my math lib"
                  LANGUAGES CXX)

add_library(${PROJECT_NAME} SHARED ${PROJECT_SOURCE_DIR}/src/calculator.cc)
target_include_directories(${PROJECT_NAME} PUBLIC ${PROJECT_SOURCE_DIR}/include)
