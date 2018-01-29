//
//  DeviceLockStatus.m
//  Vachnamrut
//
//  Created by Bhautik Ziniya on 1/1/18.
//  Copyright © 2018 Agile Infoways. All rights reserved.
//

#import "DeviceLockStatus.h"
#import "notify.h"
#import "Vachnamrut-Swift.h"

@implementation DeviceLockStatus

static DeviceLockStatus *sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DeviceLockStatus alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        [self registerAppforDetectLockState];
    }
    return self;
}

-(void)registerAppforDetectLockState {
    
    int notify_token;

    notify_register_dispatch("com.apple.springboard.lockstate", &notify_token,dispatch_get_main_queue(), ^(int token) {
        uint64_t state = UINT64_MAX;
        notify_get_state(token, &state);
        
        if(state == 0) {
            if ( self.deviceUnlocked ) {
                self.deviceUnlocked();
            }
            NSLog(@"unlock device");
        } else {
            if ( self.deviceLocked ) {
                self.deviceLocked();
            }
            NSLog(@"lock device");
        }
    });
}

-(void)deviceLockedNotification:(DeviceLockedUnlockHandler)block {
    self.deviceLocked = block;
}

-(void)deviceUnlockedNotification:(DeviceLockedUnlockHandler)block {
    self.deviceUnlocked = block;
}

@end
