//
//  HelloWorldLayer.h
//  TilesetTest
//
//  Created by Administrator on 4/29/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    CCTMXTiledMap *_tileMap;
    CCTMXLayer *_background;
    CCTMXLayer *_rocks;
    CCTMXLayer *_trees;
    
    CGPoint draggingPoint;
    
    CGPoint ZB_last_posn;
    float scale;
}

@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (nonatomic, retain) CCTMXLayer *background;
@property (nonatomic, retain) CCTMXLayer *rocks;
@property (nonatomic, retain) CCTMXLayer *trees;
//@property (nonatomic, assign) CGPoint *draggingPoint;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
