//
//  About.m
//  MultiCleaner
//
//  Created by Marius Petcu on 9/12/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "About.h"
#define UIViewAutoresizingAll \
UIViewAutoresizingFlexibleBottomMargin | \
UIViewAutoresizingFlexibleHeight | \
UIViewAutoresizingFlexibleLeftMargin | \
UIViewAutoresizingFlexibleRightMargin | \
UIViewAutoresizingFlexibleTopMargin | \
UIViewAutoresizingFlexibleWidth


@implementation About


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        UITextView * view = [[UITextView alloc] initWithFrame:[self.view bounds]];
		view.autoresizingMask=UIViewAutoresizingAll;
		view.editable = NO;
		view.text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"About" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
		[self.view addSubview:view];
		[view release];
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = loc(@"AboutTitle");
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
