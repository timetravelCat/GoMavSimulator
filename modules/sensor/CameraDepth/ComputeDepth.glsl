#[compute]
#version 450

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) restrict buffer DepthBuffer {
    float data[];
}
depth_buffer;

void main() {
    // Parse DepthBuffer (See CameraDepth.gdshader in the same folder)
    uint data = floatBitsToUint(depth_buffer.data[gl_GlobalInvocationID.x]);

    uint x = data & 0xFF;
    uint y = (data >> 8) & 0xFF;
    uint z = (data >> 16) & 0xFF;

    if (x == 255 && y == 255 && z == 255) {
        depth_buffer.data[gl_GlobalInvocationID.x] = uintBitsToFloat(0x7F800000);
        return;
    }

    // 0.005 + floor
    depth_buffer.data[gl_GlobalInvocationID.x] =    \
        10.0f * floor(100.0f * x / 255.0f + 0.5f) +\
        0.1f * floor(100.0f * y / 255.0f + 0.5f)   +\
        0.001f * floor(100.0f * z / 255.0f + 0.5f);
}