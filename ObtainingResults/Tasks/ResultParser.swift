//
//  ResultParser.swift
//  HeartRateTask
//
//  Created by 叶思帆 on 25/07/2018.
//  Copyright © 2018 Sifan Ye. All rights reserved.
//

import ResearchKit

struct TaskResults{
    static var startDate = Date.distantPast
    static var endDate = Date.distantFuture
    static var hrPlotPoints = [ORKValueRange]()
}

struct ResultParser{
    
    static func getHKData(startDate: Date, endDate: Date){
        let healthStore = HKHealthStore()
        let hrType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)]
        let hrQuery = HKSampleQuery(sampleType: hrType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: sortDescriptors){
            (query:HKSampleQuery, results:[HKSample]?, error: Error?) -> Void in
            
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Error: \(String(describing: error))")
                    return
                }
                guard let results = results as? [HKQuantitySample] else {
                    print("Data conversion error")
                    return
                }
                if results.count == 0 {
                    print("Empty Results")
                    return
                }
                for result in results{
                    print("HR: \(ORKValueRange(value: result.quantity.doubleValue(for: HKUnit(from: "count/min"))))")
                    TaskResults.hrPlotPoints.append(ORKValueRange(value: result.quantity.doubleValue(for: HKUnit(from: "count/min"))))
                }
                resultViaHTTP(results: results)
            }
        }
        healthStore.execute(hrQuery)
    }
    
    static func sampleToDict(sample: HKQuantitySample) -> [String: String]{
        var dict: [String:String] = [:]
        dict["hr"] = "\(sample.quantity.doubleValue(for: HKUnit(from: "count/min")))"
        dict["startDate"] = "\(sample.startDate)"
        dict["endDate"] = "\(sample.endDate)"
        return dict
    }
    
    static func resultViaHTTP(results: [HKQuantitySample]){
        var toSend: [[String: String]] = []
        for result in results{
            toSend.append(sampleToDict(sample: result))
        }
        
        var request = URLRequest(url: URL(string: "http://169.254.84.138:8080/AppleWatchDataReceiver/Receiver")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if JSONSerialization.isValidJSONObject(toSend){
            do{
                let data = try JSONSerialization.data(withJSONObject: toSend, options: JSONSerialization.WritingOptions.prettyPrinted)
                request.httpBody = data
                let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                    if error != nil{
                        print(error)
                        return
                    }
                }
                task.resume()
            }catch{
                print("Error while sending JSON via HTTP")
            }
        }else{
            print("Invalid JSON Object")
        }
    }
    
}
