
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>


@interface VVTextGlyph : NSObject <NSCopying, NSMutableCopying, NSCoding>

@property(nonatomic, assign) CGGlyph glyph;
@property(nonatomic, assign) CGPoint position;
@property(nonatomic, assign) CGFloat ascent;
@property(nonatomic, assign) CGFloat descent;
@property(nonatomic, assign) CGFloat leading;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;

@end
