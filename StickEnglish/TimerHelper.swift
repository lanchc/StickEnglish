//
//  TimerHelper.swift
//  StickEnglish
//
//  Created by 吴非 on 2020/12/24.
//  Copyright © 2020 Lanchc. All rights reserved.
//

import Cocoa

typealias completeTask = () -> Void

class TimerHelper: NSObject {
    
    private var currentTask: completeTask
    
    private var timer: Timer!
    
    // MARK: - 构造方法
    init(task: @escaping completeTask) {
        self.currentTask = task
        super.init()
    }
    
    var automaticSlidingInterval: CGFloat = 0.0 {
        didSet {
            self.cancelTimer()
            if self.automaticSlidingInterval > 0 {
                self.startTimer()
            }
        }
    }
    
    func startTimer() {
        guard self.automaticSlidingInterval > 0 && self.timer == nil else {
            return
        }
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.automaticSlidingInterval), target: self, selector: #selector(self.flipNext(sender:)), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    
    func cancelTimer() {
        guard self.timer != nil else {
            return
        }
        self.timer!.invalidate()
        self.timer = nil
    }
    
    
    @objc fileprivate func flipNext(sender: Timer?) {
        
        DispatchQueue.main.async { [weak self] in
            guard let wkThis = self else { return }
            wkThis.currentTask()
        }
    }
    
    deinit {
        print("释放类：\(self.classForCoder)")
    }
}
