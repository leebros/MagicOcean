//
//  ViewController.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/8.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh


class DropletsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var data:NSArray = []
    var needReload:Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 0.19, green: 0.56, blue: 0.91, alpha: 1)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.translucent = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView.init(frame: CGRectZero)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        setupMJRefresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Account.sharedInstance.loadUser()
        if Account.sharedInstance.Access_Token != "" {
            if needReload {
                self.loadDroplets(0, per_page:10)
                needReload = false
            }
        } else {
            self.performSegueWithIdentifier("gotologin", sender: nil)
        }
    }
    
    func setupMJRefresh() {
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction:#selector(mjRefreshData))
        header.automaticallyChangeAlpha = true;
        
        header.lastUpdatedTimeLabel.hidden = true;
        self.tableView.mj_header = header;
        
        self.tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            
        })
    }
    
    func mjRefreshData() {
        self.loadDroplets(0, per_page:10)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier:String = "dropletscell"
        let cell:DropletsCell = tableView.dequeueReusableCellWithIdentifier(identifier) as! DropletsCell
        let dic:NSDictionary = data.objectAtIndex(indexPath.row) as! NSDictionary
        cell.titleLabel.text = dic.valueForKey("name") as? String
        let imageDic:NSDictionary = dic.valueForKey("image") as! NSDictionary
        let regionDic:NSDictionary = dic.valueForKey("region") as! NSDictionary
        let sizeDic:NSDictionary = dic.valueForKey("size") as! NSDictionary
        
        let imageSlug:String = imageDic.valueForKey("slug") as! String
        let regionSlug:String = regionDic.valueForKey("slug") as! String
        let sizeSlug:String = sizeDic.valueForKey("slug") as! String
        let disksizeSlug:Int = sizeDic.valueForKey("disk") as! Int
        
        
        cell.infoLabel.text = "\(imageSlug) - \(regionSlug) - \(sizeSlug) - \(disksizeSlug)G"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func loadDroplets(page: Int, per_page: Int) {
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        weak var weakSelf = self
        Alamofire.request(.GET, BASE_URL+URL_DROPLETS+"?page=\(page)&per_page=\(per_page)", parameters: nil, encoding: .URL, headers: Headers).responseJSON { response in
            if let _ = weakSelf {
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
                self.data = (dic.valueForKey("droplets") as? NSArray)!
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.mj_header.endRefreshing()
                    self.tableView.reloadData()
                })
            }
        }
    }
}
