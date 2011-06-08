//
//  HelloWorldLayer.m
//  TilesetTest
//
//  Created by Administrator on 4/29/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

static const float MIN_SCALE = 0.25;
static const float MAX_SCALE = 1.0; //max scale


// Import the interfaces
#import "HelloWorldLayer.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize tileMap = _tileMap;
@synthesize background = _background;
@synthesize rocks = _rocks;
@synthesize trees = _trees;
//@synthesize draggingPoint = _draggingPoint;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void)outputDebugInfo:(NSString *)methodName {
    /*
    NSLog(@"===== %@ called! =====", methodName);
    NSLog(@"ZB_last_posn: %f, %f", ZB_last_posn.x, ZB_last_posn.y);
    NSLog(@"self.position: %f, %f", self.position.x, self.position.y);
    NSLog(@"self.scale: scale=%f, scaleX=%f, scaleY=%f", self.scale, self.scaleX, self.scaleY);
    NSLog(@"self.contentSize: %f, %f", self.contentSize.width, self.contentSize.height);
    NSLog(@"self.contentSizeInPixels: %f, %f", self.contentSizeInPixels.width, self.contentSizeInPixels.height);
    NSLog(@"achorPointInPixels: %f, %f", self.anchorPointInPixels.x, self.anchorPointInPixels.y);
    NSLog(@"achorPoint: %f, %f", self.anchorPoint.x, self.anchorPoint.y);    
     */
}


// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init])) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];

        //scale = 0.5;
        
		self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"dungeon.tmx"];
        //self.background = [_tileMap layerNamed:@"Background"];
        //self.rocks = [_tileMap layerNamed:@"Rocks"];
        //self.trees = [_tileMap layerNamed:@"Trees"];
        //[self.background.textureAtlas.texture setAntiAliasTexParameters];
        [self addChild:_tileMap z:-1];
        
        /*
        for(int y=0; y<_rocks.layerSize.height; y++)
            for(int x=0; x<_rocks.layerSize.width; x++)
                [[_rocks tileAt:ccp(x,y)] setOpacity:(255*0.5)];
        */
    
        
        
        //[self.camera setCenterX:0 centerY:0 centerZ:0];
        //[self.camera setEyeX:0 eyeY:0 eyeZ: scale];
        
        NSLog(@"initial position: x=%f, y=%f", self.position.x, self.position.y);
        
        self.position = ccp(0, -2000 + winSize.height);
        //[self setAnchorPoint: ccp(0.0f, 0.0f)];
        //[self setScale: scale];
        
        NSLog(@"anchorPoint: %f, %f", self.anchorPoint.x, self.anchorPoint.y);
        
        ZB_last_posn = self.position;
        

        // Turn on UIGesture recognizers
		UIPanGestureRecognizer *panGestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)] autorelease];
		UIPinchGestureRecognizer *pinchGestureRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)] autorelease];
		UITapGestureRecognizer *singleTapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)] autorelease];
		singleTapGestureRecognizer.numberOfTapsRequired = 1;
		singleTapGestureRecognizer.numberOfTouchesRequired = 1;
		UITapGestureRecognizer *doubleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleDoubleTapFrom:)] autorelease];
		doubleTap.numberOfTapsRequired = 2;
		doubleTap.numberOfTouchesRequired = 1;
		[singleTapGestureRecognizer requireGestureRecognizerToFail: doubleTap];
        
		// Add them to the director
		[[[CCDirector sharedDirector] openGLView] addGestureRecognizer:singleTapGestureRecognizer];
		[[[CCDirector sharedDirector] openGLView] addGestureRecognizer:doubleTap];
		[[[CCDirector sharedDirector] openGLView] addGestureRecognizer:panGestureRecognizer];
		[[[CCDirector sharedDirector] openGLView] addGestureRecognizer:pinchGestureRecognizer];

        
        [self outputDebugInfo: @"init"];

        //self.isTouchEnabled = YES;
	}
	return self;
}

// Point conversion routines
- (CGPoint)convertPoint:(CGPoint)point fromNode:(CCNode *)node {
    return [self convertToNodeSpace:[node convertToWorldSpace:point]];
}
- (CGPoint)convertPoint:(CGPoint)touchLocation toNode:(CCNode *)node {
	// do the inverse of the routine above
	// Where touchLocation is the result of what is called from the UIGestureRecognizer
	CGPoint newPos = [[CCDirector sharedDirector] convertToGL: touchLocation];
	newPos = [node convertToNodeSpace:newPos];
	return newPos;
}

// Zoom board
- (void)zoomLayer:(float)zoomScale {
	// Debugging purposes
	//NSLog(@"self.scale: %f, gesture's scale: %f\n", self.scale, zoomScale);
    //NSLog(@"zoomLayer: x=%f, y=%f", self.position.x, self.position.y);
	if ((self.scale*zoomScale) <= MIN_SCALE) {
		zoomScale = MIN_SCALE/self.scale;
	}
	if ((self.scale*zoomScale) >= MAX_SCALE) {
		zoomScale =	MAX_SCALE/self.scale;
	}
	self.scale = self.scale*zoomScale;

    //self.position = ccp(self.scale * self.position.x, self.scale * self.position.y);
    //self.position = ccpAdd(self.position, ccpMult(self.position, 1-zoomScale));
    //ZB_last_posn = self.position;
}

// Pan board
- (void)moveBoard:(CGPoint)translation from:(CGPoint)lastLocation {
	CGPoint target_position = ccpAdd(translation, lastLocation);
    
	//CGSize size = [[CCDirector sharedDirector] winSize];
    
	// Insert routine here to check that target position is not out of bounds for your background
	// Remember that ZB_last_posn is a variable that holds the current position of zoombase
    
	self.position = target_position;
    //NSLog(@"moveBoard: x=%f, y=%f", self.position.x, self.position.y);
    
}

// anchorPointInPixels_ = ccp( contentSizeInPixels_.width * anchorPoint_.x, contentSizeInPixels_.height * anchorPoint_.y );

- (void)setNewAnchorPoint {
    //CGSize winSize = [[CCDirector sharedDirector] winSize];
    //CGPoint newAnchorPoint = ccpMult(ccp(0.5 - self.position.x/(winSize.width/2)/2, 
    //                                                0.5 - self.position.y/(winSize.height/2)/2),
    //                                            self.scale);
    CGPoint newAnchorPointInPixels = ccpAdd(self.anchorPointInPixels, 
                                            ccpSub(ZB_last_posn, self.position));
    CGPoint newAnchorPoint = ccp(self.scaleX * newAnchorPointInPixels.x / self.contentSizeInPixels.width, 
                                 self.scaleY * newAnchorPointInPixels.y / self.contentSizeInPixels.height );
    NSLog(@"anchorPointinPixels calculated: %f, %f", newAnchorPointInPixels.x, newAnchorPointInPixels.y);
    [self setAnchorPoint: newAnchorPoint];
    [self outputDebugInfo: @"setNewAnchorPoint"];
}

// UIGesture recognizer routines
- (void)handleSingleTapFrom:(UITapGestureRecognizer *)recognizer {
}
- (void)handleDoubleTapFrom:(UITapGestureRecognizer *)recognizer {
	// Here you could set this to do whatever you want, but I set it to reset the scale to 1
    self.scale = 1;
    self.position = ccp(0, 0);
    self.anchorPoint = ccp(0.5, 0.5);
    ZB_last_posn = self.position;
    [self outputDebugInfo: @"handleDoubleTapFrom"];
    //NSLog(@"double Tap: x=%f, y=%f", self.position.x, self.position.y);
}
- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateChanged) {
		CGPoint translation = [recognizer translationInView:recognizer.view];
		translation.y = -1 * translation.y;
		[self moveBoard:translation from:ZB_last_posn];
	}
    if (recognizer.state == UIGestureRecognizerStateEnded){
		// Update the zoombase position
        [self setNewAnchorPoint];
		ZB_last_posn = self.position;        
    }
}

- (void)handlePinchFrom:(UIPinchGestureRecognizer *)recognizer {
	if ((recognizer.state == UIGestureRecognizerStateBegan) || (recognizer.state == UIGestureRecognizerStateChanged)) {
		float zoomScale = [recognizer scale];
		[self zoomLayer:zoomScale];
		recognizer.scale = 1;
	}
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		// Update the zoombase position
        //[self setNewAnchorPoint];
        [self outputDebugInfo:@"handlePinchFrom"];
		ZB_last_posn = self.position;
	}
}


/*
- (void)registerWithTouchDispatcher
{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}


- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView: [touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    draggingPoint = touchLocation;
    return YES;
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView: [touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    //CGPoint touchPos = [_tileMap convertToNodeSpace:touchLocation];

    CGPoint desiredPosition = ccp(self.position.x + scale * (touchLocation.x - draggingPoint.x), 
                                  self.position.y + scale * (touchLocation.y - draggingPoint.y));
    [self setPosition: desiredPosition];
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView: [touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    NSLog(@"current position: x=%f, y=%f", self.position.x, self.position.y);
    NSLog(@"draggingPoint: x=%f, y=%f", draggingPoint.x, draggingPoint.y);
    NSLog(@"ccTouchEnded: x=%f, y=%f", touchLocation.x, touchLocation.y);
    
}
*/


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	self.tileMap = nil;
    //self.background = nil;
    //self.rocks = nil;
    //self.trees = nil;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
