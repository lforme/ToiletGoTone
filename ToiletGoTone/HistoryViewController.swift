//
//  HistoryViewController.swift
//  ToiletGoTone
//
//  Created by mugua on 2019/6/13.
//  Copyright © 2019 mugua. All rights reserved.
//
import ChameleonFramework
import UIKit
import MJRefresh
import PKHUD


class HistoryCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var buildingLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var evaluateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 7
        
        let randomColor = UIColor.randomFlat
        
        bgView.backgroundColor = randomColor
        [buildingLabel, streetLabel, evaluateLabel].forEach { $0?.textColor = ContrastColorOf(randomColor, returnFlat: true) }
        
    }
    
    func bindData(building: String?, street: String?, evaluate: String?) {
        buildingLabel.text = building
        streetLabel.text = street
        evaluateLabel.text = evaluate
    }
}

class HistoryViewController: UITableViewController {
    
    var datasource: [HistoryModel] = []
    var vm: HistoryModel!
    private var page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppDelegate.changeStatusBarStyle(.default)
        
        title = "收藏的厕所"
        guard let id = AVUser.current()?.objectId else {
            HUD.flash(.label("无法获取用户ID"), delay: 2)
            return
        }
        
        vm = HistoryModel(id: id)
        
        setupTableView()
    }
    
    func setupTableView() {
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.estimatedRowHeight = 120
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[unowned self] in
            self.vm?.fetchLabelMoels(page: 0).subscribe(onNext: { (data) in
                self.page = 0
                self.datasource = data
                self.tableView.reloadData()
                self.tableView.mj_header.endRefreshing()
            }, onError: {[unowned self] (error) in
                HUD.flash(.label(error.localizedDescription), delay: 2)
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
            }).disposed(by: self.rx.disposeBag)
        })
        
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[unowned self] in
            self.page += 1
            self.vm?.fetchLabelMoels(page: self.page).subscribe(onNext: { (models) in
                self.datasource += models
                if models.count == 0 {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.mj_footer.endRefreshing()
                }
                self.tableView.reloadData()
            }, onError: {[unowned self] (error) in
                HUD.flash(.label(error.localizedDescription), delay: 2)
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
            }).disposed(by: self.rx.disposeBag)
            
        })
        
        tableView.mj_header.beginRefreshing()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return datasource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        
        let d = datasource[indexPath.row]
        cell.bindData(building: d.buildingName, street: d.street, evaluate: d.evaluate)
        return cell
    }
}
