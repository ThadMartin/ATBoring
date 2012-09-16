//
//  scratchPadDraw.m
//  AT_Boring
//
//  Created by Thad Martin on 9/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "scratchPadDraw.h"

@implementation scratchPadDraw

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor=[UIColor whiteColor];
        myPath=[[UIBezierPath alloc]init];
        myPath.lineCapStyle=kCGLineCapRound;
        myPath.miterLimit=0;
        myPath.lineWidth=1;
        brushColor=[UIColor blackColor];

    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [brushColor setStroke];
    [myPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    [myPath moveToPoint:[mytouch locationInView:self]];
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    [myPath addLineToPoint:[mytouch locationInView:self]];
    [self setNeedsDisplay];
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    
}


@end
