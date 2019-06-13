//
//  ViewController.h
//  AudioPlayground
//
//  Created by Fanghao Chen on 3/27/18.
//  Copyright © 2018 Fanghao Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>


@interface ViewController : UIViewController <AVAudioPlayerDelegate, AVRoutePickerViewDelegate, AVAudioRecorderDelegate>

@end

