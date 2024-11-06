#define THREADS_PER_BALL 32
#define LOCAL_SIZE 256

__kernel void updateBalls(
    __global float4* positions,
    __global float4* velocities,
    __global float4* colors,
    const int numBalls,
    const float gravity,
    const float windowWidth,
    const float windowHeight
) {
    __local float4 local_pos[16];   // Local storage for positions
    __local float4 local_vel[16];   // Local storage for velocities
    
    int global_id = get_global_id(0);
    int local_id = get_local_id(0);
    int ball_idx = global_id / THREADS_PER_BALL;
    int thread_idx = global_id % THREADS_PER_BALL;
    
    if (ball_idx >= numBalls) return;
    
    // Load ball data into local memory
    if (thread_idx == 0) {
        local_pos[ball_idx] = positions[ball_idx];
        local_vel[ball_idx] = velocities[ball_idx];
    }
    barrier(CLK_LOCAL_MEM_FENCE);
    
    // Get local copy of ball data
    float4 pos = local_pos[ball_idx];
    float4 vel = local_vel[ball_idx];
    
    // Update position and apply gravity - only one thread per ball
    if (thread_idx == 0) {
        vel.y += gravity;
        pos.x += vel.x;
        pos.y += vel.y;
        
        // Handle boundary collisions
        if (pos.x - pos.z < 0) {
            pos.x = pos.z;
            vel.x = -vel.x * 0.95f;
        }
        if (pos.x + pos.z > windowWidth) {
            pos.x = windowWidth - pos.z;
            vel.x = -vel.x * 0.95f;
        }
        if (pos.y - pos.z < 0) {
            pos.y = pos.z;
            vel.y = -vel.y * 0.95f;
        }
        if (pos.y + pos.z > windowHeight) {
            pos.y = windowHeight - pos.z;
            vel.y = -vel.y * 0.95f;
        }
        
        // Update local memory
        local_pos[ball_idx] = pos;
        local_vel[ball_idx] = vel;
    }
    barrier(CLK_LOCAL_MEM_FENCE);
    
    // Parallel collision detection
    if (thread_idx < numBalls) {
        int other_idx = thread_idx;
        if (other_idx != ball_idx) {
            float4 other_pos = local_pos[other_idx];
            float4 other_vel = local_vel[other_idx];
            
            float dx = other_pos.x - pos.x;
            float dy = other_pos.y - pos.y;
            float distance = sqrt(dx * dx + dy * dy);
            float minDist = pos.z + other_pos.z;
            
            if (distance < minDist && distance > 0.0f) {
                float nx = dx / distance;
                float ny = dy / distance;
                
                float overlap = minDist - distance;
                pos.x -= nx * overlap * 0.5f;
                pos.y -= ny * overlap * 0.5f;
                
                float rvx = other_vel.x - vel.x;
                float rvy = other_vel.y - vel.y;
                float velAlongNormal = rvx * nx + rvy * ny;
                
                if (velAlongNormal < 0) {
                    float restitution = 0.8f;
                    float j = -(1.0f + restitution) * velAlongNormal;
                    j /= 2.0f;
                    
                    vel.x -= j * nx;
                    vel.y -= j * ny;
                }
            }
        }
    }
    barrier(CLK_LOCAL_MEM_FENCE);
    
    // Write back results - only first thread per ball
    if (thread_idx == 0) {
        float4 final_pos = pos;
        float4 final_vel = vel;
        
        // Apply velocity limits
        float maxSpeed = 10.0f;
        float speedSq = final_vel.x * final_vel.x + final_vel.y * final_vel.y;
        if (speedSq > maxSpeed * maxSpeed) {
            float scale = maxSpeed / sqrt(speedSq);
            final_vel.x *= scale;
            final_vel.y *= scale;
        }
        
        // Write to global memory
        positions[ball_idx] = final_pos;
        velocities[ball_idx] = final_vel;
    }
}