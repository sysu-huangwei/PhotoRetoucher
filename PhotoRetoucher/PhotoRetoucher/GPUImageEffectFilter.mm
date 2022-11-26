//
//  GPUImageEffectFilter.mm
//  PhotoRetoucher
//
//  Created by rayyy on 2021/11/16.
//

#import "GPUImageEffectFilter.h"
#include "EffectEngine.hpp"
#include "DelaunayTriangle.hpp"

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
    
//    std::vector<BasePoint> points;
//    //图片角落
//    points.push_back(BasePoint(0,0));
//    points.push_back(BasePoint(355,0));
//    points.push_back(BasePoint(355,500));
//    points.push_back(BasePoint(0,500));
//    //脸一圈
//    points.push_back(BasePoint(92,176));
//    points.push_back(BasePoint(94,211));
//    points.push_back(BasePoint(101,248));
//    points.push_back(BasePoint(116,286));
//    points.push_back(BasePoint(143,316));
//    points.push_back(BasePoint(182,333));
//    points.push_back(BasePoint(225,315));
//    points.push_back(BasePoint(251,288));
//    points.push_back(BasePoint(269,251));
//    points.push_back(BasePoint(277,212));
//    points.push_back(BasePoint(278,171));
//    //额头
//    points.push_back(BasePoint(257,124));
//    points.push_back(BasePoint(185,103));
//    points.push_back(BasePoint(125,126));
//    //左眼睛
//    points.push_back(BasePoint(121,194));
//    points.push_back(BasePoint(144,206));
//    points.push_back(BasePoint(165,201));
//    points.push_back(BasePoint(144,184));
//    //右眼睛
//    points.push_back(BasePoint(253,196));
//    points.push_back(BasePoint(226,188));
//    points.push_back(BasePoint(209,202));
//    points.push_back(BasePoint(232,204));
//    //鼻子
//    points.push_back(BasePoint(188,181));
//    points.push_back(BasePoint(188,223));
//    points.push_back(BasePoint(163,250));
//    points.push_back(BasePoint(186,262));
//    points.push_back(BasePoint(211,253));
//    //嘴巴
//    points.push_back(BasePoint(154,282));
//    points.push_back(BasePoint(185,305));
//    points.push_back(BasePoint(218,283));
//    points.push_back(BasePoint(186,276));
//    points.push_back(BasePoint(186,288));
//    
//    for (int i = 0; i < points.size(); i++) {
//        points[i].x /= 355.0f;
//        points[i].y /= 500.0f;
//    }
//
//    
//    std::vector<BaseTriangle> t = DelaunayTriangle::getTriangles(points);
    
    std::vector<BasePoint> points;
    BasePoint p0;
    p0.x = 0.4;
    p0.y = 0.4;
    points.push_back(p0);
    BasePoint p1;
    p1.x = 0.2;
    p1.y = 0.2;
    points.push_back(p1);
    self->effectEngine->setPoints(points);

//    self->effectEngine->setPoints(points);
    
    
    self->effectEngine->renderToFrameBuffer(outputFrameBuffer);
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

//- (void)setEffectAlpha:(EffectType)type alpha:(float)alpha {
//    std::map<std::string, std::string> params;
//    switch (type) {
//        case EffectType_Brightness:
//            params = {
//                { FilterParam_Brightness_Alpha, std::to_string(alpha) }
//            };
//            break;
//        case EffectType_Contrast:
//            params = {
//                { FilterParam_Contrast_Alpha, std::to_string(alpha) }
//            };
//            break;
//        case EffectType_Saturation:
//            params = {
//                { FilterParam_Saturation_Alpha, std::to_string(alpha) }
//            };
//            break;
//        case EffectType_Level:
//            params = {
//                { FilterParam_Level_Midtone, std::to_string(alpha) }
//            };
//            break;
//        case EffectType_Sharpen:
//            params = {
//                { FilterParam_Sharpen_Alpha, std::to_string(alpha) }
//            };
//            break;
//        case EffectType_Mean:
//            params = {
//                { FilterParam_Mean_Alpha, std::to_string(alpha) }
//            };
//            break;
//        default:
//            break;
//    }
//    effectEngine->setParams(params);
//}
//
//- (void)setLutImagePath:(NSString *)lutImagePath {
//    runSynchronouslyOnVideoProcessingQueue(^{
//        [GPUImageContext useImageProcessingContext];
//        std::map<std::string, std::string> params = {
//            { FilterParam_Lut_Path, std::string(lutImagePath.UTF8String) }
//        };
//        self->effectEngine->setParams(params);
//    });
//}
//
//- (void)setStickerImagePath:(NSString *)stickerImagePath {
//    runSynchronouslyOnVideoProcessingQueue(^{
//        [GPUImageContext useImageProcessingContext];
//        std::map<std::string, std::string> params = {
//            { FilterParam_Sticker_Path, std::string(stickerImagePath.UTF8String) }
//        };
//        self->effectEngine->setParams(params);
//    });
//}
//
//- (void)setBGRASmallImageData:(unsigned char *)data width:(size_t)width height:(size_t)height bytesPerRow:(size_t)bytesPerRow {
//    effectEngine->setBGRASmallImageData(data, width, height, bytesPerRow);
//}

@end
