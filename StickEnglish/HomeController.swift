//
//  HomeController.swift
//  StickEnglish
//
//  Created by 吴非 on 2020/12/24.
//  Copyright © 2020 Lanchc. All rights reserved.
//

import Cocoa

class HomeController: NSViewController {
    
    private lazy var timer: TimerHelper = {
        return TimerHelper { [weak self] in
            guard let wkThis = self else { return }
            wkThis.analysis()
        }
    }()
    
    /**输出结果*/
    @IBOutlet var outputText: NSTextView!
    
    @IBOutlet weak var btnLanguage: NSButton!
    
    
    
    /**上一次翻译内容*/
    private var lastContent: String = ""
    
    private var toLanguage: LanguageType = .en {
        didSet {
            if toLanguage == .en {
                btnLanguage.title = "翻译成->英文"
            } else if toLanguage == .zh {
                btnLanguage.title = "翻译成->中文"
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        toLanguage = .zh
        timer.automaticSlidingInterval = 0.5
    }
    
    
    @IBAction func btnTouch(_ sender: NSButton) {
        
        switch sender.tag {
        case 1000:
            clean()
            break
        case 1001:
            toLanguage = (toLanguage == .en) ? .zh : .en
            break
        default:
            break
        }
    }
    
    private func clean() {
        
        NSPasteboard.general.setString("", forType: .string)
        
        outputText.string = ""
        
        lastContent = ""
    }
    
    
    private func analysis() {
        
        guard let copyText = NSPasteboard.general.string(forType: .string) else { return }

        guard copyText != lastContent else { return }
        
        print("====================== 粘贴板的内容 ======================")
        print(copyText)
        
        lastContent = copyText

        BaiduApi.translate(q: copyText, toType: toLanguage) { [weak self] (dm) in
            
            guard let wkThis = self else { return }
            
            DispatchQueue.main.async {
                
                wkThis.outputText.string = dm.trans_result.first?.dst ?? ""
            }
        }
    }
    
}

