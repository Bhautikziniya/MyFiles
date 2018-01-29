//
//  DeviceLockStatus.h
//  Vachnamrut
//
//  Created by Bhautik Ziniya on 1/1/18.
//  Copyright © 2018 Agile Infoways. All rights reserved.
//

#ifndef DeviceLockStatus_h
#define DeviceLockStatus_h

#import <Foundation/Foundation.h>

typedef void (^DeviceLockedUnlockHandler)(void);

@interface DeviceLockStatus : NSObject

@property (strong, nonatomic) id _Nullable someProperty;
@property (nonatomic, copy, nullable) DeviceLockedUnlockHandler deviceLocked;
@property (nonatomic, copy, nullable) DeviceLockedUnlockHandler deviceUnlocked;

+(DeviceLockStatus *_Nonnull)sharedInstance;
-(void)registerAppforDetectLockState;
-(void)deviceLockedNotification:(DeviceLockedUnlockHandler _Nullable )block;
-(void)deviceUnlockedNotification:(DeviceLockedUnlockHandler _Nullable )block;
@end

#endif /* DeviceLockStatus_h */
