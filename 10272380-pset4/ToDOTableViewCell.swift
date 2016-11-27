//
//  ToDOTableViewCell.swift
//  10272380-pset4
//
//  Created by Quinten van der Post on 22/11/2016.
//  Copyright © 2016 Quinten van der Post. All rights reserved.
//

import UIKit

protocol ToDOTableViewCellDelegate {
    func todoCheckTapped(cell: ToDOTableViewCell)
}

class ToDOTableViewCell: UITableViewCell {

    @IBOutlet weak var todoTitle: UITextView!
    @IBOutlet weak var todoDesc: UITextView!
    @IBOutlet weak var todoCheck: UIButton!
    var expanded = false
    var done = false
    var delegate: ToDOTableViewCellDelegate?
    
    @IBAction func todoCheckTapped(_ sender: Any) {
        if let _ = delegate {
            delegate?.todoCheckTapped(cell: self)
            updateImage()
        }
        
    }
    
    
    func updateImage() {
        if done == true {
            todoCheck.setImage(UIImage(named: "checkMark"), for: .normal)
        }
        else {
            todoCheck.setImage(nil, for: .normal)
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    

}
