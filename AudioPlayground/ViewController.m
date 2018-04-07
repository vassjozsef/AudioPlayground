//
//  ViewController.m
//  AudioPlayground
//
//  Created by Fanghao Chen on 3/27/18.
//  Copyright © 2018 Fanghao Chen. All rights reserved.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>

@interface ViewController ()

@property (nonatomic, strong) AVAudioPlayer *player;

@property(nonatomic,strong) AVAudioRecorder *recorder;
@property(nonatomic,strong) NSMutableDictionary *recorderSettings;
@property(nonatomic,strong) NSString *recorderFilePath;
@property(nonatomic,strong) AVAudioPlayer *audioPlayer;
@property(nonatomic,strong) NSString *audioFileName;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  [self.view addSubview: [[AVRoutePickerView alloc] initWithFrame:CGRectMake(100, 40, 40, 40)]];
  
  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
  
  [audioSession addObserver:self
             forKeyPath:@"outputVolume"
                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                context:nil];
    
  NSError *inputError;
  [audioSession setPreferredInput:audioSession.availableInputs[0] error:&inputError];
  if (inputError) {
    NSLog(@"Error setting preferred input: %@", inputError.localizedDescription);
  }
    
  NSError* categoryError;
  if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers |  AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionDefaultToSpeaker error:&categoryError]) {
  NSLog(@"Error setting category: %@", categoryError.localizedDescription);
  }
 
  // category must already be set to AVAudioSessionCategoryPlayAndRecord
  NSError *modeError;
  NSString *mode = AVAudioSessionModeVoiceChat;
  if (![audioSession setMode:mode error:&modeError]) {
    NSLog(@"Error setting mode: %@", modeError.localizedDescription);
  }
  
//  NSError* categoryError2;
//  if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers |  AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionDefaultToSpeaker error:&categoryError2]) {
//    NSLog(@"Error setting category second time: %@", categoryError2.localizedDescription);
//  }
  
  NSError* activationError;
  AVAudioSessionSetActiveOptions options = 0;
  if (![audioSession setActive:YES withOptions:options error:&activationError]) {
    NSLog(@"Error activating session: %@", activationError.localizedDescription);
  }
    
  NSLog(@"           mode: %@", audioSession.mode);
  NSLog(@"       category: %@", audioSession.category);
  NSLog(@"categoryOptions: %ld", audioSession.categoryOptions);
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  NSNumber *newVolume = change[NSKeyValueChangeNewKey];
  NSNumber *oldVolume = change[NSKeyValueChangeOldKey];
  NSLog(@"OutputVolumeDidChange from %f to %f", oldVolume.floatValue, newVolume.floatValue);
}

- (IBAction)play:(id)sender {
  NSError *error;
  NSURL *url = [[NSBundle mainBundle] URLForResource:@"song" withExtension:@"mp3"];
  
//  if (!_recorderFilePath) {
//    NSLog(@"no file to play");
//    return;
//  }
//  NSURL *url = [NSURL fileURLWithPath:_recorderFilePath];

  _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
  if (error) {
    NSLog(@"%@", error.localizedDescription);
  }
  _player.delegate = self;
  [_player prepareToPlay];
  _player.numberOfLoops = -1; //infinite
  
  [_player play];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}



#pragma mark - Audio Recording
- (IBAction)startRecording:(id)sender
{
  NSError *err = nil;
  AVAudioSession *audioSession = [AVAudioSession sharedInstance];

  [audioSession setActive:YES error:&err];
  err = nil;
  if(err)
  {
    NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
    return;
  }
  
  _recorderSettings = [[NSMutableDictionary alloc] init];
  [_recorderSettings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
  [_recorderSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
  [_recorderSettings setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
  [_recorderSettings setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
  [_recorderSettings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
  [_recorderSettings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
  
  // Create a new audio file
  _recorderFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.caf"];
  
  NSURL *url = [NSURL fileURLWithPath:_recorderFilePath];
  err = nil;
  _recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:_recorderSettings error:&err];
  
  if(!_recorder){
    NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
    return;
  }
  
  //prepare to record
  _recorder.delegate = self;
  [_recorder prepareToRecord];
  _recorder.meteringEnabled = YES;
  
  if (audioSession.recordPermission == AVAudioSessionRecordPermissionGranted) {
    [_recorder recordForDuration:(NSTimeInterval) 20];//Maximum recording time : 60 seconds default
  } else {
    [audioSession requestRecordPermission:^(BOOL granted) {
      if (granted) {
        [_recorder recordForDuration:(NSTimeInterval) 20];//Maximum recording time : 60 seconds default
      }
    }];
  }
  
  // start recording
  NSLog(@"Recroding Started");
}

- (IBAction)stopRecording:(id)sender
{
  [_recorder stop];
  NSLog(@"Recording Stopped");
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
  NSLog (@"audioRecorderDidFinishRecording:successfully:");
}

@end
