# COMP-426 A3: Multicore Implementation of 2D Bouncing Balls Simulation on the GPU

Name: Denis Oh

Student ID: 40208580

![BouncingBallsDemo](https://github.com/user-attachments/assets/7398048c-47db-49b0-816c-f88c7a9f2b1f)

#### How to run: (from project directory)
- `mkdir build`
- `cd build`
- `cmake ..`
- `make`
- `./BouncingBalls`

## Introduction:
This 2D bouncing balls simulation uses Intel Threading Building Blocks (TBB) to leverage multicore processing. The simulation consists of several coloured balls moving and bouncing within a window, affected by gravity and interacting with each other upon collision. The simulation was redesigned from Assignment 1 to use TBB constructs for improved parallelism and efficiency.

## Design and Optimization:

### TBB Integration:
Concurrent vector: The std::vector from Assignment 1 has been replaced with tbb::concurrent_vector. This allows for safe parallel access and modification without the need for explicit locking, improving performance in multi-threaded scenarios.

Parallel Execution: Instead of individual threads for each ball, we now use tbb::parallel_for to update all balls concurrently. This approach divides the work of updating balls among available threads, potentially utilizing all available CPU cores more efficiently.

### Control Thread Implementation:
The control thread function manages the main simulation loop, including updating ball positions, rendering, and maintaining the frame rate. It uses a tbb::task_group to run the parallel ball updates:

### Gravity and Motion:
A constant gravitational force is applied to each ball's vertical velocity (vy) during each update, simulating the effect of gravity pulling the balls downward.

Each ball's position (x, y) is updated based on its current velocity (vx, vy) to reflect its movement across the screen.

### Handling Collisions:
Wall Collisions: The simulation detects when a ball reaches the window's boundaries and reflects its velocity to simulate bouncing.

Ball-to-Ball Collisions: When two balls collide, their x and y velocities are re-calculated. The change in velocity is calculated based on the relative velocity and the collision vector between the two balls.

### Rendering with OpenGL:
The rendering process using OpenGL remains largely unchanged from Assignment 1. The balls on screen are rendered with the OpenGL library. The drawBall function draws each ball as a fan of triangles with OpenGL's GL_TRIANGLE_FAN. The result resembles a circle.

## Conclusion:
By transitioning from standard C++ threads to Intel TBB, we've created a more scalable and efficient implementation of the 2D bouncing balls simulation. The use of TBB's concurrent data structures and parallel algorithms allows for better utilization of multi-core processors, while the control thread ensures proper synchronization and timing of the simulation updates and rendering.
