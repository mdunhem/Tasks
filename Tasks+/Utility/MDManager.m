//
//  MDManager.m
//  Tasks+
//
//  Created by Sven on 5/14/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import "MDManager.h"

@implementation MDManager

@synthesize ticket = _ticket;

- (instancetype)initWithAuth:(GTMOAuth2Authentication *)auth {
    self = [super init];
    if (self) {
        [self.service setAuthorizer:auth];
    }
    
    return self;
}

#pragma mark - Properties

- (GTLServiceTasks *)service {
    
    if (!_service) {
        _service = [[GTLServiceTasks alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them
        _service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        _service.retryEnabled = YES;
    }
    return _service;
}

- (void)setAuth:(GTMOAuth2Authentication *)auth {
    _auth = auth;
    self.service.authorizer = auth;
}

#pragma mark - Methods

- (NSInteger)count {
    return 0;
}

- (void)fetch {

}

@end
