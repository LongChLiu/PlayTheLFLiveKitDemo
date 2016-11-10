//
//  ViewController.swift
//  PlayTheLFLiveKitDemo
//
//  Created by langyue on 16/11/10.
//  Copyright © 2016年 langyue. All rights reserved.
//

import UIKit
import LFLiveKit

class ViewController: UIViewController,LFLiveSessionDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        session.delegate = self
        session.preView = self.view

        self.requestAccessForVideo()
        self.requestAccessForAudio()


        self.view.backgroundColor = .clear
        self.view.addSubview(containerView)
        containerView.addSubview(stateLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(beautyButton)
        containerView.addSubview(cameraBtn)
        containerView.addSubview(startLiveBtn)

        cameraBtn.addTarget(self, action: #selector(didTappedCameraButton(_:)), for: .touchUpInside)
        beautyButton.addTarget(self, action: #selector(didTappedBeautyButton(_:)), for: .touchUpInside)
        startLiveBtn.addTarget(self, action: #selector(didTappedStartLiveButton(_:)), for: .touchUpInside)

    }

    //MARK: - Callbacks
    //  回调

    func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
        print("debugInfo: \(debugInfo?.currentBandwidth)")
    }


    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
        print("errorCode: \(errorCode.rawValue)")
    }


    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
        switch state {
        case LFLiveState.ready:
            stateLabel.text = "未连接"
            break;
        case LFLiveState.pending:
            stateLabel.text = "连接中"
            break;
        case LFLiveState.start:
            stateLabel.text = "已连接"
            break;
        case LFLiveState.error:
            stateLabel.text = "连接错误"
            break;
        case LFLiveState.stop:
            stateLabel.text = "未连接"
            break;
        default:
            break;
        }
    }





    //MARK: - Events
    //开始直播
    func didTappedStartLiveButton(_ button: UIButton)->Void{
        startLiveBtn.isSelected = !startLiveBtn.isSelected;
        if startLiveBtn.isSelected {
            startLiveBtn.setTitle("结束直播", for: .normal)
            let stream = LFLiveStreamInfo()
            stream.url = "rtmp://live.hkstv.hk.lxdns.com:1935/live/stream153"
            session.startLive(stream)
        }else{
            startLiveBtn.setTitle("开始直播", for: .normal)
            session.stopLive()
        }
    }
    


    //美颜
    func didTappedBeautyButton(_ button: UIButton)->Void{
        session.beautyFace = session.beautyFace;
        beautyButton.isSelected = !session.beautyFace
    }
    //摄像头
    func didTappedCameraButton(_ button: UIButton)->Void{
        let devicePosition = session.captureDevicePosition;
        session.captureDevicePosition = (devicePosition == AVCaptureDevicePosition.back) ? AVCaptureDevicePosition.front : AVCaptureDevicePosition.back
    }
    //关闭
    func didTappedCloseButton(_ button: UIButton)->Void{

    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK: AccessAuth
    func requestAccessForVideo()->Void{
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch status {
            //许可对话没有出现 发起授权许可

        case AVAuthorizationStatus.notDetermined:

            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                if(granted){
                    DispatchQueue.main.async {
                        self.session.running = true
                    }
                }
            })

            break;

        case AVAuthorizationStatus.authorized:
            session.running = true;
            break;
            //用户明确的拒绝授权 或者相机设备无法访问
        case AVAuthorizationStatus.denied:
            break
        case AVAuthorizationStatus.restricted:
            break
        default:
            break;
        }
    }


    func requestAccessForAudio()->Void{
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
        switch status {
        case AVAuthorizationStatus.notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { (granted) in

            })
            break;
            //已经开区授权 可继续
        case AVAuthorizationStatus.authorized:
            break;
            //用户明确地拒绝授权 或者相机设备无法运行
        case AVAuthorizationStatus.denied:
            break;

        case AVAuthorizationStatus.restricted:
            break;

        default:
            break;
        }

    }






    //MARK: - Getters and Setters
    //默认分辨率368 * 640 音频： 44.1 iphone6以上48 双声道 方向竖屏
    var session : LFLiveSession = {
        let audioConfiguration = LFLiveAudioConfiguration.defaultConfiguration(for: LFLiveAudioQuality.high)
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.low3)
        let session = LFLiveSession(audioConfiguration: audioConfiguration,videoConfiguration: videoConfiguration)
        return session!
    }()

    //视图
    var containerView: UIView = {
        let containerView = UIView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        containerView.backgroundColor = UIColor.clear
        containerView.autoresizingMask = [UIViewAutoresizing.flexibleHeight,UIViewAutoresizing.flexibleHeight];
        return containerView
    }()

    //状态Label
    var stateLabel : UILabel = {
        let stateLabel = UILabel.init(frame: CGRect.init(x: 20, y: 20, width: 80, height: 40))
        stateLabel.text = "未连接"
        stateLabel.textColor = UIColor.white
        stateLabel.font = UIFont.systemFont(ofSize: 14)
        return stateLabel
    }()

    //关闭按钮
    var closeButton: UIButton = {
        let closeBtn = UIButton(frame: CGRect.init(x: UIScreen.main.bounds.width-10-44, y: 20, width: 44, height: 44))
        closeBtn.setImage(UIImage(named:"close_preview"), for: .normal)
        return closeBtn
    }()


    //摄像头
    var cameraBtn: UIButton = {
        let cameraBtn = UIButton.init(frame: CGRect.init(x: UIScreen.main.bounds.width - 54*2, y: 20, width: 44, height: 44))
        cameraBtn.setImage(UIImage(named:"camra_preview"), for: .normal)
        return cameraBtn
    }()


    //摄像头美容按钮
    var beautyButton: UIButton = {
        let beautyBtn = UIButton(frame:CGRect.init(x: UIScreen.main.bounds.width-54*3, y: 20, width: 44, height: 44))
        beautyBtn.setImage(UIImage(named:"camra_beauty"), for: .selected)
        beautyBtn.setImage(UIImage(named:"camra_beauty_close"), for: .normal)
        return beautyBtn
    }()


    //开始直播按钮
    var startLiveBtn: UIButton = {
        let startLiveBtn = UIButton(frame: CGRect.init(x: 30, y: UIScreen.main.bounds.height-50, width: UIScreen.main.bounds.width-10-44, height: 44))
        startLiveBtn.layer.cornerRadius = 22
        startLiveBtn.setTitleColor(UIColor.black, for: .normal)
        startLiveBtn.setTitle("开始直播", for: .normal)
        startLiveBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        startLiveBtn.backgroundColor = UIColor.init(colorLiteralRed: 50, green: 32, blue: 245, alpha: 1)
        return startLiveBtn
    }()


}

