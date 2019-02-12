//
//  QuestionsViewController.swift
//  HappyLottery
//
//  Created by 杉田 尚哉 on 2019/02/12.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class QuestionsViewController: UIViewController {

    @IBOutlet weak private var economyGradeSegCon: UISegmentedControl!
    @IBOutlet weak private var effortGradeSegCon: UISegmentedControl!
    @IBOutlet weak private var schoolStageSegCon: UISegmentedControl!
    @IBOutlet weak private var childrenSegCon: UISegmentedControl!
    @IBOutlet weak private var totalBudgetSegCon: UISegmentedControl!
    
    let economyRate = BehaviorRelay<Int>(value: 0)
    let effortRate = BehaviorRelay<Int>(value: 0)
    let schoolRate = BehaviorRelay<Int>(value: 0)
    let childrenRate = BehaviorRelay<Int>(value: 0)
    let totalBudgetRate = BehaviorRelay<Int>(value: 0)
    
    private let disposeBag = DisposeBag()
    
    enum EconomyGrade {
        case good
        case fair
        case poor
        
        var rate: Double {
            // FIXME: 計算ロジックを考える
            switch self {
            case .good: return 1.2
            case .fair: return 1
            case .poor: return 0.8
            }
        }
    }
    
    enum EffortGrade {
        case good
        case fair
        case poor
        
        var rate: Double {
            // FIXME: 計算ロジックを考える
            switch self {
            case .good: return 1.2
            case .fair: return 1
            case .poor: return 0.8
            }
        }
    }
    
    enum SchoolStage {
        case preschool
        case elementarySchool
        case juniorHighSchool
        case highSchool
        case university
        
        var rate: Double {
            // FIXME: 計算ロジックを考える
            switch self {
            case .preschool: return 500
            case .elementarySchool: return 2000
            case .juniorHighSchool: return 5000
            case .highSchool: return 7000
            case .university: return 10000
            }
        }
    }
    
    enum Children {
        case one
        case two
        case three
        case four
        case overFive
        
        var rate: Double {
            // FIXME: 計算ロジックを考える
            switch self {
            case .one: return 500
            case .two: return 2000
            case .three: return 5000
            case .four: return 7000
            case .overFive: return 10000
            }
        }
    }
    
    enum TotalBudget: Double {
        case low     // 10000円
        case middle  // 30000円
        case high    // 50000円
        case more    // それ以上
        
        var rate: Double {
            // FIXME: 計算ロジックを考える
            switch self {
            case .low: return 500
            case .middle: return 2000
            case .high: return 5000
            case .more: return 7000
            }
        }
    }
    
    private var economyGrade: EconomyGrade = .good
    private var effortGrade: EffortGrade = .good
    private var schoolStage: SchoolStage = .preschool
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    func bind() {
        economyGradeSegCon.rx.selectedSegmentIndex
            .subscribe(onNext: { [unowned self] index in
                
            })
            .disposed(by: disposeBag)
        
        effortGradeSegCon.rx.selectedSegmentIndex
            .subscribe(onNext: { [unowned self] index in
                
            })
            .disposed(by: disposeBag)
        
        schoolStageSegCon.rx.selectedSegmentIndex
            .subscribe(onNext: { [unowned self] index in
                
            })
            .disposed(by: disposeBag)
        
        childrenSegCon.rx.selectedSegmentIndex
            .subscribe(onNext: { [unowned self] index in
                
            })
            .disposed(by: disposeBag)
        
        totalBudgetSegCon.rx.selectedSegmentIndex
            .subscribe(onNext: { [unowned self] index in
                
            })
            .disposed(by: disposeBag)
    }
}
