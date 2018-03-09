//
//  BookmarksTabScreen.swift
//  PregBuddy Tweets
//
//  Created by CBH iOS on 09/03/18.
//  Copyright © 2018 MM iOS. All rights reserved.
//

import UIKit
import CoreData

class BookmarksTabScreen: UIViewController {
    
    var tweets: [NSManagedObject] = []
    var pregBuddyShared = PregBuddyShared()

    @IBOutlet weak var mTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BookMarkTweet")
        do {
            tweets = try managedContext.fetch(fetchRequest)
            self.mTableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

}
// MARK: - UITableViewDataSource
extension BookmarksTabScreen: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tweet = tweets[indexPath.row]
        let lTweetsTabTableCell = tableView.dequeueReusableCell(withIdentifier: "TweetsTabTableCellId2") as! TweetsTabTableCell
        let single = pregBuddyShared.convertJSONFromString(obj:(tweet.value(forKeyPath: "tweetData") as? String)!) as! NSDictionary
        let user = single.value(forKey: "user") as! NSDictionary
        
        
        lTweetsTabTableCell.lblName.text = user.value(forKey: "name") as? String
        var tweetTitle = ""
        if (single.value(forKey: "retweeted_status") != nil) {
            tweetTitle = ((single.value(forKey: "retweeted_status") as? NSDictionary)?.value(forKey: "text") as? String)!
        }
        else {
            tweetTitle = (single.value(forKey: "text") as? String)!
        }
        
        lTweetsTabTableCell.lblTweet.text = tweetTitle
        
        lTweetsTabTableCell.lblCreatedAt.text = pregBuddyShared.getTimeAgoFromDate(single.value(forKey: "created_at") as! String)

        return lTweetsTabTableCell
    }
}
