//
//  MDManager.h
//  Tasks+
//
//  Created by Sven on 5/14/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTLTasks.h"
#import "GTMOAuth2ViewControllerTouch.h"

@protocol MDManagerDelegate;

@interface MDManager : NSObject

@property (nonatomic, strong) id <MDManagerDelegate> delegate;
@property (nonatomic, strong) GTLServiceTasks *service;
@property (nonatomic, assign) GTMOAuth2Authentication *auth;
@property (nonatomic, strong) GTLServiceTicket *ticket;

- (instancetype)initWithAuth:(GTMOAuth2Authentication *)auth;

- (NSInteger)count;
- (void)fetch;

@end

@protocol MDManagerDelegate <NSObject>

@required
- (void)managerDidRefresh:(MDManager *)manager;
- (void)manager:(MDManager *)manager didAddItem:(id)item atIndexPath:(NSIndexPath *)indexPath;
- (void)manager:(MDManager *)manager didUpdateItem:(id)item atIndexPath:(NSIndexPath *)indexPath;
- (void)manager:(MDManager *)manager didDeleteItem:(id)item atIndexPath:(NSIndexPath *)indexPath;


@end
