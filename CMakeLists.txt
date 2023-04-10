cmake_minimum_required(VERSION 3.5)

project(main VERSION 1.0
                  DESCRIPTION "main function"
                  LANGUAGES CXX)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
add_executable(${PROJECT_NAME} src/main.cc)
add_subdirectory(${PROJECT_SOURCE_DIR}/extern/math)
target_link_libraries(${PROJECT_NAME} PUBLIC mymathlib)
install()
