//
//  spaceyStuffMyScene.m
//  Spacey Stuff
//
//  Created by Ryan Batchelder on 10/31/13.
//  Copyright (c) 2013 Ryan Batchelder. All rights reserved.
//

#import "spaceyStuffMyScene.h"


@interface spaceyStuffMyScene () <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) SKLabelNode* scoreBoard;
@end

@implementation spaceyStuffMyScene

static const uint32_t projectileCategory = 0x1 << 0;
static const uint32_t enemyCategory = 0x1 << 1;
int score = 0;

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        self.backgroundColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:0];
        
//        SKSpriteNode * bg = [SKSpriteNode spriteNodeWithImageNamed:@"images/background.gif"];
//        bg.anchorPoint = CGPointZero;
//        bg.name = @"background";
//        [self addChild:bg];
        
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"images/SpaceShip"];
        self.player.position = CGPointMake(50, self.frame.size.height/2);
        [self addChild:self.player];
        
        self.scoreBoard = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        
        self.scoreBoard.text = [NSString stringWithFormat:@"Score: %d", score];
        self.scoreBoard.fontSize = 15;
        self.scoreBoard.fontColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:1];
        self.scoreBoard.position = CGPointMake(self.scene.size.width/2, self.scene.size.height-30);\
        [self addChild:self.scoreBoard];

        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        /* Setup your scene here */
        
//        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
//        
//        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
//        
//        myLabel.text = @"Hello, World!";
//        myLabel.fontSize = 30;
//        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
//                                       CGRectGetMidY(self.frame));
//        
//        [self addChild:myLabel];
    }
    return self;
}

-(void)addEnemy {
    SKSpriteNode * enemy = [SKSpriteNode spriteNodeWithImageNamed:@"images/BaddieShip"];
    
    CGSize enemySize = CGSizeMake(25, 25);
    
    enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemySize];
    enemy.physicsBody.dynamic = YES;
    enemy.physicsBody.categoryBitMask = enemyCategory;
    enemy.physicsBody.contactTestBitMask = projectileCategory;
    enemy.physicsBody.collisionBitMask = 0;
    
    int minY = enemy.size.height / 2;
    int maxY = self.frame.size.height - enemy.size.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    enemy.position = CGPointMake(self.frame.size.width + enemy.size.width/2, actualY);
    [self addChild:enemy];
    
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-enemy.size.width/2, actualY) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [enemy runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

-(void)updateWithtimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addEnemy];
    }
}

-(void)update:(NSTimeInterval)currentTime {
    CFTimeInterval timeSinceLast = currentTime - self.lastSpawnTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) {
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    [self updateWithtimeSinceLastUpdate:timeSinceLast];
}

//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInNode:self];
//    CGPoint previousLocation = [touch previousLocationInNode:self];
//    
//    CGPoint translation = CGPointMake(100, location.y - previousLocation.y);
//    self.player.position = translation;
//                    
//}

-(void)didMoveToView:(SKView *)view {
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    panGestureRecognizer.cancelsTouchesInView = NO;
    panGestureRecognizer.delegate = self;
    [[self view] addGestureRecognizer:panGestureRecognizer];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    singleTapGestureRecognizer.enabled = YES;
    singleTapGestureRecognizer.cancelsTouchesInView = NO;
    singleTapGestureRecognizer.delegate = self;
    [[self view] addGestureRecognizer:singleTapGestureRecognizer];
}

-(bool)gestureRecognizer:(UIGestureRecognizer *)singleTapGestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UITapGestureRecognizer *)panGestureRecognizer {
    return YES;
}

-(void)singleTap:(UITapGestureRecognizer *)gesture {
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //UITouch * touch = [touches anyObject];
    //CGPoint location = [touch locationInNode:self];
    
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"images/PewPew"];
    projectile.position = CGPointMake(self.player.position.x+5, self.player.position.y);
    CGSize projectileSize = CGSizeMake(15, 25);
    projectile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:projectileSize];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = enemyCategory;
    projectile.physicsBody.contactTestBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
    [self addChild:projectile];
    
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    CGPoint dest = CGPointMake(self.frame.size.width+10, self.player.position.y);
    SKAction * actionMove = [SKAction moveTo:dest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

-(void)projectile:(SKSpriteNode *)projectile didCollideWithEnemy:(SKSpriteNode *)enemy {
    NSLog(@"Hit");
    score++;
    self.scoreBoard.text = [NSString stringWithFormat:@"Score: %d", score];
    [projectile removeFromParent];
    [enemy removeFromParent];
}

-(void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else{
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & projectileCategory) != 0 && (secondBody.categoryBitMask & enemyCategory) != 0) {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithEnemy:(SKSpriteNode *) secondBody.node];
    }
}

-(void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = CGPointMake(100, -translation.y);
        [self.player setPosition:CGPointMake(self.player.position.x, self.player.position.y + translation.y)];
        if (self.player.position.y > self.scene.size.height + 50)
            [self.player setPosition:CGPointMake(self.player.position.x, -50)];
        else if (self.player.position.y < -50)
            [self.player setPosition:CGPointMake(self.player.position.x, self.scene.size.height+50)];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    }
    
}


//-(void)update:(CFTimeInterval)currentTime {
//    /* Called before each frame is rendered */
//}

@end
