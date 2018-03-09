//
//  TweetsTabScreen.swift
//  PregBuddy Tweets
//
//  Created by CBH iOS on 09/03/18.
//  Copyright © 2018 MM iOS. All rights reserved.
//

import UIKit
import TwitterKit

class TweetsTabScreen: UIViewController {
    
    @IBOutlet weak var mSegment: UISegmentedControl!
    var pregBuddyShared = PregBuddyShared()
    var tweetsFullData = NSMutableArray()
    var tweetsTableData = NSMutableArray()

    @IBOutlet weak var mTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecent100Tweets()
    }
    
    func loadRecent100Tweets() {
        if (TWTRTwitter.sharedInstance().sessionStore.session() != nil) {
            let twError:NSErrorPointer = nil
            let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID
            let client = TWTRAPIClient(userID: userID)
            let request = client.urlRequest(withMethod: "GET", urlString: "https://api.twitter.com/1.1/search/tweets.json", parameters: ["q":"#pregnancy","result_type":"recent", "count":"100"], error: twError)
            client.sendTwitterRequest(request) { (response, data, error) in
                do {
                    if (data != nil) {
                        let j = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                        self.tweetsTableData = NSMutableArray.init(array: j.value(forKey: "statuses") as! NSArray)
                        self.filterDataWithFormat(sender: 0)
                    }
                    else {
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                            return
                        }
                        let shipAddressScreen = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
                        appDelegate.window?.rootViewController? = shipAddressScreen!
                        appDelegate.window?.makeKeyAndVisible()
                    }
                }
                catch let error
                {
                    print(error)
                }
            }
        }
    }
    @IBAction func filterSegmentSelectAction(_ sender: UISegmentedControl) {
        filterDataWithFormat(sender:sender.selectedSegmentIndex)
    }
    
    func filterDataWithFormat(sender: Int) {
        var sortType = "created_at"
        if (sender == 1) {
            //Most Tweeted
            sortType = "retweet_count"
        }
        let sortDescriptor = NSSortDescriptor(key: sortType, ascending: false)
        let mTableData = self.tweetsTableData as NSArray
        self.tweetsTableData =  NSMutableArray.init(array: mTableData.sortedArray(using: [sortDescriptor]))
        self.mTableView.reloadData()
    }
    
    func saveBookMark(_ single: NSDictionary) {
        if (isBookmarked(single: single) == true) {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedContext = appDelegate?.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookMarkTweet")
            
            // Add Predicate
            let predicate = NSPredicate(format: "tweetId == %@", single.value(forKey: "id") as! CVarArg)
            fetchRequest.predicate = predicate
            
            do {
                let records = try managedContext?.fetch(fetchRequest) as! [NSManagedObject]
                
                if (records.count != 0) {
                    managedContext?.delete(records.last!)
                    self.mTableView.reloadData()
                }
            } catch {
                print(error)
            }
        }
        else {
            let tweetId = single.value(forKey: "id") as? Int64
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: "BookMarkTweet",
                                                    in: managedContext)!
            
            let lBookMarkTweet = NSManagedObject(entity: entity,
                                                 insertInto: managedContext)
            
            lBookMarkTweet.setValue(tweetId, forKeyPath: "tweetId")
            lBookMarkTweet.setValue(pregBuddyShared.convertStringFromJSON(obj:single), forKeyPath: "tweetData")
            
            do {
                try managedContext.save()
                self.mTableView.reloadData()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        }
    }
    
    func isBookmarked(single:NSDictionary) -> Bool {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookMarkTweet")
        
        // Add Predicate
        let predicate = NSPredicate(format: "tweetId == %@", single.value(forKey: "id") as! CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            let records = try managedContext?.fetch(fetchRequest) as! [NSManagedObject]
            
            if (records.count != 0) {
                return true
            }
        } catch {
            print(error)
        }
        
        return false
    }
    
}

extension TweetsTabScreen: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (currentPage == totalItems || totalItems == tweetsTableData.count) {
            return tweetsTableData.count;
        }
        return tweetsTableData.count + 1;

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lTweetsTabTableCell = tableView.dequeueReusableCell(withIdentifier: "TweetsTabTableCellId") as! TweetsTabTableCell
        let single = tweetsTableData[indexPath.row] as! NSDictionary
        let user = single.value(forKey: "user") as! NSDictionary
        
        lTweetsTabTableCell.lblName.text = user.value(forKey: "name") as? String
        var tweet = ""
        if (single.value(forKey: "retweeted_status") != nil) {
            tweet = ((single.value(forKey: "retweeted_status") as? NSDictionary)?.value(forKey: "text") as? String)!
        }
        else {
            tweet = (single.value(forKey: "text") as? String)!
        }
        
        
        lTweetsTabTableCell.lblTweet.text = tweet
        
        lTweetsTabTableCell.lblCreatedAt.text = pregBuddyShared.getTimeAgoFromDate(single.value(forKey: "created_at") as! String)
        let img = lTweetsTabTableCell.contentView.viewWithTag(55) as! UIImageView
        if (isBookmarked(single: single) == true) {
            img.image = #imageLiteral(resourceName: "bookmark")
        }
        else {
            img.image = #imageLiteral(resourceName: "unbookmark")
        }
        
        lTweetsTabTableCell.onTapBookmarkBtn = {
            self.saveBookMark(single)
        }
        
        return lTweetsTabTableCell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (self.tweetsTableData.count - 4  < indexPath.row) {
            print(indexPath)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
}
