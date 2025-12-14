cmake_minimum_required(VERSION 4.2.0)
project(crs)
set(CMAKE_C_STANDARD 99)

set(BUILD_SHARED_LIBS ON)

# Game Build
add_library(
  crs
  crs.c)


