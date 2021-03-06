//
//  EPFrappManager.m
//  Espresso
//
//  Created by Brandon Holland on 12-03-08.
//  Copyright 2012 What a Nutbar Software. All rights reserved.
//

#import "EPFrappManager.h"
#import "EPFrappMerchant.h"

@implementation EPFrappManager

#pragma mark -
#pragma mark Creation + Destruction
#pragma mark

- (id) init
{
    if((self = [super init]))
    {
        _frappuccinos = [[NSMutableArray alloc] init];
        _frappuccinosLoaded = NO;
    }
    return self;
}

- (void) dealloc
{
    [_frappuccinos release];
    [super dealloc];
}

#pragma mark -
#pragma mark Class Methods
#pragma mark

+ (id) sharedFrappManager
{
    static EPFrappManager *frappManager = nil;
    if(!frappManager)
    { frappManager = [[EPFrappManager alloc] init]; }
    return frappManager;
}

#pragma mark -
#pragma mark Private Methods
#pragma mark

- (void) _loadFrappuccinos
{    
    NSString *appleTVPath = [[NSBundle mainBundle] bundlePath];
	NSString *frappPath = [appleTVPath stringByAppendingPathComponent: @"Frappuccinos"];
	NSDirectoryEnumerator *iterator = [[NSFileManager defaultManager] enumeratorAtPath: frappPath];
	
    NSString *filePath = nil;
	while((filePath = [iterator nextObject]))
    {
        if([[filePath pathExtension] isEqualToString: @"frappuccino"]) 
		{
			NSBundle *frappBundle = [NSBundle bundleWithPath: [frappPath stringByAppendingPathComponent: filePath]];
			NSLog(@"EPFrappManager -> attempting to load %@...", [filePath lastPathComponent]);
            
            if([frappBundle load])
            {
                Class frappClass = [frappBundle principalClass];
                
                NSDictionary *frappBundleInfoDict = [frappBundle infoDictionary];
                NSDictionary *frappDict = [frappBundleInfoDict objectForKey: kEPFrappuccinoKey];
                if(frappDict)
                { 
                    EPFrappMerchant *frappMerchant = [EPFrappMerchant merchant];
                    [frappMerchant setRootControllerClass: frappClass];
                    
                    NSString *title = [frappDict objectForKey: kEPFrappuccinoTitleKey];
                    if(title)
                    { [frappMerchant setTitle: title]; }
                    
                    NSString *imageName = [frappDict objectForKey: kEPFrappuccinoImageNameKey];
                    if(imageName)
                    {
                        NSString *imagePath = [frappBundle pathForResource: [imageName stringByDeletingPathExtension] ofType: [imageName pathExtension]];
                        NSURL *imageURL = [NSURL fileURLWithPath: imagePath];
                        [frappMerchant setIconURL: imageURL];
                    }
                    
                    NSString *identifier = [frappDict objectForKey: kEPFrappuccinoIdentifierKey];
                    if(identifier)
                    { [frappMerchant setIdentifier: identifier]; }
                    
                    NSNumber *preferredOrder = [frappDict objectForKey: kEPFrappuccinoPreferredOrderKey];
                    if(preferredOrder)
                    { [frappMerchant setPreferredOrder: [preferredOrder floatValue]]; }

                    [_frappuccinos addObject: frappMerchant];
                    NSLog(@"EPFrappManager -> loaded %@", NSStringFromClass(frappClass));
                }
            }
            else
            { NSLog(@"EPFrappManager -> failed to load %@", [filePath lastPathComponent]); }
		}
    }
    _frappuccinosLoaded = YES;
}

#pragma mark -
#pragma mark Public Methods
#pragma mark

- (NSArray *) frappuccinos
{ return _frappuccinos; }

- (BOOL) frappuccinosLoaded
{ return _frappuccinosLoaded; }

- (void) clearFrappuccinos
{
    [_frappuccinos removeAllObjects];
    _frappuccinosLoaded = NO;
}

- (void) reloadFrappuccinos
{
    [self clearFrappuccinos];
    [self _loadFrappuccinos];
}

- (void) loadFrappuccinos
{
    if(!_frappuccinosLoaded)
    { [self _loadFrappuccinos]; }
}

@end
