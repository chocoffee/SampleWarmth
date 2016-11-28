//
//  NotifyListTableViewCell.swift
//  SilentWarmth
//
//  Created by guest on 2016/11/28.
//  Copyright © 2016年 chocoffee. All rights reserved.
//

import UIKit

class NotifyListTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var strLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(_ title: String, str: String) {
        titleLabel.text = title
        strLabel.text = str
    }

}
