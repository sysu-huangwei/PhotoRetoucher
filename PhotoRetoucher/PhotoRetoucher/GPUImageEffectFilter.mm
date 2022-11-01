//
//  GPUImageEffectFilter.mm
//  PhotoRetoucher
//
//  Created by rayyy on 2021/11/16.
//

#import "GPUImageEffectFilter.h"
#include "EffectEngine.hpp"

std::shared_ptr<effect::FrameBuffer> getCPPFrameBufferFromGPUImageFrameBuffer(GPUImageFramebuffer *frameBuffer) {
    effect::TextureOptions textureOptions;
    textureOptions.minFilter = frameBuffer.textureOptions.minFilter;
    textureOptions.magFilter = frameBuffer.textureOptions.magFilter;
    textureOptions.wrapS = frameBuffer.textureOptions.wrapS;
    textureOptions.wrapT = frameBuffer.textureOptions.wrapT;
    textureOptions.internalFormat = frameBuffer.textureOptions.internalFormat;
    textureOptions.format = frameBuffer.textureOptions.format;
    textureOptions.type = frameBuffer.textureOptions.type;
    std::shared_ptr<effect::FrameBuffer> frameBufferCPP = std::make_shared<effect::FrameBuffer>();
    frameBufferCPP->init(frameBuffer.size.width, frameBuffer.size.height, frameBuffer.missingFramebuffer, textureOptions, frameBuffer.texture, frameBuffer.framebuffer);
    return frameBufferCPP;
}

@interface GPUImageEffectFilter()
{
    effect::EffectEngine *effectEngine;
}
@end

@implementation GPUImageEffectFilter

- (instancetype)init {
    if (self = [super init]) {
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUImageContext useImageProcessingContext];
            NSString *configFilePath = [NSBundle.mainBundle.bundlePath stringByAppendingPathComponent:@"ImageEffect.bundle/descriptions/PhotoRetoucher.json"];
            self->effectEngine = new effect::EffectEngine(configFilePath.UTF8String);
            self->effectEngine->init();
        });
    }
    return self;
}

- (void)dealloc {
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        self->effectEngine->release();
        delete self->effectEngine;
    });
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        self->effectEngine->setOutputSize(filterFrameSize.width, filterFrameSize.height);
    });
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    std::shared_ptr<effect::FrameBuffer> inputFrameBuffer = getCPPFrameBufferFromGPUImageFrameBuffer(firstInputFramebuffer);
    std::shared_ptr<effect::FrameBuffer> outputFrameBuffer = getCPPFrameBufferFromGPUImageFrameBuffer(outputFramebuffer);
    
    self->effectEngine->setInputFrameBufferAtIndex(inputFrameBuffer);
    
    self->effectEngine->renderToFrameBuffer(outputFrameBuffer);
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

- (void)setEffectAlpha:(EffectType)type alpha:(float)alpha {
    std::map<std::string, std::string> params;
    switch (type) {
        case EffectType_Brightness:
            params = {
                { FilterParam_Brightness_Alpha, std::to_string(alpha) }
            };
            break;
        case EffectType_Contrast:
            params = {
                { FilterParam_Contrast_Alpha, std::to_string(alpha) }
            };
            break;
        case EffectType_Saturation:
            params = {
                { FilterParam_Saturation_Alpha, std::to_string(alpha) }
            };
            break;
        case EffectType_Level:
            params = {
                { FilterParam_Level_Midtone, std::to_string(alpha) }
            };
            break;
        case EffectType_Sharpen:
            params = {
                { FilterParam_Sharpen_Alpha, std::to_string(alpha) }
            };
            break;
        case EffectType_Mean:
            params = {
                { FilterParam_Mean_Alpha, std::to_string(alpha) }
            };
            break;
        default:
            break;
    }
    effectEngine->setParams(params);
}

- (void)setLutImagePath:(NSString *)lutImagePath {
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        std::map<std::string, std::string> params = {
            { FilterParam_Lut_Path, std::string(lutImagePath.UTF8String) }
        };
        self->effectEngine->setParams(params);
    });
}

- (void)setStickerImagePath:(NSString *)stickerImagePath {
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        std::map<std::string, std::string> params = {
            { FilterParam_Sticker_Path, std::string(stickerImagePath.UTF8String) }
        };
        self->effectEngine->setParams(params);
    });
}

- (void)setBGRASmallImageData:(unsigned char *)data width:(size_t)width height:(size_t)height bytesPerRow:(size_t)bytesPerRow {
    effectEngine->setBGRASmallImageData(data, width, height, bytesPerRow);
}

@end
