//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
#import "Sphere.h"

// 桥接
int initSphere(int numSlices, float radius, float **vertices, float **texCoords, uint16_t **indices, int *numVerticesOut);
