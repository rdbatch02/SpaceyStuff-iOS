//
//  spaceyStuffMyScene.m
//  Spacey Stuff
//
//  Created by Ryan Batchelder on 10/31/13.
//  Copyright (c) 2013 Ryan Batchelder. All rights reserved.
//

#import "spaceyStuffMyScene.h"
//#import "spaceyStuffViewController.h"
#include <stdlib.h>


@interface spaceyStuffMyScene () <SKPhysicsContactDelegate>
//@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) SKLabelNode* scoreBoard;
@property (nonatomic) SKLabelNode* gameOver;
@end

@implementation spaceyStuffMyScene

static const uint32_t playerCategory = 0x1 << 4;
static const uint32_t projectileCategory = 0x1 << 1;
static const uint32_t enemyCategory = 0x1 << 2;
static const uint32_t asteroidCategory = 0x1 << 3;
static const uint32_t buttonCategory = 0x1 << 3;
SKSpriteNode *player;
SKSpriteNode *enemy;
SKSpriteNode *background1;
SKSpriteNode *background2;
int score = 0;
int kills = 0;
int multiplier = 1;
int lives = 3;
int asteroidCount = 0;
int enemyCount = 0;
int shots = 0;
bool playerOnScreen = NO;
bool boardCleared = NO;
NSString *scoreString;
CGSize *frameSize;
extern int shipValue;

-(id)initWithSize:(CGSize)size {
    frameSize = &size;
    if (self = [super initWithSize:size]) {
        
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        self.backgroundColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:0];
        
//        SKSpriteNode *background1 = [SKSpriteNode spriteNodeWithImageNamed:@"images/background_static"];
//        background1.position = CGPointMake(background1.size.width/2, background1.size.height/2);
//        background1.zPosition = -100;
//        [self addChild:background1];
//        SKAction * bgmove = [SKAction moveToX:-background1.size.width/2 duration:3];
//        SKAction * bgmoveDone = [SKAction removeFromParent];
//        [background1 runAction:[SKAction sequence:@[bgmove, bgmoveDone]]];
        
        [self addBackground];
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        if (shipValue == 1) {
            player = [SKSpriteNode spriteNodeWithImageNamed:@"images/SpaceShip"]; //Create player ship TODO: Randomize this!
        }
        else {
            player = [SKSpriteNode spriteNodeWithImageNamed:@"images/SpaceShip3"];
        }
        player.position = CGPointMake(50, self.frame.size.height/2); //Set player start position
        player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(25, 25)]; //Define the PhysicsBody for the player's collision detection
        player.physicsBody.dynamic = YES;
        player.physicsBody.categoryBitMask = playerCategory;
        player.physicsBody.contactTestBitMask = asteroidCategory;
        player.physicsBody.collisionBitMask = 0;
        player.physicsBody.usesPreciseCollisionDetection = YES;
        playerOnScreen = YES;
        [self resetPlayer];
        
        NSString *scoreString = [NSString stringWithFormat:@"Score: %d Multiplier: %d Lives: %d", score, multiplier, lives];
        self.scoreBoard = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        
//        self.scoreBoard.text = [NSString stringWithFormat:@"Score: %d Multiplier: %d", score, multiplier];
        self.scoreBoard.text = scoreString;
        self.scoreBoard.fontSize = 18;
        self.scoreBoard.fontColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:1];
        self.scoreBoard.position = CGPointMake(self.scene.size.width/2, self.scene.size.height-30);\
        [self addChild:self.scoreBoard];
        
        self.gameOver = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        self.gameOver.position = CGPointMake(self.scene.size.width/2, self.scene.size.height - 60);
        self.gameOver.text = [NSString stringWithFormat:@"Game Over!"];
        self.gameOver.fontSize = 24;
        self.gameOver.fontColor = [SKColor whiteColor];
        
        

    
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
    int randEnemy = arc4random_uniform(2)+1;
    
    NSString *enemyType = [NSString stringWithFormat:@"images/BaddieShip%d", randEnemy];
    enemyCount++;
    
    SKSpriteNode * enemy = [SKSpriteNode spriteNodeWithImageNamed:enemyType];

    CGSize enemySize = CGSizeMake(25, 25);
    
    enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemySize];
    enemy.physicsBody.dynamic = YES;
    enemy.physicsBody.categoryBitMask = enemyCategory;
    enemy.physicsBody.contactTestBitMask = projectileCategory;
    enemy.physicsBody.collisionBitMask = 0;
    
    enemy.name = [NSString stringWithFormat:@"enemy"];
    
    int minY = 25;
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
    [enemy runAction:[SKAction sequence:@[actionMove, [SKAction group:@[actionMoveDone, [SKAction runBlock:^{
        enemyCount--;
    }]]]]]];
}

-(void)addAsteroid {
    SKSpriteNode * asteroid = [SKSpriteNode spriteNodeWithImageNamed:@"images/asteroid"];
    asteroidCount++;
    
    //CGSize asteroidSize = CGSizeMake(asteroid.size.width, asteroid.size.height);
    
    asteroid.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:25];
    asteroid.physicsBody.dynamic = YES;
    asteroid.physicsBody.categoryBitMask = asteroidCategory;
    asteroid.physicsBody.contactTestBitMask = playerCategory;
    asteroid.physicsBody.collisionBitMask = 0;
    
    asteroid.name = [NSString stringWithFormat:@"asteroid"];
    
    int minY = asteroid.size.height / 2;
    int maxY = self.frame.size.height - asteroid.size.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    asteroid.position = CGPointMake(self.frame.size.width + asteroid.size.width / 2, actualY);
    asteroid.anchorPoint = CGPointMake(.4, .5);
    [self addChild:asteroid];
    
//    int minDuration = 1.0;
//    int maxDuration = 5.0;
//    int rangeDuration = maxDuration - minDuration;
//    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    int actualDuration = arc4random_uniform(5);
    
    SKAction * asteroidSpin = [SKAction rotateByAngle:actualDuration duration:0.5];
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-asteroid.size.width/2, actualY) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [asteroid runAction:[SKAction sequence:@[actionMove, [SKAction group:@[actionMoveDone, [SKAction runBlock:^{
        asteroidCount--;
    }]]]]]];
    [asteroid runAction:[SKAction repeatActionForever:asteroidSpin]];
}

-(void)addBackground {
    SKSpriteNode * background = [SKSpriteNode spriteNodeWithImageNamed:@"images/background_static"];
    
    background.position = CGPointMake(self.size.width + background.size.width/2, self.size.height/2);
    background.zPosition = -100;
    [self addChild:background];
    SKAction * bgmove = [SKAction moveToX:-background.size.width/2 duration:3];
    SKAction * bgmoveDone = [SKAction removeFromParent];
    [background runAction:[SKAction sequence:@[bgmove, bgmoveDone]]];
}

-(void)updateWithtimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1 && lives > 0) {
        self.lastSpawnTimeInterval = 0;
        if (enemyCount < 4) {
            [self addEnemy];
        }
        if (asteroidCount < 4) {
            [self addAsteroid];
        }
        [self addBackground];
        if (!playerOnScreen) {
            [self resetPlayer];
        }
        if (multiplier % 5 == 0) {
            lives++;
        }
    }
    else if (lives == 0 && !boardCleared) { //Game is over and we still need to clear the board
        [self addBackground];
        boardCleared = [self doClearBoard];
    }
    
    else if (lives == 0 && boardCleared && self.lastSpawnTimeInterval > 1) { //Game is over and the board is already cleared
        self.lastSpawnTimeInterval = 0;
        [self addBackground];
        if (!playerOnScreen) {
            [self resetPlayer];
        }
    }
}

-(BOOL)doClearBoard {
    int accuracy = (double)((float)kills/(float)shots)*100;
    NSLog(@"%d", accuracy);
    self.scoreBoard.text = [NSString stringWithFormat:@"Final Score: %d Shots: %d Accuracy: %d%%", score, shots, accuracy];
    [self addChild:self.gameOver];
    [self enumerateChildNodesWithName:[NSString stringWithFormat:@"asteroid"] usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:[NSString stringWithFormat:@"enemy"] usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];

    SKSpriteNode *replay = [SKSpriteNode spriteNodeWithImageNamed:@"images/replayButton"];
    replay.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(100, 50)];
    replay.physicsBody.dynamic = YES;
    replay.physicsBody.categoryBitMask = buttonCategory;
    replay.physicsBody.contactTestBitMask = projectileCategory;
    replay.physicsBody.collisionBitMask = 0;
    replay.name = [NSString stringWithFormat:@"replayButton"];
    replay.position = CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild:replay];
    
    return YES;
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
//    player.position = translation;
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
    //CGPoint location = [gesture locationInNode:self];

    CGPoint location = [gesture locationInView:self.view];
    
    if (playerOnScreen && (location.x < 510 && location.y > 20))
    {
        SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"images/PewPew"];
        projectile.position = CGPointMake(player.position.x+5, player.position.y);
        CGSize projectileSize = CGSizeMake(15, 25);
        projectile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:projectileSize];
        projectile.physicsBody.dynamic = YES;
        projectile.physicsBody.categoryBitMask = projectileCategory;
        projectile.physicsBody.contactTestBitMask = enemyCategory;
        projectile.physicsBody.collisionBitMask = 0;
        projectile.physicsBody.usesPreciseCollisionDetection = YES;
        
        [self addChild:projectile];
        
        shots++;
        
        float velocity = 480.0;
        float realMoveDuration = self.size.width / velocity;
        CGPoint dest = CGPointMake(self.frame.size.width+10, player.position.y);
        SKAction * actionMove = [SKAction moveTo:dest duration:realMoveDuration];
        SKAction * actionMoveDone = [SKAction removeFromParent];
        [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    }
}

-(void)resetPlayer {
    player.position = CGPointMake(50, self.frame.size.height/2); //Set player start position
    playerOnScreen = YES;
    [self addChild:player];
}

-(void)projectile:(SKSpriteNode *)projectile didCollideWithEnemy:(SKSpriteNode *)enemy {
    //NSLog(@"Hit"); Used for debugging
    score += multiplier;
    kills++;
    if (score % 5 == 0) {
        multiplier++;
    }
    enemyCount--;
    self.scoreBoard.text = [NSString stringWithFormat:@"Score: %d Multiplier: %d Lives: %d", score, multiplier, lives];
    [projectile removeFromParent];
    [enemy removeFromParent];
}

-(void)projectile:(SKSpriteNode *)projectile didCollideWithButton:(SKSpriteNode *)replay {
    //NSLog(@"Replay Button");
    lives = 3;
    multiplier = 1;
    score = 0;
    shots = 0;
    enemyCount = 0;
    asteroidCount = 0;
    kills = 0;
    
    self.scoreBoard.text = [NSString stringWithFormat:@"Score: %d Multiplier: %d Lives: %d", score, multiplier, lives];
    self.lastSpawnTimeInterval = 0;
    boardCleared = NO;
    [replay removeFromParent];
    [player removeFromParent];
    [self.gameOver removeFromParent];
    [projectile removeFromParent];
    playerOnScreen = NO;
}

-(void)asteroid:(SKSpriteNode *)asteroid didCollideWithPlayer:(SKSpriteNode *)player {
    //NSLog(@"Asteroid hit");
    lives--;
    multiplier = 1;
    asteroidCount--;
    self.scoreBoard.text = [NSString stringWithFormat:@"Score: %d Multiplier: %d Lives: %d", score, multiplier, lives];
    [asteroid removeFromParent];
    [player removeFromParent];
    playerOnScreen = NO;
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
    if ((firstBody.categoryBitMask & asteroidCategory) != 0 && (secondBody.categoryBitMask & playerCategory) != 0) {
        [self asteroid:(SKSpriteNode *) firstBody.node didCollideWithPlayer:(SKSpriteNode *) secondBody.node];
    }
    if ((firstBody.categoryBitMask & projectileCategory) !=0 && (secondBody.categoryBitMask & buttonCategory) != 0) {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithButton:(SKSpriteNode *) secondBody.node];
    }
}

-(void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = CGPointMake(100, -translation.y);
        [player setPosition:CGPointMake(player.position.x, player.position.y + translation.y)];
        if (player.position.y > self.scene.size.height + 15)
            [player setPosition:CGPointMake(player.position.x, -15)];
        else if (player.position.y < -15)
            [player setPosition:CGPointMake(player.position.x, self.scene.size.height+15)];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    }
    
}


//-(void)update:(CFTimeInterval)currentTime {
//    /* Called before each frame is rendered */
//}

@end
