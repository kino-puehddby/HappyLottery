//
//  ResultViewController.swift
//  HappyLottery
//
//  Created by 杉田 尚哉 on 2019/02/15.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import BubbleTransition

final class ResultViewController: UIViewController {
    
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var resultLabel: UILabel!
    @IBOutlet weak private var closeButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    var name: String = ""
    var result: Double = 0.0
    
    weak var interactiveTransition: BubbleInteractiveTransition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = L10n.Result.name(name)
        resultLabel.text = L10n.Result.result(Int(result))
        
        closeButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true)
                self.interactiveTransition?.finish()
            })
            .disposed(by: disposeBag)
    }
}
