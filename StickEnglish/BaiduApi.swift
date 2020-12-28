//
//  BaiduApi.swift
//  StickEnglish
//
//  Created by 吴非 on 2020/12/24.
//  Copyright © 2020 Lanchc. All rights reserved.
//

import Cocoa
import Alamofire
import CommonCrypto

//#import <CommonCrypto/CommonDigest.h>
/// 网络请求处理
class BaiduApi: NSObject {
    
    static let apiURL: String = "http://fanyi-api.baidu.com/api/trans/vip/translate"
    static let appId: String = ""
    static let secretKey: String = ""
    
    /// 文档地址 https://fanyi-api.baidu.com/doc/21

    /// appid+q+salt+密钥 的MD5值
    static func signature(q: String, salt: String) -> String {
        let temp_str: String = "\(BaiduApi.appId)\(q)\(salt)\(BaiduApi.secretKey)"
        print("temp_str:", temp_str)
        let sign_str: String = String(temp_str).md5
        print("sign:", sign_str.lowercased())
        /// md5 需要小写的#大写会报错
        return sign_str.lowercased()
    }
    
    
    static func translate(q: String, toType: LanguageType = .en, completeHandle: @escaping (RspModel) -> Void) {

        let salt: String = Date().timeStamp
        
        var parameters = Parameters()
        
        parameters["q"] = q             /// 请求翻译文本
        /// 翻译源语言 可设置为 auto
        parameters["from"] = "auto"
        /// 翻译目标语言 中文 zh 英语 en
        parameters["to"] = toType.rawValue
        /// 控制台查看
        parameters["appid"] = BaiduApi.appId
        parameters["salt"] = salt
        parameters["sign"] = signature(q: q, salt: salt)
        /// 设置请求头
        let headers: HTTPHeaders = [ .contentType("application/x-www-form-urlencoded") ]
        
        let req = AF.request(BaiduApi.apiURL, method: .get, parameters: parameters, headers: headers)
        req.responseJSON { (repss) in
            print(repss)
        }
        req.response { (response) in

            guard let dm = response.data else { return }

            guard let apiModel  = try? JSONDecoder().decode(RspModel.self, from: dm) else { return }
            
            completeHandle(apiModel)
        }
    }
    
}

///// Model representing a selection of results from the iTunes Lookup API.
struct RspModel: Decodable {
    /// Codable Coding Keys for the Top-Level iTunes Lookup API JSON response.
    private enum CodingKeys: String, CodingKey {
        /// The results JSON key.
        case from
        case to
        case trans_result
    }
    
    
    let from: String
    
    let to: String
    
    let trans_result: [Results]
    
    /// The Results object from the the iTunes Lookup API.
    struct Results: Decodable {
        ///  Codable Coding Keys for the Results array in the iTunes Lookup API JSON response.
        private enum CodingKeys: String, CodingKey {
            case dst = "dst"
            case src = "src"
        }
        
        let dst: String

        let src: String
    }
}



extension String {
    var md5:String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02X", $1) }
    }
    
    static func random(len: Int = 10) -> String {
        /// abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
        let letters : NSString = "0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 0 ..< len {
            
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C",letters.character(at: Int(rand)))
        }
        
        return randomString as String
    }
}


extension Date {
    
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
}
