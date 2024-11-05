cmake_minimum_required(VERSION 3.10)
project(BouncingBallsSimulation)

set(CMAKE_CXX_STANDARD 11)

# Set TBB paths explicitly
set(TBB_DIR "/opt/homebrew/opt/tbb")
set(TBB_INCLUDE_DIRS "${TBB_DIR}/include")
set(TBB_LIBRARIES "${TBB_DIR}/lib/libtbb.dylib")

# Add the source files
add_executable(BouncingBalls main.cpp)

# Include GLFW
include_directories(/opt/homebrew/opt/glfw/include)
find_library(GLFW_LIBRARY glfw PATHS /opt/homebrew/opt/glfw/lib)
target_link_libraries(BouncingBalls ${GLFW_LIBRARY})

# Include OpenGL
find_library(OpenGL_LIBRARY OpenGL)
target_link_libraries(BouncingBalls ${OpenGL_LIBRARY})

# Include and link TBB
include_directories(${TBB_INCLUDE_DIRS})
target_link_libraries(BouncingBalls ${TBB_LIBRARIES})

# Print TBB paths for debugging
message(STATUS "TBB_INCLUDE_DIRS: ${TBB_INCLUDE_DIRS}")
message(STATUS "TBB_LIBRARIES: ${TBB_LIBRARIES}")