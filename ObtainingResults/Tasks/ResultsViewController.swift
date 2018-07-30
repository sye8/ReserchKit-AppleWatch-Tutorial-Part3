//
//  ResultsViewController.swift
//  ObtainingResults
//
//  Created by 叶思帆 on 27/07/2018.
//  Copyright © 2018 Sifan Ye. All rights reserved.
//

import UIKit

import ResearchKit

class ResultsViewController: UIViewController{
    
    @IBOutlet var graphChartView: ORKLineGraphChartView!
    let dataSource = HeartRateDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        graphChartView.dataSource = dataSource
        dataSource.updatePlotPoints(newPlotPoints: TaskResults.hrPlotPoints)
        graphChartView.tintColor = UIColor(red: 255/255, green: 41/255, blue: 135/255, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        refresh()
    }
    
    func refresh(){
        if(TaskResults.startDate != Date.distantPast && TaskResults.endDate != Date.distantFuture){
            ResultParser.getHKData(startDate: TaskResults.startDate, endDate: TaskResults.endDate)
            dataSource.updatePlotPoints(newPlotPoints: TaskResults.hrPlotPoints)
            graphChartView.reloadData()
        }
    }
}

