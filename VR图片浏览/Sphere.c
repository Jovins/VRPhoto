//
//  Sphere.c
//  VR图片浏览
//
//  Created by 黄进文 on 2017/1/7.
//  Copyright © 2017年 evenCoder. All rights reserved.
//

#include "Sphere.h"
#include "stdlib.h"
#include "math.h"

#define MM_PI (3.14159265f)

// MARK: - 设置球体纹理

/**
 初始化球体纹理
 
 @param numSlices      帧片数
 @param radius         球体半径
 @param vertices       顶点数
 @param texCoords      坐标
 @param indices        指数
 @param numVerticesOut 顶点
 
 @return 返回球体纹理指数
 */
int initSphere(int numSlices, float radius, float **vertices, float **texCoords, uint16_t **indices, int *numVerticesOut) {
    
    
    int numParallels = numSlices / 2;
    int numVertices  = (numParallels + 1) * (numSlices + 1);
    int numIndices   = numParallels * numSlices * 6;
    float angleStep  = (2.0f * MM_PI) / ((float) numSlices);
    
    if (vertices != NULL) {
        
        *vertices = malloc(sizeof(float) * 3 * numVertices);
    }
    
    if (texCoords != NULL) {
        
        *texCoords = malloc(sizeof(float) * 2 * numVertices);
    }
    
    if (indices != NULL) {
        
        *indices = malloc(sizeof(uint16_t) * numIndices);
    }
    
    for (int i = 0; i <= numParallels; i++) {
        
        for (int j = 0; j <= numSlices; j++) {
            
            int vertex = (i * (numSlices + 1) + j) * 3;
            if (vertices) {
                
                (*vertices)[vertex + 0] = radius * sinf(angleStep * (float)i) * cosf(angleStep * (float)j);
                (*vertices)[vertex + 1] = radius * cosf(angleStep * (float)i);
                (*vertices)[vertex + 2] = radius * sinf(angleStep * (float)i) * sinf(angleStep * (float)j);
            }
            
            if (texCoords) {
                
                int texIndex = (i * (numSlices + 1) + j) * 2;
                (*texCoords)[texIndex + 0] = (float)j / (float)numSlices;
                (*texCoords)[texIndex + 1] = ((float)i / (float)numParallels);
            }
        }
    }
    
    if (indices != NULL) {
        
        uint16_t *indexBuff = (*indices);
        for (int i = 0; i < numParallels; i++) {
            
            for (int j = 0; j < numSlices; j++) {
                
                *indexBuff++ = i * (numSlices + 1) + j;
                *indexBuff++ = (i + 1) * (numSlices + 1) + j;
                *indexBuff++ = (i + 1) * (numSlices + 1) + (j + 1);
                
                *indexBuff++ = i * (numSlices + 1) + j;
                *indexBuff++ = (i + 1) * (numSlices + 1) + (j + 1);
                *indexBuff++ = i * (numSlices + 1) + (j + 1);
            }
        }
    }
    
    if (numVerticesOut) {
        
        *numVerticesOut = numVertices;
    }
    
    return numIndices;
}

























