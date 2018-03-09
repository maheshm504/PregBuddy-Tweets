//
//  TweetsTabTableCell.swift
//  PregBuddy Tweets
//
//  Created by CBH iOS on 09/03/18.
//  Copyright © 2018 MM iOS. All rights reserved.
//

import UIKit

class TweetsTabTableCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTweet: UILabel!
    @IBOutlet weak var lblCreatedAt: UILabel!
    @IBOutlet weak var btnBookMark: UIButton!
    var onTapBookmarkBtn : (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func bookMarkBtnAction(_ sender: UIButton) {
        if sender == self.btnBookMark {
            onTapBookmarkBtn!()
        }
    }
}
